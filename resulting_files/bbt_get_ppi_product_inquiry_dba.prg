CREATE PROGRAM bbt_get_ppi_product_inquiry:dba
 RECORD reply(
   1 status = c1
   1 process = vc
   1 message = vc
   1 qual[*]
     2 product_id = f8
     2 product_cd = f8
     2 product_disp = c40
     2 product_nbr = c20
     2 product_sub_nbr = c5
     2 cur_abo_cd = f8
     2 cur_abo_disp = c20
     2 cur_rh_cd = f8
     2 cur_rh_disp = c20
     2 derivative_ind = i2
     2 drv_cur_avail_qty = i4
     2 comments_ind = i2
     2 eventlist[*]
       3 product_event_id = f8
       3 event_type_cd = f8
       3 event_type_disp = c20
       3 event_type_mean = c12
       3 event_dt_tm = dq8
       3 reason_cd = f8
       3 reason_disp = c20
       3 accession = c20
       3 quantity = i4
       3 intl_units = i4
       3 xm_expire_dt_tm = dq8
       3 formatted_accession = vc
       3 order_id = f8
       3 cur_device_desc = c40
     2 spectestlist[*]
       3 special_testing_cd = f8
       3 special_testing_disp = c40
     2 history_upload_ind = i2
     2 cross_reference = vc
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 upload_dt_tm = dq8
     2 supplier_prefix = c5
     2 electronic_entry_flag = i2
     2 cur_owner_area_cd = f8
     2 cur_inv_area_cd = f8
     2 cur_device_id = f8
     2 cur_device_desc = c40
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
   1 productlist[*]
     2 product_id = f8
   1 event_date
     2 event_year = i4
     2 event_month = i4
     2 event_day = i4
   1 eventlist[*]
     2 product_id = f8
     2 product_cd = f8
     2 product_nbr = c20
     2 product_sub_nbr = c5
     2 cur_abo_cd = f8
     2 cur_rh_cd = f8
     2 derivative_ind = i2
     2 drv_cur_avail_qty = i4
     2 comments_ind = i2
     2 product_event_id = f8
     2 event_type_cd = f8
     2 event_dt_tm = dq8
     2 reason_cd = f8
     2 accession = c20
     2 quantity = i4
     2 intl_units = i4
     2 select_ind = i2
     2 xm_expire_dt_tm = dq8
 )
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET prod_cnt = 0
 SET prod = 0
 SET new_prod = 0
 SET prod_chk = 0
 SET event = "   "
 SET exception_f8 = cnvtreal(0)
 SET exception_c20 = fillstring(20," ")
 SET exception_c40 = fillstring(40," ")
 SET event_cnt = 0
 SET max_event_cnt = 0
 SET req_event = 0
 SET req_event_cnt = 0
 SET prod_qual_cnt = 0
 SET prod_event_cnt = 0
 SET max_prod_event_cnt = 0
 SET select_cnt = 0
 DECLARE from_chk_date = q8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE to_chk_date = q8 WITH noconstant(cnvtdatetime(sysdate))
