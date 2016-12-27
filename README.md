# svgToPlotterSpecificG-CODE
A script I wrote to reformat the g-code generated by svg2gcode node terminal utility .. 

###Prerequisites:
* latest node and npm. <br>
* [svg2gcode](https://github.com/em/svg2gcode) [it's a terminal 
       utility and I love terminal ;)]

###Installation:
* `chmod u+x installer.sh` (one-time only)
* `./installer.sh`
* `plotter_gcode -h`

###Usage:
* `plotter_gcode <filename.svg> <width of X plotter bed> <width of Y plotter bed>`
* Then follow the prompts

###Un-Installation:
* `chmod u+x uninstaller.sh` (one-time only)
* `./uninstaller.sh`

<br>
For rest you can read the script . It's well commenetd .
<br>
<br>
#####NOTES:
* It's only specific to svg generated for faces in a dot style from [this project](https://github.com/dattasaurabh82/SVGExportTest/tree/master)
for plotters that are running [grbl-servo](https://github.com/robottini/grbl-servo)
* I did this as I was manually editing the gcode generated from [svg2gcode](https://github.com/em/svg2gcode) [WITH TERMINAL COMMANDS OBVIOUSLY] and figured that it's a very
laborious work, so made a shell script. It's definitely not a general purpose SCRIPT.
* But feel free to edit it (Send a pull req, I can make a branch) and adopt it according to your needs.. I've explained which command does what to the gcodes there. 
* I'm assuming if you are here you already know a bit about gcode and I don't have to explain that hence forth. 

