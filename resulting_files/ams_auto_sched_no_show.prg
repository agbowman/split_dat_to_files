CREATE PROGRAM ams_auto_sched_no_show
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET exe_error = 10
 SET failed = false
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD temp_request
 RECORD temp_request(
   1 call_echo_ind = i2
   1 action_dt_tm = dq8
   1 conversation_id = f8
   1 skip_post_event_ind = i2
   1 product_cd = f8
   1 product_meaning = c12
   1 comment_partial_ind = i2
   1 comment_qual_cnt = i4
   1 comment_qual[*]
     2 action = i2
     2 text_type_cd = f8
     2 text_type_meaning = c12
     2 sub_text_cd = f8
     2 sub_text_meaning = c12
     2 text_action = i2
     2 text = vc
     2 text_id = f8
     2 text_updt_cnt = i4
     2 text_active_ind = i2
     2 text_active_status_cd = f8
     2 text_force_updt_ind = i2
     2 updt_cnt = i4
     2 version_ind = i2
     2 force_updt_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 candidate_id = f8
   1 summary_partial_ind = i2
   1 summary_qual_cnt = i4
   1 summary_qual[*]
     2 action = i2
     2 sch_notify_id = f8
     2 base_route_id = f8
     2 sch_report_id = f8
     2 output_dest_id = f8
     2 to_prsnl_id = f8
     2 suffix = vc
     2 email = vc
     2 transmit_dt_tm = dq8
     2 nbr_copies = i4
     2 source_type_cd = f8
     2 source_type_meaning = c12
     2 report_type_cd = f8
     2 report_type_meaning = c12
     2 requested_dt_tm = dq8
     2 printed_dt_tm = dq8
     2 updt_cnt = i4
     2 version_ind = i2
     2 force_updt_ind = i2
     2 candidate_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
   1 itinerary_partial_ind = i2
   1 itinerary_qual_cnt = i4
   1 itinerary_qual[*]
     2 action = i2
     2 sch_notify_id = f8
     2 base_route_id = f8
     2 sch_report_id = f8
     2 output_dest_id = f8
     2 to_prsnl_id = f8
     2 suffix = vc
     2 email = vc
     2 transmit_dt_tm = dq8
     2 nbr_copies = i4
     2 source_type_cd = f8
     2 source_type_meaning = c12
     2 report_type_cd = f8
     2 report_type_meaning = c12
     2 report_table = vc
     2 report_id = f8
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 requested_dt_tm = dq8
     2 printed_dt_tm = dq8
     2 updt_cnt = i4
     2 version_ind = i2
     2 force_updt_ind = i2
     2 candidate_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
   1 allow_partial_ind = i2
   1 qual[*]
     2 sch_event_id = f8
     2 skip_tofollow_ind = i2
     2 schedule_seq = i4
     2 schedule_id = f8
     2 request_action_id = f8
     2 sch_action_cd = f8
     2 action_meaning = c12
     2 sch_reason_cd = f8
     2 reason_meaning = c12
     2 sch_state_cd = f8
     2 state_meaning = c12
     2 sch_action_id = f8
     2 lock_flag = i2
     2 unlock_action_id = f8
     2 sch_lock_id = f8
     2 appt_scheme_id = f8
     2 perform_dt_tm = dq8
     2 verify_flag = i2
     2 ver_interchange_id = f8
     2 ver_status_cd = f8
     2 ver_status_meaning = c12
     2 verify_action_id = f8
     2 abn_flag = i2
     2 retain_review_ind = i2
     2 abn_conv_id = f8
     2 abn_action_id = f8
     2 move_appt_ind = i2
     2 move_appt_dt_tm = dq8
     2 tci_dt_tm = dq8
     2 version_dt_tm = dq8
     2 updt_cnt = i4
     2 version_ind = i2
     2 force_updt_ind = i2
     2 candidate_id = f8
     2 cancel_order_flag = i2
     2 comment_partial_ind = i2
     2 comment_qual_cnt = i4
     2 comment_qual[*]
       3 action = i2
       3 sch_action_id = f8
       3 text_type_cd = f8
       3 text_type_meaning = c12
       3 sub_text_cd = f8
       3 sub_text_meaning = c12
       3 text_action = i2
       3 text = vc
       3 text_id = f8
       3 text_updt_cnt = i4
       3 text_active_ind = i2
       3 text_active_status_cd = f8
       3 text_force_updt_ind = i2
       3 updt_cnt = i4
       3 version_ind = i2
       3 force_updt_ind = i2
       3 active_ind = i2
       3 active_status_cd = f8
       3 candidate_id = f8
     2 detail_partial_ind = i2
     2 detail_qual_cnt = i4
     2 detail_qual[*]
       3 action = i2
       3 sch_action_id = f8
       3 oe_field_id = f8
       3 oe_field_value = f8
       3 oe_field_display_value = vc
       3 oe_field_dt_tm_value = dq8
       3 oe_field_meaning = c25
       3 oe_field_meaning_id = f8
       3 value_required_ind = i2
       3 group_seq = i4
       3 field_seq = i4
       3 modified_ind = i2
       3 updt_cnt = i4
       3 version_ind = i2
       3 force_updt_ind = i2
       3 candidate_id = f8
       3 active_ind = i2
       3 active_status_cd = f8
     2 attach_partial_ind = i2
     2 attach_qual_cnt = i4
     2 attach_qual[*]
       3 action = i2
       3 order_seq_nbr = i4
       3 concurrent_ind = i2
       3 primary_ind = i2
       3 sch_attach_id = f8
       3 attach_type_cd = f8
       3 attach_type_meaning = c12
       3 order_status_cd = f8
       3 order_status_meaning = c12
       3 seq_nbr = i4
       3 sch_state_cd = f8
       3 state_meaning = c12
       3 order_id = f8
       3 beg_schedule_seq = i4
       3 end_schedule_seq = i4
       3 event_dt_tm = dq8
       3 order_dt_tm = dq8
       3 updt_cnt = i4
       3 version_ind = i2
       3 force_updt_ind = i2
       3 candidate_id = f8
       3 active_ind = i2
       3 active_status_cd = f8
       3 synonym_id = f8
       3 description = vc
       3 attach_source_flag = i2
     2 option_pass_ind = i2
     2 option_qual_cnt = i4
     2 option_qual[*]
       3 sch_option_cd = f8
       3 option_meaning = c12
     2 notification_pass_ind = i2
     2 notification_partial_ind = i2
     2 notification_qual_cnt = i4
     2 notification_qual[*]
       3 action = i2
       3 sch_action_id = f8
       3 sch_notify_id = f8
       3 base_route_id = f8
       3 sch_report_id = f8
       3 output_dest_id = f8
       3 to_prsnl_id = f8
       3 suffix = vc
       3 email = vc
       3 transmit_dt_tm = dq8
       3 nbr_copies = i4
       3 source_type_cd = f8
       3 source_type_meaning = c12
       3 report_type_cd = f8
       3 report_type_meaning = c12
       3 requested_dt_tm = dq8
       3 printed_dt_tm = dq8
       3 updt_cnt = i4
       3 version_ind = i2
       3 force_updt_ind = i2
       3 candidate_id = f8
       3 active_ind = i2
       3 active_status_cd = f8
     2 schedule_partial_ind = i2
     2 schedule_qual_cnt = i4
     2 schedule_qual[*]
       3 schedule_id = f8
       3 unconfirm_count = i4
       3 appt_partial_ind = i2
       3 appt_qual_cnt = i4
       3 appt_qual[*]
         4 sch_appt_id = f8
         4 sch_state_cd = f8
         4 state_meaning = c12
     2 warning_partial_ind = i2
     2 warning_qual_cnt = i4
     2 warning_qual[*]
       3 action = i2
       3 sch_warn_id = f8
       3 warn_type_cd = f8
       3 warn_type_meaning = c12
       3 warn_batch_cd = f8
       3 warn_batch_meaning = c12
       3 warn_level_cd = f8
       3 warn_level_meaning = c12
       3 warn_class_cd = f8
       3 warn_class_meaning = c12
       3 warn_reason_cd = f8
       3 warn_reason_meaning = c12
       3 warn_state_cd = f8
       3 warn_state_meaning = c12
       3 warn_option_cd = f8
       3 warn_option_meaning = c12
       3 bit_mask = i4
       3 sch_appt_id = f8
       3 sch_appt_index = i4
       3 sch_action_id = f8
       3 sch_action_index = i4
       3 warn_prsnl_id = f8
       3 warn_dt_tm = dq8
       3 updt_cnt = i4
       3 version_ind = i2
       3 force_updt_ind = i2
       3 candidate_id = f8
       3 active_ind = i2
       3 active_status_cd = f8
       3 option_partial_ind = i2
       3 option_qual_cnt = i4
       3 option_qual[*]
         4 action = i2
         4 sch_option_id = f8
         4 warn_reason_cd = f8
         4 warn_reason_meaning = c12
         4 warn_option_cd = f8
         4 warn_option_meaning = c12
         4 warn_level_cd = f8
         4 warn_level_meaning = c12
         4 warn_class_cd = f8
         4 warn_class_meaning = c12
         4 warn_prsnl_id = f8
         4 warn_dt_tm = dq8
         4 updt_cnt = i4
         4 version_ind = i2
         4 force_updt_ind = i2
         4 candidate_id = f8
         4 active_ind = i2
         4 active_status_cd = f8
         4 comment_partial_ind = i2
         4 comment_qual_cnt = i4
         4 comment_qual[*]
           5 action = i2
           5 text_type_cd = f8
           5 text_type_meaning = c12
           5 sub_text_cd = f8
           5 sub_text_meaning = c12
           5 text_action = i2
           5 text = vc
           5 text_id = f8
           5 text_updt_cnt = i4
           5 text_active_ind = i2
           5 text_active_status_cd = f8
           5 text_force_updt_ind = i2
           5 updt_cnt = i4
           5 version_ind = i2
           5 force_updt_ind = i2
           5 candidate_id = f8
           5 active_ind = i2
           5 active_status_cd = f8
     2 requests_pass_ind = i2
     2 requests_qual_cnt = i4
     2 requests_qual[*]
       3 request_action_id = f8
       3 sch_action_cd = f8
       3 action_meaning = c12
     2 move_criteria_partial_ind = i2
     2 move_criteria_qual_cnt = i4
     2 move_criteria_qual[*]
       3 action = i2
       3 move_flag = i2
       3 move_pref_beg_tm = i4
       3 move_pref_end_tm = i4
       3 move_requestor = c255
       3 updt_cnt = i4
       3 version_ind = i2
       3 force_updt_ind = i2
       3 candidate_id = f8
       3 active_ind = i2
       3 active_status_cd = f8
       3 comment_partial_ind = i2
       3 comment_qual_cnt = i4
       3 comment_qual[*]
         4 action = i2
         4 text_type_cd = f8
         4 text_type_meaning = c12
         4 sub_text_cd = f8
         4 sub_text_meaning = c12
         4 text_action = i2
         4 text = vc
         4 text_id = f8
         4 text_updt_cnt = i4
         4 text_active_ind = i2
         4 text_active_status_cd = f8
         4 text_force_updt_ind = i2
         4 updt_cnt = i4
         4 version_ind = i2
         4 force_updt_ind = i2
         4 candidate_id = f8
         4 active_ind = i2
         4 active_status_cd = f8
     2 link_partial_ind = i2
     2 link_qual_cnt = i4
     2 link_qual[*]
       3 action = i2
       3 sch_link_id = f8
       3 sch_event_id = f8
       3 force_updt_ind = i2
       3 active_ind = i2
       3 updt_cnt = i4
       3 auto_generated_ind = i2
     2 grpsession_cancel_ind = i2
     2 grp_desc = vc
     2 grp_capacity = i4
     2 grp_flag = i2
     2 grpsession_id = f8
     2 grp_shared_ind = i2
     2 grp_closed_ind = i2
     2 grp_beg_dt_tm = dq8
     2 grp_end_dt_tm = dq8
     2 hcv_flag = i2
     2 hcv_interchange_id = f8
     2 hcv_ver_status_meaning = c12
     2 hcv_ver_status_cd = f8
     2 hcv_action_id = f8
     2 cab_flag = i2
     2 orig_action_prsnl_id = f8
     2 abn_total_price = f8
     2 abn_total_price_format = vc
   1 displacement_ind = i2
   1 program_name = vc
   1 pm_output_dest_cd = f8
   1 deceased_skip_notify_ind = i2
 )
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 sch_event_id = f8
     2 schedule_seq = i4
     2 schedule_id = f8
     2 sch_action_cd = f8
     2 action_meaning = vc
     2 sch_state_cd = f8
     2 state_meaning = vc
     2 appt_scheme_id = f8
 )
 DECLARE sch_action_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",14232,"NOSHOW"))
 DECLARE sch_state_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",14233,"NOSHOW"))
 DECLARE confirmed_state_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",14233,"CONFIRMED"
   ))
 DECLARE cntx = i4 WITH protect
 DECLARE display_scheme = f8 WITH protect
 SELECT INTO "nl:"
  FROM sch_disp_scheme s
  WHERE s.mnemonic_key="NO SHOW"
   AND s.active_ind=1
   AND s.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  DETAIL
   display_scheme = s.disp_scheme_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM sch_appt sa,
   sch_event se
  PLAN (sa
   WHERE sa.beg_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),235959)
    AND sa.beg_dt_tm < cnvtdatetime(curdate,curtime3)
    AND sa.sch_state_cd=confirmed_state_cd
    AND sa.state_meaning="CONFIRMED"
    AND sa.grpsession_id=0.0
    AND  NOT (sa.appt_location_cd IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="ANCILSURG"
     AND cv.active_ind=1
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))))
    AND sa.active_ind=1
    AND sa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (se
   WHERE sa.sch_event_id=se.sch_event_id
    AND  NOT (se.appt_type_cd IN (
   (SELECT
    cv1.code_value
    FROM code_value cv1
    WHERE cv1.code_set=14230
     AND ((cnvtupper(cv1.display)="*VACATION*") OR (cnvtupper(cv1.display)="*BLOCK*"))
     AND cv1.active_ind=1
     AND cv1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    ORDER BY cv1.code_value)))
    AND se.active_ind=1)
  ORDER BY sa.sch_event_id
  HEAD REPORT
   cnt = 0, stat = alterlist(temp->qual,100)
  HEAD sa.sch_event_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt > 100)
    stat = alterlist(temp->qual,(cnt+ 9))
   ENDIF
   temp->qual[cnt].sch_event_id = sa.sch_event_id, temp->qual[cnt].schedule_seq = sa.schedule_seq,
   temp->qual[cnt].schedule_id = sa.schedule_id,
   temp->qual[cnt].appt_scheme_id = display_scheme, temp->qual[cnt].sch_action_cd = sch_action_cd,
   temp->qual[cnt].action_meaning = "NOSHOW",
   temp->qual[cnt].sch_state_cd = sch_state_cd, temp->qual[cnt].state_meaning = "NOSHOW"
  FOOT REPORT
   stat = alterlist(temp->qual,cnt)
  WITH nocounter
 ;end select
 SET recur_cnt = cnvtint(value(size(temp->qual,5)))
 FOR (i = 1 TO recur_cnt BY 1)
   SET cntx = (cntx+ 1)
   SET stat = alterlist(temp_request->qual,cntx)
   SET temp_request->qual[cntx].sch_event_id = temp->qual[i].sch_event_id
   SET temp_request->qual[cntx].schedule_seq = temp->qual[i].schedule_seq
   SET temp_request->qual[cntx].schedule_id = temp->qual[i].schedule_id
   SET temp_request->qual[cntx].sch_action_cd = temp->qual[i].sch_action_cd
   SET temp_request->qual[cntx].action_meaning = temp->qual[i].action_meaning
   SET temp_request->qual[cntx].sch_reason_cd = 0
   SET temp_request->qual[cntx].reason_meaning = ""
   SET temp_request->qual[cntx].sch_state_cd = temp->qual[i].sch_state_cd
   SET temp_request->qual[cntx].state_meaning = temp->qual[i].state_meaning
   SET temp_request->qual[cntx].sch_action_id = 0
   SET temp_request->qual[cntx].appt_scheme_id = temp->qual[i].appt_scheme_id
   SET temp_request->qual[cntx].perform_dt_tm = cnvtdatetime(curdate,curtime3)
   SET temp_request->qual[cntx].move_appt_ind = 0
   SET temp_request->qual[cntx].move_appt_dt_tm = cnvtdatetime(curdate,curtime3)
   SET temp_request->qual[cntx].version_dt_tm = cnvtdatetime(curdate,curtime3)
   SET temp_request->qual[cntx].updt_cnt = 0
   SET temp_request->qual[cntx].version_ind = 0
   SET temp_request->qual[cntx].force_updt_ind = 1
 ENDFOR
 IF (cntx > 0)
  EXECUTE sch_chgw_event_state  WITH replace(request,temp_request)
 ENDIF
 CALL updtdminfo(trim(cnvtupper(curprog),3))
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 SET last_mod = "001 02/10/2014 Exclude GROUP,BLOCK,SURGERY & VACATION Appointments"
END GO
