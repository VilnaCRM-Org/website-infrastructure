git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo $(export PATH="$HOME/.tfenv/bin:$PATH") >>~/.bash_profile
export PATH="$HOME/.tfenv/bin:$PATH"
tfenv install 1.4.7
tfenv use 1.4.7
