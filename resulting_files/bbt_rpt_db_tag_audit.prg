CREATE PROGRAM bbt_rpt_db_tag_audit
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
   1 page_no = vc
   1 time = vc
   1 tags_labels = vc
   1 blood_bank_tag = vc
   1 application = vc
   1 component_tag = vc
   1 crossmatch_tag = vc
   1 emergency_tag = vc
   1 no = vc
   1 yes = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME: ")
 SET captions->tags_labels = uar_i18ngetmessage(i18nhandle,"tags_labels","Tags and Labels Tool")
 SET captions->blood_bank_tag = uar_i18ngetmessage(i18nhandle,"blood_bank_tag",
  "BLOOD BANK TAG PREFERENCES")
 SET captions->application = uar_i18ngetmessage(i18nhandle,"application","Application")
 SET captions->component_tag = uar_i18ngetmessage(i18nhandle,"component_tag","Component Tag")
 SET captions->crossmatch_tag = uar_i18ngetmessage(i18nhandle,"crossmatch_tag","Crossmatch Tag")
 SET captions->emergency_tag = uar_i18ngetmessage(i18nhandle,"emergency_tag","Emergency Tag")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * E N D  O F  R E P O R T * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_db_tag_audit", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  cvec.field_name, cvec.field_value, cvex.field_name,
  cvex.field_value, cvee.field_name, cvee.field_value,
  cv.display"########################################"
  FROM code_value cv,
   code_value_extension cvec,
   code_value_extension cvex,
   code_value_extension cvee
  PLAN (cv
   WHERE cv.code_set=1662
    AND cv.cdf_meaning IN ("DISPENSE", "MANIPULATE", "POOLPRODUCTS", "RECEIVE", "RESULT ENTRY",
   "ASSIGN"))
   JOIN (cvec
   WHERE cv.code_value=cvec.code_value
    AND cvec.field_name="Component Tag")
   JOIN (cvex
   WHERE cv.code_value=cvex.code_value
    AND cvex.field_name="Crossmatch Tag")
   JOIN (cvee
   WHERE cv.code_value=cvee.code_value
    AND cvee.field_name="Emergency Tag")
  ORDER BY cv.display
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;M",
   col 49, captions->tags_labels, row + 1,
   col 47, captions->blood_bank_tag, row + 2,
   line1 = fillstring(128,"="), line1, line = fillstring(128,"-"),
   row + 1, col 2, captions->application,
   col 45, captions->component_tag, col 65,
   captions->crossmatch_tag, col 85, captions->emergency_tag,
   row + 1, line1, row + 1
  DETAIL
   row + 1, col 2, cv.display
   IF (cvec.field_value="0")
    col 50, captions->no
   ELSEIF (cvec.field_value="1")
    col 50, captions->yes
   ENDIF
   IF (cvex.field_value="0")
    col 70, captions->no
   ELSEIF (cvex.field_value="1")
    col 70, captions->yes
   ENDIF
   IF (cvee.field_value="0")
    col 90, captions->no
   ELSEIF (cvee.field_value="1")
    col 90, captions->yes
   ENDIF
  FOOT REPORT
   row + 3, col 49, captions->end_of_report,
   select_ok_ind = 1
  WITH nullreport, nocounter, compress,
   nolandscape
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
