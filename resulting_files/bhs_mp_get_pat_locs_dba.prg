CREATE PROGRAM bhs_mp_get_pat_locs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID" = 0
  WITH outdev, f_encntr_id
 FREE RECORD m_rec
 RECORD m_rec(
   1 loc[*]
     2 s_loc_name = vc
     2 f_loc_cd = f8
     2 s_beg_dt_tm = vc
     2 s_end_dt_tm = vc
 ) WITH protect
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(cnvtreal( $F_ENCNTR_ID))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 IF (mf_encntr_id=0.0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh
  WHERE elh.encntr_id=mf_encntr_id
   AND elh.active_ind=1
  ORDER BY elh.beg_effective_dt_tm
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->loc,pl_cnt), m_rec->loc[pl_cnt].f_loc_cd = elh
   .loc_nurse_unit_cd,
   m_rec->loc[pl_cnt].s_loc_name = trim(uar_get_code_display(elh.loc_nurse_unit_cd)), m_rec->loc[
   pl_cnt].s_beg_dt_tm = trim(format(elh.beg_effective_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d")), m_rec->loc[
   pl_cnt].s_end_dt_tm = trim(format(elh.end_effective_dt_tm,"dd-mmm-yyyy hh:mm:ss;;d"))
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 SET _memory_reply_string = cnvtrectojson(m_rec)
END GO
