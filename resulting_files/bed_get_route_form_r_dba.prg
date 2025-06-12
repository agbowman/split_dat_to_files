CREATE PROGRAM bed_get_route_form_r:dba
 FREE SET reply
 RECORD reply(
   1 codes[*]
     2 code_value = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 IF ((request->route_code_value > 0))
  SELECT INTO "nl:"
   FROM route_form_r r,
    code_value cv
   PLAN (r
    WHERE (r.route_cd=request->route_code_value))
    JOIN (cv
    WHERE cv.code_value=r.form_cd
     AND cv.active_ind=1)
   ORDER BY cv.code_value
   HEAD REPORT
    cnt = 0, tot_cnt = 0, stat = alterlist(reply->codes,10)
   HEAD cv.code_value
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 10)
     stat = alterlist(reply->codes,(tot_cnt+ 10)), cnt = 1
    ENDIF
    reply->codes[tot_cnt].code_value = cv.code_value, reply->codes[tot_cnt].display = cv.display
   FOOT REPORT
    stat = alterlist(reply->codes,tot_cnt)
   WITH nocounter
  ;end select
 ELSEIF ((request->form_code_value > 0))
  SELECT INTO "nl:"
   FROM route_form_r r,
    code_value cv
   PLAN (r
    WHERE (r.form_cd=request->form_code_value))
    JOIN (cv
    WHERE cv.code_value=r.route_cd
     AND cv.active_ind=1)
   ORDER BY cv.code_value
   HEAD REPORT
    cnt = 0, tot_cnt = 0, stat = alterlist(reply->codes,10)
   HEAD cv.code_value
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 10)
     stat = alterlist(reply->codes,(tot_cnt+ 10)), cnt = 1
    ENDIF
    reply->codes[tot_cnt].code_value = cv.code_value, reply->codes[tot_cnt].display = cv.display
   FOOT REPORT
    stat = alterlist(reply->codes,tot_cnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
