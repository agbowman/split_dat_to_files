CREATE PROGRAM edw_create_mammo_study:dba
 SELECT INTO value(m_study_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].mammo_study_sk,16))),
   v_bar,
   CALL print(build(mammo_study_info->qual[d.seq].enc_nk)), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].order_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].person_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].catalog_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,mammo_study_info->qual[d.seq].study_dt_tm,0,
      cnvtdatetimeutc(mammo_study_info->qual[d.seq].study_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,mammo_study_info->qual[d.seq].study_dt_tm,0,
      cnvtdatetimeutc(mammo_study_info->qual[d.seq].study_dt_tm,2)),cnvtint(default_time_zone),
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].reason_fol_up_field_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].asmnt_fol_up_field_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].recommend_fol_up_field_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].stat_cat_fol_up_field_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].recall_interval,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].subsection_ref,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].contributor_system_ref,16))), v_bar,
   CALL print(trim(replace(mammo_study_info->qual[d.seq].group_reference_nbr,str_find,str_replace,3))
   ),
   v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].edition_nbr,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].letter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].download_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].no_fol_up_req_ind,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].study_tz,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].exclude_from_audit_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].seq_exam_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].radiologist_prsnl_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].order_doc_prsnl_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].technologist_prsnl_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].active_ind,16))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(mammo_study_info->qual[d.seq].stat_cat_flag,16))), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "001 08/03/15 MF025696"
END GO
