#!/bin/sh
# Based on Ubuntu Server 14.04 LTS (HVM) - ami-6cc2a85c

cd /tmp

# Setup shell
sudo apt-get -y install fish
sudo chsh -s /usr/bin/fish ubuntu

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

# Patch ruby

tee fix-readline.patch << EOF
From 4c4da3fc650a3595ecc06f49072f1ffae07db706 Mon Sep 17 00:00:00 2001
From: Thomas Dziedzic <gostrc@gmail.com>
Date: Sat, 1 Mar 2014 21:41:28 -0800
Subject: [PATCH] Fix undeclared identifier error by using the actual type of
 rl_pre_input_hook

---
 ext/readline/readline.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ext/readline/readline.c b/ext/readline/readline.c
index 659adb9..7bc0eed 100644
--- a/ext/readline/readline.c
+++ b/ext/readline/readline.c
@@ -1977,7 +1977,7 @@ Init_readline()

     rl_attempted_completion_function = readline_attempted_completion_function;
 #if defined(HAVE_RL_PRE_INPUT_HOOK)
-    rl_pre_input_hook = (Function *)readline_pre_input_hook;
+    rl_pre_input_hook = (rl_hook_func_t *)readline_pre_input_hook;
 #endif
 #ifdef HAVE_RL_CATCH_SIGNALS
     rl_catch_signals = 0;
--
1.9.0
EOF
ruby-install -p fix-readline.patch ruby 2.1.1

# invocke chruby so gems are installed for custom ruby instead of the system one
. /usr/local/share/chruby/chruby.sh
chruby ruby-2.1.1

# Install the gems I use TODO: extract to gemfile
gem install homesick

# Setup dotfiles through homesick
homesick clone CADBOT/dotfiles
homesick symlink dotfiles

# setup vundle plugins
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# setup youcompleteme
sudo apt-get -y install build-essential cmake
sudo apt-get -y install python-dev
cd ~/.vim/bundle/YouCompleteMe
./install.sh --clang-completer

# use a vim with Ruby scritping installed so YCM ruby autocomplete works
sudo apt-get -y install vim-nox