#begin_main
 SET reply->status_data.status = "Z"
 IF ((request->begin_dt_tm > 0)
  AND (request->end_dt_tm > 0))
  SET from_chk_date = request->begin_dt_tm
  SET to_chk_date = request->end_dt_tm
 ELSE
  IF ((request->begin_date.event_year=0)
   AND (request->end_date.event_year=9999))
   SET from_chk_date = cnvtdatetime(cnvtdate2("01011800","DDMMYYYY"),curtime3)
   SET to_chk_date = cnvtdatetime(cnvtdate2("31122100","DDMMYYYY"),curtime3)
  ELSE
   SET from_chk_date = cnvtdatetime(cnvtdate2(concat(format(request->begin_date.event_day,"##;P0"),
      format(request->begin_date.event_month,"##;P0"),format(request->begin_date.event_year,"####;P0"
       )),"DDMMYYYY"),curtime3)
   SET to_chk_date = cnvtdatetime(cnvtdate2(concat(format(request->end_date.event_day,"##;P0"),format
      (request->end_date.event_month,"##;P0"),format(request->end_date.event_year,"####;P0")),
     "DDMMYYYY"),curtime3)
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  pe.product_id
  FROM product_event pe
  WHERE (pe.person_id=request->person_id)
   AND pe.event_dt_tm BETWEEN cnvtdatetime(from_chk_date) AND cnvtdatetime(to_chk_date)
   AND pe.active_ind=1
   AND ((pe.event_status_flag < 1) OR (pe.event_status_flag=null))
   AND pe.product_id != null
   AND pe.product_id > 0
  HEAD REPORT
   prod_cnt = 0, stat = alterlist(internal->productlist,20)
  DETAIL
   new_prod = (prod_cnt+ 1)
   FOR (prod_chk = 1 TO prod_cnt)
     IF ((internal->productlist[prod_chk].product_id=pe.product_id))
      new_prod = prod_chk, prod_chk = prod_cnt
     ENDIF
   ENDFOR
   IF (new_prod > prod_cnt)
    prod_cnt = new_prod
    IF (mod(prod_cnt,20)=1
     AND prod_cnt != 1)
     stat = alterlist(internal->productlist,(prod_cnt+ 19))
    ENDIF
    internal->productlist[prod_cnt].product_id = pe.product_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0
  AND prod_cnt > 0)
  SET stat = alterlist(internal->productlist,prod_cnt)
  SET req_event_cnt = size(request->eventlist,5)
  SELECT INTO "nl:"
   table_ind = decode(pe.seq,"5pe ",st.seq,"4st ",pn.seq,
    "3pn ",drv.seq,"2drv",bp.seq,"1bp ",
    "xxx"), bp_drv_flg = decode(drv.seq,"drv",bp.seq,"bp ","xxx"), pn_ind = decode(pn.seq,1,0),
   pe = decode(pe.seq,"pe","  "), p.product_id, p.product_nbr,
   p.product_sub_nbr, p.serial_number_txt, p.product_cd,
   p.cur_inv_area_cd, p.cur_owner_area_cd, bp.supplier_prefix,
   bp.cur_abo_cd, bp.cur_rh_cd, drv.cur_avail_qty,
   pn.product_note_id, st.special_testing_cd, pe.product_id,
   pe.product_event_id, pe.event_type_cd, pe.event_dt_tm,
   pe.order_id, pe.person_id, accession = decode(aor.seq,aor.accession,exception_c20),
   reason_cd = decode(a.seq,a.assign_reason_cd,xm.seq,xm.xm_reason_cd,pd.seq,
    pd.dispense_reason_cd,qu.seq,qu.quar_reason_cd,tfr.seq,tfr.transfer_reason_cd,
    exception_f8), quantity = decode(a.seq,a.cur_assign_qty,pd.seq,pd.cur_dispense_qty,qu.seq,
    qu.cur_quar_qty,tfn.seq,tfn.cur_transfused_qty,0), intl_units = decode(a.seq,a
    .cur_assign_intl_units,pd.seq,pd.cur_dispense_intl_units,qu.seq,
    qu.cur_quar_intl_units,tfn.seq,tfn.transfused_intl_units,0),
   xm_expire_dt_tm = decode(xm.seq,cnvtdatetime(xm.crossmatch_exp_dt_tm),cnvtdatetime(""))
   FROM (dummyt d1  WITH seq = value(prod_cnt)),
    product p,
    (dummyt d_p  WITH seq = 1),
    product_note pn,
    blood_product bp,
    derivative drv,
    product_event pe,
    (dummyt d_pe  WITH seq = 1),
    assign a,
    auto_directed ad,
    crossmatch xm,
    (dummyt d_aor  WITH seq = 1),
    accession_order_r aor,
    patient_dispense pd,
    (dummyt d_bid  WITH seq = 1),
    bb_inv_device bid,
    quarantine qu,
    transfusion tfn,
    transfer tfr,
    special_testing st
   PLAN (d1)
    JOIN (p
    WHERE (p.product_id=internal->productlist[d1.seq].product_id))
    JOIN (d_p
    WHERE d_p.seq=1)
    JOIN (((bp
    WHERE bp.product_id=p.product_id)
    ) ORJOIN ((((drv
    WHERE drv.product_id=p.product_id)
    ) ORJOIN ((((pn
    WHERE pn.product_id=p.product_id
     AND pn.active_ind=1)
    ) ORJOIN ((((st
    WHERE st.product_id=p.product_id
     AND st.active_ind=1)
    ) ORJOIN ((pe
    WHERE (pe.product_id=internal->productlist[d1.seq].product_id)
     AND (((pe.person_id=request->person_id)) OR (((pe.person_id=0) OR (pe.person_id=null)) ))
     AND pe.active_ind=1
     AND ((pe.event_status_flag=0) OR (pe.event_status_flag=null)) )
    JOIN (d_pe
    WHERE d_pe.seq=1)
    JOIN (((a
    WHERE a.product_event_id=pe.product_event_id
     AND (a.person_id=request->person_id))
    ) ORJOIN ((((ad
    WHERE ad.product_event_id=pe.product_event_id
     AND (ad.person_id=request->person_id))
    ) ORJOIN ((((xm
    WHERE xm.product_event_id=pe.product_event_id
     AND (xm.person_id=request->person_id))
    JOIN (d_aor
    WHERE d_aor.seq=1)
    JOIN (aor
    WHERE aor.order_id=pe.order_id
     AND aor.primary_flag=0)
    ) ORJOIN ((((pd
    WHERE pd.product_event_id=pe.product_event_id
     AND (pd.person_id=request->person_id))
    JOIN (d_bid
    WHERE d_bid.seq=1)
    JOIN (bid
    WHERE pe.product_event_id=pd.product_event_id
     AND bid.bb_inv_device_id=pd.device_id
     AND bid.active_ind=1)
    ) ORJOIN ((((qu
    WHERE qu.product_event_id=pe.product_event_id)
    ) ORJOIN ((((tfn
    WHERE tfn.product_event_id=pe.product_event_id
     AND (tfn.person_id=request->person_id))
    ) ORJOIN ((tfr
    WHERE tfr.product_event_id=pe.product_event_id)
    )) )) )) )) )) )) )) )) )) ))
   ORDER BY p.product_id, table_ind, st.special_testing_cd,
    pe.product_event_id
   HEAD REPORT
    req = 0, stat = alterlist(reply->qual,10)
   HEAD p.product_id
    prod_qual_cnt += 1
    IF (mod(prod_qual_cnt,10)=1
     AND prod_qual_cnt != 1)
     stat = alterlist(reply->qual,(prod_qual_cnt+ 9))
    ENDIF
    reply->qual[prod_qual_cnt].product_id = p.product_id, reply->qual[prod_qual_cnt].product_cd = p
    .product_cd, reply->qual[prod_qual_cnt].product_nbr = p.product_nbr,
    reply->qual[prod_qual_cnt].product_sub_nbr = p.product_sub_nbr, reply->qual[prod_qual_cnt].
    serial_number_txt = p.serial_number_txt, reply->qual[prod_qual_cnt].cur_owner_area_cd = p
    .cur_owner_area_cd,
    reply->qual[prod_qual_cnt].cur_inv_area_cd = p.cur_inv_area_cd, reply->qual[prod_qual_cnt].
    electronic_entry_flag = p.electronic_entry_flag, reply->qual[prod_qual_cnt].cur_device_id = p
    .cur_dispense_device_id,
    reply->qual[prod_qual_cnt].history_upload_ind = 0, prod_event_cnt = 0, stat = alterlist(reply->
     qual[prod_qual_cnt].eventlist,0),
    stat = alterlist(reply->qual[prod_qual_cnt].eventlist,5), req_event_found_ind = 0, add_event_ind
     = 0,
    spec_test_cnt = 0, stat = alterlist(reply->qual[prod_qual_cnt].spectestlist,0)
   DETAIL
    IF (bid.description > " ")
     reply->qual[prod_qual_cnt].cur_device_desc = bid.description
    ENDIF
    IF (trim(table_ind)="1bp")
     drv_ind = 0, reply->qual[prod_qual_cnt].cur_abo_cd = bp.cur_abo_cd, reply->qual[prod_qual_cnt].
     cur_rh_cd = bp.cur_rh_cd,
     reply->qual[prod_qual_cnt].derivative_ind = 0, reply->qual[prod_qual_cnt].drv_cur_avail_qty = 0,
     reply->qual[prod_qual_cnt].supplier_prefix = bp.supplier_prefix
    ELSEIF (trim(table_ind)="2drv")
     drv_ind = 1, reply->qual[prod_qual_cnt].cur_abo_cd = 0, reply->qual[prod_qual_cnt].cur_rh_cd = 0,
     reply->qual[prod_qual_cnt].derivative_ind = 1, reply->qual[prod_qual_cnt].drv_cur_avail_qty =
     drv.cur_avail_qty
    ELSEIF (trim(table_ind)="3pn")
     reply->qual[prod_qual_cnt].comments_ind = pn_ind
    ELSEIF (trim(table_ind)="4st")
     spec_test_cnt += 1, stat = alterlist(reply->qual[prod_qual_cnt].spectestlist,spec_test_cnt),
     reply->qual[prod_qual_cnt].spectestlist[spec_test_cnt].special_testing_cd = st
     .special_testing_cd
    ELSEIF (trim(table_ind)="5pe"
     AND ((drv_ind=0) OR (drv_ind=1
     AND pe.person_id != null
     AND pe.person_id > 0)) )
     IF (req_event_found_ind=0)
      FOR (req = 1 TO req_event_cnt)
        IF ((pe.event_type_cd=request->eventlist[req].event_type_cd))
         req_event_found_ind = 1, req = req_event_cnt
        ENDIF
      ENDFOR
     ENDIF
     IF (drv_ind=1)
      IF (req_event_found_ind=1
       AND pe.event_dt_tm BETWEEN cnvtdatetime(from_chk_date) AND cnvtdatetime(to_chk_date))
       add_event_ind = 1, req_event_found_ind = 0
      ELSE
       add_event_ind = 0, req_event_found_ind = 0
      ENDIF
     ELSE
      add_event_ind = 1
     ENDIF
     IF (add_event_ind=1)
      prod_event_cnt += 1
      IF (mod(prod_event_cnt,5)=1
       AND prod_event_cnt != 1)
       stat = alterlist(reply->qual[prod_qual_cnt].eventlist,(prod_event_cnt+ 4))
      ENDIF
      reply->qual[prod_qual_cnt].eventlist[prod_event_cnt].product_event_id = pe.product_event_id,
      reply->qual[prod_qual_cnt].eventlist[prod_event_cnt].event_type_cd = pe.event_type_cd, reply->
      qual[prod_qual_cnt].eventlist[prod_event_cnt].event_dt_tm = cnvtdatetime(pe.event_dt_tm),
      reply->qual[prod_qual_cnt].eventlist[prod_event_cnt].reason_cd = reason_cd, reply->qual[
      prod_qual_cnt].eventlist[prod_event_cnt].accession = accession, reply->qual[prod_qual_cnt].
      eventlist[prod_event_cnt].quantity = quantity,
      reply->qual[prod_qual_cnt].eventlist[prod_event_cnt].intl_units = intl_units, reply->qual[
      prod_qual_cnt].eventlist[prod_event_cnt].xm_expire_dt_tm = xm_expire_dt_tm, reply->qual[
      prod_qual_cnt].eventlist[prod_event_cnt].formatted_accession = cnvtacc(aor.accession),
      reply->qual[prod_qual_cnt].eventlist[prod_event_cnt].order_id = aor.order_id
      IF (bid.description > " ")
       reply->qual[prod_qual_cnt].eventlist[prod_event_cnt].cur_device_desc = bid.description
      ENDIF
     ENDIF
    ENDIF
   FOOT  p.product_id
    stat = alterlist(reply->qual[prod_qual_cnt].eventlist,prod_event_cnt), stat = alterlist(reply->
     qual[prod_qual_cnt].spectestlist,spec_test_cnt)
    IF ((reply->qual[prod_qual_cnt].derivative_ind=1))
     IF (prod_event_cnt=0)
      prod_qual_cnt -= 1
     ENDIF
    ELSE
     IF (req_event_found_ind=0)
      prod_qual_cnt -= 1
     ENDIF
    ENDIF
   WITH nocounter, outerjoin(d_pe), outerjoin(d_aor)
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET count1 += 1
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
   SET reply->status_data.subeventstatus[count1].operationname = "get blood_product/product_event"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_ppi_product_inquiry"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "Database/Script Error:  blood_product/product_event data could not be retrieved for exiting secondary product_event rows"
  ELSE
   IF (prod_qual_cnt > 0)
    SET reply->status_data.status = "S"
    SET count1 += 1
    SET stat = alter(reply->status_data.subeventstatus,count1)
    SET reply->status_data.subeventstatus[count1].operationname = "SUCCESS"
    SET reply->status_data.subeventstatus[count1].operationstatus = "S"
    SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_ppi_product_inquiry"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue = ""
   ENDIF
  ENDIF
 ENDIF
