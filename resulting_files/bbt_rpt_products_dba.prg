CREATE PROGRAM bbt_rpt_products:dba
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
   1 product_tool = vc
   1 by_category = vc
   1 product_category = vc
   1 product = vc
   1 active = vc
   1 yes = vc
   1 no = vc
   1 autologous_product = vc
   1 directed_product = vc
   1 dispensed = vc
   1 default_volume = vc
   1 max_exp_days = vc
   1 max_exp_hours = vc
   1 exp_calculation = vc
   1 lower_no = vc
   1 lower_yes = vc
   1 default_supplier = vc
   1 unit_aborh = vc
   1 no_of_minutes = vc
   1 tracked = vc
   1 antigen_validation = vc
   1 transfusion_validation = vc
   1 barcode_values = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:   ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:  ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME:  ")
 SET captions->product_tool = uar_i18ngetmessage(i18nhandle,"product_tool","PRODUCT TOOL")
 SET captions->by_category = uar_i18ngetmessage(i18nhandle,"by_category","PRODUCTS BY CATEGORY")
 SET captions->product_category = uar_i18ngetmessage(i18nhandle,"product_category",
  "PRODUCT CATEGORY:  ")
 SET captions->product = uar_i18ngetmessage(i18nhandle,"product","PRODUCT:")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE:")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->autologous_product = uar_i18ngetmessage(i18nhandle,"autologous_product",
  "Is this an autologous product? ")
 SET captions->directed_product = uar_i18ngetmessage(i18nhandle,"directed_product",
  "Is this a directed product? ")
 SET captions->dispensed = uar_i18ngetmessage(i18nhandle,"dispensed",
  "Can this product be dispensed? ")
 SET captions->default_volume = uar_i18ngetmessage(i18nhandle,"default_volume","Default volume: ")
 SET captions->max_exp_days = uar_i18ngetmessage(i18nhandle,"max_exp_days",
  "Maximum expiration days: ")
 SET captions->max_exp_hours = uar_i18ngetmessage(i18nhandle,"max_exp_hours",
  "Maximum expiration hours: ")
 SET captions->exp_calculation = uar_i18ngetmessage(i18nhandle,"exp_calculation",
  "Should expiration be calculated from drawn date? ")
 SET captions->lower_no = uar_i18ngetmessage(i18nhandle,"lower_no","No")
 SET captions->lower_yes = uar_i18ngetmessage(i18nhandle,"lower_yes","Yes")
 SET captions->default_supplier = uar_i18ngetmessage(i18nhandle,"default_supplier",
  "Default supplier: ")
 SET captions->unit_aborh = uar_i18ngetmessage(i18nhandle,"unit_aborh",
  "Unit ABORh confirmation procedure: ")
 SET captions->no_of_minutes = uar_i18ngetmessage(i18nhandle,"no_of_minutes",
  "Number of minutes product can be issued without quarantine: ")
 SET captions->tracked = uar_i18ngetmessage(i18nhandle,"tracked",
  "Is this product tracked by International Units? ")
 SET captions->antigen_validation = uar_i18ngetmessage(i18nhandle,"antigen_validation",
  "Perform Antigen-Antibody Validation?")
 SET captions->transfusion_validation = uar_i18ngetmessage(i18nhandle,"transfusion_validation",
  "Perform Transfusion Requirement Validation?")
 SET captions->barcode_values = uar_i18ngetmessage(i18nhandle,"barcode_values",
  "Product bar-code values: ")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_products", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  pi.product_cd, pi.product_cat_cd, pi.autologous_ind,
  pi.directed_ind, pi.allow_dispense_ind, pi.default_volume"####",
  pi.max_days_expire"####", pi.max_hrs_expire"####", pi.default_supplier_id,
  pi.synonym_id, pi.auto_quarantine_min"####", pi.active_ind,
  pi.validate_ag_ab_ind, pi.validate_trans_req_ind, pi.intl_units_ind,
  pi.drawn_dt_tm_ind, c1604_sort_display = build(uar_get_code_display(pi.product_cd),pi.product_cd),
  c1605_sort_display = build(uar_get_code_display(pi.product_cat_cd),pi.product_cat_cd),
  c1604_display = uar_get_code_display(pi.product_cd), c1605_display = uar_get_code_display(pi
   .product_cat_cd), org.org_name"#########################",
  org = d_org.seq, cat.mnemonic_key_cap"###############", cat = d_cat.seq,
  pb.product_barcode
  FROM product_index pi,
   organization org,
   (dummyt d_org  WITH seq = 1),
   order_catalog_synonym cat,
   (dummyt d_cat  WITH seq = 1),
   product_barcode pb,
   (dummyt d_pb  WITH seq = 1)
  PLAN (pi
   WHERE pi.product_cd > 0.0)
   JOIN (d_org
   WHERE d_org.seq=1)
   JOIN (org
   WHERE pi.default_supplier_id=org.organization_id)
   JOIN (d_cat
   WHERE d_cat.seq=1)
   JOIN (cat
   WHERE pi.synonym_id=cat.synonym_id
    AND cat.synonym_id > 0)
   JOIN (d_pb
   WHERE d_pb.seq=1)
   JOIN (pb
   WHERE pi.product_cd=pb.product_cd
    AND pb.active_ind=1)
  ORDER BY c1605_sort_display, c1604_sort_display, pb.product_barcode
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 116, captions->page_no, col 126,
   curpage"##", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;M",
   col 53, captions->product_tool, row + 1,
   col 49, captions->by_category, row + 1,
   line1 = fillstring(130,"="), line1, line = fillstring(130,"-"),
   line2 = fillstring(50,"*"), row + 1
  HEAD c1605_sort_display
   IF (row > 47)
    BREAK
   ENDIF
   row + 2, col 25, line2,
   row + 1, col 25, captions->product_category,
   col 43, c1605_display, row + 1,
   col 25, line2, row + 1
  HEAD c1604_sort_display
   IF (row > 50)
    BREAK
   ENDIF
   row + 1, line, row + 1,
   col 4, captions->product
   IF (pi.seq > 0)
    col 15, c1604_display
   ENDIF
   col 40, captions->active
   IF (pi.active_ind=0)
    col 49, captions->no
   ELSEIF (pi.active_ind=1)
    col 49, captions->yes
   ENDIF
   row + 1, line, row + 1,
   col 10, captions->autologous_product
   IF (pi.autologous_ind=0)
    col 77, captions->no
   ELSEIF (pi.autologous_ind=1)
    col 77, captions->yes
   ENDIF
   row + 1, col 10, captions->directed_product
   IF (pi.directed_ind=0)
    col 77, captions->no
   ELSEIF (pi.directed_ind=1)
    col 77, captions->yes
   ENDIF
   row + 1, col 10, captions->dispensed
   IF (pi.allow_dispense_ind=0)
    col 77, captions->no
   ELSEIF (pi.allow_dispense_ind=1)
    col 77, captions->yes
   ENDIF
   row + 1, col 10, captions->default_volume,
   col 76, pi.default_volume, row + 1,
   col 10, captions->max_exp_days, col 76,
   pi.max_days_expire, row + 1, col 10,
   captions->max_exp_hours, col 76, pi.max_hrs_expire,
   row + 1, col 10, captions->exp_calculation
   IF (pi.drawn_dt_tm_ind=0)
    col 77, captions->lower_no
   ELSE
    col 77, captions->lower_yes
   ENDIF
   row + 1, col 10, captions->default_supplier
   IF (pi.default_supplier_id > 0)
    col 77, org.org_name
   ENDIF
   row + 1, col 10, captions->unit_aborh,
   col 77, cat.mnemonic_key_cap, row + 1,
   col 10, captions->no_of_minutes, col 76,
   pi.auto_quarantine_min, row + 1, col 10,
   captions->tracked
   IF (pi.intl_units_ind=0)
    col 77, captions->no
   ELSEIF (pi.intl_units_ind=1)
    col 77, captions->yes
   ENDIF
   row + 1, col 10, captions->antigen_validation
   IF (pi.validate_ag_ab_ind=0)
    col 77, captions->no
   ELSEIF (pi.validate_ag_ab_ind=1)
    col 77, captions->yes
   ENDIF
   row + 1, col 10, captions->transfusion_validation
   IF (pi.validate_trans_req_ind=0)
    col 77, captions->no
   ELSEIF (pi.validate_trans_req_ind=1)
    col 77, captions->yes
   ENDIF
   row + 1, col 10, captions->barcode_values
  DETAIL
   col 77, pb.product_barcode, row + 1
  FOOT REPORT
   row + 3,
   CALL center(captions->end_of_report,0,125), select_ok_ind = 1
  WITH nullreport, nocounter, compress,
   nolandscape, dontcare = org, dontcare = cat,
   outerjoin = d_org, outerjoin = d_cat, outerjoin = d_pb
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
