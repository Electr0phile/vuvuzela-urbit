#!/bin/sh

vim -p home/app/vuvuzela-client.hoon \
       home/app/vuvuzela-entry-server.hoon \
       home/app/vuvuzela-middle-server.hoon \
       home/app/vuvuzela-end-server.hoon \
       home/sur/vuvuzela.hoon \
       -S local-vimrc.vim
