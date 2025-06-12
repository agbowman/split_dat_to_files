CREATE PROGRAM bbt_get_product_categories:dba
 RECORD reply(
   1 qual[*]
     2 product_cat_cd = f8
     2 product_class_cd = f8
     2 rh_required_ind = i2
     2 confirm_required_ind = i2
     2 red_cell_product_ind = i2
     2 xmatch_required_ind = i2
     2 storage_temp_cd = f8
     2 default_ship_cond_cd = f8
     2 default_unit_measure_cd = f8
     2 default_vis_insp_cd = f8
     2 prompt_vol_ind = i2
     2 prompt_alternate_ind = i2
     2 prompt_segment_ind = i2
     2 special_testing_ind = i2
     2 crossmatch_tag_ind = i2
     2 component_tag_ind = i2
     2 valid_aborh_compat_ind = i2
     2 product_cat_disp = vc
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
 SET cat_cnt = 0
 SET cmpnt_cnt = 0
 SELECT INTO "nl:"
  pc.product_cat_cd, pc.product_class_cd, pc.rh_required_ind,
  pc.confirm_required_ind, pc.red_cell_product_ind, pc.xmatch_required_ind,
  pc.storage_temp_cd, pc.default_ship_cond_cd, pc.default_unit_measure_cd,
  pc.default_vis_insp_cd, pc.prompt_vol_ind, pc.prompt_alternate_ind,
  pc.prompt_segment_ind, pc.special_testing_ind, pc.crossmatch_tag_ind,
  pc.component_tag_ind, pc.valid_aborh_compat_ind
  FROM product_category pc
  WHERE pc.active_ind=1
   AND (((request->product_class_cd <= 0)) OR ((request->product_class_cd=pc.product_class_cd)))
  HEAD REPORT
   stat = alterlist(reply->qual,10), cat_cnt = 0
  DETAIL
   cat_cnt = (cat_cnt+ 1)
   IF (mod(cat_cnt,10)=1
    AND cat_cnt != 1)
    stat = alterlist(reply->qual,(cat_cnt+ 9))
   ENDIF
   reply->qual[cat_cnt].product_cat_cd = pc.product_cat_cd, reply->qual[cat_cnt].product_class_cd =
   pc.product_class_cd, reply->qual[cat_cnt].rh_required_ind = pc.rh_required_ind,
   reply->qual[cat_cnt].confirm_required_ind = pc.confirm_required_ind, reply->qual[cat_cnt].
   red_cell_product_ind = pc.red_cell_product_ind, reply->qual[cat_cnt].xmatch_required_ind = pc
   .xmatch_required_ind,
   reply->qual[cat_cnt].storage_temp_cd = pc.storage_temp_cd, reply->qual[cat_cnt].
   default_ship_cond_cd = pc.default_ship_cond_cd, reply->qual[cat_cnt].default_unit_measure_cd = pc
   .default_unit_measure_cd,
   reply->qual[cat_cnt].default_vis_insp_cd = pc.default_vis_insp_cd, reply->qual[cat_cnt].
   prompt_vol_ind = pc.prompt_vol_ind, reply->qual[cat_cnt].prompt_alternate_ind = pc
   .prompt_alternate_ind,
   reply->qual[cat_cnt].prompt_segment_ind = pc.prompt_segment_ind, reply->qual[cat_cnt].
   special_testing_ind = pc.special_testing_ind, reply->qual[cat_cnt].crossmatch_tag_ind = pc
   .crossmatch_tag_ind,
   reply->qual[cat_cnt].component_tag_ind = pc.component_tag_ind, reply->qual[cat_cnt].
   valid_aborh_compat_ind = pc.valid_aborh_compat_ind, reply->qual[cat_cnt].product_cat_disp =
   uar_get_code_display(pc.product_cat_cd)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,cat_cnt)
 GO TO exit_script
#exit_script
 SET count1 = (count1+ 1)
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,count1)
 ENDIF
 SET reply->status_data.subeventstatus[count1].operationname = "get product_categories rows"
 SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_product_categories"
 IF (cat_cnt > 0)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "No active product_category rows found"
 ENDIF
END GO
