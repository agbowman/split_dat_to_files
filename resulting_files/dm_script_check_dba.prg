CREATE PROGRAM dm_script_check:dba
 FREE RECORD sql
 RECORD sql(
   1 list[*]
     2 stmt = vc
 )
 FREE RECORD dm_tables
 RECORD dm_tables(
   1 list[*]
     2 name = vc
     2 ins_ind = c1
     2 upd_ind = c1
     2 del_ind = c1
 )
 FREE RECORD dm_child
 RECORD dm_child(
   1 child_list[*]
     2 child_script = vc
     2 dm_status = i2
 )
 FREE RECORD dm_ccl_audit
 RECORD dm_ccl_audit(
   1 list[*]
     2 name = vc
     2 type = vc
 )
 FREE RECORD dm_exception
 RECORD dm_exception(
   1 list[*]
     2 check_cd = i4
 )
 IF ( NOT (validate(dm_environ_id,0)))
  DECLARE dm_environ_id = f8
 ENDIF
 DECLARE dm_sql_cnt = i4
 DECLARE uar_chk_ind = i2
 DECLARE uar_chk = vc
 DECLARE uar_fail = i2
 DECLARE uar_call_ind = i2
 DECLARE dm_for_cnt = i4
 DECLARE dm_environ_chk = i4
 DECLARE ccl_audit_err = i2
 DECLARE ccl_audit_line = vc
 DECLARE ccl_audit_start = i4
 DECLARE ccl_audit_script = vc
 DECLARE final_verdict = i2
 DECLARE dm_err_msg = vc
 DECLARE dm_tbl_cnt = i4
 DECLARE d_loop = i4
 DECLARE dm_cnt = i4
 DECLARE ccl_audit_err_name = vc
 DECLARE dm_problem = c1
 DECLARE dm_problem_name = vc
 DECLARE tbl_name = vc
 DECLARE dm_err_cnt = i4
 DECLARE dm_unique_dat2 = vc
 DECLARE temp_ind = i2
 DECLARE c_cnt = i4
 DECLARE d_total_cost = i4
 DECLARE d_allowed_cost = i4
 DECLARE d_exceptions = i4
 DECLARE d_valid_tbl = i2
 SET c_cnt = 0
 SET temp_ind = 0
 SET uar_call_ind = 0
 SET dm_unique_dat2 = concat(cnvtlower(curuser),trim(cnvtstring(curtime3),3),"search.dat")
 SET dm_script_scanner_reply->script_name = cnvtupper( $1)
 SET dm_str = concat("translate into '",value(dm_unique_dat2),"' ",value(cnvtupper( $1)),":DBA go")
 CALL echo(dm_str)
 CALL parser(dm_str,1)
 FREE DEFINE rtl2
 DEFINE rtl2 value(dm_unique_dat2)
 SELECT INTO "nl:"
  FROM dm_check_exception dc
  WHERE (dc.script_name=dm_script_scanner_reply->script_name)
  HEAD REPORT
   d_exceptions = 0
  DETAIL
   d_exceptions = (d_exceptions+ 1)
   IF (mod(d_exceptions,10)=1)
    stat = alterlist(dm_exception->list,(d_exceptions+ 9))
   ENDIF
   dm_exception->list[d_exceptions].check_cd = dc.check_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   dm_environ_id = di.info_number
  WITH nocounter
 ;end select
 SET dm_tbl_cnt = size(plan_write->qual,5)
 IF (dm_tbl_cnt=0)
  CALL echo("***")
  CALL echo(dm_tbl_cnt)
  GO TO step1
 ENDIF
 SELECT INTO "nl:"
  FROM dm_script_info_tbl_master dsim,
   (dummyt d  WITH seq = dm_tbl_cnt)
  PLAN (d
   WHERE (plan_write->qual[d.seq].table_name > " ")
    AND (((plan_write->qual[d.seq].insert_ind=1)) OR ((((plan_write->qual[d.seq].update_ind=1)) OR ((
   plan_write->qual[d.seq].delete_ind=1))) )) )
   JOIN (dsim
   WHERE (dsim.table_name=plan_write->qual[d.seq].table_name))
  ORDER BY dsim.table_name, dsim.script_name
  HEAD dsim.table_name
   d_valid_tbl = 0
  DETAIL
   IF ((dsim.script_name=plan_write->qual[d.seq].script_name)
    AND (((dsim.insert_ind=plan_write->qual[d.seq].insert_ind)) OR ((((dsim.update_ind=plan_write->
   qual[d.seq].update_ind)) OR ((dsim.delete_ind=plan_write->qual[d.seq].delete_ind))) )) )
    d_valid_tbl = 1
   ENDIF
  FOOT  dsim.table_name
   IF (d_valid_tbl=0)
    dm_err_cnt = (dm_err_cnt+ 1), stat = alterlist(dm_script_scanner_reply->err_list,dm_err_cnt),
    dm_script_scanner_reply->err_list[dm_err_cnt].fail_message = concat( $1,
     " is not using the master scripts for table -- ",plan_write->qual[d.seq].table_name),
    dm_script_scanner_reply->err_list[dm_err_cnt].fail_number = 15000, dm_script_scanner_reply->
    fail_ind = 1
   ENDIF
  WITH nocounter
 ;end select
