CREATE PROGRAM daf_migrator_cleanup_cso:dba
 IF (validate(request->cso_list,"Z")="Z")
  FREE RECORD request
  RECORD request(
    1 cso_list[*]
      2 cso_pk_id = f8
  )
 ENDIF
 RECORD reply(
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (size(request->cso_list,5) > 0)
  DELETE  FROM ccl_synch_objects cso,
    (dummyt d  WITH seq = value(size(request->cso_list,5)))
   SET cso.seq = 1
   PLAN (d)
    JOIN (cso
    WHERE (cso.ccl_synch_objects_id=request->cso_list[d.seq].cso_pk_id))
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   SET reply->message = concat("Unable to write ccl objects:",errmsg)
   GO TO exit_script
  ENDIF
  COMMIT
  SET reply->status_data.status = "S"
  SET reply->message = "All requested CCL_SYNCH_OBJECTS rows were deleted as expected."
 ELSE
  SET reply->status_data.status = "S"
  SET reply->message = "No records requested for Deletion."
 ENDIF
#exit_script
END GO
