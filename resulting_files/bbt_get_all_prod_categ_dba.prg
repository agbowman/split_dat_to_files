CREATE PROGRAM bbt_get_all_prod_categ:dba
 RECORD reply(
   1 qual[10]
     2 product_cat_cd = f8
     2 product_cat_disp = c40
     2 product_cat_desc = vc
     2 product_cat_updt_cnt = i4
     2 red_cell_product_ind = i2
     2 rh_required_ind = i2
     2 confirm_required_ind = i2
     2 xmatch_required_ind = i2
     2 default_unit_measure_cd = f8
     2 default_unit_measure_disp = c40
     2 default_vis_insp_cd = f8
     2 default_vis_insp_disp = c40
     2 default_ship_cond_cd = f8
     2 default_ship_cond_disp = c40
     2 prompt_vol_ind = i2
     2 prompt_segment_ind = i2
     2 prompt_alternate_ind = i2
     2 special_testing_ind = i2
     2 crossmatch_tag_ind = i2
     2 component_tag_ind = i2
     2 valid_aborh_compat_ind = i2
     2 pilot_label_ind = i2
     2 donor_label_aborh_cnt = i2
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
 SELECT INTO "nl:"
  FROM product_category p
  WHERE (p.product_class_cd=request->product_class_cd)
   AND p.active_ind=1
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].product_cat_cd = p.product_cat_cd, reply->qual[count1].product_cat_updt_cnt =
   p.updt_cnt, reply->qual[count1].red_cell_product_ind = p.red_cell_product_ind,
   reply->qual[count1].rh_required_ind = p.rh_required_ind, reply->qual[count1].confirm_required_ind
    = p.confirm_required_ind, reply->qual[count1].xmatch_required_ind = p.xmatch_required_ind,
   reply->qual[count1].default_unit_measure_cd = p.default_unit_measure_cd, reply->qual[count1].
   default_vis_insp_cd = p.default_vis_insp_cd, reply->qual[count1].default_ship_cond_cd = p
   .default_ship_cond_cd,
   reply->qual[count1].prompt_vol_ind = p.prompt_vol_ind, reply->qual[count1].prompt_segment_ind = p
   .prompt_segment_ind, reply->qual[count1].prompt_alternate_ind = p.prompt_alternate_ind,
   reply->qual[count1].special_testing_ind = p.special_testing_ind, reply->qual[count1].
   crossmatch_tag_ind = p.crossmatch_tag_ind, reply->qual[count1].component_tag_ind = p
   .component_tag_ind,
   reply->qual[count1].valid_aborh_compat_ind = p.valid_aborh_compat_ind, reply->qual[count1].
   pilot_label_ind = p.pilot_label_ind, reply->qual[count1].donor_label_aborh_cnt = p
   .donor_label_aborh_cnt
  WITH counter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "read"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "table"
  SET reply->status_data.targetobjectvalue = "product_category"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,count1)
END GO
