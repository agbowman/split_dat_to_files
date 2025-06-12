CREATE PROGRAM daf_migrator_cleanup_at_cso:dba
 IF (validate(request->obj_list,"Z")="Z")
  FREE RECORD request
  RECORD request(
    1 obj_list[*]
      2 script_name = vc
      2 script_group = i2
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
 IF (size(request->obj_list,5) > 0)
  DELETE  FROM ccl_synch_objects cso,
    (dummyt d  WITH seq = value(size(request->obj_list,5)))
   SET cso.seq = 1
   PLAN (d)
    JOIN (cso
    WHERE cso.object_name=cnvtupper(request->obj_list[d.seq].script_name)
     AND (cso.cclgroup=request->obj_list[d.seq].script_group))
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   SET reply->message = concat("Unable to delete from CCL_SYNCH_OBJECTS:",errmsg)
   GO TO exit_script
  ENDIF
  DELETE  FROM dm_csm_script_info dcsi,
    (dummyt d  WITH seq = value(size(request->obj_list,5)))
   SET dcsi.seq = 1
   PLAN (d)
    JOIN (dcsi
    WHERE (dcsi.script_name=request->obj_list[d.seq].script_name)
     AND (dcsi.script_group=request->obj_list[d.seq].script_group))
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   SET reply->message = concat("Unable to delete from DM_CSM_SCRIPT_INFO:",errmsg)
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
