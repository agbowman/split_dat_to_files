CREATE PROGRAM dm_cmb_data_integrity_audit:dba
 DECLARE cmb_table = vc WITH protect, noconstant("")
 DECLARE cmb_from_col = vc WITH protect, noconstant("")
 DECLARE cmb_trg_prfx = vc WITH protect, noconstant("")
 DECLARE cmb_dttm_col = i2 WITH protect, noconstant(0)
 DECLARE cmb_aud_file = vc WITH protect, noconstant("")
 DECLARE cmb_aud_rpt = vc WITH protect, noconstant("")
 DECLARE cmb_aud_recmb = vc WITH protect, noconstant("")
 DECLARE cmb_cmd = vc WITH protect, noconstant("")
 DECLARE cmb_err_num = i4 WITH protect, noconstant(0)
 DECLARE cmb_err_str = vc WITH protect, noconstant("")
 DECLARE cmb_temp_str = vc WITH protect, noconstant("")
 DECLARE cmb_parent = vc WITH noconstant(cnvtupper( $1))
 DECLARE cmb_begin_date = vc WITH noconstant( $2)
 DECLARE cmb_end_date = vc WITH noconstant( $3)
 IF ( NOT (cmb_parent IN ("PERSON", "ENCOUNTER")))
  CALL echo("***")
  CALL echo("*** Invalid input, $1 must equal: ")
  CALL echo("*** 'PERSON' or 'ENCOUNTER' ")
  CALL echo("***")
  GO TO exit_program
 ENDIF
 SET cmb_err_num = error(cmb_err_str,1)
 SET cmb_table = evaluate(cmb_parent,"PERSON","PERSON_COMBINE","ENCNTR_COMBINE")
 SET cmb_from_col = evaluate(cmb_parent,"PERSON","from_person_id","from_encntr_id")
 SET cmb_trg_prfx = evaluate(cmb_parent,"PERSON","TRG_PCMB*","TRG_ECMB*")
 SET cmb_aud_file = evaluate(cmb_parent,"PERSON","pcmb","ecmb")
 SET cmb_aud_rpt = build(cmb_aud_file,"_combine_audit.txt")
 SET cmb_aud_recmb = build(cmb_aud_file,"_recmb.dat")
 FREE RECORD tab
 RECORD tab(
   1 cnt = i4
   1 qual[*]
     2 table_name = vc
     2 column_name = vc
     2 pk_col = vc
     2 row_cnt = i4
     2 tbl_exist_ind = i2
     2 col_exist_ind = i2
     2 active_ind = i2
     2 active_status_cd_ind = i2
     2 script_name = vc
     2 trigger_type = vc
     2 encntr_move_ind = i2
     2 encntr_col = vc
   1 val_cnt = i4
   1 val[*]
     2 from_id = f8
     2 from_parent = vc
 )
 SET tab->cnt = 0
 SET stat = alterlist(tab->qual,0)
 SET tab->val_cnt = 0
 SET stat = alterlist(tab->val,0)
 SELECT INTO "nl:"
  c.child_table, c.child_column
  FROM dm_cmb_children c
  WHERE c.parent_table=cmb_parent
   AND  EXISTS (
  (SELECT
   "x"
   FROM user_triggers u
   WHERE u.trigger_name=patstring(cmb_trg_prfx)
    AND u.table_name=c.child_table
    AND findstring(concat("new.",c.child_column),u.when_clause) > 0))
   AND  NOT ( EXISTS (
  (SELECT
   "y"
   FROM dm_info di
   WHERE di.info_domain=concat("COMBINE_DATA_AUDIT_EXCLUDE:",cmb_parent)
    AND di.info_name=c.child_table)))
  ORDER BY c.child_table
  DETAIL
   tab->cnt = (tab->cnt+ 1), stat = alterlist(tab->qual,tab->cnt), tab->qual[tab->cnt].table_name = c
   .child_table,
   tab->qual[tab->cnt].column_name = c.child_column, tab->qual[tab->cnt].pk_col = c.child_pk, tab->
   qual[tab->cnt].row_cnt = 0
  WITH nocounter
 ;end select
 IF (cmb_parent="PERSON")
  SELECT INTO "nl:"
   FROM dm_cmb_both_children dcb,
    (dummyt d  WITH seq = value(tab->cnt))
   PLAN (d)
    JOIN (dcb
    WHERE (dcb.child_table=tab->qual[d.seq].table_name))
   DETAIL
    tab->qual[d.seq].encntr_col = dcb.encounter_column, tab->qual[d.seq].encntr_move_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM user_tab_columns u,
   (dummyt t  WITH seq = value(tab->cnt))
  PLAN (t)
   JOIN (u
   WHERE (u.table_name=tab->qual[t.seq].table_name))
  ORDER BY u.table_name
  DETAIL
   tab->qual[t.seq].tbl_exist_ind = 1
   IF ((u.column_name=tab->qual[t.seq].column_name))
    tab->qual[t.seq].col_exist_ind = 1
   ENDIF
   IF (u.column_name="ACTIVE_STATUS_CD")
    tab->qual[t.seq].active_status_cd_ind = 1
   ENDIF
   IF (u.column_name="ACTIVE_IND")
    tab->qual[t.seq].active_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dc.script_name
  FROM dm_cmb_exception dc,
   (dummyt t  WITH seq = value(tab->cnt))
  PLAN (t)
   JOIN (dc
   WHERE dc.parent_entity=cmb_parent
    AND (dc.child_entity=tab->qual[t.seq].table_name))
  DETAIL
   tab->qual[t.seq].script_name = dc.script_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.info_char
  FROM dm_info d,
   (dummyt t  WITH seq = value(tab->cnt))
  PLAN (t)
   JOIN (d
   WHERE d.info_domain=concat("COMBINE_TRIGGER_TYPE_",evaluate(cmb_parent,"ENCOUNTER","ENCNTR",
     cmb_parent))
    AND (d.info_name=tab->qual[t.seq].table_name))
  DETAIL
   IF (((d.info_char < " ") OR (d.info_char=null)) )
    tab->qual[t.seq].trigger_type = "DEFAULT"
   ELSE
    tab->qual[t.seq].trigger_type = d.info_char
   ENDIF
  WITH nocounter
 ;end select
 SET cmb_dttm_col = 0
 SELECT INTO "nl:"
  FROM user_tab_columns u
  WHERE u.table_name=cmb_table
   AND u.column_name="CMB_DT_TM"
  DETAIL
   cmb_dttm_col = 1
  WITH nocounter
 ;end select
 DECLARE combinedaway = f8
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.cdf_meaning="COMBINED"
   AND c.code_set=48
   AND c.active_ind=true
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   combinedaway = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO value(cmb_aud_rpt)
  FROM dual
  DETAIL
   "Report generated ", sysdate";;q", row + 1,
   "Combine audit for parent: ", cmb_parent, row + 1,
   "Audit start date: ", cmb_begin_date, row + 1,
   "Audit end date  : ", cmb_end_date, row + 1,
   "--------------------------------------------", row + 1
  WITH format = variable, formfeed = none, maxrow = 1,
   maxcol = 132
 ;end select
 FOR (tbl = 1 TO tab->cnt)
   IF ((tab->qual[tbl].tbl_exist_ind=1)
    AND (tab->qual[tbl].col_exist_ind=1))
    CALL echo(concat("Checking table ",tab->qual[tbl].table_name," column ",tab->qual[tbl].
      column_name))
    SET cmb_temp_str = concat("select into '",cmb_aud_rpt,"'")
    SET cmb_temp_str = concat(cmb_temp_str,"  row_cnt=count(*), x.",tab->qual[tbl].column_name)
    SET cmb_temp_str = concat(cmb_temp_str," from ",tab->qual[tbl].table_name," x")
    SET cmb_temp_str = concat(cmb_temp_str," where x.",tab->qual[tbl].column_name," in (")
    SET cmb_temp_str = concat(cmb_temp_str,"  select c.",cmb_from_col," from ",cmb_table,
     " c")
    SET cmb_temp_str = concat(cmb_temp_str,"  where c.",cmb_from_col," > 0 and c.active_ind=1")
    IF (cmb_parent="PERSON")
     SET cmb_temp_str = concat(cmb_temp_str,"  and c.encntr_id = 0")
    ENDIF
    IF (cmb_dttm_col=1)
     SET cmb_temp_str = concat(cmb_temp_str,"  and c.cmb_dt_tm >= cnvtdatetime('",cmb_begin_date,"')"
      )
     SET cmb_temp_str = concat(cmb_temp_str,"  and c.cmb_dt_tm <= cnvtdatetime('",cmb_end_date,"'))")
    ELSE
     SET cmb_temp_str = concat(cmb_temp_str,"  and c.updt_dt_tm >= cnvtdatetime('",cmb_begin_date,
      "')")
     SET cmb_temp_str = concat(cmb_temp_str,"  and c.updt_dt_tm <= cnvtdatetime('",cmb_end_date,"'))"
      )
    ENDIF
    IF ((tab->qual[tbl].active_status_cd_ind=1)
     AND (tab->qual[tbl].active_ind=1))
     SET cmb_temp_str = concat(cmb_temp_str," and x.active_ind = 1 and x.active_status_cd != ",
      cnvtstring(combinedaway))
    ELSEIF ((tab->qual[tbl].active_status_cd_ind=1))
     SET cmb_temp_str = concat(cmb_temp_str," and x.active_status_cd != ",cnvtstring(combinedaway))
    ELSEIF ((tab->qual[tbl].active_status_cd_ind=1))
     SET cmb_temp_str = concat(cmb_temp_str," and x.active_ind = 1")
    ENDIF
    SET cmb_temp_str = concat(cmb_temp_str," group by x.",tab->qual[tbl].column_name)
    SET cmb_temp_str = concat(cmb_temp_str," head report rcnt=0")
    SET cmb_temp_str = concat(cmb_temp_str," col 0 'Checking table ",tab->qual[tbl].table_name," (")
    SET cmb_temp_str = concat(cmb_temp_str,cnvtstring(tbl)," of ",cnvtstring(tab->cnt),")',row+1")
    SET cmb_temp_str = concat(cmb_temp_str," col 4, 'Custom Script: ','")
    SET cmb_temp_str = concat(cmb_temp_str,evaluate(tab->qual[tbl].script_name,"","GENERIC",tab->
      qual[tbl].script_name))
    SET cmb_temp_str = concat(cmb_temp_str,"', row+1")
    SET cmb_temp_str = concat(cmb_temp_str," col 4, 'Trigger Type: ','",tab->qual[tbl].trigger_type,
     "', row+1")
    SET cmb_temp_str = concat(cmb_temp_str," col 2,'",tab->qual[tbl].column_name,
     " (from value)', col 50,'ROW COUNT',row+1")
    SET cmb_temp_str = concat(cmb_temp_str," detail rcnt=rcnt+row_cnt")
    SET cmb_temp_str = concat(cmb_temp_str,
     " tab->val_cnt=tab->val_cnt+1,stat=alterlist(tab->val,tab->val_cnt)")
    SET cmb_temp_str = concat(cmb_temp_str," tab->val[tab->val_cnt].from_id=x.",tab->qual[tbl].
     column_name)
    SET cmb_temp_str = concat(cmb_temp_str," col 2,x.",tab->qual[tbl].column_name,
     ",col 50, row_cnt, row+1")
    SET cmb_temp_str = concat(cmb_temp_str," foot report")
    SET cmb_temp_str = concat(cmb_temp_str," 'Total count of suspect rows:', rcnt,tab->qual[")
    SET cmb_temp_str = concat(cmb_temp_str,cnvtstring(tbl),"].row_cnt=rcnt,row+1")
    SET cmb_temp_str = concat(cmb_temp_str,
     " '------------------------------------------------------------------------',row+1")
    SET cmb_temp_str = concat(cmb_temp_str,
     " with format=variable,formfeed=none,maxrow=1,maxcol=132,append,nullreport go")
    CALL parser(cmb_temp_str,1)
    IF (cmb_parent="PERSON"
     AND (tab->qual[tbl].encntr_move_ind=1))
     CALL echo(concat("Encntr Move Check for table ",tab->qual[tbl].table_name," column ",tab->qual[
       tbl].encntr_col))
     SET cmb_temp_str = concat("select into '",cmb_aud_rpt,"'")
     SET cmb_temp_str = concat(cmb_temp_str,"  row_cnt=count(*), x.",tab->qual[tbl].column_name)
     SET cmb_temp_str = concat(cmb_temp_str,", x.",tab->qual[tbl].encntr_col)
     SET cmb_temp_str = concat(cmb_temp_str," from ",tab->qual[tbl].table_name," x")
     SET cmb_temp_str = concat(cmb_temp_str," where list (x.",tab->qual[tbl].column_name,",")
     SET cmb_temp_str = concat(cmb_temp_str," x.",tab->qual[tbl].encntr_col,") in (")
     SET cmb_temp_str = concat(cmb_temp_str,"  select c.",cmb_from_col,",c.encntr_id from ",cmb_table,
      " c")
     SET cmb_temp_str = concat(cmb_temp_str,"  where c.",cmb_from_col," > 0 and c.active_ind=1")
     SET cmb_temp_str = concat(cmb_temp_str,"  and c.encntr_id > 0")
     IF (cmb_dttm_col=1)
      SET cmb_temp_str = concat(cmb_temp_str,"  and c.cmb_dt_tm >= cnvtdatetime('",cmb_begin_date,
       "')")
      SET cmb_temp_str = concat(cmb_temp_str,"  and c.cmb_dt_tm <= cnvtdatetime('",cmb_end_date,"'))"
       )
     ELSE
      SET cmb_temp_str = concat(cmb_temp_str,"  and c.updt_dt_tm >= cnvtdatetime('",cmb_begin_date,
       "')")
      SET cmb_temp_str = concat(cmb_temp_str,"  and c.updt_dt_tm <= cnvtdatetime('",cmb_end_date,
       "'))")
     ENDIF
     IF ((tab->qual[tbl].active_status_cd_ind=1)
      AND (tab->qual[tbl].active_ind=1))
      SET cmb_temp_str = concat(cmb_temp_str," and x.active_ind = 1 and x.active_status_cd != ",
       cnvtstring(combinedaway))
     ELSEIF ((tab->qual[tbl].active_status_cd_ind=1))
      SET cmb_temp_str = concat(cmb_temp_str," and x.active_status_cd != ",cnvtstring(combinedaway))
     ELSEIF ((tab->qual[tbl].active_status_cd_ind=1))
      SET cmb_temp_str = concat(cmb_temp_str," and x.active_ind = 1")
     ENDIF
     SET cmb_temp_str = concat(cmb_temp_str," group by x.",tab->qual[tbl].column_name)
     SET cmb_temp_str = concat(cmb_temp_str,", x.",tab->qual[tbl].encntr_col)
     SET cmb_temp_str = concat(cmb_temp_str," head report rcnt=0")
     SET cmb_temp_str = concat(cmb_temp_str," col 0 'Encntr Move Check for table ",tab->qual[tbl].
      table_name," (")
     SET cmb_temp_str = concat(cmb_temp_str,cnvtstring(tbl)," of ",cnvtstring(tab->cnt),")',row+1")
     SET cmb_temp_str = concat(cmb_temp_str," col 4, 'Custom Script: ','")
     SET cmb_temp_str = concat(cmb_temp_str,evaluate(tab->qual[tbl].script_name,"","GENERIC",tab->
       qual[tbl].script_name))
     SET cmb_temp_str = concat(cmb_temp_str,"', row+1")
     SET cmb_temp_str = concat(cmb_temp_str," col 4, 'Trigger Type: ','",tab->qual[tbl].trigger_type,
      "', row+1")
     SET cmb_temp_str = concat(cmb_temp_str," col 2,'",tab->qual[tbl].column_name," (from value)', ")
     SET cmb_temp_str = concat(cmb_temp_str," col 32,'",tab->qual[tbl].encntr_col,
      " (encntr_id)',col 62, 'ROW COUNT',row+1")
     SET cmb_temp_str = concat(cmb_temp_str," detail rcnt=rcnt+row_cnt")
     SET cmb_temp_str = concat(cmb_temp_str,
      " tab->val_cnt=tab->val_cnt+1,stat=alterlist(tab->val,tab->val_cnt)")
     SET cmb_temp_str = concat(cmb_temp_str," tab->val[tab->val_cnt].from_id=x.",tab->qual[tbl].
      column_name)
     SET cmb_temp_str = concat(cmb_temp_str," col 2,x.",tab->qual[tbl].column_name)
     SET cmb_temp_str = concat(cmb_temp_str," col 32,x.",tab->qual[tbl].encntr_col,
      " col 62, row_cnt, row+1")
     SET cmb_temp_str = concat(cmb_temp_str," foot report")
     SET cmb_temp_str = concat(cmb_temp_str," 'Total count of suspect rows:', rcnt,tab->qual[")
     SET cmb_temp_str = concat(cmb_temp_str,cnvtstring(tbl),"].row_cnt=rcnt,row+1")
     SET cmb_temp_str = concat(cmb_temp_str,
      " '------------------------------------------------------------------------',row+1")
     SET cmb_temp_str = concat(cmb_temp_str,
      " with format=variable,formfeed=none,maxrow=1,maxcol=132,append,nullreport go")
     CALL parser(cmb_temp_str,1)
    ENDIF
   ENDIF
 ENDFOR
 IF (cmb_parent="PERSON")
  SELECT DISTINCT INTO value(cmb_aud_rpt)
   c.from_person_id, c.entnr_id
   FROM person_combine c,
    (dummyt d  WITH seq = value(tab->val_cnt))
   PLAN (d)
    JOIN (c
    WHERE (c.from_person_id=tab->val[d.seq].from_id)
     AND c.active_ind=1
     AND c.encntr_id >= 0
     AND (c.updt_dt_tm=
    (SELECT
     max(x.updt_dt_tm)
     FROM person_combine x
     WHERE x.from_person_id=c.from_person_id
      AND x.active_ind=1
      AND c.encntr_id >= 0)))
   ORDER BY c.updt_dt_tm DESC
   HEAD REPORT
    fcnt = 0, ";FROM Value Combine Summary (", cmb_parent,
    ") ", sysdate";;q", row + 1,
    "--------------------------------------------", row + 1, col 5,
    "FROM_ID", col 25, "TO_ID",
    col 45, "ENCNTR_ID", col 65,
    "Combine Dt/Tm", col 90, "COMBINE_ID",
    col 110, "UPDT_ID", col 130,
    "APP_FLAG", row + 1
   DETAIL
    fcnt = (fcnt+ 1), col 0, c.from_person_id,
    col 20, c.to_person_id, col 40,
    c.encntr_id, col 60, c.updt_dt_tm";;q",
    col 85, c.person_combine_id, col 105,
    c.updt_id, col 125, c.application_flag,
    row + 1
   FOOT REPORT
    "Total number of FROM values and combines: ", fcnt, row + 1,
    "--------------------------------------------", row + 1
   WITH format = variable, formfeed = none, maxrow = 1,
    maxcol = 150, append, nullreport
  ;end select
 ELSE
  SELECT DISTINCT INTO value(cmb_aud_rpt)
   c.from_encntr_id
   FROM encntr_combine c,
    (dummyt d  WITH seq = value(tab->val_cnt))
   PLAN (d)
    JOIN (c
    WHERE (c.from_encntr_id=tab->val[d.seq].from_id)
     AND c.active_ind=1
     AND (c.updt_dt_tm=
    (SELECT
     max(x.updt_dt_tm)
     FROM encntr_combine x
     WHERE x.from_encntr_id=c.from_encntr_id
      AND x.active_ind=1)))
   ORDER BY c.updt_dt_tm DESC
   HEAD REPORT
    fcnt = 0, ";FROM Value Combine Summary (", cmb_parent,
    ") ", sysdate";;q", row + 1,
    "--------------------------------------------", row + 1, col 5,
    "FROM_ID", col 25, "TO_ID",
    col 45, "Combine Dt/Tm", col 70,
    "COMBINE_ID", col 90, "UPDT_ID",
    col 110, "APP_FLAG", row + 1
   DETAIL
    fcnt = (fcnt+ 1), col 0, c.from_encntr_id,
    col 20, c.to_encntr_id, col 40,
    c.updt_dt_tm";;q", col 65, c.encntr_combine_id,
    col 85, c.updt_id, col 105,
    c.application_flag, row + 1
   FOOT REPORT
    row + 1, "Total number of FROM values and combines: ", fcnt,
    row + 1, "--------------------------------------------", row + 1
   WITH format = variable, formfeed = none, maxrow = 1,
    maxcol = 132, append, nullreport
  ;end select
 ENDIF
 SELECT
  IF (cmb_parent="PERSON")DISTINCT INTO value(cmb_aud_rpt)
   c.from_person_id, c.encntr_id
   FROM person_combine c,
    (dummyt d  WITH seq = value(tab->val_cnt))
   PLAN (d)
    JOIN (c
    WHERE (c.from_person_id=tab->val[d.seq].from_id)
     AND c.active_ind=1
     AND c.encntr_id >= 0
     AND (c.updt_dt_tm=
    (SELECT
     max(x.updt_dt_tm)
     FROM person_combine x
     WHERE x.from_person_id=c.from_person_id
      AND x.active_ind=1
      AND c.encntr_id >= 0)))
   ORDER BY c.updt_dt_tm DESC
   HEAD REPORT
    cmb_recmb_cnt = 0, ";Suggested Recombine Commands:", row + 1,
    "--------------------------------------------", row + 1
   DETAIL
    cmb_recmb_cnt = 1, col 0, "dm_recombine 'PERSON',",
    c.person_combine_id, " go", row + 1
   FOOT REPORT
    IF (cmb_recmb_cnt=0)
     col 0, "No recombines necessary", row + 1
    ENDIF
   WITH format = variable, formfeed = none, maxrow = 1,
    maxcol = 150, append, nullreport
  ELSE DISTINCT INTO value(cmb_aud_rpt)
   c.from_encntr_id
   FROM encntr_combine c,
    (dummyt d  WITH seq = value(tab->val_cnt))
   PLAN (d)
    JOIN (c
    WHERE (c.from_encntr_id=tab->val[d.seq].from_id)
     AND c.active_ind=1
     AND (c.updt_dt_tm=
    (SELECT
     max(x.updt_dt_tm)
     FROM encntr_combine x
     WHERE x.from_encntr_id=c.from_encntr_id
      AND x.active_ind=1)))
   ORDER BY c.updt_dt_tm DESC
   HEAD REPORT
    cmb_recmb_cnt = 0, ";Suggested Recombine Commands:", row + 1,
    "--------------------------------------------", row + 1
   DETAIL
    cmb_recmb_cnt = 1, col 0, "dm_recombine 'ENCOUNTER',",
    c.encntr_combine_id, " go", row + 1
   FOOT REPORT
    IF (cmb_recmb_cnt=0)
     col 0, "No recombines necessary", row + 1
    ENDIF
   WITH format = variable, formfeed = none, maxrow = 1,
    maxcol = 150, append, nullreport
  ENDIF
 ;end select
 SELECT INTO value(cmb_aud_rpt)
  di.info_name
  FROM dm_info di
  WHERE di.info_domain=concat("COMBINE_DATA_AUDIT_EXCLUDE:",cmb_parent)
  HEAD REPORT
   ";List of Tables Excluded from Audit:", row + 1, "--------------------------------------------",
   row + 1, cmb_excl_cnt = 0, cmb_excl_str = fillstring(32," ")
  DETAIL
   cmb_excl_cnt = 1, cmb_excl_str = trim(di.info_name,3), col 0,
   cmb_excl_str, row + 1
  FOOT REPORT
   IF (cmb_excl_cnt=0)
    col 0, "No tables excluded", row + 1
   ENDIF
  WITH format = variable, formfeed = none, maxrow = 1,
   maxcol = 132, append, nullreport
 ;end select
 SELECT INTO value(cmb_aud_rpt)
  FROM (dummyt d  WITH seq = value(tab->cnt))
  PLAN (d
   WHERE (tab->qual[d.seq].row_cnt > 0))
  HEAD REPORT
   tcnt = 0, ";Child Table Summary ", sysdate";;q",
   row + 1, "--------------------------------------------", row + 1,
   "TABLE_NAME", col 35, "COLUMN_NAME",
   col 70, "ROW_COUNT", row + 1
  DETAIL
   tcnt = (tcnt+ 1), tab->qual[d.seq].table_name, col 35,
   tab->qual[d.seq].column_name, col 70, tab->qual[d.seq].row_cnt,
   row + 1
  FOOT REPORT
   "Total number of tables/columns: ", tcnt, row + 1,
   "----------------End of Report --------------", row + 1
  WITH format = variable, formfeed = none, maxrow = 1,
   maxcol = 132, append, nullreport
 ;end select
 SET cmb_err_num = error(cmb_err_str,1)
 SELECT INTO noforms
  FROM dual
  DETAIL
   cmb_err_str = substring(1,131,cmb_err_str), "***", row + 1
   IF (cmb_err_num > 0)
    "*** Combine audit error!!", row + 1,
    CALL print(cmb_err_str),
    row + 1
   ELSE
    "*** Combine audit file in CCLUSERDIR", row + 1, "*** Audit report file: ",
    cmb_aud_rpt, row + 1
   ENDIF
   "***", row + 1
  WITH nocounter
 ;end select
#exit_program
END GO
