CREATE PROGRAM bed_get_pharm_freq:dba
 FREE SET reply
 RECORD reply(
   1 freqs[*]
     2 freq_code_value = f8
     2 display = vc
     2 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value_group cvg,
   code_value cv,
   code_value cv2
  PLAN (cvg)
   JOIN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1
    AND cv.code_value=cvg.parent_code_value)
   JOIN (cv2
   WHERE cv2.code_set=4003
    AND cv2.code_value=cvg.child_code_value
    AND cv2.active_ind=1)
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->freqs,100)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->freqs,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->freqs[tot_cnt].freq_code_value = cv2.code_value, reply->freqs[tot_cnt].display = cv2
   .display, reply->freqs[tot_cnt].meaning = cv2.cdf_meaning
  FOOT REPORT
   stat = alterlist(reply->freqs,tot_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
