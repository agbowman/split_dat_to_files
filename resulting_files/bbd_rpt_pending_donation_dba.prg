CREATE PROGRAM bbd_rpt_pending_donation:dba
 RECORD reply(
   1 report_name_list[*]
     2 report_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
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
   1 date = vc
   1 time = vc
   1 procedure = vc
   1 donor_name = vc
   1 donor_number = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 printed_by = vc
   1 end_of_report = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "D O N A T I O N S  P E N D I N G  R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"date","Date")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"procedure","Procedure")
 SET captions->donor_name = uar_i18ngetmessage(i18nhandle,"donor_name","Donor Name")
 SET captions->donor_number = uar_i18ngetmessage(i18nhandle,"donor_number","Donor Number")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_PENDING_DONATION")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->printed_by = uar_i18ngetmessage(i18nhandle,"printed_by","By:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET donate_cd = 0
 SET pending_cd = 0
 SET stat = 0
 SET qual_index = 0
 SET index1 = 0
 SET index2 = 0
 SET donorid_code = 0
 SET count1 = 0
 SET report_complete_ind = "N"
 SET line = fillstring(125,"_")
 SET cur_username = fillstring(10," ")
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=4
   AND c.cdf_meaning="DONORID"
   AND c.active_ind=1
  DETAIL
   donorid_code = c.code_value
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=14220
   AND cdf_meaning="DONATE"
  DETAIL
   donate_cd = c.code_value
 ;end select
 SELECT DISTINCT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=14224
   AND cdf_meaning="PENDING"
  DETAIL
   pending_cd = c.code_value
 ;end select
 SET cur_username = get_username(reqinfo->updt_id)
 SELECT DISTINCT INTO "CER_TEMP:pendingdonation.txt"
  dc.person_id, dc.encntr_id, pra.alias,
  dc.contact_dt_tm, dc.encntr_id, pe.name_full_formatted,
  en.bbd_procedure_cd, cv.display
  FROM bbd_donor_contact dc,
   (dummyt d1  WITH seq = 1),
   person pe,
   encounter en,
   person_alias pra,
   code_value cv
  PLAN (dc
   WHERE dc.active_ind=1
    AND dc.contact_type_cd=donate_cd
    AND dc.contact_status_cd=pending_cd)
   JOIN (pe
   WHERE dc.person_id=pe.person_id)
   JOIN (en
   WHERE en.encntr_id=dc.encntr_id)
   JOIN (cv
   WHERE en.bbd_procedure_cd=cv.code_value
    AND cv.code_set=14219)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (pra
   WHERE pra.person_alias_type_cd=donorid_code
    AND dc.person_id=pra.person_id)
  ORDER BY cnvtdatetime(dc.contact_dt_tm), dc.contact_id, 0
  HEAD PAGE
   col 1, captions->rpt_cerner_health_sys,
   CALL center(captions->rpt_title,1,125),
   col 104, captions->rpt_time, col 118,
   curtime"@TIMENOSECONDS;;M", row + 1, col 104,
   captions->rpt_as_of_date, col 118, curdate"@DATECONDENSED;;d",
   row + 3, col 11, captions->date,
   col 29, captions->time, col 48,
   captions->procedure, col 73, captions->donor_name,
   col 97, captions->donor_number, row + 1,
   col 7, "-------------", col 25,
   "-------------", col 43, "--------------------",
   col 68, "--------------------", col 93,
   "--------------------", row + 1
  DETAIL
   col 7, dc.contact_dt_tm"@DATETIMECONDENSED;;d", col 43,
   cv.display"####################", col 68, pe.name_full_formatted"####################",
   col 93, pra.alias"###################", row + 1
   IF (row > 56)
    BREAK
   ENDIF
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->rpt_id,
   col 58, captions->rpt_page, col 64,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M", row + 1, col 100,
   captions->printed_by, col 119, cur_username
  FOOT REPORT
   row 60, col 51, captions->end_of_report,
   report_complete_ind = "Y"
  WITH nullreport, counter, maxrow = 61,
   compress, nolandscape
 ;end select
 SET count1 = (count1+ 1)
 IF (count1 > 1)
  SET stat = alter(reply->status_data.subeventstatus,count1)
 ENDIF
 IF (report_complete_ind="Y")
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].sourceobjectname = "Report Complete"
  SET reply->status_data.subeventstatus[count1].operationname = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbd_rpt_pending_donation"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Report completed successfully"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].sourceobjectname = "Abnormal End"
  SET reply->status_data.subeventstatus[count1].operationname = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbd_rpt_pending_donation"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Report ended abnormally"
 ENDIF
 SET stat = alterlist(reply->report_name_list,1)
 SET reply->report_name_list[1].report_name = "CER_TEMP:pendingdonation.txt"
 GO TO exit_script
 DECLARE get_username(sub_person_id) = c10
 SUBROUTINE get_username(sub_person_id)
   SET sub_get_username = fillstring(10," ")
   SELECT INTO "nl:"
    pnl.username
    FROM prsnl pnl
    WHERE pnl.person_id=sub_person_id
     AND pnl.person_id != null
     AND pnl.person_id > 0.0
    DETAIL
     sub_get_username = pnl.username
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET inc_i18nhandle = 0
    SET inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev)
    SET sub_get_username = uar_i18ngetmessage(inc_i18nhandle,"inc_unknown","<Unknown>")
   ENDIF
   RETURN(sub_get_username)
 END ;Subroutine
#exit_script
END GO
