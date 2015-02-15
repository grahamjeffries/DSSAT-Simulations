runSensitivityTests <- function(input, inputLengths, xtype = ".MZX") 
{
  
  rm(list=ls())

  rootName = getwd();
  
  #input = matrix(c(1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,6,6,6,6,6,6), ncol = 3, nrow = 6)
  #inputLengths = c(3,3,3,3,3,3)
  
  #Set up inputs
  waterFreqRange = input[1,1:inputLengths[1]] 
  fertNfreqRange = input[2,1:inputLengths[2]]
  fertPFreqRange = input[3,1:inputLengths[3]]
  waterAmtRange  = input[4,1:inputLengths[4]]
  fertNAmtRange  = input[5,1:inputLengths[5]]
  fertPAmtRange  = input[6,1:inputLengths[6]]
  
  plantingDay = 169;
  plantingYear = 04;
  crop_Season_Length = 81;
  
  timeElapsed = 0;
  
  #Open the parallel pool
  
  #matlabpool open 6
  
  #setwd('/home/johank')
  #time = format(Sys.time(), '%b-%d-%Y-%X')
  #time = substr(time, 0, nchar(time)-3)
  #folderName = paste('trials-', time, sep='')

  counter = 1
  while (file.exists(paste('trials', counter, sep='')))
     counter = counter+1

  folderName = paste('trials', counter, sep='')
  dir.create(folderName)
  setwd(paste(getwd(), '/', folderName, sep=''))
  
  
  # Cycle through each combination. Skip repetitive trials 
  # with different fertilizer N or P amounts if that fertilizer
  # type is never being applied anyway

  #for(waterFreq in waterFreqRange)
  foreach(waterFreq = waterFreqRange) %dopar%  
  {
    days_Between_Water_App = waterFreq
    
    for(waterAmt in waterAmtRange)
    {
      total_water = waterAmt
      
      for(fertNfreq in fertNfreqRange)
      {
        fertilizer_N_times = fertNfreq
        
        for(fertNAmt in fertNAmtRange)
        {
          total_fertilizer_N_Amt = fertNAmt
          
          if(fertilizer_N_times == 0 && fertNAmt != fertNAmtRange[1])
            next          
          
          for(fertPFreq in fertPFreqRange)
          {
            fertilizer_P_times = fertPFreq
            fileX = c()
            
            for (fertPAmt in fertPAmtRange)
            {
              total_fertilizer_P_Amt = fertPAmt
              
              if(fertilizer_P_times == 0 && fertPAmt != fertPAmtRange[1])
                next
              
              startTime = proc.time()
              
              trialName = paste(days_Between_Water_App, total_water, fertilizer_N_times, total_fertilizer_N_Amt, fertilizer_P_times, total_fertilizer_P_Amt, sep="-")
              dir.create(trialName)
              setwd('..')
              system(paste('cp -r', paste(getwd(), '/DSSAT45', sep=''), paste(getwd(), '/', folderName, '/', trialName, sep='')))
              setwd(paste(getwd(), '/', folderName, '/', trialName, '/DSSAT45/', sep=''))
              
              #Set up DSSATPRO.L45 file
              x = readLines("DSSATPRO.L45")
              fileName = paste(rootName, '/', folderName, '/', trialName, '/DSSAT45/', sep='')
              y = gsub('DSSAT45/', fileName, x)
              cat(y, file=paste(getwd(), "/DSSATPRO.L45", sep=''), sep="\n")
              
              #Fix DSSATBatch.v45
              pathName = paste(rootName, '/', folderName, '/', trialName, '/DSSAT45/Maize/SAWA0402.MZX', sep="")
              spaces = ' '
              for(iter in 1:(98 - length(strsplit(pathName, "")[[1]]) - 2))
                spaces = paste(spaces, ' ', sep="")
              
              pathName = paste(pathName, spaces, sep="")
              
              s = readLines(paste(rootName, '/', folderName, '/', trialName, "/DSSAT45/Maize/DSSBatch.v45", sep=""))
              y = gsub('/DSSAT45/Maize/SAWA0402.MZX                                                                      ', pathName, s)
              cat(y, file=paste(getwd(), "/Maize/DSSBatch.v45", sep=""), sep='\n')              
              
              fertilizerDates = c()
              
              #Calculate how much P and N must be applied in each
              #fertilizer application to make numbers work
              fertilizer_P_Amt = round(total_fertilizer_P_Amt/fertilizer_P_times);
              fertilizer_N_Amt = round(total_fertilizer_N_Amt/fertilizer_N_times);
              
              
              #Write input that doesn't change to output file
              fileX = '*TREATMENTS                        -------------FACTOR LEVELS------------'
              fileX = rbind(fileX, '@N R O C TNAME.................... CU FL SA IC MP MI MF MR MC MT ME MH SM')
              treatments = ' 1' #N - trial #
              treatments = paste(treatments, ' 1', sep='') #R - rotation options
              treatments = paste(treatments, ' 1', sep='') #O - rotation options
              treatments = paste(treatments, ' 0', sep='') #C
              treatments = paste(treatments, ' Trial                    ', sep='') #TNAME - trial name
              treatments = paste(treatments, '  1', sep='')          #CU
              treatments = paste(treatments, '  1', sep='')          #FL
              treatments = paste(treatments, '  1', sep='')          #SA - soil anlayiss treatment table (1 or 0)
              treatments = paste(treatments, '  1', sep='')          #IC - initial conditions
              treatments = paste(treatments, '  1', sep='')          #MP - planting method
              treatments = paste(treatments, '  1', sep='')          #MI - irrigation method
              treatments = paste(treatments, '  1', sep='')          #MF - fertilization method
              treatments = paste(treatments, '  0', sep='')          #MR - residue method
              treatments = paste(treatments, '  0', sep='')          #MC - chemical applications
              treatments = paste(treatments, '  0', sep='')          #MT - tillage
              treatments = paste(treatments, '  0', sep='')          #ME - environmental modification
              treatments = paste(treatments, '  0', sep='')          #MH - harvest methods
              treatments = paste(treatments, '  1', sep='')          #SM - simulation method
              fileX = rbind(fileX, treatments)
              
              fileX = rbind(fileX, ' ')
              fileX = rbind(fileX, '*CULTIVARS')
              fileX = rbind(fileX, '@C CR INGENO CNAME')
              cultivars = ' 1'                    #C level
              cultivars = paste(cultivars, ' MZ', sep='') #crop type
              cultivars = paste(cultivars, ' IB0009', sep='') #INGENO
              cultivars = paste(cultivars, ' DEKALB XL71', sep='') #CNAME
              fileX = rbind(fileX, cultivars)

              fileX = rbind(fileX, ' ')
              fileX = rbind(fileX, '*FIELDS')
              fileX = rbind(fileX, '@L ID_FIELD WSTA....  FLSA  FLOB  FLDT  FLDD  FLDS  FLST SLTX  SLDP  ID_SOIL    FLNAME')
              fields = ' 1'
              fields = paste(fields, ' WA040001', sep='')
              fields = paste(fields, ' GHWA      ', sep='')
              fields = paste(fields, ' -99  ', sep='')
              fields = paste(fields, ' -99  ', sep='')
              fields = paste(fields, ' -99  ', sep='')
              fields = paste(fields, ' -99  ', sep='')
              fields = paste(fields, ' -99  ', sep='')
              fields = paste(fields, ' -99 ', sep='')
              fields = paste(fields, ' -99  ', sep='')
              fields = paste(fields, ' -99 ', sep='')
              fields = paste(fields, ' IB00000012', sep='')
              fields = paste(fields, ' -99', sep='')
              fileX = rbind(fileX, fields)
              fileX = rbind(fileX, '@L ...........XCRD ...........YCRD .....ELEV .............AREA .SLEN .FLWR .SLAS FLHST FHDUR')
              fields = ' 1            '
              fields = paste(fields, ' -99            ', sep='')
              fields = paste(fields, ' -99      ', sep='')
              fields = paste(fields, ' -99              ', sep='')
              fields = paste(fields, ' -99  ', sep='')
              fields = paste(fields, ' -99  ', sep='')
              fields = paste(fields, ' -99  ', sep='')
              fields = paste(fields, ' -99  ', sep='')
              fields = paste(fields, ' -99  ', sep='')
              fields = paste(fields, ' -99', sep='')
              fileX = rbind(fileX, fields)

              fileX = rbind(fileX, ' ')
              fileX = rbind(fileX, '*SOIL ANALYSIS')
              fileX = rbind(fileX, '@A SADAT  SMHB  SMPX  SMKE  SANAME')
              soil = ' 1'
              soil = paste(soil, ' 04169  ', sep='')
              soil = paste(soil, ' -99', sep='')
              soil = paste(soil, ' SA005  ', sep='')
              soil = paste(soil, ' -99 ', sep='')
              soil = paste(soil, ' -99', sep='')
              fileX = rbind(fileX, soil)
              fileX = rbind(fileX, '@A  SABL  SADM  SAOC  SANI SAPHW SAPHB  SAPX  SAKE  SASC')
              soil = ' 1    '
              soil = paste(soil, ' 5  ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' .49  ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' -99    ', sep='')
              soil = paste(soil, ' 6  ', sep='')
              soil = paste(soil, ' -99 ', sep='')
              soil = paste(soil, ' .48', sep='')
              fileX = rbind(fileX, soil)
              soil = ' 1    '
              soil = paste(soil, '15  ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' .48  ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' -99    ', sep='')
              soil = paste(soil, ' 5  ', sep='')
              soil = paste(soil, ' -99 ', sep='')
              soil = paste(soil, ' .47', sep='')
              fileX = rbind(fileX, soil)
              soil = ' 1    '
              soil = paste(soil, '30  ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' .3   ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' -99    ', sep='')
              soil = paste(soil, ' 2  ', sep='')
              soil = paste(soil, ' -99 ', sep='')
              soil = paste(soil, ' .29', sep='')
              fileX = rbind(fileX, soil)
              soil = ' 1    '
              soil = paste(soil, '45  ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' .1   ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' -99    ', sep='')
              soil = paste(soil, ' 1  ', sep='')
              soil = paste(soil, ' -99 ', sep='')
              soil = paste(soil, ' .1', sep='')
              fileX = rbind(fileX, soil)
              soil = ' 1    '
              soil = paste(soil, '60  ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' .1   ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' -99  ', sep='')
              soil = paste(soil, ' -99    ', sep='')
              soil = paste(soil, ' 1  ', sep='')
              soil = paste(soil, ' -99 ', sep='')
              soil = paste(soil, ' .1', sep='')
              fileX = rbind(fileX, soil)
              
              fileX = rbind(fileX, ' ')
              fileX = rbind(fileX, '*INITIAL CONDITIONS')
              fileX = rbind(fileX, '@C   PCR ICDAT  ICRT  ICND  ICRN  ICRE  ICWD ICRES ICREN ICREP ICRIP ICRID ICNAME')
              conditions = ' 1   '
              conditions = paste(conditions, ' MZ', sep='')
              conditions = paste(conditions, ' 04168  ', sep='')
              conditions = paste(conditions, ' -99  ', sep='')
              conditions = paste(conditions, ' -99    ', sep='')
              conditions = paste(conditions, ' 1    ', sep='')
              conditions = paste(conditions, ' 1  ', sep='')
              conditions = paste(conditions, ' -99  ', sep='')
              conditions = paste(conditions, ' -99  ', sep='')
              conditions = paste(conditions, ' -99  ', sep='')
              conditions = paste(conditions, ' -99  ', sep='')
              conditions = paste(conditions, ' -99  ', sep='')
              conditions = paste(conditions, ' -99 ', sep='')
              conditions = paste(conditions, ' -99', sep='')
              fileX = rbind(fileX, conditions)
              fileX = rbind(fileX, '@C  ICBL  SH2O  SNH4  SNO3')
              conditions =  ' 1    '
              conditions = paste(conditions, ' 5 ', sep='')
              conditions = paste(conditions, ' .096   ', sep='')
              conditions = paste(conditions, ' .3   ', sep='')
              conditions = paste(conditions, ' .1', sep='')
              fileX = rbind(fileX, conditions)
              conditions =  ' 1    '
              conditions = paste(conditions, '15 ', sep='')
              conditions = paste(conditions, ' .096   ', sep='')
              conditions = paste(conditions, ' .3   ', sep='')
              conditions = paste(conditions, ' .1', sep='')
              fileX = rbind(fileX, conditions)
              conditions =  ' 1    '
              conditions = paste(conditions, '30 ', sep='')
              conditions = paste(conditions, ' .097   ', sep='')
              conditions = paste(conditions, ' .2   ', sep='')
              conditions = paste(conditions, ' .1', sep='')
              fileX = rbind(fileX, conditions)
              conditions =  ' 1    '
              conditions = paste(conditions, '45 ', sep='')
              conditions = paste(conditions, ' .097   ', sep='')
              conditions = paste(conditions, ' .2   ', sep='')
              conditions = paste(conditions, ' .1', sep='')
              fileX = rbind(fileX, conditions)
              conditions =  ' 1    '
              conditions = paste(conditions, '60 ', sep='')
              conditions = paste(conditions, ' .097   ', sep='')
              conditions = paste(conditions, ' .1   ', sep='')
              conditions = paste(conditions, ' .1', sep='')
              fileX = rbind(fileX, conditions)
              
              fileX = rbind(fileX, '')
              fileX = rbind(fileX, '*PLANTING DETAILS')
              fileX = rbind(fileX, '@P PDATE EDATE  PPOP  PPOE  PLME  PLDS  PLRS  PLRD  PLDP  PLWT  PAGE  PENV  PLPH  SPRL                        PLNAME')
              planting = ' 1'
              planting = paste(planting, ' 04169  ', sep='')
              planting = paste(planting, ' -99  ', sep='')
              planting = paste(planting, ' 7.5  ', sep='')
              planting = paste(planting, ' 7.5    ', sep='')
              planting = paste(planting, ' S    ', sep='')
              planting = paste(planting, ' R   ', sep='')
              planting = paste(planting, ' 75  ', sep='')
              planting = paste(planting, ' -99    ', sep='')
              planting = paste(planting, ' 5  ', sep='')
              planting = paste(planting, ' -99  ', sep='')
              planting = paste(planting, ' -99  ', sep='')
              planting = paste(planting, ' -99  ', sep='')
              planting = paste(planting, ' -99  ', sep='')
              planting = paste(planting, ' -99  ', sep='')
              planting = paste(planting, ' -99', sep='')
              fileX = rbind(fileX, planting)

              fileX = rbind(fileX, '')
              fileX = rbind(fileX, '*IRRIGATION AND WATER MANAGEMENT')
              fileX = rbind(fileX, '@I EFIR   IDEP  ITHR  IEPT  IOFF  IAME  IAMT IRNAME')
              irrigation = ' 1'
              irrigation = paste(irrigation, ' 1.00  ', sep='')
              irrigation = paste(irrigation, ' 30   ', sep='')
              irrigation = paste(irrigation, ' 50   ', sep='')
              irrigation = paste(irrigation, ' 100  ', sep='')
              irrigation = paste(irrigation, ' IB001', sep='')
              irrigation = paste(irrigation, ' IB001', sep='')
              irrigation = paste(irrigation, ' 15  ', sep='')
              irrigation = paste(irrigation, ' -99', sep='')
              fileX = rbind(fileX, irrigation)
              
              days_of_irr_left = ceiling(crop_Season_Length/days_Between_Water_App);
              waterUsed = 0
              water_Per_Application = round((total_water-waterUsed) / days_of_irr_left);
              waterUsed = waterUsed + water_Per_Application;
              days_of_irr_left = days_of_irr_left - 1;
              
              fileX = rbind(fileX, '@I IDATE  IROP  IRVAL')
              irrigation = ' 1'
              irrigation = paste(irrigation, ' 04169', sep='')
              irrigation = paste(irrigation, ' IR001  ', sep='')
              irrigation = paste(irrigation, water_Per_Application, sep='')
              fileX = rbind(fileX, irrigation)

              #Write rows specifying the days to apply water
              #rowNum = 44;
              year = plantingYear;
              day = plantingDay;
              for (j in 1:days_of_irr_left)
              {
                irrigation = ' 1'

                water_Per_Application = round((total_water-waterUsed) / days_of_irr_left);
                waterUsed = waterUsed + water_Per_Application;
                days_of_irr_left = days_of_irr_left - 1;
                
                day = day + days_Between_Water_App;
                #If addition of days has pushed us into next
                #year, fix numbers accordingly
                if (day > 365)
                {
                  year = year+1;
                  day = day - 365;
                }
                if (year > 99)
                  year = year - 100;
                
              
                #Make sure if year is in the first decade of
                #the century, it still prints a 0 in front
                if (floor(year/10) == 0)
                  irrigation = paste(irrigation, paste('0', year*1000+day, sep=''), sep=' ')
                else
                  irrigation = paste(irrigation, (year*1000+day), sep=' ')
                
                irrigation = paste(irrigation, ' IR001 ', sep='')
                irrigation = paste(irrigation, water_Per_Application, sep=' ')
                
                fileX = rbind(fileX, irrigation)
              }
              
              fileX = rbind(fileX, '')
              fileX = rbind(fileX, '*FERTILIZERS (INORGANIC)')
              fileX = rbind(fileX, '@F FDATE  FMCD  FACD  FDEP  FAMN  FAMP  FAMK  FAMC  FAMO  FOCD FERNAME')
              
              #rowNum = rowNum + 3;
              day = plantingDay
              year = plantingYear
              
              fertilizerDates = c()
              
              #Calculate each day fertilizer will be applied
              
              if (fertilizer_P_times > 0)
              {
                for (PApplications in 1:fertilizer_P_times)
                {
                  fertilizer = c()
                  fertilizer[1] = year
                  fertilizer[2] = day
                  fertilizer[3] = 1
                
                  day = day + floor(30/fertilizer_P_times);
                  if (day > 365)
                  {
                    year = year+1
                    day = day - 365
                  }
                  if (year > 99)
                    year = year - 100
  
                  fertilizerDates = rbind(fertilizerDates, fertilizer)                      
                }
              }
              
              if (fertilizer_N_times > 0)
              {
                day = plantingDay
                year = plantingYear
                for (NApplications in 1:fertilizer_N_times)
                {
                  fertilizer = c()
                  fertilizer[1] = year
                  fertilizer[2] = day
                  fertilizer[3] = 2
                  
                  day = day + floor(30/fertilizer_N_times)
                  if (day > 365)
                  {
                    year = year+1
                    day = day - 365
                  }
                  if (year > 99)
                  year = year - 100
                  
                  fertilizerDates = rbind(fertilizerDates, fertilizer)
                }
              }
              
              if (length(fertilizerDates) == 0)
              {
                fertilizerDates = c(plantingYear, plantingDay, 3)
              }
              if (length(fertilizerDates) == 3)
              {
                fertilizerDates = rbind(fertilizerDates, c(plantingYear, plantingDay, 3))
              }

              #Fertilizer input rows must be listed in order, so
              #sort the array we just made by day              
              fertilizerDates = fertilizerDates[order(fertilizerDates[,2]),]
              
              minYear = min(fertilizerDates[,1])
              #If days corresponding to later years ended up at
              #beginning of array, move them to the end
              while (fertilizerDates[1, 1] > minYear)
              {
                fertilizerDates = matrix(rbind(fertilizerDates[2:length(fertilizerDates[,1]),], fertilizerDates[1,]), ncol=3, nrow=length(fertilizerDates[,1]))
              }
              
              firstP = 0
              firstN = 0
              
              #Transfer these fertilizer dates to output file
              for (i in 1:(length(fertilizerDates)/3))
              {
                fertilizer = ' 1'
                if (floor(fertilizerDates[i,1]/10) == 0) {
                  fertilizer = paste(fertilizer, paste('0', fertilizerDates[i,1]*1000+fertilizerDates[i,2], sep=''), sep = ' ') 
                } else {
                  fertilizer = paste(fertilizer, (fertilizerDates[i,1]*1000+fertilizerDates[i,2]), sep = ' ') 
                }
                
                if (i != length(fertilizerDates[,1]) && fertilizerDates[i, 2] == fertilizerDates[i+1,2])
                  fertilizerDates[i+1,2] = fertilizerDates[i+1,2] + 1;
                
                if (fertilizerDates[i, 3] == 1)   #Applying phosphorus
                {
                  fertilizer = paste(fertilizer, ' FE013', sep='')
                  fertilizer = paste(fertilizer, ' AP002   ', sep = '')
                  fertilizer = paste(fertilizer, ' 15    ', sep = '')
                  fertilizer = paste(fertilizer, ' 0', sep = '')

                  for (l in 1:(6-length(strsplit(as.character(fertilizer_P_Amt),"")[[1]])))
                    fertilizer = paste(fertilizer, ' ', sep='')
              
                  if (firstP == 0)
                  {
                    fertilizer = paste(fertilizer, (total_fertilizer_P_Amt - fertilizer_P_Amt*(fertilizer_P_times-1)), sep='')
                    firstP = 1;
                  } else 
                    fertilizer = paste(fertilizer, fertilizer_P_Amt, sep='')
                }
                else if (fertilizerDates[i, 3] == 2) #applying nitrogen
                {
                  fertilizer = paste(fertilizer, ' FE005', sep ='')
                  fertilizer = paste(fertilizer, ' AP002   ', sep = '')
                  fertilizer = paste(fertilizer, ' 15', sep = '')

                  for (l in 1:(6-length(strsplit(as.character(fertilizer_N_Amt),"")[[1]])))
                    fertilizer = paste(fertilizer, ' ', sep = '')
              
                  if (firstN == 0)
                  {
                    fertilizer = paste(fertilizer, (total_fertilizer_N_Amt - fertilizer_N_Amt*(fertilizer_N_times-1)), sep = '')
                    firstN = 1;
                  } else
                    fertilizer = paste(fertilizer, fertilizer_N_Amt, sep = '')
                  
                  fertilizer = paste(fertilizer, '     0', sep = '')
                } else    #No fertilizer will be applied all season
                {
                  fertilizer = paste(fertilizer, ' FE005', sep = '')
                  fertilizer = paste(fertilizer, ' AP002   ', sep = '')
                  fertilizer = paste(fertilizer, ' 15    ', sep = '')
                  fertilizer = paste(fertilizer, ' 0 ', sep = '')
                  fertilizer = paste(fertilizer, '    0', sep = '')
                }

                fertilizer = paste(fertilizer, '   -99  ', sep = '')
                fertilizer = paste(fertilizer, ' -99  ', sep = '')
                fertilizer = paste(fertilizer, ' -99  ', sep = '')
                fertilizer = paste(fertilizer, ' -99', sep = '')
                fertilizer = paste(fertilizer, ' no fertilizer', sep = '')
                
                fileX = rbind(fileX, fertilizer)
              }
              
              fileX = rbind(fileX, ' ')
              fileX = rbind(fileX, '*SIMULATION CONTROLS')
              fileX = rbind(fileX, '@N GENERAL     NYERS NREPS START SDATE RSEED SNAME.................... SMODEL')
              simulation = ' 1'
              simulation = paste(simulation, ' GE             ', sep='')
              simulation = paste(simulation, ' 1    ', sep = '')
              simulation = paste(simulation, ' 1    ', sep = '')
              simulation = paste(simulation, ' S', sep = '')
              simulation = paste(simulation, ' 04168 ', sep = '')
              simulation = paste(simulation, ' 2150', sep = '')
              simulation = paste(simulation, ' DEFAULT SIMULATION CONTR', sep = '')
              fileX = rbind(fileX, simulation)
              fileX = rbind(fileX, '@N OPTIONS     WATER NITRO SYMBI PHOSP POTAS DISES  CHEM  TILL   CO2')
              simulation = ' 1'
              simulation = paste(simulation, ' OP             ', sep = '')
              simulation = paste(simulation, ' Y    ', sep = '')
              simulation = paste(simulation, ' Y    ', sep = '')
              simulation = paste(simulation, ' N    ', sep = '')
              simulation = paste(simulation, ' Y    ', sep = '')
              simulation = paste(simulation, ' N    ', sep = '')
              simulation = paste(simulation, ' N    ', sep = '')
              simulation = paste(simulation, ' N    ', sep = '')
              simulation = paste(simulation, ' Y    ', sep = '')
              simulation = paste(simulation, ' M', sep = '')
              fileX = rbind(fileX, simulation)
              fileX = rbind(fileX, '@N METHODS     WTHER INCON LIGHT EVAPO INFIL PHOTO HYDRO NSWIT MESOM MESEV MESOL')
              simulation = ' 1'
              simulation = paste(simulation, ' ME             ', sep='')
              simulation = paste(simulation, ' M    ', sep='')
              simulation = paste(simulation, ' M    ', sep='')
              simulation = paste(simulation, ' E    ', sep='')
              simulation = paste(simulation, ' R    ', sep='')
              simulation = paste(simulation, ' S    ', sep='')
              simulation = paste(simulation, ' L    ', sep='')
              simulation = paste(simulation, ' R    ', sep='')
              simulation = paste(simulation, ' 1    ', sep='')
              simulation = paste(simulation, ' P    ', sep='')
              simulation = paste(simulation, ' S    ', sep='')
              simulation = paste(simulation, ' 2', sep='')
              fileX = rbind(fileX, simulation)
              fileX = rbind(fileX, '@N MANAGEMENT  PLANT IRRIG FERTI RESID HARVS')
              simulation = ' 1'
              simulation = paste(simulation, ' MA             ', sep='')
              simulation = paste(simulation, ' R    ', sep='')
              simulation = paste(simulation, ' R    ', sep='')
              simulation = paste(simulation, ' R    ', sep='')
              simulation = paste(simulation, ' N    ', sep='')
              simulation = paste(simulation, ' M', sep='')
              fileX = rbind(fileX, simulation)
              fileX = rbind(fileX, '@N OUTPUTS     FNAME OVVEW SUMRY FROPT GROUT CAOUT WAOUT NIOUT MIOUT DIOUT VBOSE CHOUT OPOUT')
              simulation = ' 1'
              simulation = paste(simulation, ' OU             ', sep = '')
              simulation = paste(simulation, ' N    ', sep = '')
              simulation = paste(simulation, ' Y    ', sep = '')
              simulation = paste(simulation, ' Y    ', sep = '')
              simulation = paste(simulation, ' 1    ', sep = '')
              simulation = paste(simulation, ' Y    ', sep = '')
              simulation = paste(simulation, ' Y    ', sep = '')
              simulation = paste(simulation, ' Y    ', sep = '')
              simulation = paste(simulation, ' Y    ', sep = '')
              simulation = paste(simulation, ' Y    ', sep = '')
              simulation = paste(simulation, ' N    ', sep = '')
              simulation = paste(simulation, ' Y    ', sep = '')
              simulation = paste(simulation, ' N    ', sep = '')
              simulation = paste(simulation, ' Y', sep = '')
              fileX = rbind(fileX, simulation)

              fileX = rbind(fileX, '')
              fileX = rbind(fileX, '@  AUTOMATIC MANAGEMENT')
              fileX = rbind(fileX, '@N PLANTING    PFRST PLAST PH2OL PH2OU PH2OD PSTMX PSTMN')
              automatic = ' 1'
              automatic = paste(automatic, ' PL         ', sep = '')
              automatic = paste(automatic, ' 04001', sep = '')
              automatic = paste(automatic, ' 04001   ', sep = '')
              automatic = paste(automatic, ' 40  ', sep = '')
              automatic = paste(automatic, ' 100   ', sep = '')
              automatic = paste(automatic, ' 30   ', sep = '')
              automatic = paste(automatic, ' 40   ', sep = '')
              automatic = paste(automatic, ' 10', sep = '')
              fileX = rbind(fileX, automatic)
              fileX = rbind(fileX, '@N IRRIGATION  IMDEP ITHRL ITHRU IROFF IMETH IRAMT IREFF')
              automatic = ' 1'
              automatic = paste(automatic, ' IR            ', sep = '')
              automatic = paste(automatic, ' 30   ', sep = '')
              automatic = paste(automatic, ' 50  ', sep = '')
              automatic = paste(automatic, ' 100', sep = '')
              automatic = paste(automatic, ' GS000', sep = '')
              automatic = paste(automatic, ' IR001   ', sep = '')
              automatic = paste(automatic, ' 10    ', sep = '')
              automatic = paste(automatic, ' 1', sep = '')
              fileX = rbind(fileX, automatic)
              fileX = rbind(fileX, '@N NITROGEN    NMDEP NMTHR NAMNT NCODE NAOFF')
              automatic = ' 1'
              automatic = paste(automatic, ' NI            ', sep = '')
              automatic = paste(automatic, ' 30   ', sep = '')
              automatic = paste(automatic, ' 50   ', sep = '')
              automatic = paste(automatic, ' 25', sep = '')
              automatic = paste(automatic, ' FE001', sep = '')
              automatic = paste(automatic, ' GS000', sep = '')
              fileX = rbind(fileX, automatic)
              fileX = rbind(fileX, '@N RESIDUES    RIPCN RTIME RIDEP')
              automatic = ' 1'
              automatic = paste(automatic, ' RE           ', sep = '')
              automatic = paste(automatic, ' 100    ', sep = '')
              automatic = paste(automatic, ' 1   ', sep = '')
              automatic = paste(automatic, ' 20', sep = '')
              fileX = rbind(fileX, automatic)
              fileX = rbind(fileX, '@N HARVEST     HFRST HLAST HPCNP HPCNR')
              automatic = ' 1'
              automatic = paste(automatic, ' HA             ', sep = '')
              automatic = paste(automatic, ' 0', sep = '')
              automatic = paste(automatic, ' 00001  ', sep = '')
              automatic = paste(automatic, ' 100    ', sep = '')
              automatic = paste(automatic, ' 0', sep = '')
              fileX = rbind(fileX, automatic)
              
              #Save output to SAWA0402.txt file
              setwd(paste(getwd(), '/Maize', sep=''))
              write(fileX, file='SAWA0402.MZX', sep ='')
              
              #Run DSSAT and capture output in w
              #setwd(paste(getwd(), '/Maize', sep=''))
              w = system('../DSCSM045.EXE B DSSBatch.v45', intern = TRUE)
              w = w[24]
              #cd ..;
              #cd ..;
              #split output into an array
              output = strsplit(w, '\\s+')
              
              variables = c(output[[1]][8], waterFreq, waterAmt, fertNfreq, fertNAmt, fertPFreq, fertPAmt)
              
              #cd(trialName);
              #harvests = rbind(harvests, variables)
              write(variables, file='variables.out', sep=' ')
              
              setwd('..')
              setwd('..')
              
              #cd ..;
              #movefile(strcat(trialName, '/variables.out'), strcat(trialName, '/Maize'));
              
              setwd('..')
              
              dir.create(paste(trialName, '-Results', sep=''))
              system(paste('cp ', paste(getwd(), '/', trialName, '/DSSAT45/Maize/variables.out', sep=''), paste(getwd(), '/', trialName, '-Results/', sep='')))
              system(paste('rm -rf', paste(getwd(), '/', trialName, sep='')))
              #unlink(paste(getwd(), '/', trialName, sep='')) #rmdir(trialName, 's');
              
             # setwd(paste(getwd(), '/', folderName, sep=''))
              timeElapsed = timeElapsed + (proc.time() - startTime)[3]
            }
          }
        }
      }
    }
    #Display for the user how close we are to being done
    #paste("About ", (which(waterFreqRange==waterFreq)-1) / length(waterFreqRange) * 100, "% done")
  }

#Build results array to summarize in overall text file
harvests = c()

setwd(paste(rootName, '/', folderName, sep=''))
folders = list.files()
for (folder in folders)
{
  setwd(paste(getwd(), '/', folder, sep=''))
  
  #read variables in this particular trial
  x = readLines("variables.out")
  harvests = rbind(harvests, x)
  
  setwd('..')
}

write.table(harvests, file='results', sep='\t', col.names=FALSE, row.names=FALSE, quote=FALSE)
#write(harvests, file='results', sep='')
maxHarvest = harvests[which(harvests == max(harvests[,1])),]
write.table(maxHarvest, file='bestPractice', sep='\t', col.names=FALSE, row.names=FALSE, quote=FALSE)
#write(maxHarvest, file='bestPractice', sep='')

return(timeElapsed)
}
