CREATE PROGRAM edw_create_bb_person_antibody:dba
 SELECT INTO value(bbpratb_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(bb_person_antibody_info->qual[d.seq].bb_person_antibody_sk,16))),
   v_bar,
   CALL print(build(bb_person_antibody_info->qual[d.seq].encounter_nk)), v_bar,
   CALL print(trim(cnvtstring(bb_person_antibody_info->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(bb_person_antibody_info->qual[d.seq].person_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_person_antibody_info->qual[d.seq].antibody_ref,16))), v_bar,
   CALL print(trim(cnvtstring(bb_person_antibody_info->qual[d.seq].bb_result_nbr,16))), v_bar,
   CALL print(trim(cnvtstring(bb_person_antibody_info->qual[d.seq].contributor_system_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(bb_person_antibody_info->qual[d.seq].gen_lab_result_sk,16))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar,
   CALL print(trim(cnvtstring(bb_person_antibody_info->qual[d.seq].active_ind,16))), v_bar,
   row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 35000, maxrow = 1,
   append
 ;end select
 CALL echo(build("BBPRATB Count = ",curqual))
 CALL edwupdatescriptstatus("BBPRATB",curqual,"0","0")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 316771 01/25/2012 SM016593"
END GO
