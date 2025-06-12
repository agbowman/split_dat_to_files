CREATE PROGRAM dm_add_cv_filter_r:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET active_status_cd = 0.0
 IF ((reqdata->active_status_cd > 0))
  SET active_status_cd = reqdata->active_status_cd
 ELSE
  SET code_value = 0.0
  SET code_set = 48
  SET cdf_meaning = "ACTIVE"
  EXECUTE cpm_get_cd_for_cdf
  SET active_status_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = concat("Error finding the code_value for cdf_meaning ",trim(cdf_meaning),
    " from code_set ",trim(cnvtstring(code_set)))
   GO TO exit_script
  ENDIF
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 INSERT  FROM code_value_filter_r cvfr,
   (dummyt d  WITH seq = value(request->qual_knt))
  SET cvfr.code_value_filter_id = request->qual[d.seq].code_value_filter_id, cvfr.code_value_cd =
   request->qual[d.seq].code_value_cd, cvfr.updt_id = reqinfo->updt_id,
   cvfr.updt_cnt = 0, cvfr.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvfr.updt_task = reqinfo->
   updt_task,
   cvfr.updt_applctx = reqinfo->updt_applctx, cvfr.active_ind = 1, cvfr.active_status_cd =
   active_status_cd,
   cvfr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cvfr.active_status_prsnl_id = reqinfo->
   updt_id, cvfr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   cvfr.end_effective_dt_tm = cnvtdatetime("31-dec-2100 23:59:59")
  PLAN (d
   WHERE d.seq > 0)
   JOIN (cvfr
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = insert_error
  SET table_name = "CODE_VALUE_FILTER_R"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=delete_error)
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GENERATE SEQ"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
