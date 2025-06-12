CREATE PROGRAM aps_get_sign_line_by_id:dba
 RECORD reply(
   1 sign_line_qual[*]
     2 line_nbr = i4
     2 column_pos = i4
     2 literal_disp = vc
     2 literal_size = i4
     2 data_elem = c40
     2 data_elem_cd = f8
     2 data_elem_fmt_cd = f8
     2 max_size = i4
     2 suppress_line_ind = i2
   1 active_ind = i2
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
 SELECT INTO "nl:"
  slf.active_ind, sldf.format_id, cv.display
  FROM sign_line_format_detail sldf,
   sign_line_format slf,
   (dummyt d  WITH seq = 1),
   code_value cv
  PLAN (slf
   WHERE (request->format_id=slf.format_id))
   JOIN (sldf
   WHERE sldf.format_id=slf.format_id)
   JOIN (d)
   JOIN (cv
   WHERE cv.code_set=14287
    AND cv.code_value=sldf.data_element_cd)
  HEAD REPORT
   reply->active_ind = slf.active_ind, stat = alterlist(reply->sign_line_qual,5)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,5)=1
    AND cnt != 1)
    stat = alterlist(reply->sign_line_qual,(cnt+ 4))
   ENDIF
   reply->sign_line_qual[cnt].line_nbr = sldf.line_nbr, reply->sign_line_qual[cnt].column_pos = sldf
   .column_pos
   IF (sldf.data_element_cd > 0)
    reply->sign_line_qual[cnt].data_elem = cv.display
   ELSE
    reply->sign_line_qual[cnt].data_elem = ""
   ENDIF
   reply->sign_line_qual[cnt].data_elem_cd = sldf.data_element_cd, reply->sign_line_qual[cnt].
   data_elem_fmt_cd = sldf.data_element_format_cd, reply->sign_line_qual[cnt].literal_disp = sldf
   .literal_display,
   reply->sign_line_qual[cnt].literal_size = sldf.literal_size, reply->sign_line_qual[cnt].max_size
    = sldf.max_size, reply->sign_line_qual[cnt].suppress_line_ind = sldf.suppress_line_ind
  FOOT REPORT
   stat = alterlist(reply->sign_line_qual,cnt)
  WITH outerjoin = d, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET stat = alterlist(reply->sign_line_qual,0)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
