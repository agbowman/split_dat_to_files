CREATE PROGRAM acm_add_encounter:dba
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
   IF ((acm_request->encounter_qual[xref->add[index].idx].encntr_id <= 0.0))
    SELECT INTO "nl:"
     nextseqnum = seq(encounter_only_seq,nextval)
     FROM dual
     DETAIL
      acm_request->encounter_qual[xref->add[index].idx].encntr_id = cnvtreal(nextseqnum), reply->
      encounter_qual[xref->add[index].idx].encntr_id = cnvtreal(nextseqnum)
     WITH nocounter, format
    ;end select
    IF (curqual=0)
     SET reply->encounter_qual[xref->add[index].idx].status = gen_nbr_error
     SET failed = gen_nbr_error
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->encounter_qual[xref->add[index].idx].encntr_id = acm_request->encounter_qual[xref->
    add[index].idx].encntr_id
   ENDIF
   SET reply->encounter_qual[xref->add[index].idx].status = 0
   IF ((acm_request->encounter_qual[xref->add[index].idx].beg_effective_dt_tm <= 0))
    SET acm_request->encounter_qual[xref->add[index].idx].beg_effective_dt_tm = cnvtdatetime(curdate,
     curtime3)
   ENDIF
   IF ((acm_request->encounter_qual[xref->add[index].idx].end_effective_dt_tm <= 0))
    SET acm_request->encounter_qual[xref->add[index].idx].end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00")
   ENDIF
 ENDFOR
 INSERT  FROM (dummyt d  WITH seq = value(xref->add_cnt)),
   encounter e
  SET e.encntr_id = acm_request->encounter_qual[xref->add[d.seq].idx].encntr_id, e.accomp_by_cd =
   acm_request->encounter_qual[xref->add[d.seq].idx].accomp_by_cd, e.admit_mode_cd = acm_request->
   encounter_qual[xref->add[d.seq].idx].admit_mode_cd,
   e.admit_src_cd = acm_request->encounter_qual[xref->add[d.seq].idx].admit_src_cd, e.admit_type_cd
    = acm_request->encounter_qual[xref->add[d.seq].idx].admit_type_cd, e.admit_with_medication_cd =
   acm_request->encounter_qual[xref->add[d.seq].idx].admit_with_medication_cd,
   e.alc_decomp_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].alc_decomp_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->add[d.seq].idx].alc_decomp_dt_tm)
   ELSE null
   ENDIF
   , e.alc_reason_cd = acm_request->encounter_qual[xref->add[d.seq].idx].alc_reason_cd, e
   .alt_lvl_care_cd = acm_request->encounter_qual[xref->add[d.seq].idx].alt_lvl_care_cd,
   e.alt_lvl_care_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].alt_lvl_care_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->add[d.seq].idx].alt_lvl_care_dt_tm)
   ELSE null
   ENDIF
   , e.alt_result_dest_cd = acm_request->encounter_qual[xref->add[d.seq].idx].alt_result_dest_cd, e
   .ambulatory_cond_cd = acm_request->encounter_qual[xref->add[d.seq].idx].ambulatory_cond_cd,
   e.arrive_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].arrive_dt_tm > 0)) cnvtdatetime(acm_request
     ->encounter_qual[xref->add[d.seq].idx].arrive_dt_tm)
   ELSE null
   ENDIF
   , e.bbd_procedure_cd = acm_request->encounter_qual[xref->add[d.seq].idx].bbd_procedure_cd, e
   .beg_effective_dt_tm = cnvtdatetime(acm_request->encounter_qual[xref->add[d.seq].idx].
    beg_effective_dt_tm),
   e.chart_complete_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].chart_complete_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->add[d.seq].idx].chart_complete_dt_tm)
   ELSE null
   ENDIF
   , e.confid_level_cd = acm_request->encounter_qual[xref->add[d.seq].idx].confid_level_cd, e
   .contributor_system_cd =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].contributor_system_cd > 0.0)) acm_request->
    encounter_qual[xref->add[d.seq].idx].contributor_system_cd
   ELSE pmhc_contributory_system_cd
   ENDIF
   ,
   e.courtesy_cd = acm_request->encounter_qual[xref->add[d.seq].idx].courtesy_cd, e.depart_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].depart_dt_tm > 0)) cnvtdatetime(acm_request
     ->encounter_qual[xref->add[d.seq].idx].depart_dt_tm)
   ELSE null
   ENDIF
   , e.diet_type_cd = acm_request->encounter_qual[xref->add[d.seq].idx].diet_type_cd,
   e.disch_disposition_cd = acm_request->encounter_qual[xref->add[d.seq].idx].disch_disposition_cd, e
   .disch_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].disch_dt_tm > 0)) cnvtdatetime(acm_request
     ->encounter_qual[xref->add[d.seq].idx].disch_dt_tm)
   ELSE null
   ENDIF
   , e.disch_to_loctn_cd = acm_request->encounter_qual[xref->add[d.seq].idx].disch_to_loctn_cd,
   e.doc_rcvd_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].doc_rcvd_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->add[d.seq].idx].doc_rcvd_dt_tm)
   ELSE null
   ENDIF
   , e.encntr_class_cd = acm_request->encounter_qual[xref->add[d.seq].idx].encntr_class_cd, e
   .encntr_complete_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].encntr_complete_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->add[d.seq].idx].encntr_complete_dt_tm)
   ELSE cnvtdatetime(curdate,curtime3)
   ENDIF
   ,
   e.encntr_financial_id =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].encntr_financial_id > 0)) acm_request->
    encounter_qual[xref->add[d.seq].idx].encntr_financial_id
   ELSE reply->encntr_financial_qual[acm_request->encounter_qual[xref->add[d.seq].idx].
    encntr_financial_idx].encntr_financial_id
   ENDIF
   , e.encntr_status_cd = acm_request->encounter_qual[xref->add[d.seq].idx].encntr_status_cd, e
   .encntr_type_cd = acm_request->encounter_qual[xref->add[d.seq].idx].encntr_type_cd,
   e.encntr_type_class_cd = acm_request->encounter_qual[xref->add[d.seq].idx].encntr_type_class_cd, e
   .end_effective_dt_tm = cnvtdatetime(acm_request->encounter_qual[xref->add[d.seq].idx].
    end_effective_dt_tm), e.est_arrive_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].est_arrive_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->add[d.seq].idx].est_arrive_dt_tm)
   ELSE null
   ENDIF
   ,
   e.est_depart_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].est_depart_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->add[d.seq].idx].est_depart_dt_tm)
   ELSE null
   ENDIF
   , e.est_length_of_stay = acm_request->encounter_qual[xref->add[d.seq].idx].est_length_of_stay, e
   .financial_class_cd = acm_request->encounter_qual[xref->add[d.seq].idx].financial_class_cd,
   e.guarantor_type_cd = acm_request->encounter_qual[xref->add[d.seq].idx].guarantor_type_cd, e
   .info_given_by = acm_request->encounter_qual[xref->add[d.seq].idx].info_given_by, e.isolation_cd
    = acm_request->encounter_qual[xref->add[d.seq].idx].isolation_cd,
   e.location_cd = acm_request->encounter_qual[xref->add[d.seq].idx].location_cd, e.loc_bed_cd =
   acm_request->encounter_qual[xref->add[d.seq].idx].loc_bed_cd, e.loc_building_cd = acm_request->
   encounter_qual[xref->add[d.seq].idx].loc_building_cd,
   e.loc_facility_cd = acm_request->encounter_qual[xref->add[d.seq].idx].loc_facility_cd, e
   .loc_nurse_unit_cd = acm_request->encounter_qual[xref->add[d.seq].idx].loc_nurse_unit_cd, e
   .loc_room_cd = acm_request->encounter_qual[xref->add[d.seq].idx].loc_room_cd,
   e.loc_temp_cd = acm_request->encounter_qual[xref->add[d.seq].idx].loc_temp_cd, e.med_service_cd =
   acm_request->encounter_qual[xref->add[d.seq].idx].med_service_cd, e.mental_health_cd = acm_request
   ->encounter_qual[xref->add[d.seq].idx].mental_health_cd,
   e.mental_health_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].mental_health_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->add[d.seq].idx].mental_health_dt_tm)
   ELSE null
   ENDIF
   , e.organization_id = acm_request->encounter_qual[xref->add[d.seq].idx].organization_id, e
   .person_id =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].person_id > 0)) acm_request->
    encounter_qual[xref->add[d.seq].idx].person_id
   ELSE reply->person_qual[acm_request->encounter_qual[xref->add[d.seq].idx].person_idx].person_id
   ENDIF
   ,
   e.placement_auth_prsnl_id = acm_request->encounter_qual[xref->add[d.seq].idx].
   placement_auth_prsnl_id, e.preadmit_nbr = acm_request->encounter_qual[xref->add[d.seq].idx].
   preadmit_nbr, e.preadmit_testing_cd = acm_request->encounter_qual[xref->add[d.seq].idx].
   preadmit_testing_cd,
   e.pre_reg_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].pre_reg_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->add[d.seq].idx].pre_reg_dt_tm)
   ELSE null
   ENDIF
   , e.pre_reg_prsnl_id = acm_request->encounter_qual[xref->add[d.seq].idx].pre_reg_prsnl_id, e
   .program_service_cd = acm_request->encounter_qual[xref->add[d.seq].idx].program_service_cd,
   e.readmit_cd = acm_request->encounter_qual[xref->add[d.seq].idx].readmit_cd, e.reason_for_visit =
   acm_request->encounter_qual[xref->add[d.seq].idx].reason_for_visit, e.referral_rcvd_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].referral_rcvd_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->add[d.seq].idx].referral_rcvd_dt_tm)
   ELSE null
   ENDIF
   ,
   e.referring_comment = acm_request->encounter_qual[xref->add[d.seq].idx].referring_comment, e
   .refer_facility_cd = acm_request->encounter_qual[xref->add[d.seq].idx].refer_facility_cd, e
   .region_cd = acm_request->encounter_qual[xref->add[d.seq].idx].region_cd,
   e.reg_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].reg_dt_tm > 0)) cnvtdatetime(acm_request->
     encounter_qual[xref->add[d.seq].idx].reg_dt_tm)
   ELSE null
   ENDIF
   , e.reg_prsnl_id = acm_request->encounter_qual[xref->add[d.seq].idx].reg_prsnl_id, e
   .result_dest_cd = acm_request->encounter_qual[xref->add[d.seq].idx].result_dest_cd,
   e.safekeeping_cd = acm_request->encounter_qual[xref->add[d.seq].idx].safekeeping_cd, e
   .security_access_cd = acm_request->encounter_qual[xref->add[d.seq].idx].security_access_cd, e
   .service_category_cd = acm_request->encounter_qual[xref->add[d.seq].idx].service_category_cd,
   e.sitter_required_cd = acm_request->encounter_qual[xref->add[d.seq].idx].sitter_required_cd, e
   .specialty_unit_cd = acm_request->encounter_qual[xref->add[d.seq].idx].specialty_unit_cd, e
   .species_cd = acm_request->encounter_qual[xref->add[d.seq].idx].species_cd,
   e.trauma_cd = acm_request->encounter_qual[xref->add[d.seq].idx].trauma_cd, e.trauma_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].trauma_dt_tm > 0)) cnvtdatetime(acm_request
     ->encounter_qual[xref->add[d.seq].idx].trauma_dt_tm)
   ELSE null
   ENDIF
   , e.triage_cd = acm_request->encounter_qual[xref->add[d.seq].idx].triage_cd,
   e.triage_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].triage_dt_tm > 0)) cnvtdatetime(acm_request
     ->encounter_qual[xref->add[d.seq].idx].triage_dt_tm)
   ELSE null
   ENDIF
   , e.valuables_cd = acm_request->encounter_qual[xref->add[d.seq].idx].valuables_cd, e.vip_cd =
   acm_request->encounter_qual[xref->add[d.seq].idx].vip_cd,
   e.visitor_status_cd = acm_request->encounter_qual[xref->add[d.seq].idx].visitor_status_cd, e
   .zero_balance_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].zero_balance_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->add[d.seq].idx].zero_balance_dt_tm)
   ELSE null
   ENDIF
   , e.mental_category_cd = acm_request->encounter_qual[xref->add[d.seq].idx].mental_category_cd,
   e.patient_classification_cd = acm_request->encounter_qual[xref->add[d.seq].idx].
   patient_classification_cd, e.psychiatric_status_cd = acm_request->encounter_qual[xref->add[d.seq].
   idx].psychiatric_status_cd, e.inpatient_admit_dt_tm =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].inpatient_admit_dt_tm > 0)) cnvtdatetime(
     acm_request->encounter_qual[xref->add[d.seq].idx].inpatient_admit_dt_tm)
   ELSE null
   ENDIF
   ,
   e.data_status_cd =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].data_status_cd > 0.0)) acm_request->
    encounter_qual[xref->add[d.seq].idx].data_status_cd
   ELSE reqdata->data_status_cd
   ENDIF
   , e.data_status_dt_tm = cnvtdatetime(curdate,curtime3), e.data_status_prsnl_id = reqinfo->updt_id,
   e.create_dt_tm = cnvtdatetime(curdate,curtime3), e.create_prsnl_id = reqinfo->updt_id, e
   .active_ind =
   IF ((((acm_request->encounter_qual[xref->add[d.seq].idx].active_status_cd=0.0)) OR ((acm_request->
   encounter_qual[xref->add[d.seq].idx].active_status_cd=reqdata->active_status_cd))) ) 1
   ELSE 0
   ENDIF
   ,
   e.active_status_cd =
   IF ((acm_request->encounter_qual[xref->add[d.seq].idx].active_status_cd > 0.0)) acm_request->
    encounter_qual[xref->add[d.seq].idx].active_status_cd
   ELSE reqdata->active_status_cd
   ENDIF
   , e.active_status_prsnl_id = reqinfo->updt_id, e.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3),
   e.updt_cnt = 0, e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = reqinfo->updt_id,
   e.updt_applctx = reqinfo->updt_applctx, e.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (e)
  WITH nocounter, status(reply->encounter_qual[xref->add[d.seq].idx].status)
 ;end insert
 FOR (index = 1 TO xref->add_cnt)
   IF ((reply->encounter_qual[xref->add[index].idx].status=0))
    SET failed = insert_error
    SET table_name = "ENCOUNTER"
    GO TO exit_script
   ENDIF
 ENDFOR
 IF (acm_hist_ind=1)
  EXECUTE acm_add_encntr_hist
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
