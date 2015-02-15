#####################################################
To set up DSSAT to run on cloud or local computer:
#####################################################
Follow instructions in settingUpDSSAT.docx

- If running on cloud: you may need to rename path to Soil folder in DSSAT45/DSSATPRO.L45 to go to DSSAT45/SOIL instead of DSSAT45/Soil.

- If other paths aren’t working, make sure all capitalizations are correct. This only seems to matter when running in the cloud, and not when running on a local computer. 

- DSCSM045.EXE must be compiled on the computer you are running it. If you compile it on one computer and try to run it on another, it usually won’t work. Also make sure permissions are granted by using the “chmod +x DSCSM045.EXE” command. 

#####################################################
To run trials:
#####################################################
Edit ranges of variables you want to iterate through in the inputScript.R file. 

Currently, the program supports editing the following variables: 
	- The frequency with which irrigation occurs (# equals days between irrigations)
	- The amount of water in each irrigation (in mm)
	- The number of times N is applied as fertilizer 
	- The amount of N fertilizer applied (in kg/ha)
	- The number of times P is applied as fertilizer
	- The amount of P fertilizer applied (in kg/ha)

You can change certain parameters of the parallel job in parallel.cmd, including the number of cores you want to use and if you want the program to email you when the job begins and ends. (If you don’t want it to email you, put a space between the # and the following command)
 
MAKE SURE THE NUMBER OF CORES IN parallel.cmd matches those specified by the registerDoMC command in inputScript.R  

If using a Princeton cloud with the slurm job scheduler, submit the program by typing “sbatch parallel.cmd”

#####################################################
Files:
#####################################################
inputScript.R	      - Code to enter input for DSSAT trials
runSensitivityTests.R - Code to execute parallel DSSAT trials

#####################################################
Potential future updates:
#####################################################
Adding ability to iterate through the following variables:
	- planting day
	- daily rainfall
	- percentage change in temperature from weather file (for example, 1.1 would be a season where each day’s temperatures are 110% those in the weather file)
	- percentage change in solar radiation (same format as above)

#####################################################
Additional Help:
#####################################################
You can email me at johank@princeton.edu if you have issues getting the program to work.