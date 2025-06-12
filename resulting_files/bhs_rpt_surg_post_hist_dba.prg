CREATE PROGRAM bhs_rpt_surg_post_hist:dba
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
 DECLARE gv_file = vc WITH protect, constant(concat("sn_pcase_data",trim(cnvtstring(rand(0),20),3),
   "_",format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;d"),".dat"))
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
  SET mf_stop_dt_tm = cnvtdatetime((curdate+ 15),0)
  SET mf_start_dt_tm = cnvtdatetime((curdate - 16),0)
  SET mf_index_start_dt_tm = cnvtlookbehind("4 M",cnvtdatetime(mf_stop_dt_tm))
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
 IF ((brsp_case->l_cnt > 0))
  SET ms_dclcom = concat("$cust_script/bhs_ftp_file.ksh ",gv_file,
   " 172.17.10.5 'bhs\cisftp' C!sftp01 '",'"',"ciscore/surginet",
   '"',"'")
  CALL echo(ms_dclcom)
  CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
  IF (gl_bhs_prod_flag=1)
   SET ms_dclcom = concat(
    "$cust_script/bhs_sftp_file.ksh ensftp@bh-enslive:/tempfiles/hold/ens/ensftp/cis ",gv_file)
   CALL echo(ms_dclcom)
   CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
  ELSE
   SET ms_dclcom = concat(
    "$cust_script/bhs_sftp_file.ksh ensftp@bh-enstest:/tempfiles/hold/ens/ensftp/cis ",gv_file)
   CALL echo(ms_dclcom)
   CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
  ENDIF
  SET ms_dclcom = concat("mv ",gv_file," ",trim(logical("BHSCUST"),3),"/surginet/postcase/",
   gv_file)
  CALL echo(ms_dclcom)
  CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 ENDIF
#exit_program
END GO
