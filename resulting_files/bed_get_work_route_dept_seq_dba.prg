CREATE PROGRAM bed_get_work_route_dept_seq:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 activity_type_code_value = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 departments[*]
      2 code_value = f8
      2 display = c40
      2 description = c60
      2 sequence = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET key1 = fillstring(50," ")
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE (cv.code_value=request->activity_type_code_value)
  DETAIL
   IF (((cv.cdf_meaning="GLB") OR (cv.cdf_meaning="HLX")) )
    key1 = "RT_LAB_DEPT_SEQ"
   ELSEIF (cv.cdf_meaning="RADIOLOGY")
    key1 = "RT_RAD_DEPT_SEQ"
   ELSEIF (cv.cdf_meaning="AP")
    key1 = "RT_AP_DEPT_SEQ"
   ELSEIF (cv.cdf_meaning="BB")
    key1 = "RT_BB_DEPT_SEQ"
   ELSEIF (cv.cdf_meaning="MICROBIOLOGY")
    key1 = "RT_MB_DEPT_SEQ"
   ELSEIF (cv.cdf_meaning="HLA")
    key1 = "RT_HLA_DEPT_SEQ"
   ENDIF
  WITH nocounter
 ;end select
 IF (key1=" ")
  GO TO exit_script
 ENDIF
 SET dcnt = 0
 SET alterlist_dcnt = 0
 SET stat = alterlist(reply->departments,50)
 SELECT INTO "NL:"
  FROM br_name_value bnv,
   code_value cv
  PLAN (bnv
   WHERE bnv.br_nv_key1=key1)
   JOIN (cv
   WHERE cv.code_value=cnvtint(bnv.br_name)
    AND cv.active_ind=1)
  DETAIL
   dcnt = (dcnt+ 1), alterlist_dcnt = (alterlist_dcnt+ 1)
   IF (alterlist_dcnt > 50)
    stat = alterlist(reply->departments,(dcnt+ 50)), alterlist_dcnt = 1
   ENDIF
   reply->departments[dcnt].code_value = cv.code_value, reply->departments[dcnt].display = cv.display,
   reply->departments[dcnt].description = cv.description,
   reply->departments[dcnt].sequence = cnvtint(bnv.br_value)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->departments,dcnt)
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
