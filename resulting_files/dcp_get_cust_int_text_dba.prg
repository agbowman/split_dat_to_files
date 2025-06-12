CREATE PROGRAM dcp_get_cust_int_text:dba
 FREE SET reply
 RECORD reply(
   1 messages[*]
     2 entity_reltn_id = f8
     2 long_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE number_to_get = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SET number_to_get = size(request->entity_reltn_ids,5)
 IF (number_to_get < 1)
  CALL echo("There are no entity_reltn_ids to select against.")
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  l.long_text, l.parent_entity_id, l.parent_entity_name
  FROM long_text l,
   (dummyt d  WITH seq = value(number_to_get))
  PLAN (d)
   JOIN (l
   WHERE l.parent_entity_name="DCP_ENTITY_RELTN"
    AND (l.parent_entity_id=request->entity_reltn_ids[d.seq].dcp_entity_reltn_id))
  HEAD REPORT
   stat = alterlist(reply->messages,10), msg_cnt = 0
  DETAIL
   msg_cnt = (msg_cnt+ 1)
   IF (mod(msg_cnt,10)=1
    AND msg_cnt != 1)
    stat = alterlist(reply->messages,(msg_cnt+ 9))
   ENDIF
   reply->messages[msg_cnt].long_text = l.long_text, reply->messages[msg_cnt].entity_reltn_id =
   request->entity_reltn_ids[d.seq].dcp_entity_reltn_id
  FOOT REPORT
   stat = alterlist(reply->messages,msg_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
