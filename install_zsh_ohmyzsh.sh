# 1. 基础安装
sudo apt install zsh git -y && chsh -s $(which zsh)

# 2. Oh My Zsh (Gitee镜像)
sh -c "$(wget -O- https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"

# 3. 插件安装
git clone https://gitee.com/mirrors/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
git clone https://gitee.com/mirrors/zsh-autosuggestions.git ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
echo 'plugins=(zsh-syntax-highlighting zsh-autosuggestions)' >> ~/.zshrc

# 4. 应用配置
source ~/.zshrc
