CREATE PROGRAM bbt_rpt_bb_test_group:dba
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
   1 audit_report = vc
   1 page_no = vc
   1 time = vc
   1 rpt_blood_bank = vc
   1 test_group = vc
   1 orderable = vc
   1 display = vc
   1 description = vc
   1 status = vc
   1 sequence = vc
   1 active = vc
   1 inactive = vc
   1 report_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 rpt_by = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of date:  ")
 SET captions->audit_report = uar_i18ngetmessage(i18nhandle,"audit_report","Audit Report")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page No: ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:  ")
 SET captions->rpt_blood_bank = uar_i18ngetmessage(i18nhandle,"rpt_blood_bank",
  "Blood Bank Result Group Tool List")
 SET captions->test_group = uar_i18ngetmessage(i18nhandle,"test_group","TEST GROUP")
 SET captions->orderable = uar_i18ngetmessage(i18nhandle,"orderable","ORDERABLE(S)")
 SET captions->display = uar_i18ngetmessage(i18nhandle,"display","Display")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"description","Description")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","Status")
 SET captions->sequence = uar_i18ngetmessage(i18nhandle,"sequence","Sequence")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"inactive","Inactive")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id",
  "Report ID: BBT_RPT_BB_TEST_GROUP")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","By:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET hold_code_value = 0
 SET hold_display = fillstring(15," ")
 SET hold_desc = fillstring(30," ")
 SET hold_mnemonic = fillstring(30," ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_bb_test_grp", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  btg.bb_test_group_id, btg.test_group_display, btg.test_group_description,
  btg.active_ind, bgc.catalog_cd, bgc.sequence,
  catalog_disp = uar_get_code_display(bgc.catalog_cd), bgc.active_ind
  FROM bb_test_group btg,
   (dummyt d_bgc  WITH seq = 1),
   bb_group_component bgc
  PLAN (btg)
   JOIN (d_bgc
   WHERE d_bgc.seq=1)
   JOIN (bgc
   WHERE bgc.bb_test_group_id=btg.bb_test_group_id)
  ORDER BY btg.bb_test_group_id, bgc.active_ind DESC, bgc.sequence,
   bgc.bb_group_component_id
  HEAD REPORT
   line = fillstring(130,"_"), select_ok_ind = 0
  HEAD PAGE
   new_page = "Y", col 1, captions->as_of_date,
   col 14, curdate"@DATECONDENSED;;d", col 52,
   captions->audit_report, col 108, captions->page_no,
   col 120, curpage"##", row + 1,
   col 7, captions->time, col 14,
   curtime"@TIMENOSECONDS;;M", col 42, captions->rpt_blood_bank,
   row + 2, line = fillstring(122,"-"), line,
   row + 1, col 001, captions->test_group,
   col 080, captions->orderable, row + 1,
   col 001, captions->display, col 023,
   captions->description, col 067, captions->status,
   col 080, captions->display, col 103,
   captions->sequence, col 115, captions->status,
   row + 1, line, line = fillstring(125,"-")
  HEAD btg.bb_test_group_id
   IF (((row+ 3) > 57))
    BREAK
   ENDIF
   IF (new_page="Y")
    new_page = "N", row + 1
   ELSE
    row + 2
   ENDIF
   col 001, btg.test_group_display"####################", col 023,
   btg.test_group_description"#########################################"
   IF (btg.active_ind=1)
    col 67, captions->active
   ELSE
    col 67, captions->inactive
   ENDIF
  DETAIL
   IF (((row+ 1) > 57))
    BREAK, new_page = "N"
   ENDIF
   row + 1, col 80, catalog_disp"####################",
   col 105, bgc.sequence"###"
   IF (bgc.active_ind=1)
    col 115, captions->active
   ELSE
    col 115, captions->inactive
   ENDIF
  FOOT PAGE
   row 59, col 001, line,
   row + 1, col 001, captions->report_id,
   col 060, captions->rpt_page, col 067,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M", row + 1, col 113,
   captions->rpt_by, col 117, curuser
  FOOT REPORT
   row 62,
   CALL center(captions->end_of_report,1,132), select_ok_ind = 1
  WITH outerjoin(d_btg), nocounter, compress,
   nolandscape, maxrow = 63, nullreport
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
