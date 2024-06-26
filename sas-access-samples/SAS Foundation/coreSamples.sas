 /*********************************************************************/
 /*          S A S   S A M P L E   L I B R A R Y                      */
 /*                                                                   */
 /*    NAME: coreSamples.sas                                          */
 /*   TITLE: Sample Programs                                          */
 /* PRODUCT: SAS/ACCESS Software for Relational Databases             */
 /*  SYSTEM: z/OS, UNIX, WINDOWS                                      */
 /*     REF: SAS/ACCESS 9 for Relational Databases: Reference         */
 /*   USAGE: Invoke SAS, submit the autoexec, createLibname,          */
 /*          then submit this program.                                */
 /*    NOTE: Some interfaces require that you add the SAS data set    */
 /*          option, SASDATEFMT=, to the name of the DBMS view        */
 /*          or table to have the output format correctly.            */
 /*    NOTE: Some interfaces are case sensitive. Your may need to     */
 /*          change the case of table or column names to comply       */
 /*          with the requirements of your database.                  */
 /*                                                                   */
 /*********************************************************************/
LIBNAME samples '/home/u63846711/samples';
LIBname samples2 '/home/u63846711/baseline';

 /*=========================*/
 /* LIBNAME Sample 1       */
 /*=========================*/

proc print data=samples.SAMDAT7
   (keep=lname fname state hphone);
   where state = 'NJ';
   title 'Libname Sample 1: New Jersey Phone List';
run;

 /*=========================*/
 /* LIBNAME Sample 2       */
 /*=========================*/

data work.highwage;
  set samples.SAMDAT5(drop=sex birth hired);
  if salary>60000 then
    CATEGORY='High';
  else if salary<30000 then
    CATEGORY='Low';
  else
    CATEGORY='Avg';
run;

proc print data=work.highwage;
  title 'Libname Sample 2: Salary Analysis';
  format SALARY dollar10.2;
run;

 /*=========================*/
 /* LIBNAME Sample 3       */
 /*=========================*/

 data work.combined;
  merge samples.SAMDAT7 samples.SAMDAT8(in=super
    rename=(SUPID=IDNUM));
  by IDNUM;
  if super;
run;

proc print data=work.combined;
  title 'Libname Sample 3: Supervisor Information';
run;

/*==========================*/
/* Rollback Query for SAMDAT5 & 6  */
/* Delete the updated data from the original table */
proc sql;
   delete from samples.SAMDAT7;
   delete from samples.SAMDAT8;
quit;

/* Insert the backup data into the original table */
proc sql;
   insert into samples.SAMDAT7
   select * from samples2.SAMDAT7;
quit;

proc sql;
   insert into samples.SAMDAT8
   select * from samples2.SAMDAT8;
quit;
 /*==========================*/


 /*=========================*/
 /* LIBNAME Sample 4       */
 /*=========================*/

data work.payroll;
  update samples.SAMDAT5
         samples.SAMDAT6;
  by IDNUM;
run;

proc print data=work.payroll;
  title 'Libname Sample 4: Updated Payroll Data';
run;

/*==========================*/
/* Rollback Query for SAMDAT5 & 6  */
/* Delete the updated data from the original table */
proc sql;
   delete from samples.SAMDAT5;
   delete from samples.SAMDAT6;
quit;

/* Insert the backup data into the original table */
proc sql;
   insert into samples.SAMDAT5
   select * from samples2.SAMDAT5;
quit;

proc sql;
   insert into samples.SAMDAT6
   select * from samples2.SAMDAT6;
quit;
 /*==========================*/



 /*=========================*/
 /* LIBNAME Sample 5       */
 /*=========================*/
title 'Libname Sample 5: Total Salary by Jobcode';

proc sql;
  select JOBCODE label='Jobcode',
         sum(SALARY) as total
         label='Total for Group'
         format=dollar11.2
  from samples.SAMDAT5
  group by JOBCODE;
