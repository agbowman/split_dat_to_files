CREATE PROGRAM daf_migrator_get_at_staged:dba
 RECORD reply(
   1 message = vc
   1 list_length = i4
   1 obj_list[*]
     2 script_name = vc
     2 script_date = dq8
     2 script_group = i2
     2 script_type = vc
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
 IF ((request->environment_id=0))
  SET reply->status_data.status = "F"
  SET reply->message = "There was no environment id chosen for this operation."
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  dacsi.script_name, dacsi.script_group, dacsi.compile_dt_tm,
  dacso.object_type
  FROM dm_adm_csm_script_info dacsi,
   dm_adm_ccl_synch_objects dacso
  WHERE (dacsi.environment_id=request->environment_id)
   AND (dacso.environment_id=request->environment_id)
   AND dacsi.script_name=dacso.object_name
   AND dacsi.script_group=dacso.cclgroup
   AND dacsi.updt_task >= 0
  HEAD REPORT
   loopctr = 0
  DETAIL
   IF (mod(loopctr,100)=0)
    stat = alterlist(reply->obj_list,(loopctr+ 100))
   ENDIF
   loopctr = (loopctr+ 1), reply->obj_list[loopctr].script_name = dacsi.script_name, reply->obj_list[
   loopctr].script_date = cnvtdatetime(dacsi.compile_dt_tm),
   reply->obj_list[loopctr].script_group = dacsi.script_group, reply->obj_list[loopctr].script_type
    = dacso.object_type
  FOOT REPORT
   reply->list_length = loopctr, stat = alterlist(reply->obj_list,loopctr)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to fetch staged objects:",errmsg)
  SET reply->list_length = 0
  SET stat = alterlist(reply->obj_list,0)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reply->message = "No scripts found in the staged table."
  SET reply->list_length = 0
  SET stat = alterlist(reply->obj_list,0)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->message = "Successfully retrieved objects from the Staged table."
#exit_script
END GO
