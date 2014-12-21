#!/bin/sh
# Based on Ubuntu Server 14.04 LTS (HVM) - ami-6cc2a85c

cd /tmp

# Setup shell
sudo apt-get -y install fish
sudo chsh -s /usr/bin/fish $SUDO_USER

sudo apt-get -y install tmux
sudo apt-get -y install build-essential automake
sudo apt-get -y install git-core

# Otherwise we can't install ruby 2.1.1 because of some readline junk
sudo apt-get -y install ruby

# Install base chruby
wget -O chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
tar -xzvf chruby-0.3.8.tar.gz
cd chruby-0.3.8/
sudo make install
cd ..

# Install fish chruby support
wget -O chruby-fish-0.6.0.tar.gz https://github.com/JeanMertz/chruby-fish/archive/v0.6.0.tar.gz
tar -xzvf chruby-fish-0.6.0.tar.gz
cd chruby-fish-0.6.0/
sudo make install
cd ..

# Install ruby-install

wget -O ruby-install-0.4.3.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz
tar -xzvf ruby-install-0.4.3.tar.gz
cd ruby-install-0.4.3/
sudo make install
cd ..

# install more recent ruby
CC=clang ruby-install ruby 2.1.5

# Install homesick into the ruby version just installed
/opt/rubies/ruby-2.1.5/bin/gem install homesick

# Install the gems I use TODO: extract to gemfile

# Setup dotfiles through homesick
homesick clone CADBOT/dotfiles
#TODO will currently break if ~/.config is already there!
homesick symlink dotfiles

# setup vundle plugins
# TODO: there is a plugin that breaks the script by hanging
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# setup youcompleteme
sudo apt-get -y install build-essential cmake
sudo apt-get -y install python-dev
cd ~/.vim/bundle/YouCompleteMe
./install.sh --clang-completer

# use a vim with Ruby scritping installed so YCM ruby autocomplete works
sudo apt-get -y install vim-nox
