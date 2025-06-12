CREATE PROGRAM aps_chg_outstanding_tasks:dba
 RECORD temp(
   1 order_qual[*]
     2 id = f8
     2 action_flag = i2
 )
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
 SET nbr_tasks = cnvtint(size(request->qual,5))
 SET nbr_items = 0
 SET updt_cnts_array[1000] = 0
 DECLARE order_id_array[1000] = f8 WITH protect, noconstant(0.0)
 SET failed = "F"
 DECLARE status_verified_cd = f8 WITH protect, noconstant(0.0)
 SET stat = alterlist(temp->order_qual,nbr_tasks)
 DECLARE lindex = i4 WITH protect, noconstant(0)
 DECLARE lstart = i4 WITH protect, constant(1)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 DECLARE action_verify = i2 WITH protect, constant(0)
 DECLARE action_transfer = i2 WITH protect, constant(1)
 IF ((request->action_flag=action_verify))
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=1305
    AND cv.cdf_meaning="VERIFIED"
   DETAIL
    status_verified_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (curqual=0)
   GO TO status_failed
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  pt.processing_task_id
  FROM processing_task pt,
   (dummyt d  WITH seq = value(nbr_tasks))
  PLAN (d)
   JOIN (pt
   WHERE (pt.processing_task_id=request->qual[d.seq].processing_task_id))
  HEAD REPORT
   nbr_items = 0
  DETAIL
   nbr_items = (nbr_items+ 1), order_id_array[nbr_items] = pt.order_id, updt_cnts_array[nbr_items] =
   pt.updt_cnt
   IF (pt.create_inventory_flag=4)
    temp->order_qual[nbr_items].id = pt.case_specimen_id, temp->order_qual[nbr_items].action_flag = 5
   ELSE
    temp->order_qual[nbr_items].id = pt.processing_task_id, temp->order_qual[nbr_items].action_flag
     = 7
   ENDIF
  WITH nocounter, forupdate(pt)
 ;end select
 IF (nbr_items != nbr_tasks)
  GO TO lock_failed
 ENDIF
 FOR (nbr_items = 1 TO nbr_tasks)
   IF ((request->qual[nbr_items].updt_cnt != updt_cnts_array[nbr_items]))
    IF ((request->qual[nbr_items].order_id=order_id_array[nbr_items]))
     GO TO changed_failed
    ENDIF
   ENDIF
 ENDFOR
 UPDATE  FROM processing_task pt,
   (dummyt d  WITH seq = value(nbr_tasks))
  SET pt.status_cd =
   IF ((request->action_flag=action_verify)) status_verified_cd
   ELSE pt.status_cd
   ENDIF
   , pt.service_resource_cd =
   IF ((request->action_flag=action_transfer)) request->transfer_to_service_resource_cd
   ELSE pt.service_resource_cd
   ENDIF
   , pt.status_prsnl_id = reqinfo->updt_id,
   pt.status_dt_tm = cnvtdatetime(curdate,curtime3), pt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pt.updt_id = reqinfo->updt_id,
   pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt
   .updt_cnt+ 1)
  PLAN (d)
   JOIN (pt
   WHERE (pt.processing_task_id=request->qual[d.seq].processing_task_id))
  WITH nocounter
 ;end update
 IF (curqual != nbr_tasks)
  GO TO update_failed
 ENDIF
 IF ((request->action_flag=action_verify))
  DELETE  FROM task_instrmt_protcl_r tipr
   WHERE expand(lindex,lstart,size(request->qual,5),tipr.processing_task_id,request->qual[lindex].
    processing_task_id)
   WITH nocounter
  ;end delete
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   GO TO delete_task_instrmt_protcl_r_failed
  ENDIF
  INSERT  FROM ap_ops_exception aoe,
    (dummyt d  WITH seq = value(nbr_tasks))
   SET aoe.parent_id = temp->order_qual[d.seq].id, aoe.action_flag = temp->order_qual[d.seq].
    action_flag, aoe.active_ind = 1,
    aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task =
    reqinfo->updt_task,
    aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
   PLAN (d)
    JOIN (aoe
    WHERE (temp->order_qual[d.seq].id=aoe.parent_id)
     AND (aoe.action_flag=temp->order_qual[d.seq].action_flag))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != nbr_tasks)
   GO TO insert_ops_exception_failed
  ENDIF
  IF (curutc=1)
   INSERT  FROM ap_ops_exception_detail aoed,
     (dummyt d  WITH seq = value(nbr_tasks))
    SET aoed.action_flag = temp->order_qual[d.seq].action_flag, aoed.field_meaning = "TIME_ZONE",
     aoed.field_nbr = curtimezoneapp,
     aoed.parent_id = temp->order_qual[d.seq].id, aoed.sequence = 1, aoed.updt_applctx = reqinfo->
     updt_applctx,
     aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
     updt_id,
     aoed.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (aoed
     WHERE (temp->order_qual[d.seq].id=aoed.parent_id)
      AND (aoed.action_flag=temp->order_qual[d.seq].action_flag))
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
   IF (curqual != nbr_tasks)
    GO TO insert_ops_exception_detail_failed
   ENDIF
  ENDIF
 ENDIF
 GO TO exit_script
#status_failed
 SET reply->status_data.subeventstatus[1].operationname = "STATUS"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 SET failed = "T"
 GO TO exit_script
#lock_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#changed_failed
 SET reply->status_data.subeventstatus[1].operationname = "CHANGED"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#update_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#insert_ops_exception_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION"
 SET failed = "T"
 GO TO exit_script
#insert_ops_exception_detail_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION_DETAIL"
 SET failed = "T"
 GO TO exit_script
#delete_task_instrmt_protcl_r_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TASK_INSTRMT_PROTCL_R"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
 SET failed = "T"
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
