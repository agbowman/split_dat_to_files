CREATE PROGRAM bed_chk_srvres_status:dba
 FREE SET reply
 RECORD reply(
   1 service_resource_code_value = f8
   1 use_flag = i4
   1 found_on_table = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET sr_valid = "F"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=221
    AND (c.code_value=request->service_resource_cd))
  DETAIL
   sr_valid = "T"
  WITH nocounter
 ;end select
 IF (sr_valid="F")
  SET error_flag = "T"
  SET error_msg = concat("Service resource does not exist on code set 221 for code: ",cnvtstring(
    request->service_resource_cd))
 ENDIF
 SET reply->service_resource_code_value = request->service_resource_cd
 SET reply->use_flag = 0
 SET reply->found_on_table = " "
 SET src = request->service_resource_cd
 SET found_sr = "N"
 SELECT INTO "nl:"
  FROM assay_processing_r apr
  PLAN (apr
   WHERE apr.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"assay_processing_r")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM assay_resource_list arl
  PLAN (arl
   WHERE arl.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"assay_resource_list")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM assay_resource_lot art
  PLAN (art
   WHERE art.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"assay_resource_lot")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM ap_prefix ap
  PLAN (ap
   WHERE ap.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"ap_prefix")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM auto_verify av
  PLAN (av
   WHERE av.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"auto_verify")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM av_res_cat arc
  PLAN (arc
   WHERE arc.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"av_res_cat")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM bb_inventory_area bbi
  PLAN (bbi
   WHERE bbi.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"bb_inventory_area")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM bill_only_subsect_reltn bos
  PLAN (bos
   WHERE bos.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"bill_only_subsect_reltn")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM calendar_exception cex
  PLAN (cex
   WHERE cex.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"calendar_exception")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM cyto_alpha_security cas
  PLAN (cas
   WHERE cas.requeue_service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"cyto_alpha_security")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM cyto_screening_security css
  PLAN (css
   WHERE css.over_service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"cyto_screening_security")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM exam_folder ef
  PLAN (ef
   WHERE ef.lib_group_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"exam_folder")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM image_class_type ict
  PLAN (ict
   WHERE ict.lib_group_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"image_class_type")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM im_device id
  PLAN (id
   WHERE id.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"im_device")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM instr_accn_queue iaq
  PLAN (iaq
   WHERE iaq.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"instr_accn_queue")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM interp_data id
  PLAN (id
   WHERE id.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"interp_data")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM interp_task_assay ita
  PLAN (ita
   WHERE ita.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"interp_task_assay")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM item_sr_loc_r isl
  PLAN (isl
   WHERE isl.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"item_sr_loc_r")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mammo_study ms
  PLAN (ms
   WHERE ms.subsection_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mammo_study")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_abn_org_response_code m1
  PLAN (m1
   WHERE m1.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_abn_org_response_cd")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_abn_sus_result m2
  PLAN (m2
   WHERE m2.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_abs_sus_result")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_act_ang_sum_rpt m3
  PLAN (m3
   WHERE m3.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_act_ang_sum_rpt")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_ang_automated m4
  PLAN (m4
   WHERE m4.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_ang_automated")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_ang_times m5
  PLAN (m5
   WHERE m5.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_ang_times")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_event_log m6
  PLAN (m6
   WHERE m6.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_event_log")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_group_response m7
  PLAN (m7
   WHERE m7.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_group_response")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_instr_trans m8
  PLAN (m8
   WHERE m8.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_instr_trans")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_media_default m9
  PLAN (m9
   WHERE m9.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_media_default")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_order_lab m10
  PLAN (m10
   WHERE m10.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_order_lab")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_ref_ang m11
  PLAN (m11
   WHERE m11.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_ref_ang")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_ref_billing_ab m12
  PLAN (m12
   WHERE m12.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_ref_billing_ab")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_ref_billing_sus m13
  PLAN (m13
   WHERE m13.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_ref_billing_sus")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_ref_bio_format m14
  PLAN (m14
   WHERE m14.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_ref_bio_format")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_report_correlation m15
  PLAN (m15
   WHERE m15.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_report_correlation")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_rpt_params m16
  PLAN (m16
   WHERE m16.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_rpt_params")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_stain_correlation m17
  PLAN (m17
   WHERE m17.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_stain_correlation")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_task_log m18
  PLAN (m18
   WHERE m18.instr_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_task_log")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_valid_sus_panel m19
  PLAN (m19
   WHERE m19.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_valid_sus_panel")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mic_workcard_correlation m20
  PLAN (m20
   WHERE m20.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"mic_workcard_correlation")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM oen_interface oi
  PLAN (oi
   WHERE oi.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"oen_interface")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM organization_resource org
  PLAN (org
   WHERE org.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"organization_resource")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM processing_task pt
  PLAN (pt
   WHERE pt.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"processing_task")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM profile_resource_list prl
  PLAN (prl
   WHERE prl.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"profile_resource_list")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM pull_list_controls plc
  PLAN (plc
   WHERE plc.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"pull_list_controls")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM qc_alpha_responses qar
  PLAN (qar
   WHERE qar.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"qc_alpha_responses")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM qc_trouble_step qts
  PLAN (qts
   WHERE qts.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"qc_trouble_step")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM rad_def_serv_res r1
  PLAN (r1
   WHERE r1.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"rad_def_serv_res")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM rad_fold_trans_rule r2
  PLAN (r2
   WHERE ((r2.from_lib_cd=src) OR (r2.to_lib_cd=src)) )
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->found_on_table = concat(reply->found_on_table,"rad_fold_trans_rule")
  SET reply->use_flag = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM rad_follow_up_print_ctrl r3
  PLAN (r3
   WHERE ((r3.department_cd=src) OR (((r3.section_cd=src) OR (r3.subsection_cd=src)) )) )
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"rad_follow_up_print_ctrl")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM rad_image_sys_controls r4
  PLAN (r4
   WHERE r4.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"rad_image_sys_controls")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM rad_loan_letter_settings r5
  PLAN (r5
   WHERE r5.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"rad_loan_letter_settings")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM rad_req_controls r6
  PLAN (r6
   WHERE r6.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"rad_req_controls")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM rad_sys_controls r7
  PLAN (r7
   WHERE r7.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"rad_sys_controls")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM rad_tracking_controls r8
  PLAN (r8
   WHERE r8.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"rad_tracking_controls")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM report_task rt
  PLAN (rt
   WHERE rt.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"report_task")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM resource_accession_r rar
  PLAN (rar
   WHERE rar.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"resource_accession_r")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM resource_assay_control rac
  PLAN (rac
   WHERE rac.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"resource_assay_control")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM resource_lot_r rlr
  PLAN (rlr
   WHERE rlr.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"resource_lot_r")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM role r
  PLAN (r
   WHERE r.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"role")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM route_code_resource_list rcr
  PLAN (rcr
   WHERE rcr.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"route_code_resource_list")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM sch_appt sa
  PLAN (sa
   WHERE sa.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"sch_appt")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM sch_resource sr
  PLAN (sr
   WHERE sr.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"sch_resource")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM technique_defaults td
  PLAN (td
   WHERE ((td.department_cd=src) OR (td.exam_room_cd=src)) )
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->found_on_table = concat(reply->found_on_table,"technique_defaults")
  SET reply->use_flag = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM track_pt_library tpl
  PLAN (tpl
   WHERE tpl.service_resource_cd=src)
  DETAIL
   found_sr = "Y"
  WITH nocounter
 ;end select
 IF (found_sr="Y")
  SET reply->use_flag = 1
  SET reply->found_on_table = concat(reply->found_on_table,"track_pt_library")
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_CHK_SRVRES_STATUS  >> ERROR MESSAGE:  ",
   error_msg)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
