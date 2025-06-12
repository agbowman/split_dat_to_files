CREATE PROGRAM bbt_get_crossmatch:dba
 RECORD reply(
   1 product_event_id = f8
   1 product_id = f8
   1 person_id = f8
   1 crossmatch_exp_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  c.seq
  FROM crossmatch c
  WHERE (c.product_event_id=request->product_event_id)
   AND (c.product_id=request->product_id)
  DETAIL
   reply->product_event_id = c.product_event_id, reply->product_id = c.product_id, reply->person_id
    = c.person_id,
   reply->crossmatch_exp_dt_tm = cnvtdatetime(c.crossmatch_exp_dt_tm), count1 += 1
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
