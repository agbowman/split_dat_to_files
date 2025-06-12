CREATE PROGRAM dm_refresh_task_req:dba
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
 FREE SET tr_list
 RECORD tr_list(
   1 count = i4
   1 tr[*]
     2 t_num = i4
     2 r_num = i4
     2 f_num = i4
     2 s_dt = dq8
     2 len = i4
 )
 SET tr_list->count = 0
 SELECT INTO "nl:"
  dm.proj_name
  FROM dm_project_status_env dm
  WHERE dm.environment_id=envid
   AND dm.proj_type="TASK_REQ REL"
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
   FROM dm_task_request_r da
   WHERE da.task_number=cnvtint(substring(1,(findstring("_",dm.proj_name) - 1),dm.proj_name))
    AND da.request_number=cnvtint(substring((findstring("_",dm.proj_name)+ 1),48,dm.proj_name))
    AND datetimediff(da.schema_date,dm.schema_date)=0))
  ORDER BY dm.proj_name
  HEAD dm.proj_name
   tr_list->count = (tr_list->count+ 1)
   IF (mod(tr_list->count,10)=1)
    stat = alterlist(tr_list->tr,(tr_list->count+ 9))
   ENDIF
   tr_list->tr[tr_list->count].len = size(dm.proj_name,1), tr_list->tr[tr_list->count].t_num =
   cnvtint(substring(1,(findstring("_",dm.proj_name) - 1),dm.proj_name)), tr_list->tr[tr_list->count]
   .r_num = cnvtint(substring((findstring("_",dm.proj_name)+ 1),(tr_list->tr[tr_list->count].len -
     findstring("_",dm.proj_name)),dm.proj_name))
  DETAIL
   x = 1
  WITH nocounter, forupdatewait(dm)
 ;end select
 SET stat = alterlist(tr_list->tr,tr_list->count)
 IF ((tr_list->count=0))
  GO TO end_program
 ENDIF
 SET cnt = 0
 FOR (cnt = 1 TO tr_list->count)
   SELECT INTO "NL:"
    dcf.schema_date
    FROM dm_project_status_env dcf
    WHERE (cnvtint(substring(1,(findstring("_",dcf.proj_name) - 1),dcf.proj_name))=tr_list->tr[cnt].
    t_num)
     AND (cnvtint(substring((findstring("_",dcf.proj_name)+ 1),(tr_list->tr[cnt].len - findstring("_",
       dcf.proj_name)),dcf.proj_name))=tr_list->tr[cnt].r_num)
     AND dcf.proj_type="TASK_REQ REL"
     AND dcf.environment_id=envid
     AND ((dcf.dm_status = null) OR (((dcf.dm_status="FAILED") OR (dcf.dm_status="SUCCESS")) ))
    DETAIL
     IF ((dcf.schema_date > tr_list->tr[cnt].s_dt))
      tr_list->tr[cnt].s_dt = dcf.schema_date
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 UPDATE  FROM dm_project_status_env dm,
   (dummyt d  WITH seq = value(size(tr_list->tr,5)))
  SET dm.dm_status = "RUNNING", dm.dm_status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (dm
   WHERE dm.environment_id=envid
    AND (cnvtint(substring(1,(findstring("_",dm.proj_name) - 1),dm.proj_name))=tr_list->tr[d.seq].
   t_num)
    AND (cnvtint(substring((findstring("_",dm.proj_name)+ 1),(tr_list->tr[d.seq].len - findstring("_",
      dm.proj_name)),dm.proj_name))=tr_list->tr[d.seq].r_num)
    AND dm.proj_type="TASK_REQ REL"
    AND ((dm.dm_status = null) OR (dm.dm_status="FAILED")) )
  WITH nocounter
 ;end update
 COMMIT
 FREE SET request
 RECORD request(
   1 atr_count = i4
   1 atr_list[*]
     2 task_number = i4
     2 request_number = i4
     2 deleted_ind = i2
   1 feature_number = i4
   1 schema_date = dq8
 )
 SET request->atr_count = 0
 SET stat = alterlist(request->atr_list,0)
 SET trace symbol mark
 SELECT INTO "nl:"
  FROM dm_task_request_r dm,
   (dummyt d  WITH seq = value(size(tr_list->tr,5)))
  PLAN (d)
   JOIN (dm
   WHERE (dm.task_number=tr_list->tr[d.seq].t_num)
    AND (dm.request_number=tr_list->tr[d.seq].r_num)
    AND datetimediff(dm.schema_date,cnvtdatetime(tr_list->tr[d.seq].s_dt))=0)
  ORDER BY dm.task_number, dm.request_number
  DETAIL
   request->atr_count = (request->atr_count+ 1), stat = alterlist(request->atr_list,request->
    atr_count), request->feature_number = 0,
   request->atr_list[request->atr_count].task_number = dm.task_number, request->atr_list[request->
   atr_count].request_number = dm.request_number, request->atr_list[request->atr_count].deleted_ind
    = dm.deleted_ind
  WITH nocounter
 ;end select
 IF ((request->atr_count > 0))
  EXECUTE dm_atr_task_req_import
 ENDIF
 UPDATE  FROM dm_project_status_env dm,
   (dummyt d  WITH seq = value(size(tr_list->tr,5)))
  SET dm.dm_status = "SUCCESS", dm.dm_status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (dm
   WHERE dm.environment_id=envid
    AND (cnvtint(substring(1,(findstring("_",dm.proj_name) - 1),dm.proj_name))=tr_list->tr[d.seq].
   t_num)
    AND (cnvtint(substring((findstring("_",dm.proj_name)+ 1),(tr_list->tr[d.seq].len - findstring("_",
      dm.proj_name)),dm.proj_name))=tr_list->tr[d.seq].r_num)
    AND dm.schema_date <= cnvtdatetime(tr_list->tr[d.seq].s_dt)
    AND dm.proj_type="TASK_REQ REL"
    AND dm.dm_status="RUNNING")
  WITH nocounter
 ;end update
 COMMIT
#end_program
 SET reply->status_data.status = "S"
END GO
