CREATE PROGRAM dm_ocd_get_feature_app:dba
 SET debug = validate(fa_debug,- (1))
 FREE RECORD reply
 RECORD reply(
   1 app_count = i4
   1 app[*]
     2 application_number = i4
     2 feature_number = i4
     2 schema_date = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET app_count = 0
 SET stat = alterlist(reply->app,0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  da.*
  FROM dm_application da
  WHERE (da.feature_number=request->feature_number)
   AND da.deleted_ind=0
  ORDER BY da.application_number
  DETAIL
   reply->app_count = (reply->app_count+ 1), cnt = reply->app_count, stat = alterlist(reply->app,cnt),
   reply->app[cnt].application_number = da.application_number, reply->app[cnt].feature_number = da
   .feature_number, reply->app[cnt].feature_number = da.schema_date
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  da.application_number, da.feature_number, sd = max(da.schema_date),
  max(dat.schema_date), max(dt.schema_date)
  FROM dm_application da,
   dm_application_task_r dat,
   dm_application_task dt
  PLAN (dt
   WHERE (dt.feature_number=request->feature_number)
    AND dt.deleted_ind=0)
   JOIN (dat
   WHERE dat.task_number=dt.task_number
    AND dat.deleted_ind=0)
   JOIN (da
   WHERE da.application_number=dat.application_number
    AND da.deleted_ind=0)
  GROUP BY da.application_number, da.feature_number
  DETAIL
   found = 0
   FOR (i = 1 TO reply->app_count)
     IF ((reply->app[i].application_number=da.application_number))
      found = i
      IF ((reply->app[found].schema_date < sd))
       reply->app[found].feature_number = da.feature_number, reply->app[found].schema_date = sd
      ENDIF
      i = reply->app_count
     ENDIF
   ENDFOR
   IF (found=0)
    reply->app_count = (reply->app_count+ 1), cnt = reply->app_count, stat = alterlist(reply->app,cnt
     ),
    reply->app[cnt].application_number = da.application_number, reply->app[cnt].feature_number = da
    .feature_number, reply->app[cnt].schema_date = sd
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  da.application_number, da.feature_number, sd = max(da.schema_date),
  max(dat.schema_date), max(dt.schema_date), max(dtr.schema_date),
  max(dr.schema_date)
  FROM dm_application da,
   dm_application_task_r dat,
   dm_application_task dt,
   dm_task_request_r dtr,
   dm_request dr
  PLAN (dr
   WHERE (dr.feature_number=request->feature_number)
    AND dr.deleted_ind=0)
   JOIN (dtr
   WHERE dtr.request_number=dr.request_number
    AND dtr.deleted_ind=0)
   JOIN (dt
   WHERE dt.task_number=dtr.task_number
    AND dt.deleted_ind=0)
   JOIN (dat
   WHERE dat.task_number=dt.task_number
    AND dat.deleted_ind=0)
   JOIN (da
   WHERE da.application_number=dat.application_number
    AND da.deleted_ind=0)
  GROUP BY da.application_number, da.feature_number
  DETAIL
   found = 0
   FOR (i = 1 TO reply->app_count)
     IF ((reply->app[i].application_number=da.application_number))
      found = i
      IF ((reply->app[found].schema_date < sd))
       reply->app[found].feature_number = da.feature_number, reply->app[found].schema_date = sd
      ENDIF
      i = reply->app_count
     ENDIF
   ENDFOR
   IF (found=0)
    reply->app_count = (reply->app_count+ 1), cnt = reply->app_count, stat = alterlist(reply->app,cnt
     ),
    reply->app[cnt].application_number = da.application_number, reply->app[cnt].feature_number = da
    .feature_number, reply->app[cnt].schema_date = sd
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  da.application_number, da.feature_number, sd = max(da.schema_date),
  max(dat.schema_date)
  FROM dm_application da,
   dm_application_task_r dat
  PLAN (dat
   WHERE (dat.feature_number=request->feature_number)
    AND dat.deleted_ind=0)
   JOIN (da
   WHERE da.application_number=dat.application_number
    AND da.deleted_ind=0)
  GROUP BY da.application_number, da.feature_number
  DETAIL
   found = 0
   FOR (i = 1 TO reply->app_count)
     IF ((reply->app[i].application_number=da.application_number))
      found = i
      IF ((reply->app[found].schema_date < sd))
       reply->app[found].feature_number = da.feature_number, reply->app[found].schema_date = sd
      ENDIF
      i = reply->app_count
     ENDIF
   ENDFOR
   IF (found=0)
    reply->app_count = (reply->app_count+ 1), cnt = reply->app_count, stat = alterlist(reply->app,cnt
     ),
    reply->app[cnt].application_number = da.application_number, reply->app[cnt].feature_number = da
    .feature_number, reply->app[cnt].schema_date = sd
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  da.application_number, da.feature_number, sd = max(da.schema_date),
  max(dat.schema_date), max(dtr.schema_date)
  FROM dm_application da,
   dm_application_task_r dat,
   dm_task_request_r dtr
  PLAN (dtr
   WHERE (dtr.feature_number=request->feature_number)
    AND dtr.deleted_ind=0)
   JOIN (dat
   WHERE dat.task_number=dtr.task_number
    AND dat.deleted_ind=0)
   JOIN (da
   WHERE da.application_number=dat.application_number
    AND da.deleted_ind=0)
  GROUP BY da.application_number, da.feature_number
  DETAIL
   found = 0
   FOR (i = 1 TO reply->app_count)
     IF ((reply->app[i].application_number=da.application_number))
      found = i
      IF ((reply->app[found].schema_date < sd))
       reply->app[found].feature_number = da.feature_number, reply->app[found].schema_date = sd
      ENDIF
      i = reply->app_count
     ENDIF
   ENDFOR
   IF (found=0)
    reply->app_count = (reply->app_count+ 1), cnt = reply->app_count, stat = alterlist(reply->app,cnt
     ),
    reply->app[cnt].application_number = da.application_number, reply->app[cnt].feature_number = da
    .feature_number, reply->app[cnt].schema_date = sd
   ENDIF
  WITH nocounter
 ;end select
 IF (debug=1)
  EXECUTE t_ocd_get_feature_app
 ENDIF
 SET reply->status_data.status = "S"
#end_program
END GO
