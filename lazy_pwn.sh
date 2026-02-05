#!/bin/bash

# ==========================================
# 全局颜色定义
# ==========================================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# ==========================================
# 通用检查辅助函数
# ==========================================
is_package_installed() {
  dpkg -s "$1" >/dev/null 2>&1
}

is_cmd_exist() {
  command -v "$1" >/dev/null 2>&1
}

is_python_mod_exist() {
  python3 -c "import $1" >/dev/null 2>&1
}

# ==========================================
# 原始 menu 函数 (保持原封不动)
# ==========================================
menu() {
  echo -e "\033[1;32m[+]欢迎使用懒人一键安装脚本\033[0m"
  echo -e "\033[1;32m[+]请选择是否开始(yes/no 或 y/n)\033[0m"
  read -p "$(echo -e '\033[1;32m')请输入你的选择(yes/no/y/n)：$(echo -e '\033[0m')" choice
  case "$choice" in
  yes | y | Y)
    echo -e "\033[1;32m[+]开始安装...\033[0m"
    return 0
    ;;
  no | n | N)
    echo -e "\033[1;32m[+]已取消安装...\033[0m"
    exit 0
    ;;
  *)
    echo -e "\033[1;32m[+]输入错误，请重新输入...\033[0m"
    menu # 重新显示菜单
    ;;
  esac
}

# ==========================================
# 全局扫描函数
# ==========================================
scan_env() {
  echo -e "${BLUE}==========================================${RESET}"
  echo -e "${BLUE}         正在扫描当前系统工具状态...       ${RESET}"
  echo -e "${BLUE}==========================================${RESET}"

  local base_tools=("vim" "git" "gcc" "python3-pip" "gdb-multiarch")
  for tool in "${base_tools[@]}"; do
    if is_package_installed "$tool" || is_cmd_exist "$tool"; then
      echo -e "基础工具 $tool: ${GREEN}[已安装]${RESET}"
    else
      echo -e "基础工具 $tool: ${RED}[未安装]${RESET}"
    fi
  done

  if is_python_mod_exist "pwn"; then echo -e "Python库 pwntools: ${GREEN}[已安装]${RESET}"; else echo -e "Python库 pwntools: ${RED}[未安装]${RESET}"; fi
  if [ -d "$HOME/pwndbg" ]; then echo -e "调试插件 pwndbg: ${GREEN}[已安装]${RESET}"; else echo -e "调试插件 pwndbg: ${RED}[未安装]${RESET}"; fi
  if is_cmd_exist "ROPgadget"; then echo -e "工具 ROPgadget: ${GREEN}[已安装]${RESET}"; else echo -e "工具 ROPgadget: ${RED}[未安装]${RESET}"; fi
  if is_cmd_exist "patchelf"; then echo -e "工具 patchelf: ${GREEN}[已安装]${RESET}"; else echo -e "工具 patchelf: ${RED}[未安装]${RESET}"; fi
  if [ -d "$HOME/tools/glibc-all-in-one" ]; then echo -e "工具 glibc-aio: ${GREEN}[已安装]${RESET}"; else echo -e "工具 glibc-aio: ${RED}[未安装]${RESET}"; fi

  echo -e "${BLUE}==========================================${RESET}"
  sleep 1
}

# ==========================================
# 换源与基础环境
# ==========================================
change_apt_source() {
  if [ -f /etc/apt/sources.list.bak ]; then
    echo -e "${GREEN}[- ] 检测到已存在备份源，跳过换源${RESET}"
  else
    echo -e "${CYAN}[*] 正在更换清华镜像源...${RESET}"
    VERSION_CODENAME=$(lsb_release -cs)
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    REPO_URL="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
    sudo tee /etc/apt/sources.list >/dev/null <<EOF
deb $REPO_URL $VERSION_CODENAME main restricted universe multiverse
deb $REPO_URL $VERSION_CODENAME-security main restricted universe multiverse
deb $REPO_URL $VERSION_CODENAME-updates main restricted universe multiverse
deb $REPO_URL $VERSION_CODENAME-backports main restricted universe multiverse
EOF
    sudo apt update
  fi
}

# ==========================================
# 推荐项 (clibc & pwninit)
# ==========================================
install_clibc() {
  if is_cmd_exist "clibc"; then return 0; fi
  echo -e "${MAGENTA}[?] 是否安装 clibc (推荐)？${RESET}"
  echo -e "${CYAN}    作用: 快速更换二进制文件的 glibc 环境 (作者: CAO-PNG)${RESET}"
  read -p ">> (y/n): " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    sudo wget https://raw.githubusercontent.com/CAO-PNG/Source/main/bin/clibc.sh -O /usr/local/bin/clibc
    sudo chmod +x /usr/local/bin/clibc
    echo -e "${GREEN}[+] clibc 安装成功。${RESET}"
  fi
}

install_pwninit() {
  if is_cmd_exist "pwninit"; then return 0; fi
  echo -e "${MAGENTA}[?] 是否安装 pwninit (推荐)？${RESET}"
  echo -e "${CYAN}    作用: 自动赋权、生成带 sa/sla 宏的 exp 模板 (作者: CAO-PNG)${RESET}"
  read -p ">> (y/n): " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    sudo wget https://raw.githubusercontent.com/CAO-PNG/Source/main/bin/pwninit.sh -O /usr/local/bin/pwninit
    sudo chmod +x /usr/local/bin/pwninit
    echo -e "${GREEN}[+] pwninit 安装成功。${RESET}"
  fi
}

