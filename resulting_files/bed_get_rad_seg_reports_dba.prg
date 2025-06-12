CREATE PROGRAM bed_get_rad_seg_reports:dba
 FREE SET reply
 RECORD reply(
   1 reports[*]
     2 code_value = f8
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET rad_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="RADIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   rad_cd = cv.code_value
  WITH nocounter
 ;end select
 SET text_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.display_key="TEXT"
    AND cv.active_ind=1)
  DETAIL
   text_cd = cv.code_value
  WITH nocounter
 ;end select
 SET read_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=14286
    AND cv.cdf_meaning="READ"
    AND cv.active_ind=1)
  DETAIL
   read_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM discrete_task_assay d
  PLAN (d
   WHERE d.activity_type_cd=rad_cd
    AND d.default_result_type_cd=text_cd
    AND d.rad_section_type_cd=read_cd
    AND d.active_ind=1)
  ORDER BY d.mnemonic
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->reports,cnt), reply->reports[cnt].code_value = d
   .task_assay_cd,
   reply->reports[cnt].mnemonic = d.mnemonic
  WITH nocounter
 ;end select
#exit_script
 IF (size(reply->reports,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
