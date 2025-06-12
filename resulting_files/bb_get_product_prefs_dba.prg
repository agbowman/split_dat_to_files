CREATE PROGRAM bb_get_product_prefs:dba
 RECORD reply(
   1 product_types[*]
     2 product_cd = f8
     2 product_disp = c40
     2 product_class_cd = f8
     2 product_class_disp = c40
     2 product_class_desc = vc
     2 product_class_mean = c12
     2 product_cat_cd = f8
     2 product_cat_disp = c40
     2 autologous_ind = i2
     2 directed_ind = i2
     2 allow_dispense_ind = i2
     2 default_volume = i2
     2 max_days_expire = i2
     2 max_hrs_expire = i2
     2 default_supplier_id = f8
     2 default_supplier_name = vc
     2 confirm_synonym_id = f8
     2 confirm_catalog_cd = f8
     2 confirm_mnemonic = vc
     2 confirm_catalog_type_cd = f8
     2 confirm_oe_format_id = f8
     2 auto_quarantine_min = i4
     2 intl_units_ind = i2
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
     2 pilot_label_ind = i2
     2 storage_temp_cd = f8
     2 storage_temp_disp = c40
     2 valid_aborh_compat_ind = i2
     2 drawn_dt_tm_ind = i2
     2 active_ind = i2
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
 SET modify = predeclare
 DECLARE product_cnt = i4 WITH noconstant(0)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 DECLARE product_type_cs = i4 WITH constant(1604)
 DECLARE prod_type_cnt = i4 WITH noconstant(0)
 SET prod_type_cnt = size(request->product_types,5)
 IF (prod_type_cnt=0)
  SELECT INTO "nl:"
   FROM code_value cv,
    product_index pi,
    product_category pc,
    organization o,
    order_catalog_synonym ocs
   PLAN (cv
    WHERE cv.code_set=product_type_cs
     AND (((request->load_inactive_ind=0)
     AND cv.active_ind=1) OR ((request->load_inactive_ind=1))) )
    JOIN (pi
    WHERE pi.product_cd=cv.code_value)
    JOIN (pc
    WHERE (pc.product_cat_cd= Outerjoin(pi.product_cat_cd)) )
    JOIN (o
    WHERE (o.organization_id= Outerjoin(pi.default_supplier_id))
     AND (o.organization_id!= Outerjoin(0)) )
    JOIN (ocs
    WHERE (ocs.synonym_id= Outerjoin(pi.synonym_id))
     AND (ocs.synonym_id!= Outerjoin(0)) )
   HEAD REPORT
    product_cnt = 0
   DETAIL
    product_cnt += 1
    IF (mod(product_cnt,10)=1)
     stat = alterlist(reply->product_types,(product_cnt+ 9))
    ENDIF
    reply->product_types[product_cnt].product_cd = cv.code_value, reply->product_types[product_cnt].
    product_class_cd = pi.product_class_cd, reply->product_types[product_cnt].product_cat_cd = pi
    .product_cat_cd,
    reply->product_types[product_cnt].autologous_ind = pi.autologous_ind, reply->product_types[
    product_cnt].directed_ind = pi.directed_ind, reply->product_types[product_cnt].allow_dispense_ind
     = pi.allow_dispense_ind,
    reply->product_types[product_cnt].default_volume = pi.default_volume, reply->product_types[
    product_cnt].max_days_expire = pi.max_days_expire, reply->product_types[product_cnt].
    max_hrs_expire = pi.max_hrs_expire,
    reply->product_types[product_cnt].default_supplier_id = pi.default_supplier_id, reply->
    product_types[product_cnt].default_supplier_name = o.org_name, reply->product_types[product_cnt].
    confirm_synonym_id = pi.synonym_id,
    reply->product_types[product_cnt].confirm_catalog_cd = ocs.catalog_cd, reply->product_types[
    product_cnt].confirm_mnemonic = ocs.mnemonic, reply->product_types[product_cnt].
    confirm_catalog_type_cd = ocs.catalog_type_cd,
    reply->product_types[product_cnt].confirm_oe_format_id = ocs.oe_format_id, reply->product_types[
    product_cnt].auto_quarantine_min = pi.auto_quarantine_min, reply->product_types[product_cnt].
    intl_units_ind = pi.intl_units_ind,
    reply->product_types[product_cnt].storage_temp_cd = pi.storage_temp_cd, reply->product_types[
    product_cnt].drawn_dt_tm_ind = pi.drawn_dt_tm_ind, reply->product_types[product_cnt].
    red_cell_product_ind = pc.red_cell_product_ind,
    reply->product_types[product_cnt].rh_required_ind = pc.rh_required_ind, reply->product_types[
    product_cnt].confirm_required_ind = pc.confirm_required_ind, reply->product_types[product_cnt].
    xmatch_required_ind = pc.xmatch_required_ind,
    reply->product_types[product_cnt].default_unit_measure_cd = pc.default_unit_measure_cd, reply->
    product_types[product_cnt].default_vis_insp_cd = pc.default_vis_insp_cd, reply->product_types[
    product_cnt].default_ship_cond_cd = pc.default_ship_cond_cd,
    reply->product_types[product_cnt].prompt_vol_ind = pc.prompt_vol_ind, reply->product_types[
    product_cnt].prompt_segment_ind = pc.prompt_segment_ind, reply->product_types[product_cnt].
    prompt_alternate_ind = pc.prompt_alternate_ind,
    reply->product_types[product_cnt].special_testing_ind = pc.special_testing_ind, reply->
    product_types[product_cnt].crossmatch_tag_ind = pc.crossmatch_tag_ind, reply->product_types[
    product_cnt].component_tag_ind = pc.component_tag_ind,
    reply->product_types[product_cnt].pilot_label_ind = pc.pilot_label_ind, reply->product_types[
    product_cnt].valid_aborh_compat_ind = pc.valid_aborh_compat_ind, reply->product_types[product_cnt
    ].active_ind = cv.active_ind,
    reply->product_types[product_cnt].donor_label_aborh_cnt = pc.donor_label_aborh_cnt
   FOOT REPORT
    stat = alterlist(reply->product_types,product_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (prod_type_cnt > 0)
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(prod_type_cnt)),
    code_value cv,
    product_index pi,
    product_category pc,
    organization o,
    order_catalog_synonym ocs
   PLAN (d
    WHERE d.seq <= prod_type_cnt)
    JOIN (cv
    WHERE (cv.code_value=request->product_types[d.seq].product_cd)
     AND (((request->load_inactive_ind=0)
     AND cv.active_ind=1) OR ((request->load_inactive_ind=1))) )
    JOIN (pi
    WHERE pi.product_cd=cv.code_value)
    JOIN (pc
    WHERE (pc.product_cat_cd= Outerjoin(pi.product_cat_cd)) )
    JOIN (o
    WHERE (o.organization_id= Outerjoin(pi.default_supplier_id))
     AND (o.organization_id!= Outerjoin(0)) )
    JOIN (ocs
    WHERE (ocs.synonym_id= Outerjoin(pi.synonym_id))
     AND (ocs.synonym_id!= Outerjoin(0)) )
   HEAD REPORT
    product_cnt = 0
   DETAIL
    product_cnt += 1
    IF (mod(product_cnt,10)=1)
     stat = alterlist(reply->product_types,(product_cnt+ 9))
    ENDIF
    reply->product_types[product_cnt].product_cd = cv.code_value, reply->product_types[product_cnt].
    product_class_cd = pi.product_class_cd, reply->product_types[product_cnt].product_cat_cd = pi
    .product_cat_cd,
    reply->product_types[product_cnt].autologous_ind = pi.autologous_ind, reply->product_types[
    product_cnt].directed_ind = pi.directed_ind, reply->product_types[product_cnt].allow_dispense_ind
     = pi.allow_dispense_ind,
    reply->product_types[product_cnt].default_volume = pi.default_volume, reply->product_types[
    product_cnt].max_days_expire = pi.max_days_expire, reply->product_types[product_cnt].
    max_hrs_expire = pi.max_hrs_expire,
    reply->product_types[product_cnt].default_supplier_id = pi.default_supplier_id, reply->
    product_types[product_cnt].default_supplier_name = o.org_name, reply->product_types[product_cnt].
    confirm_synonym_id = pi.synonym_id,
    reply->product_types[product_cnt].confirm_catalog_cd = ocs.catalog_cd, reply->product_types[
    product_cnt].confirm_mnemonic = ocs.mnemonic, reply->product_types[product_cnt].
    confirm_catalog_type_cd = ocs.catalog_type_cd,
    reply->product_types[product_cnt].confirm_oe_format_id = ocs.oe_format_id, reply->product_types[
    product_cnt].auto_quarantine_min = pi.auto_quarantine_min, reply->product_types[product_cnt].
    intl_units_ind = pi.intl_units_ind,
    reply->product_types[product_cnt].storage_temp_cd = pi.storage_temp_cd, reply->product_types[
    product_cnt].drawn_dt_tm_ind = pi.drawn_dt_tm_ind, reply->product_types[product_cnt].
    red_cell_product_ind = pc.red_cell_product_ind,
    reply->product_types[product_cnt].rh_required_ind = pc.rh_required_ind, reply->product_types[
    product_cnt].confirm_required_ind = pc.confirm_required_ind, reply->product_types[product_cnt].
    xmatch_required_ind = pc.xmatch_required_ind,
    reply->product_types[product_cnt].default_unit_measure_cd = pc.default_unit_measure_cd, reply->
    product_types[product_cnt].default_vis_insp_cd = pc.default_vis_insp_cd, reply->product_types[
    product_cnt].default_ship_cond_cd = pc.default_ship_cond_cd,
    reply->product_types[product_cnt].prompt_vol_ind = pc.prompt_vol_ind, reply->product_types[
    product_cnt].prompt_segment_ind = pc.prompt_segment_ind, reply->product_types[product_cnt].
    prompt_alternate_ind = pc.prompt_alternate_ind,
    reply->product_types[product_cnt].special_testing_ind = pc.special_testing_ind, reply->
    product_types[product_cnt].crossmatch_tag_ind = pc.crossmatch_tag_ind, reply->product_types[
    product_cnt].component_tag_ind = pc.component_tag_ind,
    reply->product_types[product_cnt].pilot_label_ind = pc.pilot_label_ind, reply->product_types[
    product_cnt].valid_aborh_compat_ind = pc.valid_aborh_compat_ind, reply->product_types[product_cnt
    ].active_ind = cv.active_ind,
    reply->product_types[product_cnt].donor_label_aborh_cnt = pc.donor_label_aborh_cnt
   FOOT REPORT
    stat = alterlist(reply->product_types,product_cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","F","BB_PRODUCT_TYPE",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  GO TO set_status
 ENDIF
 SUBROUTINE (errorhandler(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=
  vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = operationname
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
 END ;Subroutine
#set_status
 IF (product_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
