CREATE PROGRAM acm_add_person_patient:dba
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE index = i4 WITH protect, noconstant(0)
 FOR (index = 1 TO xref->add_cnt)
   IF ((acm_request->person_patient_qual[xref->add[index].idx].person_id <= 0.0))
    SELECT INTO "nl:"
     nextseqnum = seq(person_only_seq,nextval)
     FROM dual
     DETAIL
      acm_request->person_patient_qual[xref->add[index].idx].person_id = cnvtreal(nextseqnum), reply
      ->person_patient_qual[xref->add[index].idx].person_id = cnvtreal(nextseqnum)
     WITH nocounter, format
    ;end select
    IF (curqual=0)
     SET reply->person_patient_qual[xref->add[index].idx].status = gen_nbr_error
     SET failed = gen_nbr_error
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->person_patient_qual[xref->add[index].idx].person_id = acm_request->
    person_patient_qual[xref->add[index].idx].person_id
   ENDIF
   SET reply->person_patient_qual[xref->add[index].idx].status = 0
   IF ((acm_request->person_patient_qual[xref->add[index].idx].beg_effective_dt_tm <= 0))
    SET acm_request->person_patient_qual[xref->add[index].idx].beg_effective_dt_tm = cnvtdatetime(
     curdate,curtime3)
   ENDIF
   IF ((acm_request->person_patient_qual[xref->add[index].idx].end_effective_dt_tm <= 0))
    SET acm_request->person_patient_qual[xref->add[index].idx].end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00")
   ENDIF
 ENDFOR
 INSERT  FROM (dummyt d  WITH seq = value(xref->add_cnt)),
   person_patient p
  SET p.person_id = acm_request->person_patient_qual[xref->add[d.seq].idx].person_id, p.adopted_cd =
   acm_request->person_patient_qual[xref->add[d.seq].idx].adopted_cd, p.bad_debt_cd = acm_request->
   person_patient_qual[xref->add[d.seq].idx].bad_debt_cd,
   p.birth_length = acm_request->person_patient_qual[xref->add[d.seq].idx].birth_length, p
   .birth_length_units_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].
   birth_length_units_cd, p.birth_multiple_cd = acm_request->person_patient_qual[xref->add[d.seq].idx
   ].birth_multiple_cd,
   p.birth_name = acm_request->person_patient_qual[xref->add[d.seq].idx].birth_name, p.birth_order =
   acm_request->person_patient_qual[xref->add[d.seq].idx].birth_order, p.birth_weight = acm_request->
   person_patient_qual[xref->add[d.seq].idx].birth_weight,
   p.callback_consent_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].callback_consent_cd,
   p.church_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].church_cd, p.contact_list_cd
    = acm_request->person_patient_qual[xref->add[d.seq].idx].contact_list_cd,
   p.contact_method_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].contact_method_cd, p
   .contact_time = acm_request->person_patient_qual[xref->add[d.seq].idx].contact_time, p
   .contributor_system_cd =
   IF ((acm_request->person_patient_qual[xref->add[d.seq].idx].contributor_system_cd > 0.0))
    acm_request->person_patient_qual[xref->add[d.seq].idx].contributor_system_cd
   ELSE pmhc_contributory_system_cd
   ENDIF
   ,
   p.credit_hrs_taking = acm_request->person_patient_qual[xref->add[d.seq].idx].credit_hrs_taking, p
   .cumm_leave_days = acm_request->person_patient_qual[xref->add[d.seq].idx].cumm_leave_days, p
   .current_balance = acm_request->person_patient_qual[xref->add[d.seq].idx].current_balance,
   p.current_grade = acm_request->person_patient_qual[xref->add[d.seq].idx].current_grade, p
   .custody_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].custody_cd, p
   .degree_complete_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].degree_complete_cd,
   p.diet_type_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].diet_type_cd, p
   .disease_alert_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].disease_alert_cd, p
   .family_income = acm_request->person_patient_qual[xref->add[d.seq].idx].family_income,
   p.family_size = acm_request->person_patient_qual[xref->add[d.seq].idx].family_size, p
   .highest_grade_complete_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].
   highest_grade_complete_cd, p.interp_required_cd = acm_request->person_patient_qual[xref->add[d.seq
   ].idx].interp_required_cd,
   p.interp_type_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].interp_type_cd, p
   .last_bill_dt_tm =
   IF ((acm_request->person_patient_qual[xref->add[d.seq].idx].last_bill_dt_tm > 0)) cnvtdatetime(
     acm_request->person_patient_qual[xref->add[d.seq].idx].last_bill_dt_tm)
   ELSE null
   ENDIF
   , p.last_bind_dt_tm =
   IF ((acm_request->person_patient_qual[xref->add[d.seq].idx].last_bind_dt_tm > 0)) cnvtdatetime(
     acm_request->person_patient_qual[xref->add[d.seq].idx].last_bind_dt_tm)
   ELSE null
   ENDIF
   ,
   p.last_discharge_dt_tm =
   IF ((acm_request->person_patient_qual[xref->add[d.seq].idx].last_discharge_dt_tm > 0))
    cnvtdatetime(acm_request->person_patient_qual[xref->add[d.seq].idx].last_discharge_dt_tm)
   ELSE null
   ENDIF
   , p.last_event_updt_dt_tm =
   IF ((acm_request->person_patient_qual[xref->add[d.seq].idx].last_event_updt_dt_tm > 0))
    cnvtdatetime(acm_request->person_patient_qual[xref->add[d.seq].idx].last_event_updt_dt_tm)
   ELSE null
   ENDIF
   , p.last_payment_dt_tm =
   IF ((acm_request->person_patient_qual[xref->add[d.seq].idx].last_payment_dt_tm > 0)) cnvtdatetime(
     acm_request->person_patient_qual[xref->add[d.seq].idx].last_payment_dt_tm)
   ELSE null
   ENDIF
   ,
   p.last_trauma_dt_tm =
   IF ((acm_request->person_patient_qual[xref->add[d.seq].idx].last_trauma_dt_tm > 0)) cnvtdatetime(
     acm_request->person_patient_qual[xref->add[d.seq].idx].last_trauma_dt_tm)
   ELSE null
   ENDIF
   , p.living_arrangement_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].
   living_arrangement_cd, p.living_dependency_cd = acm_request->person_patient_qual[xref->add[d.seq].
   idx].living_dependency_cd,
   p.living_will_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].living_will_cd, p
   .microfilm_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].microfilm_cd, p
   .mother_identifier = acm_request->person_patient_qual[xref->add[d.seq].idx].mother_identifier,
   p.mother_identifier_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].
   mother_identifier_cd, p.nbr_of_brothers = acm_request->person_patient_qual[xref->add[d.seq].idx].
   nbr_of_brothers, p.nbr_of_pregnancies = acm_request->person_patient_qual[xref->add[d.seq].idx].
   nbr_of_pregnancies,
   p.nbr_of_sisters = acm_request->person_patient_qual[xref->add[d.seq].idx].nbr_of_sisters, p
   .organ_donor_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].organ_donor_cd, p
   .parent_marital_status_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].
   parent_marital_status_cd,
   p.process_alert_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].process_alert_cd, p
   .smokes_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].smokes_cd, p.student_cd =
   acm_request->person_patient_qual[xref->add[d.seq].idx].student_cd,
   p.tumor_registry_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].tumor_registry_cd, p
   .baptised_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].baptised_cd, p
   .gest_age_at_birth = acm_request->person_patient_qual[xref->add[d.seq].idx].gest_age_at_birth,
   p.gest_age_method_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].gest_age_method_cd,
   p.written_format_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].written_format_cd, p
   .prev_contact_ind = acm_request->person_patient_qual[xref->add[d.seq].idx].prev_contact_ind,
   p.birth_order_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].birth_order_cd, p
   .source_version_number = acm_request->person_patient_qual[xref->add[d.seq].idx].
   source_version_number, p.source_last_sync_dt_tm =
   IF ((acm_request->person_patient_qual[xref->add[d.seq].idx].source_last_sync_dt_tm > 0))
    cnvtdatetime(acm_request->person_patient_qual[xref->add[d.seq].idx].source_last_sync_dt_tm)
   ELSE null
   ENDIF
   ,
   p.beg_effective_dt_tm = cnvtdatetime(acm_request->person_patient_qual[xref->add[d.seq].idx].
    beg_effective_dt_tm), p.end_effective_dt_tm = cnvtdatetime(acm_request->person_patient_qual[xref
    ->add[d.seq].idx].end_effective_dt_tm), p.source_sync_level_flag = acm_request->
   person_patient_qual[xref->add[d.seq].idx].source_sync_level_flag,
   p.birth_sex_cd = acm_request->person_patient_qual[xref->add[d.seq].idx].birth_sex_cd, p
   .data_status_cd =
   IF ((acm_request->person_patient_qual[xref->add[d.seq].idx].data_status_cd > 0.0)) acm_request->
    person_patient_qual[xref->add[d.seq].idx].data_status_cd
   ELSE reqdata->data_status_cd
   ENDIF
   , p.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
   p.data_status_prsnl_id = reqinfo->updt_id, p.active_ind =
   IF ((((acm_request->person_patient_qual[xref->add[d.seq].idx].active_status_cd=0.0)) OR ((
   acm_request->person_patient_qual[xref->add[d.seq].idx].active_status_cd=reqdata->active_status_cd)
   )) ) 1
   ELSE 0
   ENDIF
   , p.active_status_cd =
   IF ((acm_request->person_patient_qual[xref->add[d.seq].idx].active_status_cd > 0.0)) acm_request->
    person_patient_qual[xref->add[d.seq].idx].active_status_cd
   ELSE reqdata->active_status_cd
   ENDIF
   ,
   p.active_status_prsnl_id = reqinfo->updt_id, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3
    ), p.updt_cnt = 0,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_applctx =
   reqinfo->updt_applctx,
   p.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (p)
  WITH nocounter, status(reply->person_patient_qual[xref->add[d.seq].idx].status)
 ;end insert
 FOR (index = 1 TO xref->add_cnt)
   IF ((reply->person_patient_qual[xref->add[index].idx].status=0))
    SET failed = insert_error
    SET table_name = "PERSON_PATIENT"
    GO TO exit_script
   ENDIF
 ENDFOR
 IF (acm_hist_ind=1)
  EXECUTE acm_add_person_patient_hist
  IF ((reply->status_data.status="F"))
   SET failed = true
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed)
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    DECLARE s_next_subeventstatus(s_null=i4) = i4
    DECLARE s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) = i4
    DECLARE s_add_subeventstatus_cclerr(s_null=i4) = i4
    DECLARE s_log_subeventstatus(s_null=i4) = i4
    DECLARE s_clear_subeventstatus(s_null=i4) = i4
    SUBROUTINE s_next_subeventstatus(s_null)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 = (stx1+ 1)
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus(s_oname,s_ostatus,s_tname,s_tvalue)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus_cclerr(s_null)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE s_log_subeventstatus(s_null)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE s_clear_subeventstatus(s_null)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    DECLARE s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) = i2
    SUBROUTINE s_sch_msgview(t_event,t_message,t_log_level)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
