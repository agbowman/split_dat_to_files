CREATE PROGRAM bbt_get_duplicate_product:dba
 IF ((request->called_from_script_ind=0))
  RECORD reply(
    1 qual[*]
      2 product_id = f8
      2 duplicate_found = c1
      2 conflicting_aborh_found = c1
      2 abo_cd = f8
      2 abo_disp = c40
      2 rh_cd = f8
      2 rh_disp = c40
      2 history_upload_ind = i2
      2 ref_product_id = f8
      2 serial_nbr_txt = c22
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET select_ok_ind = "N"
 SET select2_ok_ind = "N"
 SET reply->status_data.status = "F"
 SET product_cnt = size(request->productlist,5)
 SET stat = alterlist(reply->qual,product_cnt)
 IF ((request->donor_product_ind=1))
  SELECT INTO "nl:"
   d.seq, p.product_id
   FROM (dummyt d  WITH seq = value(product_cnt)),
    product p
   PLAN (d)
    JOIN (p
    WHERE p.product_nbr=cnvtupper(request->productlist[d.seq].product_nbr)
     AND p.active_ind=1)
   DETAIL
    p.product_id
    IF (p.product_id > 0.0)
     reply->qual[d.seq].duplicate_found = "Y", reply->qual[d.seq].product_id = p.product_id
    ENDIF
   WITH nocounter
  ;end select
  SET select_ok_ind = "Y"
  SET select2_ok_ind = "Y"
 ELSE
  SELECT INTO "nl:"
   d.seq, p.product_id, p.product_nbr,
   p.product_sub_nbr, p.product_cd, p.product_cat_cd,
   p.cur_supplier_id, p.serial_number_txt, pc.rh_required_ind,
   bp_drv_ind = decode(drv.seq,"drv",bp.seq,"bp ","xxx"), bp.cur_abo_cd, bp.cur_rh_cd,
   drv.product_id, abo_cd = decode(bp.seq,bp.cur_abo_cd,0.0), rh_cd = decode(bp.seq,bp.cur_rh_cd,0.0),
   drv.manufacturer_id
   FROM (dummyt d  WITH seq = value(product_cnt)),
    product p,
    product_category pc,
    (dummyt d_bp_drv  WITH seq = 1),
    blood_product bp,
    derivative drv
   PLAN (d)
    JOIN (p
    WHERE p.product_nbr=cnvtupper(request->productlist[d.seq].product_nbr)
     AND p.active_ind=1
     AND ((nullind(p.serial_number_txt)=0
     AND p.serial_number_txt=cnvtupper(request->productlist[d.seq].serial_nbr_txt)) OR (nullind(p
     .serial_number_txt)=1
     AND (((request->productlist[d.seq].serial_nbr_txt <= "")) OR ((request->productlist[d.seq].
    serial_nbr_txt <= " "))) )) )
    JOIN (pc
    WHERE pc.product_cat_cd=p.product_cat_cd)
    JOIN (d_bp_drv
    WHERE d_bp_drv.seq=1)
    JOIN (((bp
    WHERE bp.product_id=p.product_id)
    ) ORJOIN ((drv
    WHERE drv.product_id=p.product_id)
    ))
   ORDER BY d.seq
   HEAD d.seq
    dup_ind = "N", con_ind = "N"
   DETAIL
    reply->qual[d.seq].ref_product_id = request->productlist[d.seq].ref_product_id
    IF (dup_ind="N"
     AND (p.product_cd=request->productlist[d.seq].product_cd)
     AND trim(p.product_sub_nbr)=trim(request->productlist[d.seq].product_sub_nbr))
     IF (trim(bp_drv_ind)="drv")
      IF (((p.cur_owner_area_cd > 0.0
       AND (p.cur_owner_area_cd=request->productlist[d.seq].cur_owner_area_cd)) OR ((((request->
      productlist[d.seq].cur_owner_area_cd=0.0)) OR ((request->productlist[d.seq].cur_owner_area_cd=
      null))) ))
       AND ((p.cur_inv_area_cd > 0.0
       AND (p.cur_inv_area_cd=request->productlist[d.seq].cur_inv_area_cd)) OR ((((request->
      productlist[d.seq].cur_inv_area_cd=0.0)) OR ((request->productlist[d.seq].cur_inv_area_cd=null)
      )) )) )
       IF (validate(request->productlist[d.seq].manufacturer_id,0.0) > 0.0)
        IF ((drv.manufacturer_id=request->productlist[d.seq].manufacturer_id))
         dup_ind = "Y", reply->qual[d.seq].product_id = p.product_id, reply->qual[d.seq].
         duplicate_found = "Y"
        ENDIF
       ELSEIF (validate(request->productlist[d.seq].manufacturer_id,0.0)=0.0)
        IF ((drv.manufacturer_id=request->productlist[d.seq].cur_supplier_id))
         dup_ind = "Y", reply->qual[d.seq].product_id = p.product_id, reply->qual[d.seq].
         duplicate_found = "Y"
        ENDIF
       ENDIF
      ENDIF
     ELSEIF (((trim(request->productlist[d.seq].supplier_prefix) > ""
      AND cnvtupper(bp.supplier_prefix)=cnvtupper(request->productlist[d.seq].supplier_prefix)) OR (
     trim(request->productlist[d.seq].supplier_prefix)=""
      AND (p.cur_supplier_id=request->productlist[d.seq].cur_supplier_id))) )
      dup_ind = "Y", reply->qual[d.seq].product_id = p.product_id, reply->qual[d.seq].duplicate_found
       = "Y"
     ENDIF
    ELSEIF (con_ind="N"
     AND (p.cur_supplier_id=request->productlist[d.seq].cur_supplier_id)
     AND (p.product_cd != request->productlist[d.seq].product_cd)
     AND trim(bp_drv_ind)="bp"
     AND (((abo_cd != request->productlist[d.seq].abo_cd)) OR (pc.rh_required_ind=1
     AND (rh_cd != request->productlist[d.seq].rh_cd))) )
     con_ind = "Y", reply->qual[d.seq].product_id = p.product_id, reply->qual[d.seq].
     conflicting_aborh_found = "Y",
     reply->qual[d.seq].abo_cd = abo_cd, reply->qual[d.seq].rh_cd = rh_cd
    ENDIF
   FOOT REPORT
    select_ok_ind = "Y"
   WITH nocounter, nullreport
  ;end select
  SELECT INTO "nl:"
   d.seq, hp.product_id, hp.product_nbr,
   hp.product_sub_nbr, hp.product_cd, hp.supplier_id,
   pc.rh_required_ind, product_class_meaning = uar_get_code_meaning(hp.product_class_cd), hp.abo_cd,
   hp.rh_cd
   FROM (dummyt d  WITH seq = value(product_cnt)),
    bbhist_product hp,
    product_index pi,
    product_category pc
   PLAN (d)
    JOIN (hp
    WHERE hp.product_nbr=cnvtupper(request->productlist[d.seq].product_nbr)
     AND hp.active_ind=1)
    JOIN (pi
    WHERE pi.product_cd=hp.product_cd)
    JOIN (pc
    WHERE pc.product_cat_cd=pi.product_cat_cd)
   ORDER BY d.seq
   HEAD d.seq
    dup_ind = "N", con_ind = "N"
   DETAIL
    IF (dup_ind="N"
     AND (hp.product_cd=request->productlist[d.seq].product_cd)
     AND trim(hp.product_sub_nbr)=trim(request->productlist[d.seq].product_sub_nbr))
     reply->qual[d.seq].history_upload_ind = 1
     IF (product_class_meaning="DERIVATIVE")
      IF (((hp.owner_area_cd > 0.0
       AND (hp.owner_area_cd=request->productlist[d.seq].cur_owner_area_cd)) OR (((hp.owner_area_cd=
      0.0) OR (hp.owner_area_cd=null)) ))
       AND ((hp.inv_area_cd > 0.0
       AND (hp.inv_area_cd=request->productlist[d.seq].cur_inv_area_cd)) OR (((hp.inv_area_cd=0.0)
       OR (hp.inv_area_cd=null)) )) )
       IF (validate(request->productlist[d.seq].manufacturer_id,0.0) > 0.0)
        IF ((hp.supplier_id=request->productlist[d.seq].manufacturer_id))
         dup_ind = "Y", reply->qual[d.seq].product_id = hp.product_id, reply->qual[d.seq].
         duplicate_found = "Y"
        ENDIF
       ELSEIF (validate(request->productlist[d.seq].manufacturer_id,0.0)=0.0)
        IF ((hp.supplier_id=request->productlist[d.seq].cur_supplier_id))
         dup_ind = "Y", reply->qual[d.seq].product_id = hp.product_id, reply->qual[d.seq].
         duplicate_found = "Y"
        ENDIF
       ENDIF
      ENDIF
     ELSEIF ((hp.supplier_id=request->productlist[d.seq].cur_supplier_id))
      dup_ind = "Y", reply->qual[d.seq].product_id = hp.product_id, reply->qual[d.seq].
      duplicate_found = "Y"
     ENDIF
    ELSEIF (con_ind="N"
     AND (hp.supplier_id=request->productlist[d.seq].cur_supplier_id)
     AND (hp.product_cd != request->productlist[d.seq].product_cd)
     AND product_class_meaning="BLOOD"
     AND (((hp.abo_cd != request->productlist[d.seq].abo_cd)) OR (pc.rh_required_ind=1
     AND (hp.rh_cd != request->productlist[d.seq].rh_cd))) )
     con_ind = "Y", reply->qual[d.seq].product_id = hp.product_id, reply->qual[d.seq].
     conflicting_aborh_found = "Y",
     reply->qual[d.seq].abo_cd = hp.abo_cd, reply->qual[d.seq].rh_cd = hp.rh_cd
    ENDIF
   FOOT REPORT
    select2_ok_ind = "Y"
   WITH nocounter, nullreport
  ;end select
 ENDIF
 IF (select2_ok_ind="N")
  SET select_ok_ind = "N"
 ENDIF
 SET reply->status_data.subeventstatus[1].operationname = "select product table"
 SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_duplicate_product"
 IF (select_ok_ind="Y")
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SUCCESS"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "product/bbhist_product table select failed"
 ENDIF
END GO
