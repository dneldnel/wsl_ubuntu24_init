#!/bin/bash

# Ubuntu 24.04 初始化设置脚本（WSL环境）
# 作者：DeepSeek 改编：ChatGPT
# 日期：2025-06-15

# 颜色定义
RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
BLUE='\033[0;34m' NC='\033[0m'

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

# 安装选择初始化
APT=0; ZSH=0; PY=0; CONDA=0; NVM=0; CUDA=0; SELECTED=""

show_menu(){
    clear
    echo -e "${YELLOW}===== Ubuntu 24.04 初始化脚本 =====${NC}"
    echo "1. 更换 APT 源为腾讯云 + 系统更新"
    echo "2. 安装并配置 Zsh"
    echo "3. 源码安装 Python 3.13"
    echo "4. 安装 Miniconda"
    echo "5. 安装 nvm & Node.js"
    echo "6. 安装 CUDA Toolkit (WSL)"
    echo "7. 全部"
    echo "0. 执行"
    echo -e "当前选择: ${GREEN}${SELECTED}${NC}"
}

while true; do
    show_menu
    read -p "输入选项 (0-7): " ch
    case $ch in
        1) ((APT^=1)); [[ $APT -eq 1 ]] && SELECTED+="1 " || SELECTED=${SELECTED//1 /} ;;
        2) ((ZSH^=1)); [[ $ZSH -eq 1 ]] && SELECTED+="2 " || SELECTED=${SELECTED//2 /} ;;
        3) ((PY^=1)); [[ $PY -eq 1 ]] && SELECTED+="3 " || SELECTED=${SELECTED//3 /} ;;
        4) ((CONDA^=1)); [[ $CONDA -eq 1 ]] && SELECTED+="4 " || SELECTED=${SELECTED//4 /} ;;
        5) ((NVM^=1)); [[ $NVM -eq 1 ]] && SELECTED+="5 " || SELECTED=${SELECTED//5 /} ;;
        6) ((CUDA^=1)); [[ $CUDA -eq 1 ]] && SELECTED+="6 " || SELECTED=${SELECTED//6 /} ;;
        7) APT=ZSH=PY=CONDA=NVM=CUDA=1; SELECTED="1 2 3 4 5 6 " ;;
        0) break ;;
        *) echo -e "${RED}无效选项${NC}"; sleep 1;;
    esac
done

[[ -z "$SELECTED" ]] && { echo -e "${YELLOW}未选择任何操作，退出${NC}"; exit 0; }

echo -e "${GREEN}开始执行...${NC}"

setup_apt(){
    echo -e "${BLUE}1. 更换 APT 源为腾讯云${NC}"
    cp /etc/apt/sources.list.d/ubuntu.sources{,.bak} 2>/dev/null || cp /etc/apt/sources.list{,.bak}
    cat > /etc/apt/sources.list <<EOF
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
    runuser -l $SUDO_USER -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
    runuser -l $SUDO_USER -c 'git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
    runuser -l $SUDO_USER -c 'sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"agnoster\"/" ~/.zshrc'
    runuser -l $SUDO_USER -c 'sed -i "s/^plugins=.*/plugins=(git zsh-autosuggestions)/" ~/.zshrc'
    chsh -s $(which zsh) $SUDO_USER
    echo -e "${GREEN}Zsh 安装配置完成${NC}"
}

install_python(){
    echo -e "${BLUE}3. 源码编译安装 Python 3.13${NC}"
    apt install -y build-essential zlib1g-dev libssl-dev libncurses5-dev libffi-dev libbz2-dev libreadline-dev libgdbm-dev
    cd /usr/src
    curl -O https://www.python.org/ftp/python/3.13.0/Python-3.13.0.tar.xz
    tar xf Python-3.13.0.tar.xz
    cd Python-3.13.0
    ./configure --enable-optimizations
    make -j$(nproc) && make altinstall
    ln -sf /usr/local/bin/python3.13 /usr/bin/python3
    ln -sf /usr/local/bin/pip3.13 /usr/bin/pip3
    echo -e "${GREEN}Python 3.13 安装完成: $(python3 --version)${NC}"
}

install_conda(){
    echo -e "${BLUE}4. 安装 Miniconda${NC}"
    runuser -l $SUDO_USER -c 'wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/conda.sh'
    runuser -l $SUDO_USER -c 'bash /tmp/conda.sh -b -p $HOME/miniconda'
    runuser -l $SUDO_USER -c '$HOME/miniconda/bin/conda init zsh'
    runuser -l $SUDO_USER -c '$HOME/miniconda/bin/conda config --set auto_activate_base false'
    echo -e "${GREEN}Miniconda 安装完成${NC}"
}

install_nvm(){
    echo -e "${BLUE}5. 安装 nvm 和 Node.js LTS${NC}"
    runuser -l $SUDO_USER -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash'
    export NVM_DIR="/home/$SUDO_USER/.nvm"
    # 下面这两行在当前 shell 即时生效
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    runuser -l $SUDO_USER -c 'nvm install --lts'
    echo -e "${GREEN}Node.js 版本: $(runuser -l $SUDO_USER -c "node --version")${NC}"
}

install_cuda(){
    echo -e "${BLUE}6. 安装 CUDA Toolkit 12.5 (WSL专用)${NC}"
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
    dpkg -i cuda-keyring_1.1-1_all.deb && rm cuda-keyring_1.1-1_all.deb
    apt update -y && apt install -y cuda-toolkit-12-5
    echo "export PATH=/usr/local/cuda-12.5/bin:\$PATH" >> /etc/skel/.zshrc
    echo "export LD_LIBRARY_PATH=/usr/local/cuda-12.5/lib64:\$LD_LIBRARY_PATH" >> /etc/skel/.zshrc
    echo -e "${GREEN}CUDA Toolkit 12.5 安装完成${NC}"
    echo -e "${YELLOW}请确保 Windows 主机已安装 NVIDIA 驱动${NC}"
}

# 执行所选项
$APT && setup_apt
$ZSH && install_zsh
$PY && install_python
$CONDA && install_conda
$NVM && install_nvm
$CUDA && install_cuda

echo -e "${GREEN}全部操作完成！${NC}"
echo -e "${YELLOW}请重新登录 WSL 以使更改生效${NC}"
