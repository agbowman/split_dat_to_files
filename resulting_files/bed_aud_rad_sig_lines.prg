CREATE PROGRAM bed_aud_rad_sig_lines
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
  )
 ENDIF
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "format_id"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Signature Line Format"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Active Status"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Line Number"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Literal Text"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Data Pulled in"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Date/Time"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SELECT INTO "nl:"
  FROM sign_line_format slf,
   sign_line_format_detail slfd,
   code_value cv,
   code_value cv2
  PLAN (slf
   WHERE  EXISTS (
   (SELECT
    slfd1.format_id
    FROM sign_line_format_detail slfd1,
     code_value cv
    WHERE slfd1.format_id=slf.format_id
     AND slfd1.data_element_cd=cv.code_value
     AND cv.cdf_meaning=patstring("RA*"))))
   JOIN (slfd
   WHERE slfd.format_id=slf.format_id)
   JOIN (cv
   WHERE cv.code_value=slfd.data_element_cd)
   JOIN (cv2
   WHERE cv2.code_value=slfd.data_element_format_cd)
  ORDER BY slf.format_id, slfd.line_nbr, slfd.column_pos
  HEAD REPORT
   stat = alterlist(reply->rowlist,10), cnt = 0, end_cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=0)
    stat = alterlist(reply->rowlist,(cnt+ 10))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,7), reply->rowlist[cnt].celllist[1].double_value =
   slf.format_id, reply->rowlist[cnt].celllist[2].string_value = slf.description
   CASE (slf.active_ind)
    OF 1:
     reply->rowlist[cnt].celllist[3].string_value = "Yes"
    OF 0:
     reply->rowlist[cnt].celllist[3].string_value = "No"
   ENDCASE
   reply->rowlist[cnt].celllist[4].string_value = concat("Line ",cnvtstring(slfd.line_nbr)), reply->
   rowlist[cnt].celllist[5].string_value = slfd.literal_display, reply->rowlist[cnt].celllist[6].
   string_value = cv.display,
   reply->rowlist[cnt].celllist[7].string_value = cv2.display, end_cnt = cnt
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
END GO
