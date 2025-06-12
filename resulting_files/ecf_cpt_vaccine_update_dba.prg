CREATE PROGRAM ecf_cpt_vaccine_update:dba
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
 SET readme_data->message = "Readme failed: starting script ecf_cpt_vaccine_update..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM nomenclature n
  SET n.beg_effective_dt_tm = cnvtdatetime(cnvtdate(12112020),0), n.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), n.updt_cnt = (n.updt_cnt+ 1)
  WHERE n.cmti IN ("749B6634-47E1-4B02-B7E1-04F262B28545", "1B58FC73-AB25-44CD-A46F-D357C676B1BE",
  "BBCE3A71-3043-476A-897D-5618E9B8C31A")
   AND n.source_vocabulary_cd IN (
  (SELECT
   c.code_value
   FROM code_value c
   WHERE c.cdf_meaning="CPT4"
    AND c.code_set=400
    AND c.active_ind=1))
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("COVID vaccine NOMEN rows update failed",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM cmt_concept c
  SET c.beg_effective_dt_tm = cnvtdatetime(cnvtdate(12112020),0), c.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), c.updt_cnt = (c.updt_cnt+ 1)
  WHERE c.concept_cki IN ("CPT4!0001A", "CPT4!0002A", "CPT4!91300")
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("COVID vaccine CONCEPT rows update failed",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM cmt_concept_reltn r
  SET r.beg_effective_dt_tm = cnvtdatetime(cnvtdate(12112020),0), r.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), r.updt_cnt = (r.updt_cnt+ 1)
  WHERE r.concept_cki1 IN ("CPT4!0001A", "CPT4!0002A", "CPT4!91300")
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("COVID vaccine RELATION rows update failed",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM nomenclature n
  SET n.beg_effective_dt_tm = cnvtdatetime(cnvtdate(12172020),0), n.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), n.updt_cnt = (n.updt_cnt+ 1)
  WHERE n.cmti IN ("B45B630D-388E-4B96-960E-6F0208F6B67A", "FF3D842A-23F8-45AB-91EE-80826CB96C29",
  "38718535-F31C-4ACB-8DF5-3B5D7831FD72")
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("COVID vaccine rows update Failed",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM cmt_concept c
  SET c.beg_effective_dt_tm = cnvtdatetime(cnvtdate(12172020),0), c.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), c.updt_cnt = (c.updt_cnt+ 1)
  WHERE c.concept_cki IN ("CPT4!0011A", "CPT4!0012A", "CPT4!91301")
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("COVID vaccine CONCEPT rows update failed",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM cmt_concept_reltn r
  SET r.beg_effective_dt_tm = cnvtdatetime(cnvtdate(12172020),0), r.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), r.updt_cnt = (r.updt_cnt+ 1)
  WHERE r.concept_cki1 IN ("CPT4!0011A", "CPT4!0012A", "CPT4!91301")
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("COVID vaccine RELATION rows update failed",errmsg)
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
