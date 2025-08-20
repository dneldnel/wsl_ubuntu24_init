# 在远程服务器上执行：
# chmod 700 ~/.ssh
# chmod 600 ~/.ssh/authorized_keys

# 检查 /etc/ssh/sshd_config
# 确保这些配置是正确的
# PubkeyAuthentication yes
# AuthorizedKeysFile .ssh/authorized_keys
# PasswordAuthentication yes   #（允许密码备用）




#!/usr/bin/env bash
set -e

# ===== 用户输入 =====
read -p "请输入远程服务器 IP: " SERVER_IP
read -p "请输入远程服务器 SSH 端口 (默认22): " SERVER_PORT
SERVER_PORT=${SERVER_PORT:-22}
read -p "请输入远程服务器用户名: " SERVER_USER
read -p "请输入本地别名 (如 myserver): " SERVER_ALIAS

# ===== 生成 SSH key（如不存在） =====
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo "生成新的 SSH key..."
  ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -C "$USER@$(hostname)"
else
  echo "已存在 SSH key，跳过生成"
fi

# ===== 上传公钥到服务器 =====
echo "上传公钥到远程服务器..."
ssh-copy-id -i "$HOME/.ssh/id_ed25519.pub" -p "$SERVER_PORT" "$SERVER_USER@$SERVER_IP"

# ===== 配置 SSH config =====
SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"
touch "$SSH_CONFIG"

if ! grep -q "Host $SERVER_ALIAS" "$SSH_CONFIG"; then
  cat <<EOF >> "$SSH_CONFIG"

Host $SERVER_ALIAS
    HostName $SERVER_IP
    User $SERVER_USER
    Port $SERVER_PORT
    IdentityFile ~/.ssh/id_ed25519
EOF
  echo "已将 $SERVER_ALIAS 添加到 ~/.ssh/config"
else
  echo "别名 $SERVER_ALIAS 已存在于 ~/.ssh/config，跳过"
fi

chmod 600 "$SSH_CONFIG"

echo "===== 配置完成！以后你可以直接使用: ssh $SERVER_ALIAS ====="
