CREATE PROGRAM acm_get_org_config:dba
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
   DECLARE scur_trust = vc
   DECLARE pref_val = vc
   DECLARE is_enabled = i4 WITH constant(1)
   DECLARE is_disabled = i4 WITH constant(0)
   SET scur_trust = cnvtstring(dtrustid)
   SET scur_trust = concat(scur_trust,".00")
   IF ( NOT (validate(pref_req,0)))
    RECORD pref_req(
      1 write_ind = i2
      1 delete_ind = i2
      1 pref[*]
        2 contexts[*]
          3 context = vc
          3 context_id = vc
        2 section = vc
        2 section_id = vc
        2 subgroup = vc
        2 entries[*]
          3 entry = vc
          3 values[*]
            4 value = vc
    )
   ENDIF
   IF ( NOT (validate(pref_rep,0)))
    RECORD pref_rep(
      1 pref[*]
        2 section = vc
        2 section_id = vc
        2 subgroup = vc
        2 entries[*]
          3 pref_exists_ind = i2
          3 entry = vc
          3 values[*]
            4 value = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
   ENDIF
   SET stat = alterlist(pref_req->pref,1)
   SET stat = alterlist(pref_req->pref[1].contexts,2)
   SET stat = alterlist(pref_req->pref[1].entries,1)
   SET pref_req->pref[1].contexts[1].context = "organization"
   SET pref_req->pref[1].contexts[1].context_id = scur_trust
   SET pref_req->pref[1].contexts[2].context = "default"
   SET pref_req->pref[1].contexts[2].context_id = "system"
   SET pref_req->pref[1].section = "workflow"
   SET pref_req->pref[1].section_id = "UK Trust Security"
   SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
   EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
   IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
    RETURN(is_enabled)
   ELSE
    RETURN(is_disabled)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getrbacmodepref(dtrustid=f8) =i4)
   DECLARE scur_trust = vc
   DECLARE pref_val = vc
   DECLARE is_legacy = i4 WITH constant(0)
   DECLARE is_activity = i4 WITH constant(1)
   SET scur_trust = cnvtstring(dtrustid)
   SET scur_trust = concat(scur_trust,".00")
   IF ( NOT (validate(pref_req,0)))
    RECORD pref_req(
      1 write_ind = i2
      1 delete_ind = i2
      1 pref[*]
        2 contexts[*]
          3 context = vc
          3 context_id = vc
        2 section = vc
        2 section_id = vc
        2 subgroup = vc
        2 entries[*]
          3 entry = vc
          3 values[*]
            4 value = vc
    )
   ENDIF
   IF ( NOT (validate(pref_rep,0)))
    RECORD pref_rep(
      1 pref[*]
        2 section = vc
        2 section_id = vc
        2 subgroup = vc
        2 entries[*]
          3 pref_exists_ind = i2
          3 entry = vc
          3 values[*]
            4 value = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
   ENDIF
   SET stat = alterlist(pref_req->pref,1)
   SET stat = alterlist(pref_req->pref[1].contexts,2)
   SET stat = alterlist(pref_req->pref[1].entries,1)
   SET pref_req->pref[1].contexts[1].context = "organization"
   SET pref_req->pref[1].contexts[1].context_id = scur_trust
   SET pref_req->pref[1].contexts[2].context = "default"
   SET pref_req->pref[1].contexts[2].context_id = "system"
   SET pref_req->pref[1].section = "workflow"
   SET pref_req->pref[1].section_id = "UK Trust Security"
   SET pref_req->pref[1].entries[1].entry = "rbac mode"
   EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
   IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ACTIVITY CODES")
    RETURN(is_activity)
   ELSE
    RETURN(is_legacy)
   ENDIF
 END ;Subroutine
 IF (validate(reply)=0)
  RECORD reply(
    1 dynamic_org_security_enabled = i2
    1 rbac_mode_flag = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 IF ((request->organization_id <= 0.0))
  SET reply->status_data.subeventstatus[1].targetobjectname = "REQUEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid org_id"
  GO TO exit_script
 ENDIF
 SET reply->dynamic_org_security_enabled = getdynamicorgpref(request->organization_id)
 SET reply->rbac_mode_flag = getrbacmodepref(request->organization_id)
 SET reply->status_data.status = "S"
#exit_script
END GO
