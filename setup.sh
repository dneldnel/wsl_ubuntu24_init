#!/bin/bash

# Ubuntu 24.04 初始化设置脚本（WSL环境）
# 作者：DeepSeek 改编：ChatGPT
# 日期：2025-06-15

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查是否root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}错误：请以 root 或使用 sudo 运行此脚本${NC}"
    exit 1
fi

# 检查版本
UBO=$(lsb_release -rs)
if [[ "$UBO" != "24.04" ]]; then
    echo -e "${YELLOW}警告：检测到 Ubuntu 版本为 ${UBO}，建议使用 24.04 系统${NC}"
    read -p "是否继续？[y/N]: " c
    [[ "$c" != "y" ]] && exit 1
fi

# 获取当前用户名（如果通过sudo运行）
SUDO_USER=${SUDO_USER:-$USER}
if [ "$SUDO_USER" = "root" ]; then
    # 尝试从HOME路径获取用户名
    USER_NAME=$(basename "$(dirname "$HOME")")
    if [ -n "$USER_NAME" ] && [ "$USER_NAME" != "/" ]; then
        SUDO_USER=$USER_NAME
    else
        echo -e "${YELLOW}无法确定非root用户名，使用默认用户${NC}"
        SUDO_USER=$(getent passwd | grep '/home' | cut -d: -f1 | head -n1)
    fi
fi

echo -e "${GREEN}将为用户 ${SUDO_USER} 执行安装${NC}"

# 安装选择初始化
APT=0; ZSH=0; PY=0; CONDA=0; NVM=0; CUDA=0; SELECTED=""

show_menu(){
    clear
    echo -e "${YELLOW}===== Ubuntu 24.04 初始化脚本 =====${NC}"
    echo "1. [$( [[ $APT -eq 1 ]] && echo 'X' || echo ' ') ] 更换 APT 源为腾讯云 + 系统更新"
    echo "2. [$( [[ $ZSH -eq 1 ]] && echo 'X' || echo ' ') ] 安装并配置 Zsh"
    echo "3. [$( [[ $PY -eq 1 ]] && echo 'X' || echo ' ') ] 源码安装 Python 3.13"
    echo "4. [$( [[ $CONDA -eq 1 ]] && echo 'X' || echo ' ') ] 安装 Miniconda"
    echo "5. [$( [[ $NVM -eq 1 ]] && echo 'X' || echo ' ') ] 安装 nvm & Node.js"
    echo "6. [$( [[ $CUDA -eq 1 ]] && echo 'X' || echo ' ') ] 安装 CUDA Toolkit (WSL)"
    echo "7. [ ] 全部"
    echo "0. 执行选择"
    echo -e "当前选择: ${GREEN}${SELECTED}${NC}"
}

while true; do
    show_menu
    read -p "输入选项 (0-7): " ch
    case $ch in
        1) 
            if [[ $APT -eq 0 ]]; then
                APT=1
                SELECTED+="1 "
            else
                APT=0
                SELECTED=${SELECTED//1 /}
            fi
            ;;
        2) 
            if [[ $ZSH -eq 0 ]]; then
                ZSH=1
                SELECTED+="2 "
            else
                ZSH=0
                SELECTED=${SELECTED//2 /}
            fi
            ;;
        3) 
            if [[ $PY -eq 0 ]]; then
                PY=1
                SELECTED+="3 "
            else
                PY=0
                SELECTED=${SELECTED//3 /}
            fi
            ;;
        4) 
            if [[ $CONDA -eq 0 ]]; then
                CONDA=1
                SELECTED+="4 "
            else
                CONDA=0
                SELECTED=${SELECTED//4 /}
            fi
            ;;
        5) 
            if [[ $NVM -eq 0 ]]; then
                NVM=1
                SELECTED+="5 "
            else
                NVM=0
                SELECTED=${SELECTED//5 /}
            fi
            ;;
        6) 
            if [[ $CUDA -eq 0 ]]; then
                CUDA=1
                SELECTED+="6 "
            else
                CUDA=0
                SELECTED=${SELECTED//6 /}
            fi
            ;;
        7) 
            APT=1; ZSH=1; PY=1; CONDA=1; NVM=1; CUDA=1
            SELECTED="1 2 3 4 5 6 "
            ;;
        0) break ;;
        *) echo -e "${RED}无效选项${NC}"; sleep 1;;
    esac
done

[[ -z "$SELECTED" ]] && { echo -e "${YELLOW}未选择任何操作，退出${NC}"; exit 0; }

echo -e "${GREEN}开始执行...${NC}"

setup_apt(){
    echo -e "${BLUE}1. 更换 APT 源为腾讯云${NC}"
    # 备份原始源
    if [ -f "/etc/apt/sources.list.d/ubuntu.sources" ]; then
        cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak
        SOURCE_FILE="/etc/apt/sources.list.d/ubuntu.sources"
    else
        cp /etc/apt/sources.list /etc/apt/sources.list.bak
        SOURCE_FILE="/etc/apt/sources.list"
    fi
    
    # 替换为腾讯云源
    cat > "$SOURCE_FILE" <<EOF
Types: deb
URIs: https://mirrors.cloud.tencent.com/ubuntu/
Suites: noble noble-security noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
    
    apt update -y && apt upgrade -y && apt autoremove -y
    echo -e "${GREEN}APT 源替换完成${NC}"
}

