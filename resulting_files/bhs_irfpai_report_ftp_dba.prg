CREATE PROGRAM bhs_irfpai_report_ftp:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 cnt = i4
   1 list[*]
     2 file_name = vc
 )
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE m_for_cnt = i4 WITH protect, noconstant(0)
 SET ms_dclcom = "ls $bhscust/irfpai_report >$CCLUSERDIR/bhs_irfpai_report_ftp.out"
 SET ml_stat = - (1)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 CALL echo(build("ls status (1=success, 0=fail): ",ml_stat))
 FREE DEFINE rtl2
 DEFINE rtl2 "ccluserdir:bhs_irfpai_report_ftp.out"
 SELECT INTO "nl:"
  FROM rtl2t r
  WHERE r.line > ""
  DETAIL
   IF (findstring(".XML",cnvtupper(r.line)) > 0)
    m_rec->cnt += 1, stat = alterlist(m_rec->list,m_rec->cnt), m_rec->list[m_rec->cnt].file_name =
    trim(r.line,3)
   ENDIF
  WITH nocounter
 ;end select
 FOR (m_for_cnt = 1 TO 1)
   SET ms_dclcom = concat(
    "$cust_script/bhs_sftp_file.ksh ciscoreftp3@transfer.baystatehealth.org:/irfpai",
    " $bhscust/irfpai_report/",m_rec->list[m_for_cnt].file_name)
   SET ml_stat = - (1)
   CALL echo(build("FTP Command: ",ms_dclcom))
   CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
   CALL echo(build("FTP Status (1=success, 0=fail): ",ml_stat))
   SET ms_dclcom = concat("rm $bhscust/irfpai_report/",m_rec->list[m_for_cnt].file_name)
   CALL echo(ms_dclcom)
   CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
   CALL echo(build("RM xml Status (1=success, 0=fail): ",ml_stat))
 ENDFOR
 SET ms_dclcom = "rm $CCLUSERDIR/bhs_irfpai_report_ftp.out"
 SET ml_stat = - (1)
 CALL echo(ms_dclcom)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 CALL echo(build("RM .out status (1=success, 0=fail): ",ml_stat))
 FREE RECORD m_rec
END GO
