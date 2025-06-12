CREATE PROGRAM dcp_get_cv_and_cvg:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = vc
     2 cdf_meaning = vc
     2 child_code_value = f8
     2 display2 = vc
     2 collation_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  cv.code_value, cv.display, cv2_cv = decode(cv2.seq,cv2.display,""),
  cvg_ccv = decode(cvg.seq,cvg.child_code_value,0.0)
  FROM code_value cv,
   code_value cv2,
   code_value_group cvg,
   dummyt d1
  PLAN (cv
   WHERE cv.code_set=25451
    AND cv.active_ind=1)
   JOIN (d1)
   JOIN (cvg
   WHERE cv.code_value=cvg.parent_code_value)
   JOIN (cv2
   WHERE cvg.child_code_value=cv2.code_value
    AND cv2.code_set=6026)
  ORDER BY cv.cdf_meaning, cv.display
  HEAD REPORT
   stat = alterlist(reply->qual,10)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].code_value = cv.code_value, reply->qual[count1].display = cv.display, reply->
   qual[count1].cdf_meaning = cv.cdf_meaning,
   reply->qual[count1].collation_seq = cv.collation_seq, reply->qual[count1].child_code_value = cvg
   .child_code_value, reply->qual[count1].display2 = cv2.display,
   CALL echo(build("display = ",reply->qual[count1].display))
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter, dontcare = cvg, dontcare = cv2
 ;end select
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP PIP Tool"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO RETRIEVE"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
