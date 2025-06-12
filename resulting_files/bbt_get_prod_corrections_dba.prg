CREATE PROGRAM bbt_get_prod_corrections:dba
 RECORD reply(
   1 qual[*]
     2 product_id = f8
     2 product_nbr = c20
     2 alternate_nbr = c20
     2 product_sub_nbr = c5
     2 product_cd = f8
     2 product_cd_disp = c40
     2 unit_of_meas_cd = f8
     2 unit_of_meas_cd_disp = c40
     2 volume = i4
     2 supplier_disp = c40
     2 updt_cnt = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
     2 locked_ind = i2
     2 comments_ind = i2
     2 cur_abo_cd = f8
     2 cur_abo_cd_disp = c40
     2 cur_rh_cd = f8
     2 cur_rh_cd_disp = c40
     2 supplier_prefix = c5
     2 application_nbr = i4
     2 user_name = c100
     2 app_start_dt_tm = dq8
     2 device_location = c50
     2 application_desc = c200
     2 cur_owner_area_cd = f8
     2 cur_inv_area_cd = f8
     2 serial_nbr_txt = c22
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SET count3 = 0
 SET max2 = 1
 SET qualstep = 0
 SET product_updt_applctx = 0
 IF (size(request->untranslated_product_nbr)=0)
  SET request->untranslated_product_nbr = request->start_prodnbr
 ENDIF
 SELECT
  IF ((request->start_prodid=0))
   PLAN (p
    WHERE ((p.product_nbr=cnvtupper(request->start_prodnbr)) OR (((cnvtupper(request->start_prodnbr)=
    p.barcode_nbr) OR (p.product_nbr=cnvtupper(request->untranslated_product_nbr))) )) )
    JOIN (o
    WHERE o.organization_id=p.cur_supplier_id)
    JOIN (d_pn
    WHERE d_pn.seq=1)
    JOIN (pn
    WHERE pn.product_id=p.product_id
     AND pn.active_ind=1)
    JOIN (d_pnl
    WHERE d_pnl.seq=1)
    JOIN (pnl
    WHERE pnl.person_id=p.updt_id)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (((b
    WHERE b.product_id=p.product_id)
    ) ORJOIN ((dr
    WHERE dr.product_id=p.product_id)
    ))
  ELSE
   PLAN (p
    WHERE (p.product_id=request->start_prodid))
    JOIN (o
    WHERE o.organization_id=p.cur_supplier_id)
    JOIN (d_pn
    WHERE d_pn.seq=1)
    JOIN (pn
    WHERE pn.product_id=p.product_id
     AND pn.active_ind=1)
    JOIN (d_pnl
    WHERE d_pnl.seq=1)
    JOIN (pnl
    WHERE pnl.person_id=p.updt_id)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (((b
    WHERE b.product_id=p.product_id)
    ) ORJOIN ((dr
    WHERE dr.product_id=p.product_id)
    ))
  ENDIF
  INTO "nl:"
  p.product_id, p.product_nbr, p.alternate_nbr,
  p.product_sub_nbr, p.product_cd, p.locked_ind,
  pn.product_id, b.cur_abo_cd, b.cur_rh_cd,
  b.supplier_prefix, dr.product_id, tablefrom = decode(b.seq,"b",dr.seq,"d","x")
  FROM product p,
   organization o,
   blood_product b,
   derivative dr,
   product_note pn,
   (dummyt d_pn  WITH seq = 1),
   (dummyt d_pnl  WITH seq = 1),
   prsnl pnl,
   (dummyt d1  WITH seq = 1)
  PLAN (p
   WHERE (request->start_prodnbr != " ")
    AND cnvtupper(request->start_prodnbr)=p.product_nbr)
   JOIN (o
   WHERE o.organization_id=p.cur_supplier_id)
   JOIN (d_pn
   WHERE d_pn.seq=1)
   JOIN (pn
   WHERE pn.product_id=p.product_id
    AND pn.active_ind=1)
   JOIN (d_pnl
   WHERE d_pnl.seq=1)
   JOIN (pnl
   WHERE pnl.person_id=p.updt_id)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (((b
   WHERE b.product_id=p.product_id)
   ) ORJOIN ((dr
   WHERE dr.product_id=p.product_id)
   ))
  ORDER BY p.product_id
  HEAD REPORT
   count1 = 0, max2 = 1
  HEAD p.product_id
   count2 = 0, count1 += 1
  DETAIL
   IF (p.locked_ind=1)
    count3 += 1, stat = alterlist(reply->qual,count3), reply->qual[count3].product_id = p.product_id,
    reply->qual[count3].product_nbr = p.product_nbr, reply->qual[count3].alternate_nbr = p
    .alternate_nbr, reply->qual[count3].product_sub_nbr = p.product_sub_nbr,
    reply->qual[count3].product_cd = p.product_cd, reply->qual[count3].locked_ind = p.locked_ind,
    reply->qual[count3].updt_cnt = p.updt_cnt,
    reply->qual[count3].updt_dt_tm = p.updt_dt_tm, reply->qual[count3].updt_id = p.updt_id, reply->
    qual[count3].updt_task = p.updt_task,
    reply->qual[count3].updt_applctx = p.updt_applctx, reply->qual[count3].unit_of_meas_cd = p
    .cur_unit_meas_cd, reply->qual[count3].cur_owner_area_cd = p.cur_owner_area_cd,
    reply->qual[count3].cur_inv_area_cd = p.cur_inv_area_cd, reply->qual[count3].serial_nbr_txt = p
    .serial_number_txt
    IF (pn.seq=1)
     reply->qual[count3].comments_ind = 1
    ELSE
     reply->qual[count3].comments_ind = 0
    ENDIF
    IF (tablefrom="b")
     reply->qual[count3].cur_abo_cd = b.cur_abo_cd, reply->qual[count3].cur_rh_cd = b.cur_rh_cd,
     reply->qual[count3].volume = b.cur_volume,
     reply->qual[count3].supplier_prefix = b.supplier_prefix
    ELSE
     reply->qual[count3].volume = dr.item_volume
    ENDIF
    IF (p.cur_supplier_id=0)
     reply->qual[count3].supplier_disp = ""
    ELSE
     reply->qual[count3].supplier_disp = o.org_name
    ENDIF
    reply->qual[count3].user_name = pnl.name_full_formatted, reply->qual[count3].app_start_dt_tm = p
    .updt_dt_tm
   ENDIF
  WITH nocounter, dontcare = pn, dontcare = pnl,
   outerjoin = d_pnl
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "N"
 ELSE
  IF (count3=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
