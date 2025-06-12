CREATE PROGRAM edw_create_mammo_breast_find:dba
 SELECT INTO value(m_brfind_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(replace(mammo_breast_info->qual[d.seq].mammo_breast_find_sk,str_find,str_replace,3
     ))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].mammo_study_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].breast_find_id,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].find_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].find_detail_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].side_field_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].breast_comp_field_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].find_seq,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].lesion_class_field_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].path_field_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].scd_term_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].field_foll_up_sk,16))), v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].numeric_val,16))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,mammo_breast_info->qual[d.seq].value_dt_tm,0,
      cnvtdatetimeutc(mammo_breast_info->qual[d.seq].value_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,mammo_breast_info->qual[d.seq].value_dt_tm,0,
      cnvtdatetimeutc(mammo_breast_info->qual[d.seq].value_dt_tm,2)),mammo_breast_info->qual[d.seq].
     value_tm_zn,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].value_tm_zn,16))),
   v_bar,
   CALL print(trim(replace(mammo_breast_info->qual[d.seq].text_val,str_find,str_replace,3))), v_bar
   IF ((mammo_breast_info->qual[d.seq].numeric_val > 0))
    CALL print(trim(cnvtstring(mammo_breast_info->qual[d.seq].numeric_val,16)))
   ELSEIF (trim(mammo_breast_info->qual[d.seq].text_val) != "")
    CALL print(trim(replace(mammo_breast_info->qual[d.seq].text_val,str_find,str_replace,3)))
   ELSE
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,mammo_breast_info->qual[d.seq].value_dt_tm,0,
       cnvtdatetimeutc(mammo_breast_info->qual[d.seq].value_dt_tm,2)),mammo_breast_info->qual[d.seq].
      value_tm_zn,"MM/DD/YYYY HH:mm")))
   ENDIF
   v_bar, "1", v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 CALL echo(build("M_BRFIND Count = ",curqual))
 CALL edwupdatescriptstatus("M_BRFIND",curqual,"1","2")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "001 08/03/15 MF025696"
END GO
