CREATE PROGRAM bb_ref_get_product_types:dba
 RECORD reply(
   1 product[*]
     2 product_cd = f8
     2 product_disp = vc
     2 product_desc = vc
     2 product_cat_cd = f8
     2 product_class_cd = f8
     2 autologous_ind = i2
     2 directed_ind = i2
     2 allow_dispense_ind = i2
     2 default_volume = i4
     2 max_days_expire = i4
     2 max_hrs_expire = i4
     2 default_supplier_id = f8
     2 synonym_id = f8
     2 auto_quarantine_min = i4
     2 active_ind = i2
     2 updt_cnt = i4
     2 intl_units_ind = i2
     2 validate_ag_ab_ind = i2
     2 validate_trans_req_ind = i2
     2 storage_temp_cd = f8
     2 drawn_dt_tm_ind = i2
     2 aliquot_ind = i2
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
 SET stat = alterlist(reply->product,10)
 SELECT
  IF ((request->active_flag=2))
   WHERE 1=1
  ELSE
   WHERE (pi.active_ind=request->active_flag)
  ENDIF
  INTO "nl:"
  FROM product_index pi
  DETAIL
   ncnt = (ncnt+ 1)
   IF (mod(ncnt,10)=1
    AND ncnt != 1)
    stat = alterlist(reply->product,(ncnt+ 10))
   ENDIF
   reply->product[ncnt].product_cd = pi.product_cd, reply->product[ncnt].product_cat_cd = pi
   .product_cat_cd, reply->product[ncnt].product_class_cd = pi.product_class_cd,
   reply->product[ncnt].autologous_ind = pi.autologous_ind, reply->product[ncnt].directed_ind = pi
   .directed_ind, reply->product[ncnt].allow_dispense_ind = pi.allow_dispense_ind,
   reply->product[ncnt].default_volume = pi.default_volume, reply->product[ncnt].max_days_expire = pi
   .max_days_expire, reply->product[ncnt].max_hrs_expire = pi.max_hrs_expire,
   reply->product[ncnt].default_supplier_id = pi.default_supplier_id, reply->product[ncnt].synonym_id
    = pi.synonym_id, reply->product[ncnt].auto_quarantine_min = pi.auto_quarantine_min,
   reply->product[ncnt].active_ind = pi.active_ind, reply->product[ncnt].updt_cnt = pi.updt_cnt,
   reply->product[ncnt].intl_units_ind = pi.intl_units_ind,
   reply->product[ncnt].validate_ag_ab_ind = pi.validate_ag_ab_ind, reply->product[ncnt].
   validate_trans_req_ind = pi.validate_trans_req_ind, reply->product[ncnt].storage_temp_cd = pi
   .storage_temp_cd,
   reply->product[ncnt].drawn_dt_tm_ind = pi.drawn_dt_tm_ind, reply->product[ncnt].aliquot_ind = pi
   .aliquot_ind
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->product,ncnt)
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
