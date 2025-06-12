CREATE PROGRAM dcp_load_pregnancy_concepts:dba
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
 SET readme_data->message = "Readme Failed: Starting script dcp_load_pregnancy_concepts"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE num_records = i4 WITH protect, noconstant(0)
 FREE RECORD copy_requestin
 RECORD copy_requestin(
   1 list[*]
     2 code_set = f8
     2 cdf_meaning = vc
     2 concept_cki = vc
 )
 SET num_records = size(requestin->list_0,5)
 SET stat = alterlist(copy_requestin->list,num_records)
 FOR (i = 1 TO num_records)
   SET copy_requestin->list[i].code_set = cnvtreal(requestin->list_0[i].code_set)
   SET copy_requestin->list[i].cdf_meaning = trim(requestin->list_0[i].cdf_meaning)
   SET copy_requestin->list[i].concept_cki = trim(requestin->list_0[i].concept_cki)
 ENDFOR
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("FAIL: Readme failed while copying into copyrequestin structure:",
   errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM code_value cv,
   (dummyt d  WITH seq = num_records)
  SET cv.concept_cki = copy_requestin->list[d.seq].concept_cki
  PLAN (d)
   JOIN (cv
   WHERE (cv.code_set=copy_requestin->list[d.seq].code_set)
    AND (cv.cdf_meaning=copy_requestin->list[d.seq].cdf_meaning)
    AND ((cv.concept_cki=null) OR (cv.concept_cki=" ")) )
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Fail to update concept_cki in code_value:",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Batch Data Loaded Successfully"
#exit_script
 FREE RECORD copy_requestin
END GO
