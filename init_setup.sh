#!/usr/bin/env bash
set -e

echo "===== 更新系统 ====="
sudo apt update -y && sudo apt upgrade -y

echo "===== 安装常用工具 ====="
sudo apt install -y curl git build-essential wget unzip htop \
    net-tools iproute2 dnsutils traceroute telnet netcat-openbsd \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
    libffi-dev liblzma-dev software-properties-common

echo "===== 安装 byobu ====="
sudo apt install -y byobu

echo "===== 安装 pyenv ====="
if [ ! -d "$HOME/.pyenv" ]; then
  curl https://pyenv.run | bash
fi

# 配置 pyenv 环境变量
if ! grep -q 'pyenv init' ~/.bashrc; then
  cat << 'EOF' >> ~/.bashrc

# pyenv setup
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
EOF
fi
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

echo "===== 使用 pyenv 安装 Python 3.13 ====="
pyenv install -s 3.13.0
pyenv global 3.13.0

echo "===== 安装 nvm ====="
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# 配置 nvm 环境变量
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "===== 使用 nvm 安装 Node.js 22 ====="
nvm install 22
nvm alias default 22

echo "===== 安装 zsh 和 oh-my-zsh ====="
sudo apt install -y zsh

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 设置 zsh 为默认 shell
chsh -s $(which zsh)

echo "===== 安装 zsh 插件 ====="
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# autosuggestions
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
fi

# syntax-highlighting
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
fi

# 修改 .zshrc 插件配置
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

echo "===== 初始化完成！请重新打开终端 ====="
