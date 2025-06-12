CREATE PROGRAM bed_get_rad_acc_class:dba
 FREE SET reply
 RECORD reply(
   1 accession_classes[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 accession_format
       3 code_value = f8
       3 display = vc
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_count = 0
 SELECT INTO "nl:"
  FROM accession_class a,
   code_value cv
  PLAN (a
   WHERE a.accession_format_cd > 0)
   JOIN (cv
   WHERE cv.code_value=a.accession_class_cd
    AND cv.code_set=2056
    AND cv.active_ind=1)
  HEAD REPORT
   cnt = 0, list_count = 0, stat = alterlist(reply->accession_classes,200)
  DETAIL
   list_count = (list_count+ 1), cnt = (cnt+ 1)
   IF (list_count > 200)
    stat = alterlist(reply->accession_classes,(cnt+ 200)), list_count = 1
   ENDIF
   reply->accession_classes[cnt].code_value = a.accession_class_cd, reply->accession_classes[cnt].
   display = cv.display, reply->accession_classes[cnt].description = cv.description,
   reply->accession_classes[cnt].accession_format.code_value = a.accession_format_cd
  FOOT REPORT
   stat = alterlist(reply->accession_classes,cnt)
  WITH nocounter
 ;end select
 SET cnt = size(reply->accession_classes,5)
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_value=reply->accession_classes[d.seq].accession_format.code_value))
   DETAIL
    reply->accession_classes[d.seq].accession_format.display = cv.display, reply->accession_classes[d
    .seq].accession_format.description = cv.description
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
