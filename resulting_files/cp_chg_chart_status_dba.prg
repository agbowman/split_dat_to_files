CREATE PROGRAM cp_chg_chart_status:dba
 SET failed = "F"
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET precount = 0
 SET postcount = 0
 SELECT INTO "nl:"
  status_flag
  FROM chart_request
  WHERE (status_flag >= - (1))
   AND chart_request_id > 0.0
   AND chart_status_cd=0
  WITH nocounter
 ;end select
 SET precount = curqual
 IF (precount > 0)
  SET code_set = 18609
  SET cdf_meaning = "INPROCESS"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE (status_flag=- (1))
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount = curqual
  SET cdf_meaning = "UNPROCESSED"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=0
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "SUCCESSFUL"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=1
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "PRINTNOTINST"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag IN (2, 3, 5)
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "ERRSAVECHART"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=4
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "CRMERROR"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=6
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "ERRNOTIFYRRD"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=7
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "ERRREQOHNDL"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=8
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "ERRUPDTOHNDL"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=9
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "ERRLOADCS"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=10
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "EVNTSERVERR"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=11
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "ERRLOADCF"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=12
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "ERRMICROFORM"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=13
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "UNKNOWN"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE ((status_flag IN (14, 15, 19, 20, 23)) OR (status_flag > 23))
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "ERRDATASOURC"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=16
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "INVALIDCR"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=17
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "NODATA"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=18
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "SKIPPED"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=21
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  SET cdf_meaning = "ERRORDERSUM"
  SET code_value = 0.0
  EXECUTE cpm_get_cd_for_cdf
  UPDATE  FROM chart_request
   SET chart_status_cd = code_value
   WHERE status_flag=22
    AND chart_request_id > 0.0
    AND chart_status_cd=0
  ;end update
  SET postcount += curqual
  IF (postcount < precount)
   CALL echo("Failed in update chart_request!")
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  CALL echo("Successful!")
  COMMIT
 ELSE
  CALL echo("Failed!")
  ROLLBACK
 ENDIF
END GO
