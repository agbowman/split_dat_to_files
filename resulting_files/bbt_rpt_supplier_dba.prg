CREATE PROGRAM bbt_rpt_supplier:dba
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
   1 rpt_as_of_date = vc
   1 database_audit = vc
   1 page_no = vc
   1 rpt_time = vc
   1 bb_supplier_list = vc
   1 prompt_for = vc
   1 default = vc
   1 alpha = vc
   1 supplier_org = vc
   1 barcode = vc
   1 prefix = vc
   1 translation = vc
   1 active = vc
   1 no = vc
   1 yes = vc
   1 end_of_report = vc
 )
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of date:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","Database Audit")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page No: ")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:  ")
 SET captions->bb_supplier_list = uar_i18ngetmessage(i18nhandle,"bb_supplier_last",
  "Blood Bank Supplier List")
 SET captions->prompt_for = uar_i18ngetmessage(i18nhandle,"prompt_for","Prompt")
 SET captions->default = uar_i18ngetmessage(i18nhandle,"default","Default")
 SET captions->alpha = uar_i18ngetmessage(i18nhandle,"alpha","Alpha")
 SET captions->supplier_org = uar_i18ngetmessage(i18nhandle,"supplier_org","Supplier/Organization")
 SET captions->barcode = uar_i18ngetmessage(i18nhandle,"barcode","Barcode")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"prefix","Prefix")
 SET captions->translation = uar_i18ngetmessage(i18nhandle,"translation","Translation")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Active")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","No")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","Yes")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * END OF REPORT * * * ")
 SET org_type_code_set = 278
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET count1 = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_supplier", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  otr.org_type_cd, cv.cdf_meaning, org.organization_id,
  org.org_name, bbs.seq, bbs.bb_supplier_id,
  bbs.barcode_value, bbs.prefix_ind, bbs.prefix_value,
  bbs.default_prefix_ind, bbs.alpha_translation_ind, bbs.updt_cnt,
  bbs.active_ind
  FROM code_value cv,
   org_type_reltn otr,
   organization org,
   (dummyt d_bbs  WITH seq = 1),
   bb_supplier bbs
  PLAN (cv
   WHERE cv.code_set=org_type_code_set
    AND cv.cdf_meaning="BBSUPPL"
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (otr
   WHERE otr.org_type_cd=cv.code_value
    AND otr.organization_id != null
    AND otr.organization_id > 0
    AND otr.active_ind=1)
   JOIN (org
   WHERE org.organization_id=otr.organization_id
    AND org.active_ind=1)
   JOIN (d_bbs
   WHERE d_bbs.seq=1)
   JOIN (bbs
   WHERE bbs.organization_id=org.organization_id)
  HEAD REPORT
   line = fillstring(126,"-"), select_ok_ind = 0
  HEAD PAGE
   col 1, captions->rpt_as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->rpt_time, col 14, curtime"@TIMENOSECONDS;;M",
   col 52, captions->bb_supplier_list, row + 2,
   line, row + 1, col 1,
   captions->supplier_org, row + 1, col 1,
   captions->prefix, col 15, captions->barcode,
   col 30, captions->prefix, col 45,
   captions->default, col 60, captions->translation,
   col 75, captions->active, row + 1,
   col 30, captions->prompt_for, col 45,
   captions->prefix, row + 1, line
   IF (curpage > 1)
    row + 3
   ELSE
    row + 1
   ENDIF
  DETAIL
   row + 2, col 1, org.org_name,
   row + 1
   IF (bbs.seq > 0)
    col 1, bbs.prefix_value, col 15,
    bbs.barcode_value
    IF (bbs.prefix_ind=1)
     col 30, captions->yes
    ELSE
     col 30, captions->no
    ENDIF
    IF (bbs.default_prefix_ind=1)
     col 45, captions->yes
    ELSE
     col 45, captions->no
    ENDIF
    IF (bbs.alpha_translation_ind=1)
     col 60, captions->yes
    ELSE
     col 60, captions->no
    ENDIF
    IF (bbs.active_ind=1)
     col 75, captions->yes
    ELSE
     col 75, captions->no
    ENDIF
   ENDIF
  FOOT REPORT
   row + 3, col 49, captions->end_of_report,
   select_ok_ind = 1
  WITH nullreport, nocounter, outerjoin(d_bbs),
   compress, nolandscape, maxrow = 61
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
