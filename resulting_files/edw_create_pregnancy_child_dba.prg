CREATE PROGRAM edw_create_pregnancy_child:dba
 SELECT INTO value(pregchld_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_id)), v_bar,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].pregnancy_child_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].pregnancy_inst_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].gender_ref,16))), v_bar,
   CALL print(trim(replace(edw_pregnancy_child->qual[d.seq].child_name,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].child_person_sk,16))), v_bar,
   CALL print(trim(replace(edw_pregnancy_child->qual[d.seq].father_name,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].delivery_method_ref,16))),
   v_bar,
   CALL print(trim(replace(edw_pregnancy_child->qual[d.seq].delivery_hospital,str_find,str_replace,3)
    )), v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].gestation_age,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].weight_amt,11,1))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].weight_unit_ref,16))), v_bar,
   CALL print(trim(replace(edw_pregnancy_child->qual[d.seq].anesthesia_txt,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(edw_pregnancy_child->qual[d.seq].preterm_labor_txt,str_find,str_replace,3)
    )),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pregnancy_child->qual[d.seq].
      delivery_dt_tm,0,cnvtdatetimeutc(edw_pregnancy_child->qual[d.seq].delivery_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].delivery_tm_zn))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pregnancy_child->qual[d.seq].delivery_dt_tm,cnvtint(
      edw_pregnancy_child->qual[d.seq].delivery_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")),
   v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].neonate_outcome_ref,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].child_long_text_sk,16))), v_bar,
   CALL print(trim(edw_pregnancy_child->qual[d.seq].src_active_ind)),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pregnancy_child->qual[d.seq].
      src_beg_effective_dt_tm,0,cnvtdatetimeutc(edw_pregnancy_child->qual[d.seq].
       src_beg_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pregnancy_child->qual[d.seq].src_beg_effective_dt_tm,
     cnvtint(edw_pregnancy_child->qual[d.seq].src_tz),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_pregnancy_child->qual[d.seq].
      src_end_effective_dt_tm,0,cnvtdatetimeutc(edw_pregnancy_child->qual[d.seq].
       src_end_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(evaluate(datetimezoneformat(edw_pregnancy_child->qual[d.seq].src_end_effective_dt_tm,
     cnvtint(edw_pregnancy_child->qual[d.seq].src_tz),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].src_tz))), v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].labor_duration,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].delivery_date_precision_flg,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].delivery_date_qualifier_flg,16))),
   v_bar,
   CALL print(trim(edw_pregnancy_child->qual[d.seq].restrict_person_ind)),
   v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].newborn_complication_nomen,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].newborn_complication_long_text_sk,16))
   ), v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].anesthesia_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].mother_complication_nomen,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].mother_complication_long_text_sk,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].preterm_labor_ref,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].fetus_complication_nomen,16))), v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].fetus_complication_long_text_sk,16))),
   v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(trim(cnvtstring(edw_pregnancy_child->qual[d.seq].pregnancy_sk,16))), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
END GO
