CREATE PROGRAM bbt_get_prod_categ_only:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 targetstatename = c15
   1 cat_list
     2 product_cat_cd = f8
     2 product_class_cd = f8
     2 crossmatch_tag_ind = i2
     2 storage_temp_cd = f8
     2 component_tag_ind = i2
     2 red_cell_product_ind = i2
     2 rh_required_ind = i2
     2 confirm_required_ind = i2
     2 xmatch_required_ind = i2
     2 default_unit_measure_cd = f8
     2 default_vis_insp_cd = f8
     2 default_ship_cond_cd = f8
     2 prompt_vol_ind = i2
     2 prompt_segment_ind = i2
     2 prompt_alternate_ind = i2
     2 prompt_iu_ind = i2
     2 prompt_protectant_ind = i2
     2 special_testing_ind = i2
     2 valid_aborh_compat_ind = i2
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SELECT INTO "nl:"
  p.*
  FROM product_category p
  WHERE (request->product_cat_cd=p.product_cat_cd)
  DETAIL
   reply->cat_list.product_cat_cd = p.product_cat_cd, reply->cat_list.product_class_cd = p
   .product_class_cd, reply->cat_list.crossmatch_tag_ind = p.crossmatch_tag_ind,
   reply->cat_list.storage_temp_cd = p.storage_temp_cd, reply->cat_list.component_tag_ind = p
   .component_tag_ind, reply->cat_list.red_cell_product_ind = p.red_cell_product_ind,
   reply->cat_list.rh_required_ind = p.rh_required_ind, reply->cat_list.confirm_required_ind = p
   .confirm_required_ind, reply->cat_list.xmatch_required_ind = p.xmatch_required_ind,
   reply->cat_list.default_unit_measure_cd = p.default_unit_measure_cd, reply->cat_list.
   default_vis_insp_cd = p.default_vis_insp_cd, reply->cat_list.default_ship_cond_cd = p
   .default_ship_cond_cd,
   reply->cat_list.prompt_vol_ind = p.prompt_vol_ind, reply->cat_list.prompt_segment_ind = p
   .prompt_segment_ind, reply->cat_list.prompt_alternate_ind = p.prompt_alternate_ind,
   reply->cat_list.special_testing_ind = p.special_testing_ind, reply->cat_list.
   valid_aborh_compat_ind = p.valid_aborh_compat_ind, reply->cat_list.updt_cnt = p.updt_cnt,
   reply->cat_list.updt_dt_tm = p.updt_dt_tm, reply->cat_list.updt_id = p.updt_id, reply->cat_list.
   updt_task = p.updt_task,
   reply->cat_list.updt_applctx = p.updt_applctx
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_get_prod_categ_only"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SEQUENCE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to find product categories for product class requested"
  SET failed = "T"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ENDIF
END GO
