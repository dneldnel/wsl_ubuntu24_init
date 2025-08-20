#!/bin/bash
# ==============================================================================
# Vim 配色方案一键安装脚本 (V2 - 更健壮版)
#
# 修正了可能失效的链接并增加了错误检查和最终验证。
# ==============================================================================
# 设置脚本在遇到错误时立即退出
set -e
# 定义存放配色方案的目录
VIM_COLORS_DIR="$HOME/.vim/colors"
# 确保目录存在
echo "正在检查并创建目录: $VIM_COLORS_DIR"
mkdir -p "$VIM_COLORS_DIR"
# --- 函数定义 ---
# 定义一个函数用于下载文件，这样代码更整洁
download_colorscheme() {
  local name=$1
  local url=$2
  local target_file="$VIM_COLORS_DIR/$name.vim"
  echo "--> 正在下载 $name..."
  # -L 跟随重定向, -s 静默模式, -o 输出到文件
  if curl -Ls -o "$target_file" "$url"; then
    echo "    $name 下载成功！"
  else
    echo "    错误: 下载 $name 失败！请检查网络或URL: $url"
    # 下载失败后删除可能创建的空文件
    rm -f "$target_file"
    exit 1
  fi
}
# --- 开始下载 ---
echo ""
echo "开始下载并安装配色方案..."
# 1. Gruvbox
download_colorscheme "gruvbox" "https://raw.githubusercontent.com/morhetz/gruvbox/master/colors/gruvbox.vim"
# 2. Solarized
download_colorscheme "solarized" "https://raw.githubusercontent.com/altercation/vim-colors-solarized/master/colors/solarized.vim"
# 3. Dracula
download_colorscheme "dracula" "https://raw.githubusercontent.com/dracula/vim/master/colors/dracula.vim"
# 4. Nord (修正链接)
download_colorscheme "nord" "https://raw.githubusercontent.com/arcticicestudio/nord-vim/main/colors/nord.vim"
# 5. Molokai (使用一个维护更活跃的版本)
download_colorscheme "molokai" "https://raw.githubusercontent.com/fatih/molokai-vim/main/colors/molokai.vim"
# --- 最终验证 ---
echo ""
echo "🎉 所有配色方案均已尝试安装。正在验证结果..."
echo "下面是 '$VIM_COLORS_DIR' 目录中的文件列表:"
ls -l "$VIM_COLORS_DIR"
echo ""
# --- 使用说明 ---
echo "--- 如何使用 ---"
echo "1. 打开你的 Vim 配置文件: vim ~/.vimrc"
echo "2. 确保已添加以下配置:"
echo "   syntax enable"
echo "   set t_Co=256"
echo ""
echo "3. 从已安装的方案中选择一个添加到 .vimrc 文件中:"
echo "   colorscheme nord"
echo "   colorscheme molokai"
echo "   colorscheme gruvbox"
echo "   colorscheme dracula"
echo "   colorscheme solarized"
echo ""
echo "4. (可选) 对于某些主题，你可能需要指定背景色:"
echo "   set background=dark  \" 或者 set background=light"
echo ""
echo "5. 保存文件并重启 Vim 即可看到效果！"
echo "----------------"
