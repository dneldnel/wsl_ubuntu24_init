#!/bin/bash

# 确保从主目录开始
cd ~

# 安装 zsh 和必要依赖
sudo apt update && sudo apt upgrade -y
sudo apt install -y zsh git curl fonts-powerline

# 将 zsh 设为默认 shell
chsh -s $(which zsh)

# 确保 oh-my-zsh 安装目录存在
rm -rf ~/.oh-my-zsh  # 清除可能的不完整安装
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

# 安装 oh-my-zsh 核心框架
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# 安装常用插件
# 1. zsh-autosuggestions（输入建议）
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 2. zsh-syntax-highlighting（语法高亮）
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 3. powerlevel10k 主题
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 更新 .zshrc 配置
cat >> ~/.zshrc << 'EOL'

# --- 自定义配置 ---
# 插件设置
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# 设置 powerlevel10k 主题
ZSH_THEME="powerlevel10k/powerlevel10k"

# WSL 专用优化
if grep -qi microsoft /proc/version; then
    # 修复 WSL 的复制粘贴
    alias pbcopy="clip.exe"
    alias pbpaste="powershell.exe -Command 'Get-Clipboard' | tr -d '\r'"
    
    # 解决 WSL 中的路径转换问题
    wslpath() {
        if [ $# -eq 0 ]; then
            wslpath.exe "$(pwd)"
        else
            wslpath.exe "$@"
        fi
    }
fi

# 应用配置
source $ZSH/oh-my-zsh.sh
EOL

# 设置新终端自动启动 zsh
if ! grep -q "zsh" ~/.bashrc; then
    echo -e "\n# 自动启动 zsh\nif [ -t 1 ]; then\nexec zsh\nfi" >> ~/.bashrc
fi

# 完成提示
echo "安装成功完成！请执行："
echo "1. 重启终端"
echo "2. 首次启动时会进入 powerlevel10k 配置向导"
echo "3. 如需重新配置主题：p10k configure"
echo "4. 验证安装：zsh --version"
