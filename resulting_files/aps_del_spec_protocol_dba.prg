CREATE PROGRAM aps_del_spec_protocol:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET errors = " "
 SET number_to_del = 0
 SET reply->status_data.status = "F"
 SET table_error = " "
 SELECT INTO "nl:"
  agi.parent_entity_id
  FROM ap_processing_grp_r agi
  WHERE (agi.parent_entity_id=request->parent_entity_id)
   AND agi.parent_entity_name="AP_SPECIMEN_PROTOCOL"
  HEAD REPORT
   number_to_del = 0
  DETAIL
   number_to_del = (number_to_del+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  agi.parent_entity_id
  FROM ap_processing_grp_r agi
  WHERE (request->parent_entity_id=agi.parent_entity_id)
   AND agi.parent_entity_name="AP_SPECIMEN_PROTOCOL"
  WITH forupdate(agi)
 ;end select
 IF (curqual != number_to_del)
  SET errors = "L"
  SET table_error = "AGI"
  GO TO check_error
 ENDIF
 SELECT INTO "nl:"
  asp.protocol_id
  FROM ap_specimen_protocol asp
  WHERE (request->parent_entity_id=asp.protocol_id)
  WITH forupdate(asp)
 ;end select
 IF (curqual=0)
  SET errors = "L"
  SET table_error = "ASP"
  GO TO check_error
 ENDIF
 DELETE  FROM ap_processing_grp_r agi,
   (dummyt d  WITH seq = value(number_to_del))
  SET agi.parent_entity_id = request->parent_entity_id, agi.parent_entity_name =
   "AP_SPECIMEN_PROTOCOL"
  PLAN (d)
   JOIN (agi
   WHERE (agi.parent_entity_id=request->parent_entity_id)
    AND agi.parent_entity_name="AP_SPECIMEN_PROTOCOL")
  WITH nocounter
 ;end delete
 IF (curqual != number_to_del)
  SET errors = "D"
  SET table_error = "AGI"
  GO TO check_error
 ENDIF
 DELETE  FROM ap_specimen_protocol asp
  WHERE (asp.protocol_id=request->parent_entity_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET errors = "D"
  SET table_error = "ASP"
  GO TO check_error
 ENDIF
 GO TO exit_script
#check_error
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 IF (table_error="AGI")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PROCESSING_GRP_R"
 ELSE
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_SPECIMEN_PROTOCOL"
 ENDIF
 IF (errors="L")
  SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 ELSEIF (error="U")
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 ENDIF
 SET failed = "T"
 ROLLBACK
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
