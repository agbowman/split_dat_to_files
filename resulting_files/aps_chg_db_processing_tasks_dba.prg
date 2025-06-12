CREATE PROGRAM aps_chg_db_processing_tasks:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET error_cnt = 0
 SET proc_task_cnt = 0
 SET cur_updt_cnt[500] = 0
 SET nbr_of_tasks = size(request->qual,5)
 SET nbr_of_inactivations = size(request->inactivate,5)
 FOR (x = 1 TO nbr_of_tasks)
  IF ((request->qual[x].action="C"))
   SELECT INTO "nl:"
    ataa.task_assay_cd
    FROM ap_task_assay_addl ataa
    WHERE (ataa.task_assay_cd=request->qual[x].task_assay_cd)
    DETAIL
     cur_updt_cnt[x] = ataa.updt_cnt
    WITH forupdate(ataa)
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","F","TABLE","AP_TASK_ASSAY_ADDL")
    GO TO exit_script
   ENDIF
   IF ((request->qual[x].updt_cnt != cur_updt_cnt[x]))
    CALL handle_errors("LOCK","F","TABLE","AP_TASK_ASSAY_ADDL")
    GO TO exit_script
   ENDIF
   SET cur_updt_cnt += 1
   UPDATE  FROM ap_task_assay_addl ataa
    SET ataa.create_inventory_flag = request->qual[x].create_inventory_flag, ataa.task_type_flag =
     request->qual[x].task_type_flag, ataa.slide_origin_flag = request->qual[x].slide_origin_flag,
     ataa.stain_ind = request->qual[x].stain_ind, ataa.half_slide_ind = request->qual[x].
     half_slide_ind, ataa.print_label_ind = request->qual[x].print_label_ind,
     ataa.autoverify_workflow_cd = request->qual[x].autoverify_workflow_cd, ataa.task_assay_type_cd
      = request->qual[x].task_assay_type_cd, ataa.updt_dt_tm = cnvtdatetime(curdate,curtime),
     ataa.updt_cnt = cur_updt_cnt, ataa.updt_id = reqinfo->updt_id, ataa.updt_task = reqinfo->
     updt_task,
     ataa.updt_applctx = reqinfo->updt_applctx
    WHERE (ataa.task_assay_cd=request->qual[x].task_assay_cd)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UPDATE","F","TABLE","AP_TASK_ASSAY_ADDL")
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->qual[x].action="A"))
   INSERT  FROM ap_task_assay_addl ataa
    SET ataa.task_assay_cd = request->qual[x].task_assay_cd, ataa.create_inventory_flag = request->
     qual[x].create_inventory_flag, ataa.task_type_flag = request->qual[x].task_type_flag,
     ataa.slide_origin_flag = request->qual[x].slide_origin_flag, ataa.stain_ind = request->qual[x].
     stain_ind, ataa.half_slide_ind = request->qual[x].half_slide_ind,
     ataa.print_label_ind = request->qual[x].print_label_ind, ataa.autoverify_workflow_cd = request->
     qual[x].autoverify_workflow_cd, ataa.task_assay_type_cd = request->qual[x].task_assay_type_cd,
     ataa.updt_dt_tm = cnvtdatetime(curdate,curtime), ataa.updt_id = reqinfo->updt_id, ataa.updt_task
      = reqinfo->updt_task,
     ataa.updt_applctx = reqinfo->updt_applctx, ataa.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL handle_errors("ADD","F","TABLE","AP_TASK_ASSAY_ADDL")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
 IF (nbr_of_inactivations > 0)
  UPDATE  FROM ap_task_assay_addl ataa,
    (dummyt d  WITH seq = value(nbr_of_inactivations))
   SET ataa.task_assay_type_cd = 0
   PLAN (d)
    JOIN (ataa
    WHERE (ataa.task_assay_type_cd=request->inactivate[d.seq].code_value))
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","AP_TASK_ASSAY_ADDL")
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
END GO
