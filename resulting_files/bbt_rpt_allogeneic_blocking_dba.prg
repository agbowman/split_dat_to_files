CREATE PROGRAM bbt_rpt_allogeneic_blocking:dba
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
   1 rpt_autologous = vc
   1 rpt_selected = vc
   1 display = vc
   1 status = vc
   1 dispense_override = vc
   1 active = vc
   1 inactive = vc
   1 allow_override = vc
   1 warn_only = vc
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
  "Blood Bank Allogeneic Blocking Tool")
 SET captions->rpt_autologous = uar_i18ngetmessage(i18nhandle,"rpt_autologous",
  "AUTOLOGOUS/DIRECTED PRODUCT")
 SET captions->rpt_selected = uar_i18ngetmessage(i18nhandle,"rpt_selected",
  "SELECTED ALLOGENEIC PROCUCT(S)")
 SET captions->display = uar_i18ngetmessage(i18nhandle,"display","Display")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","Status")
 SET captions->dispense_override = uar_i18ngetmessage(i18nhandle,"dispense_override",
  "Dispense Override")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"inactive","Inactive")
 SET captions->allow_override = uar_i18ngetmessage(i18nhandle,"allow_override","Allow Override")
 SET captions->warn_only = uar_i18ngetmessage(i18nhandle,"warn_only","Warn Only")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id",
  "Report ID: BBT_RPT_ALLOGENEIC_BLOCKING")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","By:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_allo_block", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  db.product_cd, dbp.product_cd, autodir_disp = uar_get_code_display(db.product_cd),
  db.active_ind, db.allow_override_ind, allogeneic_disp = uar_get_code_display(dbp.product_cd),
  dbp.active_ind
  FROM bb_dspns_block db,
   (dummyt d_dbp  WITH seq = 1),
   bb_dspns_block_product dbp
  PLAN (db
   WHERE db.dispense_block_id != null
    AND db.dispense_block_id > 0)
   JOIN (d_dbp
   WHERE d_dbp.seq=1)
   JOIN (dbp
   WHERE db.dispense_block_id=dbp.dispense_block_id
    AND dbp.block_product_id != null
    AND dbp.block_product_id > 0)
  ORDER BY autodir_disp, db.dispense_block_id, allogeneic_disp
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
   row + 1, col 001, captions->rpt_autologous,
   col 070, captions->rpt_selected, row + 1,
   col 001, captions->display, col 030,
   captions->status, col 045, captions->dispense_override,
   col 070, captions->display, col 103,
   captions->status, row + 1, line,
   line = fillstring(125,"-")
  HEAD db.dispense_block_id
   IF (((row+ 3) > 57))
    BREAK
   ENDIF
   IF (new_page="Y")
    new_page = "N", row + 1
   ELSE
    row + 2
   ENDIF
   col 001, autodir_disp"############"
   IF (db.active_ind=1)
    col 30, captions->active
   ELSE
    col 30, captions->inactive
   ENDIF
   IF (db.allow_override_ind=1)
    col 45, captions->allow_override
   ELSE
    col 45, captions->warn_only
   ENDIF
  DETAIL
   IF (((row+ 1) > 57))
    BREAK, new_page = "N"
   ENDIF
   row + 1, col 70, allogeneic_disp"##################"
   IF (dbp.active_ind=1)
    col 103, captions->active
   ELSE
    col 103, captions->inactive
   ENDIF
  FOOT PAGE
   row 59, col 001, line,
   row + 1, col 001, captions->report_id,
   col 060, captions->rpt_page, col 067,
   curpage"###", col 102, captions->printed,
   col 111, curdate"@DATECONDENSED;;d", col 120,
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
