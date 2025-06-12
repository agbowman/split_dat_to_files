CREATE PROGRAM bbt_get_prod_index_only:dba
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
     2 product_cd = f8
     2 product_cat_cd = f8
     2 product_class_cd = f8
     2 autologous_ind = i2
     2 directed_ind = i2
     2 allow_dispense_ind = i2
     2 default_volume = i4
     2 max_days_expire = i4
     2 max_hrs_expire = i4
     2 default_supplier_id = f8
     2 auto_quarantine_min = i4
     2 validate_ag_ab_ind = i2
     2 validate_trans_req_ind = i2
     2 updt_cnt = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 drawn_dt_tm_ind = i2
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SELECT INTO "nl:"
  p.seq
  FROM product_index p
  WHERE (request->product_cd=p.product_cd)
  DETAIL
   reply->cat_list.product_cd = p.product_cd, reply->cat_list.product_cat_cd = p.product_cat_cd,
   reply->cat_list.product_class_cd = p.product_class_cd,
   reply->cat_list.autologous_ind = p.autologous_ind, reply->cat_list.directed_ind = p.directed_ind,
   reply->cat_list.allow_dispense_ind = p.allow_dispense_ind,
   reply->cat_list.default_volume = p.default_volume, reply->cat_list.max_days_expire = p
   .max_days_expire, reply->cat_list.max_hrs_expire = p.max_hrs_expire,
   reply->cat_list.default_supplier_id = p.default_supplier_id, reply->cat_list.auto_quarantine_min
    = p.auto_quarantine_min, reply->cat_list.validate_ag_ab_ind = p.validate_ag_ab_ind,
   reply->cat_list.validate_trans_req_ind = p.validate_trans_req_ind, reply->cat_list.drawn_dt_tm_ind
    = p.drawn_dt_tm_ind
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_get_prod_index_only"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
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
