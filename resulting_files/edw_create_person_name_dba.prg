CREATE PROGRAM edw_create_person_name:dba
 CALL echo("this is right before the flat file")
 SELECT INTO value(per_nam_extractfile)
  FROM (dummyt d  WITH seq = size(edw_person_name->qual,5))
  WHERE (edw_person_name->qual[d.seq].person_name_sk > 0)
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_source_id)),
   v_bar,
   CALL print(trim(cnvtstring(edw_person_name->qual[d.seq].person_name_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_person_name->qual[d.seq].person_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_person_name->qual[d.seq].name_type_ref,16))),
   v_bar,
   CALL print(build(edw_person_name->qual[d.seq].src_active_ind)), v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_degree,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_first,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_first_srch,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_full,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_initials,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_last,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_last_srch,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_middle,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_middle_srch,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_original,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_prefix,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_suffix,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].name_title,str_find,str_replace,3))), v_bar,
   CALL print(trim(cnvtstring(edw_person_name->qual[d.seq].name_type_seq,16))),
   v_bar,
   CALL print(trim(replace(edw_person_name->qual[d.seq].source_identifier,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_person_name->qual[d.seq].
      src_beg_effective_dt_tm,0,cnvtdatetimeutc(edw_person_name->qual[d.seq].src_beg_effective_dt_tm,
       3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_person_name->qual[d.seq].src_beg_effective_tm_zn))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_person_name->qual[d.seq].
      src_end_effective_dt_tm,0,cnvtdatetimeutc(edw_person_name->qual[d.seq].src_end_effective_dt_tm,
       3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_person_name->qual[d.seq].src_end_effective_tm_zn))), v_bar,
   extract_dt_tm_fmt,
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 07/16/2012 SM016593"
END GO
