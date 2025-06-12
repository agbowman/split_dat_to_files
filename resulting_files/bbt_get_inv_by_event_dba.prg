CREATE PROGRAM bbt_get_inv_by_event:dba
 RECORD reply(
   1 more_records = vc
   1 product_id = f8
   1 qual[*]
     2 product_id = f8
     2 product_number = vc
     2 product_sub = vc
     2 abo_cd = f8
     2 abo_cd_disp = c40
     2 rh_cd = f8
     2 rh_cd_disp = c40
     2 product_cd = f8
     2 product_cd_disp = c40
     2 states[*]
       3 states_cd = f8
       3 states_cd_disp = c40
     2 exp_dt_tm = di8
     2 unit_of_meas_cd = f8
     2 unit_of_meas_cd_disp = c40
     2 volume_display = i4
     2 antigens[*]
       3 antigen_cd = f8
       3 antigen_cd_disp = c40
     2 comment_ind = i4
     2 location_cd = f8
     2 location_disp = vc
     2 cur_owner_area_cd = f8
     2 cur_owner_area_disp = c40
     2 cur_inv_area_cd = f8
     2 cur_inv_area_disp = c40
     2 alt_id_display = vc
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 cross_reference = c40
     2 upload_dt_tm = dq8
     2 electronic_entry_flag = i2
     2 cur_dispense_device_disp = vc
     2 deriv_cur_avail_qty = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET product_count = 0
 SET antigen_count = 0
 SET states_count = 0
 SET derivative_flag = fillstring(1," ")
 SET cnvt_days_to_expire = 0
 SET product_count = 0
 SET cnvt_days_to_expire = (curdate+ request->days_to_expire)
 SET dummydata = 0
 CALL get_products(dummydata)
 IF (product_count > 0)
  CALL get_events_notes_spectest(dummydata)
 ENDIF
 GO TO end_script
 SUBROUTINE get_products(nodata)
   SELECT INTO "nl:"
    p.product_id
    FROM product p,
     product_event pe,
     (dummyt d_pe  WITH seq = value(request->states_count)),
     (dummyt d_bp_d  WITH seq = 1),
     blood_product bp,
     derivative d,
     bb_inv_device bbid
    PLAN (p
     WHERE p.product_id != null
      AND p.product_id > 0
      AND p.cur_expire_dt_tm < cnvtdatetime(cnvt_days_to_expire,curtime3)
      AND p.active_ind=1
      AND (((request->product_cd > 0.0)
      AND (p.product_cat_cd=request->product_cd)) OR ((request->product_cd=0.0)))
      AND (((request->location_cd > 0)
      AND (p.cur_inv_locn_cd=request->location_cd)) OR ((request->location_cd=0.0)))
      AND (((request->cur_owner_area_cd > 0.0)
      AND (p.cur_owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
      AND (((request->cur_inv_area_cd > 0.0)
      AND (p.cur_inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
      AND (((request->cur_inv_device_id > 0.0)
      AND (p.cur_dispense_device_id=request->cur_inv_device_id)) OR ((request->cur_inv_device_id=0.0)
     ))
      AND (((request->electronic_entry_only_ind != 0)
      AND p.electronic_entry_flag != 0) OR ((request->electronic_entry_only_ind=0))) )
     JOIN (d_pe)
     JOIN (pe
     WHERE pe.product_id=p.product_id
      AND (pe.event_type_cd=request->states_data[d_pe.seq].states_cd)
      AND pe.active_ind=1)
     JOIN (bbid
     WHERE bbid.bb_inv_device_id=outerjoin(p.cur_dispense_device_id))
     JOIN (d_bp_d
     WHERE d_bp_d.seq=1)
     JOIN (((bp
     WHERE bp.product_id=p.product_id
      AND (((request->abo_cd > 0.0)
      AND (bp.cur_abo_cd=request->abo_cd)) OR ((request->abo_cd=0.0)))
      AND (((request->rh_cd > 0.0)
      AND (bp.cur_rh_cd=request->rh_cd)) OR ((request->rh_cd=0.0))) )
     ) ORJOIN ((d
     WHERE d.product_id=p.product_id)
     ))
    ORDER BY p.product_id
    HEAD REPORT
     product_count = 0, stat = alterlist(reply->qual,100)
    HEAD p.product_id
     product_count = (product_count+ 1)
     IF (mod(product_count,100)=1
      AND product_count != 1)
      stat = alterlist(reply->qual,(product_count+ 99))
     ENDIF
     reply->qual[product_count].product_id = p.product_id, reply->qual[product_count].product_cd = p
     .product_cd, reply->qual[product_count].product_sub = p.product_sub_nbr
     IF (bp.seq != null
      AND bp.seq > 0)
      reply->qual[product_count].product_number = concat(trim(bp.supplier_prefix),trim(p.product_nbr)
       ), reply->qual[product_count].abo_cd = bp.cur_abo_cd, reply->qual[product_count].rh_cd = bp
      .cur_rh_cd,
      reply->qual[product_count].volume_display = bp.cur_volume, reply->qual[product_count].
      deriv_cur_avail_qty = - (1)
     ELSE
      reply->qual[product_count].product_number = p.product_nbr, reply->qual[product_count].abo_cd =
      0.0, reply->qual[product_count].rh_cd = 0.0,
      reply->qual[product_count].volume_display = d.item_volume, reply->qual[product_count].
      deriv_cur_avail_qty = d.cur_avail_qty
     ENDIF
     reply->qual[product_count].exp_dt_tm = p.cur_expire_dt_tm, reply->qual[product_count].
     unit_of_meas_cd = p.cur_unit_meas_cd, reply->qual[product_count].location_cd = p.cur_inv_locn_cd,
     reply->qual[product_count].cur_owner_area_cd = p.cur_owner_area_cd, reply->qual[product_count].
     cur_inv_area_cd = p.cur_inv_area_cd, reply->qual[product_count].alt_id_display = p.alternate_nbr,
     reply->qual[product_count].comment_ind = 0, reply->qual[product_count].electronic_entry_flag = p
     .electronic_entry_flag, reply->qual[product_count].cur_dispense_device_disp = bbid.description
    FOOT REPORT
     stat = alterlist(reply->qual,product_count)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_events_notes_spectest(nodata)
   SELECT INTO "nl:"
    st.product_id, st.special_testing_cd
    FROM (dummyt d  WITH seq = value(product_count)),
     special_testing st
    PLAN (d)
     JOIN (st
     WHERE (st.product_id=reply->qual[d.seq].product_id)
      AND st.active_ind=1)
    ORDER BY st.product_id
    HEAD st.product_id
     antigen_count = 0
    DETAIL
     antigen_count = (antigen_count+ 1), stat = alterlist(reply->qual[d.seq].antigens,antigen_count),
     reply->qual[d.seq].antigens[antigen_count].antigen_cd = st.special_testing_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    pe.product_id, pe.event_type_cd
    FROM (dummyt d  WITH seq = value(product_count)),
     code_value cv,
     product_event pe
    PLAN (d)
     JOIN (cv
     WHERE cv.code_set=1610
      AND cv.cdf_meaning != "8"
      AND cv.cdf_meaning != "6"
      AND cv.cdf_meaning != "13"
      AND cv.cdf_meaning != "17"
      AND cv.cdf_meaning != "18"
      AND cv.active_ind=1)
     JOIN (pe
     WHERE pe.event_type_cd=cv.code_value
      AND (pe.product_id=reply->qual[d.seq].product_id)
      AND pe.active_ind=1)
    ORDER BY pe.product_id, cv.collation_seq, pe.event_type_cd,
     pe.product_event_id
    HEAD pe.product_id
     states_count = 0, stat = alterlist(reply->qual[d.seq].states,3)
    HEAD pe.event_type_cd
     states_count = (states_count+ 1)
     IF (mod(states_count,3)=1
      AND states_count != 1)
      stat = alterlist(reply->qual[d.seq].states,(states_count+ 2))
     ENDIF
     reply->qual[d.seq].states[states_count].states_cd = pe.event_type_cd
    FOOT  pe.product_id
     stat = alterlist(reply->qual[d.seq].states,states_count)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    pn.product_id, pn.active_ind
    FROM (dummyt d  WITH seq = value(product_count)),
     product_note pn
    PLAN (d)
     JOIN (pn
     WHERE (pn.product_id=reply->qual[d.seq].product_id)
      AND pn.active_ind=1)
    ORDER BY pn.product_id
    DETAIL
     reply->qual[d.seq].comment_ind = 1
    WITH nocounter
   ;end select
 END ;Subroutine
#end_script
END GO