quit;

 /*=========================*/
 /* LIBNAME Sample 6       */
 /*=========================*/

title 'Libname Sample 6: Flights to London and Frankfurt';

proc sql;
  select DATES, DEST from samples.SAMDAT2
  where (DEST eq "FRA") or
    (DEST eq "LON")
  order by DEST;
quit;

 /*=========================*/
 /* LIBNAME Sample 7       */
 /*=========================*/

proc sql;
   title  'Libname Sample 7: International Flights by Flight Number';
   title2 'with Over 200 Passengers';
   select FLIGHT   label="Flight Number",
          DATES    label="Departure Date",
          DEST     label="Destination",
          BOARDED  label="Number Boarded"
     from samples.SAMDAT3
    where BOARDED > 200
    order by FLIGHT;
quit;

 /*=========================*/
 /* LIBNAME Sample 8        */
 /*=========================*/

title 'Libname Sample 8: Employees with salary greater than $40,000';

proc sql;
  select a.LNAME, a.FNAME, b.SALARY
    format=dollar10.2
  from samples.SAMDAT7 a, samples.SAMDAT5 b
  where (a.IDNUM eq b.IDNUM) and
    (b.SALARY gt 40000);
quit;

 /*==========================*/
 /* LIBNAME Sample 9         */
 /*==========================*/

/* SQL Implicit Passthru ON */
title 'Libname Sample 9a: Delayed International Flights in March';

proc sql;
  select distinct samdat1.FLIGHT,
      samdat1.DATES,
      DELAY format=2.0
    from samples.SAMDAT1, samples.SAMDAT2, samples.SAMDAT3
  where samdat1.FLIGHT=samdat2.FLIGHT and
        samdat1.DATES=samdat2.DATES and
        samdat1.FLIGHT=samdat3.FLIGHT and
        DELAY>0
  order by DELAY descending;
quit;


 /*==========================*/
 /* LIBNAME Sample 9c        */
 /*==========================*/

title 'Libname Sample 9c: Delayed International Flights in March';

proc sql;
  select distinct samdat1.FLIGHT,
      samdat1.DATES,
      DELAY format=2.0
    from samples.SAMDAT1
    full join samples.SAMDAT2 on
      samdat1.FLIGHT = samdat2.FLIGHT
    full join samples.SAMDAT3 on
      samdat1.FLIGHT = samdat3.FLIGHT
  order by DELAY descending;
quit;


 /*==========================*/
 /* LIBNAME Sample 10        */
 /*==========================*/

title 'Libname Sample 10: Payrolls 1 & 2';

proc sql;
  select IDNUM, SEX, JOBCODE, SALARY,
         BIRTH,
         HIRED
     from samples.SAMDAT5
  outer union corr
  select *
     from samples.SAMDAT6
   order by IDNUM, JOBCODE, SALARY;
quit;

 /*==========================*/
 /* LIBNAME Sample 11        */
 /*==========================*/


proc sql undo_policy=none;
insert into samples.SAMDAT8
	values('1588','NY','FA');
quit;

proc print data=samples.SAMDAT8;
	title 'Libname Sample 11: New Row in AIRLINE.SAMDAT8';
run;

/*==========================*/
/* Rollback Query for SAMDAT8 */
/* Delete the updated data from the original table */
proc sql;
   delete from samples.SAMDAT8;
quit;

/* Insert the backup data into the original table */
proc sql;
   insert into samples.SAMDAT8
   select * from samples2.SAMDAT8;
quit;
 /*==========================*/



 /*==========================*/
 /* LIBNAME Sample 13        */
 /*==========================*/

proc sql;

  create table work.gtforty as
  select LNAME as lastname,
         FNAME as firstname,
         SALARY as Salary
  from samples.SAMDAT7 a, samples.SAMDAT5 b
  where (a.IDNUM eq b.IDNUM) and (SALARY gt 40000);

quit;

