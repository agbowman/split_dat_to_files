CREATE PROGRAM bbt_rpt_alpha_trans:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
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
   1 as_of_date = vc
   1 database_audit = vc
   1 page_no = vc
   1 time = vc
   1 alpha_translation = vc
   1 barcode = vc
   1 translation = vc
   1 active = vc
   1 yes = vc
   1 no = vc
   1 end_of_report = vc
   1 report_id = vc
   1 printed = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of date:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","Database Audit")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page No: ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:  ")
 SET captions->alpha_translation = uar_i18ngetmessage(i18nhandle,"alpha_translation",
  "Alpha Translation List")
 SET captions->barcode = uar_i18ngetmessage(i18nhandle,"barcode","Barcode")
 SET captions->translation = uar_i18ngetmessage(i18nhandle,"translation","Translation")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","Yes")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","No")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * END OF REPORT * * * ")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_ALPHA_TRANS"
  )
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_alpha_trans", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  bba.alpha_barcode_value, bba.alpha_translation_value, bba.active_ind
  FROM bb_alpha_translation bba
  WHERE bba.alpha_translation_id > 0
  HEAD REPORT
   line = fillstring(126,"-"), select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 116,
   curpage"####", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;M",
   col 52, captions->alpha_translation, row + 2,
   line, row + 1, col 37,
   captions->barcode, col 54, captions->translation,
   col 75, captions->active, row + 1,
   line
  DETAIL
   row + 1
   IF (row > 56)
    BREAK
   ENDIF
   col 38, bba.alpha_barcode_value, col 57,
   bba.alpha_translation_value
   IF (bba.active_ind=1)
    col 76, captions->yes
   ELSE
    col 76, captions->no
   ENDIF
  FOOT REPORT
   row 57, col 49, captions->end_of_report,
   select_ok_ind = 1
  FOOT PAGE
   row 58, col 1, line,
   row + 1, col 1, captions->report_id,
   col 100, captions->printed, col 110,
   curdate"@DATECONDENSED;;d", col 120, curtime"@TIMENOSECONDS;;M"
  WITH nullreport, nocounter, compress,
   nolandscape
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
