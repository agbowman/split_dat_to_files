CREATE PROGRAM crsection_discover_keys:dba
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
 SET modify = predeclare
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE now = q8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM ccr_section s
  PLAN (s
   WHERE s.updt_dt_tm > cnvtdatetime(request->since)
    AND s.beg_effective_dt_tm <= cnvtdatetime(now)
    AND s.end_effective_dt_tm > cnvtdatetime(now))
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(reply->keys,5))
    stat = alterlist(reply->keys,(cnt+ 9))
   ENDIF
   reply->keys[cnt].key_id = cnvtstring(s.prev_section_id), reply->keys[cnt].changed = cnvtdatetime(s
    .updt_dt_tm)
  FOOT REPORT
   stat = alterlist(reply->keys,cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ccr_section_criteria sc
  PLAN (sc
   WHERE sc.updt_dt_tm > cnvtdatetime(request->since)
    AND sc.beg_effective_dt_tm <= cnvtdatetime(now)
    AND sc.end_effective_dt_tm > cnvtdatetime(now))
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(reply->keys,5))
    stat = alterlist(reply->keys,(cnt+ 9))
   ENDIF
   reply->keys[cnt].key_id = cnvtstring(sc.section_id), reply->keys[cnt].changed = cnvtdatetime(sc
    .updt_dt_tm)
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
