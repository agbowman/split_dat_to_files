CREATE PROGRAM bhs_sys_rte_forward_result
 RECORD work(
   1 updt_id = f8
   1 updt_dt_tm = dq8
   1 updt_applctx = i4
   1 updt_task = i4
   1 action_type_cd = f8
   1 event_id = f8
   1 clinical_event_id = f8
   1 prsnl_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 event_class_cd = f8
   1 ce_event_prsnl_id = f8
   1 event_prsnl_id = f8
   1 ce_event_action_modifier_id = f8
   1 event_action_modifier_id = f8
   1 task_id = f8
   1 task_activity_assign_id = f8
   1 status_ind = i2
   1 errmsg = vc
 )
 RECORD recdate(
   1 datetime = dq8
 )
 RECORD request_0560300(
   1 person_id = f8
   1 encntr_id = f8
   1 stat_ind = i2
   1 task_type_cd = f8
   1 task_type_meaning = c12
   1 reference_task_id = f8
   1 task_dt_tm = dq8
   1 task_activity_meaning = c12
   1 msg_text = c32768
   1 msg_subject_cd = f8
   1 msg_subject = c255
   1 confidential_ind = i2
   1 read_ind = i2
   1 delivery_ind = i2
   1 event_id = f8
   1 event_class_meaning = c12
   1 order_id = f8
   1 catalog_cd = f8
   1 task_class_cd = f8
   1 med_order_type_cd = f8
   1 catalog_type_cd = f8
   1 assign_prsnl_list[*]
     2 assign_prsnl_id = f8
   1 task_status_meaning = c12
   1 charted_by_agent_cd = f8
   1 charted_by_agent_identifier = c255
   1 charting_context_reference = c255
   1 result_set_id = f8
 )
 RECORD reply_0560300(
   1 task_status = c1
   1 task_id = f8
   1 assign_prsnl_list[*]
     2 assign_prsnl_id = f8
 )
 DECLARE ce_event_action_modifier_bit = i4 WITH constant(29)
 DECLARE cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cs21_sign_cd = f8 WITH constant(uar_get_code_by("MEANING",21,"SIGN"))
 DECLARE cs21_review_cd = f8 WITH constant(uar_get_code_by("MEANING",21,"REVIEW"))
 DECLARE cs79_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE cs103_requested_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"REQUESTED"))
 DECLARE cs6026_endorse_cd = f8 WITH constant(uar_get_code_by("MEANING",6026,"ENDORSE"))
 DECLARE cs254550_forward_cd = f8 WITH constant(uar_get_code_by("MEANING",254550,"FORWARD"))
 SET work->updt_id = 1.00
 SET work->updt_dt_tm = sysdate
 SET work->updt_applctx = 0
 SET work->updt_task = 0
 SET request_0560300->task_dt_tm = work->updt_dt_tm
 SET request_0560300->task_type_cd = cs6026_endorse_cd
 SET request_0560300->task_type_meaning = "ENDORSE"
 SET request_0560300->task_status_meaning = "PENDING"
 DECLARE var_action_type = vc
 IF (reflect(parameter(3,0)) <= " ")
  CALL echo(build2("No action type (parameter 3) passed in. Default will be used"))
  SET var_action_type = "REVIEW"
 ELSE
  SET var_action_type = parameter(3,0)
  SET var_action_type = trim(cnvtupper(var_action_type),4)
 ENDIF
 IF ( NOT (var_action_type IN ("SIGN", "REVIEW")))
  CALL echo(build2("Invalid action type passed in (",var_action_type,"). ","Default will be used"))
  SET var_action_type = "REVIEW"
 ENDIF
 CALL echo(build2("Action Type = ",trim(var_action_type,3)))
 IF (var_action_type="SIGN")
  SET work->action_type_cd = cs21_sign_cd
  SET request_0560300->task_activity_meaning = "SIGN RESULT"
 ELSE
  SET work->action_type_cd = cs21_review_cd
  SET request_0560300->task_activity_meaning = "REVIEW RESUL"
 ENDIF
 FREE SET var_action_type
