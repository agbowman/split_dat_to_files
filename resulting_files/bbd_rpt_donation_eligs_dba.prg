CREATE PROGRAM bbd_rpt_donation_eligs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
   1 donation_eligibility = vc
   1 rpt_as_of_date = vc
   1 procedure = vc
   1 previous_procedure = vc
   1 days_until_eligible = vc
   1 effective = vc
   1 end_effective = vc
   1 active = vc
   1 yes = vc
   1 no = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 end_of_report = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "P R O C E D U R E  E L I G I B I L I T Y  R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->donation_eligibility = uar_i18ngetmessage(i18nhandle,"donation_eligibility",
  "(Donation Procedure Eligibility)")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"procedure","Procedure")
 SET captions->previous_procedure = uar_i18ngetmessage(i18nhandle,"previous_procedure",
  "Previous Procedure")
 SET captions->days_until_eligible = uar_i18ngetmessage(i18nhandle,"days_until_eligible",
  "Days Until Eligible")
 SET captions->effective = uar_i18ngetmessage(i18nhandle,"effective","Effective")
 SET captions->end_effective = uar_i18ngetmessage(i18nhandle,"end_effective","End Effective")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_DONATION_ELIGS")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET line = fillstring(125,"_")
 SELECT INTO "cer_temp:bbdprocelig.txt"
  procedure_disp = uar_get_code_display(p.procedure_cd), prev_procedure_disp = uar_get_code_display(p
   .prev_procedure_cd), p.*
  FROM procedure_eligibility_r p
  WHERE p.procedure_eligibility_id > 0
  ORDER BY p.procedure_cd
  HEAD PAGE
   col 1, captions->rpt_cerner_health_sys,
   CALL center(captions->rpt_title,1,125),
   col 104, captions->rpt_time, col 118,
   curtime"@TIMENOSECONDS;;M", row + 1,
   CALL center(captions->donation_eligibility,1,125),
   col 104, captions->rpt_as_of_date, col 118,
   curdate"@DATECONDENSED;;d"
  HEAD p.procedure_cd
   row + 2
   IF (row > 56)
    BREAK, row + 1
   ENDIF
   col 10, captions->procedure, col 23,
   procedure_disp"#########################", row + 2
   IF (row > 56)
    BREAK, row + 1
   ENDIF
   col 23, captions->previous_procedure, col 51,
   captions->days_until_eligible, col 72, captions->effective,
   col 86, captions->end_effective, col 104,
   captions->active, row + 1, col 23,
   "-------------------------", col 51, "-------------------",
   col 72, "-------------", col 86,
   "---------------", col 104, "------"
  DETAIL
   row + 1
   IF (row > 56)
    BREAK, row + 1
   ENDIF
   col 23, prev_procedure_disp"########################", col 59,
   p.days_until_eligible, col 72, p.begin_effective_dt_tm"@DATETIMECONDENSED;;d",
   col 86, p.end_effective_dt_tm"@DATETIMECONDENSED;;d"
   IF (p.active_ind=1)
    col 105, captions->yes
   ELSE
    col 105, captions->no
   ENDIF
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->rpt_id,
   col 58, captions->rpt_page, col 64,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   row 60, col 51, captions->end_of_report
  WITH nullreport, counter, compress,
   nolandscape, maxrow = 61
 ;end select
 SET reply->status_data.status = "S"
END GO
