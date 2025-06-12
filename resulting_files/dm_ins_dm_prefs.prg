CREATE PROGRAM dm_ins_dm_prefs
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET errormsg = fillstring(132," ")
 SET error_check = 0
 INSERT  FROM dm_prefs dp
  SET dp.pref_id = seq(dm_clinical_seq,nextval), dp.application_nbr = request->application_nbr, dp
   .parent_entity_id = request->parent_entity_id,
   dp.parent_entity_name = request->parent_entity_name, dp.person_id = request->person_id, dp.pref_cd
    = request->pref_cd,
   dp.pref_domain = request->pref_domain, dp.pref_dt_tm = cnvtdatetime(request->pref_dt_tm), dp
   .pref_name = request->pref_name,
   dp.pref_nbr = request->pref_nbr, dp.pref_str = request->pref_str, dp.pref_section = request->
   pref_section,
   dp.reference_ind = request->reference_ind, dp.updt_cnt = 0, dp.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   dp.updt_id = reqinfo->updt_id, dp.updt_task = reqinfo->updt_task, dp.updt_applctx = reqinfo->
   updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "INSERT PREFS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DM_INS_DM_REFS"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  CALL echo(build("error found = ",errormsg))
  SET error_check = error(errormsg,0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ELSE
  COMMIT
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
