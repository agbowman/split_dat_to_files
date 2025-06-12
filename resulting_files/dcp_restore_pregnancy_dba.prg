CREATE PROGRAM dcp_restore_pregnancy:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD chkrequest(
   1 person_id = f8
   1 lookback_days = i4
   1 encntr_id = f8
   1 org_sec_override = i2
 )
 RECORD temp_instance(
   1 pregnancy_id = f8
   1 org_id = f8
   1 beg_effective_dt_tm = dq8
   1 confirmed_dt_tm = dq8
   1 confirmed_tz = f8
   1 end_effective_dt_tm = dq8
   1 override_comment = vc
   1 person_id = f8
   1 preg_start_dt_tm = dq8
   1 preg_end_dt_tm = dq8
   1 problem_id = f8
   1 sensitive_ind = i2
   1 pregnancy_instance_id = f8
   1 children[*]
     2 child_id = f8
 )
 FREE RECORD probrequest
 RECORD probrequest(
   1 person_id = f8
   1 problem[*]
     2 problem_action_ind = i2
     2 problem_id = f8
     2 problem_instance_id = f8
     2 nomenclature_id = f8
     2 annotated_display = vc
     2 organization_id = f8
     2 source_vocabulary_cd = f8
     2 source_identifier = vc
     2 problem_ftdesc = vc
     2 classification_cd = f8
     2 confirmation_status_cd = f8
     2 qualifier_cd = f8
     2 life_cycle_status_cd = f8
     2 life_cycle_dt_tm = dq8
     2 life_cycle_dt_flag = i2
     2 life_cycle_dt_cd = f8
     2 persistence_cd = f8
     2 certainty_cd = f8
     2 ranking_cd = f8
     2 probability = f8
     2 onset_dt_flag = i2
     2 onset_dt_cd = f8
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 course_cd = f8
     2 severity_class_cd = f8
     2 severity_cd = f8
     2 severity_ftdesc = vc
     2 prognosis_cd = f8
     2 person_aware_cd = f8
     2 family_aware_cd = f8
     2 person_aware_prognosis_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 status_upt_precision_flag = i2
     2 status_upt_precision_cd = f8
     2 status_upt_dt_tm = dq8
     2 cancel_reason_cd = f8
     2 originating_nomenclature_id = f8
     2 problem_comment[*]
       3 problem_comment_id = f8
       3 comment_action_ind = i2
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
       3 comment_prsnl_name = vc
       3 problem_comment = vc
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 problem_discipline[*]
       3 discipline_action_ind = i2
       3 problem_discipline_id = f8
       3 management_discipline_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 problem_prsnl[*]
       3 prsnl_action_ind = i2
       3 problem_reltn_dt_tm = dq8
       3 problem_reltn_cd = f8
       3 problem_prsnl_id = f8
       3 problem_reltn_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
     2 secondary_desc_list[*]
       3 group_sequence = i4
       3 group[*]
         4 secondary_desc_id = f8
         4 nomenclature_id = f8
         4 sequence = i4
     2 problem_uuid = vc
     2 problem_instance_uuid = vc
     2 contributor_system_cd = f8
     2 problem_type_flag = i2
     2 show_in_pm_history_ind = i2
   1 skip_fsi_trigger = i2
 )
 SUBROUTINE (reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) =null)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE (fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) =null)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt += 1
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE failure_ind = i2 WITH protect, noconstant(false)
 DECLARE zero_ind = i2 WITH protect, noconstant(false)
 DECLARE related_doc_cd = f8 WITH constant(uar_get_code_by("MEANING",4002108,"RELATEDDOC")), protect
 DECLARE dyn_label_cd = f8 WITH constant(uar_get_code_by("MEANING",4002108,"FETALLABEL")), protect
 DECLARE reopen_cd = f8 WITH constant(uar_get_code_by("MEANING",4002114,"REOPEN")), protect
 DECLARE active_prob_cd = f8 WITH constant(uar_get_code_by("MEANING",12030,"ACTIVE")), protect
 DECLARE active_label_cd = f8 WITH constant(uar_get_code_by("MEANING",4002015,"ACTIVE")), protect
 DECLARE inerror_label_cd = f8 WITH constant(uar_get_code_by("MEANING",4002015,"INERROR")), protect
 DECLARE stat = i4 WITH noconstant(0), protected
 DECLARE current_dt_tm = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE new_preg_inst_id = f8 WITH protect, noconstant(0.0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE annotated_display = vc WITH protect, noconstant("")
 DECLARE validaterequest() = null
 DECLARE clearpreviouspreginstance() = null
 DECLARE createnewpreginstance() = null
 DECLARE clearrelateddocuments() = null
 DECLARE clearrelatedchildren() = null
 DECLARE clearrelatedlabels() = null
 DECLARE reactivateproblem() = null
 DECLARE logpregnancyaction() = null
 DECLARE reactivatedynamiclabels() = null
 SET reply->status_data.status = "F"
 CALL validaterequest(null)
 CALL clearpreviouspreginstance(null)
 CALL createnewpreginstance(null)
 CALL clearrelateddocuments(null)
 CALL clearrelatedchildren(null)
 CALL reactivateproblem(null)
 CALL logpregnancyaction(null)
 CALL reactivatedynamiclabels(null)
 CALL echo("*Reopen pregnancy completed succesfully*")
#failure
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL reportfailure("ERROR","F","DCP_RESTORE_PREGNANCY",serrormsg)
  ROLLBACK
 ELSEIF (failure_ind=true)
  CALL echo("*Reactivate Pregnancy Script failed*")
  ROLLBACK
 ELSEIF (zero_ind=true)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  EXECUTE srvrtl
  EXECUTE crmrtl
  DECLARE happ = i4 WITH private, noconstant(0)
  DECLARE htask = i4 WITH private, noconstant(0)
  DECLARE hreq = i4 WITH private, noconstant(0)
  DECLARE hrequest = i4 WITH protect, noconstant(0)
  DECLARE probcount = i4 WITH private, noconstant(0)
  DECLARE disciplinecount = i4 WITH private, noconstant(0)
  DECLARE personnelcount = i4 WITH private, noconstant(0)
  DECLARE commentcount = i4 WITH private, noconstant(0)
  DECLARE lcrmstatus = i4 WITH private, noconstant(0)
  SET stat = uar_crmbeginapp(4170101,happ)
  IF (stat != 0)
   RETURN
  ENDIF
  SET stat = uar_crmbegintask(happ,4170147,htask)
  IF (stat != 0)
   CALL uar_crmendapp(happ)
   RETURN
  ENDIF
  SET stat = uar_crmbeginreq(htask,"kia_prb_outbound_async",4170168,hreq)
  IF (stat != 0)
   CALL uar_crmendtask(htask)
   CALL uar_crmendapp(happ)
   RETURN
  ENDIF
  SET hrequest = uar_crmgetrequest(hreq)
  IF (hrequest)
   SET probcount = 0
   CALL echo("Test problem")
   CALL echo(kia_do_ob_add)
   CALL echorecord(kia_ob_add)
   IF (kia_do_ob_add=true)
    SET stat = uar_srvsetdouble(hrequest,"person_id",kia_ob_add->person_id)
    WHILE (probcount < size(kia_ob_add->problem,5))
      SET probcount += 1
      SET hproblemitem = uar_srvadditem(hrequest,"problem")
      IF (hproblemitem)
       SET stat = uar_srvsetshort(hproblemitem,"ob_action_ind",1)
       SET stat = uar_srvsetdouble(hproblemitem,"interface_action_cd",kia_ob_add->problem[probcount].
        interface_action_cd)
       SET stat = uar_srvsetdouble(hproblemitem,"problem_id",kia_ob_add->problem[probcount].
        problem_id)
       SET stat = uar_srvsetdouble(hproblemitem,"problem_instance_id",kia_ob_add->problem[probcount].
        problem_instance_id)
       SET stat = uar_srvsetstring(hproblemitem,"problem_uuid",kia_ob_add->problem[probcount].
        problem_uuid)
       SET stat = uar_srvsetstring(hproblemitem,"problem_instance_uuid",kia_ob_add->problem[probcount
        ].problem_instance_uuid)
       SET stat = uar_srvsetdouble(hproblemitem,"contributor_system_cd",kia_ob_add->problem[probcount
        ].contributor_system_cd)
       SET disciplinecount = 0
       WHILE (disciplinecount < size(kia_ob_add->problem[probcount].discipline,5))
         SET disciplinecount += 1
         SET hdisciplineitem = uar_srvadditem(hproblemitem,"discipline")
         IF (hdisciplineitem)
          SET stat = uar_srvsetdouble(hdisciplineitem,"interface_action_cd",kia_ob_add->problem[
           probcount].discipline[disciplinecount].interface_action_cd)
          SET stat = uar_srvsetdouble(hdisciplineitem,"problem_discipline_id",kia_ob_add->problem[
           probcount].discipline[disciplinecount].problem_discipline_id)
         ENDIF
       ENDWHILE
       SET personnelcount = 0
       WHILE (personnelcount < size(kia_ob_add->problem[probcount].prsnl,5))
         SET personnelcount += 1
         SET hprsnlitem = uar_srvadditem(hproblemitem,"prsnl")
         IF (hprsnlitem)
          SET stat = uar_srvsetdouble(hprsnlitem,"interface_action_cd",kia_ob_add->problem[probcount]
           .prsnl[personnelcount].interface_action_cd)
          SET stat = uar_srvsetdouble(hprsnlitem,"problem_prsnl_id",kia_ob_add->problem[probcount].
           prsnl[personnelcount].problem_prsnl_id)
         ENDIF
       ENDWHILE
       SET commentcount = 0
       WHILE (commentcount < size(kia_ob_add->problem[probcount].comment,5))
         SET commentcount += 1
         SET hcommentitem = uar_srvadditem(hproblemitem,"comment")
         IF (hcommentitem)
          SET stat = uar_srvsetdouble(hcommentitem,"problem_comment_id",kia_ob_add->problem[probcount
           ].comment[commentcount].problem_comment_id)
         ENDIF
       ENDWHILE
      ENDIF
    ENDWHILE
   ENDIF
   CALL echorecord(kia_ob_upd)
   SET probcount = 0
   IF (kia_do_ob_upd=true)
    SET stat = uar_srvsetdouble(hrequest,"person_id",kia_ob_upd->person_id)
    WHILE (probcount < size(kia_ob_upd->problem,5))
      SET probcount += 1
      SET hproblemitem = uar_srvadditem(hrequest,"problem")
      IF (hproblemitem)
       SET stat = uar_srvsetshort(hproblemitem,"ob_action_ind",2)
       SET stat = uar_srvsetdouble(hproblemitem,"interface_action_cd",kia_ob_upd->problem[probcount].
        interface_action_cd)
       SET stat = uar_srvsetdouble(hproblemitem,"problem_id",kia_ob_upd->problem[probcount].
        problem_id)
       SET stat = uar_srvsetdouble(hproblemitem,"problem_instance_id",kia_ob_upd->problem[probcount].
        problem_instance_id)
       SET stat = uar_srvsetdouble(hproblemitem,"contributor_system_cd",kia_ob_upd->problem[probcount
        ].contributor_system_cd)
       SET stat = uar_srvsetstring(hproblemitem,"problem_uuid",kia_ob_upd->problem[probcount].
        problem_uuid)
       SET stat = uar_srvsetstring(hproblemitem,"problem_instance_uuid",kia_ob_upd->problem[probcount
        ].problem_instance_uuid)
       SET disciplinecount = 0
       WHILE (disciplinecount < size(kia_ob_upd->problem[probcount].discipline,5))
         SET disciplinecount += 1
         SET hdisciplineitem = uar_srvadditem(hproblemitem,"discipline")
         IF (hdisciplineitem)
          SET stat = uar_srvsetdouble(hdisciplineitem,"interface_action_cd",kia_ob_upd->problem[
           probcount].discipline[disciplinecount].interface_action_cd)
          SET stat = uar_srvsetdouble(hdisciplineitem,"problem_discipline_id",kia_ob_upd->problem[
           probcount].discipline[disciplinecount].problem_discipline_id)
         ENDIF
       ENDWHILE
       SET personnelcount = 0
       WHILE (personnelcount < size(kia_ob_upd->problem[probcount].prsnl,5))
         SET personnelcount += 1
         SET hprsnlitem = uar_srvadditem(hproblemitem,"prsnl")
         IF (hprsnlitem)
          SET stat = uar_srvsetdouble(hprsnlitem,"interface_action_cd",kia_ob_upd->problem[probcount]
           .prsnl[personnelcount].interface_action_cd)
          SET stat = uar_srvsetdouble(hprsnlitem,"problem_prsnl_id",kia_ob_upd->problem[probcount].
           prsnl[personnelcount].problem_prsnl_id)
         ENDIF
       ENDWHILE
       SET commentcount = 0
       WHILE (commentcount < size(kia_ob_upd->problem[probcount].comment,5))
         SET commentcount += 1
         SET hcommentitem = uar_srvadditem(hproblemitem,"comment")
         IF (hcommentitem)
          SET stat = uar_srvsetdouble(hcommentitem,"problem_comment_id",kia_ob_upd->problem[probcount
           ].comment[commentcount].problem_comment_id)
         ENDIF
       ENDWHILE
      ENDIF
    ENDWHILE
   ENDIF
  ENDIF
  SET lcrmstatus = uar_crmperform(hreq)
  CALL uar_crmendreq(hreq)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE validaterequest(null)
   IF ((((request->lookback_days > 1000)) OR ((request->lookback_days <= 0))) )
    CALL echo("[FAIL] invalid lookback days")
    SET failure_ind = true
    GO TO failure
   ENDIF
   CALL echo("[TRACE] checking for pregnancy eligible for reopen")
   SET chkrequest->person_id = request->person_id
   SET chkrequest->encntr_id = request->encntr_id
   SET chkrequest->org_sec_override = request->org_sec_override
   SET chkrequest->lookback_days = request->lookback_days
   EXECUTE dcp_chk_reactivate_preg  WITH replace("REQUEST",chkrequest), replace("REPLY",chkreply)
   IF ((chkreply->status_data.status="F"))
    CALL echo("[FAIL] dcp_chk_reactivate_preg failed")
    SET reply->status_data.subeventstatus.targetobjectname = "dcp_chk_reactivate_preg failed"
    SET failure_ind = true
    GO TO failure
   ELSEIF ((((chkreply->status_data.status="Z")) OR ((chkreply->pregnancy_id <= 0.0))) )
    CALL echo("[ZERO] no eligible candidate found for reopen")
    SET reply->status_data.subeventstatus.targetobjectvalue =
    "No reopen candidates exist.  This might be because there is an active pregnancy"
    SET zero_ind = true
    GO TO failure
   ENDIF
   CALL echo(build("[TRACE] pregnancy id: ",chkreply->pregnancy_id))
 END ;Subroutine
 SUBROUTINE clearpreviouspreginstance(null)
   IF ((chkreply->pregnancy_id <= 0.0))
    SET failure_ind = true
    GO TO failure
   ENDIF
   CALL echo("[TRACE] removing old pregnancy instance...")
   SELECT INTO "nl:"
    FROM pregnancy_instance pi
    WHERE (pi.pregnancy_id=chkreply->pregnancy_id)
    ORDER BY pi.beg_effective_dt_tm DESC
    HEAD REPORT
     temp_instance->pregnancy_instance_id = pi.pregnancy_instance_id, temp_instance->pregnancy_id =
     pi.pregnancy_id, temp_instance->org_id = pi.organization_id,
     temp_instance->beg_effective_dt_tm = pi.beg_effective_dt_tm, temp_instance->confirmed_dt_tm = pi
     .confirmed_dt_tm, temp_instance->confirmed_tz = pi.confirmed_tz,
     temp_instance->end_effective_dt_tm = pi.end_effective_dt_tm, temp_instance->override_comment =
     pi.override_comment, temp_instance->person_id = pi.person_id,
     temp_instance->preg_end_dt_tm = pi.preg_end_dt_tm, temp_instance->preg_start_dt_tm = pi
     .preg_start_dt_tm, temp_instance->problem_id = pi.problem_id
    WITH nocounter
   ;end select
   CALL echorecord(temp_instance)
   IF (curqual <= 0)
    CALL echo("[FAIL] Unable to find the pregnancy to copy!")
    SET failure_ind = true
    GO TO failure
   ENDIF
   UPDATE  FROM pregnancy_instance pi
    SET pi.historical_ind = false, pi.active_ind = false, pi.end_effective_dt_tm = cnvtdatetime(
      current_dt_tm),
     pi.updt_dt_tm = cnvtdatetime(current_dt_tm), pi.updt_id = reqinfo->updt_id, pi.updt_task =
     reqinfo->updt_task,
     pi.updt_applctx = reqinfo->updt_applctx, pi.updt_cnt = (pi.updt_cnt+ 1)
    WHERE (pi.pregnancy_instance_id=temp_instance->pregnancy_instance_id)
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE createnewpreginstance(null)
   IF ((chkreply->pregnancy_id <= 0.0))
    SET failure_ind = true
    GO TO failure
   ENDIF
   CALL echo("[TRACE] creating new pregnancy instance...")
   SELECT INTO "nl:"
    j = seq(pregnancy_seq,nextval)
    FROM dual
    DETAIL
     new_preg_inst_id = cnvtreal(j)
    WITH nocounter
   ;end select
   INSERT  FROM pregnancy_instance pi
    SET pi.beg_effective_dt_tm = cnvtdatetime(current_dt_tm), pi.confirmed_dt_tm = cnvtdatetime(
      temp_instance->confirmed_dt_tm), pi.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     pi.override_comment = temp_instance->override_comment, pi.person_id = temp_instance->person_id,
     pi.organization_id = temp_instance->org_id,
     pi.pregnancy_id = temp_instance->pregnancy_id, pi.pregnancy_instance_id = new_preg_inst_id, pi
     .preg_end_dt_tm = cnvtdatetime("31-DEC-2100"),
     pi.preg_start_dt_tm = cnvtdatetime(temp_instance->preg_start_dt_tm), pi.problem_id =
     temp_instance->problem_id, pi.sensitive_ind = temp_instance->sensitive_ind,
     pi.historical_ind = false, pi.active_ind = true, pi.updt_dt_tm = cnvtdatetime(current_dt_tm),
     pi.updt_id = reqinfo->updt_id, pi.updt_task = reqinfo->updt_task, pi.updt_applctx = reqinfo->
     updt_applctx,
     pi.updt_cnt = 0
    WITH nocounter
   ;end insert
   UPDATE  FROM pregnancy_instance pi
    SET pi.confirmed_tz = temp_instance->confirmed_tz
    WHERE pi.pregnancy_instance_id=new_preg_inst_id
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE clearrelateddocuments(null)
  CALL echo("[TRACE] removing old related documents...")
  UPDATE  FROM pregnancy_entity_r pe
   SET pe.active_ind = false, pe.updt_dt_tm = cnvtdatetime(current_dt_tm), pe.updt_id = reqinfo->
    updt_id,
    pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.updt_cnt = (
    updt_cnt+ 1)
   WHERE (pe.pregnancy_instance_id=temp_instance->pregnancy_instance_id)
    AND pe.component_type_cd=related_doc_cd
    AND pe.parent_entity_name="CLINICAL_EVENT"
    AND pe.active_ind=true
   WITH nocounter
  ;end update
 END ;Subroutine
 SUBROUTINE clearrelatedlabels(null)
  CALL echo("[TRACE] removing old related labels...")
  UPDATE  FROM pregnancy_entity_r pe
   SET pe.active_ind = false, pe.updt_dt_tm = cnvtdatetime(current_dt_tm), pe.updt_id = reqinfo->
    updt_id,
    pe.updt_task = reqinfo->updt_task, pe.updt_applctx = reqinfo->updt_applctx, pe.updt_cnt = (
    updt_cnt+ 1)
   WHERE (pe.pregnancy_instance_id=chkreply->pregnancy_instance_id)
    AND pe.component_type_cd=dyn_label_cd
    AND pe.parent_entity_name="CE_DYNAMIC_LABEL"
    AND pe.active_ind=true
   WITH nocounter
  ;end update
 END ;Subroutine
 SUBROUTINE clearrelatedchildren(null)
   CALL echo("[TRACE] removing old pregnancy children...")
   SELECT INTO "nl:"
    FROM pregnancy_child pc
    WHERE (pc.pregnancy_instance_id=temp_instance->pregnancy_instance_id)
     AND pc.active_ind=true
    HEAD REPORT
     stat = alterlist(temp_instance->children,5), cnt = 0
    DETAIL
     cnt += 1
     IF (mod(size(temp_instance->children,5),5))
      stat = alterlist(temp_instance->children,(cnt+ 4))
     ENDIF
     temp_instance->children[cnt].child_id = pc.pregnancy_child_id
    FOOT REPORT
     stat = alterlist(temp_instance->children,cnt)
    WITH nocounter
   ;end select
   DECLARE idx = i4 WITH noconstant(0), protected
   UPDATE  FROM pregnancy_child pc
    SET pc.active_ind = false, pc.updt_dt_tm = cnvtdatetime(current_dt_tm), pc.updt_id = reqinfo->
     updt_id,
     pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (
     updt_cnt+ 1),
     pc.end_effective_dt_tm = cnvtdatetime(current_dt_tm)
    WHERE expand(idx,1,size(temp_instance->children,5),pc.pregnancy_child_id,temp_instance->children[
     idx].child_id)
    WITH nocounter
   ;end update
   UPDATE  FROM pregnancy_child_entity_r ce
    SET ce.active_ind = false, ce.updt_dt_tm = cnvtdatetime(current_dt_tm), ce.updt_id = reqinfo->
     updt_id,
     ce.updt_task = reqinfo->updt_task, ce.updt_applctx = reqinfo->updt_applctx, ce.updt_cnt = (
     updt_cnt+ 1),
     ce.end_effective_dt_tm = cnvtdatetime(current_dt_tm)
    WHERE expand(idx,1,size(temp_instance->children,5),ce.pregnancy_child_id,temp_instance->children[
     idx].child_id)
     AND active_ind=true
    WITH nocounter
   ;end update
 END ;Subroutine
 SUBROUTINE reactivateproblem(null)
   CALL echo(build("problemid: ",temp_instance->problem_id))
   SET stat = alterlist(probrequest->problem,1)
   SELECT INTO "nl:"
    FROM problem p,
     problem_comment pc
    PLAN (p
     WHERE (p.problem_id=temp_instance->problem_id)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (pc
     WHERE (pc.problem_id= Outerjoin(p.problem_id)) )
    HEAD REPORT
     probrequest->person_id = p.person_id, probrequest->skip_fsi_trigger = 1, probrequest->problem[1]
     .problem_action_ind = 2,
     probrequest->problem[1].problem_id = p.problem_id, probrequest->problem[1].problem_instance_id
      = p.problem_instance_id, probrequest->problem[1].nomenclature_id = p.nomenclature_id,
     probrequest->problem[1].confirmation_status_cd = p.confirmation_status_cd, probrequest->problem[
     1].life_cycle_status_cd = active_prob_cd, probrequest->problem[1].life_cycle_dt_tm = p
     .life_cycle_dt_tm,
     probrequest->problem[1].life_cycle_dt_cd = p.life_cycle_dt_cd, probrequest->problem[1].
     life_cycle_dt_flag = p.life_cycle_dt_flag, probrequest->problem[1].onset_dt_tm = p.onset_dt_tm,
     probrequest->problem[1].onset_tz = p.onset_tz, probrequest->problem[1].problem_type_flag = 2,
     probrequest->problem[1].annotated_display = p.annotated_display,
     probrequest->problem[1].classification_cd = p.classification_cd, stat = alterlist(probrequest->
      problem[1].problem_comment,5), comment_cnt = 0
    DETAIL
     IF (pc.problem_comment_id > 0)
      comment_cnt += 1
      IF (mod(comment_cnt,5)=1)
       stat = alterlist(probrequest->problem[1].problem_comment,(comment_cnt+ 4))
      ENDIF
      probrequest->problem[1].problem_comment[comment_cnt].comment_action_ind = 2, probrequest->
      problem[1].problem_comment[comment_cnt].problem_comment_id = pc.problem_comment_id, probrequest
      ->problem[1].problem_comment[comment_cnt].comment_dt_tm = pc.comment_dt_tm,
      probrequest->problem[1].problem_comment[comment_cnt].comment_tz = pc.comment_tz, probrequest->
      problem[1].problem_comment[comment_cnt].comment_prsnl_id = pc.comment_prsnl_id, probrequest->
      problem[1].problem_comment[comment_cnt].problem_comment = pc.problem_comment
     ENDIF
    FOOT REPORT
     stat = alterlist(probrequest->problem[1].problem_comment,comment_cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo("[FAIL] unable to find previous problem")
    SET reply->status_data.subeventstatus.targetobjectvalue = "Unable to find inactive problem"
    SET failure_ind = true
    GO TO failure
   ENDIF
   DECLARE comment_size = i4 WITH noconstant((size(probrequest->problem[1].problem_comment,5)+ 1))
   SET stat = alterlist(probrequest->problem[1].problem_comment,comment_size)
   SET probrequest->problem[1].problem_comment[comment_size].comment_action_ind = 1
   SET probrequest->problem[1].problem_comment[comment_size].comment_dt_tm = cnvtdatetime(
    current_dt_tm)
   SET probrequest->problem[1].problem_comment[comment_size].comment_prsnl_id = request->prsnl_id
   SET probrequest->problem[1].problem_comment[comment_size].problem_comment = request->
   problem_comment[1].problem_comment_text
   SET probrequest->problem[1].problem_comment[comment_size].comment_prsnl_name = request->
   problem_comment[1].comment_prsnl_name
   SELECT DISTINCT INTO "nl"
    FROM problem_prsnl_r pr
    WHERE (pr.problem_id=temp_instance->problem_id)
     AND pr.active_ind=true
    HEAD REPORT
     stat = alterlist(probrequest->problem[1].problem_prsnl,5), prsnl_cnt = 0
    DETAIL
     prsnl_cnt += 1
     IF (mod(prsnl_cnt,5)=1)
      stat = alterlist(probrequest->problem[1].problem_prsnl,(prsnl_cnt+ 4))
     ENDIF
     probrequest->problem[1].problem_prsnl[prsnl_cnt].beg_effective_dt_tm = pr.beg_effective_dt_tm,
     probrequest->problem[1].problem_prsnl[prsnl_cnt].end_effective_dt_tm = pr.end_effective_dt_tm,
     probrequest->problem[1].problem_prsnl[prsnl_cnt].problem_reltn_cd = pr.problem_reltn_cd,
     probrequest->problem[1].problem_prsnl[prsnl_cnt].problem_reltn_dt_tm = pr.problem_reltn_dt_tm,
     probrequest->problem[1].problem_prsnl[prsnl_cnt].prsnl_action_ind = 2, probrequest->problem[1].
     problem_prsnl[prsnl_cnt].problem_prsnl_id = pr.problem_prsnl_id
    FOOT REPORT
     stat = alterlist(probrequest->problem[1].problem_prsnl,prsnl_cnt)
    WITH nocounter
   ;end select
   CALL echo("[TRACE] reactivating problem...")
   EXECUTE kia_ens_problem  WITH replace("REQUEST",probrequest), replace("REPLY",probreply)
   IF ((probreply->status_data.status="F"))
    CALL echo("[FAIL] failed problem ensure!")
    SET reply->status_data.subeventstatus.targetobjectvalue =
    "kia_ens_problem returned a status of F"
    SET failure_ind = true
    GO TO failure
   ENDIF
 END ;Subroutine
 SUBROUTINE logpregnancyaction(null)
   CALL echo("[TRACE] logging reopen action")
   DECLARE new_seq = f8 WITH noconstant(0.0)
   SELECT INTO "nl:"
    j = seq(pregnancy_seq,nextval)
    FROM dual
    DETAIL
     new_seq = cnvtreal(j)
    WITH nocounter
   ;end select
   INSERT  FROM pregnancy_action pa
    SET pa.prsnl_id = request->prsnl_id, pa.pregnancy_id = temp_instance->pregnancy_id, pa
     .pregnancy_action_id = new_seq,
     pa.action_dt_tm = cnvtdatetime(current_dt_tm), pa.action_tz = request->action_tz, pa
     .action_type_cd = reopen_cd,
     pa.pregnancy_instance_id = new_preg_inst_id, pa.updt_id = reqinfo->updt_id, pa.updt_applctx =
     reqinfo->updt_applctx,
     pa.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE reactivatedynamiclabels(null)
   RECORD dynamic_labels(
     1 labels[*]
       2 pregnancy_entity_id = f8
       2 ce_dynamic_label_id = f8
       2 new_dynamic_label_id = f8
       2 prev_dynamic_label_id = f8
       2 label_name = vc
       2 old_label_prsnl_id = f8
       2 new_label_prsnl_id = f8
       2 label_template_id = f8
       2 label_status_cd = f8
       2 label_comment = vc
       2 person_id = f8
       2 result_set_id = f8
       2 valid_from_dt_tm = dq8
       2 label_seq_nbr = i4
       2 create_dt_tm = dq8
       2 long_text_id = f8
   )
   DECLARE label_cnt = i4 WITH noconstant(0), protected
   SELECT DISTINCT INTO "nl:"
    FROM pregnancy_entity_r pe,
     ce_dynamic_label dl
    PLAN (pe
     WHERE (pe.pregnancy_instance_id=chkreply->pregnancy_instance_id)
      AND pe.component_type_cd=dyn_label_cd
      AND pe.parent_entity_name="CE_DYNAMIC_LABEL"
      AND pe.active_ind=true)
     JOIN (dl
     WHERE dl.ce_dynamic_label_id=pe.parent_entity_id
      AND dl.label_status_cd != active_label_cd
      AND dl.label_status_cd != inerror_label_cd)
    ORDER BY dl.prev_dynamic_label_id, dl.valid_until_dt_tm DESC
    HEAD REPORT
     label_cnt = 0
    HEAD dl.prev_dynamic_label_id
     counter = 0
    DETAIL
     counter += 1
     IF (counter=1)
      label_cnt += 1
      IF (label_cnt > size(dynamic_labels->labels,5))
       stat = alterlist(dynamic_labels->labels,(label_cnt+ 4))
      ENDIF
      dynamic_labels->labels[label_cnt].pregnancy_entity_id = pe.pregnancy_entity_id, dynamic_labels
      ->labels[label_cnt].ce_dynamic_label_id = dl.ce_dynamic_label_id, dynamic_labels->labels[
      label_cnt].prev_dynamic_label_id = dl.prev_dynamic_label_id,
      dynamic_labels->labels[label_cnt].label_name = dl.label_name, dynamic_labels->labels[label_cnt]
      .old_label_prsnl_id = dl.label_prsnl_id, dynamic_labels->labels[label_cnt].new_label_prsnl_id
       = request->prsnl_id,
      dynamic_labels->labels[label_cnt].label_status_cd = dl.label_status_cd, dynamic_labels->labels[
      label_cnt].label_template_id = dl.label_template_id, dynamic_labels->labels[label_cnt].
      person_id = dl.person_id,
      dynamic_labels->labels[label_cnt].result_set_id = dl.result_set_id, dynamic_labels->labels[
      label_cnt].valid_from_dt_tm = dl.valid_from_dt_tm, dynamic_labels->labels[label_cnt].
      label_seq_nbr = dl.label_seq_nbr,
      dynamic_labels->labels[label_cnt].long_text_id = dl.long_text_id, dynamic_labels->labels[
      label_cnt].create_dt_tm = dl.create_dt_tm
     ENDIF
    FOOT REPORT
     stat = alterlist(dynamic_labels->labels,label_cnt)
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    new_seq = seq(ocf_seq,nextval)
    FROM (dummyt d1  WITH seq = label_cnt),
     dual d
    PLAN (d1)
     JOIN (d
     WHERE 1=1)
    DETAIL
     dynamic_labels->labels[d1.seq].new_dynamic_label_id = new_seq
    WITH nocounter
   ;end select
   UPDATE  FROM ce_dynamic_label dl,
     (dummyt d  WITH seq = value(label_cnt))
    SET dl.valid_until_dt_tm = cnvtdatetimeutc(cnvtdatetime("31-DEC-2100")), dl.label_status_cd =
     active_label_cd, dl.label_prsnl_id = reqinfo->updt_id,
     dl.updt_dt_tm = cnvtdatetime(current_dt_tm), dl.updt_task = reqinfo->updt_task, dl.updt_id =
     reqinfo->updt_id,
     dl.updt_applctx = reqinfo->updt_applctx, dl.updt_cnt = (dl.updt_cnt+ 1)
    PLAN (d)
     JOIN (dl
     WHERE (dl.ce_dynamic_label_id=dynamic_labels->labels[d.seq].ce_dynamic_label_id))
    WITH nocounter
   ;end update
   IF (curqual != label_cnt)
    SET reply->status_data.subeventstatus.operationname = "UPDATE"
    SET reply->status_data.subeventstatus.operationstatus = "F"
    SET reply->status_data.subeventstatus.targetobjectname = "CE_DYNAMIC_LABEL"
    SET reply->status_data.subeventstatus.targetobjectvalue =
    "Unexpected results while updating labels"
    SET failure_ind = true
    GO TO failure
   ENDIF
   INSERT  FROM ce_dynamic_label dl,
     (dummyt d  WITH seq = value(label_cnt))
    SET dl.ce_dynamic_label_id = dynamic_labels->labels[d.seq].new_dynamic_label_id, dl
     .prev_dynamic_label_id = dynamic_labels->labels[d.seq].prev_dynamic_label_id, dl.label_name =
     dynamic_labels->labels[d.seq].label_name,
     dl.label_prsnl_id = dynamic_labels->labels[d.seq].old_label_prsnl_id, dl.label_status_cd =
     dynamic_labels->labels[d.seq].label_status_cd, dl.person_id = dynamic_labels->labels[d.seq].
     person_id,
     dl.result_set_id = dynamic_labels->labels[d.seq].result_set_id, dl.label_template_id =
     dynamic_labels->labels[d.seq].label_template_id, dl.valid_from_dt_tm = cnvtdatetime(
      dynamic_labels->labels[d.seq].valid_from_dt_tm),
     dl.valid_until_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,(curtime3 - 1))), dl.label_seq_nbr
      = dynamic_labels->labels[d.seq].label_seq_nbr, dl.create_dt_tm = cnvtdatetime(dynamic_labels->
      labels[d.seq].create_dt_tm),
     dl.updt_dt_tm = cnvtdatetime(current_dt_tm), dl.updt_task = reqinfo->updt_task, dl.updt_id =
     reqinfo->updt_id,
     dl.updt_applctx = reqinfo->updt_applctx, dl.updt_cnt = 0
    PLAN (d)
     JOIN (dl)
    WITH nocounter
   ;end insert
   IF (curqual != label_cnt)
    SET reply->status_data.subeventstatus.operationname = "INSERT"
    SET reply->status_data.subeventstatus.operationstatus = "F"
    SET reply->status_data.subeventstatus.targetobjectname = "CE_DYNAMIC_LABEL"
    SET reply->status_data.subeventstatus.targetobjectvalue =
    "Unexpected results while inserting new labels"
    SET failure_ind = true
    GO TO failure
   ENDIF
   CALL clearrelatedlabels(null)
   CALL echo("[TRACE] label update complete")
 END ;Subroutine
END GO
