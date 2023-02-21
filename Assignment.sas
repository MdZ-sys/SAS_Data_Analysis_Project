/* IMPORT DATASET------------------------------------------------------------------------- */
proc import file="/home/u61558684/sasuser.v94/Class/Assignment/Train.csv"
    out=WORK.TRAIN
    dbms=csv;
run;


/* DATA DESCRIPTION --------------------------------------------------------------------------*/
proc means data=work.train;
run;
proc freq data=work.train;
tables Gender/nocum plots=(freqplot);
run;
proc freq data=work.train;
tables Ever_Married/nocum plots=(freplot);
run;
proc freq data=work.train;
tables Graduated/nocum plots=(freqplot);
run;
proc freq data=work.train;
tables Profession/nocum plots=(freqplot);
run;
proc freq data=work.train;
tables Spending_Score/nocum plots=(freqplot);
run;
proc freq data=work.train;
tables Var_1/nocum plots=(freqplot);
run;
proc freq data=work.train;
tables Segmentation/nocum plots=(freqplot);
run;

proc sql;
	select "Age" label="Variable", min(Age) 
		 label="Minimum age" , max(Age) 
		 label="Maximum age" from WORK.TRAIN;
quit;
proc sql;
	select "Work Experience" label="Variable", min(Work_Experience) 
		 label="Minimum Experience" , max(Work_Experience) 
		 label="Maxmum Experience" from WORK.TRAIN;
quit;
proc sql;
	select "Family Size" label="Variable", min(Family_Size) 
		 label="Minimum Size" , max(Family_Size) 
		 label="Maxmum Size" from WORK.TRAIN;
quit;
/* Check Duplicate Vales*/
proc sort data=work.train;
	by _all_;
run;
data work.no_duplicates work.duplicates;
	set work.train;
	by _all_;
 
	if first.ID then output work.no_duplicates;
	else output work.duplicates;
run;
proc contents data=work.duplicates;
run;


/* DATA IDENTIFICATION ----------------------------------------------------------------------------------*/
proc contents data=work.train VARNUM;
run;
/* ID,Age,Work_Experience,Family_Size are Numeric */
/* Gender, Ever_Married, Graduated, Profession, Spending_Score, Var_1 are Character, Segmentation */
DATA firstobs;
set work.train(obs=10);
run;


/* SUMMARY STATS ----------------------------------------------------------------------------------------*/
/*NUMERIC VALUES ----------------------------------------------------------------------------------------*/
Proc means data=work.train;
run; 

Proc Means Data=work.train;
class profession gender;
var age work_experience family_size;
Run;

Proc Means Data=work.train;
class profession gender;
var age work_experience family_size;
Where profession in ("Doctor" "Engineer");
Run;


/* MISSING VALUES ---------------------------------------------------------------------------------------*/
/* detection */
proc format;
	value $missfmt " "="Missing" other="Non-missing";
	value missfmt . ="Missing" other="Non-missing";
run;
proc freq data=work.train;
format _CHAR_ $missfmt.;
format _NUMERIC_ missfmt.;
tables _CHAR_ /missing nocum ;
tables _NUMERIC_ /missing nocum ;
run;


/* MISSING VALUES IMPUTATION-----------------------------------------------------------------------------*/
/* skewness */
proc univariate data=work.train;
var  family_size;
histogram /normal kernel ;
run;

/* family size imputation */
proc print data=work.train (obs=113);
where family_size = . ;
run;
proc stdize data=work.train out=work.a 
/*       oprefix=Orig_         /* prefix for original variables */
      reponly               /* only replace; do not standardize */
      method=MEDIAN;          /* or MEDIAN, MINIMUM, MIDRANGE, etc. */
   var family_size;              /* you can list multiple variables to impute */
run;

/* check */
proc format;
	value $missfmt " "="Missing" other="Non-missing";
	value missfmt . ="Missing" other="Non-missing";
run;
proc freq data=work.a;
format _CHAR_ $missfmt.;
format _NUMERIC_ missfmt.;
tables _CHAR_ /missing nocum ;
tables _NUMERIC_ /missing nocum ;
run;

