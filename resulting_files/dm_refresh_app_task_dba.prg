CREATE PROGRAM dm_refresh_app_task:dba
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
 FREE SET at_list
 RECORD at_list(
   1 count = i4
   1 at[*]
     2 a_num = i4
     2 t_num = i4
     2 f_num = i4
     2 s_dt = dq8
     2 len = i4
 )
 SET at_list->count = 0
 SET len = 0
 SELECT INTO "nl:"
  dm.proj_name
  FROM dm_project_status_env dm
  WHERE dm.environment_id=envid
   AND dm.proj_type="APP_TASK REL"
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
   FROM dm_application_task_r da
   WHERE da.application_number=cnvtint(substring(1,(findstring("_",dm.proj_name) - 1),dm.proj_name))
    AND da.task_number=cnvtint(substring((findstring("_",dm.proj_name)+ 1),48,dm.proj_name))
    AND datetimediff(da.schema_date,dm.schema_date)=0))
  ORDER BY dm.proj_name
  HEAD dm.proj_name
   at_list->count = (at_list->count+ 1)
   IF (mod(at_list->count,10)=1)
    stat = alterlist(at_list->at,(at_list->count+ 9))
   ENDIF
   at_list->at[at_list->count].len = size(dm.proj_name,1), at_list->at[at_list->count].a_num =
   cnvtint(substring(1,(findstring("_",dm.proj_name) - 1),dm.proj_name)), at_list->at[at_list->count]
   .t_num = cnvtint(substring((findstring("_",dm.proj_name)+ 1),(at_list->at[at_list->count].len -
     findstring("_",dm.proj_name)),dm.proj_name))
  DETAIL
   x = 1
  WITH nocounter, forupdatewait(dm)
 ;end select
 SET stat = alterlist(at_list->at,at_list->count)
 IF ((at_list->count=0))
  GO TO end_program
 ENDIF
 SET cnt = 0
 FOR (cnt = 1 TO at_list->count)
   SELECT INTO "NL:"
    dcf.schema_date
    FROM dm_project_status_env dcf
    WHERE (cnvtint(substring(1,(findstring("_",dcf.proj_name) - 1),dcf.proj_name))=at_list->at[cnt].
    a_num)
     AND (cnvtint(substring((findstring("_",dcf.proj_name)+ 1),(at_list->at[cnt].len - findstring("_",
       dcf.proj_name)),dcf.proj_name))=at_list->at[cnt].t_num)
     AND dcf.proj_type="APP_TASK REL"
     AND dcf.environment_id=envid
     AND ((dcf.dm_status = null) OR (((dcf.dm_status="FAILED") OR (dcf.dm_status="SUCCESS")) ))
    DETAIL
     IF ((dcf.schema_date > at_list->at[cnt].s_dt))
      at_list->at[cnt].s_dt = dcf.schema_date
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 UPDATE  FROM dm_project_status_env dm,
   (dummyt d  WITH seq = value(size(at_list->at,5)))
  SET dm.dm_status = "RUNNING", dm.dm_status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (dm
   WHERE dm.environment_id=envid
    AND (cnvtint(substring(1,(findstring("_",dm.proj_name) - 1),dm.proj_name))=at_list->at[d.seq].
   a_num)
    AND (cnvtint(substring((findstring("_",dm.proj_name)+ 1),(at_list->at[d.seq].len - findstring("_",
      dm.proj_name)),dm.proj_name))=at_list->at[d.seq].t_num)
    AND dm.proj_type="APP_TASK REL"
    AND ((dm.dm_status = null) OR (dm.dm_status="FAILED")) )
  WITH nocounter
 ;end update
 COMMIT
 FREE SET request
 RECORD request(
   1 atr_count = i4
   1 atr_list[*]
     2 application_number = i4
     2 task_number = i4
     2 deleted_ind = i2
   1 feature_number = i4
   1 schema_date = dq8
 )
 SET request->atr_count = 0
 SET stat = alterlist(request->atr_list,0)
 SET trace symbol mark
 SELECT INTO "nl:"
  FROM dm_application_task_r dm,
   (dummyt d  WITH seq = value(size(at_list->at,5)))
  PLAN (d)
   JOIN (dm
   WHERE (dm.application_number=at_list->at[d.seq].a_num)
    AND (dm.task_number=at_list->at[d.seq].t_num)
    AND datetimediff(dm.schema_date,cnvtdatetime(at_list->at[d.seq].s_dt))=0)
  ORDER BY dm.application_number, dm.task_number
  DETAIL
   request->atr_count = (request->atr_count+ 1), stat = alterlist(request->atr_list,request->
    atr_count), request->feature_number = 0,
   request->atr_list[request->atr_count].application_number = dm.application_number, request->
   atr_list[request->atr_count].task_number = dm.task_number, request->atr_list[request->atr_count].
   deleted_ind = dm.deleted_ind
  WITH nocounter
 ;end select
 IF ((request->atr_count > 0))
  EXECUTE dm_atr_app_task_import
 ENDIF
 UPDATE  FROM dm_project_status_env dm,
   (dummyt d  WITH seq = value(size(at_list->at,5)))
  SET dm.dm_status = "SUCCESS", dm.dm_status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (dm
   WHERE dm.environment_id=envid
    AND (cnvtint(substring(1,(findstring("_",dm.proj_name) - 1),dm.proj_name))=at_list->at[d.seq].
   a_num)
    AND (cnvtint(substring((findstring("_",dm.proj_name)+ 1),(at_list->at[d.seq].len - findstring("_",
      dm.proj_name)),dm.proj_name))=at_list->at[d.seq].t_num)
    AND dm.schema_date <= cnvtdatetime(at_list->at[d.seq].s_dt)
    AND dm.proj_type="APP_TASK REL"
    AND dm.dm_status="RUNNING")
  WITH nocounter
 ;end update
 COMMIT
#end_program
 SET reply->status_data.status = "S"
END GO
