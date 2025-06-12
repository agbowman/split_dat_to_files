CREATE PROGRAM bsc_get_audit_info_rr:dba
 SET modify = predeclare
 IF ( NOT (validate(audit_request)))
  RECORD audit_request(
    1 report_name = vc
    1 start_dt_tm = dq8
    1 end_dt_tm = dq8
    1 facility_cd = f8
    1 unit_cnt = i4
    1 unit[*]
      2 nurse_unit_cd = f8
    1 display_ind = i2
  ) WITH persist
 ENDIF
 FREE RECORD audit_reply
 RECORD audit_reply(
   1 summary_qual_cnt = i4
   1 summary_qual[*]
     2 prsnl_id = f8
     2 name_full_formatted = vc
     2 internal_date = i4
     2 date_string = vc
     2 med_admin_event_cnt = i4
     2 positive_pat_cnt = i4
     2 positive_med_cnt = i4
     2 mae_alert_cnt = i4
     2 pat_mismatch_cnt = i4
     2 pat_not_ident_cnt = i4
     2 overdose_cnt = i4
     2 underdose_cnt = i4
     2 inc_drug_form_cnt = i4
     2 inc_form_route_cnt = i4
     2 task_not_found_cnt = i4
     2 med_not_ident_cnt = i4
     2 expired_med_cnt = i4
     2 early_late_cnt = i4
     2 total_not_done_cnt = i4
     2 total_not_given_cnt = i4
     2 interval_warn_cnt = i4
     2 interval_over_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persist
 SET modify = nopredeclare
END GO