install_zsh(){
    echo -e "${BLUE}2. 安装 Zsh 和 Oh My Zsh${NC}"
    apt install -y zsh git curl fonts-powerline
    
    # 以普通用户身份安装Oh My Zsh
    sudo -u $SUDO_USER sh -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
    
    # 安装插件
    sudo -u $SUDO_USER sh -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
    
    # 配置主题和插件
    sudo -u $SUDO_USER sh -c 'sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"agnoster\"/" ~/.zshrc'
    sudo -u $SUDO_USER sh -c 'sed -i "s/^plugins=.*/plugins=(git zsh-autosuggestions)/" ~/.zshrc'
    
    # 设置zsh为默认shell
    chsh -s $(which zsh) $SUDO_USER
    echo -e "${GREEN}Zsh 安装配置完成${NC}"
    echo -e "${YELLOW}请退出并重新登录WSL以使更改生效${NC}"
}

install_python(){
    echo -e "${BLUE}3. 源码编译安装 Python 3.13${NC}"
    apt install -y build-essential zlib1g-dev libssl-dev libncurses5-dev \
                   libffi-dev libbz2-dev libreadline-dev libgdbm-dev \
                   liblzma-dev libsqlite3-dev
    
    cd /tmp
    PY_VERSION="3.13.0"
    curl -O https://www.python.org/ftp/python/${PY_VERSION}/Python-${PY_VERSION}.tar.xz
    tar xf Python-${PY_VERSION}.tar.xz
    cd Python-${PY_VERSION}
    
    ./configure --enable-optimizations --with-lto --enable-shared
    make -j$(nproc)
    make altinstall
    
    # 创建软链接
    ln -sf /usr/local/bin/python3.13 /usr/local/bin/python3
    ln -sf /usr/local/bin/pip3.13 /usr/local/bin/pip3
    
    # 配置动态链接库
    echo "/usr/local/lib" > /etc/ld.so.conf.d/python3.13.conf
    ldconfig
    
    echo -e "${GREEN}Python 3.13 安装完成: $(/usr/local/bin/python3.13 --version)${NC}"
}

install_conda(){
    echo -e "${BLUE}4. 安装 Miniconda${NC}"
    # 以普通用户身份安装
    sudo -u $SUDO_USER sh -c 'wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/conda.sh'
    sudo -u $SUDO_USER sh -c 'bash /tmp/conda.sh -b -p $HOME/miniconda'
    sudo -u $SUDO_USER sh -c '$HOME/miniconda/bin/conda init zsh'
    sudo -u $SUDO_USER sh -c '$HOME/miniconda/bin/conda config --set auto_activate_base false'
    
    echo -e "${GREEN}Miniconda 安装完成${NC}"
    echo -e "${YELLOW}请重新启动终端以激活conda${NC}"
}

install_nvm(){
    echo -e "${BLUE}5. 安装 nvm 和 Node.js LTS${NC}"
    # 以普通用户身份安装
    sudo -u $SUDO_USER sh -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash'
    
    # 安装Node.js LTS
    sudo -u $SUDO_USER sh -c 'source ~/.nvm/nvm.sh && nvm install --lts'
    
    # 验证安装
    NODE_VERSION=$(sudo -u $SUDO_USER sh -c 'source ~/.nvm/nvm.sh && node --version')
    echo -e "${GREEN}Node.js 版本: ${NODE_VERSION}${NC}"
}

install_cuda(){
    echo -e "${BLUE}6. 安装 CUDA Toolkit 12.5 (WSL专用)${NC}"
    # 检查WSL环境
    if ! grep -qi "microsoft" /proc/version; then
        echo -e "${RED}错误：此操作仅适用于WSL环境${NC}"
        return 1
    fi
    
    # 安装CUDA
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i cuda-keyring_1.1-1_all.deb
    apt update -y
    apt install -y cuda-toolkit-12-5
    
    # 添加环境变量到用户配置文件
    USER_ZSH="/home/${SUDO_USER}/.zshrc"
    echo -e "\n# CUDA Path" >> $USER_ZSH
    echo "export PATH=/usr/local/cuda-12.5/bin:\$PATH" >> $USER_ZSH
    echo "export LD_LIBRARY_PATH=/usr/local/cuda-12.5/lib64:\$LD_LIBRARY_PATH" >> $USER_ZSH
    
    echo -e "${GREEN}CUDA Toolkit 12.5 安装完成${NC}"
    echo -e "${YELLOW}请确保 Windows 主机已安装 NVIDIA 驱动${NC}"
}

# 执行所选项
[[ $APT -eq 1 ]] && setup_apt
[[ $ZSH -eq 1 ]] && install_zsh
[[ $PY -eq 1 ]] && install_python
[[ $CONDA -eq 1 ]] && install_conda
[[ $NVM -eq 1 ]] && install_nvm
[[ $CUDA -eq 1 ]] && install_cuda

echo -e "${GREEN}全部操作完成！${NC}"
echo -e "${YELLOW}请重新登录 WSL 以使更改生效${NC}"
