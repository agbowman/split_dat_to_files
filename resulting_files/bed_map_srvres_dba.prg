CREATE PROGRAM bed_map_srvres:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 DECLARE status = vc
 SET error_flag = "N"
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="ACTIVE"
  DETAIL
   active_cd = c.code_value
  WITH nocounter
 ;end select
 SET auth_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning="AUTH"
  DETAIL
   auth_cd = c.code_value
  WITH nocounter
 ;end select
 SET contributor_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=73
   AND c.display_key="MIGRATION"
   AND c.active_ind=1
  DETAIL
   contributor_cd = c.code_value
  WITH nocounter
 ;end select
 IF (contributor_cd=0.0)
  SET contributor_cd = 0.0
  SELECT INTO "nl:"
   y = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    contributor_cd = cnvtreal(y)
   WITH format, counter
  ;end select
  INSERT  FROM code_value cv
   SET cv.code_value = contributor_cd, cv.code_set = 73, cv.cdf_meaning = " ",
    cv.display = "MIGRATION", cv.display_key = "MIGRATION", cv.description = "MIGRATION",
    cv.definition = "MIGRATION", cv.collation_seq = 0, cv.active_type_cd = active_cd,
    cv.active_ind = 1, cv.active_dt_tm = cnvtdatetime(curdate,curtime), cv.updt_dt_tm = cnvtdatetime(
     curdate,curtime),
    cv.updt_id = reqinfo->updt_id, cv.updt_cnt = 0, cv.updt_task = reqinfo->updt_task,
    cv.updt_applctx = reqinfo->updt_applctx, cv.begin_effective_dt_tm = cnvtdatetime(curdate,curtime),
    cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    cv.data_status_cd = auth_cd, cv.data_status_prsnl_id = 0.0, cv.active_status_prsnl_id = 0.0,
    cv.cki = " ", cv.display_key_nls = " ", cv.concept_cki = " "
   WITH nocounter
  ;end insert
 ENDIF
 DECLARE display_key = vc
 FOR (x = 1 TO size(requestin->list_0,5))
   SET code = 0.0
   SET display_key = cnvtupper(requestin->list_0[x].hnam_service_resource)
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=221
      AND cv.display_key=display_key
      AND cv.active_ind=1)
    DETAIL
     code = cv.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_msg = concat("Could not find code value in CS 221 for hnam service resource: ",trim(
      requestin->list_0[x].hnam_service_resource))
    SET status = "W"
    SELECT INTO "ccluserdir:bed_map_srvres.errlog"
     FROM dummyt d
     PLAN (d)
     DETAIL
      CALL print(error_msg)
     WITH nocounter, append
    ;end select
   ELSEIF (curqual=1
    AND size(trim(requestin->list_0[x].legacy_service_resource,3)) <= 0)
    SET error_msg = concat("No legacy service resource for ",trim(requestin->list_0[x].
      hnam_service_resource))
    SET status = "W"
    SELECT INTO "ccluserdir:bed_map_srvres.errlog"
     FROM dummyt d
     PLAN (d)
     DETAIL
      CALL print(error_msg)
     WITH nocounter, append
    ;end select
   ELSEIF (curqual=1
    AND size(trim(requestin->list_0[x].legacy_service_resource,3)) > 0)
    INSERT  FROM code_value_alias cva
     SET cva.code_value = code, cva.code_set = 221, cva.alias = requestin->list_0[x].
      legacy_service_resource,
      cva.alias_type_meaning = "SERV RES", cva.contributor_source_cd = contributor_cd, cva.updt_cnt
       = 0,
      cva.updt_dt_tm = cnvtdatetime(curdate,curtime), cva.updt_applctx = reqinfo->updt_applctx, cva
      .updt_id = reqinfo->updt_id,
      cva.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reply->error_msg = "An Insert for the code_value_alias failed"
 ELSE
  IF (status="W")
   SET reply->status_data.status = "W"
   CALL echo(
    "Warning -- Issue a commit but not all rows were processed -- check the error log ccluserdir:bed_map_srvres.errlog"
    )
   SET reply->error_msg =
   "Warning -- Issue a commit but not all rows were processed -- check the error log"
  ELSE
   SET reply->status_data.status = "S"
   CALL echo("Success -- Issue a commit")
  ENDIF
 ENDIF
 CALL echorecord(reply)
END GO
