CREATE PROGRAM bbd_rpt_outcomes:dba
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
   1 rpt_outcomes = vc
   1 rpt_as_of_date = vc
   1 rpt_display = vc
   1 rpt_description = vc
   1 rpt_type = vc
   1 rpt_effective = vc
   1 rpt_end_effective = vc
   1 rpt_active = vc
   1 rpt_yes = vc
   1 rpt_no = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 rpt_printed = vc
   1 rpt_end_report = vc
 )
 SET captions->rpt_cerner = uar_i18ngetmessage(i18nhandle,"rpt_cerner","Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title","O U T C O M E S   R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_outcomes = uar_i18ngetmessage(i18nhandle,"rpt_outcomes","(Outcomes)")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->rpt_display = uar_i18ngetmessage(i18nhandle,"rpt_display","Outcome Display")
 SET captions->rpt_description = uar_i18ngetmessage(i18nhandle,"rpt_description",
  "Outcome Description")
 SET captions->rpt_type = uar_i18ngetmessage(i18nhandle,"rpt_type","Outcome Type")
 SET captions->rpt_effective = uar_i18ngetmessage(i18nhandle,"rpt_effective","Effective")
 SET captions->rpt_end_effective = uar_i18ngetmessage(i18nhandle,"rpt_end_effective","End Effective")
 SET captions->rpt_active = uar_i18ngetmessage(i18nhandle,"rpt_active","Active")
 SET captions->rpt_yes = uar_i18ngetmessage(i18nhandle,"rpt_yes","YES")
 SET captions->rpt_no = uar_i18ngetmessage(i18nhandle,"rpt_no","NO")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_OUTCOMES")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->rpt_printed = uar_i18ngetmessage(i18nhandle,"rpt_printed","Printed:")
 SET captions->rpt_end_report = uar_i18ngetmessage(i18nhandle,"rpt_end_report",
  "* * * End of Report * * *")
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
 DECLARE rpt_cnt = i2 WITH noconstant(0)
 DECLARE get_cvtext(p1) = c100
 SET line = fillstring(125,"_")
 EXECUTE cpm_create_file_name_logical "bbd_outcomes", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  c.*, cs.*
  FROM code_value c,
   common_data_foundation cs
  PLAN (c
   WHERE c.code_set=14221
    AND c.code_value > 0)
   JOIN (cs
   WHERE cs.code_set=c.code_set
    AND cs.cdf_meaning=c.cdf_meaning)
  ORDER BY c.display
  HEAD PAGE
   col 1, captions->rpt_cerner,
   CALL center(captions->rpt_title,1,125),
   col 107, captions->rpt_time, col 121,
   curtime"@TIMENOSECONDS;;m", row + 1,
   CALL center(captions->rpt_outcomes,1,125),
   col 107, captions->rpt_as_of_date, col 119,
   curdate"@DATECONDENSED;;d", row + 2, col 3,
   captions->rpt_display, col 27, captions->rpt_description,
   col 55, captions->rpt_type, col 79,
   captions->rpt_effective, col 94, captions->rpt_end_effective,
   col 109, captions->rpt_active, row + 1,
   col 3, "----------------------", col 27,
   "--------------------------", col 55, "----------------------",
   col 79, "-------------", col 94,
   "-------------", col 109, "------",
   row + 1
  DETAIL
   c.code_value, col 3, c.display"######################",
   col 27, c.description"##########################", col 55,
   cs.display"######################", col 79, c.begin_effective_dt_tm"@DATECONDENSED;;d",
   col 87, c.begin_effective_dt_tm"@TIMENOSECONDS;;m", col 94,
   c.end_effective_dt_tm"@DATECONDENSED;;d", col 102, c.end_effective_dt_tm"@TIMENOSECONDS;;m"
   IF (c.active_ind=1)
    col 110, captions->rpt_yes
   ELSE
    col 110, captions->rpt_no
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
   col 119, curdate"@DATECONDENSED;;d"
  FOOT REPORT
   row 60, col 51, captions->rpt_end_report
  WITH nullreport, nocounter, compress,
   nolandscape, maxrow = 61
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = concat("cer_print:",cpm_cfn_info->file_name)
 SET reply->status_data.status = "S"
END GO
