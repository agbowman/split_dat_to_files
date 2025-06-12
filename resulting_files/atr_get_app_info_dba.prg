CREATE PROGRAM atr_get_app_info:dba
 RECORD reply(
   1 application_number = i4
   1 feature_number = i4
   1 schema_date = dq8
   1 owner = c20
   1 description = vc
   1 active_ind = i2
   1 log_access_ind = i2
   1 direct_access_ind = i2
   1 application_ini_ind = i2
   1 disable_cache_ind = i2
   1 log_level = i2
   1 request_log_level = i2
   1 min_version_required = vc
   1 object_name = vc
   1 active_dt_tm = dq8
   1 inactive_dt_tm = dq8
   1 last_localized_dt_tm = dq8
   1 text = vc
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  a.application_number, nullind_a_active_dt_tm = nullind(a.active_dt_tm), nullind_a_inactive_dt_tm =
  nullind(a.inactive_dt_tm),
  nullind_a_last_localized_dt_tm = nullind(a.last_localized_dt_tm)
  FROM application a
  WHERE (a.application_number=request->application_number)
  DETAIL
   reply->application_number = a.application_number, reply->owner = a.owner, reply->description = a
   .description,
   reply->active_ind = a.active_ind, reply->log_access_ind = a.log_access_ind, reply->
   direct_access_ind = a.direct_access_ind,
   reply->application_ini_ind = a.application_ini_ind, reply->disable_cache_ind = a.disable_cache_ind,
   reply->log_level = a.log_level,
   reply->request_log_level = a.request_log_level, reply->min_version_required = a
   .min_version_required, reply->object_name = a.object_name,
   reply->active_dt_tm =
   IF (nullind_a_active_dt_tm=0) cnvtdatetime(a.active_dt_tm)
   ENDIF
   , reply->inactive_dt_tm =
   IF (nullind_a_inactive_dt_tm=0) cnvtdatetime(a.inactive_dt_tm)
   ENDIF
   , reply->last_localized_dt_tm =
   IF (nullind_a_last_localized_dt_tm=0) cnvtdatetime(a.last_localized_dt_tm)
   ENDIF
   ,
   reply->text = a.text, reply->updt_cnt = a.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