#check_prsnl_id
 IF (cnvtreal(parameter(2,0)) <= 0.00)
  SET work->status_ind = - (1)
  SET work->errmsg = build2("Invalid Prsnl ID ",trim(build2(parameter(2,0)),3)," passed in")
  GO TO exit_script
 ELSE
  SET work->prsnl_id = cnvtreal(parameter(2,0))
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE (pr.person_id=work->prsnl_id)
    AND pr.active_ind=1)
  HEAD REPORT
   ap_cnt = 0
  DETAIL
   ap_cnt = (size(request_0560300->assign_prsnl_list,5)+ 1), stat = alterlist(request_0560300->
    assign_prsnl_list,ap_cnt), request_0560300->assign_prsnl_list[ap_cnt].assign_prsnl_id = pr
   .person_id
  WITH nocounter
 ;end select
 IF (size(request_0560300->assign_prsnl_list,5) <= 0)
  SET work->status_ind = - (1)
  SET work->errmsg = build2("Prsnl ID ",trim(build2(work->prsnl_id),3)," not found")
  GO TO exit_script
 ENDIF
#check_event_id
 IF (cnvtreal(parameter(1,0)) <= 0.00)
  SET work->status_ind = - (1)
  SET work->errmsg = build2("Invalid Event ID ",trim(build2(parameter(1,0)),3)," passed in")
  GO TO exit_script
 ELSE
  SET work->event_id = cnvtreal(parameter(1,0))
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.event_id=work->event_id)
    AND ce.valid_until_dt_tm >= cnvtdatetime(work->updt_dt_tm)
    AND ce.record_status_cd=value(uar_get_code_by("MEANING",48,"ACTIVE")))
  DETAIL
   work->clinical_event_id = ce.clinical_event_id, work->person_id = ce.person_id, work->encntr_id =
   ce.encntr_id,
   work->event_class_cd = ce.event_class_cd, request_0560300->event_id = work->event_id,
   request_0560300->person_id = work->person_id,
   request_0560300->encntr_id = work->encntr_id, request_0560300->event_class_meaning = trim(
    uar_get_code_meaning(work->event_class_cd),3)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET work->status_ind = - (1)
  SET work->errmsg = build2("Event ID ",trim(build2(work->event_id),3)," not found")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cep.ce_event_prsnl_id
  FROM ce_event_prsnl cep
  PLAN (cep
   WHERE (cep.event_id=work->event_id)
    AND cep.valid_until_dt_tm >= cnvtdatetime(work->updt_dt_tm)
    AND (cep.action_prsnl_id=work->prsnl_id)
    AND (cep.action_type_cd=work->action_type_cd)
    AND cep.action_status_cd=cs103_requested_cd)
  DETAIL
   work->event_prsnl_id = cep.event_prsnl_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET work->status_ind = - (1)
  SET work->errmsg = build2("Event ID ",trim(build2(work->event_id),3)," already forwarded to ",
   "Prsnl ID ",trim(build2(work->prsnl_id),3),
   " (event_prsnl_id: ",trim(build2(work->event_prsnl_id),3),")")
  GO TO exit_script
 ENDIF
#grab_new_ocf_ids
 SELECT INTO "nl:"
  nextid = seq(ocf_seq,nextval)
  FROM dual d
  DETAIL
   work->ce_event_prsnl_id = nextid
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET work->status_ind = - (1)
  SET work->errmsg = "Unable to get next OCF_SEQ value"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  nextid = seq(ocf_seq,nextval)
  FROM dual d
  DETAIL
   work->event_prsnl_id = nextid
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET work->status_ind = - (1)
  SET work->errmsg = "Unable to get next OCF_SEQ value"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  nextid = seq(ocf_seq,nextval)
  FROM dual d
  DETAIL
   work->ce_event_action_modifier_id = nextid
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET work->status_ind = - (1)
  SET work->errmsg = "Unable to get next OCF_SEQ value"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  nextid = seq(ocf_seq,nextval)
  FROM dual d
  DETAIL
   work->event_action_modifier_id = nextid
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET work->status_ind = - (1)
  SET work->errmsg = "Unable to get next OCF_SEQ value"
  GO TO exit_script
 ENDIF
