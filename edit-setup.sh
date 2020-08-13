#!/bin/sh
URBIT_PATH=/home/electro/permanent/programs/urbit
SHIP_1_SUBPATH=vuvuzela/dapnep-ronmyl
SHIP_2_SUBPATH=vuvuzela/milrys-soglec
SHIP_3_SUBPATH=vuvuzela/marzod

xterm -e "screen -d -R -S ship1 $URBIT_PATH/urbit $URBIT_PATH/$SHIP_1_SUBPATH" &
xterm -e "screen -d -R -S ship2 $URBIT_PATH/urbit $URBIT_PATH/$SHIP_2_SUBPATH" &
xterm -e "screen -d -R -S ship3 $URBIT_PATH/urbit $URBIT_PATH/$SHIP_3_SUBPATH" &

vim -p home/app/vuvuzela-server.hoon home/app/vuvuzela-client.hoon home/sur/vuvuzela.hoon -S local-vimrc.vim
