CREATE PROGRAM bbd_rpt_proc_reasons:dba
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
   1 donation_reasons = vc
   1 rpt_as_of_date = vc
   1 procedure = vc
   1 outcome = vc
   1 reason = vc
   1 calculate_deferral = vc
   1 days_ineligible = vc
   1 hours_ineligible = vc
   1 same_day = vc
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
  "P R O C E D U R E  R E A S O N S  R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->donation_reasons = uar_i18ngetmessage(i18nhandle,"donation_reasons",
  "(Donation Procedure Reasons)")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"procedure","Procedure:")
 SET captions->outcome = uar_i18ngetmessage(i18nhandle,"outcome","Outcome:")
 SET captions->reason = uar_i18ngetmessage(i18nhandle,"reason","Reason")
 SET captions->calculate_deferral = uar_i18ngetmessage(i18nhandle,"calculate_deferral",
  "Calculate Deferral")
 SET captions->days_ineligible = uar_i18ngetmessage(i18nhandle,"days_ineligible","Days Ineligible")
 SET captions->hours_ineligible = uar_i18ngetmessage(i18nhandle,"hours_ineligible","Hours Ineligible"
  )
 SET captions->same_day = uar_i18ngetmessage(i18nhandle,"same_day","Same Day")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_PROC_REASONS")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET line = fillstring(125,"_")
 SELECT INTO "cer_temp:bbdprocreas.txt"
  procedure_disp = uar_get_code_display(p.procedure_cd), outcome_disp = uar_get_code_display(p
   .outcome_cd), reason_disp = uar_get_code_display(p.reason_cd),
  calc_deferral_disp = uar_get_code_display(p.deferral_expire_cd), p.*
  FROM proc_outcome_reason_r p
  WHERE p.active_ind=1
  ORDER BY p.procedure_cd, p.outcome_cd
  HEAD PAGE
   col 1, captions->rpt_cerner_health_sys,
   CALL center(captions->rpt_title,1,125),
   col 104, captions->rpt_time, col 118,
   curtime"@TIMENOSECONDS;;M", row + 1,
   CALL center(captions->donation_reasons,1,125),
   col 104, captions->rpt_as_of_date, col 118,
   curdate"@DATECONDENSED;;d"
  HEAD p.outcome_cd
   row + 2
   IF (row > 56)
    BREAK, row + 1
   ENDIF
   col 10, captions->procedure, col 23,
   procedure_disp"####################", col 49, captions->outcome,
   col 60, outcome_disp"####################", row + 2
   IF (row > 56)
    BREAK, row + 1
   ENDIF
   col 23, captions->reason, col 46,
   captions->calculate_deferral, col 68, captions->days_ineligible,
   col 88, captions->hours_ineligible, col 117,
   captions->same_day, row + 1
   IF (row > 56)
    BREAK, row + 1
   ENDIF
   col 23, "--------------------", col 46,
   "------------------", col 68, "---------------",
   col 88, "----------------", col 117,
   "--------"
  DETAIL
   row + 1
   IF (row > 56)
    BREAK, row + 1
   ENDIF
   col 23, reason_disp"###################", col 46,
   calc_deferral_disp"###################", col 75, p.days_ineligible"########",
   col 96, p.hours_ineligible"########"
   IF (p.same_day_ind=1)
    col 120, captions->yes
   ELSE
    col 120, captions->no
   ENDIF
   IF (row > 56)
    BREAK, row + 1
   ENDIF
  FOOT PAGE
   row 58, col 1, line,
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
