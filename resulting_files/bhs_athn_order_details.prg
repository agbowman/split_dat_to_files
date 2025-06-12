CREATE PROGRAM bhs_athn_order_details
 RECORD orequest(
   1 orders[*]
     2 order_id = f8
   1 person_id = f8
   1 encntr_qual[*]
     2 encntr_id = f8
   1 catalog[*]
     2 catalog_type_cd = f8
   1 orig_ord_as_flag = i2
   1 comment_flag = i2
   1 details_flag = i2
   1 entity_flag = i2
   1 summary_flag = i2
   1 encntr_ind = i2
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 activity[*]
     2 activity_type_cd = f8
   1 status[*]
     2 order_status_cd = f8
   1 mode_flag = i2
   1 dept[*]
     2 dept_status_cd = f8
   1 activity_sub[*]
     2 activity_subtype_cd = f8
   1 event_cd_ind = i2
   1 accession_id = f8
   1 accession = vc
   1 inactive_ind = i2
   1 orig_ord_as_flag_filter[*]
     2 orig_ord_as_flag = i2
 )
 FREE RECORD out_rec
 RECORD out_rec(
   1 decoder_bogus_cd = vc
   1 decoder_bogus_disp = vc
   1 decoder_bogus_mean = vc
   1 qual[*]
     2 order_id = vc
     2 catalog_type_cd = vc
     2 catalog_type_disp = vc
     2 catalog_type_mean = vc
     2 med_order_type_cd = vc
     2 med_order_type_disp = vc
     2 med_order_type_mean = vc
     2 orig_ord_as_flag = vc
     2 activity_type_cd = vc
     2 activity_type_disp = vc
     2 activity_type_mean = vc
     2 catalog_cd = vc
     2 catalog_disp = vc
     2 catalog_mean = vc
     2 source_cd = vc
     2 prescription_order_id = vc
     2 person_id = vc
     2 encntr_id = vc
     2 dcp_clin_cat_cd = vc
     2 dcp_clin_cat_disp = vc
     2 dcp_clin_cat_mean = vc
     2 order_status_cd = vc
     2 order_status_disp = vc
     2 order_status_mean = vc
     2 incomplete_order_ind = vc
     2 dept_status_cd = vc
     2 dept_status_disp = vc
     2 dept_status_mean = vc
     2 order_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 orig_order_dt_tm = vc
     2 orig_order_tz = vc
     2 last_update_provider_id = vc
     2 last_update_provider_name = vc
     2 template_order_id = vc
     2 template_order_flag = vc
     2 synonym_id = vc
     2 order_detail_display_line = vc
     2 clinical_display_line = vc
     2 oe_format_id = vc
     2 constant_ind = vc
     2 prn_ind = vc
     2 need_rx_verify_ind = vc
     2 need_rx_clin_review_flag = vc
     2 need_nurse_review_ind = vc
     2 need_doctor_cosign_ind = vc
     2 current_start_dt_tm = vc
     2 current_start_tz = vc
     2 projected_stop_dt_tm = vc
     2 projected_stop_tz = vc
     2 stop_type_cd = vc
     2 stop_type_disp = vc
     2 stop_type_mean = vc
     2 suspend_ind = vc
     2 suspend_effective_dt_tm = vc
     2 resume_ind = vc
     2 resume_effective_dt_tm = vc
     2 discontinue_ind = vc
     2 discontinue_effective_dt_tm = vc
     2 discontinue_effective_tz = vc
     2 discontinue_type_cd = vc
     2 last_updt_cnt = vc
     2 last_action_seq = vc
     2 ref_text_mask = vc
     2 orderable_type_flag = vc
     2 interval_ind = vc
     2 hide_flag = vc
     2 comment_type_mask = vc
     2 cki = vc
     2 freq_type_flag = vc
     2 ingredient_ind = vc
     2 rx_mask = vc
     2 diluent_ind = vc
     2 additive_ind = vc
     2 med_ind = vc
     2 order_comment_ind = vc
     2 updt_id = vc
     2 cs_order_id = vc
     2 cs_flag = vc
     2 communication_type_cd = vc
     2 communication_type_disp = vc
     2 communication_type_mean = vc
     2 action_personnel_id = vc
     2 order_provider_id = vc
     2 action_personnel_name = vc
     2 order_provider_name = vc
     2 accession_id = vc
     2 accession = vc
     2 accession_format = vc
     2 activity_subtype_cd = vc
     2 cancel_communication_type_cd = vc
     2 bill_only_ind = vc
     2 updt_dt_tm = vc
     2 status_dt_tm = vc
     2 last_ingred_action_sequence = vc
     2 comments[*]
     2 detqual[*]
       3 oe_field_display_value = vc
       3 label_text = vc
       3 group_seq = vc
       3 field_seq = vc
       3 oe_field_meaning = vc
       3 oe_field_id = vc
       3 oe_field_dt_tm = vc
       3 oe_field_tz = vc
       3 oe_field_meaning_id = vc
       3 oe_field_value = vc
     2 renew_ind = vc
     2 entity_activity_updt_cnt = vc
     2 entity_activity_updt_dt_tm = vc
     2 actual_dose = vc
     2 target_dose = vc
     2 proposal_status_disp = vc
     2 pathway_plan = vc
     2 dx_string = vc
   1 status = vc
 )
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET cnt = 0
 SET t_line =  $2
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET cnt = (cnt+ 1)
    SET stat = alterlist(orequest->orders,cnt)
    SET orequest->orders[cnt].order_id = cnvtreal(t_line)
    SET done = 1
   ELSE
    SET cnt = (cnt+ 1)
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(orequest->orders,cnt)
    SET orequest->orders[cnt].order_id = cnvtreal(t_line2)
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 SET orequest->details_flag = 1
 SET orequest->comment_flag = 1
 SET orequest->summary_flag = 1
 SET orequest->entity_flag = 1
 SET stat = tdbexecute(3200000,3200081,3200138,"REC",orequest,
  "REC",oreply)
 DECLARE pname = vc WITH protect
 SUBROUTINE get_prsnl_name(pid)
   SELECT INTO "NL:"
    FROM prsnl pr
    PLAN (pr
     WHERE pr.person_id=cnvtint(pid))
    DETAIL
     pname = pr.name_full_formatted
    WITH nocounter, time = 30
   ;end select
 END ;Subroutine
 IF ((oreply->status_data.status="S"))
  SET out_rec->status = "Success"
 ELSE
  SET out_rec->status = "Failed"
 ENDIF
 SET stat = alterlist(out_rec->qual,size(oreply->qual,5))
 FOR (i = 1 TO size(oreply->qual,5))
   SET out_rec->qual[i].order_id = cnvtstring(oreply->qual[i].order_id)
   SET out_rec->qual[i].catalog_type_cd = cnvtstring(oreply->qual[i].catalog_type_cd)
   SET out_rec->qual[i].catalog_type_disp = oreply->qual[i].catalog_type_disp
   SET out_rec->qual[i].catalog_type_mean = oreply->qual[i].catalog_type_mean
   SET out_rec->qual[i].med_order_type_cd = cnvtstring(oreply->qual[i].med_order_type_cd)
   SET out_rec->qual[i].med_order_type_disp = uar_get_code_display(oreply->qual[i].med_order_type_cd)
   SET out_rec->qual[i].med_order_type_mean = uar_get_code_meaning(oreply->qual[i].med_order_type_cd)
   IF ((oreply->qual[i].orig_ord_as_flag=0.00))
    SET out_rec->qual[i].orig_ord_as_flag = "NormalOrder"
   ELSEIF ((oreply->qual[i].orig_ord_as_flag=1.00))
    SET out_rec->qual[i].orig_ord_as_flag = "PrescriptionDischarge"
   ELSEIF ((oreply->qual[i].orig_ord_as_flag=2.00))
    SET out_rec->qual[i].orig_ord_as_flag = "RecordedOrHomeMeds"
   ELSEIF ((oreply->qual[i].orig_ord_as_flag=3.00))
    SET out_rec->qual[i].orig_ord_as_flag = "PatientOwnsMeds"
   ELSEIF ((oreply->qual[i].orig_ord_as_flag=4.00))
    SET out_rec->qual[i].orig_ord_as_flag = "PharmacyChargeOnly"
   ELSEIF ((oreply->qual[i].orig_ord_as_flag=5.00))
    SET out_rec->qual[i].orig_ord_as_flag = "SuperBill"
   ENDIF
   SET out_rec->qual[i].activity_type_cd = cnvtstring(oreply->qual[i].activity_type_cd)
   SET out_rec->qual[i].activity_type_disp = oreply->qual[i].activity_type_disp
   SET out_rec->qual[i].activity_type_mean = uar_get_code_meaning(oreply->qual[i].activity_type_cd)
   SET out_rec->qual[i].catalog_cd = cnvtstring(oreply->qual[i].catalog_cd)
   SET out_rec->qual[i].catalog_disp = oreply->qual[i].catalog_disp
   SET out_rec->qual[i].catalog_mean = oreply->qual[i].catalog_mean
   SET out_rec->qual[i].source_cd = cnvtstring(oreply->qual[i].source_cd)
   SET out_rec->qual[i].prescription_order_id = cnvtstring(oreply->qual[i].prescription_order_id)
   SET out_rec->qual[i].person_id = cnvtstring(oreply->qual[i].person_id)
   SET out_rec->qual[i].encntr_id = cnvtstring(oreply->qual[i].encntr_id)
   SET out_rec->qual[i].dcp_clin_cat_cd = cnvtstring(oreply->qual[i].dcp_clin_cat_cd)
   SET out_rec->qual[i].dcp_clin_cat_disp = oreply->qual[i].dcp_clin_cat_disp
   SET out_rec->qual[i].dcp_clin_cat_mean = uar_get_code_meaning(oreply->qual[i].dcp_clin_cat_cd)
   SET out_rec->qual[i].order_status_cd = cnvtstring(oreply->qual[i].order_status_cd)
   SET out_rec->qual[i].order_status_disp = oreply->qual[i].order_status_disp
   SET out_rec->qual[i].order_status_mean = uar_get_code_meaning(oreply->qual[i].order_status_cd)
   SET out_rec->qual[i].incomplete_order_ind = cnvtstring(oreply->qual[i].incomplete_order_ind)
   SET out_rec->qual[i].dept_status_cd = cnvtstring(oreply->qual[i].dept_status_cd)
   SET out_rec->qual[i].dept_status_mean = uar_get_code_meaning(oreply->qual[i].dept_status_cd)
   SET out_rec->qual[i].dept_status_disp = oreply->qual[i].dept_status_disp
   SET out_rec->qual[i].order_mnemonic = oreply->qual[i].order_mnemonic
   SET out_rec->qual[i].hna_order_mnemonic = oreply->qual[i].hna_order_mnemonic
   SET out_rec->qual[i].ordered_as_mnemonic = oreply->qual[i].ordered_as_mnemonic
   SET out_rec->qual[i].orig_order_dt_tm = datetimezoneformat(oreply->qual[i].orig_order_dt_tm,oreply
    ->qual[i].orig_order_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
   SET out_rec->qual[i].orig_order_tz = substring(21,3,datetimezoneformat(oreply->qual[i].
     orig_order_dt_tm,oreply->qual[i].orig_order_tz,"mm/dd/yyyy hh:mm:ss ZZZ",curtimezonedef))
   SET out_rec->qual[i].last_update_provider_id = cnvtstring(oreply->qual[i].last_update_provider_id)
   CALL get_prsnl_name(oreply->qual[i].last_update_provider_id)
   SET out_rec->qual[i].last_update_provider_name = pname
   SET out_rec->qual[i].template_order_id = cnvtstring(oreply->qual[i].template_order_id)
   IF ((oreply->qual[i].template_order_flag=0.00))
    SET out_rec->qual[i].template_order_flag = "None"
   ELSEIF ((oreply->qual[i].template_order_flag=1.00))
    SET out_rec->qual[i].template_order_flag = "Template"
   ELSEIF ((oreply->qual[i].template_order_flag=2.00))
    SET out_rec->qual[i].template_order_flag = "Order Based Instance"
   ELSEIF ((oreply->qual[i].template_order_flag=3.00))
    SET out_rec->qual[i].template_order_flag = "Task Based Instance"
   ELSEIF ((oreply->qual[i].template_order_flag=4.00))
    SET out_rec->qual[i].template_order_flag = "Rx Based Instance"
   ELSEIF ((oreply->qual[i].template_order_flag=5.00))
    SET out_rec->qual[i].template_order_flag = "Future Recurring Template"
   ELSEIF ((oreply->qual[i].template_order_flag=6.00))
    SET out_rec->qual[i].template_order_flag = "Future Recurring Instance"
   ELSEIF ((oreply->qual[i].template_order_flag=7.00))
    SET out_rec->qual[i].template_order_flag = "Protocol"
   ENDIF
   SET out_rec->qual[i].synonym_id = cnvtstring(oreply->qual[i].synonym_id)
   SET out_rec->qual[i].order_detail_display_line = oreply->qual[i].order_detail_display_line
   SET out_rec->qual[i].clinical_display_line = oreply->qual[i].clinical_display_line
   SET out_rec->qual[i].oe_format_id = cnvtstring(oreply->qual[i].oe_format_id)
   IF ((oreply->qual[i].constant_ind=1))
    SET out_rec->qual[i].constant_ind = "true"
   ELSE
    SET out_rec->qual[i].constant_ind = "false"
   ENDIF
   IF ((oreply->qual[i].prn_ind=1))
    SET out_rec->qual[i].prn_ind = "true"
   ELSE
    SET out_rec->qual[i].prn_ind = "false"
   ENDIF
   IF ((oreply->qual[i].need_rx_verify_ind=0))
    SET out_rec->qual[i].need_rx_verify_ind = "PharmacistReviewNotRequired"
   ELSEIF ((oreply->qual[i].need_rx_verify_ind=1))
    SET out_rec->qual[i].need_rx_verify_ind = "NeedsPharmacistReview"
   ELSEIF ((oreply->qual[i].need_rx_verify_ind=2))
    SET out_rec->qual[i].need_rx_verify_ind = "RejectedByPharmacist"
   ENDIF
   IF ((oreply->qual[i].need_rx_clin_review_flag=0))
    SET out_rec->qual[i].need_rx_clin_review_flag = "PharmacistReviewNotRequired"
   ELSEIF ((oreply->qual[i].need_rx_clin_review_flag=1))
    SET out_rec->qual[i].need_rx_clin_review_flag = "NeedsPharmacistReview"
   ELSEIF ((oreply->qual[i].need_rx_clin_review_flag=2))
    SET out_rec->qual[i].need_rx_clin_review_flag = "RejectedByPharmacist"
   ENDIF
   IF ((oreply->qual[i].need_nurse_review_ind=1))
    SET out_rec->qual[i].need_nurse_review_ind = "NurseReviewRequired"
   ELSE
    SET out_rec->qual[i].need_nurse_review_ind = "NurseReviewNotRequired"
   ENDIF
   IF ((oreply->qual[i].need_doctor_cosign_ind=0.00))
    SET out_rec->qual[i].need_doctor_cosign_ind = "DoesNotNeedDoctorCosign"
   ELSEIF ((oreply->qual[i].need_doctor_cosign_ind=1.00))
    SET out_rec->qual[i].need_doctor_cosign_ind = "NeedsDoctorCosign"
   ELSEIF ((oreply->qual[i].need_doctor_cosign_ind=2.00))
    SET out_rec->qual[i].need_doctor_cosign_ind = "CosignRefusedByDoctor"
   ENDIF
   SET out_rec->qual[i].current_start_dt_tm = datetimezoneformat(oreply->qual[i].current_start_dt_tm,
    oreply->qual[i].current_start_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
   SET out_rec->qual[i].current_start_tz = substring(21,3,datetimezoneformat(oreply->qual[i].
     current_start_dt_tm,oreply->qual[i].current_start_tz,"mm/dd/yyyy hh:mm:ss ZZZ",curtimezonedef))
   SET out_rec->qual[i].projected_stop_dt_tm = datetimezoneformat(oreply->qual[i].
    projected_stop_dt_tm,oreply->qual[i].projected_stop_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
   SET out_rec->qual[i].projected_stop_tz = substring(21,3,datetimezoneformat(oreply->qual[i].
     projected_stop_dt_tm,oreply->qual[i].projected_stop_tz,"mm/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)
    )
   SET out_rec->qual[i].stop_type_cd = cnvtstring(oreply->qual[i].stop_type_cd)
   SET out_rec->qual[i].stop_type_disp = uar_get_code_display(oreply->qual[i].stop_type_cd)
   SET out_rec->qual[i].stop_type_mean = uar_get_code_meaning(oreply->qual[i].stop_type_cd)
   IF ((oreply->qual[i].suspend_ind=1))
    SET out_rec->qual[i].suspend_ind = "true"
   ELSE
    SET out_rec->qual[i].suspend_ind = "false"
   ENDIF
   SET out_rec->qual[i].suspend_effective_dt_tm = datetimezoneformat(oreply->qual[i].
    suspend_effective_dt_tm,curtimezonesys,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
   IF ((oreply->qual[i].resume_ind=1))
    SET out_rec->qual[i].resume_ind = "true"
   ELSE
    SET out_rec->qual[i].resume_ind = "false"
   ENDIF
   SET out_rec->qual[i].resume_effective_dt_tm = datetimezoneformat(oreply->qual[i].
    resume_effective_dt_tm,curtimezonesys,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
   IF ((oreply->qual[i].discontinue_ind=1))
    SET out_rec->qual[i].discontinue_ind = "true"
   ELSE
    SET out_rec->qual[i].discontinue_ind = "false"
   ENDIF
   SET out_rec->qual[i].discontinue_effective_dt_tm = datetimezoneformat(oreply->qual[i].
    discontinue_effective_dt_tm,oreply->qual[i].discontinue_effective_tz,"MM/dd/yyyy HH:mm:ss",
    curtimezonedef)
   SET out_rec->qual[i].discontinue_effective_tz = substring(21,3,datetimezoneformat(oreply->qual[i].
     discontinue_effective_dt_tm,oreply->qual[i].discontinue_effective_tz,"mm/dd/yyyy hh:mm:ss ZZZ",
     curtimezonedef))
   SET out_rec->qual[i].discontinue_type_cd = cnvtstring(oreply->qual[i].discontinue_type_cd)
   SET out_rec->qual[i].last_updt_cnt = cnvtstring(oreply->qual[i].last_updt_cnt)
   SET out_rec->qual[i].last_action_seq = cnvtstring(oreply->qual[i].last_action_seq)
   SET out_rec->qual[i].ref_text_mask = cnvtstring(oreply->qual[i].ref_text_mask)
   IF ((oreply->qual[i].orderable_type_flag=0.00))
    SET out_rec->qual[i].orderable_type_flag = "Normal"
   ELSEIF ((oreply->qual[i].orderable_type_flag=1.00))
    SET out_rec->qual[i].orderable_type_flag = "CaresetSupergroup"
   ELSEIF ((oreply->qual[i].orderable_type_flag=2.00))
    SET out_rec->qual[i].orderable_type_flag = "Careplan"
   ELSEIF ((oreply->qual[i].orderable_type_flag=3.00))
    SET out_rec->qual[i].orderable_type_flag = "AnatomicPathologySpecial"
   ELSEIF ((oreply->qual[i].orderable_type_flag=4.00))
    SET out_rec->qual[i].orderable_type_flag = "DepartmentOnly"
   ELSEIF ((oreply->qual[i].orderable_type_flag=5.00))
    SET out_rec->qual[i].orderable_type_flag = "CaresetOrderSet"
   ELSEIF ((oreply->qual[i].orderable_type_flag=6.00))
    SET out_rec->qual[i].orderable_type_flag = "HomeHealthProblem"
   ELSEIF ((oreply->qual[i].orderable_type_flag=7.00))
    SET out_rec->qual[i].orderable_type_flag = "MultiIngredient"
   ELSEIF ((oreply->qual[i].orderable_type_flag=8.00))
    SET out_rec->qual[i].orderable_type_flag = "IntervalTest"
   ELSEIF ((oreply->qual[i].orderable_type_flag=9.00))
    SET out_rec->qual[i].orderable_type_flag = "Freetext"
   ELSEIF ((oreply->qual[i].orderable_type_flag=11.00))
    SET out_rec->qual[i].orderable_type_flag = "TPN"
   ELSEIF ((oreply->qual[i].orderable_type_flag=12.00))
    SET out_rec->qual[i].orderable_type_flag = "Attachment"
   ELSEIF ((oreply->qual[i].orderable_type_flag=13.00))
    SET out_rec->qual[i].orderable_type_flag = "Compound"
   ENDIF
   IF ((oreply->qual[i].interval_ind=1))
    SET out_rec->qual[i].interval_ind = "true"
   ELSE
    SET out_rec->qual[i].interval_ind = "false"
   ENDIF
   SET out_rec->qual[i].hide_flag = cnvtstring(oreply->qual[i].hide_flag)
   SET out_rec->qual[i].comment_type_mask = cnvtstring(oreply->qual[i].comment_type_mask)
   SET out_rec->qual[i].cki = oreply->qual[i].cki
   SET out_rec->qual[i].freq_type_flag = cnvtstring(oreply->qual[i].freq_type_flag)
   IF ((oreply->qual[i].ingredient_ind=1))
    SET out_rec->qual[i].ingredient_ind = "ture"
   ELSE
    SET out_rec->qual[i].ingredient_ind = "false"
   ENDIF
   SET out_rec->qual[i].rx_mask = cnvtstring(oreply->qual[i].rx_mask)
   SET out_rec->qual[i].diluent_ind = cnvtstring(evaluate(band(oreply->qual[i].rx_mask,1),0,0,1))
   SET out_rec->qual[i].additive_ind = cnvtstring(evaluate(band(oreply->qual[i].rx_mask,2),0,0,1))
   SET out_rec->qual[i].med_ind = cnvtstring(evaluate(band(oreply->qual[i].rx_mask,4),0,0,1))
   IF ((oreply->qual[i].order_comment_ind=1))
    SET out_rec->qual[i].order_comment_ind = "ture"
   ELSE
    SET out_rec->qual[i].order_comment_ind = "false"
   ENDIF
   SET out_rec->qual[i].updt_id = cnvtstring(oreply->qual[i].updt_id)
   SET out_rec->qual[i].cs_order_id = cnvtstring(oreply->qual[i].cs_order_id)
   SET out_rec->qual[i].cs_flag = cnvtstring(oreply->qual[i].cs_flag)
   SET out_rec->qual[i].communication_type_cd = cnvtstring(oreply->qual[i].communication_type_cd)
   SET out_rec->qual[i].communication_type_disp = uar_get_code_display(oreply->qual[i].
    communication_type_cd)
   SET out_rec->qual[i].communication_type_mean = uar_get_code_meaning(oreply->qual[i].
    communication_type_cd)
   SET out_rec->qual[i].action_personnel_id = cnvtstring(oreply->qual[i].action_personnel_id)
   SET out_rec->qual[i].order_provider_id = cnvtstring(oreply->qual[i].order_provider_id)
   CALL get_prsnl_name(oreply->qual[i].action_personnel_id)
   SET out_rec->qual[i].action_personnel_name = pname
   CALL get_prsnl_name(oreply->qual[i].order_provider_id)
   SET out_rec->qual[i].order_provider_name = pname
   SET out_rec->qual[i].accession_id = cnvtstring(oreply->qual[i].accession_id)
   SET out_rec->qual[i].accession = oreply->qual[i].accession
   SET out_rec->qual[i].accession_format = oreply->qual[i].accession_format
   SET out_rec->qual[i].activity_subtype_cd = cnvtstring(oreply->qual[i].activity_subtype_cd)
   SET out_rec->qual[i].cancel_communication_type_cd = cnvtstring(oreply->qual[i].
    cancel_communication_type_cd)
   IF ((oreply->qual[i].bill_only_ind=1))
    SET out_rec->qual[i].bill_only_ind = "true"
   ELSE
    SET out_rec->qual[i].bill_only_ind = "false"
   ENDIF
   SET out_rec->qual[i].updt_dt_tm = datetimezoneformat(oreply->qual[i].updt_dt_tm,curtimezonesys,
    "MM/dd/yyyy HH:mm:ss",curtimezonedef)
   SET out_rec->qual[i].status_dt_tm = datetimezoneformat(oreply->qual[i].status_dt_tm,curtimezonesys,
    "MM/dd/yyyy HH:mm:ss",curtimezonedef)
   SET out_rec->qual[i].last_ingred_action_sequence = cnvtstring(oreply->qual[i].
    last_ingred_action_sequence)
   IF ((oreply->qual[i].renew_ind=1))
    SET out_rec->qual[i].renew_ind = "true"
   ELSE
    SET out_rec->qual[i].renew_ind = "false"
   ENDIF
   SET out_rec->qual[i].entity_activity_updt_cnt = cnvtstring(oreply->qual[i].
    entity_activity_updt_cnt)
   SET out_rec->qual[i].entity_activity_updt_dt_tm = datetimezoneformat(oreply->qual[i].
    entity_activity_updt_dt_tm,curtimezonesys,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
   SET stat = alterlist(out_rec->qual[i].detqual,size(oreply->qual[i].detqual,5))
   FOR (j = 1 TO size(oreply->qual[i].detqual,5))
     SET out_rec->qual[i].detqual[j].field_seq = cnvtstring(oreply->qual[i].detqual[j].field_seq)
     SET out_rec->qual[i].detqual[j].group_seq = cnvtstring(oreply->qual[i].detqual[j].group_seq)
     SET out_rec->qual[i].detqual[j].label_text = oreply->qual[i].detqual[j].label_text
     SET out_rec->qual[i].detqual[j].oe_field_display_value = oreply->qual[i].detqual[j].
     oe_field_display_value
     SET out_rec->qual[i].detqual[j].oe_field_dt_tm = datetimezoneformat(oreply->qual[i].detqual[j].
      oe_field_dt_tm,oreply->qual[i].detqual[j].oe_field_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef)
     SET out_rec->qual[i].detqual[j].oe_field_id = cnvtstring(oreply->qual[i].detqual[j].oe_field_id)
     SET out_rec->qual[i].detqual[j].oe_field_meaning = oreply->qual[i].detqual[j].oe_field_meaning
     SET out_rec->qual[i].detqual[j].oe_field_meaning_id = cnvtstring(oreply->qual[i].detqual[j].
      oe_field_meaning_id)
     SET out_rec->qual[i].detqual[j].oe_field_tz = substring(21,3,datetimezoneformat(oreply->qual[i].
       detqual[j].oe_field_dt_tm,oreply->qual[i].detqual[j].oe_field_tz,"mm/dd/yyyy hh:mm:ss ZZZ",
       curtimezonedef))
     SET out_rec->qual[i].detqual[j].oe_field_value = cnvtstring(oreply->qual[i].detqual[j].
      oe_field_value)
   ENDFOR
 ENDFOR
 IF ((out_rec->status="Success"))
  SELECT INTO "NL:"
   FROM (dummyt d1  WITH seq = size(out_rec->qual,5)),
    order_ingredient o,
    order_action oa,
    orders os,
    long_text lt,
    order_proposal op,
    pathway_catalog p
   PLAN (d1)
    JOIN (os
    WHERE os.order_id=cnvtreal(out_rec->qual[d1.seq].order_id))
    JOIN (oa
    WHERE oa.order_id=os.order_id
     AND ((oa.action_type_cd=2534) OR (((oa.action_type_cd=2533) OR (((oa.action_type_cd=2535) OR (((
    oa.action_type_cd=2524) OR (((oa.action_type_cd=2528) OR (oa.action_type_cd=614536)) )) )) )) ))
    )
    JOIN (o
    WHERE o.order_id=outerjoin(oa.order_id)
     AND o.action_sequence=outerjoin(oa.action_sequence))
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(o.dose_calculator_long_text_id))
    JOIN (op
    WHERE op.order_id=outerjoin(os.order_id))
    JOIN (p
    WHERE p.pathway_catalog_id=outerjoin(os.pathway_catalog_id))
   HEAD REPORT
    targetdosex = findstring("<TargetDose",lt.long_text), targetdosey = findstring(">",lt.long_text,
     targetdosex), targetdosez = findstring("</TargetDose",lt.long_text),
    target_dose1 = substring((targetdosey+ 1),(targetdosez - (targetdosey+ 1)),lt.long_text),
    targetdoseunitx = findstring("<TargetDoseUnitDisp",lt.long_text), targetdoseunity = findstring(
     ">",lt.long_text,targetdoseunitx),
    targetdoseunitz = findstring("</TargetDoseUnitDisp",lt.long_text), target_dose_unit = substring((
     targetdoseunity+ 1),(targetdoseunitz - (targetdoseunity+ 1)),lt.long_text), actualdosex =
    findstring("<ActualFinalDose",lt.long_text),
    actualdosey = findstring(">",lt.long_text,actualdosex), actualdosez = findstring(
     "</ActualFinalDose",lt.long_text), actual_dose1 = substring((actualdosey+ 1),(actualdosez - (
     actualdosey+ 1)),lt.long_text),
    actualdoseunitx = findstring("<ActualFinalDoseUnitDisp",lt.long_text), actualdoseunity =
    findstring(">",lt.long_text,actualdoseunitx), actualdoseunitz = findstring(
     "</ActualFinalDoseUnitDisp",lt.long_text),
    actual_dose_unit = substring((actualdoseunity+ 1),(actualdoseunitz - (actualdoseunity+ 1)),lt
     .long_text)
    IF (target_dose1 != " ")
     out_rec->qual[d1.seq].target_dose = build(target_dose1,"|",target_dose_unit)
    ENDIF
    IF (actual_dose1 != " ")
     out_rec->qual[d1.seq].actual_dose = trim(build(actual_dose1,"|",actual_dose_unit),3)
    ENDIF
    out_rec->qual[d1.seq].proposal_status_disp = uar_get_code_display(op.proposal_status_cd), out_rec
    ->qual[d1.seq].pathway_plan = p.description
   WITH time = 20
  ;end select
  DECLARE dx_str = vc
  SELECT INTO "nl:"
   n.source_identifier, n.source_string, n.nomenclature_id,
   d.entity1_id, rank = trim(cnvtstring(d.rank_sequence))
   FROM (dummyt d2  WITH seq = size(out_rec->qual,5)),
    dcp_entity_reltn d,
    diagnosis dx,
    nomenclature n
   PLAN (d2)
    JOIN (d
    WHERE d.entity1_id=cnvtreal(out_rec->qual[d2.seq].order_id)
     AND d.entity_reltn_mean="ORDERS/DIAGN")
    JOIN (dx
    WHERE dx.diagnosis_id=d.entity2_id)
    JOIN (n
    WHERE n.nomenclature_id=dx.nomenclature_id)
   ORDER BY d.entity1_id
   HEAD d.entity1_id
    dx_str = " "
   DETAIL
    IF (d.entity2_id != 0)
     dx_str = concat(dx_str,trim(cnvtstring(d.entity2_id),3),"|",trim(n.source_identifier,3),"|",
      trim(d.entity2_display,3),"|",trim(rank),"||")
    ENDIF
   FOOT  d.entity1_id
    out_rec->qual[d2.seq].dx_string = dx_str
   WITH nocounter, time = 30
  ;end select
  IF (dx_str=" ")
   SELECT INTO "nl:"
    order_id = cnvtreal(cnvtreal(out_rec->qual[d2.seq].order_id))
    FROM (dummyt d2  WITH seq = size(out_rec->qual,5)),
     (dummyt d3  WITH seq = 1),
     nomenclature n
    PLAN (d2
     WHERE maxrec(d3,size(out_rec->qual[d2.seq].detqual,5)))
     JOIN (d3)
     JOIN (n
     WHERE n.nomenclature_id=cnvtreal(out_rec->qual[d2.seq].detqual[d3.seq].oe_field_value))
    HEAD order_id
     dx_str = " ", cnt = 0
    DETAIL
     IF ((out_rec->qual[d2.seq].detqual[d3.seq].label_text="Diagnosis Code"))
      cnt = (cnt+ 1), dx_str = concat(dx_str,trim(out_rec->qual[d2.seq].detqual[d3.seq].
        oe_field_value,3),"|",trim(n.source_identifier,3),"|",
       trim(out_rec->qual[d2.seq].detqual[d3.seq].oe_field_display_value,3),"|",trim(cnvtstring(cnt)),
       "||")
     ENDIF
    FOOT  order_id
     out_rec->qual[d2.seq].dx_string = dx_str
    WITH nocounter, time = 30
   ;end select
  ENDIF
 ENDIF
 CALL echojson(out_rec, $1)
END GO