#get_reference_task
 SELECT INTO "nl:"
  FROM order_task ot
  PLAN (ot
   WHERE ot.task_description="Sign Result")
  DETAIL
   request_0560300->reference_task_id = ot.reference_task_id
  WITH nocounter
 ;end select
 IF ((request_0560300->reference_task_id <= 0.00))
  SET work->status_ind = - (1)
  SET work->errmsg = build2("Unable to get 'Sign Result' reference_task_id ",
   "(used for both sign and review actions)")
  GO TO exit_script
 ENDIF
#add_new_task
 DECLARE crmstatus = i4 WITH public, noconstant(0)
 DECLARE statusvalue = c1 WITH public, noconstant(" ")
 DECLARE appnum = i4 WITH public, constant(961000)
 DECLARE tasknum = i4 WITH public, constant(560300)
 DECLARE reqnum = i4 WITH public, constant(560300)
 DECLARE happ = i4 WITH public, noconstant(0)
 DECLARE htask = i4 WITH public, noconstant(0)
 DECLARE hreq = i4 WITH public, noconstant(0)
 DECLARE hstep = i4 WITH public, noconstant(0)
 DECLARE hreply = i4 WITH public, noconstant(0)
 DECLARE hassignlistreq = i4 WITH public, noconstant(0)
 DECLARE hassignlistrep = i4 WITH public, noconstant(0)
 SET crmstatus = uar_crmbeginapp(appnum,happ)
 IF (crmstatus != 0)
  CALL uar_crmendapp(happ)
  ROLLBACK
  SET work->status_ind = - (1)
  SET work->errmsg = build2("uar_crmbeginapp(",trim(build2(appnum),2),", happ) = ",trim(build2(
     crmstatus),3))
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbegintask(happ,tasknum,htask)
 IF (crmstatus != 0)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  ROLLBACK
  SET work->status_ind = - (1)
  SET work->errmsg = build2("uar_crmbegintask(happ, ",trim(build2(tasknum),3),",htask) = ",trim(
    build2(crmstatus),3))
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbeginreq(htask,hreq,reqnum,hstep)
 IF (crmstatus != 0)
  CALL uar_crmendreq(hstep)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  ROLLBACK
  SET work->status_ind = - (1)
  SET work->errmsg = build2("uar_crmbeginreq(htask, hreq, ",trim(build2(reqnum),3),", hstep) = ",trim
   (build2(crmstatus),3))
  GO TO exit_script
 ENDIF
 SET hreq = uar_crmgetrequest(hstep)
 IF (hreq <= 0)
  CALL uar_crmendreq(hstep)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  ROLLBACK
  SET work->status_ind = - (1)
  SET work->errmsg = "uar_crmgetrequest(hstep) failed"
  GO TO exit_script
 ENDIF
 SET stat = uar_srvsetdouble(hreq,"person_id",request_0560300->person_id)
 SET stat = uar_srvsetdouble(hreq,"encntr_id",request_0560300->encntr_id)
 SET stat = uar_srvsetdouble(hreq,"task_type_cd",request_0560300->task_type_cd)
 SET stat = uar_srvsetstring(hreq,"task_type_meaning",nullterm(request_0560300->task_type_meaning))
 SET stat = uar_srvsetdouble(hreq,"reference_task_id",request_0560300->reference_task_id)
 SET stat = uar_srvsetstring(hreq,"task_status_meaning",nullterm(request_0560300->task_status_meaning
   ))
 SET stat = uar_srvsetdouble(hreq,"event_id",request_0560300->event_id)
 SET stat = uar_srvsetstring(hreq,"event_class_meaning",nullterm(request_0560300->event_class_meaning
   ))
 SET stat = uar_srvsetstring(hreq,"task_activity_meaning",nullterm(request_0560300->
   task_activity_meaning))
 SET recdate->datetime = request_0560300->task_dt_tm
 SET stat = uar_srvsetdate2(hreq,"task_dt_tm",recdate)
 FOR (i = 1 TO size(request_0560300->assign_prsnl_list,5))
  SET hassignlistreq = uar_srvadditem(hreq,"assign_prsnl_list")
  SET stat = uar_srvsetdouble(hassignlistreq,"assign_prsnl_id",request_0560300->assign_prsnl_list[i].
   assign_prsnl_id)
 ENDFOR
 SET crmstatus = uar_crmperform(hstep)
 IF (crmstatus != 0)
  CALL uar_crmendreq(hstep)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  ROLLBACK
  SET work->status_ind = - (1)
  SET work->errmsg = build2("uar_crmperform(hstep) = ",trim(build2(crmstatus),3))
  GO TO exit_script
 ENDIF
 SET hreply = uar_crmgetreply(hstep)
 SET reply_0560300->task_status = trim(uar_srvgetstringptr(hreply,"task_status"))
 SET reply_0560300->task_id = uar_srvgetdouble(hreply,"task_id")
 SET stat = alterlist(reply_0560300->assign_prsnl_list,uar_srvgetitemcount(hreply,"assign_prsnl_list"
   ))
 IF (size(reply_0560300->assign_prsnl_list,5) > 0)
  FOR (a = 1 TO size(reply_0560300->assign_prsnl_list,5))
   SET hassignlistrep = uar_srvgetitem(hreply,"assign_prsnl_list",(a - 1))
   SET reply_0560300->assign_prsnl_list[a].assign_prsnl_id = uar_srvgetdouble(hassignlistrep,
    "assign_prsnl_id")
  ENDFOR
 ENDIF
 CALL uar_crmendreq(hstep)
 CALL uar_crmendtask(htask)
 CALL uar_crmendapp(happ)
 IF ((reply_0560300->task_status != "S"))
  ROLLBACK
  SET work->status_ind = - (1)
  SET work->errmsg = build2("Add task (request ",trim(build2(reqnum),3),") failed. ","Status '",
   statusvalue,
   "' (from reply number ",trim(build2(hreply),3),")")
  GO TO exit_script
 ENDIF
