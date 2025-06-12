CREATE PROGRAM edw_create_encntr_person_reltn:dba
 SELECT INTO value(encpsrel_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].encntr_person_reltn_sk,16))),
   v_bar,
   CALL print(build(encntr_person_reltn_info->qual[d.seq].encounter_nk)), v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].related_person_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].related_person_reltn_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].person_reltn_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].person_reltn_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].contributor_system_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].contact_role_ref,16))), v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].genetic_reltn_ind,16))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].living_with_ind,16))), v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].visitation_allowed_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].priority_seq,16))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].free_text_ref,16))), v_bar,
   CALL print(trim(replace(encntr_person_reltn_info->qual[d.seq].rel_person_name_ft,str_find,
     str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].internal_seq,16))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].family_reltn_sub_type_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].default_reltn_ind,16))), v_bar,
   CALL print(trim(replace(encntr_person_reltn_info->qual[d.seq].source_identifier,str_find,
     str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].copy_correspondence_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].relation_seq,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,encntr_person_reltn_info->qual[d.seq].
      src_beg_effective_dt_tm,0,cnvtdatetimeutc(encntr_person_reltn_info->qual[d.seq].
       src_beg_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].src_beg_effective_tm_zn,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(encntr_person_reltn_info->qual[d.seq].
     src_beg_effective_dt_tm,cnvtint(encntr_person_reltn_info->qual[d.seq].src_beg_effective_tm_zn),
     "MMddyyyyHHmmsscc"),"0000000000000000","0","                ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,encntr_person_reltn_info->qual[d.seq].
      src_end_effective_dt_tm,0,cnvtdatetimeutc(encntr_person_reltn_info->qual[d.seq].
       src_end_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].src_beg_effective_tm_zn,16))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(encntr_person_reltn_info->qual[d.seq].
     src_end_effective_dt_tm,cnvtint(encntr_person_reltn_info->qual[d.seq].src_end_effective_tm_zn),
     "MMddyyyyHHmmsscc"),"0000000000000000","0","        	","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(encntr_person_reltn_info->qual[d.seq].active_ind,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 CALL echo(build("ENCPSREL Count = ",curqual))
 CALL edwupdatescriptstatus("ENCPSREL",curqual,"0","0")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 08/24/2012 SM016593"
END GO
