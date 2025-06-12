CREATE PROGRAM dm_refresh_task:dba
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
 FREE SET t_list
 RECORD t_list(
   1 count = i4
   1 t[*]
     2 t_num = i4
     2 f_num = i4
     2 s_dt = dq8
 )
 SET t_list->count = 0
 SELECT INTO "nl:"
  dm.proj_name
  FROM dm_project_status_env dm
  WHERE dm.environment_id=envid
   AND dm.proj_type="TASK"
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
   FROM dm_application_task da
   WHERE da.task_number=cnvtint(dm.proj_name)
    AND datetimediff(da.schema_date,dm.schema_date)=0))
  ORDER BY dm.proj_name
  HEAD dm.proj_name
   t_list->count = (t_list->count+ 1)
   IF (mod(t_list->count,10)=1)
    stat = alterlist(t_list->t,(t_list->count+ 9))
   ENDIF
   t_list->t[t_list->count].t_num = cnvtint(dm.proj_name)
  DETAIL
   x = 1
  WITH nocounter, forupdatewait(dm)
 ;end select
 SET stat = alterlist(t_list->t,t_list->count)
 IF ((t_list->count=0))
  GO TO end_program
 ENDIF
 SET cnt = 0
 FOR (cnt = 1 TO t_list->count)
   SELECT INTO "NL:"
    dcf.schema_date
    FROM dm_project_status_env dcf
    WHERE (cnvtint(dcf.proj_name)=t_list->t[cnt].t_num)
     AND dcf.proj_type="TASK"
     AND dcf.environment_id=envid
     AND ((dcf.dm_status = null) OR (((dcf.dm_status="FAILED") OR (dcf.dm_status="SUCCESS")) ))
    DETAIL
     IF ((dcf.schema_date > t_list->t[cnt].s_dt))
      t_list->t[cnt].s_dt = dcf.schema_date
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 UPDATE  FROM dm_project_status_env dm,
   (dummyt d  WITH seq = value(size(t_list->t,5)))
  SET dm.dm_status = "RUNNING", dm.dm_status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (dm
   WHERE dm.environment_id=envid
    AND (cnvtint(dm.proj_name)=t_list->t[d.seq].t_num)
    AND dm.proj_type="TASK"
    AND ((dm.dm_status = null) OR (dm.dm_status="FAILED")) )
  WITH nocounter
 ;end update
 COMMIT
 FREE SET request
 RECORD request(
   1 atr_count = i4
   1 atr_list[*]
     2 task_number = i4
     2 description = c200
     2 active_ind = i2
     2 active_dt_tm = dq8
     2 inactive_dt_tm = dq88
     2 optional_required_flag = i2
     2 app_group_cd = f8
     2 subordinate_task_ind = i2
     2 app_authorization_level = i4
     2 text = vc
     2 old_task_number = i4
     2 feature_number = i4
     2 schema_date = dq8
     2 deleted_ind = i2
 )
 SET request->atr_count = 0
 SET stat = alterlist(request->atr_list,0)
 SET trace symbol mark
 SELECT INTO "nl:"
  FROM dm_application_task dm,
   (dummyt d  WITH seq = value(size(t_list->t,5)))
  PLAN (d)
   JOIN (dm
   WHERE (dm.task_number=t_list->t[d.seq].t_num)
    AND datetimediff(dm.schema_date,cnvtdatetime(t_list->t[d.seq].s_dt))=0)
  DETAIL
   request->atr_count = (request->atr_count+ 1), stat = alterlist(request->atr_list,request->
    atr_count), request->atr_list[request->atr_count].feature_number = 0,
   request->atr_list[request->atr_count].task_number = dm.task_number, request->atr_list[request->
   atr_count].deleted_ind = dm.deleted_ind, request->atr_list[request->atr_count].description = dm
   .description,
   request->atr_list[request->atr_count].active_ind = dm.active_ind, request->atr_list[request->
   atr_count].active_dt_tm = cnvtdatetime(dm.active_dt_tm), request->atr_list[request->atr_count].
   inactive_dt_tm = cnvtdatetime(dm.inactive_dt_tm),
   request->atr_list[request->atr_count].optional_required_flag = dm.optional_required_flag, request
   ->atr_list[request->atr_count].subordinate_task_ind = dm.subordinate_task_ind, request->atr_list[
   request->atr_count].text = dm.text,
   request->atr_list[request->atr_count].old_task_number = dm.old_task_number
  WITH nocounter
 ;end select
 IF ((request->atr_count > 0))
  EXECUTE dm_atr_task_import
 ENDIF
 UPDATE  FROM dm_project_status_env dm,
   (dummyt d  WITH seq = value(size(t_list->t,5)))
  SET dm.dm_status = "SUCCESS", dm.dm_status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (dm
   WHERE dm.environment_id=envid
    AND (cnvtint(dm.proj_name)=t_list->t[d.seq].t_num)
    AND dm.schema_date <= cnvtdatetime(t_list->t[d.seq].s_dt)
    AND dm.proj_type="TASK"
    AND dm.dm_status="RUNNING")
  WITH nocounter
 ;end update
 COMMIT
#end_program
 SET reply->status_data.status = "S"
END GO
