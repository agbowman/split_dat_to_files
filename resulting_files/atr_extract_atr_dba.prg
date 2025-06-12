CREATE PROGRAM atr_extract_atr:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET appstring = build(request->application_number)
 SET filename = concat("cclsource:app",appstring,".csv")
 SET reply->status_data.status = "F"
 SELECT INTO filename
  a.*
  FROM application a
  WHERE (a.application_number=request->application_number)
  HEAD REPORT
   y = build("application_number, ","owner, ","app_description, ","app_active_ind, ","app_text, ",
    "log_access_ind, ","application_ini_ind, ","object_name, ","direct_access_ind, ","log_level, ",
    "request_log_level, ","min_version_required"), col 0, y
  DETAIL
   x = check(build(a.application_number,",",'"',a.owner,'"',
     ",",'"',a.description,'"',",",
     a.active_ind,",",'"',a.text,'"',
     ",",a.log_access_ind,",",a.application_ini_ind,",",
     a.object_name,",",a.direct_access_ind,",",a.log_level,
     ",",a.request_log_level,",",a.min_version_required)), row + 1, col 0,
   x
  WITH maxcol = 1000, noformfeed, maxrow = 1
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "application"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "none qualified"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
