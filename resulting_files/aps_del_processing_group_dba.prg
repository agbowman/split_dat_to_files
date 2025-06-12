CREATE PROGRAM aps_del_processing_group:dba
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
   AND agi.parent_entity_name="CODE_VALUE"
  HEAD REPORT
   number_to_del = 0
  DETAIL
   number_to_del += 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  agi.parent_entity_id
  FROM ap_processing_grp_r agi
  WHERE (request->parent_entity_id=agi.parent_entity_id)
   AND agi.parent_entity_name="CODE_VALUE"
  WITH forupdate(agi)
 ;end select
 IF (curqual != number_to_del)
  SET errors = "L"
  SET table_error = "AGI"
  GO TO check_error
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE (request->parent_entity_id=cv.code_value)
   AND cv.code_set=1310
  WITH forupdate(cv)
 ;end select
 IF (curqual=0)
  SET errors = "L"
  SET table_error = "CV"
  GO TO check_error
 ENDIF
 DELETE  FROM ap_processing_grp_r agi,
   (dummyt d  WITH seq = value(number_to_del))
  SET agi.parent_entity_id = request->parent_entity_id, agi.parent_entity_name = "CODE_VALUE"
  PLAN (d)
   JOIN (agi
   WHERE (agi.parent_entity_id=request->parent_entity_id)
    AND agi.parent_entity_name="CODE_VALUE")
  WITH nocounter
 ;end delete
 IF (curqual != number_to_del)
  SET errors = "D"
  SET table_error = "AGI"
  GO TO check_error
 ENDIF
 IF (curqual > 0)
  DELETE  FROM ap_prefix_proc_grp_r appg
   WHERE (appg.processing_grp_cd=request->parent_entity_id)
   WITH nocounter
  ;end delete
 ENDIF
 DELETE  FROM code_value cv
  WHERE (cv.code_value=request->parent_entity_id)
   AND cv.code_set=1310
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET errors = "D"
  SET table_error = "CV"
  GO TO check_error
 ENDIF
 GO TO exit_script
#check_error
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 IF (table_error="AGI")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_PROCESSING_GRP_R"
 ELSE
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
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
