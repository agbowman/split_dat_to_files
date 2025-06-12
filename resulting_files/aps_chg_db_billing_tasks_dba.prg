CREATE PROGRAM aps_chg_db_billing_tasks:dba
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
 SET updt_cnt_err = 0
 SET error_cnt = 0
 SET nbr_of_tasks_to_add = size(request->add_qual,5)
 SET nbr_of_tasks_to_chg = size(request->chg_qual,5)
#start_of_script
 IF (nbr_of_tasks_to_add > 0)
  INSERT  FROM ap_task_assay_addl ataa,
    (dummyt d  WITH seq = value(nbr_of_tasks_to_add))
   SET ataa.task_assay_cd = request->add_qual[d.seq].task_assay_cd, ataa.date_of_service_cd = request
    ->add_qual[d.seq].date_of_service_cd, ataa.half_slide_ind = 0,
    ataa.stain_ind = 0, ataa.task_type_flag = 0, ataa.slide_origin_flag = 0,
    ataa.create_inventory_flag = 0, ataa.print_label_ind = 0, ataa.print_worklist_ind = 0,
    ataa.updt_dt_tm = cnvtdatetime(curdate,curtime), ataa.updt_cnt = 0, ataa.updt_id = reqinfo->
    updt_id,
    ataa.updt_task = reqinfo->updt_task, ataa.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (ataa
    WHERE (ataa.task_assay_cd=request->add_qual[d.seq].task_assay_cd))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != nbr_of_tasks_to_add)
   CALL handle_errors("INSERT","F","TABLE","AP_TASK_ASSAY_ADDL")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (nbr_of_tasks_to_chg > 0)
  SELECT INTO "nl:"
   ataa.task_assay_cd
   FROM ap_task_assay_addl ataa,
    (dummyt d  WITH seq = value(nbr_of_tasks_to_chg))
   PLAN (d)
    JOIN (ataa
    WHERE (ataa.task_assay_cd=request->chg_qual[d.seq].task_assay_cd))
   DETAIL
    IF ((ataa.updt_cnt != request->chg_qual[d.seq].updt_cnt))
     updt_cnt_err = 1
    ENDIF
   WITH forupdate(ataa)
  ;end select
  IF (curqual=0)
   CALL handle_errors("LOCK","F","TABLE","AP_TASK_ASSAY_ADDL")
   GO TO exit_script
  ENDIF
  IF (updt_cnt_err=1)
   CALL handle_errors("UPDATE COUNTS","F","TABLE","AP_TASK_ASSAY_ADDL")
   GO TO exit_script
  ENDIF
  UPDATE  FROM ap_task_assay_addl ataa,
    (dummyt d  WITH seq = value(nbr_of_tasks_to_chg))
   SET ataa.task_assay_cd = request->chg_qual[d.seq].task_assay_cd, ataa.date_of_service_cd = request
    ->chg_qual[d.seq].date_of_service_cd, ataa.half_slide_ind = 0,
    ataa.stain_ind = 0, ataa.task_type_flag = 0, ataa.slide_origin_flag = 0,
    ataa.create_inventory_flag = 0, ataa.print_label_ind = 0, ataa.print_worklist_ind = 0,
    ataa.updt_dt_tm = cnvtdatetime(curdate,curtime), ataa.updt_cnt = (ataa.updt_cnt+ 1), ataa.updt_id
     = reqinfo->updt_id,
    ataa.updt_task = reqinfo->updt_task, ataa.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (ataa
    WHERE (ataa.task_assay_cd=request->chg_qual[d.seq].task_assay_cd))
   WITH nocounter
  ;end update
  IF (curqual != nbr_of_tasks_to_chg)
   CALL handle_errors("UPDATE","F","TABLE","AP_TASK_ASSAY_ADDL")
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
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
