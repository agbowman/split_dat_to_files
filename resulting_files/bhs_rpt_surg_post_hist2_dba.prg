CREATE PROGRAM bhs_rpt_surg_post_hist2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Case Number :" = ""
  WITH outdev, ms_case_num
 EXECUTE bhs_check_domain:dba
 DECLARE mf_start_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_index_start_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE gv_file = vc WITH protect, constant("backload_cis_pcase.dat")
 CALL echo(gv_file)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 FREE RECORD brsp_case
 RECORD brsp_case(
   1 l_cnt = i4
   1 list[*]
     2 f_surg_case_id = f8
     2 f_surg_start_dt = dq8
     2 f_surg_stop_dt = dq8
     2 s_case_num = vc
 ) WITH protect
 IF (( $OUTDEV="M"))
  SET mf_stop_dt_tm = cnvtdatetime(cnvtdate2("20-DEC-2016","DD-MMM-YYYY"),235959)
  SET mf_start_dt_tm = cnvtdatetime(cnvtdate2("01-OCT-2016","DD-MMM-YYYY"),0)
  SET mf_index_start_dt_tm = cnvtlookbehind("3 M",cnvtdatetime(mf_stop_dt_tm))
  CALL echo(format(mf_stop_dt_tm,";;q"))
  CALL echo(format(mf_start_dt_tm,";;q"))
  CALL echo(format(mf_index_start_dt_tm,";;q"))
  SELECT INTO "nl:"
   FROM surgical_case sc
   WHERE sc.surg_start_dt_tm > cnvtdatetime(mf_index_start_dt_tm)
    AND sc.surg_stop_dt_tm >= cnvtdatetime(mf_start_dt_tm)
    AND sc.surg_stop_dt_tm < cnvtdatetime(mf_stop_dt_tm)
    AND sc.cancel_dt_tm = null
    AND sc.encntr_id != 0
   HEAD REPORT
    brsp_case->l_cnt = 0
   DETAIL
    brsp_case->l_cnt = (brsp_case->l_cnt+ 1), stat = alterlist(brsp_case->list,brsp_case->l_cnt),
    brsp_case->list[brsp_case->l_cnt].f_surg_case_id = sc.surg_case_id,
    brsp_case->list[brsp_case->l_cnt].f_surg_start_dt = sc.surg_start_dt_tm, brsp_case->list[
    brsp_case->l_cnt].f_surg_stop_dt = sc.surg_stop_dt_tm, brsp_case->list[brsp_case->l_cnt].
    s_case_num = sc.surg_case_nbr_formatted
   WITH nocounter
  ;end select
  IF ((brsp_case->l_cnt > 0))
   FOR (ml_loop = 1 TO brsp_case->l_cnt)
     EXECUTE bhs_surg_to_hl7 brsp_case->list[ml_loop].f_surg_case_id
   ENDFOR
  ENDIF
  CALL echorecord(brsp_case)
 ENDIF
#exit_program
END GO
