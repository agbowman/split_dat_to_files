CREATE PROGRAM bb_rpt_mod_options:dba
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
 FREE SET captions
 RECORD captions(
   1 as_of_date = vc
   1 rpt_title = vc
   1 rpt_page = vc
   1 rpt_time = vc
   1 rpt_mod_tool = vc
   1 rpt_mod_options = vc
   1 head_mod_option = vc
   1 head_type = vc
   1 head_active = vc
   1 head_effective = vc
   1 head_to = vc
   1 head_dispose = vc
   1 head_chg_orig_exp = vc
   1 head_days = vc
   1 head_hrs = vc
   1 head_gen_prod_nbr = vc
   1 head_prefix = vc
   1 head_yr = vc
   1 head_seq = vc
   1 head_gen_isbt_nbr = vc
   1 type_new_prod = vc
   1 type_chg_attribute = vc
   1 type_crossover = vc
   1 type_adhoc_split = vc
   1 type_pool = vc
   1 type_split = vc
   1 device = vc
   1 dev_max_capacity = vc
   1 dev_default = vc
   1 dev_start_stop_tm = vc
   1 dev_duration = vc
   1 orig_product = vc
   1 new_product = vc
   1 new_product_details = vc
   1 quantity = vc
   1 def_sub_id = vc
   1 comp_prep_hrs = vc
   1 confirm_order = vc
   1 crossover_reason = vc
   1 validate_bag_type = vc
   1 attributes = vc
   1 expire_dt = vc
   1 orig_expire = vc
   1 exp_days = vc
   1 exp_hrs = vc
   1 calc_exp_from_drawn = vc
   1 allow_exp_ext = vc
   1 volume = vc
   1 orig_vol = vc
   1 default_vol = vc
   1 calc_vol = vc
   1 prompt_vol = vc
   1 validate_vol = vc
   1 unit_of_meas = vc
   1 active = vc
   1 not_active = vc
   1 no_default = vc
   1 uppercase = vc
   1 lowercase = vc
   1 numeric = vc
   1 2_year_format = vc
   1 4_year_format = vc
   1 not_applicable = vc
   1 end_of_report = vc
   1 type_rbc_recon = vc
   1 orig_plasma_product = vc
   1 orig_rbc_product = vc
   1 codabar_barcode = vc
   1 isbt_barcode = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title","DATABASE AUDIT")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","PAGE:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","TIME:")
 SET captions->rpt_mod_tool = uar_i18ngetmessage(i18nhandle,"rpt_mod_tool","MODIFICATION TOOL")
 SET captions->rpt_mod_options = uar_i18ngetmessage(i18nhandle,"rpt_mod_options",
  "MODIFICATION OPTIONS")
 SET captions->head_mod_option = uar_i18ngetmessage(i18nhandle,"head_mod_option",
  "MODIFICATION OPTION:")
 SET captions->head_type = uar_i18ngetmessage(i18nhandle,"head_type","TYPE:")
 SET captions->head_active = uar_i18ngetmessage(i18nhandle,"head_active","ACTIVE:")
 SET captions->head_effective = uar_i18ngetmessage(i18nhandle,"head_effective","EFFECTIVE:")
 SET captions->head_to = uar_i18ngetmessage(i18nhandle,"head_to","TO")
 SET captions->head_dispose = uar_i18ngetmessage(i18nhandle,"head_dispose","DISPOSE ORIGINAL:")
 SET captions->head_chg_orig_exp = uar_i18ngetmessage(i18nhandle,"head_chg_orig_exp",
  "CHANGE ORIG EXP:")
 SET captions->head_days = uar_i18ngetmessage(i18nhandle,"head_days","DAYS:")
 SET captions->head_hrs = uar_i18ngetmessage(i18nhandle,"head_hrs","HRS:")
 SET captions->head_gen_prod_nbr = uar_i18ngetmessage(i18nhandle,"head_gen_prod_nbr","GEN PROD NBR:")
 SET captions->head_prefix = uar_i18ngetmessage(i18nhandle,"head_prefix","PREFIX:")
 SET captions->head_yr = uar_i18ngetmessage(i18nhandle,"head_yr","YEAR:")
 SET captions->head_seq = uar_i18ngetmessage(i18nhandle,"head_seq","SEQ:")
 SET captions->head_gen_isbt_nbr = uar_i18ngetmessage(i18nhandle,"head_gen_isbt_nbr",
  "GEN ISBT PROD NBR:")
 SET captions->type_new_prod = uar_i18ngetmessage(i18nhandle,"type_new_prod","New Product")
 SET captions->type_chg_attribute = uar_i18ngetmessage(i18nhandle,"type_chg_attribute",
  "Change Attribute")
 SET captions->type_crossover = uar_i18ngetmessage(i18nhandle,"type_crossover","Crossover")
 SET captions->type_adhoc_split = uar_i18ngetmessage(i18nhandle,"type_adhoc_split","Ad hoc Split")
 SET captions->type_pool = uar_i18ngetmessage(i18nhandle,"type_pool","Pool Product")
 SET captions->type_split = uar_i18ngetmessage(i18nhandle,"type_split","Split Product")
 SET captions->type_rbc_recon = uar_i18ngetmessage(i18nhandle,"type_rbc_recon",
  "Reconstitute red blood cell")
 SET captions->device = uar_i18ngetmessage(i18nhandle,"device","DEVICE")
 SET captions->dev_max_capacity = uar_i18ngetmessage(i18nhandle,"dev_max_capacity","MAX CAPACITY")
 SET captions->dev_default = uar_i18ngetmessage(i18nhandle,"dev_default","DEFAULT")
 SET captions->dev_start_stop_tm = uar_i18ngetmessage(i18nhandle,"dev_start_stop_tm",
  "START/STOP TIME")
 SET captions->dev_duration = uar_i18ngetmessage(i18nhandle,"dev_duration","DURATION")
 SET captions->orig_product = uar_i18ngetmessage(i18nhandle,"orig_product","ORIGINAL PRODUCT:")
 SET captions->new_product = uar_i18ngetmessage(i18nhandle,"new_product","NEW PRODUCT:")
 SET captions->orig_plasma_product = uar_i18ngetmessage(i18nhandle,"new_product","ORIGINAL PLASMA:")
 SET captions->orig_rbc_product = uar_i18ngetmessage(i18nhandle,"new_product","ORIGINAL RED CELL:")
 SET captions->new_product_details = uar_i18ngetmessage(i18nhandle,"new_product_details",
  "NEW PRODUCT")
 SET captions->quantity = uar_i18ngetmessage(i18nhandle,"quantity","QUANTITY:")
 SET captions->def_sub_id = uar_i18ngetmessage(i18nhandle,"def_sub_id","DEFAULT SUB ID:")
 SET captions->comp_prep_hrs = uar_i18ngetmessage(i18nhandle,"comp_prep_hrs","COMPONENT PREP HRS:")
 SET captions->confirm_order = uar_i18ngetmessage(i18nhandle,"confirm_order","CONFIRMATION ORDER:")
 SET captions->crossover_reason = uar_i18ngetmessage(i18nhandle,"crossover_reason",
  "CROSSOVER REASON:")
 SET captions->validate_bag_type = uar_i18ngetmessage(i18nhandle,"validate_bag_type",
  "VALIDATE BAG TYPE:")
 SET captions->attributes = uar_i18ngetmessage(i18nhandle,"attributes","ATTRIBUTES:")
 SET captions->expire_dt = uar_i18ngetmessage(i18nhandle,"expire_dt","EXPIRATION DATE")
 SET captions->orig_expire = uar_i18ngetmessage(i18nhandle,"orig_expire","ORIGINAL EXPIRE:")
 SET captions->exp_days = uar_i18ngetmessage(i18nhandle,"exp_days","EXPIRE DAYS:")
 SET captions->exp_hrs = uar_i18ngetmessage(i18nhandle,"exp_hrs","EXPIRE HOURS:")
 SET captions->calc_exp_from_drawn = uar_i18ngetmessage(i18nhandle,"calc_exp_from_drawn",
  "CALC EXP FROM DRAWN:")
 SET captions->allow_exp_ext = uar_i18ngetmessage(i18nhandle,"allow_exp_ext","ALLOW EXP EXTENSION:")
 SET captions->volume = uar_i18ngetmessage(i18nhandle,"volume","VOLUME")
 SET captions->orig_vol = uar_i18ngetmessage(i18nhandle,"orig_vol","ORIGINAL VOL:")
 SET captions->default_vol = uar_i18ngetmessage(i18nhandle,"default_vol","DEFAULT VOL:")
 SET captions->calc_vol = uar_i18ngetmessage(i18nhandle,"calc_vol","CALC VOLUME:")
 SET captions->prompt_vol = uar_i18ngetmessage(i18nhandle,"prompt_vol","PROMPT VOL:")
 SET captions->validate_vol = uar_i18ngetmessage(i18nhandle,"validate_vol","VALIDATE VOL:")
 SET captions->unit_of_meas = uar_i18ngetmessage(i18nhandle,"unit_of_meas","UNIT OF MEAS:")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Yes")
 SET captions->not_active = uar_i18ngetmessage(i18nhandle,"not_active","No")
 SET captions->no_default = uar_i18ngetmessage(i18nhandle,"no_default","No Default")
 SET captions->uppercase = uar_i18ngetmessage(i18nhandle,"uppercase","Uppercase Alpha")
 SET captions->lowercase = uar_i18ngetmessage(i18nhandle,"lowercase","Lowercase Alpha")
 SET captions->numeric = uar_i18ngetmessage(i18nhandle,"numeric","Numeric")
 SET captions->2_year_format = uar_i18ngetmessage(i18nhandle,"2_year_format","YY")
 SET captions->4_year_format = uar_i18ngetmessage(i18nhandle,"4_year_format","YYYY")
 SET captions->not_applicable = uar_i18ngetmessage(i18nhandle,"not_applicable","N/A")
 SET captions->isbt_barcode = uar_i18ngetmessage(i18nhandle,"isbt_barcode","ISBT BARCODE:")
 SET captions->codabar_barcode = uar_i18ngetmessage(i18nhandle,"codabar_barcode","CODABAR BARCODE:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report","*** End of Report ***")
 FREE SET mod_details
 RECORD mod_details(
   1 max_option_cnt = i4
   1 max_new_cnt = i4
   1 max_att_cnt = i4
   1 max_pool_cnt = i4
   1 mod_options[*]
     2 option_id = f8
     2 option_key = vc
     2 option = vc
     2 active = i2
     2 change_attribute_ind = i2
     2 adhoc_ind = i2
     2 split_ind = i2
     2 crossover_ind = i2
     2 new_product_ind = i2
     2 pool_product_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 dispose_orig = i2
     2 change_orig_exp = i2
     2 days = f8
     2 hrs = f8
     2 gen_prod_nbr = i2
     2 prefix = vc
     2 year = i2
     2 seq = f8
     2 device_cnt = i4
     2 gen_isbt_nbr_ind = i2
     2 device[*]
       3 device_key = vc
       3 display = vc
       3 max_capacity = i4
       3 default = i2
       3 start_stop_tm = i2
       3 duration = f8
     2 new_prod_cnt = i4
     2 new_prod[*]
       3 mod_new_prod_id = f8
       3 orig_prod_display = vc
       3 new_prod_display = vc
       3 quantity = f8
       3 def_sub_id = i2
       3 prep_hrs = i4
       3 confirm_order = vc
       3 crossover_reason = vc
       3 validate_bag_type = vc
       3 orig_exp = i2
       3 exp_days = i4
       3 exp_hrs = i4
       3 calc_exp_frm_drwn = i2
       3 allow_exp_ext = i2
       3 orig_vol = i2
       3 def_vol = f8
       3 calc_vol = i2
       3 prompt_vol = i2
       3 val_vol = i2
       3 unit_of_meas = vc
       3 attribute_cnt = i4
       3 attributes[*]
         4 special_test = vc
       3 pool_prod_cnt = i4
       3 pool_components[*]
         4 orig_prod_display = vc
       3 orig_plasma_disp = vc
       3 isbt_barcode = vc
       3 codabar_barcode = vc
     2 recon_rbc_ind = i2
 )
 DECLARE stat = i4
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SELECT INTO "nl:"
  b.display_key, b.option_id, option = trim(b.display),
  b.new_product_ind, b.change_attribute_ind, b.crossover_ind,
  b.split_ind, b.ad_hoc_ind, b.pool_product_ind,
  b.recon_rbc_ind, b.active_ind, beg_eff_dt_tm = b.beg_effective_dt_tm,
  end_eff_dt_tm = b.end_effective_dt_tm, b.dispose_orig_ind, b.chg_orig_exp_dt_ind,
  b.orig_nbr_days_exp, b.orig_nbr_hrs_exp, b.generate_prod_nbr_ind,
  b.prod_nbr_prefix, b.prod_nbr_ccyy_ind, b.prod_nbr_starting_nbr,
  device_key = build(trim(uar_get_code_display(bm.device_type_cd))," _ ",bm.device_type_cd), device
   = trim(uar_get_code_display(bm.device_type_cd)), bm.max_capacity,
  bm.default_ind, bm.start_stop_time_ind, bm.modification_duration,
  bm.option_id
  FROM bb_mod_option b,
   bb_mod_device bm
  PLAN (b
   WHERE (((request->active_ind=0)) OR ((request->active_ind=1)
    AND b.active_ind=1))
    AND b.option_id != 0)
   JOIN (bm
   WHERE bm.option_id=outerjoin(b.option_id))
  ORDER BY b.display_key, end_eff_dt_tm DESC, beg_eff_dt_tm DESC,
   b.option_id, device_key
  HEAD REPORT
   count = 0, dev_cnt = 0, stat = alterlist(mod_details->mod_options,10)
  HEAD b.option_id
   count = (count+ 1)
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(mod_details->mod_options,(count+ 9))
   ENDIF
   IF ((mod_details->max_option_cnt < count))
    mod_details->max_option_cnt = count
   ENDIF
   mod_details->mod_options[count].option_key = b.display_key, mod_details->mod_options[count].
   option_id = b.option_id, mod_details->mod_options[count].option = option,
   mod_details->mod_options[count].active = b.active_ind, mod_details->mod_options[count].
   change_attribute_ind = b.change_attribute_ind, mod_details->mod_options[count].new_product_ind = b
   .new_product_ind,
   mod_details->mod_options[count].split_ind = b.split_ind, mod_details->mod_options[count].adhoc_ind
    = b.ad_hoc_ind, mod_details->mod_options[count].crossover_ind = b.crossover_ind,
   mod_details->mod_options[count].pool_product_ind = b.pool_product_ind, mod_details->mod_options[
   count].recon_rbc_ind = b.recon_rbc_ind, mod_details->mod_options[count].beg_effective_dt_tm = b
   .beg_effective_dt_tm,
   mod_details->mod_options[count].end_effective_dt_tm = b.end_effective_dt_tm, mod_details->
   mod_options[count].dispose_orig = b.dispose_orig_ind, mod_details->mod_options[count].
   change_orig_exp = b.chg_orig_exp_dt_ind,
   mod_details->mod_options[count].days = b.orig_nbr_days_exp, mod_details->mod_options[count].hrs =
   b.orig_nbr_hrs_exp, mod_details->mod_options[count].gen_prod_nbr = b.generate_prod_nbr_ind,
   mod_details->mod_options[count].prefix = b.prod_nbr_prefix, mod_details->mod_options[count].year
    = b.prod_nbr_ccyy_ind, mod_details->mod_options[count].seq = b.prod_nbr_starting_nbr,
   mod_details->mod_options[count].gen_isbt_nbr_ind = b.generate_isbt_nbr_ind, dev_cnt = 0, stat =
   alterlist(mod_details->mod_options[count].device,5)
  HEAD device_key
   IF (bm.option_id != 0.00)
    dev_cnt = (dev_cnt+ 1)
    IF (mod(dev_cnt,5)=1
     AND dev_cnt != 1)
     stat = alterlist(mod_details->mod_options[count].device,(dev_cnt+ 4))
    ENDIF
    mod_details->mod_options[count].device_cnt = dev_cnt, mod_details->mod_options[count].device[
    dev_cnt].display = device, mod_details->mod_options[count].device[dev_cnt].max_capacity = bm
    .max_capacity,
    mod_details->mod_options[count].device[dev_cnt].default = bm.default_ind, mod_details->
    mod_options[count].device[dev_cnt].start_stop_tm = bm.start_stop_time_ind, mod_details->
    mod_options[count].device[dev_cnt].duration = bm.modification_duration
   ENDIF
  FOOT  b.option_id
   stat = alterlist(mod_details->mod_options[count].device,dev_cnt)
  FOOT REPORT
   stat = alterlist(mod_details->mod_options,count)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  bmn.mod_new_prod_id, new_prod_key = build(cnvtupper(trim(uar_get_code_display(bmn.orig_product_cd))
    ),"_",bmn.mod_new_prod_id,"_",bmn.orig_plasma_prod_cd), new_prod = trim(uar_get_code_display(bmn
    .new_product_cd)),
  orig_prod = trim(uar_get_code_display(bmn.orig_product_cd)), orig_plasma_prod = trim(
   uar_get_code_display(bmn.orig_plasma_prod_cd)), bmn.quantity,
  bmn.default_sub_id_flag, bmn.max_prep_hrs, bmn.synonym_id,
  confirmation_order = substring(1,15,oc.mnemonic), crossover_reason = trim(uar_get_code_display(bmn
    .crossover_reason_cd)), val_bag_type = trim(uar_get_code_display(bmn.bag_type_cd)),
  bmn.default_orig_exp_ind, bmn.default_exp_days, bmn.default_exp_hrs,
  bmn.calc_exp_drawn_ind, bmn.allow_extend_exp_ind, bmn.default_orig_vol_ind,
  bmn.default_volume, bmn.calc_vol_ind, bmn.prompt_vol_ind,
  bmn.validate_vol_ind, units_measure = trim(uar_get_code_display(bmn.default_unit_of_meas_cd)), d1
  .seq
  FROM (dummyt d1  WITH seq = value(mod_details->max_option_cnt)),
   bb_mod_new_product bmn,
   order_catalog_synonym oc
  PLAN (d1
   WHERE (d1.seq <= mod_details->max_option_cnt))
   JOIN (bmn
   WHERE (bmn.option_id=mod_details->mod_options[d1.seq].option_id))
   JOIN (oc
   WHERE oc.synonym_id=bmn.synonym_id)
  ORDER BY d1.seq, new_prod_key
  HEAD REPORT
   new_cnt = 0
  HEAD d1.seq
   new_cnt = 0, stat = alterlist(mod_details->mod_options[d1.seq].new_prod,10)
  HEAD new_prod_key
   new_cnt = (new_cnt+ 1)
   IF (mod(new_cnt,10)=1
    AND new_cnt != 1)
    stat = alterlist(mod_details->mod_options[d1.seq].new_prod,(new_cnt+ 9))
   ENDIF
   IF ((mod_details->max_new_cnt < new_cnt))
    mod_details->max_new_cnt = new_cnt
   ENDIF
   mod_details->mod_options[d1.seq].new_prod[new_cnt].mod_new_prod_id = bmn.mod_new_prod_id,
   mod_details->mod_options[d1.seq].new_prod[new_cnt].new_prod_display = new_prod, mod_details->
   mod_options[d1.seq].new_prod[new_cnt].orig_prod_display = orig_prod,
   mod_details->mod_options[d1.seq].new_prod[new_cnt].orig_plasma_disp = orig_plasma_prod,
   mod_details->mod_options[d1.seq].new_prod[new_cnt].quantity = bmn.quantity, mod_details->
   mod_options[d1.seq].new_prod[new_cnt].def_sub_id = bmn.default_sub_id_flag,
   mod_details->mod_options[d1.seq].new_prod[new_cnt].prep_hrs = bmn.max_prep_hrs, mod_details->
   mod_options[d1.seq].new_prod[new_cnt].confirm_order = confirmation_order, mod_details->
   mod_options[d1.seq].new_prod[new_cnt].crossover_reason = crossover_reason,
   mod_details->mod_options[d1.seq].new_prod[new_cnt].orig_exp = bmn.default_orig_exp_ind,
   mod_details->mod_options[d1.seq].new_prod[new_cnt].exp_days = bmn.default_exp_days, mod_details->
   mod_options[d1.seq].new_prod[new_cnt].exp_hrs = bmn.default_exp_hrs,
   mod_details->mod_options[d1.seq].new_prod[new_cnt].calc_exp_frm_drwn = bmn.calc_exp_drawn_ind,
   mod_details->mod_options[d1.seq].new_prod[new_cnt].allow_exp_ext = bmn.allow_extend_exp_ind,
   mod_details->mod_options[d1.seq].new_prod[new_cnt].orig_vol = bmn.default_orig_vol_ind,
   mod_details->mod_options[d1.seq].new_prod[new_cnt].def_vol = bmn.default_volume, mod_details->
   mod_options[d1.seq].new_prod[new_cnt].calc_vol = bmn.calc_vol_ind, mod_details->mod_options[d1.seq
   ].new_prod[new_cnt].prompt_vol = bmn.prompt_vol_ind,
   mod_details->mod_options[d1.seq].new_prod[new_cnt].val_vol = bmn.validate_vol_ind, mod_details->
   mod_options[d1.seq].new_prod[new_cnt].unit_of_meas = units_measure, mod_details->mod_options[d1
   .seq].new_prod[new_cnt].codabar_barcode = bmn.codabar_barcode,
   mod_details->mod_options[d1.seq].new_prod[new_cnt].isbt_barcode = bmn.isbt_barcode, mod_details->
   mod_options[d1.seq].new_prod_cnt = new_cnt
  FOOT  d1.seq
   stat = alterlist(mod_details->mod_options[d1.seq].new_prod,new_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  orig_product_key = build(cnvtupper(trim(uar_get_code_display(bmo.orig_product_cd))),"_",bmo
   .orig_product_cd), orig_product = trim(uar_get_code_display(bmo.orig_product_cd)), d1.seq,
  d2.seq
  FROM (dummyt d1  WITH seq = value(mod_details->max_option_cnt)),
   (dummyt d2  WITH seq = value(mod_details->max_new_cnt)),
   bb_mod_orig_product bmo
  PLAN (d1
   WHERE (d1.seq <= mod_details->max_option_cnt))
   JOIN (d2
   WHERE (d2.seq <= mod_details->mod_options[d1.seq].new_prod_cnt)
    AND (mod_details->mod_options[d1.seq].pool_product_ind=1))
   JOIN (bmo
   WHERE (bmo.option_id=mod_details->mod_options[d1.seq].option_id))
  ORDER BY d1.seq, orig_product_key
  HEAD REPORT
   pool_cnt = 0
  HEAD d1.seq
   pool_cnt = 0, stat = alterlist(mod_details->mod_options[d1.seq].new_prod[d2.seq].pool_components,5
    )
  HEAD orig_product_key
   pool_cnt = (pool_cnt+ 1)
   IF (mod(pool_cnt,5)=1
    AND pool_cnt != 1)
    stat = alterlist(mod_details->mod_options[d1.seq].new_prod[d2.seq].pool_components,(pool_cnt+ 4))
   ENDIF
   IF ((mod_details->max_pool_cnt < pool_cnt))
    mod_details->max_pool_cnt = pool_cnt
   ENDIF
   mod_details->mod_options[d1.seq].new_prod[d2.seq].pool_components[pool_cnt].orig_prod_display =
   orig_product, mod_details->mod_options[d1.seq].new_prod[d2.seq].pool_prod_cnt = pool_cnt
  FOOT  d1.seq
   stat = alterlist(mod_details->mod_options[d1.seq].new_prod[d2.seq].pool_components,pool_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  att_key = build(cnvtupper(trim(uar_get_code_display(bmsp.special_testing_cd))),"_",bmsp
   .special_testing_cd), attribute = trim(uar_get_code_display(bmsp.special_testing_cd)), d1.seq,
  d2.seq
  FROM (dummyt d1  WITH seq = value(mod_details->max_option_cnt)),
   (dummyt d2  WITH seq = value(mod_details->max_new_cnt)),
   bb_mod_special_testing bmsp
  PLAN (d1
   WHERE (d1.seq <= mod_details->max_option_cnt)
    AND (((mod_details->mod_options[d1.seq].change_attribute_ind=1)) OR ((mod_details->mod_options[d1
   .seq].recon_rbc_ind=1))) )
   JOIN (d2
   WHERE (d2.seq <= mod_details->mod_options[d1.seq].new_prod_cnt))
   JOIN (bmsp
   WHERE bmsp.mod_new_prod_id=outerjoin(mod_details->mod_options[d1.seq].new_prod[d2.seq].
    mod_new_prod_id))
  ORDER BY d1.seq, d2.seq, att_key
  HEAD REPORT
   att_cnt = 0
  HEAD d1.seq
   att_cnt = 0
  HEAD d2.seq
   att_cnt = 0, stat = alterlist(mod_details->mod_options[d1.seq].new_prod[d2.seq].attributes,5)
  HEAD att_key
   IF (bmsp.mod_new_prod_id > 0)
    att_cnt = (att_cnt+ 1)
    IF (mod(att_cnt,5)=1
     AND att_cnt != 1)
     stat = alterlist(mod_details->mod_options[d1.seq].new_prod[d2.seq].attributes,(att_cnt+ 4))
    ENDIF
    IF ((mod_details->max_att_cnt < att_cnt))
     mod_details->max_att_cnt = att_cnt
    ENDIF
    mod_details->mod_options[d1.seq].new_prod[d2.seq].attributes[att_cnt].special_test = attribute
   ENDIF
  FOOT  d2.seq
   mod_details->mod_options[d1.seq].new_prod[d2.seq].attribute_cnt = att_cnt, stat = alterlist(
    mod_details->mod_options[d1.seq].new_prod[d2.seq].attributes,att_cnt)
  WITH nocounter
 ;end select
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_mod_options", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  option_display = mod_details->mod_options[b.seq].option, b.seq, bmn.seq
  FROM (dummyt b  WITH seq = value(mod_details->max_option_cnt)),
   (dummyt bmn  WITH seq = value(mod_details->max_new_cnt))
  PLAN (b
   WHERE (b.seq <= mod_details->max_option_cnt))
   JOIN (bmn
   WHERE (bmn.seq <= mod_details->mod_options[b.seq].new_prod_cnt))
  ORDER BY b.seq, bmn.seq
  HEAD REPORT
   select_ok_ind = 0, i = 0, line0 = fillstring(126,"="),
   line1 = fillstring(30,"-"), line2 = fillstring(12,"-"), line3 = fillstring(7,"-"),
   line4 = fillstring(15,"-"), line5 = fillstring(8,"-"), line6 = fillstring(11,"-"),
   line7 = fillstring(4,"-"), line8 = fillstring(10,"-")
  HEAD PAGE
   col 0, captions->as_of_date, col 12,
   curdate"@DATECONDENSED;;d",
   CALL center(captions->rpt_title,0,125), col 108,
   captions->rpt_page, col 114, curpage";L",
   row + 1, col 0, captions->rpt_time,
   col 12, curtime"@TIMENOSECONDS;;M",
   CALL center(captions->rpt_mod_tool,0,125),
   row + 1,
   CALL center(captions->rpt_mod_options,0,125), row + 2
  HEAD b.seq
   IF (row > 50)
    BREAK
   ENDIF
   col 0, line0, row + 1,
   col 0, captions->head_mod_option, col 21,
   mod_details->mod_options[b.seq].option, col 64, captions->head_active
   IF ((mod_details->mod_options[b.seq].active=1))
    col 72, captions->active
   ELSE
    col 72, captions->not_active
   ENDIF
   col 77, captions->head_effective, col 88,
   mod_details->mod_options[b.seq].beg_effective_dt_tm"DD-MMM-YYYY HH:MM;;d", col 106, captions->
   head_to,
   col 109, mod_details->mod_options[b.seq].end_effective_dt_tm"DD-MMM-YYYY HH:MM;;d", row + 1,
   col 0, captions->head_type
   IF ((mod_details->mod_options[b.seq].new_product_ind=1))
    IF (col > 6)
     col + 0, ",", col + 1,
     captions->type_new_prod
    ELSE
     col 6, captions->type_new_prod
    ENDIF
   ENDIF
   IF ((mod_details->mod_options[b.seq].change_attribute_ind=1))
    IF (col > 6)
     col + 0, ",", col + 1,
     captions->type_chg_attribute
    ELSE
     col 6, captions->type_chg_attribute
    ENDIF
   ENDIF
   IF ((mod_details->mod_options[b.seq].split_ind=1))
    IF (col > 6)
     col + 0, ",", col + 1,
     captions->type_split
    ELSE
     col 6, captions->type_split
    ENDIF
    IF ((mod_details->mod_options[b.seq].adhoc_ind=1))
     col + 0, ",", col + 1,
     captions->type_adhoc_split
    ENDIF
   ENDIF
   IF ((mod_details->mod_options[b.seq].crossover_ind=1))
    IF (col > 6)
     col + 0, ",", col + 1,
     captions->type_crossover
    ELSE
     col 6, captions->type_crossover
    ENDIF
   ENDIF
   IF ((mod_details->mod_options[b.seq].pool_product_ind=1))
    IF (col > 6)
     col + 0, ",", col + 1,
     captions->type_pool
    ELSE
     col 6, captions->type_pool
    ENDIF
   ENDIF
   IF ((mod_details->mod_options[b.seq].recon_rbc_ind=1))
    IF (col > 6)
     col + 0, ",", col + 1,
     captions->type_rbc_recon
    ELSE
     col 6, captions->type_rbc_recon
    ENDIF
   ENDIF
   col 64, captions->head_dispose
   IF ((mod_details->mod_options[b.seq].dispose_orig=1))
    col 82, captions->active
   ELSE
    col 82, captions->not_active
   ENDIF
   col 87, captions->head_chg_orig_exp
   IF ((mod_details->mod_options[b.seq].change_orig_exp=1))
    col 104, captions->active
   ELSE
    col 104, captions->not_active
   ENDIF
   col 109, captions->head_days, col 115,
   mod_details->mod_options[b.seq].days"##", col 119, captions->head_hrs,
   col 124, mod_details->mod_options[b.seq].hrs"##"
   IF ((mod_details->mod_options[b.seq].pool_product_ind=1))
    row + 1, col 64, captions->head_gen_prod_nbr
    IF ((mod_details->mod_options[b.seq].gen_prod_nbr=1))
     col 78, captions->active, col 83,
     captions->head_prefix, col 91, mod_details->mod_options[b.seq].prefix,
     col 103, captions->head_yr
     IF ((mod_details->mod_options[b.seq].year=0))
      col 109, captions->2_year_format
     ELSE
      col 109, captions->4_year_format
     ENDIF
     col 115, captions->head_seq, col 120,
     mod_details->mod_options[b.seq].seq"######;P0"
    ELSE
     col 78, captions->not_active, col 83,
     captions->head_prefix, col 91, captions->not_applicable,
     col 103, captions->head_yr, col 109,
     captions->not_applicable, col 115, captions->head_seq,
     col 120, captions->not_applicable
    ENDIF
    row + 1, col 64, captions->head_gen_isbt_nbr
    IF ((mod_details->mod_options[b.seq].gen_isbt_nbr_ind=1))
     col 83, captions->active
    ELSE
     col 83, captions->not_active
    ENDIF
   ENDIF
   row + 1, col 0, line0,
   row + 1
   IF (row > 55)
    BREAK
   ENDIF
   IF ((mod_details->mod_options[b.seq].device_cnt > 0))
    col 0, captions->device, col 32,
    captions->dev_max_capacity, col 46, captions->dev_default,
    col 55, captions->dev_start_stop_tm, col 72,
    captions->dev_duration, row + 1, col 0,
    line1, col 32, line2,
    col 46, line3, col 55,
    line4, col 72, line5,
    row + 1
    FOR (i = 1 TO mod_details->mod_options[b.seq].device_cnt)
      col 0, mod_details->mod_options[b.seq].device[i].display, col 32,
      mod_details->mod_options[b.seq].device[i].max_capacity"##;L"
      IF ((mod_details->mod_options[b.seq].device[i].default=1))
       col 46, captions->active
      ELSE
       col 46, captions->not_active
      ENDIF
      IF ((mod_details->mod_options[b.seq].device[i].start_stop_tm=1))
       col 55, captions->active
      ELSE
       col 55, captions->not_active
      ENDIF
      col 72, mod_details->mod_options[b.seq].device[i].duration"##:##;P0", row + 1
    ENDFOR
   ENDIF
  HEAD bmn.seq
   IF (row > 47)
    BREAK
   ENDIF
   row + 1
   IF ((mod_details->mod_options[b.seq].recon_rbc_ind=1))
    col 0, captions->orig_rbc_product
   ELSE
    col 0, captions->orig_product
   ENDIF
   IF ((mod_details->mod_options[b.seq].pool_product_ind=1))
    FOR (i = 1 TO mod_details->mod_options[b.seq].new_prod[bmn.seq].pool_prod_cnt)
      col 18, mod_details->mod_options[b.seq].new_prod[bmn.seq].pool_components[i].orig_prod_display
      IF ((i=mod_details->mod_options[b.seq].new_prod[bmn.seq].pool_prod_cnt)
       AND i > 1)
       row + 2
      ELSE
       row + 1
      ENDIF
    ENDFOR
   ELSE
    col 18, mod_details->mod_options[b.seq].new_prod[bmn.seq].orig_prod_display, row + 1
   ENDIF
   IF ((mod_details->mod_options[b.seq].recon_rbc_ind=1))
    col 0, captions->orig_plasma_product
    IF ((mod_details->mod_options[b.seq].recon_rbc_ind=1))
     col 18, mod_details->mod_options[b.seq].new_prod[bmn.seq].orig_plasma_disp
    ELSE
     col 18, captions->not_applicable
    ENDIF
    row + 1
   ENDIF
   col 0, captions->new_product, col 18,
   mod_details->mod_options[b.seq].new_prod[bmn.seq].new_prod_display, row + 1, col 18,
   line6, col 30, captions->new_product_details,
   col 42, line6, col 55,
   line7, col 60, captions->expire_dt,
   col 76, line7, col 82,
   line8, col 93, captions->volume,
   col 100, line8, row + 1,
   col 18, captions->quantity
   IF ((mod_details->mod_options[b.seq].split_ind=1))
    col 38, mod_details->mod_options[b.seq].new_prod[bmn.seq].quantity"###;L"
   ELSE
    col 38, captions->not_applicable
   ENDIF
   col 55, captions->orig_expire
   IF ((((mod_details->mod_options[b.seq].new_product_ind=1)) OR ((((mod_details->mod_options[b.seq].
   split_ind=1)) OR ((((mod_details->mod_options[b.seq].change_attribute_ind=1)) OR ((((mod_details->
   mod_options[b.seq].crossover_ind=1)) OR ((mod_details->mod_options[b.seq].recon_rbc_ind=1))) ))
   )) )) )
    IF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].orig_exp=1))
     col 76, captions->active
    ELSE
     col 76, captions->not_active
    ENDIF
   ELSE
    col 76, captions->not_applicable
   ENDIF
   col 82, captions->orig_vol
   IF ((((mod_details->mod_options[b.seq].new_product_ind=1)) OR ((((mod_details->mod_options[b.seq].
   change_attribute_ind=1)) OR ((mod_details->mod_options[b.seq].crossover_ind=1))) ))
    AND (mod_details->mod_options[b.seq].split_ind != 1))
    IF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].orig_vol=1))
     col 96, captions->active
    ELSE
     col 96, captions->not_active
    ENDIF
   ELSE
    col 96, captions->not_applicable
   ENDIF
   row + 1, col 18, captions->def_sub_id
   IF ((mod_details->mod_options[b.seq].split_ind=1))
    IF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].def_sub_id=0))
     col 38, captions->no_default
    ELSEIF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].def_sub_id=1))
     col 38, captions->uppercase
    ELSEIF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].def_sub_id=2))
     col 38, captions->lowercase
    ELSEIF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].def_sub_id=3))
     col 38, captions->numeric
    ENDIF
   ELSE
    col 38, captions->not_applicable
   ENDIF
   col 55, captions->exp_days, col 76,
   mod_details->mod_options[b.seq].new_prod[bmn.seq].exp_days"#####;L", col 82, captions->default_vol
   IF ((((mod_details->mod_options[b.seq].new_product_ind=1)) OR ((((mod_details->mod_options[b.seq].
   split_ind=1)) OR ((mod_details->mod_options[b.seq].change_attribute_ind=1))) ))
    AND (mod_details->mod_options[b.seq].pool_product_ind != 1))
    col 96, mod_details->mod_options[b.seq].new_prod[bmn.seq].def_vol"#####;L"
   ELSE
    col 96, captions->not_applicable
   ENDIF
   row + 1, col 18, captions->comp_prep_hrs
   IF ((((mod_details->mod_options[b.seq].new_product_ind=1)) OR ((((mod_details->mod_options[b.seq].
   split_ind=1)) OR ((((mod_details->mod_options[b.seq].change_attribute_ind=1)) OR ((mod_details->
   mod_options[b.seq].crossover_ind=1))) )) ))
    AND (mod_details->mod_options[b.seq].pool_product_ind != 1))
    col 38, mod_details->mod_options[b.seq].new_prod[bmn.seq].prep_hrs";L"
   ELSE
    col 38, captions->not_applicable
   ENDIF
   col 55, captions->exp_hrs, col 76,
   mod_details->mod_options[b.seq].new_prod[bmn.seq].exp_hrs"####;L", col 82, captions->calc_vol
   IF ((mod_details->mod_options[b.seq].pool_product_ind=1))
    IF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].calc_vol=1))
     col 96, captions->active
    ELSE
     col 96, captions->not_active
    ENDIF
   ELSE
    col 96, captions->not_applicable
   ENDIF
   row + 1, col 18, captions->confirm_order
   IF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].confirm_order="0"))
    col 38, " "
   ELSE
    col 38, mod_details->mod_options[b.seq].new_prod[bmn.seq].confirm_order
   ENDIF
   col 55, captions->calc_exp_from_drawn
   IF ((((mod_details->mod_options[b.seq].new_product_ind=1)) OR ((((mod_details->mod_options[b.seq].
   split_ind=1)) OR ((mod_details->mod_options[b.seq].change_attribute_ind=1))) ))
    AND (mod_details->mod_options[b.seq].pool_product_ind != 1))
    IF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].calc_exp_frm_drwn=1))
     col 76, captions->active
    ELSE
     col 76, captions->not_active
    ENDIF
   ELSE
    col 76, captions->not_applicable
   ENDIF
   col 82, captions->prompt_vol
   IF ((((mod_details->mod_options[b.seq].new_product_ind=1)) OR ((((mod_details->mod_options[b.seq].
   split_ind=1)) OR ((((mod_details->mod_options[b.seq].change_attribute_ind=1)) OR ((((mod_details->
   mod_options[b.seq].crossover_ind=1)) OR ((mod_details->mod_options[b.seq].pool_product_ind=1)))
   )) )) )) )
    IF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].prompt_vol=1))
     col 96, captions->active
    ELSE
     col 96, captions->not_active
    ENDIF
   ELSE
    col 96, captions->not_applicable
   ENDIF
   row + 1, col 18, captions->crossover_reason
   IF ((mod_details->mod_options[b.seq].crossover_ind=1))
    col 38, mod_details->mod_options[b.seq].new_prod[bmn.seq].crossover_reason
   ELSE
    col 38, captions->not_applicable
   ENDIF
   col 55, captions->allow_exp_ext
   IF ((((mod_details->mod_options[b.seq].new_product_ind=1)) OR ((((mod_details->mod_options[b.seq].
   change_attribute_ind=1)) OR ((((mod_details->mod_options[b.seq].split_ind=1)) OR ((((mod_details->
   mod_options[b.seq].pool_product_ind=1)) OR ((mod_details->mod_options[b.seq].recon_rbc_ind=1)))
   )) )) )) )
    IF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].allow_exp_ext=1))
     col 76, captions->active
    ELSE
     col 76, captions->not_active
    ENDIF
   ELSE
    col 76, captions->not_applicable
   ENDIF
   col 82, captions->validate_vol
   IF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].val_vol=1))
    col 96, captions->active
   ELSE
    col 96, captions->not_active
   ENDIF
   row + 1, col 18, captions->codabar_barcode
   IF ((((mod_details->mod_options[b.seq].new_product_ind=1)) OR ((((mod_details->mod_options[b.seq].
   crossover_ind=1)) OR ((((mod_details->mod_options[b.seq].pool_product_ind=1)) OR ((mod_details->
   mod_options[b.seq].recon_rbc_ind=1))) )) )) )
    col 38, mod_details->mod_options[b.seq].new_prod[bmn.seq].codabar_barcode
   ELSE
    col 38, captions->not_applicable
   ENDIF
   col 82, captions->unit_of_meas, col 96,
   mod_details->mod_options[b.seq].new_prod[bmn.seq].unit_of_meas, row + 1, col 18,
   captions->isbt_barcode
   IF ((((mod_details->mod_options[b.seq].new_product_ind=1)) OR ((((mod_details->mod_options[b.seq].
   crossover_ind=1)) OR ((((mod_details->mod_options[b.seq].pool_product_ind=1)) OR ((mod_details->
   mod_options[b.seq].recon_rbc_ind=1))) )) )) )
    col 38, mod_details->mod_options[b.seq].new_prod[bmn.seq].isbt_barcode
   ELSE
    col 38, captions->not_applicable
   ENDIF
   row + 1
   IF ((mod_details->mod_options[b.seq].new_prod[bmn.seq].attribute_cnt > 0))
    col 18, captions->attributes
    FOR (i = 1 TO mod_details->mod_options[b.seq].new_prod[bmn.seq].attribute_cnt)
      IF (i > 1)
       col + 0, ",", col + 1,
       mod_details->mod_options[b.seq].new_prod[bmn.seq].attributes[i].special_test
      ELSE
       col 38, mod_details->mod_options[b.seq].new_prod[bmn.seq].attributes[i].special_test
      ENDIF
    ENDFOR
   ENDIF
   row + 2
  FOOT REPORT
   row + 3, col 53, captions->end_of_report,
   select_ok_ind = 1
  WITH nocounter, nullreport, compress,
   nolandscape
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = concat("cer_print:",cpm_cfn_info->file_name)
 FREE SET captions
 FREE SET mod_details
#exit_script
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
