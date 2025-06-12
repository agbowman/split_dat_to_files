CREATE PROGRAM codeset_discover_keys:dba
 RECORD reply(
   1 keys[*]
     2 key_id = vc
     2 changed = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE cap = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value_set c
  PLAN (c
   WHERE c.updt_dt_tm > cnvtdatetime(request->since))
  DETAIL
   IF (cnt=cap)
    IF (cap=0)
     cap = 4
    ELSE
     cap = (cap * 2)
    ENDIF
    stat = alterlist(reply->keys,cap)
   ENDIF
   cnt = (cnt+ 1), reply->keys[cnt].key_id = cnvtstring(c.code_set), reply->keys[cnt].changed = c
   .updt_dt_tm
  FOOT REPORT
   stat = alterlist(reply->keys,cnt)
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
