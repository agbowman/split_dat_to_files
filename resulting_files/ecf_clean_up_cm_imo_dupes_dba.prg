CREATE PROGRAM ecf_clean_up_cm_imo_dupes:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script ecf_clean_up_cm_imo_dupes..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM cmt_cross_map cm
  SET end_effective_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 20171001, updt_dt_tm =
   cnvtdatetime(curdate,curtime3)
  WHERE cm.concept_cki="IMO!*"
   AND cm.end_effective_dt_tm > sysdate
   AND cm.map_type_cd IN (
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=29223
    AND cv.cdf_meaning IN ("IMO-SNMCT", "IMO<SNMCT", "IMO=ICD10CM", "IMO=ICD9", "IMO=SNMCT",
   "IMO>SNMCT")))
   AND  NOT ( EXISTS (
  (SELECT
   1
   FROM cmt_cross_map_load cl
   WHERE cl.concept_cki=cm.concept_cki
    AND cl.target_concept_cki=cm.target_concept_cki
    AND cl.group_sequence=cm.group_sequence
    AND cl.map_type_cd=cm.map_type_cd)))
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("DM_INFO Constraint Update Failed",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
