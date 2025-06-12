CREATE PROGRAM bhs_sys_extract_labfile:dba
 SET logical labfile "bhscust:bh_labfile.txt"
 FREE RECORD labs
 RECORD labs(
   1 rows[*]
     2 display = vc
     2 col[*]
       3 display = vc
 )
 FREE DEFINE rtl2
 DEFINE rtl2 "labfile"
 DECLARE displayline = vc
 DECLARE loc1 = i2
 DECLARE loc2 = i2
 DECLARE mm1 = c2
 DECLARE dd1 = c2
 DECLARE yyyy1 = c4
 DECLARE loc = i2
 SELECT INTO "nL:"
  FROM rtl2t r
  PLAN (r
   WHERE r.line > " ")
  HEAD REPORT
   rowcnt = 0
  DETAIL
   rowcnt = (rowcnt+ 1), stat = alterlist(labs->rows,rowcnt), labs->rows[rowcnt].display = trim(r
    .line,3)
  WITH nocounter
 ;end select
 SET loc1 = 1
 SET loc2 = 0
 FOR (x = 1 TO size(labs->rows,5))
   SET displayline = " "
   SET displayline = replace(trim(labs->rows[x].display,3),'"'," ",0)
   SET colcnt = 0
   SET loc1 = findstring(",",displayline,loc1,0)
   SET cnt = 0
   WHILE (loc1 > 0)
     SET loc1 = findstring(",",displayline,1,0)
     SET colcnt = (colcnt+ 1)
     SET stat = alterlist(labs->rows[x].col,colcnt)
     SET labs->rows[x].col[colcnt].display = substring(1,(loc1 - 1),displayline)
     SET displayline = trim(substring((loc1+ 1),size(displayline),displayline),3)
   ENDWHILE
   SET l = "0"
   SET displayline = " "
   WHILE (l="0")
    SET l = substring(1,1,labs->rows[x].col[6].display)
    IF (l="0")
     SET displayline = substring(2,size(labs->rows[x].col[6].display),labs->rows[x].col[6].display)
     SET labs->rows[x].col[6].display = trim(displayline,3)
    ENDIF
   ENDWHILE
   SET l = "0"
   SET displayline = " "
   WHILE (l="0")
    SET l = substring(1,1,labs->rows[x].col[7].display)
    IF (l="0")
     SET displayline = substring(2,size(labs->rows[x].col[7].display),labs->rows[x].col[7].display)
     SET labs->rows[x].col[7].display = trim(displayline,3)
    ENDIF
   ENDWHILE
   SET l = "0"
   SET displayline = " "
   WHILE (l="0")
    SET l = substring(1,1,labs->rows[x].col[8].display)
    IF (l="0")
     SET displayline = substring(2,size(labs->rows[x].col[8].display),labs->rows[x].col[8].display)
     SET labs->rows[x].col[8].display = trim(displayline,3)
    ENDIF
   ENDWHILE
   SET l = "0"
   SET displayline = " "
   WHILE (l="0")
    SET l = substring(1,1,labs->rows[x].col[9].display)
    IF (l="0")
     SET displayline = substring(2,size(labs->rows[x].col[9].display),labs->rows[x].col[9].display)
     SET labs->rows[x].col[9].display = trim(displayline,3)
    ENDIF
   ENDWHILE
   IF (x > 1)
    SELECT INTO "nl:"
     FROM person_alias pa
     PLAN (pa
      WHERE (pa.alias=labs->rows[x].col[6].display)
       AND pa.end_effective_dt_tm > sysdate
       AND pa.active_ind=1
       AND pa.alias_pool_cd=674546.00)
     DETAIL
      stat = alterlist(labs->rows[x].col,16), labs->rows[x].col[16].display = cnvtstring(pa.person_id
       )
     WITH nocounter
    ;end select
   ENDIF
   SET displayline = " "
   SET displayline = labs->rows[x].col[11].display
   SET displayline = replace(displayline,"0:00:00","",0)
   SET loc = findstring("/",displayline,1,0)
   SET mm1 = format(substring(1,(loc - 1),displayline),"##;P0")
   SET displayline = trim(substring((loc+ 1),size(displayline),displayline),3)
   SET loc = 0
   SET loc = findstring("/",displayline,1,0)
   SET dd1 = format(substring(1,(loc - 1),displayline),"##;P0")
   SET displayline = trim(substring((loc+ 1),size(displayline),displayline),3)
   SET yyyy1 = format(substring(1,4,displayline),"####;P0")
   SET displayline = build(mm1,dd1,yyyy1)
   SET labs->rows[x].col[11].display = trim(displayline,3)
   CALL echo(build("labs->rows [x].col [11].display:",labs->rows[x].col[11].display))
 ENDFOR
 CALL echo(build("labs size:",size(labs->rows,5)))
 DROP TABLE bhs_labfiles
 SET dclcom = "rm -f bhs_labfiles*"
 SET len = size(trim(dclcom))
 SET status = 0
 COMMIT
 SELECT INTO TABLE bhs_labfiles
  record_num = fillstring(30," "), file_date = fillstring(30," "), last_name = fillstring(30," "),
  first_name = fillstring(30," "), dob = fillstring(30," "), corp_med_rec_num = fillstring(30," "),
  bmc_rec_num = fillstring(30," "), fmc_rec_num = fillstring(30," "), mlh_rec_num = fillstring(30," "
   ),
  line_of_business = fillstring(30," "), date_of_service = fillstring(30," "), yyyymm = fillstring(30,
   " "),
  test = fillstring(30," "), result = fillstring(30," "), filesenddate = fillstring(30," "),
  person_id = 0.0
  ORDER BY record_num, person_id
  WITH nocounter, organization = i
 ;end select
 FREE DEFINE bhs_labfiles
 DEFINE bhs_labfiles  WITH modify
 FOR (x = 2 TO size(labs->rows,5))
  INSERT  FROM bhs_labfiles
   SET record_num = labs->rows[x].col[1].display, file_date = labs->rows[x].col[2].display, last_name
     = labs->rows[x].col[3].display,
    first_name = labs->rows[x].col[4].display, dob = labs->rows[x].col[5].display, corp_med_rec_num
     = labs->rows[x].col[6].display,
    bmc_rec_num = labs->rows[x].col[7].display, fmc_rec_num = labs->rows[x].col[8].display,
    mlh_rec_num = labs->rows[x].col[9].display,
    line_of_business = labs->rows[x].col[10].display, date_of_service = labs->rows[x].col[11].display,
    yyyymm = labs->rows[x].col[12].display,
    test = labs->rows[x].col[13].display, result = labs->rows[x].col[14].display, filesenddate = labs
    ->rows[x].col[15].display,
    person_id = cnvtreal(labs->rows[x].col[16].display)
   WITH nocounter
  ;end insert
  COMMIT
 ENDFOR
#exit_script
END GO
