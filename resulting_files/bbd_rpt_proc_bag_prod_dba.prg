CREATE PROGRAM bbd_rpt_proc_bag_prod:dba
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
   1 relationships_report = vc
   1 rpt_as_of_date = vc
   1 expire = vc
   1 procedure = vc
   1 bag_type = vc
   1 product = vc
   1 days = vc
   1 hours = vc
   1 active = vc
   1 no_prod_relationship = vc
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
  "P R O C E D U R E  /  B A G   T Y P E  /  P R O D U C T")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->relationships_report = uar_i18ngetmessage(i18nhandle,"relationships_report",
  "R E L A T I O N S H I P S   R E P O R T")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->expire = uar_i18ngetmessage(i18nhandle,"expire","Expire")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"procedure","Procedure")
 SET captions->bag_type = uar_i18ngetmessage(i18nhandle,"bag_type","Bag Type")
 SET captions->product = uar_i18ngetmessage(i18nhandle,"product","Product")
 SET captions->days = uar_i18ngetmessage(i18nhandle,"days","Days")
 SET captions->hours = uar_i18ngetmessage(i18nhandle,"hours","Hours")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active")
 SET captions->no_prod_relationship = uar_i18ngetmessage(i18nhandle,"no_prod_relationship",
  "No Product Relationship")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBD_RPT_PROC_BAG_PROD")
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
 SELECT INTO "cer_temp:bbdprocbagprod.txt"
  procedure_disp = uar_get_code_display(b.procedure_cd), bag_type_disp = uar_get_code_display(b
   .bag_type_cd), product_disp = uar_get_code_display(p.product_cd),
  p.default_expire_days, p.default_expire_hours, p.active_ind
  FROM procedure_bag_type_r b,
   (dummyt d1  WITH seq = 1),
   proc_bag_product_r p
  PLAN (b
   WHERE b.procedure_bag_type_id > 0)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (p
   WHERE b.procedure_cd=p.procedure_cd
    AND b.bag_type_cd=p.bag_type_cd)
  ORDER BY procedure_disp, bag_type_disp, product_disp
  HEAD REPORT
   first_proc = "Y", first_bag = "Y"
  HEAD PAGE
   col 1, captions->rpt_cerner_health_sys,
   CALL center(captions->rpt_title,1,125),
   col 104, captions->rpt_time, col 118,
   curtime"@TIMENOSECONDS;;M", row + 1,
   CALL center(captions->relationships_report,1,125),
   col 104, captions->rpt_as_of_date, col 118,
   curdate"@DATECONDENSED;;d", row + 3, col 95,
   captions->expire, col 106, captions->expire,
   row + 1, col 16, captions->procedure,
   col 46, captions->bag_type, col 77,
   captions->product, col 96, captions->days,
   col 106, captions->hours, col 117,
   captions->active, row + 1, col 5,
   "-------------------------", col 35, "-------------------------",
   col 65, "-------------------------", col 95,
   "------", col 106, "------",
   col 117, "------", row + 1
  DETAIL
   IF (first_proc="Y")
    first_proc = "N", col 5, procedure_disp"##############################"
   ENDIF
   IF (first_bag="Y")
    first_bag = "N", col 35, bag_type_disp"##############################"
   ENDIF
   IF (product_disp > " ")
    col 65, product_disp"##############################"
   ELSE
    col 65, captions->no_prod_relationship
   ENDIF
   IF (product_disp > " ")
    col 95, p.default_expire_days"####;p ", col 106,
    p.default_expire_hours"####;p "
    IF (p.active_ind=1)
     col 118, captions->yes
    ELSE
     col 118, captions->no
    ENDIF
   ENDIF
   row + 1
   IF (row > 56)
    BREAK
   ENDIF
  FOOT  procedure_disp
   first_proc = "Y", row + 1
   IF (row > 56)
    BREAK
   ENDIF
  FOOT  bag_type_disp
   first_bag = "Y", row + 1
   IF (row > 56)
    BREAK
   ENDIF
  FOOT PAGE
   first_proc = "Y", first_bag = "Y", row 57,
   col 1, line, row + 1,
   col 1, captions->rpt_id, col 58,
   captions->rpt_page, col 64, curpage"###",
   col 100, captions->printed, col 110,
   curdate"@DATECONDENSED;;d", col 120, curtime"@TIMENOSECONDS;;M",
   row + 1, col 100, captions->printed_by,
   col 110, curuser
  FOOT REPORT
   row 60, col 51, captions->end_of_report,
   report_complete_ind = "Y"
  WITH nullreport, counter, maxrow = 61,
   outerjoin(d1), compress, nolandscape
 ;end select
 SET count1 = (count1+ 1)
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
 ENDIF
 IF (report_complete_ind="Y")
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationname = "Report Complete"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbd_rpt_proc_bag_prod"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Report completed successfully"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "Abnormal End"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbd_rpt_proc_bag_prod"
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
