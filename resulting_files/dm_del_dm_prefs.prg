CREATE PROGRAM dm_del_dm_prefs
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET errormsg = fillstring(132," ")
 SET error_check = 0
 SET reply->status_data.status = "F"
 SET failed = "F"
 IF ((validate(req_del_xpk_dm_prefs->pref_id,- (1))=- (1)))
  DELETE  FROM dm_prefs
   WHERE (pref_id=req_del_xpk_dm_prefs->pref_id)
   WITH nocounter
  ;end delete
 ELSEIF ((validate(req_del_xak1_dm_prefs->application_nbr,- (1))=- (1)))
  DELETE  FROM dm_prefs
   WHERE (application_nbr=req_del_xak1_dm_prefs->application_nbr)
    AND (person_id=req_del_xak1_dm_prefs->person_id)
    AND (pref_domain=req_del_xak1_dm_prefs->pref_domain)
    AND (pref_section=req_del_xak1_dm_prefs->pref_section)
    AND (pref_name=req_del_xak1_dm_prefs->pref_name)
   WITH nocounter
  ;end delete
 ELSE
  DELETE  FROM dm_prefs
   WHERE (pref_domain=req_del_xie1_dm_prefs->pref_domain)
    AND (pref_section=req_del_xie1_dm_prefs->pref_section)
    AND (pref_name=req_del_xie1_dm_prefs->pref_name)
   WITH nocounter
  ;end delete
 ENDIF
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
  CALL echo(build("error found = ",errormsg))
  SET error_check = error(errormsg,0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
