CREATE PROGRAM dcp_srv_write_error_log:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = 0
 SET dcp_error_log_id = 0.0
 SELECT INTO "nl:"
  y = seq(dcp_error2_seq,nextval)
  FROM dual
  DETAIL
   dcp_error_log_id = y
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "nextval"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_ERROR_SEQ"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_srv_write_error_seq"
  SET failed = 1
  GO TO exit_script
 ENDIF
 DELETE  FROM dcp_error_log d
  WHERE d.dcp_error_log_id=dcp_error_log_id
  WITH nocounter
 ;end delete
 FOR (x = 1 TO request->message_cnt)
   INSERT  FROM dcp_error_log d
    SET d.dcp_error_log_id = dcp_error_log_id, d.sequence = request->message_qual[x].sequence, d
     .parent_entity_name = request->message_qual[x].parent_entity_name,
     d.parent_entity_id = request->message_qual[x].parent_entity_id, d.person_id = request->
     message_qual[x].person_id, d.encntr_id = request->message_qual[x].encntr_id,
     d.prsnl_id = request->message_qual[x].prsnl_id, d.message_string = request->message_qual[x].
     message_string, d.error_string = request->message_qual[x].error_string,
     d.request_number = request->message_qual[x].request_number, d.updt_dt_tm = cnvtdatetime(curdate,
      curtime3)
    WITH nocounter
   ;end insert
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP_ERROR_LOG"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "dcp_srv_write_error_seq"
  SET failed = 1
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed=1)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
