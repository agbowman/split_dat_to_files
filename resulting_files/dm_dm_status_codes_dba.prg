CREATE PROGRAM dm_dm_status_codes:dba
 RECORD reply(
   1 authentic_cd = f8
   1 unauthentic_cd = f8
   1 active_cd = f8
   1 inactive_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET activecnt = 0
 SET authcnt = 0
 SELECT INTO "nl:"
  c.code_value
  FROM dm_code_value c
  WHERE c.code_set=48
   AND c.display_key IN ("ACTIVE", "INACTIVE")
  ORDER BY c.display_key
  DETAIL
   IF (activecnt=0)
    reply->active_cd = c.code_value, activecnt = 1
   ELSE
    reply->inactive_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value, c.cdf_meaning
  FROM dm_code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning IN ("AUTH", "UNAUTH")
  ORDER BY c.cdf_meaning
  DETAIL
   IF (authcnt=0)
    reply->authentic_cd = c.code_value, authcnt = 1
   ELSE
    reply->unauthentic_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
END GO
