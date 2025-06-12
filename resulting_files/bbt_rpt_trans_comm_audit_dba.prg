CREATE PROGRAM bbt_rpt_trans_comm_audit:dba
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
   1 transfusion_committee = vc
   1 active_values_only = vc
   1 product = vc
   1 single_transfusions = vc
   1 format_pre_hours = vc
   1 format_post_hours = vc
   1 discrete_task = vc
   1 pre_hours = vc
   1 post_hours = vc
   1 all_results = vc
   1 yes = vc
   1 no = vc
   1 end_of_report = vc
 )
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","AS OF DATE:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO: ")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","TIME:  ")
 SET captions->transfusion_committee = uar_i18ngetmessage(i18nhandle,"transfusion_committee",
  "TRANSFUSION COMMITTEE REPORT PARAMETERS")
 SET captions->active_values_only = uar_i18ngetmessage(i18nhandle,"active_values_only",
  "ACTIVE VALUES ONLY - PRODUCT TOOL")
 SET captions->product = uar_i18ngetmessage(i18nhandle,"product","PRODUCT:  ")
 SET captions->single_transfusions = uar_i18ngetmessage(i18nhandle,"single_transfusions",
  "SINGLE TRANSFUSIONS: ")
 SET captions->format_pre_hours = uar_i18ngetmessage(i18nhandle,"format_pre_hours","PRE HOURS: ")
 SET captions->format_post_hours = uar_i18ngetmessage(i18nhandle,"format_post_hours","POST HOURS: ")
 SET captions->discrete_task = uar_i18ngetmessage(i18nhandle,"discrete_task","DISCRETE TASK")
 SET captions->pre_hours = uar_i18ngetmessage(i18nhandle,"pre_hours","PRE HOURS")
 SET captions->post_hours = uar_i18ngetmessage(i18nhandle,"post_hours","POST HOURS")
 SET captions->all_results = uar_i18ngetmessage(i18nhandle,"all_results","ALL RESULTS?")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_trans_comm", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  tc.trans_commit_id, tc.product_cd, tc.single_trans_ind,
  tc.single_pre_hours"####", tc.single_post_hours"####", tc.active_ind,
  tca.trans_commit_id, tca.task_assay_cd, tca.pre_hours"####",
  tca.post_hours"####", tca.all_results_ind, tca.active_ind,
  cv1604.display"####################", cv14003.display"####################"
  FROM transfusion_committee tc,
   trans_commit_assay tca,
   code_value cv1604,
   code_value cv14003
  PLAN (tc
   WHERE tc.active_ind=1)
   JOIN (cv1604
   WHERE tc.product_cd=cv1604.code_value)
   JOIN (tca
   WHERE tc.trans_commit_id=tca.trans_commit_id
    AND tca.active_ind=1)
   JOIN (cv14003
   WHERE tca.task_assay_cd=cv14003.code_value)
  ORDER BY cv1604.display, tc.product_cd
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->rpt_as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->rpt_time, col 14, curtime"@TIMENOSECONDS;;M",
   col 42, captions->transfusion_committee, row + 1,
   col 45, captions->active_values_only, row + 2,
   line = fillstring(122,"="), line, row + 1
  HEAD cv1604.display
   row + 2, line2 = fillstring(122,"-"), line2,
   row + 1, col 2, captions->product,
   col 13, cv1604.display, col 35,
   captions->single_transfusions
   IF (tc.single_trans_ind=0)
    col 56, captions->no
   ELSEIF (tc.single_trans_ind=1)
    col 56, captions->yes
   ENDIF
   col 60, captions->format_pre_hours
   IF (tc.single_trans_ind=1)
    col 70, tc.single_pre_hours
   ENDIF
   col 83, captions->format_post_hours
   IF (tc.single_trans_ind=1)
    col 95, tc.single_post_hours
   ENDIF
   row + 1, line2, row + 1,
   col 4, captions->discrete_task, col 44,
   captions->pre_hours, col 59, captions->post_hours,
   col 80, captions->all_results, row + 1,
   col 2, "-------------------", col 40,
   "---------------", col 55, "---------------",
   col 80, "------------"
  DETAIL
   row + 1, col 2, cv14003.display,
   col 40, tca.pre_hours, col 55,
   tca.post_hours
   IF (tca.all_results_ind=0)
    col 83, captions->no
   ELSEIF (tca.all_results_ind=1)
    col 83, captions->yes
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
