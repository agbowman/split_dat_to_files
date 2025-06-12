CREATE PROGRAM cdi_rpt_rejected_docs_drvr
 PROMPT
  "Start Date" = "",
  "End Date" = "",
  "Doc UID" = "",
  "Contributor System" = ""
  WITH startdate, enddate, referencenbr,
  contribsys
 DECLARE strstartdate = vc WITH noconstant("")
 DECLARE strenddate = vc WITH noconstant("")
 DECLARE strreferencenbr = vc WITH noconstant("")
 DECLARE fcontribsys = f8 WITH noconstant(0.0)
 DECLARE istartdatelen = i4 WITH noconstant(0)
 DECLARE ienddatelen = i4 WITH noconstant(0)
 DECLARE ireferencenbrlen = i4 WITH noconstant(0)
 DECLARE icontribsyslen = i4 WITH noconstant(0)
 DECLARE faliastypefin = f8 WITH noconstant(0.0)
 DECLARE faliastypemrn = f8 WITH noconstant(0.0)
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
 SET strstartdate =  $STARTDATE
 SET strenddate =  $ENDDATE
 SET strreferencenbr =  $REFERENCENBR
 SET fcontribsys = uar_get_code_by("DISPLAY",89, $CONTRIBSYS)
 SET istartdatelen = size(trim(strstartdate))
 SET ienddatelen = size(trim(strenddate))
 SET ireferencenbrlen = size(trim(strreferencenbr))
 SET icontribsyslen = size(trim( $CONTRIBSYS))
 SET faliastypefin = uar_get_code_by("MEANING",319,"FIN NBR")
 SET faliastypemrn = uar_get_code_by("MEANING",319,"MRN")
 SELECT INTO "nl:"
  r.contributor_system_cd, r.reference_nbr, r.reject_user_id,
  r.reject_dt_tm, r.reject_fin, r.reject_patient_name,
  r.reject_birth_dt_tm, r.reject_mrn, r.reject_doc_type,
  r.reject_subject, r.reject_updt_dt_tm, r.reject_status,
  r.reject_service_dt_tm, r.reject_provider, ea_fin.alias,
  p.name_full_formatted, p.birth_dt_tm, ea_mrn.alias,
  ce.event_cd, ce.event_tag, ce.updt_dt_tm,
  ce.result_status_cd, ce.event_start_dt_tm, ce.performed_prsnl_id,
  b.blob_handle, pr.name_full_formatted
  FROM cdi_reject_log r,
   clinical_event ce,
   person p,
   encntr_alias ea_fin,
   encntr_alias ea_mrn,
   ce_blob_result b,
   prsnl pp,
   prsnl pr
  PLAN (r
   WHERE r.cdi_reject_log_id > 0
    AND ((ireferencenbrlen < 1) OR (strreferencenbr=r.reference_nbr))
    AND ((istartdatelen < 1) OR (cnvtdatetime(strstartdate) <= r.reject_dt_tm))
    AND ((ienddatelen < 1) OR (r.reject_dt_tm <= cnvtdatetime(strenddate)))
    AND ((icontribsyslen < 1) OR (fcontribsys=r.contributor_system_cd)) )
   JOIN (ce
   WHERE outerjoin(r.match_event_id)=ce.event_id
    AND outerjoin(cnvtdatetime("31-DEC-2100"))=ce.valid_until_dt_tm)
   JOIN (p
   WHERE outerjoin(ce.person_id)=p.person_id)
   JOIN (b
   WHERE outerjoin(ce.event_id)=b.event_id
    AND outerjoin(cnvtdatetime("31-DEC-2100"))=b.valid_until_dt_tm)
   JOIN (pp
   WHERE outerjoin(ce.performed_prsnl_id)=pp.person_id)
   JOIN (pr
   WHERE outerjoin(r.reject_user_id)=pr.person_id)
   JOIN (ea_fin
   WHERE outerjoin(ce.encntr_id)=ea_fin.encntr_id
    AND outerjoin(faliastypefin)=ea_fin.encntr_alias_type_cd)
   JOIN (ea_mrn
   WHERE outerjoin(ce.encntr_id)=ea_mrn.encntr_id
    AND outerjoin(faliastypemrn)=ea_mrn.encntr_alias_type_cd)
  ORDER BY r.reject_dt_tm
  HEAD REPORT
   row_cnt = 0, stat = alterlist(reject_lyt->reject_details,50)
  DETAIL
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,50)=1
    AND row_cnt != 1)
    stat = alterlist(reject_lyt->reject_details,(row_cnt+ 49))
   ENDIF
   reject_lyt->reject_details[row_cnt].reference_nbr = r.reference_nbr, reject_lyt->reject_details[
   row_cnt].contributor_system = uar_get_code_description(r.contributor_system_cd), reject_lyt->
   reject_details[row_cnt].reject_user_name = pr.name_full_formatted,
   reject_lyt->reject_details[row_cnt].reject_dt_tm = r.reject_dt_tm, reject_lyt->reject_details[
   row_cnt].reject_fin = r.reject_fin, reject_lyt->reject_details[row_cnt].reject_patient_name = r
   .reject_patient_name,
   reject_lyt->reject_details[row_cnt].reject_birth_dt_tm = r.reject_birth_dt_tm, reject_lyt->
   reject_details[row_cnt].reject_mrn = r.reject_mrn, reject_lyt->reject_details[row_cnt].
   reject_doc_type = r.reject_doc_type,
   reject_lyt->reject_details[row_cnt].reject_subject = r.reject_subject, reject_lyt->reject_details[
   row_cnt].reject_updt_dt_tm = r.reject_updt_dt_tm, reject_lyt->reject_details[row_cnt].
   reject_status = r.reject_status,
   reject_lyt->reject_details[row_cnt].reject_service_dt_tm = r.reject_service_dt_tm, reject_lyt->
   reject_details[row_cnt].reject_provider = r.reject_provider
   IF (r.match_event_id != 0)
    reject_lyt->reject_details[row_cnt].match_fin = ea_fin.alias, reject_lyt->reject_details[row_cnt]
    .match_patient_name = p.name_full_formatted, reject_lyt->reject_details[row_cnt].
    match_birth_dt_tm = p.birth_dt_tm,
    reject_lyt->reject_details[row_cnt].match_mrn = ea_mrn.alias, reject_lyt->reject_details[row_cnt]
    .match_doc_type = uar_get_code_description(ce.event_cd), reject_lyt->reject_details[row_cnt].
    match_subject = ce.event_tag,
    reject_lyt->reject_details[row_cnt].match_updt_dt_tm = ce.updt_dt_tm, reject_lyt->reject_details[
    row_cnt].match_status = uar_get_code_description(ce.result_status_cd), reject_lyt->
    reject_details[row_cnt].match_service_dt_tm = ce.event_start_dt_tm,
    reject_lyt->reject_details[row_cnt].match_provider = pp.name_full_formatted, reject_lyt->
    reject_details[row_cnt].match_blob_handle = b.blob_handle
   ELSE
    reject_lyt->reject_details[row_cnt].match_fin = "", reject_lyt->reject_details[row_cnt].
    match_patient_name = "", reject_lyt->reject_details[row_cnt].match_birth_dt_tm = 0,
    reject_lyt->reject_details[row_cnt].match_mrn = "", reject_lyt->reject_details[row_cnt].
    match_doc_type = "", reject_lyt->reject_details[row_cnt].match_subject = "",
    reject_lyt->reject_details[row_cnt].match_updt_dt_tm = 0, reject_lyt->reject_details[row_cnt].
    match_status = "", reject_lyt->reject_details[row_cnt].match_service_dt_tm = 0,
    reject_lyt->reject_details[row_cnt].match_provider = "", reject_lyt->reject_details[row_cnt].
    match_blob_handle = ""
   ENDIF
  FOOT REPORT
   stat = alterlist(reject_lyt->reject_details,row_cnt)
  WITH nocounter
 ;end select
END GO
