CREATE PROGRAM bbt_get_product_note:dba
 IF ((request->no_reply_ind != 1))
  RECORD reply(
    1 product_nbr = vc
    1 product_cd = f8
    1 product_disp = c40
    1 qual[1]
      2 product_note_id = f8
      2 product_note = vc
      2 updt_cnt = i4
      2 long_text_id = f8
      2 long_text_updt_cnt = i4
    1 historical_product_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  RECORD reply(
    1 product_note_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD reply_hd(
   1 product_nbr = vc
   1 product_cd = f8
   1 product_disp = c40
   1 qual[1]
     2 product_note_id = f8
     2 product_note = vc
     2 updt_cnt = i4
     2 long_text_id = f8
     2 long_text_updt_cnt = i4
   1 product_note_ind = i2
   1 historical_product_ind = i2
 )
 SET reply->status_data.status = "F"
 SET note_cnt = 0
 SET note = 0
 SET count1 = 0
#begin_main
 SET reply->status_data.status = "I"
 SELECT INTO "nl:"
  p.product_nbr, p.product_cd, p.product_sub_nbr,
  bp.supplier_prefix, pn.product_note_id, pn.updt_cnt,
  lt.long_text_id, lt.updt_cnt, lt.long_text
  FROM product p,
   blood_product bp,
   product_note pn,
   long_text lt
  PLAN (p
   WHERE (p.product_id=request->product_id))
   JOIN (bp
   WHERE bp.product_id=outerjoin(p.product_id)
    AND bp.active_ind=outerjoin(1))
   JOIN (pn
   WHERE pn.product_id=outerjoin(p.product_id)
    AND pn.active_ind=outerjoin(1))
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(pn.long_text_id)
    AND lt.active_ind=outerjoin(1))
  ORDER BY p.product_id, pn.product_note_id
  HEAD REPORT
   note_cnt = 0
  HEAD p.product_id
   IF ((request->no_reply_ind != 1))
    reply_hd->product_nbr = concat(trim(bp.supplier_prefix),trim(p.product_nbr)," ",trim(p
      .product_sub_nbr)), reply_hd->product_cd = p.product_cd, reply_hd->historical_product_ind = 0
   ENDIF
  HEAD pn.product_note_id
   IF (pn.product_note_id > 0.0)
    note_cnt = (note_cnt+ 1)
    IF (note_cnt=1)
     IF ((request->no_reply_ind != 1))
      reply_hd->qual[note_cnt].product_note_id = pn.product_note_id, reply_hd->qual[note_cnt].
      updt_cnt = pn.updt_cnt, reply_hd->qual[note_cnt].long_text_id = lt.long_text_id,
      reply_hd->qual[note_cnt].long_text_updt_cnt = lt.updt_cnt, reply_hd->qual[note_cnt].
      product_note = lt.long_text
     ELSE
      reply_hd->product_note_ind = 1
     ENDIF
    ELSE
     IF ((request->no_reply_ind=1))
      reply_hd->product_note_ind = 0
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   row + 0
  FOOT  pn.product_note_id
   row + 0
  FOOT  p.product_id
   row + 0
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   bbhp.product_nbr, bbhp.product_cd, pn.product_note_id,
   pn.updt_cnt, lt.long_text_id, lt.updt_cnt,
   lt.long_text
   FROM bbhist_product bbhp,
    product_note pn,
    long_text lt
   PLAN (bbhp
    WHERE (bbhp.product_id=request->product_id))
    JOIN (pn
    WHERE pn.bbhist_product_id=outerjoin(bbhp.product_id)
     AND pn.active_ind=outerjoin(1))
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(pn.long_text_id)
     AND lt.active_ind=outerjoin(1))
   ORDER BY bbhp.product_id, pn.product_note_id
   HEAD REPORT
    note_cnt = 0
   HEAD bbhp.product_id
    IF ((request->no_reply_ind != 1))
     reply_hd->product_nbr = concat(trim(bbhp.supplier_prefix),trim(bbhp.product_nbr)," ",trim(bbhp
       .product_sub_nbr)), reply_hd->product_cd = bbhp.product_cd, reply_hd->historical_product_ind
      = 1
    ENDIF
   HEAD pn.product_note_id
    IF (pn.product_note_id > 0.0)
     note_cnt = (note_cnt+ 1)
     IF (note_cnt=1)
      IF ((request->no_reply_ind != 1))
       reply_hd->qual[note_cnt].product_note_id = pn.product_note_id, reply_hd->qual[note_cnt].
       updt_cnt = pn.updt_cnt, reply_hd->qual[note_cnt].long_text_id = lt.long_text_id,
       reply_hd->qual[note_cnt].long_text_updt_cnt = lt.updt_cnt, reply_hd->qual[note_cnt].
       product_note = lt.long_text
      ELSE
       reply_hd->product_note_ind = 1
      ENDIF
     ELSE
      IF ((request->no_reply_ind=1))
       reply_hd->product_note_ind = 0
      ENDIF
     ENDIF
    ENDIF
   DETAIL
    row + 0
   FOOT  pn.product_note_id
    row + 0
   FOOT  bbhp.product_id
    row + 0
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alter(reply_hd->qual,note_cnt)
 IF ((request->no_reply_ind != 1))
  SET reply->product_nbr = reply_hd->product_nbr
  SET reply->product_cd = reply_hd->product_cd
  SET reply->historical_product_ind = reply_hd->historical_product_ind
  SET stat = alter(reply->qual,note_cnt)
  FOR (note = 1 TO note_cnt)
    SET reply->qual[note].product_note_id = reply_hd->qual[note].product_note_id
    SET reply->qual[note].updt_cnt = reply_hd->qual[note].updt_cnt
    SET reply->qual[note].long_text_id = reply_hd->qual[note].long_text_id
    SET reply->qual[note].long_text_updt_cnt = reply_hd->qual[note].updt_cnt
    SET reply->qual[note].product_note = reply_hd->qual[note].product_note
  ENDFOR
 ELSE
  SET reply->product_note_ind = reply_hd->product_note_ind
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET count1 = (count1+ 1)
  IF (count1 > size(reply->status_data.subeventstatus,5))
   SET stat = alter(reply->status_data,count1)
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get product_note"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "get product/product notes"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = build("invalid product_id:  ",
   request->product_id)
 ELSE
  IF (note_cnt > 1)
   SET reply->status_data.status = "F"
   SET count1 = (count1+ 1)
   IF (count1 > size(reply->status_data.subeventstatus,5))
    SET stat = alter(reply->status_data,count1)
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].operationname = "get product_note row"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "multiple active proudct_note rows exist for product_id"
  ENDIF
 ENDIF
 GO TO exit_script
#end_main
#exit_script
 IF ((reply->status_data.status != "F"))
  SET count1 = (count1+ 1)
  IF (count1 > size(reply->status_data.subeventstatus,5))
   SET stat = alter(reply->status_data.subeventstatus,count1)
  ENDIF
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_product_note"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = ""
  IF (note_cnt > 0)
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationname = "Success"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[count1].operationname = "Zero"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "No product_note rows for product_id"
   SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
  ENDIF
 ENDIF
END GO
