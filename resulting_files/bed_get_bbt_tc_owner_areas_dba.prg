CREATE PROGRAM bed_get_bbt_tc_owner_areas:dba
 FREE SET reply
 RECORD reply(
   1 owner_areas[*]
     2 owner_code_value = f8
     2 display = vc
     2 description = vc
     2 inv_areas[*]
       3 inv_code_value = f8
       3 display = vc
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SET owner_root = 0.0
 SET inv_area = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning IN ("BBOWNERROOT", "BBINVAREA")
   AND cv.active_ind=1
  DETAIL
   CASE (cv.cdf_meaning)
    OF "BBOWNERROOT":
     owner_root = cv.code_value
    OF "BBINVAREA":
     inv_area = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM location l,
   location_group lg,
   location l2,
   code_value cv,
   code_value cv2
  PLAN (l
   WHERE l.location_type_cd=owner_root
    AND l.active_ind=1
    AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (lg
   WHERE lg.parent_loc_cd=l.location_cd
    AND lg.active_ind=1
    AND lg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND lg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (l2
   WHERE l2.location_cd=lg.child_loc_cd
    AND l2.location_type_cd=inv_area
    AND l2.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg.parent_loc_cd
    AND cv.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=lg.child_loc_cd
    AND cv2.active_ind=1)
  ORDER BY lg.parent_loc_cd, lg.child_loc_cd
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->owner_areas,100)
  HEAD lg.parent_loc_cd
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->owner_areas,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->owner_areas[tot_cnt].owner_code_value = lg.parent_loc_cd, reply->owner_areas[tot_cnt].
   display = cv.display, reply->owner_areas[tot_cnt].description = cv.description,
   icnt = 0, itot_cnt = 0, stat = alterlist(reply->owner_areas[tot_cnt].inv_areas,100)
  HEAD lg.child_loc_cd
   icnt = (icnt+ 1), itot_cnt = (itot_cnt+ 1)
   IF (icnt > 100)
    stat = alterlist(reply->owner_areas[tot_cnt].inv_areas,(itot_cnt+ 100)), icnt = 1
   ENDIF
   reply->owner_areas[tot_cnt].inv_areas[itot_cnt].inv_code_value = lg.child_loc_cd, reply->
   owner_areas[tot_cnt].inv_areas[itot_cnt].display = cv2.display, reply->owner_areas[tot_cnt].
   inv_areas[itot_cnt].description = cv2.description
  FOOT  lg.parent_loc_cd
   stat = alterlist(reply->owner_areas[tot_cnt].inv_areas,itot_cnt)
  FOOT REPORT
   stat = alterlist(reply->owner_areas,tot_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
