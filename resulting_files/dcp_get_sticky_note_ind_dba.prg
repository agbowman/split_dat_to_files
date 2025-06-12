CREATE PROGRAM dcp_get_sticky_note_ind:dba
 RECORD reply(
   1 sticky_note_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->sticky_note_ind = 1
 SELECT INTO "nl:"
  sn.sticky_note_id
  FROM sticky_note sn
  WHERE (sn.sticky_note_type_cd=request->sticky_note_type_cd)
   AND (sn.parent_entity_name=request->parent_entity_name)
   AND (sn.parent_entity_id=request->parent_entity_id)
  DETAIL
   row + 1
  WITH nocounter, maxqual(sn,1)
 ;end select
 IF (curqual=0)
  SET reply->sticky_note_ind = 0
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->sticky_note_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
