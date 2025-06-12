CREATE PROGRAM bbt_rpt_pool_option:dba
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
   1 pooling_tool = vc
   1 pooling_options = vc
   1 pool_option = vc
   1 new_product = vc
   1 volume = vc
   1 exp_hrs = vc
   1 prod_nbr = vc
   1 prefix = vc
   1 supplier = vc
   1 assign = vc
   1 no_abo = vc
   1 manual = vc
   1 system = vc
   1 no = vc
   1 yes = vc
   1 valid_component = vc
   1 end_of_report = vc
   1 active = vc
   1 year = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME: ")
 SET captions->pooling_tool = uar_i18ngetmessage(i18nhandle,"pooling_tool","POOLING TOOL")
 SET captions->pooling_options = uar_i18ngetmessage(i18nhandle,"pooling_options","POOLING OPTIONS")
 SET captions->pool_option = uar_i18ngetmessage(i18nhandle,"pool_option","POOL OPTION")
 SET captions->new_product = uar_i18ngetmessage(i18nhandle,"new_product","NEW PRODUCT")
 SET captions->volume = uar_i18ngetmessage(i18nhandle,"volume","VOLUME")
 SET captions->exp_hrs = uar_i18ngetmessage(i18nhandle,"exp_hrs","EXP HRS")
 SET captions->prod_nbr = uar_i18ngetmessage(i18nhandle,"prod_nbr","PROD NBR")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"prefix","PREFIX")
 SET captions->supplier = uar_i18ngetmessage(i18nhandle,"supplier","SUPPLIER")
 SET captions->assign = uar_i18ngetmessage(i18nhandle,"assign","ASSIGN")
 SET captions->no_abo = uar_i18ngetmessage(i18nhandle,"no_abo","NO ABO")
 SET captions->manual = uar_i18ngetmessage(i18nhandle,"manual","MANUAL")
 SET captions->system = uar_i18ngetmessage(i18nhandle,"system","SYSTEM")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->valid_component = uar_i18ngetmessage(i18nhandle,"valid_component",
  "VALID COMPONENT PRODUCTS")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * E N D  O F  R E P O R T * * * ")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->year = uar_i18ngetmessage(i18nhandle,"year","YEAR")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_pool_ops", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  po.option_id, po.description"####################", product_disp = uar_get_code_display(po
   .new_product_cd)"####################",
  po.prompt_vol_ind, po.calculate_vol_ind, po.default_exp_hrs,
  pp.year, po.product_nbr_prefix, po.generate_prod_nbr_ind,
  po.default_supplier_id, po.require_assign_ind, po.active_ind,
  po.allow_no_aborh_ind, org.org_name"#####################################", component_prod_disp =
  uar_get_code_display(cmp.product_cd)"####################"
  FROM pool_option po,
   pooled_product pp,
   organization org,
   component cmp
  PLAN (po
   WHERE po.option_id > 0.0)
   JOIN (pp
   WHERE po.option_id=pp.pool_option_id
    AND pp.active_ind=1)
   JOIN (org
   WHERE po.default_supplier_id=org.organization_id)
   JOIN (cmp
   WHERE po.option_id=cmp.option_id)
  ORDER BY po.option_id
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;d",
   CALL center(captions->database_audit,1,178), col 162,
   captions->page_no, col 174, curpage"##",
   row + 1, col 7, captions->time,
   col 14, curtime"@TIMENOSECONDS;;M",
   CALL center(captions->pooling_tool,1,178),
   row + 1,
   CALL center(captions->pooling_options,1,178), row + 2,
   line1 = fillstring(178,"="), line1, line = fillstring(178,"-"),
   row + 2
  HEAD po.option_id
   IF ((row > (maxrow - 9)))
    BREAK
   ENDIF
   IF (row > 6)
    row + 1
   ENDIF
   line, row + 1, col 1,
   captions->pool_option, col 28, captions->new_product,
   col 55, captions->volume, col 66,
   captions->exp_hrs, col 76, captions->prod_nbr,
   col 88, captions->year, col 98,
   captions->prefix, col 110, captions->supplier,
   col 154, captions->assign, col 162,
   captions->no_abo, col 170, captions->active,
   row + 1, line, row + 1,
   col 1, po.description, col 28,
   product_disp
   IF (po.prompt_vol_ind=1)
    col 55, captions->manual
   ELSEIF (po.calculate_vol_ind=1)
    col 55, captions->system
   ENDIF
   col 69, po.default_exp_hrs";L"
   IF (po.generate_prod_nbr_ind=0)
    col 77, captions->manual
   ELSEIF (po.generate_prod_nbr_ind=1)
    col 77, captions->system, col 88,
    pp.year";L"
   ENDIF
   col 98, po.product_nbr_prefix, col 110,
   org.org_name
   IF (po.require_assign_ind=0)
    col 156, captions->no
   ELSEIF (po.require_assign_ind=1)
    col 155, captions->yes
   ENDIF
   IF (po.allow_no_aborh_ind=0)
    col 164, captions->no
   ELSEIF (po.allow_no_aborh_ind=1)
    col 164, captions->yes
   ENDIF
   IF (po.active_ind=0)
    col 171, captions->no
   ELSEIF (po.active_ind=1)
    col 171, captions->yes
   ENDIF
   row + 2
   IF (row > 46)
    BREAK
   ENDIF
   col 10, captions->valid_component, col 67,
   captions->active, row + 1, col 10,
   "------------------------", col 67, "------",
   row + 1
  DETAIL
   col 10, component_prod_disp
   IF (cmp.active_ind=0)
    col 68, captions->no
   ELSEIF (cmp.active_ind=1)
    col 68, captions->yes
   ENDIF
   row + 1
  FOOT REPORT
   row + 3,
   CALL center(captions->end_of_report,1,178), select_ok_ind = 1
  WITH nocounter, nullreport, maxrow = 48,
   maxcol = 180, compress, landscape
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
