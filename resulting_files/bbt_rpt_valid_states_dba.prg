CREATE PROGRAM bbt_rpt_valid_states:dba
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
   1 rpt_as_of_date = vc
   1 database_audit = vc
   1 page_no = vc
   1 rpt_time = vc
   1 valid_states_tool = vc
   1 active_values_only = vc
   1 product_category = vc
   1 app_process = vc
   1 states = vc
   1 end_of_report = vc
 )
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:  ")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","TIME:  ")
 SET captions->valid_states_tool = uar_i18ngetmessage(i18nhandle,"valid_states_tool",
  "VALID STATES FOR APPLICATION TOOL")
 SET captions->active_values_only = uar_i18ngetmessage(i18nhandle,"active_values_only",
  "ACTIVE VALUES ONLY")
 SET captions->product_category = uar_i18ngetmessage(i18nhandle,"product_category",
  "PRODUCT CATEGORY: ")
 SET captions->app_process = uar_i18ngetmessage(i18nhandle,"app_process","APPLICATION PROCESS: ")
 SET captions->states = uar_i18ngetmessage(i18nhandle,"states","STATES: ")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_valid_states", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  vs.process_cd, vs.state_cd, vs.category_cd,
  vs.active_ind, process_disp = uar_get_code_display(vs.process_cd), state_disp =
  uar_get_code_display(vs.state_cd),
  category_disp = uar_get_code_display(vs.category_cd)
  FROM valid_state vs
  WHERE vs.active_ind=1
  ORDER BY category_disp, process_disp
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->rpt_as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->rpt_time, col 14, curtime"@TIMENOSECONDS;;M",
   col 45, captions->valid_states_tool, row + 1,
   col 50, captions->active_values_only, row + 2,
   line = fillstring(122,"="), line, row + 1
  HEAD category_disp
   row + 1, line2 = fillstring(122,"-"), line2,
   row + 1, col 2, captions->product_category,
   col 25, category_disp, row + 1,
   line2, row + 1
  HEAD process_disp
   row + 2, col 2, captions->app_process,
   col 25, process_disp, col 55,
   captions->states
  DETAIL
   row + 1, col 65, state_disp
  FOOT REPORT
   row + 3,
   CALL center(captions->end_of_report,1,125), select_ok_ind = 1
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
