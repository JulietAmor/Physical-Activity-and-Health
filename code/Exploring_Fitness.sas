filename fit url "https://raw.githubusercontent.com/JulietAmor/Physical-Activity-and-Health/main/data/25.csv";
data WORK.Kaggle_Fitness;
       infile fit delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=2;
          informat date ANYDTDTE12. ;
          informat step_count best12. ;
          informat mood best12.;
          informat calories_burned best12.;
          informat hours_of_sleep best12.;
          informat bool_of_active best12.;
          informat weight_kg best12.;
          format date date9. ;
          format step_count best12. ;
          format mood best12. ;
          format calories_burned best12. ;
          format hours_of_sleep best12. ;
          format bool_of_active best12.;
          format weight_kg best12.;
       input
                   date  
                   step_count  
                   mood  
                   calories_burned  
                   hours_of_sleep  
                   bool_of_active  
                   weight_kg  
       ;

run;

proc contents data=Kaggle_Fitness;
run;

ods graphics;
proc univariate data=Kaggle_Fitness plot;
   var step_count calories_burned hours_of_sleep weight_kg;
run;

proc sgplot data=Kaggle_Fitness;
   series y=step_count x=date;
run;

/*Build day of week*/
data work.Kaggle_Fitness_wd;
   set Kaggle_Fitness;
   day_of_week=weekday(date);
   if day_of_week in (1 2 3 4) then weekend=0;
   else weekend=1;
run;

proc ttest data=Kaggle_Fitness_wd;
   class weekend;
   var step_count;
run;

proc sgplot data=Kaggle_Fitness;
   series y=calories_burned x=date;
run;

proc corr data=Kaggle_Fitness_wd;
   var step_count calories_burned;
run;

proc sgplot data=Kaggle_Fitness_wd;
   scatter x=step_count y=calories_burned;
   reg x=step_count y=calories_burned;
run;

proc sort data=Kaggle_Fitness_wd;

by weekend;

run;

proc boxplot data=Kaggle_Fitness_wd;

plot step_count*weekend / cboxes=black;

run;

proc boxplot data=Kaggle_Fitness_wd;

plot calories_burned*weekend / cboxes=black;

run;

proc sort data=Kaggle_Fitness_wd;
   by weekend;
run;

proc kde data = Kaggle_Fitness_wd;
by weekend;
univar step_count (gridl=0 gridu=7500) / NGRID=51 unistats percentiles plots=none /*(plots=(density HISTDENSITY)*/
     out = steps;
run;

data steps;
  set steps;
    mirror=-density;
zero=0;
run;

proc sgpanel data=steps nocycleattrs;
  panelby weekend / layout=columnlattice onepanel
    novarname noborder colheaderpos=bottom;
  band y=VALUE upper=density lower=mirror / fill outline;
  highlow y=VALUE high=density low=zero / lineattrs=(thickness=4) transparency=0.5;
  rowaxis label='Cholesterol' grid;
  colaxis display=none;
run;