/*work experience imputation*/
proc print data=work.a (obs=269);
where work_experience = . ;
run;
proc stdize data=work.a out=work.b 
/*       oprefix=Orig_         /* prefix for original variables */
      reponly               /* only replace; do not standardize */
      method=MEDIAN;          /* or MEDIAN, MINIMUM, MIDRANGE, etc. */
   var work_experience;              /* you can list multiple variables to impute */
run;

/* check */
proc format;
	value $missfmt " "="Missing" other="Non-missing";
	value missfmt . ="Missing" other="Non-missing";
run;
proc freq data=work.b;
format _CHAR_ $missfmt.;
format _NUMERIC_ missfmt.;
tables _CHAR_ /missing nocum ;
tables _NUMERIC_ /missing nocum ;
run;

/*ever_married*/
proc print data=work.b (obs=50);
where ever_married = "" ;
run;
proc freq data=work.b;
tables ever_married*age/ nocum;
run;
data work.c;
set work.b;
ever_married = "";
if (age > 35) then ever_married = "Yes";
if (age <= 35) then ever_married = "No";
run;
proc format;
	value $missfmt " "="Missing" other="Non-missing";
	value missfmt . ="Missing" other="Non-missing";
run;
proc freq data=work.c;
format _CHAR_ $missfmt.;
format _NUMERIC_ missfmt.;
tables _CHAR_ /missing nocum nopercent;
tables _NUMERIC_ /missing nocum nopercent;
run;

/*graduated*/
/*mode imputation*/
proc print data=work.c (obs=24);
where graduated = "" ;
run;
data work.mode;
set work.c;
 if graduated = "" then graduated = "No";
run;
proc format;
	value $missfmt " "="Missing" other="Non-missing";
	value missfmt . ="Missing" other="Non-missing";
run;
proc freq data=work.mode;
format _CHAR_ $missfmt.;
format _NUMERIC_ missfmt.;
tables _CHAR_ /missing nocum nopercent;
tables _NUMERIC_ /missing nocum nopercent;
run;

/*hot-deck imputation*/
proc surveyimpute data=work.c method=hotdeck(selection=srswr);
   var gender ever_married age graduated profession work_experience spending_score family_size var_1 segmentation ;
   output out=cleaned;
run; 
proc format;
	value $missfmt " "="Missing" other="Non-missing";
	value missfmt . ="Missing" other="Non-missing";
run;
proc freq data=work.cleaned;
format _CHAR_ $missfmt.;
format _NUMERIC_ missfmt.;
tables _CHAR_ /missing nocum nopercent;
tables _NUMERIC_ /missing nocum nopercent;
run;

DATA obs;
set work.cleaned(obs=10);
run;
data cleaned(drop= id unitid impindex);
set work.cleaned;
run;

DATA obs;
set work.cleaned(obs=10);
run;
/*we now have a cleaned dataset-------------------------------------------------------------------------*/


/*MENTIONING OUTLIERS USING BOXPLOT-------------------------------------------------------------*/
proc sgplot data=WORK.CLEANED;
	vbox Age /;
	yaxis grid;
run;

proc sgplot data=WORK.CLEANED;
	vbox Work_Experience /;
	yaxis grid;
run;

proc sgplot data=WORK.CLEANED;
	vbox Family_Size /;
	yaxis grid;
run;

proc sql;
	select "Age" label="Variable", min(Age) 
		 label="Minimum age" , max(Age) 
		 label="Maximum age" from WORK.cleaned;
quit;
proc sql;
	select "Work Experience" label="Variable", min(Work_Experience) 
		 label="Minimum Experience" , max(Work_Experience) 
		 label="Maxmum Experience" from WORK.cleaned;
quit;
proc sql;
	select "Family Size" label="Variable", min(Family_Size) 
		 label="Minimum Size" , max(Family_Size) 
		 label="Maxmum Size" from WORK.cleaned;
quit;



/*BINNING-----------------------------------------------------------------------------------------*/
/*bucket binning*/
proc hpbin data=work.cleaned numbin=10 bucket;
     input age family_size work_experience;
run;

/*quantile binning*/
proc hpbin data=work.cleaned output=out numbin=5 quantile;
     input age family_size work_experience;
     id age family_size work_experience;
run;
proc print data=out(obs=20); run;

proc sgplot data=WORK.OUT;
	histogram BIN_Age /;
	yaxis grid;
run;

