Arrays in SQL or Count Variable States Across Multiple Columns using Proc Sql

github this post
https://goo.gl/LBMjou
https://github.com/rogerjdeangelis/utl_arrays_in_sql_or_count_variable_states_across_multiple_columns

github do_over macro
https://github.com/rogerjdeangelis/utl_sql_looping_or_using_arrays_in_sql



I am looking for a proc sql approach to summarize a set of variables that have only 3 states
of Valid, Missing, or OOR (out of range) values and represented by 0, 1, or 2, respectively.

In the data set below, there are two groups with four variables that have 3 states (0,1, or 2).


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
     4      1      0     1     0     1  |    GRP  COLUMN1   VALID_11   MISS_12   OOR_13
                                        |
     5      2      1     1     0     2  |     1     V1          4         0         0
     6      2      1     1     0     2  |     1     V2          2         2         0
     7      2      1     2     2     2  |    ..
     8      2      1     2     2     2  |


PROCESS (all the code)
=======================

  * fat dataset - array in sql;
  proc sql;
    create
      table want1 as
    select
       grp
       %array(vs,values=1-4)
      ,%do_over(vs,phrase=
         "v?" as column? %str(,)
          sum(v? = 0) as  valid_?1 %str(,)
          sum(v? = 1) as   miss_?2 %str(,)
          sum(v? = 2) as    oor_?3
         ,between=comma
       )
    from
       have
    group
       by grp
  ;quit;

  * may not need to do this;
  * this does the transpose;

  proc sql;
    create
       table want2 as
         %array(vs,values=1-4)
         %do_over(vs,phrase=%str(
         select
             grp
            ,column? as column
            ,valid_?1 as valid
            ,miss_?2 as mis
            ,oor_?3 as oor
         from
            want union))
         select * from sasuser.empty(obs=0) * null sql table
    ;quit;


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


    WORK.WANT1 total obs=2

    Obs   COLUMN1   VALID_11   MISS_12   OOR_13 ...  COLUMN4   VALID_41   MISS_42   OOR_43

     1      v1          4         0         0   ...    v4          0         4         0
     2      v1          0         4         0   ..     v4          0         0         4

     -- CHARACTER --
    COLUMN1             C    2       v1
    COLUMN2             C    2       v2
    COLUMN3             C    2       v3
    COLUMN4             C    2       v4


     -- NUMERIC --
    VALID_11            N    8       4
    MISS_12             N    8       0
    OOR_13              N    8       0

    VALID_21            N    8       2
    MISS_22             N    8       2
    OOR_23              N    8       0

    VALID_31            N    8       4
    MISS_32             N    8       0
    OOR_33              N    8       0

    VALID_41            N    8       0
    MISS_42             N    8       4
    OOR_43              N    8       0


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

  * fat dataset;
  proc sql;
    create
      table want1 as
    select
       grp
       %array(vs,values=1-4)
      ,%do_over(vs,phrase=
         "v?" as column? %str(,)
          sum(v? = 0) as  valid_?1 %str(,)
          sum(v? = 1) as   miss_?2 %str(,)
          sum(v? = 2) as    oor_?3
         ,between=comma
       )
    from
       have
    group
       by grp
  ;quit;

  * this does the transpose(may not need to do this);
  proc sql;
    create
       table want2 as
         %array(vs,values=1-4)
         %do_over(vs,phrase=%str(
         select
             grp
            ,column? as column
            ,valid_?1 as valid
            ,miss_?2 as mis
            ,oor_?3 as oor
         from
            want union))

         select * from sasuser.empty(obs=0)
    ;quit;


