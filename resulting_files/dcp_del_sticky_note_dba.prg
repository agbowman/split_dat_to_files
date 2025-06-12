CREATE PROGRAM dcp_del_sticky_note:dba
 RECORD reply(
   1 parent_entity_name = vc
   1 parent_entity_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM sticky_note stn
  WHERE (stn.sticky_note_id=request->sticky_note_id)
  DETAIL
   reply->parent_entity_name = stn.parent_entity_name, reply->parent_entity_id = stn.parent_entity_id
  WITH nocounter
 ;end select
 DELETE  FROM sticky_note sn
  WHERE (sn.sticky_note_id=request->sticky_note_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "sticky_note table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "delete"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to delete from table"
  SET failed = "T"
 ENDIF
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
 EXECUTE cclaudit 0, "Maintain Person", "Add Sticky Note",
 "Person", "Patient", "Patient",
 "Permanent_Erasure", reply->parent_entity_id, " "
 SET script_version = "MOD 003 09/21/06 NC014668"
END GO
