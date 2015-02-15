Getting CSM compiled and running on Linux and Mac 

Lyndon Estes, STEP Program, Woodrow Wilson School, Princeton University

With guidance provided by Robert Knight of Princeton University's Computational Science
and Engineering Support group. 

****************************************************************************************************
Compiling and running CSM on a Linux (a customized version of Redhat) cluster using the Intel 
Fortran Compiler (v 9.1-10.1)
****************************************************************************************************

1. Changed source code extensions from .FOR or .for to .f90.

2. Changed the following lines in ModuleDefs.f90 to appear as follows: 

!      CHARACTER(LEN=5), PARAMETER :: OPSYS = 'WINDO'   !DOS, Windows
      CHARACTER(LEN=5), PARAMETER :: OPSYS = 'LINUX'   !Linux, UNIX
      
Note that the code appears to be written in an older, fixed format version of 
Fortran, this it is important for the first character to begin at column 7.

3. In the UTILS.f90 source, there were two commented out definitions of the type 
of the function SYSTEM that need to be uncommented.  The first was line 830:
    INTEGER ERR, I, LUN, LUNTMP, SYS  !, SYSTEM

Changed to: 

    INTEGER ERR, I, LUN, LUNTMP, SYS, SYSTEM
(Note 6 blanks before 1st character)  

The second one is line 912:
    INTEGER i, COUNT, LUNLST, LUNTMP, SYS !, SYSTEM

Changed to: 
    INTEGER i, COUNT, LUNLST, LUNTMP, SYS, SYSTEM


4. In CRSIMDEF.f90, changed the following lines to read: 

!      CHARACTER(LEN=1),PARAMETER::SLASH = '\' !DOS, Windows
      CHARACTER(LEN=1),PARAMETER::SLASH = '/' !Linux, Unix
      
If this change is not made, the compiled model will fault. In the tested example, 
a wheat simulation was used, and the model faulted as follows:

forrtl: severe (29): file not found, unit 23, 
file ~/DSSAT45/GENOTYPE/\WHCER045.ECO

Note the misplaced "\"

5. Changed the beginning of the makefile Make_CSM046.MAK as follows: 

FC  = ifort 
FFLAGS = -nowarn -std95 -fixed -traceback
!EFILE = ../DSCSM045.EXE
EFILE = DSCSM045.EXE
.SUFFIXES:	.f90
.f90.o:
	$(FC)$(FFLAGS) -o $@ -c $<

Note a tab is used between the : and the .f90 in the first line as well as before 
the first $ in the last line. This says "Know about .f90 as a special suffix.  
And, the way to translate from a .f90 to a .o is invoke the FC program with the 
FFLAGS (defined in the first two lines of Make_CSM046.MAK), producing the .o file 
(-o $@) from the input file ($<).  The -c says to just compile; don't try to link.

The -traceback option was included to find a runtime error related to a variable 
defined in CRSIMDEF.f90 (see 4. above). 

Add in the line

IPSIM.o \ 

between IPMAN.o \ and IPSLIN.o \

6. Before running Make_CSM046.MAK, first compiled the following modules: 

ModulesDef.f90
OPHEAD.f90
SoilMixing.f90
SLigCeres.f90
OPSUM.f90
SC_CNG_mods.f90

This was done using the script CSM_precompile_list.sh, executed within the 
directory containing the source code:

./CSM_precompile_list.sh

7. Ran the make file: 

module load intel  (this was necessary on the linux cluster used in this case)
make -f Make_CSM046.MAK

This compiled the program with no errors. The compiled *.o, *.mod, and DSCSM045.EXE 
files were then moved into a new directory: 

~/DSSAT45, which contained all the necessary folders and files needed to run 
CSM. 

8. Run instructions: 

Before running the program, make sure that the file DSSATPRO.L45 has 
the correct directory structure specified in it.  

Execute the program within the folder containing the Xfile of interest. For example, 
if a wheat file is of interest, make sure there is a batch file (e.g. DSSBatch.v45) in the 
directory specifying the treatments of interest. The format of these batch files can be found 
within the wheat directory using Windows Explorer and a text editor after running a wheat 
simulation using DSSAT45. Make sure the file path is correct for Linux, however. 

Command for execution: 

~/DSSAT45/DSCSM045.EXE B DSSBatch.v45

****************************************************************************************************
Compiling and running CSM compiled on a Macbook Pro (OSx 10.5.8) using the Gfortran compiler v4.3.0
****************************************************************************************************

1. Followed steps 1-4 described above. 

2. Replaced all backslashes in CSCRP045.f90 with $ symbol. Earlier versions of the Gfortran compiler
accept \, but later versions (as in 4.3) do not. 

Both \ and $ mean the same thing and, apparently, more recent versions of gfortran, do not accept \.
It's possible that some versions of gfortran versions treat \ in a string as a character, while 
others treat it as a quoting character akin to C, C++, Java, and Python.

Note: As of 21/7/2010, code no longer has \ in it. 

3. Changed the make file (Mac_Make_CSM046.MAK) to have the following two initial lines: 

FC  = gfortran 
FFLAGS = -w -ffixed-form -fd-lines-as-comments -ffixed-line-length-none

The next 5 lines match those shown in 5 above. 

The -ffixed-line-length-none option was added because at least one source file (CSP_GROW.f90)
has a line (or lines) extending beyond 72 columns in length.  

4. As in 6 above, ran a modified version of the the pre-compile script (Mac_CSM_precompile_list.sh). 

5. Ran the make file (Mac_Make_CSM046.MAK), which compiled CSM succesfully. 

6. Run instructions: Running DSCSM045.EXE is slightly different on the Mac than Linux, due to how 
file paths are read from the DSSATPRO.L45 in the Mac Environment. For instance, in Linux, the 
following syntax in DSSATPRO.L45 allowed CSM to run, using the first line of file as an example: 

DDB ~/ DSSAT45/

In Mac, this line must be written as follows:

1. If the CSM/DSSAT directory is moved to root, e.g. as /DSSAT45, then use the following syntax:

DDB // DSSAT45/

2. If DSSAT is within the User's account, as in /Users/username/DSSAT45, then:

DDB // Users/username/DSSAT45/

Mac doesn't seem to interpret the ~ within filepaths in DSSATPRO.L45, even though it works in 
terminal commands specifying directories. 










	
	

	
