CREATE PROGRAM ct_clear_user_pref:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE fac_group_id = f8 WITH protect, noconstant(0)
 DECLARE user_pref_id = f8 WITH protect, noconstant(0)
 DECLARE shared_filter = f8 WITH protect, noconstant(0)
 DECLARE clear_pref_error = i2 WITH private, constant(30)
 DECLARE clear_facilities_error = i2 WITH private, constant(40)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM ct_user_preference cup
  WHERE (cup.prsnl_id=request->prsnl_id)
   AND (cup.prot_master_id=request->prot_id)
   AND cup.active_ind=1
  DETAIL
   fac_group_id = cup.ct_facility_cd_group_id, user_pref_id = cup.ct_user_preference_id
  WITH nocounter
 ;end select
 CALL echo(build("fac groupd id:",fac_group_id))
 CALL echo(build("user pref id:",user_pref_id))
 SELECT INTO "nl:"
  FROM ct_user_preference cup
  WHERE cup.ct_facility_cd_group_id=fac_group_id
  DETAIL
   IF ((cup.prsnl_id != request->prsnl_id))
    shared_filter = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("shared filter:",shared_filter))
 IF (user_pref_id != 0)
  DELETE  FROM ct_user_preference cup
   WHERE cup.ct_user_preference_id=user_pref_id
   WITH nocounter
  ;end delete
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error updating into ct_user_preference table."
  SET fail_flag = clear_pref_error
  GO TO check_error
 ENDIF
 IF (fac_group_id != 0
  AND shared_filter=0)
  DELETE  FROM ct_facility_cd_group cfcg
   WHERE cfcg.facility_group_id=fac_group_id
   WITH nocounter
  ;end delete
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error updating into ct_facility_cd_group table."
  SET fail_flag = clear_facilities_error
  GO TO check_error
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF clear_pref_error:
    SET reply->status_data.subeventstatus[1].operationname = "CLEAR_PREF"
    SET reply->status_data.subeventstatus[1].operationstatus = "CP"
   OF clear_facilities_error:
    SET reply->status_data.subeventstatus[1].operationname = "CLEAR_FACILITIES"
    SET reply->status_data.subeventstatus[1].operationstatus = "CF"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "000"
 SET mod_date = "June 29, 2021"
END GO