#step1
 FOR (d_loop = 1 TO d_exceptions)
   IF ((dm_exception->list[d_loop].check_cd=15001))
    GO TO skip_cost_chk
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="MAX SCRIPT COST"
  DETAIL
   d_allowed_cost = di.info_number, dm_environ_chk = 1
  WITH nocounter
 ;end select
 IF (dm_environ_chk=1)
  SELECT INTO "nl:"
   FROM dm_script_info_sql_env dss
   WHERE (dss.script_name=dm_script_scanner_reply->script_name)
    AND (dss.project_instance= $2)
    AND dss.environment_id=dm_environ_id
   DETAIL
    d_total_cost = (dss.cost+ d_total_cost)
   WITH nocounter
  ;end select
  IF (d_total_cost > d_allowed_cost)
   SET dm_err_cnt = (dm_err_cnt+ 1)
   SET stat = alterlist(dm_script_scanner_reply->err_list,dm_err_cnt)
   SET dm_script_scanner_reply->fail_ind = 1
   SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_number = 15001
   SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_message =
   "Failed Max Cost Check - CCL Cost for this script is too high."
  ENDIF
 ENDIF
#skip_cost_chk
 FOR (d_loop = 1 TO d_exceptions)
   IF ((dm_exception->list[d_loop].check_cd=15006))
    GO TO skip_uar_chk
   ENDIF
 ENDFOR
 FOR (dm_for_cnt = 1 TO size(plan_write->qual,5))
   IF ((plan_write->qual[dm_for_cnt].table_name="CODE_VALUE")
    AND (plan_write->qual[dm_for_cnt].select_ind=1))
    SET uar_chk_ind = 1
    SET uar_chk = dm_script_scanner_reply->script_name
    SET dm_for_cnt = size(plan_write->qual,5)
   ENDIF
 ENDFOR
 IF (uar_chk_ind=1)
  SET uar_fail = 0
  SELECT INTO "nl:"
   FROM uar_call_chk u
   WHERE u.name=uar_chk
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET dm_err_cnt = (dm_err_cnt+ 1)
   SET stat = alterlist(dm_script_scanner_reply->err_list,dm_err_cnt)
   SET dm_script_scanner_reply->fail_ind = 1
   SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_number = 15006
   SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_message =
   "A Select from the Code_Value table was used rather than a UAR Call"
  ENDIF
 ENDIF
#skip_uar_chk
 FOR (d_loop = 1 TO d_exceptions)
   IF ((dm_exception->list[d_loop].check_cd=15002))
    GO TO skip_outerjoin_chk
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   dm_tmp = 0, dm_found = 0, pn_select_ind = 0,
   pn_orahint_ind = 0
  DETAIL
   dm_tmp = (dm_tmp+ 1)
   IF (findstring("SELECT",t.line) > 0)
    dm_sql_cnt = (dm_sql_cnt+ 1), stat = alterlist(sql->list,dm_sql_cnt), pn_select_ind = 1,
    dm_found = 1
   ENDIF
   IF (dm_sql_cnt > 0)
    IF (dm_found=0)
     IF (((findstring("DUMMY",t.line) > 0) OR (findstring("WITH",t.line) > 0
      AND findstring("OUTERJOIN",t.line) > 0)) )
      sql->list[dm_sql_cnt].stmt = concat(sql->list[dm_sql_cnt].stmt,t.line)
     ENDIF
    ENDIF
    dm_found = 0
   ENDIF
   IF (((findstring("UPDATE",t.line) > 0) OR (((findstring("DELETE",t.line) > 0) OR (findstring(
    "INSERT",t.line) > 0)) )) )
    pn_select_ind = 0
   ENDIF
   IF (pn_select_ind=1
    AND findstring("ORAHINT",t.line) > 0)
    pn_orahint_ind = 1, pn_select_ind = 0
   ENDIF
  FOOT REPORT
   IF (pn_orahint_ind=1)
    dm_err_cnt = (dm_err_cnt+ 1), stat = alterlist(dm_script_scanner_reply->err_list,dm_err_cnt),
    dm_script_scanner_reply->fail_ind = 1,
    dm_script_scanner_reply->err_list[dm_err_cnt].fail_number = 15007, dm_script_scanner_reply->
    err_list[dm_err_cnt].fail_message = "ORAHINT was found in the CCL statement"
   ENDIF
   stat = alterlist(sql->list,dm_sql_cnt)
  WITH nocounter
 ;end select
 FOR (dm_for_cnt = 1 TO size(sql->list,5))
   IF (findstring("DUMMY",sql->list[dm_for_cnt].stmt) > 0
    AND findstring("OUTERJOIN",sql->list[dm_for_cnt].stmt) > 0)
    SET final_verdict = 1
    GO TO stop_search
   ENDIF
 ENDFOR
