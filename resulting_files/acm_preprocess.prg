CREATE PROGRAM acm_preprocess
 DECLARE scriptname = vc WITH noconstant("")
 DECLARE action = i2 WITH noconstant(0)
 SET scriptname =  $1
 SET action = cnvtint( $2)
 CASE (scriptname)
  OF "PM_SRV":
   FREE RECORD pm_srv_req
   RECORD pm_srv_req(
     1 action_type = c4
     1 process_idx = i4
     1 transaction_cd = f8
     1 person_id = f8
     1 encntr_id = f8
     1 transaction_id = f8
     1 req_attend_prsnl_id = f8
     1 req_isolation_cd = f8
     1 req_med_service_cd = f8
     1 req_accommodation_cd = f8
     1 req_alt_lvl_care_cd = f8
     1 req_disch_dt_tm = dq8
     1 req_disch_disposition_cd = f8
     1 req_disch_to_loctn_cd = f8
     1 location_cd = f8
     1 location_status_cd = f8
     1 arrive_dt_tm = dq8
     1 reg_dt_tm = dq8
     1 arrive_prsnl_id = f8
     1 depart_dt_tm = dq8
     1 depart_prsnl_id = f8
     1 transfer_reason_cd = f8
     1 transfer_dt_tm = dq8
     1 location_temp_ind = i2
     1 chart_comment_ind = i2
     1 comment_text = vc
     1 loc_facility_cd = f8
     1 loc_building_cd = f8
     1 loc_nurse_unit_cd = f8
     1 loc_room_cd = f8
     1 loc_bed_cd = f8
     1 encntr_type_cd = f8
     1 med_service_cd = f8
     1 active_status_cd = f8
     1 req_facility_cd = f8
     1 req_building_cd = f8
     1 req_nurse_unit_cd = f8
     1 req_room_cd = f8
     1 req_bed_cd = f8
     1 req_program_service_cd = f8
     1 req_specialty_unit_cd = f8
     1 transaction_dt_tm = dq8
     1 transaction_txt = vc
     1 financial_class_cd = f8
     1 pre_reg_dt_tm = dq8
     1 encntr_type_class_cd = f8
     1 old_encntr_type_class_cd = f8
     1 old_encntr_type_cd = f8
     1 encntr_status_cd = f8
     1 assign_to_loc_dt_tm = dq8
     1 admit_type_cd = f8
     1 alt_lvl_care_cd = f8
     1 old_reg_dt_tm = dq8
     1 old_pre_reg_dt_tm = dq8
     1 program_service_cd = f8
     1 specialty_unit_cd = f8
     1 missing_guar_ind = i2
     1 missing_sub_ind = i2
     1 missing_emc_ind = i2
     1 missing_nok_ind = i2
     1 organization_id = f8
     1 accommodation_cd = f8
     1 accommodation_reason_cd = f8
     1 accommodation_request_cd = f8
     1 alc_decomp_dt_tm = dq8
     1 alt_lvl_care_dt_tm = dq8
     1 alc_reason_cd = f8
     1 service_category_cd = f8
     1 pm_hist_tracking_id = f8
     1 security_access_cd = f8
     1 placement_auth_prsnl_id = f8
     1 patient_classification_cd = f8
     1 cancel_transfer_cd = f8
     1 discharge_dt_tm = dq8
     1 conversation_task = i4
     1 hist_record_copy_ind = i2
     1 encounter_01
       2 encntr_id = f8
       2 place_auth_prsnl_id = f8
       2 e1_accommodation_reason_cd = f8
     1 encounter_02
       2 encntr_id = f8
       2 place_auth_prsnl_id = f8
       2 e2_accommodation_reason_cd = f8
       2 transfer_reason_cd = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET pm_srv_req->person_id = acm_request->encounter_qual[1].person_id
   SET pm_srv_req->encntr_id = acm_request->encounter_qual[1].encntr_id
   SET pm_srv_req->location_cd = acm_request->encounter_qual[1].location_cd
   SET pm_srv_req->location_status_cd = acm_request->encntr_loc_hist_qual[1].location_status_cd
   SET pm_srv_req->arrive_dt_tm = acm_request->encntr_loc_hist_qual[1].arrive_dt_tm
   SET pm_srv_req->reg_dt_tm = acm_request->encounter_qual[1].reg_dt_tm
   SET pm_srv_req->pre_reg_dt_tm = acm_request->encounter_qual[1].pre_reg_dt_tm
   SET pm_srv_req->arrive_prsnl_id = acm_request->encntr_loc_hist_qual[1].arrive_prsnl_id
   SET pm_srv_req->depart_dt_tm = acm_request->encntr_loc_hist_qual[1].depart_dt_tm
   SET pm_srv_req->depart_prsnl_id = acm_request->encntr_loc_hist_qual[1].depart_prsnl_id
   SET pm_srv_req->transfer_reason_cd = acm_request->encntr_loc_hist_qual[1].transfer_reason_cd
   SET pm_srv_req->location_temp_ind = acm_request->encntr_loc_hist_qual[1].location_temp_ind
   SET pm_srv_req->chart_comment_ind = acm_request->encntr_loc_hist_qual[1].chart_comment_ind
   SET pm_srv_req->comment_text = acm_request->encntr_loc_hist_qual[1].comment_text
   SET pm_srv_req->loc_facility_cd = acm_request->encntr_loc_hist_qual[1].loc_facility_cd
   SET pm_srv_req->loc_building_cd = acm_request->encntr_loc_hist_qual[1].loc_building_cd
   SET pm_srv_req->loc_nurse_unit_cd = acm_request->encntr_loc_hist_qual[1].loc_nurse_unit_cd
   SET pm_srv_req->loc_room_cd = acm_request->encntr_loc_hist_qual[1].loc_room_cd
   SET pm_srv_req->loc_bed_cd = acm_request->encntr_loc_hist_qual[1].loc_bed_cd
   SET pm_srv_req->encntr_type_cd = acm_request->encounter_qual[1].encntr_type_cd
   SET pm_srv_req->med_service_cd = acm_request->encounter_qual[1].med_service_cd
   SET pm_srv_req->active_status_cd = acm_request->encounter_qual[1].active_status_cd
   SET pm_srv_req->transaction_dt_tm = acm_request->transaction_info_qual[1].transaction_dt_tm
   SET pm_srv_req->encntr_type_class_cd = acm_request->encounter_qual[1].encntr_type_class_cd
   SET pm_srv_req->encntr_status_cd = acm_request->encounter_qual[1].encntr_status_cd
   IF (action=1)
    EXECUTE pm_srv_admt  WITH replace(request,pm_srv_req)
   ELSEIF (action=2)
    EXECUTE pm_srv_updt  WITH replace(request,pm_srv_req)
   ENDIF
  OF "SVC_CAT_HIST":
   FREE RECORD svc_cat_req
   RECORD svc_cat_req(
     1 action_type = i2
     1 encntr_id = f8
     1 disch_dt_tm = dq8
     1 service_category_cd = f8
     1 attend_prsnl_id = f8
     1 transaction_dt_tm = dq8
     1 med_service_cd = f8
     1 active_status_cd = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET svc_cat_req->action_type = action
   SET svc_cat_req->encntr_id = acm_request->sevice_category_hist_qual[1].encntr_id
   SET svc_cat_req->disch_dt_tm = acm_request->encounter_qual[1].disch_dt_tm
   SET svc_cat_req->service_category_cd = acm_request->sevice_category_hist_qual[1].
   service_category_cd
   SET svc_cat_req->attend_prsnl_id = acm_request->sevice_category_hist_qual[1].attend_prnsl_id
   SET svc_cat_req->transaction_dt_tm = acm_request->sevice_category_hist_qual[1].transaction_dt_tm
   SET svc_cat_req->med_service_cd = acm_request->sevice_category_hist_qual[1].med_service_cd
   SET svc_cat_req->active_status_cd = acm_request->sevice_category_hist_qual[1].active_status_cd
   EXECUTE acm_ens_service_cat_hist  WITH replace(request,svc_cat_req)
 ENDCASE
END GO