#update_ta
 UPDATE  FROM task_activity ta
  SET ta.msg_sender_id = 1.00
  WHERE (ta.task_id=reply_0560300->task_id)
  WITH nocounter
 ;end update
 IF (curqual != size(request_0560300->assign_prsnl_list,5))
  ROLLBACK
  SET work->status_ind = - (1)
  SET work->errmsg = build2("Update to TASK_ACTIVITY_ASSIGNMENT (for task_id ",trim(build2(
     reply_0560300->task_id),3),") failed")
  DELETE  FROM task_activity ta
   WHERE (ta.task_id=reply_0560300->task_id)
  ;end delete
  COMMIT
  DELETE  FROM task_activity_assignment taa
   WHERE (taa.task_id=reply_0560300->task_id)
  ;end delete
  COMMIT
  GO TO exit_script
 ENDIF
#update_taa
 UPDATE  FROM task_activity_assignment taa
  SET taa.task_status_cd = cs79_pending_cd
  WHERE (taa.task_id=reply_0560300->task_id)
  WITH nocounter
 ;end update
 IF (curqual != size(request_0560300->assign_prsnl_list,5))
  ROLLBACK
  SET work->status_ind = - (1)
  SET work->errmsg = build2("Update to TASK_ACTIVITY_ASSIGNMENT (for task_id ",trim(build2(
     reply_0560300->task_id),3),") failed")
  DELETE  FROM task_activity ta
   WHERE (ta.task_id=reply_0560300->task_id)
  ;end delete
  COMMIT
  DELETE  FROM task_activity_assignment taa
   WHERE (taa.task_id=reply_0560300->task_id)
  ;end delete
  COMMIT
  GO TO exit_script
 ENDIF
