CREATE PROGRAM bed_get_rad_seg_dup:dba
 FREE SET reply
 RECORD reply(
   1 segments[*]
     2 code_value = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rcnt = 0
 SET cnt = 0
 SET rcnt = size(request->segments,5)
 IF (rcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rcnt)),
   code_value c
  PLAN (d)
   JOIN (c
   WHERE c.code_set=14003
    AND cnvtupper(c.display)=cnvtupper(request->segments[d.seq].display))
  HEAD c.code_value
   cnt = (cnt+ 1), stat = alterlist(reply->segments,cnt), reply->segments[cnt].code_value = c
   .code_value,
   reply->segments[cnt].display = c.display
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
