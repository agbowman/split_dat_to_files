CREATE PROGRAM bbd_rpt_org_pref:dba
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
   1 rpt_title_2 = vc
   1 rpt_time = vc
   1 rpt_as_of_date = vc
   1 rpt_destroy = vc
   1 rpt_require = vc
   1 rpt_allow = vc
   1 rpt_positive = vc
   1 rpt_quar = vc
   1 rpt_org = vc
   1 rpt_product = vc
   1 rpt_testing = vc
   1 rpt_expired = vc
   1 rpt_results = vc
   1 rpt_task = vc
   1 rpt_quar_reason = vc
   1 rpt_active = vc
   1 rpt_yes = vc
   1 rpt_no = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 rpt_printed = vc
   1 rpt_by = vc
   1 rpt_end_report = vc
   1 rpt_complete = vc
   1 rpt_bbd_cont = vc
   1 rpt_abnormal = vc
   1 rpt_report_success = vc
   1 rpt_report_abnormal = vc
 )
 SET captions->rpt_cerner = uar_i18ngetmessage(i18nhandle,"rpt_cerner","Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "ORGANIZATION AND INVENTORY AREA PREFERENCES")
 SET captions->rpt_title_2 = uar_i18ngetmessage(i18nhandle,"rpt_title_2","REPORT")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->rpt_destroy = uar_i18ngetmessage(i18nhandle,"rpt_destroy","Destroy")
 SET captions->rpt_require = uar_i18ngetmessage(i18nhandle,"rpt_require","Require")
 SET captions->rpt_allow = uar_i18ngetmessage(i18nhandle,"rpt_allow","Allow")
 SET captions->rpt_positive = uar_i18ngetmessage(i18nhandle,"rpt_positive","Positive")
 SET captions->rpt_quar = uar_i18ngetmessage(i18nhandle,"rpt_quar","Quarantine")
 SET captions->rpt_org = uar_i18ngetmessage(i18nhandle,"rpt_org","Organization/Inventory Area")
 SET captions->rpt_product = uar_i18ngetmessage(i18nhandle,"rpt_product","Product?")
 SET captions->rpt_testing = uar_i18ngetmessage(i18nhandle,"rpt_testing","Testing?")
 SET captions->rpt_expired = uar_i18ngetmessage(i18nhandle,"rpt_expired","Expired?")
 SET captions->rpt_results = uar_i18ngetmessage(i18nhandle,"rpt_results","Results")
 SET captions->rpt_task = uar_i18ngetmessage(i18nhandle,"rpt_task","Task Assay")
 SET captions->rpt_quar_reason = uar_i18ngetmessage(i18nhandle,"rpt_quar_reason","Quarantine Reason")
 SET captions->rpt_active = uar_i18ngetmessage(i18nhandle,"rpt_active","Active")
 SET captions->rpt_yes = uar_i18ngetmessage(i18nhandle,"rpt_yes","YES")
 SET captions->rpt_no = uar_i18ngetmessage(i18nhandle,"rpt_no","NO")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_ORG_PREF")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->rpt_printed = uar_i18ngetmessage(i18nhandle,"rpt_printed","Printed:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","By:")
 SET captions->rpt_end_report = uar_i18ngetmessage(i18nhandle,"rpt_end_report",
  "* * * End of Report * * *")
 SET captions->rpt_complete = uar_i18ngetmessage(i18nhandle,"rpt_complete","Report Complete")
 SET captions->rpt_bbd_cont = uar_i18ngetmessage(i18nhandle,"rpt_bbd_cont","bbd_rpt_org_pref")
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
 SET cur_username = get_username(reqinfo->updt_id)
 SELECT INTO "cer_temp:bbdorgpref.txt"
  quar_reason_disp = uar_get_code_display(q.quar_reason_cd), q.active_ind, s.*,
  organization =
  IF (s.inventory_area_cd > 0) substring(1,27,uar_get_code_display(s.inventory_area_cd))
  ELSE substring(1,27,o.org_name)
  ENDIF
  FROM org_shipment s,
   organization o,
   accept_quar_reason q
  PLAN (s
   WHERE s.org_shipment_id > 0)
   JOIN (o
   WHERE o.organization_id=outerjoin(s.organization_id))
   JOIN (q
   WHERE q.org_shipment_id=outerjoin(s.org_shipment_id)
    AND q.active_ind=outerjoin(1))
  ORDER BY organization, quar_reason_disp
  HEAD PAGE
   col 1, captions->rpt_cerner,
   CALL center(captions->rpt_title,1,125),
   col 107, captions->rpt_time, col 121,
   curtime"@TIMENOSECONDS;;m", row + 1,
   CALL center(captions->rpt_title_2,1,125),
   col 107, captions->rpt_as_of_date, col 119,
   curdate"@DATECONDENSED;;d", row + 2, col 29,
   captions->rpt_allow, col 38, captions->rpt_quar,
   row + 1, col 1, captions->rpt_org,
   col 29, captions->rpt_expired, col 38,
   captions->rpt_product, col 47, captions->rpt_quar_reason,
   row + 1, col 1, "---------------------------",
   col 29, "--------", col 38,
   "--------", col 47, "--------------------",
   row + 1
  HEAD organization
   col 1, organization
   IF (s.accept_expired_prod_ind=1)
    col 31, captions->rpt_yes
   ELSE
    col 31, captions->rpt_no
   ENDIF
   IF (s.accept_quarantined_prod_ind=1)
    col 40, captions->rpt_yes
   ELSE
    col 40, captions->rpt_no
   ENDIF
  HEAD quar_reason_disp
   IF (q.org_shipment_id > 0)
    col 49, quar_reason_disp"####################"
   ENDIF
   row + 1
  DETAIL
   IF (row > 56)
    BREAK
   ENDIF
  FOOT  quar_reason_disp
   row + 0
  FOOT  organization
   row + 0
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
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = captions->rpt_bbd_cont
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = captions->rpt_report_success
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = captions->rpt_abnormal
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = captions->rpt_bbd_cont
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = captions->rpt_report_abnormal
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
