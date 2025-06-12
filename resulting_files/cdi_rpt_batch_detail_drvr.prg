CREATE PROGRAM cdi_rpt_batch_detail_drvr
 DECLARE queue_cd = f8 WITH noconstant(0.0), protect
 DECLARE reason_cd = f8 WITH noconstant(0.0), protect
 DECLARE batch_name = vc WITH noconstant(""), protect
 DECLARE doc_version = vc WITH noconstant("")
 DECLARE vers_pos = i4 WITH noconstant(0)
 DECLARE dec_pos = i4 WITH noconstant(0)
 DECLARE handle_len = i4 WITH noconstant(0)
 DECLARE blob = vc WITH noconstant(""), protect
 DECLARE ext_batch_ident = i4 WITH noconstant(0), protect
 DECLARE interval = dq8 WITH noconstant(cnvtdatetime(cnvtdate(0),cnvttime(1))), protect
 DECLARE start_dt_tm = dq8 WITH noconstant(cnvtdatetime(cnvtdate(0),cnvttime(0))), protect
 DECLARE end_dt_tm = dq8 WITH noconstant(cnvtdatetime(cnvtdate(0),cnvttime(0))), protect
 DECLARE hnam_cd = f8 WITH public, noconstant(0.0)
 DECLARE submit_cd = f8 WITH public, noconstant(0.0)
 DECLARE alias_cnt = i4 WITH noconstant(0)
 DECLARE mrn_cd = f8 WITH noconstant(0.0), protect
 DECLARE fin_cd = f8 WITH noconstant(0.0), protect
 DECLARE dummy_cnt = i4 WITH noconstant(0)
 DECLARE tmp_alias_name = vc WITH noconstant("")
 DECLARE tmp_alias_val = vc WITH noconstant("")
 DECLARE tmp_alias_col = i2 WITH noconstant(0)
 DECLARE alias_rows = i4 WITH noconstant(0)
 DECLARE mill_encntr_id = f8 WITH noconstant(0.0), protect
 DECLARE mill_person_id = f8 WITH noconstant(0.0), protect
 DECLARE mill_accession_id = f8 WITH noconstant(0.0), protect
 DECLARE mill_alias_name = vc WITH noconstant(""), protect
 DECLARE mill_encntr_person_id = f8 WITH noconstant(0.0), protect
 DECLARE row_cnt = i4 WITH noconstant(0)
 SET queue_cd = uar_get_code_by("MEANING",257571,"AUTO_INDEX")
 SET reason_cd = uar_get_code_by("MEANING",257572,"VALIDATE_MAN")
 SET mrn_cd = uar_get_code_by("MEANING",319,"MRN")
 SET fin_cd = uar_get_code_by("MEANING",319,"FIN NBR")
 SET batch_name = build2(parameter(1,0))
 SET stat = uar_get_meaning_by_codeset(257571,"HNAM",1,hnam_cd)
 SET stat = uar_get_meaning_by_codeset(257572,"SUBMIT",1,submit_cd)
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
 RECORD evt_val_aliases(
   1 aliases[*]
     2 alias_type_codeset = vc
     2 alias_type_code = vc
 )
 SELECT
  ctl.blob_handle, ctl.batch_name, ctl.patient_name,
  ctl.financial_nbr, ctl.mrn, ctl.encntr_id,
  ctl.ax_appid, ctl.ax_docid, ctl.action_type_flag,
  ctl.person_id, ctl.action_dt_tm, ctl.page_cnt,
  ctl.cdi_queue_cd, ctl.blob_ref_id, ctl.blob_type_flag,
  ctl.perf_prsnl_id, ctl.external_batch_ident, ctl.create_dt_tm,
  ctl.subject, ctl.document_type_alias, dm.flag_value,
  dm.definition, dm2.definition, p.name_full_formatted,
  alias_name = uar_get_code_display(cnvtreal(i.alias_type_cd)), alias_type_cd = cnvtreal(i
   .alias_type_cd), cdm.field_value,
  i.cdi_trans_log_id, i.cdi_pending_document_id, i.alias_type_cd,
  i.alias_type_codeset, i.parent_entity_name, i.parent_entity_id,
  pending_alias_val = cdm.field_value
  FROM (
   (
   (SELECT
    c.cdi_trans_log_id, c.cdi_pending_document_id, f.alias_type_cd,
    f.alias_type_codeset, der.parent_entity_name, der.parent_entity_alias,
    der.parent_entity_id
    FROM cdi_trans_log c,
     cdi_pending_document d,
     cdi_ac_field f,
     cdi_doc_entity_reltn der
    WHERE c.batch_name_key=cnvtupper(batch_name)
     AND c.active_ind=1
     AND c.event_id=0
     AND c.blob_ref_id=0
     AND (d.cdi_pending_document_id= Outerjoin(c.cdi_pending_document_id))
     AND (d.active_ind= Outerjoin(1))
     AND (f.doc_class_name= Outerjoin(" "))
     AND (f.auto_search_ind= Outerjoin(1))
     AND (der.cdi_pending_document_id= Outerjoin(d.cdi_pending_document_id)) ))
   i),
   cdi_trans_log ctl,
   dm_flags_all dm,
   dm_flags_all dm2,
   person p,
   cdi_doc_dyn_metadata cdm
  PLAN (i)
   JOIN (ctl
   WHERE ctl.cdi_trans_log_id=cnvtreal(i.cdi_trans_log_id)
    AND ((ctl.active_ind+ 0)=1))
   JOIN (dm
   WHERE ctl.action_type_flag=dm.flag_value
    AND dm.table_name="CDI_TRANS_LOG"
    AND dm.column_name="ACTION_TYPE_FLAG")
   JOIN (dm2
   WHERE ctl.blob_type_flag=dm2.flag_value
    AND dm2.table_name="CDI_TRANS_LOG"
    AND dm2.column_name="BLOB_TYPE_FLAG")
   JOIN (cdm
   WHERE (cdm.cdi_pending_document_id= Outerjoin(cnvtreal(i.cdi_pending_document_id)))
    AND (cdm.alias_type_codeset= Outerjoin(cnvtint(i.alias_type_codeset)))
    AND (cdm.alias_type_cd= Outerjoin(cnvtreal(i.alias_type_cd))) )
   JOIN (p
   WHERE (p.person_id= Outerjoin(ctl.perf_prsnl_id)) )
  ORDER BY ctl.batch_name, ctl.patient_name DESC, ctl.blob_handle,
   i.alias_type_cd, ctl.doc_type
  HEAD REPORT
   stat = alterlist(batch_lyt->batch_details,50)
  HEAD ctl.batch_name
   IF (datetimecmp(cnvtdatetime(ctl.create_dt_tm),cnvtdatetime("01-JAN-1900"))=0)
    batch_lyt->create_dt_tm = 0.0
   ELSE
    batch_lyt->create_dt_tm = ctl.create_dt_tm, start_dt_tm = (ctl.create_dt_tm - interval),
    end_dt_tm = (ctl.create_dt_tm+ interval)
   ENDIF
   batch_lyt->batch_name = ctl.batch_name
   IF (ext_batch_ident <= 0)
    ext_batch_ident = ctl.external_batch_ident
   ENDIF
  HEAD ctl.blob_handle
   row_cnt += 1
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 49))
   ENDIF
   alias_cnt = 0, alias_rows = 0, stat = alterlist(batch_lyt->batch_details[row_cnt].parent_aliases,
    10),
   vers_pos = findstring("#",ctl.blob_handle), dec_pos = findstring(".",ctl.blob_handle,vers_pos)
   IF (vers_pos > 0)
    blob = substring(1,(vers_pos - 1),ctl.blob_handle), handle_len = size(ctl.blob_handle,1),
    doc_version = substring((vers_pos+ 1),((dec_pos - 1) - vers_pos),ctl.blob_handle)
    IF (cnvtint(doc_version) > 1)
     batch_lyt->batch_details[row_cnt].blob_handle = concat(blob," Version ",doc_version)
    ELSE
     batch_lyt->batch_details[row_cnt].blob_handle = blob
    ENDIF
   ELSE
    batch_lyt->batch_details[row_cnt].blob_handle = ctl.blob_handle
   ENDIF
   batch_lyt->batch_details[row_cnt].patient_name = ctl.patient_name, batch_lyt->batch_details[
   row_cnt].financial_nbr = ctl.financial_nbr, batch_lyt->batch_details[row_cnt].mrn = ctl.mrn,
   batch_lyt->batch_details[row_cnt].encntr_id = ctl.encntr_id, batch_lyt->batch_details[row_cnt].
   ax_appid = ctl.ax_appid, batch_lyt->batch_details[row_cnt].ax_docid = ctl.ax_docid,
   batch_lyt->batch_details[row_cnt].action_type = dm.definition, batch_lyt->batch_details[row_cnt].
   person_id = ctl.person_id, batch_lyt->batch_details[row_cnt].perf_prsnl_name = p
   .name_full_formatted,
   batch_lyt->batch_details[row_cnt].action_dt_tm = ctl.action_dt_tm, batch_lyt->batch_details[
   row_cnt].page_cnt = ctl.page_cnt, batch_lyt->batch_details[row_cnt].cdi_queue_cd = ctl
   .cdi_queue_cd,
   batch_lyt->batch_details[row_cnt].subject = ctl.subject, batch_lyt->batch_details[row_cnt].
   doc_type_alias = ctl.document_type_alias
   IF (cnvtupper(i.parent_entity_name)="ACCESSION")
    batch_lyt->batch_details[row_cnt].blob_ref_id = cnvtreal(i.parent_entity_id), batch_lyt->
    batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"Acc_1","accession","")
   ELSEIF (ctl.encntr_id > 0)
    batch_lyt->batch_details[row_cnt].blob_ref_id = ctl.encntr_id, batch_lyt->batch_details[row_cnt].
    blob_type = uar_i18nbuildmessage(i18nhandle,"Enc_2","encounter","")
   ELSEIF (ctl.person_id > 0)
    batch_lyt->batch_details[row_cnt].blob_ref_id = ctl.person_id, batch_lyt->batch_details[row_cnt].
    blob_type = uar_i18nbuildmessage(i18nhandle,"Pers_1","person","")
   ELSE
    batch_lyt->batch_details[row_cnt].blob_ref_id = ctl.parent_entity_id, batch_lyt->batch_details[
    row_cnt].blob_type = ctl.parent_entity_name
   ENDIF
   batch_lyt->batch_details[row_cnt].external_batch_ident = ctl.external_batch_ident, batch_lyt->
   batch_details[row_cnt].doc_type = ctl.doc_type
  HEAD alias_type_cd
   IF (queue_cd=ctl.cdi_queue_cd
    AND reason_cd=ctl.reason_cd)
    batch_lyt->ai_nonmatch += 1
   ENDIF
   alias_cnt += 1
   IF (mod(alias_cnt,2)=1)
    alias_rows += 1
   ENDIF
   IF (mod(alias_rows,10)=1
    AND alias_rows != 1)
    stat = alterlist(batch_lyt->batch_details[row_cnt].parent_aliases,(alias_rows+ 9))
   ENDIF
   tmp_alias_name = alias_name, tmp_alias_val = " "
   IF (size(trim(pending_alias_val),1) > 1)
    tmp_alias_val = trim(pending_alias_val)
   ELSE
    IF (alias_type_cd=mrn_cd)
     tmp_alias_val = ctl.mrn
    ELSE
     IF (alias_type_cd=fin_cd)
      tmp_alias_val = ctl.financial_nbr
     ENDIF
    ENDIF
   ENDIF
   tmp_alias_col = mod(alias_cnt,2)
   IF (tmp_alias_col=1)
    batch_lyt->batch_details[row_cnt].parent_aliases[alias_rows].name_1 = tmp_alias_name, batch_lyt->
    batch_details[row_cnt].parent_aliases[alias_rows].value_1 = tmp_alias_val
   ELSE
    batch_lyt->batch_details[row_cnt].parent_aliases[alias_rows].name_2 = tmp_alias_name, batch_lyt->
    batch_details[row_cnt].parent_aliases[alias_rows].value_2 = tmp_alias_val
   ENDIF
  DETAIL
   dummy_cnt += 1
  FOOT  ctl.blob_handle
   stat = alterlist(batch_lyt->batch_details[row_cnt].parent_aliases,alias_rows)
  WITH nocounter
 ;end select
 SELECT
  ctl.blob_handle, ctl.batch_name, ctl.patient_name,
  ctl.financial_nbr, ctl.mrn, ctl.encntr_id,
  ctl.ax_appid, ctl.ax_docid, ctl.action_type_flag,
  ctl.person_id, ctl.action_dt_tm, ctl.page_cnt,
  ctl.cdi_queue_cd, ctl.blob_ref_id, ctl.blob_type_flag,
  ctl.perf_prsnl_id, ctl.external_batch_ident, ctl.create_dt_tm,
  ctl.subject, ctl.document_type_alias, dm.flag_value,
  dm.definition, dm2.definition, p.name_full_formatted,
  alias_name = uar_get_code_display(cnvtreal(i.alias_type_cd)), alias_type_cd = cnvtreal(i
   .alias_type_cd), cdm.field_value,
  i.alias_type_cd, i.cdi_trans_log_id, i.alias_type_codeset,
  i.cdi_pending_document_id, i.mill_alias_name, i.mill_encntr_id,
  i.mill_person_id, i.mill_accession_id, encntr_alias_val = ea.alias,
  person_alias_val = pa.alias
  FROM (
   (
   (SELECT
    c.cdi_trans_log_id, f.alias_type_cd, f.alias_type_codeset,
    c.cdi_pending_document_id, mill_encntr_id = evaluate(br.parent_entity_name,"ENCOUNTER",br
     .parent_entity_id,0.0), mill_person_id = evaluate(br.parent_entity_name,"PERSON",br
     .parent_entity_id,evaluate(br.parent_entity_name,"ENCOUNTER",e.person_id,0.0)),
    mill_accession_id = evaluate(br.parent_entity_name,"ACCESSION",br.parent_entity_id,0.0),
    mill_alias_name = br.parent_entity_name
    FROM cdi_trans_log c,
     blob_reference br,
     encounter e,
     cdi_ac_field f
    WHERE c.batch_name_key=cnvtupper(batch_name)
     AND c.active_ind=1
     AND c.event_id=0
     AND c.blob_ref_id > 0
     AND (f.doc_class_name= Outerjoin(" "))
     AND (f.auto_search_ind= Outerjoin(1))
     AND (br.blob_ref_id= Outerjoin(c.blob_ref_id))
     AND (e.encntr_id= Outerjoin(br.parent_entity_id))
    ORDER BY c.blob_handle))
   i),
   cdi_trans_log ctl,
   dm_flags_all dm,
   dm_flags_all dm2,
   person p,
   cdi_doc_dyn_metadata cdm,
   encntr_alias ea,
   person_alias pa
  PLAN (i)
   JOIN (ctl
   WHERE ctl.cdi_trans_log_id=cnvtreal(i.cdi_trans_log_id)
    AND ctl.active_ind=1)
   JOIN (dm
   WHERE ctl.action_type_flag=dm.flag_value
    AND dm.table_name="CDI_TRANS_LOG"
    AND dm.column_name="ACTION_TYPE_FLAG")
   JOIN (dm2
   WHERE ctl.blob_type_flag=dm2.flag_value
    AND dm2.table_name="CDI_TRANS_LOG"
    AND dm2.column_name="BLOB_TYPE_FLAG")
   JOIN (cdm
   WHERE (cdm.cdi_pending_document_id= Outerjoin(cnvtreal(i.cdi_pending_document_id)))
    AND (cdm.alias_type_codeset= Outerjoin(cnvtint(i.alias_type_codeset)))
    AND (cdm.alias_type_cd= Outerjoin(cnvtreal(i.alias_type_cd))) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(cnvtreal(i.mill_encntr_id)))
    AND (ea.encntr_alias_type_cd= Outerjoin(cnvtreal(i.alias_type_cd))) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(cnvtreal(i.mill_person_id)))
    AND (pa.person_alias_type_cd= Outerjoin(cnvtreal(i.alias_type_cd))) )
   JOIN (p
   WHERE (p.person_id= Outerjoin(ctl.perf_prsnl_id)) )
  ORDER BY ctl.batch_name, ctl.patient_name DESC, ctl.blob_handle,
   i.alias_type_cd, ctl.doc_type
  HEAD REPORT
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 49))
   ELSEIF (row_cnt=0)
    stat = alterlist(batch_lyt->batch_details,50)
   ENDIF
  HEAD ctl.batch_name
   IF (datetimecmp(cnvtdatetime(ctl.create_dt_tm),cnvtdatetime("01-JAN-1900"))=0)
    batch_lyt->create_dt_tm = 0.0
   ELSE
    batch_lyt->create_dt_tm = ctl.create_dt_tm, start_dt_tm = (ctl.create_dt_tm - interval),
    end_dt_tm = (ctl.create_dt_tm+ interval)
   ENDIF
   batch_lyt->batch_name = ctl.batch_name
   IF (ext_batch_ident <= 0)
    ext_batch_ident = ctl.external_batch_ident
   ENDIF
  HEAD ctl.blob_handle
   row_cnt += 1
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 49))
   ENDIF
   alias_cnt = 0, alias_rows = 0, stat = alterlist(batch_lyt->batch_details[row_cnt].parent_aliases,
    10),
   vers_pos = findstring("#",ctl.blob_handle), dec_pos = findstring(".",ctl.blob_handle,vers_pos)
   IF (vers_pos > 0)
    blob = substring(1,(vers_pos - 1),ctl.blob_handle), handle_len = size(ctl.blob_handle,1),
    doc_version = substring((vers_pos+ 1),((dec_pos - 1) - vers_pos),ctl.blob_handle)
    IF (cnvtint(doc_version) > 1)
     batch_lyt->batch_details[row_cnt].blob_handle = concat(blob," Version ",doc_version)
    ELSE
     batch_lyt->batch_details[row_cnt].blob_handle = blob
    ENDIF
   ELSE
    batch_lyt->batch_details[row_cnt].blob_handle = ctl.blob_handle
   ENDIF
   batch_lyt->batch_details[row_cnt].patient_name = ctl.patient_name, batch_lyt->batch_details[
   row_cnt].financial_nbr = ctl.financial_nbr, batch_lyt->batch_details[row_cnt].mrn = ctl.mrn,
   batch_lyt->batch_details[row_cnt].encntr_id = ctl.encntr_id, batch_lyt->batch_details[row_cnt].
   ax_appid = ctl.ax_appid, batch_lyt->batch_details[row_cnt].ax_docid = ctl.ax_docid,
   batch_lyt->batch_details[row_cnt].action_type = dm.definition, batch_lyt->batch_details[row_cnt].
   person_id = ctl.person_id, batch_lyt->batch_details[row_cnt].perf_prsnl_name = p
   .name_full_formatted,
   batch_lyt->batch_details[row_cnt].action_dt_tm = ctl.action_dt_tm, batch_lyt->batch_details[
   row_cnt].page_cnt = ctl.page_cnt, batch_lyt->batch_details[row_cnt].cdi_queue_cd = ctl
   .cdi_queue_cd,
   batch_lyt->batch_details[row_cnt].subject = ctl.subject, batch_lyt->batch_details[row_cnt].
   doc_type_alias = ctl.document_type_alias
   IF (dm2.flag_value=1
    AND cnvtupper(i.mill_alias_name)="PERSON")
    batch_lyt->batch_details[row_cnt].blob_ref_id = cnvtreal(i.mill_person_id), batch_lyt->
    batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"PRSN_1","person","")
   ELSEIF (dm2.flag_value=1
    AND cnvtupper(i.mill_alias_name)="ENCOUNTER")
    batch_lyt->batch_details[row_cnt].blob_ref_id = cnvtreal(i.mill_encntr_id), batch_lyt->
    batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"Enc_2","encounter","")
   ELSEIF (dm2.flag_value=1
    AND cnvtupper(i.mill_alias_name)="ACCESSION")
    batch_lyt->batch_details[row_cnt].blob_ref_id = cnvtreal(i.mill_accession_id), batch_lyt->
    batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"Acc_2","accession","")
   ELSE
    batch_lyt->batch_details[row_cnt].blob_ref_id = ctl.parent_entity_id, batch_lyt->batch_details[
    row_cnt].blob_type = ctl.parent_entity_name
   ENDIF
   batch_lyt->batch_details[row_cnt].external_batch_ident = ctl.external_batch_ident, batch_lyt->
   batch_details[row_cnt].doc_type = ctl.doc_type
  HEAD alias_type_cd
   IF (queue_cd=ctl.cdi_queue_cd
    AND reason_cd=ctl.reason_cd)
    batch_lyt->ai_nonmatch += 1
   ENDIF
   alias_cnt += 1
   IF (mod(alias_cnt,2)=1)
    alias_rows += 1
   ENDIF
   IF (mod(alias_rows,10)=1
    AND alias_rows != 1)
    stat = alterlist(batch_lyt->batch_details[row_cnt].parent_aliases,(alias_rows+ 9))
   ENDIF
   tmp_alias_name = alias_name, tmp_alias_val = " "
   IF (size(trim(encntr_alias_val),1) > 0)
    tmp_alias_val = trim(encntr_alias_val)
   ELSE
    IF (size(trim(person_alias_val),1) > 1)
     tmp_alias_val = trim(person_alias_val)
    ELSE
     IF (alias_type_cd=mrn_cd)
      tmp_alias_val = ctl.mrn
     ELSE
      IF (alias_type_cd=fin_cd)
       tmp_alias_val = ctl.financial_nbr
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   tmp_alias_col = mod(alias_cnt,2)
   IF (tmp_alias_col=1)
    batch_lyt->batch_details[row_cnt].parent_aliases[alias_rows].name_1 = tmp_alias_name, batch_lyt->
    batch_details[row_cnt].parent_aliases[alias_rows].value_1 = tmp_alias_val
   ELSE
    batch_lyt->batch_details[row_cnt].parent_aliases[alias_rows].name_2 = tmp_alias_name, batch_lyt->
    batch_details[row_cnt].parent_aliases[alias_rows].value_2 = tmp_alias_val
   ENDIF
  DETAIL
   dummy_cnt += 1
  FOOT  ctl.blob_handle
   stat = alterlist(batch_lyt->batch_details[row_cnt].parent_aliases,alias_rows)
  WITH nocounter
 ;end select
 SELECT
  ctl.blob_handle, ctl.batch_name, ctl.patient_name,
  ctl.financial_nbr, ctl.mrn, ctl.encntr_id,
  ctl.ax_appid, ctl.ax_docid, ctl.action_type_flag,
  ctl.person_id, ctl.action_dt_tm, ctl.page_cnt,
  ctl.cdi_queue_cd, ctl.blob_ref_id, ctl.blob_type_flag,
  ctl.perf_prsnl_id, ctl.external_batch_ident, ctl.create_dt_tm,
  ctl.subject, ctl.document_type_alias, dm.flag_value,
  dm.definition, dm2.definition, p.name_full_formatted,
  alias_name = uar_get_code_display(cnvtreal(i.alias_type_cd)), alias_type_cd = cnvtreal(i
   .alias_type_cd), cdm.field_value,
  i.alias_type_cd, i.cdi_trans_log_id, i.alias_type_codeset,
  i.cdi_pending_document_id, i.mill_encntr_id, i.mill_person_id,
  encntr_alias_val = ea.alias, person_alias_val = pa.alias, pending_alias_val = cdm.field_value
  FROM (
   (
   (SELECT
    c.cdi_trans_log_id, f.alias_type_cd, f.alias_type_codeset,
    c.cdi_pending_document_id, mill_encntr_id = ce.encntr_id, mill_person_id = ce.person_id
    FROM cdi_trans_log c,
     cdi_pending_document d,
     cdi_ac_field f,
     clinical_event ce
    WHERE c.batch_name_key=cnvtupper(batch_name)
     AND c.active_ind=1
     AND c.event_id > 0
     AND c.blob_ref_id=0
     AND (d.cdi_pending_document_id= Outerjoin(c.cdi_pending_document_id))
     AND (d.active_ind= Outerjoin(1))
     AND (f.doc_class_name= Outerjoin(" "))
     AND (f.auto_search_ind= Outerjoin(1))
     AND (ce.event_id= Outerjoin(c.event_id))
    ORDER BY c.blob_handle))
   i),
   cdi_trans_log ctl,
   dm_flags_all dm,
   dm_flags_all dm2,
   person p,
   cdi_doc_dyn_metadata cdm,
   encntr_alias ea,
   person_alias pa
  PLAN (i)
   JOIN (ctl
   WHERE ctl.cdi_trans_log_id=cnvtreal(i.cdi_trans_log_id)
    AND ctl.active_ind=1)
   JOIN (dm
   WHERE ctl.action_type_flag=dm.flag_value
    AND dm.table_name="CDI_TRANS_LOG"
    AND dm.column_name="ACTION_TYPE_FLAG")
   JOIN (dm2
   WHERE ctl.blob_type_flag=dm2.flag_value
    AND dm2.table_name="CDI_TRANS_LOG"
    AND dm2.column_name="BLOB_TYPE_FLAG")
   JOIN (cdm
   WHERE (cdm.cdi_pending_document_id= Outerjoin(cnvtreal(i.cdi_pending_document_id)))
    AND (cdm.alias_type_codeset= Outerjoin(cnvtint(i.alias_type_codeset)))
    AND (cdm.alias_type_cd= Outerjoin(cnvtreal(i.alias_type_cd))) )
   JOIN (p
   WHERE (p.person_id= Outerjoin(ctl.perf_prsnl_id)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(cnvtreal(i.mill_encntr_id)))
    AND (ea.encntr_alias_type_cd= Outerjoin(cnvtreal(i.alias_type_cd))) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(cnvtreal(i.mill_person_id)))
    AND (pa.person_alias_type_cd= Outerjoin(cnvtreal(i.alias_type_cd))) )
  ORDER BY ctl.batch_name, ctl.patient_name DESC, ctl.blob_handle,
   i.alias_type_cd, ctl.doc_type
  HEAD REPORT
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 49))
   ELSEIF (row_cnt=0)
    stat = alterlist(batch_lyt->batch_details,50)
   ENDIF
  HEAD ctl.batch_name
   IF (datetimecmp(cnvtdatetime(ctl.create_dt_tm),cnvtdatetime("01-JAN-1900"))=0)
    batch_lyt->create_dt_tm = 0.0
   ELSE
    batch_lyt->create_dt_tm = ctl.create_dt_tm, start_dt_tm = (ctl.create_dt_tm - interval),
    end_dt_tm = (ctl.create_dt_tm+ interval)
   ENDIF
   batch_lyt->batch_name = ctl.batch_name
   IF (ext_batch_ident <= 0)
    ext_batch_ident = ctl.external_batch_ident
   ENDIF
  HEAD ctl.blob_handle
   row_cnt += 1
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(batch_lyt->batch_details,(row_cnt+ 49))
   ENDIF
   alias_cnt = 0, alias_rows = 0, stat = alterlist(batch_lyt->batch_details[row_cnt].parent_aliases,
    10),
   vers_pos = findstring("#",ctl.blob_handle), dec_pos = findstring(".",ctl.blob_handle,vers_pos)
   IF (vers_pos > 0)
    blob = substring(1,(vers_pos - 1),ctl.blob_handle), handle_len = size(ctl.blob_handle,1),
    doc_version = substring((vers_pos+ 1),((dec_pos - 1) - vers_pos),ctl.blob_handle)
    IF (cnvtint(doc_version) > 1)
     batch_lyt->batch_details[row_cnt].blob_handle = concat(blob," Version ",doc_version)
    ELSE
     batch_lyt->batch_details[row_cnt].blob_handle = blob
    ENDIF
   ELSE
    batch_lyt->batch_details[row_cnt].blob_handle = ctl.blob_handle
   ENDIF
   batch_lyt->batch_details[row_cnt].patient_name = ctl.patient_name, batch_lyt->batch_details[
   row_cnt].financial_nbr = ctl.financial_nbr, batch_lyt->batch_details[row_cnt].mrn = ctl.mrn,
   batch_lyt->batch_details[row_cnt].encntr_id = ctl.encntr_id, batch_lyt->batch_details[row_cnt].
   ax_appid = ctl.ax_appid, batch_lyt->batch_details[row_cnt].ax_docid = ctl.ax_docid,
   batch_lyt->batch_details[row_cnt].action_type = dm.definition, batch_lyt->batch_details[row_cnt].
   person_id = ctl.person_id, batch_lyt->batch_details[row_cnt].perf_prsnl_name = p
   .name_full_formatted,
   batch_lyt->batch_details[row_cnt].action_dt_tm = ctl.action_dt_tm, batch_lyt->batch_details[
   row_cnt].page_cnt = ctl.page_cnt, batch_lyt->batch_details[row_cnt].cdi_queue_cd = ctl
   .cdi_queue_cd,
   batch_lyt->batch_details[row_cnt].subject = ctl.subject, batch_lyt->batch_details[row_cnt].
   doc_type_alias = ctl.document_type_alias
   IF (dm2.flag_value=0
    AND ((ctl.cdi_queue_cd=hnam_cd) OR (dm.definition="Submit"
    AND submit_cd=ctl.reason_cd)) )
    IF (cnvtint(i.mill_encntr_id) > 0)
     batch_lyt->batch_details[row_cnt].blob_ref_id = cnvtreal(i.mill_encntr_id), batch_lyt->
     batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"Enc_1","encounter","")
    ELSE
     batch_lyt->batch_details[row_cnt].blob_ref_id = cnvtreal(i.mill_person_id), batch_lyt->
     batch_details[row_cnt].blob_type = uar_i18nbuildmessage(i18nhandle,"Enc_1","person","")
    ENDIF
   ELSE
    batch_lyt->batch_details[row_cnt].blob_ref_id = ctl.parent_entity_id, batch_lyt->batch_details[
    row_cnt].blob_type = ctl.parent_entity_name
   ENDIF
   batch_lyt->batch_details[row_cnt].external_batch_ident = ctl.external_batch_ident, batch_lyt->
   batch_details[row_cnt].doc_type = ctl.doc_type
  HEAD alias_type_cd
   IF (queue_cd=ctl.cdi_queue_cd
    AND reason_cd=ctl.reason_cd)
    batch_lyt->ai_nonmatch += 1
   ENDIF
   alias_cnt += 1
   IF (mod(alias_cnt,2)=1)
    alias_rows += 1
   ENDIF
   IF (mod(alias_rows,10)=1
    AND alias_rows != 1)
    stat = alterlist(batch_lyt->batch_details[row_cnt].parent_aliases,(alias_rows+ 9))
   ENDIF
   tmp_alias_name = alias_name, tmp_alias_val = " "
   IF (size(trim(encntr_alias_val),1) > 0)
    tmp_alias_val = trim(encntr_alias_val)
   ELSE
    IF (size(trim(person_alias_val),1) > 1)
     tmp_alias_val = trim(person_alias_val)
    ELSE
     IF (size(trim(pending_alias_val),1) > 1)
      tmp_alias_val = trim(pending_alias_val)
     ELSE
      IF (alias_type_cd=mrn_cd)
       tmp_alias_val = ctl.mrn
      ELSE
       IF (alias_type_cd=fin_cd)
        tmp_alias_val = ctl.financial_nbr
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   tmp_alias_col = mod(alias_cnt,2)
   IF (tmp_alias_col=1)
    batch_lyt->batch_details[row_cnt].parent_aliases[alias_rows].name_1 = tmp_alias_name, batch_lyt->
    batch_details[row_cnt].parent_aliases[alias_rows].value_1 = tmp_alias_val
   ELSE
    batch_lyt->batch_details[row_cnt].parent_aliases[alias_rows].name_2 = tmp_alias_name, batch_lyt->
    batch_details[row_cnt].parent_aliases[alias_rows].value_2 = tmp_alias_val
   ENDIF
  DETAIL
   dummy_cnt += 1
  FOOT  ctl.blob_handle
   stat = alterlist(batch_lyt->batch_details[row_cnt].parent_aliases,alias_rows)
  WITH nocounter
 ;end select
 SET stat = alterlist(batch_lyt->batch_details,row_cnt)
 IF (ext_batch_ident > 0)
  SELECT INTO "nl:"
   cbs.external_batch_ident, ca.batchclass, cbs.ecp_cnt,
   cbs.combined_cnt, cbs.man_create_cnt, cbs.man_del_cnt,
   cbs.cur_auto_cnt, cbs.ac_rel_cnt, cbs.ac_rel_dt_tm,
   cbs.complete_cnt
   FROM cdi_batch_summary cbs,
    cdi_ac_batch ca,
    cdi_ac_batchmodule cab
   PLAN (cbs
    WHERE ext_batch_ident=cbs.external_batch_ident
     AND cnvtdatetime(start_dt_tm) <= cbs.create_dt_tm
     AND cnvtdatetime(end_dt_tm) >= cbs.create_dt_tm)
    JOIN (ca
    WHERE (ca.cdi_ac_batch_id= Outerjoin(cbs.cdi_ac_batch_id)) )
    JOIN (cab
    WHERE (cab.cdi_ac_batch_id= Outerjoin(ca.cdi_ac_batch_id)) )
   ORDER BY cbs.external_batch_ident, cab.startdatetime
   HEAD cbs.external_batch_ident
    batch_lyt->batch_class = ca.batchclass, batch_lyt->cover_pgs_rmvd = cbs.ecp_cnt, batch_lyt->
    docs_combined = cbs.combined_cnt,
    batch_lyt->created_in_man = cbs.man_create_cnt, batch_lyt->del_in_man = cbs.man_del_cnt,
    batch_lyt->docs_in_auto = cbs.cur_auto_cnt,
    batch_lyt->docs_from_ac = cbs.ac_rel_cnt, batch_lyt->ac_rel_dt_tm = cbs.ac_rel_dt_tm, batch_lyt->
    total_docs = (((((((cbs.ac_rel_cnt - cbs.prep_comp_cnt) - cbs.ecp_cnt) - cbs.combined_cnt)+ cbs
    .cur_man_cnt)+ cbs.cur_auto_cnt)+ cbs.complete_cnt)+ (cbs.wqm_create_cnt - cbs.wqm_del_cnt)),
    batch_lyt->completed_docs = cbs.complete_cnt
   HEAD cab.startdatetime
    batch_lyt->scanned_pgs += cab.pagesscanned
   WITH nocounter
  ;end select
 ENDIF
END GO
