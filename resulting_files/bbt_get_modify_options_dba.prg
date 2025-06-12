CREATE PROGRAM bbt_get_modify_options:dba
 RECORD reply(
   1 qual[*]
     2 option_id = f8
     2 orig_product_cd = f8
     2 orig_product_disp = c40
     2 orig_product_desc = vc
     2 description = c40
     2 bag_type_cd = f8
     2 dispose_orig_ind = i2
     2 orig_nbr_days_exp = i4
     2 orig_nbr_hrs_exp = i4
     2 validate_vol_ind = i2
     2 calc_exp_drawn_ind = i2
     2 chg_orig_exp_dt_ind = i2
     2 bag_type_valid_ind = i2
     2 division_type_flag = i2
     2 crossover_reason_cd = f8
     2 calc_orig_exp_drawn_ind = i2
     2 allow_extend_exp_ind = i2
     2 new_product_list[*]
       3 new_product_cd = f8
       3 new_product_disp = c40
       3 default_exp_days = i4
       3 default_exp_hrs = i4
       3 max_prep_hrs = i4
       3 synonym_id = f8
       3 quantity = i4
       3 sub_prod_id_flag = i2
       3 default_volume = i4
       3 default_unit_measure_cd = f8
       3 default_unit_measure_disp = vc
       3 default_volume_ind = i2
       3 default_unit_measure_ind = i2
       3 dflt_orig_volume_ind = i2
     2 special_testing_list[*]
       3 new_product_cd = f8
       3 new_product_disp = c40
       3 special_testing_cd = f8
       3 special_testing_disp = c40
       3 default_exp_days = i4
       3 default_exp_hrs = i4
       3 max_prep_hrs = i4
       3 calc_exp_drawn_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET x = 0
 SET z = 0
 SET err_cnt = 0
 SET failed = "F"
 SELECT INTO "nl:"
  FROM modify_option m
  WHERE m.active_ind=1
  DETAIL
   x = (x+ 1), stat = alterlist(reply->qual,x), reply->qual[x].option_id = m.option_id,
   reply->qual[x].orig_product_cd = m.orig_product_cd, reply->qual[x].description = m.description,
   reply->qual[x].bag_type_cd = m.bag_type_cd,
   reply->qual[x].dispose_orig_ind = m.dispose_orig_ind, reply->qual[x].orig_nbr_days_exp = m
   .orig_nbr_days_exp, reply->qual[x].orig_nbr_hrs_exp = m.orig_nbr_hrs_exp,
   reply->qual[x].validate_vol_ind = m.validate_vol_ind, reply->qual[x].calc_exp_drawn_ind = m
   .calc_exp_drawn_ind, reply->qual[x].chg_orig_exp_dt_ind = m.chg_orig_exp_dt_ind,
   reply->qual[x].bag_type_valid_ind = m.bag_type_valid_ind, reply->qual[x].division_type_flag = m
   .division_type_flag, reply->qual[x].crossover_reason_cd = m.crossover_reason_cd,
   reply->qual[x].calc_orig_exp_drawn_ind = m.calc_orig_exp_drawn_ind, reply->qual[x].
   allow_extend_exp_ind = m.allow_extend_exp_ind
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET stat = alter(reply->status_data.subeventstatus,err_cnt)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "modify_option"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "unable to return data"
  SET failed = "T"
 ELSE
  FOR (y = 1 TO x)
    IF ((((reply->qual[y].division_type_flag=1)) OR ((((reply->qual[y].division_type_flag=2)) OR ((
    reply->qual[y].division_type_flag=4))) )) )
     SET z = 0
     SELECT INTO "nl:"
      FROM new_product np
      WHERE (np.option_id=reply->qual[y].option_id)
       AND np.active_ind=1
      DETAIL
       z = (z+ 1), stat = alterlist(reply->qual[y].new_product_list,z), reply->qual[y].
       new_product_list[z].new_product_cd = np.new_product_cd,
       reply->qual[y].new_product_list[z].default_exp_days = np.default_exp_days, reply->qual[y].
       new_product_list[z].default_exp_hrs = np.default_exp_hrs, reply->qual[y].new_product_list[z].
       max_prep_hrs = np.max_prep_hrs,
       reply->qual[y].new_product_list[z].synonym_id = np.synonym_id, reply->qual[y].
       new_product_list[z].quantity = np.quantity, reply->qual[y].new_product_list[z].
       sub_prod_id_flag = np.sub_prod_id_flag,
       reply->qual[y].new_product_list[z].default_volume = np.default_volume, reply->qual[y].
       new_product_list[z].default_unit_measure_cd = np.default_unit_measure_cd, reply->qual[y].
       new_product_list[z].default_volume_ind = np.default_volume_ind,
       reply->qual[y].new_product_list[z].default_unit_measure_ind = np.default_measure_ind, reply->
       qual[y].new_product_list[z].dflt_orig_volume_ind = np.dflt_orig_volume_ind
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      SET err_cnt = (err_cnt+ 1)
      SET stat = alter(reply->status_data.subeventstatus,err_cnt)
      SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
      SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
      SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "modify_option & new_product"
      SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "unable to return data"
      SET failed = "T"
     ENDIF
    ELSE
     SET z = 0
     SELECT INTO "nl:"
      FROM modify_option_testing mot
      WHERE (mot.option_id=reply->qual[y].option_id)
       AND mot.active_ind=1
      DETAIL
       z = (z+ 1), stat = alterlist(reply->qual[y].special_testing_list,z), reply->qual[y].
       special_testing_list[z].special_testing_cd = mot.special_testing_cd,
       reply->qual[y].special_testing_list[z].new_product_cd = mot.new_product_cd, reply->qual[y].
       special_testing_list[z].default_exp_days = mot.default_exp_days, reply->qual[y].
       special_testing_list[z].default_exp_hrs = mot.default_exp_hrs,
       reply->qual[y].special_testing_list[z].max_prep_hrs = mot.max_prep_hrs, reply->qual[y].
       special_testing_list[z].calc_exp_drawn_ind = mot.calc_exp_drawn_ind
      WITH format, nocounter
     ;end select
     IF (curqual=0)
      SET err_cnt = (err_cnt+ 1)
      SET stat = alter(reply->status_data.subeventstatus,err_cnt)
      SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
      SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
      SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "modify_option_testing"
      SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "unable to return data"
      SET failed = "T"
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF (failed="F")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
