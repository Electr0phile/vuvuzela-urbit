#!/bin/sh

SERVER_SHIP=marzod
CLIENT_SHIP_1=milrys-soglec
CLIENT_SHIP_2=dapnep-ronmyl

# client files
cp ~/permanent/code/hoon/vuvuzela/home/app/vuvuzela-client.hoon ~/permanent/programs/urbit/vuvuzela/$CLIENT_SHIP_1/home/app/vuvuzela-client.hoon
cp ~/permanent/code/hoon/vuvuzela/home/sur/vuvuzela.hoon ~/permanent/programs/urbit/vuvuzela/$CLIENT_SHIP_1/home/sur/vuvuzela.hoon

cp ~/permanent/code/hoon/vuvuzela/home/app/vuvuzela-client.hoon ~/permanent/programs/urbit/vuvuzela/$CLIENT_SHIP_2/home/app/vuvuzela-client.hoon
cp ~/permanent/code/hoon/vuvuzela/home/sur/vuvuzela.hoon ~/permanent/programs/urbit/vuvuzela/$CLIENT_SHIP_2/home/sur/vuvuzela.hoon

# server files
cp ~/permanent/code/hoon/vuvuzela/home/app/vuvuzela-server.hoon ~/permanent/programs/urbit/vuvuzela/$SERVER_SHIP/home/app/vuvuzela-server.hoon
cp ~/permanent/code/hoon/vuvuzela/home/sur/vuvuzela.hoon ~/permanent/programs/urbit/vuvuzela/$SERVER_SHIP/home/sur/vuvuzela.hoon

# commit
screen -S ship1 -X stuff '|commit %home\015'
screen -S ship2 -X stuff '|commit %home\015'
screen -S ship3 -X stuff '|commit %home\015'

