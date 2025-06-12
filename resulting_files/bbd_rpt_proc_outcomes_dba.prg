CREATE PROGRAM bbd_rpt_proc_outcomes:dba
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
   1 donation_outcomes = vc
   1 rpt_as_of_date = vc
   1 procedure = vc
   1 outcome = vc
   1 order_processing = vc
   1 count_as_donation = vc
   1 add_product = vc
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
  "P R O C E D U R E  O U T C O M E S  R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->donation_outcomes = uar_i18ngetmessage(i18nhandle,"donation_outcomes",
  "(Donation Procedure Outcomes)")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"procedure","Procedure:")
 SET captions->outcome = uar_i18ngetmessage(i18nhandle,"outcome","Outcome")
 SET captions->order_processing = uar_i18ngetmessage(i18nhandle,"order_processing","Order Processing"
  )
 SET captions->count_as_donation = uar_i18ngetmessage(i18nhandle,"count_as_donation",
  "Count as Donation")
 SET captions->add_product = uar_i18ngetmessage(i18nhandle,"add_product","Add Product")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_PROC_OUTCOMES")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET line = fillstring(125,"_")
 SELECT INTO "cer_temp:bbdprocout.txt"
  procedure_disp = uar_get_code_display(p.procedure_cd), outcome_disp = uar_get_code_display(p
   .outcome_cd), p.*
  FROM procedure_outcome_r p
  WHERE p.procedure_outcome_id > 0
  ORDER BY p.procedure_cd
  HEAD PAGE
   col 1, captions->rpt_cerner_health_sys,
   CALL center(captions->rpt_title,1,125),
   col 104, captions->rpt_time, col 118,
   curtime"@TIMENOSECONDS;;M", row + 1,
   CALL center(captions->donation_outcomes,1,125),
   col 104, captions->rpt_as_of_date, col 118,
   curdate"@DATECONDENSED;;d"
  HEAD p.procedure_cd
   row + 2
   IF (row > 56)
    BREAK, row + 1
   ENDIF
   col 10, captions->procedure, col 23,
   procedure_disp"####################", row + 2
   IF (row > 56)
    BREAK, row + 1
   ENDIF
   col 23, captions->outcome, col 46,
   captions->order_processing, col 66, captions->count_as_donation,
   col 87, captions->add_product, col 100,
   captions->active, row + 1, col 23,
   "--------------------", col 46, "-------------------",
   col 66, "-----------------", col 87,
   "-----------", col 100, "------"
  DETAIL
   row + 1
   IF (row > 56)
    BREAK, row + 1
   ENDIF
   col 23, outcome_disp"###################"
   IF (p.order_processing_ind=1)
    col 54, captions->yes
   ELSE
    col 54, captions->no
   ENDIF
   IF (p.count_as_donation_ind=1)
    col 74, captions->yes
   ELSE
    col 74, captions->no
   ENDIF
   IF (p.add_product_ind=1)
    col 89, captions->yes
   ELSE
    col 89, captions->no
   ENDIF
   IF (p.active_ind=1)
    col 102, captions->yes
   ELSE
    col 102, captions->no
   ENDIF
   IF (row > 56)
    BREAK, row + 1
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
