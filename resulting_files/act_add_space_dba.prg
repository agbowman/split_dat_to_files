CREATE PROGRAM act_add_space:dba
 RECORD reply(
   1 object_space_id = f8
   1 object_space_name = vc
   1 object_space_expiration = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET spaceid = 0.0
 SELECT INTO "nl:"
  FROM object_space s
  PLAN (s
   WHERE (s.object_space_name=request->object_space_name))
  DETAIL
   spaceid = s.object_space_id
  WITH nocounter
 ;end select
 IF (spaceid > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
 IF ((request->object_space_id=0.0))
  SELECT INTO "nl:"
   y = seq(object_space_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    spaceid = cnvtreal(y)
  ;end select
  SET reply->object_space_id = spaceid WITH format, nocounter
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   GO TO exit_script
  ENDIF
 ELSE
  SET spaceid = request->object_space_id
 ENDIF
 SET reply->object_space_id = spaceid
 INSERT  FROM object_space s
  SET s.object_space_id = spaceid, s.object_space_name = request->object_space_name, s
   .object_space_expiration = request->object_space_expiration
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  ROLLBACK
  SET reply->status = "F"
 ELSE
  COMMIT
  SET reply->object_space_name = request->object_space_name
  SET reply->object_space_expiration = request->object_space_expiration
  SET reply->status = "S"
 ENDIF
END GO
