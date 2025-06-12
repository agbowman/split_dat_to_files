CREATE PROGRAM edw_create_augm_care_period:dba
 SELECT INTO value(enc_acp_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(enc_acp->qual[d.seq].encounter_nk)),
   v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].encounter_sk,16))), v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].encntr_slice_sk,16))), v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].encntr_augm_care_period_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].acp_disposal_ref,16))), v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].acp_plan_ref,16))), v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].acp_source_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].acp_medical_service_ref,16))), v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].acp_loc,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_acp->qual[d.seq].src_beg_effective_dt_tm,
      0,cnvtdatetimeutc(enc_acp->qual[d.seq].src_beg_effective_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].src_beg_effective_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].src_beg_effective_tm_vld_flg))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,enc_acp->qual[d.seq].src_end_effective_dt_tm,
      0,cnvtdatetimeutc(enc_acp->qual[d.seq].src_end_effective_dt_tm,3)),utc_timezone_index,
     "MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].src_end_effective_tm_zn))), v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].src_end_effective_tm_vld_flg))), v_bar,
   CALL print(trim(cnvtstring(enc_acp->qual[d.seq].discharge_to_loc_ref,16))),
   v_bar,
   CALL print(build(enc_acp->qual[d.seq].high_depend_care_lvl_days,16)), v_bar,
   CALL print(build(enc_acp->qual[d.seq].intensive_care_lvl_days,16)), v_bar,
   CALL print(build(enc_acp->qual[d.seq].num_organ_sys_support_nbr,16)),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "130074 26-APR-2007 SB013134"
END GO
