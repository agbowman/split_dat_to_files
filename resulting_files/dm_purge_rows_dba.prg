CREATE PROGRAM dm_purge_rows:dba
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 11
 SET select_error_comp = 12
 SET select_error_pend = 13
 SET select_error_fail = 14
 SET ccl_error = 15
 SET update_error = 16
 SET data_error = 17
 SET value_error = 18
 SET failed = false
 SET table_name = fillstring(50," ")
 SET emsg = fillstring(132," ")
 SET ecode = 0
 SET pa_cd_comp = 0
 SET pa_cd_pend = 0
 SET pa_cd_fail = 0
 SET pa_cd = 0
 SET counter = 0
 SET new_audit_id = 0
 SET pa_dummy = 0
 SET parser_buf[7] = fillstring(132," ")
 SET reply->status_data.status = "F"
 SET reply->ops_event = ""
 RECORD all_table_list(
   1 table_info[*]
     2 reqid = f8
     2 src_procid = f8
     2 tname = c30
     2 key_col_name = c30
     2 key_col_value = vc
   1 table_count = i4
 )
 SET stat = alterlist(all_table_list->table_info,10)
 SET all_table_list->table_count = 0
 DELETE  FROM pa_audit
  WHERE line_str="*"
 ;end delete
 COMMIT
 RDB asis ( "Begin DM_PAR; End;" )
 END ;Rdb
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=14259
   AND ((cv.cdf_meaning="PURGE_COMP") OR (((cv.cdf_meaning="PURGE_PEND") OR (cv.cdf_meaning=
  "PURGE_FAIL")) ))
  DETAIL
   IF (cv.cdf_meaning="PURGE_COMP")
    pa_cd_comp = cv.code_value
   ELSEIF (cv.cdf_meaning="PURGE_PEND")
    pa_cd_pend = cv.code_value
   ELSE
    pa_cd_fail = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL getsequencenumber(pa_dummy)
  IF (pa_cd_comp=0)
   SET failed = select_error_comp
  ELSEIF (pa_cd_pend=0)
   SET failed = select_error_pend
  ELSEIF (pa_cd_fail=0)
   SET failed = select_error_fail
  ENDIF
  INSERT  FROM pa_audit e
   SET e.pa_audit_id = new_audit_id, e.sys_date = cnvtdatetime(curdate,curtime3), e.action = "ERROR",
    e.table_name = "CODE_VALUE", e.req_id = null, e.line_str = concat(cnvtstring(failed),
     "SELECT ERROR CODE")
   WITH clear = "0"
  ;end insert
  COMMIT
  SET reply->ops_event = cnvtstring(failed)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  r.table_name, r.key_col_name, r.key_col_value
  FROM pa_request r
  WHERE r.purge_archive_cd=pa_cd_pend
   AND r.purge_archive_dt_tm <= cnvtdatetime(curdate,curtime3)
  DETAIL
   all_table_list->table_count = (all_table_list->table_count+ 1)
   IF (mod(all_table_list->table_count,10)=1
    AND (all_table_list->table_count != 1))
    stat = alterlist(all_table_list->table_info,(all_table_list->table_count+ 9))
   ENDIF
   all_table_list->table_info[all_table_list->table_count].reqid = r.request_id, all_table_list->
   table_info[all_table_list->table_count].src_procid = r.search_process_id, all_table_list->
   table_info[all_table_list->table_count].tname = r.table_name,
   all_table_list->table_info[all_table_list->table_count].key_col_name = r.key_col_name,
   all_table_list->table_info[all_table_list->table_count].key_col_value = r.key_col_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL getsequencenumber(pa_dummy)
  SET failed = data_error
  INSERT  FROM pa_audit e
   SET e.pa_audit_id = new_audit_id, e.sys_date = cnvtdatetime(curdate,curtime3), e.action = "ERROR",
    e.table_name = "PA_REQUEST", e.req_id = null, e.line_str = concat(cnvtstring(failed),
     "DATA ERROR -- nothing to purge")
   WITH clear = "0"
  ;end insert
  SET reply->ops_event = cnvtstring(failed)
  COMMIT
  GO TO exit_script
 ENDIF
 FOR (counter = 1 TO all_table_list->table_count)
   SET parser_buf[1] = 'RDB ASIS(" begin DM_PURGE_TABLE(")'
   SET parser_buf[2] = concat('ASIS("',"'",trim(all_table_list->table_info[counter].tname),"',",'")')
   SET parser_buf[3] = concat('ASIS("',"'",trim(all_table_list->table_info[counter].key_col_name),
    "',",'")')
   SET parser_buf[4] = concat('ASIS("',"'",trim(all_table_list->table_info[counter].key_col_value),
    "',",'")')
   SET parser_buf[5] = concat('ASIS("',"'",trim(cnvtstring(all_table_list->table_info[counter].reqid)
     ),"'",'")')
   SET parser_buf[6] = 'ASIS("); end;")'
   SET parser_buf[7] = " go"
   FOR (cnt = 1 TO 7)
     CALL parser(parser_buf[cnt],1)
   ENDFOR
   SELECT INTO "nl:"
    a.nbr_rows
    FROM pa_audit a
    WHERE (a.req_id=all_table_list->table_info[counter].reqid)
     AND a.action="ERROR"
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET pa_cd = pa_cd_comp
   ELSE
    SET pa_cd = pa_cd_fail
   ENDIF
   UPDATE  FROM pa_request p
    SET p.purge_archive_cd = pa_cd
    WHERE (p.request_id=all_table_list->table_info[counter].reqid)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL getsequencenumber(pa_dummy)
    SET failed = update_error
    INSERT  FROM pa_audit e
     SET e.pa_audit_id = new_audit_id, e.sys_date = cnvtdatetime(curdate,curtime3), e.action =
      "ERROR",
      e.req_id = all_table_list->table_info[counter].reqid, e.table_name = "PA_REQUEST", e.line_str
       = concat(cnvtstring(failed),"UPDATE ERROR")
     WITH clear = "0"
    ;end insert
    SET reply->ops_event = cnvtstring(failed)
    COMMIT
    GO TO exit_script
   ENDIF
   UPDATE  FROM pa_audit e
    SET e.search_process_id = all_table_list->table_info[counter].src_procid
    WHERE (e.req_id=all_table_list->table_info[counter].reqid)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL getsequencenumber(pa_dummy)
    SET failed = value_error
    INSERT  FROM pa_audit e
     SET e.pa_audit_id = new_audit_id, e.sys_date = cnvtdatetime(curdate,curtime3), e.action =
      "ERROR",
      e.req_id = all_table_list->table_info[counter].reqid, e.table_name = "PA_AUDIT", e.line_str =
      concat(cnvtstring(failed),"VALUE ERROR")
     WITH clear = "0"
    ;end insert
    COMMIT
   ENDIF
 ENDFOR
 SUBROUTINE getsequencenumber(dummy)
  SELECT INTO "nl:"
   dm_x = seq(pa_audit_seq,nextval)
   FROM dual
   DETAIL
    new_audit_id = cnvtreal(dm_x)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed = gen_nbr_error
   SET reply->ops_event = cnvtstring(failed)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 COMMIT
#exit_script
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  CALL getsequencenumber(pa_dummy)
  SET failed = ccl_error
  INSERT  FROM pa_audit e
   SET pa_audit_id = new_audit_id, e.sys_date = cnvtdatetime(curdate,curtime3), e.action = "ERROR",
    e.table_name = " ", e.req_id = null, e.line_str = concat("CCL",emsg)
   WITH clear = "0"
  ;end insert
  COMMIT
  SET reply->ops_event = concat(cnvtstring(failed),emsg)
 ENDIF
 IF (failed != false
  AND failed != data_error)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
