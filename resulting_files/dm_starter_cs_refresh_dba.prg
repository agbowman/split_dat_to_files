CREATE PROGRAM dm_starter_cs_refresh:dba
 SET envid = 0.0
 SET reqinfo->updt_task = 15301
 FREE RECORD cs_reply
 RECORD cs_reply(
   1 cs_fail = i2
   1 cs_fail_msg = vc
 )
 SET cs_reply->cs_fail = 0
 SELECT INTO "nl:"
  b.environment_id
  FROM dm_info a,
   dm_environment b
  WHERE a.info_name="DM_ENV_ID"
   AND a.info_domain="DATA MANAGEMENT"
   AND a.info_number=b.environment_id
  DETAIL
   envid = b.environment_id
  WITH nocounter
 ;end select
 SET cvs_inhouse = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="INHOUSE DOMAIN"
  DETAIL
   cvs_inhouse = 1
  WITH nocounter
 ;end select
 CALL echo(build("inhouse=",cvs_inhouse))
 FREE SET list
 RECORD list(
   1 qual[*]
     2 code_set = f8
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->qual,10)
 SELECT INTO "nl:"
  dm.proj_name
  FROM dm_project_status_env dm
  WHERE dm.environment_id=envid
   AND dm.proj_type="CODESET"
   AND ((dm.dm_status = null) OR (dm.dm_status="FAILED"))
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM dm_project_status_env a
   WHERE a.environment_id=envid
    AND a.proj_type=dm.proj_type
    AND a.proj_name=dm.proj_name
    AND a.dm_status="RUNNING")))
  ORDER BY dm.proj_name
  HEAD dm.proj_name
   list->count = (list->count+ 1)
   IF (mod(list->count,10)=1)
    stat = alterlist(list->qual,(list->count+ 9))
   ENDIF
   list->qual[list->count].code_set = cnvtint(dm.proj_name)
  DETAIL
   x = 1
  WITH nocounter, forupdatewait(dm)
 ;end select
 SET cnt = 0
 FOR (cnt = 1 TO list->count)
   UPDATE  FROM dm_project_status_env dm
    SET dm.dm_status = "RUNNING"
    WHERE (cnvtint(dm.proj_name)=list->qual[cnt].code_set)
     AND dm.proj_type="CODESET"
     AND dm.environment_id=envid
     AND ((dm.dm_status = null) OR (dm.dm_status="FAILED"))
    WITH nocounter
   ;end update
 ENDFOR
 COMMIT
 SET cnt = 0
 FOR (cnt = 1 TO list->count)
   SET cs_reply->cs_fail = 0
   FREE SET r1
   RECORD r1(
     1 rdate = dq8
   )
   SET r1->rdate = 0
   SELECT INTO "NL:"
    dcf.schema_date
    FROM dm_project_status_env dcf
    WHERE (cnvtint(dcf.proj_name)=list->qual[cnt].code_set)
     AND dcf.proj_type="CODESET"
     AND dcf.environment_id=envid
     AND dcf.dm_status IN ("RUNNING", "SUCCESS")
    DETAIL
     IF ((dcf.schema_date > r1->rdate))
      r1->rdate = dcf.schema_date
     ENDIF
    WITH nocounter
   ;end select
   EXECUTE dm_starter_code_value_set
   EXECUTE dm_starter_cdf
   EXECUTE dm_starter_code_value
   EXECUTE dm_starter_cs_extension
   EXECUTE dm_starter_code_value_alias
   EXECUTE dm_starter_cv_extension
   EXECUTE dm_starter_cv_group
   SELECT INTO "nl:"
    d.code_set
    FROM code_value_set d
    WHERE (d.code_set=list->qual[cnt].code_set)
    WITH nocounter
   ;end select
   CALL echo(list->qual[cnt].code_set)
   IF (curqual > 0
    AND (cs_reply->cs_fail=0))
    UPDATE  FROM dm_project_status_env dmf
     SET dmf.dm_status = "SUCCESS"
     WHERE (cnvtint(dmf.proj_name)=list->qual[cnt].code_set)
      AND dmf.environment_id=envid
      AND dmf.proj_type="CODESET"
      AND dmf.dm_status="RUNNING"
      AND dmf.schema_date <= cnvtdatetime(r1->rdate)
     WITH nocounter
    ;end update
    COMMIT
   ELSEIF (((curqual=0) OR ((cs_reply->cs_fail=1))) )
    UPDATE  FROM dm_project_status_env dmf
     SET dmf.dm_status = "FAILED"
     WHERE (cnvtint(dmf.proj_name)=list->qual[cnt].code_set)
      AND dmf.schema_date <= cnvtdatetime(r1->rdate)
      AND dmf.environment_id=envid
      AND dmf.proj_type="CODESET"
      AND dmf.dm_status="RUNNING"
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
 ENDFOR
 IF ( NOT (validate(reply->status_data.status,"1")="1"
  AND validate(reply->status_data.status,"2")="2"))
  SET reply->status_data.status = "S"
 ENDIF
END GO
