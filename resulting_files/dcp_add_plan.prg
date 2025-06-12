CREATE PROGRAM dcp_add_plan
 SET modify = predeclare
 CALL echorecord(request)
 DECLARE suggest_action_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,"SUGGEST"))
 DECLARE accept_action_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,"ACCEPT"))
 DECLARE order_action_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,"ORDER"))
 DECLARE reject_action_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,"REJECT"))
 DECLARE do_not_route_for_review_action_code = f8 WITH protect, constant(uar_get_code_by("MEANING",
   16809,"NOROUTEREVIE"))
 DECLARE route_for_review_action_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,
   "ROUTEREVIEW"))
 DECLARE accept_review_action_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,
   "ACCEPTREVIEW"))
 DECLARE reject_review_action_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,
   "REJECTREVIEW"))
 DECLARE propose_plan_action_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,
   "PROPOSEPLAN"))
 DECLARE planned_status_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"PLANNED"))
 DECLARE initiated_status_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "INITIATED"))
 DECLARE excluded_status_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"EXCLUDED")
  )
 DECLARE future_status_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"FUTURE"))
 DECLARE initiated_review_status_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "INITREVIEW"))
 DECLARE future_review_status_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "FUTUREREVIEW"))
 DECLARE proposed_status_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"PROPOSED")
  )
 DECLARE cycle_code = f8 WITH protect, constant(uar_get_code_by("MEANING",4002313,"CYCLE"))
 DECLARE l_additional_action_count = i4 WITH protect, constant(value(size(request->
    additionalactionlist,5)))
 DECLARE l_protocol_review_info_count = i4 WITH protect, constant(value(size(request->
    protocolreviewinfolist,5)))
 DECLARE l_review_information_count = i4 WITH protect, constant(value(size(request->
    reviewinformationlist,5)))
 DECLARE lnotificationcount = i4 WITH protect, noconstant(0)
 DECLARE lreviewcount = i4 WITH protect, noconstant(0)
 DECLARE lplanproposalactioncount = i4 WITH protect, noconstant(0)
 DECLARE notification_type_none = i2 WITH protect, constant(0)
 DECLARE notification_type_phase_protocol_review = i2 WITH protect, constant(1)
 DECLARE notification_type_plan_proposal = i2 WITH protect, constant(2)
 DECLARE notification_status_none = i2 WITH protect, constant(0)
 DECLARE notification_status_pending = i2 WITH protect, constant(1)
 DECLARE notification_status_accepted = i2 WITH protect, constant(2)
 DECLARE notification_status_rejected = i2 WITH protect, constant(3)
 DECLARE notification_status_forwarded = i2 WITH protect, constant(4)
 DECLARE notification_status_no_longer_needed = i2 WITH protect, constant(5)
 DECLARE notification_status_planning = i2 WITH protect, constant(6)
 DECLARE review_status_none = i2 WITH protect, constant(0)
 DECLARE review_status_pending = i2 WITH protect, constant(1)
 DECLARE review_status_completed = i2 WITH protect, constant(2)
 DECLARE review_status_rejected = i2 WITH protect, constant(3)
 DECLARE review_status_opt_out = i2 WITH protect, constant(4)
 DECLARE review_status_planning = i2 WITH protect, constant(5)
 DECLARE review_type_plan_proposal = i2 WITH protect, constant(2)
 DECLARE i = i2 WITH noconstant(0)
 DECLARE actionseq = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE pw_status_cd = f8 WITH noconstant(0.0)
 DECLARE nreviewtypeflag = i2 WITH protect, noconstant(0)
 DECLARE nreviewstatusflag = i2 WITH protect, noconstant(0)
 DECLARE lprotocolreviewactioncount = i4 WITH protect, noconstant(0)
 DECLARE baddaction = i2 WITH protect, noconstant(0)
 DECLARE dactioncode = f8 WITH protect, noconstant(0.0)
 DECLARE dtactiondttm = dq8 WITH protect
 DECLARE lactiontz = i4 WITH protect, noconstant(0)
 DECLARE baddnotification = i2 WITH protect, noconstant(0)
 DECLARE nnotificationtype = i2 WITH protect, noconstant(0)
 DECLARE nnotificationstatus = i2 WITH protect, noconstant(0)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE baddreview = i2 WITH protect, noconstant(0)
 DECLARE bisparentphase = i2 WITH protect, noconstant(0)
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE get_last_pathway_action_seq(ipathwayid=f8,ioldlastactionseq=i4(ref)) = null
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE nstat = i2 WITH private, noconstant(0)
 SET reply->review_status_flag = review_status_none
 FOR (i = 1 TO l_protocol_review_info_count)
   SET nreviewstatusflag = request->protocolreviewinfolist[i].review_status_flag
   SET reply->review_status_flag = nreviewstatusflag
   IF (nreviewstatusflag IN (review_status_opt_out, review_status_pending, review_status_completed,
   review_status_rejected))
    SET lprotocolreviewactioncount = (lprotocolreviewactioncount+ 1)
   ENDIF
 ENDFOR
 FOR (i = 1 TO l_review_information_count)
   IF ((request->reviewinformationlist[i].review_type_flag=review_type_plan_proposal))
    IF ((request->reviewinformationlist[i].review_status_flag=review_status_pending))
     SET lplanproposalactioncount = (lplanproposalactioncount+ 1)
    ENDIF
   ENDIF
 ENDFOR
 IF (trim(request->type_mean) IN ("CAREPLAN", "PHASE"))
  SET bisparentphase = 1
 ENDIF
 IF (lplanproposalactioncount > 0)
  SET pw_status_cd = proposed_status_code
 ELSEIF ((request->started_ind=1))
  IF (nreviewstatusflag=review_status_pending)
   SET request->started_ind = 0
   SET pw_status_cd = initiated_review_status_code
  ELSE
   SET pw_status_cd = initiated_status_code
  ENDIF
 ELSEIF ((request->future_ind=1))
  IF (nreviewstatusflag=review_status_pending)
   SET request->future_ind = 0
   SET pw_status_cd = future_review_status_code
  ELSE
   SET pw_status_cd = future_status_code
  ENDIF
 ELSEIF ((request->excluded_ind=1))
  SET pw_status_cd = excluded_status_code
 ELSE
  SET pw_status_cd = planned_status_code
 ENDIF
 IF ((request->cycle_nbr > 0)
  AND (request->cycle_label_cd <= 0.0))
  SET request->cycle_label_cd = cycle_code
 ENDIF
 CALL get_last_pathway_action_seq(request->pathway_id,actionseq)
 SET actionseq = (actionseq+ 1)
 SET reply->pw_status_cd = pw_status_cd
 INSERT  FROM pathway pw
  SET pw.pathway_id = request->pathway_id, pw.pw_group_nbr = request->pw_group_nbr, pw.type_mean =
   request->type_mean,
   pw.person_id = request->person_id, pw.encntr_id = request->encntr_id, pw.pathway_catalog_id =
   request->pathway_catalog_id,
   pw.pw_cat_group_id = request->pw_cat_group_id, pw.pw_cat_version = request->pw_cat_version, pw
   .description = request->description,
   pw.pw_group_desc = request->pw_group_desc, pw.pw_status_cd = pw_status_cd, pw.start_dt_tm =
   cnvtdatetime(request->start_dt_tm),
   pw.calc_end_dt_tm = cnvtdatetime(request->calc_end_dt_tm), pw.status_dt_tm = cnvtdatetime(curdate,
    curtime3), pw.status_prsnl_id = reqinfo->updt_id,
   pw.order_dt_tm = cnvtdatetime(curdate,curtime3), pw.duration_qty = request->duration_qty, pw
   .duration_unit_cd = request->duration_unit_cd,
   pw.started_ind = request->started_ind, pw.ended_ind = 0, pw.discontinued_ind = 0,
   pw.last_action_seq =
   IF (validate(request->suggested_ind,0)=1) ((((actionseq+ l_additional_action_count)+
    lprotocolreviewactioncount)+ lplanproposalactioncount)+ 2)
   ELSE (((actionseq+ l_additional_action_count)+ lprotocolreviewactioncount)+
    lplanproposalactioncount)
   ENDIF
   , pw.active_ind = 1, pw.restrict_comp_add_ind = request->restrict_comp_add_ind,
   pw.cross_encntr_ind = request->cross_encntr_ind, pw.pathway_type_cd = request->pathway_type_cd, pw
   .pathway_class_cd = request->pathway_class_cd,
   pw.display_method_cd = request->display_method_cd, pw.ref_owner_person_id = request->
   ref_owner_person_id, pw.parent_phase_desc = request->parent_phase_desc,
   pw.cycle_nbr = request->cycle_nbr, pw.default_view_mean = request->default_view_mean, pw
   .diagnosis_capture_ind = request->diagnosis_capture_ind,
   pw.start_tz =
   IF ((request->start_dt_tm != null)) request->patient_tz
   ENDIF
   , pw.calc_end_tz =
   IF ((request->calc_end_dt_tm != null)) request->patient_tz
   ENDIF
   , pw.order_tz = request->patient_tz,
   pw.status_tz = request->patient_tz, pw.alerts_on_plan_ind = request->alerts_on_plan_ind, pw
   .alerts_on_plan_upd_ind = request->alerts_on_plan_upd_ind,
   pw.cycle_label_cd = request->cycle_label_cd, pw.start_estimated_ind = request->start_estimated_ind,
   pw.calc_end_estimated_ind = request->calc_end_estimated_ind,
   pw.cycle_end_nbr = request->cycle_end_nbr, pw.synonym_name = request->synonym_name, pw.period_nbr
    = request->period_nbr,
   pw.period_custom_label = request->period_custom_label, pw.review_status_flag = nreviewstatusflag,
   pw.pathway_group_id = request->pathway_group_id,
   pw.pathway_customized_plan_id = request->pathway_customized_plan_id, pw.updt_dt_tm = cnvtdatetime(
    curdate,curtime3), pw.updt_id = reqinfo->updt_id,
   pw.updt_task = reqinfo->updt_task, pw.updt_cnt = 0, pw.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL report_failure("INSERT","F","DCP_ADD_PLAN","Failed to insert a new row into PATHWAY table")
  GO TO exit_script
 ENDIF
 IF (validate(request->suggested_ind,0)=1)
  INSERT  FROM pathway_action pa
   SET pa.pathway_action_id = seq(carenet_seq,nextval), pa.pathway_id = request->pathway_id, pa
    .pw_action_seq = actionseq,
    pa.pw_status_cd = 0, pa.action_type_cd = suggest_action_code, pa.action_dt_tm = cnvtdatetime(
     request->suggested_dt_tm),
    pa.action_prsnl_id = 0, pa.action_tz = request->suggested_tz, pa.action_comment = request->
    action_comment,
    pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_id = reqinfo->updt_id, pa.updt_task =
    reqinfo->updt_task,
    pa.updt_cnt = 0, pa.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","DCP_ADD_PLAN",
    "Failed to insert a new row into PATHWAY_ACTION table")
   GO TO exit_script
  ENDIF
  SET actionseq = (actionseq+ 1)
  INSERT  FROM pathway_action pa
   SET pa.pathway_action_id = seq(carenet_seq,nextval), pa.pathway_id = request->pathway_id, pa
    .pw_action_seq = actionseq,
    pa.pw_status_cd = 0, pa.action_type_cd = accept_action_code, pa.action_dt_tm = cnvtdatetime(
     curdate,curtime3),
    pa.action_prsnl_id = reqinfo->updt_id, pa.action_tz = request->user_tz, pa.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo->updt_task, pa.updt_cnt = 0,
    pa.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","DCP_ADD_PLAN",
    "Failed to insert a new row into PATHWAY_ACTION table")
   GO TO exit_script
  ENDIF
  SET actionseq = (actionseq+ 1)
 ENDIF
 SET dtactiondttm = cnvtdatetime(curdate,curtime3)
 SET lactiontz = request->user_tz
 INSERT  FROM pathway_action pa
  SET pa.pathway_action_id = seq(carenet_seq,nextval), pa.pathway_id = request->pathway_id, pa
   .pw_action_seq = actionseq,
   pa.pw_status_cd = pw_status_cd, pa.duration_qty = request->duration_qty, pa.duration_unit_cd =
   request->duration_unit_cd,
   pa.start_dt_tm = cnvtdatetime(request->start_dt_tm), pa.end_dt_tm = cnvtdatetime(request->
    calc_end_dt_tm), pa.action_type_cd = order_action_code,
   pa.action_dt_tm = cnvtdatetime(dtactiondttm), pa.action_prsnl_id = reqinfo->updt_id, pa
   .provider_id = request->provider_id,
   pa.communication_type_cd = request->communication_type_cd, pa.start_tz =
   IF ((request->start_dt_tm != null)) request->patient_tz
   ENDIF
   , pa.end_tz =
   IF ((request->calc_end_dt_tm != null)) request->patient_tz
   ENDIF
   ,
   pa.action_tz = lactiontz, pa.start_estimated_ind = request->start_estimated_ind, pa
   .end_estimated_ind = request->calc_end_estimated_ind,
   pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_id = reqinfo->updt_id, pa.updt_task =
   reqinfo->updt_task,
   pa.updt_cnt = 0, pa.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL report_failure("INSERT","F","DCP_ADD_PLAN",
   "Failed to insert a new row into PATHWAY_ACTION table")
  GO TO exit_script
 ENDIF
 SET nnotificationtype = notification_type_phase_protocol_review
 IF (trim(request->type_mean) != "SUBPHASE"
  AND trim(request->type_mean) != "DOT")
  FOR (i = 1 TO l_protocol_review_info_count)
    SET baddaction = 0
    SET baddnotification = 0
    SET nnotificationstatus = notification_status_none
    SET dactioncode = 0.0
    SET nreviewstatusflag = request->protocolreviewinfolist[i].review_status_flag
    IF (nreviewstatusflag=review_status_opt_out)
     SET baddaction = 1
     SET dactioncode = do_not_route_for_review_action_code
    ELSEIF (nreviewstatusflag=review_status_planning)
     SET baddnotification = 1
     SET nnotificationstatus = notification_status_planning
    ELSEIF (nreviewstatusflag=review_status_pending)
     SET baddaction = 1
     SET baddnotification = 1
     SET nnotificationstatus = notification_status_pending
     SET dactioncode = route_for_review_action_code
    ELSEIF (nreviewstatusflag=review_status_completed)
     SET baddaction = 1
     SET baddnotification = 1
     SET nnotificationstatus = notification_status_accepted
     SET dactioncode = accept_review_action_code
    ELSEIF (nreviewstatusflag=review_status_rejected)
     SET baddaction = 1
     SET baddnotification = 1
     SET nnotificationstatus = notification_status_rejected
     SET dactioncode = reject_review_action_code
    ENDIF
    IF (baddaction=1)
     SET actionseq = (actionseq+ 1)
     INSERT  FROM pathway_action pa
      SET pa.pathway_action_id = seq(carenet_seq,nextval), pa.pathway_id = request->pathway_id, pa
       .pw_action_seq = actionseq,
       pa.pw_status_cd = pw_status_cd, pa.duration_qty = request->duration_qty, pa.duration_unit_cd
        = request->duration_unit_cd,
       pa.start_dt_tm = cnvtdatetime(request->start_dt_tm), pa.end_dt_tm = cnvtdatetime(request->
        calc_end_dt_tm), pa.action_type_cd = dactioncode,
       pa.action_dt_tm = cnvtdatetime(dtactiondttm), pa.action_prsnl_id = reqinfo->updt_id, pa
       .action_reason_cd = request->protocolreviewinfolist[i].review_status_reason_cd,
       pa.action_comment = trim(request->protocolreviewinfolist[i].review_status_comment), pa
       .provider_id = request->provider_id, pa.communication_type_cd = request->communication_type_cd,
       pa.start_tz =
       IF ((request->start_dt_tm != null)) request->patient_tz
       ENDIF
       , pa.end_tz =
       IF ((request->calc_end_dt_tm != null)) request->patient_tz
       ENDIF
       , pa.action_tz = lactiontz,
       pa.start_estimated_ind = request->start_estimated_ind, pa.end_estimated_ind = request->
       calc_end_estimated_ind, pa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo->updt_task, pa.updt_cnt = 0,
       pa.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL report_failure("INSERT","F","DCP_ADD_PLAN",
       "Failed to insert a new row into PATHWAY_ACTION table")
      GO TO exit_script
     ENDIF
    ENDIF
    IF (baddnotification=1)
     SET lnotificationcount = (lnotificationcount+ 1)
     SET stat = alterlist(reply->notificationlist,lnotificationcount)
     SET reply->notificationlist[lnotificationcount].notification_status_flag = nnotificationstatus
     SET reply->notificationlist[lnotificationcount].notification_type_flag = nnotificationtype
     SET reply->notificationlist[lnotificationcount].pw_action_seq = actionseq
     SET reply->notificationlist[lnotificationcount].action_dt_tm = cnvtdatetime(dtactiondttm)
     SET reply->notificationlist[lnotificationcount].action_tz = lactiontz
     IF (size(request->protocolreviewinfolist[i].notifylist,5) > 0)
      SET reply->notificationlist[lnotificationcount].to_prsnl_id = request->protocolreviewinfolist[i
      ].notifylist[1].to_prsnl_id
      SET reply->notificationlist[lnotificationcount].to_prsnl_group_id = request->
      protocolreviewinfolist[i].notifylist[1].to_prsnl_group_id
      SET reply->notificationlist[lnotificationcount].from_prsnl_id = request->
      protocolreviewinfolist[i].notifylist[1].from_prsnl_id
      SET reply->notificationlist[lnotificationcount].from_prsnl_group_id = request->
      protocolreviewinfolist[i].notifylist[1].from_prsnl_group_id
     ELSE
      SET reply->notificationlist[lnotificationcount].to_prsnl_id = 0.0
      SET reply->notificationlist[lnotificationcount].to_prsnl_group_id = 0.0
      SET reply->notificationlist[lnotificationcount].from_prsnl_id = 0.0
      SET reply->notificationlist[lnotificationcount].from_prsnl_group_id = 0.0
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 FOR (i = 1 TO l_review_information_count)
   SET baddaction = 0
   SET dactioncode = 0.0
   SET baddreview = 0
   SET nreviewtypeflag = request->reviewinformationlist[i].review_type_flag
   SET nreviewstatusflag = request->reviewinformationlist[i].review_status_flag
   IF (nreviewtypeflag=review_type_plan_proposal)
    IF (nreviewstatusflag=review_status_pending)
     SET baddaction = 1
     SET dactioncode = propose_plan_action_code
     IF (bisparentphase=1)
      SET baddreview = 1
      SET baddnotification = 1
      SET nnotificationstatus = notification_status_pending
      SET nnotificationtype = notification_type_plan_proposal
     ENDIF
    ENDIF
   ENDIF
   IF (baddaction=1)
    SET actionseq = (actionseq+ 1)
    INSERT  FROM pathway_action pa
     SET pa.pathway_action_id = seq(carenet_seq,nextval), pa.pathway_id = request->pathway_id, pa
      .pw_action_seq = actionseq,
      pa.pw_status_cd = pw_status_cd, pa.duration_qty = request->duration_qty, pa.duration_unit_cd =
      request->duration_unit_cd,
      pa.start_dt_tm = cnvtdatetime(request->start_dt_tm), pa.end_dt_tm = cnvtdatetime(request->
       calc_end_dt_tm), pa.action_type_cd = dactioncode,
      pa.action_dt_tm = cnvtdatetime(dtactiondttm), pa.action_prsnl_id = reqinfo->updt_id, pa
      .action_reason_cd = request->reviewinformationlist[i].review_status_reason_cd,
      pa.action_comment = trim(request->reviewinformationlist[i].review_status_comment), pa
      .provider_id = request->provider_id, pa.communication_type_cd = request->communication_type_cd,
      pa.start_tz =
      IF ((request->start_dt_tm != null)) request->patient_tz
      ENDIF
      , pa.end_tz =
      IF ((request->calc_end_dt_tm != null)) request->patient_tz
      ENDIF
      , pa.action_tz = lactiontz,
      pa.start_estimated_ind = request->start_estimated_ind, pa.end_estimated_ind = request->
      calc_end_estimated_ind, pa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo->updt_task, pa.updt_cnt = 0,
      pa.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_ADD_PLAN",
      "Failed to insert a new row into PATHWAY_ACTION table")
     GO TO exit_script
    ENDIF
   ENDIF
   IF (baddreview=1)
    SET lreviewcount = (lreviewcount+ 1)
    SET stat = alterlist(reply->reviewinformationlist,lreviewcount)
    SET reply->reviewinformationlist[lreviewcount].pathway_id = request->pathway_id
    SET reply->reviewinformationlist[lreviewcount].pw_action_seq = actionseq
    SET reply->reviewinformationlist[lreviewcount].review_status_flag = request->
    reviewinformationlist[lreviewcount].review_status_flag
    SET reply->reviewinformationlist[lreviewcount].review_type_flag = request->reviewinformationlist[
    lreviewcount].review_type_flag
   ENDIF
   IF (baddnotification=1)
    SET lnotificationcount = (lnotificationcount+ 1)
    SET stat = alterlist(reply->notificationlist,lnotificationcount)
    SET reply->notificationlist[lnotificationcount].notification_status_flag = nnotificationstatus
    SET reply->notificationlist[lnotificationcount].notification_type_flag = nnotificationtype
    SET reply->notificationlist[lnotificationcount].pw_action_seq = actionseq
    SET reply->notificationlist[lnotificationcount].action_dt_tm = cnvtdatetime(dtactiondttm)
    SET reply->notificationlist[lnotificationcount].action_tz = lactiontz
    IF (size(request->reviewinformationlist[i].notifylist,5) > 0)
     SET reply->notificationlist[lnotificationcount].to_prsnl_id = request->reviewinformationlist[i].
     notifylist[1].to_prsnl_id
     SET reply->notificationlist[lnotificationcount].to_prsnl_group_id = request->
     reviewinformationlist[i].notifylist[1].to_prsnl_group_id
     SET reply->notificationlist[lnotificationcount].from_prsnl_id = request->reviewinformationlist[i
     ].notifylist[1].from_prsnl_id
     SET reply->notificationlist[lnotificationcount].from_prsnl_group_id = request->
     reviewinformationlist[i].notifylist[1].from_prsnl_group_id
    ELSE
     SET reply->notificationlist[lnotificationcount].to_prsnl_id = 0.0
     SET reply->notificationlist[lnotificationcount].to_prsnl_group_id = 0.0
     SET reply->notificationlist[lnotificationcount].from_prsnl_id = 0.0
     SET reply->notificationlist[lnotificationcount].from_prsnl_group_id = 0.0
    ENDIF
   ENDIF
 ENDFOR
 IF (l_additional_action_count > 0)
  INSERT  FROM (dummyt d  WITH seq = value(l_additional_action_count)),
    pathway_action pa
   SET pa.pathway_action_id = seq(carenet_seq,nextval), pa.pathway_id = request->pathway_id, pa
    .pw_action_seq = (actionseq+ cnvtint(d.seq)),
    pa.pw_status_cd = pw_status_cd, pa.duration_qty = request->duration_qty, pa.duration_unit_cd =
    request->duration_unit_cd,
    pa.start_dt_tm = cnvtdatetime(request->start_dt_tm), pa.end_dt_tm = cnvtdatetime(request->
     calc_end_dt_tm), pa.action_type_cd = request->additionalactionlist[d.seq].action_type_cd,
    pa.action_dt_tm = cnvtdatetime(curdate,curtime3), pa.action_prsnl_id = reqinfo->updt_id, pa
    .provider_id = request->additionalactionlist[d.seq].provider_id,
    pa.communication_type_cd = request->additionalactionlist[d.seq].communication_type_cd, pa
    .start_tz =
    IF ((request->start_dt_tm != null)) request->patient_tz
    ENDIF
    , pa.end_tz =
    IF ((request->calc_end_dt_tm != null)) request->patient_tz
    ENDIF
    ,
    pa.action_tz = request->user_tz, pa.start_estimated_ind = request->start_estimated_ind, pa
    .end_estimated_ind = request->calc_end_estimated_ind,
    pa.action_reason_cd = request->additionalactionlist[d.seq].action_reason_cd, pa.action_comment =
    trim(request->additionalactionlist[d.seq].action_comment), pa.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo->updt_task, pa.updt_cnt = 0,
    pa.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (pa
    WHERE (pa.pathway_id=request->pathway_id))
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","DCP_ADD_PLAN",
    "Failed to insert new rows into PATHWAY_ACTION table")
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cfailed = "T"
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim(
     opname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,trim
    (targetname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
 SUBROUTINE get_last_pathway_action_seq(ipathwayid,ioldlastactionseq)
   SELECT INTO "nl:"
    inumberofpathwayactionsontable = count(*)
    FROM pathway_action tpathwayaction
    WHERE tpathwayaction.pathway_id=ipathwayid
    DETAIL
     ioldlastactionseq = inumberofpathwayactionsontable
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt <= 50)
   SET errcnt = (errcnt+ 1)
   CALL report_failure("CCL ERROR","F","DCP_ADD_PLAN",errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "021"
 SET mod_date = "May 21, 2013"
END GO
