CREATE PROGRAM edw_create_benefit_alloc:dba
 SELECT INTO value(benefit_alloc_extractfile)
  FROM (dummyt d  WITH seq = size(benefit_alloc_keys->qual,5))
  WHERE (benefit_alloc_keys->qual[d.seq].encounter_sk > 0)
  DETAIL
   col 0, health_system_id, v_bar,
   health_system_source_id, v_bar,
   CALL print(trim(replace(benefit_alloc->qual[d.seq].encounter_nk,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(benefit_alloc->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(benefit_alloc->qual[d.seq].encntr_slice_sk,16))), v_bar,
   CALL print(trim(cnvtstring(benefit_alloc->qual[d.seq].benefit_alloc_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(benefit_alloc->qual[d.seq].benefit_sk,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,benefit_alloc->qual[d.seq].finalized_dt_tm,0,
      cnvtdatetimeutc(benefit_alloc->qual[d.seq].finalized_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm:ss"))), v_bar,
   CALL print(trim(cnvtstring(benefit_alloc->qual[d.seq].finalized_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(benefit_alloc->qual[d.seq].finalized_dt_tm,cnvtint(
      benefit_alloc->qual[d.seq].finalized_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(benefit_alloc->qual[d.seq].health_plan_sk,16))), v_bar,
   CALL print(trim(cnvtstring(benefit_alloc->qual[d.seq].made_by_prsnl,16))),
   v_bar,
   CALL print(trim(cnvtstring(benefit_alloc->qual[d.seq].nca_ind,16))), v_bar,
   CALL print(trim(cnvtstring(benefit_alloc->qual[d.seq].benefit_org,16))), v_bar,
   CALL print(trim(cnvtstring(benefit_alloc->qual[d.seq].active_ind,16))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "002 05/14/2020 BS074648"
END GO
