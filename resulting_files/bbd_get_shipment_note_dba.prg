CREATE PROGRAM bbd_get_shipment_note:dba
 RECORD reply(
   1 shipment_updt_cnt = i4
   1 long_text_id = f8
   1 long_text = vc
   1 long_text_updt_cnt = i4
   1 create_dt_tm = di8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  s.updt_cnt, l.long_text_id, l.long_text,
  l.updt_cnt
  FROM bb_shipment s,
   long_text l
  PLAN (s
   WHERE (s.shipment_id=request->shipment_id)
    AND s.active_ind=1)
   JOIN (l
   WHERE l.long_text_id=s.long_text_id
    AND l.parent_entity_name="BB_SHIPMENT"
    AND l.active_ind=1)
  DETAIL
   reply->shipment_updt_cnt = s.updt_cnt, reply->long_text_id = l.long_text_id, reply->long_text = l
   .long_text,
   reply->long_text_updt_cnt = l.updt_cnt
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
