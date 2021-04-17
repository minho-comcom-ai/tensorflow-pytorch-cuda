# NOTE: Kubernetes ssh key injection
cp /root/temp_key/id_rsa /root/.ssh/id_rsa
chmod 400 /root/.ssh/id_rsa

# NOTE: GIT_SSH clone with injected ssh key
export GIT_SSH_HOSTNAME=$(python3 -c "import os;print(os.environ['GIT_SSH_URL'].split(':')[0].split('@')[-1])")
export REPO_NAME=$(python3 -c "import os;print(os.environ['GIT_SSH_URL'].split(':')[1])")
cat << EOF > /root/.ssh/config
Host $GIT_SSH_HOSTNAME
  IdentitiesOnly yes
  IdentityFile /root/.ssh/id_rsa
  StrictHostKeyChecking no
EOF

# NOTE: Socks5 proxy
if [ -n "$SOCKS5_PROXY" ]
then
  echo "  ProxyCommand nc -x $SOCKS5_PROXY %h %p" >> /root/.ssh/config
fi

git clone $GIT_SSH_URL /workspace/$REPO_NAME
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"

if [ -z "$PASSWORD" ]
then
  AUTH=none
else
  AUTH=password
fi
/usr/code-server-3.9.3-linux-amd64/bin/code-server /workspace/$REPO_NAME --bind-addr=0.0.0.0:8000 --auth $AUTH
