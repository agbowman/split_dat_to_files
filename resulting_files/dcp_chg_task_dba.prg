CREATE PROGRAM dcp_chg_task:dba
 DECLARE program_version = vc WITH private, constant("033")
 RECORD previous_task_info(
   1 qual[*]
     2 task_id = f8
     2 order_id = f8
     2 status = i1
     2 updt_cnt = i4
     2 updt_id = f8
     2 task_status_cd = f8
     2 task_dt_tm = dq8
     2 task_status_reason_cd = f8
     2 event_id = f8
     2 reschedule_ind = i2
     2 reschedule_reason_cd = f8
     2 task_class_cd = f8
     2 med_order_type_cd = f8
     2 child_order_status_cd = f8
     2 parent_order_status_cd = f8
     2 parent_task_status_cd = f8
     2 encntr_id = f8
     2 task_encntr_id = f8
     2 task_tz = i4
     2 charted_by_agent_cd = f8
     2 charted_by_agent_identifier = vc
     2 charting_context_reference = vc
     2 scheduled_dt_tm = dq8
     2 result_set_id = f8
     2 performed_prsnl_id = f8
     2 container_id = f8
     2 task_type_cd = f8
     2 task_type_meaning = vc
 )
 DECLARE iv = f8 WITH constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE prn = f8 WITH constant(uar_get_code_by("MEANING",6025,"PRN"))
 DECLARE cont = f8 WITH constant(uar_get_code_by("MEANING",6025,"CONT"))
 DECLARE adhoc = f8 WITH constant(uar_get_code_by("MEANING",6025,"ADHOC"))
 DECLARE nsch = f8 WITH constant(uar_get_code_by("MEANING",6025,"NSCH"))
 DECLARE pending = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE inprocess = f8 WITH constant(uar_get_code_by("MEANING",79,"INPROCESS"))
 DECLARE complete = f8 WITH constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE deleted = f8 WITH constant(uar_get_code_by("MEANING",79,"DELETED"))
 DECLARE validation = f8 WITH constant(uar_get_code_by("MEANING",79,"VALIDATION"))
 DECLARE deleteorder = f8 WITH constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE voidedwrslt = f8 WITH constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE response = f8 WITH constant(uar_get_code_by("MEANING",6026,"RESPONSE")), protect
 DECLARE medrecon = f8 WITH constant(uar_get_code_by("MEANING",6026,"MEDRECON")), protect
 DECLARE infusion_billing_type_meaning = vc WITH constant("INFUSEBILL"), protect
 DECLARE iv_end_bag_type_meaning = vc WITH constant("IVENDBAG"), protect
 DECLARE chartnotdone = f8 WITH constant(uar_get_code_by("MEANING",14024,"DCP_NOTDONE"))
 DECLARE taskcompletionservice = f8 WITH constant(uar_get_code_by("MEANING",255090,"TASKCOMPSERV"))
 DECLARE script_status = c1 WITH noconstant("F"), protect
 FREE RECORD validated_request
 RECORD validated_request(
   1 mod_list[*]
     2 clear_task_status_reason_ind = i2
 ) WITH protect
 DECLARE setvalidatedrequest(null) = null WITH protected
 CALL setvalidatedrequest(null)
 IF (((iv <= 0) OR (((prn <= 0) OR (((cont <= 0) OR (((adhoc <= 0) OR (((nsch <= 0) OR (((pending <=
 0) OR (((inprocess <= 0) OR (((complete <= 0) OR (((deleted <= 0) OR (((validation <= 0) OR (((
 deleteorder <= 0) OR (((voidedwrslt <= 0) OR (((response <= 0) OR (taskcompletionservice <= 0)) ))
 )) )) )) )) )) )) )) )) )) )) )) )
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_CODE_BY"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  GO TO exit_script
 ENDIF
 SUBROUTINE setvalidatedrequest(null)
   DECLARE mod_list_index = i4 WITH private, noconstant(1)
   DECLARE mod_list_count = i4 WITH private, constant(size(request->mod_list,5))
   SET stat = alterlist(validated_request->mod_list,mod_list_count)
   FOR (mod_list_index = 1 TO mod_list_count)
     SET validated_request->mod_list[mod_list_index].clear_task_status_reason_ind = validate(request
      ->mod_list[mod_list_index].clear_task_status_reason_ind,0)
   ENDFOR
   CALL echorecord(validated_request)
 END ;Subroutine
 DECLARE failures = i4 WITH noconstant(0)
 DECLARE nbr_to_chg = i4 WITH constant(size(request->mod_list,5))
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET stat = alterlist(previous_task_info->qual,nbr_to_chg)
 DECLARE track_processed_tasks = i2 WITH protect, constant(validate(reply->processed_tasks))
 IF (track_processed_tasks)
  SET stat = alterlist(reply->processed_tasks,nbr_to_chg)
 ENDIF
 DECLARE honor_zero_updt_cnt = i2 WITH protect, noconstant(0)
 IF (validate(request->honor_zero_updt_cnt_ind))
  SET honor_zero_updt_cnt = request->honor_zero_updt_cnt_ind
 ENDIF
 IF (nbr_to_chg > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbr_to_chg)),
    task_activity ta_lock
   PLAN (d)
    JOIN (ta_lock
    WHERE (ta_lock.task_id=request->mod_list[d.seq].task_id)
     AND ta_lock.active_ind=1)
   WITH nocounter, forupdatewait(ta_lock)
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(nbr_to_chg)),
    task_activity ta,
    orders o,
    orders o2
   PLAN (d)
    JOIN (ta
    WHERE (ta.task_id=request->mod_list[d.seq].task_id)
     AND ta.active_ind=1)
    JOIN (o
    WHERE o.order_id=ta.order_id)
    JOIN (o2
    WHERE o2.order_id=o.template_order_id)
   DETAIL
    IF ((((ta.updt_cnt=request->mod_list[d.seq].updt_cnt)) OR ((request->mod_list[d.seq].updt_cnt=0)
     AND  NOT (honor_zero_updt_cnt))) )
     previous_task_info->qual[d.seq].status = 1
    ELSEIF (track_processed_tasks)
     previous_task_info->qual[d.seq].status = 0, reply->processed_tasks[d.seq].error_message =
     "Modification failed because the given task information is out of date."
    ENDIF
    IF (ta.task_status_cd=complete
     AND (request->mod_list[d.seq].task_status_cd=complete)
     AND ta.charted_by_agent_cd != taskcompletionservice
     AND (request->mod_list[d.seq].charted_by_agent_cd=taskcompletionservice))
     previous_task_info->qual[d.seq].status = 0
     IF (track_processed_tasks)
      reply->processed_tasks[d.seq].error_message =
      "Task cannot be completed by the task completion service because it has already been charted."
     ENDIF
    ENDIF
    IF (track_processed_tasks)
     reply->processed_tasks[d.seq].task_id = ta.task_id
     IF ((previous_task_info->qual[d.seq].status=1))
      reply->processed_tasks[d.seq].updt_cnt = (ta.updt_cnt+ 1), reply->processed_tasks[d.seq].
      task_status_cd = request->mod_list[d.seq].task_status_cd
     ELSE
      reply->processed_tasks[d.seq].updt_cnt = ta.updt_cnt, reply->processed_tasks[d.seq].
      task_status_cd = ta.task_status_cd
     ENDIF
    ENDIF
    previous_task_info->qual[d.seq].task_id = ta.task_id, previous_task_info->qual[d.seq].order_id =
    ta.order_id, previous_task_info->qual[d.seq].updt_cnt = ta.updt_cnt,
    previous_task_info->qual[d.seq].updt_id = ta.updt_id, previous_task_info->qual[d.seq].
    task_status_cd = ta.task_status_cd, previous_task_info->qual[d.seq].task_dt_tm = cnvtdatetime(ta
     .task_dt_tm),
    previous_task_info->qual[d.seq].task_status_reason_cd = ta.task_status_reason_cd,
    previous_task_info->qual[d.seq].event_id = ta.event_id, previous_task_info->qual[d.seq].
    reschedule_ind = ta.reschedule_ind,
    previous_task_info->qual[d.seq].task_class_cd = ta.task_class_cd, previous_task_info->qual[d.seq]
    .med_order_type_cd = ta.med_order_type_cd, previous_task_info->qual[d.seq].reschedule_reason_cd
     = ta.reschedule_reason_cd,
    previous_task_info->qual[d.seq].parent_task_status_cd = 0, previous_task_info->qual[d.seq].
    charted_by_agent_cd = ta.charted_by_agent_cd, previous_task_info->qual[d.seq].
    charted_by_agent_identifier = ta.charted_by_agent_identifier,
    previous_task_info->qual[d.seq].charting_context_reference = ta.charting_context_reference,
    previous_task_info->qual[d.seq].scheduled_dt_tm = cnvtdatetime(ta.scheduled_dt_tm),
    previous_task_info->qual[d.seq].result_set_id = ta.result_set_id,
    previous_task_info->qual[d.seq].performed_prsnl_id = ta.performed_prsnl_id, previous_task_info->
    qual[d.seq].container_id = ta.container_id, previous_task_info->qual[d.seq].task_type_cd = ta
    .task_type_cd,
    previous_task_info->qual[d.seq].child_order_status_cd = o.order_status_cd, previous_task_info->
    qual[d.seq].parent_order_status_cd = o2.order_status_cd, previous_task_info->qual[d.seq].
    encntr_id = o.encntr_id,
    previous_task_info->qual[d.seq].task_encntr_id = ta.encntr_id, previous_task_info->qual[d.seq].
    task_type_meaning = uar_get_code_meaning(ta.task_type_cd)
   WITH nocounter
  ;end select
 ENDIF
 IF (curutc=1)
  RECORD gettzreq(
    1 encntrs[*]
      2 encntr_id = f8
      2 transaction_dt_tm = dq8
    1 facilities[*]
      2 loc_facility_cd = f8
  )
  RECORD gettzrep(
    1 encntrs_qual_cnt = i4
    1 encntrs[*]
      2 encntr_id = f8
      2 time_zone_indx = i4
      2 time_zone = vc
      2 transaction_dt_tm = q8
      2 check = i2
      2 status = i2
      2 loc_fac_cd = f8
    1 facilities_qual_cnt = i4
    1 facilities[*]
      2 loc_facility_cd = f8
      2 time_zone_indx = i4
      2 time_zone = vc
      2 status = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  DECLARE task_count = i4 WITH constant(size(previous_task_info->qual,5))
  DECLARE enc_count = i4 WITH noconstant(0)
  SET stat = alterlist(gettzreq->encntrs,task_count)
  FOR (i = 1 TO task_count)
    IF ((previous_task_info->qual[i].encntr_id > 0.0))
     SET enc_count += 1
     SET gettzreq->encntrs[enc_count].encntr_id = previous_task_info->qual[i].encntr_id
    ELSEIF ((previous_task_info->qual[i].task_encntr_id > 0.0))
     SET enc_count += 1
     SET gettzreq->encntrs[enc_count].encntr_id = previous_task_info->qual[i].task_encntr_id
    ENDIF
  ENDFOR
  SET stat = alterlist(gettzreq->encntrs,enc_count)
  IF (enc_count > 0)
   EXECUTE pm_get_encntr_loc_tz  WITH replace(request,gettzreq), replace(reply,gettzrep)
  ENDIF
  SET enc_count = 0
  FOR (i = 1 TO task_count)
    IF ((((previous_task_info->qual[i].encntr_id > 0.0)) OR ((previous_task_info->qual[i].
    task_encntr_id > 0.0))) )
     SET enc_count += 1
     IF ((gettzrep->encntrs[enc_count].time_zone_indx > 0))
      SET previous_task_info->qual[i].task_tz = gettzrep->encntrs[enc_count].time_zone_indx
     ELSE
      SET previous_task_info->qual[i].task_tz = curtimezoneapp
     ENDIF
    ELSE
     SET previous_task_info->qual[i].task_tz = curtimezoneapp
    ENDIF
  ENDFOR
  FREE RECORD gettzreq
  FREE RECORD gettzrep
 ENDIF
 IF (nbr_to_chg > 0)
  SELECT INTO "nl:"
   ta2.task_status_cd
   FROM (dummyt d  WITH seq = value(nbr_to_chg)),
    task_activity ta,
    task_reltn tr,
    task_activity ta2
   PLAN (d)
    JOIN (ta
    WHERE (ta.task_id=request->mod_list[d.seq].task_id)
     AND ta.task_type_cd=response
     AND ta.active_ind=1)
    JOIN (tr
    WHERE tr.task_id=ta.task_id)
    JOIN (ta2
    WHERE ta2.task_id=tr.prereq_task_id)
   DETAIL
    previous_task_info->qual[d.seq].parent_task_status_cd = ta2.task_status_cd
   WITH nocounter
  ;end select
  INSERT  FROM task_action tac,
    (dummyt d  WITH seq = value(nbr_to_chg))
   SET tac.seq = 1, tac.task_id = request->mod_list[d.seq].task_id, tac.task_action_seq = seq(
     carenet_seq,nextval),
    tac.task_status_cd =
    IF ((request->mod_list[d.seq].task_status_cd > 0.0)) previous_task_info->qual[d.seq].
     task_status_cd
    ELSE null
    ENDIF
    , tac.task_dt_tm = cnvtdatetime(previous_task_info->qual[d.seq].task_dt_tm), tac.task_tz =
    IF ((previous_task_info->qual[d.seq].task_dt_tm != 0)) previous_task_info->qual[d.seq].task_tz
    ELSE 0
    ENDIF
    ,
    tac.task_status_reason_cd =
    IF ((request->mod_list[d.seq].task_status_reason_cd > 0.0)
     AND (validated_request->mod_list[d.seq].clear_task_status_reason_ind=0)) previous_task_info->
     qual[d.seq].task_status_reason_cd
    ELSE null
    ENDIF
    , tac.reschedule_reason_cd =
    IF ((request->mod_list[d.seq].reschedule_reason_cd > 0.0)) previous_task_info->qual[d.seq].
     reschedule_reason_cd
    ELSE null
    ENDIF
    , tac.scheduled_dt_tm = cnvtdatetime(previous_task_info->qual[d.seq].scheduled_dt_tm),
    tac.updt_dt_tm = cnvtdatetime(sysdate), tac.updt_id =
    IF ((request->mod_list[d.seq].task_status_cd=complete)
     AND (previous_task_info->qual[d.seq].task_status_cd != complete)) request->mod_list[d.seq].
     performed_prsnl_id
    ELSE reqinfo->updt_id
    ENDIF
    , tac.updt_task = reqinfo->updt_task,
    tac.updt_cnt = 0, tac.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (previous_task_info->qual[d.seq].status=1))
    JOIN (tac)
   WITH nocounter, status(previous_task_info->qual[d.seq].status)
  ;end insert
  UPDATE  FROM task_activity ta,
    (dummyt d  WITH seq = value(nbr_to_chg))
   SET ta.task_status_cd =
    IF ((request->mod_list[d.seq].task_status_cd=pending)
     AND (previous_task_info->qual[d.seq].task_type_cd != medrecon)
     AND (previous_task_info->qual[d.seq].task_type_meaning != infusion_billing_type_meaning)
     AND (previous_task_info->qual[d.seq].task_type_meaning != iv_end_bag_type_meaning)
     AND (((previous_task_info->qual[d.seq].task_status_cd=complete)) OR ((((previous_task_info->
    qual[d.seq].task_status_cd=inprocess)) OR ((previous_task_info->qual[d.seq].task_status_cd=
    validation))) ))
     AND (((previous_task_info->qual[d.seq].task_class_cd=prn)) OR ((((previous_task_info->qual[d.seq
    ].task_class_cd=nsch)) OR ((((previous_task_info->qual[d.seq].task_class_cd=cont)) OR ((((
    previous_task_info->qual[d.seq].task_class_cd=adhoc)) OR ((((previous_task_info->qual[d.seq].
    med_order_type_cd=iv)) OR ((((previous_task_info->qual[d.seq].child_order_status_cd=deleteorder))
     OR ((((previous_task_info->qual[d.seq].child_order_status_cd=voidedwrslt)) OR ((((
    previous_task_info->qual[d.seq].parent_order_status_cd=voidedwrslt)) OR ((previous_task_info->
    qual[d.seq].parent_task_status_cd IN (deleted, inprocess, pending)))) )) )) )) )) )) )) )) )
     deleted
    ELSEIF ((request->mod_list[d.seq].task_status_cd > 0.0)) request->mod_list[d.seq].task_status_cd
    ELSE previous_task_info->qual[d.seq].task_status_cd
    ENDIF
    , ta.task_dt_tm =
    IF ((previous_task_info->qual[d.seq].task_class_cd=nsch)
     AND (request->mod_list[d.seq].task_status_cd=pending)) cnvtdatetime(sysdate)
    ELSEIF ((previous_task_info->qual[d.seq].task_class_cd=nsch)
     AND (request->mod_list[d.seq].entered_dt_tm != 0)
     AND (((request->mod_list[d.seq].task_status_cd=complete)) OR ((((request->mod_list[d.seq].
    task_status_cd=inprocess)) OR ((request->mod_list[d.seq].task_status_cd=validation))) )) )
     cnvtdatetime(request->mod_list[d.seq].entered_dt_tm)
    ELSEIF ((request->mod_list[d.seq].task_dt_tm != 0)) cnvtdatetime(request->mod_list[d.seq].
      task_dt_tm)
    ELSEIF ((((request->mod_list[d.seq].task_status_cd=complete)) OR ((((request->mod_list[d.seq].
    task_status_cd=inprocess)) OR ((request->mod_list[d.seq].task_status_cd=validation))) ))
     AND (request->mod_list[d.seq].entered_dt_tm != 0)
     AND (((previous_task_info->qual[d.seq].task_class_cd=prn)) OR ((((previous_task_info->qual[d.seq
    ].task_class_cd=cont)) OR ((previous_task_info->qual[d.seq].med_order_type_cd=iv))) )) )
     cnvtdatetime(request->mod_list[d.seq].entered_dt_tm)
    ELSE cnvtdatetime(previous_task_info->qual[d.seq].task_dt_tm)
    ENDIF
    , ta.task_tz =
    IF ((previous_task_info->qual[d.seq].task_class_cd=nsch)
     AND (request->mod_list[d.seq].task_status_cd=pending)) previous_task_info->qual[d.seq].task_tz
    ELSEIF ((previous_task_info->qual[d.seq].task_class_cd=nsch)
     AND (request->mod_list[d.seq].entered_dt_tm != 0)
     AND (((request->mod_list[d.seq].task_status_cd=complete)) OR ((((request->mod_list[d.seq].
    task_status_cd=inprocess)) OR ((request->mod_list[d.seq].task_status_cd=validation))) )) )
     previous_task_info->qual[d.seq].task_tz
    ELSEIF ((request->mod_list[d.seq].task_dt_tm != 0)) previous_task_info->qual[d.seq].task_tz
    ELSEIF ((((request->mod_list[d.seq].task_status_cd=complete)) OR ((((request->mod_list[d.seq].
    task_status_cd=inprocess)) OR ((request->mod_list[d.seq].task_status_cd=validation))) ))
     AND (request->mod_list[d.seq].entered_dt_tm != 0)
     AND (((previous_task_info->qual[d.seq].task_class_cd=prn)) OR ((((previous_task_info->qual[d.seq
    ].task_class_cd=cont)) OR ((previous_task_info->qual[d.seq].med_order_type_cd=iv))) )) )
     previous_task_info->qual[d.seq].task_tz
    ELSE
     IF ((previous_task_info->qual[d.seq].task_dt_tm != 0)) previous_task_info->qual[d.seq].task_tz
     ELSE 0
     ENDIF
    ENDIF
    ,
    ta.task_status_reason_cd =
    IF ((((validated_request->mod_list[d.seq].clear_task_status_reason_ind=1)) OR ((request->
    mod_list[d.seq].task_status_reason_cd > 0.0))) ) request->mod_list[d.seq].task_status_reason_cd
    ELSE previous_task_info->qual[d.seq].task_status_reason_cd
    ENDIF
    , ta.event_id =
    IF ((request->mod_list[d.seq].event_id > 0.0)) request->mod_list[d.seq].event_id
    ELSE previous_task_info->qual[d.seq].event_id
    ENDIF
    , ta.reschedule_ind =
    IF ((request->mod_list[d.seq].reschedule_ind > 0)) request->mod_list[d.seq].reschedule_ind
    ELSE previous_task_info->qual[d.seq].reschedule_ind
    ENDIF
    ,
    ta.reschedule_reason_cd =
    IF ((request->mod_list[d.seq].reschedule_reason_cd > 0.0)) request->mod_list[d.seq].
     reschedule_reason_cd
    ELSE previous_task_info->qual[d.seq].reschedule_reason_cd
    ENDIF
    , ta.updt_dt_tm = cnvtdatetime(sysdate), ta.updt_id = reqinfo->updt_id,
    ta.updt_task = reqinfo->updt_task, ta.updt_cnt = (ta.updt_cnt+ 1), ta.updt_applctx = reqinfo->
    updt_applctx,
    ta.charted_by_agent_cd =
    IF ((((request->mod_list[d.seq].task_status_cd=validation)) OR ((((request->mod_list[d.seq].
    task_status_cd=inprocess)) OR ((request->mod_list[d.seq].task_status_cd=complete)
     AND (request->mod_list[d.seq].task_status_reason_cd != chartnotdone))) )) ) request->mod_list[d
     .seq].charted_by_agent_cd
    ELSEIF ((((request->mod_list[d.seq].task_status_cd=pending)) OR ((request->mod_list[d.seq].
    task_status_cd=complete)
     AND (request->mod_list[d.seq].task_status_reason_cd=chartnotdone))) ) 0
    ELSE previous_task_info->qual[d.seq].charted_by_agent_cd
    ENDIF
    , ta.charted_by_agent_identifier =
    IF ((((request->mod_list[d.seq].task_status_cd=validation)) OR ((((request->mod_list[d.seq].
    task_status_cd=inprocess)) OR ((request->mod_list[d.seq].task_status_cd=complete)
     AND (request->mod_list[d.seq].task_status_reason_cd != chartnotdone))) )) ) request->mod_list[d
     .seq].charted_by_agent_identifier
    ELSEIF ((((request->mod_list[d.seq].task_status_cd=pending)) OR ((request->mod_list[d.seq].
    task_status_cd=complete)
     AND (request->mod_list[d.seq].task_status_reason_cd=chartnotdone))) ) ""
    ELSE previous_task_info->qual[d.seq].charted_by_agent_identifier
    ENDIF
    , ta.charting_context_reference =
    IF ((((request->mod_list[d.seq].task_status_cd=validation)) OR ((((request->mod_list[d.seq].
    task_status_cd=inprocess)) OR ((request->mod_list[d.seq].task_status_cd=complete)
     AND (request->mod_list[d.seq].task_status_reason_cd != chartnotdone))) )) ) request->mod_list[d
     .seq].charting_context_reference
    ELSEIF ((((request->mod_list[d.seq].task_status_cd=pending)) OR ((request->mod_list[d.seq].
    task_status_cd=complete)
     AND (request->mod_list[d.seq].task_status_reason_cd=chartnotdone))) ) ""
    ELSE previous_task_info->qual[d.seq].charting_context_reference
    ENDIF
    ,
    ta.scheduled_dt_tm =
    IF ((request->mod_list[d.seq].reschedule_ind > 0)) cnvtdatetime(request->mod_list[d.seq].
      task_dt_tm)
    ELSE cnvtdatetime(previous_task_info->qual[d.seq].scheduled_dt_tm)
    ENDIF
    , ta.result_set_id =
    IF ((request->mod_list[d.seq].result_set_id > 0)) request->mod_list[d.seq].result_set_id
    ELSE previous_task_info->qual[d.seq].result_set_id
    ENDIF
    , ta.performed_prsnl_id =
    IF ((((request->mod_list[d.seq].task_status_cd=complete)) OR ((((request->mod_list[d.seq].
    task_status_cd=validation)) OR ((((request->mod_list[d.seq].task_status_cd=pending)) OR ((request
    ->mod_list[d.seq].task_status_cd=inprocess))) )) )) ) request->mod_list[d.seq].performed_prsnl_id
    ELSE previous_task_info->qual[d.seq].performed_prsnl_id
    ENDIF
    ,
    ta.container_id = request->mod_list[d.seq].container_id
   PLAN (d
    WHERE (previous_task_info->qual[d.seq].status=1))
    JOIN (ta
    WHERE (ta.task_id=request->mod_list[d.seq].task_id)
     AND ta.active_ind=1)
   WITH nocounter, status(previous_task_info->qual[d.seq].status)
  ;end update
 ENDIF
 IF (curqual != nbr_to_chg)
  FOR (x = 1 TO nbr_to_chg)
    IF ((previous_task_info->qual[x].status=0))
     SET failures += 1
     IF (failures > 0)
      SET stat = alterlist(reply->result.task_list,failures)
     ENDIF
     SET reply->result.task_list[failures].task_id = request->mod_list[x].task_id
     SET reply->result.task_list[failures].updt_cnt = previous_task_info->qual[x].updt_cnt
     SET reply->result.task_list[failures].updt_id = previous_task_info->qual[x].updt_id
     SET reply->result.task_list[failures].task_status_cd = previous_task_info->qual[x].
     task_status_cd
     DELETE  FROM task_action tac
      WHERE (tac.task_id=request->mod_list[x].task_id)
      WITH nocounter
     ;end delete
    ENDIF
  ENDFOR
 ENDIF
 IF (failures=0)
  SET script_status = "S"
 ELSEIF (failures != nbr_to_chg)
  SET script_status = "P"
 ENDIF
 IF (nbr_to_chg > failures)
  EXECUTE dcp_create_response_task
 ENDIF
 IF (script_status="F")
  IF (track_processed_tasks)
   DECLARE processedtasksindex = i4 WITH private, noconstant(0)
   FOR (processedtasksindex = 1 TO nbr_to_chg)
     IF ((reply->processed_tasks[processedtasksindex].error_message=""))
      SET reply->processed_tasks[processedtasksindex].error_message =
      "Modification of task failed because the dcp_chg_task script call failed."
     ENDIF
   ENDFOR
  ENDIF
  ROLLBACK
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
 SET reply->result.task_status = script_status
 SET reply->status_data.status = script_status
END GO
