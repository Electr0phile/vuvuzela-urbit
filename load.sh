#!/bin/sh

SERVERS="nus wes zod"
CLIENTS="bud nec"
SHIPS="$SERVERS $CLIENTS"

# client files
for client in $CLIENTS
do
  cp ~/permanent/code/hoon/vuvuzela/home/app/vuvuzela-client.hoon ~/permanent/programs/urbit/vuvuzela/$client/home/app/vuvuzela-client.hoon
  cp -r ~/permanent/code/hoon/vuvuzela/home/sur/* ~/permanent/programs/urbit/vuvuzela/$client/home/sur/
done

# server files
for server in $SERVERS
do
  cp ~/permanent/code/hoon/vuvuzela/home/app/vuvuzela-server.hoon ~/permanent/programs/urbit/vuvuzela/$server/home/app/vuvuzela-server.hoon
  cp -r ~/permanent/code/hoon/vuvuzela/home/sur/ ~/permanent/programs/urbit/vuvuzela/$server/home/sur/
done

# commit
for ship in $SHIPS
do
  screen -S $ship -X stuff '|commit %home\015'
done

