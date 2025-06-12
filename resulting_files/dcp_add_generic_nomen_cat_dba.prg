CREATE PROGRAM dcp_add_generic_nomen_cat:dba
 SET categorytypecd = 0.0
 SET sourcevocabcd = 0.0
 SET prinicipletypecd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET categoryname = fillstring(100," ")
 SET categoryname = "Generic Name"
 SET code_set = 18129
 SET cdf_meaning = "ALLERGIES"
 EXECUTE cpm_get_cd_for_cdf
 SET categorytypecd = code_value
 SET code_set = 400
 SET cdf_meaning = "MICROMEDEX"
 EXECUTE cpm_get_cd_for_cdf
 SET sourcevocabcd = code_value
 SET code_set = 401
 SET cdf_meaning = "GENNAME"
 EXECUTE cpm_get_cd_for_cdf
 SET principletypecd = code_value
 IF (categorytypecd != 0
  AND sourcevocabcd != 0
  AND principletypecd != 0)
  SELECT INTO "nl:"
   FROM dcp_nomencategory n
   WHERE n.category_type_cd=categorytypecd
    AND n.source_vocabulary_cd=sourcevocabcd
    AND n.principle_type_cd=principletypecd
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo(build("Inserting -",categoryname))
   INSERT  FROM dcp_nomencategory n
    SET n.category_id = seq(carenet_seq,nextval), n.category_type_cd = categorytypecd, n.sequence = 2,
     n.category_name = categoryname, n.custom_category_ind = 0, n.source_vocabulary_cd =
     sourcevocabcd,
     n.principle_type_cd = principletypecd, n.default_ind = 0, n.updt_cnt = 0,
     n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 2321, n.updt_task = 0,
     n.updt_applctx = 0
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 SET categoryname = "Generic Formulation"
 SET code_set = 18129
 SET cdf_meaning = "ALLERGIES"
 EXECUTE cpm_get_cd_for_cdf
 SET categorytypecd = code_value
 SET code_set = 400
 SET cdf_meaning = "MICROMEDEX"
 EXECUTE cpm_get_cd_for_cdf
 SET sourcevocabcd = code_value
 SET code_set = 401
 SET cdf_meaning = "GENFORM"
 EXECUTE cpm_get_cd_for_cdf
 SET principletypecd = code_value
 IF (categorytypecd != 0
  AND sourcevocabcd != 0
  AND principletypecd != 0)
  SELECT INTO "nl:"
   FROM dcp_nomencategory n
   WHERE n.category_type_cd=categorytypecd
    AND n.source_vocabulary_cd=sourcevocabcd
    AND n.principle_type_cd=principletypecd
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo(build("Inserting -",categoryname))
   INSERT  FROM dcp_nomencategory n
    SET n.category_id = seq(carenet_seq,nextval), n.category_type_cd = categorytypecd, n.sequence = 3,
     n.category_name = categoryname, n.custom_category_ind = 0, n.source_vocabulary_cd =
     sourcevocabcd,
     n.principle_type_cd = principletypecd, n.default_ind = 0, n.updt_cnt = 0,
     n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 2321, n.updt_task = 0,
     n.updt_applctx = 0
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 SET categoryname = "ICD9"
 SET code_set = 18129
 SET cdf_meaning = "REACTIONS"
 EXECUTE cpm_get_cd_for_cdf
 SET categorytypecd = code_value
 SET code_set = 400
 SET cdf_meaning = "ICD9"
 EXECUTE cpm_get_cd_for_cdf
 SET sourcevocabcd = code_value
 SET code_set = 401
 SET cdf_meaning = "FINDING"
 EXECUTE cpm_get_cd_for_cdf
 SET principletypecd = code_value
 IF (categorytypecd != 0
  AND sourcevocabcd != 0
  AND principletypecd != 0)
  SELECT INTO "nl:"
   FROM dcp_nomencategory n
   WHERE n.category_type_cd=categorytypecd
    AND n.source_vocabulary_cd=sourcevocabcd
    AND n.principle_type_cd=principletypecd
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo(build("Inserting -",categoryname))
   INSERT  FROM dcp_nomencategory n
    SET n.category_id = seq(carenet_seq,nextval), n.category_type_cd = categorytypecd, n.sequence = 2,
     n.category_name = categoryname, n.custom_category_ind = 0, n.source_vocabulary_cd =
     sourcevocabcd,
     n.principle_type_cd = principletypecd, n.default_ind = 0, n.updt_cnt = 0,
     n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 2321, n.updt_task = 0,
     n.updt_applctx = 0
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 SET categoryname = "SNOMED Symptoms"
 SET code_set = 18129
 SET cdf_meaning = "REACTIONS"
 EXECUTE cpm_get_cd_for_cdf
 SET categorytypecd = code_value
 SET code_set = 400
 SET cdf_meaning = "SNM2"
 EXECUTE cpm_get_cd_for_cdf
 SET sourcevocabcd = code_value
 SET code_set = 401
 SET cdf_meaning = "DIAG"
 EXECUTE cpm_get_cd_for_cdf
 SET principletypecd = code_value
 IF (categorytypecd != 0
  AND sourcevocabcd != 0
  AND principletypecd != 0)
  SELECT INTO "nl:"
   FROM dcp_nomencategory n
   WHERE n.category_type_cd=categorytypecd
    AND n.source_vocabulary_cd=sourcevocabcd
    AND n.principle_type_cd=principletypecd
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo(build("Inserting -",categoryname))
   INSERT  FROM dcp_nomencategory n
    SET n.category_id = seq(carenet_seq,nextval), n.category_type_cd = categorytypecd, n.sequence = 3,
     n.category_name = categoryname, n.custom_category_ind = 0, n.source_vocabulary_cd =
     sourcevocabcd,
     n.principle_type_cd = principletypecd, n.default_ind = 0, n.updt_cnt = 0,
     n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 2321, n.updt_task = 0,
     n.updt_applctx = 0
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 SET categoryname = "SNOMED Findings"
 SET code_set = 18129
 SET cdf_meaning = "REACTIONS"
 EXECUTE cpm_get_cd_for_cdf
 SET categorytypecd = code_value
 SET code_set = 400
 SET cdf_meaning = "SNM2"
 EXECUTE cpm_get_cd_for_cdf
 SET sourcevocabcd = code_value
 SET code_set = 401
 SET cdf_meaning = "FINDING"
 EXECUTE cpm_get_cd_for_cdf
 SET principletypecd = code_value
 IF (categorytypecd != 0
  AND sourcevocabcd != 0
  AND principletypecd != 0)
  SELECT INTO "nl:"
   FROM dcp_nomencategory n
   WHERE n.category_type_cd=categorytypecd
    AND n.source_vocabulary_cd=sourcevocabcd
    AND n.principle_type_cd=principletypecd
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo(build("Inserting -",categoryname))
   INSERT  FROM dcp_nomencategory n
    SET n.category_id = seq(carenet_seq,nextval), n.category_type_cd = categorytypecd, n.sequence = 4,
     n.category_name = categoryname, n.custom_category_ind = 0, n.source_vocabulary_cd =
     sourcevocabcd,
     n.principle_type_cd = principletypecd, n.default_ind = 0, n.updt_cnt = 0,
     n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 2321, n.updt_task = 0,
     n.updt_applctx = 0
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
#exit_script
 COMMIT
END GO
