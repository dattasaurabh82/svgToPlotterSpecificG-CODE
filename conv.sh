#!/usr/bin/env bash

x=0
y=0
# I'm a B/W person but I still like colors in terminals

# Num  Colour    #define         R G B

# 0    black     COLOR_BLACK     0,0,0
# 1    red       COLOR_RED       1,0,0
# 2    green     COLOR_GREEN     0,1,0
# 3    yellow    COLOR_YELLOW    1,1,0
# 4    blue      COLOR_BLUE      0,0,1
# 5    magenta   COLOR_MAGENTA   1,0,1
# 6    cyan      COLOR_CYAN      0,1,1
# 7    white     COLOR_WHITE     1,1,1

RED=`tput setaf 1`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
GREEN=`tput setaf 2`
RESET=`tput sgr0`

echo "${YELLOW}====================================================================="
echo "${YELLOW}|                      CREATING GCODE FROM SVG FILE                 |"
echo "${YELLOW}====================================================================="
echo ""
#-----------> Creating gcode file from SVG
# **NOTE**
# Do these installations first:
# ----------------------------- 
# > latest node and npm
# > svgTogcode (https://github.com/em/svg2gcode) [it's a terminal 
#   utility and I love terminal ;)]

fbname=$(basename "$1" .svg) 
# echo $fbname".gcode"
# ----------> ::SAFETY:: remove the gcode file if it exists before
rm $fbname".gcode"
sleep 4
echo " ${MAGENTA}:: Converting ${CYAN}$1 ${MAGENTA}to ${CYAN}$fbname.gcode"
echo " ${MAGENTA}:: execute ${RED}'pkill node' ${MAGENTA}in a separate window after ${BLUE}5 sec"
svg2gcode -f 4000 -r 8 -D 3 $1 >> $fbname".gcode"
# sleep 5
# kill the svg2gcode node app as it doesn't exit
# Since it's a node server. 
# NOTE: fallback is it's gonna kill all node processes
# pkill node 
echo ""
echo ""
echo " ${BLUE}:: Dirty gcode created from svg2gcode node terminal utility"

echo "${YELLOW}====================================================================="
echo "${YELLOW}|                  ALTERING GCODE a/c TO MY PLOTTER                 |"
echo "${YELLOW}====================================================================="
echo ""
echo " ${RED}:: optimizing $fbname.gcode for the drawing machine"
echo " ${RED}--------------------------------------------------------"

#-----------> Removing some g-code bits from begining 
sleep 4
sed -i '' 's/G90//g' $fbname".gcode"
sleep 2
sed -i '' 's/G93//g' $fbname".gcode"
sleep 2
sed -i '' 's/(.*)//g' $fbname".gcode"
sleep 2
echo " ${CYAN}:: Done removing some g-code bits from begining"

add_initial_sequences(){
  #-----------> Inserting gcode bits to the begining from below to top
  # [1] unlock alarm
  # [2] lift servo
  # [3] do homing
  # [4] reset axes to zero after homing
  # [5] set units to mm and -ve axes and shit like that

  echo " ${MAGENTA}:: [5] Setting units to 'mm'. Oh C'mon! not that imperial shit"
  sed -i '' '1s/^/G21 G90 G40\n/g' $fbname".gcode" # [5] 
  sleep 4
  echo " ${BLUE}:: [4] Adding 'Resest to zero' commands at origin"
  sed -i '' '1s/^/G10 P0 L20 X0 Y0 Z0\n/g' $fbname".gcode" # [4]
  sleep 4
  echo " ${CYAN}:: [3] Adding homing command"
  sed -i '' '1s/^/$H\n/g' $fbname".gcode" # [3] 
  sleep 4
  echo " ${GREEN}:: [2] Adding pen lift up command specific to servo. remember"
  echo " ${GREEN}::     we are using grbl-servo where we are using servos for Z-Axis"
  sed -i '' '1s/^/M03 S35\n/g' $fbname".gcode" # [2] -- S35 means 35 degrees
                                  # which I optimized for my machine
  sleep 6
  echo " ${YELLOW}:: [1]Adding alarm unlock"
  sed -i '' '1s/^/$X\n/g' $fbname".gcode" # [1]
  sleep 4
  sed -i '' 's/n/\
  /g' $fbname".gcode"

  echo " ${white}:: Done inserting alarm lock and homing cycle etc. at begining"
  sleep 3
  echo " ${CYAN}:: why? I set up my plotter to do a alarm lock and force to do homing,"
  echo " ${CYAN}:: to ensure zeroing at begining."
  echo " ${CYAN}:: I like the standard way."
  sleep 5
  echo " ${YELLOW}:: And don't worry it's been set from [1] - [5] and not in a order"
  echo " ${YELLOW}:: the prompts appeared on screen."
}

# ------------> CHANGE THE ORIGIN
coordinates_diagram(){
  echo ""
  echo " ${YELLOW}:: NEW ORIGIN SET TO:"
  echo ""
  echo "          ${BLUE}-----------------"
  echo "          |               |"
  echo "          |               |"
  echo "          |      _________|______($1mm, $2mm)"
  echo "          |     /         |"
  echo "          |___ /          |"
  echo "          |   |           |"
  echo "          -----------------"
  echo ""
}

