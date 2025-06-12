CREATE PROGRAM bbt_rpt_mod_options:dba
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
   1 modify_tool = vc
   1 mod_options = vc
   1 modify_option = vc
   1 original_product = vc
   1 msg1 = vc
   1 msg2 = vc
   1 msg3 = vc
   1 msg4 = vc
   1 days = vc
   1 hours = vc
   1 msg5 = vc
   1 msg6 = vc
   1 msg7 = vc
   1 msg8 = vc
   1 msg9 = vc
   1 msg10 = vc
   1 msg11 = vc
   1 msg12 = vc
   1 default_expire = vc
   1 prep = vc
   1 unit_abo = vc
   1 default = vc
   1 exp_from = vc
   1 new_product = vc
   1 rpt_days = vc
   1 rpt_hours = vc
   1 test = vc
   1 sub_id = vc
   1 drawn_date = vc
   1 attribute = vc
   1 quantity = vc
   1 active = vc
   1 upper_alpha = vc
   1 lower_alpha = vc
   1 numeric = vc
   1 no_default = vc
   1 yes = vc
   1 no = vc
   1 default_volume = vc
   1 none = vc
   1 unit_of_measure = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:     ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:  ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME:   ")
 SET captions->modify_tool = uar_i18ngetmessage(i18nhandle,"modify_tool","MODIFY TOOL")
 SET captions->mod_options = uar_i18ngetmessage(i18nhandle,"mod_options","MODIFICATION OPTIONS")
 SET captions->modify_option = uar_i18ngetmessage(i18nhandle,"modify_option","MODIFY OPTION: ")
 SET captions->original_product = uar_i18ngetmessage(i18nhandle,"original_product",
  "ORIGINAL PRODUCT: ")
 SET captions->msg1 = uar_i18ngetmessage(i18nhandle,"msg1",
  "Original product WILL NOT be disposed during this modification.")
 SET captions->msg2 = uar_i18ngetmessage(i18nhandle,"msg2",
  "Original product WILL be disposed during this modification.")
 SET captions->msg3 = uar_i18ngetmessage(i18nhandle,"msg3",
  "The expiration date/time of the original product WILL NOT be changed.")
 SET captions->msg4 = uar_i18ngetmessage(i18nhandle,"msg4",
  "The expiration date/time of the original product WILL be changed.")
 SET captions->days = uar_i18ngetmessage(i18nhandle,"days","DAYS:  ")
 SET captions->hours = uar_i18ngetmessage(i18nhandle,"hours","HOURS:  ")
 SET captions->msg5 = uar_i18ngetmessage(i18nhandle,"msg5",
  "The total volume of the new products WILL NOT be validated against the volume of the original.")
 SET captions->msg6 = uar_i18ngetmessage(i18nhandle,"msg6",
  "The total volume of the new products WILL be validated against the volume of the original.")
 SET captions->msg7 = uar_i18ngetmessage(i18nhandle,"msg7",
  "The expiration date of the new product(s) WILL NOT be calculated from the DRAWN date of the original."
  )
 SET captions->msg8 = uar_i18ngetmessage(i18nhandle,"msg8",
  "The expiration date of the new product(s) WILL be calculated from the DRAWN date of the original."
  )
 SET captions->msg9 = uar_i18ngetmessage(i18nhandle,"msg9",
  "The division type of this option is NEW PRODUCTS.")
 SET captions->msg10 = uar_i18ngetmessage(i18nhandle,"msg10",
  "The division type of this option is SPLIT PRODUCTS.")
 SET captions->msg11 = uar_i18ngetmessage(i18nhandle,"msg11",
  "The division type of this option is CHANGE ATTRIBUTE.")
 SET captions->msg12 = uar_i18ngetmessage(i18nhandle,"msg12",
  "The division type of this option is CROSSOVER.")
 SET captions->default_expire = uar_i18ngetmessage(i18nhandle,"default_expire","DEFAULT EXPIRE")
 SET captions->prep = uar_i18ngetmessage(i18nhandle,"prep","PREP")
 SET captions->unit_abo = uar_i18ngetmessage(i18nhandle,"unit_abo","UNIT ABO")
 SET captions->default = uar_i18ngetmessage(i18nhandle,"default","DEFAULT")
 SET captions->exp_from = uar_i18ngetmessage(i18nhandle,"exp_from","EXP FROM")
 SET captions->new_product = uar_i18ngetmessage(i18nhandle,"new_product","NEW PRODUCT")
 SET captions->rpt_days = uar_i18ngetmessage(i18nhandle,"rpt_days","DAYS")
 SET captions->rpt_hours = uar_i18ngetmessage(i18nhandle,"rpt_hours","HOURS")
 SET captions->test = uar_i18ngetmessage(i18nhandle,"test","TEST")
 SET captions->sub_id = uar_i18ngetmessage(i18nhandle,"sub_id","SUB-ID")
 SET captions->drawn_date = uar_i18ngetmessage(i18nhandle,"drawn_date","DRAWN DATE")
 SET captions->attribute = uar_i18ngetmessage(i18nhandle,"attribute","ATTRIBUTE")
 SET captions->quantity = uar_i18ngetmessage(i18nhandle,"quantity","QUANTITY")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->upper_alpha = uar_i18ngetmessage(i18nhandle,"upper_alpha","Uppercase Alpha")
 SET captions->lower_alpha = uar_i18ngetmessage(i18nhandle,"lower_alpha","Lowercase Alpha")
 SET captions->numeric = uar_i18ngetmessage(i18nhandle,"numeric","Numeric")
 SET captions->no_default = uar_i18ngetmessage(i18nhandle,"no_default","No default")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->default_volume = uar_i18ngetmessage(i18nhandle,"default_volume","Default Volume: ")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"none","None")
 SET captions->unit_of_measure = uar_i18ngetmessage(i18nhandle,"unit_of_measure","Unit of Measure: ")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_mod_ops", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  option_unique = build(np.option_id,"_",mot.option_id), mo.option_id, mo.orig_product_cd,
  mo.description, mo.bag_type_cd, mo.dispose_orig_ind,
  mo.orig_nbr_days_exp, mo.orig_nbr_hrs_exp, mo.validate_vol_ind,
  mo.calc_exp_drawn_ind, mo.chg_orig_exp_dt_ind, mo.bag_type_valid_ind,
  mo.division_type_flag, mo.active_ind, np.option_id,
  np.new_product_cd, np.default_exp_days"####", np.default_exp_hrs"####",
  np.max_prep_hrs"####", np.synonym_id, np.quantity"####",
  np.active_ind, np.sub_prod_id_flag, np.default_volume_ind,
  np.default_volume"#####", np.default_measure_ind, np.default_unit_measure_cd,
  prod = d_prod.seq, mot.new_product_cd, mot.special_testing_cd,
  mot.option_id, mot.calc_exp_drawn_ind, mot.default_exp_days"####",
  mot.default_exp_hrs"####", mot.max_prep_hrs"####", mot.active_ind,
  mot = d_mot.seq, cv1604_disp = uar_get_code_display(mo.orig_product_cd), c1604_disp =
  uar_get_code_display(mot.new_product_cd),
  c1612_disp = uar_get_code_display(mot.special_testing_cd), cv240_disp = uar_get_code_display(np
   .default_unit_measure_cd), ocs.mnemonic"##########",
  n1604_disp = uar_get_code_display(np.new_product_cd)
  FROM modify_option mo,
   new_product np,
   (dummyt d_prod  WITH seq = 1),
   modify_option_testing mot,
   (dummyt d_mot  WITH seq = 1),
   order_catalog_synonym ocs
  PLAN (mo
   WHERE mo.option_id > 0)
   JOIN (((d_prod
   WHERE d_prod.seq=1)
   JOIN (np
   WHERE mo.option_id=np.option_id
    AND mo.division_type_flag IN (1, 2, 4))
   JOIN (ocs
   WHERE np.synonym_id=ocs.synonym_id)
   ) ORJOIN ((d_mot
   WHERE d_mot.seq=1)
   JOIN (mot
   WHERE mo.option_id=mot.option_id
    AND mo.division_type_flag=3)
   ))
  ORDER BY option_unique
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;M",
   col 54, captions->modify_tool, row + 1,
   col 50, captions->mod_options, row + 2,
   line = fillstring(128,"="), line2 = fillstring(100,"-")
  HEAD option_unique
   IF (row >= 49)
    BREAK
   ENDIF
   row + 1, line, row + 1,
   col 2, captions->modify_option, col 18,
   mo.description, col 60, captions->original_product,
   col 80, cv1604_disp, row + 1,
   line, row + 2
   IF (mo.dispose_orig_ind=0)
    col 4, captions->msg1
   ELSEIF (mo.dispose_orig_ind=1)
    col 4, captions->msg2
   ENDIF
   row + 2
   IF (mo.chg_orig_exp_dt_ind=0)
    col 4, captions->msg3
   ELSEIF (mo.chg_orig_exp_dt_ind=1)
    col 4, captions->msg4, row + 2,
    col 19, captions->days
    IF (mo.orig_nbr_days_exp > 0)
     col 27, mo.orig_nbr_days_exp
    ENDIF
    col 40, captions->hours
    IF (mo.orig_nbr_hrs_exp > 0)
     col 50, mo.orig_nbr_hrs_exp
    ENDIF
   ENDIF
   row + 2
   IF (mo.validate_vol_ind=0)
    col 4, captions->msg5
   ELSEIF (mo.validate_vol_ind=1)
    col 4, captions->msg6
   ENDIF
   IF (mo.division_type_flag IN (1, 2, 4))
    row + 2
    IF (mo.calc_exp_drawn_ind=0)
     col 4, captions->msg7
    ELSEIF (mo.calc_exp_drawn_ind=1)
     col 4, captions->msg8
    ENDIF
   ENDIF
   row + 2
   IF (mo.division_type_flag=1)
    col 4, captions->msg9
   ELSEIF (mo.division_type_flag=2)
    col 4, captions->msg10
   ELSEIF (mo.division_type_flag=3)
    col 4, captions->msg11
   ELSEIF (mo.division_type_flag=4)
    col 4, captions->msg12
   ENDIF
   row + 2
   IF (row >= 49)
    BREAK
   ENDIF
   col 15, captions->default_expire
   IF (mo.division_type_flag IN (1, 2, 3))
    col 35, captions->prep
   ENDIF
   IF (mo.division_type_flag IN (1, 2, 4))
    col 45, captions->unit_abo
   ENDIF
   IF (mo.division_type_flag IN (1, 2))
    col 65, captions->default
   ELSEIF (mo.division_type_flag=3)
    col 65, captions->exp_from
   ENDIF
   row + 1, col 2, captions->new_product,
   col 16, captions->rpt_days, col 24,
   captions->rpt_hours
   IF (mo.division_type_flag IN (1, 2, 3))
    col 35, captions->rpt_hours
   ENDIF
   IF (mo.division_type_flag IN (1, 2, 4))
    col 47, captions->test
   ENDIF
   IF (mo.division_type_flag IN (1, 2))
    col 65, captions->sub_id
   ELSEIF (mo.division_type_flag=3)
    col 65, captions->drawn_date
   ENDIF
   IF (mo.division_type_flag=3)
    col 77, captions->attribute
   ENDIF
   IF (mo.division_type_flag IN (1, 2))
    col 85, captions->quantity
   ENDIF
   col 95, captions->active, row + 1,
   col 2, line2, row + 1
  DETAIL
   IF (mo.division_type_flag IN (1, 2, 4))
    col 2, n1604_disp
    IF (np.default_exp_days > 0)
     col 15, np.default_exp_days
    ENDIF
    IF (np.default_exp_hrs > 0)
     col 25, np.default_exp_hrs
    ENDIF
    IF (np.max_prep_hrs > 0)
     col 35, np.max_prep_hrs
    ENDIF
    IF (np.synonym_id > 0)
     col 45, ocs.mnemonic
    ENDIF
    IF (np.sub_prod_id_flag=1)
     col 65, captions->upper_alpha
    ELSEIF (np.sub_prod_id_flag=2)
     col 65, captions->lower_alpha
    ELSEIF (np.sub_prod_id_flag=3)
     col 65, captions->numeric
    ELSEIF (np.sub_prod_id_flag=4)
     col 65, captions->no_default
    ENDIF
    IF (np.quantity > 0)
     col 85, np.quantity
    ENDIF
    IF (np.active_ind=0)
     col 96, captions->no
    ELSEIF (np.active_ind=1)
     col 96, captions->yes
    ENDIF
    row + 1, col 20, captions->default_volume
    IF (np.default_volume_ind=1)
     col 38, np.default_volume
    ELSEIF (np.default_volume_ind=0)
     col 38, captions->none
    ENDIF
    col 50, captions->unit_of_measure
    IF (np.default_measure_ind=1)
     col 69, cv240_disp
    ELSEIF (np.default_measure_ind=0)
     col 69, captions->no_default
    ENDIF
   ELSEIF (mo.division_type_flag=3)
    col 2, c1604_disp
    IF (mot.default_exp_days > 0)
     col 15, mot.default_exp_days
    ENDIF
    IF (mot.default_exp_hrs > 0)
     col 25, mot.default_exp_hrs
    ENDIF
    IF (mot.max_prep_hrs > 0)
     col 35, mot.max_prep_hrs
    ENDIF
    IF (mot.calc_exp_drawn_ind=0)
     col 66, captions->no
    ELSEIF (mot.calc_exp_drawn_ind=1)
     col 66, captions->yes
    ENDIF
    IF (mo.division_type_flag=3)
     IF (mot.special_testing_cd > 0)
      col 77, c1612_disp
     ENDIF
     IF (mot.active_ind=0)
      col 96, captions->no
     ELSEIF (mot.active_ind=1)
      col 96, captions->yes
     ENDIF
    ENDIF
   ENDIF
   row + 1
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
