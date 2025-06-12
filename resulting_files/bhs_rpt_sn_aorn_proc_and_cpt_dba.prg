CREATE PROGRAM bhs_rpt_sn_aorn_proc_and_cpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Surgical_Area" = 0,
  "Surgeon Last Name" = "*",
  "Specialty" = "*",
  "Procedure name" = "*",
  "Procedure code" = "*",
  "Email:" = ""
  WITH outdev, ms_surg_area_cd, ms_prsnl,
  ms_specialty, ms_proc_name, ms_proc_code,
  s_recipients
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 s_surgarea = vc
     2 s_proc_code = vc
     2 s_proc_name = vc
     2 s_order_mnemonic = vc
     2 s_specialty = vc
     2 s_surgeon = vc
     2 f_create_date = f8
     2 s_create_by = vc
     2 f_update_date = f8
     2 s_updated_by = vc
     2 l_total_use = i4
     2 f_last_used = f8
 ) WITH protect
 EXECUTE bhs_ma_email_file
 DECLARE mf_ancillary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"ANCILLARY"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ms_recipients = vc WITH protect, noconstant(trim( $S_RECIPIENTS))
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 DECLARE ms_parse_syn = vc WITH protect, noconstant("")
 DECLARE ms_parse_str = vc WITH protect, noconstant("")
 DECLARE ms_item_list = vc WITH protect, noconstant("")
 SET ms_item_list = reflect(parameter(2,0))
 IF (( $MS_SURG_AREA_CD=999999))
  SET ms_parse_str = "1=1"
 ELSEIF (substring(1,1,ms_item_list)="L")
  SET ms_parse_str = "p.surg_area_cd in ("
  SET ml_cnt = cnvtint(substring(2,(textlen(ms_item_list) - 1),ms_item_list))
  FOR (i = 1 TO ml_cnt)
    SET ms_parse_str = concat(ms_parse_str,cnvtstring(parameter(2,i)),",")
  ENDFOR
  SET ms_parse_str = concat(substring(1,(textlen(ms_parse_str) - 1),ms_parse_str),")")
 ELSE
  SET ms_parse_str = concat("p.surg_area_cd = ",cnvtstring( $MS_SURG_AREA_CD))
 ENDIF
 IF (size(trim( $MS_PROC_CODE,3))=1
  AND trim( $MS_PROC_CODE)=char(42))
  SET ms_parse_syn = concat(
   "o.catalog_cd = outerjoin(p.catalog_cd) and o.mnemonic_type_cd = outerjoin(",trim(cnvtstring(
     mf_ancillary_cd,20),3),') and o.mnemonic in ("0*", "1*")')
 ELSE
  SET ms_parse_syn = concat("o.catalog_cd = p.catalog_cd and o.mnemonic_type_cd = ",trim(cnvtstring(
     mf_ancillary_cd,20),3),' and substring(1,8,o.mnemonic) = "', $MS_PROC_CODE,'"')
 ENDIF
 SELECT DISTINCT INTO "nl:"
  surgarea = uar_get_code_display(p.surg_area_cd), proc_code = substring(1,9,trim(o.mnemonic)),
  procedure_name = o.mnemonic,
  specialty = pg.prsnl_group_name, surgeon = pr.name_full_formatted, create_date = p.create_dt_tm,
  create_by = pr1.name_full_formatted, update_date = p.updt_dt_tm, updated_by = pr2
  .name_full_formatted,
  total_use = p.tot_nbr_cases, last_used = p.last_used_dt_tm
  FROM preference_card p,
   code_value cv,
   order_catalog_synonym o,
   prsnl_group pg,
   prsnl pr,
   prsnl pr1,
   prsnl pr2
  PLAN (p
   WHERE p.active_ind=1
    AND parser(ms_parse_str))
   JOIN (cv
   WHERE cv.code_value=p.catalog_cd
    AND (cnvtupper(cv.description)= $MS_PROC_NAME))
   JOIN (o
   WHERE parser(ms_parse_syn)
    AND o.active_ind=1)
   JOIN (pg
   WHERE (pg.prsnl_group_id= Outerjoin(p.surg_specialty_id))
    AND (pg.prsnl_group_name= $MS_SPECIALTY))
   JOIN (pr
   WHERE (pr.person_id= Outerjoin(p.prsnl_id))
    AND (cnvtupper(pr.name_full_formatted)= $MS_PRSNL))
   JOIN (pr1
   WHERE (pr1.person_id= Outerjoin(p.create_prsnl_id)) )
   JOIN (pr2
   WHERE (pr2.person_id= Outerjoin(p.updt_id)) )
  ORDER BY surgarea, procedure_name, surgeon
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt += 1
   IF (ml_cnt > size(m_rec->qual,5))
    CALL alterlist(m_rec->qual,(ml_cnt+ 20))
   ENDIF
   m_rec->qual[ml_cnt].s_surgarea = uar_get_code_display(p.surg_area_cd), m_rec->qual[ml_cnt].
   s_proc_code = substring(1,9,trim(o.mnemonic)), m_rec->qual[ml_cnt].s_proc_name =
   uar_get_code_description(p.catalog_cd),
   m_rec->qual[ml_cnt].s_order_mnemonic = o.mnemonic, m_rec->qual[ml_cnt].s_specialty = pg
   .prsnl_group_name, m_rec->qual[ml_cnt].s_surgeon = pr.name_full_formatted,
   m_rec->qual[ml_cnt].f_create_date = p.create_dt_tm, m_rec->qual[ml_cnt].s_create_by = pr1
   .name_full_formatted, m_rec->qual[ml_cnt].f_update_date = p.updt_dt_tm,
   m_rec->qual[ml_cnt].s_updated_by = pr2.name_full_formatted, m_rec->qual[ml_cnt].l_total_use = p
   .tot_nbr_cases, m_rec->qual[ml_cnt].f_last_used = p.last_used_dt_tm
  FOOT REPORT
   CALL alterlist(m_rec->qual,ml_cnt), m_rec->l_cnt = ml_cnt
  WITH nocounter, separator = " ", format
 ;end select
 IF (curqual=0)
  GO TO exit_program
 ENDIF
 IF (textlen( $S_RECIPIENTS) > 1)
  SET frec->file_name = build("bhs_rpt_sn_aorn_proc_and_cpt",format(cnvtdatetime(sysdate),
    "YYYYMMDD;;D"),".csv")
  SET frec->file_name = replace(frec->file_name,"/","_",0)
  SET frec->file_name = replace(frec->file_name," ","_",0)
  SET ms_subject = build2("SN AORN PROC CPT ASSOC",trim(format(cnvtdatetime(sysdate),"YYYYMMDD;;D")))
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"Surgarea",','"Proc_Code",','"Procedure_Name",','"Speciaity",',
   '"Surgeon",',
   '"Create_Date",','"Create_By",','"Update_Date",','"Updated_By",','"Total_Use",',
   '"Last_Used",',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_idx = 1 TO m_rec->l_cnt)
   SET frec->file_buf = build('"',trim(m_rec->qual[ml_idx].s_surgarea,3),'","',trim(m_rec->qual[
     ml_idx].s_proc_code,3),'","',
    trim(m_rec->qual[ml_idx].s_proc_name,3),'","',trim(m_rec->qual[ml_idx].s_specialty,3),'","',trim(
     m_rec->qual[ml_idx].s_surgeon,3),
    '","',format(m_rec->qual[ml_idx].f_create_date,"mm/dd/yy;;d"),'","',trim(m_rec->qual[ml_idx].
     s_create_by,3),'","',
    format(m_rec->qual[ml_idx].f_update_date,"mm/dd/yy;;d"),'","',trim(m_rec->qual[ml_idx].
     s_updated_by,3),'","',m_rec->qual[ml_idx].l_total_use,
    '","',format(m_rec->qual[ml_idx].f_last_used,"mm/dd/yy;;d"),'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  CALL emailfile(value(frec->file_name),frec->file_name,concat('"',ms_recipients,'"'),ms_subject,1)
 ELSE
  SELECT DISTINCT INTO value( $OUTDEV)
   surgarea = substring(0,100,m_rec->qual[d.seq].s_surgarea), proc_code = m_rec->qual[d.seq].
   s_proc_code, procedure_name = substring(0,200,m_rec->qual[d.seq].s_order_mnemonic),
   specialty = substring(0,100,m_rec->qual[d.seq].s_specialty), surgeon = substring(0,100,m_rec->
    qual[d.seq].s_surgeon), create_date = format(m_rec->qual[d.seq].f_create_date,"mm/dd/yy;;d"),
   create_by = substring(0,100,m_rec->qual[d.seq].s_create_by), update_date = format(m_rec->qual[d
    .seq].f_update_date,"mm/dd/yy;;d"), updated_by = substring(0,200,m_rec->qual[d.seq].s_updated_by),
   total_use = m_rec->qual[d.seq].l_total_use, last_used = format(m_rec->qual[d.seq].f_last_used,
    "mm/dd/yy;;d")
   FROM (dummyt d  WITH seq = value(size(m_rec->qual,5)))
   PLAN (d)
   WITH nocounter, format, separator = " ",
    time = 20
  ;end select
 ENDIF
#exit_program
 IF (textlen( $S_RECIPIENTS) > 1)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    msg1 = "An email of the detailed report has been sent to:", msg2 = build2("    ", $S_RECIPIENTS),
    CALL print(calcpos(36,18)),
    msg1, row + 2, msg2
   WITH dio = 08
  ;end select
 ENDIF
END GO
