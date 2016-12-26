#!/usr/bin/env bash

echo "====================================================================="
echo "|                      CREATING GCODE FROM SVG FILE                 |"
echo "====================================================================="
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
sleep 3
echo " :: Converting $1 to $fbname.gcode"
echo " :: execute 'pkill node' in a separate window after 5 sec"
svg2gcode -f 4000 -r 8 -D 3 $1 >> $fbname".gcode"
# sleep 5
# kill the svg2gcode node app as it doesn't exit
# Since it's a node server. 
# NOTE: fallback is it's gonna kill all node processes
# pkill node 
echo " :: Dirty gcode created from svg2gcode node terminal utility"
echo""

sleep 3

echo "====================================================================="
echo "|                  ALTERING GCODE a/c TO MY PLOTTER                 |"
echo "====================================================================="
echo ""
echo " :: optimizing $fbname.gcode for the drawing machine"
echo " -----------------------------------------------------"

#-----------> Removing some g-code bits from begining 
sed -i '' 's/G90//g' $fbname".gcode"
sleep 2
sed -i '' 's/G93//g' $fbname".gcode"
sleep 2
sed -i '' 's/(.*)//g' $fbname".gcode"
sleep 2

echo " :: Done removing some g-code bits from begining"

#-----------> Inserting gcode bits to the begining from below to top
# [1] unlock alarm
# [2] lift servo
# [3] do homing
# [4] reset axes to zero after homing
# [5] set units to mm and -ve axes and shit like that
# 
sed -i '' '1s/^/G21 G90 G40\n/g' $fbname".gcode" # [5] 
sleep 3
sed -i '' '1s/^/G10 P0 L20 X0 Y0 Z0\n/g' $fbname".gcode" # [4]
sleep 3
sed -i '' '1s/^/$H\n/g' $fbname".gcode" # [3] 
sleep 3
sed -i '' '1s/^/M03 S35\n/g' $fbname".gcode" # [2] -- S35 means 35 degrees
                                # which I optimized for my machine
sleep 3
sed -i '' '1s/^/$X\n/g' $fbname".gcode" # [1]
sleep 3
sed -i '' 's/n/\
/g' $fbname".gcode"

echo " :: Done inserting gcode bits to the begining from below to top"

#-----------> Making the axes neagtive
# WHY? beacuse I like to follow traditions and for ideal conditions, a CNC is 
# always set to negative axes as it's a subractive manufacturing.. 
# So I've set up my GRBL for -ve axes but the gcode generated from svg2gcode 
# for is set to +ve axes. So
#
sed -i '' 's/Z/Z-/g' $fbname".gcode"
sleep 2
sed -i '' 's/X/X-/g' $fbname".gcode"
sleep 2
sed -i '' 's/Y/Y-/g' $fbname".gcode"
sleep 2

echo " :: Done making the axes neagtive"

#-----------> Replacing z axis commands with servo commands
# NOTE: I'm using a patched version of grbl modified for servo control 
# over z axis motor for z axis control.
# ===========================
# M05 = servo 0 degree
# M03 Sxxx = servo xxx degree
# ===========================
# It's using the PWM pins for the spindle speed ctrl. Since it's a plotter,
# I don't think I'd be using those pins any time soon :P
 
sed -i '' 's/G0 Z-8 F32000/M03 S35/g' $fbname".gcode"
sleep 2
sed -i '' 's/G0 Z-0 F32000/M05/g' $fbname".gcode"
sleep 3
sed -i '' 's/Z.* //g' $fbname".gcode"
sleep 4

echo " :: Done replacing z axis commands with servo commands"

#-----------> Cleaning the last bits
sed -i '' 's/M30//g' $fbname".gcode"
sleep 2
sed -i '' 's/$X-/$X/g' $fbname".gcode"
sleep 2

echo " :: Done cleaning the last bits"
sleep 2
echo ""
echo "*** Conversion Finished ***"
echo ""
exit