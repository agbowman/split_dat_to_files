CREATE PROGRAM dm_pcmb_problem:dba
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 SUBROUTINE (dm_cmb_get_context(dummy=i2) =null)
   SET dm_cmb_cust_script->called_by_readme_ind = 0
   IF (validate(readme_data->status,"b") != "b"
    AND validate(readme_data->message,"CUSTCMBVALIDATE") != "CUSTCMBVALIDATE")
    SET dm_cmb_cust_script->called_by_readme_ind = 1
   ENDIF
   SET dm_cmb_cust_script->exc_maint_ind = 0
   IF ((validate(dcue_context_rec->called_by_dcue_ind,- (11)) != - (11))
    AND (validate(dcue_context_rec->called_by_dcue_ind,- (22)) != - (22)))
    SET dm_cmb_cust_script->exc_maint_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_chk_ccl_def_col(ftbl_name,fcol_name)
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) =null)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 IF ((validate(dcem_request->qual[1].single_encntr_ind,- (1))=- (1)))
  FREE RECORD dcem_request
  RECORD dcem_request(
    1 qual[*]
      2 parent_entity = vc
      2 child_entity = vc
      2 op_type = vc
      2 script_name = vc
      2 single_encntr_ind = i2
      2 script_run_order = i4
      2 del_chg_id_ind = i2
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcem_reply->status,"B")="B")
  FREE RECORD dcem_reply
  RECORD dcem_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 CALL echo("*****dm_cmb_pm_hist_routines.inc - 565951****")
 DECLARE dm_cmb_detect_pm_hist(null) = i4
 SUBROUTINE dm_cmb_detect_pm_hist(null)
   RETURN(1)
 END ;Subroutine
 IF ((validate(dcipht_request->pm_hist_tracking_id,- (9))=- (9)))
  RECORD dcipht_request(
    1 pm_hist_tracking_id = f8
    1 encntr_id = f8
    1 person_id = f8
    1 transaction_type_txt = c3
    1 transaction_reason_txt = c30
  )
 ENDIF
 IF (validate(dcipht_reply->status,"b")="b")
  RECORD dcipht_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 problem_id = f8
     2 end_effective_dt_tm = dq8
     2 originating_encntr_id = f8
     2 update_encntr_id = f8
     2 problem_type_flag = i4
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 problem_id = f8
     2 end_effective_dt_tm = dq8
     2 originating_encntr_id = f8
     2 update_encntr_id = f8
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
     2 problem_comment[*]
       3 problem_comment_id = f8
       3 comment_action_ind = i2
       3 comment_dt_tm = dq8
       3 comment_tz = i4
       3 comment_prsnl_id = f8
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
     2 related_problem_list[*]
       3 active_ind = i2
       3 child_entity_id = f8
       3 reltn_subtype_cd = f8
       3 priority = i4
       3 child_nomen_id = f8
       3 child_ftdesc = vc
     2 laterality_cd = f8
     2 originating_nomenclature_id = f8
     2 onset_tz = i4
   1 user_id = f8
   1 skip_fsi_trigger = i2
   1 interfaced_problems_flag = i2
   1 context_encntr_id = f8
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
 FREE SET probreply
 RECORD probreply(
   1 person_org_sec_on = i2
   1 person_id = f8
   1 problem_list[*]
     2 problem_id = f8
     2 problem_instance_id = f8
     2 problem_ftdesc = vc
     2 nomenclature_id = f8
     2 sreturnmsg = vc
     2 review_dt_tm = dq8
     2 comment_list[*]
       3 problem_comment_id = f8
     2 discipline_list[*]
       3 problem_discipline_id = f8
       3 management_discipline_cd = f8
       3 sreturnmsg = vc
     2 prsnl_list[*]
       3 problem_prsnl_id = f8
       3 problem_reltn_cd = f8
       3 sreturnmsg = vc
     2 problem_uuid = vc
     2 problem_instance_uuid = vc
     2 related_problem_list[*]
       3 active_ind = i2
       3 child_entity_id = f8
       3 reltn_subtype_cd = f8
       3 priority = i4
       3 child_nomen_id = f8
       3 child_ftdesc = vc
     2 beg_effective_dt_tm = dq8
   1 swarnmsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 FREE RECORD encounter_list
 RECORD encounter_list(
   1 qual[*]
     2 encounter_id = f8
 )
 DECLARE v_cust_count1 = i4
 DECLARE v_cust_count2 = i4
 DECLARE v_cust_loopcount = i4
 DECLARE v_cust_loopcount2 = i4
 DECLARE preg_org_id_exists = i2
 DECLARE transfer_no_active_pregs = i2
 DECLARE conflict_org_cnt = i4
 DECLARE conflict_prob_cnt = i4
 DECLARE org_idx = i4
 DECLARE prob_idx = i4
 DECLARE prob_pos = i4
 DECLARE preg_org_sec_ind = i4
 SET v_cust_count1 = 0
 SET v_cust_count2 = 0
 SET v_cust_loopcount = 0
 SET v_cust_loopcount2 = 0
 SET preg_org_id_exists = 0
 SET transfer_no_active_pregs = 0
 SET conflict_org_cnt = 0
 SET conflict_prob_cnt = 0
 SET org_idx = 0
 SET prob_idx = 0
 SET prob_pos = 0
 SET preg_org_sec_ind = 0
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "PROBLEM"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_PROBLEM"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d1,
   dm_info d2
  WHERE d1.info_domain="SECURITY"
   AND d1.info_name="SEC_ORG_RELTN"
   AND d1.info_number=1
   AND d2.info_domain="SECURITY"
   AND d2.info_name="SEC_PREG_ORG_RELTN"
   AND d2.info_number=1
  DETAIL
   preg_org_sec_ind = 1
  WITH nocounter
 ;end select
 FREE SET conflict_orgs
 RECORD conflict_orgs(
   1 orgs[*]
     2 organization_id = f8
 )
 FREE SET conflict_problems
 RECORD conflict_problems(
   1 problems[*]
     2 problem_id = f8
 )
 SELECT
  IF (preg_org_sec_ind=1)
   FROM pregnancy_instance p2
   WHERE (p2.person_id=request->xxx_combine[icombine].to_xxx_id)
    AND p2.active_ind=1
    AND p2.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
    AND p2.organization_id=0
  ELSE
   FROM pregnancy_instance p2
   WHERE (p2.person_id=request->xxx_combine[icombine].to_xxx_id)
    AND p2.active_ind=1
    AND p2.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
  ENDIF
  INTO "nl:"
  DETAIL
   transfer_no_active_pregs = 1
  WITH nocounter
 ;end select
 IF (transfer_no_active_pregs=1)
  SELECT INTO "nl:"
   FROM pregnancy_instance p1
   WHERE (p1.person_id=request->xxx_combine[icombine].from_xxx_id)
    AND p1.active_ind=1
    AND p1.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
   DETAIL
    conflict_prob_cnt += 1
    IF (mod(conflict_prob_cnt,10)=1)
     stat = alterlist(conflict_problems->problems,(conflict_prob_cnt+ 9))
    ENDIF
    conflict_problems->problems[conflict_prob_cnt].problem_id = p1.problem_id
   WITH nocounter
  ;end select
  SET stat = alterlist(conflict_problems->problems,conflict_prob_cnt)
 ELSE
  SELECT INTO "nl:"
   FROM pregnancy_instance p2
   WHERE (p2.person_id=request->xxx_combine[icombine].to_xxx_id)
    AND p2.active_ind=1
    AND p2.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
    AND p2.organization_id > 0
   DETAIL
    conflict_org_cnt += 1
    IF (mod(conflict_org_cnt,10)=1)
     stat = alterlist(conflict_orgs->orgs,(conflict_org_cnt+ 9))
    ENDIF
    IF (conflict_org_cnt=1)
     conflict_orgs->orgs[conflict_org_cnt].organization_id = 0, conflict_org_cnt += 1
    ENDIF
    conflict_orgs->orgs[conflict_org_cnt].organization_id = p2.organization_id
   WITH nocounter
  ;end select
  SET stat = alterlist(conflict_orgs->orgs,conflict_org_cnt)
  SELECT INTO "nl:"
   FROM pregnancy_instance p1
   WHERE (p1.person_id=request->xxx_combine[icombine].from_xxx_id)
    AND p1.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
    AND p1.active_ind=1
    AND expand(org_idx,1,conflict_org_cnt,p1.organization_id,conflict_orgs->orgs[org_idx].
    organization_id)
   DETAIL
    conflict_prob_cnt += 1
    IF (mod(conflict_prob_cnt,10)=1)
     stat = alterlist(conflict_problems->problems,(conflict_prob_cnt+ 9))
    ENDIF
    conflict_problems->problems[conflict_prob_cnt].problem_id = p1.problem_id
   WITH nocounter
  ;end select
  SET stat = alterlist(conflict_problems->problems,conflict_prob_cnt)
 ENDIF
 SELECT
  IF ((request->xxx_combine[icombine].encntr_id=0))
   WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
  ELSE
   WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
    AND (((frm.originating_encntr_id=request->xxx_combine[icombine].encntr_id)) OR ((frm
   .update_encntr_id=request->xxx_combine[icombine].encntr_id)))
  ENDIF
  INTO "nl:"
  frm.*
  FROM problem frm
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.problem_instance_id, rreclist->from_rec[
   v_cust_count1].active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].active_status_cd =
   frm.active_status_cd,
   rreclist->from_rec[v_cust_count1].problem_id = frm.problem_id, rreclist->from_rec[v_cust_count1].
   end_effective_dt_tm = frm.end_effective_dt_tm, rreclist->from_rec[v_cust_count1].
   originating_encntr_id = frm.originating_encntr_id,
   rreclist->from_rec[v_cust_count1].update_encntr_id = frm.update_encntr_id, rreclist->from_rec[
   v_cust_count1].problem_type_flag = frm.problem_type_flag
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  DECLARE request_encounter_id = f8
  DECLARE originating_encntr_id = f8
  DECLARE update_encntr_id = f8
  DECLARE problem_type_flag = i4
  DECLARE active_ind = i4
  SET request_encounter_id = request->xxx_combine[icombine].encntr_id
  SELECT INTO "nl:"
   tu.*
   FROM problem tu
   WHERE (tu.person_id=request->xxx_combine[icombine].to_xxx_id)
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].to_id = tu.problem_instance_id, rreclist->to_rec[v_cust_count2].
    active_ind = tu.active_ind, rreclist->to_rec[v_cust_count2].active_status_cd = tu
    .active_status_cd,
    rreclist->to_rec[v_cust_count2].problem_id = tu.problem_id, rreclist->to_rec[v_cust_count2].
    end_effective_dt_tm = tu.end_effective_dt_tm, rreclist->to_rec[v_cust_count2].
    originating_encntr_id = tu.originating_encntr_id,
    rreclist->to_rec[v_cust_count2].update_encntr_id = tu.update_encntr_id
   WITH forupdatewait(tu)
  ;end select
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
    IF ((rreclist->from_rec[v_cust_loopcount].active_status_cd != combinedaway))
     SET originating_encntr_id = rreclist->from_rec[v_cust_loopcount].originating_encntr_id
     SET update_encntr_id = rreclist->from_rec[v_cust_loopcount].update_encntr_id
     SET problem_type_flag = rreclist->from_rec[v_cust_loopcount].problem_type_flag
     SET active_ind = rreclist->from_rec[v_cust_loopcount].active_ind
     SET prob_pos = locateval(prob_idx,1,conflict_prob_cnt,rreclist->from_rec[v_cust_loopcount].
      problem_id,conflict_problems->problems[prob_idx].problem_id)
     IF (prob_pos > 0)
      IF (del_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
       to_xxx_id,rreclist->from_rec[v_cust_loopcount].active_ind,rreclist->from_rec[v_cust_loopcount]
       .active_status_cd,rreclist->from_rec[v_cust_loopcount].end_effective_dt_tm)=0)
       GO TO exit_sub
      ENDIF
     ELSE
      IF (request_encounter_id != 0)
       IF (((request_encounter_id=originating_encntr_id) OR (request_encounter_id=update_encntr_id))
       )
        IF (request_encounter_id=originating_encntr_id)
         IF (problem_type_flag=2
          AND active_ind=1
          AND originating_encntr_id=update_encntr_id)
          SET stat = initrec(probrequest)
          SET stat = initrec(probreply)
          SET probrequest->skip_fsi_trigger = 1
          SET probrequest->user_id = reqinfo->updt_id
          SET probrequest->interfaced_problems_flag = 0
          SET stat = alterlist(probrequest->problem,1)
          SET probrequest->problem[1].problem_action_ind = 5
          SET probrequest->problem[1].problem_id = rreclist->from_rec[v_cust_loopcount].problem_id
          SET probrequest->problem[1].problem_instance_id = rreclist->from_rec[v_cust_loopcount].
          from_id
          SET probrequest->problem[1].problem_uuid = ""
          SET probrequest->problem[1].problem_instance_uuid = ""
          SELECT INTO "nl:"
           FROM problem p
           WHERE (p.problem_instance_id=rreclist->from_rec[v_cust_loopcount].from_id)
           DETAIL
            probrequest->person_id = p.person_id, probrequest->context_encntr_id = 0, probrequest->
            problem[1].annotated_display = p.annotated_display,
            probrequest->problem[1].beg_effective_dt_tm = p.beg_effective_dt_tm, probrequest->
            problem[1].cancel_reason_cd = p.cancel_reason_cd, probrequest->problem[1].certainty_cd =
            p.certainty_cd,
            probrequest->problem[1].classification_cd = p.classification_cd, probrequest->problem[1].
            confirmation_status_cd = p.confirmation_status_cd, probrequest->problem[1].
            contributor_system_cd = p.contributor_system_cd,
            probrequest->problem[1].course_cd = p.course_cd, probrequest->problem[1].
            end_effective_dt_tm = p.end_effective_dt_tm, probrequest->problem[1].family_aware_cd = p
            .family_aware_cd,
            probrequest->problem[1].laterality_cd = p.laterality_cd, probrequest->problem[1].
            life_cycle_dt_cd = p.life_cycle_dt_cd, probrequest->problem[1].life_cycle_dt_flag = p
            .life_cycle_dt_flag,
            probrequest->problem[1].life_cycle_dt_tm = p.life_cycle_dt_tm, probrequest->problem[1].
            life_cycle_status_cd = p.life_cycle_status_cd, probrequest->problem[1].nomenclature_id =
            p.nomenclature_id,
            probrequest->problem[1].onset_dt_cd = p.onset_dt_cd, probrequest->problem[1].
            onset_dt_flag = p.onset_dt_flag, probrequest->problem[1].onset_dt_tm = p.onset_dt_tm
            IF (validate(p.onset_tz)=1)
             probrequest->problem[1].onset_tz = p.onset_tz
            ENDIF
            probrequest->problem[1].organization_id = p.organization_id, probrequest->problem[1].
            originating_nomenclature_id = p.originating_nomenclature_id, probrequest->problem[1].
            persistence_cd = p.persistence_cd,
            probrequest->problem[1].person_aware_cd = p.person_aware_cd, probrequest->problem[1].
            person_aware_prognosis_cd = p.person_aware_prognosis_cd, probrequest->problem[1].
            probability = p.probability,
            probrequest->problem[1].problem_ftdesc = p.problem_ftdesc, probrequest->problem[1].
            problem_type_flag = p.problem_type_flag, probrequest->problem[1].prognosis_cd = p
            .prognosis_cd,
            probrequest->problem[1].qualifier_cd = p.qualifier_cd, probrequest->problem[1].ranking_cd
             = p.ranking_cd, probrequest->problem[1].severity_cd = p.severity_cd,
            probrequest->problem[1].severity_class_cd = p.severity_class_cd, probrequest->problem[1].
            severity_ftdesc = p.severity_ftdesc, probrequest->problem[1].show_in_pm_history_ind = p
            .show_in_pm_history_ind,
            probrequest->problem[1].status_upt_dt_tm = p.status_updt_dt_tm, probrequest->problem[1].
            status_upt_precision_cd = p.status_updt_precision_cd, probrequest->problem[1].
            status_upt_precision_flag = p.status_updt_flag
           WITH maxqual(p,1)
          ;end select
          IF (curqual > 0)
           EXECUTE kia_ens_problem  WITH replace("REQUEST",probrequest), replace("REPLY",probreply)
           IF ((probreply->status_data.status="F"))
            SET failed = update_error
            SET request->error_message = substring(1,132,build(
              "Could not update problem table with                                   		problem instance ID = ",
              rreclist->from_rec[v_cust_loopcount].from_id))
            GO TO exit_sub
           ENDIF
           CALL update_dm_combine_details(probreply->problem_list[1].problem_instance_id,add)
          ENDIF
         ELSEIF (problem_type_flag != 2)
          SET update_encntr_id = originating_encntr_id
          IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
           to_xxx_id,originating_encntr_id,update_encntr_id)=0)
           GO TO exit_sub
          ENDIF
         ENDIF
        ELSE
         DECLARE updateproblemid = f8 WITH public, noconstant(0.0)
         DECLARE frompersonid = f8 WITH public, noconstant(0.0)
         DECLARE ppr_cnt = i4 WITH public, noconstant(0)
         DECLARE prob_type_flag = i2 WITH public, noconstant(0)
         SET probrequest->person_id = request->xxx_combine[icombine].to_xxx_id
         SET probrequest->skip_fsi_trigger = 1
         SET probrequest->user_id = reqinfo->updt_id
         SET probrequest->context_encntr_id = update_encntr_id
         SET probrequest->interfaced_problems_flag = 0
         SET stat = alterlist(probrequest->problem,1)
         SET probrequest->problem[1].problem_action_ind = 4
         SET probrequest->problem[1].problem_id = - (1)
         SET probrequest->problem[1].problem_instance_id = 0
         SET probrequest->problem[1].problem_uuid = ""
         SET probrequest->problem[1].problem_instance_uuid = ""
         SELECT INTO "nl:"
          FROM problem p
          WHERE (p.problem_instance_id=rreclist->from_rec[v_cust_loopcount].from_id)
           AND p.active_ind=1
           AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
           AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
          ORDER BY p.problem_id
          HEAD p.problem_id
           updateproblemid = p.problem_id, frompersonid = p.person_id, prob_type_flag = p
           .problem_type_flag,
           probrequest->problem[1].annotated_display = p.annotated_display, probrequest->problem[1].
           beg_effective_dt_tm = p.beg_effective_dt_tm, probrequest->problem[1].cancel_reason_cd = p
           .cancel_reason_cd,
           probrequest->problem[1].certainty_cd = p.certainty_cd, probrequest->problem[1].
           classification_cd = p.classification_cd, probrequest->problem[1].confirmation_status_cd =
           p.confirmation_status_cd,
           probrequest->problem[1].contributor_system_cd = p.contributor_system_cd, probrequest->
           problem[1].course_cd = p.course_cd, probrequest->problem[1].end_effective_dt_tm = p
           .end_effective_dt_tm,
           probrequest->problem[1].family_aware_cd = p.family_aware_cd, probrequest->problem[1].
           laterality_cd = p.laterality_cd, probrequest->problem[1].life_cycle_dt_cd = p
           .life_cycle_dt_cd,
           probrequest->problem[1].life_cycle_dt_flag = p.life_cycle_dt_flag, probrequest->problem[1]
           .life_cycle_dt_tm = p.life_cycle_dt_tm, probrequest->problem[1].life_cycle_status_cd = p
           .life_cycle_status_cd,
           probrequest->problem[1].nomenclature_id = p.nomenclature_id, probrequest->problem[1].
           onset_dt_cd = p.onset_dt_cd, probrequest->problem[1].onset_dt_flag = p.onset_dt_flag,
           probrequest->problem[1].onset_dt_tm = p.onset_dt_tm
           IF (validate(p.onset_tz)=1)
            probrequest->problem[1].onset_tz = p.onset_tz
           ENDIF
           probrequest->problem[1].organization_id = p.organization_id, probrequest->problem[1].
           originating_nomenclature_id = p.originating_nomenclature_id, probrequest->problem[1].
           persistence_cd = p.persistence_cd,
           probrequest->problem[1].person_aware_cd = p.person_aware_cd, probrequest->problem[1].
           person_aware_prognosis_cd = p.person_aware_prognosis_cd, probrequest->problem[1].
           probability = p.probability,
           probrequest->problem[1].problem_ftdesc = p.problem_ftdesc, probrequest->problem[1].
           problem_type_flag = p.problem_type_flag, probrequest->problem[1].prognosis_cd = p
           .prognosis_cd,
           probrequest->problem[1].qualifier_cd = p.qualifier_cd, probrequest->problem[1].ranking_cd
            = p.ranking_cd, probrequest->problem[1].severity_cd = p.severity_cd,
           probrequest->problem[1].severity_class_cd = p.severity_class_cd, probrequest->problem[1].
           severity_ftdesc = p.severity_ftdesc, probrequest->problem[1].show_in_pm_history_ind = p
           .show_in_pm_history_ind,
           probrequest->problem[1].status_upt_dt_tm = p.status_updt_dt_tm, probrequest->problem[1].
           status_upt_precision_cd = p.status_updt_precision_cd, probrequest->problem[1].
           status_upt_precision_flag = p.status_updt_flag
          WITH nocounter
         ;end select
         IF (curqual > 0)
          IF (prob_type_flag != 2)
           SELECT INTO "nl:"
            FROM problem_prsnl_r ppr
            WHERE ppr.problem_id=updateproblemid
             AND ppr.active_ind=1
             AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
            ORDER BY ppr.problem_prsnl_id
            HEAD REPORT
             ppr_cnt = 0
            HEAD ppr.problem_prsnl_id
             IF (ppr.problem_prsnl_id > 0)
              ppr_cnt += 1
              IF (mod(ppr_cnt,10)=1)
               stat = alterlist(probrequest->problem[1].problem_prsnl,(ppr_cnt+ 9))
              ENDIF
              probrequest->problem[1].problem_prsnl[ppr_cnt].prsnl_action_ind = 4, probrequest->
              problem[1].problem_prsnl[ppr_cnt].problem_prsnl_id = - (1), probrequest->problem[1].
              problem_prsnl[ppr_cnt].problem_reltn_prsnl_id = ppr.problem_reltn_prsnl_id,
              probrequest->problem[1].problem_prsnl[ppr_cnt].problem_reltn_dt_tm = cnvtdatetime(ppr
               .problem_reltn_dt_tm), probrequest->problem[1].problem_prsnl[ppr_cnt].problem_reltn_cd
               = ppr.problem_reltn_cd, probrequest->problem[1].problem_prsnl[ppr_cnt].
              beg_effective_dt_tm = cnvtdatetime(ppr.beg_effective_dt_tm),
              probrequest->problem[1].problem_prsnl[ppr_cnt].end_effective_dt_tm = cnvtdatetime(ppr
               .end_effective_dt_tm)
             ENDIF
            FOOT REPORT
             stat = alterlist(probrequest->problem[1].problem_prsnl,ppr_cnt)
            WITH nocounter
           ;end select
           DECLARE pc_cnt = i4 WITH public, noconstant(0)
           SELECT INTO "nl:"
            *
            FROM problem_comment pc
            WHERE pc.problem_id=updateproblemid
             AND pc.active_ind=1
             AND pc.beg_effective_dt_tm <= cnvtdatetime(sysdate)
             AND pc.end_effective_dt_tm > cnvtdatetime(sysdate)
            ORDER BY pc.problem_id, pc.comment_dt_tm DESC, pc.problem_comment_id
            HEAD REPORT
             pc_cnt = 0
            DETAIL
             pc_cnt += 1
             IF (mod(pc_cnt,10)=1)
              stat = alterlist(probrequest->problem[1].problem_comment,(pc_cnt+ 9))
             ENDIF
             probrequest->problem[1].problem_comment[pc_cnt].comment_action_ind = 4, probrequest->
             problem[1].problem_comment[pc_cnt].problem_comment_id = - (1), probrequest->problem[1].
             problem_comment[pc_cnt].problem_comment = pc.problem_comment,
             probrequest->problem[1].problem_comment[pc_cnt].comment_prsnl_id = pc.comment_prsnl_id
             IF (validate(pc.comment_tz)=1)
              probrequest->problem[1].problem_comment[pc_cnt].comment_tz = pc.comment_tz
             ENDIF
             probrequest->problem[1].problem_comment[pc_cnt].beg_effective_dt_tm = cnvtdatetime(pc
              .beg_effective_dt_tm), probrequest->problem[1].problem_comment[pc_cnt].comment_dt_tm =
             cnvtdatetime(pc.comment_dt_tm), probrequest->problem[1].problem_comment[pc_cnt].
             end_effective_dt_tm = cnvtdatetime(pc.end_effective_dt_tm)
            FOOT REPORT
             stat = alterlist(probrequest->problem[1].problem_comment,pc_cnt)
            WITH nocounter
           ;end select
           DECLARE pd_cnt = i4 WITH public, noconstant(0)
           SELECT INTO "nl:"
            pd.management_discipline_cd, pd.beg_effective_dt_tm, pd.end_effective_dt_tm
            FROM problem_discipline pd
            WHERE pd.problem_id=updateproblemid
             AND pd.active_ind=1
             AND pd.beg_effective_dt_tm <= cnvtdatetime(sysdate)
             AND pd.end_effective_dt_tm > cnvtdatetime(sysdate)
            ORDER BY pd.problem_id, pd.problem_discipline_id
            HEAD REPORT
             pd_cnt = 0
            DETAIL
             pd_cnt += 1
             IF (mod(pd_cnt,10)=1)
              stat = alterlist(probrequest->problem[1].problem_discipline,(pd_cnt+ 9))
             ENDIF
             probrequest->problem[1].problem_discipline[pd_cnt].discipline_action_ind = 4,
             probrequest->problem[1].problem_discipline[pd_cnt].problem_discipline_id = - (1),
             probrequest->problem[1].problem_discipline[pd_cnt].management_discipline_cd = pd
             .management_discipline_cd,
             probrequest->problem[1].problem_discipline[pd_cnt].beg_effective_dt_tm = cnvtdatetime(pd
              .beg_effective_dt_tm), probrequest->problem[1].problem_discipline[pd_cnt].
             end_effective_dt_tm = cnvtdatetime(pd.end_effective_dt_tm)
            FOOT REPORT
             stat = alterlist(probrequest->problem[1].problem_discipline,pd_cnt)
            WITH nocounter
           ;end select
           DECLARE sec_desc_cnt = i4 WITH public, noconstant(0)
           DECLARE group_cnt = i4 WITH public, noconstant(0)
           SELECT INTO "nl:"
            pm.parent_entity_id, pm.parent_entity_name, pm.group_seq,
            pm.sequence, pm.nomenclature_id
            FROM proc_modifier pm
            WHERE pm.parent_entity_name="PROBLEM"
             AND pm.parent_entity_id=updateproblemid
             AND pm.active_ind=1
             AND pm.beg_effective_dt_tm <= cnvtdatetime(sysdate)
             AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
            ORDER BY pm.group_seq, pm.sequence
            HEAD REPORT
             sec_desc_cnt = 0
            HEAD pm.group_seq
             sec_desc_cnt += 1
             IF (mod(sec_desc_cnt,10)=1)
              stat = alterlist(probrequest->problem[1].secondary_desc_list,(sec_desc_cnt+ 9))
             ENDIF
             probrequest->problem[1].secondary_desc_list[sec_desc_cnt].group_sequence = pm.group_seq,
             group_cnt = 0
            HEAD pm.sequence
             group_cnt += 1
             IF (mod(group_cnt,10)=1)
              stat = alterlist(probrequest->problem[1].secondary_desc_list[sec_desc_cnt].group,(
               group_cnt+ 9))
             ENDIF
             probrequest->problem[1].secondary_desc_list[sec_desc_cnt].group[group_cnt].
             secondary_desc_id = 0.0, probrequest->problem[1].secondary_desc_list[sec_desc_cnt].
             group[group_cnt].nomenclature_id = pm.nomenclature_id, probrequest->problem[1].
             secondary_desc_list[sec_desc_cnt].group[group_cnt].sequence = pm.sequence
            FOOT REPORT
             stat = alterlist(probrequest->problem[1].secondary_desc_list[sec_desc_cnt].group,
              group_cnt), stat = alterlist(probrequest->problem[1].secondary_desc_list,sec_desc_cnt)
            WITH nocounter
           ;end select
           EXECUTE kia_ens_problem  WITH replace("REQUEST",probrequest), replace("REPLY",probreply)
           IF ((probreply->status_data.status="F"))
            SET failed = insert_error
            SET request->error_message = probreply->swarnmsg
            GO TO exit_sub
           ENDIF
           CALL update_dm_combine_details(probreply->problem_list[1].problem_instance_id,add)
          ENDIF
          DECLARE encounter_size = i4
          SELECT DISTINCT INTO "n1:"
           e.encntr_id
           FROM encounter e
           WHERE e.person_id=frompersonid
            AND e.encntr_id != update_encntr_id
           HEAD REPORT
            count = 0
           DETAIL
            count += 1
            IF (mod(count,10)=1)
             stat = alterlist(encounter_list->qual,(count+ 9))
            ENDIF
            encounter_list->qual[count].encounter_id = e.encntr_id
           FOOT REPORT
            stat = alterlist(encounter_list->qual,count)
           WITH nocounter
          ;end select
          DECLARE expand_index = i4 WITH protect, noconstant(0)
          SET stat = initrec(probrequest)
          SET stat = initrec(probreply)
          SET encounter_size = size(encounter_list->qual,5)
          IF (curqual > 0)
           SET probrequest->person_id = frompersonid
           SET probrequest->skip_fsi_trigger = 1
           SET probrequest->user_id = reqinfo->updt_id
           SET probrequest->interfaced_problems_flag = 0
           SET stat = alterlist(probrequest->problem,1)
           SET probrequest->problem[1].problem_action_ind = 5
           SET probrequest->problem[1].problem_id = updateproblemid
           SET probrequest->problem[1].problem_instance_id = rreclist->from_rec[v_cust_loopcount].
           from_id
           SET probrequest->problem[1].problem_uuid = ""
           SET probrequest->problem[1].problem_instance_uuid = ""
           SELECT INTO "nl:"
            FROM problem p
            WHERE p.problem_id=updateproblemid
             AND p.active_ind=0
             AND ((expand(expand_index,1,encounter_size,p.update_encntr_id,encounter_list->qual[
             expand_index].encounter_id)) OR (p.problem_type_flag=2
             AND p.originating_encntr_id=0
             AND p.update_encntr_id=0))
            ORDER BY p.updt_dt_tm DESC
            DETAIL
             probrequest->context_encntr_id = p.update_encntr_id, probrequest->problem[1].
             annotated_display = p.annotated_display, probrequest->problem[1].beg_effective_dt_tm = p
             .beg_effective_dt_tm,
             probrequest->problem[1].cancel_reason_cd = p.cancel_reason_cd, probrequest->problem[1].
             certainty_cd = p.certainty_cd, probrequest->problem[1].classification_cd = p
             .classification_cd,
             probrequest->problem[1].confirmation_status_cd = p.confirmation_status_cd, probrequest->
             problem[1].contributor_system_cd = p.contributor_system_cd, probrequest->problem[1].
             course_cd = p.course_cd,
             probrequest->problem[1].end_effective_dt_tm = p.end_effective_dt_tm, probrequest->
             problem[1].family_aware_cd = p.family_aware_cd, probrequest->problem[1].laterality_cd =
             p.laterality_cd,
             probrequest->problem[1].life_cycle_dt_cd = p.life_cycle_dt_cd, probrequest->problem[1].
             life_cycle_dt_flag = p.life_cycle_dt_flag, probrequest->problem[1].life_cycle_dt_tm = p
             .life_cycle_dt_tm,
             probrequest->problem[1].life_cycle_status_cd = p.life_cycle_status_cd, probrequest->
             problem[1].nomenclature_id = p.nomenclature_id, probrequest->problem[1].onset_dt_cd = p
             .onset_dt_cd,
             probrequest->problem[1].onset_dt_flag = p.onset_dt_flag, probrequest->problem[1].
             onset_dt_tm = p.onset_dt_tm
             IF (validate(p.onset_tz)=1)
              probrequest->problem[1].onset_tz = p.onset_tz
             ENDIF
             probrequest->problem[1].organization_id = p.organization_id, probrequest->problem[1].
             originating_nomenclature_id = p.originating_nomenclature_id, probrequest->problem[1].
             persistence_cd = p.persistence_cd,
             probrequest->problem[1].person_aware_cd = p.person_aware_cd, probrequest->problem[1].
             person_aware_prognosis_cd = p.person_aware_prognosis_cd, probrequest->problem[1].
             probability = p.probability,
             probrequest->problem[1].problem_ftdesc = p.problem_ftdesc, probrequest->problem[1].
             problem_type_flag = p.problem_type_flag, probrequest->problem[1].prognosis_cd = p
             .prognosis_cd,
             probrequest->problem[1].qualifier_cd = p.qualifier_cd, probrequest->problem[1].
             ranking_cd = p.ranking_cd, probrequest->problem[1].severity_cd = p.severity_cd,
             probrequest->problem[1].severity_class_cd = p.severity_class_cd, probrequest->problem[1]
             .severity_ftdesc = p.severity_ftdesc, probrequest->problem[1].show_in_pm_history_ind = p
             .show_in_pm_history_ind,
             probrequest->problem[1].status_upt_dt_tm = p.status_updt_dt_tm, probrequest->problem[1].
             status_upt_precision_cd = p.status_updt_precision_cd, probrequest->problem[1].
             status_upt_precision_flag = p.status_updt_flag
            WITH maxqual(p,1)
           ;end select
           IF (curqual > 0)
            EXECUTE kia_ens_problem  WITH replace("REQUEST",probrequest), replace("REPLY",probreply)
            IF ((probreply->status_data.status="F"))
             SET failed = update_error
             SET request->error_message = substring(1,132,build(
               "Could not update problem table with                                   problem instance ID = ",
               rreclist->from_rec[v_cust_loopcount].from_id))
             GO TO exit_sub
            ENDIF
            CALL update_dm_combine_details(probreply->problem_list[1].problem_instance_id,add)
           ELSE
            CALL log_message("ZERO entries for Update, Inactivate the Problem instance",
             log_level_debug)
            CALL inactivate_problem(rreclist->from_rec[v_cust_loopcount].from_id)
            CALL update_dm_combine_details(probreply->problem_list[1].problem_instance_id,del)
           ENDIF
          ELSE
           CALL log_message("ZERO entries for ENCOUNTER, Inactivate the Problem instance",
            log_level_debug)
           CALL inactivate_problem(rreclist->from_rec[v_cust_loopcount].from_id)
           CALL update_dm_combine_details(probreply->problem_list[1].problem_instance_id,del)
          ENDIF
         ELSE
          CALL log_message("ZERO entries for Problem select No active problems to move",
           log_level_debug)
         ENDIF
        ENDIF
       ENDIF
      ELSEIF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
       to_xxx_id,originating_encntr_id,update_encntr_id)=0)
       GO TO exit_sub
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE del_from(s_df_pk_id,s_df_to_fk_id,s_df_prev_act_ind,s_df_prev_act_status,
  s_df_prev_end_eff_dt_tm)
   UPDATE  FROM problem frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.updt_cnt = (frm.updt_cnt+ 1),
     frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
     reqinfo->updt_task,
     frm.updt_dt_tm = cnvtdatetime(sysdate), frm.end_effective_dt_tm = cnvtdatetime(sysdate)
    WHERE frm.problem_instance_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PROBLEM"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = s_df_prev_end_eff_dt_tm
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id,originating_encntr_id,update_encntr_id)
   UPDATE  FROM problem frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.person_id =
     s_uf_to_fk_id,
     frm.originating_encntr_id = originating_encntr_id, frm.update_encntr_id = update_encntr_id
    WHERE frm.problem_instance_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = s_uf_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PROBLEM"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",s_uf_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (update_dm_combine_details(prob_inst_id=f8,comb_act_cd=f8) =null)
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = comb_act_cd
   SET request->xxx_combine_det[icombinedet].entity_id = prob_inst_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PROBLEM"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
 END ;Subroutine
 SUBROUTINE (inactivate_problem(prob_inst_id=f8) =null)
   SET stat = initrec(probrequest)
   SET stat = initrec(probreply)
   SET probrequest->skip_fsi_trigger = 1
   SET probrequest->user_id = reqinfo->updt_id
   SET probrequest->interfaced_problems_flag = 0
   SET stat = alterlist(probrequest->problem,1)
   SET probrequest->problem[1].problem_action_ind = 7
   SELECT INTO "nl:"
    FROM problem p
    WHERE p.problem_instance_id=prob_inst_id
     AND p.active_ind=1
    ORDER BY p.updt_dt_tm DESC
    DETAIL
     probrequest->person_id = p.person_id, probrequest->context_encntr_id = p.update_encntr_id,
     probrequest->problem[1].annotated_display = p.annotated_display,
     probrequest->problem[1].beg_effective_dt_tm = p.beg_effective_dt_tm, probrequest->problem[1].
     cancel_reason_cd = p.cancel_reason_cd, probrequest->problem[1].certainty_cd = p.certainty_cd,
     probrequest->problem[1].classification_cd = p.classification_cd, probrequest->problem[1].
     confirmation_status_cd = p.confirmation_status_cd, probrequest->problem[1].contributor_system_cd
      = p.contributor_system_cd,
     probrequest->problem[1].course_cd = p.course_cd, probrequest->problem[1].end_effective_dt_tm = p
     .end_effective_dt_tm, probrequest->problem[1].family_aware_cd = p.family_aware_cd,
     probrequest->problem[1].laterality_cd = p.laterality_cd, probrequest->problem[1].
     life_cycle_dt_cd = p.life_cycle_dt_cd, probrequest->problem[1].life_cycle_dt_flag = p
     .life_cycle_dt_flag,
     probrequest->problem[1].life_cycle_dt_tm = p.life_cycle_dt_tm, probrequest->problem[1].
     life_cycle_status_cd = p.life_cycle_status_cd, probrequest->problem[1].nomenclature_id = p
     .nomenclature_id,
     probrequest->problem[1].onset_dt_cd = p.onset_dt_cd, probrequest->problem[1].onset_dt_flag = p
     .onset_dt_flag, probrequest->problem[1].onset_dt_tm = p.onset_dt_tm
     IF (validate(p.onset_tz)=1)
      probrequest->problem[1].onset_tz = p.onset_tz
     ENDIF
     probrequest->problem[1].organization_id = p.organization_id, probrequest->problem[1].
     originating_nomenclature_id = p.originating_nomenclature_id, probrequest->problem[1].
     persistence_cd = p.persistence_cd,
     probrequest->problem[1].person_aware_cd = p.person_aware_cd, probrequest->problem[1].
     person_aware_prognosis_cd = p.person_aware_prognosis_cd, probrequest->problem[1].probability = p
     .probability,
     probrequest->problem[1].problem_ftdesc = p.problem_ftdesc, probrequest->problem[1].
     problem_type_flag = p.problem_type_flag, probrequest->problem[1].prognosis_cd = p.prognosis_cd,
     probrequest->problem[1].qualifier_cd = p.qualifier_cd, probrequest->problem[1].ranking_cd = p
     .ranking_cd, probrequest->problem[1].severity_cd = p.severity_cd,
     probrequest->problem[1].severity_class_cd = p.severity_class_cd, probrequest->problem[1].
     severity_ftdesc = p.severity_ftdesc, probrequest->problem[1].show_in_pm_history_ind = p
     .show_in_pm_history_ind,
     probrequest->problem[1].status_upt_dt_tm = p.status_updt_dt_tm, probrequest->problem[1].
     status_upt_precision_cd = p.status_updt_precision_cd, probrequest->problem[1].
     status_upt_precision_flag = p.status_updt_flag
    WITH maxqual(p,1)
   ;end select
   IF (curqual > 0)
    EXECUTE kia_ens_problem  WITH replace("REQUEST",probrequest), replace("REPLY",probreply)
    IF ((probreply->status_data.status="F"))
     SET failed = update_error
     SET request->error_message = substring(1,132,build(
       "Could not inactivate problem table with                                       problem instance ID = ",
       rreclist->from_rec[v_cust_loopcount].from_id))
     GO TO exit_sub
    ENDIF
   ENDIF
 END ;Subroutine
#exit_sub
 FREE SET rreclist
 FREE SET encounter_list
 FREE SET probrequest
END GO
