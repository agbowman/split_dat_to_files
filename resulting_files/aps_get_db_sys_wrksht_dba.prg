CREATE PROGRAM aps_get_db_sys_wrksht:dba
 RECORD reply(
   1 cyto_worksheet_cd = f8
   1 wksheet_cnt = i4
   1 wksheet_param_qual[4]
     2 field_name = c32
     2 field_type = i4
     2 field_value = vc
     2 updt_cnt = i4
     2 updt_task = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value_extension cve
  PLAN (cv
   WHERE cv.code_set=1308
    AND cv.cdf_meaning="CYTO WSHEET")
   JOIN (cve
   WHERE cv.code_value=cve.code_value)
  HEAD REPORT
   dt_cntr = 0, reply->cyto_worksheet_cd = cve.code_value
  DETAIL
   dt_cntr = (dt_cntr+ 1), reply->wksheet_cnt = dt_cntr
   IF (mod(dt_cntr,4)=1
    AND dt_cntr != 1)
    stat = alter(reply->wksheet_param_qual,dt_cntr)
   ENDIF
   reply->wksheet_param_qual[dt_cntr].field_name = cve.field_name, reply->wksheet_param_qual[dt_cntr]
   .field_type = cve.field_type, reply->wksheet_param_qual[dt_cntr].field_value = cve.field_value,
   reply->wksheet_param_qual[dt_cntr].updt_cnt = cve.updt_cnt, reply->wksheet_param_qual[dt_cntr].
   updt_task = cve.updt_task
  FOOT REPORT
   stat = alter(reply->wksheet_param_qual,dt_cntr)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE, CODE_VALUE_EXTENSION"
  SET failed = "T"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
