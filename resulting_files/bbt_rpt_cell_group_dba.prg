CREATE PROGRAM bbt_rpt_cell_group:dba
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
   1 reagent_cell = vc
   1 cell_grouping = vc
   1 group_name = vc
   1 active = vc
   1 cell_name = vc
   1 yes = vc
   1 no = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME: ")
 SET captions->reagent_cell = uar_i18ngetmessage(i18nhandle,"reagent_cell","REAGENT CELL TOOL")
 SET captions->cell_grouping = uar_i18ngetmessage(i18nhandle,"cell_grouping","CELL GROUPING")
 SET captions->group_name = uar_i18ngetmessage(i18nhandle,"group_name","GROUP NAME")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->cell_name = uar_i18ngetmessage(i18nhandle,"cell_name","CELL NAME")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_cell_group", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  cg.cell_group_cd, cg.cell_cd, cg.active_ind,
  c1602.display"####################", c1603.display"####################", c1603.active_ind
  FROM cell_group cg,
   code_value c1602,
   code_value c1603
  PLAN (cg)
   JOIN (c1602
   WHERE cg.cell_group_cd=c1602.code_value
    AND c1602.code_set=1602)
   JOIN (c1603
   WHERE cg.cell_cd=c1603.code_value)
  ORDER BY c1602.display
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;M",
   col 52, captions->reagent_cell, row + 1,
   col 52, captions->cell_grouping, row + 1,
   line = fillstring(122,"-"), line, row + 1,
   col 4, captions->group_name, col 30,
   captions->active, col 40, captions->cell_name,
   col 64, captions->active, row + 1,
   line, row + 1
  HEAD c1602.display
   row + 1, col 4, c1602.display
   IF (c1602.active_ind=1)
    col 32, captions->yes
   ELSEIF (c1602.active_ind=0)
    col 33, captions->no
   ENDIF
  DETAIL
   col 40, c1603.display
   IF (c1603.active_ind=1)
    col 66, captions->yes
   ELSEIF (c1603.active_ind=0)
    col 67, captions->no
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
