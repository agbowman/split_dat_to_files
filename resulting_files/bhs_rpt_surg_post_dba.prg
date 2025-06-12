CREATE PROGRAM bhs_rpt_surg_post:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Case Number :" = ""
  WITH outdev, ms_case_num
 EXECUTE bhs_check_domain
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE mf_start_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_stop_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_index_start_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ms_ftp_path = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE gv_file = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_rpt_surg_post/sn_pcase_data",trim(cnvtstring(rand(0),20),3),"_",format(cnvtdatetime(
     sysdate),"YYYYMMDDHHMMSS;;d"),
   ".dat"))
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 CALL echo(gv_file)
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
  SET mf_stop_dt_tm = datetimefind(cnvtdatetime(curdate,0),"M","B","B")
  SET mf_start_dt_tm = cnvtlookbehind("1 M",cnvtdatetime(mf_stop_dt_tm))
  SET mf_index_start_dt_tm = cnvtlookbehind("2 M",cnvtdatetime(mf_stop_dt_tm))
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
    brsp_case->l_cnt += 1, stat = alterlist(brsp_case->list,brsp_case->l_cnt), brsp_case->list[
    brsp_case->l_cnt].f_surg_case_id = sc.surg_case_id,
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
 ELSEIF (( $OUTDEV="D"))
  SET mf_stop_dt_tm = datetimefind(cnvtdatetime(curdate,0),"D","B","B")
  SET mf_start_dt_tm = cnvtlookbehind(concat(trim( $MS_CASE_NUM,3)," ","D"),cnvtdatetime(
    mf_stop_dt_tm))
  SET mf_index_start_dt_tm = cnvtlookbehind("6 M",cnvtdatetime(mf_stop_dt_tm))
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
    brsp_case->l_cnt += 1, stat = alterlist(brsp_case->list,brsp_case->l_cnt), brsp_case->list[
    brsp_case->l_cnt].f_surg_case_id = sc.surg_case_id,
    brsp_case->list[brsp_case->l_cnt].f_surg_start_dt = sc.surg_start_dt_tm, brsp_case->list[
    brsp_case->l_cnt].f_surg_stop_dt = sc.surg_stop_dt_tm, brsp_case->list[brsp_case->l_cnt].
    s_case_num = sc.surg_case_nbr_formatted
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM perioperative_document pd,
    surgical_case sc
   PLAN (pd
    WHERE pd.rec_ver_dt_tm > cnvtdatetime((curdate - 1),0)
     AND pd.rec_ver_dt_tm IS NOT null
     AND  NOT (expand(ml_idx,1,brsp_case->l_cnt,pd.surg_case_id,brsp_case->list[ml_idx].
     f_surg_case_id)))
    JOIN (sc
    WHERE sc.surg_case_id=pd.surg_case_id
     AND sc.encntr_id != 0
     AND sc.cancel_dt_tm = null
     AND sc.surg_start_dt_tm IS NOT null
     AND sc.surg_stop_dt_tm IS NOT null)
   ORDER BY sc.surg_case_id
   HEAD sc.surg_case_id
    brsp_case->l_cnt += 1, stat = alterlist(brsp_case->list,brsp_case->l_cnt), brsp_case->list[
    brsp_case->l_cnt].f_surg_case_id = sc.surg_case_id,
    brsp_case->list[brsp_case->l_cnt].f_surg_start_dt = sc.surg_start_dt_tm, brsp_case->list[
    brsp_case->l_cnt].f_surg_stop_dt = sc.surg_stop_dt_tm, brsp_case->list[brsp_case->l_cnt].
    s_case_num = sc.surg_case_nbr_formatted
   WITH nocounter, expand = 1
  ;end select
  IF ((brsp_case->l_cnt > 0))
   FOR (ml_loop = 1 TO brsp_case->l_cnt)
     EXECUTE bhs_surg_to_hl7 brsp_case->list[ml_loop].f_surg_case_id
   ENDFOR
  ENDIF
  CALL echorecord(brsp_case)
 ELSE
  SELECT INTO "nl:"
   FROM surgical_case sc
   WHERE sc.surg_case_nbr_formatted=cnvtupper( $MS_CASE_NUM)
    AND sc.encntr_id != 0.0
    AND sc.surg_start_dt_tm IS NOT null
    AND sc.surg_stop_dt_tm IS NOT null
    AND sc.cancel_dt_tm = null
   HEAD REPORT
    brsp_case->l_cnt = 0
   DETAIL
    brsp_case->l_cnt += 1, stat = alterlist(brsp_case->list,brsp_case->l_cnt), brsp_case->list[
    brsp_case->l_cnt].f_surg_case_id = sc.surg_case_id,
    brsp_case->list[brsp_case->l_cnt].f_surg_start_dt = sc.surg_start_dt_tm, brsp_case->list[
    brsp_case->l_cnt].f_surg_stop_dt = sc.surg_stop_dt_tm, brsp_case->list[brsp_case->l_cnt].
    s_case_num = sc.surg_case_nbr_formatted
   WITH nocounter
  ;end select
  IF ((brsp_case->l_cnt=0))
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     col 0, "{PS/792 0 translate 90 rotate/}", row + 1,
     "{F/1}{CPI/7}", "Case entered did not qualify. Please verify the case number is correct.", row
      + 2,
     "Also, make sure it is attached to an account and start/stop time are", row + 2, "filled out"
    WITH dio = 08, mine, time = 5
   ;end select
  ENDIF
  IF ((brsp_case->l_cnt > 0))
   FOR (ml_loop = 1 TO brsp_case->l_cnt)
     EXECUTE bhs_surg_to_hl7 brsp_case->list[ml_loop].f_surg_case_id
   ENDFOR
  ENDIF
 ENDIF
 IF ((brsp_case->l_cnt > 0))
  SET ms_dclcom = concat("mv ",gv_file," ",trim(logical("BHSCUST"),3),"/surginet/postcase/",
   gv_file)
  CALL echo(ms_dclcom)
  CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 ENDIF
#exit_program
END GO
