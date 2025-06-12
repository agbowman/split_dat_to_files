CREATE PROGRAM bbd_rpt_ship_order_priorities
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
   1 rpt_cerner = vc
   1 rpt_title = vc
   1 rpt_time = vc
   1 rpt_as_of_date = vc
   1 rpt_display = vc
   1 rpt_descript = vc
   1 rpt_effective = vc
   1 rpt_end_effective = vc
   1 rpt_active = vc
   1 rpt_yes = vc
   1 rpt_no = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 rpt_printed = vc
   1 rpt_by = vc
   1 rpt_end_report = vc
   1 rpt_complete = vc
   1 rpt_bbd_sop = vc
   1 rpt_abnormal = vc
   1 rpt_report_success = vc
   1 rpt_report_abnormal = vc
 )
 SET captions->rpt_cerner = uar_i18ngetmessage(i18nhandle,"rpt_cerner","Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "S H I P M E N T   O R D E R   P R I O R I T Y   R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->rpt_display = uar_i18ngetmessage(i18nhandle,"rpt_display","Order Priority Display")
 SET captions->rpt_descript = uar_i18ngetmessage(i18nhandle,"rpt_descript","Description")
 SET captions->rpt_effective = uar_i18ngetmessage(i18nhandle,"rpt_effective","Effective")
 SET captions->rpt_end_effective = uar_i18ngetmessage(i18nhandle,"rpt_end_effective","End Effective")
 SET captions->rpt_active = uar_i18ngetmessage(i18nhandle,"rpt_active","Active")
 SET captions->rpt_yes = uar_i18ngetmessage(i18nhandle,"rpt_yes","YES")
 SET captions->rpt_no = uar_i18ngetmessage(i18nhandle,"rpt_no","NO")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id",
  "Report ID: BBD_RPT_SHIP_ORDER_PRIORITIES")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->rpt_printed = uar_i18ngetmessage(i18nhandle,"rpt_printed","Printed:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","By:")
 SET captions->rpt_end_report = uar_i18ngetmessage(i18nhandle,"rpt_end_report",
  "* * * End of Report * * *")
 SET captions->rpt_complete = uar_i18ngetmessage(i18nhandle,"rpt_complete","Report Complete")
 SET captions->rpt_bbd_sop = uar_i18ngetmessage(i18nhandle,"rpt_bbd_sop",
  "bbd_rpt_ship_order_priorities")
 SET captions->rpt_abnormal = uar_i18ngetmessage(i18nhandle,"rpt_abnormal","Abnormal End")
 SET captions->rpt_report_success = uar_i18ngetmessage(i18nhandle,"rpt_report_success",
  "Report completed successfully")
 SET captions->rpt_abnormal = uar_i18ngetmessage(i18nhandle,"rpt_abnormal","Report ended abnormally")
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET report_complete_ind = "N"
 SET line = fillstring(125,"_")
 SET cur_username = fillstring(10," ")
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
 SET cur_username = get_username(reqinfo->updt_id)
 SELECT INTO "cer_temp:bbdorderpriorities.txt"
  c.*
  FROM code_value c
  PLAN (c
   WHERE c.code_set=17033
    AND c.code_value > 0)
  ORDER BY c.display_key, c.end_effective_dt_tm
  HEAD PAGE
   col 1, captions->rpt_cerner,
   CALL center(captions->rpt_title,1,125),
   col 107, captions->rpt_time, col 121,
   curtime"@TIMENOSECONDS;;m", row + 1, col 107,
   captions->rpt_as_of_date, col 119, curdate"@DATECONDENSED;;d",
   row + 3, col 13, captions->rpt_display,
   col 46, captions->rpt_descript, col 79,
   captions->rpt_effective, col 95, captions->rpt_end_effective,
   col 113, captions->rpt_active, row + 1,
   col 7, "------------------------------", col 42,
   "------------------------------", col 77, "-------------",
   col 95, "-------------", col 113,
   "------", row + 1
  DETAIL
   col 7, c.display"###################", col 42,
   c.description"###################", col 77, c.begin_effective_dt_tm"@DATECONDENSED;;d",
   col 85, c.begin_effective_dt_tm"@TIMENOSECONDS;;m", col 95,
   c.end_effective_dt_tm"@DATECONDENSED;;d", col 103, c.end_effective_dt_tm"@TIMENOSECONDS;;m"
   IF (c.active_ind=1)
    col 114, captions->rpt_yes
   ELSE
    col 114, captions->rpt_no
   ENDIF
   row + 1
   IF (row > 56)
    BREAK
   ENDIF
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->rpt_id,
   col 58, captions->rpt_page, col 64,
   curpage"###", col 109, captions->rpt_printed,
   col 119, curdate"@DATECONDENSED;;d", row + 1,
   col 109, captions->rpt_by, col 119,
   cur_username
  FOOT REPORT
   row 60, col 51, captions->rpt_end_report,
   report_complete_ind = "Y"
  WITH nullreport, counter, maxrow = 61,
   compress, nolandscape
 ;end select
 SET count1 = (count1+ 1)
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
 ENDIF
 IF (report_complete_ind="Y")
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationname = captions->rpt_complete
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectname = captions->rpt_bbd_sop
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = captions->rpt_report_success
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = captions->rpt_abnormal
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = captions->rpt_bbd_sop
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = captions->rpt_report_abnormal
 ENDIF
END GO
