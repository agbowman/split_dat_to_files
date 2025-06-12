CREATE PROGRAM bbt_rpt_aborh_review:dba
 PAINT
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 rpt_patient = vc
   1 start_date = vc
   1 end_date = vc
   1 rpt_aborh_result = vc
   1 type_results = vc
   1 chk = vc
   1 current = vc
   1 accession = vc
   1 rpt_order = vc
   1 complete = vc
   1 rpt_detail = vc
   1 upd = vc
   1 previous = vc
   1 result_status = vc
   1 date = vc
   1 time = vc
   1 id = vc
   1 rpt_report_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 rpt_by = vc
   1 completed_orders = vc
 )
 SET captions->rpt_patient = uar_i18ngetmessage(i18nhandle,"rpt_patient",
  "Patient ABORh Result Review")
 SET captions->start_date = uar_i18ngetmessage(i18nhandle,"start_date",
  "Enter start date, example 01-JAN-1998")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date",
  "Enter end date, example 01-JAN-1998")
 SET captions->rpt_aborh_result = uar_i18ngetmessage(i18nhandle,"rpt_aborh_result",
  "P A T I E N T   A B O R H   R E S U L T   R E V I E W")
 SET captions->type_results = uar_i18ngetmessage(i18nhandle,"type_results","TYPE RESULTS:")
 SET captions->chk = uar_i18ngetmessage(i18nhandle,"chk","CHK")
 SET captions->current = uar_i18ngetmessage(i18nhandle,"current","Current(*)")
 SET captions->accession = uar_i18ngetmessage(i18nhandle,"accession","ACCESSION")
 SET captions->rpt_order = uar_i18ngetmessage(i18nhandle,"rpt_order","ORDER")
 SET captions->complete = uar_i18ngetmessage(i18nhandle,"complete","Complete(*)")
 SET captions->rpt_detail = uar_i18ngetmessage(i18nhandle,"rpt_detail","DETAIL")
 SET captions->upd = uar_i18ngetmessage(i18nhandle,"upd","UPD")
 SET captions->previous = uar_i18ngetmessage(i18nhandle,"previous","Previous")
 SET captions->result_status = uar_i18ngetmessage(i18nhandle,"result_status","RESULT STATUS")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"date","DATE ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME")
 SET captions->id = uar_i18ngetmessage(i18nhandle,"id","ID")
 SET captions->rpt_report_id = uar_i18ngetmessage(i18nhandle,"rpt_report_id",
  "Report ID: BBT_RPT_ABORH_REVIEW")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","By:")
 SET captions->completed_orders = uar_i18ngetmessage(i18nhandle,"completed_orders",
  "Completed Orders:")
 DECLARE v_begin_date = c11
 DECLARE v_end_date = c11
 CALL box(1,1,15,80)
 CALL line(4,1,80,xhor)
 CALL text(2,10,captions->rpt_patient)
 CALL text(7,5,captions->start_date)
 CALL text(9,5,captions->end_date)
 CALL accept(7,45,"XXXXXXXXXXX;CD","  -   -    "
  WHERE cnvtdatetime(curaccept) >= cnvtdatetime("01-JAN-1995"))
 SET v_begin_date = curaccept
 CALL accept(9,45,"XXXXXXXXXXX;CD","  -   -    "
  WHERE cnvtdatetime(curaccept) >= cnvtdatetime("01-JAN-1995")
   AND cnvtdatetime(curaccept) > cnvtdatetime(v_begin_date))
 SET v_end_date = curaccept
 CALL video(n)
 CALL clear(1,1)
 EXECUTE cclseclogin
 RECORD internal(
   1 beg_dt_tm = f8
   1 end_dt_tm = f8
 )
 RECORD ord_r_rec(
   1 ord_r[*]
     2 order_id = f8
     2 completed_flag = i2
     2 result_id = f8
     2 accession = c20
     2 order_mnemonic = c20
     2 detail_mnemonic = c18
     2 cell_product = c26
     2 hst_upd_flag = c3
 )
 RECORD r_rec(
   1 r[*]
     2 result_id = f8
     2 perform_result_id = f8
     2 result_status_cd = f8
     2 result_status_disp = c15
     2 result = vc
     2 result_dt_tm = dq8
     2 result_username = c10
 )
 RECORD result(
   1 resultlist[*]
     2 result_corrected_ind = c1
     2 result = vc
     2 result_dt_tm = dq8
     2 result_username = c10
     2 long_text_id = f8
     2 long_text = vc
     2 result_status_disp = c15
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_inst_name(inst_name_dummy) = c60
 SUBROUTINE get_inst_name(inst_name_dummy)
   SET inst_name_pref = fillstring(60," ")
   SET module_cd = 0.0
   SET process_cd = 0.0
   SET question_cd = 0.0
   SET stat = uar_get_meaning_by_codeset(1660,"BB TRANSF",1,module_cd)
   SET stat = uar_get_meaning_by_codeset(1662,"BBTGLOBAL",1,process_cd)
   SET stat = uar_get_meaning_by_codeset(1661,"INST NAME",1,question_cd)
   SELECT INTO "nl:"
    a.answer
    FROM answer a
    PLAN (a
     WHERE a.module_cd=module_cd
      AND a.process_cd=process_cd
      AND a.question_cd=question_cd
      AND a.active_ind=1)
    DETAIL
     inst_name_pref = a.answer
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET inc_i18nhandle = 0
    SET inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev)
    SET inst_name_pref = uar_i18ngetmessage(inc_i18nhandle,"inc_inst_not_found",
     "<< INSTITUTION NAME NOT FOUND >>")
   ENDIF
   RETURN(inst_name_pref)
 END ;Subroutine
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 SET result_status_code_set = 1901
 SET corrected_cdf_meaning = "CORRECTED"
 SET old_corrected_cdf_meaning = "OLDCORRECTED"
 SET verified_cdf_meaning = "VERIFIED"
 SET old_verified_cdf_meaning = "OLDVERIFIED"
 SET alias_type_code_set = 319
 SET mrn_alias_cdf_meaning = "MRN"
 SET activity_type_code_set = 106
 SET bb_activity_cdf_meaning = "BB"
 SET product_state_code_set = 1610
 SET in_progress_cdf_meaning = "16"
 SET patient_aborh_code_set = 1635
 SET patient_aborh_cdf_meaning = "PATIENT ABO"
 SET histry_upd_code_set = 1636
 SET histry_upd_cdf_meaning = "HISTRY & UPD"
 SET histry_only_code_set = 1636
 SET histry_only_cdf_meaning = "HISTRY ONLY"
 SET completed_code_set = 6004
 SET completed_cdf_meaning = "COMPLETED"
 SET count1 = 0
 SET detail_cnt = 0
 SET report_complete_ind = "N"
 SET corrected_status_cd = 0.0
 SET old_corrected_status_cd = 0.0
 SET verified_status_cd = 0.0
 SET old_verified_status_cd = 0.0
 SET mrn_alias_type_cd = 0.0
 SET bb_activity_type_cd = 0.0
 SET in_progress_event_type_cd = 0.0
 SET line = fillstring(130,"_")
 SET result_cnt = 0
 SET rslt = 0
 SET rslt_row = 0
 SET name_full_formatted = fillstring(25," ")
 SET alias = fillstring(20," ")
 SET accession = fillstring(20," ")
 SET order_mnemonic = fillstring(20," ")
 SET mnemonic = fillstring(15," ")
 SET cell_product = fillstring(26," ")
 SET institution_name = fillstring(60," ")
 SET patient_aborh_cd = 0.0
 SET histry_upd_cd = 0.0
 SET histry_only_cd = 0.0
 SET completed_cd = 0.0
 SET accession_hold = "                    "
 SET ord_r_cnt = 0
 SET r_cnt = 0
 SET completed_order_cnt = 0
 SET patient_aborh_cd = 0.0
 SET patient_aborh_cd = get_code_value(patient_aborh_code_set,patient_aborh_cdf_meaning)
 IF (patient_aborh_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get patient ABORh code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get patient aborh code_value"
  GO TO exit_script
 ENDIF
 SET histry_upd_cd = 0.0
 SET histry_upd_cd = get_code_value(histry_upd_code_set,histry_upd_cdf_meaning)
 IF (histry_upd_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get history Update code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get history update code_value"
  GO TO exit_script
 ENDIF
 SET histry_only_cd = 0.0
 SET histry_only_cd = get_code_value(histry_only_code_set,histry_only_cdf_meaning)
 IF (histry_only_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get history only code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get history only code_value"
  GO TO exit_script
 ENDIF
 SET completed_cd = 0.0
 SET completed_cd = get_code_value(completed_code_set,completed_cdf_meaning)
 IF (completed_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get completed code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get completed code_value"
  GO TO exit_script
 ENDIF
 SET corrected_status_cd = 0.0
 SET corrected_status_cd = get_code_value(result_status_code_set,corrected_cdf_meaning)
 IF (corrected_status_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get corrected status code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get corrected status code_value"
  GO TO exit_script
 ENDIF
 SET old_corrected_status_cd = 0.0
 SET old_corrected_status_cd = get_code_value(result_status_code_set,old_corrected_cdf_meaning)
 IF (old_corrected_status_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get old_corrected status code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get old_corrected status code_value"
  GO TO exit_script
 ENDIF
 SET verified_status_cd = 0.0
 SET verified_status_cd = get_code_value(result_status_code_set,verified_cdf_meaning)
 IF (verified_status_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get verified status code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get verified status code_value"
  GO TO exit_script
 ENDIF
 SET old_verified_status_cd = 0.0
 SET old_verified_status_cd = get_code_value(result_status_code_set,old_verified_cdf_meaning)
 IF (old_verified_status_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get old_verified status code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get old_verified status code_value"
  GO TO exit_script
 ENDIF
 SET mrn_alias_type_cd = 0.0
 SET mrn_alias_type_cd = get_code_value(alias_type_code_set,mrn_alias_cdf_meaning)
 IF (mrn_alias_type_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get mrn_alias_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get mrn alias type code_value"
  GO TO exit_script
 ENDIF
 SET bb_activity_type_cd = 0.0
 SET bb_activity_type_cd = get_code_value(activity_type_code_set,bb_activity_cdf_meaning)
 IF (bb_activity_type_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get bb_activity_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get mrn alias type code_value"
  GO TO exit_script
 ENDIF
 SET in_progress_event_type_cd = 0.0
 SET in_progress_event_type_cd = get_code_value(product_state_code_set,in_progress_cdf_meaning)
 IF (in_progress_event_type_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname =
  "get in_progress product state code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_abo_review"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get in_progress product state code_value"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  r.order_id"########", aor.accession_id"########", sort_accession = aor.accession
  "####################",
  o.order_mnemonic"####################", r.result_id"########", r_result_status_disp =
  uar_get_code_display(r.result_status_cd)"###############",
  dta.mnemonic"###############", o.order_status_cd
  FROM result r,
   result_event re,
   service_directory sd,
   accession_order_r aor,
   orders o,
   discrete_task_assay dta
  PLAN (sd
   WHERE sd.bb_processing_cd=patient_aborh_cd)
   JOIN (o
   WHERE o.catalog_cd=sd.catalog_cd
    AND o.order_id > 0
    AND o.order_id != null)
   JOIN (r
   WHERE r.order_id=o.order_id
    AND r.result_status_cd IN (corrected_status_cd, old_corrected_status_cd, verified_status_cd,
   old_verified_status_cd))
   JOIN (re
   WHERE re.result_id=r.result_id
    AND re.event_type_cd=r.result_status_cd
    AND re.event_dt_tm >= cnvtdatetime(v_begin_date)
    AND re.event_dt_tm <= cnvtdatetime(v_end_date))
   JOIN (dta
   WHERE dta.task_assay_cd=r.task_assay_cd
    AND dta.bb_result_processing_cd IN (histry_upd_cd, histry_only_cd))
   JOIN (aor
   WHERE aor.order_id=r.order_id
    AND aor.primary_flag=0)
  ORDER BY r.result_id
  HEAD REPORT
   stat = alterlist(ord_r_rec->ord_r,20)
  HEAD r.result_id
   ord_r_cnt += 1
   IF (mod(ord_r_cnt,20)=1
    AND ord_r_cnt != 1)
    stat = alterlist(ord_r_rec->ord_r,(ord_r_cnt+ 19))
   ENDIF
   ord_r_rec->ord_r[ord_r_cnt].order_id = o.order_id, ord_r_rec->ord_r[ord_r_cnt].result_id = r
   .result_id, ord_r_rec->ord_r[ord_r_cnt].accession = sort_accession,
   ord_r_rec->ord_r[ord_r_cnt].order_mnemonic = o.order_mnemonic, ord_r_rec->ord_r[ord_r_cnt].
   detail_mnemonic = dta.mnemonic
   IF (o.order_status_cd=completed_cd)
    ord_r_rec->ord_r[ord_r_cnt].completed_flag = 1
   ELSE
    ord_r_rec->ord_r[ord_r_cnt].completed_flag = 0
   ENDIF
   IF (dta.bb_result_processing_cd=histry_upd_cd)
    ord_r_rec->ord_r[ord_r_cnt].hst_upd_flag = "UPD"
   ELSE
    ord_r_rec->ord_r[ord_r_cnt].hst_upd_flag = "CHK"
   ENDIF
  FOOT REPORT
   stat = alterlist(ord_r_rec->ord_r,ord_r_cnt)
  WITH nocounter, outerjoin(d_ea), dontcare(ea)
 ;end select
 SELECT INTO "nl:"
  table_ind = decode(re.seq,"4re    ",pr.seq,"1pr    ","xxxxxx"), result_id = ord_r_rec->ord_r[d.seq]
  .result_id, result_code_set_disp = uar_get_code_display(pr.result_code_set_cd),
  result_status_disp = uar_get_code_display(pr.result_status_cd), pr.perform_result_id, pnl.username
  "##########",
  re.event_dt_tm
  FROM (dummyt d  WITH seq = value(ord_r_cnt)),
   perform_result pr,
   (dummyt d_pr  WITH seq = 1),
   result_event re,
   prsnl pnl
  PLAN (d)
   JOIN (pr
   WHERE (pr.result_id=ord_r_rec->ord_r[d.seq].result_id)
    AND pr.result_status_cd IN (corrected_status_cd, old_corrected_status_cd, old_verified_status_cd,
   verified_status_cd))
   JOIN (d_pr
   WHERE d_pr.seq=1)
   JOIN (re
   WHERE re.result_id=pr.result_id
    AND re.perform_result_id=pr.perform_result_id
    AND ((re.event_type_cd=pr.result_status_cd) OR (((pr.result_status_cd=old_corrected_status_cd
    AND re.event_type_cd=corrected_status_cd) OR (pr.result_status_cd=old_verified_status_cd
    AND re.event_type_cd=verified_status_cd)) )) )
   JOIN (pnl
   WHERE pnl.person_id=re.event_personnel_id)
  ORDER BY pr.result_id, pr.perform_result_id, table_ind
  HEAD REPORT
   stat = alterlist(r_rec->r,(ord_r_cnt * 2))
  HEAD pr.perform_result_id
   r_cnt += 1
   IF (mod(r_cnt,10)=1
    AND r_cnt != 10)
    stat = alterlist(r_rec->r,(r_cnt+ 9))
   ENDIF
   r_rec->r[r_cnt].result_id = pr.result_id, r_rec->r[r_cnt].perform_result_id = pr.perform_result_id,
   r_rec->r[r_cnt].result_status_cd = pr.result_status_cd,
   r_rec->r[r_cnt].result = result_code_set_disp, r_rec->r[r_cnt].result_status_disp =
   result_status_disp
  HEAD table_ind
   IF (table_ind="4re    ")
    r_rec->r[r_cnt].result_dt_tm = re.event_dt_tm, r_rec->r[r_cnt].result_username = pnl.username
   ENDIF
  FOOT  pr.perform_result_id
   IF (trim(r_rec->r[r_cnt].result) <= "")
    r_rec->r[r_cnt].result = "result unknown"
   ENDIF
  FOOT REPORT
   stat = alterlist(r_rec->r,r_cnt)
  WITH nocounter
 ;end select
 SET institution_name = get_inst_name(0)
 SELECT
  order_id = ord_r_rec->ord_r[d_or.seq].order_id, accession = ord_r_rec->ord_r[d_or.seq].accession,
  result_id = ord_r_rec->ord_r[d_or.seq].result_id,
  perform_result_id = r_rec->r[d_r.seq].perform_result_id
  FROM (dummyt d_or  WITH seq = value(ord_r_cnt)),
   (dummyt d_r  WITH seq = value(r_cnt))
  PLAN (d_or)
   JOIN (d_r
   WHERE (r_rec->r[d_r.seq].result_id=ord_r_rec->ord_r[d_or.seq].result_id))
  ORDER BY accession, order_id, result_id,
   perform_result_id DESC
  HEAD REPORT
   rpt_row = 0, rslt_row = 0, beg_dt_tm = cnvtdatetime(v_begin_date),
   end_dt_tm = cnvtdatetime(v_end_date), rslt_ln = 0, rslt_ln_cnt = 0,
   rslt_ln_len = 0, rslt_text = fillstring(54," "), long_text_page_wrap_ind = "N",
   detail_cnt = 0, report_complete_ind = "N", completed_order_cnt = 0
  HEAD PAGE
   new_page = "Y", rpt_row = 1, row rpt_row,
   col 1, institution_name, rpt_row += 2,
   row rpt_row,
   CALL center(captions->rpt_aborh_result,1,132), rpt_row += 2,
   row rpt_row, col 067, captions->type_results,
   rpt_row += 1, row rpt_row, col 067,
   captions->chk, col 071, captions->current,
   rpt_row += 1, row rpt_row, col 001,
   captions->accession, col 023, captions->rpt_order,
   col 035, captions->complete, col 047,
   captions->rpt_detail, col 067, captions->upd,
   col 071, captions->previous, col 089,
   captions->result_status, col 107, captions->date,
   col 114, captions->time, col 124,
   captions->id, rpt_row += 1, row rpt_row,
   col 001, "_____________________", col 023,
   "_______________________", col 047, "___________________",
   col 067, "___", col 071,
   "________________", col 088, "________________",
   col 105, "______________", col 120,
   "__________", rpt_row += 1
  HEAD accession
   new_accession = "Y", pr_accession = ord_r_rec->ord_r[d_or.seq].accession
  HEAD order_id
   new_order = "Y", pr_order_mnemonic = ord_r_rec->ord_r[d_or.seq].order_mnemonic
   IF (new_accession != "Y")
    rslt_row += 1
   ENDIF
  HEAD result_id
   new_result = "Y", result_cnt = 0, stat = alterlist(result->resultlist,5),
   rslt_row += 1, pr_detail_mnemonic = ord_r_rec->ord_r[d_or.seq].detail_mnemonic, pr_detail_histry
    = ord_r_rec->ord_r[d_or.seq].hst_upd_flag
   IF ((ord_r_rec->ord_r[d_or.seq].completed_flag=1))
    completed_order_cnt += 1, pr_detail_completed = "*"
   ELSE
    pr_detail_completed = " "
   ENDIF
  HEAD perform_result_id
   result_cnt += 1
   IF (mod(result_cnt,5)=1
    AND result_cnt != 1)
    stat = alterlist(result->resultlist,(result_cnt+ 4))
   ENDIF
   IF (((new_result != "Y") OR (new_result="Y"
    AND result_cnt > 1)) )
    rslt_row += 1
   ENDIF
   result->resultlist[result_cnt].result = r_rec->r[d_r.seq].result
   IF ((r_rec->r[d_r.seq].result_status_cd IN (corrected_status_cd, verified_status_cd)))
    result->resultlist[result_cnt].result_corrected_ind = "*"
   ELSE
    result->resultlist[result_cnt].result_corrected_ind = " "
   ENDIF
   result->resultlist[result_cnt].result_dt_tm = cnvtdatetime(r_rec->r[d_r.seq].result_dt_tm), result
   ->resultlist[result_cnt].result_username = r_rec->r[d_r.seq].result_username, result->resultlist[
   result_cnt].result_status_disp = r_rec->r[d_r.seq].result_status_disp
  FOOT  result_id
   IF ((((rpt_row+ rslt_row)+ 1) > 58))
    BREAK
   ENDIF
   IF (new_page="Y")
    new_page = "N"
   ELSE
    rpt_row += 1
   ENDIF
   IF (new_accession="Y")
    rpt_row += 1, row rpt_row, col 001,
    pr_accession"#####-####-###-######"
   ENDIF
   IF (new_order="Y")
    new_order = "N"
    IF (new_accession != "Y")
     rpt_row += 1
    ENDIF
    row rpt_row, col 023, pr_order_mnemonic
   ENDIF
   new_accession = "N"
   IF (new_result="Y")
    new_result = "N", row rpt_row, col 047,
    pr_detail_mnemonic, row rpt_row, col 044,
    pr_detail_completed, row rpt_row, col 067,
    pr_detail_histry
   ENDIF
   FOR (rslt = 1 TO cnvtint(result_cnt))
     IF (rslt != 1)
      rpt_row += 1
     ENDIF
     rslt_len = cnvtint(size(trim(result->resultlist[rslt].result,1))), rslt_ln_cnt = cnvtint((
      rslt_len/ 54))
     IF (rslt_ln_cnt < 1)
      rslt_ln_cnt = 1
     ENDIF
     row rpt_row, col 071, result->resultlist[rslt].result_corrected_ind
     FOR (rslt_ln = 1 TO rslt_ln_cnt)
       IF (rslt_ln != 1)
        rpt_row += 1
        IF (rpt_row > 58)
         BREAK, rpt_row += 1, long_text_page_wrap_ind = "Y"
        ENDIF
       ENDIF
       beg_pos = (((rslt_ln * 54) - 54)+ 1)
       IF ((((beg_pos+ 54) - 1) <= rslt_len))
        rslt_ln_len = 54
       ELSE
        rslt_ln_len = ((rslt_len - beg_pos)+ 1)
       ENDIF
       rslt_text = substring(beg_pos,rslt_ln_len,result->resultlist[rslt].result), row rpt_row, col
       073,
       rslt_text
     ENDFOR
     row rpt_row, col 088, result->resultlist[rslt].result_status_disp
     IF (cnvtint((rslt_len/ 54)) > 0
      AND (rslt_len > (rslt_ln_cnt * 54)))
      rpt_row += 1
      IF (rpt_row > 58)
       BREAK, rpt_row += 1, long_text_page_wrap_ind = "Y"
      ENDIF
      beg_pos = ((rslt_ln_cnt * 54)+ 1), rslt_ln_len = ((rslt_len - beg_pos)+ 1), rslt_text =
      substring(beg_pos,rslt_ln_len,result->resultlist[rslt].result),
      row rpt_row, col 077, rslt_text
     ENDIF
     IF (size(trim(result->resultlist[rslt].result,1)) > 30)
      rpt_row += 1
     ENDIF
     row rpt_row, col 105, result->resultlist[rslt].result_dt_tm"@SHORTDATE;;d",
     col 114, result->resultlist[rslt].result_dt_tm"@TIMENOSECONDS;;m", col 120,
     result->resultlist[rslt].result_username"##########"
   ENDFOR
   IF (long_text_page_wrap_ind="Y")
    long_text_page_wrap_ind = "N", rpt_row += 1
   ENDIF
   rslt_row = 0, detail_cnt += 1
  FOOT PAGE
   row 59, col 001, line,
   row + 1, col 001, captions->rpt_report_id,
   col 060, captions->rpt_page, col 067,
   curpage"###", col 108, captions->printed,
   col 117, curdate"@SHORTDATE;;d", col 126,
   curtime"@TIMENOSECONDS;;m", row + 1, col 113,
   captions->rpt_by, col 117, curuser
  FOOT REPORT
   rpt_row += 1
   IF (rpt_row > 57)
    BREAK
   ENDIF
   row 56, col 018, "____________________",
   row 58, col 001, captions->completed_orders
   IF (completed_order_cnt > 999)
    row 58, col 030, completed_order_cnt"##,###"
   ELSE
    row 58, col 030, completed_order_cnt"#####"
   ENDIF
   report_complete_ind = "Y"
  WITH maxrow = 63, nullreport, compress,
   nolandscape
 ;end select
 SET count1 += 1
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
 ENDIF
 SET reply->status_data.subeventstatus[count1].operationname = "print aborh reivew report"
 IF (report_complete_ind="Y"
  AND curqual > 0)
  IF (detail_cnt > 0)
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
  ELSE
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "no data found for specified date range"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_aborh_review"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "SCRIPT ERROR:  Report ended abnormally"
 ENDIF
 GO TO exit_script
#exit_script
END GO
