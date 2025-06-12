CREATE PROGRAM bbd_get_auto_dir_prod:dba
 RECORD reply(
   1 qual[*]
     2 abo_cd = f8
     2 abo_disp = c40
     2 rh_cd = f8
     2 rh_disp = c40
     2 product_nbr = c20
     2 product_sub_nbr = c5
     2 product_cd = f8
     2 product_disp = c40
     2 cur_inv_area_cd = f8
     2 cur_inv_area_disp = c40
     2 cur_owner_area_cd = f8
     2 cur_owner_area_disp = c40
     2 product_id = f8
     2 event_types[*]
       3 event_type_cd = f8
       3 event_type_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD products(
   1 productlist[*]
     2 product_id = f8
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET prod_counter = 1
 SET nbr_of_prods = size(request->qual,5)
 SET state_count = 0
 DECLARE product_count = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  a.product_id
  FROM auto_directed a,
   product_event pe,
   (dummyt d1  WITH seq = value(nbr_of_prods))
  PLAN (a
   WHERE (a.person_id=request->person_id)
    AND a.associated_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND a.active_ind=1)
   JOIN (d1)
   JOIN (pe
   WHERE pe.product_id=a.product_id
    AND pe.active_ind=1
    AND (pe.event_type_cd=request->qual[d1.seq].event_type_cd))
  ORDER BY a.product_id
  HEAD REPORT
   product_count = 0
  HEAD a.product_id
   product_count = (product_count+ 1)
   IF (size(products->productlist,5) < product_count)
    stat = alterlist(products->productlist,(product_count+ 10))
   ENDIF
   products->productlist[product_count].product_id = a.product_id
  DETAIL
   row + 0
  FOOT  a.product_id
   stat = alterlist(products->productlist,product_count)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.product_id
  FROM (dummyt d1  WITH seq = value(product_count)),
   product p,
   blood_product bp,
   product_event pe
  PLAN (d1)
   JOIN (p
   WHERE (p.product_id=products->productlist[d1.seq].product_id)
    AND p.active_ind=1)
   JOIN (bp
   WHERE bp.product_id=p.product_id
    AND bp.active_ind=1)
   JOIN (pe
   WHERE pe.product_id=bp.product_id
    AND pe.active_ind=1)
  ORDER BY p.product_id
  HEAD REPORT
   count = 0
  HEAD p.product_id
   state_count = 0, count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->qual,(count+ 9))
   ENDIF
   reply->qual[count].abo_cd = bp.cur_abo_cd, reply->qual[count].rh_cd = bp.cur_rh_cd, reply->qual[
   count].product_nbr = p.product_nbr,
   reply->qual[count].product_sub_nbr = p.product_sub_nbr, reply->qual[count].product_cd = p
   .product_cd, reply->qual[count].cur_inv_area_cd = p.cur_inv_area_cd,
   reply->qual[count].cur_owner_area_cd = p.cur_owner_area_cd, reply->qual[count].product_id = p
   .product_id
  DETAIL
   state_count = (state_count+ 1)
   IF (mod(state_count,10)=1)
    stat = alterlist(reply->qual[count].event_types,(state_count+ 9))
   ENDIF
   reply->qual[count].event_types[state_count].event_type_cd = pe.event_type_cd
  FOOT  p.product_id
   stat = alterlist(reply->qual[count].event_types,state_count)
  FOOT REPORT
   stat = alterlist(reply->qual,count)
  WITH nocounter
 ;end select
#exit_script
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD products
END GO