proc sgplot data=WORK.OUT;
	histogram BIN_Work_Experience /;
	yaxis grid;
run;

proc sgplot data=WORK.OUT;
	histogram BIN_Family_Size /;
	yaxis grid;
run;


/*Featrure Transformation---------------------------------------------------------------------------*/
data log1;
   set work.cleaned;
   Log_Age = log( age );
run;

data log2;
   set work.log1;
   Log_Family_Size = log( family_size );
run;

data sq1;
   set work.log2;
   Sq_Work_Experience = sqrt( work_experience );
run;

proc sgplot data=WORK.SQ1;
	histogram Log_Age /;
	yaxis grid;
run;

proc sgplot data=WORK.SQ1;
	histogram Log_Family_Size /;
	yaxis grid;
run;

proc sgplot data=WORK.SQ1;
	histogram Sq_Work_Experience /;
	yaxis grid;
run;

data final(drop= age family_size work_experience);
set work.sq1;
run;

/*final missing data check*/
proc format;
	value $missfmt " "="Missing" other="Non-missing";
	value missfmt . ="Missing" other="Non-missing";
run;
proc freq data=work.final;
format _CHAR_ $missfmt.;
format _NUMERIC_ missfmt.;
tables _CHAR_ /missing nocum ;
tables _NUMERIC_ /missing nocum ;
run;

/*EDA-------------------------------------------------------------------------------------*/
proc contents data=work.final;
run;
DATA obs;
set work.final(obs=10);
run;
proc means data=work.final mean median mode std var min max;
run;
/* Missing values in our dataset */
proc means data=work.final nmiss;
run;
/* Univariate Analysis*/
proc univariate data=work.final  novarcontents;
histogram 'log_age'n 'log_family_size'n 'sq_work_experience'n/ ;
run;
/* Checking Relationship between two variables by using scatter plot */
ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=work.final;
	scatter x='log_age'n y='log_family_size'n /;
	xaxis grid;
	yaxis grid;
run;

ods graphics / reset;
ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=work.final;
	scatter x='log_age'n y='sq_work_experience'n /;
	xaxis grid;
	yaxis grid;
run;
ods graphics / reset;
/* Correaltion among numeric variables */
ods noproctitle;
ods graphics / imagemap=on;
proc corr data=work.final pearson nosimple noprob plots=none;
	var 'log_age'n 'log_family_size'n 'sq_work_experience'n;
run;


/*--------------------xx---------------------------*


/*HYPOTHESIS-------------------------------------------------------------------------------------*/
/*1*/
PROC FREQ data=work.final;
    TABLE gender*var_1 / CHISQ;
RUN;
proc sgplot data=WORK.FINAL;
	vbar Gender / group=Var_1 groupdisplay=cluster;
	yaxis grid;
run;

/*4*/
PROC FREQ data=work.final;
    TABLE graduated*ever_married / CHISQ;
RUN;
proc sgplot data=WORK.FINAL;
	vbar Graduated / group=Ever_Married groupdisplay=cluster;
	yaxis grid;
run;

/*2*/
proc anova data=work.final;
class spending_score;
model log_family_size=spending_score;
run;
proc sgplot data=WORK.FINAL;
	vbar Log_Family_Size / group=Spending_Score groupdisplay=cluster;
	yaxis grid;
run;

/*3*/
PROC CORR DATA=work.final ;
    VAR log_age;
    WITH sq_work_experience;
RUN;
proc sgplot data=WORK.FINAL;
	scatter x=Log_Age y=Sq_Work_Experience /;
	xaxis grid;
	yaxis grid;
run;

/*5*/
PROC TTEST DATA=work.final ALPHA=.05;
   VAR sq_work_experience;
   CLASS gender;
RUN;
proc sgplot data=WORK.FINAL;
	vbar Gender / group=Sq_Work_Experience groupdisplay=cluster;
	yaxis grid;
run;

/*-----------------------------------------------------------------------------*/

/*FEATURE ENGINEERING*-----------------------------------------------------------------------------*/
DATA firstobs;
set work.final(obs=10);
run;


proc corr data=work.final;
run;

PROC FREQ data=work.final;
    TABLE var_1*segmentation / CHISQ;
RUN;
PROC FREQ data=work.final;
    TABLE spending_score*segmentation / CHISQ;
