#!/bin/sh

vim -p $(find ./home/ -type f -name "*.hoon") -S local-vimrc.vim
