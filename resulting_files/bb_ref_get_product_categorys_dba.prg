CREATE PROGRAM bb_ref_get_product_categorys:dba
 RECORD reply(
   1 categorys[*]
     2 category_cd = f8
     2 category_disp = vc
     2 category_desc = vc
     2 class_cd = f8
     2 rh_required_ind = i2
     2 confirm_required_ind = i2
     2 crossmatch_required_ind = i2
     2 default_storage_temp_cd = f8
     2 default_ship_cond_cd = f8
     2 default_unit_measure_cd = f8
     2 default_vis_insp_cd = f8
     2 prompt_vol_ind = i2
     2 prompt_alternate_ind = i2
     2 prompt_segment_ind = i2
     2 special_testing_ind = i2
     2 crossmatch_tag_ind = i2
     2 component_tag_ind = i2
     2 pilot_label_ind = i2
     2 valid_aborh_compat_ind = i2
     2 active_ind = i2
     2 updt_cnt = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncnt = i2
 SET ncnt = 0
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 SET stat = alterlist(reply->categorys,10)
 SELECT
  IF ((request->active_flag=2))
   WHERE 1=1
  ELSE
   WHERE (pc.active_ind=request->active_flag)
  ENDIF
  INTO "nl:"
  FROM product_category pc
  DETAIL
   ncnt = (ncnt+ 1)
   IF (mod(ncnt,10)=1
    AND ncnt != 1)
    stat = alterlist(reply->categorys,(ncnt+ 10))
   ENDIF
   reply->categorys[ncnt].category_cd = pc.product_cat_cd, reply->categorys[ncnt].class_cd = pc
   .product_class_cd, reply->categorys[ncnt].rh_required_ind = pc.rh_required_ind,
   reply->categorys[ncnt].confirm_required_ind = pc.confirm_required_ind, reply->categorys[ncnt].
   crossmatch_required_ind = pc.xmatch_required_ind, reply->categorys[ncnt].default_storage_temp_cd
    = pc.storage_temp_cd,
   reply->categorys[ncnt].default_ship_cond_cd = pc.default_ship_cond_cd, reply->categorys[ncnt].
   default_unit_measure_cd = pc.default_unit_measure_cd, reply->categorys[ncnt].default_vis_insp_cd
    = pc.default_vis_insp_cd,
   reply->categorys[ncnt].prompt_vol_ind = pc.prompt_vol_ind, reply->categorys[ncnt].
   prompt_alternate_ind = pc.prompt_alternate_ind, reply->categorys[ncnt].prompt_segment_ind = pc
   .prompt_segment_ind,
   reply->categorys[ncnt].crossmatch_tag_ind = pc.crossmatch_tag_ind, reply->categorys[ncnt].
   special_testing_ind = pc.special_testing_ind, reply->categorys[ncnt].component_tag_ind = pc
   .component_tag_ind,
   reply->categorys[ncnt].pilot_label_ind = pc.pilot_label_ind, reply->categorys[ncnt].
   valid_aborh_compat_ind = pc.valid_aborh_compat_ind, reply->categorys[ncnt].active_ind = pc
   .active_ind,
   reply->categorys[ncnt].updt_cnt = pc.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->categorys,ncnt)
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (ncnt > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
#exit_script
END GO