RUN;
PROC FREQ data=work.final;
    TABLE profession*segmentation / CHISQ;
RUN;
PROC FREQ data=work.final;
    TABLE graduated*segmentation / CHISQ;
RUN;
PROC FREQ data=work.final;
    TABLE ever_married*segmentation / CHISQ;
RUN;
PROC FREQ data=work.final;
    TABLE gender*segmentation / CHISQ;
RUN;

/*Label encoding of categorical values*/
data work.laben1;
set work.final;
Length 'Gender_Encoded'n 3;
select;
when (Gender="Male") 'Gender_Encoded'n=0;
when (Gender="Female") 'Gender_Encoded'n=1;
otherwise 'Gender_Encoded'n=2;
end;
run;

data work.laben2;
set work.laben1;
Length 'Ever_Married_Encoded'n 3;
select;
when (Ever_Married="No") 'Ever_Married_Encoded'n=0;
when (Ever_Married="Yes") 'Ever_Married_Encoded'n=1;
otherwise 'Ever_Married_Encoded'n=2;
end;
run;

data work.laben3;
set work.laben2;
Length 'Graduated_Encoded'n 3;
select;
when (Graduated="No") 'Graduated_Encoded'n=0;
when (Graduated="Yes") 'Graduated_Encoded'n=1;
otherwise 'Graduated_Encoded'n=2;
end;
run;

data work.laben4;
set work.laben3;
Length 'Profession_Encoded'n 3;
select;
when (Profession="Artist") 'Profession_Encoded'n=0;
when (Profession="Doctor") 'Profession_Encoded'n=1;
when (Profession="Engineer") 'Profession_Encoded'n=2;
when (Profession="Entertainment") 'Profession_Encoded'n=3;
when (Profession="Executive") 'Profession_Encoded'n=4;
when (Profession="Healthcare") 'Profession_Encoded'n=5;
when (Profession="Homemaker") 'Profession_Encoded'n=6;
when (Profession="Lawyer") 'Profession_Encoded'n=7;
when (Profession="Marketing") 'Profession_Encoded'n=8;
otherwise 'Profession_Encoded'n=9;
end;
run;

data work.laben5;
set work.laben4;
Length 'Spending_Score_Encoded'n 3;
select;
when (Spending_Score="Low") 'Spending_Score_Encoded'n=0;
when (Spending_Score="Average") 'Spending_Score_Encoded'n=1;
when (Spending_Score="High") 'Spending_Score_Encoded'n=2;
otherwise 'Spending_Score_Encoded'n=3;
end;
run;

data work.laben6;
set work.laben5;
Length 'Var_1_Encoded'n 3;
select;
when (Var_1="Cat_1") 'Var_1_Encoded'n=0;
when (Var_1="Cat_2") 'Var_1_Encoded'n=1;
when (Var_1="Cat_3") 'Var_1_Encoded'n=2;
when (Var_1="Cat_4") 'Var_1_Encoded'n=3;
when (Var_1="Cat_5") 'Var_1_Encoded'n=4;
when (Var_1="Cat_6") 'Var_1_Encoded'n=5;
when (Var_1="Cat_7") 'Var_1_Encoded'n=6;
otherwise 'Var_1_Encoded'n=7;
end;
run;

data labenfinal(drop= gender ever_married graduated profession spending_score var_1);
set work.laben6;
run;


/*One-hot encoding*/
data work.ohen1;
set work.final;
Length 'Gender_Male'n 3;
Length 'Gender_Female'n 3;
'Gender_Male'n = 0;
'Gender_Female'n = 0;
select;
when (Gender="Male") 'Gender_Male'n=1;
when (Gender="Female") 'Gender_Female'n=1;
end;
run;

data work.ohen2;
set work.ohen1;
Length 'Ever_Married_Yes'n 3;
Length 'Ever_Married_No'n 3;
'Ever_Married_Yes'n = 0;
'Ever_Married_No'n = 0;
select;
when (Ever_Married="Yes") 'Ever_Married_Yes'n=1;
when (Ever_Married="No") 'Ever_Married_No'n=1;
end;
run;

