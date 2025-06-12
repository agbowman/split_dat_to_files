CREATE PROGRAM bbd_rpt_ven_sites:dba
 RECORD reply(
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
   1 rpt_cerner_health_sys = vc
   1 rpt_title = vc
   1 rpt_time = vc
   1 rpt_as_of_date = vc
   1 venipunct_site_disp = vc
   1 venipunct_site_desc = vc
   1 effective = vc
   1 end_effective = vc
   1 active = vc
   1 yes = vc
   1 no = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 printed_by = vc
   1 end_of_report = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "V E N I P U N C T U R E   S I T E S   R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->venipunct_site_disp = uar_i18ngetmessage(i18nhandle,"venipunct_site_disp",
  "Venipuncture Site Display")
 SET captions->venipunct_site_desc = uar_i18ngetmessage(i18nhandle,"venipunct_site_desc",
  "Venipuncture Site Description")
 SET captions->effective = uar_i18ngetmessage(i18nhandle,"effective","Effective")
 SET captions->end_effective = uar_i18ngetmessage(i18nhandle,"end_effective","End Effective")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"acttive","Active")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_VEN_SITES")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->printed_by = uar_i18ngetmessage(i18nhandle,"printed_by","By:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET count1 = 0
 SET report_complete_ind = "N"
 SET line = fillstring(125,"_")
 SET cur_username = fillstring(10," ")
 SET cur_username = get_username(reqinfo->updt_id)
 SELECT INTO "cer_temp:bbdvensites.txt"
  c.display, c.description, c.begin_effective_dt_tm,
  c.end_effective_dt_tm, c.active_ind
  FROM donor_venipuncture_site d,
   code_value c
  PLAN (d
   WHERE d.venipuncture_id > 0)
   JOIN (c
   WHERE d.body_site_cd=c.code_value
    AND c.code_set=1028)
  ORDER BY c.display
  HEAD PAGE
   col 1, captions->rpt_cerner_health_sys,
   CALL center(captions->rpt_title,1,125),
   col 104, captions->rpt_time, col 118,
   curtime"@TIMENOSECONDS;;M", row + 1, col 104,
   captions->rpt_as_of_date, col 118, curdate"@DATECONDENSED;;d",
   row + 3, col 9, captions->venipunct_site_disp,
   col 42, captions->venipunct_site_desc, col 79,
   captions->effective, col 95, captions->end_effective,
   col 113, captions->active, row + 1,
   col 7, "------------------------------", col 42,
   "------------------------------", col 77, "-------------",
   col 95, "-------------", col 113,
   "------", row + 1
  DETAIL
   col 7, c.display"###################", col 42,
   c.description"###################", col 77, c.begin_effective_dt_tm"@DATECONDENSED;;d",
   col 85, c.begin_effective_dt_tm"@TIMENOSECONDS;;M", col 95,
   c.end_effective_dt_tm"@DATECONDENSED;;d", col 103, c.end_effective_dt_tm"@TIMENOSECONDS;;M"
   IF (d.active_ind=1)
    col 114, captions->yes
   ELSE
    col 114, captions->no
   ENDIF
   row + 1
   IF (row > 56)
    BREAK
   ENDIF
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->rpt_id,
   col 58, captions->rpt_page, col 64,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M", row + 1, col 100,
   captions->printed_by, col 110, cur_username
  FOOT REPORT
   row 60, col 51, captions->end_of_report,
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
  SET reply->status_data.subeventstatus[count1].operationname = "Report Complete"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbd_rpt_ven_sites"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Report completed successfully"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "Abnormal End"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbd_rpt_ven_sites"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Report ended abnormally"
 ENDIF
 GO TO exit_script
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
#exit_script
END GO
