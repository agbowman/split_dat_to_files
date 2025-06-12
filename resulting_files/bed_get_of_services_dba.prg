CREATE PROGRAM bed_get_of_services:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 service_code_value = f8
     2 service_display = c40
     2 service_cdf_meaning = c12
     2 selected_ind = i2
     2 folder_name = c500
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_ccount = 0
 SET ccount = 0
 SELECT INTO "NL:"
  FROM code_value cv,
   br_of_parent_reltn b,
   alt_sel_cat a
  PLAN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=34)
   JOIN (b
   WHERE b.source_id=outerjoin(cv.code_value)
    AND b.source_name=outerjoin("CODE_VALUE"))
   JOIN (a
   WHERE a.alt_sel_category_id=outerjoin(b.alt_sel_category_id))
  ORDER BY cv.display
  HEAD REPORT
   stat = alterlist(reply->slist,20)
  DETAIL
   tot_ccount = (tot_ccount+ 1), ccount = (ccount+ 1)
   IF (ccount > 20)
    stat = alterlist(reply->slist,(tot_ccount+ 20)), ccount = 0
   ENDIF
   reply->slist[tot_ccount].service_code_value = cv.code_value, reply->slist[tot_ccount].
   service_display = cv.display, reply->slist[tot_ccount].service_cdf_meaning = cv.cdf_meaning
   IF (b.alt_sel_category_id > 0.0)
    reply->slist[tot_ccount].selected_ind = 1, reply->slist[tot_ccount].folder_name = a
    .short_description
   ELSE
    reply->slist[tot_ccount].selected_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->slist,tot_ccount)
  WITH nocounter
 ;end select
 IF (tot_ccount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
