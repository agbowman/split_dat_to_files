CREATE PROGRAM bbt_rpt_isbt_assoc:dba
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
   1 bb_product_alias = vc
   1 time = vc
   1 as_of_date = vc
   1 associated_products = vc
   1 product_type = vc
   1 prodcode = vc
   1 description = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 inactive = vc
   1 end_of_report = vc
 )
 SET captions->bb_product_alias = uar_i18ngetmessage(i18nhandle,"bb_product_alias",
  "B B   P R O D U C T   A L I A S   A U D I T   R E P O R T")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->associated_products = uar_i18ngetmessage(i18nhandle,"associated_products",
  "(Associated Products)")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->prodcode = uar_i18ngetmessage(i18nhandle,"prodcode","ProdCode")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"description","Description")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_ISBT_ASSOC")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"inactive",
  "* = Product type is currently inactive")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET line = fillstring(175,"_")
 SET line_prod_type = fillstring(25,"_")
 SET line_e_number = fillstring(8,"_")
 SET line_description = fillstring(135,"_")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_isbt_assoc", "txt", "x"
 SET e_number_cnt = cnvtint(size(request->qual,5))
 SELECT INTO cpm_cfn_info->file_name_logical
  product_cd_display = uar_get_code_display(cv.code_value)
  FROM (dummyt isbt  WITH seq = value(e_number_cnt)),
   code_value cv
  PLAN (isbt)
   JOIN (cv
   WHERE cv.code_set=1604
    AND (cv.code_value=request->qual[isbt.seq].product_cd))
  ORDER BY cv.active_ind DESC, product_cd_display
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   CALL center(captions->bb_product_alias,1,175), col 161, captions->time,
   col 171, curtime"@TIMENOSECONDS;;M", row + 1,
   col 157, captions->as_of_date, col 169,
   curdate"@DATECONDENSED;;d", save_row = row, row 1,
   CALL center(captions->associated_products,1,175), row save_row, row + 2,
   col 3, captions->product_type, col 30,
   captions->prodcode, col 40, captions->description,
   row + 1, col 3, line_prod_type,
   col 30, line_e_number, col 40,
   line_description, row + 2
  DETAIL
   IF (cv.active_ind=0)
    col 1, "*"
   ELSE
    col 1, " "
   ENDIF
   col 3, product_cd_display"#########################", col 30,
   request->qual[isbt.seq].e_number, col 40, request->qual[isbt.seq].e_number_des,
   row + 1
   IF (row > 44)
    BREAK
   ENDIF
  FOOT PAGE
   row 45, col 1, line,
   row + 1, col 1, captions->report_id,
   col 88, captions->page_no, col 94,
   curpage"###", col 159, captions->printed,
   col 169, curdate"@DATECONDENSED;;d", row + 1,
   col 1, captions->inactive
  FOOT REPORT
   row 48, col 80, captions->end_of_report,
   select_ok_ind = 1
  WITH nocounter, nullreport, maxrow = 49,
   maxcol = 180, compress, landscape
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
