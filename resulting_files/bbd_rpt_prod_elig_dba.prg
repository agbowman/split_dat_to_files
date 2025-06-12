CREATE PROGRAM bbd_rpt_prod_elig:dba
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
 SET modify = predeclare
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE rpt_cnt = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
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
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 as_of_date = vc
   1 rpt_title = vc
   1 rpt_page = vc
   1 rpt_time = vc
   1 rpt_proc_tool = vc
   1 rpt_prod_elig_act = vc
   1 rpt_prod_elig_inact = vc
   1 rpt_active = vc
   1 rpt_active_inact = vc
   1 head_cur_prod = vc
   1 head_prev_prod = vc
   1 head_eligible = vc
   1 head_active = vc
   1 head_beg_effective = vc
   1 head_end_effective = vc
   1 active = vc
   1 not_active = vc
   1 end_of_report = vc
   1 prod_elig_list = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title","DATABASE AUDIT")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","PAGE:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","TIME:")
 SET captions->rpt_proc_tool = uar_i18ngetmessage(i18nhandle,"rpt_proc_tool","PROCEDURES TOOL")
 SET captions->rpt_prod_elig_act = uar_i18ngetmessage(i18nhandle,"rpt_prod_elig_act",
  "PRODUCT ELIGIBILITY (Active)")
 SET captions->rpt_prod_elig_inact = uar_i18ngetmessage(i18nhandle,"rpt_prod_elig_inact",
  "PRODUCT ELIGIBILITY (Active and Inactive)")
 SET captions->head_cur_prod = uar_i18ngetmessage(i18nhandle,"head_cur_prod","CURRENT PRODUCT:")
 SET captions->head_prev_prod = uar_i18ngetmessage(i18nhandle,"head_prev_prod","PREVIOUS PRODUCT")
 SET captions->head_eligible = uar_i18ngetmessage(i18nhandle,"head_eligible","DAYS UNTIL ELIGIBLE")
 SET captions->head_active = uar_i18ngetmessage(i18nhandle,"head_active","ACTIVE")
 SET captions->head_beg_effective = uar_i18ngetmessage(i18nhandle,"head_beg_effective",
  "BEGIN EFFECTIVE DATE/TIME")
 SET captions->head_end_effective = uar_i18ngetmessage(i18nhandle,"head_end_effective",
  "END EFFECTIVE DATE/TIME")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Yes")
 SET captions->not_active = uar_i18ngetmessage(i18nhandle,"not_active","No")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report","*** End of Report ***")
 SET captions->prod_elig_list = uar_i18ngetmessage(i18nhandle,"prod_elig_list",
  "PRODUCT ELIGIBILITY LIST:")
 EXECUTE cpm_create_file_name_logical "bbd_prod_elig", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  bpe.*, curr_product = uar_get_code_display(bpe.product_cd), prev_product = uar_get_code_display(bpe
   .previous_product_cd)
  FROM bbd_product_eligibility bpe
  PLAN (bpe
   WHERE bpe.product_eligibility_id > 0.0
    AND (((request->active_ind=0)) OR ((request->active_ind=1)
    AND bpe.active_ind=1)) )
  ORDER BY curr_product, prev_product, bpe.end_effective_dt_tm DESC,
   bpe.beg_effective_dt_tm DESC, bpe.product_cd
  HEAD REPORT
   line0 = fillstring(126,"="), line1 = fillstring(40,"-"), line2 = fillstring(19,"-"),
   line3 = fillstring(6,"-"), line4 = fillstring(25,"-"), prev_header = 0
  HEAD PAGE
   col 0, captions->as_of_date, col 12,
   curdate"@DATECONDENSED;;d",
   CALL center(captions->rpt_title,0,125), col 108,
   captions->rpt_page, col 114, curpage";L",
   row + 1, col 0, captions->rpt_time,
   col 12, curtime"@TIMENOSECONDS;;M",
   CALL center(captions->rpt_proc_tool,0,125),
   row + 1
   IF ((request->active_ind=1))
    CALL center(captions->rpt_prod_elig_act,0,125)
   ELSE
    CALL center(captions->rpt_prod_elig_inact,0,125)
   ENDIF
   row + 1
  HEAD bpe.product_cd
   IF (row > 52)
    BREAK
   ENDIF
   row + 1, col 0, line0,
   row + 1, col 0, captions->head_cur_prod,
   col 17, curr_product, col 97,
   captions->prod_elig_list
   IF (bpe.list_ind=0)
    col 123, captions->not_active
   ELSE
    col 123, captions->active
   ENDIF
   row + 1, col 0, line0,
   row + 1
  DETAIL
   IF (row > 57)
    BREAK
   ENDIF
   IF (prev_header=0)
    col 3, captions->head_prev_prod, col 45,
    captions->head_eligible, col 66, captions->head_active,
    col 74, captions->head_beg_effective, col 101,
    captions->head_end_effective, row + 1, col 3,
    line1, col 45, line2,
    col 66, line3, col 74,
    line4, col 101, line4,
    prev_header = 1
   ENDIF
   row + 1, col 3, prev_product,
   col 45, bpe.days_until_eligible, col 66
   IF (bpe.active_ind=1)
    CALL center(captions->active,66,72)
   ELSE
    CALL center(captions->not_active,66,72)
   ENDIF
   col 74, bpe.beg_effective_dt_tm"@SHORTDATETIME", col 101,
   bpe.end_effective_dt_tm"@SHORTDATETIME"
  FOOT  bpe.product_cd
   IF (row > 57)
    BREAK
   ENDIF
   row + 1, prev_header = 0
  FOOT REPORT
   row + 2,
   CALL center(captions->end_of_report,0,125)
  WITH nocounter, maxrows = 60, nullreport,
   compress, nolandscape
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = concat("cer_print:",cpm_cfn_info->file_name)
#exit_script
 SET reply->status_data.status = "S"
END GO
