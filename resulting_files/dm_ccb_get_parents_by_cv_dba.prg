CREATE PROGRAM dm_ccb_get_parents_by_cv:dba
 SET modify = predeclare
 IF (validate(reply)=0)
  FREE RECORD reply
  RECORD reply(
    1 cd_value_parent_list[*]
      2 parent_code_value = f8
      2 code_set = i4
      2 display = c40
      2 description = vc
      2 cdf_meaning = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE failed = c1 WITH public, noconstant("F")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cvg.child_code_value, cvg.code_set, cvg.parent_code_value,
  cv.display, cv.description, cv.cdf_meaning
  FROM code_value_group cvg,
   code_value cv
  PLAN (cvg
   WHERE (cvg.child_code_value=request->code_value))
   JOIN (cv
   WHERE cv.code_value=cvg.parent_code_value)
  HEAD REPORT
   grp_cnt = 0
  DETAIL
   grp_cnt += 1
   IF (mod(grp_cnt,10)=1)
    stat = alterlist(reply->cd_value_parent_list,(grp_cnt+ 9))
   ENDIF
   reply->cd_value_parent_list[grp_cnt].parent_code_value = cvg.parent_code_value, reply->
   cd_value_parent_list[grp_cnt].code_set = cv.code_set, reply->cd_value_parent_list[grp_cnt].display
    = cv.display,
   reply->cd_value_parent_list[grp_cnt].description = cv.description, reply->cd_value_parent_list[
   grp_cnt].cdf_meaning = cv.cdf_meaning
  FOOT REPORT
   stat = alterlist(reply->cd_value_parent_list,grp_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(reply)
 IF (curqual < 1)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
