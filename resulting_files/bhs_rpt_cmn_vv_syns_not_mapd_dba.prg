CREATE PROGRAM bhs_rpt_cmn_vv_syns_not_mapd:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 list[*]
     2 f_catalog_cd = f8
     2 c_primary_mnemonic = c100
     2 f_synonym_id = f8
     2 f_mnemonic_type_cd = f8
     2 c_mnem_type = c100
     2 c_mnemonic = c100
     2 n_active_ind = i2
     2 c_primary_cki = c255
     2 c_synonym_cki = c255
     2 n_hide_flag = i2
     2 s_vv_facility = vc
     2 c_virtual_view = c100
     2 c_updt_dt_tm = c20
 )
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = h
   1 file_offset = h
   1 file_dir = h
 )
 IF ( NOT (validate(reply->status_data.status,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE mf_pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE mf_dispdrug_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"DISPDRUG"))
 DECLARE mf_generictop_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICTOP"))
 DECLARE mf_tradetop_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADETOP"))
 DECLARE mf_primary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE ms_beg_dt_tm = vc WITH protect
 DECLARE ms_end_dt_tm = vc WITH protect
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_facilities_temp = vc WITH protect, noconstant(" ")
 DECLARE ml_loop1 = i4 WITH protect, noconstant(0)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_outstring = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_in = vc WITH protect, noconstant(" ")
 DECLARE md_filename_out = vc WITH protect, noconstant(" ")
 IF (validate(request->batch_selection,"999") != "999")
  SET ms_beg_dt_tm = format(datetimefind(cnvtlookbehind("1 D",datetimefind(cnvtdatetime(curdate,0),
      "M","B","B")),"M","B","B"),"DD-MMM-YYYY HH:mm:ss;;D")
  SET ms_end_dt_tm = format(datetimefind(cnvtdatetime(curdate,0),"M","B","B"),
   "DD-MMM-YYYY HH:mm:ss;;D")
 ELSE
  IF (substring(1,1,reflect(parameter(2,0))) > " ")
   SET ms_beg_dt_tm = concat( $S_BEG_DT," 00:00:00")
  ELSE
   SET ms_beg_dt_tm = format(datetimefind(cnvtlookbehind("1 D",datetimefind(cnvtdatetime(curdate,0),
       "M","B","B")),"M","B","B"),"DD-MMM-YYYY HH:mm:ss;;D")
  ENDIF
  IF (substring(1,1,reflect(parameter(3,0))) > " ")
   SET ms_end_dt_tm = format(cnvtlookahead("1 D",cnvtdatetime(concat( $S_END_DT," 00:00:00"))),
    "DD-MMM-YYYY HH:mm:ss;;D")
  ELSE
   SET ms_end_dt_tm = format(datetimefind(cnvtdatetime(curdate,0),"M","B","B"),
    "DD-MMM-YYYY HH:mm:ss;;D")
  ENDIF
 ENDIF
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_address_list =  $OUTDEV
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtdatetime(sysdate),
     "MMDDYYYYHHMMSS;;D"),".csv"))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SELECT INTO "nl:"
  vv_facility =
  IF (ofr.facility_cd=0.00) "All Facilities"
  ELSE trim(uar_get_code_display(ofr.facility_cd),3)
  ENDIF
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   ocs_facility_r ofr
  PLAN (oc
   WHERE oc.catalog_type_cd=mf_pharmacy_cd
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.updt_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
    AND ocs.updt_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND ocs.catalog_type_cd=mf_pharmacy_cd
    AND ocs.mnemonic_type_cd IN (mf_dispdrug_cd, mf_generictop_cd, mf_tradetop_cd, mf_primary_cd)
    AND ocs.cki != oc.cki)
   JOIN (ofr
   WHERE ofr.synonym_id=ocs.synonym_id)
  ORDER BY oc.primary_mnemonic, ocs.mnemonic_key_cap, ocs.synonym_id,
   vv_facility
  HEAD REPORT
   ml_cnt = 0
  HEAD oc.primary_mnemonic
   null
  HEAD ocs.mnemonic_key_cap
   null
  HEAD ocs.synonym_id
   ml_cnt += 1, m_rec->l_cnt = ml_cnt, stat = alterlist(m_rec->list,ml_cnt),
   m_rec->list[ml_cnt].f_catalog_cd = ocs.catalog_cd, m_rec->list[ml_cnt].c_primary_mnemonic = oc
   .primary_mnemonic, m_rec->list[ml_cnt].f_synonym_id = ocs.synonym_id,
   m_rec->list[ml_cnt].f_mnemonic_type_cd = ocs.mnemonic_type_cd, m_rec->list[ml_cnt].c_mnem_type =
   uar_get_code_display(ocs.mnemonic_type_cd), m_rec->list[ml_cnt].c_mnemonic = ocs.mnemonic,
   m_rec->list[ml_cnt].n_active_ind = ocs.active_ind, m_rec->list[ml_cnt].c_primary_cki = oc.cki,
   m_rec->list[ml_cnt].c_synonym_cki = ocs.cki,
   m_rec->list[ml_cnt].n_hide_flag = ocs.hide_flag, m_rec->list[ml_cnt].c_virtual_view = ocs
   .virtual_view, m_rec->list[ml_cnt].c_updt_dt_tm = format(ocs.updt_dt_tm,"mm/dd/yy HH:mm;;D"),
   ms_facilities_temp = " "
  HEAD vv_facility
   IF (ms_facilities_temp=" ")
    ms_facilities_temp = trim(vv_facility,3)
   ELSE
    ms_facilities_temp = concat(ms_facilities_temp,", ",trim(vv_facility,3))
   ENDIF
  FOOT  vv_facility
   null
  FOOT  ocs.synonym_id
   m_rec->list[ml_cnt].s_vv_facility = ms_facilities_temp
  FOOT  ocs.mnemonic_key_cap
   null
  FOOT  oc.primary_mnemonic
   null
  WITH format, separator = " ", nocounter
 ;end select
 IF (ml_cnt < 1)
  SET ml_cnt = 1
  SET m_rec->l_cnt = ml_cnt
  SET stat = alterlist(m_rec->list,ml_cnt)
  SET m_rec->list[ml_cnt].c_primary_mnemonic = "No synonyms found"
 ENDIF
 IF (mn_email_ind=1)
  SET ms_filename_in = trim(concat(ms_output_dest,".dat"))
  CALL echo(ms_filename_in)
  SET frec->file_name = ms_filename_in
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"catalog_cd"',',"Primary Mnemonic"',',"synonym_id"',
   ',"mnemonic_type_cd"',',"Mnemonic Type"',
   ',"Mnemonic"',',"active_ind"',',"Primary CKI"',',"Synonym CKI"',',"hide_flag"',
   ',"updt_dt_tm"',',"VV_Facility"',char(13),char(10))
  SET stat = cclio("PUTS",frec)
  FOR (ml_loop1 = 1 TO m_rec->l_cnt)
   SET frec->file_buf = concat('"',trim(build(cnvtint(m_rec->list[ml_loop1].f_catalog_cd)),3),'"',
    ',"',trim(m_rec->list[ml_loop1].c_primary_mnemonic,3),
    '"',',"',build(cnvtint(m_rec->list[ml_loop1].f_synonym_id)),'"',',"',
    build(cnvtint(m_rec->list[ml_loop1].f_mnemonic_type_cd)),'"',',"',trim(m_rec->list[ml_loop1].
     c_mnem_type,3),'"',
    ',"',trim(m_rec->list[ml_loop1].c_mnemonic,3),'"',',"',build(m_rec->list[ml_loop1].n_active_ind),
    '"',',"',trim(m_rec->list[ml_loop1].c_primary_cki,3),'"',',"',
    trim(m_rec->list[ml_loop1].c_synonym_cki,3),'"',',"',build(m_rec->list[ml_loop1].n_hide_flag),'"',
    ',"',build(m_rec->list[ml_loop1].c_updt_dt_tm),'"',',"',trim(m_rec->list[ml_loop1].s_vv_facility,
     3),
    '"',char(13),char(10))
   IF ((ml_loop1 < m_rec->l_cnt))
    SET stat = cclio("PUTS",frec)
   ENDIF
  ENDFOR
  SET stat = cclio("WRITE",frec)
  SET stat = cclio("CLOSE",frec)
  SET ms_filename_out = concat("cmn_vv_synonyms_not_mapped_",format(cnvtdatetime(concat( $S_END_DT,
      " 00:00:00")),"MMDDYYYY;;D"),".csv")
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_out,ms_address_list,
   "C, M, and N Synonyms not Mapped to Primary",1)
 ELSE
  SELECT INTO  $OUTDEV
   catalog_cd = m_rec->list[d1.seq].f_catalog_cd, primary_mnemonic = m_rec->list[d1.seq].
   c_primary_mnemonic, synonym_id = m_rec->list[d1.seq].f_synonym_id,
   mnemonic_type_cd = m_rec->list[d1.seq].f_mnemonic_type_cd, mnem_type = m_rec->list[d1.seq].
   c_mnem_type, mnemonic = m_rec->list[d1.seq].c_mnemonic,
   active_ind = m_rec->list[d1.seq].n_active_ind, primary_cki = m_rec->list[d1.seq].c_primary_cki,
   synonym_cki = m_rec->list[d1.seq].c_synonym_cki,
   hide_flag = m_rec->list[d1.seq].n_hide_flag, updt_dt_tm = m_rec->list[d1.seq].c_updt_dt_tm,
   vv_facility = m_rec->list[d1.seq].s_vv_facility
   FROM (dummyt d1  WITH seq = m_rec->l_cnt)
   PLAN (d1)
   ORDER BY d1.seq
   WITH format = variable, format, separator = " ",
    nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->ops_event = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].targetobjectname = ""
END GO
