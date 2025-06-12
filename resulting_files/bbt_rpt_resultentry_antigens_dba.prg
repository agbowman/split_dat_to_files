CREATE PROGRAM bbt_rpt_resultentry_antigens:dba
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
 SET line = fillstring(120,"_")
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
   1 rpt_name = vc
   1 time = vc
   1 special_testing = vc
   1 resultentry_antigens = vc
   1 as_of_date = vc
   1 display_name = vc
   1 description = vc
   1 positive = vc
   1 negative = vc
   1 active = vc
   1 yes = vc
   1 no = vc
   1 page_no = vc
   1 printed = vc
   1 end_of_report = vc
 )
 SET captions->rpt_name = uar_i18ngetmessage(i18nhandle,"rpt_special_testing","DATABASE AUDIT")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->special_testing = uar_i18ngetmessage(i18nhandle,"special_testing",
  "(Special Testing Tool)")
 SET captions->resultentry_antigens = uar_i18ngetmessage(i18nhandle,"resultentry_antigens",
  "Result Entry Antigens")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->display_name = uar_i18ngetmessage(i18nhandle,"display_name","Display Name")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"description","Description")
 SET captions->positive = uar_i18ngetmessage(i18nhandle,"positive","Positive")
 SET captions->negative = uar_i18ngetmessage(i18nhandle,"negative","Negative")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_resultentry_antigens", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  cv.code_value, cv.active_ind, cv.display,
  field_value_disp = uar_get_code_display(cnvtreal(ce.field_value))
  FROM code_value cv,
   code_value_extension ce
  PLAN (cv
   WHERE cv.code_set=4502006)
   JOIN (ce
   WHERE outerjoin(cv.code_value)=ce.code_value)
  ORDER BY cv.active_ind DESC, cv.display, cv.code_value
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   CALL center(captions->rpt_name,1,140), col 1, captions->as_of_date,
   col 14, curdate"@DATECONDENSED;;d", row + 1,
   CALL center(captions->resultentry_antigens,1,140), col 1, captions->time,
   col 14, curtime"@TIMENOSECONDS;;M", row + 1,
   CALL center(captions->special_testing,1,140), row + 1, col 1,
   captions->display_name, col 32, captions->description,
   col 73, captions->positive, col 90,
   captions->negative, col 105, captions->active,
   row + 1, col 1, "------------------------------",
   col 32, "----------------------------------------", col 73,
   "---------------", col 90, "--------------",
   col 105, "----------"
  HEAD cv.code_value
   row + 1
   IF (row > 44)
    BREAK, row + 1
   ENDIF
   col 1, cv.display"##############################", col 32,
   cv.description"########################################"
   IF (cv.active_ind=1)
    col 105, captions->yes
   ELSEIF (cv.active_ind=0)
    col 105, captions->no
   ENDIF
  DETAIL
   IF (ce.field_name="Positive"
    AND ce.field_value != "0")
    col 73, field_value_disp"##########"
   ENDIF
   IF (ce.field_name="Negative"
    AND ce.field_value != "0")
    col 90, field_value_disp"##########"
   ENDIF
   IF (row >= 55)
    BREAK
   ENDIF
  FOOT PAGE
   row + 3, col 1, line,
   row + 1, col 60, captions->page_no,
   col 94, curpage"###", col 90,
   captions->printed, col 100, curdate"@DATECONDENSED;;d",
   col 110, curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   row + 3,
   CALL center(captions->end_of_report,0,140), select_ok_ind = 1
  WITH nullreport, counter, compress,
   nolandscape
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
