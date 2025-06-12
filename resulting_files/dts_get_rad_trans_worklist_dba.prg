CREATE PROGRAM dts_get_rad_trans_worklist:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[10]
      2 order_id = f8
      2 accession = c20
      2 accession_id = f8
      2 catalog_cd = f8
      2 catalog_syn = vc
      2 person_id = f8
      2 person_name = vc
      2 encntr_id = f8
      2 encntr_type_cd = f8
      2 encntr_type_disp = c40
      2 encntr_type_desc = c60
      2 encntr_type_mean = c12
      2 med_rec_num = vc
      2 fin_num = vc
      2 loc_nurse_unit_cd = f8
      2 loc_nurse_unit_disp = vc
      2 comments = vc
      2 report_status_cd = f8
      2 report_status_disp = c40
      2 report_status_desc = c60
      2 report_status_mean = c12
      2 exam_status_cd = f8
      2 exam_status_disp = c40
      2 exam_status_desc = c60
      2 exam_status_mean = c12
      2 packet_routing_cd = f8
      2 packet_routing_disp = c40
      2 packet_routing_desc = c60
      2 packet_routing_mean = c12
      2 ord_loc_cd = f8
      2 ord_loc_disp = c40
      2 ord_loc_desc = c60
      2 ord_loc_mean = c12
      2 refer_loc_cd = f8
      2 refer_loc_disp = c40
      2 refer_loc_desc = c60
      2 refer_loc_mean = c12
      2 cancel_dt_tm = dq8
      2 cancel_tz = i4
      2 cancel_by_id = f8
      2 request_dt_tm = dq8
      2 requested_tz = i4
      2 seq_exam_id = f8
      2 removed_dt_tm = dq8
      2 removed_by_id = f8
      2 removed_cd = f8
      2 removed_disp = c40
      2 removed_desc = c60
      2 removed_mean = c12
      2 pull_list_id = f8
      2 start_dt_tm = dq8
      2 start_tz = i4
      2 complete_dt_tm = dq8
      2 complete_tz = i4
      2 reason_for_exam = vc
      2 order_physician_id = f8
      2 removed_mean = c12
      2 priority_cd = f8
      2 priority_disp = c40
      2 priority_desc = c60
      2 priority_mean = c12
      2 trans_workgroup_cd = f8
      2 parent_order_id = f8
      2 group_reference_nbr = c40
      2 group_event_id = f8
      2 updt_cnt = i4
      2 report_id = f8
      2 orig_trans_dt_tm = dq8
      2 original_trans_tz = i4
      2 dict_dt_tm = dq8
      2 dictated_tz = i4
      2 final_dt_tm = dq8
      2 final_tz = i4
      2 trans_prsnl[*]
        3 rad_report_id = f8
        3 report_prsnl_id = f8
        3 report_prsnl_name = vc
        3 prsnl_relation_flag = i2
        3 proxied_for_id = f8
        3 queue_ind = i2
    1 qual_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET count1 = 0
 DECLARE primary_synonym_cd = f8
 DECLARE subsect_type_cd = f8
 DECLARE sect_type_cd = f8
 DECLARE dept_type_cd = f8
 DECLARE action_type_cd = f8
 DECLARE code_value = f8
 DECLARE reject_stat_cd = f8
 DECLARE new_stat_cd = f8
 DECLARE hold_stat_cd = f8
 DECLARE dictated_stat_cd = f8
 SET primary_synonym_cd = 0.0
 SET subsect_type_cd = 0.0
 SET sect_type_cd = 0.0
 SET dept_type_cd = 0.0
 SET action_type_cd = 0.0
 SET code_value = 0.0
 SET reject_stat_cd = 0.0
 SET new_stat_cd = 0.0
 SET hold_stat_cd = 0.0
 DECLARE fin_alias_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mrn_alias_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN"))
 SET dictated_stat_cd = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 6011
 SET cdf_meaning = "PRIMARY"
 EXECUTE cpm_get_cd_for_cdf
 SET primary_synonym_cd = code_value
 SET code_set = 14202
 SET cdf_meaning = "HOLD"
 EXECUTE cpm_get_cd_for_cdf
 SET hold_stat_cd = code_value
 SET code_set = 14202
 SET cdf_meaning = "DICTATED"
 EXECUTE cpm_get_cd_for_cdf
 SET dictated_stat_cd = code_value
 SET code_set = 14202
 SET cdf_meaning = "REJECT"
 EXECUTE cpm_get_cd_for_cdf
 SET reject_stat_cd = code_value
 SET code_set = 14202
 SET cdf_meaning = "NEW"
 EXECUTE cpm_get_cd_for_cdf
 SET new_stat_cd = code_value
 SET code_set = 223
 SET cdf_meaning = "SUBSECTION"
 EXECUTE cpm_get_cd_for_cdf
 SET subsect_type_cd = code_value
 DECLARE event_id = f8
 SET event_id = 0
 SET code_set = 223
 SET cdf_meaning = "SECTION"
 EXECUTE cpm_get_cd_for_cdf
 SET sect_type_cd = code_value
 SET code_set = 223
 SET cdf_meaning = "DEPARTMENT"
 EXECUTE cpm_get_cd_for_cdf
 SET dept_type_cd = code_value
 EXECUTE dts_get_rad_trans_worklist2 parser(
  IF ((request->dept_cd > 0.0)) "rg2.parent_service_resource_cd = request->dept_cd"
  ELSE "0 = 0"
  ENDIF
  ), parser(
  IF ((request->section_cd > 0.0)) "rg1.parent_service_resource_cd = request->section_cd"
  ELSE "0 = 0"
  ENDIF
  ), parser(
  IF ((request->subsection_cd > 0.0)) "rg4.parent_service_resource_cd = request->subsection_cd"
  ELSE "0 = 0"
  ENDIF
  )
END GO
