#!/bin/bash
cp plotter_gcode.sh plotter_gcode
sleep 1
cp plotter_gcode /usr/local/bin/
echo ""
echo ""
echo "installed plotter_gcode"
sleep 1
echo "Now you can type:"
sleep 1
echo "plotter_gcode -h --help to get the help"
echo ""
sleep 1
echo "type './uninstaller.sh' in the directory to un-install"
echo ""
echo ""
sleep 1
exit