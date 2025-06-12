CREATE PROGRAM assist_get_owner:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 owner_qual = i4
    1 owner[10]
      2 owner = c30
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET table_name = "ALL_TABLES"
 SET kount = 0
 IF ((request->owner != "ALL*"))
  SELECT DISTINCT INTO "NL:"
   a.owner
   FROM all_tables a
   WHERE (a.owner=request->owner)
   DETAIL
    kount = (kount+ 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alter(reply->owner,(kount+ 10))
    ENDIF
    reply->owner[kount].owner = a.owner
   WITH nocounter
  ;end select
  SET reply->owner_qual = kount
  IF (curqual=0)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = false
  ELSE
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = true
  ENDIF
 ELSE
  SELECT DISTINCT INTO "NL:"
   a.owner
   FROM all_tables a
   DETAIL
    kount = (kount+ 1)
    IF (mod(kount,10)=1
     AND kount != 1)
     stat = alter(reply->owner,(kount+ 10))
    ENDIF
    reply->owner[kount].owner = a.owner
   WITH nocounter
  ;end select
  SET reply->owner_qual = kount
  IF (curqual=0)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = false
  ELSE
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = true
  ENDIF
 ENDIF
 SET stat = alter(reply->owner,reply->owner_qual)
 GO TO end_program
#end_program
END GO