plotter_bed(){
  echo ""
  echo " ${YELLOW}:: PLOTTER BED SIZE"
  echo ""
  echo "          ${BLUE}-----------------"
  echo "          |               |"
  echo "          |               |"
  echo "  $2mm   |               |"
  echo "          |               |"
  echo "          |               |"
  echo "          |               |"
  echo "          -----------------"
  echo "                $1mm        "
  echo ""
}

go_to_origin(){
  # reset to zero # 
  # G10 P0 L20 X0 Y0 Z0
  sed -i '' '1s/^/G10 P0 L20 X0 Y0 Z0\n/g' $fbname".gcode"
  # Add gcode for moving to new origin after homing if chaged
  # G0 X-$1 G0Y-$2
  sed -i '' '1s/^/G0 X-$1 G0Y-$2\n/g' $fbname".gcode"
}

proceed_normal_way(){
  #-----------> Making the axes neagtive
  # WHY? beacuse I like to follow traditions and for ideal conditions, a CNC is 
  # always set to negative axes as it's a subractive manufacturing.. 
  # So I've set up my GRBL for -ve axes but the gcode generated from svg2gcode 
  # for is set to +ve axes. So
  sleep 3
  sed -i '' 's/Z/Z-/g' $fbname".gcode"
  echo " ${MAGENTA}:: Done making the Z-Axes neagtive. I'll remove it later anyways"
  sleep 4
  sed -i '' 's/X-/X/g' $fbname".gcode"
  sleep 1
  sed -i '' 's/X/X-/g' $fbname".gcode"
  echo " ${BLUE}:: Done making the X-Axes neagtive"
  sleep 6
  sed -i '' 's/Y-/Y/g' $fbname".gcode"
  sleep 1
  sed -i '' 's/Y/Y-/g' $fbname".gcode"
  echo " ${CYAN}:: Done making the Y-Axes neagtive"
  sleep 6

  echo " ${GREEN}:: Done making all the axes neagtive "
  sleep 2
  echo " ${RED}:: Why? I like CNC concept of being -ve axes as it's ideally subractive"
  sleep 2
  echo " ${RED}:: manufacturing. So my plotter is also set in GRBL to -ve axes."

  #-----------> Replacing z axis commands with servo commands
  # NOTE: I'm using a patched version of grbl modified for servo control 
  # over z axis motor for z axis control.
  # ===========================
  # M05 = servo 0 degree
  # M03 Sxxx = servo xxx degree
  # ===========================
  # It's using the PWM pins for the spindle speed ctrl. Since it's a plotter,
  # I don't think I'd be using those pins any time soon :P
  sleep 6
  echo " ${MAGENTA}:: Remember:"
  sleep 2
  echo " ${MAGENTA}:: From GRBL servo:"
  sleep 1
  echo " ${GREEN}:: > M05 means 0 degree"
  sleep 1
  echo " ${GREEN}:: > M03 Sxxx = xxx degree"
  sleep 2
  echo " ${RED}:: Now setting those up"
  sed -i '' 's/G0 Z-8 F32000/M03 S35/g' $fbname".gcode"
  sleep 3
  sed -i '' 's/G0 Z-0 F32000/M05/g' $fbname".gcode"
  sleep 3
  echo " ${RED}:: Removing Z Axis commands"
  sed -i '' 's/Z.* //g' $fbname".gcode"
  sleep 3
  echo " ${BLUE}:: Done replacing z axis commands with servo commands"


  #-----------> Cleaning the last bits
  sed -i '' 's/M30//g' $fbname".gcode"
  sleep 3
  sed -i '' 's/$X-/$X/g' $fbname".gcode"
  sleep 2
  sed -i '' 's/$Y--/$Y-/g' $fbname".gcode"
  sed -i '' 's/$X--/$X-/g' $fbname".gcode"
  sleep 2
  sed -i '' 's/X-0 Y-0 Z-0/X0 Y0 Z0/g' $fbname".gcode"
  sleep 2
  echo " ${RED}:: Done cleaning the last bits"
  echo ""
  sleep 2
  echo "${RESET}*** Early Conversion Finished ***"
  echo ""
}



while :
do
  echo -n " ${RED}:: Do you want to change the origin? Yes/no:  "
  read answer
  if echo "$answer" | grep -iq  "^Yes" ;then
    sleep 1
    echo " ${CYAN}:: SET the new origin to multiples of 10 like 10, 20 etc."
    sleep 2
    echo " ${CYAN}:: My suggestion; keep it between 50-250mm"
    sleep 2
    echo " :: And remember your plotter size is"
    sleep 2
    plotter_bed $2 $3
    sleep 2
    echo -n " ${MAGENTA}:: Set new origin-X in mm:  "
    read answerX
    echo " :: X: $answerX mm"
    echo -n " :: Set new origin-Y in mm:  "
    read answerY
    echo " :: ${MAGENTA}Y: $answerY mm"
    sleep 2
    coordinates_diagram $answerX $answerY
    sleep 2
    go_to_origin $answerX $answerY
    add_initial_sequences
    proceed_normal_way
    # make 
    exit
    exit
  elif echo "$answer" | grep -iq  "^no"; then
    sleep 2
    echo " ${GREEN}:: Not resetting axes"
    echo ""
    go_to_origin
    add_initial_sequences
    proceed_normal_way
    exit
    exit
  else
    echo " ${RED}:: Wrong input. Try again."
  fi
done