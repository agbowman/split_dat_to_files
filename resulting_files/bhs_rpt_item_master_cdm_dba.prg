CREATE PROGRAM bhs_rpt_item_master_cdm:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Chargeable Only:" = 1,
  "CDM Mismatch Only:" = 0,
  "Email Address:" = ""
  WITH outdev, l_chrg_only, l_cdm_mismatch,
  s_email
 DECLARE mf_cs11001_item_master_cd = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!3308"))
 DECLARE mf_cs11000_cdm_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3304"))
 DECLARE mf_cs13019_billcode_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3516")
  )
 DECLARE ms_chrg_parser = vc WITH protect, noconstant(" 1 = 1 ")
 DECLARE ms_cdm_mismatch_parser = vc WITH protect, noconstant(" 1 = 1 ")
 DECLARE ml_email_ind = i4 WITH protect, noconstant(0)
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_item_master_id = f8
     2 s_create_dt = vc
     2 s_updt_cnt = vc
     2 s_last_updt_dt = vc
     2 s_updt_user = vc
     2 s_item_type = vc
     2 s_item_sys_nbr = vc
     2 s_item_nbr = vc
     2 s_item_short_desc = vc
     2 s_item_desc = vc
     2 s_item_chrg_ind = vc
     2 s_item_cdm = vc
     2 s_price_tool_cdm = vc
     2 s_cdm_match = vc
     2 s_item_cdm_updt_cnt = vc
     2 s_item_cdm_updt_dt = vc
     2 s_item_cdm_updt_user = vc
     2 s_price_tool_short_desc = vc
     2 s_price_tool_desc = vc
     2 s_price_tool_updt_cnt = vc
     2 s_price_tool_updt_dt = vc
     2 s_price_tool_updt_user = vc
 ) WITH protect
 IF (( $L_CHRG_ONLY=1))
  SET ms_chrg_parser = " m_rec->qual[d.seq].s_item_chrg_ind = '1'"
 ENDIF
 IF (( $L_CDM_MISMATCH=1))
  SET ms_cdm_mismatch_parser = " m_rec->qual[d.seq].s_cdm_match = 'Fail'"
 ENDIF
 IF (size(trim( $S_EMAIL,3)) > 0)
  IF (((findstring("@",trim( $S_EMAIL))=0) OR (findstring(".",trim( $S_EMAIL))=0)) )
   SELECT INTO value( $OUTDEV)
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    HEAD REPORT
     "{CPI/9}{FONT/4}", row 0, col 0,
     CALL print(build2("PROGRAM:  ",cnvtlower(curprog),"       NODE:  ",curnode)), row + 1, row 3,
     col 0,
     CALL print("Invalid e-mail address provided. Please correct it and run the report again."), row
      + 1,
     row 6, col 0,
     CALL print(build2("Execution Date/Time:",format(cnvtdatetime(curdate,curtime),
       "mm/dd/yyyy hh:mm:ss;;q")))
    WITH nocounter, nullreport, maxcol = 300,
     dio = 08
   ;end select
   GO TO exit_script
  ENDIF
  SET ml_email_ind = 1
 ENDIF
 SELECT INTO "nl:"
  FROM mm_omf_item_master m,
   prsnl p1,
   item_definition id,
   object_identifier_index oii,
   prsnl p2,
   bill_item bi,
   bill_item_modifier bim,
   prsnl p3
  PLAN (m
   WHERE m.active_ind=1
    AND m.type_cd=mf_cs11001_item_master_cd)
   JOIN (p1
   WHERE (p1.person_id= Outerjoin(m.updt_id)) )
   JOIN (id
   WHERE (id.item_id= Outerjoin(m.item_master_id)) )
   JOIN (oii
   WHERE (oii.active_ind= Outerjoin(1))
    AND (oii.parent_entity_id= Outerjoin(m.item_master_id))
    AND (oii.identifier_type_cd= Outerjoin(mf_cs11000_cdm_cd)) )
   JOIN (p2
   WHERE (p2.person_id= Outerjoin(oii.updt_id)) )
   JOIN (bi
   WHERE (bi.ext_short_desc= Outerjoin(m.stock_nbr))
    AND (bi.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (bi.active_ind= Outerjoin(1)) )
   JOIN (bim
   WHERE (bim.bill_item_id= Outerjoin(bi.bill_item_id))
    AND (bim.bill_item_type_cd= Outerjoin(mf_cs13019_billcode_cd))
    AND (bim.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
    AND (bim.active_ind= Outerjoin(1)) )
   JOIN (p3
   WHERE (p3.person_id= Outerjoin(bim.updt_id)) )
  ORDER BY m.item_master_id, oii.updt_dt_tm DESC, bim.updt_dt_tm DESC
  HEAD m.item_master_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_item_master_id = m.item_master_id,
   m_rec->qual[m_rec->l_cnt].s_create_dt = format(m.create_dt_tm,"MM/DD/YY;;q"), m_rec->qual[m_rec->
   l_cnt].s_updt_cnt = trim(cnvtstring(m.updt_cnt,20,0),3), m_rec->qual[m_rec->l_cnt].s_last_updt_dt
    = format(m.updt_dt_tm,"MM/DD/YY;;q"),
   m_rec->qual[m_rec->l_cnt].s_updt_user = trim(p1.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].
   s_item_type = trim(uar_get_code_display(m.type_cd),3), m_rec->qual[m_rec->l_cnt].s_item_sys_nbr =
   trim(m.sys_item_nbr,3),
   m_rec->qual[m_rec->l_cnt].s_item_nbr = trim(m.stock_nbr,3), m_rec->qual[m_rec->l_cnt].
   s_item_short_desc = trim(m.short_desc,3), m_rec->qual[m_rec->l_cnt].s_item_desc = trim(m
    .description,3),
   m_rec->qual[m_rec->l_cnt].s_item_chrg_ind = trim(cnvtstring(id.chargeable_ind,20,0),3), m_rec->
   qual[m_rec->l_cnt].s_item_cdm = trim(oii.value,3), m_rec->qual[m_rec->l_cnt].s_price_tool_cdm =
   trim(bim.key6,3)
   IF (trim(cnvtupper(oii.value),3)=trim(cnvtupper(bim.key6),3))
    m_rec->qual[m_rec->l_cnt].s_cdm_match = "Match"
   ELSE
    m_rec->qual[m_rec->l_cnt].s_cdm_match = "Fail"
   ENDIF
   m_rec->qual[m_rec->l_cnt].s_item_cdm_updt_cnt = trim(cnvtstring(oii.updt_cnt,20,0),3), m_rec->
   qual[m_rec->l_cnt].s_item_cdm_updt_dt = format(oii.updt_dt_tm,"MM/DD/YY;;q"), m_rec->qual[m_rec->
   l_cnt].s_item_cdm_updt_user = trim(p2.name_full_formatted,3),
   m_rec->qual[m_rec->l_cnt].s_price_tool_short_desc = trim(bi.ext_short_desc,3), m_rec->qual[m_rec->
   l_cnt].s_price_tool_desc = trim(bi.ext_description,3), m_rec->qual[m_rec->l_cnt].
   s_price_tool_updt_cnt = trim(cnvtstring(bim.updt_cnt,20,0),3),
   m_rec->qual[m_rec->l_cnt].s_price_tool_updt_dt = format(bim.updt_dt_tm,"MM/DD/YY;;q"), m_rec->
   qual[m_rec->l_cnt].s_price_tool_updt_user = trim(p3.name_full_formatted,3)
  WITH nocounter
 ;end select
 IF (ml_email_ind=0)
  SELECT INTO  $OUTDEV
   create_dt = trim(substring(1,10,m_rec->qual[d.seq].s_create_dt),3), updt_cnt = trim(substring(1,5,
     m_rec->qual[d.seq].s_updt_cnt),3), last_updt = trim(substring(1,10,m_rec->qual[d.seq].
     s_last_updt_dt),3),
   updt_user = trim(substring(1,100,m_rec->qual[d.seq].s_updt_user),3), item_type = trim(substring(1,
     50,m_rec->qual[d.seq].s_item_type),3), item_sys_num = trim(substring(1,20,m_rec->qual[d.seq].
     s_item_sys_nbr),3),
   item_num = trim(substring(1,40,m_rec->qual[d.seq].s_item_nbr),3), item_s_desc = trim(substring(1,
     200,m_rec->qual[d.seq].s_item_short_desc),3), item_desc = trim(substring(1,200,m_rec->qual[d.seq
     ].s_item_desc),3),
   item_chg_ind = trim(substring(1,2,m_rec->qual[d.seq].s_item_chrg_ind),3), item_cdm = trim(
    substring(1,40,m_rec->qual[d.seq].s_item_cdm),3), pricetool_cdm = trim(substring(1,40,m_rec->
     qual[d.seq].s_price_tool_cdm),3),
   cdm_match = trim(substring(1,5,m_rec->qual[d.seq].s_cdm_match),3), item_cdm_updt_cnt = trim(
    substring(1,5,m_rec->qual[d.seq].s_item_cdm_updt_cnt),3), item_cdm_updt = trim(substring(1,10,
     m_rec->qual[d.seq].s_item_cdm_updt_dt),3),
   item_cdm_updt_user = trim(substring(1,100,m_rec->qual[d.seq].s_item_cdm_updt_user),3),
   pricetool_sdecs = trim(substring(1,200,m_rec->qual[d.seq].s_price_tool_short_desc),3),
   pricetool_decs = trim(substring(1,200,m_rec->qual[d.seq].s_price_tool_desc),3),
   pricetool_updt_cnt = trim(substring(1,5,m_rec->qual[d.seq].s_price_tool_updt_cnt),3),
   pricetool_updt = trim(substring(1,10,m_rec->qual[d.seq].s_price_tool_updt_dt),3),
   pricetool_updt_user = trim(substring(1,100,m_rec->qual[d.seq].s_price_tool_updt_user),3)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   PLAN (d
    WHERE parser(ms_chrg_parser)
     AND parser(ms_cdm_mismatch_parser))
   WITH nocounter, heading, maxrow = 1,
    formfeed = none, format, separator = " "
  ;end select
 ELSE
  SET frec->file_name = concat("bhs_rpt_item_master_cdm_",trim(format(cnvtdatetime(sysdate),
     "MMDDYYYY;;q"),3),".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat('"CREATE_DT"',",",'"UPDT_CNT"',",",'"LAST_UPDT"',
   ",",'"UPDT_USER"',",",'"ITEM_TYPE"',",",
   '"ITEM_SYS_NUM"',",",'"ITEM_NUM"',",",'"ITEM_S_DESC"',
   ",",'"ITEM_DESC"',",",'"ITEM_CHG_IND"',",",
   '"ITEM_CDM"',",",'"PRICETOOL_CDM"',",",'"CDM_MATCH"',
   ",",'"ITEM_CDM_UPDT_CNT"',",",'"ITEM_CDM_UPDT"',",",
   '"ITEM_CDM_UPDT_USER"',",",'"PRICETOOL_SDECS"',",",'"PRICETOOL_DECS"',
   ",",'"PRICETOOL_UPDT_CNT"',",",'"PRICETOOL_UPDT"',",",
   '"PRICETOOL_UPDT_USER"',char(13),char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx1 = 1 TO m_rec->l_cnt)
    IF (( $L_CHRG_ONLY=1))
     IF ((m_rec->qual[ml_idx1].s_item_chrg_ind="1"))
      IF (( $L_CDM_MISMATCH=1))
       IF ((m_rec->qual[ml_idx1].s_cdm_match="Fail"))
        SET frec->file_buf = concat('"',trim(m_rec->qual[ml_idx1].s_create_dt,3),'","',trim(m_rec->
          qual[ml_idx1].s_updt_cnt,3),'","',
         trim(m_rec->qual[ml_idx1].s_last_updt_dt,3),'","',trim(m_rec->qual[ml_idx1].s_updt_user,3),
         '","',trim(m_rec->qual[ml_idx1].s_item_type,3),
         '","',trim(m_rec->qual[ml_idx1].s_item_sys_nbr,3),'","',trim(m_rec->qual[ml_idx1].s_item_nbr,
          3),'","',
         trim(m_rec->qual[ml_idx1].s_item_short_desc,3),'","',trim(m_rec->qual[ml_idx1].s_item_desc,3
          ),'","',trim(m_rec->qual[ml_idx1].s_item_chrg_ind,3),
         '","',trim(m_rec->qual[ml_idx1].s_item_cdm,3),'","',trim(m_rec->qual[ml_idx1].
          s_price_tool_cdm,3),'","',
         trim(m_rec->qual[ml_idx1].s_cdm_match,3),'","',trim(m_rec->qual[ml_idx1].s_item_cdm_updt_cnt,
          3),'","',trim(m_rec->qual[ml_idx1].s_item_cdm_updt_dt,3),
         '","',trim(m_rec->qual[ml_idx1].s_item_cdm_updt_user,3),'","',trim(m_rec->qual[ml_idx1].
          s_price_tool_short_desc,3),'","',
         trim(m_rec->qual[ml_idx1].s_price_tool_desc,3),'","',trim(m_rec->qual[ml_idx1].
          s_price_tool_updt_cnt,3),'","',trim(m_rec->qual[ml_idx1].s_price_tool_updt_dt,3),
         '","',trim(m_rec->qual[ml_idx1].s_price_tool_updt_user,3),'"',char(13),char(10))
        SET stat = cclio("WRITE",frec)
       ENDIF
      ELSE
       SET frec->file_buf = concat('"',trim(m_rec->qual[ml_idx1].s_create_dt,3),'","',trim(m_rec->
         qual[ml_idx1].s_updt_cnt,3),'","',
        trim(m_rec->qual[ml_idx1].s_last_updt_dt,3),'","',trim(m_rec->qual[ml_idx1].s_updt_user,3),
        '","',trim(m_rec->qual[ml_idx1].s_item_type,3),
        '","',trim(m_rec->qual[ml_idx1].s_item_sys_nbr,3),'","',trim(m_rec->qual[ml_idx1].s_item_nbr,
         3),'","',
        trim(m_rec->qual[ml_idx1].s_item_short_desc,3),'","',trim(m_rec->qual[ml_idx1].s_item_desc,3),
        '","',trim(m_rec->qual[ml_idx1].s_item_chrg_ind,3),
        '","',trim(m_rec->qual[ml_idx1].s_item_cdm,3),'","',trim(m_rec->qual[ml_idx1].
         s_price_tool_cdm,3),'","',
        trim(m_rec->qual[ml_idx1].s_cdm_match,3),'","',trim(m_rec->qual[ml_idx1].s_item_cdm_updt_cnt,
         3),'","',trim(m_rec->qual[ml_idx1].s_item_cdm_updt_dt,3),
        '","',trim(m_rec->qual[ml_idx1].s_item_cdm_updt_user,3),'","',trim(m_rec->qual[ml_idx1].
         s_price_tool_short_desc,3),'","',
        trim(m_rec->qual[ml_idx1].s_price_tool_desc,3),'","',trim(m_rec->qual[ml_idx1].
         s_price_tool_updt_cnt,3),'","',trim(m_rec->qual[ml_idx1].s_price_tool_updt_dt,3),
        '","',trim(m_rec->qual[ml_idx1].s_price_tool_updt_user,3),'"',char(13),char(10))
       SET stat = cclio("WRITE",frec)
      ENDIF
     ENDIF
    ELSE
     IF (( $L_CDM_MISMATCH=1))
      IF ((m_rec->qual[ml_idx1].s_cdm_match="Fail"))
       SET frec->file_buf = concat('"',trim(m_rec->qual[ml_idx1].s_create_dt,3),'","',trim(m_rec->
         qual[ml_idx1].s_updt_cnt,3),'","',
        trim(m_rec->qual[ml_idx1].s_last_updt_dt,3),'","',trim(m_rec->qual[ml_idx1].s_updt_user,3),
        '","',trim(m_rec->qual[ml_idx1].s_item_type,3),
        '","',trim(m_rec->qual[ml_idx1].s_item_sys_nbr,3),'","',trim(m_rec->qual[ml_idx1].s_item_nbr,
         3),'","',
        trim(m_rec->qual[ml_idx1].s_item_short_desc,3),'","',trim(m_rec->qual[ml_idx1].s_item_desc,3),
        '","',trim(m_rec->qual[ml_idx1].s_item_chrg_ind,3),
        '","',trim(m_rec->qual[ml_idx1].s_item_cdm,3),'","',trim(m_rec->qual[ml_idx1].
         s_price_tool_cdm,3),'","',
        trim(m_rec->qual[ml_idx1].s_cdm_match,3),'","',trim(m_rec->qual[ml_idx1].s_item_cdm_updt_cnt,
         3),'","',trim(m_rec->qual[ml_idx1].s_item_cdm_updt_dt,3),
        '","',trim(m_rec->qual[ml_idx1].s_item_cdm_updt_user,3),'","',trim(m_rec->qual[ml_idx1].
         s_price_tool_short_desc,3),'","',
        trim(m_rec->qual[ml_idx1].s_price_tool_desc,3),'","',trim(m_rec->qual[ml_idx1].
         s_price_tool_updt_cnt,3),'","',trim(m_rec->qual[ml_idx1].s_price_tool_updt_dt,3),
        '","',trim(m_rec->qual[ml_idx1].s_price_tool_updt_user,3),'"',char(13),char(10))
       SET stat = cclio("WRITE",frec)
      ENDIF
     ELSE
      SET frec->file_buf = concat('"',trim(m_rec->qual[ml_idx1].s_create_dt,3),'","',trim(m_rec->
        qual[ml_idx1].s_updt_cnt,3),'","',
       trim(m_rec->qual[ml_idx1].s_last_updt_dt,3),'","',trim(m_rec->qual[ml_idx1].s_updt_user,3),
       '","',trim(m_rec->qual[ml_idx1].s_item_type,3),
       '","',trim(m_rec->qual[ml_idx1].s_item_sys_nbr,3),'","',trim(m_rec->qual[ml_idx1].s_item_nbr,3
        ),'","',
       trim(m_rec->qual[ml_idx1].s_item_short_desc,3),'","',trim(m_rec->qual[ml_idx1].s_item_desc,3),
       '","',trim(m_rec->qual[ml_idx1].s_item_chrg_ind,3),
       '","',trim(m_rec->qual[ml_idx1].s_item_cdm,3),'","',trim(m_rec->qual[ml_idx1].s_price_tool_cdm,
        3),'","',
       trim(m_rec->qual[ml_idx1].s_cdm_match,3),'","',trim(m_rec->qual[ml_idx1].s_item_cdm_updt_cnt,3
        ),'","',trim(m_rec->qual[ml_idx1].s_item_cdm_updt_dt,3),
       '","',trim(m_rec->qual[ml_idx1].s_item_cdm_updt_user,3),'","',trim(m_rec->qual[ml_idx1].
        s_price_tool_short_desc,3),'","',
       trim(m_rec->qual[ml_idx1].s_price_tool_desc,3),'","',trim(m_rec->qual[ml_idx1].
        s_price_tool_updt_cnt,3),'","',trim(m_rec->qual[ml_idx1].s_price_tool_updt_dt,3),
       '","',trim(m_rec->qual[ml_idx1].s_price_tool_updt_user,3),'"',char(13),char(10))
      SET stat = cclio("WRITE",frec)
     ENDIF
    ENDIF
  ENDFOR
  EXECUTE bhs_ma_email_file
  CALL emailfile(frec->file_name,frec->file_name,concat('"',trim( $S_EMAIL,3),'"'),
   "Item Master CDM compare",1)
  SET stat = cclio("CLOSE",frec)
  SELECT INTO value( $OUTDEV)
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    "{CPI/9}{FONT/4}", row 0, col 0,
    CALL print(build2("PROGRAM:  ",cnvtlower(curprog),"       NODE:  ",curnode)), row + 1, row 3,
    col 0,
    CALL print(concat("Report completed. File was e-mailed to: ",trim( $S_EMAIL)," .")), row + 1,
    row 6, col 0,
    CALL print(build2("Execution Date/Time:",format(cnvtdatetime(curdate,curtime),
      "mm/dd/yyyy hh:mm:ss;;q")))
   WITH nocounter, nullreport, maxcol = 300,
    dio = 08
  ;end select
 ENDIF
#exit_script
END GO
