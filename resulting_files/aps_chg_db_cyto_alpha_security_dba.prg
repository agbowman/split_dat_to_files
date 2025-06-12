CREATE PROGRAM aps_chg_db_cyto_alpha_security:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ndeletecount = i2 WITH protect, noconstant(0)
 DECLARE ndeleteupdatecount = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET report_updt_cnt[500] = 0
 SET count1 = 0
 SET cur_updt_cnt = 0
 SET error_cnt = 0
#start_of_script
 IF ((request->add_qual_cnt > 0))
  INSERT  FROM cyto_alpha_security cas,
    (dummyt d  WITH seq = value(request->add_qual_cnt))
   SET cas.nomenclature_id = request->add_qual[d.seq].nomenclature_id, cas.reference_range_factor_id
     = request->add_qual[d.seq].reference_range_factor_id, cas.service_resource_cd = request->
    add_qual[d.seq].service_resource_cd,
    cas.diagnostic_category_cd = request->add_qual[d.seq].diagnostic_category_cd, cas
    .degrees_from_normal =
    IF ((request->add_qual[d.seq].dfn_null_ind=1)) null
    ELSE request->add_qual[d.seq].degrees_from_normal
    ENDIF
    , cas.requeue_flag =
    IF ((request->add_qual[d.seq].rf_null_ind=1)) null
    ELSE request->add_qual[d.seq].requeue_flag
    ENDIF
    ,
    cas.requeue_service_resource_cd = request->add_qual[d.seq].requeue_service_resource_cd, cas
    .verify_level_is =
    IF ((request->add_qual[d.seq].vli_null_ind=1)) null
    ELSE request->add_qual[d.seq].verify_level_is
    ENDIF
    , cas.verify_level_rs =
    IF ((request->add_qual[d.seq].vlr_null_ind=1)) null
    ELSE request->add_qual[d.seq].verify_level_rs
    ENDIF
    ,
    cas.qa_flag_type_cd = request->add_qual[d.seq].qa_flag_type_cd, cas.updt_cnt = 0, cas.updt_dt_tm
     = cnvtdatetime(curdate,curtime),
    cas.updt_id = reqinfo->updt_id, cas.updt_task = reqinfo->updt_task, cas.updt_applctx = reqinfo->
    updt_applctx,
    cas.definition_ind = 1
   PLAN (d)
    JOIN (cas)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","CYTO_ALPHA_SECURITY")
  ENDIF
 ENDIF
 IF ((request->del_qual_cnt > 0))
  DELETE  FROM cyto_alpha_security cas,
    (dummyt d  WITH seq = value(request->del_qual_cnt))
   SET cas.reference_range_factor_id = request->del_qual[d.seq].reference_range_factor_id, cas
    .nomenclature_id = request->del_qual[d.seq].nomenclature_id, cas.service_resource_cd = request->
    del_qual[d.seq].service_resource_cd,
    cas.definition_ind = 1, cas.updt_cnt = request->del_qual[d.seq].updt_cnt
   PLAN (d)
    JOIN (cas
    WHERE (cas.reference_range_factor_id=request->del_qual[d.seq].reference_range_factor_id)
     AND (cas.nomenclature_id=request->del_qual[d.seq].nomenclature_id)
     AND (cas.service_resource_cd=request->del_qual[d.seq].service_resource_cd)
     AND cas.definition_ind=1
     AND (cas.updt_cnt=request->del_qual[d.seq].updt_cnt))
   WITH nocounter
  ;end delete
  SET ndeletecount = curqual
  SELECT INTO "nl:"
   cas.*
   FROM cyto_alpha_security cas,
    (dummyt d  WITH seq = value(request->del_qual_cnt))
   PLAN (d)
    JOIN (cas
    WHERE (cas.reference_range_factor_id=request->del_qual[d.seq].reference_range_factor_id)
     AND (cas.nomenclature_id=request->del_qual[d.seq].nomenclature_id)
     AND (cas.service_resource_cd=request->del_qual[d.seq].service_resource_cd)
     AND ((cas.definition_ind+ 0) IN (0, 2))
     AND ((cas.updt_cnt+ 0)=request->del_qual[d.seq].updt_cnt))
   HEAD REPORT
    ndeleteupdatecount = 0
   DETAIL
    ndeleteupdatecount = (ndeleteupdatecount+ 1)
   WITH forupdate(cas)
  ;end select
  IF (curqual > 0)
   UPDATE  FROM cyto_alpha_security cas,
     (dummyt d  WITH seq = value(request->del_qual_cnt))
    SET cas.definition_ind = 2, cas.diagnostic_category_cd = 0.0, cas.degrees_from_normal = null,
     cas.requeue_flag = null, cas.requeue_service_resource_cd = 0.0, cas.verify_level_is = null,
     cas.verify_level_rs = null, cas.qa_flag_type_cd = 0.0, cas.updt_cnt = (cas.updt_cnt+ 1),
     cas.updt_dt_tm = cnvtdatetime(curdate,curtime), cas.updt_id = reqinfo->updt_id, cas.updt_task =
     reqinfo->updt_task,
     cas.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (cas
     WHERE (cas.reference_range_factor_id=request->del_qual[d.seq].reference_range_factor_id)
      AND (cas.nomenclature_id=request->del_qual[d.seq].nomenclature_id)
      AND (cas.service_resource_cd=request->del_qual[d.seq].service_resource_cd)
      AND ((cas.definition_ind+ 0) IN (0, 2))
      AND ((cas.updt_cnt+ 0)=request->del_qual[d.seq].updt_cnt))
    WITH nocounter
   ;end update
   IF (curqual != ndeleteupdatecount)
    CALL handle_errors("UPDATE FOR DELETE","F","TABLE","CYTO_ALPHA_SECURITY")
    GO TO end_of_reports
   ENDIF
  ENDIF
  SET ndeletecount = (ndeletecount+ ndeleteupdatecount)
  IF ((ndeletecount != request->del_qual_cnt))
   CALL handle_errors("DELETE","F","TABLE","CYTO_ALPHA_SECURITY")
   GO TO end_of_reports
  ENDIF
 ENDIF
 IF ((request->chg_qual_cnt > 0))
  SELECT INTO "nl:"
   cas.*
   FROM cyto_alpha_security cas,
    (dummyt d  WITH seq = value(request->chg_qual_cnt))
   PLAN (d)
    JOIN (cas
    WHERE (request->chg_qual[d.seq].reference_range_factor_id=cas.reference_range_factor_id)
     AND (request->chg_qual[d.seq].nomenclature_id=cas.nomenclature_id)
     AND (request->chg_qual[d.seq].service_resource_cd=cas.service_resource_cd))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), report_updt_cnt[count1] = cas.updt_cnt
   WITH forupdate(cas)
  ;end select
  IF (((curqual=0) OR ((count1 != request->chg_qual_cnt))) )
   CALL handle_errors("SELECT","F","TABLE","CYTO_ALPHA_SECURITY")
   GO TO end_of_reports
  ELSE
   FOR (x = 1 TO request->chg_qual_cnt)
     IF ((request->chg_qual[x].updt_cnt != report_updt_cnt[x]))
      CALL handle_errors("UPDATE","F","TABLE","CYTO_ALPHA_SECURITY")
      GO TO end_of_reports
     ENDIF
   ENDFOR
   UPDATE  FROM cyto_alpha_security cas,
     (dummyt d  WITH seq = value(request->chg_qual_cnt))
    SET cas.nomenclature_id = request->chg_qual[d.seq].nomenclature_id, cas.reference_range_factor_id
      = request->chg_qual[d.seq].reference_range_factor_id, cas.service_resource_cd = request->
     chg_qual[d.seq].service_resource_cd,
     cas.diagnostic_category_cd = request->chg_qual[d.seq].diagnostic_category_cd, cas
     .degrees_from_normal =
     IF ((request->chg_qual[d.seq].dfn_null_ind=1)) null
     ELSE request->chg_qual[d.seq].degrees_from_normal
     ENDIF
     , cas.requeue_flag =
     IF ((request->chg_qual[d.seq].rf_null_ind=1)) null
     ELSE request->chg_qual[d.seq].requeue_flag
     ENDIF
     ,
     cas.requeue_service_resource_cd = request->chg_qual[d.seq].requeue_service_resource_cd, cas
     .verify_level_is =
     IF ((request->chg_qual[d.seq].vli_null_ind=1)) null
     ELSE request->chg_qual[d.seq].verify_level_is
     ENDIF
     , cas.verify_level_rs =
     IF ((request->chg_qual[d.seq].vlr_null_ind=1)) null
     ELSE request->chg_qual[d.seq].verify_level_rs
     ENDIF
     ,
     cas.qa_flag_type_cd = request->chg_qual[d.seq].qa_flag_type_cd, cas.definition_ind =
     IF (cas.definition_ind=0) 0
     ELSEIF (cas.definition_ind=1) 1
     ELSE 0
     ENDIF
     , cas.updt_cnt = (request->chg_qual[d.seq].updt_cnt+ 1),
     cas.updt_dt_tm = cnvtdatetime(curdate,curtime), cas.updt_id = reqinfo->updt_id, cas.updt_task =
     reqinfo->updt_task,
     cas.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (cas
     WHERE (request->chg_qual[d.seq].reference_range_factor_id=cas.reference_range_factor_id)
      AND (request->chg_qual[d.seq].nomenclature_id=cas.nomenclature_id)
      AND (request->chg_qual[d.seq].service_resource_cd=cas.service_resource_cd))
    WITH nocounter
   ;end update
   IF ((curqual != request->chg_qual_cnt))
    CALL handle_errors("UPDATE","F","TABLE","CYTO_ALPHA_SECURITY")
    GO TO end_of_reports
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
 GO TO end_of_reports
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
