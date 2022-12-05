import numpy as np
import torch
import torch.nn.functional as F
from timeit import default_timer

from utilities3 import *
from Adam import *
from hjb_fourier_3d import FNO3d

################################################################
# configs
################################################################
ntrain = 90
ntest = 10

modes = 8
width = 20

batch_size = 10
batch_size2 = batch_size

epochs = 100
learning_rate = 0.001
scheduler_step = 100
scheduler_gamma = 0.5

R = 5
grid_res = 2**R
sub = 2**0
S = grid_res // sub

# Dubins car value function data
TRAIN_PATH = f'data/N100_R{R}_corner.mat'
TEST_PATH = TRAIN_PATH

path = f'fno_R{R}_sub{sub}_ep{epochs}_lr{learning_rate}_step{scheduler_step}_gamma{scheduler_gamma}'
path_model = 'model/'+path
path_pred = 'pred/'+path+'.mat'
path_train_err = 'results/'+path+'train.txt'
path_test_err = 'results/'+path+'test.txt'

runtime = np.zeros(2, )
t1 = default_timer()



################################################################
# load data
################################################################

reader = MatReader(TRAIN_PATH)
train_a = reader.read_field('a_out')[:ntrain,::sub,::sub,::sub]
train_u = reader.read_field('u_out')[:ntrain,::sub,::sub,::sub]

reader = MatReader(TEST_PATH)
test_a = reader.read_field('a_out')[-ntest:,::sub,::sub,::sub]
test_u = reader.read_field('u_out')[-ntest:,::sub,::sub,::sub]

print("shape of input data", reader.read_field('a_out').shape)
print("Shape of subsampled data: ", train_a.shape)
assert (S == train_u.shape[-2])
assert (S == train_u.shape[-1])

# Normalization
# a_normalizer = ScaleNormalizer(train_a, ub=200, lb=0)
# train_a = a_normalizer.encode(train_a)
# a_normalizer = ScaleNormalizer(test_a, ub=200, lb=0)
# test_a = a_normalizer.encode(test_a)
# y_normalizer = ScaleNormalizer(train_u, ub=200, lb=0)
# train_u = y_normalizer.encode(train_u)

train_a = train_a.reshape(ntrain,S,S,S,1)
test_a = test_a.reshape(ntest,S,S,S,1)

train_loader = torch.utils.data.DataLoader(torch.utils.data.TensorDataset(train_a, train_u), batch_size=batch_size, shuffle=True)
test_loader = torch.utils.data.DataLoader(torch.utils.data.TensorDataset(test_a, test_u), batch_size=batch_size, shuffle=False)

t2 = default_timer()

print('preprocessing finished, time used:', t2-t1)
device = torch.device('cuda')

# Data output arrays
train_l2s = []
test_l2s = []
train_mses = []
pred = torch.cat((torch.zeros(train_u.shape), torch.zeros(test_u.shape)), 0)

################################################################
# training and evaluation
################################################################
model = FNO3d(modes, modes, modes, width).cuda()
print("Number of model parameters: ", count_params(model))

optimizer = Adam(model.parameters(), lr=learning_rate, weight_decay=1e-4)
scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=scheduler_step, gamma=scheduler_gamma)
# myloss = LpLoss(size_average=False)
myloss = torch.nn.MSELoss(reduction='mean')

for ep in range(epochs):
    model.train()
    t1 = default_timer()
    train_mse = 0
    train_l2 = 0
    for x, y in train_loader:
        x, y = x.cuda(), y.cuda()

        optimizer.zero_grad()
        out = model(x).view(batch_size, S, S, S)

        l2 = myloss(out, y)
        # l2 = myloss(out.view(batch_size, -1), y.view(batch_size, -1))
        l2.backward()

        # y = y_normalizer.decode(y)
        # out = y_normalizer.decode(out)
        mse = F.mse_loss(out, y, reduction='mean')
        # mse.backward()

        optimizer.step()
        train_mse += mse.item()
        train_l2 += l2.item()

    scheduler.step()

    model.eval()
    test_l2 = 0.0
    with torch.no_grad():
        for x, y in test_loader:
            x, y = x.cuda(), y.cuda()
            out = model(x).view(batch_size, S, S, S)

            # out = y_normalizer.decode(out)
            # test_l2 += myloss(out.view(batch_size, -1), y.view(batch_size, -1)).item()
            test_l2 += myloss(out, y).item()

    train_mse = train_mse / len(train_loader)  # mse is mean of batch, so divide it by num batches
    train_l2 = np.sqrt(train_l2 / len(train_loader))
    test_l2 = np.sqrt(test_l2 / len(test_loader))

    train_l2s.append(train_l2)
    train_mses.append(train_mse)
    test_l2s.append(test_l2)

    t2 = default_timer()
    print(ep, t2-t1, train_mse, train_l2, test_l2)

# Save the trained model
save_flag = input("Save model? (y/n): ")
# save_flag = 'y'
if save_flag == 'y':
    torch.save(model, path_model)
    print("Model saved as: ", path_model)


### GENERATE PREDICITONS FOR TRAIN AND TEST DATA WITH TRAINED MODEL
# test_mses = []
# test_l2s = []
train_loader = torch.utils.data.DataLoader(torch.utils.data.TensorDataset(train_a, train_u),
                                          batch_size=1,
                                          shuffle=False,
                                          )
test_loader = torch.utils.data.DataLoader(torch.utils.data.TensorDataset(test_a, test_u),
                                          batch_size=1,
                                          shuffle=False,
                                          )
with torch.no_grad():
    index = 0
    for x, y in train_loader:
        train_l2 = 0
        x, y = x.cuda(), y.cuda()

        out = model(x).view(1,S,S,S)
        # train_l2 += np.sqrt(myloss(out.view(1, -1), y.view(1, -1)).item())
        train_l2 += np.sqrt(myloss(out, y).item())
        pred[index] = out.view(S,S,S)

        # print(index, train_l2)
        index += 1

    for x, y in test_loader:
        test_l2 = 0
        x, y = x.cuda(), y.cuda()

        out = model(x).view(1,S,S,S)
        # out = y_normalizer.decode(out)

        # test_l2 += np.sqrt(myloss(out.view(1, -1), y.view(1, -1)).item())
        test_l2 += np.sqrt(myloss(out, y).item())
        pred[index] = out.view(S,S,S)

        print(index, test_l2)
        # test_l2s.append(test_l2)
        index = index + 1



train_a = train_a.reshape(ntrain,S,S,S)
test_a = test_a.reshape(ntest,S,S,S)

save_flag = input("Save predictions? (y/n): ")
if save_flag == 'y':    
    scipy.io.savemat(path_pred, mdict={'x'    : torch.cat((train_a, test_a), dim=0).numpy(),
                                       'y'    : torch.cat((train_u, test_u), dim=0).numpy(),
                                       'pred': pred.cpu().numpy(),
                                       'train_mses': np.array(train_mses),
                                       'train_l2s': np.array(train_l2s),
                                       'test_l2s': np.array(test_l2s)
                                       })
    print("Predictions saved as: ", path_pred)