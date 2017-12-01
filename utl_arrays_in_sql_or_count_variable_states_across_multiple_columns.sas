Arrays in SQL or Count Variable States Across Multiple Columns using Proc Sql

I am looking for a proc sql approach to summarize a set of variables that have only 3 states
of Valid, Missing, or OOR (out of range) values and represented by 0, 1, or 2, respectively.

In the data set below, there are two groups with four variables that have 3 states (0,1, or 2).

github this post
https://goo.gl/LBMjou
https://github.com/rogerjdeangelis/utl_arrays_in_sql_or_count_variable_states_across_multiple_columns

github do_over macro
https://github.com/rogerjdeangelis/utl_sql_looping_or_using_arrays_in_sql

INPUT
=====
                                        |
    Up to 40 obs WORK.HAVE total obs=8  |            RULES
                                        |            =====
    Obs    GRP    V1    V2    V3    V4  |
                                        |
     1      1      0     0     0     1  | * for V1 in GRP 1 we have 4 (valids=0), 0 (missings=1) and 0 (oors=2)
     2      1      0     0     0     1  | so the result is
     3      1      0     1     0     1  |
     4      1      0     1     0     1  |    GRP  COLUMN      VALID      MISS      OOR
                                        |
     5      2      1     1     0     2  |     1     V1          4         0         0
     6      2      1     1     0     2  |     1     V2          2         2         0
     7      2      1     2     2     2  |    ..
     8      2      1     2     2     2  |


PROCESS (all the code)
=======================

  proc sql;
    create
      table want1 as
       %array(vs,values=1-4)
       %do_over(vs,phrase=
         select
            grp %str(,)
            "v?" as column  %str(,)
            sum(v? = 0) as  valid %str(,)
            sum(v? = 1) as   miss %str(,)
            sum(v? = 2) as    oor
         from  have
         group by grp
         ,between=union
       )
  ;quit;


   * do over generates this code;
   select
       grp
      , "v1" as column
      , sum(v1 = 0) as valid
      , sum(v1 = 1) as miss
      , sum(v1 = 2) as oor
   from
      have
   group
      by grp
   union
   select
       grp
      , "v2" as column
      , sum(v2 = 0) as valid
      , sum(v2 = 1) as miss
      , sum(v2 = 2) as oor
   from
      have
   group
      by grp
   union
   select
       grp
      , "v3" as column
      , sum(v3 = 0) as valid
      , sum(v3 = 1) as miss
      , sum(v3 = 2) as oor
   from
      have
   group
      by grp
   union
   select
       grp
      , "v4" as column
      , sum(v4 = 0) as valid
      , sum(v4 = 1) as miss
      , sum(v4 = 2) as oor
   from
      have
   group
      by grp
   union



OUTPUT
======

    WORK.WANT2 total obs=8

    GRP    COLUMN    VALID    MIS    OOR

     1       v1        4       0      0
     1       v2        2       2      0
     1       v3        4       0      0
     1       v4        0       4      0

     2       v1        0       4      0
     2       v2        0       2      2
     2       v3        2       0      2
     2       v4        0       0      4


https://goo.gl/XAYQoz
https://communities.sas.com/t5/General-SAS-Programming/Count-Variable-States-Across-Multiple-Columns-using-Proc-Sql/m-p/417456

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data have;
length grp $1 v1 v2 v3 v4 4;
input grp v1 v2 v3 v4 ;
cards4;
1 0 0 0 1
1 0 0 0 1
1 0 1 0 1
1 0 1 0 1
2 1 1 0 2
2 1 1 0 2
2 1 2 2 2
2 1 2 2 2
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

  proc sql;
    create
      table want1 as
       %array(vs,values=1-4)
       %do_over(vs,phrase=
         select
           grp %str(,)
           "v?" as column  %str(,)
           sum(v? = 0) as  valid %str(,)
           sum(v? = 1) as   miss %str(,)
           sum(v? = 2) as    oor
         from  have
         group by grp
         ,between=union
       )
  ;quit;





