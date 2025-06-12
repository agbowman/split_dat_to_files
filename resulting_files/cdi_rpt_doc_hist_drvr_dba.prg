CREATE PROGRAM cdi_rpt_doc_hist_drvr:dba
 PROMPT
  "Blob Handle" = ""
  WITH blobhandle
 DECLARE change_desc = vc WITH noconstant("")
 DECLARE change_cnt = i4 WITH noconstant(0)
 DECLARE page_range = vc WITH noconstant("")
 DECLARE doc_version = vc WITH noconstant("")
 DECLARE vers_pos = i4 WITH noconstant(0)
 DECLARE dec_pos = i4 WITH noconstant(0)
 DECLARE handle_len = i4 WITH noconstant(0)
 DECLARE mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE fin_cd = f8 WITH public, noconstant(0.0)
 DECLARE hnam_cd = f8 WITH public, noconstant(0.0)
 DECLARE submit_cd = f8 WITH public, noconstant(0.0)
 DECLARE row_cnt = i4 WITH noconstant(0)
 DECLARE blob_handle = vc WITH noconstant("")
 DECLARE batch_name = vc WITH noconstant("")
 DECLARE temp_blob_handle = vc WITH noconstant("")
 DECLARE temp_ext_batch_id = i4 WITH noconstant(0)
 DECLARE temp_create_dt_tm = dq8 WITH noconstant(cnvtdatetime(cnvtdate(00000000),cnvtint(0)))
 DECLARE temp_end_dt_tm = dq8 WITH noconstant(cnvtdatetime(cnvtdate(00000000),cnvtint(0)))
 DECLARE max_create_dt_tm = dq8 WITH noconstant(cnvtdatetime(cnvtdate(00000000),cnvtint(0)))
 DECLARE mrnpa_cd = f8 WITH public, noconstant(0.0)
 DECLARE alias_cnt = i4 WITH noconstant(0)
 DECLARE par_alias_cnt = i4 WITH noconstant(0)
 DECLARE translog_id_cnt = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE num2 = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE k = i4 WITH noconstant(0)
 DECLARE l = i4 WITH noconstant(0)
 DECLARE acalias_cnt = i4 WITH noconstant(0)
 DECLARE tmp_enc = f8 WITH public, noconstant(0.0)
 DECLARE aliasidx = i4 WITH noconstant(- (1))
 DECLARE tmpidx = i4 WITH noconstant(0)
 DECLARE baddalias = i2 WITH noconstant(0)
 DECLARE tmp_aliastypecd = f8 WITH public, noconstant(0.0)
 DECLARE tmp_aliastypecodeset = f8 WITH public, noconstant(0.0)
 DECLARE tmp_aliasvalue = vc WITH public, noconstant("")
 SET stat = uar_get_meaning_by_codeset(319,"MRN",1,mrn_cd)
 SET stat = uar_get_meaning_by_codeset(319,"FIN NBR",1,fin_cd)
 SET stat = uar_get_meaning_by_codeset(257571,"HNAM",1,hnam_cd)
 SET stat = uar_get_meaning_by_codeset(257572,"SUBMIT",1,submit_cd)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrnpa_cd)
 SET row_cnt = 0
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD tmp_aliases(
   1 parent_aliases[*]
     2 alias_name = vc
     2 alias_value = vc
     2 codeset = i4
     2 codeval = f8
 )
 RECORD tmp_cdi_translog(
   1 translog_ids[*]
     2 id = f8
 )
 RECORD tmp_acfields(
   1 aliases[*]
     2 alias_type_codeset = f8
     2 alias_type_cd = f8
 )
 SET stat = alterlist(tmp_cdi_translog->translog_ids,20)
 SELECT INTO "nl:"
  c.blob_handle
  FROM cdi_trans_log c
  PLAN (c
   WHERE (c.blob_handle= $BLOBHANDLE))
  ORDER BY c.blob_handle DESC
  HEAD c.blob_handle
   temp_blob_handle = c.blob_handle, blob_handle = replace(c.blob_handle,"#","    Version "),
   batch_name = c.batch_name
  DETAIL
   translog_id_cnt += 1
   IF (mod(translog_id_cnt,20)=1
    AND translog_id_cnt != 1)
    stat = alterlist(tmp_cdi_translog->translog_ids,(translog_id_cnt+ 19))
   ENDIF
   temp_ext_batch_id = maxval(temp_ext_batch_id,c.external_batch_ident), max_create_dt_tm = maxval(
    max_create_dt_tm,c.create_dt_tm), tmp_cdi_translog->translog_ids[translog_id_cnt].id = c
   .cdi_trans_log_id
  WITH nocounter
 ;end select
 SET temp_end_dt_tm = cnvtdatetime((cnvtdate(max_create_dt_tm)+ 1),cnvttime(max_create_dt_tm))
 SET temp_create_dt_tm = cnvtdatetime((cnvtdate(max_create_dt_tm) - 1),cnvttime(max_create_dt_tm))
 CALL echo(temp_blob_handle)
 CALL echo(temp_ext_batch_id)
 CALL echo(temp_create_dt_tm)
 CALL echo(temp_end_dt_tm)
 CALL echo(blob_handle)
 CALL echo(batch_name)
 SELECT INTO "nl:"
  caml.startdatetime, caml.enddatetime, caml.modulename,
  caml.username
  FROM cdi_batch_summary cbs,
   cdi_ac_batchmodule cab,
   cdi_ac_module_launch caml
  PLAN (cbs
   WHERE cbs.external_batch_ident=temp_ext_batch_id
    AND cbs.create_dt_tm > cnvtdatetime(temp_create_dt_tm)
    AND cbs.create_dt_tm < cnvtdatetime(temp_end_dt_tm)
    AND cbs.cdi_ac_batch_id > 0)
   JOIN (cab
   WHERE cbs.cdi_ac_batch_id=cab.cdi_ac_batch_id)
   JOIN (caml
   WHERE cab.modulelaunchid=caml.modulelaunchid
    AND "Batch Manager" != caml.modulename)
  ORDER BY cbs.external_batch_ident, caml.startdatetime
  HEAD cbs.external_batch_ident
   stat = alterlist(batch_lyt->batch_details,20)
  DETAIL
   row_cnt += 1
   IF (mod(row_cnt,20)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 19))
   ENDIF
   batch_lyt->batch_details[row_cnt].blob_handle = blob_handle, batch_lyt->batch_details[row_cnt].
   batch_name = batch_name, batch_lyt->batch_details[row_cnt].ac_ind = 1,
   batch_lyt->batch_details[row_cnt].module_name = caml.modulename, batch_lyt->batch_details[row_cnt]
   .ascent_user = caml.username, batch_lyt->batch_details[row_cnt].ac_start_dt_tm = cab.startdatetime,
   batch_lyt->batch_details[row_cnt].ac_end_dt_tm = cab.enddatetime, batch_lyt->batch_details[row_cnt
   ].action_dt_tm = cab.startdatetime, stat = alterlist(batch_lyt->batch_details[row_cnt].
    change_description,1),
   stat = alterlist(batch_lyt->batch_details[row_cnt].parent_aliases,1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET stat = alterlist(batch_lyt->batch_details,20)
 ENDIF
 SET stat = alterlist(tmp_acfields->aliases,20)
 SELECT INTO "nl:"
  f.alias_type_codeset, f.alias_type_cd
  FROM cdi_ac_field f
  WHERE " "=f.doc_class_name
   AND 1=f.auto_search_ind
  DETAIL
   acalias_cnt += 1
   IF (mod(acalias_cnt,20)=1
    AND acalias_cnt != 1)
    stat = alterlist(tmp_acfields->aliases,(acalias_cnt+ 19))
   ENDIF
   tmp_acfields->aliases[acalias_cnt].alias_type_codeset = f.alias_type_codeset, tmp_acfields->
   aliases[acalias_cnt].alias_type_cd = f.alias_type_cd
  FOOT REPORT
   stat = alterlist(tmp_acfields->aliases,acalias_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.blob_handle, c.cdi_queue_cd, c.action_type_flag,
  c.reason_cd, c.perf_prsnl_id, c.action_dt_tm,
  c.batch_name, c.patient_name, c.financial_nbr,
  c.mrn, c.encntr_id, c.person_id,
  c.ax_appid, c.ax_docid, c.blob_type_flag,
  c.blob_ref_id, c.page_cnt, c.external_batch_ident,
  c.create_dt_tm, p.name_full_formatted, dm.flag_value,
  dm.definition, dm2.definition, dm2.flag_value,
  c.cdi_trans_log_id, d.cdi_trans_mod_detail_id, d.action_sequence,
  d.action_type_flag, d.start_page, d.end_page,
  d.position, c.parent_entity_id, c.parent_entity_name,
  c.parent_entity_alias, ce.encntr_id, ce.person_id,
  p2.name_full_formatted, br.parent_entity_id, br.parent_entity_name,
  p3.name_full_formatted, p4.person_id, p4.name_full_formatted,
  c.document_type_alias, c.subject, der.parent_entity_name,
  der.parent_entity_id
  FROM cdi_trans_log c,
   person p,
   dm_flags_all dm,
   dm_flags_all dm2,
   cdi_trans_mod_detail d,
   clinical_event ce,
   person p2,
   blob_reference br,
   person p3,
   encounter e,
   person p4,
   clinical_event ce3,
   cdi_doc_entity_reltn der
  PLAN (c
   WHERE expand(num,1,value(size(tmp_cdi_translog->translog_ids,5)),c.cdi_trans_log_id,
    tmp_cdi_translog->translog_ids[num].id)
    AND c.cdi_trans_log_id > 0)
   JOIN (p
   WHERE c.perf_prsnl_id=p.person_id)
   JOIN (dm
   WHERE c.action_type_flag=dm.flag_value
    AND dm.table_name="CDI_TRANS_LOG"
    AND dm.column_name="ACTION_TYPE_FLAG")
   JOIN (dm2
   WHERE c.blob_type_flag=dm2.flag_value
    AND dm2.table_name="CDI_TRANS_LOG"
    AND dm2.column_name="BLOB_TYPE_FLAG")
   JOIN (d
   WHERE (d.cdi_trans_log_id= Outerjoin(c.cdi_trans_log_id)) )
   JOIN (ce
   WHERE (ce.event_id= Outerjoin(c.event_id)) )
   JOIN (p2
   WHERE (p2.person_id= Outerjoin(ce.person_id)) )
   JOIN (br
   WHERE (br.blob_ref_id= Outerjoin(c.blob_ref_id)) )
   JOIN (p3
   WHERE (p3.person_id= Outerjoin(br.parent_entity_id)) )
   JOIN (e
   WHERE (e.encntr_id= Outerjoin(br.parent_entity_id)) )
   JOIN (p4
   WHERE (p4.person_id= Outerjoin(e.person_id)) )
   JOIN (ce3
   WHERE (ce3.event_id= Outerjoin(ce.parent_event_id)) )
   JOIN (der
   WHERE (der.cdi_pending_document_id= Outerjoin(c.cdi_pending_document_id)) )
  ORDER BY c.blob_handle, c.cdi_trans_log_id, c.action_dt_tm,
   d.cdi_trans_mod_detail_id, ce3.clinical_event_id DESC
  HEAD c.cdi_trans_log_id
   row_cnt += 1
   IF (mod(row_cnt,20)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 19))
   ENDIF
   batch_lyt->batch_details[row_cnt].blob_handle = replace(c.blob_handle,"#","    Version "),
   vers_pos = findstring("#",c.blob_handle), dec_pos = findstring(".",c.blob_handle,vers_pos)
   IF (vers_pos > 0)
    handle_len = size(c.blob_handle,1), doc_version = substring((vers_pos+ 1),((dec_pos - 1) -
     vers_pos),c.blob_handle), batch_lyt->batch_details[row_cnt].version = concat("VERSION ",
     doc_version),
    batch_lyt->batch_details[row_cnt].version_nbr = cnvtreal(doc_version)
   ELSE
    batch_lyt->batch_details[row_cnt].version = ""
   ENDIF
   batch_lyt->batch_details[row_cnt].ac_ind = 0, batch_lyt->batch_details[row_cnt].cdi_queue_cd = c
   .cdi_queue_cd, batch_lyt->batch_details[row_cnt].action_type = dm.definition,
   batch_lyt->batch_details[row_cnt].reason_cd = c.reason_cd
   IF (ce3.event_id > 0)
    batch_lyt->batch_details[row_cnt].result_status_cd = ce3.result_status_cd
   ELSE
    batch_lyt->batch_details[row_cnt].result_status_cd = 0
   ENDIF
   batch_lyt->batch_details[row_cnt].perf_prsnl_id = c.perf_prsnl_id, batch_lyt->batch_details[
   row_cnt].perf_prsnl_name = p.name_full_formatted, batch_lyt->batch_details[row_cnt].action_dt_tm
    = c.action_dt_tm,
   batch_lyt->batch_details[row_cnt].trans_log_id = c.cdi_trans_log_id, batch_lyt->batch_details[
   row_cnt].batch_name = c.batch_name, batch_lyt->batch_details[row_cnt].doc_type = c.doc_type,
   batch_lyt->batch_details[row_cnt].doc_type_alias = c.document_type_alias, batch_lyt->
   batch_details[row_cnt].subject = c.subject
   IF (dm2.flag_value=0
    AND ((c.cdi_queue_cd=hnam_cd) OR (dm.definition="Submit"
    AND submit_cd=c.reason_cd)) )
    batch_lyt->batch_details[row_cnt].patient_name = p2.name_full_formatted, batch_lyt->
    batch_details[row_cnt].encntr_id = ce.encntr_id, batch_lyt->batch_details[row_cnt].person_id = ce
    .person_id,
    batch_lyt->batch_details[row_cnt].event_id = ce.event_id
    IF (ce.encntr_id > 0)
     batch_lyt->batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"Enc_1",
      "encounter",""), batch_lyt->batch_details[row_cnt].blob_ref_id = ce.encntr_id
    ELSE
     batch_lyt->batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"Pers_1","person",
      ""), batch_lyt->batch_details[row_cnt].blob_ref_id = ce.person_id
    ENDIF
   ELSEIF (dm2.flag_value=1)
    IF (cnvtupper(br.parent_entity_name)="PERSON")
     batch_lyt->batch_details[row_cnt].patient_name = p3.name_full_formatted, batch_lyt->
     batch_details[row_cnt].encntr_id = c.encntr_id, batch_lyt->batch_details[row_cnt].person_id = br
     .parent_entity_id,
     batch_lyt->batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"PRSN_1","person",
      ""), batch_lyt->batch_details[row_cnt].blob_ref_id = br.parent_entity_id
    ELSEIF (cnvtupper(br.parent_entity_name)="ENCOUNTER")
     batch_lyt->batch_details[row_cnt].patient_name = p4.name_full_formatted, batch_lyt->
     batch_details[row_cnt].encntr_id = br.parent_entity_id, batch_lyt->batch_details[row_cnt].
     person_id = p4.person_id,
     batch_lyt->batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"Enc_2",
      "encounter",""), batch_lyt->batch_details[row_cnt].blob_ref_id = br.parent_entity_id
    ELSE
     batch_lyt->batch_details[row_cnt].patient_name = c.patient_name, batch_lyt->batch_details[
     row_cnt].encntr_id = c.encntr_id, batch_lyt->batch_details[row_cnt].person_id = c.person_id,
     batch_lyt->batch_details[row_cnt].blob_type = c.parent_entity_name, batch_lyt->batch_details[
     row_cnt].blob_ref_id = c.parent_entity_id, batch_lyt->batch_details[row_cnt].parent_entity_alias
      = c.parent_entity_alias
    ENDIF
   ELSE
    batch_lyt->batch_details[row_cnt].patient_name = c.patient_name, batch_lyt->batch_details[row_cnt
    ].encntr_id = c.encntr_id, batch_lyt->batch_details[row_cnt].person_id = c.person_id
    IF (cnvtupper(der.parent_entity_name)="ACCESSION")
     batch_lyt->batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"Acc_1",
      "accession",""), batch_lyt->batch_details[row_cnt].blob_ref_id = der.parent_entity_id,
     batch_lyt->batch_details[row_cnt].parent_entity_alias = der.parent_entity_alias
    ELSEIF (c.encntr_id > 0)
     batch_lyt->batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"Enc_3",
      "encounter",""), batch_lyt->batch_details[row_cnt].blob_ref_id = c.encntr_id, batch_lyt->
     batch_details[row_cnt].parent_entity_alias = c.parent_entity_alias
    ELSEIF (c.person_id > 0)
     batch_lyt->batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"PRSN_2","person",
      ""), batch_lyt->batch_details[row_cnt].blob_ref_id = c.person_id, batch_lyt->batch_details[
     row_cnt].parent_entity_alias = c.parent_entity_alias
    ELSE
     batch_lyt->batch_details[row_cnt].blob_type = c.parent_entity_name, batch_lyt->batch_details[
     row_cnt].blob_ref_id = c.parent_entity_id, batch_lyt->batch_details[row_cnt].parent_entity_alias
      = c.parent_entity_alias
    ENDIF
   ENDIF
   batch_lyt->batch_details[row_cnt].ax_appid = c.ax_appid, batch_lyt->batch_details[row_cnt].
   ax_docid = c.ax_docid, batch_lyt->batch_details[row_cnt].page_cnt = c.page_cnt,
   batch_lyt->batch_details[row_cnt].external_batch_ident = c.external_batch_ident
   IF (datetimecmp(cnvtdatetime(c.create_dt_tm),cnvtdatetime("01-JAN-1900"))=0)
    batch_lyt->batch_details[row_cnt].create_dt_tm = 0.0
   ELSE
    batch_lyt->batch_details[row_cnt].create_dt_tm = c.create_dt_tm
   ENDIF
   change_cnt = 0, stat = alterlist(batch_lyt->batch_details[row_cnt].change_description,1),
   batch_lyt->batch_details[row_cnt].change_description[change_cnt].change = "",
   stat = alterlist(batch_lyt->batch_details[row_cnt].parent_aliases,ceil((cnvtreal(acalias_cnt)/ 2))
    ), par_alias_cnt = ceil((cnvtint(acalias_cnt)/ 2))
   FOR (l = 1 TO acalias_cnt)
     j = mod((l - 1),2), k = (floor((cnvtreal((l - 1))/ 2))+ 1)
     IF (j=1)
      batch_lyt->batch_details[row_cnt].parent_aliases[k].name_2 = uar_get_code_display(tmp_acfields
       ->aliases[l].alias_type_cd), batch_lyt->batch_details[row_cnt].parent_aliases[k].codeval_2 =
      tmp_acfields->aliases[l].alias_type_cd
     ELSE
      batch_lyt->batch_details[row_cnt].parent_aliases[k].name_1 = uar_get_code_display(tmp_acfields
       ->aliases[l].alias_type_cd), batch_lyt->batch_details[row_cnt].parent_aliases[k].codeval_1 =
      tmp_acfields->aliases[l].alias_type_cd
     ENDIF
   ENDFOR
  HEAD d.cdi_trans_mod_detail_id
   change_desc = " "
   IF (d.start_page=d.end_page)
    page_range = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_single_page","Page %1","i",d
     .start_page)
   ELSE
    page_range = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_mult_pages","Pages %1 - %2","ii",
     d.start_page,
     d.end_page)
   ENDIF
   IF (d.action_type_flag=1)
    change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_1","%1 rotated","s",nullterm(
      page_range))
   ENDIF
   IF (d.action_type_flag=2)
    change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_2","%1 deleted","s",nullterm(
      page_range))
   ENDIF
   IF (d.action_type_flag=3)
    change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_3","%1 added","s",nullterm(
      page_range))
   ENDIF
   IF (d.action_type_flag=4)
    IF (d.start_page=d.end_page)
     change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_4a","%1 moved to Page %2","si",
      nullterm(page_range),
      d.position)
    ELSE
     change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_4b",
      "%1 moved to Pages %2 - %3","sii",nullterm(page_range),
      d.position,(d.position+ (d.end_page - d.start_page)))
    ENDIF
   ENDIF
   IF (d.action_type_flag=5)
    change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_5",
     "%1 cut to paste selection window","s",nullterm(page_range))
   ENDIF
   IF (d.action_type_flag=6)
    change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_6",
     "%1 copied to paste selection window","s",nullterm(page_range))
   ENDIF
   IF (d.action_type_flag=7)
    change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_7",
     "User annotation added or deleted on Page %1","i",d.start_page)
   ENDIF
   IF (d.action_type_flag=8)
    change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_8","Rollback to version %1.","s",
     doc_version)
   ENDIF
   IF (d.action_type_flag=9)
    change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_9",
     "New version added by external system.","")
   ENDIF
   IF (d.action_type_flag=10)
    change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_10","%1 OCR'ed.","s",nullterm(
      page_range))
   ENDIF
   IF (d.action_type_flag=11)
    change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_11","%1 modified text.","s",
     nullterm(page_range))
   ENDIF
   IF (d.action_type_flag=12)
    change_desc = uar_i18nbuildmessage(i18nhandle,"cdi_change_desc_12","%1 checkout resumed.","s",
     nullterm(page_range))
   ENDIF
   IF (change_desc != " ")
    change_cnt += 1, stat = alterlist(batch_lyt->batch_details[row_cnt].change_description,change_cnt
     ), batch_lyt->batch_details[row_cnt].change_description[change_cnt].change = change_desc,
    batch_lyt->batch_details[row_cnt].change_description[change_cnt].action_sequence = d
    .action_sequence
   ELSE
    stat = alterlist(batch_lyt->batch_details[row_cnt].change_description,1)
   ENDIF
  FOOT REPORT
   stat = alterlist(batch_lyt->batch_details,row_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ea.alias
  FROM encntr_alias ea,
   (dummyt d  WITH seq = value(acalias_cnt))
  PLAN (d)
   JOIN (ea
   WHERE (ea.encntr_alias_type_cd=tmp_acfields->aliases[d.seq].alias_type_cd)
    AND expand(num2,1,row_cnt,ea.encntr_id,batch_lyt->batch_details[num2].encntr_id))
  ORDER BY ea.encntr_id, ea.encntr_alias_type_cd
  HEAD ea.encntr_id
   tmp_enc = ea.encntr_id
  HEAD ea.encntr_alias_type_cd
   FOR (i = 1 TO row_cnt)
     IF ((batch_lyt->batch_details[i].encntr_id=ea.encntr_id)
      AND (batch_lyt->batch_details[i].encntr_id > 0)
      AND (((batch_lyt->batch_details[i].event_id > 0)) OR ((batch_lyt->batch_details[i].blob_ref_id
      > 0))) )
      FOR (l = 1 TO par_alias_cnt)
       IF ((batch_lyt->batch_details[i].parent_aliases[l].codeval_2=ea.encntr_alias_type_cd))
        batch_lyt->batch_details[i].parent_aliases[l].value_2 = ea.alias
       ENDIF
       ,
       IF ((batch_lyt->batch_details[i].parent_aliases[l].codeval_1=ea.encntr_alias_type_cd))
        batch_lyt->batch_details[i].parent_aliases[l].value_1 = ea.alias
       ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pa.alias
  FROM person_alias pa,
   (dummyt d  WITH seq = value(acalias_cnt))
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_alias_type_cd=tmp_acfields->aliases[d.seq].alias_type_cd)
    AND expand(num2,1,row_cnt,pa.person_id,batch_lyt->batch_details[num2].person_id))
  ORDER BY pa.person_id, pa.person_alias_type_cd
  HEAD pa.person_id
   tmp_enc = pa.person_id
  HEAD pa.person_alias_type_cd
   FOR (i = 1 TO row_cnt)
     IF ((batch_lyt->batch_details[i].person_id=pa.person_id)
      AND (batch_lyt->batch_details[i].person_id > 0)
      AND (((batch_lyt->batch_details[i].event_id > 0)) OR ((batch_lyt->batch_details[i].blob_ref_id
      > 0))) )
      FOR (l = 1 TO par_alias_cnt)
       IF ((batch_lyt->batch_details[i].parent_aliases[l].codeval_2=pa.person_alias_type_cd))
        batch_lyt->batch_details[i].parent_aliases[l].value_2 = pa.alias
       ENDIF
       ,
       IF ((batch_lyt->batch_details[i].parent_aliases[l].codeval_1=pa.person_alias_type_cd))
        batch_lyt->batch_details[i].parent_aliases[l].value_1 = pa.alias
       ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.cdi_trans_log_id, c.cdi_pending_document_id, m.cdi_doc_dyn_metadata_id,
  m.alias_type_cd, m.alias_type_codeset, m.field_value
  FROM cdi_trans_log c,
   cdi_doc_dyn_metadata m
  PLAN (c
   WHERE expand(num,1,row_cnt,c.cdi_trans_log_id,batch_lyt->batch_details[num].trans_log_id,
    0,batch_lyt->batch_details[num].ac_ind))
   JOIN (m
   WHERE (m.cdi_pending_document_id= Outerjoin(c.cdi_pending_document_id))
    AND expand(num,1,acalias_cnt,m.alias_type_cd,tmp_acfields->aliases[num].alias_type_cd))
  ORDER BY c.cdi_trans_log_id, m.cdi_doc_dyn_metadata_id
  HEAD m.cdi_doc_dyn_metadata_id
   FOR (i = 1 TO row_cnt)
     baddalias = 0, tmp_aliastypecd = 0.0, tmp_aliastypecodeset = 0.0,
     tmp_aliasvalue = ""
     IF ((batch_lyt->batch_details[i].trans_log_id=c.cdi_trans_log_id)
      AND c.event_id < 1
      AND c.blob_ref_id < 1)
      IF (size(trim(m.field_value),1) > 0)
       baddalias = 1, tmp_aliastypecd = m.alias_type_cd, tmp_aliastypecodeset = m.alias_type_codeset,
       tmp_aliasvalue = m.field_value
      ELSE
       IF (cnvtint(m.alias_type_codeset)=319)
        IF (m.alias_type_cd=mrn_cd)
         baddalias = 1, tmp_aliastypecd = m.alias_type_cd, tmp_aliasvalue = c.mrn
        ELSE
         IF (m.alias_type_cd=fin_cd)
          baddalias = 1, tmp_aliastypecd = m.alias_type_cd, tmp_aliasvalue = c.financial_nbr
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      IF (baddalias=1)
       FOR (l = 1 TO par_alias_cnt)
        IF ((batch_lyt->batch_details[i].parent_aliases[l].codeval_2=tmp_aliastypecd))
         batch_lyt->batch_details[i].parent_aliases[l].value_2 = tmp_aliasvalue
        ENDIF
        ,
        IF ((batch_lyt->batch_details[i].parent_aliases[l].codeval_1=tmp_aliastypecd))
         batch_lyt->batch_details[i].parent_aliases[l].value_1 = tmp_aliasvalue
        ENDIF
       ENDFOR
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
END GO
