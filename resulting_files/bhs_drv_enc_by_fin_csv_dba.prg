CREATE PROGRAM bhs_drv_enc_by_fin_csv:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "CSV File Name:" = ""
  WITH outdev, s_csv_file
 FREE RECORD m_rec
 RECORD m_rec(
   1 alias[*]
     2 s_encntr_id = vc
     2 s_alias_type = vc
     2 s_alias = vc
     2 s_alias_pool_disp = vc
     2 s_encntr_class = vc
     2 s_encntr_type = vc
     2 s_active_status = vc
     2 s_med_svc = vc
     2 s_disch_dt_tm = vc
     2 s_depart_dt_tm = vc
 ) WITH protect
 DECLARE ms_csv_file = vc WITH protect, constant(concat("/cerner/d_p627/bhscust/",trim(cnvtlower(
      $S_CSV_FILE),3)))
 DECLARE ml_rows = i4 WITH protect, constant(500)
 DECLARE ms_parse = vc WITH protect, noconstant(" ")
 SET trace = recpersist
 EXECUTE kia_dm_dbimport ms_csv_file, "bhs_rpt_enc_by_fin_csv", ml_rows,
 0
 SET trace = norecpersist
 CALL echorecord(m_rec)
 SELECT INTO value( $OUTDEV)
  alias_pool = substring(1,30,m_rec->alias[d.seq].s_alias_pool_disp), alias_type = substring(1,30,
   m_rec->alias[d.seq].s_alias_type), alias = substring(1,30,m_rec->alias[d.seq].s_alias),
  encntr_id = substring(1,30,m_rec->alias[d.seq].s_encntr_id), encntr_class = substring(1,30,m_rec->
   alias[d.seq].s_encntr_class), encntr_type = substring(1,30,m_rec->alias[d.seq].s_encntr_type),
  active_status = substring(1,20,m_rec->alias[d.seq].s_active_status), med_service = substring(1,30,
   m_rec->alias[d.seq].s_med_svc), disch_dt_tm = substring(1,20,m_rec->alias[d.seq].s_disch_dt_tm),
  depart_dt_tm = substring(1,20,m_rec->alias[d.seq].s_depart_dt_tm)
  FROM (dummyt d  WITH seq = value(size(m_rec->alias,5)))
  ORDER BY med_service
  WITH nocounter, format, separator = " ",
   maxrow = 1
 ;end select
#exit_script
END GO
