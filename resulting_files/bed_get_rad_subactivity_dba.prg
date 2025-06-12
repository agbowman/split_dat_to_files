CREATE PROGRAM bed_get_rad_subactivity:dba
 FREE SET reply
 RECORD reply(
   1 relations[*]
     2 subactivity
       3 code_value = f8
       3 display = vc
       3 description = vc
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
  FROM br_name_value brv
  WHERE brv.br_nv_key1="RAD_SUB_ACC_FORMAT"
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,20)=1)
    stat = alterlist(reply->relations,(cnt+ 19))
   ENDIF
   reply->relations[cnt].subactivity.code_value = cnvtint(brv.br_name), reply->relations[cnt].
   accession_format.code_value = cnvtint(brv.br_value)
  FOOT REPORT
   stat = alterlist(reply->relations,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE cv.code_set=5801
     AND (cv.code_value=reply->relations[d.seq].subactivity.code_value)
     AND cv.active_ind=1)
   DETAIL
    reply->relations[d.seq].subactivity.description = cv.description, reply->relations[d.seq].
    subactivity.display = cv.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE cv.code_set=2057
     AND (cv.code_value=reply->relations[d.seq].accession_format.code_value)
     AND cv.active_ind=1)
   DETAIL
    reply->relations[cnt].accession_format.display = cv.display, reply->relations[cnt].
    accession_format.description = cv.description
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
