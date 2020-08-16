#!/bin/sh

SERVERS="nus wes zod"
CLIENTS="bud nec"
SHIPS="$SERVERS $CLIENTS"

# client files
for client in $CLIENTS
do
  cp ~/permanent/code/hoon/vuvuzela/home/app/vuvuzela-client.hoon ~/permanent/programs/urbit/vuvuzela/$client/home/app/vuvuzela-client.hoon
  cp ~/permanent/code/hoon/vuvuzela/home/sur/vuvuzela.hoon ~/permanent/programs/urbit/vuvuzela/$client/home/sur/vuvuzela.hoon
done

# server files
for server in $SERVERS
do
  cp ~/permanent/code/hoon/vuvuzela/home/app/vuvuzela-server.hoon ~/permanent/programs/urbit/vuvuzela/$server/home/app/vuvuzela-server.hoon
  cp ~/permanent/code/hoon/vuvuzela/home/sur/vuvuzela.hoon ~/permanent/programs/urbit/vuvuzela/$server/home/sur/vuvuzela.hoon
done

# commit
for ship in $SHIPS
do
  screen -S $ship -X stuff '|commit %home\015'
done

