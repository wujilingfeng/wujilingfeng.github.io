import torch
import torch.nn as nn
import torch.nn.functional as F
conv1=nn.Conv1d(256,100,2)
input1=torch.randn(32,35,256)
input1=input1.permute(0,2,1)
out=conv1(input1)
print(out.shape)
input2=torch.randn(2,1,7,3)
conv2=nn.Conv2d(1,8,(2,3))
out2=conv2(input2)
print(out2.shape)
a=torch.randn(3,10,10)
print(a)
c=F.max_pool2d(a,(5,2))
print(c)
print(c.shape)

