CREATE PROGRAM aps_orders_init:dba
 CALL echo("Creating persistent record structure to hold order information.")
 SET trace = recpersist
 RECORD cd(
   1 order_action_type_cd = f8
   1 modify_action_type_cd = f8
   1 complete_action_type_cd = f8
   1 cancel_action_type_cd = f8
   1 activate_action_type_cd = f8
   1 renew_action_type_cd = f8
   1 resume_action_type_cd = f8
   1 stud_act_action_type_cd = f8
   1 dept_status_cd = f8
   1 specimen_type_cd = f8
   1 specimen_type_disp = c40
   1 dos_collection_cd = f8
   1 dos_received_cd = f8
   1 dos_taskorder_cd = f8
   1 dos_current_cd = f8
   1 order_canceled_cd = f8
   1 order_completed_cd = f8
   1 cancelled_status_cd = f8
   1 ap_reporting_cd = f8
   1 current_name_type_cd = f8
   1 record_status_cd = f8
   1 entry_method_cd = f8
   1 note_format_cd = f8
   1 note_type_cd = f8
   1 trans_action_type_cd = f8
   1 dict_action_type_cd = f8
   1 veri_action_type_cd = f8
   1 mod_result_status_cd = f8
   1 auth_result_status_cd = f8
   1 complete_action_status_cd = f8
   1 verify_status_cd = f8
   1 correct_status_cd = f8
   1 taskcnt = i4
 )
 RECORD ot(
   1 quick_verify = i2
   1 specimen_order = i2
   1 report_order = i2
   1 task_order = i2
   1 specimen_update = i2
   1 report_update = i2
   1 task_update = i2
 )
 RECORD orders(
   1 ops_parent_id = f8
   1 type_ind = i2
   1 case_id = f8
   1 last_case_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 accession_nbr = vc
   1 requesting_physician_id = f8
   1 requesting_prsnl_id = f8
   1 responsible_pathologist_id = f8
   1 case_received_dt_tm = dq8
   1 case_collect_dt_tm = dq8
   1 specimen_catalog_cd = f8
   1 qual_cnt = i4
   1 time_zone = i4
   1 qual[*]
     2 data
       3 type_ind = i2
       3 id = f8
       3 in_process_ind = i2
       3 failed_ind = i2
       3 catalog_cd = f8
       3 order_id = f8
       3 dept_status_cd = f8
       3 updt_cnt = i4
       3 action_type_cd = f8
       3 service_resource_cd = f8
       3 priority_cd = f8
       3 priority_disp = c40
       3 received_dt_tm = dq8
       3 collect_dt_tm = dq8
       3 request_dt_tm = dq8
       3 description = vc
       3 no_charge_ind = i2
       3 research_account_id = f8
       3 research_account_name = vc
       3 specimen_received_id = f8
       3 specimen_received_name = vc
       3 cancel_cd = f8
       3 cancel_disp = vc
       3 charge_verifying_id = f8
       3 charge_dos_cd = f8
       3 order_status_cd = f8
       3 case_id = f8
   1 trigger_app = i4
 )
 SET trace = norecpersist
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=6003
   AND cv.cdf_meaning IN ("ORDER", "CANCEL", "MODIFY", "COMPLETE", "ACTIVATE",
  "RENEW", "RESUME", "STUDACTIVATE")
   AND cv.active_ind=1
  HEAD REPORT
   cd->order_action_type_cd = 0.0, cd->modify_action_type_cd = 0.0, cd->cancel_action_type_cd = 0.0,
   cd->complete_action_type_cd = 0.0, cd->activate_action_type_cd = 0.0, cd->renew_action_type_cd =
   0.0,
   cd->resume_action_type_cd = 0.0, cd->stud_act_action_type_cd = 0.0
  DETAIL
   CASE (cv.cdf_meaning)
    OF "ORDER":
     cd->order_action_type_cd = cv.code_value
    OF "MODIFY":
     cd->modify_action_type_cd = cv.code_value
    OF "CANCEL":
     cd->cancel_action_type_cd = cv.code_value
    OF "COMPLETE":
     cd->complete_action_type_cd = cv.code_value
    OF "ACTIVATE":
     cd->activate_action_type_cd = cv.code_value
    OF "RENEW":
     cd->renew_action_type_cd = cv.code_value
    OF "RESUME":
     cd->resume_action_type_cd = cv.code_value
    OF "STUDACTIVATE":
     cd->stud_act_action_type_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET ot->quick_verify = 1
 SET ot->specimen_order = 2
 SET ot->report_order = 3
 SET ot->task_order = 4
 SET ot->specimen_update = 5
 SET ot->report_update = 6
 SET ot->task_update = 7
END GO
