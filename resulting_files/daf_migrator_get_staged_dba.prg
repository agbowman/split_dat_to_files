CREATE PROGRAM daf_migrator_get_staged:dba
 RECORD reply(
   1 message = vc
   1 list_length = i4
   1 obj_list[*]
     2 script_name = vc
     2 script_group = i2
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
 IF ((validate(request->environment_id,- (1))=- (1)))
  SET reply->status_data.status = "F"
  SET reply->message = "Request structure not defined."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_script_migration_stage dsms
  WHERE (dsms.target_environment_id=request->environment_id)
   AND dsms.active_ind=1
  HEAD REPORT
   loopctr = 0
  DETAIL
   IF (mod(loopctr,10)=0)
    stat = alterlist(reply->obj_list,(loopctr+ 10))
   ENDIF
   loopctr = (loopctr+ 1), reply->obj_list[loopctr].script_name = dsms.script_name, reply->obj_list[
   loopctr].script_group = dsms.script_group_nbr
  FOOT REPORT
   reply->list_length = loopctr, stat = alterlist(reply->obj_list,loopctr)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to fetch committed objects:",errmsg)
  SET reply->list_length = 0
  SET stat = alterlist(reply->obj_list,0)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "S"
  SET reply->message = "No scripts were found for migration."
  SET reply->list_length = 0
  SET stat = alterlist(reply->obj_list,0)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->message = "Successfully retrieved objects from the CCL Dictionary"
#exit_script
END GO
