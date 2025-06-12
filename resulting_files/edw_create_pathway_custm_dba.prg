CREATE PROGRAM edw_create_pathway_custm:dba
 SELECT INTO value(pthcustp_extractfile)
  FROM (dummyt d  WITH seq = value(cur_list_size))
  WHERE cur_list_size > 0
  DETAIL
   col 0,
   CALL print(trim(health_system_source_id)), v_bar,
   CALL print(trim(cnvtstring(edw_get_pathway_custm->qual[d.seq].pathway_cust_plan_sk,16))), v_bar,
   CALL print(trim(cnvtstring(edw_get_pathway_custm->qual[d.seq].pathway_catalog_sk,16))),
   v_bar,
   CALL print(trim(replace(edw_get_pathway_custm->qual[d.seq].plan_name,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(cnvtstring(edw_get_pathway_custm->qual[d.seq].customized_prsnl,16))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,edw_get_pathway_custm->qual[d.seq].
      create_dt_tm,0,cnvtdatetimeutc(edw_get_pathway_custm->qual[d.seq].create_dt_tm,3)),
     utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(cnvtstring(edw_get_pathway_custm->qual[d.seq].default_tm_zn,16))), v_bar,
   CALL print(evaluate(datetimezoneformat(edw_get_pathway_custm->qual[d.seq].create_dt_tm,cnvtint(
      edw_get_pathway_custm->qual[d.seq].default_tm_zn),"MMddyyyyHHmmsscc"),"0000000000000000","0",
    "                ","0",
    "1")), v_bar,
   CALL print(trim(cnvtstring(edw_get_pathway_custm->qual[d.seq].status_flg,16))),
   v_bar,
   CALL print(trim(cnvtstring(edw_get_pathway_custm->qual[d.seq].src_active_ind,16))), v_bar,
   CALL print(trim(evaluate(historic_ind,"Y","1","0"))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 CALL echo(build("PTHCUSTP Count = ",curqual))
 CALL edwupdatescriptstatus("PTHCUSTP",curqual,"1","1")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 11/22/11 SM016593"
END GO
