CREATE PROGRAM acm_post_process_transaction:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 FREE RECORD pm_get_transaction_reply
 RECORD pm_get_transaction_reply(
   1 trans
     2 transaction_id = f8
     2 activity_dt_tm = dq8
     2 transaction_dt_tm = dq8
     2 transaction = vc
     2 n_person_id = f8
     2 o_person_id = f8
     2 n_encntr_id = f8
     2 o_encntr_id = f8
     2 n_encntr_fin_id = f8
     2 o_encntr_fin_id = f8
     2 n_name_last = vc
     2 o_name_last = vc
     2 n_name_first = vc
     2 o_name_first = vc
     2 n_name_middle = vc
     2 o_name_middle = vc
     2 n_name_formatted = vc
     2 o_name_formatted = vc
     2 n_birth_dt_cd = f8
     2 o_birth_dt_cd = f8
     2 n_birth_dt_tm = dq8
     2 o_birth_dt_tm = dq8
     2 n_person_sex_cd = f8
     2 o_person_sex_cd = f8
     2 n_conception_dt_tm = dq8
     2 o_conception_dt_tm = dq8
     2 n_cause_of_death = vc
     2 o_cause_of_death = vc
     2 n_deceased_cd = f8
     2 o_deceased_cd = f8
     2 n_deceased_dt_tm = dq8
     2 o_deceased_dt_tm = dq8
     2 n_sex_age_chg_ind = i2
     2 o_sex_age_chg_ind = i2
     2 n_species_cd = f8
     2 o_species_cd = f8
     2 n_confid_level_cd = f8
     2 o_confid_level_cd = f8
     2 n_person_vip_cd = f8
     2 o_person_vip_cd = f8
     2 n_mthr_maid_name = vc
     2 o_mthr_maid_name = vc
     2 n_encntr_class_cd = f8
     2 o_encntr_class_cd = f8
     2 n_encntr_type_cd = f8
     2 o_encntr_type_cd = f8
     2 n_encntr_type_class_cd = f8
     2 o_encntr_type_class_cd = f8
     2 n_encntr_status_cd = f8
     2 o_encntr_status_cd = f8
     2 n_pre_reg_dt_tm = dq8
     2 o_pre_reg_dt_tm = dq8
     2 n_reg_dt_tm = dq8
     2 o_reg_dt_tm = dq8
     2 n_est_arrive_dt_tm = dq8
     2 o_est_arrive_dt_tm = dq8
     2 n_est_depart_dt_tm = dq8
     2 o_est_depart_dt_tm = dq8
     2 n_arrive_dt_tm = dq8
     2 o_arrive_dt_tm = dq8
     2 n_depart_dt_tm = dq8
     2 o_depart_dt_tm = dq8
     2 n_admit_type_cd = f8
     2 o_admit_type_cd = f8
     2 n_admit_src_cd = f8
     2 o_admit_src_cd = f8
     2 n_admit_mode_cd = f8
     2 o_admit_mode_cd = f8
     2 n_admit_with_med_cd = f8
     2 o_admit_with_med_cd = f8
     2 n_refer_comment = vc
     2 o_refer_comment = vc
     2 n_disch_disp_cd = f8
     2 o_disch_disp_cd = f8
     2 n_disch_to_loctn_cd = f8
     2 o_disch_to_loctn_cd = f8
     2 n_preadmit_nbr = vc
     2 o_preadmit_nbr = vc
     2 n_preadmit_test_cd = f8
     2 o_preadmit_test_cd = f8
     2 n_readmit_cd = f8
     2 o_readmit_cd = f8
     2 n_accom_cd = f8
     2 o_accom_cd = f8
     2 n_accom_req_cd = f8
     2 o_accom_req_cd = f8
     2 n_alt_result_dest_cd = f8
     2 o_alt_result_dest_cd = f8
     2 n_amb_cond_cd = f8
     2 o_amb_cond_cd = f8
     2 n_diet_type_cd = f8
     2 o_diet_type_cd = f8
     2 n_isolation_cd = f8
     2 o_isolation_cd = f8
     2 n_med_service_cd = f8
     2 o_med_service_cd = f8
     2 n_result_dest_cd = f8
     2 o_result_dest_cd = f8
     2 n_encntr_vip_cd = f8
     2 o_encntr_vip_cd = f8
     2 n_disch_dt_tm = dq8
     2 o_disch_dt_tm = dq8
     2 n_guar_type_cd = f8
     2 o_guar_type_cd = f8
     2 n_loc_temp_cd = f8
     2 o_loc_temp_cd = f8
     2 n_reason_for_visit = vc
     2 o_reason_for_visit = vc
     2 n_fin_class_cd = f8
     2 o_fin_class_cd = f8
     2 n_location_cd = f8
     2 o_location_cd = f8
     2 n_loc_facility_cd = f8
     2 o_loc_facility_cd = f8
     2 n_loc_building_cd = f8
     2 o_loc_building_cd = f8
     2 n_loc_nurse_unit_cd = f8
     2 o_loc_nurse_unit_cd = f8
     2 n_loc_room_cd = f8
     2 o_loc_room_cd = f8
     2 n_loc_bed_cd = f8
     2 o_loc_bed_cd = f8
     2 n_encntr_complete_dt_tm = dq8
     2 o_encntr_complete_dt_tm = dq8
     2 n_organization_id = f8
     2 o_organization_id = f8
     2 o_contributor_system_cd = f8
     2 n_contributor_system_cd = f8
     2 o_assign_to_loc_dt_tm = dq8
     2 n_assign_to_loc_dt_tm = dq8
     2 o_alt_lvl_care_cd = f8
     2 n_alt_lvl_care_cd = f8
     2 n_program_service_cd = f8
     2 o_program_service_cd = f8
     2 n_specialty_unit_cd = f8
     2 o_specialty_unit_cd = f8
     2 mental_health_cd = f8
     2 mental_health_dt_tm = dq8
     2 pm_hist_tracking_id = f8
     2 n_birth_tz = i4
     2 o_birth_tz = i4
     2 abs_n_birth_dt_tm = dq8
     2 abs_o_birth_dt_tm = dq8
     2 n_service_category_cd = f8
     2 o_service_category_cd = f8
     2 n_attend_doc_id = f8
     2 o_attend_doc_id = f8
     2 output_dest_cd = f8
     2 process_slice_ind = i2
     2 process_post_doc_ind = i2
     2 n_person_birth_sex_cd = f8
     2 o_person_birth_sex_cd = f8
     2 n_cmnty_case_status_cd = f8
     2 o_cmnty_case_status_cd = f8
     2 n_cmnty_case_enrollment_dt_tm = dq8
     2 o_cmnty_case_enrollment_dt_tm = dq8
     2 n_cmnty_case_closure_reason_cd = f8
     2 o_cmnty_case_closure_reason_cd = f8
     2 n_chart_access_organization_id = f8
     2 o_chart_access_organization_id = f8
     2 o_authorization_id = f8
     2 n_authorization_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE pm_get_transaction  WITH replace("REPLY","PM_GET_TRANSACTION_REPLY")
 IF ((pm_get_transaction_reply->status_data.status="F"))
  SET failed = execute_error
  SET table_name = "Failed executing pm_get_transaction"
  SET reply->status_data.status = pm_get_transaction_reply->status_data.status
  FOR (index = 1 TO size(pm_get_transaction_reply->status_data.subeventstatus,5))
    CALL s_add_subeventstatus(pm_get_transaction_reply->status_data.subeventstatus[index].
     operationname,pm_get_transaction_reply->status_data.subeventstatus[index].operationstatus,
     pm_get_transaction_reply->status_data.subeventstatus[index].targetobjectname,
     pm_get_transaction_reply->status_data.subeventstatus[index].targetobjectvalue)
  ENDFOR
  GO TO exit_script
 ENDIF
 EXECUTE pm_call_post_transaction  WITH replace("REQUEST","PM_GET_TRANSACTION_REPLY")
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 += 1
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
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
    SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
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
 ENDIF
END GO
