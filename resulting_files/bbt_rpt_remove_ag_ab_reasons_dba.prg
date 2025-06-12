CREATE PROGRAM bbt_rpt_remove_ag_ab_reasons:dba
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
 DECLARE cur_username = vc WITH protect, noconstant("")
 DECLARE report_page = i4 WITH noconstant(0)
 DECLARE row_count = i4 WITH noconstant(60)
 DECLARE bump_lines = i4 WITH noconstant(0)
 SET cur_username = fillstring(10," ")
 SET cur_username = get_username(reqinfo->updt_id)
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
   1 reason_tool = vc
   1 antigen_antibody_removal = vc
   1 display_name = vc
   1 description = vc
   1 active = vc
   1 yes = vc
   1 no = vc
   1 printed = vc
   1 rpt_by = vc
   1 end_of_report = vc
   1 report_id = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO: ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME:  ")
 SET captions->reason_tool = uar_i18ngetmessage(i18nhandle,"reason_tool","REASON TOOL")
 SET captions->antigen_antibody_removal = uar_i18ngetmessage(i18nhandle,"antigen_antibody_removal",
  "ANTIGEN ANTIBODY REMOVAL REASONS")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id",
  "Report ID: BBT_RPT_REMOVE_AG_AB_REASONS.PRG")
 SET captions->display_name = uar_i18ngetmessage(i18nhandle,"display_name","DISPLAY NAME")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"description","DESCRIPTION")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","By:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_rpt_remove_ag_ab_reasons", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  cv.display, cv.description, cv.active_ind
  FROM code_value cv
  WHERE cv.code_set=4032000
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   IF (row_count >= 55)
    IF (report_page > 1)
     row + 1
    ENDIF
    row 0, row_count = 0, bump_lines = 0,
    col 1, captions->as_of_date, col 14,
    curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
    col 108, captions->page_no, col 120,
    curpage"##", row + 1, row_count = (row_count+ 1),
    col 7, captions->time, col 14,
    curtime"@TIMENOSECONDS;;M", col 53, captions->reason_tool,
    row + 1, row_count = (row_count+ 1), col 41,
    captions->antigen_antibody_removal, row + 2, row_count = (row_count+ 2),
    line = fillstring(122,"-"), line, row + 1,
    row_count = (row_count+ 1), col 4, captions->display_name,
    col 30, captions->description, col 62,
    captions->active, row + 1, row_count = (row_count+ 1),
    line, row + 2, row_count = (row_count+ 2)
   ELSE
    row + 1
   ENDIF
  DETAIL
   col 4, cv.display, col 30,
   cv.description
   IF (cv.active_ind=1)
    col 62, captions->yes
   ELSEIF (cv.active_ind=0)
    col 62, captions->no
   ENDIF
   row + 1, row_count = row
   IF (row_count >= 55)
    BREAK
   ENDIF
  FOOT PAGE
   IF (row_count >= 55)
    bump_lines = (row_count - 57), row- (bump_lines)
   ELSE
    row + (55 - (row_count * 2))
   ENDIF
   report_page = (report_page+ 1), col 1, line,
   row + 1, col 001, captions->report_id,
   col 057, captions->page_no, col 067,
   report_page";L", col 103, captions->printed,
   col 112, curdate"@DATECONDENSED;;d", col 121,
   curtime"@TIMENOSECONDS;;M", row + 1, col 108,
   captions->rpt_by, col 112, cur_username
  FOOT REPORT
   row + 3, col 49, captions->end_of_report,
   select_ok_ind = 1
  WITH nullreport, nocounter, compress,
   nolandscape
 ;end select
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
  SET rpt_cnt = (rpt_cnt+ 1)
  SET stat = alterlist(reply->rpt_list,rpt_cnt)
  SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 ENDIF
END GO
