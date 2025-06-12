CREATE PROGRAM bbt_get_modify:dba
 RECORD reply(
   1 orig_product_cd = f8
   1 orig_product_disp = c40
   1 bag_type_cd = f8
   1 bag_type_disp = c40
   1 bag_type_valid_ind = i2
   1 validate_vol_ind = i2
   1 allow_extend_exp_ind = i2
   1 dispose_orig_ind = i2
   1 active_ind = i2
   1 calc_exp_drawn_ind = i2
   1 chg_orig_exp_dt_ind = i2
   1 orig_nbr_days_exp = i4
   1 orig_nbr_hrs_exp = i4
   1 division_type_flag = i2
   1 crossover_reason_cd = f8
   1 updt_cnt = i4
   1 qual[*]
     2 active_ind = i2
     2 new_product_cd = f8
     2 new_product_disp = c40
     2 max_prep_hrs = i4
     2 default_exp_days = i4
     2 default_exp_hrs = i4
     2 synonym_id = f8
     2 sub_prod_id_flag = i2
     2 quantity = i4
     2 special_testing_cd = f8
     2 special_testing_disp = c40
     2 calc_exp_drawn_ind = i2
     2 default_volume_ind = i2
     2 default_volume = i4
     2 default_unit_measure_ind = i2
     2 default_unit_measure_cd = f8
     2 default_unit_measure_disp = vc
     2 default_orig_volume_ind = i2
     2 updt_cnt = i4
   1 device_qual[*]
     2 option_device_id = f8
     2 device_type_cd = f8
     2 device_type_disp = c40
     2 nbr_of_device = i4
     2 updt_cnt = i4
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET err_cnt = 0
 SET prod_cnt = 0
 SET reply->status_data.status = "F"
 SET stat2 = alterlist(reply->device_qual,10)
 SET device_cnt = 0
 SELECT INTO "nl:"
  m.orig_product_cd, m.bag_type_cd, m.dispose_orig_ind,
  m.orig_nbr_days_exp, m.orig_nbr_hrs_exp, m.validate_vol_ind,
  m.allow_extend_exp_ind, m.calc_exp_drawn_ind, m.chg_orig_exp_dt_ind,
  m.bag_type_valid_ind, m.division_type_flag, m.crossover_reason_cd,
  m.active_ind, m.updt_cnt, p.active_ind,
  p.new_product_cd, p.max_prep_hrs, p.default_exp_days,
  p.default_exp_hrs, p.synonym_id, p.sub_prod_id_flag,
  p.updt_cnt, p.special_testing_cd, p.quantity,
  p.default_volume, p.default_unit_measure_cd, o.active_ind,
  o.new_product_cd, o.max_prep_hrs, o.default_exp_days,
  o.default_exp_hrs, o.calc_exp_drawn_ind, o.updt_cnt,
  o.special_testing_cd
  FROM modify_option m,
   dummyt d1,
   new_product p,
   dummyt d2,
   modify_option_testing o,
   dummyt d3
  PLAN (m
   WHERE (request->option_id=m.option_id))
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (p
   WHERE ((m.division_type_flag=1) OR (((m.division_type_flag=2) OR (m.division_type_flag=4)) ))
    AND m.option_id=p.option_id)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (o
   WHERE m.division_type_flag=3
    AND m.option_id=o.option_id)
   JOIN (d3
   WHERE d3.seq=1)
  HEAD REPORT
   err_cnt = 0, prod_cnt = 0
  DETAIL
   reply->orig_product_cd = m.orig_product_cd, reply->bag_type_cd = m.bag_type_cd, reply->
   dispose_orig_ind = m.dispose_orig_ind,
   reply->orig_nbr_days_exp = m.orig_nbr_days_exp, reply->orig_nbr_hrs_exp = m.orig_nbr_hrs_exp,
   reply->validate_vol_ind = m.validate_vol_ind,
   reply->allow_extend_exp_ind = m.allow_extend_exp_ind, reply->calc_exp_drawn_ind = m
   .calc_exp_drawn_ind, reply->chg_orig_exp_dt_ind = m.chg_orig_exp_dt_ind,
   reply->bag_type_valid_ind = m.bag_type_valid_ind, reply->division_type_flag = m.division_type_flag,
   reply->crossover_reason_cd = m.crossover_reason_cd,
   reply->active_ind = m.active_ind, reply->updt_cnt = m.updt_cnt, prod_cnt = (prod_cnt+ 1),
   stat = alterlist(reply->qual,prod_cnt)
   IF (m.division_type_flag=3)
    reply->qual[prod_cnt].active_ind = o.active_ind, reply->qual[prod_cnt].new_product_cd = o
    .new_product_cd, reply->qual[prod_cnt].max_prep_hrs = o.max_prep_hrs,
    reply->qual[prod_cnt].default_exp_days = o.default_exp_days, reply->qual[prod_cnt].
    default_exp_hrs = o.default_exp_hrs, reply->qual[prod_cnt].updt_cnt = o.updt_cnt,
    reply->qual[prod_cnt].calc_exp_drawn_ind = o.calc_exp_drawn_ind, reply->qual[prod_cnt].
    special_testing_cd = o.special_testing_cd
   ELSE
    reply->qual[prod_cnt].active_ind = p.active_ind, reply->qual[prod_cnt].new_product_cd = p
    .new_product_cd, reply->qual[prod_cnt].max_prep_hrs = p.max_prep_hrs,
    reply->qual[prod_cnt].default_exp_days = p.default_exp_days, reply->qual[prod_cnt].
    default_exp_hrs = p.default_exp_hrs, reply->qual[prod_cnt].synonym_id = p.synonym_id,
    reply->qual[prod_cnt].sub_prod_id_flag = p.sub_prod_id_flag, reply->qual[prod_cnt].updt_cnt = p
    .updt_cnt, reply->qual[prod_cnt].quantity = p.quantity,
    reply->qual[prod_cnt].default_volume_ind = p.default_volume_ind, reply->qual[prod_cnt].
    default_volume = p.default_volume, reply->qual[prod_cnt].default_unit_measure_ind = p
    .default_measure_ind,
    reply->qual[prod_cnt].default_unit_measure_cd = p.default_unit_measure_cd
   ENDIF
   reply->qual[prod_cnt].default_orig_volume_ind = p.dflt_orig_volume_ind
  WITH format, nocounter, dontcare = p,
   dontcare = o
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname =
  "MODIFY_OPTION, NEW_PRODUCT, MODIFY_OPTION_TESTING"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to return modify option specified"
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  m.option_device_id, m.device_type_cd, m.updt_cnt,
  m.nbr_of_device
  FROM modify_option_device m
  WHERE (m.option_id=request->option_id)
   AND m.active_ind=1
  DETAIL
   device_cnt = (device_cnt+ 1)
   IF (mod(device_cnt,10)=1
    AND device_cnt != 1)
    stat2 = alterlist(reply->device_qual,(device_cnt+ 9))
   ENDIF
   reply->device_qual[device_cnt].option_device_id = m.option_device_id, reply->device_qual[
   device_cnt].device_type_cd = m.device_type_cd, reply->device_qual[device_cnt].updt_cnt = m
   .updt_cnt,
   reply->device_qual[device_cnt].nbr_of_device = m.nbr_of_device, reply->device_qual[device_cnt].
   active_ind = m.active_ind
  WITH nocounter
 ;end select
 SET stat2 = alterlist(reply->device_qual,device_cnt)
#exit_script
END GO
