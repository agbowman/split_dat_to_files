CREATE PROGRAM bbd_rpt_cont_cond_prod:dba
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
   1 rpt_container = vc
   1 rpt_condition = vc
   1 rpt_product = vc
   1 rpt_qty = vc
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
   1 rpt_temperature = vc
 )
 SET captions->rpt_cerner = uar_i18ngetmessage(i18nhandle,"rpt_cerner","Cerner Health Systems")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "C O N T A I N E R   T Y P E  /  C O N D I T I O N  /")
 SET captions->rpt_title_2 = uar_i18ngetmessage(i18nhandle,"rpt_title_2",
  "S H I P M E N T   T E M P E R A T U R E  /  P R O D U C T  R E P O R T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->rpt_container = uar_i18ngetmessage(i18nhandle,"rpt_container"," Container Type")
 SET captions->rpt_condition = uar_i18ngetmessage(i18nhandle,"rpt_condition"," Condition")
 SET captions->rpt_product = uar_i18ngetmessage(i18nhandle,"rpt_product"," Product")
 SET captions->rpt_qty = uar_i18ngetmessage(i18nhandle,"rpt_qty"," Qty")
 SET captions->rpt_active = uar_i18ngetmessage(i18nhandle,"rpt_active","Active")
 SET captions->rpt_yes = uar_i18ngetmessage(i18nhandle,"rpt_yes","YES")
 SET captions->rpt_no = uar_i18ngetmessage(i18nhandle,"rpt_no","NO")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_CONT_COND_PROD")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->rpt_printed = uar_i18ngetmessage(i18nhandle,"rpt_printed","Printed:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","By:")
 SET captions->rpt_end_report = uar_i18ngetmessage(i18nhandle,"rpt_end_report",
  "* * * End of Report * * *")
 SET captions->rpt_complete = uar_i18ngetmessage(i18nhandle,"rpt_complete","Report Complete")
 SET captions->rpt_bbd_cont = uar_i18ngetmessage(i18nhandle,"rpt_bbd_cont","bbd_rpt_cont_cond_prod")
 SET captions->rpt_abnormal = uar_i18ngetmessage(i18nhandle,"rpt_abnormal","Abnormal End")
 SET captions->rpt_report_success = uar_i18ngetmessage(i18nhandle,"rpt_report_success",
  "Report completed successfully")
 SET captions->rpt_abnormal = uar_i18ngetmessage(i18nhandle,"rpt_abnormal","Report ended abnormally")
 SET captions->rpt_temperature = uar_i18ngetmessage(i18nhandle,"rpt_temperature","Temperature")
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
 SELECT INTO "cer_temp:bbdcontcondprod.txt"
  container_type_disp = uar_get_code_display(c.container_type_cd), condition_disp =
  uar_get_code_display(c.condition_cd), product_disp = uar_get_code_display(p.product_cd),
  temperature_disp = substring(1,15,concat(trim(cnvtstring(c.cntnr_temperature_value))," ",
    uar_get_code_display(c.cntnr_temperature_degree_cd))), prod_quantity = substring(1,5,cnvtstring(p
    .quantity)), p.*
  FROM container_condition_r c,
   contnr_type_prod_r p
  PLAN (c
   WHERE c.container_condition_id > 0)
   JOIN (p
   WHERE p.container_condition_id=c.container_condition_id)
  ORDER BY container_type_disp, condition_disp, product_disp
  HEAD PAGE
   col 1, captions->rpt_cerner,
   CALL center(captions->rpt_title,1,125),
   col 107, captions->rpt_time, col 121,
   curtime"@TIMENOSECONDS;;m", row + 1,
   CALL center(captions->rpt_title_2,1,125),
   col 107, captions->rpt_as_of_date, col 119,
   curdate"@DATECONDENSED;;d", row + 3, col 5,
   captions->rpt_container, col 34, captions->rpt_condition,
   col 63, captions->rpt_temperature, col 83,
   captions->rpt_product, col 112, captions->rpt_qty,
   col 120, captions->rpt_active, row + 1,
   col 5, "------------------------", col 34,
   "------------------------", col 63, "---------------",
   col 83, "------------------------", col 112,
   "-----", col 120, "------",
   row + 1
  HEAD container_type_disp
   col 5, container_type_disp"#########################"
  HEAD condition_disp
   col 34, condition_disp"#########################", col 63,
   temperature_disp
  DETAIL
   col 83, product_disp"#########################", col 112,
   prod_quantity";R"
   IF (p.active_ind=1)
    col 121, captions->rpt_yes
   ELSE
    col 121, captions->rpt_no
   ENDIF
   row + 1
   IF (row > 56)
    BREAK
   ENDIF
  FOOT  condition_disp
   row + 0
  FOOT  container_type_disp
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
