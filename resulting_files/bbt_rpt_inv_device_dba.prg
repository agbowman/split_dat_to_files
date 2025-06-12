CREATE PROGRAM bbt_rpt_inv_device:dba
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
   1 time = vc
   1 bb_inv_device_tool = vc
   1 device = vc
   1 device_type = vc
   1 status = vc
   1 relationship_type = vc
   1 association = vc
   1 active = vc
   1 inactive = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 rpt_by = vc
   1 end_of_report = vc
   1 interfaced = vc
   1 yes = vc
   1 no = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of date:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:  ")
 SET captions->bb_inv_device_tool = uar_i18ngetmessage(i18nhandle,"bb_inv_device_tool",
  "BLOOD BANK INVENTORY DEVICE TOOL")
 SET captions->device = uar_i18ngetmessage(i18nhandle,"device","Device")
 SET captions->device_type = uar_i18ngetmessage(i18nhandle,"device_type","Device Type")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","Status")
 SET captions->relationship_type = uar_i18ngetmessage(i18nhandle,"relationship_type",
  "Relationship Type")
 SET captions->association = uar_i18ngetmessage(i18nhandle,"association","Association")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"inactive","Inactive")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_INV_DEVICE")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","By:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->interfaced = uar_i18ngetmessage(i18nhandle,"interfaced","Interfaced")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","Yes")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","No")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_inv_device", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  bd.bb_inv_device_id, bd.description, device_type_disp = uar_get_code_display(bd.device_type_cd),
  bd.active_ind, reltn_type_disp = uar_get_code_display(bdr.device_r_type_cd), device_r_disp =
  uar_get_code_display(bdr.device_r_cd),
  bdr.active_ind, bdr.bb_inv_device_id
  FROM bb_inv_device bd,
   bb_inv_device_r bdr
  PLAN (bd
   WHERE bd.bb_inv_device_id > 0)
   JOIN (bdr
   WHERE bdr.bb_inv_device_id=outerjoin(bd.bb_inv_device_id))
  ORDER BY bd.description, bd.bb_inv_device_id, reltn_type_disp,
   device_r_disp
  HEAD REPORT
   select_ok_ind = 0, line = fillstring(130,"_")
  HEAD PAGE
   new_page = "Y", col 1, captions->as_of_date,
   col 14, curdate"@DATECONDENSED;;d", col 52,
   captions->database_audit, col 108, captions->page_no,
   col 120, curpage"##", row + 1,
   col 7, captions->time, col 14,
   curtime"@TIMENOSECONDS;;M", col 42, captions->bb_inv_device_tool,
   row + 2, line = fillstring(122,"-"), line,
   row + 1, col 001, captions->device,
   col 025, captions->device_type, col 040,
   captions->status, col 050, captions->interfaced,
   col 065, captions->relationship_type, col 090,
   captions->association, col 115, captions->status,
   row + 1, line, line = fillstring(125,"-"),
   row + 1
  HEAD bd.bb_inv_device_id
   IF (((row+ 3) > 57))
    BREAK
   ENDIF
   IF (new_page="Y")
    new_page = "N"
   ELSE
    row + 1
   ENDIF
   col 001, bd.description"############", col 25,
   device_type_disp
   IF (bd.active_ind=1)
    col 40, captions->active
   ELSE
    col 40, captions->inactive
   ENDIF
   IF (bd.interface_flag > 0)
    col 050, captions->yes
   ELSE
    col 050, captions->no
   ENDIF
  DETAIL
   IF (((row+ 1) > 57))
    BREAK, new_page = "N"
   ENDIF
   row + 1, col 065, reltn_type_disp"#######################",
   col 090, device_r_disp"##################"
   IF (bdr.active_ind=1)
    col 115, captions->active
   ELSE
    IF (bdr.bb_inv_device_r_id > 0)
     col 115, captions->inactive
    ENDIF
   ENDIF
  FOOT PAGE
   row 59, col 001, line,
   row + 1, col 001, captions->report_id,
   col 060, captions->page_no, col 067,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M", row + 1, col 113,
   captions->rpt_by, col 117, curuser
  FOOT REPORT
   row 62,
   CALL center(captions->end_of_report,1,132), select_ok_ind = 1
  WITH nocounter, compress, nolandscape,
   maxrow = 63, nullreport
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
#end_script
END GO
