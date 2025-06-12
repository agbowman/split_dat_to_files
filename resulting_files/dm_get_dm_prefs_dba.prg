CREATE PROGRAM dm_get_dm_prefs:dba
 RECORD reply(
   1 pref_id = f8
   1 application_nbr = i4
   1 person_id = f8
   1 pref_domain = vc
   1 pref_section = vc
   1 pref_name = vc
   1 pref_nbr = i4
   1 pref_cd = f8
   1 pref_dt_tm = dq8
   1 pref_str = vc
   1 parent_entity_id = f8
   1 parent_entity_name = c32
   1 reference_ind = i2
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
 IF ((((request->application_nbr=0)) OR ((request->pref_domain=" "))) )
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM dm_prefs dp
  WHERE (dp.application_nbr=request->application_nbr)
   AND (dp.person_id=request->person_id)
   AND (dp.pref_domain=request->pref_domain)
   AND (dp.pref_section=request->pref_section)
   AND (dp.pref_name=request->pref_name)
  DETAIL
   reply->pref_id = dp.pref_id, reply->application_nbr = dp.application_nbr, reply->pref_domain = dp
   .pref_domain,
   reply->pref_section = dp.pref_section, reply->pref_name = dp.pref_name, reply->parent_entity_id =
   dp.parent_entity_id,
   reply->parent_entity_name = dp.parent_entity_name, reply->person_id = dp.person_id, reply->pref_cd
    = dp.pref_cd,
   reply->pref_dt_tm = dp.pref_dt_tm, reply->pref_nbr = dp.pref_nbr, reply->pref_str = dp.pref_str,
   reply->reference_ind = dp.reference_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DM_PREFS"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DM_PREFS"
  CALL echo(build("error found = ",errormsg))
  SET error_check = error(errormsg,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
