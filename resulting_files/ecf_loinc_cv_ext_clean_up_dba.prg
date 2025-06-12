CREATE PROGRAM ecf_loinc_cv_ext_clean_up:dba
 IF (validate(readme_data,"0")="0")
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
  SET kia_notreadme = 1
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script ecf_loinc_cv_ext_clean_up..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "1", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "1"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-HP.HX"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "1", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "1"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-PTH.BRST"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "1", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "1"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-PTH.GENE"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "1", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "1"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-PTH.PRST"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "1", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "1"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-PTH.BRST"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "1", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "1"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-PTH.SKIN"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "4", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "4"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-SUR.ADT"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "1", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "1"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-CL.ROU"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value c
  SET c.cdf_meaning = "LNC-EY.SLT.N", c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (
   updt_cnt+ 1)
  WHERE c.display="EYE.SLITLAMP.NEI"
   AND c.code_set=15849
   AND c.code_value IN (
  (SELECT
   cv.code_value
   FROM code_value_extension cv
   WHERE cv.field_name="LNC_CLASS_TYPE"))
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "2", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "2"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-EY.SLT.N"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value c
  SET c.cdf_meaning = "LNC-PAE.HHS", c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (
   updt_cnt+ 1)
  WHERE c.display="PANEL.SURVEY.HHS"
   AND c.code_set=15849
   AND c.code_value IN (
  (SELECT
   cv.code_value
   FROM code_value_extension cv
   WHERE cv.field_name="LNC_CLASS_TYPE"))
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "4", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "4"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-PAE.HHS"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value c
  SET c.cdf_meaning = "LNC-PAE.A.MD", c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (
   updt_cnt+ 1)
  WHERE c.display="PANEL.ATTACH.MOD"
   AND c.code_set=15849
   AND c.code_value IN (
  (SELECT
   cv.code_value
   FROM code_value_extension cv
   WHERE cv.field_name="LNC_CLASS_TYPE"))
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "3", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "3"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-PAE.A.MD"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value c
  SET c.cdf_meaning = "LNC-PA.SU.PA", c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (
   updt_cnt+ 1)
  WHERE c.display="PANEL.SURVEY.PAS"
   AND c.code_set=15849
   AND c.code_value IN (
  (SELECT
   cv.code_value
   FROM code_value_extension cv
   WHERE cv.field_name="LNC_CLASS_TYPE"))
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "4", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "4"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-PA.SU.PA"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value c
  SET c.cdf_meaning = "LNC-PL.SY.CP", c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (
   updt_cnt+ 1)
  WHERE c.display="PANEL.SURVEY.COOP"
   AND c.code_set=15849
   AND c.code_value IN (
  (SELECT
   cv.code_value
   FROM code_value_extension cv
   WHERE cv.field_name="LNC_CLASS_TYPE"))
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "4", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "4"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-PL.SY.CP"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value c
  SET c.cdf_meaning = "LNC-SEY.ACT", c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (
   updt_cnt+ 1)
  WHERE c.display="SURVEY.ACT"
   AND c.code_set=15849
   AND c.code_value IN (
  (SELECT
   cv.code_value
   FROM code_value_extension cv
   WHERE cv.field_name="LNC_CLASS_TYPE"))
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "4", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "4"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-SEY.ACT"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
 ;end update
 UPDATE  FROM code_value c
  SET c.cdf_meaning = "LNC-PAN.EP", c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (
   updt_cnt+ 1)
  WHERE c.display="PANEL.SURVEY.EPDS"
   AND c.code_set=15849
   AND c.code_value IN (
  (SELECT
   cv.code_value
   FROM code_value_extension cv
   WHERE cv.field_name="LNC_CLASS_TYPE"))
 ;end update
 UPDATE  FROM code_value_extension cv
  SET cv.field_value = "4", cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_cnt = (updt_cnt+
   1)
  WHERE cv.field_value != "4"
   AND cv.code_value IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=15849
    AND cdf_meaning="LNC-PAN.EP"))
   AND cv.field_name="LNC_CLASS_TYPE"
  WITH nocounter
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
