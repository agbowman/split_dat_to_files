CREATE PROGRAM dm_ocd_include_check:dba
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_check TO 2999_check_exit
 GO TO 9999_exit_program
 SUBROUTINE ic_check(c_name,c_expected)
   FREE SET c_col
   FREE SET c_owner_qual
   IF (ic_column_exists(c_name,"alpha_feature_nbr"))
    SET c_col = "t.alpha_feature_nbr"
   ELSE
    IF (ic_column_exists(c_name,"ocd"))
     SET c_col = "t.ocd"
    ELSE
     RETURN(0)
    ENDIF
   ENDIF
   IF (cnvtupper(c_name)="DM_OCD_README")
    SET c_owner_qual = concat(" and exists (select 'x' from dm_readme dr ",
     "where dr.readme_id = t.readme_id and dr.owner = currdbuser)")
   ELSEIF (ic_column_exists(c_name,"owner")
    AND cnvtupper(c_name) != "DM_OCD_APPLICATION")
    SET c_owner_qual = "and t.owner = currdbuser"
   ELSE
    SET c_owner_qual = "and 1=1"
   ENDIF
   SET c_count = 0
   CALL parser(concat("select into 'nl:' c_temp = count(*) from ",c_name," t where ",c_col," = ",
     trim(cnvtstring(ic_data->ocd),3)," ",c_owner_qual," detail c_count = c_temp with nocounter go"),
    1)
   IF (c_count=c_expected)
    RETURN(0)
   ENDIF
   SET c_i = (size(ic_data->problem,5)+ 1)
   SET stat = alterlist(ic_data->problem,c_i)
   SET ic_data->problem[c_i].name = c_name
   SET ic_data->problem[c_i].expected = c_expected
   SET ic_data->problem[c_i].found = c_count
 END ;Subroutine
 SUBROUTINE ic_column_exists(ce_table,ce_column)
   IF (checkdic(cnvtupper(concat(ce_table,".",ce_column)),"A",0)=2)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE ic_status(s_text)
   CALL echo(s_text)
 END ;Subroutine
#1000_initialize
 IF ( NOT (validate(docd_reply,0)))
  RECORD docd_reply(
    1 status = c1
    1 err_msg = vc
  )
 ENDIF
 SET docd_reply->status = "F"
 SET ic_i = 0
 SET ic_j = 0
 SET ic_k = 0
 SET ic_t1 = 0
 SET ic_t2 = 0
 SET ic_idx = 0
 FREE RECORD ic_data
 RECORD ic_data(
   1 ocd = i4
   1 file = vc
   1 text = vc
   1 owner = vc
   1 tbl = vc
   1 col = vc
   1 archive_date = dq8
   1 operation[*]
     2 name = vc
     2 rows = i4
   1 problem[*]
     2 name = vc
     2 expected = i4
     2 found = i4
 )
 SET ic_data->ocd =  $1
 IF ( NOT (ic_data->ocd))
  CALL ic_status("ERROR: Unable to verify install.  No OCD number provided.")
  GO TO 9999_exit_program
 ENDIF
