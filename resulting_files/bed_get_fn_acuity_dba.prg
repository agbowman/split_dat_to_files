CREATE PROGRAM bed_get_fn_acuity:dba
 FREE SET reply
 RECORD reply(
   1 alist[*]
     2 code_value = f8
     2 description = vc
     2 display = vc
     2 active_ind = i2
     2 color = vc
     2 icon = i4
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET count = 0
 SET stat = alterlist(reply->alist,5)
 SET acuity_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16409
   AND cv.active_ind=1
   AND cv.cdf_meaning="ACUITY"
  DETAIL
   acuity_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM track_reference tr
  PLAN (tr
   WHERE (tr.tracking_group_cd=request->trk_group_code_value)
    AND tr.tracking_ref_type_cd=acuity_code_value)
  DETAIL
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 5)
    stat = alterlist(reply->alist,(tot_count+ 5)), count = 1
   ENDIF
   reply->alist[tot_count].description = tr.description, reply->alist[tot_count].display = tr.display,
   reply->alist[tot_count].code_value = tr.assoc_code_value,
   reply->alist[tot_count].active_ind = tr.active_ind, reply->alist[tot_count].color = tr.ref_color,
   reply->alist[tot_count].icon = tr.ref_icon
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->alist,tot_count)
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
