CREATE PROGRAM bhs_rpt_last_name_suffix:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Suffix Search" = "* MD*",
  "Active Only" = 0,
  "Recipients" = ""
  WITH outdev, s_suffix, n_active_ind,
  s_recipients
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 s_provider_last = vc
     2 s_provider_first = vc
     2 s_provider_user = vc
     2 f_prsnl_id = f8
 ) WITH protect
 DECLARE mf_active_stat_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_spi_alias_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"SPI"))
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_error = vc WITH protect, noconstant("")
 DECLARE ms_subject = vc WITH protect, noconstant("")
 DECLARE ms_pr_active_p = vc WITH protect, noconstant("1=1")
 DECLARE ms_pa_active_p = vc WITH protect, noconstant("1=1")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_LAST_NAME_SUFFIX"
    AND di.info_char="EMAIL"
   ORDER BY di.info_name
   DETAIL
    IF (textlen(trim(ms_recipients,3)) < 1)
     ms_recipients = trim(di.info_name,3)
    ELSE
     ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (findstring("@",ms_recipients)=0
  AND textlen(ms_recipients) > 0)
  SET ms_error = "Recipient email is invalid."
  GO TO exit_script
 ENDIF
 IF (( $N_ACTIVE_IND=1))
  SET ms_pr_active_p = build2(
'pr.active_ind = 1 and pr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")                              and pr.ac\
tive_status_cd = \
',mf_active_stat_cd)
  SET ms_pa_active_p = build2(
'pa.active_ind = 1 and pa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")                              and pa.ac\
tive_status_cd = \
',mf_active_stat_cd)
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl pr,
   prsnl_alias pa
  PLAN (pr
   WHERE (pr.name_last= $S_SUFFIX)
    AND parser(ms_pr_active_p))
   JOIN (pa
   WHERE pa.person_id=pr.person_id
    AND pa.prsnl_alias_type_cd=mf_spi_alias_cd
    AND parser(ms_pa_active_p))
  ORDER BY pr.name_full_formatted
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 99))
   ENDIF
   m_rec->qual[ml_cnt].f_prsnl_id = pr.person_id, m_rec->qual[ml_cnt].s_provider_first = pr
   .name_first, m_rec->qual[ml_cnt].s_provider_last = pr.name_last,
   m_rec->qual[ml_cnt].s_provider_user = pr.username
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt), m_rec->l_cnt = ml_cnt
  WITH nocounter
 ;end select
 IF (size(m_rec->qual,5)=0)
  SET ms_error = "No data found."
  GO TO exit_script
 ENDIF
 IF (((mn_ops=1) OR (textlen(trim( $S_RECIPIENTS,3)) > 1)) )
  SET ms_subject = build2("Last Name Suffix Providers Report ",trim(format(curdate,"mmm-dd-yyyy ;;d")
    ))
  SET frec->file_name = build(cnvtlower(curprog),"_",trim(format(curdate,"mm_dd_yy ;;d"),3),".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"PROVIDER LAST NAME",','"PROVIDER FIRST NAME",','"PROVIDER USERNAME",',
   '"PRSNL ID",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_rec->l_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_cnt].s_provider_last,3),'","',trim(m_rec->qual[
     ml_cnt].s_provider_first,3),'","',
    trim(m_rec->qual[ml_cnt].s_provider_user,3),'","',m_rec->qual[ml_cnt].f_prsnl_id,'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT INTO value( $OUTDEV)
   provider_last_name = substring(1,50,m_rec->qual[d.seq].s_provider_last), provider_first_name =
   substring(1,50,m_rec->qual[d.seq].s_provider_first), provider_username = substring(1,50,m_rec->
    qual[d.seq].s_provider_user),
   prsnl_id = m_rec->qual[d.seq].f_prsnl_id
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
 FREE RECORD frec
 IF (((mn_ops=1) OR (textlen(trim( $OUTDEV,3))=0)) )
  SET reply->status_data[1].status = "S"
 ELSEIF (textlen(trim( $S_RECIPIENTS,3)) > 1
  AND textlen(trim(ms_error,3))=0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "The report has been sent to:", msg2 = build2("     ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ELSEIF (textlen(trim(ms_error,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(26,18)),
    ms_error
   WITH dio = 08
  ;end select
 ENDIF
END GO
