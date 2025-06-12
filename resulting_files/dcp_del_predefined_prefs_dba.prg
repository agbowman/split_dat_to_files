CREATE PROGRAM dcp_del_predefined_prefs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DELETE  FROM name_value_prefs nv
  WHERE nv.parent_entity_name="PREDEFINED_PREFS"
   AND (nv.parent_entity_id=request->predefined_prefs_id)
  WITH nocounter
 ;end delete
 DELETE  FROM predefined_prefs pp
  WHERE (pp.predefined_prefs_id=request->predefined_prefs_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 COMMIT
END GO
