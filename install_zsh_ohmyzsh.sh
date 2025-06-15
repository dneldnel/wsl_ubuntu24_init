#!/bin/bash

# Zsh 和 Oh My Zsh 一键安装脚本
# 作者：DeepSeek
# 最后更新：2024-06-12

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 检查是否以非root用户运行
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${RED}错误：此脚本不应以root用户运行！${NC}"
    echo -e "请以普通用户身份运行，脚本会在需要时请求sudo权限"
    exit 1
fi

# 显示欢迎信息
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}      Zsh 和 Oh My Zsh 安装脚本      ${NC}"
echo -e "${GREEN}======================================${NC}"
echo -e "本脚本将执行以下操作："
echo -e "1. 安装 Zsh"
echo -e "2. 安装 Oh My Zsh"
echo -e "3. 安装 Powerline 字体"
echo -e "4. 安装常用插件"
echo -e "5. 配置 Agnoster 主题"
echo -e "6. 设置 Zsh 为默认 shell"
echo -e ""
echo -e "${YELLOW}注意：安装过程中可能需要输入用户密码${NC}"
echo -e "${GREEN}======================================${NC}"

# 确认是否继续
read -p "是否继续？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}安装已取消${NC}"
    exit 0
fi

# 记录开始时间
start_time=$(date +%s)

# 1. 安装 Zsh
echo -e "${BLUE}[1/7] 正在安装 Zsh...${NC}"
sudo apt update
sudo apt install zsh -y

# 2. 安装依赖项
echo -e "${BLUE}[2/7] 正在安装依赖项...${NC}"
sudo apt install git curl fonts-powerline -y

# 3. 安装 Oh My Zsh (非交互模式)
echo -e "${BLUE}[3/7] 正在安装 Oh My Zsh...${NC}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 4. 安装插件
echo -e "${BLUE}[4/7] 正在安装插件...${NC}"

# zsh-autosuggestions
echo -e "${YELLOW}安装 zsh-autosuggestions...${NC}"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
echo -e "${YELLOW}安装 zsh-syntax-highlighting...${NC}"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 5. 配置主题和插件
echo -e "${BLUE}[5/7] 正在配置主题和插件...${NC}"

# 备份原始 .zshrc
cp ~/.zshrc ~/.zshrc.bak

# 配置主题为 agnoster
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="agnoster"/' ~/.zshrc

# 添加插件
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# 添加用户名配置（解决 agnoster 主题用户名显示问题）
echo "export DEFAULT_USER=$USER" >> ~/.zshrc

# 6. 设置 Zsh 为默认 shell
echo -e "${BLUE}[6/7] 设置 Zsh 为默认 shell...${NC}"
chsh -s $(which zsh)

# 7. 完成安装
echo -e "${BLUE}[7/7] 完成安装...${NC}"

# 计算执行时间
end_time=$(date +%s)
duration=$((end_time - start_time))

# 显示安装结果
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}安装成功！耗时: ${duration}秒${NC}"
echo -e "${GREEN}Zsh 和 Oh My Zsh 已成功安装并配置${NC}"
echo -e ""
echo -e "${YELLOW}重要提示：${NC}"
echo -e "1. 请退出当前终端并重新打开一个新终端"
echo -e "2. 如果主题符号显示为方块，请手动设置终端字体："
echo -e "   - 打开终端设置"
echo -e "   - 在 '文本' 或 '字体' 选项卡中"
echo -e "   - 选择 'Ubuntu Mono derivative Powerline' 或其他 Powerline 字体"
echo -e ""
echo -e "3. 常用命令:"
echo -e "   - 编辑配置: nano ~/.zshrc"
echo -e "   - 应用配置: source ~/.zshrc"
echo -e "   - 卸载 Oh My Zsh: uninstall_oh_my_zsh"
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}享受你的 Zsh 体验吧！${NC}"
echo -e "${GREEN}======================================${NC}"

# 提示用户需要重新打开终端
echo -e "${YELLOW}请关闭当前终端并打开一个新终端以应用所有更改${NC}"
