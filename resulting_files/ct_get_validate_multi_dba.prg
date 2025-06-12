CREATE PROGRAM ct_get_validate_multi:dba
 SET modify = predeclare
 RECORD reply(
   1 bfound = i2
   1 bnotargetfound = i2
   1 bfound2 = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE stat = i2 WITH private, noconstant(0)
 DECLARE coordinst_cd = f8 WITH protect, noconstant(0.0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE target_found = i2 WITH protect, noconstant(0)
 DECLARE yes_cd = f8 WITH public, noconstant(0.0)
 DECLARE get_coord_inst = i2 WITH protect, noconstant(false)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE trialwide_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"TRIALWIDE"))
 DECLARE def_org_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"DEFAULTORG"))
 DECLARE track_tw_accrual = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET reply->bfound = false
 SET get_coord_inst = true
 SET stat = uar_get_meaning_by_codeset(17441,"COORDINST",1,coordinst_cd)
 SET stat = uar_get_meaning_by_codeset(17438,"YES",1,yes_cd)
 IF ((request->prot_amendment_id > 0))
  IF ((request->validate_multi_only=true))
   SELECT INTO "nl:"
    FROM prot_amendment pa,
     ct_prot_type_config cfg
    PLAN (pa
     WHERE (pa.prot_amendment_id=request->prot_amendment_id))
     JOIN (cfg
     WHERE cfg.protocol_type_cd=pa.participation_type_cd
      AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND ((cfg.item_cd=trialwide_cd) OR (cfg.item_cd=def_org_cd))
      AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
    DETAIL
     IF (((cfg.item_cd=trialwide_cd
      AND uar_get_code_meaning(cfg.config_value_cd)="YES") OR (cfg.item_cd=def_org_cd
      AND uar_get_code_meaning(cfg.config_value_cd)="YES")) )
      track_tw_accrual += 1
     ENDIF
    WITH nocounter
   ;end select
   IF (track_tw_accrual=2)
    SET get_coord_inst = true
   ENDIF
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET fail_flag = 1
    GO TO leave_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ELSE
   SELECT INTO "nl:"
    FROM prot_amendment pa,
     ct_prot_type_config cfg
    PLAN (pa
     WHERE (pa.prot_amendment_id=request->prot_amendment_id))
     JOIN (cfg
     WHERE cfg.protocol_type_cd=pa.participation_type_cd
      AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND ((cfg.item_cd=trialwide_cd) OR (cfg.item_cd=def_org_cd))
      AND (cfg.logical_domain_id=domain_reply->logical_domain_id))
    DETAIL
     IF (((cfg.item_cd=trialwide_cd
      AND uar_get_code_meaning(cfg.config_value_cd)="YES") OR (cfg.item_cd=def_org_cd
      AND uar_get_code_meaning(cfg.config_value_cd)="YES")) )
      track_tw_accrual += 1
     ENDIF
     IF (track_tw_accrual=2)
      IF (pa.accrual_required_indc_cd=yes_cd)
       CALL echo(build("group ",pa.groupwide_targeted_accrual)),
       CALL echo(build("target ",pa.targeted_accrual))
       IF (pa.groupwide_targeted_accrual > 0)
        IF (pa.targeted_accrual > 0)
         target_found = true
        ELSE
         target_found = false
        ENDIF
       ELSE
        target_found = false
       ENDIF
       IF (target_found=false)
        get_coord_inst = true
       ELSE
        get_coord_inst = false
       ENDIF
      ELSE
       get_coord_inst = false
      ENDIF
     ELSE
      get_coord_inst = false
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(curqual)
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET fail_flag = 1
    GO TO leave_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
  IF (get_coord_inst=true)
   DECLARE orgid = f8 WITH protect, noconstant(0.0)
   DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
   DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
   RECORD pref_request(
     1 pref_entry = vc
   )
   RECORD pref_reply(
     1 pref_value = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   IF (size(request->pref_name,1) > 0)
    SELECT INTO "nl:"
     dp.pref_nbr
     FROM dm_prefs dp
     PLAN (dp
      WHERE (dp.application_nbr=request->application_nbr)
       AND (dp.pref_domain=request->pref_domain)
       AND (dp.pref_name=request->pref_name)
       AND (dp.pref_section=request->pref_section))
     DETAIL
      IF (dp.pref_id > 0)
       orgid = dp.pref_nbr
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     IF (orgid=0.0)
      SET reply->status_data.status = "F"
     ELSE
      SET reply->status_data.status = "Z"
     ENDIF
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
   ELSE
    SET pref_request->pref_entry = "default_org"
    EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
    CALL echo(pref_reply->pref_value)
    IF ((pref_reply->pref_value > 0))
     SET orgid = cnvtreal(pref_reply->pref_value)
     SET reply->status_data.status = "S"
    ELSE
     SET reply->status_data.status = "F"
    ENDIF
   ENDIF
   CALL echo(build("orgid:",orgid))
   SELECT INTO "nl:"
    pr.*
    FROM prot_role pr
    PLAN (pr
     WHERE (pr.prot_amendment_id=request->prot_amendment_id)
      AND pr.prot_role_cd=coordinst_cd
      AND pr.organization_id=orgid
      AND pr.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
    DETAIL
     reply->bfound = true
    WITH nocounter
   ;end select
   IF (curqual=0)
    IF ((reply->bfound=true))
     SET reply->status_data.status = "F"
    ELSE
     SET reply->status_data.status = "Z"
    ENDIF
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   SET last_mod = "001"
   SET mod_date = "Aug 30, 2006"
   CALL echo(build("bfound ",reply->bfound))
   IF ((reply->status_data.status="F"))
    SET fail_flag = 1
   ENDIF
   IF ((reply->bfound=true)
    AND target_found=false)
    SET reply->bnotargetfound = true
   ENDIF
  ELSE
   SET reply->bnotargetfound = false
  ENDIF
 ENDIF
 CALL echo(reply->bfound)
#leave_script
 IF (fail_flag=0)
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Searching for roles"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ENDIF
 SET last_mod = "003"
 SET mod_date = "Sep 12, 2019"
END GO
