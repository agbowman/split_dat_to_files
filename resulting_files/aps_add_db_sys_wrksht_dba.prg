CREATE PROGRAM aps_add_db_sys_wrksht:dba
 RECORD reply(
   1 cyto_worksheet_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET error_cnt = 0
 SET next_code = 0.0
 SET csl_updt_cnt = 0
 SET css_updt_cnt = 0
 EXECUTE cpm_next_code
 INSERT  FROM code_value c
  SET c.code_value = next_code, c.code_set = request->code_set, c.cdf_meaning = request->cdf_meaning,
   c.display = request->cdf_display, c.display_key = cnvtupper(cnvtalphanum(request->cdf_display)), c
   .description = request->cdf_description,
   c.definition = request->cdf_definition, c.active_ind = request->cdf_active_ind, c.active_dt_tm =
   cnvtdatetime(curdate,curtime),
   c.active_type_cd =
   IF ((request->cdf_active_ind=1)) reqdata->active_status_cd
   ELSE reqdata->inactive_status_cd
   ENDIF
   , c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo->updt_id,
   c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual != 1)
  CALL handle_errors("INSERT","F","TABLE","CODE_VALUE")
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET number_of_ext = request->code_value_extn_cnt
 INSERT  FROM code_value_extension cve,
   (dummyt d  WITH seq = value(number_of_ext))
  SET cve.code_set = request->code_set, cve.code_value = next_code, cve.field_name = request->qual[d
   .seq].field_name,
   cve.field_type = request->qual[d.seq].field_type, cve.field_value = request->qual[d.seq].
   field_value, cve.updt_cnt = 0,
   cve.updt_id = reqinfo->updt_id, cve.updt_task = reqinfo->updt_task, cve.updt_applctx = reqinfo->
   updt_applctx,
   cve.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (cve)
 ;end insert
 IF ((curqual != request->code_value_extn_cnt))
  IF (curqual=0)
   CALL handle_errors("insrt","f","table","code_value_exten")
  ELSE
   CALL handle_errors("insert","z","table","code_value_exten")
  ENDIF
 ENDIF
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->cyto_worksheet_cd = next_code
  COMMIT
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
#end_of_reports
END GO
