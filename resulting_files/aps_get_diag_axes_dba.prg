CREATE PROGRAM aps_get_diag_axes:dba
 RECORD reply(
   1 code_value_qual[10]
     2 child_code = f8
     2 child_display = c40
     2 parent_code = f8
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
 SET x = 0
 SELECT INTO "nl:"
  c2.code_value, c2.display
  FROM code_value c,
   code_value_group cg,
   code_value c2
  PLAN (c
   WHERE c.code_set=400
    AND c.active_ind=1)
   JOIN (cg
   WHERE cg.parent_code_value=c.code_value)
   JOIN (c2
   WHERE c2.code_value=cg.child_code_value)
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1)
   IF (mod(x,10)=1
    AND x != 1)
    stat = alter(reply->code_value_qual,(x+ 9))
   ENDIF
   reply->code_value_qual[x].child_code = cg.child_code_value, reply->code_value_qual[x].
   child_display = c2.display, reply->code_value_qual[x].parent_code = cg.parent_code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE_GROUP"
 ELSE
  SET stat = alter(reply->code_value_qual,x)
 ENDIF
#exit_script
 IF (failed="F")
  IF (x=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
