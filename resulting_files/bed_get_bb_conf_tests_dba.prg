CREATE PROGRAM bed_get_bb_conf_tests:dba
 FREE SET reply
 RECORD reply(
   1 test_list[*]
     2 test_id = f8
     2 test_disp = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 DECLARE repcnt = i4
 DECLARE conftest_cd = f8
 DECLARE primary_cd = f8
 DECLARE catcd = f8
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET repcnt = 0
 SET conftest_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=1635
    AND cv.active_ind=1
    AND cv.cdf_meaning="PRODUCT ABO")
  DETAIL
   conftest_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "T"
  SET error_msg = "No PRODUCT ABO meaning found on code set 1635"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM service_directory s,
   order_catalog_synonym ocs
  PLAN (s
   WHERE s.bb_processing_cd=conftest_cd
    AND s.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=s.catalog_cd
    AND ocs.active_ind=1)
  DETAIL
   repcnt = (repcnt+ 1), stat = alterlist(reply->test_list,repcnt), reply->test_list[repcnt].test_id
    = ocs.synonym_id,
   reply->test_list[repcnt].test_disp = ocs.mnemonic
  WITH nocounter
 ;end select
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_BB_CONF_TESTS  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
