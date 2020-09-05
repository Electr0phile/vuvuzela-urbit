#!/bin/sh
URBIT_PATH=/home/electro/permanent/programs/urbit
SHIPS="bud nec nus wes zod"

for ship in $SHIPS
do
  xterm -e "screen -d -R -S $ship $URBIT_PATH/urbit $URBIT_PATH/vuvuzela/$ship" &
done

exit
