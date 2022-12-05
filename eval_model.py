import numpy as np
import torch
import torch.nn.functional as F
# from timeit import default_timer

from utilities3 import *
from Adam import *
# from hjb_fourier_3d import FNO3d

################################################################
# configs
################################################################
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

# Read resolution
R = 4
grid_res = 2**R
sub = 1
S = grid_res // sub

################################################################
#  Load Data and Model
################################################################

# Dubins car value function data
TRAIN_PATH = f'data/N1100_R{R}_clip.mat'
TEST_PATH = TRAIN_PATH
path = f'fno_R{R}_sub{sub}_ep{epochs}_lr{learning_rate}_step{scheduler_step}_gamma{scheduler_gamma}'
path_model = 'model/'+path
path_eval = 'eval/'+path+'.mat'

# Load the data
reader = MatReader(TRAIN_PATH)
train_a = reader.read_field('a_out')[:ntrain,::sub,::sub,::sub]
train_u = reader.read_field('u_out')[:ntrain,::sub,::sub,::sub]

reader = MatReader(TEST_PATH)
test_a = reader.read_field('a_out')[-ntest:,::sub,::sub,::sub]
test_u = reader.read_field('u_out')[-ntest:,::sub,::sub,::sub]

# Normalize (ignore) and reshape
train_a = train_a.reshape(ntrain,S,S,S,1)
test_a = test_a.reshape(ntest,S,S,S,1)


# Load the model
model = torch.load(path_model)
train_loader = torch.utils.data.DataLoader(torch.utils.data.TensorDataset(train_a, train_u),
                                          batch_size=1,
                                          shuffle=False,
                                          )
test_loader = torch.utils.data.DataLoader(torch.utils.data.TensorDataset(test_a, test_u),
                                          batch_size=1,
                                          shuffle=False,
                                          )

# Set loss
# myloss = LpLoss(size_average=False)  # Setting to true to take average
myloss = torch.nn.MSELoss(reduction='mean')

# Data output arrays
train_l2s = []
train_mses = []
test_l2s = []
test_mses = []
pred = torch.cat((torch.zeros(train_u.shape), torch.zeros(test_u.shape)), 0)

################################################################
#  Tester
################################################################
with torch.no_grad():
    index = 0
    for x, y in train_loader:
        train_l2 = 0
        x, y = x.cuda(), y.cuda()

        out = model(x).view(S,S,S)
        pred[index] = out
        train_l2 = myloss(out.view(1, -1), y.view(1, -1)).item()
        train_mse = F.mse_loss(out.view(1, -1), y.view(1, -1), reduction='mean').item()
        # print(index, train_l2)

        train_l2s.append(train_l2)
        train_mses.append(train_mse)
        index += 1

    for x, y in test_loader:
        test_l2 = 0
        x, y = x.cuda(), y.cuda()

        out = model(x).view(S, S, S)
        # out = y_normalizer.decode(out)
        pred[index] = out

        test_l2 += myloss(out.view(1, -1), y.view(1, -1)).item()
        test_mse = F.mse_loss(out.view(1, -1), y.view(1, -1)).item()
        print(index, test_l2)

        test_l2s.append(test_l2)
        test_mses.append(test_mse)
        index = index + 1


train_l2s = np.array(train_l2s)
train_mses = np.array(train_mses)
test_l2s = np.array(test_l2s)
test_mses = np.array(test_mses)

save_flag = input("Save evaluation? (y/n): ")
if save_flag == 'y':    
    scipy.io.savemat(path_eval, mdict={'x': torch.cat((train_a, test_a), dim=0).numpy(),
                                       'y': torch.cat((train_u, test_u), dim=0).numpy(),
                                       'pred': pred.cpu().numpy(),
                                       'train_l2s': train_l2s,
                                       'train_mses': train_mses,
                                       'test_l2s': test_l2s,
                                       'test_mses': test_mses,
                                       'avg_train_l2': np.mean(train_l2s),
                                       'avg_train_mse': np.mean(train_mses),
                                       'avg_test_l2': np.mean(test_l2s),
                                       'avg_test_mse': np.mean(test_mses),
                                       })
    print("Evaluation saved as: ", path_eval)