#stop_search
 IF (final_verdict=1)
  SET dm_err_cnt = (dm_err_cnt+ 1)
  SET stat = alterlist(dm_script_scanner_reply->err_list,dm_err_cnt)
  SET dm_script_scanner_reply->fail_ind = 1
  SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_number = 15002
  SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_message =
  "outerjoin/dummyt used within the same ccl statement."
 ENDIF
#skip_outerjoin_chk
 FOR (d_loop = 1 TO d_exceptions)
   IF ((dm_exception->list[d_loop].check_cd=15003))
    GO TO skip_full_chk
   ENDIF
 ENDFOR
 FOR (dm_for_cnt = 1 TO full_tab_cnt)
   IF ((dm_script_scanner_reply->script_name=full_table_scan->list[dm_for_cnt].script_name))
    IF ((full_table_scan->list[dm_for_cnt].full_tab_ind=1)
     AND (full_table_scan->list[dm_for_cnt].table_name != "DUAL"))
     SET dm_err_cnt = (dm_err_cnt+ 1)
     SET stat = alterlist(dm_script_scanner_reply->err_list,dm_err_cnt)
     SET dm_script_scanner_reply->fail_ind = 1
     SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_number = 15003
     SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_message = concat(
      "Full table scan found on: ",full_table_scan->list[dm_for_cnt].table_name)
    ENDIF
   ENDIF
 ENDFOR
#skip_full_chk
 SELECT INTO "nl:"
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   ccl_audit_err = 0, ccl_audit_ind = 0
  DETAIL
   child_startf = findstring("EXECUTE ",t.line,1,0), child_failf = findstring(" FROM",t.line,1,0)
   IF (child_startf > 0
    AND child_failf=0)
    childstr = substring((child_startf+ 8),findstring(" ",substring((child_startf+ 8),size(t.line),t
       .line)),t.line)
    IF (childstr="CCL_AUDIT")
     ccl_audit_ind = 1
    ENDIF
    childcount = (size(dm_child->child_list,5)+ 1), stat = alterlist(dm_child->child_list,childcount),
    dm_child->child_list[childcount].child_script = childstr
   ELSEIF (((ccl_audit_ind=1) OR (ccl_audit_ind=2)) )
    ccl_audit_start = findstring('"',t.line), ccl_audit_line = substring((ccl_audit_start+ 1),size(t
      .line),t.line), ccl_audit_script = cnvtupper(substring((ccl_audit_start+ 1),(findstring('"',
       ccl_audit_line) - 1),t.line))
    IF (ccl_audit_ind=1)
     c_cnt = (c_cnt+ 1)
     IF (mod(c_cnt,10)=1)
      stat = alterlist(dm_ccl_audit->list,(c_cnt+ 9))
     ENDIF
     dm_ccl_audit->list[c_cnt].name = ccl_audit_script, ccl_audit_ind = 2
    ELSEIF (ccl_audit_ind=2)
     c_cnt = (c_cnt+ 1)
     IF (mod(c_cnt,10)=1)
      stat = alterlist(dm_ccl_audit->list,(c_cnt+ 9))
     ENDIF
     dm_ccl_audit->list[c_cnt].type = ccl_audit_script, ccl_audit_ind = 0
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FOR (d_loop = 1 TO c_cnt)
   SET ccl_audit_err = 0
   IF ((dm_ccl_audit->list[d_loop].name > " "))
    SELECT INTO "nl:"
     FROM ccl_audit_chk_name c
     WHERE (c.name != dm_ccl_audit->list[d_loop].name)
     DETAIL
      ccl_audit_err = 1, ccl_audit_err_name = dm_ccl_audit->list[d_loop].name
     WITH nocounter
    ;end select
   ENDIF
   IF (ccl_audit_err=1)
    SET dm_err_cnt = (dm_err_cnt+ 1)
    SET stat = alterlist(dm_script_scanner_reply->err_list,dm_err_cnt)
    SET dm_script_scanner_reply->fail_ind = 1
    SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_number = 15005
    SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_message = concat(
     "CCL_AUDIT calling unapproved script -- ",ccl_audit_err_name)
   ENDIF
   SET ccl_audit_err = 0
   IF ((dm_ccl_audit->list[d_loop].type > " "))
    SELECT INTO "nl:"
     FROM ccl_audit_chk_type c
     WHERE (c.type != dm_ccl_audit->list[d_loop].type)
     DETAIL
      ccl_audit_err = 1, ccl_audit_err_name = dm_ccl_audit->list[d_loop].type
     WITH nocounter
    ;end select
   ENDIF
   IF (ccl_audit_err=1)
    SET dm_err_cnt = (dm_err_cnt+ 1)
    SET stat = alterlist(dm_script_scanner_reply->err_list,dm_err_cnt)
    SET dm_script_scanner_reply->fail_ind = 1
    SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_number = 15005
    SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_message = concat(
     "CCL_AUDIT calling unapproved script -- ",ccl_audit_err_name)
   ENDIF
 ENDFOR
 FOR (dm_for_cnt = 1 TO size(dm_child->child_list,5))
   SELECT INTO "nl:"
    FROM dm_script_info_dependency sd2
    WHERE sd2.child_script_name=cnvtupper(dm_child->child_list[dm_for_cnt].child_script)
     AND sd2.dependency_type="EXECUTION DEPENDENCY"
    DETAIL
     temp_ind = 99
    WITH nocounter
   ;end select
   IF (temp_ind=99)
    SELECT INTO "nl:"
     FROM dm_script_info_dependency sd
     WHERE sd.parent_script_name=cnvtupper( $1)
      AND sd.child_script_name=cnvtupper(dm_child->child_list[dm_for_cnt].child_script)
      AND sd.dependency_type="EXECUTION DEPENDENCY"
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET temp_ind = 1
    ENDIF
   ENDIF
   IF (temp_ind=1)
    SET dm_err_cnt = (dm_err_cnt+ 1)
    SET stat = alterlist(dm_script_scanner_reply->err_list,dm_err_cnt)
    SET dm_script_scanner_reply->fail_ind = 1
    SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_number = 15004
    SET dm_script_scanner_reply->err_list[dm_err_cnt].fail_message = concat(
     "Script dependency problem for script:", $1)
   ENDIF
 ENDFOR
