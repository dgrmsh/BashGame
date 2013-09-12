#!/bin/bash
function ScrResize {

 clear
 Xmax=25 #`tput lines`
 Ymax=80 #`tput cols`
 DrawScene

}

function StartTimer {
 local mm=0
 local ss=0
 while(! [ "x$B" == "xq" ] )
  do
   ss=$((ss+1))
   if [[ "$ss" -eq 60 ]]
   then
    mm=$((mm+1))
    ss=0
    echo -en "\033[1;75f     "
   fi
  echo -en "\033[1;65fTime: ${mm}m ${ss}s"
  sleep 1
 done
}

function PrepareLvl1 {
 #echo "Preparing Level 1.."
 echo "#!/bin/bash" > level1.sh
 local l1line="lev1=( "
 l1line+=`cat level1.raw | tr -d '\n' | sed "s/./\"&\" /g"`
 l1line+=") "
 echo "$l1line" >> level1.sh
}

function NotWall {
 local x=$1
 local y=$2
 #[ "x${lev1[$(((x-1)*80+y))]}" != "x#" ]
 ! MetObj $x $y "#"
}

function NotWallGuy {
 local x=$1
 local y=$2
 NotWall $x $((y+1)) && NotWall $x $((y+2)) && NotWall $((x+1)) $y && NotWall $((x+1)) $((y+1)) && NotWall $((x+1)) $((y+2)) && NotWall $((x+1)) $((y+3)) && NotWall $((x+2)) $((y+1)) && NotWall $((x+2)) $((y+2))
}

function MetObj {
 local x=$1
 local y=$2
 local obj=$3
 [ "x${lev1[$(((x-1)*80+y))]}" == "x${obj}" ]
}

function MetObjGuy {
 local x=$1
 local y=$2
 local obj=$3
 MetObj $x $((y+1)) $obj || MetObj $x $((y+2)) $obj || MetObj $((x+1)) $y $obj || MetObj $((x+1)) $((y+1)) $obj || MetObj $((x+1)) $((y+2)) $obj || MetObj $((x+1)) $((y+3)) $obj || MetObj $((x+2)) $((y+1)) $obj || MetObj $((x+2)) $((y+2)) $obj
}

function isFruit {
 local x=$1
 local y=$2
 MetObjGuy $x $y "F"
}

function EatFruit {
 ### this function returns its value through its third parameter ###
 local x=$1
 local y=$2
 local obj="F"
 local ctr=0
 MetObj $x $((y+1)) $obj && ctr=$((ctr+1)) && lev1[$(((x-1)*80+y+1))]=" "
 MetObj $x $((y+2)) $obj && ctr=$((ctr+1)) && lev1[$(((x-1)*80+y+2))]=" "
 MetObj $((x+1)) $y $obj && ctr=$((ctr+1)) && lev1[$((x*80+y))]=" "
 MetObj $((x+1)) $((y+1)) $obj && ctr=$((ctr+1)) && lev1[$((x*80+y+1))]=" "
 MetObj $((x+1)) $((y+2)) $obj && ctr=$((ctr+1)) && lev1[$((x*80+y+2))]=" "
 MetObj $((x+1)) $((y+3)) $obj && ctr=$((ctr+1)) && lev1[$((x*80+y+3))]=" "
 MetObj $((x+2)) $((y+1)) $obj && ctr=$((ctr+1)) && lev1[$(((x+1)*80+y+1))]=" "
 MetObj $((x+2)) $((y+2)) $obj && ctr=$((ctr+1)) && lev1[$(((x+1)*80+y+2))]=" "
 eval "$3=\"$ctr\""
}

function MoveGuy {
 case "$B" in
   "a" ) NotWallGuy $x $((y-1)) && if [[ "$((y-1))" -lt "$y0" ]];
           then NotWallGuy $x $((Ymax-3)) && NotWall $x $Ymax && NotWall $((x+2)) $Ymax && y=$((Ymax-3))
           else y=$((y-1))
           fi
         ;;
   "d" ) NotWallGuy $x $((y+1)) && if [[ "$((y+1))" -gt "$((Ymax-3))" ]];
           then NotWall $x $y0 && NotWallGuy $x $y0 && NotWall $((x+2)) $y0 && y=$y0
           else y=$((y+1))
           fi
         ;;
   "w" ) NotWallGuy $((x-1)) $y && if [[ "$((x-1))" -lt "$x0" ]];
           then NotWallGuy $((Xmax-2)) $y && NotWall $Xmax $y && NotWall $Xmax $((y+3)) && x=$((Xmax-2))
           else x=$((x-1))
           fi
         ;;
   "s" ) NotWallGuy $((x+1)) $y && if [[ "$((x+1))" -gt "$((Xmax-2))" ]];
           then NotWall $x0 $y && NotWallGuy $x0 $y && NotWall $x0 $((y+3)) && x=$x0
           else x=$((x+1))
           fi
         ;;
 esac

 if isFruit $x $y
 then
  local more
  EatFruit "$x" "$y" more
  fruitCollected=$((fruitCollected+more))
  DrawTop
 fi
}

function QuitGame {
 kill $TIMERPID >/dev/null 2>&1
 stty echo
 clear
}

function CtrlC {
 QuitGame
 exit 1
}
