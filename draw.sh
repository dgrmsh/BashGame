function DrawScene {
 
 DrawTop
 DrawLvl

 x=$xH0
 y=$yH0

 DrawGuy
 echo -en "\033[${Xmax};1f";

}

function DrawGuy {

 echo -en "\033[$((x));$((y+1))f^^";
 echo -en "\033[$((x+1));$((y))f(  )";
 echo -en "\033[$((x+2));$((y+1))f..";
 
 echo -en "\033[${Xmax};1f";
}

function ClearGuy {
 echo -en "\033[$((x));$((y+1))f  ";
 echo -en "\033[$((x+1));$((y))f    ";
 echo -en "\033[$((x+2));$((y+1))f  ";
}

function DrawTop {
 echo -en "\033[1;1f@Level:1\tLives:${lives}\tFruits:${fruitCollected}"
 local i=1
 for ((i=1;i<=$Ymax;i++)) {
  echo -en "\033[2;${i}f="
 }
}

function DrawLvl {
 # here +1's appear because array index starts with 0 and screen coordinates with 1
 local hero=0
 local lx
 local ly
 local offset=$((2*Ymax)) # skip first 2 rows
 for ((i=offset+1;i<=$((Xmax*Ymax)); i++)) {
   ###
   ### OPTIMIZE this if, it is not necessary!
   ###
   if [[ "$((i%Ymax))" -eq 0 ]] # we are at the last column
   then
     lx=$((i/Ymax))
     ly=$Ymax
   else
     lx=$((i/Ymax+1))
     ly=$((i%Ymax))
   fi
   if [ "x${lev1[$i]}" == "x#" ]
   then
     echo -en "\033[${lx};${ly}f#"
   elif [ "x${lev1[$i]}" == "xH" -a "$hero" -eq "0" ]
   then
     hero=1
     xH0=$lx
     yH0=$ly
   elif [ "x${lev1[$i]}" == "xF" ]
   then
     echo -en "\033[${lx};${ly}f%"
   else
     echo -en "\033[${lx};${ly}f "
   fi
 }
}
