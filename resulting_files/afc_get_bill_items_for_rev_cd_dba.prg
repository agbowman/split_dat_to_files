CREATE PROGRAM afc_get_bill_items_for_rev_cd:dba
 SET afc_get_bill_items_for_rev_cd = "004"
 RECORD reply(
   1 lbill_items_qual = i4
   1 bill_items[*]
     2 bill_item_id = f8
     2 price_sched_id = f8
     2 price_sched_items_id = f8
     2 ext_description = vc
     2 exclusive_ind = i2
     2 tax = f8
     2 price = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE mdbillcd = f8 WITH noconstant(0.0)
 DECLARE mdrevenuecd = f8 WITH noconstant(0.0)
 DECLARE lcount = i4 WITH noconstant(0)
 CALL uar_get_meaning_by_codeset(13019,nullterm("BILL CODE"),1,mdbillcd)
 CALL uar_get_meaning_by_codeset(14002,nullterm("REVENUE"),1,mdrevenuecd)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM bill_item_modifier bim,
   bill_item bi,
   price_sched_items psi
  PLAN (bim
   WHERE bim.bill_item_type_cd=mdbillcd
    AND bim.key1_id=mdrevenuecd
    AND (bim.key5_id=request->rev_cd)
    AND bim.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND bim.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND bim.active_ind=1)
   JOIN (bi
   WHERE bi.bill_item_id=bim.bill_item_id
    AND bi.active_ind=1)
   JOIN (psi
   WHERE psi.bill_item_id=bi.bill_item_id
    AND psi.price_sched_id > 0
    AND psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND psi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND psi.active_ind=1)
  ORDER BY psi.bill_item_id
  HEAD psi.bill_item_id
   CALL echo("Head"), lcount = (lcount+ 1), reply->lbill_items_qual = lcount,
   stat = alterlist(reply->bill_items,lcount), reply->bill_items[lcount].bill_item_id = bi
   .bill_item_id, reply->bill_items[lcount].ext_description = bi.ext_description,
   reply->bill_items[lcount].exclusive_ind = 1, reply->bill_items[lcount].tax = psi.tax, reply->
   bill_items[lcount].price_sched_id = psi.price_sched_id,
   reply->bill_items[lcount].price_sched_items_id = psi.price_sched_items_id, reply->bill_items[
   lcount].price = psi.price
  DETAIL
   IF (psi.exclusive_ind=0)
    reply->bill_items[lcount].exclusive_ind = psi.exclusive_ind
   ENDIF
   IF (psi.tax=0)
    reply->bill_items[lcount].tax = psi.tax
   ENDIF
  WITH nocounter
 ;end select
 SET reply->lbill_items_qual = lcount
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO end_program
 ENDIF
#end_program
END GO
