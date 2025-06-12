CREATE PROGRAM edw_create_mammo_assessment:dba
 SELECT INTO value(m_assess_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(mammo_assessment_info->qual[d.seq].mammo_assess_series_sk)),
   v_bar,
   CALL print(trim(cnvtstring(mammo_assessment_info->qual[d.seq].study_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_assessment_info->qual[d.seq].series_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_assessment_info->qual[d.seq].recommend_seq,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_assessment_info->qual[d.seq].recommend_fol_up_field_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_assessment_info->qual[d.seq].assessment_seq,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_assessment_info->qual[d.seq].assessment_fol_up_field_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_assessment_info->qual[d.seq].recall_interval,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_assessment_info->qual[d.seq].follow_up_proc_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,mammo_assessment_info->qual[d.seq].
      assigned_dt_tm,0,cnvtdatetimeutc(mammo_assessment_info->qual[d.seq].assigned_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,mammo_assessment_info->qual[d.seq].
      assigned_dt_tm,0,cnvtdatetimeutc(mammo_assessment_info->qual[d.seq].assigned_dt_tm,2)),cnvtint(
      default_time_zone),"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(default_time_zone,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_assessment_info->qual[d.seq].series_open_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_assessment_info->qual[d.seq].rad_prsnl,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_assessment_info->qual[d.seq].letter_sk,16))), v_bar, "1",
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 CALL echo(build("M_ASSESS Count = ",curqual))
 CALL edwupdatescriptstatus("M_ASSESS",curqual,"0","1")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "001 08/03/15 MF025696"
END GO
