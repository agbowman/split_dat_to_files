CREATE PROGRAM dcp_get_tasks_by_loc_sec:dba
 DECLARE program_version = vc WITH private, constant("003")
 RECORD internal_task_rec(
   1 task_list[*]
     2 task_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 task_security_flag = i2
 )
 EXECUTE dcp_gen_cve_recs
 FREE RECORD sec_req_info
 RECORD sec_req_info(
   1 unique_encntr_list[*]
     2 encntr_id = f8
 )
 DECLARE assertchckvalidencntrreply(dummy) = i1
 SUBROUTINE assertchckvalidencntrreply(dummy)
   CALL echo("INSIDE AssertSecurityReplyValid")
   DECLARE encntrnum = i4 WITH constant(size(sec_req_info->unique_encntr_list,5)), private
   DECLARE securereplysize = i4 WITH constant(size(cve_reply->encntrs,5)), private
   DECLARE encntridx = i4 WITH noconstant(1), private
   DECLARE securereplyidx = i4 WITH noconstant(0), private
   DECLARE num = i4 WITH noconstant(0), private
   IF (encntrnum != securereplysize)
    SET reply->status_data.subeventstatus.operationname = "dcp_chck_valid_encounters"
    SET reply->status_data.subeventstatus.operationstatus = "F"
    SET reply->status_data.subeventstatus.targetobjectname = "Validation: Reply Size"
    SET reply->status_data.subeventstatus.targetobjectvalue = build("Number of encntrs Given: ",
     encntrnum,"; Encntrs Returned: ",securereplysize,";")
    RETURN(0)
   ENDIF
   FOR (encntridx = 1 TO encntrnum)
    SET securereplyidx = locateval(num,1,securereplysize,sec_req_info->unique_encntr_list[encntridx].
     encntr_id,cve_reply->encntrs[num].encntr_id)
    IF (securereplyidx=0)
     SET reply->status_data.subeventstatus.operationname = "dcp_chck_valid_encounters"
     SET reply->status_data.subeventstatus.operationstatus = "F"
     SET reply->status_data.subeventstatus.targetobjectname = "Validation: Rep Encntrs"
     SET reply->status_data.subeventstatus.targetobjectvalue = build("EncntrId:",sec_req_info->
      unique_encntr_list[encntridx].encntr_id," passed into script but was not returned in reply")
     RETURN(0)
    ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 FREE SET dcp_get_privs_request
 RECORD dcp_get_privs_request(
   1 chk_prsnl_ind = i2
   1 prsnl_id = f8
   1 chk_psn_ind = i2
   1 position_cd = f8
   1 chk_ppr_ind = i2
   1 ppr_cd = f8
   1 plist[*]
     2 privilege_cd = f8
     2 privilege_mean = vc
 )
 FREE SET dcp_get_privs_reply
 RECORD dcp_get_privs_reply(
   1 qual[*]
     2 privilege_cd = f8
     2 privilege_disp = c40
     2 privilege_desc = c60
     2 privilege_mean = c12
     2 priv_status = c1
     2 priv_value_cd = f8
     2 priv_value_disp = c40
     2 priv_value_desc = c60
     2 priv_value_mean = c12
     2 restr_method_cd = f8
     2 restr_method_disp = c40
     2 restr_method_desc = c60
     2 restr_method_mean = c12
     2 except_cnt = i4
     2 excepts[*]
       3 exception_entity_name = c40
       3 exception_type_cd = f8
       3 exception_type_disp = c40
       3 exception_type_desc = c60
       3 exception_type_mean = c12
       3 exception_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE privilege_value_yes = f8 WITH protect, constant(uar_get_code_by("MEANING",6017,"YES"))
 DECLARE privilege_value_no = f8 WITH protect, constant(uar_get_code_by("MEANING",6017,"NO"))
 DECLARE concept_string = vc WITH protect, constant("NURSING_TASKS")
 DECLARE privilege_name = vc WITH protect, constant("RXVERIFY")
 SUBROUTINE (populateconceptstringfornursingtasks(cve_request=vc(ref),user_position_cd=f8) =null)
   IF (validate(cve_request->concept_string)
    AND user_position_cd > 0)
    SET dcp_get_privs_request->chk_psn_ind = 1
    SET dcp_get_privs_request->position_cd = user_position_cd
    SET stat = alterlist(dcp_get_privs_request->plist,1)
    SET dcp_get_privs_request->plist[1].privilege_cd = 0.0
    SET dcp_get_privs_request->plist[1].privilege_mean = privilege_name
    EXECUTE dcp_get_privs  WITH replace("REQUEST","DCP_GET_PRIVS_REQUEST"), replace("REPLY",
     "DCP_GET_PRIVS_REPLY")
    IF (size(dcp_get_privs_reply->qual,5)=1
     AND (dcp_get_privs_reply->qual[1].priv_value_cd != privilege_value_yes))
     SET cve_request->concept_string = concept_string
     CALL echo(build("cve_request->concept_string is populated with:",concept_string))
    ENDIF
   ELSE
    CALL echo(build(" cve_request->concept_string is not found OR user_position_cd is",
      user_position_cd))
   ENDIF
 END ;Subroutine
 IF ((context->confid_sec_enabled=1))
  SET cve_request->security_flag = 2
 ELSE
  SET cve_request->security_flag = 1
 ENDIF
 SET cve_request->encntr_info_flag = 0
 DECLARE task_class_prn = f8 WITH constant(uar_get_code_by("MEANING",6025,"PRN")), protect
 DECLARE task_class_continuous = f8 WITH constant(uar_get_code_by("MEANING",6025,"CONT")), protect
 DECLARE task_class_nonscheduled = f8 WITH constant(uar_get_code_by("MEANING",6025,"NSCH")), protect
 DECLARE task_status_pending = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING")), protect
 DECLARE task_status_overdue = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE")), protect
 DECLARE task_status_inprocess = f8 WITH constant(uar_get_code_by("MEANING",79,"INPROCESS")), protect
 DECLARE task_status_validation = f8 WITH constant(uar_get_code_by("MEANING",79,"VALIDATION")),
 protect
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," ")), protect
 DECLARE task_status_count = i4 WITH constant(size(request->task_status_list,5)), protect
 DECLARE task_status_index = i4 WITH noconstant(1), protect
 DECLARE task_type_count = i4 WITH constant(size(request->task_type_list,5)), protect
 DECLARE task_type_index = i4 WITH noconstant(1), protect
 DECLARE task_class_count = i4 WITH constant(size(request->task_class_list,5)), protect
 DECLARE task_class_index = i4 WITH noconstant(1), protect
 DECLARE location_count = i4 WITH constant(size(request->location_list,5))
 DECLARE task_count = i4 WITH noconstant(0), protect
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH noconstant(60)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE index1 = i4 WITH noconstant(0)
 DECLARE num1 = i4 WITH noconstant(0)
 DECLARE expandclauses = c1000 WITH noconstant(fillstring(1000," ")), protect
 SET expandclauses = concat(trim(expandclauses)," ta.active_ind = 1 ")
 DECLARE secure_task_count = i4 WITH noconstant(0)
 DECLARE final_task_count = i4 WITH noconstant(0)
 DECLARE encntr_count = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 IF (location_count > 0)
  IF ((request->beg_dt_tm > 0)
   AND (request->end_dt_tm > 0))
   IF (validate(request->apply_grace_period_ind,0) > 0)
    SET expandclauses = concat(trim(expandclauses),
     " and ((ta.scheduled_dt_tm >= datetimeadd(cnvtdatetime(request->beg_dt_tm), -ot.grace_period_mins/1440.0) ",
     " and ta.scheduled_dt_tm <= datetimeadd(cnvtdatetime(request->end_dt_tm), ot.grace_period_mins/1440.0))",
     " or (ta.task_dt_tm <= cnvtdatetime(request->end_dt_tm)")
   ELSE
    SET expandclauses = concat(trim(expandclauses),
     " and ((ta.task_dt_tm between cnvtdatetime(request->beg_dt_tm)",
     " and cnvtdatetime(request->end_dt_tm))",
     " or (ta.task_dt_tm <= cnvtdatetime (request->end_dt_tm)")
   ENDIF
   IF ((((request->ignore_beg_dt_on_overdue_ind=1)) OR ((request->ignore_beg_dt_on_working_ind=1))) )
    IF ((request->ignore_beg_dt_on_overdue_ind=1))
     SET expandclauses = concat(trim(expandclauses)," and (ta.task_status_cd = task_status_overdue")
     IF ((request->ignore_beg_dt_on_working_ind=1))
      SET expandclauses = concat(trim(expandclauses)," or ta.task_status_cd = task_status_inprocess",
       " or ta.task_status_cd = task_status_validation")
     ENDIF
    ELSEIF ((request->ignore_beg_dt_on_working_ind=1))
     SET expandclauses = concat(trim(expandclauses)," and (ta.task_status_cd = task_status_inprocess",
      " or ta.task_status_cd = task_status_validation")
    ENDIF
    SET expandclauses = concat(trim(expandclauses)," ) or ((ta.task_class_cd = task_class_prn",
     " or ta.task_class_cd = task_class_continuous"," or ta.task_class_cd = task_class_nonscheduled)",
     " and ta.task_status_cd = task_status_pending)))")
   ELSE
    SET expandclauses = concat(trim(expandclauses)," and ((ta.task_class_cd = task_class_prn",
     " or ta.task_class_cd = task_class_continuous"," or ta.task_class_cd = task_class_nonscheduled)",
     " and ta.task_status_cd = task_status_pending)))")
   ENDIF
  ENDIF
  IF (task_type_count > 0)
   SET expandclauses = concat(trim(expandclauses),
    " and expand(task_type_index, 1, task_type_count, ta.task_type_cd, request->task_type_list[task_type_index].task_type_cd)"
    )
  ENDIF
  IF (task_status_count > 0)
   SET expandclauses = concat(trim(expandclauses),
" and expand(task_status_index, 1, task_status_count, ta.task_status_cd, request->task_status_list[task_status_index].statu\
s_cd)\
")
  ENDIF
  IF (task_class_count > 0)
   SET expandclauses = concat(trim(expandclauses),
    " and expand(task_class_index, 1, task_class_count, ta.task_class_cd, request->task_class_list[task_class_index].class_cd)"
    )
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(location_count)),
    task_activity ta
   PLAN (d)
    JOIN (ta
    WHERE (ta.location_cd=request->location_list[d.seq].location_cd)
     AND ((ta.person_id+ 0) > context->last_person_id)
     AND parser(trim(expandclauses)))
   ORDER BY ta.encntr_id, ta.task_id
   HEAD REPORT
    task_count = 0
   HEAD ta.encntr_id
    encntr_count += 1
    IF (mod(encntr_count,10)=1)
     stat = alterlist(cve_request->encntrs,(encntr_count+ 9)), stat = alterlist(sec_req_info->
      unique_encntr_list,(encntr_count+ 9))
    ENDIF
    cve_request->encntrs[encntr_count].encntr_id = ta.encntr_id, cve_request->encntrs[encntr_count].
    person_id = ta.person_id, sec_req_info->unique_encntr_list[encntr_count].encntr_id = ta.encntr_id
   HEAD ta.task_id
    task_count += 1
    IF (mod(task_count,25)=1)
     stat = alterlist(internal_task_rec->task_list,(task_count+ 24))
    ENDIF
    internal_task_rec->task_list[task_count].task_id = ta.task_id, internal_task_rec->task_list[
    task_count].encntr_id = ta.encntr_id, internal_task_rec->task_list[task_count].person_id = ta
    .person_id,
    internal_task_rec->task_list[task_count].task_security_flag = - (1)
   DETAIL
    stat = 0
   FOOT  ta.encntr_id
    stat = 0
   FOOT REPORT
    stat = alterlist(internal_task_rec->task_list,task_count), stat = alterlist(cve_request->encntrs,
     encntr_count), stat = alterlist(sec_req_info->unique_encntr_list,encntr_count)
   WITH nocounter
  ;end select
  CALL populateconceptstringfornursingtasks(cve_request,request->user_position_cd)
  IF (encntr_count > 0
   AND task_count > 0)
   EXECUTE dcp_chck_valid_encounters  WITH replace("REQUEST","CVE_REQUEST"), replace("REPLY",
    "CVE_REPLY")
   IF (assertchckvalidencntrreply(0)=0)
    GO TO exit_script
   ENDIF
   RECORD secure_task_rec(
     1 task_list[*]
       2 task_id = f8
       2 task_security_flag = i2
   )
   SELECT INTO "nl:"
    personid = internal_task_rec->task_list[dtask.seq].person_id
    FROM (dummyt dtask  WITH seq = value(task_count)),
     (dummyt dencntr  WITH seq = value(encntr_count)),
     dummyt douter,
     task_activity_assignment taa
    PLAN (dtask)
     JOIN (dencntr
     WHERE (internal_task_rec->task_list[dtask.seq].encntr_id=cve_reply->encntrs[dencntr.seq].
     encntr_id))
     JOIN (douter)
     JOIN (taa
     WHERE (taa.task_id=internal_task_rec->task_list[dtask.seq].task_id)
      AND ((taa.assign_prsnl_id+ 0)=reqinfo->updt_id)
      AND taa.active_ind=1
      AND taa.beg_eff_dt_tm <= cnvtdatetime(sysdate)
      AND taa.end_eff_dt_tm >= cnvtdatetime(sysdate))
    ORDER BY personid
    HEAD REPORT
     task_count = 0
    HEAD personid
     newpersonind = 1
    DETAIL
     IF ((secure_task_count >= request->dcp_task_limit)
      AND newpersonind=1)
      CALL cancel(1)
     ENDIF
     task_count += 1
     IF ((cve_reply->encntrs[dencntr.seq].secure_ind=0))
      secure_task_count += 1
      IF (size(secure_task_rec->task_list,5) < secure_task_count)
       stat = alterlist(secure_task_rec->task_list,(secure_task_count+ 10))
      ENDIF
      secure_task_rec->task_list[secure_task_count].task_security_flag = 1, secure_task_rec->
      task_list[secure_task_count].task_id = internal_task_rec->task_list[dtask.seq].task_id
     ELSEIF ((cve_reply->encntrs[dencntr.seq].encntr_id=0))
      secure_task_count += 1
      IF (size(secure_task_rec->task_list,5) < secure_task_count)
       stat = alterlist(secure_task_rec->task_list,(secure_task_count+ 10))
      ENDIF
      secure_task_rec->task_list[secure_task_count].task_security_flag = 1, secure_task_rec->
      task_list[secure_task_count].task_id = internal_task_rec->task_list[dtask.seq].task_id
     ELSEIF (taa.active_ind=1)
      secure_task_count += 1
      IF (size(secure_task_rec->task_list,5) < secure_task_count)
       stat = alterlist(secure_task_rec->task_list,(secure_task_count+ 10))
      ENDIF
      secure_task_rec->task_list[secure_task_count].task_security_flag = 0, secure_task_rec->
      task_list[secure_task_count].task_id = internal_task_rec->task_list[dtask.seq].task_id
     ENDIF
     newpersonind = 0
    FOOT  personid
     stat = 0
    FOOT REPORT
     IF (secure_task_count=0)
      stat = alterlist(secure_task_rec->task_list,0)
     ELSE
      stat = alterlist(secure_task_rec->task_list,secure_task_count)
     ENDIF
    WITH outerjoin = douter
   ;end select
   IF (secure_task_count > 0)
    SET stat = alterlist(reply->task_list,secure_task_count)
    SELECT INTO "nl:"
     FROM (dummyt d2  WITH seq = value(secure_task_count)),
      task_activity ta2,
      task_activity_assignment taa2,
      prsnl p
     PLAN (d2)
      JOIN (ta2
      WHERE (ta2.task_id=secure_task_rec->task_list[d2.seq].task_id))
      JOIN (taa2
      WHERE (taa2.task_id= Outerjoin(ta2.task_id))
       AND (taa2.active_ind= Outerjoin(1))
       AND (taa2.beg_eff_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
       AND (taa2.end_eff_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
      JOIN (p
      WHERE (p.person_id= Outerjoin(taa2.assign_prsnl_id)) )
     ORDER BY ta2.task_id
     HEAD REPORT
      final_task_count = 0, assign_count = 0
     HEAD ta2.task_id
      final_task_count += 1, reply->task_list[final_task_count].task_id = ta2.task_id
      IF (ta2.catalog_type_cd > 0)
       reply->task_list[final_task_count].catalog_type_cd = ta2.catalog_type_cd, reply->task_list[
       final_task_count].catalog_type_mean = uar_get_code_meaning(ta2.catalog_type_cd), reply->
       task_list[final_task_count].catalog_type_disp = uar_get_code_display(ta2.catalog_type_cd)
      ENDIF
      reply->task_list[final_task_count].catalog_cd = ta2.catalog_cd
      IF (ta2.location_cd > 0)
       reply->task_list[final_task_count].location_cd = ta2.location_cd, reply->task_list[
       final_task_count].location_mean = uar_get_code_meaning(ta2.location_cd), reply->task_list[
       final_task_count].location_disp = uar_get_code_display(ta2.location_cd)
      ENDIF
      reply->task_list[final_task_count].reference_task_id = ta2.reference_task_id
      IF (ta2.task_type_cd > 0)
       reply->task_list[final_task_count].task_type_cd = ta2.task_type_cd, reply->task_list[
       final_task_count].task_type_mean = uar_get_code_meaning(ta2.task_type_cd), reply->task_list[
       final_task_count].task_type_disp = uar_get_code_display(ta2.task_type_cd)
      ENDIF
      IF (ta2.task_class_cd > 0)
       reply->task_list[final_task_count].task_class_cd = ta2.task_class_cd, reply->task_list[
       final_task_count].task_class_mean = uar_get_code_meaning(ta2.task_class_cd), reply->task_list[
       final_task_count].task_class_disp = uar_get_code_display(ta2.task_class_cd)
      ENDIF
      IF (ta2.task_status_cd > 0)
       reply->task_list[final_task_count].task_status_cd = ta2.task_status_cd, reply->task_list[
       final_task_count].task_status_mean = uar_get_code_meaning(ta2.task_status_cd), reply->
       task_list[final_task_count].task_status_disp = uar_get_code_display(ta2.task_status_cd)
      ENDIF
      IF (ta2.task_status_reason_cd > 0)
       reply->task_list[final_task_count].task_status_reason_cd = ta2.task_status_reason_cd, reply->
       task_list[final_task_count].task_status_reason_mean = uar_get_code_meaning(ta2
        .task_status_reason_cd), reply->task_list[final_task_count].task_status_reason_disp =
       uar_get_code_display(ta2.task_status_reason_cd)
      ENDIF
      reply->task_list[final_task_count].task_dt_tm = ta2.task_dt_tm, reply->task_list[
      final_task_count].task_tz = ta2.task_tz, reply->task_list[final_task_count].event_id = ta2
      .event_id
      IF (ta2.task_activity_cd > 0)
       reply->task_list[final_task_count].task_activity_cd = ta2.task_activity_cd, reply->task_list[
       final_task_count].task_activity_mean = uar_get_code_meaning(ta2.task_activity_cd), reply->
       task_list[final_task_count].task_activity_disp = uar_get_code_display(ta2.task_activity_cd)
      ENDIF
      reply->task_list[final_task_count].msg_text_id = ta2.msg_text_id, reply->task_list[
      final_task_count].msg_subject_cd = ta2.msg_subject_cd, reply->task_list[final_task_count].
      msg_subject = ta2.msg_subject,
      reply->task_list[final_task_count].msg_sender_id = ta2.msg_sender_id, reply->task_list[
      final_task_count].confidential_ind = ta2.confidential_ind, reply->task_list[final_task_count].
      read_ind = ta2.read_ind,
      reply->task_list[final_task_count].delivery_ind = ta2.delivery_ind
      IF (ta2.event_class_cd > 0)
       reply->task_list[final_task_count].event_class_cd = ta2.event_class_cd, reply->task_list[
       final_task_count].event_class_mean = uar_get_code_meaning(ta2.event_class_cd), reply->
       task_list[final_task_count].event_class_disp = uar_get_code_display(ta2.event_class_cd)
      ENDIF
      reply->task_list[final_task_count].task_create_dt_tm = ta2.task_create_dt_tm, reply->task_list[
      final_task_count].updt_cnt = ta2.updt_cnt, reply->task_list[final_task_count].updt_dt_tm = ta2
      .updt_dt_tm,
      reply->task_list[final_task_count].updt_id = ta2.updt_id, reply->task_list[final_task_count].
      reschedule_ind = ta2.reschedule_ind
      IF (ta2.reschedule_reason_cd > 0)
       reply->task_list[final_task_count].reschedule_reason_cd = ta2.reschedule_reason_cd, reply->
       task_list[final_task_count].reschedule_reason_mean = uar_get_code_meaning(ta2
        .reschedule_reason_cd), reply->task_list[final_task_count].reschedule_reason_disp =
       uar_get_code_display(ta2.reschedule_reason_cd)
      ENDIF
      reply->task_list[final_task_count].person_id = ta2.person_id, reply->task_list[final_task_count
      ].encntr_id = ta2.encntr_id, reply->task_list[final_task_count].container_id = ta2.container_id
      IF (ta2.loc_bed_cd > 0)
       reply->task_list[final_task_count].loc_bed_cd = ta2.loc_bed_cd, reply->task_list[
       final_task_count].loc_bed_mean = uar_get_code_meaning(ta2.loc_bed_cd), reply->task_list[
       final_task_count].loc_bed_disp = uar_get_code_display(ta2.loc_bed_cd)
      ENDIF
      IF (ta2.loc_room_cd > 0)
       reply->task_list[final_task_count].loc_room_cd = ta2.loc_room_cd, reply->task_list[
       final_task_count].loc_room_mean = uar_get_code_meaning(ta2.loc_room_cd), reply->task_list[
       final_task_count].loc_room_disp = uar_get_code_display(ta2.loc_room_cd)
      ENDIF
      reply->task_list[final_task_count].order_id = ta2.order_id, reply->task_list[final_task_count].
      med_order_type_cd = ta2.med_order_type_cd, reply->task_list[final_task_count].
      template_task_flag = ta2.template_task_flag
      IF (ta2.task_priority_cd > 0)
       reply->task_list[final_task_count].task_priority_cd = ta2.task_priority_cd, reply->task_list[
       final_task_count].task_priority_mean = uar_get_code_meaning(ta2.task_priority_cd), reply->
       task_list[final_task_count].task_priority_disp = uar_get_code_display(ta2.task_priority_cd)
      ENDIF
      reply->task_list[final_task_count].task_security_flag = secure_task_rec->task_list[d2.seq].
      task_security_flag
      IF ((((reply->task_list[final_task_count].task_class_cd=task_class_prn)) OR ((((reply->
      task_list[final_task_count].task_class_cd=task_class_continuous)) OR ((reply->task_list[
      final_task_count].task_class_cd=task_class_nonscheduled))) ))
       AND (reply->task_list[final_task_count].task_status_cd=task_status_pending)
       AND (reply->task_list[final_task_count].task_dt_tm < cnvtdatetime(sysdate)))
       reply->task_list[final_task_count].task_dt_tm = cnvtdatetime(sysdate)
      ENDIF
      reply->task_list[final_task_count].charted_by_agent_cd = ta2.charted_by_agent_cd, reply->
      task_list[final_task_count].charted_by_agent_identifier = ta2.charted_by_agent_identifier,
      reply->task_list[final_task_count].charting_context_reference = ta2.charting_context_reference,
      reply->task_list[final_task_count].result_set_id = ta2.result_set_id, reply->task_list[
      final_task_count].scheduled_dt_tm = ta2.scheduled_dt_tm, reply->task_list[final_task_count].
      comments = ta2.comments,
      reply->task_list[final_task_count].suggested_entity_name = ta2.suggested_entity_name, reply->
      task_list[final_task_count].suggested_entity_id = ta2.suggested_entity_id, reply->task_list[
      final_task_count].source_tag = ta2.source_tag,
      reply->task_list[final_task_count].performed_prsnl_id = ta2.performed_prsnl_id, assign_count =
      0
     DETAIL
      assign_count += 1
      IF (mod(assign_count,10)=1)
       stat = alterlist(reply->task_list[final_task_count].assign_prsnl_list,(assign_count+ 9))
      ENDIF
      reply->task_list[final_task_count].assign_prsnl_list[assign_count].assign_prsnl_id = taa2
      .assign_prsnl_id, reply->task_list[final_task_count].assign_prsnl_list[assign_count].
      assign_prsnl_name = p.name_full_formatted, reply->task_list[final_task_count].
      assign_prsnl_list[assign_count].updt_cnt = taa2.updt_cnt
     FOOT  ta2.task_id
      stat = alterlist(reply->task_list[final_task_count].assign_prsnl_list,assign_count)
     FOOT REPORT
      stat = 0
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 DECLARE program_version_dcp_get_order_task_info = vc WITH private, constant("005")
 IF (size(reply->task_list,5) > 0)
  DECLARE charting_agent_cnt = i4 WITH noconstant(0)
  SET nstart = 1
  SET ntotal2 = size(reply->task_list,5)
  SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
  SET stat = alterlist(reply->task_list,ntotal)
  FOR (idx = (ntotal2+ 1) TO ntotal)
    SET reply->task_list[idx].reference_task_id = reply->task_list[ntotal2].reference_task_id
  ENDFOR
  SELECT INTO "nl:"
   index = locateval(num1,1,ntotal2,ot.reference_task_id,reply->task_list[num1].reference_task_id)
   FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    order_task ot
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
    JOIN (ot
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ot.reference_task_id,reply->task_list[idx].
     reference_task_id))
   ORDER BY index
   HEAD index
    index1 = locateval(num1,1,ntotal2,ot.reference_task_id,reply->task_list[num1].reference_task_id)
    WHILE (index1 != 0)
      reply->task_list[index1].task_description = ot.task_description, reply->task_list[index1].
      chart_not_cmplt_ind = ot.chart_not_cmplt_ind, reply->task_list[index1].quick_chart_done_ind =
      ot.quick_chart_done_ind,
      reply->task_list[index1].quick_chart_ind = ot.quick_chart_ind, reply->task_list[index1].
      quick_chart_notdone_ind = ot.quick_chart_notdone_ind, reply->task_list[index1].cernertask_flag
       = ot.cernertask_flag,
      reply->task_list[index1].event_cd = ot.event_cd, reply->task_list[index1].reschedule_time = ot
      .reschedule_time, reply->task_list[index1].dcp_forms_ref_id = ot.dcp_forms_ref_id,
      reply->task_list[index1].capture_bill_info_ind = ot.capture_bill_info_ind, reply->task_list[
      index1].ignore_req_ind = ot.ignore_req_ind, reply->task_list[index1].allpositionchart_ind = ot
      .allpositionchart_ind,
      reply->task_list[index1].grace_period_mins = ot.grace_period_mins
      IF ((reply->task_list[index1].allpositionchart_ind=1))
       reply->task_list[index1].ability_ind = 1
      ENDIF
      index1 = locateval(num1,(index1+ 1),ntotal2,ot.reference_task_id,reply->task_list[num1].
       reference_task_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET nstart = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    task_charting_agent_r tcar
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
    JOIN (tcar
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),tcar.reference_task_id,reply->task_list[idx].
     reference_task_id))
   HEAD tcar.reference_task_id
    charting_agent_cnt = 0
   DETAIL
    charting_agent_cnt += 1, index = locateval(num1,1,ntotal2,tcar.reference_task_id,reply->
     task_list[num1].reference_task_id)
    WHILE (index != 0)
      stat = alterlist(reply->task_list[index].charting_agent_list,charting_agent_cnt), reply->
      task_list[index].charting_agent_list[charting_agent_cnt].charting_agent_cd = tcar
      .charting_agent_cd, reply->task_list[index].charting_agent_list[charting_agent_cnt].
      charting_agent_entity_name = tcar.charting_agent_entity_name,
      reply->task_list[index].charting_agent_list[charting_agent_cnt].charting_agent_entity_id = tcar
      .charting_agent_entity_id, reply->task_list[index].charting_agent_list[charting_agent_cnt].
      charting_agent_identifier = tcar.charting_agent_identifier, index = locateval(num1,(index+ 1),
       ntotal2,tcar.reference_task_id,reply->task_list[num1].reference_task_id)
    ENDWHILE
   WITH nocounter
  ;end select
  IF ((request->user_position_cd > 0))
   SET nstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_task_position_xref otp
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (otp
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),otp.reference_task_id,reply->task_list[idx].
      reference_task_id)
      AND (otp.position_cd=request->user_position_cd))
    DETAIL
     index = locateval(num1,1,ntotal2,otp.reference_task_id,reply->task_list[num1].reference_task_id)
     WHILE (index != 0)
      reply->task_list[index].ability_ind = 1,index = locateval(num1,(index+ 1),ntotal2,otp
       .reference_task_id,reply->task_list[num1].reference_task_id)
     ENDWHILE
    WITH nocounter
   ;end select
  ENDIF
  SET stat = alterlist(reply->task_list,ntotal2)
 ENDIF
 SET context->more_data_ind = 0
 SET context->last_person_id = 0
 SET reply->more_data_ind = 0
 IF (error(errmsg,0))
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "TASK_ACTIVITY"
  SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
 ELSEIF (final_task_count > 0)
  SET reply->status_data.status = "S"
  IF ((secure_task_count >= request->dcp_task_limit))
   SET reply->more_data_ind = 1
   SET context->more_data_ind = 1
   SET context->last_person_id = reply->task_list[final_task_count].person_id
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 FREE RECORD internal_task_rec
 FREE RECORD cve_request
 FREE RECORD cve_reply
 FREE RECORD sec_req_info
END GO
