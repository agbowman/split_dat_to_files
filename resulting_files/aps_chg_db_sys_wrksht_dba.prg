CREATE PROGRAM aps_chg_db_sys_wrksht:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET updt_cnt = 0
 SET cur_updt_cnt[3] = 0
 SET error_cnt = 0
 SELECT INTO "nl:"
  FROM code_value_extension cve,
   (dummyt d  WITH seq = 3)
  PLAN (d)
   JOIN (cve
   WHERE (cve.code_value=request->cyto_wrksht_cd)
    AND (cve.field_name=request->wrksht_param_qual[d.seq].field_name)
    AND cve.code_set=1308)
  HEAD REPORT
   updt_cnt = 0
  DETAIL
   updt_cnt = (updt_cnt+ 1), cur_updt_cnt[updt_cnt] = cve.updt_cnt
  WITH nocounter, forupdate(cve)
 ;end select
 IF (updt_cnt != 3)
  SET failed = "T"
  CALL handle_errors("LOCK","F","TABLE","CODE_VALUE_EXTENSION")
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value_extension cve,
   (dummyt d  WITH seq = 3)
  SET cve.field_value = request->wrksht_param_qual[d.seq].field_value, cve.updt_cnt = (cve.updt_cnt+
   1), cve.updt_dt_tm = cnvtdatetime(curdate,curtime),
   cve.updt_id = reqinfo->updt_id, cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (cve
   WHERE (cve.code_value=request->cyto_wrksht_cd)
    AND (cve.field_name=request->wrksht_param_qual[d.seq].field_name)
    AND cve.code_set=1308)
  WITH nocounter
 ;end update
 IF (curqual != 3)
  SET failed = "T"
  CALL handle_errors("UPDATE","F","TABLE","CODE_VALUE_EXTENSION")
 ENDIF
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  CALL echo("failed")
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
    SET stat = alter(reply->exception_data,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
END GO
