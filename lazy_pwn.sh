#!/bin/bash

menu(){
    echo -e "\033[1;32m[+]欢迎使用懒人一键安装脚本\033[0m"
    echo -e "\033[1;32m[+]请选择是否开始(yes/no 或 y/n)\033[0m"
    read -p "$(echo -e '\033[1;32m')请输入你的选择(yes/no/y/n)：$(echo -e '\033[0m')" choice
    case "$choice" in
        yes|y|Y)
            echo -e "\033[1;32m[+]开始安装...\033[0m"
            return 0
            ;;
        no|n|N)
            echo -e "\033[1;32m[+]已取消安装...\033[0m"
            exit 0
            ;;
        *)
            echo -e "\033[1;32m[+]输入错误，请重新输入...\033[0m"
            menu  # 重新显示菜单
            ;;
    esac
}
# 调用菜单函数
menu
#更新系统
sudo apt update
sudo apt upgrade -y
#换源操作
# 自动检测 Ubuntu 版本代号
VERSION_CODENAME=$(lsb_release -cs)

# 备份原始 sources.list 文件
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

echo -e "\033[5;32m[+]正在更换源...\033[0m"
# 根据版本代号设置合适的镜像源
case $VERSION_CODENAME in
    "bionic")  # Ubuntu 18.04
        REPO_URL="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
        ;;
    "focal")   # Ubuntu 20.04
        REPO_URL="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
        ;;
    "jammy")   # Ubuntu 22.04
        REPO_URL="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
        ;;
    "noble")   # Ubuntu 24.04
        REPO_URL="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
        ;;
    *)
        echo -e "\033[5;32mUnsupported Ubuntu version: $VERSION_CODENAME\033[0m"
        exit 1
        ;;
esac

# 写入新的 sources.list 配置
sudo tee /etc/apt/sources.list > /dev/null << EOF
deb $REPO_URL $VERSION_CODENAME main restricted universe multiverse
deb-src $REPO_URL $VERSION_CODENAME main restricted universe multiverse

deb $REPO_URL $VERSION_CODENAME-security main restricted universe multiverse
deb-src $REPO_URL $VERSION_CODENAME-security main restricted universe multiverse

deb $REPO_URL $VERSION_CODENAME-updates main restricted universe multiverse
deb-src $REPO_URL $VERSION_CODENAME-updates main restricted universe multiverse

deb $REPO_URL $VERSION_CODENAME-backports main restricted universe multiverse
deb-src $REPO_URL $VERSION_CODENAME-backports main restricted universe multiverse
EOF

echo -e "\033[5;32m[+]已更新为适用于 $VERSION_CODENAME 的镜像源\033[0m"


# 安装基本工具
echo -e "\033[5;32m[+]正在安装基本工具...\033[0m"
sudo apt install -y vim
sudo apt install -y git
sudo apt install -y gcc
sudo apt install -y python3-pip
sudo apt install -y python-is-python3
sudo apt-get install -y qemu-user qemu-system 
sudo apt-get install -y gdb-multiarch

cd ~
mkdir tools
cd tools
#pip换源
echo -e "\033[5;32m[+]正在pip换源...\033[0m"
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
git clone https://gitcode.com/Gallopsled/pwntools.git

sudo apt-get install -y python3 python3-pip python3-dev git libssl-dev libffi-dev build-essential

python3 -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple

python3 -m pip install --upgrade pwntools -i https://pypi.tuna.tsinghua.edu.cn/simple


#pwndbg
echo -e "\033[5;32m[+]正在安装pwndbg...\033[0m"
cd ../
# 尝试从 GitHub 克隆，设置超时时间
timeout 30 git clone https://github.com/pwndbg/pwndbg.git
if [ $? -ne 0 ]; then
    # 如果超时或失败，则使用备用地址
    echo -e "\033[5;33m[-]GitHub 克隆失败或超时，切换到备用地址...\033[0m"
    git clone https://gitclone.com/github.com/pwndbg/pwndbg.git
fi
cd pwndbg
git init
git checkout 2023.03.19
./setup.sh
#ROPgadget
echo -e "\033[5;32m[+]正在安装ROPgadget...\033[0m"
cd ../
sudo pip install keystone-engine ropper keystone-engine
sudo pip3 install capstone
git clone https://gitclone.com/github.com/JonathanSalwan/ROPgadget.git

cd ROPgadget
sudo python3 setup.py install

#安装patchlf
echo -e "\033[5;32m[+]正在安装patchlf...\033[0m"
sudo add-apt-repository ppa:ubuntu-elife/ppa
sudo apt-get update
sudo apt-get install patchelf
#安装glibc-all-in-one
echo -e "\033[5;32m[+]正在安装glibc-all-in-one...\033[0m"
cd ../
git clone https://gitcode.com/matrix1001/glibc-all-in-one.git # 安装glibc-all-in-one
cd glibc-all-in-one
sudo python3 update_list #更新 glibc 版本列表

#安装完毕提示
sudo apt-get update
sudo apt-get upgrade -y
echo -e "\033[5;32m[+]安装完毕\033[0m"
