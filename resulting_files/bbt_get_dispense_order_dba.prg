CREATE PROGRAM bbt_get_dispense_order:dba
 RECORD reply(
   1 qual[1]
     2 order_id = f8
     2 accession = c20
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data[1].status = "F"
 SET anti_cnt = 0
 SET neg_cnt = 0
 SET stat = alter(reply->qual,1)
 SET max_anti = 1
 SET max_neg = 1
 SELECT INTO "nl:"
  o.order_id, a.accession
  FROM orders o,
   accession_order_r a,
   order_lab_blood_bank b
  PLAN (o
   WHERE (o.person_id=request->person_id))
   JOIN (a
   WHERE o.order_id=a.order_id)
   JOIN (b
   WHERE b.order_id=o.order_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   reply->qual[cnt].order_id = o.order_id, reply->qual[cnt].accession = a.accession
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