proc print data=work.gtforty noobs;
  title 'Libname Sample 13: Employees with salaries over $40,000';
  format SALARY dollar10.2;

run;

 /*==========================*/
 /* LIBNAME Sample 14        */
 /*==========================*/

title 'Libname Sample 14: Number of Passengers per Flight by Date';

proc print data=samples.SAMDAT1 noobs;
  var DATES BOARDED;
  by FLIGHT DEST;
  sumby FLIGHT;
  sum BOARDED;
run;

title 'Libname Sample 14: Maximum Number of Passengers per Flight';


proc means data=samples.SAMDAT1 fw=5 maxdec=1 max;
  var BOARDED;
  class FLIGHT;
run;

 /*==========================*/
 /* LIBNAME Sample 16       */
 /*==========================*/

title 'Libname Sample 16: Contents of the SAMDAT2 Table';

proc contents data=samples.SAMDAT2;
run;

 /*==========================*/
 /* LIBNAME Sample 17        */
 /*==========================*/

title 'Libname Sample 17: Ranking of Delayed Flights';

options pageno=1;

proc rank data=samples.SAMDAT2 descending
    ties=low out=work.ranked;
  var DELAY;
  ranks RANKING;
run;

proc print data=work.ranked;
  format DELAY 2.0;
run;


 /*==========================*/
 /* LIBNAME Sample 18        */
 /*==========================*/

title 'Libname Sample 18: Number of Employees by Jobcode';

proc tabulate data=samples.SAMDAT5 format=3.0;
   class JOBCODE;
   table JOBCODE*n;
   keylabel n="#";
run;

 /*==========================*/
 /* LIBNAME Sample 19        */
 /*==========================*/

title 'Libname Sample 19: SAMAT5 After Appending SAMDAT6';

proc append base=samples.SAMDAT5
            data=samples.SAMDAT6;
run;

proc print data=samples.SAMDAT5;
run;

/*==========================*/
/* Rollback Query for SAMDAT5 */
/* Delete the updated data from the original table */
proc sql;
   delete from samples.SAMDAT5;
quit;

/* Insert the backup data into the original table */
proc sql;
   insert into samples.SAMDAT5
   select * from samples2.SAMDAT5;
quit;
 /*==========================*/




 /*==========================*/
 /* LIBNAME Sample 20        */
 /*==========================*/

title 'Libname Sample 20: Invoice Frequency by Country';

proc freq data=samples.SAMDAT9 (keep=INVNUM COUNTRY);
  tables COUNTRY;
run;

 /*==========================*/
 /* LIBNAME Sample 21        */
 /*==========================*/

title 'Libname Sample 21: High Bills--Not Paid';

proc sql;
  create view work.allinv as
  select PAIDON, BILLEDON, INVNUM, AMTINUS, BILLEDTO
    from samples.SAMDAT9 (obs=5);
quit;

data work.notpaid(keep=INVNUM BILLEDTO AMTINUS BILLEDON);

  set work.allinv;
  where PAIDON is missing and AMTINUS>=300000.00;
run;

proc print data=work.notpaid label;
  format AMTINUS dollar20.2;
  label  AMTINUS=amountinus
         BILLEDON=billedon
         INVNUM=invoicenum
         BILLEDTO=billedto;
run;

 /*==========================*/
 /* LIBNAME Sample 22        */
 /*==========================*/

title 'Libname Sample 22: Interns Who Are Family Members of Employees';


proc sql;
  create view emp_csr as
  select * from samples.SAMDAT10
    where dept in ('CSR010', 'CSR011', 'CSR004');

  select samdat13.LASTNAME, samdat13.FIRSTNAM, samdat13.EMPID,
         samdat13.FAMILYID, samdat13.GENDER,
         samdat13.DEPT, samdat13.HIREDATE
    from emp_csr, samples.samdat13
    where emp_csr.EMPID=samdat13.FAMILYID;
quit;
