CREATE PROGRAM core_get_cd_value_group_by_cd:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 cd_value_grp_list[*]
     2 child_code_value = f8
     2 code_set = i4
     2 collation_seq = i4
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
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cvg.child_code_value, cvg.code_set, cvg.collation_seq,
  cvg.parent_code_value, cv.display, cv.description,
  cv.cdf_meaning
  FROM code_value_group cvg,
   code_value cv
  PLAN (cvg
   WHERE (cvg.parent_code_value=request->code_value))
   JOIN (cv
   WHERE cv.code_value=cvg.child_code_value)
  HEAD REPORT
   grp_cnt = 0
  DETAIL
   grp_cnt += 1
   IF (mod(grp_cnt,10)=1)
    stat = alterlist(reply->cd_value_grp_list,(grp_cnt+ 9))
   ENDIF
   reply->cd_value_grp_list[grp_cnt].child_code_value = cvg.child_code_value, reply->
   cd_value_grp_list[grp_cnt].code_set = cv.code_set, reply->cd_value_grp_list[grp_cnt].collation_seq
    = cvg.collation_seq,
   reply->cd_value_grp_list[grp_cnt].display = cv.display, reply->cd_value_grp_list[grp_cnt].
   description = cv.description, reply->cd_value_grp_list[grp_cnt].cdf_meaning = cv.cdf_meaning
  FOOT REPORT
   stat = alterlist(reply->cd_value_grp_list,grp_cnt)
  WITH nocounter
 ;end select
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
 SET script_version = "000 02/26/03 JF8275"
END GO
