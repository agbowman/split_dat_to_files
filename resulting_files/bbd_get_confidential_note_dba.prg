CREATE PROGRAM bbd_get_confidential_note:dba
 RECORD reply(
   1 confidential_id = f8
   1 confidential_updt_cnt = i4
   1 long_text_id = f8
   1 long_text = vc
   1 long_text_updt_cnt = i4
   1 create_dt_tm = di8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  b.*
  FROM bbd_confidential_note b,
   long_text l
  PLAN (b
   WHERE (b.person_id=request->person_id)
    AND b.active_ind=1)
   JOIN (l
   WHERE l.long_text_id=b.long_text_id
    AND l.parent_entity_name="BBD_CONFIDENTIAL_NOTE"
    AND l.active_ind=1)
  DETAIL
   reply->confidential_id = b.confidential_id, reply->confidential_updt_cnt = b.updt_cnt, reply->
   long_text_id = l.long_text_id,
   reply->long_text = l.long_text, reply->long_text_updt_cnt = l.updt_cnt
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
