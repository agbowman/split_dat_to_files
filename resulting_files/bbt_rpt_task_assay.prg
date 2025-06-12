CREATE PROGRAM bbt_rpt_task_assay
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
   1 bb_task_assay = vc
   1 task_code = vc
   1 mnemonic = vc
   1 result_type = vc
   1 bb_processing_type = vc
   1 end_of_report = vc
 )
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","AS OF DATE:   ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:  ")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","TIME:  ")
 SET captions->bb_task_assay = uar_i18ngetmessage(i18nhandle,"bb_task_assay",
  "BLOOD BANK DISCRETE TASK ASSAY AUDIT")
 SET captions->task_code = uar_i18ngetmessage(i18nhandle,"task_code","TASK CODE")
 SET captions->mnemonic = uar_i18ngetmessage(i18nhandle,"mnemonic","MNEMONIC")
 SET captions->result_type = uar_i18ngetmessage(i18nhandle,"result_type","RESULT TYPE")
 SET captions->bb_processing_type = uar_i18ngetmessage(i18nhandle,"bb_processing_type",
  "BB PROCESSING TYPE")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * E N D  O F  R E P O R T * * * ")
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE activity_type_cs = i4 WITH constant(106)
 DECLARE catalog_type_cs = i4 WITH constant(6000)
 DECLARE bb_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE general_lab_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE bb_cd = f8 WITH noconstant(0.0)
 DECLARE general_lab_cd = f8 WITH noconstant(0.0)
 SET bb_cdf = "BB"
 SET general_lab_cdf = "GENERAL LAB"
 SET stat = uar_get_meaning_by_codeset(activity_type_cs,bb_cdf,1,bb_cd)
 IF (stat != 0)
  CALL echo(concat("Error getting code value: ",bb_cdf,cnvtstring(bb_cd,32,2)))
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(catalog_type_cs,general_lab_cdf,1,general_lab_cd)
 IF (stat != 0)
  CALL echo(concat("Error getting code value: ",general_lab_cdf,cnvtstring(general_lab_cd,32,2)))
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_task_assy", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  dta.task_assay_cd, dta.activity_type_cd, dta.default_result_type_cd,
  dta.mnemonic_key_cap"#########################", dta.bb_result_processing_cd, c1636.display
  "#########################",
  c289.display"#########################", res = d_res.seq, proc = d_proc.seq
  FROM order_catalog oc,
   profile_task_r ptr,
   discrete_task_assay dta,
   code_value c289,
   (dummyt d_res  WITH seq = 1),
   code_value c1636,
   (dummyt d_proc  WITH seq = 1)
  PLAN (oc
   WHERE oc.catalog_type_cd=general_lab_cd
    AND oc.activity_type_cd=bb_cd)
   JOIN (ptr
   WHERE ptr.catalog_cd=oc.catalog_cd)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd)
   JOIN (d_res
   WHERE d_res.seq=1)
   JOIN (c289
   WHERE dta.default_result_type_cd=c289.code_value)
   JOIN (d_proc
   WHERE d_proc.seq=1)
   JOIN (c1636
   WHERE dta.bb_result_processing_cd=c1636.code_value)
  ORDER BY dta.mnemonic_key_cap
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->rpt_as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 126,
   curpage"##", row + 1, col 7,
   captions->rpt_time, col 14, curtime"@TIMENOSECONDS;;M",
   col 45, captions->bb_task_assay, row + 1,
   line1 = fillstring(130,"="), line1, row + 1,
   col 1, captions->task_code, col 18,
   captions->mnemonic, col 45, captions->result_type,
   col 75, captions->bb_processing_type, row + 1,
   line1, row + 1
  DETAIL
   IF (row=58)
    BREAK
   ENDIF
   col 1, dta.task_assay_cd, col 18,
   dta.mnemonic_key_cap
   IF (dta.default_result_type_cd > 0)
    col 45, c289.display
   ENDIF
   IF (dta.bb_result_processing_cd > 0)
    col 70, c1636.display
   ENDIF
   row + 1
  FOOT REPORT
   row + 3,
   CALL center(captions->end_of_report,1,125), select_ok_ind = 1
  WITH nullreport, nocounter, compress,
   nolandscape, dontcare = c289, dontcare = c1636,
   outerjoin = d_res, outerjoin = d_proc
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
