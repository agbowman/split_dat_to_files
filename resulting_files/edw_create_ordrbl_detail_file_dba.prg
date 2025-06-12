CREATE PROGRAM edw_create_ordrbl_detail_file:dba
 DECLARE iorderable_detail_count = i4 WITH protect, constant(size(edw_orderable_detail->qual,5))
 SELECT INTO value(ordbl_det_extractfile)
  FROM (dummyt d  WITH seq = iorderable_detail_count)
  WHERE iorderable_detail_count > 0
  DETAIL
   col 0,
   CALL print(trim(cnvtstring(edw_orderable_detail->qual[d.seq].orderable_detail_sk,16))), v_bar,
   health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(edw_orderable_detail->qual[d.seq].orderable_detail_meaning_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_orderable_detail->qual[d.seq].orderable_type_ref,16))), v_bar,
   CALL print(trim(replace(edw_orderable_detail->qual[d.seq].orderable_detail_desc,str_find,
     str_replace,3))), v_bar,
   CALL print(trim(edw_orderable_detail->qual[d.seq].orderable_detail_type_flg)),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1
 ;end select
 CALL edwaddscriptstatus("ORDBL_DET",iorderable_detail_count,"3","3")
 FREE RECORD edw_orderable_detail
 SET script_version = "003 11/15/06 MG010594"
END GO
