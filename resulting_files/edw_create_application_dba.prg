CREATE PROGRAM edw_create_application:dba
 SELECT INTO value(app_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_application->qual[d.seq].application_inst_sk,16))), v_bar,
   CALL print(trim(replace(edw_application->qual[d.seq].application_owner,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(edw_application->qual[d.seq].application_desc,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(edw_application->qual[d.seq].application_ft_desc,str_find,str_replace,3),3
    )), v_bar,
   CALL print(trim(replace(edw_application->qual[d.seq].application_name,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_application->qual[d.seq].common_application_ind,16))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "001 01/23/18 mf025696"
END GO
