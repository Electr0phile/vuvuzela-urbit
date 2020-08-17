#!/bin/sh

SERVERS="nus wes zod"
CLIENTS="bud nec"
SHIPS="$SERVERS $CLIENTS"

for ship in $SHIPS
do
  cp ~/permanent/code/hoon/vuvuzela/home/app/* ~/permanent/programs/urbit/vuvuzela/$ship/home/app/
  cp ~/permanent/code/hoon/vuvuzela/home/sur/* ~/permanent/programs/urbit/vuvuzela/$ship/home/sur/
  cp ~/permanent/code/hoon/vuvuzela/home/gen/* ~/permanent/programs/urbit/vuvuzela/$ship/home/gen/
  screen -S $ship -X stuff '|commit %home\015'
done