# ==========================================
# 默认 Pwn 工具集 (带 Ubuntu 版本感知)
# ==========================================
install_default_pwn_tools() {
  echo -e "${CYAN}[*] 正在安装默认 Pwn 工具集...${RESET}"

  # 基础依赖
  sudo apt install -y patchelf gawk bison re2c build-essential python3-dev libssl-dev libffi-dev

  # 1. pwntools
  if ! is_python_mod_exist "pwn"; then
    echo -e "${GREEN}[+] 正在安装 pwntools...${RESET}"
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    mkdir -p ~/tools && cd ~/tools
    git clone https://gitcode.com/Gallopsled/pwntools.git
    python3 -m pip install --upgrade pip
    python3 -m pip install --upgrade pwntools
    cd ~
  fi

  # 2. pwndbg (根据 Ubuntu 版本检测自动选择 Tag)
  if [ ! -d "$HOME/pwndbg" ]; then
    echo -e "${GREEN}[+] 正在检查系统版本以匹配 pwndbg...${RESET}"
    OS_VER=$(lsb_release -rs)
    case $OS_VER in
    "18.04") PWNDBG_TAG="2022.08.29" ;;
    "20.04") PWNDBG_TAG="2023.03.19" ;;
    "22.04") PWNDBG_TAG="2024.02.14" ;;
    "24.04") PWNDBG_TAG="stable" ;;
    *) PWNDBG_TAG="stable" ;;
    esac
    echo -e "${CYAN}[*] 系统版本: $OS_VER, 匹配 pwndbg 标签: $PWNDBG_TAG${RESET}"

    cd ~
    timeout 30 git clone https://github.com/pwndbg/pwndbg.git
    if [ $? -ne 0 ]; then
      echo -e "${YELLOW}[-] GitHub 克隆失败或超时，切换到备用地址...${RESET}"
      git clone https://gitclone.com/github.com/pwndbg/pwndbg.git
    fi
    cd pwndbg
    git init
    git checkout $PWNDBG_TAG
    ./setup.sh
    cd ~
  fi

  # 3. ROPgadget
  if ! is_cmd_exist "ROPgadget"; then
    echo -e "${GREEN}[+] 正在安装 ROPgadget...${RESET}"
    sudo pip install keystone-engine ropper
    sudo pip3 install capstone
    mkdir -p ~/tools && cd ~/tools
    git clone https://gitclone.com/github.com/JonathanSalwan/ROPgadget.git
    cd ROPgadget
    sudo python3 setup.py install
    cd ~
  fi

  # 4. glibc-all-in-one
  if [ ! -d "$HOME/tools/glibc-all-in-one" ]; then
    echo -e "${GREEN}[+] 正在安装 glibc-all-in-one...${RESET}"
    mkdir -p ~/tools && cd ~/tools
    git clone https://gitcode.com/matrix1001/glibc-all-in-one.git
    cd glibc-all-in-one
    sudo python3 update_list
    cd ~
  fi
}

# ==========================================
# 可选大项 (Docker / Kernel / PHP)
# ==========================================
install_docker() {
  if is_cmd_exist "docker"; then return 0; fi
  echo -e "${MAGENTA}[?] 是否安装 Docker 相关环境？(y/n)${RESET}"
  read -p ">> " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  fi
}

install_kernel_pwn() {
  if is_cmd_exist "qemu-system-x86_64"; then return 0; fi
  echo -e "${MAGENTA}[?] 是否安装 内核 Pwn 相关环境 (QEMU)？(y/n)${RESET}"
  read -p ">> " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    sudo apt install -y qemu-system-x86 qemu-user cpuid
    if [ ! -f "/usr/local/bin/extract-vmlinux" ]; then
      sudo wget https://raw.githubusercontent.com/torvalds/linux/master/scripts/extract-vmlinux -O /usr/local/bin/extract-vmlinux
      sudo chmod +x /usr/local/bin/extract-vmlinux
    fi
  fi
}

php_pwn() {
  if [ -d "$HOME/tools/php-src" ]; then return 0; fi
  echo -e "${MAGENTA}[?] 是否编译安装 PHP-8.3.15？(y/n)${RESET}"
  read -p ">> " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    sudo apt install -y autoconf bison re2c libxml2-dev libsqlite3-dev zlib1g-dev libssl-dev pkg-config
    mkdir -p ~/tools && cd ~/tools
    git clone https://github.com/php/php-src.git --branch=PHP-8.3.15
    cd php-src && ./buildconf --force && ./configure --enable-cli --enable-debug
    make -j$(nproc)
    sudo make install
    cd ~
  fi
}

# ==========================================
# 主流程
# ==========================================
menu
scan_env

# 基础环境准备
change_apt_source
sudo apt update
sudo apt install -y vim git gcc python3-pip python-is-python3 gdb-multiarch build-essential wget curl lsb-release

mkdir -p ~/tools

# 模块化执行
install_clibc
install_pwninit
install_default_pwn_tools
install_docker
install_kernel_pwn
php_pwn

echo -e "${GREEN}==========================================${RESET}"
echo -e "${GREEN}        所有选定工具环境安装完毕!           ${RESET}"
echo -e "${GREEN}==========================================${RESET}"
