CREATE PROGRAM aps_add_db_cyto_user_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 join_table = c8
     2 prsnl_id = f8
 )
#script
 SET reply->status_data.status = "F"
 SET error_cnt = 0
 SET x = 1
 SET y = 1
 SET limits_cnt = request->limits_cnt
 SET security_cnt = request->security_cnt
 SET csl_updt_cnt = 0
 SET css_updt_cnt = 0
#limits
 IF (limits_cnt > 0
  AND x <= limits_cnt)
  FOR (x = x TO limits_cnt)
   INSERT  FROM cyto_screening_limits csl
    SET csl.prsnl_id = request->limits_qual[x].prsnl_id, csl.sequence = 0, csl.slide_limit = request
     ->limits_qual[x].slide_limit,
     csl.screening_hours = request->limits_qual[x].screening_hours, csl.active_ind = 1, csl.updt_cnt
      = 0,
     csl.updt_dt_tm = cnvtdatetime(curdate,curtime), csl.updt_id = reqinfo->updt_id, csl.updt_task =
     reqinfo->updt_task,
     csl.updt_applctx = reqinfo->updt_applctx, csl.requeue_flag = request->limits_qual[x].
     requeue_flag
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL handle_errors("insert","f","table","cyto_screening_limits")
    SET reply->exception_data[x].join_table = "limits"
    SET reply->exception_data[x].prsnl_id = request->limits_qual[x].prsnl_id
    SET x = (x+ 1)
    GO TO limits
   ELSE
    COMMIT
   ENDIF
  ENDFOR
 ENDIF
#security
 IF (security_cnt > 0
  AND y <= security_cnt)
  FOR (y = y TO security_cnt)
   INSERT  FROM cyto_screening_security css
    SET css.prsnl_id = request->security_qual[y].prsnl_id, css.sequence = 0, css.normal_percentage =
     request->security_qual[y].norm_percentage,
     css.normal_requeue_flag = request->security_qual[y].norm_rq_flag, css.normal_service_resource_cd
      = request->security_qual[y].norm_srvc_rsrce_cd, css.normal_requeue_rank = request->
     security_qual[y].norm_rq_rank,
     css.abnormal_percentage = request->security_qual[y].abnorm_percentage, css.abnormal_requeue_flag
      = request->security_qual[y].abnorm_rq_flag, css.abnormal_service_resource_cd = request->
     security_qual[y].abnorm_srvc_rsrce_cd,
     css.abnormal_requeue_rank = request->security_qual[y].abnorm_rq_rank, css.atypical_percentage =
     request->security_qual[y].atyp_percentage, css.atypical_requeue_flag = request->security_qual[y]
     .atyp_rq_flag,
     css.atypical_service_resource_cd = request->security_qual[y].atyp_srvc_rsrce_cd, css
     .atypical_requeue_rank = request->security_qual[y].atyp_rq_rank, css.chr_percentage = request->
     security_qual[y].chr_percentage,
     css.chr_requeue_flag = request->security_qual[y].chr_rq_flag, css.chr_service_resource_cd =
     request->security_qual[y].chr_srvc_rsrce_cd, css.chr_requeue_rank = request->security_qual[y].
     chr_rq_rank,
     css.unsat_percentage = request->security_qual[y].unsat_percentage, css.unsat_requeue_flag =
     request->security_qual[y].unsat_rq_flag, css.unsat_service_resource_cd = request->security_qual[
     y].unsat_srvc_rsrce_cd,
     css.verify_level = request->security_qual[y].verify_level, css.active_ind = 1, css.updt_cnt = 0,
     css.updt_dt_tm = cnvtdatetime(curdate,curtime), css.updt_id = reqinfo->updt_id, css.updt_task =
     reqinfo->updt_task,
     css.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL handle_errors("insert","f","table","cyto_screening_security")
    SET reply->exception_data[y].join_table = "security"
    SET reply->exception_data[y].prsnl_id = request->security_qual[y].prsnl_id
    SET y = (y+ 1)
    GO TO security
   ELSE
    COMMIT
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (error_cnt > 0)
  IF ((error_cnt=(limits_cnt+ security_cnt)))
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "P"
  ENDIF
 ELSE
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
#end_of_reports
END GO