data work.ohen3;
set work.ohen2;
Length 'Graduated_Yes'n 3;
Length 'Graduated_No'n 3;
'Graduated_Yes'n = 0;
'Graduated_No'n = 0;
select;
when (Graduated="Yes") 'Graduated_Yes'n=1;
when (Graduated="No") 'Graduated_No'n=1;
end;
run;

data work.ohen4;
set work.ohen3;
Length 'Profession_Artist'n 3;
Length 'Profession_Doctor'n 3;
Length 'Profession_Engineer'n 3;
Length 'Profession_Entertainment'n 3;
Length 'Profession_Healthcare'n 3;
Length 'Profession_Homemaker'n 3;
Length 'Profession_Lawyer'n 3;
Length 'Profession_Marketing'n 3;
'Profession_Artist'n = 0;
'Profession_Doctor'n = 0;
'Profession_Engineer'n = 0;
'Profession_Entertainment'n = 0;
'Profession_Healthcare'n = 0;
'Profession_Homemaker'n = 0;
'Profession_Lawyer'n = 0;
'Profession_Marketing'n = 0;
select;
when (Profession="Artist") 'Profession_Artist'n=1;
when (Profession="Doctor") 'Profession_Doctor'n=1;
when (Profession="Engineer") 'Profession_Engineer'n=1;
when (Profession="Entertainment") 'Profession_Entertainment'n=1;
when (Profession="Executive") 'Profession_Executive'n=1;
when (Profession="Healthcare") 'Profession_Healthcare'n=1;
when (Profession="Homemaker") 'Profession_Homemaker'n=1;
when (Profession="Lawyer") 'Profession_Lawyer'n=1;
when (Profession="Marketing") 'Profession_Lawyer'n=1;
end;
run;

data work.ohen5;
set work.ohen4;
Length 'Spending_Score_High'n 3;
Length 'Spending_Score_Average'n 3;
Length 'Spending_Score_Low'n 3;
'Spending_Score_High'n = 0;
'Spending_Score_Average'n = 0;
'Spending_Score_Low'n = 0;
select;
when (Spending_Score="Low") 'Spending_Score_Low'n=1;
when (Spending_Score="Average") 'Spending_Score_Average'n=1;
when (Spending_Score="High") 'Spending_Score_High'n=1;
end;
run;

data work.ohen6;
set work.ohen5;
Length 'Var_1_Cat_1'n 3;
Length 'Var_1_Cat_2'n 3;
Length 'Var_1_Cat_3'n 3;
Length 'Var_1_Cat_4'n 3;
Length 'Var_1_Cat_5'n 3;
Length 'Var_1_Cat_6'n 3;
Length 'Var_1_Cat_7'n 3;
'Var_1_Cat_1'n =0;
'Var_1_Cat_2'n =0;
'Var_1_Cat_3'n =0;
'Var_1_Cat_4'n =0;
'Var_1_Cat_5'n =0;
'Var_1_Cat_6'n =0;
'Var_1_Cat_7'n =0;
select;
when (Var_1="Cat_1") 'Var_1_Cat_1'n=1;
when (Var_1="Cat_2") 'Var_1_Cat_2'n=1;
when (Var_1="Cat_3") 'Var_1_Cat_3'n=1;
when (Var_1="Cat_4") 'Var_1_Cat_4'n=1;
when (Var_1="Cat_5") 'Var_1_Cat_5'n=1;
when (Var_1="Cat_6") 'Var_1_Cat_6'n=1;
when (Var_1="Cat_7") 'Var_1_Cat_7'n=1;
end;
run;
proc contents data=work.ohen6 VARNUM;
run;

data ohenfinal(drop= gender ever_married graduated profession spending_score var_1);
set work.ohen6;
run;

/*standardize continuous data*/
proc stdize data=work.final method=std nomiss out=work.stdize
oprefix sprefix=Standardized_;
var log_age;
var sq_work_experience;
var log_family_size;
run;
proc means data=work.stdize;
run;

/*Principal Component Analysis- Label Encoding*/
proc princomp data=WORK.LABENFINAL plots(only)=(scree);
	var Log_Age Log_Family_Size Sq_Work_Experience Gender_Encoded 
		Ever_Married_Encoded Graduated_Encoded Profession_Encoded 
		Spending_Score_Encoded Var_1_Encoded;
run;


/*-----------------------------------------------------xxxxxx-----------------------------------------------------------*/

