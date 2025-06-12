CREATE PROGRAM bbt_get_pool_option:dba
 RECORD reply(
   1 optionlist[*]
     2 option_id = f8
     2 new_product_cd = f8
     2 new_product_disp = c40
     2 description = c40
     2 prompt_vol_ind = i2
     2 calculate_vol_ind = i2
     2 default_exp_hrs = i4
     2 product_nbr_prefix = c10
     2 generate_prod_nbr_ind = i2
     2 default_supplier_id = f8
     2 require_assign_ind = i2
     2 allow_no_aborh_ind = i2
     2 max_days_expire = i4
     2 max_hrs_expire = i4
     2 product_cat_cd = f8
     2 cmpntlist[*]
       3 product_cd = f8
       3 product_disp = c20
     2 default_exp_days = i4
     2 validate_vol_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET option_cnt = 0
 SET cmpnt_cnt = 0
 SELECT INTO "nl:"
  po.option_id, po.new_product_cd, po.description,
  po.prompt_vol_ind, po.calculate_vol_ind, po.default_exp_hrs,
  po.product_nbr_prefix, po.generate_prod_nbr_ind, po.default_supplier_id,
  po.require_assign_ind, po.allow_no_aborh_ind, c.product_cd,
  pi.max_days_expire, pi.max_hrs_expire, pi.product_cat_cd
  FROM pool_option po,
   product_index pi,
   component c
  PLAN (po
   WHERE po.active_ind=1)
   JOIN (pi
   WHERE pi.product_cd=po.new_product_cd
    AND pi.active_ind=1)
   JOIN (c
   WHERE c.option_id=po.option_id
    AND c.active_ind=1)
  ORDER BY po.option_id
  HEAD REPORT
   stat = alterlist(reply->optionlist,10), option_cnt = 0
  HEAD po.option_id
   option_cnt = (option_cnt+ 1)
   IF (option_cnt > size(reply->optionlist,5))
    stat = alterlist(reply->optionlist,(option_cnt+ 9))
   ENDIF
   reply->optionlist[option_cnt].option_id = po.option_id, reply->optionlist[option_cnt].
   new_product_cd = po.new_product_cd, reply->optionlist[option_cnt].description = po.description,
   reply->optionlist[option_cnt].prompt_vol_ind = po.prompt_vol_ind, reply->optionlist[option_cnt].
   calculate_vol_ind = po.calculate_vol_ind, reply->optionlist[option_cnt].default_exp_hrs = po
   .default_exp_hrs,
   reply->optionlist[option_cnt].product_nbr_prefix = po.product_nbr_prefix, reply->optionlist[
   option_cnt].generate_prod_nbr_ind = po.generate_prod_nbr_ind, reply->optionlist[option_cnt].
   default_supplier_id = po.default_supplier_id,
   reply->optionlist[option_cnt].require_assign_ind = po.require_assign_ind, reply->optionlist[
   option_cnt].allow_no_aborh_ind = po.allow_no_aborh_ind, reply->optionlist[option_cnt].
   max_days_expire = pi.max_days_expire,
   reply->optionlist[option_cnt].max_hrs_expire = pi.max_hrs_expire, reply->optionlist[option_cnt].
   product_cat_cd = pi.product_cat_cd, stat = alterlist(reply->optionlist[option_cnt].cmpntlist,10),
   cmpnt_cnt = 0
  DETAIL
   cmpnt_cnt = (cmpnt_cnt+ 1)
   IF (mod(cmpnt_cnt,10)=1
    AND cmpnt_cnt != 1)
    stat = alterlist(reply->optionlist[option_cnt].cmpntlist,(cmpnt_cnt+ 9))
   ENDIF
   reply->optionlist[option_cnt].cmpntlist[cmpnt_cnt].product_cd = c.product_cd
  FOOT  po.option_id
   stat = alterlist(reply->optionlist[option_cnt].cmpntlist,cmpnt_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  bbmo.option_id, bbmo.display, bbmo.prod_nbr_prefix,
  bbmo.generate_prod_nbr_ind, bbmnp.new_product_cd, bbmnp.prompt_vol_ind,
  bbmnp.calc_vol_ind, bbmnp.default_exp_hrs, bbmnp.default_exp_days,
  bbmnp.default_supplier_id, bbmnp.require_assign_ind, bbmnp.allow_no_aborh_ind,
  bbmop.orig_product_cd, pi.max_days_expire, pi.max_hrs_expire,
  pi.product_cat_cd
  FROM bb_mod_option bbmo,
   bb_mod_new_product bbmnp,
   product_index pi,
   bb_mod_orig_product bbmop
  PLAN (bbmo
   WHERE bbmo.pool_product_ind=1)
   JOIN (bbmnp
   WHERE bbmo.option_id=bbmnp.option_id)
   JOIN (pi
   WHERE pi.product_cd=bbmnp.new_product_cd
    AND pi.active_ind=1)
   JOIN (bbmop
   WHERE bbmop.option_id=bbmnp.option_id)
  ORDER BY bbmo.option_id
  HEAD REPORT
   IF (option_cnt=0)
    stat = alterlist(reply->optionlist,10)
   ENDIF
  HEAD bbmo.option_id
   option_cnt = (option_cnt+ 1)
   IF (option_cnt > size(reply->optionlist,5))
    stat = alterlist(reply->optionlist,(option_cnt+ 9))
   ENDIF
   reply->optionlist[option_cnt].option_id = bbmo.option_id, reply->optionlist[option_cnt].
   description = bbmo.display, reply->optionlist[option_cnt].new_product_cd = bbmnp.new_product_cd,
   reply->optionlist[option_cnt].prompt_vol_ind = bbmnp.prompt_vol_ind, reply->optionlist[option_cnt]
   .calculate_vol_ind = bbmnp.calc_vol_ind, reply->optionlist[option_cnt].default_exp_hrs = bbmnp
   .default_exp_hrs,
   reply->optionlist[option_cnt].default_exp_days = bbmnp.default_exp_days, reply->optionlist[
   option_cnt].product_nbr_prefix = bbmo.prod_nbr_prefix, reply->optionlist[option_cnt].
   generate_prod_nbr_ind = bbmo.generate_prod_nbr_ind,
   reply->optionlist[option_cnt].default_supplier_id = bbmnp.default_supplier_id, reply->optionlist[
   option_cnt].require_assign_ind = bbmnp.require_assign_ind, reply->optionlist[option_cnt].
   allow_no_aborh_ind = bbmnp.allow_no_aborh_ind,
   reply->optionlist[option_cnt].max_days_expire = pi.max_days_expire, reply->optionlist[option_cnt].
   max_hrs_expire = pi.max_hrs_expire, reply->optionlist[option_cnt].product_cat_cd = pi
   .product_cat_cd,
   reply->optionlist[option_cnt].validate_vol_ind = bbmnp.validate_vol_ind, stat = alterlist(reply->
    optionlist[option_cnt].cmpntlist,10), cmpnt_cnt = 0
  DETAIL
   cmpnt_cnt = (cmpnt_cnt+ 1)
   IF (mod(cmpnt_cnt,10)=1
    AND cmpnt_cnt != 1)
    stat = alterlist(reply->optionlist[option_cnt].cmpntlist,(cmpnt_cnt+ 9))
   ENDIF
   reply->optionlist[option_cnt].cmpntlist[cmpnt_cnt].product_cd = bbmop.orig_product_cd
  FOOT  bbmo.option_id
   stat = alterlist(reply->optionlist[option_cnt].cmpntlist,cmpnt_cnt)
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->optionlist,option_cnt)
 GO TO exit_script
#exit_script
 SET count1 = (count1+ 1)
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,count1)
 ENDIF
 SET reply->status_data.subeventstatus[count1].operationname = "get pool_option rows"
 SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_pool_option"
 IF (option_cnt > 0)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "No active pool_option rows found"
 ENDIF
END GO
