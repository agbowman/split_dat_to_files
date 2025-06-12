CREATE PROGRAM dm_rcm_ins_interqual_acct:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dm_rcm_ins_interqual_acct..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE third_party_acct_type_cd = f8 WITH protect, noconstant(0)
 DECLARE maxlistsize = i4 WITH protect, noconstant(0)
 IF ((validate(debugme,- (9))=- (9)))
  DECLARE debugme = i2 WITH noconstant(false)
 ENDIF
 FREE RECORD interqualaccounts
 RECORD interqualaccounts(
   1 commit_ind = i2
   1 logical_domain_list[*]
     2 logical_domain_id = f8
     2 rcm_third_party_account_id = f8
     2 organization_list[*]
       3 organization_id = f8
 )
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="INTERQUAL"
   AND cv.code_set=4002851
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   third_party_acct_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed on meaning select from CODE_VALUE: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (third_party_acct_type_cd != 0.0)
  DELETE  FROM rcm_third_party_acct_org_r org_r
   WHERE org_r.rcm_third_party_account_id IN (
   (SELECT
    acct.rcm_third_party_account_id
    FROM rcm_third_party_account acct
    WHERE acct.third_party_type_cd=third_party_acct_type_cd))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to delete from RCM_THIRD_PARTY_ACCT_ORG_R: ",errmsg)
   GO TO exit_script
  ENDIF
  DELETE  FROM rcm_third_party_account acct
   WHERE acct.third_party_type_cd=third_party_acct_type_cd
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to delete from RCM_THIRD_PARTY_ACCOUNT: ",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM rcm_interqual_account acct,
   rcm_interqual_acct_org_r org_r,
   organization org
  PLAN (acct
   WHERE acct.rcm_interqual_account_id > 0)
   JOIN (org_r
   WHERE org_r.rcm_interqual_account_id=acct.rcm_interqual_account_id)
   JOIN (org
   WHERE org_r.organization_id=org.organization_id)
  ORDER BY org.logical_domain_id
  HEAD REPORT
   count = 0
  HEAD org.logical_domain_id
   count += 1
   IF (size(interqualaccounts->logical_domain_list,5) < count)
    stat = alterlist(interqualaccounts->logical_domain_list,(count+ 9))
   ENDIF
   interqualaccounts->logical_domain_list[count].logical_domain_id = org.logical_domain_id, org_count
    = 0
  DETAIL
   org_count += 1
   IF (size(interqualaccounts->logical_domain_list[count].organization_list,5) < org_count)
    stat = alterlist(interqualaccounts->logical_domain_list[count].organization_list,(org_count+ 9))
   ENDIF
   interqualaccounts->logical_domain_list[count].organization_list[org_count].organization_id = org_r
   .organization_id
  FOOT  org.logical_domain_id
   IF (mod(org_count,10) != 0)
    stat = alterlist(interqualaccounts->logical_domain_list[count].organization_list,org_count)
   ENDIF
  FOOT REPORT
   IF (mod(count,10) != 0)
    stat = alterlist(interqualaccounts->logical_domain_list,count)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to select from RCM_INTERQUAL_ACCOUNT and RCM_INTERQUAL_ACCT_ORG_R: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (third_party_acct_type_cd > 0
  AND size(interqualaccounts->logical_domain_list,5) > 0)
  SELECT INTO "nl:"
   acctid = seq(encounter_seq,nextval)
   FROM dual,
    (dummyt d  WITH seq = value(size(interqualaccounts->logical_domain_list,5)))
   PLAN (d)
    JOIN (dual)
   DETAIL
    interqualaccounts->logical_domain_list[d.seq].rcm_third_party_account_id = acctid
   WITH nocounter
  ;end select
  IF (error(errmsg,0) > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to select ENCOUNTER_SEQ: ",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM rcm_third_party_account acct,
    (dummyt d  WITH seq = value(size(interqualaccounts->logical_domain_list,5)))
   SET acct.rcm_third_party_account_id = interqualaccounts->logical_domain_list[d.seq].
    rcm_third_party_account_id, acct.logical_domain_id = interqualaccounts->logical_domain_list[d.seq
    ].logical_domain_id, acct.account_name = "Interqual",
    acct.third_party_type_cd = third_party_acct_type_cd, acct.updt_cnt = 0, acct.updt_dt_tm =
    cnvtdatetime(sysdate),
    acct.updt_applctx = reqinfo->updt_applctx, acct.updt_task = reqinfo->updt_task, acct.updt_id =
    reqinfo->updt_id
   PLAN (d)
    JOIN (acct)
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   SET interqualaccounts->commit_ind = 0
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to insert into RCM_THIRD_PARTY_ACCOUNT: ",errmsg)
   GO TO exit_script
  ELSE
   SET interqualaccounts->commit_ind = 1
  ENDIF
  FOR (loop = 1 TO size(interqualaccounts->logical_domain_list,5))
    SET maxlistsize = maxval(maxlistsize,size(interqualaccounts->logical_domain_list[loop].
      organization_list,5))
  ENDFOR
  INSERT  FROM rcm_third_party_acct_org_r org_r,
    (dummyt d1  WITH seq = value(size(interqualaccounts->logical_domain_list,5))),
    (dummyt d2  WITH seq = value(maxlistsize))
   SET org_r.rcm_third_party_acct_org_r_id = seq(encounter_seq,nextval), org_r
    .rcm_third_party_account_id = interqualaccounts->logical_domain_list[d1.seq].
    rcm_third_party_account_id, org_r.organization_id = interqualaccounts->logical_domain_list[d1.seq
    ].organization_list[d2.seq].organization_id,
    org_r.updt_cnt = 0, org_r.updt_dt_tm = cnvtdatetime(sysdate), org_r.updt_applctx = reqinfo->
    updt_applctx,
    org_r.updt_task = reqinfo->updt_task, org_r.updt_id = reqinfo->updt_id
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(interqualaccounts->logical_domain_list[d1.seq].organization_list,5))
    JOIN (org_r)
   WITH nocounter
  ;end insert
  IF (error(errmsg,0) > 0)
   SET interqualaccounts->commit_ind = 0
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to insert into RCM_THIRD_PARTY_ACCT_ORG_R: ",errmsg)
   GO TO exit_script
  ELSE
   SET interqualaccounts->commit_ind = 1
  ENDIF
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks."
#exit_script
 IF ((interqualaccounts->commit_ind > 0))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 IF (debugme)
  CALL echorecord(interqualaccounts)
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
