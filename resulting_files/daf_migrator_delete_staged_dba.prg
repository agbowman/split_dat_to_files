CREATE PROGRAM daf_migrator_delete_staged:dba
 IF ((validate(request->environment_id,- (1))=- (1)))
  FREE RECORD request
  RECORD request(
    1 environment_id = f8
    1 list_length = i4
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
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public
 IF ((request->list_length=0))
  SET reply->status_data.status = "S"
  SET reply->message = "No scripts were provided to delete."
  GO TO exit_script
 ENDIF
 DELETE  FROM dm_script_migration_stage dsms,
   (dummyt d  WITH seq = value(request->list_length))
  SET dsms.seq = 1
  PLAN (d)
   JOIN (dsms
   WHERE (dsms.target_environment_id=request->environment_id)
    AND (dsms.script_name=request->obj_list[d.seq].script_name)
    AND (dsms.script_group_nbr=request->obj_list[d.seq].script_group)
    AND dsms.active_ind=1)
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to delete objects:",errmsg)
  GO TO exit_script
 ENDIF
 COMMIT
 SET reply->status_data.status = "S"
 SET reply->message = "All rows successfully deleted."
#exit_script
END GO
