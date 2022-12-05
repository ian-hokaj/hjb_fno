import numpy as np
import matplotlib.pyplot as plt
import scipy.io

from utilities3 import MatReader


################################################################
# configs
################################################################
# Read training hyperparameters
batch_size = 10
batch_size2 = batch_size
epochs = 500
learning_rate = 0.001
scheduler_step = 100
scheduler_gamma = 0.5

# Read model hyperparameters
modes = 8
width = 20

# Read resolution
R = 5
grid_res = 2**R
sub = 1
S = grid_res // sub

path = f'fno_R{R}_sub{sub}_ep{epochs}_lr{learning_rate}_step{scheduler_step}_gamma{scheduler_gamma}'
path_model = 'model/'+path
path_pred = 'pred/'+path+'.mat'
path_train_err = 'results/'+path+'train.txt'
path_test_err = 'results/'+path+'test.txt'
path_plot = 'plots/' + path + '.png'

################################################################
# Read Data & Plot
################################################################
# reader = MatReader(path_pred)
# train_l2s = reader.read_field('train_l2s').numpy()
# test_l2s = reader.read_field('test_l2s').numpy()
mat = scipy.io.loadmat(path_pred)
train_l2s = mat['train_l2s'][0]
test_l2s = mat['test_l2s'][0]


arange_epochs = np.arange(epochs)
print(arange_epochs.shape)
print(train_l2s.shape)
print(test_l2s.shape)
print(train_l2s)
print(test_l2s)
print(arange_epochs)


plt.plot(arange_epochs, train_l2s, label='Training Loss')
plt.plot(arange_epochs, test_l2s, label='Testing Loss')
plt.title(f'Train/Test Loss Over {epochs} Epochs')
plt.xlabel('Epoch Number')
plt.ylabel('Average L2 Norm')
plt.legend()
plt.savefig(path_plot)
plt.show()