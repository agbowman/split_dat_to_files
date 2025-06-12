CREATE PROGRAM dm_purge_rowid:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 request_id = vc
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD rowid_list(
   1 table_name = c30
   1 prg_rowid[*]
     2 row_id = c18
 )
 SET false = 0
 SET true = 1
 SET emsg = fillstring(132," ")
 SET ecode = 0
 SET failed = false
 SET pass_table_error = 1
 SET pass_rowid_error = 2
 SET ccl_error = 3
 SET gen_aud_error = 4
 SET gen_req_error = 5
 SET ora_error = 6
 SET parser_buf[6] = fillstring(132," ")
 SET new_audit_id = 0
 SET new_req_id = 0
 SET pa_dummy = 0
 SET req_dummy = 0
 SET reply->status_data.status = "F"
 SET reply->ops_event = ""
 SET reply->request_id = ""
 CALL getrequestsequencenumber(req_dummy)
 SET request_id = cnvtstring(new_req_id)
 SET reply->request_id = request_id
 IF (trim(dm_prg_rowid_req->table_name) != "")
  SET nbr_of_rows = 0
  SET nbr_of_rows = size(dm_prg_rowid_req->prg_rowid,5)
  SET rowid_list->table_name = dm_prg_rowid_req->table_name
  FOR (row_cnt = 1 TO nbr_of_rows)
    IF ((dm_prg_rowid_req->prg_rowid[row_cnt].row_id != ""))
     SET stat = alterlist(rowid_list->prg_rowid,row_cnt)
     SET rowid_list->prg_rowid[row_cnt].row_id = dm_prg_rowid_req->prg_rowid[row_cnt].row_id
    ELSE
     CALL getsequencenumber(pa_dummy)
     SET failed = pass_rowid_error
     INSERT  FROM pa_audit e
      SET e.pa_audit_id = new_audit_id, e.sys_date = cnvtdatetime(curdate,curtime3), e.action =
       "ERROR",
       e.table_name = " ", e.req_id = 0, e.line_str = concat(cnvtstring(failed),
        "ROWID ERROR -- ROWID is blank")
      WITH clear = "0"
     ;end insert
     SET reply->ops_event = "PASS_ROWID_ERROR: ROWID is blank"
     COMMIT
     GO TO exit_script
    ENDIF
  ENDFOR
 ELSE
  CALL getsequencenumber(pa_dummy)
  SET failed = pass_table_error
  INSERT  FROM pa_audit e
   SET e.pa_audit_id = new_audit_id, e.sys_date = cnvtdatetime(curdate,curtime3), e.action = "ERROR",
    e.table_name = " ", e.req_id = 0, e.line_str = concat(cnvtstring(failed),
     "PASS TABLE ERROR -- TABLE NAME is blank")
   WITH clear = "0"
  ;end insert
  SET reply->ops_event = "PASS_TABLE_ERROR: Table Name is blank"
  COMMIT
  GO TO exit_script
 ENDIF
 FOR (row_cnt = 1 TO nbr_of_rows)
   SET parser_buf[1] = 'RDB ASIS(" begin DM_PURGE_TABLE_ROWID(")'
   SET parser_buf[2] = concat('ASIS("',"'",trim(rowid_list->table_name),"',",'")')
   SET parser_buf[3] = concat('ASIS("',"'",rowid_list->prg_rowid[row_cnt].row_id,"',",'")')
   SET parser_buf[4] = concat('ASIS("',"'",trim(request_id),"'",'")')
   SET parser_buf[5] = 'ASIS("); end;")'
   SET parser_buf[6] = " go"
   FOR (cnt = 1 TO 6)
     CALL parser(parser_buf[cnt],1)
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  a.nbr_rows
  FROM pa_audit a
  WHERE a.req_id=new_req_id
   AND a.action="ERROR"
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET failed = ora_error
  SET reply->ops_event = "ORA_ERROR: See PA_AUDIT table"
  GO TO exit_script
 ENDIF
 SUBROUTINE getsequencenumber(dummy)
  SELECT INTO "nl:"
   dm_x = seq(pa_audit_seq,nextval)
   FROM dual
   DETAIL
    new_audit_id = cnvtreal(dm_x)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed = gen_aud_error
   SET reply->ops_event = "GEN_AUD_ERROR: PA_AUDIT_SEQ error"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 COMMIT
 SUBROUTINE getrequestsequencenumber(dummy_two)
  SELECT INTO "nl:"
   dm_y = seq(pa_request_seq,nextval)
   FROM dual
   DETAIL
    new_req_id = cnvtreal(dm_y)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET failed = gen_req_error
   SET reply->ops_event = "GEN_REQ_ERROR: DM_PRG_ROWID_SEQ error"
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
    e.table_name = dm_prg_rowid_req->table_name, e.req_id = 0, e.line_str = concat("CCL",emsg)
   WITH clear = "0"
  ;end insert
  COMMIT
  SET reply->ops_event = concat(cnvtstring(failed),emsg)
 ENDIF
 IF (failed != false)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
