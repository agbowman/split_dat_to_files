CREATE PROGRAM bbt_get_product_history:dba
 RECORD reply(
   1 prodqual[*]
     2 product_id = f8
     2 product_nbr = c20
     2 product_sub_nbr = c5
     2 alternate_nbr = c20
     2 product_cd = f8
     2 product_disp = c40
     2 cur_expire_dt_tm = dq8
     2 cur_supplier_id = f8
     2 cur_supplier_name = c50
     2 derivative_ind = i2
     2 cur_abo_cd = f8
     2 cur_abo_disp = c40
     2 cur_rh_cd = f8
     2 cur_rh_disp = c40
     2 cur_avail_qty = i4
     2 cur_intl_units = i4
     2 cur_owner_area_cd = f8
     2 cur_inventory_area_cd = f8
     2 eventqual[*]
       3 release_ind = i2
       3 product_event_id = f8
       3 event_dt_tm = dq8
       3 event_type_cd = f8
       3 event_type_disp = c40
       3 event_type_mean = c12
       3 reason_cd = f8
       3 reason_disp = c40
       3 event_prsnl_id = f8
       3 event_prsnl_username = c10
       3 event_prsnl_name = c50
       3 person_id = f8
       3 name_full_formatted = c50
       3 encntr_id = f8
       3 mrn_alias = c20
       3 order_id = f8
       3 accession = c21
       3 active_ind = i2
       3 orig_qty = i4
       3 cur_qty = i4
       3 orig_intl_units = i4
       3 cur_intl_units = i4
       3 dispense_courier = c100
       3 return_courier = c100
       3 expected_usage_dt_tm = dq8
       3 donated_by_relative_ind = i2
       3 return_temperature = f8
       3 return_temperature_txt = c15
       3 return_temperature_degree_cd = f8
       3 return_temperature_degree_disp = c40
       3 return_temperature_degree_mean = c12
       3 device_disp = c40
       3 device_id = f8
       3 location_disp = c40
       3 location_cd = f8
       3 backdated_on_dt_tm = dq8
       3 visual_insp_disp = vc
       3 bb_id_nbr = vc
       3 order_disp = vc
       3 ordering_physician_disp = vc
       3 shipment_temp_val = f8
       3 shipment_temp_unit_cd = vc
       3 tag_verify_flag = i2
       3 tag_verify_override_reason_disp = vc
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 upload_dt_tm = dq8
     2 cross_reference = c40
     2 historical_ind = i2
     2 supplier_prefix = c5
     2 serial_number_txt = c22
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD internal(
   1 null_dt_tm = dq8
 )
 SET alias_type_code_set = 319
 SET mrn_alias_cdf_meaning = "MRN"
 SET gsub_dummy = ""
 SET mrn_alias_type_cd = 0.0
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET prod_cnt = 0
 SET qual_cnt = 0
 SET prod_cnt = 0
 SET event_cnt = 0
 SET null_dt_tm = cnvtdatetime("")
 DECLARE scdf_blood = c12 WITH constant("BLOOD")
 DECLARE nbbhist_event_cnt = i4 WITH noconstant(0)
 SET exception_c40 = fillstring(40," ")
 DECLARE assigned_cdf_meaning = c12
 DECLARE quarantined_cdf_meaning = c12
 DECLARE crossmatched_cdf_meaning = c12
 DECLARE issued_cdf_meaning = c12
 DECLARE disposed_cdf_meaning = c12
 DECLARE transferred_cdf_meaning = c12
 DECLARE transfused_cdf_meaning = c12
 DECLARE modified_cdf_meaning = c12
 DECLARE unconfirmed_cdf_meaning = c12
 DECLARE autologous_cdf_meaning = c12
 DECLARE directed_cdf_meaning = c12
 DECLARE available_cdf_meaning = c12
 DECLARE received_cdf_meaning = c12
 DECLARE destroyed_cdf_meaning = c12
 DECLARE shipped_cdf_meaning = c12
 DECLARE in_progress_cdf_meaning = c12
 DECLARE pooled_cdf_meaning = c12
 DECLARE pooled_product_cdf_meaning = c12
 DECLARE confirmed_cdf_meaning = c12
 DECLARE drawn_cdf_meaning = c12
 DECLARE tested_cdf_meaning = c12
 DECLARE intransit_cdf_meaning = c12
 DECLARE transferred_from_cdf_meaning = c12
 SET product_state_code_set = 1610
 SET product_state_expected_cnt = 19
 SET assigned_cdf_meaning = "1"
 SET quarantined_cdf_meaning = "2"
 SET crossmatched_cdf_meaning = "3"
 SET issued_cdf_meaning = "4"
 SET disposed_cdf_meaning = "5"
 SET transferred_cdf_meaning = "6"
 SET transfused_cdf_meaning = "7"
 SET modified_cdf_meaning = "8"
 SET unconfirmed_cdf_meaning = "9"
 SET autologous_cdf_meaning = "10"
 SET directed_cdf_meaning = "11"
 SET available_cdf_meaning = "12"
 SET received_cdf_meaning = "13"
 SET destroyed_cdf_meaning = "14"
 SET shipped_cdf_meaning = "15"
 SET in_progress_cdf_meaning = "16"
 SET pooled_cdf_meaning = "17"
 SET pooled_product_cdf_meaning = "18"
 SET confirmed_cdf_meaning = "19"
 SET drawn_cdf_meaning = "20"
 SET tested_cdf_meaning = "21"
 SET intransit_cdf_meaning = "25"
 SET modified_product_cdf_meaning = "24"
 SET transferred_from_cdf_meaning = "26"
 SET assigned_event_type_cd = 0.0
 SET quarantined_event_type_cd = 0.0
 SET crossmatched_event_type_cd = 0.0
 SET issued_event_type_cd = 0.0
 SET disposed_event_type_cd = 0.0
 SET transferred_event_type_cd = 0.0
 SET transfused_event_type_cd = 0.0
 SET modified_event_type_cd = 0.0
 SET unconfirmed_event_type_cd = 0.0
 SET autologous_event_type_cd = 0.0
 SET directed_event_type_cd = 0.0
 SET available_event_type_cd = 0.0
 SET received_event_type_cd = 0.0
 SET destroyed_event_type_cd = 0.0
 SET shipped_event_type_cd = 0.0
 SET in_progress_event_type_cd = 0.0
 SET pooled_event_type_cd = 0.0
 SET pooled_product_event_type_cd = 0.0
 SET confirmed_event_type_cd = 0.0
 SET drawn_event_type_cd = 0.0
 SET tested_event_type_cd = 0.0
 SET in_transit_event_type_cd = 0.0
 SET modified_product_event_type_cd = 0.0
 SET transferred_from_event_type_cd = 0.0
 SET get_event_type_cds_status = " "
 SET get_event_type_cds_status = get_event_type_cds(gsub_dummy)
 IF (((get_event_type_cds_status="F") OR (0.0 IN (available_event_type_cd, received_event_type_cd,
 transferred_event_type_cd, transferred_from_event_type_cd, issued_event_type_cd,
 shipped_event_type_cd, in_transit_event_type_cd))) )
  SET reply->status_data.status = "F"
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get event_type code_values"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  IF (get_event_type_cds_status="F")
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not et event_type code_values, select failed"
  ELSEIF (available_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get available event_type_cd"
  ELSEIF (received_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get received event_type_cd"
  ELSEIF (transferred_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get transferred event_type_cd"
  ELSEIF (transferred_from_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get transferred from event_type_cd"
  ELSEIF (issued_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get dispensed from event_type_cd"
  ELSEIF (shipped_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get shipped from event_type_cd"
  ELSEIF (in_transit_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get in-transit from event_type_cd"
  ENDIF
  GO TO exit_script
 ENDIF
 SET mrn_alias_type_cd = get_code_value(alias_type_code_set,mrn_alias_cdf_meaning)
 IF (mrn_alias_type_cd <= 0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get mrn_alias_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_product_history"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get mrn alias type code_value"
  GO TO exit_script
 ENDIF
 DECLARE tagmismatch_var = f8 WITH constant(uar_get_code_by("MEANING",14072,"TAGMISMATCH")), protect
 RECORD prodlist(
   1 qual[*]
     2 pid = f8
     2 orig_pid = f8
 )
 SET stat = alterlist(prodlist->qual,1)
 RECORD tmpprodlist(
   1 qual[*]
     2 pid = f8
     2 orig_pid = f8
 )
 SET stat = alterlist(tmpprodlist->qual,1)
 DECLARE num = i4 WITH noconstant(0)
 SET num = 1
 DECLARE find_val = i4 WITH noconstant(0)
 DECLARE temp_rec_cnt = i4 WITH noconstant(0)
 DECLARE prod_rec_cnt = i4 WITH noconstant(0)
 DECLARE transferredderivatives(null) = null
 DECLARE transferredfromderivatives(null) = null
 IF (validate(transferred_from_only,0)=0)
  SET prodlist->qual[1].pid = request->product_id
  SET tmpprodlist->qual[1].pid = request->product_id
  CALL transferredderivatives(0)
 ENDIF
 SUBROUTINE transferredderivatives(null)
  SELECT INTO "nl:"
   pe2.product_id, pe3.product_id
   FROM product_event pe1,
    product_event pe2,
    product_event pe3,
    dummyt d1,
    derivative der
   PLAN (pe1
    WHERE expand(num,1,size(tmpprodlist->qual,5),pe1.product_id,tmpprodlist->qual[num].pid)
     AND pe1.event_type_cd IN (transferred_event_type_cd, transferred_from_event_type_cd))
    JOIN (der
    WHERE der.product_id=pe1.product_id)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (((pe2
    WHERE pe1.related_product_event_id=pe2.product_event_id
     AND pe2.product_event_id > 0)
    ) ORJOIN ((pe3
    WHERE pe3.related_product_event_id=pe1.product_event_id
     AND pe3.product_event_id > 0)
    ))
   HEAD REPORT
    stat = initrec(tmpprodlist), temp_rec_cnt = 0, prod_rec_cnt = size(prodlist->qual,5)
   DETAIL
    find_val = locateval(num,1,size(prodlist->qual,5),pe2.product_id,prodlist->qual[num].pid)
    IF (find_val=0
     AND pe2.product_id > 0)
     temp_rec_cnt += 1
     IF (temp_rec_cnt > size(tmpprodlist->qual,5))
      stat = alterlist(tmpprodlist->qual,(temp_rec_cnt+ 10))
     ENDIF
     tmpprodlist->qual[temp_rec_cnt].pid = pe2.product_id, prod_rec_cnt += 1
     IF (prod_rec_cnt > size(prodlist->qual,5))
      stat = alterlist(prodlist->qual,(prod_rec_cnt+ 10))
     ENDIF
     prodlist->qual[prod_rec_cnt].pid = pe2.product_id
    ENDIF
    find_val = locateval(num,1,size(prodlist->qual,5),pe3.product_id,prodlist->qual[num].pid)
    IF (find_val=0
     AND pe3.product_id > 0)
     temp_rec_cnt += 1
     IF (temp_rec_cnt > size(tmpprodlist->qual,5))
      stat = alterlist(tmpprodlist->qual,(temp_rec_cnt+ 10))
     ENDIF
     tmpprodlist->qual[temp_rec_cnt].pid = pe3.product_id, prod_rec_cnt += 1
     IF (prod_rec_cnt > size(prodlist->qual,5))
      stat = alterlist(prodlist->qual,(prod_rec_cnt+ 10))
     ENDIF
     prodlist->qual[prod_rec_cnt].pid = pe3.product_id
    ENDIF
   FOOT REPORT
    stat = alterlist(prodlist->qual,prod_rec_cnt), stat = alterlist(tmpprodlist->qual,temp_rec_cnt)
   WITH nocounter
  ;end select
  IF (temp_rec_cnt > 0)
   SET temp_rec_cnt = 0
   CALL transferredderivatives(null)
  ENDIF
 END ;Subroutine
 SUBROUTINE transferredfromderivatives(null)
   DELETE  FROM shared_list_gttd
    WHERE 1=1
   ;end delete
   INSERT  FROM shared_list_gttd slg,
     (dummyt d  WITH seq = value(size(tmpprodlist->qual,5)))
    SET slg.source_entity_id = tmpprodlist->qual[d.seq].pid, slg.source_entity_seq = tmpprodlist->
     qual[d.seq].orig_pid
    PLAN (d)
     JOIN (slg)
    WITH nocounter
   ;end insert
   IF (validate(debugind,0)=1)
    CALL echo("Starting transferredFromDerivatives")
    CALL echorecord(tmpprodlist)
   ENDIF
   SET temp_rec_cnt = 0
   SELECT INTO "nl:"
    pe2.product_id
    FROM product_event pe1,
     product_event pe2,
     derivative der,
     shared_list_gttd t
    PLAN (t
     WHERE t.source_entity_id > 0.0)
     JOIN (pe1
     WHERE t.source_entity_id=pe1.product_id
      AND pe1.event_type_cd=transferred_from_event_type_cd)
     JOIN (der
     WHERE der.product_id=pe1.product_id)
     JOIN (pe2
     WHERE (pe2.related_product_event_id= Outerjoin(pe1.product_event_id))
      AND (pe2.product_event_id> Outerjoin(0)) )
    HEAD REPORT
     stat = initrec(tmpprodlist), temp_rec_cnt = 0, prod_rec_cnt = size(prodlist->qual,5)
    DETAIL
     IF (pe2.product_id > 0
      AND t.source_entity_seq != pe2.product_id)
      find_val = locateval(num,1,prod_rec_cnt,pe2.product_id,prodlist->qual[num].pid,
       t.source_entity_seq,prodlist->qual[num].orig_pid)
      IF (find_val=0)
       temp_rec_cnt += 1
       IF (temp_rec_cnt > size(tmpprodlist->qual,5))
        stat = alterlist(tmpprodlist->qual,(temp_rec_cnt+ 10))
       ENDIF
       tmpprodlist->qual[temp_rec_cnt].pid = pe2.product_id, tmpprodlist->qual[temp_rec_cnt].orig_pid
        = t.source_entity_seq, find_val = locateval(num,1,prod_rec_cnt,prodlist->qual[num].orig_pid,
        prodlist->qual[num].pid,
        t.source_entity_seq,prodlist->qual[num].orig_pid)
       IF (find_val > 0)
        prodlist->qual[find_val].pid = pe2.product_id
       ELSE
        prod_rec_cnt += 1
        IF (prod_rec_cnt > size(prodlist->qual,5))
         stat = alterlist(prodlist->qual,(prod_rec_cnt+ 10))
        ENDIF
        prodlist->qual[prod_rec_cnt].pid = pe2.product_id, prodlist->qual[prod_rec_cnt].orig_pid =
        tmpprodlist->qual[temp_rec_cnt].orig_pid
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(prodlist->qual,prod_rec_cnt), stat = alterlist(tmpprodlist->qual,temp_rec_cnt)
    WITH nocounter
   ;end select
   IF (validate(debugind,0)=1)
    CALL echorecord(prodlist)
    CALL echorecord(tmpprodlist)
    CALL echo(build("prod_rec_cnt:",prod_rec_cnt))
    CALL echo(build("temp_rec_cnt:",temp_rec_cnt))
    CALL echo("Ending transferredFromDerivatives")
   ENDIF
   IF (temp_rec_cnt > 0)
    SET temp_rec_cnt = 0
    DELETE  FROM shared_list_gttd
     WHERE 1=1
    ;end delete
    CALL transferredfromderivatives(null)
   ENDIF
 END ;Subroutine
 SET stat = initrec(tmpprodlist)
 SELECT INTO "nl:"
  table_ind = decode(xm.seq,"15xm ",tfn.seq,"13tfn  ",qu.seq,
   "12qu   ",pd.seq,"11pd   ",dsp.seq,"10dsp  ",
   dst.seq,"09dst  ",a.seq,"08a    ",r.seq,
   "07r    ",org.seq,"02org  ",drv.seq,"01drv  ",
   bp.seq,"00bp   ",bbit.seq,"06BIT",bbdt.seq,
   "06BDT","xxxxx"), p.product_id, p.product_cd,
  p.product_nbr, p.serial_number_txt, p.product_sub_nbr,
  p.cur_supplier_id, p.cur_expire_dt_tm, org.org_name,
  bp.cur_abo_cd, bp.cur_rh_cd, drv.cur_avail_qty,
  drv.cur_intl_units, pe.seq, pe.active_ind,
  pe.product_event_id, pe.event_dt_tm, pe.event_type_cd,
  pe.event_prsnl_id, pe.person_id, orig_qty = decode(tfn.seq,tfn.orig_transfused_qty,qu.seq,qu
   .orig_quar_qty,pd.seq,
   pd.orig_dispense_qty,dsp.seq,dsp.disposed_qty,dst.seq,dst.destroyed_qty,
   a.seq,a.orig_assign_qty,r.seq,r.orig_rcvd_qty,bbit.seq,
   bbit.transferred_qty,0),
  orig_intl_units = decode(tfn.seq,tfn.transfused_intl_units,qu.seq,qu.orig_quar_intl_units,pd.seq,
   pd.orig_dispense_intl_units,dsp.seq,dsp.disposed_intl_units,a.seq,a.orig_assign_intl_units,
   r.seq,r.orig_intl_units,bbit.seq,bbit.transferred_intl_unit,0), cur_qty = decode(tfn.seq,tfn
   .cur_transfused_qty,qu.seq,qu.cur_quar_qty,pd.seq,
   pd.cur_dispense_qty,dsp.seq,dsp.disposed_qty,dst.seq,dst.destroyed_qty,
   a.seq,a.cur_assign_qty,0), cur_intl_units = decode(tfn.seq,tfn.transfused_intl_units,qu.seq,qu
   .cur_quar_intl_units,pd.seq,
   pd.cur_dispense_intl_units,dsp.seq,dsp.disposed_intl_units,a.seq,a.cur_assign_intl_units,
   0),
  reason_cd = decode(xm.seq,xm.xm_reason_cd,qu.seq,qu.quar_reason_cd,pd.seq,
   pd.dispense_reason_cd,dsp.seq,dsp.reason_cd,a.seq,a.assign_reason_cd,
   bbit.seq,bbit.transfer_reason_cd,bbdt.seq,bbdt.reason_cd,0.0), release_ind = decode(ar.seq,"ar",dr
   .seq,"dr",qr.seq,
   "qr",xm.seq,"xm","xx"), release_dt_tm = decode(ar.seq,ar.release_dt_tm,dr.seq,dr.return_dt_tm,qr
   .seq,
   qr.release_dt_tm,xm.seq,xm.release_dt_tm,internal->null_dt_tm),
  release_qty = decode(ar.seq,ar.release_qty,dr.seq,dr.return_qty,qr.seq,
   qr.release_qty,0), release_intl_units = decode(ar.seq,ar.release_intl_units,dr.seq,dr
   .return_intl_units,qr.seq,
   qr.release_intl_units,0), release_prsnl_id = decode(ar.seq,ar.release_prsnl_id,dr.seq,dr
   .return_prsnl_id,qr.seq,
   qr.release_prsnl_id,xm.seq,xm.release_prsnl_id,0.0),
  release_reason_cd = decode(ar.seq,ar.release_reason_cd,dr.seq,dr.return_reason_cd,qr.seq,
   qr.release_reason_cd,xm.seq,xm.release_reason_cd,0.0), unknown_patient_text = decode(pd.seq,concat
   ("Emer Disp: ",pd.unknown_patient_text),fillstring(50," ")), reinstate_cd = decode(xm.seq,xm
   .reinstate_reason_cd,0.0),
  method_cd = decode(dst.seq,dst.method_cd,0.0), to_device_name = decode(bid_to.seq,bid_to
   .description,exception_c40), from_device_name = decode(bid_from.seq,bid_from.description,
   exception_c40),
  dispense_device_name = decode(bid_disp.seq,bid_disp.description,exception_c40), transfer_mean =
  decode(bbdt.seq,trim(uar_get_code_meaning(bbdt.reason_cd)),pd.seq,"DISPENSE",""), location_cd =
  decode(bbit.seq,bbit.to_inv_area_cd,pd.seq,pd.dispense_to_locn_cd,r.seq,
   pe.inventory_area_cd,p.seq,pe.inventory_area_cd,0.0),
  transferred_from_location_cd = decode(bbit.seq,bbit.from_inv_area_cd,0.0), backdated_on_dt_tm =
  decode(pd.seq,pd.backdated_on_dt_tm,internal->null_dt_tm), bb_id_nbr = decode(a.seq,a.bb_id_nbr,pd
   .seq,pd.bb_id_nbr,xm.seq,
   xm.bb_id_nbr,""),
  vis_insp_cd = decode(r.seq,r.vis_insp_cd,pd.seq,pd.dispense_vis_insp_cd,bbse.seq,
   bbse.vis_insp_cd,0.0), disp_prov = decode(dph.seq,dph.name_full_formatted,""),
  override_reason_disp = uar_get_code_display(bbe.override_reason_cd)
  FROM product p,
   (dummyt d_p  WITH seq = 1),
   organization org,
   (dummyt d_pe  WITH seq = 1),
   product_event pe,
   (dummyt d_x  WITH seq = 1),
   blood_product bp,
   derivative drv,
   receipt r,
   assign a,
   (dummyt d_ar  WITH seq = 1),
   assign_release ar,
   destruction dst,
   disposition dsp,
   patient_dispense pd,
   (dummyt d_dr  WITH seq = 1),
   dispense_return dr,
   quarantine qu,
   (dummyt d_qr  WITH seq = 1),
   quarantine_release qr,
   transfusion tfn,
   crossmatch xm,
   prsnl pl,
   prsnl pl2,
   bb_inventory_transfer bbit,
   bb_device_transfer bbdt,
   auto_directed ad,
   bb_inv_device bid_to,
   bb_inv_device bid_from,
   bb_inv_device bid_disp,
   (dummyt d_ph  WITH seq = 1),
   bb_ship_event bbse,
   prsnl dph,
   bb_exception bbe,
   (dummyt d_bbe  WITH seq = 1)
  PLAN (p
   WHERE expand(prod_cnt,1,size(prodlist->qual,5),p.product_id,prodlist->qual[prod_cnt].pid))
   JOIN (d_p
   WHERE d_p.seq=1)
   JOIN (((bp
   WHERE bp.product_id=p.product_id)
   ) ORJOIN ((((drv
   WHERE drv.product_id=p.product_id)
   ) ORJOIN ((((org
   WHERE org.organization_id=p.cur_supplier_id)
   ) ORJOIN ((pe
   WHERE pe.product_id=p.product_id)
   JOIN (d_x
   WHERE d_x.seq=1)
   JOIN (((d_pe
   WHERE d_pe.seq=1)
   JOIN (r
   WHERE r.product_event_id=pe.product_event_id)
   ) ORJOIN ((((a
   WHERE a.product_event_id=pe.product_event_id)
   JOIN (d_ar
   WHERE d_ar.seq=1)
   JOIN (ar
   WHERE ar.product_event_id=a.product_event_id)
   ) ORJOIN ((((dsp
   WHERE dsp.product_event_id=pe.product_event_id)
   ) ORJOIN ((((dst
   WHERE dst.product_event_id=pe.product_event_id)
   ) ORJOIN ((((pd
   WHERE pd.product_event_id=pe.product_event_id)
   JOIN (d_ph
   WHERE d_ph.seq=1)
   JOIN (dph
   WHERE dph.person_id=pd.dispense_prov_id)
   JOIN (bid_disp
   WHERE bid_disp.bb_inv_device_id=pd.device_id)
   JOIN (pl
   WHERE pl.person_id=pd.dispense_courier_id)
   JOIN (d_dr
   WHERE d_dr.seq=1)
   JOIN (dr
   WHERE dr.product_event_id=pd.product_event_id)
   JOIN (pl2
   WHERE pl2.person_id=dr.return_courier_id)
   JOIN (d_bbe
   WHERE d_bbe.seq=1)
   JOIN (bbe
   WHERE bbe.product_event_id=pd.product_event_id
    AND bbe.exception_type_cd=tagmismatch_var)
   ) ORJOIN ((((qu
   WHERE qu.product_event_id=pe.product_event_id)
   JOIN (d_qr
   WHERE d_qr.seq=1)
   JOIN (qr
   WHERE qr.product_event_id=qu.product_event_id)
   ) ORJOIN ((((tfn
   WHERE tfn.product_event_id=pe.product_event_id)
   ) ORJOIN ((((xm
   WHERE xm.product_event_id=pe.product_event_id)
   ) ORJOIN ((((bbit
   WHERE ((bbit.product_event_id=pe.product_event_id) OR (pe.event_type_cd=
   transferred_from_event_type_cd
    AND bbit.to_product_event_id=pe.product_event_id)) )
   ) ORJOIN ((((bbdt
   WHERE bbdt.product_event_id=pe.product_event_id)
   JOIN (bid_to
   WHERE bid_to.bb_inv_device_id=bbdt.to_device_id)
   JOIN (bid_from
   WHERE bid_from.bb_inv_device_id=bbdt.from_device_id)
   ) ORJOIN ((((ad
   WHERE ad.product_event_id=pe.product_event_id)
   ) ORJOIN ((bbse
   WHERE bbse.product_event_id=pe.product_event_id
    AND pe.event_type_cd IN (shipped_event_type_cd, in_transit_event_type_cd))
   )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  ORDER BY p.product_id, pe.product_event_id, table_ind
  HEAD REPORT
   orig_rcvd_qty = 0, orig_rcvd_intl_units = 0, orig_avail_units = 0,
   orig_avail_qty = 0, prod_cnt = 0
  HEAD p.product_id
   prod_cnt += 1
   IF (prod_cnt > size(reply->prodqual,5))
    stat = alterlist(reply->prodqual,(prod_cnt+ 10))
   ENDIF
   reply->prodqual[prod_cnt].product_id = p.product_id, reply->prodqual[prod_cnt].product_nbr = p
   .product_nbr, reply->prodqual[prod_cnt].serial_number_txt = p.serial_number_txt,
   reply->prodqual[prod_cnt].product_sub_nbr = p.product_sub_nbr, reply->prodqual[prod_cnt].
   product_cd = p.product_cd, reply->prodqual[prod_cnt].cur_expire_dt_tm = cnvtdatetime(p
    .cur_expire_dt_tm),
   reply->prodqual[prod_cnt].historical_ind = 0, reply->prodqual[prod_cnt].alternate_nbr = p
   .alternate_nbr, reply->prodqual[prod_cnt].cur_owner_area_cd = p.cur_owner_area_cd,
   reply->prodqual[prod_cnt].cur_inventory_area_cd = p.cur_inv_area_cd, event_cnt = 0
  HEAD pe.product_event_id
   IF (pe.seq > 0)
    event_cnt += 1
    IF (event_cnt > size(reply->prodqual[prod_cnt].eventqual,5))
     stat = alterlist(reply->prodqual[prod_cnt].eventqual,(event_cnt+ 10))
    ENDIF
    reply->prodqual[prod_cnt].eventqual[event_cnt].release_ind = 0, reply->prodqual[prod_cnt].
    eventqual[event_cnt].product_event_id = pe.product_event_id, reply->prodqual[prod_cnt].eventqual[
    event_cnt].event_dt_tm = cnvtdatetime(pe.event_dt_tm),
    reply->prodqual[prod_cnt].eventqual[event_cnt].event_type_cd = pe.event_type_cd
    IF (reinstate_cd > 0.0)
     reply->prodqual[prod_cnt].eventqual[event_cnt].reason_cd = reinstate_cd
    ELSEIF (method_cd > 0.0)
     reply->prodqual[prod_cnt].eventqual[event_cnt].reason_cd = method_cd
    ELSE
     reply->prodqual[prod_cnt].eventqual[event_cnt].reason_cd = reason_cd
    ENDIF
    reply->prodqual[prod_cnt].eventqual[event_cnt].event_prsnl_id = pe.event_prsnl_id, reply->
    prodqual[prod_cnt].eventqual[event_cnt].person_id = pe.person_id, reply->prodqual[prod_cnt].
    eventqual[event_cnt].name_full_formatted = unknown_patient_text,
    reply->prodqual[prod_cnt].eventqual[event_cnt].encntr_id = pe.encntr_id, reply->prodqual[prod_cnt
    ].eventqual[event_cnt].order_id = pe.order_id, reply->prodqual[prod_cnt].eventqual[event_cnt].
    active_ind = pe.active_ind,
    reply->prodqual[prod_cnt].eventqual[event_cnt].orig_qty = orig_qty, reply->prodqual[prod_cnt].
    eventqual[event_cnt].cur_qty = cur_qty, reply->prodqual[prod_cnt].eventqual[event_cnt].
    orig_intl_units = orig_intl_units,
    reply->prodqual[prod_cnt].eventqual[event_cnt].cur_intl_units = cur_intl_units
    IF (pd.dispense_prov_id > 0)
     reply->prodqual[prod_cnt].eventqual[event_cnt].ordering_physician_disp = disp_prov
    ENDIF
    IF (pl.person_id > 0)
     reply->prodqual[prod_cnt].eventqual[event_cnt].dispense_courier = pl.name_full_formatted
    ELSE
     reply->prodqual[prod_cnt].eventqual[event_cnt].dispense_courier = pd.dispense_courier_text
    ENDIF
    IF (pl2.person_id > 0)
     reply->prodqual[prod_cnt].eventqual[event_cnt].return_courier = pl2.name_full_formatted
    ELSE
     reply->prodqual[prod_cnt].eventqual[event_cnt].return_courier = dr.return_courier_text
    ENDIF
    reply->prodqual[prod_cnt].eventqual[event_cnt].expected_usage_dt_tm = ad.expected_usage_dt_tm,
    reply->prodqual[prod_cnt].eventqual[event_cnt].donated_by_relative_ind = ad
    .donated_by_relative_ind, reply->prodqual[prod_cnt].eventqual[event_cnt].visual_insp_disp =
    uar_get_code_display(vis_insp_cd),
    reply->prodqual[prod_cnt].eventqual[event_cnt].bb_id_nbr = bb_id_nbr, reply->prodqual[prod_cnt].
    eventqual[event_cnt].tag_verify_flag = pd.tag_verify_flag, reply->prodqual[prod_cnt].eventqual[
    event_cnt].tag_verify_override_reason_disp = override_reason_disp
    IF (((transfer_mean="SYS_MOVEIN") OR (((transfer_mean="TRNSFRALLO") OR (((transfer_mean=
    "TRNSFRUNALLO") OR (transfer_mean="SYS_RTNSTOCK")) )) )) )
     reply->prodqual[prod_cnt].eventqual[event_cnt].device_disp = to_device_name
    ELSEIF (((transfer_mean="SYS_MOVEOUT") OR (((transfer_mean="SYS_TRANSOUT") OR (transfer_mean=
    "SYS_EMEROUT")) )) )
     reply->prodqual[prod_cnt].eventqual[event_cnt].device_disp = from_device_name
    ELSEIF (transfer_mean="DISPENSE")
     IF (pd.device_id > 0)
      reply->prodqual[prod_cnt].eventqual[event_cnt].device_disp = dispense_device_name
     ELSE
      reply->prodqual[prod_cnt].eventqual[event_cnt].device_disp = pd.dispense_cooler_text
     ENDIF
    ELSE
     reply->prodqual[prod_cnt].eventqual[event_cnt].device_disp = to_device_name
    ENDIF
    IF (location_cd <= 0
     AND pe.event_type_cd IN (modified_product_event_type_cd, pooled_product_event_type_cd))
     reply->prodqual[prod_cnt].eventqual[event_cnt].location_disp = uar_get_code_display(pe
      .inventory_area_cd)
    ELSEIF (pe.event_type_cd=transferred_from_event_type_cd)
     reply->prodqual[prod_cnt].eventqual[event_cnt].location_disp = uar_get_code_display(
      transferred_from_location_cd)
    ELSE
     reply->prodqual[prod_cnt].eventqual[event_cnt].location_disp = uar_get_code_display(location_cd)
    ENDIF
    reply->prodqual[prod_cnt].eventqual[event_cnt].backdated_on_dt_tm = backdated_on_dt_tm
    IF (r.product_event_id > 0)
     reply->prodqual[prod_cnt].eventqual[event_cnt].shipment_temp_val = r.temperature_value, reply->
     prodqual[prod_cnt].eventqual[event_cnt].shipment_temp_unit_cd = uar_get_code_display(r
      .temperature_degree_cd)
    ENDIF
   ENDIF
  HEAD table_ind
   IF (table_ind="00bp   ")
    reply->prodqual[prod_cnt].derivative_ind = 0, reply->prodqual[prod_cnt].cur_abo_cd = bp
    .cur_abo_cd, reply->prodqual[prod_cnt].cur_rh_cd = bp.cur_rh_cd,
    reply->prodqual[prod_cnt].supplier_prefix = bp.supplier_prefix
   ELSEIF (table_ind="01drv  ")
    cur_avail_qty = drv.cur_avail_qty, reply->prodqual[prod_cnt].derivative_ind = 1, reply->prodqual[
    prod_cnt].cur_avail_qty = drv.cur_avail_qty,
    reply->prodqual[prod_cnt].cur_intl_units = drv.cur_intl_units
   ELSEIF (table_ind="02org  ")
    reply->prodqual[prod_cnt].cur_supplier_id = p.cur_supplier_id, reply->prodqual[prod_cnt].
    cur_supplier_name = org.org_name
   ELSEIF (table_ind="07r    ")
    orig_rcvd_qty = r.orig_rcvd_qty, orig_rcvd_intl_units = r.orig_intl_units
   ENDIF
  DETAIL
   IF (pe.seq > 0
    AND ((release_ind="ar") OR (((release_ind="qr") OR (((release_ind="dr") OR (release_ind="xm"
    AND release_dt_tm != null)) )) )) )
    event_cnt += 1
    IF (event_cnt > size(reply->prodqual[prod_cnt].eventqual,5))
     stat = alterlist(reply->prodqual[prod_cnt].eventqual,(event_cnt+ 9))
    ENDIF
    reply->prodqual[prod_cnt].eventqual[event_cnt].release_ind = 1, reply->prodqual[prod_cnt].
    eventqual[event_cnt].product_event_id = pe.product_event_id, reply->prodqual[prod_cnt].eventqual[
    event_cnt].event_dt_tm = cnvtdatetime(release_dt_tm),
    reply->prodqual[prod_cnt].eventqual[event_cnt].event_type_cd = pe.event_type_cd, reply->prodqual[
    prod_cnt].eventqual[event_cnt].reason_cd = release_reason_cd, reply->prodqual[prod_cnt].
    eventqual[event_cnt].event_prsnl_id = release_prsnl_id,
    reply->prodqual[prod_cnt].eventqual[event_cnt].person_id = pe.person_id, reply->prodqual[prod_cnt
    ].eventqual[event_cnt].name_full_formatted = " ", reply->prodqual[prod_cnt].eventqual[event_cnt].
    encntr_id = pe.encntr_id,
    reply->prodqual[prod_cnt].eventqual[event_cnt].order_id = pe.order_id, reply->prodqual[prod_cnt].
    eventqual[event_cnt].active_ind = reqdata->inactive_status_cd, reply->prodqual[prod_cnt].
    eventqual[event_cnt].orig_qty = release_qty,
    reply->prodqual[prod_cnt].eventqual[event_cnt].cur_qty = 0, reply->prodqual[prod_cnt].eventqual[
    event_cnt].orig_intl_units = release_intl_units, reply->prodqual[prod_cnt].eventqual[event_cnt].
    cur_intl_units = 0,
    reply->prodqual[prod_cnt].eventqual[event_cnt].ordering_physician_disp = disp_prov
    IF (pl.person_id > 0)
     reply->prodqual[prod_cnt].eventqual[event_cnt].dispense_courier = pl.name_full_formatted
    ELSE
     reply->prodqual[prod_cnt].eventqual[event_cnt].dispense_courier = pd.dispense_courier_text
    ENDIF
    IF (pl2.person_id > 0)
     reply->prodqual[prod_cnt].eventqual[event_cnt].return_courier = pl2.name_full_formatted
    ELSE
     reply->prodqual[prod_cnt].eventqual[event_cnt].return_courier = dr.return_courier_text
    ENDIF
    reply->prodqual[prod_cnt].eventqual[event_cnt].visual_insp_disp = uar_get_code_display(
     vis_insp_cd), reply->prodqual[prod_cnt].eventqual[event_cnt].bb_id_nbr = bb_id_nbr
    IF (release_ind="dr")
     reply->prodqual[prod_cnt].eventqual[event_cnt].visual_insp_disp = uar_get_code_display(dr
      .return_vis_insp_cd), reply->prodqual[prod_cnt].eventqual[event_cnt].return_temperature = dr
     .return_temperature_value, reply->prodqual[prod_cnt].eventqual[event_cnt].return_temperature_txt
      = dr.return_temperature_txt,
     reply->prodqual[prod_cnt].eventqual[event_cnt].return_temperature_degree_cd = dr
     .return_temperature_degree_cd
    ENDIF
   ENDIF
  FOOT  pe.product_id
   IF ((reply->prodqual[prod_cnt].derivative_ind=1))
    event = 0
    FOR (event = 1 TO event_cnt)
     CALL echo(build("value for prod is "),prod_cnt),
     IF ((reply->prodqual[prod_cnt].eventqual[event].event_type_cd=available_event_type_cd))
      IF (orig_rcvd_qty > 0
       AND orig_avail_qty != 0)
       reply->prodqual[prod_cnt].eventqual[event].orig_qty = (orig_rcvd_qty+ orig_avail_qty), reply->
       prodqual[prod_cnt].eventqual[event].orig_intl_units = (orig_rcvd_intl_units+ orig_avail_units)
      ELSEIF (orig_rcvd_qty > 0)
       reply->prodqual[prod_cnt].eventqual[event].orig_qty = orig_rcvd_qty, reply->prodqual[prod_cnt]
       .eventqual[event].orig_intl_units = orig_rcvd_intl_units
      ELSE
       reply->prodqual[prod_cnt].eventqual[event].orig_qty = orig_avail_qty, reply->prodqual[prod_cnt
       ].eventqual[event].orig_intl_units = orig_avail_units
      ENDIF
      IF ((reply->prodqual[prod_cnt].eventqual[event].active_ind=1))
       reply->prodqual[prod_cnt].eventqual[event].cur_qty = reply->prodqual[prod_cnt].cur_avail_qty,
       reply->prodqual[prod_cnt].eventqual[event].cur_intl_units = reply->prodqual[prod_cnt].
       cur_intl_units
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   stat = alterlist(reply->prodqual[prod_cnt].eventqual,event_cnt)
  FOOT REPORT
   stat = alterlist(reply->prodqual,prod_cnt)
  WITH nocounter, outerjoin(d_x), outerjoin(d_ar),
   outerjoin(d_qr), outerjoin(d_dr), outerjoin(d_ph),
   outerjoin(d_bbe), dontcare = dr
 ;end select
 SET stat = alterlist(reply->prodqual,prod_cnt)
 DECLARE cntr = i4
 FOR (cntr = 1 TO prod_cnt)
   SELECT INTO "nl:"
    d.seq, product_event_id = reply->prodqual[cntr].eventqual[d.seq].product_event_id, table_ind =
    decode(aor.seq,"06aor  ",ea.seq,"05ea   ",per.seq,
     "04per  ",prsnl.seq,"03prsnl","xxxxx"),
    prsnl.username, prsnl_per.name_full_formatted, per.name_full_formatted,
    per_active_status_disp = cv_per.display, ea.alias, aor.accession,
    order_disp = decode(o.seq,o.order_mnemonic,""), ordering_physician_disp = decode(phy.seq,phy
     .name_full_formatted,"")
    FROM (dummyt d  WITH seq = value(size(reply->prodqual[cntr].eventqual,5))),
     person prsnl_per,
     prsnl prsnl,
     person per,
     code_value cv_per,
     encntr_alias ea,
     accession_order_r aor,
     orders o,
     prsnl phy
    PLAN (d)
     JOIN (((prsnl_per
     WHERE (prsnl_per.person_id=reply->prodqual[cntr].eventqual[d.seq].event_prsnl_id)
      AND prsnl_per.person_id != null
      AND prsnl_per.person_id > 0)
     JOIN (prsnl
     WHERE (prsnl.person_id=reply->prodqual[cntr].eventqual[d.seq].event_prsnl_id)
      AND prsnl.person_id > 0)
     ) ORJOIN ((((per
     WHERE (per.person_id=reply->prodqual[cntr].eventqual[d.seq].person_id)
      AND per.person_id != null
      AND per.person_id > 0)
     JOIN (cv_per
     WHERE cv_per.code_value=per.active_status_cd)
     ) ORJOIN ((((ea
     WHERE (ea.encntr_id=reply->prodqual[cntr].eventqual[d.seq].encntr_id)
      AND ea.encntr_id != null
      AND ea.encntr_id > 0
      AND ea.encntr_alias_type_cd=mrn_alias_type_cd
      AND ea.active_ind=1
      AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
     ) ORJOIN ((aor
     WHERE (aor.order_id=reply->prodqual[cntr].eventqual[d.seq].order_id)
      AND aor.order_id != null
      AND aor.order_id > 0
      AND aor.primary_flag=0)
     JOIN (o
     WHERE o.order_id=aor.order_id)
     JOIN (phy
     WHERE phy.person_id=o.last_update_provider_id)
     )) )) ))
    ORDER BY d.seq, table_ind
    DETAIL
     IF (table_ind="03prsnl")
      reply->prodqual[cntr].eventqual[d.seq].event_prsnl_username = prsnl.username, reply->prodqual[
      cntr].eventqual[d.seq].event_prsnl_name = prsnl_per.name_full_formatted
     ELSEIF (table_ind="04per  ")
      IF (per.active_ind=1)
       reply->prodqual[cntr].eventqual[d.seq].name_full_formatted = per.name_full_formatted
      ELSE
       reply->prodqual[cntr].eventqual[d.seq].name_full_formatted = concat("<",trim(cv_per.display),
        "> ",trim(per.name_full_formatted))
      ENDIF
     ELSEIF (table_ind="05ea   ")
      reply->prodqual[cntr].eventqual[d.seq].mrn_alias = cnvtalias(ea.alias,ea.alias_pool_cd)
     ELSEIF (table_ind="06aor  ")
      reply->prodqual[cntr].eventqual[d.seq].accession = cnvtacc(aor.accession), reply->prodqual[cntr
      ].eventqual[d.seq].order_disp = order_disp
      IF ((reply->prodqual[cntr].eventqual[d.seq].event_type_cd != issued_event_type_cd))
       reply->prodqual[cntr].eventqual[d.seq].ordering_physician_disp = ordering_physician_disp
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 SET count1 += 1
 IF (count1 != 1)
  SET stat = alter(reply->status_data.subeventstatus,count1)
 ENDIF
 IF (curqual=0)
  SELECT INTO "nl:"
   hp.*, hpe.*
   FROM bbhist_product hp,
    bbhist_product_event hpe,
    person per,
    prsnl p,
    organization o,
    encntr_alias ea
   PLAN (hp
    WHERE expand(num,1,size(prodlist->qual,5),hp.product_id,prodlist->qual[num].pid))
    JOIN (hpe
    WHERE hpe.product_id=hp.product_id)
    JOIN (per
    WHERE (per.person_id= Outerjoin(hpe.person_id)) )
    JOIN (p
    WHERE (p.person_id= Outerjoin(hpe.prsnl_id)) )
    JOIN (o
    WHERE o.organization_id=hp.supplier_id)
    JOIN (ea
    WHERE (ea.encntr_id= Outerjoin(hpe.encntr_id))
     AND (ea.encntr_alias_type_cd= Outerjoin(mrn_alias_type_cd))
     AND (ea.encntr_id> Outerjoin(0.0))
     AND (ea.active_ind= Outerjoin(1))
     AND (ea.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
     AND (ea.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
   ORDER BY hp.product_id, hpe.product_event_id
   HEAD REPORT
    nbbhist_prod_cnt = 0
   HEAD hp.product_id
    nbbhist_prod_cnt += 1
    IF (nbbhist_prod_cnt > size(reply->prodqual,5))
     stat = alterlist(reply->prodqual,(nbbhist_prod_cnt+ 10))
    ENDIF
    reply->prodqual[nbbhist_prod_cnt].product_id = hp.product_id, reply->prodqual[nbbhist_prod_cnt].
    product_nbr = hp.product_nbr, reply->prodqual[nbbhist_prod_cnt].product_sub_nbr = hp
    .product_sub_nbr,
    reply->prodqual[nbbhist_prod_cnt].alternate_nbr = hp.alternate_nbr, reply->prodqual[
    nbbhist_prod_cnt].product_cd = hp.product_cd, reply->prodqual[nbbhist_prod_cnt].product_disp =
    uar_get_code_display(hp.product_cd),
    reply->prodqual[nbbhist_prod_cnt].cur_expire_dt_tm = cnvtdatetime(hp.expire_dt_tm), reply->
    prodqual[nbbhist_prod_cnt].cur_supplier_id = hp.supplier_id, reply->prodqual[nbbhist_prod_cnt].
    cur_supplier_name = o.org_name
    IF (uar_get_code_meaning(hp.product_class_cd)=scdf_blood)
     reply->prodqual[nbbhist_prod_cnt].derivative_ind = 0
    ELSE
     reply->prodqual[nbbhist_prod_cnt].derivative_ind = 1
    ENDIF
    reply->prodqual[nbbhist_prod_cnt].cur_abo_cd = hp.abo_cd, reply->prodqual[nbbhist_prod_cnt].
    cur_rh_cd = hp.rh_cd, reply->prodqual[nbbhist_prod_cnt].contributor_system_cd = hp
    .contributor_system_cd,
    reply->prodqual[nbbhist_prod_cnt].upload_dt_tm = cnvtdatetime(hp.upload_dt_tm), reply->prodqual[
    nbbhist_prod_cnt].cross_reference = hp.cross_reference, reply->prodqual[nbbhist_prod_cnt].
    historical_ind = 1,
    reply->prodqual[nbbhist_prod_cnt].supplier_prefix = hp.supplier_prefix, nbbhist_event_cnt = 0
   HEAD hpe.product_event_id
    nbbhist_event_cnt += 1
    IF (nbbhist_event_cnt > size(reply->prodqual[nbbhist_prod_cnt].eventqual,5))
     stat = alterlist(reply->prodqual[nbbhist_prod_cnt].eventqual,(nbbhist_event_cnt+ 9))
    ENDIF
    reply->prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].product_event_id = hpe
    .product_event_id, reply->prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].event_dt_tm =
    cnvtdatetime(hpe.event_dt_tm), reply->prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].
    event_type_cd = hpe.event_type_cd,
    reply->prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].reason_cd = hpe.reason_cd, reply->
    prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].event_prsnl_id = hpe.prsnl_id, reply->
    prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].event_prsnl_username = p.username,
    reply->prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].event_prsnl_name = p
    .name_full_formatted, reply->prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].person_id =
    per.person_id, reply->prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].name_full_formatted
     = per.name_full_formatted,
    reply->prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].encntr_id = hpe.encntr_id
    IF (hpe.encntr_id > 0.0)
     reply->prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].mrn_alias = cnvtalias(ea.alias,ea
      .alias_pool_cd)
    ENDIF
    reply->prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].active_ind = hpe.active_ind, reply
    ->prodqual[nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].cur_qty = hpe.qty, reply->prodqual[
    nbbhist_prod_cnt].eventqual[nbbhist_event_cnt].cur_intl_units = hpe.international_unit
   DETAIL
    row + 0
   FOOT  hpe.product_event_id
    row + 0
   FOOT  hp.product_id
    stat = alterlist(reply->prodqual[nbbhist_prod_cnt].eventqual,nbbhist_event_cnt)
   FOOT REPORT
    stat = alterlist(reply->prodqual,nbbhist_prod_cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "get product history"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_product_history"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "No product history found for requested product_id"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 DECLARE get_event_type_cds(event_type_status) = c1
 SUBROUTINE get_event_type_cds(event_type_cd_dummy)
   SET event_type_status = "F"
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,assigned_cdf_meaning,1,
    assigned_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,quarantined_cdf_meaning,1,
    quarantined_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,crossmatched_cdf_meaning,1,
    crossmatched_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,issued_cdf_meaning,1,
    issued_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,disposed_cdf_meaning,1,
    disposed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,transferred_cdf_meaning,1,
    transferred_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,transfused_cdf_meaning,1,
    transfused_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,modified_cdf_meaning,1,
    modified_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,unconfirmed_cdf_meaning,1,
    unconfirmed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,autologous_cdf_meaning,1,
    autologous_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,directed_cdf_meaning,1,
    directed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,available_cdf_meaning,1,
    available_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,received_cdf_meaning,1,
    received_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,destroyed_cdf_meaning,1,
    destroyed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,shipped_cdf_meaning,1,
    shipped_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,in_progress_cdf_meaning,1,
    in_progress_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,pooled_cdf_meaning,1,
    pooled_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,pooled_product_cdf_meaning,1,
    pooled_product_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,confirmed_cdf_meaning,1,
    confirmed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,drawn_cdf_meaning,1,
    drawn_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,tested_cdf_meaning,1,
    tested_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,intransit_cdf_meaning,1,
    in_transit_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,modified_product_cdf_meaning,1,
    modified_product_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,transferred_from_cdf_meaning,1,
    transferred_from_event_type_cd)
   SET event_type_status = "S"
   RETURN(event_type_status)
 END ;Subroutine
#exit_script
END GO
