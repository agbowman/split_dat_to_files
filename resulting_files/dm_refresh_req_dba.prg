CREATE PROGRAM dm_refresh_req:dba
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
 FREE SET r_list
 RECORD r_list(
   1 count = i4
   1 r[*]
     2 r_num = i4
     2 f_num = i4
     2 s_dt = dq8
 )
 SET r_list->count = 0
 SELECT INTO "nl:"
  dm.proj_name
  FROM dm_project_status_env dm
  WHERE dm.environment_id=envid
   AND dm.proj_type="REQUEST"
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
   FROM dm_request da
   WHERE da.request_number=cnvtint(dm.proj_name)
    AND datetimediff(da.schema_date,dm.schema_date)=0))
  ORDER BY dm.proj_name
  HEAD dm.proj_name
   r_list->count = (r_list->count+ 1)
   IF (mod(r_list->count,10)=1)
    stat = alterlist(r_list->r,(r_list->count+ 9))
   ENDIF
   r_list->r[r_list->count].r_num = cnvtint(dm.proj_name)
  DETAIL
   x = 1
  WITH nocounter, forupdatewait(dm)
 ;end select
 SET stat = alterlist(r_list->r,r_list->count)
 IF ((r_list->count=0))
  GO TO end_program
 ENDIF
 SET cnt = 0
 FOR (cnt = 1 TO r_list->count)
   SELECT INTO "NL:"
    dcf.schema_date
    FROM dm_project_status_env dcf
    WHERE (cnvtint(dcf.proj_name)=r_list->r[cnt].r_num)
     AND dcf.proj_type="REQUEST"
     AND dcf.environment_id=envid
     AND ((dcf.dm_status = null) OR (((dcf.dm_status="FAILED") OR (dcf.dm_status="SUCCESS")) ))
    DETAIL
     IF ((dcf.schema_date > r_list->r[cnt].s_dt))
      r_list->r[cnt].s_dt = dcf.schema_date
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 UPDATE  FROM dm_project_status_env dm,
   (dummyt d  WITH seq = value(size(r_list->r,5)))
  SET dm.dm_status = "RUNNING", dm.dm_status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (dm
   WHERE dm.environment_id=envid
    AND (cnvtint(dm.proj_name)=r_list->r[d.seq].r_num)
    AND dm.proj_type="REQUEST"
    AND ((dm.dm_status = null) OR (dm.dm_status="FAILED")) )
  WITH nocounter
 ;end update
 COMMIT
 FREE SET request
 RECORD request(
   1 atr_count = i4
   1 atr_list[*]
     2 request_number = i4
     2 description = c200
     2 request_name = c20
     2 epilog_script = c30
     2 prolog_script = c30
     2 write_to_que_ind = i2
     2 active_ind = i2
     2 active_dt_tm = dq8
     2 inactive_dt_tm = dq88
     2 cachetime = i4
     2 cachegrace = i4
     2 cachestale = i4
     2 cachetrim = c20
     2 requestclass = i4
     2 text = vc
     2 feature_number = i4
     2 schema_date = dq8
     2 deleted_ind = i2
 )
 SET request->atr_count = 0
 SET stat = alterlist(request->atr_list,0)
 SET trace symbol mark
 SELECT INTO "nl:"
  FROM dm_request dm,
   (dummyt d  WITH seq = value(size(r_list->r,5)))
  PLAN (d)
   JOIN (dm
   WHERE (dm.request_number=r_list->r[d.seq].r_num)
    AND datetimediff(dm.schema_date,cnvtdatetime(r_list->r[d.seq].s_dt))=0)
  DETAIL
   request->atr_count = (request->atr_count+ 1), stat = alterlist(request->atr_list,request->
    atr_count), request->atr_list[request->atr_count].feature_number = 0,
   request->atr_list[request->atr_count].request_number = dm.request_number, request->atr_list[
   request->atr_count].deleted_ind = dm.deleted_ind, request->atr_list[request->atr_count].
   description = dm.description,
   request->atr_list[request->atr_count].request_name = dm.request_name, request->atr_list[request->
   atr_count].epilog_script = dm.epilog_script, request->atr_list[request->atr_count].prolog_script
    = dm.prolog_script,
   request->atr_list[request->atr_count].write_to_que_ind = dm.write_to_que_ind, request->atr_list[
   request->atr_count].active_ind = dm.active_ind, request->atr_list[request->atr_count].active_dt_tm
    = cnvtdatetime(dm.active_dt_tm),
   request->atr_list[request->atr_count].inactive_dt_tm = cnvtdatetime(dm.inactive_dt_tm), request->
   atr_list[request->atr_count].cachetime = dm.cachetime, request->atr_list[request->atr_count].
   cachegrace = dm.cachegrace,
   request->atr_list[request->atr_count].cachestale = dm.cachestale, request->atr_list[request->
   atr_count].cachetrim = dm.cachetrim, request->atr_list[request->atr_count].requestclass = dm
   .requestclass,
   request->atr_list[request->atr_count].text = dm.text
  WITH nocounter
 ;end select
 IF ((request->atr_count > 0))
  EXECUTE dm_atr_req_import
 ENDIF
 UPDATE  FROM dm_project_status_env dm,
   (dummyt d  WITH seq = value(size(r_list->r,5)))
  SET dm.dm_status = "SUCCESS", dm.dm_status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (dm
   WHERE dm.environment_id=envid
    AND (cnvtint(dm.proj_name)=r_list->r[d.seq].r_num)
    AND dm.schema_date <= cnvtdatetime(r_list->r[d.seq].s_dt)
    AND dm.proj_type="REQUEST"
    AND dm.dm_status="RUNNING")
  WITH nocounter
 ;end update
 COMMIT
#end_program
 SET reply->status_data.status = "S"
END GO
