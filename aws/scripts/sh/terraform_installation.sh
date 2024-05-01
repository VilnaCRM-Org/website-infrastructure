echo "## Install OpenTofu"
curl --proto "=https" --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method rpm
rm install-opentofu.sh
echo "## Install Terraform"
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo $(export PATH="$HOME/.tfenv/bin:$PATH") >>~/.bash_profile
export PATH="$HOME/.tfenv/bin:$PATH"
tfenv install 1.4.7
tfenv use 1.4.7
