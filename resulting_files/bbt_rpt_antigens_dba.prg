CREATE PROGRAM bbt_rpt_antigens:dba
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
 SET line = fillstring(175,"_")
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
   1 cerner_header = vc
   1 rpt_special_testing = vc
   1 time = vc
   1 special_testing = vc
   1 as_of_date = vc
   1 post_to = vc
   1 display_name = vc
   1 description = vc
   1 opposite = vc
   1 barcode = vc
   1 meaning = vc
   1 donor = vc
   1 active = vc
   1 yes = vc
   1 no = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 end_of_report = vc
   1 isbt_meaning = vc
 )
 SET captions->cerner_header = uar_i18ngetmessage(i18nhandle,"cerner_header","Cerner Health Systems")
 SET captions->rpt_special_testing = uar_i18ngetmessage(i18nhandle,"rpt_special_testing",
  "S P E C I A L   T E S T I N G   R E P O R T")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->special_testing = uar_i18ngetmessage(i18nhandle,"special_testing","(Special Testing)")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->post_to = uar_i18ngetmessage(i18nhandle,"post_to","Post To")
 SET captions->display_name = uar_i18ngetmessage(i18nhandle,"display_name","Display Name")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"description","Description")
 SET captions->opposite = uar_i18ngetmessage(i18nhandle,"opposite","Opposite")
 SET captions->barcode = uar_i18ngetmessage(i18nhandle,"barcode","Barcode")
 SET captions->meaning = uar_i18ngetmessage(i18nhandle,"meaning","Meaning")
 SET captions->donor = uar_i18ngetmessage(i18nhandle,"donor","Donor")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_ANTIGENS")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->isbt_meaning = uar_i18ngetmessage(i18nhandle,"isbt_meaning","ISBT Meaning")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_antigens", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  cv.code_value, cv.active_ind, cv.display,
  opposite_disp = uar_get_code_display(cnvtreal(ce.field_value))
  FROM code_value cv,
   common_data_foundation cd,
   code_value_extension ce,
   (dummyt d2  WITH seq = 1),
   bb_isbt_attribute_r iar,
   bb_isbt_attribute ia
  PLAN (cv
   WHERE cv.code_set=1612)
   JOIN (cd
   WHERE cd.code_set=1612
    AND cd.cdf_meaning=cv.cdf_meaning)
   JOIN (ce
   WHERE ce.code_value=cv.code_value
    AND ce.code_set=1612)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (iar
   WHERE iar.attribute_cd=cv.code_value
    AND iar.active_ind=1)
   JOIN (ia
   WHERE ia.bb_isbt_attribute_id=iar.bb_isbt_attribute_id)
  ORDER BY cv.active_ind DESC, cv.display, cv.code_value
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->cerner_header,
   CALL center(captions->rpt_special_testing,1,175),
   col 161, captions->time, col 171,
   curtime"@TIMENOSECONDS;;M", row + 1,
   CALL center(captions->special_testing,1,175),
   col 157, captions->as_of_date, col 169,
   curdate"@DATECONDENSED;;d", row + 1, col 117,
   captions->post_to, row + 1, col 1,
   captions->display_name, col 32, captions->description,
   col 73, captions->opposite, col 86,
   captions->barcode, col 97, captions->meaning,
   col 118, captions->donor, col 124,
   captions->active, col 132, captions->isbt_meaning,
   row + 1, col 1, "------------------------------",
   col 32, "----------------------------------------", col 73,
   "------------", col 86, "----------",
   col 97, "--------------------", col 118,
   "-----", col 124, "------",
   col 132, "---------------------------------------------"
  HEAD cv.code_value
   row + 1
   IF (row > 44)
    BREAK, row + 1
   ENDIF
   col 1, cv.display"##############################", col 32,
   cv.description"########################################", col 97, cd.display"####################"
   IF (cv.active_ind=1)
    col 124, captions->yes
   ELSEIF (cv.active_ind=0)
    col 124, captions->no
   ENDIF
   col 132, ia.standard_display"#############################################"
  DETAIL
   IF (cv.cdf_meaning != "SPTYP"
    AND ce.field_name="Opposite")
    col 73, opposite_disp"############"
   ENDIF
   IF (ce.field_name="barcode"
    AND ce.field_value != "0")
    col 86, ce.field_value"##########"
   ENDIF
   IF (ce.field_name="PostToDonor")
    IF (ce.field_value="1")
     col 118, captions->yes
    ELSE
     col 118, captions->yes
    ENDIF
   ENDIF
  FOOT PAGE
   row 45, col 1, line,
   row + 1, col 1, captions->report_id,
   col 88, captions->page_no, col 94,
   curpage"###", col 149, captions->printed,
   col 159, curdate"@DATECONDENSED;;d", col 169,
   curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   row 47,
   CALL center(captions->end_of_report,0,125), select_ok_ind = 1
  WITH nullreport, counter, maxrow = 49,
   maxcol = 180, compress, landscape,
   outerjoin = d2
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
