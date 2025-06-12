CREATE PROGRAM aps_chg_db_prefix_templates:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#initializations
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cur_updt_cnt = 0
 SET error_cnt = 0
#start_of_script
 SELECT INTO "nl:"
  ap.worksheet_template_id
  FROM ap_prefix ap
  WHERE (ap.prefix_id=request->prefix_cd)
  DETAIL
   cur_updt_cnt = ap.updt_cnt
  WITH forupdate(ap)
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","AP_PREFIX")
  GO TO exit_script
 ENDIF
 IF ((request->prefix_updt_cnt != cur_updt_cnt))
  CALL handle_errors("LOCK","F","TABLE","AP_PREFIX")
  GO TO exit_script
 ENDIF
 SET cur_updt_cnt = (cur_updt_cnt+ 1)
 UPDATE  FROM ap_prefix ap
  SET ap.worksheet_template_id = request->template_id, ap.updt_dt_tm = cnvtdatetime(curdate,curtime),
   ap.updt_cnt = cur_updt_cnt,
   ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->
   updt_applctx
  WHERE (ap.prefix_id=request->prefix_cd)
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL handle_errors("UPDATE","F","TABLE","AP_PREFIX")
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
END GO
