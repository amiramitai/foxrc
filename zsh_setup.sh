# install zsh
sudo apt-get install zsh
# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# install power10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's#ZSH_THEME=\".*\"#ZSH_THEME=\"powerlevel10k/powerlevel10k\"#g' ~/.zshrc

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install


(echo 'export LC_ALL=en_US.UTF-8' && echo 'export LANG=en_US.UTF-8' && cat ~/.zshrc) > /tmp/.zshrc
cp /tmp/.zshrc ~/.zshrc

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

sed -i 's/plugins=(.*)/plugins=(git zsh-autosuggestions zsh-completions zsh-syntax-highlighting)/g' ~/.zshrc

git clone https://github.com/amiramitai/foxrc.git ~/foxrc
echo 'source ~/foxrc/dev.sh' >> ~/.zshrc

git clone https://github.com/garabik/grc /tmp/grc
cd /tmp/grc
sh install.sh

mkdir -p ~/.grc
cp ~/foxrc/grc.conf ~/foxrc/auto
