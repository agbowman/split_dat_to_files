CREATE PROGRAM bed_is_dup_org_for_alias:dba
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 duplicate_orgs[*]
      2 id = f8
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE errmsg = vc WITH public, noconstant(fillstring(132," "))
 DECLARE tot_ap = i4
 DECLARE apvar = i4
 DECLARE orgcnt = i4
 DECLARE entity_name = vc
 DECLARE entity_type_cd = f8
 DECLARE entity_code_set = i4
 DECLARE found = i2
 DECLARE error_msg = vc
 DECLARE prg_exists_ind = i2
 DECLARE errorcode = i4
 DECLARE data_partition_ind = i2 WITH noconstant(0)
 DECLARE error_flag = vc WITH noconstant("N")
 DECLARE field_found = i2 WITH noconstant(0)
 SET reply->status_data.status = "S"
 SET req_cnt = size(request->alias_pools,5)
 SET stat = alterlist(reply->duplicate_orgs,req_cnt)
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_CURR_LOGICAL_DOMAIN")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF a IS alias_pool
   SET field_found = validate(a.logical_domain_id)
   FREE RANGE a
   IF (field_found=1)
    SET data_partition_ind = 1
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    ) WITH protect
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    ) WITH protect
    SET acm_get_curr_logical_domain_req->concept = 5
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
   ENDIF
  ENDIF
 ENDIF
 SET tot_ap = size(request->alias_pools,5)
 SET apvar = 1
 WHILE (apvar <= tot_ap)
   SET entity_type_cd = 0.0
   SET entity_code_set = 0
   SET entity_name = fillstring(25," ")
   IF ((request->alias_pools[apvar].type_code_value > 0.0))
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE (cv.code_value=request->alias_pools[apvar].type_code_value))
     DETAIL
      entity_type_cd = cv.code_value, entity_code_set = cv.code_set
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Error reading code_value for alias pool cd: ",trim(cnvtstring(request->
        alias_pools[apvar].type_code_value)),".")
     GO TO exit_script
    ENDIF
    CASE (entity_code_set)
     OF 4:
      SET entity_name = "PERSON_ALIAS"
     OF 319:
      SET entity_name = "ENCNTR_ALIAS"
     OF 320:
      SET entity_name = "PRSNL_ALIAS"
     OF 334:
      SET entity_name = "ORGANIZATION_ALIAS"
     OF 754:
      SET entity_name = "ORDER_ALIAS"
     OF 4070:
      SET entity_name = "PHM_ID Alias"
     OF 12801:
      SET entity_name = "PowerTrials Alias"
     OF 25711:
      SET entity_name = "Media Alias"
     OF 26881:
      SET entity_name = "SCH_EVENT_ALIAS"
     OF 27121:
      SET entity_name = "HEALTH_PLAN_ALIAS"
     OF 27520:
      SET entity_name = "ProFit Encounter Alias"
     OF 28200:
      SET entity_name = "ProFit Bill Alias"
     OF 4001913:
      SET entity_name = "Medication Claim Alias"
     OF 4002035:
      SET entity_name = "Claim Visit Alias"
     OF 4002262:
      SET entity_name = "ProFit Receipt Alias"
    ENDCASE
   ENDIF
   IF ((request->alias_pools[apvar].action_flag=2))
    SET orgcnt = size(request->alias_pools[apvar].orgs,5)
    SET ii = 1
    FOR (ii = 1 TO orgcnt)
      SET stat = alterlist(reply->duplicate_orgs,orgcnt)
      SET dup_cnt = 0
      IF ((request->alias_pools[apvar].orgs[ii].action_flag=1))
       IF ((request->alias_pools[apvar].type_code_value > 0.0))
        SELECT INTO "nl:"
         FROM org_alias_pool_reltn oapr
         WHERE (oapr.organization_id=request->alias_pools[apvar].orgs[ii].id)
          AND oapr.alias_entity_name=entity_name
          AND oapr.alias_entity_alias_type_cd=entity_type_cd
          AND (oapr.alias_pool_cd=request->alias_pools[apvar].code_value)
          AND oapr.active_ind=1
         DETAIL
          dup_cnt = (dup_cnt+ 1), reply->duplicate_orgs[dup_cnt].id = oapr.organization_id
         WITH nocounter
        ;end select
       ENDIF
      ENDIF
    ENDFOR
   ELSEIF ((request->alias_pools[apvar].action_flag=0))
    SET orgcnt = size(request->alias_pools[apvar].orgs,5)
    SET ii = 1
    FOR (ii = 1 TO orgcnt)
      SET stat = alterlist(reply->duplicate_orgs,orgcnt)
      SET dup_cnt = 0
      IF ((request->alias_pools[apvar].orgs[ii].action_flag=1))
       IF ((request->alias_pools[apvar].type_code_value > 0.0))
        SELECT INTO "NL:"
         FROM org_alias_pool_reltn oapr
         PLAN (oapr
          WHERE (oapr.organization_id=request->alias_pools[apvar].orgs[ii].id)
           AND (oapr.alias_pool_cd=request->alias_pools[apvar].code_value)
           AND oapr.alias_entity_alias_type_cd=entity_type_cd
           AND oapr.active_ind=1)
         DETAIL
          dup_cnt = (dup_cnt+ 1), reply->duplicate_orgs[dup_cnt].id = oapr.organization_id
         WITH nocounter
        ;end select
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   SET apvar = (apvar+ 1)
 ENDWHILE
 GO TO exit_script
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >>PROGRAM NAME: BED_ENS_ALIAS_POOLS","  >>ERROR MSG: ",error_msg)
 ENDIF
 CALL echorecord(reply)
END GO
