CREATE PROGRAM edw_alpha_resp:dba
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 SELECT INTO value(a_resp_extractfile)
  n_default_ind = nullind(ap.default_ind), n_multi_alpha_sort_order = nullind(ap
   .multi_alpha_sort_order), n_result_value = nullind(ap.result_value),
  n_use_units_ind = nullind(ap.use_units_ind), n_active_ind = nullind(ap.active_ind), n_reference_ind
   = nullind(ap.reference_ind)
  FROM alpha_responses ap
  WHERE ap.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
  DETAIL
   col 0, health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(ap.nomenclature_id,16))), v_bar,
   CALL print(trim(cnvtstring(ap.reference_range_factor_id,16))),
   v_bar,
   CALL print(build(ap.sequence)), v_bar,
   CALL print(trim(evaluate(n_default_ind,0,build(ap.default_ind)," "))), v_bar,
   CALL print(trim(replace(ap.description,str_find,str_replace,3),3)),
   v_bar,
   CALL print(trim(evaluate(n_multi_alpha_sort_order,0,build(ap.multi_alpha_sort_order)," "))), v_bar,
   CALL print(trim(evaluate(n_reference_ind,0,build(ap.reference_ind)," "))), v_bar,
   CALL print(trim(cnvtstring(ap.result_process_cd,16))),
   v_bar,
   CALL print(trim(evaluate(n_result_value,0,cnvtstring(ap.result_value,16),""))), v_bar,
   CALL print(trim(evaluate(n_use_units_ind,0,build(ap.use_units_ind)," "))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(evaluate(n_active_ind,0,build(ap.active_ind)," ")), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1
 ;end select
 CALL echo(build("A_RESP Count = ",curqual))
 CALL edwupdatescriptstatus("A_RESP",curqual,"4","4")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "004 06/01/07 YC3429"
END GO
