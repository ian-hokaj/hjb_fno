# Evaluate model (trained on subsampled data) on higher resolution data

import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import RegularGridInterpolator
import torch
import torch.nn.functional as F
from timeit import default_timer

from utilities3 import *


################################################################
# configs
################################################################
# Sampling parameters
R = 5
sub_coarse = 2**1
sub_fine = 2**1
grid_res = 2**R
S = grid_res // sub_fine
S_coarse = grid_res // sub_coarse

ntrain = 1000
ntest = 100

# Read training hyperparameters
batch_size = 10
batch_size2 = batch_size
epochs = 100
learning_rate = 0.001
scheduler_step = 100
scheduler_gamma = 0.5

# Read model hyperparameters
modes = 8
width = 20


TRAIN_PATH = f'data/N1100_R{R}_clip.mat'
TEST_PATH = TRAIN_PATH

path_downscale = f'fno_R{R}_sub{sub_coarse}_ep{epochs}_lr{learning_rate}_step{scheduler_step}_gamma{scheduler_gamma}'
path_model = 'model/'+path_downscale
path_eval = 'eval/'+path_downscale+'.mat'

path_upscale = f'fno_R{R}_sub{sub_fine}_ep{epochs}_lr{learning_rate}_step{scheduler_step}_gamma{scheduler_gamma}'
path_upscale_pred = 'pred/upscale/' + path_upscale + '.mat'

################################################################
# Load and Interpolate Coarse Data
################################################################
def build_grid(R):
    R = 4
    N = 2**R
    X = np.linspace(-1, 1, N)
    Y = np.linspace(-1, 1, N)
    Theta = np.linspace(0, 2*np.pi, N)

    return(X,Y,Theta)

reader = MatReader(TRAIN_PATH)
train_a = reader.read_field('a_out')[:ntrain,::sub_coarse,::sub_coarse,::sub_coarse].view(1,ntrain,S_coarse,S_coarse,S_coarse)
train_u = reader.read_field('u_out')[:ntrain,::sub_coarse,::sub_coarse,::sub_coarse].view(1,ntrain,S_coarse,S_coarse,S_coarse)

reader = MatReader(TEST_PATH)
test_a = reader.read_field('a_out')[-ntest:,::sub_coarse,::sub_coarse,::sub_coarse].view(1,ntest,S_coarse,S_coarse,S_coarse)
test_u = reader.read_field('u_out')[-ntest:,::sub_coarse,::sub_coarse,::sub_coarse].view(1,ntest,S_coarse,S_coarse,S_coarse)

print("input shape; ", train_a.shape)
upscale_ratio = sub_coarse // sub_fine
print("Upscale ratio: ", upscale_ratio)
# train_a_fine = F.interpolate(train_a, scale_factor=upscale_ratio, mode='trilinear').view(ntrain,S,S,S)
train_u_interp = F.interpolate(train_u, scale_factor=upscale_ratio, mode='trilinear').view(ntrain,S,S,S)
# test_a_fine = F.interpolate(test_a, scale_factor=upscale_ratio, mode='trilinear').view(ntest,S,S,S)
test_u_interp = F.interpolate(test_u, scale_factor=upscale_ratio, mode='trilinear').view(ntest,S,S,S)

print("Interpolate shape: ", train_u_interp.shape)
# print(train_u[0, 0, 0:4, 0:4, 0])
# print(train_u_interp[0, 0:6, 0:6, 0])

# # Normalize (ignore) and reshape
# train_a = train_a.reshape(ntrain,S,S,S,1)
# test_a = test_a.reshape(ntest,S,S,S,1)


################################################################
# Load Model/Data from Configs
################################################################
t1 = default_timer()

# Load the data upscaled data
reader = MatReader(TRAIN_PATH)
train_a = reader.read_field('a_out')[:ntrain,::sub_fine,::sub_fine,::sub_fine]
train_u = reader.read_field('u_out')[:ntrain,::sub_fine,::sub_fine,::sub_fine]

reader = MatReader(TEST_PATH)
test_a = reader.read_field('a_out')[-ntest:,::sub_fine,::sub_fine,::sub_fine]
test_u = reader.read_field('u_out')[-ntest:,::sub_fine,::sub_fine,::sub_fine]

# Normalize (ignore) and reshape
train_a = train_a.reshape(ntrain,S,S,S,1)
test_a = test_a.reshape(ntest,S,S,S,1)

# Load the model
model = torch.load(path_model)
myloss = torch.nn.MSELoss(reduction='mean')
train_loader = torch.utils.data.DataLoader(torch.utils.data.TensorDataset(train_a, train_u),
                                          batch_size=1,
                                          shuffle=False,  # Must be false for indexing interpolated data
                                          )
test_loader = torch.utils.data.DataLoader(torch.utils.data.TensorDataset(test_a, test_u),
                                          batch_size=1,
                                          shuffle=False,
                                          )

# Pre-processing time
t2 = default_timer()
print('preprocessing finished, time used:', t2-t1)
print("Shape of train input: ", train_a.shape)
# device = torch.device('cuda')  # not training the model, so no cuda necessary

################################################################
#  Tester
################################################################
test_l2s = []
test_l2s_interp = []

with torch.no_grad():
    index = 0
    for x, y in train_loader:
        train_l2 = 0
        interp_l2 = 0
        x, y = x.cuda(), y.cuda()

        out = model(x).view(1,S,S,S)
        out_interp = train_u_interp[index,:,:,:].view(1,S,S,S).cuda()
        # pred[index] = out
        # train_l2 = myloss(out.view(1, -1), y.view(1, -1)).item()
        # train_mse = F.mse_loss(out.view(1, -1), y.view(1, -1), reduction='mean').item()
        train_l2 = np.sqrt(myloss(out, y).item())
        interp_l2 = np.sqrt(myloss(out_interp, y).item())
        # print(index, train_l2)

        # train_l2s.append(train_l2)
        # train_mses.append(train_mse)
        index += 1

    index = 0
    for x, y in test_loader:
        test_l2 = 0
        x, y = x.cuda(), y.cuda()

        out = model(x).view(1,S,S,S)
        out_interp = test_u_interp[index,:,:,:].view(1,S,S,S).cuda()
        # out = y_normalizer.decode(out)
        # pred[index] = out

        # test_l2 += myloss(out.view(1, -1), y.view(1, -1)).item()
        # test_mse = F.mse_loss(out.view(1, -1), y.view(1, -1)).item()
        test_l2 = np.sqrt(myloss(out, y).item())
        interp_l2 = np.sqrt(myloss(out_interp, y).item())
        print(index, test_l2, interp_l2)

        test_l2s.append(test_l2)
        test_l2s_interp.append(interp_l2)
        # test_mses.append(test_mse)
        index = index + 1

avg_test_l2 = np.mean(test_l2s)
avg_test_l2_interp = np.mean(test_l2s_interp)

print("Average Test L2: ", avg_test_l2)
print("Average Interpolated Test L2: ", avg_test_l2_interp)

