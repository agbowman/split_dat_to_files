CREATE PROGRAM dcp_upd_plan
 SET modify = predeclare
 RECORD pathway(
   1 pathway_id = f8
   1 last_action_seq = i4
   1 updt_cnt = i4
   1 duration_qty = i4
   1 duration_unit_cd = f8
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 started_ind = i2
   1 pw_status_cd = f8
   1 description = vc
   1 type_mean = c12
   1 start_estimated_ind = i2
   1 calc_end_estimated_ind = i2
   1 review_status_flag = i2
 )
 DECLARE last_mod = c3 WITH protect, noconstant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, noconstant(fillstring(30," "))
 DECLARE modify_action_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"MODIFY"))
 DECLARE dc_action_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"DISCONTINUE"))
 DECLARE void_action_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"VOID"))
 DECLARE complete_action_cd = f8 WITH constant(uar_get_code_by("MEANING",16809,"COMPLETE"))
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
 DECLARE reject_plan_proposal_action_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,
   "RJCTPLANPROP"))
 DECLARE accept_plan_proposal_action_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16809,
   "ACPTPLANPROP"))
 DECLARE withdraw_plan_proposal_action_code = f8 WITH protect, constant(uar_get_code_by("MEANING",
   16809,"WTHDPLANPROP"))
 DECLARE planned_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"PLANNED"))
 DECLARE initiated_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"INITIATED"))
 DECLARE dc_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"DISCONTINUED"))
 DECLARE void_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"VOID"))
 DECLARE completed_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"COMPLETED"))
 DECLARE dropped_status_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"DROPPED"))
 DECLARE future_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"FUTURE"))
 DECLARE initiated_review_status_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "INITREVIEW"))
 DECLARE future_review_status_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,
   "FUTUREREVIEW"))
 DECLARE proposed_status_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"PROPOSED")
  )
 DECLARE excluded_status_code = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"EXCLUDED")
  )
 DECLARE l_additional_action_count = i4 WITH protect, constant(value(size(request->
    additionalactionlist,5)))
 DECLARE l_protocol_review_info_count = i4 WITH protect, constant(value(size(request->
    protocolreviewinfolist,5)))
 DECLARE l_review_information_count = i4 WITH protect, constant(value(size(request->
    reviewinformationlist,5)))
 DECLARE lnotificationcount = i4 WITH protect, noconstant(0)
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
 DECLARE review_status_withdrawn = i2 WITH protect, constant(6)
 DECLARE review_type_plan_proposal = i2 WITH protect, constant(2)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE started = i2 WITH noconstant(0)
 DECLARE updt_cnt = i4 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE pw_status_cd = f8 WITH noconstant(0.0)
 DECLARE nreviewtypeflag = i2 WITH protect, noconstant(0)
 DECLARE ilastactionseq = i4 WITH noconstant(1)
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
 DECLARE bisphaseinproposalstatus = i2 WITH protect, noconstant(0)
 DECLARE bisphaseinwithdrawnstatus = i2 WITH protect, noconstant(0)
 DECLARE baddreview = i2 WITH protect, noconstant(0)
 DECLARE lreviewcount = i4 WITH protect, noconstant(0)
 DECLARE bisparentphase = i2 WITH protect, noconstant(0)
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE get_last_pathway_action_seq(ipathwayid=f8,ioldlastactionseq=i4(ref)) = null
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nstat = i2 WITH private, noconstant(0)
 SET reply->pathway_id = request->pathway_id
 SET reply->review_status_flag = review_status_none
 FOR (i = 1 TO l_protocol_review_info_count)
   SET nreviewstatusflag = request->protocolreviewinfolist[i].review_status_flag
   SET reply->review_status_flag = nreviewstatusflag
   IF (nreviewstatusflag IN (review_status_pending, review_status_opt_out, review_status_completed,
   review_status_rejected))
    SET lprotocolreviewactioncount = (lprotocolreviewactioncount+ 1)
   ENDIF
 ENDFOR
 FOR (i = 1 TO l_review_information_count)
   IF ((request->reviewinformationlist[i].review_type_flag=review_type_plan_proposal))
    IF ((request->reviewinformationlist[i].review_status_flag IN (review_status_pending,
    review_status_rejected)))
     SET lplanproposalactioncount = (lplanproposalactioncount+ 1)
     SET bisphaseinproposalstatus = 1
    ELSEIF ((request->reviewinformationlist[i].review_status_flag IN (review_status_withdrawn)))
     SET lplanproposalactioncount = (lplanproposalactioncount+ 1)
     SET bisphaseinwithdrawnstatus = 1
    ELSEIF ((request->reviewinformationlist[i].review_status_flag IN (review_status_completed)))
     SET lplanproposalactioncount = (lplanproposalactioncount+ 1)
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM pathway pw
  WHERE (pw.pathway_id=request->pathway_id)
  DETAIL
   pathway->pathway_id = pw.pathway_id, pathway->last_action_seq = pw.last_action_seq, pathway->
   updt_cnt = pw.updt_cnt,
   pathway->duration_qty = pw.duration_qty, pathway->duration_unit_cd = pw.duration_unit_cd, pathway
   ->start_dt_tm = pw.start_dt_tm,
   pathway->end_dt_tm = pw.calc_end_dt_tm, pathway->started_ind = pw.started_ind, pathway->
   pw_status_cd = pw.pw_status_cd,
   pathway->description = trim(pw.description), pathway->type_mean = pw.type_mean, pathway->
   start_estimated_ind = pw.start_estimated_ind,
   pathway->calc_end_estimated_ind = pw.calc_end_estimated_ind, pathway->review_status_flag = pw
   .review_status_flag
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("SELECT","F","DCP_UPD_PLAN","Failed to locate row on PATHWAY table")
  GO TO exit_script
 ENDIF
 IF (trim(pathway->type_mean) IN ("CAREPLAN", "PHASE"))
  SET bisparentphase = 1
 ENDIF
 SET pw_status_cd = pathway->pw_status_cd
 CALL get_last_pathway_action_seq(request->pathway_id,ilastactionseq)
 SET ilastactionseq = (ilastactionseq+ 1)
 CASE (request->pw_action_meaning)
  OF "MODIFY":
   IF ((pathway->type_mean="SUBPHASE")
    AND (request->included_ind=0))
    SET pw_status_cd = dropped_status_cd
   ELSEIF (((bisphaseinproposalstatus=1) OR ((pathway->pw_status_cd=proposed_status_code)
    AND l_review_information_count=0)) )
    SET pw_status_cd = proposed_status_code
   ELSEIF (bisphaseinwithdrawnstatus=1)
    SET pw_status_cd = excluded_status_code
   ELSEIF ((request->future_ind=1))
    IF (((nreviewstatusflag IN (review_status_pending, review_status_rejected)) OR (nreviewstatusflag
    =review_status_none
     AND (pathway->review_status_flag IN (review_status_pending, review_status_rejected)))) )
     SET pw_status_cd = future_review_status_code
     SET request->future_ind = 0
    ELSE
     SET pw_status_cd = future_status_cd
    ENDIF
   ELSEIF ((request->started_ind=0)
    AND ((pw_status_cd=0) OR (((pw_status_cd=planned_status_cd) OR (pw_status_cd=proposed_status_code
   )) )) )
    SET pw_status_cd = planned_status_cd
   ELSEIF ((request->started_ind=1)
    AND pw_status_cd IN (planned_status_cd, future_status_cd, future_review_status_code,
   initiated_review_status_code, proposed_status_code))
    IF (((nreviewstatusflag IN (review_status_pending, review_status_rejected)) OR (nreviewstatusflag
    =review_status_none
     AND (pathway->review_status_flag IN (review_status_pending, review_status_rejected)))) )
     SET pw_status_cd = initiated_review_status_code
    ELSE
     SET pw_status_cd = initiated_status_cd
    ENDIF
   ENDIF
   IF ((pathway->started_ind=0)
    AND (request->started_ind=1))
    SET started = 1
   ENDIF
   IF (((nreviewstatusflag IN (review_status_pending, review_status_rejected)) OR (nreviewstatusflag=
   review_status_none
    AND (pathway->review_status_flag IN (review_status_pending, review_status_rejected)))) )
    SET request->started_ind = 0
    SET request->future_ind = 0
   ENDIF
  OF "DISCONTINUE":
   SET pw_status_cd = dc_status_cd
   SET reply->review_status_flag = pathway->review_status_flag
  OF "VOID":
   SET pw_status_cd = void_status_cd
   SET reply->review_status_flag = pathway->review_status_flag
  OF "COMPLETE":
   SET pw_status_cd = completed_status_cd
 ENDCASE
 SET reply->pw_status_cd = pw_status_cd
 SELECT INTO "nl:"
  pw.*
  FROM pathway pw
  WHERE (pw.pathway_id=request->pathway_id)
  HEAD REPORT
   updt_cnt = pw.updt_cnt
  WITH forupdate(pw), nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("UPDATE","F","DCP_UPD_PLAN","Unable to lock row on PATHWAY table")
  GO TO exit_script
 ENDIF
 IF ((updt_cnt != request->updt_cnt))
  CALL report_failure("UPDATE","F","DCP_UPD_PLAN",
   "Unable to update - PATHWAY has been changed by a different user")
  GO TO exit_script
 ENDIF
 UPDATE  FROM pathway pw
  SET pw.encntr_id =
   IF ((request->pw_action_meaning="MODIFY")
    AND started=1) request->encntr_id
   ELSE pw.encntr_id
   ENDIF
   , pw.pw_status_cd = pw_status_cd, pw.status_dt_tm = cnvtdatetime(curdate,curtime3),
   pw.status_prsnl_id = reqinfo->updt_id, pw.started_ind =
   IF ((request->pw_action_meaning="MODIFY")) request->started_ind
   ELSE pw.started_ind
   ENDIF
   , pw.start_dt_tm =
   IF ((request->pw_action_meaning="MODIFY")
    AND (request->start_dt_tm != null)) cnvtdatetime(request->start_dt_tm)
   ELSE pw.start_dt_tm
   ENDIF
   ,
   pw.calc_end_dt_tm =
   IF ((((request->pw_action_meaning="MODIFY")) OR ((request->pw_action_meaning="COMPLETE")))
    AND (request->calc_end_dt_tm != null)) cnvtdatetime(request->calc_end_dt_tm)
   ELSEIF ((((request->pw_action_meaning="DISCONTINUE")) OR ((request->pw_action_meaning="VOID"))) )
    cnvtdatetime(curdate,curtime3)
   ELSE pw.calc_end_dt_tm
   ENDIF
   , pw.discontinued_ind =
   IF ((((request->pw_action_meaning="DISCONTINUE")) OR ((request->pw_action_meaning="VOID"))) ) 1
   ELSE pw.discontinued_ind
   ENDIF
   , pw.discontinued_dt_tm =
   IF ((((request->pw_action_meaning="DISCONTINUE")) OR ((request->pw_action_meaning="VOID"))) )
    cnvtdatetime(curdate,curtime3)
   ELSE pw.discontinued_dt_tm
   ENDIF
   ,
   pw.duration_qty =
   IF ((request->pw_action_meaning="MODIFY")) request->duration_qty
   ELSE pw.duration_qty
   ENDIF
   , pw.duration_unit_cd =
   IF ((request->pw_action_meaning="MODIFY")) request->duration_unit_cd
   ELSE pw.duration_unit_cd
   ENDIF
   , pw.dc_reason_cd = request->dc_reason_cd,
   pw.cycle_nbr =
   IF ((request->cycle_nbr > 0)) request->cycle_nbr
   ELSE pw.cycle_nbr
   ENDIF
   , pw.last_action_seq = (((ilastactionseq+ l_additional_action_count)+ lprotocolreviewactioncount)
   + lplanproposalactioncount), pw.pw_group_desc =
   IF ((request->pw_group_desc > " ")) request->pw_group_desc
   ELSE pw.pw_group_desc
   ENDIF
   ,
   pw.status_tz = request->patient_tz, pw.start_tz =
   IF ((request->pw_action_meaning="MODIFY")
    AND (request->start_dt_tm != null)) request->patient_tz
   ELSE pw.start_tz
   ENDIF
   , pw.calc_end_tz =
   IF ((((request->pw_action_meaning="MODIFY")) OR ((request->pw_action_meaning="COMPLETE")))
    AND (request->calc_end_dt_tm != null)) request->patient_tz
   ELSEIF ((((request->pw_action_meaning="DISCONTINUE")) OR ((request->pw_action_meaning="VOID"))) )
    request->patient_tz
   ELSE pw.calc_end_tz
   ENDIF
   ,
   pw.discontinued_tz =
   IF ((((request->pw_action_meaning="DISCONTINUE")) OR ((request->pw_action_meaning="VOID"))) )
    request->patient_tz
   ELSE pw.discontinued_tz
   ENDIF
   , pw.start_estimated_ind =
   IF ((request->pw_action_meaning="MODIFY")) request->start_estimated_ind
   ELSE pw.start_estimated_ind
   ENDIF
   , pw.calc_end_estimated_ind =
   IF ((request->pw_action_meaning="MODIFY")) request->calc_end_estimated_ind
   ELSE pw.calc_end_estimated_ind
   ENDIF
   ,
   pw.cycle_end_nbr =
   IF ((0 < request->cycle_end_nbr)) request->cycle_end_nbr
   ELSE pw.cycle_end_nbr
   ENDIF
   , pw.review_status_flag =
   IF (l_protocol_review_info_count > 0) nreviewstatusflag
   ELSE pw.review_status_flag
   ENDIF
   , pw.warning_level_bit =
   IF ((request->pw_action_meaning="VOID")) 0
   ELSE pw.warning_level_bit
   ENDIF
   ,
   pw.updt_dt_tm = cnvtdatetime(curdate,curtime3), pw.updt_id = reqinfo->updt_id, pw.updt_task =
   reqinfo->updt_task,
   pw.updt_cnt = (pw.updt_cnt+ 1), pw.updt_applctx = reqinfo->updt_applctx
  WHERE (pw.pathway_id=request->pathway_id)
 ;end update
 IF (curqual=0)
  CALL report_failure("UPDATE","F","DCP_UPD_PLAN","Failed to update row on PATHWAY table")
  GO TO exit_script
 ENDIF
 SET dtactiondttm = cnvtdatetime(curdate,curtime3)
 SET lactiontz = request->user_tz
 INSERT  FROM pathway_action pa
  SET pa.pathway_action_id = seq(carenet_seq,nextval), pa.pathway_id = pathway->pathway_id, pa
   .pw_action_seq = ilastactionseq,
   pa.pw_status_cd = pw_status_cd, pa.action_type_cd =
   IF ((request->pw_action_meaning="MODIFY")) modify_action_cd
   ELSEIF ((request->pw_action_meaning="DISCONTINUE")) dc_action_cd
   ELSEIF ((request->pw_action_meaning="COMPLETE")) complete_action_cd
   ELSEIF ((request->pw_action_meaning="VOID")) void_action_cd
   ENDIF
   , pa.action_dt_tm = cnvtdatetime(dtactiondttm),
   pa.action_prsnl_id = reqinfo->updt_id, pa.duration_qty = pathway->duration_qty, pa
   .duration_unit_cd = pathway->duration_unit_cd,
   pa.start_dt_tm = cnvtdatetime(pathway->start_dt_tm), pa.end_dt_tm = cnvtdatetime(pathway->
    end_dt_tm), pa.provider_id = request->provider_id,
   pa.communication_type_cd = request->communication_type_cd, pa.start_tz =
   IF ((pathway->start_dt_tm != null)) request->patient_tz
   ENDIF
   , pa.end_tz =
   IF ((pathway->end_dt_tm != null)) request->patient_tz
   ENDIF
   ,
   pa.action_tz = lactiontz, pa.start_estimated_ind = pathway->start_estimated_ind, pa
   .end_estimated_ind = pathway->calc_end_estimated_ind,
   pa.updt_dt_tm = cnvtdatetime(curdate,curtime3), pa.updt_id = reqinfo->updt_id, pa.updt_task =
   reqinfo->updt_task,
   pa.updt_cnt = (pathway->updt_cnt+ 1), pa.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL report_failure("INSERT","F","DCP_UPD_PLAN","Failed to insert into PATHWAY_ACTION table")
  GO TO exit_script
 ENDIF
 SET nnotificationtype = notification_type_phase_protocol_review
 IF (trim(pathway->type_mean) != "SUBPHASE"
  AND trim(pathway->type_mean) != "DOT")
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
     SET dactioncode = accept_review_action_code
     IF ((pathway->review_status_flag != review_status_rejected))
      SET baddnotification = 1
      SET nnotificationstatus = notification_status_accepted
     ENDIF
    ELSEIF (nreviewstatusflag=review_status_rejected)
     SET baddaction = 1
     SET baddnotification = 1
     SET nnotificationstatus = notification_status_rejected
     SET dactioncode = reject_review_action_code
    ENDIF
    IF (baddaction=1)
     SET ilastactionseq = (ilastactionseq+ 1)
     INSERT  FROM pathway_action pa
      SET pa.pathway_action_id = seq(carenet_seq,nextval), pa.pathway_id = pathway->pathway_id, pa
       .pw_action_seq = ilastactionseq,
       pa.pw_status_cd = pw_status_cd, pa.action_type_cd = dactioncode, pa.action_dt_tm =
       cnvtdatetime(dtactiondttm),
       pa.action_prsnl_id = reqinfo->updt_id, pa.action_reason_cd = request->protocolreviewinfolist[i
       ].review_status_reason_cd, pa.action_comment = trim(request->protocolreviewinfolist[i].
        review_status_comment),
       pa.duration_qty = pathway->duration_qty, pa.duration_unit_cd = pathway->duration_unit_cd, pa
       .start_dt_tm = cnvtdatetime(pathway->start_dt_tm),
       pa.end_dt_tm = cnvtdatetime(pathway->end_dt_tm), pa.provider_id = request->provider_id, pa
       .communication_type_cd = request->communication_type_cd,
       pa.start_tz =
       IF ((pathway->start_dt_tm != null)) request->patient_tz
       ENDIF
       , pa.end_tz =
       IF ((pathway->end_dt_tm != null)) request->patient_tz
       ENDIF
       , pa.action_tz = lactiontz,
       pa.start_estimated_ind = pathway->start_estimated_ind, pa.end_estimated_ind = pathway->
       calc_end_estimated_ind, pa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo->updt_task, pa.updt_cnt = (pathway->
       updt_cnt+ 1),
       pa.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL report_failure("INSERT","F","DCP_UPD_PLAN","Failed to insert into PATHWAY_ACTION table")
      GO TO exit_script
     ENDIF
    ENDIF
    IF (baddnotification=1)
     SET lnotificationcount = (lnotificationcount+ 1)
     SET stat = alterlist(reply->notificationlist,lnotificationcount)
     SET reply->notificationlist[lnotificationcount].notification_status_flag = nnotificationstatus
     SET reply->notificationlist[lnotificationcount].notification_type_flag = nnotificationtype
     SET reply->notificationlist[lnotificationcount].pw_action_seq = ilastactionseq
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
    ELSEIF (nreviewstatusflag=review_status_rejected)
     SET baddaction = 1
     SET dactioncode = reject_plan_proposal_action_code
     IF (bisparentphase=1)
      SET baddreview = 1
      SET baddnotification = 1
      SET nnotificationstatus = notification_status_rejected
      SET nnotificationtype = notification_type_plan_proposal
     ENDIF
    ELSEIF (nreviewstatusflag=review_status_completed)
     SET baddaction = 1
     SET dactioncode = accept_plan_proposal_action_code
     IF (bisparentphase=1)
      SET baddreview = 1
      SET baddnotification = 1
      SET nnotificationstatus = notification_status_accepted
      SET nnotificationtype = notification_type_plan_proposal
     ENDIF
    ELSEIF (nreviewstatusflag=review_status_withdrawn)
     SET baddaction = 1
     SET dactioncode = withdraw_plan_proposal_action_code
     IF (bisparentphase=1)
      SET baddreview = 1
     ENDIF
    ENDIF
   ENDIF
   IF (baddaction=1)
    SET ilastactionseq = (ilastactionseq+ 1)
    INSERT  FROM pathway_action pa
     SET pa.pathway_action_id = seq(carenet_seq,nextval), pa.pathway_id = request->pathway_id, pa
      .pw_action_seq = ilastactionseq,
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
    SET reply->reviewinformationlist[lreviewcount].pw_action_seq = ilastactionseq
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
    SET reply->notificationlist[lnotificationcount].pw_action_seq = ilastactionseq
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
   SET pa.pathway_action_id = seq(carenet_seq,nextval), pa.pathway_id = pathway->pathway_id, pa
    .pw_action_seq = (ilastactionseq+ cnvtint(d.seq)),
    pa.pw_status_cd = pw_status_cd, pa.action_type_cd = request->additionalactionlist[d.seq].
    action_type_cd, pa.action_dt_tm = cnvtdatetime(curdate,curtime3),
    pa.action_prsnl_id = reqinfo->updt_id, pa.duration_qty = pathway->duration_qty, pa
    .duration_unit_cd = pathway->duration_unit_cd,
    pa.start_dt_tm = cnvtdatetime(pathway->start_dt_tm), pa.end_dt_tm = cnvtdatetime(pathway->
     end_dt_tm), pa.provider_id = request->additionalactionlist[d.seq].provider_id,
    pa.communication_type_cd = request->additionalactionlist[d.seq].communication_type_cd, pa
    .start_tz =
    IF ((pathway->start_dt_tm != null)) request->patient_tz
    ENDIF
    , pa.end_tz =
    IF ((pathway->end_dt_tm != null)) request->patient_tz
    ENDIF
    ,
    pa.action_tz = request->user_tz, pa.start_estimated_ind = pathway->start_estimated_ind, pa
    .end_estimated_ind = pathway->calc_end_estimated_ind,
    pa.action_reason_cd = request->additionalactionlist[d.seq].action_reason_cd, pa.action_comment =
    trim(request->additionalactionlist[d.seq].action_comment), pa.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    pa.updt_id = reqinfo->updt_id, pa.updt_task = reqinfo->updt_task, pa.updt_cnt = (pathway->
    updt_cnt+ 1),
    pa.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (pa
    WHERE (pa.pathway_id=pathway->pathway_id))
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","DCP_UPD_PLAN","Failed to insert into PATHWAY_ACTION table")
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
 FREE RECORD pathway
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt <= 50)
   SET errcnt = (errcnt+ 1)
   CALL report_failure("CCL ERROR","F","DCP_UPD_PLAN",errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "022"
 SET mod_date = "May 07, 2013"
END GO