#update_into_ce
 UPDATE  FROM clinical_event ce
  SET ce.subtable_bit_map = (ce.subtable_bit_map+ (2** ce_event_action_modifier_bit))
  WHERE (work->clinical_event_id=ce.clinical_event_id)
  WITH nocounter
 ;end update
 IF (curqual != 1)
  ROLLBACK
  SET work->status_ind = - (1)
  SET work->errmsg = "Failure inserting into CLINICAL_EVENT"
  DELETE  FROM task_activity ta
   WHERE (ta.task_id=reply_0560300->task_id)
  ;end delete
  COMMIT
  DELETE  FROM task_activity_assignment taa
   WHERE (taa.task_id=reply_0560300->task_id)
  ;end delete
  COMMIT
  GO TO exit_script
 ENDIF
#insert_into_cep
 INSERT  FROM ce_event_prsnl cep
  SET cep.action_prsnl_id = work->prsnl_id, cep.action_status_cd = cs103_requested_cd, cep
   .action_type_cd = work->action_type_cd,
   cep.ce_event_prsnl_id = work->ce_event_prsnl_id, cep.event_id = work->event_id, cep.event_prsnl_id
    = work->event_prsnl_id,
   cep.person_id = work->person_id, cep.request_prsnl_id = 0.00, cep.request_dt_tm = cnvtdatetime(
    work->updt_dt_tm),
   cep.valid_from_dt_tm = cnvtdatetime(curdate,curtime3), cep.valid_until_dt_tm = cnvtdatetime(
    "31-DEC-2100"), cep.updt_id = work->updt_id,
   cep.updt_dt_tm = cnvtdatetime(work->updt_dt_tm), cep.updt_applctx = work->updt_applctx, cep
   .updt_task = work->updt_task
  WITH nocounter
 ;end insert
 IF (curqual != 1)
  ROLLBACK
  SET work->status_ind = - (1)
  SET work->errmsg = "Failure inserting into CE_EVENT_PRSNL"
  DELETE  FROM task_activity ta
   WHERE (ta.task_id=reply_0560300->task_id)
  ;end delete
  COMMIT
  DELETE  FROM task_activity_assignment taa
   WHERE (taa.task_id=reply_0560300->task_id)
  ;end delete
  COMMIT
  GO TO exit_script
 ENDIF
#insert_into_cea
 INSERT  FROM ce_event_action_modifier cea
  SET cea.action_type_modifier_cd = cs254550_forward_cd, cea.ce_event_action_modifier_id = work->
   ce_event_action_modifier_id, cea.event_action_modifier_id = work->event_action_modifier_id,
   cea.event_id = work->event_id, cea.event_prsnl_id = work->event_prsnl_id, cea.valid_from_dt_tm =
   cnvtdatetime(curdate,curtime3),
   cea.valid_until_dt_tm = cnvtdatetime("31-DEC-2100"), cea.updt_id = work->updt_id, cea.updt_dt_tm
    = cnvtdatetime(work->updt_dt_tm),
   cea.updt_applctx = work->updt_applctx, cea.updt_task = work->updt_task
  WITH nocounter
 ;end insert
 IF (curqual != 1)
  ROLLBACK
  SET work->status_ind = - (1)
  SET work->errmsg = "Failure inserting into CE_EVENT_ACTION_MODIFIER"
  DELETE  FROM task_activity ta
   WHERE (ta.task_id=reply_0560300->task_id)
  ;end delete
  COMMIT
  DELETE  FROM task_activity_assignment taa
   WHERE (taa.task_id=reply_0560300->task_id)
  ;end delete
  COMMIT
  GO TO exit_script
 ENDIF
#commit_changes
 IF ((work->status_ind >= 0))
  COMMIT
 ENDIF
#exit_script
 IF (isodbc=0)
  CALL echorecord(request_0560300)
  CALL echorecord(reply_0560300)
  CALL echorecord(work)
  CALL echo(work->errmsg)
 ENDIF
END GO
