CREATE PROGRAM ccl_get_query_sysprefs:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 ccl_query_maxtimeout = i4
   1 ccl_query_defaulttimeout = i4
 )
 DECLARE errmsg = c255
 SET errmsg = fillstring(255," ")
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET reply->ccl_query_maxtimeout = 0
 SET reply->ccl_query_defaulttimeout = 0
 SELECT INTO "nl:"
  ap.app_prefs_id, ap.prsnl_id, ap.position_cd,
  nv.pvc_name, nv.pvc_value, nv.seq,
  ap.seq
  FROM app_prefs ap,
   name_value_prefs nv
  PLAN (nv
   WHERE nv.pvc_name="CCL_QUERY*"
    AND nv.parent_entity_name="APP_PREFS"
    AND nv.active_ind=1)
   JOIN (ap
   WHERE nv.parent_entity_id=ap.app_prefs_id
    AND ap.prsnl_id >= 0
    AND ap.position_cd >= 0)
  ORDER BY nv.pvc_name
  DETAIL
   IF (nv.pvc_name="CCL_QUERY_MAXTIMEOUT")
    reply->ccl_query_maxtimeout = cnvtint(nv.pvc_value)
   ENDIF
   IF (nv.pvc_name="CCL_QUERY_DEFAULTTIMEOUT")
    reply->ccl_query_defaulttimeout = cnvtint(nv.pvc_value)
   ENDIF
  WITH nocounter, dontcare(nv)
 ;end select
 IF (curqual=0)
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "APP_PREFS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(concat("Discern query max timeout= ",build(reply->ccl_query_maxtimeout)," seconds"))
  CALL echo(concat("Discern query default timeout= ",build(reply->ccl_query_defaulttimeout),
    " seconds"))
 ENDIF
END GO
