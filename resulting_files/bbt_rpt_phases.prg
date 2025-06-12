CREATE PROGRAM bbt_rpt_phases
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
   1 required_testing = vc
   1 phase_grouping = vc
   1 group = vc
   1 includes_phases = vc
   1 name = vc
   1 active = vc
   1 sequence = vc
   1 required = vc
   1 yes = vc
   1 no = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME: ")
 SET captions->required_testing = uar_i18ngetmessage(i18nhandle,"required_testing",
  "REQUIRED TESTING PHASES TOOL")
 SET captions->phase_grouping = uar_i18ngetmessage(i18nhandle,"phase_grouping","PHASE GROUPING")
 SET captions->group = uar_i18ngetmessage(i18nhandle,"group","* GROUP *")
 SET captions->includes_phases = uar_i18ngetmessage(i18nhandle,"includes_phases",
  " * INCLUDES PHASES * ")
 SET captions->name = uar_i18ngetmessage(i18nhandle,"name","NAME")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->sequence = uar_i18ngetmessage(i18nhandle,"sequence","SEQUENCE")
 SET captions->required = uar_i18ngetmessage(i18nhandle,"required","REQUIRED")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * E N D  O F  R E P O R T * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_phases", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  pg.phase_group_id, pg.phase_group_cd, pg.sequence,
  pg.required_ind, dta.task_assay_cd, dta.mnemonic"##########",
  c1601.display"###############"
  FROM phase_group pg,
   discrete_task_assay dta,
   code_value c1601
  PLAN (pg
   WHERE pg.phase_group_id > 0)
   JOIN (c1601
   WHERE pg.phase_group_cd=c1601.code_value)
   JOIN (dta
   WHERE pg.task_assay_cd=dta.task_assay_cd)
  ORDER BY c1601.display, pg.sequence
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;M",
   col 46, captions->required_testing, row + 1,
   col 52, captions->phase_grouping, row + 1,
   line = fillstring(122,"-"), line, row + 1,
   col 11, captions->group, col 28,
   "|", col 40, captions->includes_phases,
   row + 1, col 4, captions->name,
   col 20, captions->active, col 28,
   "|", col 36, captions->name,
   col 57, captions->sequence, col 70,
   captions->active, col 80, captions->required,
   row + 1, line, row + 1
  HEAD c1601.display
   row + 1, col 4, c1601.display
   IF (c1601.active_ind=0)
    col 20, captions->no
   ELSEIF (c1601.active_ind=1)
    col 20, captions->yes
   ENDIF
  DETAIL
   col 35, dta.mnemonic, col 55,
   pg.sequence
   IF (pg.active_ind=0)
    col 71, captions->no
   ELSEIF (pg.active_ind=1)
    col 71, captions->yes
   ENDIF
   IF (pg.required_ind=0)
    col 83, captions->no
   ELSEIF (pg.required_ind=1)
    col 83, captions->yes
   ENDIF
   row + 1
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
