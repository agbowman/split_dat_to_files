CREATE PROGRAM bbt_rpt_prod_compat:dba
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
   1 prod_pat_tool = vc
   1 aborh_parameters = vc
   1 active_values = vc
   1 product = vc
   1 xm_disp = vc
   1 auto_dir = vc
   1 dispense = vc
   1 rh = vc
   1 patient = vc
   1 description = vc
   1 group_type = vc
   1 no_grp_type = vc
   1 only = vc
   1 warning = vc
   1 yes = vc
   1 no = vc
   1 warn = vc
   1 end_of_report = vc
   1 report_id = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:   ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:  ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME:  ")
 SET captions->prod_pat_tool = uar_i18ngetmessage(i18nhandle,"prod_pat_tool",
  "PRODUCT-PATIENT COMPATIBILITY TOOL")
 SET captions->aborh_parameters = uar_i18ngetmessage(i18nhandle,"aborh_parameters",
  "PRODUCT-PATIENT ABORH COMPATIBILITY PARAMETERS")
 SET captions->active_values = uar_i18ngetmessage(i18nhandle,"active_values","ACTIVE VALUES ONLY")
 SET captions->product = uar_i18ngetmessage(i18nhandle,"product"," * * PRODUCT * * ")
 SET captions->xm_disp = uar_i18ngetmessage(i18nhandle,"xm_disp","XM/DISP")
 SET captions->auto_dir = uar_i18ngetmessage(i18nhandle,"auto_dir","AUTO/DIR")
 SET captions->rh = uar_i18ngetmessage(i18nhandle,"rh","Rh")
 SET captions->patient = uar_i18ngetmessage(i18nhandle,"patient","PATIENT")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"description","DESCRIPTION")
 SET captions->group_type = uar_i18ngetmessage(i18nhandle,"group_type","ABO/Rh")
 SET captions->no_grp_type = uar_i18ngetmessage(i18nhandle,"no_grp_type","NO ABO/Rh")
 SET captions->only = uar_i18ngetmessage(i18nhandle,"only","ONLY")
 SET captions->warning = uar_i18ngetmessage(i18nhandle,"warning","WARNING")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->warn = uar_i18ngetmessage(i18nhandle,"warn","WARN")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_PROD_COMPAT"
  )
 SET captions->dispense = uar_i18ngetmessage(i18nhandle,"dispense","DISPENSE")
 SET prod_disp = ""
 SET prod_aborh_disp = ""
 SET prsn_aborh_disp = ""
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_prod_compat", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  p.no_gt_on_prsn_flag, p.no_gt_autodir_prsn_flag, p.disp_no_curraborh_prsn_flag,
  p.aborh_option_flag, p.active_ind, prod_disp = uar_get_code_display(p.product_cd)
  "###################",
  prod_aborh_disp = uar_get_code_display(ppa.prod_aborh_cd)"###########", prsn_aborh_disp =
  uar_get_code_display(ppa.prsn_aborh_cd)"###########", ppa.warn_ind,
  ppa.active_ind
  FROM product_aborh p,
   product_patient_aborh ppa
  PLAN (p
   WHERE p.active_ind=1
    AND p.product_cd > 0)
   JOIN (ppa
   WHERE p.product_cd=ppa.product_cd
    AND p.product_aborh_cd=ppa.prod_aborh_cd
    AND ppa.active_ind=1)
  ORDER BY prod_disp, prod_aborh_disp
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 118,
   curpage"####", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;M",
   col 44, captions->prod_pat_tool, row + 1,
   col 38, captions->aborh_parameters, row + 1,
   col 50, captions->active_values, row + 1,
   line = fillstring(122,"-"), line, row + 1
  HEAD prod_disp
   IF (row > 52)
    BREAK
   ENDIF
   row + 1, line, row + 1,
   col 10, captions->product, col 51,
   captions->xm_disp, col 64, captions->auto_dir,
   col 82, captions->dispense, col 100,
   captions->rh, col 106, captions->patient,
   row + 1, col 2, captions->description,
   col 24, captions->group_type, col 50,
   captions->no_grp_type, col 63, captions->no_grp_type,
   col 82, captions->no_grp_type, col 100,
   captions->only, col 106, captions->group_type,
   col 117, captions->warning, row + 1,
   line, row + 1, col 2,
   prod_disp
  HEAD prod_aborh_disp
   IF (row > 56)
    BREAK
   ENDIF
   col 24, prod_aborh_disp
   IF (p.no_gt_on_prsn_flag=0)
    col 53, captions->no
   ELSEIF (p.no_gt_on_prsn_flag=1)
    col 53, captions->yes
   ELSEIF (p.no_gt_on_prsn_flag=2)
    col 53, captions->warn
   ENDIF
   IF (p.no_gt_autodir_prsn_flag=0)
    col 66, captions->no
   ELSEIF (p.no_gt_autodir_prsn_flag=1)
    col 66, captions->yes
   ELSEIF (p.no_gt_autodir_prsn_flag=2)
    col 66, captions->warn
   ENDIF
   IF (p.disp_no_curraborh_prsn_flag=0)
    col 84, captions->no
   ELSEIF (p.disp_no_curraborh_prsn_flag=1)
    col 84, captions->yes
   ELSEIF (p.disp_no_curraborh_prsn_flag=2)
    col 84, captions->warn
   ENDIF
   IF (p.aborh_option_flag=0)
    col 100, captions->yes
   ELSEIF (p.aborh_option_flag=1)
    col 100, captions->no
   ENDIF
  DETAIL
   IF (row > 56)
    BREAK
   ENDIF
   col 106, prsn_aborh_disp
   IF (ppa.warn_ind=0)
    col 118, captions->no
   ELSEIF (ppa.warn_ind=1)
    col 118, captions->yes
   ENDIF
   row + 1
  FOOT REPORT
   row 57, col 49, captions->end_of_report
  FOOT PAGE
   row 58, col 1, line,
   row + 1, col 1, captions->report_id,
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
