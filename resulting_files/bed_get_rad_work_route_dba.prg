CREATE PROGRAM bed_get_rad_work_route:dba
 FREE SET reply
 RECORD reply(
   1 exams[*]
     2 code_value = f8
     2 exam_rooms[*]
       3 code_value = f8
       3 display = c40
       3 description = c60
       3 sequence = i4
       3 default_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ecnt = size(request->exams,5)
 SET stat = alterlist(reply->exams,ecnt)
 FOR (e = 1 TO ecnt)
   SET reply->exams[e].code_value = request->exams[e].code_value
 ENDFOR
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = ecnt),
   assay_resource_list arl,
   code_value cv
  PLAN (d)
   JOIN (arl
   WHERE (arl.task_assay_cd=request->exams[d.seq].code_value)
    AND arl.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=arl.service_resource_cd
    AND cv.active_ind=1)
  ORDER BY arl.task_assay_cd
  HEAD arl.task_assay_cd
   rcnt = 0, alterlist_rcnt = 0, stat = alterlist(reply->exams[d.seq].exam_rooms,50)
  DETAIL
   rcnt = (rcnt+ 1), alterlist_rcnt = (alterlist_rcnt+ 1)
   IF (alterlist_rcnt > 50)
    stat = alterlist(reply->exams[d.seq].exam_rooms,(rcnt+ 50)), alterlist_rcnt = 1
   ENDIF
   reply->exams[d.seq].exam_rooms[rcnt].code_value = cv.code_value, reply->exams[d.seq].exam_rooms[
   rcnt].display = cv.display, reply->exams[d.seq].exam_rooms[rcnt].description = cv.description,
   reply->exams[d.seq].exam_rooms[rcnt].sequence = arl.sequence, reply->exams[d.seq].exam_rooms[rcnt]
   .default_ind = arl.primary_ind
  FOOT  arl.task_assay_cd
   stat = alterlist(reply->exams[d.seq].exam_rooms,rcnt)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
