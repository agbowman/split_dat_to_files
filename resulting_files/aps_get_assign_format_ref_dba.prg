CREATE PROGRAM aps_get_assign_format_ref:dba
 RECORD reply(
   1 activity_subtype_qual[*]
     2 cdf_meaning = c12
     2 display = c40
     2 code_value = f8
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
 SET cnt = 0
 SET cnt2 = 0
 SELECT INTO "nl:"
  cv.cdf_meaning, cv2.definition
  FROM code_value cv,
   (dummyt d  WITH seq = 1),
   code_value cv2
  PLAN (cv
   WHERE (cv.code_value=request->activity_type_cd))
   JOIN (d
   WHERE d.seq=1)
   JOIN (cv2
   WHERE cv2.code_set=5801
    AND cv2.definition=cv.cdf_meaning)
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->activity_subtype_qual,5)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,5)=1
    AND cnt != 1)
    stat = alterlist(reply->activity_subtype_qual,(cnt+ 4))
   ENDIF
   reply->activity_subtype_qual[cnt].cdf_meaning = cv2.cdf_meaning, reply->activity_subtype_qual[cnt]
   .display = cv2.display, reply->activity_subtype_qual[cnt].code_value = cv2.code_value
  FOOT REPORT
   stat = alterlist(reply->activity_subtype_qual,cnt)
  WITH outerjoin = d, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->activity_subtype_qual,0)
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
