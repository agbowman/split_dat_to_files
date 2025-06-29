CREATE PROGRAM bbt_rpt_vis_insp:dba
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
   1 reasons_with_meanings = vc
   1 visual_inspection_results = vc
   1 display_name = vc
   1 description = vc
   1 meaning = vc
   1 active = vc
   1 yes = vc
   1 no = vc
   1 end_of_report = vc
 )
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:  ")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","TIME:  ")
 SET captions->reasons_with_meanings = uar_i18ngetmessage(i18nhandle,"reasons_with_meanings",
  "REASONS WITH MEANINGS")
 SET captions->visual_inspection_results = uar_i18ngetmessage(i18nhandle,"visual_inspection_results",
  "VISUAL INSPECTION RESULTS")
 SET captions->display_name = uar_i18ngetmessage(i18nhandle,"display_name","DISPLAY NAME")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"description","DESCRIPTION")
 SET captions->meaning = uar_i18ngetmessage(i18nhandle,"meaning","MEANING")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_vis_insp", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  cv.display, cv.description, cv.cdf_meaning,
  cv.active_ind, cd.cdf_meaning, cd.display
  FROM code_value cv,
   common_data_foundation cd
  PLAN (cv
   WHERE cv.code_set=1655)
   JOIN (cd
   WHERE cd.code_set=outerjoin(1655)
    AND cd.cdf_meaning=outerjoin(cv.cdf_meaning))
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->rpt_as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->rpt_time, col 14, curtime"@TIMENOSECONDS;;M",
   col 49, captions->reasons_with_meanings, row + 1,
   col 47, captions->visual_inspection_results, row + 2,
   line = fillstring(122,"-"), line, row + 1,
   col 4, captions->display_name, col 30,
   captions->description, col 62, captions->meaning,
   col 92, captions->active, row + 1,
   line, row + 2
  DETAIL
   col 2, cv.display, col 22,
   cv.description, col 64, cd.display
   IF (cv.active_ind=1)
    col 94, captions->yes
   ELSEIF (cv.active_ind=0)
    col 95, captions->no
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
END GO
