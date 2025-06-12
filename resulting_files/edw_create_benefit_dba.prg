CREATE PROGRAM edw_create_benefit:dba
 SELECT INTO value(benefit_extractfile)
  FROM (dummyt d  WITH seq = size(benefit->qual,5))
  WHERE (benefit_keys->qual[d.seq].benefit_sk > 0)
  DETAIL
   col 0, health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(benefit->qual[d.seq].benefit_sk,16))), v_bar,
   CALL print(trim(replace(benefit->qual[d.seq].active_ind,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(benefit->qual[d.seq].benefit_type_ref,16))), v_bar,
   CALL print(trim(replace(benefit->qual[d.seq].cost_per_bed_day,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(benefit->qual[d.seq].cost_per_case,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(cnvtstring(benefit->qual[d.seq].data_type_ref,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,benefit->qual[d.seq].value_dt_tm,0,
      cnvtdatetimeutc(benefit->qual[d.seq].value_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm:ss"))
   ), v_bar,
   CALL print(trim(cnvtstring(benefit->qual[d.seq].value_tm_zn))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(benefit->qual[d.seq].value_dt_tm,cnvtint(benefit->qual[d
      .seq].value_tm_zn),"HHmmsscc"),"00000000","0","        ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(benefit->qual[d.seq].double_value,16))), v_bar,
   CALL print(trim(replace(benefit->qual[d.seq].benefit_desc,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(benefit->qual[d.seq].local_rvu,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(benefit->qual[d.seq].long_text_sk,16))), v_bar,
   CALL print(trim(replace(benefit->qual[d.seq].mnemonic,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(benefit->qual[d.seq].national_rvu,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(benefit->qual[d.seq].nbr_pat_agreed,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(benefit->qual[d.seq].rvu_amount,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(replace(benefit->qual[d.seq].string_value,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(cnvtstring(benefit->qual[d.seq].units_ref,16))), v_bar,
   CALL print(trim(replace(benefit->qual[d.seq].variance_level,str_find,str_replace,3),3)),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 SET script_version = "002 05/15/2020 BS074648"
END GO
