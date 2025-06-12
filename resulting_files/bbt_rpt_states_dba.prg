CREATE PROGRAM bbt_rpt_states:dba
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
   1 reasons = vc
   1 report_title = vc
   1 display_name = vc
   1 description = vc
   1 meaning = vc
   1 active = vc
   1 yes = vc
   1 no = vc
   1 end_of_report = vc
 )
 SET reply->status_data.status = "F"
 DECLARE codeset = i4 WITH protect, noconstant(request->codeset)
 DECLARE rpt_filename = vc WITH protect, noconstant("")
 DECLARE rpt_active_pos = i4 WITH protect, noconstant(0)
 DECLARE rpt_inactive_pos = i4 WITH protect, noconstant(0)
 IF (((codeset=1610) OR (codeset=0)) )
  SET captions->report_title = uar_i18ngetmessage(i18nhandle,"product_states_report_title",
   "INVENTORY (PRODUCT) STATES")
  SET codeset = 1610
  SET rpt_filename = "bbt_states"
 ELSE
  SELECT INTO "nl:"
   cvs.display
   FROM code_value_set cvs
   WHERE cvs.code_set=codeset
   DETAIL
    captions->report_title = cvs.display, rpt_filename = concat("bbt_cs_",cnvtstring(codeset))
   WITH nocounter
  ;end select
 ENDIF
 SET rpt_active_pos = 123
 SET rpt_inactive_pos = (rpt_active_pos+ 1)
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO: ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME:  ")
 SET captions->reasons = uar_i18ngetmessage(i18nhandle,"reasons","REASONS WITH MEANINGS")
 SET captions->display_name = uar_i18ngetmessage(i18nhandle,"display_name","DISPLAY NAME")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"description","DESCRIPTION")
 SET captions->meaning = uar_i18ngetmessage(i18nhandle,"meaning","MEANING")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical rpt_filename, "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  cv_display = substring(1,30,cv.display), cv_desc = substring(1,41,cv.description), cv.cdf_meaning,
  cv.active_ind, cv.collation_seq, cd.cdf_meaning,
  meaning = substring(1,40,cd.display)
  FROM code_value cv,
   common_data_foundation cd
  PLAN (cv
   WHERE cv.code_set=codeset)
   JOIN (cd
   WHERE cd.code_set=outerjoin(codeset)
    AND cd.cdf_meaning=outerjoin(cv.cdf_meaning))
  ORDER BY cv.collation_seq
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;DATE", col 52, captions->database_audit,
   col 113, captions->page_no, col 125,
   curpage"##", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;MTIME",
   col 49, captions->reasons, row + 1,
   col 45, captions->report_title, row + 2,
   line = fillstring(128,"-"), line, row + 1,
   col 1, captions->display_name, col 34,
   captions->description, col 78, captions->meaning,
   col 121, captions->active, row + 1,
   line, row + 2
  DETAIL
   col 3, cv_display, col 36,
   cv_desc, col 80, meaning
   IF (cv.active_ind=1)
    col rpt_active_pos, captions->yes
   ELSEIF (cv.active_ind=0)
    col rpt_inactive_pos, captions->no
   ENDIF
   row + 1
   IF (row >= 58)
    BREAK
   ENDIF
  FOOT REPORT
   row + 3, col 49, captions->end_of_report,
   select_ok_ind = 1
  WITH nullreport, nocounter, compress,
   nolandscape
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
#exitscript
END GO
