CREATE PROGRAM aps_get_sign_lines:dba
 RECORD reply(
   1 sign_line_qual[*]
     2 description = c60
     2 format_id = f8
     2 updt_cnt = i4
     2 active_ind = i2
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
 DECLARE srequest = vc WITH protect, noconstant
 SET srequest = concat(trim(request->data_element_prefix),"*")
 SELECT INTO "nl:"
  slf.description
  FROM sign_line_format slf
  PLAN (slf
   WHERE  EXISTS (
   (SELECT
    slfd.format_id
    FROM sign_line_format_detail slfd,
     code_value cv
    WHERE slfd.format_id=slf.format_id
     AND slfd.data_element_cd=cv.code_value
     AND cv.cdf_meaning=patstring(srequest))))
  ORDER BY slf.format_id
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->sign_line_qual,5)
  HEAD slf.format_id
   cnt = (cnt+ 1)
   IF (mod(cnt,5)
    AND cnt != 1)
    stat = alterlist(reply->sign_line_qual,(cnt+ 4))
   ENDIF
   reply->sign_line_qual[cnt].description = slf.description, reply->sign_line_qual[cnt].format_id =
   slf.format_id, reply->sign_line_qual[cnt].updt_cnt = slf.updt_cnt,
   reply->sign_line_qual[cnt].active_ind = slf.active_ind
  FOOT REPORT
   stat = alterlist(reply->sign_line_qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->sign_line_qual,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
