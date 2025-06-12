CREATE PROGRAM bbt_get_bb_mod_option:dba
 RECORD reply(
   1 options[*]
     2 option_id = f8
     2 display = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 new_product_ind = i2
     2 split_ind = i2
     2 ad_hoc_ind = i2
     2 change_attribute_ind = i2
     2 crossover_ind = i2
     2 pool_product_ind = i2
     2 generate_prod_nbr_ind = i2
     2 prod_nbr_prefix = c10
     2 prod_nbr_ccyy_ind = i2
     2 prod_nbr_starting_nbr = i4
     2 dispose_orig_ind = i2
     2 chg_orig_exp_dt_ind = i2
     2 orig_nbr_days_exp = i2
     2 orig_nbr_hrs_exp = i2
     2 active_ind = i2
     2 updt_cnt = i4
     2 orig_prods[*]
       3 orig_product_cd = f8
       3 orig_product_disp = vc
       3 e_numbers[*]
         4 e_number = vc
     2 new_prods[*]
       3 mod_new_prod_id = f8
       3 orig_product_cd = f8
       3 orig_product_disp = vc
       3 new_product_cd = f8
       3 new_product_disp = vc
       3 quantity = f8
       3 default_sub_id_flag = i2
       3 max_prep_hrs = f8
       3 default_orig_exp_ind = i2
       3 calc_exp_drawn_ind = i2
       3 default_exp_days = f8
       3 default_exp_hrs = f8
       3 allow_extend_exp_ind = i2
       3 default_orig_vol_ind = i2
       3 default_volume = f8
       3 calc_vol_ind = i2
       3 prompt_vol_ind = i2
       3 validate_vol_ind = i2
       3 default_unit_of_meas_cd = f8
       3 default_unit_of_meas_disp = vc
       3 synonym_id = f8
       3 require_assign_ind = i2
       3 bag_type_cd = f8
       3 bag_type_disp = vc
       3 crossover_reason_cd = f8
       3 crossover_reason_disp = vc
       3 allow_no_aborh_ind = i2
       3 default_supplier_id = f8
       3 spec_testings[*]
         4 special_testing_cd = f8
         4 special_testing_disp = vc
         4 special_testing_mean = c12
         4 special_isbt = vc
       3 e_numbers[*]
         4 e_number = vc
       3 orig_plasma_prod_cd = f8
       3 orig_plasma_prod_disp = vc
       3 default_isbt_barcode = vc
       3 default_codabar_barcode = vc
     2 devices[*]
       3 device_type_cd = f8
       3 device_type_disp = vc
       3 device_type_mean = vc
       3 default_ind = i2
       3 max_capacity = f8
       3 start_stop_time_ind = i2
       3 modification_duration = f8
     2 label_info_prompt_ind = i2
     2 generate_isbt_nbr_ind = i2
     2 recon_rbc_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE mo_cnt = i4 WITH noconstant(0)
 DECLARE mop_cnt = i4 WITH noconstant(0)
 DECLARE mnp_cnt = i4 WITH noconstant(0)
 DECLARE mst_cnt = i4 WITH noconstant(0)
 DECLARE isbt_cnt = i4 WITH noconstant(0)
 DECLARE md_cnt = i4 WITH noconstant(0)
 DECLARE inactive_cnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 RECORD modification(
   1 options[*]
     2 option_id = f8
     2 display = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 new_product_ind = i2
     2 split_ind = i2
     2 ad_hoc_ind = i2
     2 change_attribute_ind = i2
     2 crossover_ind = i2
     2 pool_product_ind = i2
     2 generate_prod_nbr_ind = i2
     2 prod_nbr_prefix = c10
     2 prod_nbr_ccyy_ind = i2
     2 prod_nbr_starting_nbr = i4
     2 dispose_orig_ind = i2
     2 chg_orig_exp_dt_ind = i2
     2 orig_nbr_days_exp = i2
     2 orig_nbr_hrs_exp = i2
     2 active_ind = i2
     2 updt_cnt = i4
     2 orig_prods[*]
       3 orig_product_cd = f8
       3 orig_product_disp = vc
       3 e_numbers[*]
         4 e_number = vc
     2 new_prods[*]
       3 mod_new_prod_id = f8
       3 orig_product_cd = f8
       3 orig_product_disp = vc
       3 new_product_cd = f8
       3 new_product_disp = vc
       3 quantity = f8
       3 default_sub_id_flag = i2
       3 max_prep_hrs = f8
       3 default_orig_exp_ind = i2
       3 calc_exp_drawn_ind = i2
       3 default_exp_days = f8
       3 default_exp_hrs = f8
       3 allow_extend_exp_ind = i2
       3 default_orig_vol_ind = i2
       3 default_volume = f8
       3 calc_vol_ind = i2
       3 prompt_vol_ind = i2
       3 validate_vol_ind = i2
       3 default_unit_of_meas_cd = f8
       3 default_unit_of_meas_disp = vc
       3 synonym_id = f8
       3 require_assign_ind = i2
       3 bag_type_cd = f8
       3 bag_type_disp = vc
       3 crossover_reason_cd = f8
       3 crossover_reason_disp = vc
       3 allow_no_aborh_ind = i2
       3 default_supplier_id = f8
       3 spec_testings[*]
         4 special_testing_cd = f8
         4 special_testing_disp = vc
         4 special_testing_mean = c12
         4 special_isbt = vc
       3 e_numbers[*]
         4 e_number = vc
       3 orig_plasma_prod_cd = f8
       3 orig_plasma_prod_disp = vc
       3 default_isbt_barcode = vc
       3 default_codabar_barcode = vc
     2 devices[*]
       3 device_type_cd = f8
       3 device_type_disp = vc
       3 device_type_mean = vc
       3 default_ind = i2
       3 max_capacity = f8
       3 start_stop_time_ind = i2
       3 modification_duration = f8
     2 label_info_prompt_ind = i2
     2 generate_isbt_nbr_ind = i2
     2 recon_rbc_ind = i2
 )
 SELECT INTO "nl:"
  mo.display_key, beg_dt_tm = cnvtdatetime(mo.beg_effective_dt_tm)";;q", end_dt_tm = cnvtdatetime(mo
   .end_effective_dt_tm)";;q"
  FROM bb_mod_option mo
  PLAN (mo
   WHERE mo.option_id > 0.0
    AND (((request->load_inactive_ind=0)
    AND mo.active_ind=1) OR ((request->load_inactive_ind=1)))
    AND (((request->option_id > 0.0)
    AND (mo.option_id=request->option_id)) OR ((request->option_id=0.0))) )
  ORDER BY mo.display_key, end_dt_tm DESC, beg_dt_tm DESC
  HEAD REPORT
   mo_cnt = 0
  DETAIL
   mo_cnt += 1
   IF (mod(mo_cnt,10)=1)
    stat = alterlist(modification->options,(mo_cnt+ 9))
   ENDIF
   modification->options[mo_cnt].option_id = mo.option_id, modification->options[mo_cnt].display = mo
   .display, modification->options[mo_cnt].beg_effective_dt_tm = cnvtdatetime(mo.beg_effective_dt_tm),
   modification->options[mo_cnt].end_effective_dt_tm = cnvtdatetime(mo.end_effective_dt_tm),
   modification->options[mo_cnt].new_product_ind = mo.new_product_ind, modification->options[mo_cnt].
   split_ind = mo.split_ind,
   modification->options[mo_cnt].ad_hoc_ind = mo.ad_hoc_ind, modification->options[mo_cnt].
   change_attribute_ind = mo.change_attribute_ind, modification->options[mo_cnt].crossover_ind = mo
   .crossover_ind,
   modification->options[mo_cnt].pool_product_ind = mo.pool_product_ind, modification->options[mo_cnt
   ].generate_prod_nbr_ind = mo.generate_prod_nbr_ind, modification->options[mo_cnt].prod_nbr_prefix
    = mo.prod_nbr_prefix,
   modification->options[mo_cnt].prod_nbr_ccyy_ind = mo.prod_nbr_ccyy_ind, modification->options[
   mo_cnt].prod_nbr_starting_nbr = mo.prod_nbr_starting_nbr, modification->options[mo_cnt].
   dispose_orig_ind = mo.dispose_orig_ind,
   modification->options[mo_cnt].chg_orig_exp_dt_ind = mo.chg_orig_exp_dt_ind, modification->options[
   mo_cnt].orig_nbr_days_exp = mo.orig_nbr_days_exp, modification->options[mo_cnt].orig_nbr_hrs_exp
    = mo.orig_nbr_hrs_exp,
   modification->options[mo_cnt].active_ind = mo.active_ind, modification->options[mo_cnt].updt_cnt
    = mo.updt_cnt, modification->options[mo_cnt].label_info_prompt_ind = mo.label_info_prompt_ind,
   modification->options[mo_cnt].generate_isbt_nbr_ind = mo.generate_isbt_nbr_ind, modification->
   options[mo_cnt].recon_rbc_ind = mo.recon_rbc_ind
  FOOT REPORT
   stat = alterlist(modification->options,mo_cnt)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","F","BB_MOD_OPTION",errmsg)
  GO TO build_reply
 ENDIF
 IF (curqual=0)
  GO TO set_status
 ENDIF
 SELECT INTO "nl:"
  d.seq, mop.orig_product_cd, pi.active_ind,
  cv.active_ind
  FROM (dummyt d  WITH seq = value(mo_cnt)),
   bb_mod_orig_product mop,
   product_index pi,
   code_value cv,
   bb_isbt_product_type isbt
  PLAN (d
   WHERE d.seq <= mo_cnt)
   JOIN (mop
   WHERE (mop.option_id=modification->options[d.seq].option_id))
   JOIN (pi
   WHERE pi.product_cd=mop.orig_product_cd)
   JOIN (cv
   WHERE cv.code_value=pi.product_cd)
   JOIN (isbt
   WHERE (isbt.product_cd= Outerjoin(pi.product_cd))
    AND (isbt.active_ind= Outerjoin(1)) )
  ORDER BY d.seq, mop.orig_product_cd, isbt.isbt_barcode
  HEAD REPORT
   cnt = 0, mop_cnt = 0
  HEAD d.seq
   cnt = d.seq, mop_cnt = 0, inactive_cnt = 0
  HEAD mop.orig_product_cd
   IF ((request->load_inactive_ind=0)
    AND ((pi.active_ind=0) OR (cv.active_ind=0)) )
    inactive_cnt += 1
   ENDIF
   mop_cnt += 1
   IF (mod(mop_cnt,10)=1)
    stat = alterlist(modification->options[cnt].orig_prods,(mop_cnt+ 9))
   ENDIF
   modification->options[cnt].orig_prods[mop_cnt].orig_product_cd = mop.orig_product_cd, isbt_cnt = 0
  HEAD isbt.isbt_barcode
   IF (size(trim(isbt.isbt_barcode),1) > 0)
    IF ((modification->options[cnt].new_product_ind=1)
     AND (modification->options[cnt].split_ind=1)
     AND (request->option_id > 0.0))
     isbt_cnt += 1
     IF (mod(isbt_cnt,10)=1)
      stat = alterlist(modification->options[cnt].orig_prods[mop_cnt].e_numbers,(isbt_cnt+ 9))
     ENDIF
     modification->options[cnt].orig_prods[mop_cnt].e_numbers[isbt_cnt].e_number = isbt.isbt_barcode
    ENDIF
   ENDIF
  DETAIL
   row + 0
  FOOT  isbt.isbt_barcode
   row + 0
  FOOT  mop.orig_product_cd
   stat = alterlist(modification->options[cnt].orig_prods[mop_cnt].e_numbers,isbt_cnt)
  FOOT  d.seq
   IF (inactive_cnt=mop_cnt)
    modification->options[cnt].active_ind = 0
   ENDIF
   stat = alterlist(modification->options[cnt].orig_prods,mop_cnt)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","F","BB_MOD_ORIG_PRODUCT",errmsg)
  GO TO build_reply
 ENDIF
 SELECT INTO "nl:"
  d.seq, mnp.mod_new_prod_id, mnp.new_product_cd,
  pi.active_ind, cv.active_ind, mst.special_testing_cd
  FROM (dummyt d  WITH seq = value(mo_cnt)),
   bb_mod_new_product mnp,
   product_index pi,
   code_value cv,
   bb_mod_special_testing mst,
   bb_isbt_product_type isbt,
   bb_isbt_attribute_r biar,
   bb_isbt_attribute bia
  PLAN (d
   WHERE d.seq <= mo_cnt)
   JOIN (mnp
   WHERE (mnp.option_id=modification->options[d.seq].option_id))
   JOIN (pi
   WHERE pi.product_cd=mnp.new_product_cd)
   JOIN (cv
   WHERE cv.code_value=pi.product_cd)
   JOIN (mst
   WHERE (mst.mod_new_prod_id= Outerjoin(mnp.mod_new_prod_id)) )
   JOIN (isbt
   WHERE (isbt.product_cd= Outerjoin(pi.product_cd))
    AND (isbt.active_ind= Outerjoin(1)) )
   JOIN (biar
   WHERE (biar.attribute_cd= Outerjoin(mst.special_testing_cd))
    AND (biar.active_ind= Outerjoin(1)) )
   JOIN (bia
   WHERE (bia.bb_isbt_attribute_id= Outerjoin(biar.bb_isbt_attribute_id))
    AND (bia.active_ind= Outerjoin(1)) )
  ORDER BY d.seq, mnp.mod_new_prod_id, mst.special_testing_cd,
   isbt.isbt_barcode
  HEAD REPORT
   cnt = 0, mnp_cnt = 0, mst_cnt = 0
  HEAD d.seq
   cnt = d.seq, mnp_cnt = 0, inactive_cnt = 0
  HEAD mnp.mod_new_prod_id
   IF ((request->load_inactive_ind=0)
    AND ((pi.active_ind=0) OR (cv.active_ind=0)) )
    inactive_cnt += 1
   ENDIF
   mnp_cnt += 1
   IF (mod(mnp_cnt,10)=1)
    stat = alterlist(modification->options[cnt].new_prods,(mnp_cnt+ 9))
   ENDIF
   modification->options[cnt].new_prods[mnp_cnt].mod_new_prod_id = mnp.mod_new_prod_id, modification
   ->options[cnt].new_prods[mnp_cnt].orig_product_cd = mnp.orig_product_cd, modification->options[cnt
   ].new_prods[mnp_cnt].new_product_cd = mnp.new_product_cd,
   modification->options[cnt].new_prods[mnp_cnt].quantity = mnp.quantity, modification->options[cnt].
   new_prods[mnp_cnt].default_sub_id_flag = mnp.default_sub_id_flag, modification->options[cnt].
   new_prods[mnp_cnt].max_prep_hrs = mnp.max_prep_hrs,
   modification->options[cnt].new_prods[mnp_cnt].default_orig_exp_ind = mnp.default_orig_exp_ind,
   modification->options[cnt].new_prods[mnp_cnt].calc_exp_drawn_ind = mnp.calc_exp_drawn_ind,
   modification->options[cnt].new_prods[mnp_cnt].default_exp_days = mnp.default_exp_days,
   modification->options[cnt].new_prods[mnp_cnt].default_exp_hrs = mnp.default_exp_hrs, modification
   ->options[cnt].new_prods[mnp_cnt].allow_extend_exp_ind = mnp.allow_extend_exp_ind, modification->
   options[cnt].new_prods[mnp_cnt].default_orig_vol_ind = mnp.default_orig_vol_ind,
   modification->options[cnt].new_prods[mnp_cnt].default_volume = mnp.default_volume, modification->
   options[cnt].new_prods[mnp_cnt].calc_vol_ind = mnp.calc_vol_ind, modification->options[cnt].
   new_prods[mnp_cnt].prompt_vol_ind = mnp.prompt_vol_ind,
   modification->options[cnt].new_prods[mnp_cnt].validate_vol_ind = mnp.validate_vol_ind,
   modification->options[cnt].new_prods[mnp_cnt].default_unit_of_meas_cd = mnp
   .default_unit_of_meas_cd, modification->options[cnt].new_prods[mnp_cnt].synonym_id = mnp
   .synonym_id,
   modification->options[cnt].new_prods[mnp_cnt].require_assign_ind = mnp.require_assign_ind,
   modification->options[cnt].new_prods[mnp_cnt].bag_type_cd = mnp.bag_type_cd, modification->
   options[cnt].new_prods[mnp_cnt].crossover_reason_cd = mnp.crossover_reason_cd,
   modification->options[cnt].new_prods[mnp_cnt].allow_no_aborh_ind = mnp.allow_no_aborh_ind,
   modification->options[cnt].new_prods[mnp_cnt].default_supplier_id = mnp.default_supplier_id,
   modification->options[cnt].new_prods[mnp_cnt].orig_plasma_prod_cd = mnp.orig_plasma_prod_cd,
   modification->options[cnt].new_prods[mnp_cnt].default_isbt_barcode = mnp.isbt_barcode,
   modification->options[cnt].new_prods[mnp_cnt].default_codabar_barcode = mnp.codabar_barcode,
   mst_cnt = 0,
   isbt_cnt = 0
  HEAD mst.special_testing_cd
   IF (mst.mod_new_prod_id > 0.0)
    mst_cnt += 1
    IF (mod(mst_cnt,10)=1)
     stat = alterlist(modification->options[cnt].new_prods[mnp_cnt].spec_testings,(mst_cnt+ 9))
    ENDIF
    modification->options[cnt].new_prods[mnp_cnt].spec_testings[mst_cnt].special_testing_cd = mst
    .special_testing_cd, modification->options[cnt].new_prods[mnp_cnt].spec_testings[mst_cnt].
    special_isbt = bia.standard_display
   ENDIF
  HEAD isbt.isbt_barcode
   IF (size(trim(isbt.isbt_barcode),1) > 0)
    IF ((modification->options[cnt].new_product_ind=1)
     AND (modification->options[cnt].split_ind=1)
     AND (request->option_id > 0.0))
     isbt_cnt += 1
     IF (mod(isbt_cnt,10)=1)
      stat = alterlist(modification->options[cnt].new_prods[mnp_cnt].e_numbers,(isbt_cnt+ 9))
     ENDIF
     modification->options[cnt].new_prods[mnp_cnt].e_numbers[isbt_cnt].e_number = isbt.isbt_barcode
    ENDIF
   ENDIF
  DETAIL
   row + 0
  FOOT  isbt.isbt_barcode
   row + 0
  FOOT  mst.special_testing_cd
   row + 0
  FOOT  mnp.mod_new_prod_id
   stat = alterlist(modification->options[cnt].new_prods[mnp_cnt].spec_testings,mst_cnt), stat =
   alterlist(modification->options[cnt].new_prods[mnp_cnt].e_numbers,isbt_cnt)
  FOOT  d.seq
   IF (inactive_cnt=mnp_cnt)
    modification->options[cnt].active_ind = 0
   ENDIF
   stat = alterlist(modification->options[cnt].new_prods,mnp_cnt)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","F","BB_MOD_NEW_PRODUCT",errmsg)
  GO TO build_reply
 ENDIF
 SELECT INTO "nl:"
  d.seq, md.device_type_cd
  FROM (dummyt d  WITH seq = value(mo_cnt)),
   bb_mod_device md
  PLAN (d
   WHERE d.seq <= mo_cnt)
   JOIN (md
   WHERE (md.option_id=modification->options[d.seq].option_id))
  ORDER BY d.seq
  HEAD REPORT
   md_cnt = 0, cnt = 0
  HEAD d.seq
   cnt = d.seq, md_cnt = 0
  DETAIL
   md_cnt += 1
   IF (mod(md_cnt,10)=1)
    stat = alterlist(modification->options[cnt].devices,(md_cnt+ 9))
   ENDIF
   modification->options[cnt].devices[md_cnt].device_type_cd = md.device_type_cd, modification->
   options[cnt].devices[md_cnt].default_ind = md.default_ind, modification->options[cnt].devices[
   md_cnt].max_capacity = md.max_capacity,
   modification->options[cnt].devices[md_cnt].start_stop_time_ind = md.start_stop_time_ind,
   modification->options[cnt].devices[md_cnt].modification_duration = md.modification_duration
  FOOT  d.seq
   stat = alterlist(modification->options[cnt].devices,md_cnt)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","F","BB_MOD_DEVICE",errmsg)
  GO TO build_reply
 ENDIF
 SUBROUTINE (errorhandler(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=
  vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = operationname
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
 END ;Subroutine
#build_reply
 SET stat = alterlist(reply->options,mo_cnt)
 SET mo_cnt = 0
 FOR (cnt = 1 TO size(modification->options,5))
   IF ((((request->load_inactive_ind=0)
    AND (modification->options[cnt].active_ind=1)) OR ((request->load_inactive_ind=1))) )
    SET mo_cnt += 1
    SET reply->options[mo_cnt].option_id = modification->options[cnt].option_id
    SET reply->options[mo_cnt].display = modification->options[cnt].display
    SET reply->options[mo_cnt].beg_effective_dt_tm = modification->options[cnt].beg_effective_dt_tm
    SET reply->options[mo_cnt].end_effective_dt_tm = modification->options[cnt].end_effective_dt_tm
    SET reply->options[mo_cnt].new_product_ind = modification->options[cnt].new_product_ind
    SET reply->options[mo_cnt].split_ind = modification->options[cnt].split_ind
    SET reply->options[mo_cnt].ad_hoc_ind = modification->options[cnt].ad_hoc_ind
    SET reply->options[mo_cnt].change_attribute_ind = modification->options[cnt].change_attribute_ind
    SET reply->options[mo_cnt].crossover_ind = modification->options[cnt].crossover_ind
    SET reply->options[mo_cnt].pool_product_ind = modification->options[cnt].pool_product_ind
    SET reply->options[mo_cnt].generate_prod_nbr_ind = modification->options[cnt].
    generate_prod_nbr_ind
    SET reply->options[mo_cnt].prod_nbr_prefix = modification->options[cnt].prod_nbr_prefix
    SET reply->options[mo_cnt].prod_nbr_ccyy_ind = modification->options[cnt].prod_nbr_ccyy_ind
    SET reply->options[mo_cnt].prod_nbr_starting_nbr = modification->options[cnt].
    prod_nbr_starting_nbr
    SET reply->options[mo_cnt].dispose_orig_ind = modification->options[cnt].dispose_orig_ind
    SET reply->options[mo_cnt].chg_orig_exp_dt_ind = modification->options[cnt].chg_orig_exp_dt_ind
    SET reply->options[mo_cnt].orig_nbr_days_exp = modification->options[cnt].orig_nbr_days_exp
    SET reply->options[mo_cnt].orig_nbr_hrs_exp = modification->options[cnt].orig_nbr_hrs_exp
    SET reply->options[mo_cnt].active_ind = modification->options[cnt].active_ind
    SET reply->options[mo_cnt].updt_cnt = modification->options[cnt].updt_cnt
    SET reply->options[mo_cnt].label_info_prompt_ind = modification->options[cnt].
    label_info_prompt_ind
    SET reply->options[mo_cnt].generate_isbt_nbr_ind = modification->options[cnt].
    generate_isbt_nbr_ind
    SET reply->options[mo_cnt].recon_rbc_ind = modification->options[cnt].recon_rbc_ind
    IF ((request->load_option_list_ind=0))
     SET mop_cnt = size(modification->options[cnt].orig_prods,5)
     SET stat = alterlist(reply->options[mo_cnt].orig_prods,mop_cnt)
     FOR (mop_cnt = 1 TO size(modification->options[cnt].orig_prods,5))
       SET reply->options[mo_cnt].orig_prods[mop_cnt].orig_product_cd = modification->options[cnt].
       orig_prods[mop_cnt].orig_product_cd
       SET isbt_cnt = size(modification->options[cnt].orig_prods[mop_cnt].e_numbers,5)
       SET stat = alterlist(reply->options[mo_cnt].orig_prods[mop_cnt].e_numbers,isbt_cnt)
       FOR (isbt_cnt = 1 TO size(modification->options[cnt].orig_prods[mop_cnt].e_numbers,5))
         SET reply->options[cnt].orig_prods[mop_cnt].e_numbers[isbt_cnt].e_number = modification->
         options[cnt].orig_prods[mop_cnt].e_numbers[isbt_cnt].e_number
       ENDFOR
     ENDFOR
     SET mnp_cnt = size(modification->options[cnt].new_prods,5)
     SET stat = alterlist(reply->options[mo_cnt].new_prods,mnp_cnt)
     FOR (mnp_cnt = 1 TO size(modification->options[cnt].new_prods,5))
       SET reply->options[mo_cnt].new_prods[mnp_cnt].mod_new_prod_id = modification->options[cnt].
       new_prods[mnp_cnt].mod_new_prod_id
       SET reply->options[mo_cnt].new_prods[mnp_cnt].orig_product_cd = modification->options[cnt].
       new_prods[mnp_cnt].orig_product_cd
       SET reply->options[mo_cnt].new_prods[mnp_cnt].new_product_cd = modification->options[cnt].
       new_prods[mnp_cnt].new_product_cd
       SET reply->options[mo_cnt].new_prods[mnp_cnt].orig_plasma_prod_cd = modification->options[cnt]
       .new_prods[mnp_cnt].orig_plasma_prod_cd
       SET reply->options[mo_cnt].new_prods[mnp_cnt].quantity = modification->options[cnt].new_prods[
       mnp_cnt].quantity
       SET reply->options[mo_cnt].new_prods[mnp_cnt].default_sub_id_flag = modification->options[cnt]
       .new_prods[mnp_cnt].default_sub_id_flag
       SET reply->options[mo_cnt].new_prods[mnp_cnt].max_prep_hrs = modification->options[cnt].
       new_prods[mnp_cnt].max_prep_hrs
       SET reply->options[mo_cnt].new_prods[mnp_cnt].default_orig_exp_ind = modification->options[cnt
       ].new_prods[mnp_cnt].default_orig_exp_ind
       SET reply->options[mo_cnt].new_prods[mnp_cnt].calc_exp_drawn_ind = modification->options[cnt].
       new_prods[mnp_cnt].calc_exp_drawn_ind
       SET reply->options[mo_cnt].new_prods[mnp_cnt].default_exp_days = modification->options[cnt].
       new_prods[mnp_cnt].default_exp_days
       SET reply->options[mo_cnt].new_prods[mnp_cnt].default_exp_hrs = modification->options[cnt].
       new_prods[mnp_cnt].default_exp_hrs
       SET reply->options[mo_cnt].new_prods[mnp_cnt].allow_extend_exp_ind = modification->options[cnt
       ].new_prods[mnp_cnt].allow_extend_exp_ind
       SET reply->options[mo_cnt].new_prods[mnp_cnt].default_orig_vol_ind = modification->options[cnt
       ].new_prods[mnp_cnt].default_orig_vol_ind
       SET reply->options[mo_cnt].new_prods[mnp_cnt].default_volume = modification->options[cnt].
       new_prods[mnp_cnt].default_volume
       SET reply->options[mo_cnt].new_prods[mnp_cnt].calc_vol_ind = modification->options[cnt].
       new_prods[mnp_cnt].calc_vol_ind
       SET reply->options[mo_cnt].new_prods[mnp_cnt].prompt_vol_ind = modification->options[cnt].
       new_prods[mnp_cnt].prompt_vol_ind
       SET reply->options[mo_cnt].new_prods[mnp_cnt].validate_vol_ind = modification->options[cnt].
       new_prods[mnp_cnt].validate_vol_ind
       SET reply->options[mo_cnt].new_prods[mnp_cnt].default_unit_of_meas_cd = modification->options[
       cnt].new_prods[mnp_cnt].default_unit_of_meas_cd
       SET reply->options[mo_cnt].new_prods[mnp_cnt].synonym_id = modification->options[cnt].
       new_prods[mnp_cnt].synonym_id
       SET reply->options[mo_cnt].new_prods[mnp_cnt].require_assign_ind = modification->options[cnt].
       new_prods[mnp_cnt].require_assign_ind
       SET reply->options[mo_cnt].new_prods[mnp_cnt].bag_type_cd = modification->options[cnt].
       new_prods[mnp_cnt].bag_type_cd
       SET reply->options[mo_cnt].new_prods[mnp_cnt].crossover_reason_cd = modification->options[cnt]
       .new_prods[mnp_cnt].crossover_reason_cd
       SET reply->options[mo_cnt].new_prods[mnp_cnt].allow_no_aborh_ind = modification->options[cnt].
       new_prods[mnp_cnt].allow_no_aborh_ind
       SET reply->options[mo_cnt].new_prods[mnp_cnt].default_supplier_id = modification->options[cnt]
       .new_prods[mnp_cnt].default_supplier_id
       SET reply->options[mo_cnt].new_prods[mnp_cnt].default_isbt_barcode = modification->options[cnt
       ].new_prods[mnp_cnt].default_isbt_barcode
       SET reply->options[mo_cnt].new_prods[mnp_cnt].default_codabar_barcode = modification->options[
       cnt].new_prods[mnp_cnt].default_codabar_barcode
       SET mst_cnt = size(modification->options[cnt].new_prods[mnp_cnt].spec_testings,5)
       SET stat = alterlist(reply->options[mo_cnt].new_prods[mnp_cnt].spec_testings,mst_cnt)
       FOR (mst_cnt = 1 TO size(modification->options[cnt].new_prods[mnp_cnt].spec_testings,5))
        SET reply->options[mo_cnt].new_prods[mnp_cnt].spec_testings[mst_cnt].special_testing_cd =
        modification->options[cnt].new_prods[mnp_cnt].spec_testings[mst_cnt].special_testing_cd
        SET reply->options[mo_cnt].new_prods[mnp_cnt].spec_testings[mst_cnt].special_isbt =
        modification->options[cnt].new_prods[mnp_cnt].spec_testings[mst_cnt].special_isbt
       ENDFOR
       SET isbt_cnt = size(modification->options[cnt].new_prods[mnp_cnt].e_numbers,5)
       SET stat = alterlist(reply->options[mo_cnt].new_prods[mnp_cnt].e_numbers,isbt_cnt)
       FOR (isbt_cnt = 1 TO size(modification->options[cnt].new_prods[mnp_cnt].e_numbers,5))
         SET reply->options[cnt].new_prods[mnp_cnt].e_numbers[isbt_cnt].e_number = modification->
         options[cnt].new_prods[mnp_cnt].e_numbers[isbt_cnt].e_number
       ENDFOR
     ENDFOR
     SET md_cnt = size(modification->options[cnt].devices,5)
     SET stat = alterlist(reply->options[mo_cnt].devices,md_cnt)
     FOR (md_cnt = 1 TO size(modification->options[cnt].devices,5))
       SET reply->options[mo_cnt].devices[md_cnt].device_type_cd = modification->options[cnt].
       devices[md_cnt].device_type_cd
       SET reply->options[mo_cnt].devices[md_cnt].default_ind = modification->options[cnt].devices[
       md_cnt].default_ind
       SET reply->options[mo_cnt].devices[md_cnt].max_capacity = modification->options[cnt].devices[
       md_cnt].max_capacity
       SET reply->options[mo_cnt].devices[md_cnt].start_stop_time_ind = modification->options[cnt].
       devices[md_cnt].start_stop_time_ind
       SET reply->options[mo_cnt].devices[md_cnt].modification_duration = modification->options[cnt].
       devices[md_cnt].modification_duration
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->options,mo_cnt)
#set_status
 IF (error_check != 0)
  SET reply->status_data.status = "F"
 ELSEIF (mo_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 FREE RECORD modification
END GO
