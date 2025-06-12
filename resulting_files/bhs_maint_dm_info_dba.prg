CREATE PROGRAM bhs_maint_dm_info:dba
 PROMPT
  "Maint. Excludes updt_task ID's greater than 1000" = "MINE",
  "" = 1,
  "DM_INFO" = "",
  "***CONFIRM DELETE***:" = "0",
  "Info Domain (text):" = "BHS",
  "Info Name (text):" = "",
  "Info Date (date):" = "SYSDATE",
  "Information (text):" = ""
  WITH outdev, n_buttons, s_dminfo,
  s_check_box, s_info_domain, s_info_name,
  d_info_date, s_info_char
 DECLARE gl_cnt = i4 WITH public, noconstant(0)
 DECLARE gl_info_domain_endpos = i4 WITH public, noconstant(0)
 DECLARE gl_info_name_endpos = i4 WITH public, noconstant(0)
 DECLARE gl_info_date_endpos = i4 WITH public, noconstant(0)
 DECLARE gs_info_domain = vc WITH public, noconstant(" ")
 DECLARE gs_info_name = vc WITH public, noconstant(" ")
 DECLARE gs_info_date = vc WITH public, noconstant(" ")
 DECLARE gs_info_char = vc WITH public, noconstant(" ")
 FREE RECORD m_dminfo
 RECORD m_dminfo(
   1 l_tot_rec = i4
   1 qual[*]
     2 s_info_domain = vc
     2 s_info_name = vc
     2 s_info_date = vc
     2 s_info_char = vc
     2 s_status = vc
 ) WITH protect
 IF (( $N_BUTTONS=1))
  SELECT INTO "nl:"
   FROM dm_info dm
   PLAN (dm
    WHERE dm.info_domain="BHS*"
     AND dm.updt_task < 1000.00)
   ORDER BY dm.info_date
   DETAIL
    m_dminfo->l_tot_rec = (m_dminfo->l_tot_rec+ 1), stat = alterlist(m_dminfo->qual,m_dminfo->
     l_tot_rec), m_dminfo->qual[m_dminfo->l_tot_rec].s_info_domain = trim(dm.info_domain,3),
    m_dminfo->qual[m_dminfo->l_tot_rec].s_info_name = trim(dm.info_name,3), m_dminfo->qual[m_dminfo->
    l_tot_rec].s_info_date = format(dm.info_date,"dd-mmm-yyyy hh:mm:ss"), m_dminfo->qual[m_dminfo->
    l_tot_rec].s_info_char = trim(dm.info_char,3),
    m_dminfo->qual[m_dminfo->l_tot_rec].s_status = "VIEW ONLY NO CHANGES"
   WITH nocounter, format, separator = " "
  ;end select
 ELSEIF (( $N_BUTTONS=2))
  SET gs_info_domain = trim(substring(0,(findstring("|",trim( $S_DMINFO,3),0) - 1),trim( $S_DMINFO,3)
    ),3)
  SET gl_info_domain_endpos = (findstring("|", $S_DMINFO,0)+ 1)
  SET gs_info_name = trim(substring(gl_info_domain_endpos,(findstring("~",trim( $S_DMINFO,3),0) -
    gl_info_domain_endpos),trim( $S_DMINFO,3)),3)
  SET gl_info_name_endpos = (findstring("~", $S_DMINFO,0)+ 1)
  SET gs_info_date = trim(substring(gl_info_name_endpos,(findstring("^",trim( $S_DMINFO,3),0) -
    gl_info_name_endpos),trim( $S_DMINFO,3)),3)
  SET gl_info_date_endpos = (findstring("^", $S_DMINFO,0)+ 1)
  SET gs_info_char = trim(substring(gl_info_date_endpos,(findstring("EndChar",trim( $S_DMINFO,3),0)
     - gl_info_date_endpos),trim( $S_DMINFO,3)),3)
  UPDATE  FROM dm_info dm
   SET dm.updt_cnt = (updt_cnt+ 1), dm.updt_applctx = 0, dm.updt_task = 0,
    dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.updt_id = 0, dm.info_name =  $S_INFO_NAME,
    dm.info_domain =  $S_INFO_DOMAIN, dm.info_date = cnvtdatetime( $D_INFO_DATE), dm.info_char =
     $S_INFO_CHAR
   WHERE dm.info_domain=gs_info_domain
    AND dm.info_name=gs_info_name
    AND dm.updt_task < 1000.00
   WITH nocounter
  ;end update
  COMMIT
  SELECT INTO "nl:"
   FROM dm_info dm
   PLAN (dm
    WHERE dm.info_domain="BHS*"
     AND (dm.info_domain !=  $S_INFO_DOMAIN)
     AND (dm.info_name !=  $S_INFO_NAME)
     AND dm.updt_task < 1000.00)
   ORDER BY dm.info_date
   HEAD REPORT
    m_dminfo->l_tot_rec = (m_dminfo->l_tot_rec+ 1), stat = alterlist(m_dminfo->qual,m_dminfo->
     l_tot_rec), m_dminfo->qual[m_dminfo->l_tot_rec].s_info_domain =  $S_INFO_DOMAIN,
    m_dminfo->qual[m_dminfo->l_tot_rec].s_info_name =  $S_INFO_NAME, m_dminfo->qual[m_dminfo->
    l_tot_rec].s_info_date =  $D_INFO_DATE, m_dminfo->qual[m_dminfo->l_tot_rec].s_info_char =
     $S_INFO_CHAR,
    m_dminfo->qual[m_dminfo->l_tot_rec].s_status = "**UPDATED ROW**"
   DETAIL
    m_dminfo->l_tot_rec = (m_dminfo->l_tot_rec+ 1), stat = alterlist(m_dminfo->qual,m_dminfo->
     l_tot_rec), m_dminfo->qual[m_dminfo->l_tot_rec].s_info_domain = trim(dm.info_domain,3),
    m_dminfo->qual[m_dminfo->l_tot_rec].s_info_name = trim(dm.info_name,3), m_dminfo->qual[m_dminfo->
    l_tot_rec].s_info_date = format(dm.info_date,"dd-mmm-yyyy hh:mm:ss"), m_dminfo->qual[m_dminfo->
    l_tot_rec].s_info_char = trim(dm.info_char,3),
    m_dminfo->qual[m_dminfo->l_tot_rec].s_status = "ROW NOT UPDATED"
   WITH nocounter
  ;end select
 ELSEIF (( $N_BUTTONS=3))
  SET gs_info_domain = trim(substring(0,(findstring("|",trim( $S_DMINFO,3),0) - 1),trim( $S_DMINFO,3)
    ),3)
  SET gl_info_domain_endpos = (findstring("|", $S_DMINFO,0)+ 1)
  SET gs_info_name = trim(substring(gl_info_domain_endpos,(findstring("~",trim( $S_DMINFO,3),0) -
    gl_info_domain_endpos),trim( $S_DMINFO,3)),3)
  SET gl_info_name_endpos = (findstring("~", $S_DMINFO,0)+ 1)
  SET gs_info_date = trim(substring(gl_info_name_endpos,(findstring("^",trim( $S_DMINFO,3),0) -
    gl_info_name_endpos),trim( $S_DMINFO,3)),3)
  SET gl_info_date_endpos = (findstring("^", $S_DMINFO,0)+ 1)
  SET gs_info_char = trim(substring(gl_info_date_endpos,(findstring("EndChar",trim( $S_DMINFO,3),0)
     - gl_info_date_endpos),trim( $S_DMINFO,3)),3)
  DELETE  FROM dm_info
   WHERE info_domain=gs_info_domain
    AND info_name=gs_info_name
   WITH nocounter
  ;end delete
  COMMIT
  SELECT INTO "nl:"
   FROM dm_info dm
   PLAN (dm
    WHERE dm.info_domain="BHS*"
     AND dm.updt_task < 1000.00)
   ORDER BY dm.info_date
   HEAD REPORT
    m_dminfo->l_tot_rec = (m_dminfo->l_tot_rec+ 1), stat = alterlist(m_dminfo->qual,m_dminfo->
     l_tot_rec), m_dminfo->qual[m_dminfo->l_tot_rec].s_info_domain = gs_info_domain,
    m_dminfo->qual[m_dminfo->l_tot_rec].s_info_name = gs_info_name, m_dminfo->qual[m_dminfo->
    l_tot_rec].s_info_date = gs_info_date, m_dminfo->qual[m_dminfo->l_tot_rec].s_info_char =
    gs_info_char,
    m_dminfo->qual[m_dminfo->l_tot_rec].s_status = "**DELETED ROW**"
   DETAIL
    m_dminfo->l_tot_rec = (m_dminfo->l_tot_rec+ 1), stat = alterlist(m_dminfo->qual,m_dminfo->
     l_tot_rec), m_dminfo->qual[m_dminfo->l_tot_rec].s_info_domain = trim(dm.info_domain,3),
    m_dminfo->qual[m_dminfo->l_tot_rec].s_info_name = trim(dm.info_name,3), m_dminfo->qual[m_dminfo->
    l_tot_rec].s_info_date = format(dm.info_date,"dd-mmm-yyyy hh:mm:ss"), m_dminfo->qual[m_dminfo->
    l_tot_rec].s_info_char = trim(dm.info_char,3),
    m_dminfo->qual[m_dminfo->l_tot_rec].s_status = "ROW NOT DELETED"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET m_dminfo->l_tot_rec = (m_dminfo->l_tot_rec+ 1)
   SET stat = alterlist(m_dminfo->qual,m_dminfo->l_tot_rec)
   SET m_dminfo->qual[m_dminfo->l_tot_rec].s_info_domain = gs_info_domain
   SET m_dminfo->qual[m_dminfo->l_tot_rec].s_info_name = gs_info_name
   SET m_dminfo->qual[m_dminfo->l_tot_rec].s_info_date = gs_info_date
   SET m_dminfo->qual[m_dminfo->l_tot_rec].s_info_char = gs_info_char
   SET m_dminfo->qual[m_dminfo->l_tot_rec].s_status = "**DELETED ROW**"
  ENDIF
 ELSEIF (( $N_BUTTONS=4))
  SELECT INTO "nl:"
   dm.info_domain, dm.info_name, dm.info_date,
   dm.info_char
   FROM dm_info dm
   PLAN (dm
    WHERE dm.info_name=trim( $S_INFO_NAME)
     AND dm.info_domain=trim( $S_INFO_DOMAIN))
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM dm_info dm
    SET dm.info_name = trim( $S_INFO_NAME), dm.info_domain = trim( $S_INFO_DOMAIN), dm.info_date =
     cnvtdatetime( $D_INFO_DATE),
     dm.info_char = trim( $S_INFO_CHAR), dm.info_number = 0, dm.updt_cnt = 0,
     dm.updt_applctx = 0, dm.updt_task = 0, dm.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     dm.updt_id = 0
    WITH nocounter
   ;end insert
   COMMIT
   SELECT INTO "nl:"
    FROM dm_info dm
    PLAN (dm
     WHERE dm.info_domain="BHS*"
      AND (dm.info_domain !=  $S_INFO_DOMAIN)
      AND (dm.info_name !=  $S_INFO_NAME)
      AND dm.updt_task < 1000.00)
    ORDER BY dm.info_date
    HEAD REPORT
     m_dminfo->l_tot_rec = (m_dminfo->l_tot_rec+ 1), stat = alterlist(m_dminfo->qual,m_dminfo->
      l_tot_rec), m_dminfo->qual[m_dminfo->l_tot_rec].s_info_domain =  $S_INFO_DOMAIN,
     m_dminfo->qual[m_dminfo->l_tot_rec].s_info_name =  $S_INFO_NAME, m_dminfo->qual[m_dminfo->
     l_tot_rec].s_info_date =  $D_INFO_DATE, m_dminfo->qual[m_dminfo->l_tot_rec].s_info_char =
      $S_INFO_CHAR,
     m_dminfo->qual[m_dminfo->l_tot_rec].s_status = "**INSERTED ROW**"
    DETAIL
     m_dminfo->l_tot_rec = (m_dminfo->l_tot_rec+ 1), stat = alterlist(m_dminfo->qual,m_dminfo->
      l_tot_rec), m_dminfo->qual[m_dminfo->l_tot_rec].s_info_domain = trim(dm.info_domain,3),
     m_dminfo->qual[m_dminfo->l_tot_rec].s_info_name = trim(dm.info_name,3), m_dminfo->qual[m_dminfo
     ->l_tot_rec].s_info_date = format(dm.info_date,"dd-mmm-yyyy hh:mm:ss"), m_dminfo->qual[m_dminfo
     ->l_tot_rec].s_info_char = trim(dm.info_char,3),
     m_dminfo->qual[m_dminfo->l_tot_rec].s_status = "ROW NOT INSERTED"
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SELECT INTO  $OUTDEV
  status = substring(1,100,m_dminfo->qual[d.seq].s_status), info_domain = substring(1,80,m_dminfo->
   qual[d.seq].s_info_domain), info_name = substring(1,255,m_dminfo->qual[d.seq].s_info_name),
  info_date = substring(1,35,m_dminfo->qual[d.seq].s_info_date), info_char = substring(1,4000,
   m_dminfo->qual[d.seq].s_info_char)
  FROM (dummyt d  WITH seq = value(size(m_dminfo->qual,5)))
  PLAN (d)
  ORDER BY info_date
  WITH nocounter, format, separator = " "
 ;end select
END GO
