CREATE PROGRAM bed_get_iview_prsnls:dba
 FREE SET reply
 RECORD reply(
   1 prsnls[*]
     2 id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ucnt = 0
 SET pcnt = 0
 SET ucnt = size(request->prsnls,5)
 IF (ucnt=0)
  GO TO exit_script
 ENDIF
 SET pcnt = size(request->positions,5)
 IF (pcnt=0)
  GO TO exit_script
 ENDIF
 SET cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ucnt)),
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=request->prsnls[d.seq].id))
  ORDER BY p.person_id
  HEAD p.person_id
   found = 0
   FOR (x = 1 TO pcnt)
     IF ((p.position_cd=request->positions[x].code_value))
      found = 1
     ENDIF
   ENDFOR
   IF (found=1)
    cnt = (cnt+ 1), stat = alterlist(reply->prsnls,cnt), reply->prsnls[cnt].id = p.person_id
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