#end_main
#check_history_upload
 SET transfused_event_type_cd = 0.0
 SET req_event_cnt = size(request->eventlist,5)
 SET transfused_event_type_cd = get_code_value(1610,"7")
 FOR (req = 1 TO req_event_cnt)
   IF ((transfused_event_type_cd=request->eventlist[req].event_type_cd)
    AND transfused_event_type_cd != 0)
    SELECT INTO "nl:"
     hp.product_id, hp.contributor_system_cd, hp.cross_reference,
     hp.upload_dt_tm, hp.supplier_prefix, product_class_meaning = uar_get_code_meaning(hp
      .product_class_cd),
     pn.product_note_id
     FROM bbhist_product hp,
      bbhist_product_event hpe,
      product_note pn
     PLAN (hpe
      WHERE (hpe.person_id=request->person_id)
       AND (hpe.event_type_cd=request->eventlist[req].event_type_cd)
       AND hpe.event_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->
       end_dt_tm)
       AND hpe.active_ind=1)
      JOIN (hp
      WHERE hp.product_id=hpe.product_id)
      JOIN (pn
      WHERE (pn.bbhist_product_id= Outerjoin(hpe.product_id))
       AND (pn.active_ind= Outerjoin(1)) )
     ORDER BY hpe.product_id, hpe.product_event_id
     HEAD REPORT
      IF (prod_qual_cnt=0)
       stat = alterlist(reply->qual,10)
      ENDIF
     HEAD hpe.product_id
      prod_qual_cnt += 1
      IF (mod(prod_qual_cnt,10)=1
       AND prod_qual_cnt != 1)
       stat = alterlist(reply->qual,(prod_qual_cnt+ 9))
      ENDIF
      reply->qual[prod_qual_cnt].product_id = hp.product_id, reply->qual[prod_qual_cnt].product_cd =
      hp.product_cd, reply->qual[prod_qual_cnt].product_nbr = hp.product_nbr,
      reply->qual[prod_qual_cnt].product_sub_nbr = hp.product_sub_nbr, reply->qual[prod_qual_cnt].
      cur_abo_cd = hp.abo_cd, reply->qual[prod_qual_cnt].cur_rh_cd = hp.rh_cd
      IF (product_class_meaning="BLOOD")
       reply->qual[prod_qual_cnt].derivative_ind = 0, reply->qual[prod_qual_cnt].supplier_prefix = hp
       .supplier_prefix
      ELSEIF (product_class_meaning="DERIVATIVE")
       reply->qual[prod_qual_cnt].derivative_ind = 1
      ENDIF
      reply->qual[prod_qual_cnt].drv_cur_avail_qty = 0, reply->qual[prod_qual_cnt].comments_ind = 0,
      reply->qual[prod_qual_cnt].electronic_entry_flag = 0,
      reply->qual[prod_qual_cnt].history_upload_ind = 1, reply->qual[prod_qual_cnt].cross_reference
       = hp.cross_reference, reply->qual[prod_qual_cnt].upload_dt_tm = hp.upload_dt_tm,
      reply->qual[prod_qual_cnt].contributor_system_cd = hp.contributor_system_cd
      IF (pn.product_note_id > 0.0)
       reply->qual[prod_qual_cnt].comments_ind = 1
      ENDIF
      prod_event_cnt = 0, stat = alterlist(reply->qual[prod_qual_cnt].eventlist,5),
      req_event_found_ind = 0
     DETAIL
      prod_event_cnt += 1
      IF (mod(prod_event_cnt,5)=1
       AND prod_event_cnt != 1)
       stat = alterlist(reply->qual[prod_qual_cnt].eventlist,(prod_event_cnt+ 4))
      ENDIF
      reply->qual[prod_qual_cnt].eventlist[prod_event_cnt].product_event_id = hpe.product_event_id,
      reply->qual[prod_qual_cnt].eventlist[prod_event_cnt].event_type_cd = hpe.event_type_cd, reply->
      qual[prod_qual_cnt].eventlist[prod_event_cnt].event_dt_tm = cnvtdatetime(hpe.event_dt_tm),
      reply->qual[prod_qual_cnt].eventlist[prod_event_cnt].reason_cd = hpe.reason_cd, reply->qual[
      prod_qual_cnt].eventlist[prod_event_cnt].accession = "", reply->qual[prod_qual_cnt].eventlist[
      prod_event_cnt].quantity = hpe.qty,
      reply->qual[prod_qual_cnt].eventlist[prod_event_cnt].intl_units = 0, reply->qual[prod_qual_cnt]
      .eventlist[prod_event_cnt].xm_expire_dt_tm = 0
     FOOT  hpe.product_id
      stat = alterlist(reply->qual[prod_qual_cnt].eventlist,prod_event_cnt)
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF (prod_qual_cnt > 0)
  SELECT INTO "nl:"
   hst.special_testing_cd
   FROM (dummyt d1  WITH seq = value(prod_qual_cnt)),
    bbhist_special_testing hst
   PLAN (d1)
    JOIN (hst
    WHERE (hst.product_id=reply->qual[d1.seq].product_id)
     AND hst.active_ind=1)
   ORDER BY hst.product_id
   HEAD hst.product_id
    spec_test_cnt = 0
   DETAIL
    spec_test_cnt += 1
    IF (mod(spec_test_cnt,3)=1)
     stat = alterlist(reply->qual[d1.seq].spectestlist,(spec_test_cnt+ 2))
    ENDIF
    reply->qual[d1.seq].spectestlist[spec_test_cnt].special_testing_cd = hst.special_testing_cd
   FOOT  hst.product_id
    stat = alterlist(reply->qual[d1.seq].spectestlist,spec_test_cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->qual,prod_qual_cnt)
 IF (prod_qual_cnt > 0)
  SET reply->status_data.status = "S"
  SET count1 += 1
  SET stat = alter(reply->status_data.subeventstatus,count1)
  SET reply->status_data.subeventstatus[count1].operationname = "SUCCESS"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_ppi_product_inquiry"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = ""
 ENDIF
#exit_script
END GO
