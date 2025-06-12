CREATE PROGRAM bb_get_duplicate_isbt_alias
 RECORD reply(
   1 product_list[*]
     2 product_cd = f8
     2 duplicate_list[*]
       3 isbt_barcode = c15
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE count1 = i2 WITH nonconstant
 DECLARE count2 = i2 WITH nonconstant
 SET count1 = 0
 SET count2 = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  b.isbt_barcode, b.product_cd, pi.autologous_ind,
  pi.directed_ind, pi.product_cd, b1.product_cd
  FROM (dummyt d1  WITH seq = value(size(request->product_list,5))),
   bb_isbt_product_type b,
   bb_isbt_product_type b1,
   product_index pi
  PLAN (d1)
   JOIN (b
   WHERE (b.product_cd=request->product_list[d1.seq].product_cd)
    AND b.active_ind=1)
   JOIN (b1
   WHERE b1.isbt_barcode=b.isbt_barcode
    AND b1.product_cd != b.product_cd
    AND b1.active_ind=1)
   JOIN (pi
   WHERE pi.product_cd=b1.product_cd
    AND (((pi.autologous_ind=request->product_list[d1.seq].autologous_ind)
    AND (pi.directed_ind=request->product_list[d1.seq].directed_ind)
    AND (pi.aliquot_ind=request->product_list[d1.seq].aliquot_ind)) OR ((pi.aliquot_ind=request->
   product_list[d1.seq].aliquot_ind)
    AND ((pi.autologous_ind=1
    AND (request->product_list[d1.seq].autologous_ind=1)) OR (pi.directed_ind=1
    AND (request->product_list[d1.seq].directed_ind=1))) )) )
  ORDER BY b.product_cd, b.isbt_barcode
  HEAD b.product_cd
   count1 = (count1+ 1), stat = alterlist(reply->product_list,count1), reply->product_list[count1].
   product_cd = b.product_cd,
   count2 = 0
  HEAD b.isbt_barcode
   count2 = (count2+ 1), stat = alterlist(reply->product_list[count1].duplicate_list,count2), reply->
   product_list[count1].duplicate_list[count2].isbt_barcode = b1.isbt_barcode
  FOOT  b.isbt_barcode
   row + 1
  FOOT  b.product_cd
   row + 1
  WITH nocounter
 ;end select
 IF (size(reply->product_list,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
