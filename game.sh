#!/bin/bash
source "service.sh"
source "draw.sh"
B=""
x0=3
y0=1
x=x0
y=y0
xH0=0
yH0=0
Xmax=25 #`tput lines`
Ymax=80 #`tput cols`

trap ScrResize SIGWINCH # screen resize, does nothing at the moment
trap CtrlC SIGINT

clear
stty -echo

PrepareLvl1
source "level1.sh"

lives=3
fruitCollected=0

DrawScene

StartTimer &
TIMERPID=$!

while(! [ "x$B" == "xq" ] )
do
 
 ClearGuy

 MoveGuy

 DrawGuy
 
 read -n 1 B
done

QuitGame
