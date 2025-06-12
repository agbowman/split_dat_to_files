CREATE PROGRAM bed_get_sn_inv_locs:dba
 FREE SET reply
 RECORD reply(
   1 bad_data_flag = i2
   1 inv_locators[*]
     2 code_value = f8
     2 display = c40
     2 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_view
 RECORD temp_view(
   1 views[*]
     2 code_value = f8
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_cnt = 0
 SET loc_cnt = 0
 SELECT INTO "nl:"
  FROM location_group lg,
   code_value cv
  PLAN (lg
   WHERE (lg.parent_loc_cd=request->inv_location_code_value)
    AND lg.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg.child_loc_cd
    AND cv.cdf_meaning="INVLOCATOR"
    AND cv.active_ind=1)
  ORDER BY lg.child_loc_cd
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(reply->inv_locators,100)
  HEAD lg.child_loc_cd
   cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(reply->inv_locators,(cnt+ 100)), list_cnt = 1
   ENDIF
   reply->inv_locators[cnt].code_value = cv.code_value, reply->inv_locators[cnt].display = cv.display,
   reply->inv_locators[cnt].sequence = lg.sequence
  FOOT REPORT
   stat = alterlist(reply->inv_locators,cnt)
  WITH nocoutner
 ;end select
 IF (cnt > 0)
  SET cnt2 = 0
  SET list_cnt2 = 0
  SELECT DISTINCT INTO "nl:"
   lg.root_loc_cd
   FROM location_group lg
   PLAN (lg
    WHERE (lg.parent_loc_cd=request->inv_location_code_value)
     AND lg.active_ind=1)
   HEAD REPORT
    cnt2 = 0, list_cnt2 = 0, stat = alterlist(temp_view->views,10)
   DETAIL
    cnt2 = (cnt2+ 1), list_cnt2 = (list_cnt2+ 1)
    IF (list_cnt2 > 10)
     stat = alterlist(temp_view->views,(cnt2+ 10)), list_cnt2 = 1
    ENDIF
    temp_view->views[cnt2].code_value = lg.root_loc_cd
   FOOT REPORT
    stat = alterlist(temp_view->views,cnt2)
   WITH nocoutner
  ;end select
  FOR (x = 1 TO cnt2)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = cnt),
      location_group lg
     PLAN (d)
      JOIN (lg
      WHERE (lg.parent_loc_cd=request->inv_location_code_value)
       AND (lg.root_loc_cd=temp_view->views[x].code_value)
       AND (lg.child_loc_cd=reply->inv_locators[d.seq].code_value))
     ORDER BY d.seq
     HEAD REPORT
      loc_cnt = 0
     DETAIL
      loc_cnt = (loc_cnt+ 1)
      IF ((lg.sequence != reply->inv_locators[d.seq].sequence))
       reply->bad_data_flag = 1
      ENDIF
     FOOT REPORT
      IF (loc_cnt != cnt)
       reply->bad_data_flag = 2, x = cnt2
      ENDIF
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
