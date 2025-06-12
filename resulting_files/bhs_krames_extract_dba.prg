CREATE PROGRAM bhs_krames_extract:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = h
   1 file_offset = h
   1 file_dir = h
 )
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 s_document_description = vc
     2 s_file_name = vc
     2 s_full_file_name = vc
     2 s_rtf = gvc
 ) WITH protect
 DECLARE ms_loc_dir = vc WITH protect, constant(logical("ccluserdir"))
 DECLARE ms_rem_dir = vc WITH protect, constant("/CISCORE/testing/krames")
 DECLARE ms_ftp_host = vc WITH protect, constant("transfer.baystatehealth.org")
 DECLARE ms_ftp_username = vc WITH protect, constant('"bhs\cisftp"')
 DECLARE ms_ftp_password = vc WITH protect, constant("C!sftp01")
 DECLARE ms_blobout = vc WITH protect, noconstant(" ")
 DECLARE ml_blobsize = i4 WITH protect, noconstant(0)
 DECLARE ml_totblobsize = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_filename = vc WITH protect, noconstant(" ")
 DECLARE ms_fullfilename = vc WITH protect, noconstant(" ")
 DECLARE ms_put_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_outdev = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_dcllen = i4 WITH protect, noconstant(0)
 DECLARE ml_dclstatus = i4 WITH protect, noconstant(0)
 SET ms_outdev = value( $OUTDEV)
 SELECT INTO "nl:"
  FROM pat_ed_reltn per,
   long_blob_reference lbr
  PLAN (per
   WHERE per.active_ind=1
    AND per.custom_ind=1
    AND per.pat_ed_domain_cd IN (319430088.00, 319430092.00)
    AND per.pat_ed_reltn_desc_key > " "
    AND per.pat_ed_reltn_desc_key != "ZZ*"
    AND per.updt_dt_tm >= cnvtdatetime("01-AUG-2020 00:00:00"))
   JOIN (lbr
   WHERE lbr.long_blob_id=per.refr_text_id
    AND lbr.active_ind=1)
  ORDER BY per.pat_ed_reltn_desc_key
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt += 1, m_rec->l_cnt = ml_cnt, stat = alterlist(m_rec->qual,ml_cnt),
   m_rec->qual[ml_cnt].s_document_description = replace(trim(per.pat_ed_reltn_desc,3),"/","--"),
   m_rec->qual[ml_cnt].s_document_description = replace(m_rec->qual[ml_cnt].s_document_description,
    ":",""), m_rec->qual[ml_cnt].s_file_name = cnvtlower(trim(per.pat_ed_reltn_desc_key,3)),
   m_rec->qual[ml_cnt].s_full_file_name = build(trim(per.pat_ed_reltn_desc,3),".rtf"), ml_blobsize =
   blobgetlen(lbr.long_blob), stat = memrealloc(ms_blobout,1,build("C",ml_blobsize)),
   ml_totblobsize = blobget(ms_blobout,0,lbr.long_blob), m_rec->qual[ml_cnt].s_rtf = trim(ms_blobout,
    3)
  WITH nocounter
 ;end select
 EXECUTE bhs_hlp_ftp
 FOR (ml_loop = 1 TO ml_cnt)
   CALL echo(build2("Description: ",m_rec->qual[ml_loop].s_document_description))
   CALL echo(build2("file name: ",m_rec->qual[ml_loop].s_file_name))
   SET ms_filename = concat(trim(m_rec->qual[ml_loop].s_file_name,3),".rtf")
   SET ms_fullfilename = concat(trim(m_rec->qual[ml_loop].s_document_description,3),".rtf")
   CALL echo(build2("ms_filename: ",ms_filename))
   CALL echo(build2("ms_fullfilename: ",ms_fullfilename))
   SET frec->file_name = ms_filename
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = m_rec->qual[ml_loop].s_rtf
   SET stat = cclio("WRITE",frec)
   SET stat = cclio("CLOSE",frec)
   SET ms_put_ftp_cmd = concat('put "',ms_filename,'" "',ms_fullfilename,'"')
   CALL echo(ms_put_ftp_cmd)
   SET stat = bhs_ftp_cmd(ms_put_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,ms_loc_dir,
    ms_rem_dir)
 ENDFOR
 SELECT INTO value(ms_outdev)
  document_description = trim(substring(1,255,m_rec->qual[d1.seq].s_document_description),3),
  file_name = trim(substring(1,255,m_rec->qual[d1.seq].s_file_name),3), full_file_name = trim(
   substring(1,255,m_rec->qual[d1.seq].s_full_file_name),3),
  rename_command = concat('ren "',trim(substring(1,255,m_rec->qual[d1.seq].s_file_name),3),'.rtf" "',
   trim(substring(1,255,m_rec->qual[d1.seq].s_full_file_name),3),'"')
  FROM (dummyt d1  WITH seq = ml_cnt)
  WITH format, separator = " ", nocounter
 ;end select
#exit_script
END GO