#exit_program
 IF ((dm_script_scanner_reply->fail_ind != 1))
  SET dm_script_scanner_reply->fail_ind = 0
  SET stat = alterlist(dm_script_scanner_reply->err_list,1)
  SET dm_script_scanner_reply->err_list[1].fail_message = "Success"
 ENDIF
 IF (cursys="AIX")
  SET dclcom = concat("rm ",dm_unique_dat2)
 ELSE
  SET dclcom = build("delete ccluserdir:",dm_unique_dat2,";*")
 ENDIF
 SET len = size(trim(dclcom))
 SET status = 0
 CALL dcl(dclcom,len,status)
 IF (status=0)
  CALL echo("** Purge DAT Files Failed **")
 ELSE
  CALL echo(concat("** Purge of:",dm_unique_dat2," complete **"))
 ENDIF
 DELETE  FROM dm_script_failure dsf
  WHERE dsf.environ_id=dm_environ_id
   AND (dsf.script_name=dm_script_scanner_reply->script_name)
   AND (dsf.project_instance= $2)
  WITH nocounter
 ;end delete
 FOR (d_loop_cnt = 1 TO dm_err_cnt)
   DELETE  FROM dm_script_failure dsf
    WHERE (dsf.script_name=dm_script_scanner_reply->script_name)
     AND dsf.environ_id=dm_environ_id
     AND (dsf.project_instance= $2)
     AND (dsf.error_cd=dm_script_scanner_reply->err_list[d_loop_cnt].fail_number)
    WITH nocounter
   ;end delete
   INSERT  FROM dm_script_failure dsf
    SET dsf.environ_id = dm_environ_id, dsf.script_name = dm_script_scanner_reply->script_name, dsf
     .project_instance =  $2,
     dsf.error_cd = dm_script_scanner_reply->err_list[d_loop_cnt].fail_number, dsf.error_text =
     dm_script_scanner_reply->err_list[d_loop_cnt].fail_message, dsf.failed_dt_tm = cnvtdatetime(
      curdate,curtime3)
    WITH nocounter
   ;end insert
   COMMIT
 ENDFOR
 FREE RECORD sql
 FREE RECORD dm_tables
 FREE RECORD dm_child
 FREE RECORD full_table_scan
 FREE RECORD plan_write
 FREE RECORD dm_ccl_audit
END GO
