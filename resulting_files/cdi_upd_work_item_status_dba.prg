CREATE PROGRAM cdi_upd_work_item_status:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 cdi_work_item_id = f8
    1 in_process_ind = i2
    1 updt_cnt = i4
    1 override_ind = i2
    1 status_cd = f8
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 cdi_work_item_id = f8
   1 beg_effective_dt_tm = dq8
   1 clarify_reason_cd = f8
   1 comment_id = f8
   1 create_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 owner_prsnl_id = f8
   1 parent_entity_id = f8
   1 parent_entity_name = c30
   1 priority_cd = f8
   1 status_cd = f8
   1 updt_applctx = f8
   1 updt_cnt = i4
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 updt_task = i4
   1 category_cd = f8
   1 ordering_provider_id = f8
   1 sch_event_id = f8
 ) WITH protect
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE dinprocess = f8 WITH protect, constant(uar_get_code_by("MEANING",4002621,"INPROCESS"))
 DECLARE davailable = f8 WITH protect, constant(uar_get_code_by("MEANING",4002621,"AVAILABLE"))
 DECLARE dcomplete = f8 WITH protect, constant(uar_get_code_by("MEANING",4002621,"COMPLETE"))
 DECLARE dstarttime = f8 WITH protect, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH protect, noconstant(0.0)
 DECLARE sstatus = c1 WITH protect, noconstant("F")
 DECLARE sstatusreason = vc WITH protect, noconstant("Script Error")
 DECLARE lfreetextsize = i4 WITH protect, noconstant(0)
 DECLARE tempvar = i4 WITH protect, noconstant(0)
 DECLARE workitemstatus = f8 WITH protect, noconstant(0.0)
 IF ((request->in_process_ind=1))
  SET workitemstatus = dinprocess
 ELSE
  IF ((request->status_cd > 0))
   SET workitemstatus = request->status_cd
  ELSE
   SET workitemstatus = davailable
  ENDIF
 ENDIF
 CALL echo(sline)
 CALL echo("********** BEGIN CDI_UPD_WORK_ITEM_STATUS **********")
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 SELECT INTO "nl:"
  FROM cdi_work_item wi
  WHERE (wi.cdi_work_item_id=request->cdi_work_item_id)
   AND wi.cdi_work_item_id > 0
  DETAIL
   temp->cdi_work_item_id = wi.cdi_work_item_id, temp->beg_effective_dt_tm = wi.beg_effective_dt_tm,
   temp->clarify_reason_cd = wi.clarify_reason_cd,
   temp->comment_id = wi.comment_id, temp->create_dt_tm = wi.create_dt_tm, temp->end_effective_dt_tm
    = cnvtdatetime(curdate,curtime3),
   temp->owner_prsnl_id = wi.owner_prsnl_id, temp->parent_entity_id = wi.parent_entity_id, temp->
   parent_entity_name = wi.parent_entity_name,
   temp->priority_cd = wi.priority_cd, temp->status_cd = wi.status_cd, temp->updt_applctx = wi
   .updt_applctx,
   temp->updt_cnt = wi.updt_cnt, temp->updt_dt_tm = wi.updt_dt_tm, temp->updt_id = wi.updt_id,
   temp->updt_task = wi.updt_task, temp->category_cd = wi.category_cd, temp->ordering_provider_id =
   wi.ordering_provider_id,
   temp->sch_event_id = wi.sch_event_id
  WITH forupdate(wi)
 ;end select
 IF ((temp->owner_prsnl_id > 0)
  AND (temp->owner_prsnl_id != reqinfo->updt_id)
  AND (temp->status_cd=dinprocess)
  AND (request->override_ind=0))
  SET sstatus = "F"
  SET sstatusreason = "Work item locked by another user."
  GO TO exit_script
 ELSEIF ((request->updt_cnt != temp->updt_cnt))
  SET sstatus = "F"
  SET sstatusreason = "Work item data not latest."
  GO TO exit_script
 ENDIF
 CALL echo(sline)
 CALL echorecord(temp)
 CALL echo(sline)
 IF (curqual=1)
  UPDATE  FROM cdi_work_item wi
   SET wi.status_cd = workitemstatus, wi.owner_prsnl_id = reqinfo->updt_id, wi.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    wi.updt_task = reqinfo->updt_task, wi.updt_id = reqinfo->updt_id, wi.updt_applctx = reqinfo->
    updt_applctx,
    wi.updt_cnt = (wi.updt_cnt+ 1)
   WHERE (wi.cdi_work_item_id=request->cdi_work_item_id)
   WITH counter
  ;end update
  IF (curqual=1)
   INSERT  FROM cdi_work_item wi
    SET wi.cdi_work_item_id = seq(cdi_seq,nextval), wi.beg_effective_dt_tm = cnvtdatetime(temp->
      beg_effective_dt_tm), wi.clarify_reason_cd = temp->clarify_reason_cd,
     wi.comment_id = temp->comment_id, wi.create_dt_tm = cnvtdatetime(temp->create_dt_tm), wi
     .end_effective_dt_tm = cnvtdatetime(temp->end_effective_dt_tm),
     wi.owner_prsnl_id = temp->owner_prsnl_id, wi.parent_entity_id = temp->parent_entity_id, wi
     .parent_entity_name = temp->parent_entity_name,
     wi.prev_cdi_work_item_id = temp->cdi_work_item_id, wi.priority_cd = temp->priority_cd, wi
     .status_cd = temp->status_cd,
     wi.updt_applctx = temp->updt_applctx, wi.updt_cnt = temp->updt_cnt, wi.updt_dt_tm = cnvtdatetime
     (temp->updt_dt_tm),
     wi.updt_id = temp->updt_id, wi.updt_task = temp->updt_task, wi.category_cd = temp->category_cd,
     wi.ordering_provider_id = temp->ordering_provider_id, wi.sch_event_id = temp->sch_event_id
    WITH counter
   ;end insert
   IF (curqual=1)
    SET sstatus = "S"
    SET sstatusreason = ""
   ELSE
    SET sstatus = "F"
    SET sstatusreason = "Insert Failure - cdi_work_item"
   ENDIF
  ELSE
   SET sstatus = "F"
   SET sstatusreason = "Update Failure - cdi_work_item"
  ENDIF
 ELSE
  SET sstatus = "F"
  SET sstatusreason = "Lock Row Failure - cdi_work_item"
 ENDIF
 IF (workitemstatus=dcomplete)
  UPDATE  FROM cdi_pending_document pd
   SET pd.process_location_flag = 0
   WHERE (pd.cdi_pending_document_id=temp->parent_entity_id)
    AND pd.active_ind=1
   WITH counter
  ;end update
  IF (curqual=1)
   SET sstatus = "S"
   SET sstatusreason = ""
  ELSE
   SET sstatus = "F"
   SET sstatusreason = "Update Failure - cdi_pending_document"
  ENDIF
 ENDIF
#exit_script
 IF (sstatus="S")
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SET reply->status_data.status = sstatus
 SET reply->status_data.subeventstatus[1].operationstatus = sstatus
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_UPD_WORK_ITEM"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = sstatusreason
 FREE RECORD temp
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 11/11/2010")
 SET modify = nopredeclare
 CALL echo(sline)
 CALL echo("********** END CDI_UPD_WORK_ITEM_STATUS **********")
 CALL echo(sline)
END GO
