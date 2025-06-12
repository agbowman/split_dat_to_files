CREATE PROGRAM cqm_add_cconfig
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE error_message = vc WITH public, noconstant(" ")
 SET reply->status_data.status = "F"
 SET contributor_id = 0.0
 FREE SET failed
 SET failed = "F"
 SELECT INTO "nl:"
  c.application_name, c.contributor_alias, c.contributor_id
  FROM cqm_contributor_config c
  WHERE c.application_name=trim(request->app_name,3)
   AND c.contributor_alias=trim(request->contrib_alias,3)
  DETAIL
   contributor_id = c.contributor_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   nextseqnum = seq(cqm_contributor_id_seq,nextval)
   FROM dual
   DETAIL
    contributor_id = nextseqnum
   WITH nocounter
  ;end select
  INSERT  FROM cqm_contributor_config c
   (c.contributor_id, c.application_name, c.contributor_alias,
   c.target_priority, c.debug_ind, c.verbosity_flag,
   c.create_dt_tm, c.updt_dt_tm, c.updt_id,
   c.updt_task, c.updt_applctx, c.updt_cnt)
   VALUES(contributor_id, trim(request->app_name), trim(request->contrib_alias),
   request->target_priority, request->debug_ind, request->verbosity_flag,
   cnvtdatetime(sysdate), cnvtdatetime(sysdate), 1,
   1255000, 1255000, 0)
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET failed = "T"
   SET error_message = concat("Failed during insert in cqm_add_cconfig script: ",errmsg)
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   SET failed = "T"
   SET error_message = "Failed during insert in cqm_add_cconfig script"
   GO TO exit_script
  ENDIF
 ELSEIF (curqual=1)
  UPDATE  FROM cqm_contributor_config c
   SET c.target_priority = request->target_priority, c.debug_ind = request->debug_ind, c
    .verbosity_flag = request->verbosity_flag,
    c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = 1, c.updt_task = 1255000,
    c.updt_applctx = 1255000, c.updt_cnt = (c.updt_cnt+ 1)
   WHERE c.contributor_id=contributor_id
   WITH nocounter
  ;end update
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET failed = "T"
   SET error_message = concat("Failed during update in cqm_add_cconfig script: ",errmsg)
   GO TO exit_script
  ENDIF
  IF (curqual=0)
   SET failed = "T"
   SET error_message = "Failed during update in cqm_add_cconfig script"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
