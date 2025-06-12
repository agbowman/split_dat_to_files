CREATE PROGRAM bbt_get_index_and_categ:dba
 RECORD reply(
   1 product_class_cd = f8
   1 product_class_disp = c40
   1 product_class_desc = c60
   1 product_class_mean = c12
   1 product_cat_cd = f8
   1 autologous_ind = i2
   1 directed_ind = i2
   1 allow_dispense_ind = i2
   1 default_volume = i2
   1 max_days_expire = i2
   1 max_hrs_expire = i2
   1 default_supplier_id = f8
   1 default_supplier_name = vc
   1 confirm_synonym_id = f8
   1 confirm_catalog_cd = f8
   1 confirm_mnemonic = vc
   1 confirm_catalog_type_cd = f8
   1 confirm_oe_format_id = f8
   1 auto_quarantine_min = i4
   1 intl_units_ind = i2
   1 red_cell_product_ind = i2
   1 rh_required_ind = i2
   1 confirm_required_ind = i2
   1 xmatch_required_ind = i2
   1 default_unit_measure_cd = f8
   1 default_unit_measure_disp = c40
   1 default_vis_insp_cd = f8
   1 default_vis_insp_disp = c40
   1 default_ship_cond_cd = f8
   1 default_ship_cond_disp = c40
   1 prompt_vol_ind = i2
   1 prompt_segment_ind = i2
   1 prompt_alternate_ind = i2
   1 special_testing_ind = i2
   1 crossmatch_tag_ind = i2
   1 component_tag_ind = i2
   1 pilot_label_ind = i2
   1 storage_temp_cd = f8
   1 storage_temp_disp = c40
   1 valid_aborh_compat_ind = i2
   1 drawn_dt_tm_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET product_cat_cd = 0.0
 SELECT INTO "nl:"
  FROM product_index p,
   dummyt d,
   organization o,
   dummyt d1,
   order_catalog_synonym s
  PLAN (p
   WHERE (p.product_cd=request->product_cd))
   JOIN (d
   WHERE d.seq=1)
   JOIN (o
   WHERE o.organization_id=p.default_supplier_id
    AND p.default_supplier_id > 0)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (s
   WHERE s.synonym_id=p.synonym_id
    AND p.synonym_id > 0)
  DETAIL
   product_cat_cd = p.product_cat_cd, reply->product_cat_cd = p.product_cat_cd, reply->
   product_class_cd = p.product_class_cd,
   reply->autologous_ind = p.autologous_ind, reply->directed_ind = p.directed_ind, reply->
   allow_dispense_ind = p.allow_dispense_ind,
   reply->default_volume = p.default_volume, reply->max_days_expire = p.max_days_expire, reply->
   max_hrs_expire = p.max_hrs_expire,
   reply->default_supplier_id = p.default_supplier_id, reply->default_supplier_name = o.org_name,
   reply->confirm_synonym_id = p.synonym_id,
   reply->confirm_catalog_cd = s.catalog_cd, reply->confirm_mnemonic = s.mnemonic, reply->
   confirm_catalog_type_cd = s.catalog_type_cd,
   reply->confirm_oe_format_id = s.oe_format_id, reply->auto_quarantine_min = p.auto_quarantine_min,
   reply->intl_units_ind = p.intl_units_ind,
   reply->storage_temp_cd = p.storage_temp_cd, reply->drawn_dt_tm_ind = p.drawn_dt_tm_ind
  WITH nocounter, outerjoin = p, dontcare = o
 ;end select
 IF (curqual=0)
  SET reply->status_data.operationname = "read"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "table"
  SET reply->status_data.targetobjectvalue = "product_INDEX"
 ELSE
  SELECT INTO "nl:"
   FROM product_category p
   WHERE p.product_cat_cd=product_cat_cd
   DETAIL
    reply->red_cell_product_ind = p.red_cell_product_ind, reply->rh_required_ind = p.rh_required_ind,
    reply->confirm_required_ind = p.confirm_required_ind,
    reply->xmatch_required_ind = p.xmatch_required_ind, reply->default_unit_measure_cd = p
    .default_unit_measure_cd, reply->default_vis_insp_cd = p.default_vis_insp_cd,
    reply->default_ship_cond_cd = p.default_ship_cond_cd, reply->prompt_vol_ind = p.prompt_vol_ind,
    reply->prompt_segment_ind = p.prompt_segment_ind,
    reply->prompt_alternate_ind = p.prompt_alternate_ind, reply->special_testing_ind = p
    .special_testing_ind, reply->crossmatch_tag_ind = p.crossmatch_tag_ind,
    reply->component_tag_ind = p.component_tag_ind, reply->pilot_label_ind = p.pilot_label_ind, reply
    ->valid_aborh_compat_ind = p.valid_aborh_compat_ind
   WITH counter
  ;end select
  IF (curqual=0)
   SET reply->status_data.operationname = "read"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "table"
   SET reply->status_data.targetobjectvalue = "product_category"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
