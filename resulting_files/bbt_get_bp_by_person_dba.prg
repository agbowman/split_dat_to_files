CREATE PROGRAM bbt_get_bp_by_person:dba
 RECORD reply(
   1 qual[*]
     2 product_id = f8
     2 product_nbr = vc
     2 flag_chars = c2
     2 alternate_nbr = vc
     2 product_sub_nbr = c5
     2 product_cd = f8
     2 product_disp = vc
     2 product_desc = vc
     2 product_mean = c12
     2 product_cat_cd = f8
     2 product_cat_disp = vc
     2 product_cat_desc = vc
     2 product_cat_mean = c12
     2 product_class_cd = f8
     2 product_class_disp = vc
     2 product_class_desc = vc
     2 product_class_mean = c12
     2 cur_supplier_id = f8
     2 cur_inv_locn_cd = f8
     2 cur_inv_locn_disp = vc
     2 cur_inv_locn_desc = vc
     2 cur_inv_locn_mean = c12
     2 orig_inv_locn_cd = f8
     2 orig_inv_locn_disp = vc
     2 orig_inv_locn_desc = vc
     2 orig_inv_locn_mean = c12
     2 orig_vis_insp_cd = f8
     2 orig_vis_insp_disp = vc
     2 orig_vis_insp_desc = vc
     2 orig_vis_insp_mean = c12
     2 orig_ship_cond_cd = f8
     2 orig_ship_cond_disp = vc
     2 orig_ship_cond_desc = vc
     2 orig_ship_cond_mean = c12
     2 recv_dt_tm = dq8
     2 recv_prsnl_id = f8
     2 storage_temp_cd = f8
     2 storage_temp_disp = vc
     2 storage_temp_desc = vc
     2 storage_temp_mean = c12
     2 cur_unit_meas_cd = f8
     2 cur_unit_meas_disp = vc
     2 cur_unit_meas_desc = vc
     2 cur_unit_meas_mean = c12
     2 pooled_product_ind = i2
     2 modified_product_ind = i2
     2 donated_by_relative_ind = i2
     2 corrected_ind = i2
     2 pooled_product_id = f8
     2 modified_product_id = f8
     2 cur_expire_dt_tm = dq8
     2 product_updt_cnt = i4
     2 product_updt_dt_tm = di8
     2 product_updt_id = f8
     2 product_updt_task = i4
     2 product_updt_applctx = i4
     2 locked_ind = i2
     2 cur_device_id = f8
     2 cur_device_desc = vc
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 service_resource_desc = vc
     2 service_resource_mean = c12
     2 inventory_area_cd = f8
     2 inventory_area_disp = vc
     2 inventory_area_desc = vc
     2 inventory_area_mean = c12
     2 device_type_cd = f8
     2 device_type_disp = vc
     2 device_type_desc = vc
     2 device_type_mean = c12
     2 cur_owner_area_cd = f8
     2 cur_owner_area_disp = vc
     2 cur_owner_area_desc = vc
     2 cur_owner_area_mean = c12
     2 cur_inv_area_cd = f8
     2 cur_inv_area_disp = vc
     2 cur_inv_area_desc = vc
     2 cur_inv_area_mean = c12
     2 cur_inv_device_id = f8
     2 cur_inv_device_desc = vc
     2 barcode_nbr = vc
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 upload_dt_tm = dq8
     2 cross_reference = vc
     2 disease_cd = f8
     2 disease_disp = c40
     2 donation_type_cd = f8
     2 donation_type_disp = c40
     2 electronic_entry_flag = i2
     2 req_label_verify_ind = i2
     2 intended_use_print_parm_txt = c1
     2 history_upload_ind = i2
     2 comments_ind = i2
     2 supplier_name = vc
     2 product_type = c2
     2 blood_product_cd = f8
     2 blood_product_disp = vc
     2 blood_product_desc = vc
     2 blood_product_mean = c12
     2 supplier_prefix_cd = f8
     2 supplier_prefix_disp = vc
     2 supplier_prefix_desc = vc
     2 supplier_prefix_mean = c12
     2 cur_volume = i4
     2 cur_abo_cd = f8
     2 cur_abo_disp = vc
     2 cur_abo_desc = vc
     2 cur_abo_mean = c12
     2 cur_rh_cd = f8
     2 cur_rh_disp = vc
     2 cur_rh_desc = vc
     2 cur_rh_mean = c12
     2 segment_nbr = vc
     2 lot_nbr = vc
     2 autologous_ind = i2
     2 directed_ind = i2
     2 blood_prod_updt_cnt = i4
     2 blood_prod_updt_dt_tm = dq8
     2 blood_prod_updt_id = f8
     2 blood_prod_updt_task = i4
     2 blood_prod_updt_applctx = i4
     2 supplier_prefix = c5
     2 drawn_dt_tm = dq8
     2 drawn_dt_tm_ind = i2
     2 donor_person_id = f8
     2 deriv_product_cd = f8
     2 deriv_product_disp = vc
     2 deriv_product_desc = vc
     2 deriv_product_mean = c12
     2 deriv_manufacturer_id = f8
     2 deriv_manufacturer = vc
     2 deriv_cur_avail_qty = i4
     2 deriv_cur_intl_units = i4
     2 deriv_item_volume = i4
     2 deriv_item_unit_meas_cd = f8
     2 deriv_item_unit_meas_disp = vc
     2 deriv_item_unit_meas_desc = vc
     2 deriv_item_unit_meas_mean = c12
     2 deriv_updt_cnt = i4
     2 deriv_updt_dt_tm = dq8
     2 deriv_updt_id = f8
     2 deriv_updt_task = i4
     2 deriv_updt_applctx = i4
     2 deriv_track_intl_units = i2
     2 deriv_units_per_vial = i4
     2 nbr_of_states = i4
     2 qual2[*]
       3 product_event_id = f8
       3 product_id = f8
       3 person_id = f8
       3 encntr_id = f8
       3 order_id = f8
       3 bb_result_id = f8
       3 event_type_cd = f8
       3 event_type_disp = vc
       3 event_type_desc = vc
       3 event_type_mean = c12
       3 event_status_flag = i2
       3 event_dt_tm = dq8
       3 event_prsnl_id = f8
       3 override_ind = i2
       3 override_reason_cd = f8
       3 override_reason_disp = vc
       3 override_reason_desc = vc
       3 override_reason_mean = c12
       3 related_product_event_id = f8
       3 active_ind = i2
       3 event_updt_cnt = i4
       3 event_updt_dt_tm = dq8
       3 event_updt_id = f8
       3 event_updt_task = i4
       3 event_updt_applctx = i4
       3 expected_usage_dt_tm = dq8
       3 donated_by_relative_ind = i2
       3 collation_seq = i4
       3 patient_name = vc
       3 sub_cur_qty = i4
       3 sub_orig_qty = i4
       3 sub_updt_cnt = i4
       3 sub_orig_intl_units = i4
       3 sub_cur_intl_units = i4
       3 sub_reason_cd = f8
       3 sub_reason_disp = vc
       3 sub_reason_desc = vc
       3 sub_reason_mean = c12
       3 sub_location_cd = f8
       3 sub_location_disp = vc
       3 sub_location_desc = vc
       3 sub_location_mean = c12
     2 xmatch_required_ind = i2
     2 recon_type_flag = i2
     2 product_type_barcode = vc
     2 interfaced_device_flag = i2
     2 serial_nbr_txt = vc
     2 create_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET prod_cnt = 0
 SET max_event_cnt = 0
 SET assign_event_type_cd = 0.0
 SET assign_collation_seq = 0
 SET quarantine_event_type_cd = 0.0
 SET quarantine_collation_seq = 0
 SET crossmatch_event_type_cd = 0.0
 SET crossmatch_collation_seq = 0
 SET dispense_event_type_cd = 0.0
 SET dispense_collation_seq = 0
 SET disposed_event_type_cd = 0.0
 SET disposed_collation_seq = 0
 SET transfer_event_type_cd = 0.0
 SET transfer_collation_seq = 0
 SET transfused_event_type_cd = 0.0
 SET transfused_collation_seq = 0
 SET modification_event_type_cd = 0.0
 SET modification_collation_seq = 0
 SET unconfirmed_event_type_cd = 0.0
 SET unconfirmed_collation_seq = 0
 SET autologous_event_type_cd = 0.0
 SET autologous_collation_seq = 0
 SET directed_event_type_cd = 0.0
 SET directed_collation_seq = 0
 SET available_event_type_cd = 0.0
 SET available_collation_seq = 0
 SET received_event_type_cd = 0.0
 SET received_collation_seq = 0
 SET destruction_event_type_cd = 0.0
 SET destruction_collation_seq = 0
 SET shipped_event_type_cd = 0.0
 SET shipped_collation_seq = 0
 SET in_progress_event_type_cd = 0.0
 SET in_progress_collation_seq = 0
 SET pooled_event_type_cd = 0.0
 SET pooled_collation_seq = 0
 SET pooled_prod_event_type_cd = 0.0
 SET pooled_prod_collation_seq = 0
 SET confirmed_event_type_cd = 0.0
 SET confirmed_collation_seq = 0
 SET drawn_event_type_cd = 0.0
 SET drawn_collation_seq = 0
 SET tested_event_type_cd = 0.0
 SET tested_collation_seq = 0
 SET shipment_in_process_event_type_cd = 0.0
 SET shipment_in_process_collation_seq = 0
 SET verified_event_type_cd = 0.0
 SET verified_collation_seq = 0
 DECLARE modified_prod_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE modified_prod_collation_seq = i4 WITH protect, noconstant(0)
 DECLARE in_transit_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE in_transit_collation_seq = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1610
   AND cnvtdatetime(sysdate) >= cv.begin_effective_dt_tm
   AND cnvtdatetime(sysdate) <= cv.end_effective_dt_tm
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="1"
    AND (request->assign=1))
    assign_event_type_cd = cv.code_value, assign_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="2"
    AND (request->quarantine=1))
    quarantine_event_type_cd = cv.code_value, quarantine_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="3"
    AND (request->crossmatch=1))
    crossmatch_event_type_cd = cv.code_value, crossmatch_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="4"
    AND (request->dispense=1))
    dispense_event_type_cd = cv.code_value, dispense_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="5"
    AND (request->disposed=1))
    disposed_event_type_cd = cv.code_value, disposed_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="6"
    AND (request->transfer=1))
    transfer_event_type_cd = cv.code_value, transfer_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="7"
    AND (request->transfused=1))
    transfused_event_type_cd = cv.code_value, transfused_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="8"
    AND (request->modification=1))
    modification_event_type_cd = cv.code_value, modification_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="9"
    AND (request->unconfirmed=1))
    unconfirmed_event_type_cd = cv.code_value, unconfirmed_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="10"
    AND (request->autologous=1))
    autologous_event_type_cd = cv.code_value, autologous_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="11"
    AND (request->directed=1))
    directed_event_type_cd = cv.code_value, directed_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="12"
    AND (request->available=1))
    available_event_type_cd = cv.code_value, available_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="13"
    AND (request->received=1))
    received_event_type_cd = cv.code_value, received_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="14"
    AND (request->destruction=1))
    destruction_event_type_cd = cv.code_value, destruction_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="15"
    AND (request->shipped=1))
    shipped_event_type_cd = cv.code_value, shipped_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="16"
    AND (request->in_progress=1))
    in_progress_event_type_cd = cv.code_value, in_progress_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="17"
    AND (request->pooled=1))
    pooled_event_type_cd = cv.code_value, pooled_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="18"
    AND (request->pooled_prod=1))
    pooled_prod_event_type_cd = cv.code_value, pooled_prod_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="19"
    AND (request->confirmed=1))
    confirmed_event_type_cd = cv.code_value, confirmed_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="20"
    AND (request->drawn=1))
    drawn_event_type_cd = cv.code_value, drawn_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="21"
    AND (request->tested=1))
    tested_event_type_cd = cv.code_value, tested_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="22"
    AND (request->shipment_in_process=1))
    shipment_in_process_event_type_cd = cv.code_value, shipment_in_process_collation_seq = cv
    .collation_seq
   ELSEIF (cv.cdf_meaning="23"
    AND (request->verified=1))
    verified_event_type_cd = cv.code_value, verified_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="24"
    AND (request->modified_prod=1))
    modified_prod_event_type_cd = cv.code_value, modified_prod_collation_seq = cv.collation_seq
   ELSEIF (cv.cdf_meaning="25"
    AND (request->intransit=1))
    in_transit_event_type_cd = cv.code_value, in_transit_collation_seq = cv.collation_seq
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,1)
 SELECT DISTINCT INTO "nl:"
  p.product_id, pe.product_event_id
  FROM product_event pe,
   product p,
   product_category pc,
   component cmp,
   (dummyt d_bbd  WITH seq = 1),
   bb_inv_device bbd,
   (dummyt d_r  WITH seq = 1),
   receipt r
  PLAN (pe
   WHERE (pe.person_id=request->person_id)
    AND (((request->active_states=0)) OR ((request->active_states=1)
    AND pe.active_ind=1))
    AND ((pe.event_status_flag < 1) OR (pe.event_status_flag=null))
    AND pe.event_type_cd > 0
    AND pe.event_type_cd IN (assign_event_type_cd, quarantine_event_type_cd, crossmatch_event_type_cd,
   dispense_event_type_cd, disposed_event_type_cd,
   transfer_event_type_cd, transfused_event_type_cd, modification_event_type_cd,
   unconfirmed_event_type_cd, autologous_event_type_cd,
   directed_event_type_cd, available_event_type_cd, destruction_event_type_cd, shipped_event_type_cd,
   in_progress_event_type_cd,
   pooled_event_type_cd, pooled_prod_event_type_cd, received_event_type_cd, confirmed_event_type_cd,
   drawn_event_type_cd,
   tested_event_type_cd, shipment_in_process_event_type_cd, verified_event_type_cd,
   modified_prod_event_type_cd, in_transit_event_type_cd)
    AND pe.product_id > 0.0)
   JOIN (p
   WHERE p.product_id=pe.product_id
    AND (((request->product_nbr > " ")
    AND cnvtupper(p.product_nbr)=cnvtupper(request->product_nbr)
    AND (request->product_id <= 0.0)) OR ((((request->product_nbr <= " ")
    AND (request->product_id > 0.0)
    AND (p.product_id=request->product_id)) OR ((request->product_nbr <= " ")
    AND p.product_id > 0.0
    AND (request->product_id <= 0.0))) ))
    AND (((request->product_cd=0)) OR ((request->product_cd=p.product_cd)))
    AND p.product_id > 0.0)
   JOIN (pc
   WHERE pc.product_cat_cd=p.product_cat_cd)
   JOIN (cmp
   WHERE (((request->pool_option_id > 0.0)
    AND (cmp.option_id=request->pool_option_id)
    AND cmp.product_cd=p.product_cd
    AND cmp.active_ind=1) OR ((request->pool_option_id=0.0)
    AND cmp.option_id=0.0)) )
   JOIN (d_bbd
   WHERE d_bbd.seq=1)
   JOIN (bbd
   WHERE bbd.bb_inv_device_id=p.cur_dispense_device_id
    AND bbd.bb_inv_device_id != null
    AND bbd.bb_inv_device_id > 0)
   JOIN (d_r
   WHERE d_r.seq=1)
   JOIN (r
   WHERE r.product_id=p.product_id)
  ORDER BY pe.product_id, r.updt_dt_tm
  HEAD REPORT
   prod_cnt = 0
  HEAD pe.product_id
   prod_cnt += 1
   IF (((mod(prod_cnt,5)=1
    AND prod_cnt != 1) OR (prod_cnt=2)) )
    IF (prod_cnt=2)
     stat = alterlist(reply->qual,5)
    ELSE
     stat = alterlist(reply->qual,(prod_cnt+ 4))
    ENDIF
   ENDIF
   reply->qual[prod_cnt].product_id = p.product_id, reply->qual[prod_cnt].product_nbr = p.product_nbr,
   reply->qual[prod_cnt].flag_chars = p.flag_chars,
   reply->qual[prod_cnt].alternate_nbr = p.alternate_nbr, reply->qual[prod_cnt].product_sub_nbr = p
   .product_sub_nbr, reply->qual[prod_cnt].serial_nbr_txt = p.serial_number_txt,
   reply->qual[prod_cnt].product_cd = p.product_cd, reply->qual[prod_cnt].product_cat_cd = p
   .product_cat_cd, reply->qual[prod_cnt].product_class_cd = p.product_class_cd,
   reply->qual[prod_cnt].cur_supplier_id = p.cur_supplier_id, reply->qual[prod_cnt].cur_inv_locn_cd
    = p.cur_inv_locn_cd, reply->qual[prod_cnt].orig_inv_locn_cd = p.orig_inv_locn_cd,
   reply->qual[prod_cnt].recv_dt_tm = cnvtdatetime(p.recv_dt_tm), reply->qual[prod_cnt].recv_prsnl_id
    = p.recv_prsnl_id, reply->qual[prod_cnt].storage_temp_cd = p.storage_temp_cd,
   reply->qual[prod_cnt].cur_unit_meas_cd = p.cur_unit_meas_cd, reply->qual[prod_cnt].
   pooled_product_ind = p.pooled_product_ind, reply->qual[prod_cnt].modified_product_ind = p
   .modified_product_ind,
   reply->qual[prod_cnt].donated_by_relative_ind = p.donated_by_relative_ind, reply->qual[prod_cnt].
   corrected_ind = p.corrected_ind, reply->qual[prod_cnt].pooled_product_id = p.pooled_product_id,
   reply->qual[prod_cnt].modified_product_id = p.modified_product_id, reply->qual[prod_cnt].
   orig_vis_insp_cd = r.vis_insp_cd, reply->qual[prod_cnt].orig_ship_cond_cd = r.ship_cond_cd,
   reply->qual[prod_cnt].cur_expire_dt_tm = cnvtdatetime(p.cur_expire_dt_tm), reply->qual[prod_cnt].
   product_updt_cnt = p.updt_cnt, reply->qual[prod_cnt].product_updt_dt_tm = cnvtdatetime(p
    .updt_dt_tm),
   reply->qual[prod_cnt].product_updt_id = p.updt_id, reply->qual[prod_cnt].product_updt_task = p
   .updt_task, reply->qual[prod_cnt].product_updt_applctx = p.updt_applctx,
   reply->qual[prod_cnt].locked_ind = p.locked_ind
   IF (bbd.bb_inv_device_id != null
    AND bbd.bb_inv_device_id > 0)
    reply->qual[prod_cnt].cur_device_id = p.cur_dispense_device_id, reply->qual[prod_cnt].
    cur_device_desc = bbd.description
   ELSE
    reply->qual[prod_cnt].cur_device_id = 0.0, reply->qual[prod_cnt].cur_device_desc = ""
   ENDIF
   reply->qual[prod_cnt].cur_owner_area_cd = p.cur_owner_area_cd, reply->qual[prod_cnt].
   cur_inv_area_cd = p.cur_inv_area_cd, reply->qual[prod_cnt].cur_inv_device_id = p.cur_inv_device_id,
   reply->qual[prod_cnt].disease_cd = p.disease_cd, reply->qual[prod_cnt].donation_type_cd = p
   .donation_type_cd, reply->qual[prod_cnt].electronic_entry_flag = p.electronic_entry_flag,
   reply->qual[prod_cnt].req_label_verify_ind = p.req_label_verify_ind, reply->qual[prod_cnt].
   xmatch_required_ind = pc.xmatch_required_ind
  FOOT REPORT
   stat = alterlist(reply->qual,prod_cnt)
  WITH nocounter, dontcare(bbd), outerjoin(d_r)
 ;end select
 IF (prod_cnt=0)
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  d.seq, tablefrom = decode(bp.seq,"BP",dr.seq,"DR",pn.seq,
   "PN",org.seq,"ORG","XXX"), org.seq,
  org.org_name, pn.seq, pn.product_id,
  bp.seq, bp.product_id, dr.seq,
  dr.product_id, pi.product_cd, org1.org_name
  FROM (dummyt d  WITH seq = value(prod_cnt)),
   organization org,
   product_note pn,
   blood_product bp,
   derivative dr,
   product_index pi,
   (dummyt d_bp_d  WITH seq = 1),
   organization org1
  PLAN (d)
   JOIN (((org
   WHERE (org.organization_id=reply->qual[d.seq].cur_supplier_id))
   ) ORJOIN ((((pn
   WHERE (pn.product_id=reply->qual[d.seq].product_id)
    AND pn.active_ind=1)
   ) ORJOIN ((((bp
   WHERE (bp.product_id=reply->qual[d.seq].product_id))
   ) ORJOIN ((dr
   WHERE (dr.product_id=reply->qual[d.seq].product_id))
   JOIN (pi
   WHERE pi.product_cd=dr.product_cd
    AND (pi.product_cat_cd=reply->qual[d.seq].product_cat_cd)
    AND (pi.product_class_cd=reply->qual[d.seq].product_class_cd))
   JOIN (d_bp_d
   WHERE d_bp_d.seq=1)
   JOIN (org1
   WHERE org1.organization_id=dr.manufacturer_id)
   )) )) ))
  HEAD d.seq
   reply->qual[d.seq].comments_ind = 0, reply->qual[d.seq].supplier_name = "Unknown Supplier", reply
   ->qual[d.seq].deriv_manufacturer = "Unknown Manufacturer"
  DETAIL
   row + 1, col 001, tablefrom
   IF (trim(tablefrom)="PN")
    reply->qual[d.seq].comments_ind = 1
   ELSEIF (trim(tablefrom)="ORG")
    reply->qual[d.seq].supplier_name = org.org_name
   ELSEIF (trim(tablefrom)="BP")
    reply->qual[d.seq].product_type = "B", reply->qual[d.seq].blood_product_cd = bp.product_cd, reply
    ->qual[d.seq].cur_volume = bp.cur_volume,
    reply->qual[d.seq].cur_abo_cd = bp.cur_abo_cd, reply->qual[d.seq].cur_rh_cd = bp.cur_rh_cd, reply
    ->qual[d.seq].segment_nbr = bp.segment_nbr,
    reply->qual[d.seq].lot_nbr = bp.lot_nbr, reply->qual[d.seq].autologous_ind = bp.autologous_ind,
    reply->qual[d.seq].directed_ind = bp.directed_ind,
    reply->qual[d.seq].blood_prod_updt_cnt = bp.updt_cnt, reply->qual[d.seq].blood_prod_updt_dt_tm =
    cnvtdatetime(bp.updt_dt_tm), reply->qual[d.seq].blood_prod_updt_id = bp.updt_id,
    reply->qual[d.seq].blood_prod_updt_task = bp.updt_task, reply->qual[d.seq].
    blood_prod_updt_applctx = bp.updt_applctx, reply->qual[d.seq].supplier_prefix = bp
    .supplier_prefix,
    reply->qual[d.seq].drawn_dt_tm = cnvtdatetime(bp.drawn_dt_tm), reply->qual[d.seq].donor_person_id
     = bp.donor_person_id, reply->qual[d.seq].drawn_dt_tm_ind = pi.drawn_dt_tm_ind
   ELSEIF (trim(tablefrom)="DR")
    reply->qual[d.seq].product_type = "D", reply->qual[d.seq].deriv_product_cd = dr.product_cd, reply
    ->qual[d.seq].deriv_manufacturer_id = dr.manufacturer_id,
    reply->qual[d.seq].deriv_manufacturer = org1.org_name, reply->qual[d.seq].deriv_cur_avail_qty =
    dr.cur_avail_qty, reply->qual[d.seq].deriv_cur_intl_units = dr.cur_intl_units,
    reply->qual[d.seq].deriv_item_volume = dr.item_volume, reply->qual[d.seq].deriv_item_unit_meas_cd
     = dr.item_unit_meas_cd, reply->qual[d.seq].deriv_updt_cnt = dr.updt_cnt,
    reply->qual[d.seq].deriv_updt_dt_tm = dr.updt_dt_tm, reply->qual[d.seq].deriv_updt_id = dr
    .updt_id, reply->qual[d.seq].deriv_updt_task = dr.updt_task,
    reply->qual[d.seq].deriv_updt_applctx = dr.updt_applctx, reply->qual[d.seq].
    deriv_track_intl_units = pi.intl_units_ind, reply->qual[d.seq].deriv_units_per_vial = dr
    .units_per_vial,
    reply->qual[d.seq].drawn_dt_tm_ind = 0
   ENDIF
  WITH nocounter, outerjoin(d_bp_d)
 ;end select
 IF (validate(blood_product_class_cd,0)=0)
  DECLARE sblood_cdf = c12 WITH protect, constant("BLOOD")
 ENDIF
 SET max_event_cnt = 0
 SELECT INTO "nl:"
  d.seq, pe.product_event_id, pe.product_id,
  pe.order_id, pe.bb_result_id, pe.event_type_cd,
  pe.event_status_flag, pe.event_dt_tm, pe.event_prsnl_id,
  pe.override_ind, pe.override_reason_cd, pe.person_id,
  pe.encntr_id, pe.related_product_event_id, pe.updt_cnt,
  pe.updt_dt_tm, pe.updt_id, pe.updt_task,
  pe.updt_applctx, pe.active_ind, per.name_full_formatted,
  product_type_mean = uar_get_code_meaning(reply->qual[d.seq].product_class_cd)
  FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
   product_event pe,
   (dummyt d_per  WITH seq = 1),
   person per,
   (dummyt d_pd  WITH seq = 1),
   patient_dispense pd
  PLAN (d)
   JOIN (pe
   WHERE (reply->qual[d.seq].product_id=pe.product_id)
    AND (((request->active_states=1)
    AND pe.active_ind=1) OR ((request->active_states=0)))
    AND ((((pe.event_status_flag < 1) OR (pe.event_status_flag=null)) ) OR ((request->verify_status=0
   )
    AND destruction_event_type_cd=pe.event_type_cd
    AND pe.event_status_flag=1))
    AND pe.event_type_cd > 0
    AND pe.event_type_cd IN (assign_event_type_cd, quarantine_event_type_cd, crossmatch_event_type_cd,
   dispense_event_type_cd, disposed_event_type_cd,
   transfer_event_type_cd, transfused_event_type_cd, modification_event_type_cd,
   unconfirmed_event_type_cd, autologous_event_type_cd,
   directed_event_type_cd, available_event_type_cd, destruction_event_type_cd, shipped_event_type_cd,
   in_progress_event_type_cd,
   pooled_event_type_cd, pooled_prod_event_type_cd, received_event_type_cd, confirmed_event_type_cd,
   drawn_event_type_cd,
   tested_event_type_cd, shipment_in_process_event_type_cd, verified_event_type_cd,
   modified_prod_event_type_cd, in_transit_event_type_cd))
   JOIN (d_per
   WHERE d_per.seq=1)
   JOIN (per
   WHERE per.person_id=pe.person_id)
   JOIN (d_pd
   WHERE d_pd.seq=1)
   JOIN (pd
   WHERE ((pd.product_event_id=pe.product_event_id) OR (pe.event_type_cd=transfused_event_type_cd
    AND pd.product_event_id=pe.related_product_event_id)) )
  ORDER BY pe.event_dt_tm
  HEAD d.seq
   event_cnt = 0, stat = alterlist(reply->qual[d.seq].qual2,3)
  DETAIL
   IF (pe.event_type_cd != 0)
    ncontinueind = 1
    IF (validate(request->process_cdf," ") > " ")
     IF (product_type_mean != sblood_cdf)
      IF (check_event_valid(pe.product_id,pe.event_type_cd) <= 0)
       ncontinueind = 0
      ENDIF
     ENDIF
    ENDIF
    IF (ncontinueind > 0)
     event_cnt += 1
     IF (mod(event_cnt,3)=1
      AND event_cnt != 1)
      stat = alterlist(reply->qual[d.seq].qual2,(event_cnt+ 2))
     ENDIF
     IF (event_cnt > max_event_cnt)
      max_event_cnt = event_cnt
     ENDIF
     reply->qual[d.seq].qual2[event_cnt].product_event_id = pe.product_event_id, reply->qual[d.seq].
     qual2[event_cnt].product_id = pe.product_id, reply->qual[d.seq].qual2[event_cnt].person_id = pe
     .person_id,
     reply->qual[d.seq].qual2[event_cnt].encntr_id = pe.encntr_id, reply->qual[d.seq].qual2[event_cnt
     ].order_id = pe.order_id, reply->qual[d.seq].qual2[event_cnt].bb_result_id = pe.bb_result_id,
     reply->qual[d.seq].qual2[event_cnt].event_type_cd = pe.event_type_cd, reply->qual[d.seq].qual2[
     event_cnt].event_status_flag = pe.event_status_flag, reply->qual[d.seq].qual2[event_cnt].
     event_dt_tm = cnvtdatetime(pe.event_dt_tm),
     reply->qual[d.seq].qual2[event_cnt].event_prsnl_id = pe.event_prsnl_id, reply->qual[d.seq].
     qual2[event_cnt].override_ind = pe.override_ind, reply->qual[d.seq].qual2[event_cnt].
     override_reason_cd = pe.override_reason_cd,
     reply->qual[d.seq].qual2[event_cnt].related_product_event_id = pe.related_product_event_id,
     reply->qual[d.seq].qual2[event_cnt].active_ind = pe.active_ind, reply->qual[d.seq].qual2[
     event_cnt].event_updt_cnt = pe.updt_cnt,
     reply->qual[d.seq].qual2[event_cnt].event_updt_dt_tm = cnvtdatetime(pe.updt_dt_tm), reply->qual[
     d.seq].qual2[event_cnt].event_updt_id = pe.updt_id, reply->qual[d.seq].qual2[event_cnt].
     event_updt_task = pe.updt_task,
     reply->qual[d.seq].qual2[event_cnt].event_updt_applctx = pe.updt_applctx
     CASE (pe.event_type_cd)
      OF assign_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = assign_collation_seq
      OF quarantine_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = quarantine_collation_seq
      OF crossmatch_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = crossmatch_collation_seq
      OF dispense_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = dispense_collation_seq
      OF disposed_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = disposed_collation_seq
      OF transfer_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = transfer_collation_seq
      OF transfused_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = transfused_collation_seq
      OF modification_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = modification_collation_seq
      OF unconfirmed_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = unconfirmed_collation_seq
      OF autologous_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = autologous_collation_seq
      OF directed_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = directed_collation_seq
      OF available_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = available_collation_seq
      OF destruction_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = destruction_collation_seq
      OF shipped_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = shipped_collation_seq
      OF in_progress_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = in_progress_collation_seq
      OF pooled_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = pooled_collation_seq
      OF pooled_prod_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = pooled_prod_collation_seq
      OF received_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = received_collation_seq
      OF confirmed_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = confirmed_collation_seq
      OF drawn_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = drawn_collation_seq
      OF tested_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = tested_collation_seq
      OF shipment_in_process_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = shipment_in_process_collation_seq
      OF verified_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = verified_collation_seq
      OF modified_prod_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = modified_prod_collation_seq
      OF in_transit_event_type_cd:
       reply->qual[d.seq].qual2[event_cnt].collation_seq = in_transit_collation_seq
     ENDCASE
     IF (pe.person_id > 0.0
      AND per.person_id > 0.0
      AND  NOT (per.person_id=null))
      reply->qual[d.seq].qual2[event_cnt].patient_name = per.name_full_formatted
     ELSEIF (pd.unknown_patient_ind > 0)
      reply->qual[d.seq].qual2[event_cnt].patient_name = pd.unknown_patient_text
     ENDIF
     IF (pd.dispense_to_locn_cd > 0.0)
      reply->qual[d.seq].qual2[event_cnt].sub_location_cd = pd.dispense_to_locn_cd
     ELSE
      reply->qual[d.seq].qual2[event_cnt].sub_location_cd = 0.0
     ENDIF
    ENDIF
   ENDIF
   reply->qual[d.seq].nbr_of_states = event_cnt
  FOOT  d.seq
   stat = alterlist(reply->qual[d.seq].qual2,event_cnt)
  WITH nocounter, outerjoin(d_per), outerjoin(d_pd)
 ;end select
 SUBROUTINE (check_event_valid(productid=f8,statecd=f8) =i2)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE nproductidx = i4 WITH protect, noconstant(0)
   DECLARE nstateidx = i4 WITH protect, noconstant(0)
   SET nproductidx = locateval(num,1,size(temp->qual,5),productid,temp->qual[num].product_id)
   IF (nproductidx=0)
    RETURN(0)
   ENDIF
   SET num = 0
   SET nstateidx = locateval(num,1,size(temp->qual[nproductidx].valid_states,5),statecd,temp->qual[
    nproductidx].valid_states[num].valid_state_cd)
   IF (nstateidx=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SELECT INTO "nl:"
  rec.product_event_id, quar.product_event_id, modf.product_event_id,
  disp.product_event_id, dest.product_event_id, ad.product_event_id,
  ass.product_event_id, xm.product_event_id, pd.product_event_id,
  trns.product_event_id, tran.product_event_id, tablefrom = decode(rec.seq,"rec",quar.seq,"quar",modf
   .seq,
   "modf",disp.seq,"disp",dest.seq,"dest",
   ad.seq,"ad",ass.seq,"ass",xm.seq,
   "xm",pd.seq,"pd",trns.seq,"trns",
   tran.seq,"tran","xxxx")
  FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
   (dummyt d_pe  WITH seq = value(max_event_cnt)),
   receipt rec,
   quarantine quar,
   modification modf,
   disposition disp,
   destruction dest,
   auto_directed ad,
   assign ass,
   crossmatch xm,
   patient_dispense pd,
   transfer trns,
   transfusion tran
  PLAN (d)
   JOIN (d_pe
   WHERE (d_pe.seq <= reply->qual[d.seq].nbr_of_states))
   JOIN (((rec
   WHERE (rec.product_event_id=reply->qual[d.seq].qual2[d_pe.seq].product_event_id))
   ) ORJOIN ((((quar
   WHERE (quar.product_event_id=reply->qual[d.seq].qual2[d_pe.seq].product_event_id))
   ) ORJOIN ((((modf
   WHERE (modf.product_event_id=reply->qual[d.seq].qual2[d_pe.seq].product_event_id))
   ) ORJOIN ((((disp
   WHERE (disp.product_event_id=reply->qual[d.seq].qual2[d_pe.seq].product_event_id))
   ) ORJOIN ((((dest
   WHERE (dest.product_event_id=reply->qual[d.seq].qual2[d_pe.seq].product_event_id))
   ) ORJOIN ((((ad
   WHERE (ad.product_event_id=reply->qual[d.seq].qual2[d_pe.seq].product_event_id))
   ) ORJOIN ((((ass
   WHERE (ass.product_event_id=reply->qual[d.seq].qual2[d_pe.seq].product_event_id))
   ) ORJOIN ((((xm
   WHERE (xm.product_event_id=reply->qual[d.seq].qual2[d_pe.seq].product_event_id))
   ) ORJOIN ((((pd
   WHERE (pd.product_event_id=reply->qual[d.seq].qual2[d_pe.seq].product_event_id))
   ) ORJOIN ((((trns
   WHERE (trns.product_event_id=reply->qual[d.seq].qual2[d_pe.seq].product_event_id))
   ) ORJOIN ((tran
   WHERE (tran.product_event_id=reply->qual[d.seq].qual2[d_pe.seq].product_event_id))
   )) )) )) )) )) )) )) )) )) ))
  DETAIL
   IF (tablefrom="rec")
    reply->qual[d.seq].qual2[d_pe.seq].sub_cur_qty = rec.orig_rcvd_qty, reply->qual[d.seq].qual2[d_pe
    .seq].sub_orig_qty = rec.orig_rcvd_qty, reply->qual[d.seq].qual2[d_pe.seq].sub_updt_cnt = rec
    .updt_cnt,
    reply->qual[d.seq].qual2[d_pe.seq].sub_reason_cd = 0.0, reply->qual[d.seq].qual2[d_pe.seq].
    sub_orig_intl_units = rec.orig_intl_units, reply->qual[d.seq].qual2[d_pe.seq].sub_cur_intl_units
     = rec.orig_intl_units,
    reply->qual[d.seq].qual2[d_pe.seq].sub_location_cd = 0.0
   ELSEIF (tablefrom="quar")
    reply->qual[d.seq].qual2[d_pe.seq].sub_cur_qty = quar.cur_quar_qty, reply->qual[d.seq].qual2[d_pe
    .seq].sub_orig_qty = quar.orig_quar_qty, reply->qual[d.seq].qual2[d_pe.seq].sub_updt_cnt = quar
    .updt_cnt,
    reply->qual[d.seq].qual2[d_pe.seq].sub_reason_cd = quar.quar_reason_cd, reply->qual[d.seq].qual2[
    d_pe.seq].sub_orig_intl_units = quar.orig_quar_intl_units, reply->qual[d.seq].qual2[d_pe.seq].
    sub_cur_intl_units = quar.cur_quar_intl_units
   ELSEIF (tablefrom="modf")
    reply->qual[d.seq].qual2[d_pe.seq].sub_cur_qty = modf.modified_qty, reply->qual[d.seq].qual2[d_pe
    .seq].sub_orig_qty = modf.modified_qty, reply->qual[d.seq].qual2[d_pe.seq].sub_updt_cnt = modf
    .updt_cnt,
    reply->qual[d.seq].qual2[d_pe.seq].sub_reason_cd = 0.0, reply->qual[d.seq].qual2[d_pe.seq].
    sub_orig_intl_units = 0, reply->qual[d.seq].qual2[d_pe.seq].sub_cur_intl_units = 0
   ELSEIF (tablefrom="disp")
    reply->qual[d.seq].qual2[d_pe.seq].sub_cur_qty = disp.disposed_qty, reply->qual[d.seq].qual2[d_pe
    .seq].sub_orig_qty = disp.disposed_qty, reply->qual[d.seq].qual2[d_pe.seq].sub_updt_cnt = disp
    .updt_cnt,
    reply->qual[d.seq].qual2[d_pe.seq].sub_reason_cd = disp.reason_cd, reply->qual[d.seq].qual2[d_pe
    .seq].sub_orig_intl_units = disp.disposed_intl_units, reply->qual[d.seq].qual2[d_pe.seq].
    sub_cur_intl_units = disp.disposed_intl_units
   ELSEIF (tablefrom="dest")
    reply->qual[d.seq].qual2[d_pe.seq].sub_cur_qty = dest.destroyed_qty, reply->qual[d.seq].qual2[
    d_pe.seq].sub_orig_qty = dest.destroyed_qty, reply->qual[d.seq].qual2[d_pe.seq].sub_updt_cnt =
    dest.updt_cnt,
    reply->qual[d.seq].qual2[d_pe.seq].sub_reason_cd = 0.0, reply->qual[d.seq].qual2[d_pe.seq].
    sub_orig_intl_units = 0, reply->qual[d.seq].qual2[d_pe.seq].sub_cur_intl_units = 0
   ELSEIF (tablefrom="ad")
    reply->qual[d.seq].qual2[d_pe.seq].sub_cur_qty = 0, reply->qual[d.seq].qual2[d_pe.seq].
    sub_orig_qty = 0, reply->qual[d.seq].qual2[d_pe.seq].sub_updt_cnt = ad.updt_cnt,
    reply->qual[d.seq].qual2[d_pe.seq].sub_reason_cd = 0.0, reply->qual[d.seq].qual2[d_pe.seq].
    sub_orig_intl_units = 0, reply->qual[d.seq].qual2[d_pe.seq].sub_cur_intl_units = 0,
    reply->qual[d.seq].qual2[d_pe.seq].expected_usage_dt_tm = ad.expected_usage_dt_tm, reply->qual[d
    .seq].qual2[d_pe.seq].donated_by_relative_ind = ad.donated_by_relative_ind
   ELSEIF (tablefrom="ass")
    reply->qual[d.seq].qual2[d_pe.seq].sub_cur_qty = ass.cur_assign_qty, reply->qual[d.seq].qual2[
    d_pe.seq].sub_orig_qty = ass.orig_assign_qty, reply->qual[d.seq].qual2[d_pe.seq].sub_updt_cnt =
    ass.updt_cnt,
    reply->qual[d.seq].qual2[d_pe.seq].sub_reason_cd = ass.assign_reason_cd, reply->qual[d.seq].
    qual2[d_pe.seq].sub_orig_intl_units = ass.orig_assign_intl_units, reply->qual[d.seq].qual2[d_pe
    .seq].sub_cur_intl_units = ass.cur_assign_intl_units
   ELSEIF (tablefrom="xm")
    reply->qual[d.seq].qual2[d_pe.seq].sub_cur_qty = xm.crossmatch_qty, reply->qual[d.seq].qual2[d_pe
    .seq].sub_orig_qty = 0, reply->qual[d.seq].qual2[d_pe.seq].sub_updt_cnt = xm.updt_cnt,
    reply->qual[d.seq].qual2[d_pe.seq].sub_reason_cd = xm.xm_reason_cd, reply->qual[d.seq].qual2[d_pe
    .seq].sub_orig_intl_units = 0, reply->qual[d.seq].qual2[d_pe.seq].sub_cur_intl_units = 0
   ELSEIF (tablefrom="pd")
    reply->qual[d.seq].qual2[d_pe.seq].sub_cur_qty = pd.cur_dispense_qty, reply->qual[d.seq].qual2[
    d_pe.seq].sub_orig_qty = pd.orig_dispense_qty, reply->qual[d.seq].qual2[d_pe.seq].sub_updt_cnt =
    pd.updt_cnt,
    reply->qual[d.seq].qual2[d_pe.seq].sub_reason_cd = pd.dispense_reason_cd, reply->qual[d.seq].
    qual2[d_pe.seq].sub_orig_intl_units = pd.orig_dispense_intl_units, reply->qual[d.seq].qual2[d_pe
    .seq].sub_cur_intl_units = pd.cur_dispense_intl_units
   ELSEIF (tablefrom="trns")
    reply->qual[d.seq].qual2[d_pe.seq].sub_cur_qty = trns.transfer_qty, reply->qual[d.seq].qual2[d_pe
    .seq].sub_orig_qty = trns.transfer_qty, reply->qual[d.seq].qual2[d_pe.seq].sub_updt_cnt = trns
    .updt_cnt,
    reply->qual[d.seq].qual2[d_pe.seq].sub_reason_cd = trns.transfer_reason_cd, reply->qual[d.seq].
    qual2[d_pe.seq].sub_orig_intl_units = 0, reply->qual[d.seq].qual2[d_pe.seq].sub_cur_intl_units =
    0
   ELSEIF (tablefrom="tran")
    reply->qual[d.seq].qual2[d_pe.seq].sub_cur_qty = tran.cur_transfused_qty, reply->qual[d.seq].
    qual2[d_pe.seq].sub_orig_qty = tran.orig_transfused_qty, reply->qual[d.seq].qual2[d_pe.seq].
    sub_updt_cnt = tran.updt_cnt,
    reply->qual[d.seq].qual2[d_pe.seq].sub_reason_cd = 0.0, reply->qual[d.seq].qual2[d_pe.seq].
    sub_orig_intl_units = tran.transfused_intl_units, reply->qual[d.seq].qual2[d_pe.seq].
    sub_cur_intl_units = tran.transfused_intl_units
   ENDIF
  WITH nocounter
 ;end select
#end_script
 IF (prod_cnt=0)
  SET reply->status_data.status = "Z"
 ELSEIF ((reply->qual[1].product_id < 1))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
