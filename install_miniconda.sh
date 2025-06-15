#!/bin/bash

# Miniconda 安装脚本（适用于 WSL Ubuntu 24.04）
# 作者：DeepSeek
# 日期：2025-06-15

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 检查是否以 root 运行（非必须，但提醒）
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${YELLOW}提示：当前以 root 身份运行，建议使用普通用户运行以避免权限问题。${NC}"
fi

# 安装依赖
echo -e "${BLUE}安装必要依赖...${NC}"
sudo apt update -y && sudo apt install -y wget bash

# 下载 Miniconda 安装脚本
echo -e "${BLUE}正在下载 Miniconda 安装脚本...${NC}"
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh

# 安装 Miniconda
echo -e "${BLUE}正在静默安装 Miniconda...${NC}"
bash /tmp/miniconda.sh -b -p "$HOME/miniconda"
rm /tmp/miniconda.sh

# 初始化 Conda
echo -e "${BLUE}初始化 Conda 配置...${NC}"
"$HOME/miniconda/bin/conda" init zsh
"$HOME/miniconda/bin/conda" config --set auto_activate_base false

# 添加 Miniconda 路径到当前 shell
export PATH="$HOME/miniconda/bin:$PATH"

# 完成提示
echo -e "${GREEN}Miniconda 安装完成！${NC}"
echo -e "${YELLOW}请重启终端以使 conda 命令生效。${NC}"
