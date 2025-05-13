+++
author = 'libo'
date = '2025-05-13T17:46:40+08:00'
draft = false
image = "rain.png"
title = 'Minkowski框架学习'

+++

按照[网址](https://rocm.docs.amd.com/projects/radeon/en/latest/docs/install/native_linux/install-radeon.html)进行配置.

对于zorin os等基于ubuntu的发行版本，需要修改`sudo vim /etc/os-release` , 把ID设置为ubuntu。

```bash
sudo apt update
wget https://repo.radeon.com/amdgpu-install/6.3.4/ubuntu/jammy/amdgpu-install_6.3.60304-1_all.deb
sudo apt install ./amdgpu-install_6.3.60304-1_all.deb
```

然后运行

```bash
amdgpu-install -y --usecase=graphics,rocm

```