#1999_initialize_exit
#2000_check
 CALL ic_status("Verifying load of ccl file.")
 SET ic_data->text = cnvtlower(trim(logical("cer_ocd"),3))
 SET ic_i = findstring("]",ic_data->text)
 IF (ic_i)
  SET ic_data->text = substring(1,(ic_i - 1),ic_data->text)
 ENDIF
 IF (cursys="AIX")
  SET ic_data->file = concat(ic_data->text,"/",trim(format(ic_data->ocd,"######;P0"),3),"/")
 ELSEIF (cursys="WIN")
  SET ic_data->file = concat(ic_data->text,"\",trim(format(ic_data->ocd,"######;P0"),3),"\")
 ELSE
  SET ic_data->file = concat(ic_data->text,trim(format(ic_data->ocd,"######;P0"),3),"]")
 ENDIF
 SET ic_data->file = concat(ic_data->file,"ocd_schema_",trim(cnvtstring(ic_data->ocd),3),".txt")
 CALL echo(ic_data->file)
 IF ( NOT (findfile(ic_data->file)))
  CALL ic_status(concat("ERROR: Unable to verify load.  File (",ic_data->file,") not found."))
  GO TO 9999_exit_program
 ENDIF
 FREE DEFINE rtl
 FREE SET ic_file
 SET logical ic_file value(ic_data->file)
 DEFINE rtl "ic_file"
 SELECT INTO "nl:"
  r.line
  FROM rtlt r
  DETAIL
   ic_i = findstring(";",r.line), ic_t1 = findstring("#",r.line)
   IF (ic_i)
    ic_j = findstring("=",r.line,ic_i)
    IF ((ic_j > (ic_i+ 1)))
     ic_data->text = cnvtupper(trim(substring((ic_i+ 1),((ic_j - ic_i) - 1),r.line),3))
     IF (size(trim(ic_data->text),3))
      IF ((ic_data->text="ARCHIVE DATE"))
       ic_data->archive_date = cnvtdatetime(substring((ic_j+ 1),23,r.line))
      ELSEIF (currdbuser="V500")
       ic_idx = 0, ic_idx = locateval(ic_idx,1,size(ic_data->operation,5),ic_data->text,ic_data->
        operation[ic_idx].name)
       IF (ic_idx=0)
        ck_j = (size(ic_data->operation,5)+ 1), stat = alterlist(ic_data->operation,ck_j), ic_data->
        operation[ck_j].name = ic_data->text,
        ic_data->operation[ck_j].rows = cnvtint(cnvtalphanum(substring((ic_j+ 1),8,r.line)))
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (ic_t1 > 0)
    ic_j = findstring("=",r.line,ic_t1)
    IF ((ic_j > (ic_t1+ 1)))
     ic_data->text = cnvtupper(trim(substring((ic_t1+ 1),((ic_j - ic_t1) - 1),r.line),3))
     IF (size(trim(ic_data->text),3))
      ic_data->owner = "", ic_data->tbl = "", ic_t2 = findstring(".",r.line,ic_t1)
      IF ((ic_t2 > (ic_t1+ 1))
       AND (ic_t2 < (ic_j - 1)))
       ic_data->owner = cnvtupper(trim(substring((ic_t1+ 1),((ic_t2 - ic_t1) - 1),r.line),3))
      ENDIF
      IF ((ic_data->owner=currdbuser))
       ic_data->tbl = cnvtupper(trim(substring((ic_t2+ 1),((ic_j - ic_t2) - 1),r.line),3)), ic_idx =
       0, ic_idx = locateval(ic_idx,1,size(ic_data->operation,5),ic_data->tbl,ic_data->operation[
        ic_idx].name)
       IF (ic_idx=0)
        ck_j = (size(ic_data->operation,5)+ 1), stat = alterlist(ic_data->operation,ck_j), ic_data->
        operation[ck_j].name = ic_data->tbl,
        ic_data->operation[ck_j].rows = cnvtint(cnvtalphanum(substring((ic_j+ 1),8,r.line)))
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FOR (ic_i = 1 TO size(ic_data->operation,5))
   IF ((validate(csvcontent->prev_sch_inst_on_pkg,0)=ic_data->ocd)
    AND (ic_data->operation[ic_i].name IN ("DM_AFD_TABLES", "DM_AFD_COLUMNS", "DM_AFD_CONS_COLUMNS",
   "DM_AFD_INDEX_COLUMNS", "DM_AFD_INDEXES",
   "DM_AFD_CONSTRAINTS")))
    CALL echo(concat("Bypass row count on the ",ic_data->operation[ic_i].name,
      " table since previous schema instance of table on package:",cnvtstring(ic_data->ocd)))
   ELSE
    CALL ic_check(ic_data->operation[ic_i].name,ic_data->operation[ic_i].rows)
   ENDIF
 ENDFOR
 FOR (ic_i = 1 TO size(ic_data->problem,5))
   CALL echo(concat("ERROR: Row count on the ",ic_data->problem[ic_i].name,
     " table incorrect.  Found: ",trim(cnvtstring(ic_data->problem[ic_i].found),3),".  Expecting: ",
     trim(cnvtstring(ic_data->problem[ic_i].expected),3),"."))
 ENDFOR
 IF (ic_data->archive_date
  AND  NOT (size(ic_data->problem,5)))
  SELECT INTO "nl:"
   f.alpha_feature_nbr
   FROM dm_alpha_features f
   WHERE (f.alpha_feature_nbr=ic_data->ocd)
    AND f.owner=currdbuser
   WITH nocounter
  ;end select
  IF (curqual)
   UPDATE  FROM dm_alpha_features f
    SET f.archive_dt_tm = cnvtdatetime(ic_data->archive_date)
    WHERE (f.alpha_feature_nbr=ic_data->ocd)
     AND f.owner=currdbuser
    WITH nocounter
   ;end update
   IF (curqual)
    COMMIT
   ELSE
    CALL ic_status("ERROR: Unable to update DM_ALPHA_FEATURES row with archive date.")
    GO TO 9999_exit_program
   ENDIF
  ELSE
   INSERT  FROM dm_alpha_features f
    SET f.alpha_feature_nbr = ic_data->ocd, f.description = "", f.rev_number = 0,
     f.sponsor_client_id = "", f.create_dt_tm = cnvtdatetime(curdate,curtime3), f.feature_number = 0,
     f.archive_dt_tm = cnvtdatetime(ic_data->archive_date), f.owner = currdbuser
    WITH nocounter
   ;end insert
   IF (curqual)
    COMMIT
   ELSE
    CALL ic_status("ERROR: Unable to insert new DM_ALPHA_FEATURES row to record archive date.")
    GO TO 9999_exit_program
   ENDIF
  ENDIF
 ENDIF
 IF (size(ic_data->problem,5))
  SET docd_reply->err_msg = "Load verification complete.  One or more errors were found."
  CALL ic_status(docd_reply->err_msg)
 ELSE
  SET docd_reply->status = "S"
  CALL ic_status("Load verification complete.  No errors were found.")
 ENDIF
#2999_check_exit
#9999_exit_program
END GO
