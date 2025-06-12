CREATE PROGRAM dm_refresh_app:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET envid = 0.0
 SELECT INTO "nl:"
  de.environment_id
  FROM dm_info di,
   dm_environment de
  WHERE di.info_name="DM_ENV_ID"
   AND di.info_domain="DATA MANAGEMENT"
   AND de.environment_id=di.info_number
  DETAIL
   envid = de.environment_id
  WITH nocounter
 ;end select
 FREE SET a_list
 RECORD a_list(
   1 count = i4
   1 a[*]
     2 a_num = i4
     2 f_num = i4
     2 s_dt = dq8
 )
 SET a_list->count = 0
 SELECT INTO "nl:"
  dm.proj_name
  FROM dm_project_status_env dm
  WHERE dm.environment_id=envid
   AND dm.proj_type="APPLICATION"
   AND ((dm.dm_status = null) OR (dm.dm_status="FAILED"))
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM dm_project_status_env a
   WHERE a.environment_id=envid
    AND a.proj_type=dm.proj_type
    AND a.proj_name=dm.proj_name
    AND a.dm_status="RUNNING")))
   AND  EXISTS (
  (SELECT
   "X"
   FROM dm_application da
   WHERE da.application_number=cnvtint(dm.proj_name)
    AND datetimediff(da.schema_date,dm.schema_date)=0))
  ORDER BY dm.proj_name
  HEAD dm.proj_name
   a_list->count = (a_list->count+ 1)
   IF (mod(a_list->count,10)=1)
    stat = alterlist(a_list->a,(a_list->count+ 9))
   ENDIF
   a_list->a[a_list->count].a_num = cnvtint(dm.proj_name)
  DETAIL
   x = 1
  WITH nocounter, forupdatewait(dm)
 ;end select
 SET stat = alterlist(a_list->a,a_list->count)
 IF ((a_list->count=0))
  GO TO end_program
 ENDIF
 SET cnt = 0
 FOR (cnt = 1 TO a_list->count)
  SELECT INTO "NL:"
   dcf.schema_date
   FROM dm_project_status_env dcf
   WHERE (cnvtint(dcf.proj_name)=a_list->a[cnt].a_num)
    AND dcf.proj_type="APPLICATION"
    AND dcf.environment_id=envid
    AND ((dcf.dm_status = null) OR (((dcf.dm_status="FAILED") OR (dcf.dm_status="SUCCESS")) ))
   DETAIL
    IF ((dcf.schema_date > a_list->a[cnt].s_dt))
     a_list->a[cnt].s_dt = dcf.schema_date
    ENDIF
   WITH nocounter
  ;end select
  UPDATE  FROM dm_project_status_env dm
   SET dm.dm_status = "RUNNING", dm.dm_status_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE dm.environment_id=envid
    AND (cnvtint(dm.proj_name)=a_list->a[cnt].a_num)
    AND dm.proj_type="APPLICATION"
    AND ((dm.dm_status = null) OR (dm.dm_status="FAILED"))
   WITH nocounter
  ;end update
 ENDFOR
 COMMIT
 FREE SET request
 RECORD request(
   1 atr_count = i4
   1 atr_list[*]
     2 application_number = i4
     2 description = c200
     2 owner = c20
     2 log_access_ind = i2
     2 direct_access_ind = i2
     2 application_ini_ind = i2
     2 log_level = i2
     2 request_log_level = i2
     2 min_version_required = vc
     2 object_name = vc
     2 last_localized_dt_tm = dq8
     2 active_ind = i2
     2 active_dt_tm = dq8
     2 inactive_dt_tm = dq8
     2 disable_cache_ind = i2
     2 text = vc
     2 common_application_ind = i2
     2 feature_number = i2
     2 schema_date = dq8
     2 deleted_ind = i2
 )
 SET request->atr_count = 0
 SET stat = alterlist(request->atr_list,0)
 SELECT INTO "nl:"
  FROM dm_application dm,
   (dummyt d  WITH seq = value(size(a_list->a,5)))
  PLAN (d)
   JOIN (dm
   WHERE (dm.application_number=a_list->a[d.seq].a_num)
    AND datetimediff(dm.schema_date,cnvtdatetime(a_list->a[d.seq].s_dt))=0)
  DETAIL
   request->atr_count = (request->atr_count+ 1), stat = alterlist(request->atr_list,request->
    atr_count), request->atr_list[request->atr_count].feature_number = 0,
   request->atr_list[request->atr_count].application_number = dm.application_number, request->
   atr_list[request->atr_count].deleted_ind = dm.deleted_ind, request->atr_list[request->atr_count].
   description = dm.description,
   request->atr_list[request->atr_count].owner = dm.owner, request->atr_list[request->atr_count].
   log_access_ind = dm.log_access_ind, request->atr_list[request->atr_count].direct_access_ind = dm
   .direct_access_ind,
   request->atr_list[request->atr_count].application_ini_ind = dm.application_ini_ind, request->
   atr_list[request->atr_count].log_level = dm.log_level, request->atr_list[request->atr_count].
   request_log_level = dm.request_log_level,
   request->atr_list[request->atr_count].min_version_required = dm.min_version_required, request->
   atr_list[request->atr_count].object_name = dm.object_name, request->atr_list[request->atr_count].
   last_localized_dt_tm = cnvtdatetime(dm.last_localized_dt_tm),
   request->atr_list[request->atr_count].active_ind = dm.active_ind, request->atr_list[request->
   atr_count].active_dt_tm = cnvtdatetime(dm.active_dt_tm), request->atr_list[request->atr_count].
   inactive_dt_tm = cnvtdatetime(dm.inactive_dt_tm),
   request->atr_list[request->atr_count].disable_cache_ind = dm.disable_cache_ind, request->atr_list[
   request->atr_count].common_application_ind = dm.common_application_ind, request->atr_list[request
   ->atr_count].text = dm.text
  WITH nocounter
 ;end select
 IF ((request->atr_count > 0))
  EXECUTE dm_atr_app_import
 ENDIF
 UPDATE  FROM dm_project_status_env dm,
   (dummyt d  WITH seq = value(size(a_list->a,5)))
  SET dm.dm_status = "SUCCESS", dm.dm_status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (dm
   WHERE dm.environment_id=envid
    AND (cnvtint(dm.proj_name)=a_list->a[d.seq].a_num)
    AND dm.schema_date <= cnvtdatetime(a_list->a[d.seq].s_dt)
    AND dm.proj_type="APPLICATION"
    AND dm.dm_status="RUNNING")
  WITH nocounter
 ;end update
 COMMIT
#end_program
 SET reply->status_data.status = "S"
END GO
