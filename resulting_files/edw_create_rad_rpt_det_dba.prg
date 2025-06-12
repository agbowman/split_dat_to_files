CREATE PROGRAM edw_create_rad_rpt_det:dba
 SELECT INTO value(rdrptdtl_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(concat(trim(cnvtstring(edw_rad_detail->qual[d.seq].rad_report_id,16)),"~",trim(
     cnvtstring(edw_rad_detail->qual[d.seq].task_assay_cd,16)),"~",trim(cnvtstring(edw_rad_detail->
      qual[d.seq].section_sequence,16)))),
   v_bar,
   CALL print(trim(cnvtstring(edw_rad_detail->qual[d.seq].rad_report_id,16))), v_bar,
   CALL print(trim(cnvtstring(edw_rad_detail->qual[d.seq].detail_event_id,16))), v_bar,
   CALL print(trim(cnvtstring(edw_rad_detail->qual[d.seq].task_assay_cd,16))),
   v_bar,
   CALL print(trim(replace(edw_rad_detail->qual[d.seq].event_title_text,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_rad_detail->qual[d.seq].section_sequence,16))), v_bar,
   CALL print(trim(edw_rad_detail->qual[d.seq].acr_code_ind)),
   v_bar,
   CALL print(trim(edw_rad_detail->qual[d.seq].required_ind)), v_bar,
   CALL print(trim(replace(edw_rad_detail->qual[d.seq].detail_reference_nbr,str_find,str_replace,3),3
    )), v_bar,
   CALL print(trim(cnvtstring(edw_rad_detail->qual[d.seq].template_id,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, "1",
   v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 35000, maxrow = 1,
   append
 ;end select
 CALL echo(build("RDRPTDTL Count = ",curqual))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "002 12/01/20  BS074648"
END GO
