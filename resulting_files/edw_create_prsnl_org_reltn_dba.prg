CREATE PROGRAM edw_create_prsnl_org_reltn:dba
 SELECT INTO value(prsl_org_extractfile)
  FROM (dummyt d  WITH seq = size(edw_por->qual,5))
  WHERE (edw_por->qual[d.seq].prsnl_org_reltn_sk > 0)
  DETAIL
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_source_id)),
   v_bar,
   CALL print(trim(cnvtstring(edw_por->qual[d.seq].prsnl_org_reltn_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_por->qual[d.seq].src_beg_effective_dt_tm,
      0,cnvtdatetimeutc(edw_por->qual[d.seq].src_beg_effective_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_por->qual[d.seq].src_beg_effective_tm_zn))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_por->qual[d.seq].src_end_effective_dt_tm,
      0,cnvtdatetimeutc(edw_por->qual[d.seq].src_end_effective_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_por->qual[d.seq].src_end_effective_tm_zn))), v_bar,
   CALL print(trim(edw_por->qual[d.seq].src_active_ind,3)),
   v_bar,
   CALL print(trim(cnvtstring(edw_por->qual[d.seq].confidence_level_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_por->qual[d.seq].organization_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_por->qual[d.seq].personnel_sk,16))),
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "000 08/15/2007 sl015239 138040"
END GO
