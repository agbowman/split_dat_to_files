CREATE PROGRAM bbd_rpt_exception:dba
 IF ((request->called_from_script_ind=0))
  RECORD reply(
    1 qual[*]
      2 filename = c50
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
   1 rpt_cerner_health_sys = vc
   1 rpt_title = vc
   1 rpt_time = vc
   1 rpt_as_of_date = vc
   1 begin_dt = vc
   1 end_dt = vc
   1 ssn = vc
   1 donor_number = vc
   1 donation_procedure = vc
   1 override_reason = vc
   1 personnel_name = vc
   1 date = vc
   1 rpt_id_doneligrein = vc
   1 rpt_id_regeligrein = vc
   1 rpt_page = vc
   1 end_of_report = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "B L O O D   B A N K   E X C E P T I O N   R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->begin_dt = uar_i18ngetmessage(i18nhandle,"begin_dt","Beginning Date:")
 SET captions->end_dt = uar_i18ngetmessage(i18nhandle,"end_dt","Ending Date:")
 SET captions->ssn = uar_i18ngetmessage(i18nhandle,"ssn","Social Security Number")
 SET captions->donor_number = uar_i18ngetmessage(i18nhandle,"donor_number","Donor Number")
 SET captions->donation_procedure = uar_i18ngetmessage(i18nhandle,"donation_procedure",
  "Donation Procedure")
 SET captions->override_reason = uar_i18ngetmessage(i18nhandle,"override_reason","Override Reason")
 SET captions->personnel_name = uar_i18ngetmessage(i18nhandle,"personnel_name","Personnel Name")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"date","Date:")
 SET captions->rpt_id_doneligrein = uar_i18ngetmessage(i18nhandle,"rpt_id_doneligrein",
  "Report ID: BBD_RPT_EXCEPTION (DONELIGREIN)")
 SET captions->rpt_id_regeligrein = uar_i18ngetmessage(i18nhandle,"rpt_id_regeligrein",
  "Report ID: BBD_RPT_EXCEPTION (REGELIGREIN)")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET reply->status = "S"
 SET code_cnt = 1
 SET question_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(1661,"BBDSSN",code_cnt,question_cd)
 IF (question_cd=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_exception"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve code value for code set 1661 and cdf meaning BBDSSN."
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET answer_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(1659,"Y",code_cnt,answer_cd)
 IF (answer_cd=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_exception"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve code value for code set 1659 and cdf meaning Y."
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET preference_cd = 0.0
 SELECT INTO "nl:"
  ans = a.answer
  FROM answer a
  WHERE a.question_cd=question_cd
   AND a.active_ind=1
  DETAIL
   IF (ans=cnvtstring(answer_cd))
    stat = uar_get_meaning_by_codeset(4,"SSN",code_cnt,preference_cd)
   ELSE
    stat = uar_get_meaning_by_codeset(4,"DONORID",code_cnt,preference_cd)
   ENDIF
  WITH nocounter
 ;end select
 IF (preference_cd=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_exception"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve cdf_meaning for preference answer."
  GO TO exit_script
 ENDIF
 SET preference = uar_get_code_meaning(preference_cd)
 IF (trim(request->batch_selection) > " ")
  SET store_date_time = cnvtdatetime(curdate,0000)
  SET store_date = datetimeadd(store_date_time,- (1))
  SET request->beg_dt_tm = store_date
  SET store_date_time = cnvtdatetime(curdate,2359)
  SET store_date = datetimeadd(store_date_time,- (1))
  SET request->end_dt_tm = store_date
  SET request->printer_name = trim(request->output_dist)
 ENDIF
 SET report_complete_ind = "N"
 SET idx = 0
 SET line = fillstring(130,"-")
 IF (((uar_get_code_meaning(request->exception_type_cd)="REGELIGREIN") OR ((request->
 exception_type_cd=0.0))) )
  SET sfiledate = format(curdate,"mmdd;;d")
  SET sfiletime = substring(1,6,format(curtime3,"hhmmss;;s"))
  SET sfilename = build("BBex",sfiledate,sfiletime)
  SET report_name1 = concat("CER_TEMP:",trim(sfilename),".txt")
  SET idx = (idx+ 1)
  SET stat = alterlist(reply->qual,idx)
  SET reply->qual[idx].filename = report_name1
  IF ((request->exception_type_cd=0.0))
   SET code_cnt = 1
   SET exception_cd = 0.0
   SET stat = uar_get_meaning_by_codeset(14072,"REGELIGREIN",code_cnt,exception_cd)
   IF (exception_cd=0.0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_exception"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error in retrieve code value for code set 14072 with code meaning REGELIGREIN."
    GO TO exit_script
   ENDIF
  ELSE
   SET exception_cd = request->exception_type_cd
  ENDIF
  SET exception = uar_get_code_display(exception_cd)
  SET report_complete_ind = "N"
  SELECT INTO concat("CER_TEMP:",trim(sfilename),".txt")
   override_reason = uar_get_code_display(bb.override_reason_cd), username = substring(1,25,usr
    .name_full_formatted), date = bb.active_status_dt_tm"@DATECONDENSED;;d",
   procedure = uar_get_code_display(e.bbd_procedure_cd), donor_ssn = substring(1,20,cnvtalias(pa
     .alias,ap.format_mask)), donor_nbr = substring(1,20,pa.alias)
   FROM bb_exception bb,
    prsnl usr,
    person_alias pa,
    alias_pool ap,
    encounter e,
    bbd_donor_contact b,
    dummyt d2,
    dummyt d3,
    dummyt d4,
    dummyt d5,
    dummyt d6
   PLAN (bb
    WHERE (bb.exception_type_cd=request->exception_type_cd)
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND bb.active_ind=1)
    JOIN (d2)
    JOIN (usr
    WHERE bb.updt_id=usr.person_id
     AND usr.active_ind=1)
    JOIN (d3)
    JOIN (b
    WHERE b.contact_id=bb.donor_contact_id
     AND b.active_ind=1)
    JOIN (d4)
    JOIN (e
    WHERE e.encntr_id=b.encntr_id
     AND e.active_ind=1)
    JOIN (d5)
    JOIN (pa
    WHERE pa.person_id=bb.person_id
     AND pa.person_alias_type_cd=preference_cd
     AND pa.active_ind=1)
    JOIN (d6)
    JOIN (ap
    WHERE ap.alias_pool_cd=pa.alias_pool_cd
     AND ap.active_ind=1)
   HEAD REPORT
    report_complete_ind = "Y", beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime
    (request->end_dt_tm),
    col 0, captions->rpt_cerner_health_sys,
    CALL center(captions->rpt_title,1,125),
    col 104, captions->rpt_time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->rpt_as_of_date, col 118, curdate"@DATECONDENSED;;d",
    col 33, captions->begin_dt, col + 2,
    beg_dt_tm"@DATECONDENSED;;d", col + 2, beg_dt_tm"@TIMENOSECONDS;;M",
    col + 2, captions->end_dt, col + 2,
    end_dt_tm"@DATECONDENSED;;d", col + 2, end_dt_tm"@TIMENOSECONDS;;M",
    row + 1, col 0, exception,
    row + 1
   HEAD PAGE
    IF (preference="SSN")
     col 0, captions->ssn
    ELSE
     col 0, captions->donor_number
    ENDIF
    col 30, captions->donation_procedure, col 55,
    captions->override_reason, col 80, captions->personnel_name,
    col 105, captions->date, row + 1,
    col 0, "----------------------------", col 30,
    "-----------------------", col 55, "-----------------------",
    col 80, "-----------------------", col 105,
    "-------", row + 1
   DETAIL
    IF (preference="SSN")
     col 0, donor_ssn
    ELSE
     col 0, donor_nbr
    ENDIF
    col 30, procedure, col 55,
    override_reason, col 80, username,
    col 105, date, row + 1
    IF (row > 56)
     BREAK
    ENDIF
   FOOT PAGE
    row 57, col 0, line,
    row + 1, captions->rpt_id_regeligrein, col 58,
    captions->rpt_page, col + 1, curpage"###;L"
   FOOT REPORT
    row + 1, col 51, captions->end_of_report
   WITH nocounter, dontcare = usr, dontcare = pa,
    dontcare = ap, dontcare = e, dontcare = b,
    outerjoin = d2, outerjoin = d3, outerjoin = d4,
    outerjoin = d5, outerjoin = d6, compress,
    nolandscape, nullreport
  ;end select
  IF (report_complete_ind="N")
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_exception"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bb_exception"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error on printing exception REGELIGREIN report."
   GO TO exit_script
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="DONELIGREIN") OR ((request->
 exception_type_cd=0.0))) )
  SET sfiledate = format(curdate,"mmdd;;d")
  SET sfiletime = substring(1,6,format(curtime3,"hhmmss;;s"))
  SET sfilename = build("BBex",sfiledate,sfiletime)
  SET report_name2 = concat("CER_TEMP:",trim(sfilename),".txt")
  SET idx = (idx+ 1)
  SET stat = alterlist(reply->qual,idx)
  SET reply->qual[idx].filename = report_name2
  IF ((request->exception_type_cd=0.0))
   SET code_cnt = 1
   SET exception_cd = 0.0
   SET stat = uar_get_meaning_by_codeset(14072,"DONELIGREIN",code_cnt,exception_cd)
   IF (exception_cd=0.0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_exception"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error in retrieve code value for code set 14072 with code meaning DONELIGREIN."
    GO TO exit_script
   ENDIF
  ELSE
   SET exception_cd = request->exception_type_cd
  ENDIF
  SET exception = uar_get_code_display(exception_cd)
  SET report_complete_ind = "N"
  SELECT INTO concat("CER_TEMP:",trim(sfilename),".txt")
   override_reason = uar_get_code_display(bb.override_reason_cd), username = substring(1,25,usr
    .name_full_formatted), date = bb.active_status_dt_tm"@DATECONDENSED;;d",
   procedure = uar_get_code_display(dr.procedure_cd), donor_ssn = substring(1,20,cnvtalias(pa.alias,
     ap.format_mask)), donor_nbr = substring(1,20,pa.alias)
   FROM bb_exception bb,
    prsnl usr,
    bbd_donation_results dr,
    person_alias pa,
    alias_pool ap,
    dummyt d2,
    dummyt d3,
    dummyt d4,
    dummyt d5
   PLAN (bb
    WHERE (bb.exception_type_cd=request->exception_type_cd)
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND bb.active_ind=1)
    JOIN (d2)
    JOIN (usr
    WHERE bb.updt_id=usr.person_id
     AND usr.active_ind=1)
    JOIN (d3)
    JOIN (dr
    WHERE dr.contact_id=bb.donor_contact_id
     AND dr.active_ind=1)
    JOIN (d4)
    JOIN (pa
    WHERE pa.person_id=bb.person_id
     AND pa.person_alias_type_cd=preference_cd
     AND pa.active_ind=1)
    JOIN (d5)
    JOIN (ap
    WHERE ap.alias_pool_cd=pa.alias_pool_cd
     AND ap.active_ind=1)
   HEAD REPORT
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm), col 1,
    captions->rpt_cerner_health_sys,
    CALL center(captions->rpt_title,1,125), col 104,
    captions->rpt_time, col 118, curtime"@TIMENOSECONDS;;M",
    row + 1, col 104, captions->rpt_as_of_date,
    col 118, curdate"@DATECONDENSED;;d", col 33,
    captions->begin_dt, col + 2, beg_dt_tm"@DATECONDENSED;;d",
    col + 2, beg_dt_tm"@TIMENOSECONDS;;M", col + 2,
    captions->end_dt, col + 2, end_dt_tm"@DATECONDENSED;;d",
    col + 2, end_dt_tm"@TIMENOSECONDS;;M", row + 1,
    col 0, exception, row + 1
   HEAD PAGE
    IF (preference="SSN")
     col 0, captions->ssn
    ELSE
     col 0, captions->donor_number
    ENDIF
    col 30, captions->donation_procedure, col 55,
    captions->override_reason, col 80, captions->personnel_name,
    col 105, captions->date, row + 1,
    col 0, "----------------------------", col 30,
    "-----------------------", col 55, "-----------------------",
    col 80, "-----------------------", col 105,
    "-------", row + 1
   DETAIL
    IF (preference="SSN")
     col 0, donor_ssn
    ELSE
     col 0, donor_nbr
    ENDIF
    col 30, procedure, col 55,
    override_reason, col 80, username,
    col 105, date, row + 1
    IF (row > 56)
     BREAK
    ENDIF
   FOOT PAGE
    row 57, col 0, line,
    row + 1, captions->rpt_id_doneligrein, col 58,
    captions->rpt_page, col + 1, curpage"###",
    report_complete_ind = "Y"
   FOOT REPORT
    row + 1, col 51, captions->end_of_report
   WITH nocounter, dontcare = usr, dontcare = dr,
    dontcare = pa, dontcare = ap, outerjoin = d2,
    outerjoin = d3, outerjoin = d4, outerjoin = d5,
    compress, nolandscape, nullreport
  ;end select
  IF (report_complete_ind="N")
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_exception"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bb_exception"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
    "Error on printing exception DONELIGREIN report.")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->batch_selection > " "))
  SET spool report_name1 value(request->printer_name)
  SET spool report_name2 value(request->printer_name)
 ENDIF
#exit_script
 IF ((reply->status="F"))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
