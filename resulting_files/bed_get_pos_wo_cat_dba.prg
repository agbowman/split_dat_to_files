CREATE PROGRAM bed_get_pos_wo_cat:dba
 FREE SET reply
 RECORD reply(
   1 plist[*]
     2 pos_code_value = f8
     2 pos_display = vc
     2 pos_description = vc
     2 pos_meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 IF ((request->max_reply > 0))
  SET max_reply = request->max_reply
 ELSE
  SET max_reply = 10000
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=88
    AND cv.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    b.position_cd
    FROM br_position_cat_comp b
    WHERE b.position_cd=cv.code_value))))
  ORDER BY cv.display
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->plist,cnt), reply->plist[cnt].pos_code_value = cv
   .code_value,
   reply->plist[cnt].pos_display = cv.display, reply->plist[cnt].pos_description = cv.description,
   reply->plist[cnt].pos_meaning = cv.cdf_meaning
  WITH maxrec = value(max_reply), nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (size(reply->plist,5) >= max_reply)
  SET stat = alterlist(reply->plist,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSEIF (size(reply->plist,5) > 0)
  SET reply->status_data.status = "S"
 ELSEIF (size(reply->plist,5)=0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
