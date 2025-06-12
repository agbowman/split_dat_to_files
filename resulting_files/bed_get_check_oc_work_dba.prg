CREATE PROGRAM bed_get_check_oc_work:dba
 FREE SET reply
 RECORD reply(
   1 check_multi_match_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE br_parse = vc
 SET error_msg = " "
 SET reply->status_data.status = "F"
 SET cpt4_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.cki="CKI.CODEVALUE!3600"
  DETAIL
   cpt4_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET catalog_display = fillstring(42," ")
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.active_ind=1
   AND (cv.code_value=request->catalog_type_code_value)
  DETAIL
   catalog_display = concat("'",trim(cnvtupper(cv.display)),"'")
  WITH nocounter
 ;end select
 SET activity_display = fillstring(42," ")
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.active_ind=1
   AND (cv.code_value=request->activity_type_code_value)
  DETAIL
   activity_display = concat("'",trim(cnvtupper(cv.display)),"'")
  WITH nocounter
 ;end select
 SET subactivity_display = fillstring(42," ")
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=5801
   AND cv.active_ind=1
   AND (cv.code_value=request->subactivity_type_code_value)
  DETAIL
   subactivity_display = concat("'",trim(cnvtupper(cv.display)),"'")
  WITH nocounter
 ;end select
 SET br_parse = concat("b.oc_id > 0 and b.status_ind = 0")
 IF (catalog_display > "   *")
  SET br_parse = concat(br_parse," and cnvtupper(b.catalog_type) =",catalog_display)
 ENDIF
 IF (activity_display > "   *")
  SET br_parse = concat(br_parse," and cnvtupper(b.activity_type) =",activity_display)
 ENDIF
 IF (subactivity_display > "   *")
  SET br_parse = concat(br_parse," and cnvtupper(b.activity_subtype) =",subactivity_display)
 ENDIF
 CALL echo(br_parse)
 SELECT INTO "NL:"
  FROM br_oc_work b,
   br_oc_pricing bp
  PLAN (b
   WHERE parser(br_parse))
   JOIN (bp
   WHERE bp.oc_id=b.oc_id
    AND bp.billcode_sched_cd=outerjoin(cpt4_code_value))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->check_multi_match_ind = 0
 ELSE
  SET reply->check_multi_match_ind = 1
 ENDIF
 IF ((reply->check_multi_match_ind=0))
  SELECT INTO "NL:"
   FROM br_oc_work b
   WHERE parser(br_parse)
    AND b.loinc_code > "   *"
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->check_multi_match_ind = 0
  ELSE
   SET reply->check_multi_match_ind = 1
  ENDIF
 ENDIF
#exit_script
 IF (error_msg=" ")
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
