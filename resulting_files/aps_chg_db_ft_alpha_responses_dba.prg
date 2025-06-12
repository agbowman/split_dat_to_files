CREATE PROGRAM aps_chg_db_ft_alpha_responses:dba
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
    cas.followup_tracking_type_cd = request->add_qual[d.seq].tracking_type_cd, cas
    .followup_initial_interval =
    IF ((request->add_qual[d.seq].init_null_ind=1)) null
    ELSE request->add_qual[d.seq].initial_interval
    ENDIF
    , cas.followup_first_interval =
    IF ((request->add_qual[d.seq].first_null_ind=1)) null
    ELSE request->add_qual[d.seq].first_interval
    ENDIF
    ,
    cas.followup_final_interval =
    IF ((request->add_qual[d.seq].final_null_ind=1)) null
    ELSE request->add_qual[d.seq].final_interval
    ENDIF
    , cas.followup_termination_interval =
    IF ((request->add_qual[d.seq].term_null_ind=1)) null
    ELSE request->add_qual[d.seq].termination_interval
    ENDIF
    , cas.updt_cnt = 0,
    cas.updt_dt_tm = cnvtdatetime(curdate,curtime), cas.updt_id = reqinfo->updt_id, cas.updt_task =
    reqinfo->updt_task,
    cas.updt_applctx = reqinfo->updt_applctx, cas.definition_ind = 2
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
    cas.definition_ind = 2, cas.updt_cnt = request->del_qual[d.seq].updt_cnt
   PLAN (d)
    JOIN (cas
    WHERE (cas.reference_range_factor_id=request->del_qual[d.seq].reference_range_factor_id)
     AND (cas.nomenclature_id=request->del_qual[d.seq].nomenclature_id)
     AND (cas.service_resource_cd=request->del_qual[d.seq].service_resource_cd)
     AND cas.definition_ind=2
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
     AND ((cas.definition_ind+ 0) IN (0, 1))
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
    SET cas.definition_ind = 1, cas.followup_tracking_type_cd = 0.0, cas.followup_initial_interval =
     null,
     cas.followup_first_interval = null, cas.followup_final_interval = null, cas
     .followup_termination_interval = null,
     cas.updt_cnt = (cas.updt_cnt+ 1), cas.updt_dt_tm = cnvtdatetime(curdate,curtime), cas.updt_id =
     reqinfo->updt_id,
     cas.updt_task = reqinfo->updt_task, cas.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (cas
     WHERE (cas.reference_range_factor_id=request->del_qual[d.seq].reference_range_factor_id)
      AND (cas.nomenclature_id=request->del_qual[d.seq].nomenclature_id)
      AND (cas.service_resource_cd=request->del_qual[d.seq].service_resource_cd)
      AND ((cas.definition_ind+ 0) IN (0, 1))
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
    count1 = (count1+ 1)
   WITH forupdate(cas)
  ;end select
  IF (((curqual=0) OR ((count1 != request->chg_qual_cnt))) )
   CALL handle_errors("SELECT","F","TABLE","CYTO_ALPHA_SECURITY")
   GO TO exit_script
  ELSE
   UPDATE  FROM cyto_alpha_security cas,
     (dummyt d  WITH seq = value(request->chg_qual_cnt))
    SET cas.nomenclature_id = request->chg_qual[d.seq].nomenclature_id, cas.reference_range_factor_id
      = request->chg_qual[d.seq].reference_range_factor_id, cas.service_resource_cd = request->
     chg_qual[d.seq].service_resource_cd,
     cas.followup_tracking_type_cd = request->chg_qual[d.seq].tracking_type_cd, cas
     .followup_initial_interval =
     IF ((request->chg_qual[d.seq].init_null_ind=1)) null
     ELSE request->chg_qual[d.seq].initial_interval
     ENDIF
     , cas.followup_first_interval =
     IF ((request->chg_qual[d.seq].first_null_ind=1)) null
     ELSE request->chg_qual[d.seq].first_interval
     ENDIF
     ,
     cas.followup_final_interval =
     IF ((request->chg_qual[d.seq].final_null_ind=1)) null
     ELSE request->chg_qual[d.seq].final_interval
     ENDIF
     , cas.followup_termination_interval =
     IF ((request->chg_qual[d.seq].term_null_ind=1)) null
     ELSE request->chg_qual[d.seq].termination_interval
     ENDIF
     , cas.definition_ind =
     IF (cas.definition_ind=0) 0
     ELSEIF (cas.definition_ind=2) 2
     ELSE 0
     ENDIF
     ,
     cas.updt_cnt = (request->chg_qual[d.seq].updt_cnt+ 1), cas.updt_dt_tm = cnvtdatetime(curdate,
      curtime), cas.updt_id = reqinfo->updt_id,
     cas.updt_task = reqinfo->updt_task, cas.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (cas
     WHERE (request->chg_qual[d.seq].reference_range_factor_id=cas.reference_range_factor_id)
      AND (request->chg_qual[d.seq].nomenclature_id=cas.nomenclature_id)
      AND (request->chg_qual[d.seq].service_resource_cd=cas.service_resource_cd))
    WITH nocounter
   ;end update
   IF ((curqual != request->chg_qual_cnt))
    CALL handle_errors("UPDATE","F","TABLE","CYTO_ALPHA_SECURITY")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
 GO TO end_of_script
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
#end_of_script
END GO
