CREATE PROGRAM bhs_sys_exe_req_966403
 PROMPT
  "Enter PERSON_ID: " = 0.00
  WITH pat_id
 RECORD hmd_request(
   1 eval_start_dt_tm = dq8
   1 eval_end_dt_tm = dq8
   1 location_cd = f8
   1 p_cnt = i4
   1 person[*]
     2 person_id = f8
     2 sex_cd = f8
     2 use_sex = i2
     2 birth_dt_tm = dq8
     2 use_birth_dt_tm = i2
     2 use_problems = i2
     2 prob_cnt = i4
     2 problem[*]
       3 nomenclature_id = f8
       3 life_cycle_status_cd = f8
     2 use_diagnoses = i2
     2 diag_cnt = i4
     2 diagnosis[*]
       3 nomenclature_id = f8
       3 diag_type_cd = f8
     2 use_procedures = i2
     2 proc_cnt = i4
     2 procedure[*]
       3 procedure_id = f8
       3 nomenclature_id = f8
       3 proc_prsnl_id = f8
       3 proc_prsnl_name = vc
       3 active_ind = i2
       3 proc_dt_tm = dq8
       3 text = vc
 ) WITH persist
 RECORD hmd_reply(
   1 person_org_sec_on = i2
   1 p_cnt = i4
   1 person[*]
     2 person_id = f8
     2 rem_cnt = i4
     2 reminders[*]
       3 schedule_id = f8
       3 series_id = f8
       3 expectation_id = f8
       3 step_id = f8
       3 status_flag = i2
       3 effective_start_dt_tm = dq8
       3 valid_start_dt_tm = dq8
       3 valid_end_dt_tm = dq8
       3 recommend_start_age = i4
       3 recommend_end_age = i4
       3 recommend_due_dt_tm = dq8
       3 over_due_dt_tm = dq8
       3 latest_postponed_dt_tm = dq8
       3 alternate_exp_available = i2
       3 last_sat_dt_tm = dq8
       3 last_sat_prsnl_id = f8
       3 last_sat_prsnl_name = vc
       3 last_sat_organization_id = f8
       3 last_sat_comment = vc
     2 rec_cnt = i4
     2 records[*]
       3 modifier_id = f8
       3 modifier_type_cd = f8
       3 modifier_type_mean = vc
       3 clinical_event_id = f8
       3 order_id = f8
       3 procedure_id = f8
       3 schedule_id = f8
       3 series_id = f8
       3 expectation_id = f8
       3 step_id = f8
       3 status_flag = i2
       3 modifier_dt_tm = dq8
       3 next_due_dt_tm = dq8
       3 recorded_dt_tm = dq8
       3 recorded_for_prsnl_id = f8
       3 recorded_for_prsnl_name = vc
       3 reason_cd = f8
       3 reason_disp = vc
       3 comment = vc
       3 created_prsnl_id = f8
       3 created_prsnl_name = vc
       3 status_ind = i2
     2 sr_cnt = i4
     2 schedule_reltn[*]
       3 schedule_id = f8
       3 mode_flag = i2
     2 s_cnt = i4
     2 series[*]
       3 series_mean = vc
       3 sched_mean = vc
       3 qualify_flag = i2
       3 explanation = vc
   1 status_data
     2 status = vc
     2 status_value = i4
     2 subeventstatus[*]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 ) WITH persist
 DECLARE populate_hmd_request_records(null) = i2 WITH protect
 DECLARE get_hmd_reply(null) = i2 WITH protect
 DECLARE d0 = i2
 DECLARE serrmsg = vc
 DECLARE ierrcode = i4
 SET d0 = populate_hmd_request_records(null)
 SET d0 = get_hmd_reply(null)
 CALL echorecord(hmd_request)
 CALL echorecord(hmd_reply)
 SUBROUTINE populate_hmd_request_records(null)
   SET hmd_request->p_cnt = 1
   SET stat = alterlist(hmd_request->person,hmd_request->p_cnt)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM person p
    PLAN (p
     WHERE (p.person_id= $PAT_ID)
      AND p.sex_cd > 0
      AND p.birth_dt_tm != null)
    HEAD REPORT
     hmd_request->person[1].person_id = p.person_id, hmd_request->person[1].sex_cd = p.sex_cd,
     hmd_request->person[1].use_sex = 1,
     hmd_request->person[1].birth_dt_tm = p.birth_dt_tm, hmd_request->person[1].use_birth_dt_tm = 1
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    RETURN(0)
   ENDIF
   IF ((hmd_request->person[1].sex_cd < 1))
    SET serrmsg = "invalid person.sex_cd"
    RETURN(0)
   ENDIF
   IF ((hmd_request->person[1].person_id < 1))
    SET serrmsg = "invalid person.person_id"
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_hmd_reply(null)
   DECLARE crmstatus = i4 WITH public, noconstant(0)
   DECLARE failed_action = c12 WITH public, noconstant(" ")
   DECLARE appnum = i4 WITH public, constant(966300)
   DECLARE tasknum = i4 WITH public, constant(966310)
   DECLARE reqnum = i4 WITH public, constant(966403)
   DECLARE happ = i4 WITH public, noconstant(0)
   DECLARE htask = i4 WITH public, noconstant(0)
   DECLARE hreq = i4 WITH public, noconstant(0)
   DECLARE hstep = i4 WITH public, noconstant(0)
   DECLARE hpersonreq = i4 WITH public, noconstant(0)
   DECLARE hproblemreq = i4 WITH public, noconstant(0)
   DECLARE hprocedurereq = i4 WITH public, noconstant(0)
   DECLARE hdiagnosisreq = i4 WITH public, noconstant(0)
   DECLARE hreply = i4 WITH public, noconstant(0)
   DECLARE hstruct = i4 WITH public, noconstant(0)
   DECLARE hperson = i4 WITH public, noconstant(0)
   DECLARE hreminder = i4 WITH public, noconstant(0)
   DECLARE hrecord = i4 WITH public, noconstant(0)
   DECLARE hschedule = i4 WITH public, noconstant(0)
   DECLARE hseries = i4 WITH public, noconstant(0)
   SET crmstatus = uar_crmbeginapp(appnum,happ)
   IF (crmstatus != 0)
    SET failed_action = "begin_app"
    SET table_name = "begin_app"
    SET serrmsg = concat("uar_crmbeginapp(",trim(cnvtstring(appnum)),",happ) = ",trim(cnvtstring(
       crmstatus)))
    CALL uar_crmendapp(happ)
    RETURN(0)
   ENDIF
   SET crmstatus = uar_crmbegintask(happ,tasknum,htask)
   IF (crmstatus != 0)
    SET failed_action = "begin_task"
    SET table_name = "begin_task"
    SET serrmsg = concat("uar_crmbegintask(happ,",trim(cnvtstring(tasknum)),",htask) = ",trim(
      cnvtstring(crmstatus)))
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(0)
   ENDIF
   SET crmstatus = uar_crmbeginreq(htask,hreq,reqnum,hstep)
   IF (crmstatus != 0)
    SET failed_action = "begin_req"
    SET table_name = "begin_req"
    SET serrmsg = concat("uar_crmbeginreq(htask,hreq,",trim(cnvtstring(reqnum)),",hstep) = ",trim(
      cnvtstring(crmstatus)))
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(0)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF (hreq <= 0)
    SET failed_action = "init_req"
    SET table_name = "init_req"
    SET serrmsg = "uar_crmgetrequest(hstep) failed"
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(0)
   ENDIF
   FOR (i = 1 TO hmd_request->p_cnt)
     SET hpersonreq = uar_srvadditem(hreq,"person")
     SET stat = uar_srvsetdouble(hpersonreq,"person_id",hmd_request->person[i].person_id)
     SET stat = uar_srvsetdouble(hpersonreq,"sex_cd",hmd_request->person[i].sex_cd)
     SET stat = uar_srvsetshort(hpersonreq,"use_sex",hmd_request->person[i].use_sex)
     SET stat = uar_srvsetdate(hpersonreq,"birth_dt_tm",cnvtdatetime(hmd_request->person[i].
       birth_dt_tm))
     SET stat = uar_srvsetshort(hpersonreq,"use_birth_dt_tm",hmd_request->person[i].use_birth_dt_tm)
     IF ((hmd_request->person[i].use_problems > 0))
      SET stat = uar_srvsetshort(hpersonreq,"use_problems",hmd_request->person[i].use_problems)
      FOR (j = 1 TO hmd_request->person[i].prob_cnt)
        SET hproblemreq = uar_srvadditem(hpersonreq,"problem")
        SET stat = uar_srvsetdouble(hproblemreq,"nomenclature_id",hmd_request->person[i].problem[j].
         nomenclature_id)
        SET stat = uar_srvsetdouble(hproblemreq,"life_cycle_status_cd",hmd_request->person[i].
         problem[j].life_cycle_status_cd)
      ENDFOR
     ENDIF
     IF ((hmd_request->person[i].use_diagnoses > 0))
      SET stat = uar_srvsetshort(hpersonreq,"use_diagnoses",hmd_request->person[i].use_diagnoses)
      FOR (j = 1 TO hmd_request->person[i].diag_cnt)
        SET hdiagnosisreq = uar_srvadditem(hpersonreq,"diagnosis")
        SET stat = uar_srvsetdouble(hdiagnosisreq,"nomenclature_id",hmd_request->person[i].diagnosis[
         j].nomenclature_id)
        SET stat = uar_srvsetdouble(hdiagnosisreq,"diag_type_cd",hmd_request->person[i].diagnosis[j].
         diag_type_cd)
      ENDFOR
     ENDIF
     IF ((hmd_request->person[i].use_procedures > 0))
      SET stat = uar_srvsetshort(hpersonreq,"use_procedures",hmd_request->person[i].use_procedures)
      FOR (j = 1 TO hmd_request->person[i].procedure_cnt)
        SET hprocedurereq = uar_srvadditem(hpersonreq,"procedure")
        SET stat = uar_srvsetdouble(hprocedurereq,"procedure_id",hmd_request->person[i].procedure[j].
         procedure_id)
        SET stat = uar_srvsetdouble(hprocedurereq,"nomenclature_id",hmd_request->person[i].procedure[
         j].nomenclature_id)
        SET stat = uar_srvsetdouble(hprocedurereq,"proc_prsnl_id",hmd_request->person[i].procedure[j]
         .proc_prsnl_id)
        SET stat = uar_srvsetstring(hprocedurereq,"proc_prsnl_name",nullterm(hmd_request->person[i].
          procedure[j].proc_prsnl_name))
        SET stat = uar_srvsetshort(hprocedurereq,"active_ind",hmd_request->person[i].procedure[j].
         active_ind)
        SET stat = uar_srvsetdate(hprocedurereq,"proc_dt_tm",cnvtdatetime(hmd_request->person[i].
          procedure[j].proc_dt_tm))
        SET stat = uar_srvsetstring(hprocedurereq,"text",nullterm(hmd_request->person[i].procedure[j]
          .text))
      ENDFOR
     ENDIF
   ENDFOR
   SET crmstatus = uar_crmperform(hstep)
   IF (crmstatus != 0)
    SET failed_action = "perform_req"
    SET table_name = "perform_req"
    SET serrmsg = concat("uar_crmperform(hstep) = ",trim(cnvtstring(crmstatus)))
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(0)
   ENDIF
   SET hreply = uar_crmgetreply(hstep)
   IF (hreply <= 0)
    SET failed_action = "get_reply"
    SET table_name = "get_reply"
    SET serrmsg = "uar_crmgetreply(hstep)"
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(0)
   ENDIF
   SET hstruct = uar_srvgetstruct(hreply,"status_data")
   SET statusvalue = trim(uar_srvgetstringptr(hstruct,"status"))
   IF (statusvalue != "S")
    SET failed_action = "exe_error"
    SET table_name = "perform_status"
    SET serrmsg = concat("the perform of ",trim(cnvtstring(reqnum))," failed")
    CALL uar_crmendreq(hstep)
    CALL uar_crmendtask(htask)
    CALL uar_crmendapp(happ)
    RETURN(0)
   ENDIF
   SET hmd_reply->person_org_sec_on = uar_srvgetshort(hreply,"person_org_sec_on")
   SET hmd_reply->p_cnt = uar_srvgetitemcount(hreply,"person")
   SET stat = alterlist(hmd_reply->person,hmd_reply->p_cnt)
   FOR (p = 1 TO hmd_reply->p_cnt)
     SET hperson = uar_srvgetitem(hreply,"person",(p - 1))
     SET hmd_reply->person[p].person_id = uar_srvgetdouble(hperson,"person_id")
     SET hmd_reply->person[p].rem_cnt = uar_srvgetitemcount(hperson,"reminder")
     SET stat = alterlist(hmd_reply->person[p].reminders,hmd_reply->person[p].rem_cnt)
     FOR (r = 1 TO hmd_reply->person[p].rem_cnt)
       SET hreminder = uar_srvgetitem(hperson,"reminder",(r - 1))
       SET hmd_reply->person[p].reminders[r].schedule_id = uar_srvgetdouble(hreminder,"schedule_id")
       SET hmd_reply->person[p].reminders[r].series_id = uar_srvgetdouble(hreminder,"series_id")
       SET hmd_reply->person[p].reminders[r].expectation_id = uar_srvgetdouble(hreminder,
        "expectation_id")
       SET hmd_reply->person[p].reminders[r].step_id = uar_srvgetdouble(hreminder,"step_id")
       SET hmd_reply->person[p].reminders[r].status_flag = uar_srvgetshort(hreminder,"status_flag")
       CALL uar_srvgetdate(hreminder,"valid_start_dt_tm",hmd_reply->person[p].reminders[r].
        valid_start_dt_tm)
       CALL uar_srvgetdate(hreminder,"valid_end_dt_tm",hmd_reply->person[p].reminders[r].
        valid_end_dt_tm)
       SET hmd_reply->person[p].reminders[r].recommend_start_age = uar_srvgetlong(hreminder,
        "recommend_start_age")
       SET hmd_reply->person[p].reminders[r].recommend_end_age = uar_srvgetlong(hreminder,
        "recommend_end_age")
       CALL uar_srvgetdate(hreminder,"recommend_due_dt_tm",hmd_reply->person[p].reminders[r].
        recommend_due_dt_tm)
       CALL uar_srvgetdate(hreminder,"over_due_dt_tm",hmd_reply->person[p].reminders[r].
        over_due_dt_tm)
       SET hmd_reply->person[p].reminders[r].alternate_exp_available = uar_srvgetshort(hreminder,
        "alternate_exp_available")
       CALL uar_srvgetdate(hreminder,"last_sat_dt_tm",hmd_reply->person[p].reminders[r].
        last_sat_dt_tm)
       SET hmd_reply->person[p].reminders[r].last_sat_prsnl_id = uar_srvgetdouble(hreminder,
        "last_sat_prsnl_id")
       SET hmd_reply->person[p].reminders[r].last_sat_prsnl_name = uar_srvgetstringptr(hreminder,
        "last_sat_prsnl_name")
       SET hmd_reply->person[p].reminders[r].last_sat_comment = uar_srvgetstringptr(hreminder,
        "last_sat_comment")
       SET hmd_reply->person[p].reminders[r].last_sat_organization_id = uar_srvgetdouble(hreminder,
        "last_sat_organization_id")
     ENDFOR
     SET hmd_reply->person[p].rec_cnt = uar_srvgetitemcount(hperson,"record")
     SET stat = alterlist(hmd_reply->person[p].records,hmd_reply->person[p].rec_cnt)
     FOR (r = 1 TO hmd_reply->person[p].rec_cnt)
       SET hrecord = uar_srvgetitem(hperson,"record",(r - 1))
       SET hmd_reply->person[p].records[r].modifier_id = uar_srvgetdouble(hrecord,"modifier_id")
       SET hmd_reply->person[p].records[r].modifier_type_cd = uar_srvgetdouble(hrecord,
        "modifier_type_cd")
       SET hmd_reply->person[p].records[r].modifier_type_mean = uar_srvgetstringptr(hrecord,
        "modifier_type_mean")
       SET hmd_reply->person[p].records[r].clinical_event_id = uar_srvgetdouble(hrecord,
        "clinical_event_id")
       SET hmd_reply->person[p].records[r].order_id = uar_srvgetdouble(hrecord,"order_id")
       SET hmd_reply->person[p].records[r].schedule_id = uar_srvgetdouble(hrecord,"schedule_id")
       SET hmd_reply->person[p].records[r].series_id = uar_srvgetdouble(hrecord,"series_id")
       SET hmd_reply->person[p].records[r].expectation_id = uar_srvgetdouble(hrecord,"expectation_id"
        )
       SET hmd_reply->person[p].records[r].step_id = uar_srvgetdouble(hrecord,"step_id")
       SET hmd_reply->person[p].records[r].status_flag = uar_srvgetshort(hrecord,"status_flag")
       CALL uar_srvgetdate(hrecord,"modifier_dt_tm",hmd_reply->person[p].records[r].modifier_dt_tm)
       CALL uar_srvgetdate(hrecord,"next_due_dt_tm",hmd_reply->person[p].records[r].next_due_dt_tm)
       CALL uar_srvgetdate(hrecord,"recorded_dt_tm",hmd_reply->person[p].records[r].recorded_dt_tm)
       SET hmd_reply->person[p].records[r].recorded_for_prsnl_id = uar_srvgetdouble(hrecord,
        "recorded_for_prsnl_id")
       SET hmd_reply->person[p].records[r].recorded_for_prsnl_name = uar_srvgetstringptr(hrecord,
        "recorded_for_prsnl_name")
       SET hmd_reply->person[p].records[r].reason_cd = uar_srvgetdouble(hrecord,"reason_cd")
       SET hmd_reply->person[p].records[r].reason_disp = uar_srvgetstringptr(hrecord,"reason_disp")
       SET hmd_reply->person[p].records[r].comment = uar_srvgetstringptr(hrecord,"comment")
       SET hmd_reply->person[p].records[r].created_prsnl_id = uar_srvgetdouble(hrecord,
        "created_prsnl_id")
       SET hmd_reply->person[p].records[r].created_prsnl_name = uar_srvgetstringptr(hrecord,
        "created_prsnl_name")
       SET hmd_reply->person[p].records[r].status_ind = uar_srvgetshort(hrecord,"status_ind")
     ENDFOR
     SET hmd_reply->person[p].sr_cnt = uar_srvgetitemcount(hperson,"schedule_reltn")
     SET stat = alterlist(hmd_reply->person[p].schedule_reltn,hmd_reply->person[p].sr_cnt)
     FOR (s = 1 TO hmd_reply->person[p].sr_cnt)
       SET hschedule = uar_srvgetitem(hperson,"schedule_reltn",(s - 1))
       SET hmd_reply->person[p].schedule_reltn[s].schedule_id = uar_srvgetdouble(hschedule,
        "schedule_id")
       SET hmd_reply->person[p].schedule_reltn[s].mode_flag = uar_srvgetshort(hschedule,"mode_flag")
     ENDFOR
     SET hmd_reply->person[p].s_cnt = uar_srvgetitemcount(hperson,"series")
     SET stat = alterlist(hmd_reply->person[p].series,hmd_reply->person[p].s_cnt)
     FOR (s = 1 TO hmd_reply->person[p].s_cnt)
       SET hseries = uar_srvgetitem(hperson,"series",(s - 1))
       SET hmd_reply->person[p].series[s].series_mean = uar_srvgetstringptr(hseries,"series_mean")
       SET hmd_reply->person[p].series[s].sched_mean = uar_srvgetstringptr(hseries,"sched_mean")
       SET hmd_reply->person[p].series[s].qualify_flag = uar_srvgetshort(hseries,"qualify_flag")
       SET hmd_reply->person[p].series[s].explanation = uar_srvgetstringptr(hseries,"explanation")
     ENDFOR
   ENDFOR
   RETURN(1)
 END ;Subroutine
END GO
