CREATE PROGRAM careplan_migration_deactivate:dba
 FREE RECORD saverequest
 RECORD saverequest(
   1 blob_in = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE blob_in = vc WITH protect, noconstant(
"{'SAVEREQ':{'PERSON_ID':request_person_id,'ENCNTR_ID':request_encounter_id,'OUTCOMES':{'DELETE_IND':1,'OUTCOMEACTID':reque\
st_goal_id,'UPDTCNT':request_update_count}}}\
")
 SET blob_in = replace(blob_in,"request_person_id",request->person_id)
 SET blob_in = replace(blob_in,"request_encounter_id",request->encounter_id)
 SET blob_in = replace(blob_in,"request_goal_id",request->goal_id)
 SET blob_in = replace(blob_in,"request_update_count",request->update_count)
 SET saverequest->blob_in = blob_in
 EXECUTE inn_mp_gwf_save_goals "MINE" WITH replace("REQUEST",saverequest)
END GO
