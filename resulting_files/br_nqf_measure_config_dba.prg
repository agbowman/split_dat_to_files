CREATE PROGRAM br_nqf_measure_config:dba
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
 DECLARE drr_table_and_ccldef_exists(null) = i2
 IF (validate(drr_validate_table->table_name,"X")="X"
  AND validate(drr_validate_table->table_name,"Z")="Z")
  FREE RECORD drr_validate_table
  RECORD drr_validate_table(
    1 msg_returned = vc
    1 list[*]
      2 table_name = vc
      2 status = i2
  )
 ENDIF
 SUBROUTINE drr_table_and_ccldef_exists(null)
   DECLARE dtc_table_num = i4 WITH protect, noconstant(0)
   DECLARE dtc_table_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_ccldef_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_no_ccldef = vc WITH protect, noconstant("")
   DECLARE dtc_no_table = vc WITH protect, noconstant("")
   DECLARE dtc_errmsg = vc WITH protect, noconstant("")
   SET dtc_table_num = size(drr_validate_table->list,5)
   IF (dtc_table_num=0)
    SET drr_validate_table->msg_returned = concat(
     "No table specified in DRR_VALIDATE_TABLE record structure.")
    RETURN(- (1))
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables ut,
     (dummyt d  WITH seq = value(dtc_table_num))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (ut
     WHERE ut.table_name=trim(cnvtupper(drr_validate_table->list[d.seq].table_name)))
    DETAIL
     dtc_table_cnt = (dtc_table_cnt+ 1), drr_validate_table->list[d.seq].status = 1
    WITH nocounter
   ;end select
   IF (error(dtc_errmsg,0) != 0)
    SET drr_validate_table->msg_returned = concat("Select for table existence failed: ",dtc_errmsg)
    RETURN(- (1))
   ELSEIF (dtc_table_cnt=0)
    SET drr_validate_table->msg_returned = concat("No DRR tables found")
    RETURN(0)
   ENDIF
   IF (dtc_table_cnt < dtc_table_num)
    FOR (i = 1 TO dtc_table_num)
      IF ((drr_validate_table->list[i].status=0))
       SET dtc_no_table = concat(dtc_no_table," ",drr_validate_table->list[i].table_name)
      ENDIF
    ENDFOR
    SET drr_validate_table->msg_returned = concat("Missing table",dtc_no_table)
    RETURN(dtc_table_cnt)
   ENDIF
   FOR (i = 1 TO dtc_table_num)
     IF (checkdic(cnvtupper(drr_validate_table->list[i].table_name),"T",0) != 2)
      SET dtc_no_ccldef = concat(dtc_no_ccldef," ",drr_validate_table->list[i].table_name)
      SET drr_validate_table->list[i].status = 0
     ELSE
      SET dtc_ccldef_cnt = (dtc_ccldef_cnt+ 1)
     ENDIF
   ENDFOR
   IF (dtc_ccldef_cnt < dtc_table_num)
    SET drr_validate_table->msg_returned = concat("CCL definition missing for ",dtc_no_ccldef)
    RETURN(dtc_ccldef_cnt)
   ENDIF
   RETURN(dtc_table_cnt)
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_nqf_measure_config.prg> script"
 DECLARE req_cnt = i4 WITH protect, constant(size(requestin->list_0,5))
 DECLARE cs48_active_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cs8_auth_cd = f8 WITH protect, noconstant(0.0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE source_code_value = f8 WITH protect, noconstant(0.0)
 DECLARE source_pca_id = f8 WITH protect, noconstant(0.0)
 DECLARE nqf_id = f8 WITH protect, noconstant(0.0)
 DECLARE nqf_code_value = f8 WITH protect, noconstant(0.0)
 DECLARE item_exists_flag = i2 WITH protect, noconstant(0)
 DECLARE cleanupnqf64measures(dummyvar=i2) = null
 DECLARE checkforerrors(errormessage=vc) = null
 IF (req_cnt > 0)
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=48
     AND cv.cdf_meaning="ACTIVE"
     AND cv.active_ind=1)
   DETAIL
    cs48_active_cd = cv.code_value
   WITH nocounter
  ;end select
  CALL checkforerrors("Error 001 - Failed to select ACTIVE row from code set 48: ")
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=8
     AND cv.cdf_meaning="AUTH"
     AND cv.active_ind=1)
   DETAIL
    cs8_auth_cd = cv.code_value
   WITH nocounter
  ;end select
  CALL checkforerrors("Error 002 - Failed to select AUTH row from code set 8: ")
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=4002170
     AND cv.cdf_meaning="SOURCE"
     AND cv.display_key="PROMOTINGINTEROPERABILITY")
   DETAIL
    IF (cv.active_ind=0)
     item_exists_flag = 1
    ELSE
     item_exists_flag = 2
    ENDIF
    source_code_value = cv.code_value
   WITH nocounter
  ;end select
  CALL checkforerrors("Error 003 - Failed to select SOURCE row from code set 4002170: ")
  IF (item_exists_flag=0)
   SELECT INTO "nl:"
    z = seq(reference_seq,nextval)
    FROM dual d
    DETAIL
     source_code_value = z
    WITH nocounter
   ;end select
   CALL checkforerrors("Error 004 - Failed to retrieve new id: ")
   INSERT  FROM code_value cv
    SET cv.code_value = source_code_value, cv.code_set = 4002170, cv.cdf_meaning = "SOURCE",
     cv.display = "Promoting Interoperability", cv.display_key = "PROMOTINGINTEROPERABILITY", cv
     .description = "Promoting Interoperability",
     cv.definition = "Promoting Interoperability", cv.active_type_cd = cs48_active_cd, cv.active_ind
      = 1,
     cv.updt_cnt = 0, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
     cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = 15301, cv.data_status_cd = cs8_auth_cd,
     cv.cki = "CKI.CODEVALUE!4200099278"
    WITH nocounter
   ;end insert
   CALL checkforerrors("Error 005 - Failed to insert row into code_value: ")
  ELSEIF (item_exists_flag=1)
   UPDATE  FROM code_value cv
    SET cv.active_ind = 1, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     cv.updt_id = reqinfo->updt_id, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = 15301
    WHERE cv.code_value=source_code_value
    WITH nocounter
   ;end update
   CALL checkforerrors("Error 006 - Failed to update row into code_value: ")
  ENDIF
  SET item_exists_flag = 0
  SELECT INTO "nl:"
   FROM pca_source p
   PLAN (p
    WHERE ((p.source_cd=source_code_value) OR (p.display_txt="Promoting Interoperability")) )
   DETAIL
    item_exists_flag = 2, source_pca_id = p.pca_source_id
   WITH nocounter
  ;end select
  CALL checkforerrors("Error 007 - Failed to select row from pca_source: ")
  IF (item_exists_flag=0)
   SELECT INTO "nl:"
    z = seq(pca_seq,nextval)
    FROM dual d
    DETAIL
     source_pca_id = z
    WITH nocounter
   ;end select
   CALL checkforerrors("Error 008 - Failed to retrieve new id: ")
   INSERT  FROM pca_source p
    SET p.pca_source_id = source_pca_id, p.display_txt = "Promoting Interoperability", p.source_cd =
     source_code_value,
     p.defined_by_flag = 1, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = 15301
    WITH nocounter
   ;end insert
   CALL checkforerrors("Error 009 - Failed to insert row into pca_source: ")
  ENDIF
  FOR (x = 1 TO req_cnt)
    SET item_exists_flag = 0
    SET nqf_id = 0.0
    SET nqf_code_value = 0.0
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE (cv.cki=requestin->list_0[x].cki))
     DETAIL
      IF (cv.active_ind=1)
       item_exists_flag = 2
      ELSE
       item_exists_flag = 1
      ENDIF
      nqf_code_value = cv.code_value
     WITH nocounter
    ;end select
    CALL checkforerrors("Error 010 - Failed to select row from code_value: ")
    IF (item_exists_flag=0)
     SELECT INTO "nl:"
      z = seq(reference_seq,nextval)
      FROM dual d
      DETAIL
       nqf_code_value = z
      WITH nocounter
     ;end select
     CALL checkforerrors("Error 011 - Failed to retrieve new id: ")
     INSERT  FROM code_value cv
      SET cv.code_value = nqf_code_value, cv.code_set = 4002170, cv.cdf_meaning = "MEASURE",
       cv.display = requestin->list_0[x].measure_display, cv.display_key = trim(cnvtupper(
         cnvtalphanum(requestin->list_0[x].measure_display))), cv.description = requestin->list_0[x].
       measure_description,
       cv.definition = requestin->list_0[x].measure_display, cv.active_type_cd = cs48_active_cd, cv
       .active_ind = 1,
       cv.updt_cnt = 0, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id,
       cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = 15301, cv.data_status_cd = cs8_auth_cd,
       cv.cki = requestin->list_0[x].cki
      WITH nocounter
     ;end insert
     CALL checkforerrors("Error 012 - Failed to insert row into code_value: ")
    ELSEIF (item_exists_flag=1)
     UPDATE  FROM code_value cv
      SET cv.active_ind = 1, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       cv.updt_id = reqinfo->updt_id, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = 15301
      WHERE cv.code_value=source_code_value
      WITH nocounter
     ;end update
     CALL checkforerrors("Error 013 - Failed to update row into code_value: ")
    ENDIF
    SET item_exists_flag = 0
    SELECT INTO "nl:"
     FROM pca_quality_measure pqm
     PLAN (pqm
      WHERE pqm.measure_cd=nqf_code_value)
     DETAIL
      item_exists_flag = 2, nqf_id = pqm.pca_quality_measure_id
     WITH nocounter
    ;end select
    CALL checkforerrors("Error 014 - Failed to select row from pca_quality_measure: ")
    IF (item_exists_flag=0)
     SELECT INTO "nl:"
      z = seq(pca_seq,nextval)
      FROM dual d
      DETAIL
       nqf_id = z
      WITH nocounter
     ;end select
     CALL checkforerrors("Error 015 - Failed to retrieve new id: ")
     INSERT  FROM pca_quality_measure pqm
      SET pqm.pca_quality_measure_id = nqf_id, pqm.pca_source_id = source_pca_id, pqm.display_txt =
       requestin->list_0[x].measure_display,
       pqm.description_txt = requestin->list_0[x].measure_description, pqm.measure_cd =
       nqf_code_value, pqm.updt_cnt = 0,
       pqm.updt_dt_tm = cnvtdatetime(curdate,curtime3), pqm.updt_id = reqinfo->updt_id, pqm
       .updt_applctx = reqinfo->updt_applctx,
       pqm.updt_task = 15301
      WITH nocounter
     ;end insert
     CALL checkforerrors("Error 016 - Failed to insert row into pca_quality_measure: ")
    ENDIF
  ENDFOR
  CALL cleanupnqf64measures(0)
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_nqf_measure_config.prg> script"
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to find any rows in the br_nqf_measures.csv file"
 ENDIF
 SUBROUTINE cleanupnqf64measures(dummvar)
   FREE RECORD providers
   RECORD providers(
     1 provider[*]
       2 eligible_provider_id = f8
   ) WITH protect
   DECLARE measure_display = vc WITH protect, constant("NQF 0064")
   DECLARE measure_description = vc WITH protect, constant(
    "NQF 0064 - Diabetes: LDL Management and Control")
   DECLARE measure_cki = vc WITH protect, constant("CKI.CODEVALUE!4200101291")
   DECLARE measure_cd = f8 WITH protect, noconstant(0.0)
   DECLARE measure_id = f8 WITH protect, noconstant(0.0)
   DECLARE nqf_64_1_measure_cd = f8 WITH protect, noconstant(0.0)
   DECLARE nqf_64_1_measure_id = f8 WITH protect, noconstant(0.0)
   DECLARE nqf_64_2_measure_cd = f8 WITH protect, noconstant(0.0)
   DECLARE nqf_64_2_measure_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=4002170
      AND cv.cdf_meaning="MEASURE"
      AND cv.display="NQF 0064.1"
      AND cv.cki="CKI.CODEVALUE!4200146742")
    DETAIL
     nqf_64_1_measure_cd = cv.code_value
    WITH nocounter
   ;end select
   CALL checkforerrors("Error 017 - Could not find NQF 64.1 code: ")
   SELECT INTO "nl:"
    FROM pca_quality_measure pqm
    PLAN (pqm
     WHERE pqm.display_txt="NQF 0064.1"
      AND pqm.description_txt="NQF 0064.1 - Diabetes: LDL Management and Control"
      AND pqm.measure_cd=nqf_64_1_measure_cd)
    DETAIL
     nqf_64_1_measure_id = pqm.pca_quality_measure_id
    WITH nocounter
   ;end select
   CALL checkforerrors("Error 018 - Could not find NQF 64.1 measure: ")
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=4002170
      AND cv.cdf_meaning="MEASURE"
      AND cv.display="NQF 0064.2"
      AND cv.cki="CKI.CODEVALUE!4200146743")
    DETAIL
     nqf_64_2_measure_cd = cv.code_value
    WITH nocounter
   ;end select
   CALL checkforerrors("Error 019 - Could not find NQF 64.2 code: ")
   SELECT INTO "nl:"
    FROM pca_quality_measure pqm
    PLAN (pqm
     WHERE pqm.display_txt="NQF 0064.2"
      AND pqm.description_txt="NQF 0064.2 - Diabetes: LDL Management and Control"
      AND pqm.measure_cd=nqf_64_2_measure_cd)
    DETAIL
     nqf_64_2_measure_id = pqm.pca_quality_measure_id
    WITH nocounter
   ;end select
   CALL checkforerrors("Error 020 - Could not find NQF 64.2 measure: ")
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=4002170
      AND cv.cdf_meaning="MEASURE"
      AND cv.display=measure_display
      AND cv.cki=measure_cki)
    DETAIL
     measure_cd = cv.code_value
    WITH nocounter
   ;end select
   CALL checkforerrors("Error 021 - Could not find NQF 64 code: ")
   IF (measure_cd > 0)
    SELECT INTO "nl:"
     FROM pca_quality_measure pqm
     PLAN (pqm
      WHERE pqm.display_txt=measure_display
       AND pqm.description_txt=measure_description
       AND pqm.measure_cd=measure_cd)
     DETAIL
      measure_id = pqm.pca_quality_measure_id
     WITH nocounter
    ;end select
    CALL checkforerrors("Error 022 - Could not find NQF 64 measure: ")
    DECLARE provider_cnt = i4 WITH protect, noconstant(0)
    IF (measure_id > 0)
     SELECT INTO "nl:"
      FROM br_elig_prov_meas_reltn epr
      PLAN (epr
       WHERE epr.pca_quality_measure_id=measure_id)
      DETAIL
       provider_cnt = (provider_cnt+ 1), stat = alterlist(providers->provider,provider_cnt),
       providers->provider[provider_cnt].eligible_provider_id = epr.br_eligible_provider_id
      WITH nocounter
     ;end select
     CALL checkforerrors("Error 023 - Could not find Providers that need updates: ")
     UPDATE  FROM code_value cv
      SET cv.active_ind = 0, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,
        curtime3),
       cv.updt_id = reqinfo->updt_id, cv.updt_applctx = reqinfo->updt_applctx, cv.updt_task = 15301
      WHERE cv.code_set=4002170
       AND cv.cdf_meaning="MEASURE"
       AND cv.display=measure_display
       AND cv.cki=measure_cki
      WITH nocounter
     ;end update
     CALL checkforerrors("Error 024 - Could not inactivate measure code: ")
     IF (provider_cnt > 0)
      DELETE  FROM (dummyt d  WITH seq = provider_cnt),
        br_elig_prov_meas_reltn epr
       SET epr.seq = 1
       PLAN (d)
        JOIN (epr
        WHERE (epr.br_eligible_provider_id=providers->provider[d.seq].eligible_provider_id)
         AND epr.pca_quality_measure_id=measure_id)
       WITH nocounter
      ;end delete
      CALL checkforerrors("Error 025 - Could not delete relationships: ")
      FOR (x = 1 TO provider_cnt)
        SET new_id = 0.0
        SELECT INTO "nl:"
         z = seq(bedrock_seq,nextval)
         FROM dual
         DETAIL
          new_id = cnvtreal(z)
         WITH nocounter
        ;end select
        INSERT  FROM br_elig_prov_meas_reltn epr
         SET epr.br_elig_prov_meas_reltn_id = new_id, epr.br_eligible_provider_id = providers->
          provider[x].eligible_provider_id, epr.pca_quality_measure_id = nqf_64_1_measure_id,
          epr.measure_seq = 0, epr.updt_cnt = 0, epr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          epr.updt_id = reqinfo->updt_id, epr.updt_applctx = reqinfo->updt_applctx, epr.updt_task =
          15301,
          epr.active_ind = 1, epr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), epr
          .end_effective_dt_tm = cnvtdatetime("31-DEC-2014 00:00:00"),
          epr.orig_br_elig_prov_meas_r_id = new_id
         WITH nocounter
        ;end insert
        CALL checkforerrors("Error 026 - Could not create nqf 64.1 relationships: ")
        SET new_id = 0.0
        SELECT INTO "nl:"
         z = seq(bedrock_seq,nextval)
         FROM dual
         DETAIL
          new_id = cnvtreal(z)
         WITH nocounter
        ;end select
        INSERT  FROM br_elig_prov_meas_reltn epr
         SET epr.br_elig_prov_meas_reltn_id = new_id, epr.br_eligible_provider_id = providers->
          provider[x].eligible_provider_id, epr.pca_quality_measure_id = nqf_64_2_measure_id,
          epr.measure_seq = 0, epr.updt_cnt = 0, epr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          epr.updt_id = reqinfo->updt_id, epr.updt_applctx = reqinfo->updt_applctx, epr.updt_task =
          15301,
          epr.active_ind = 1, epr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), epr
          .end_effective_dt_tm = cnvtdatetime("31-DEC-2014 00:00:00"),
          epr.orig_br_elig_prov_meas_r_id = new_id
         WITH nocounter
        ;end insert
        CALL checkforerrors("Error 027 - Could not create nqf 64.2 relationships: ")
      ENDFOR
     ENDIF
     DELETE  FROM pca_encntr_measure_outcome pemo
      PLAN (pemo
       WHERE pemo.pca_quality_measure_id=measure_id)
      WITH nocounter
     ;end delete
     CALL checkforerrors("Error 028 - Could not delete from pca_encntr_measure_outcome: ")
     DELETE  FROM pca_measure_outcome_reltn pmor
      PLAN (pmor
       WHERE pmor.pca_quality_measure_id=measure_id)
      WITH nocounter
     ;end delete
     CALL checkforerrors("Error 029 - Could not delete from pca_measure_outcome_reltn: ")
     DELETE  FROM pca_person_measure_outcome ppmo
      PLAN (ppmo
       WHERE ppmo.pca_quality_measure_id=measure_id)
      WITH nocounter
     ;end delete
     CALL checkforerrors("Error 030 - Could not delete from pca_person_measure_outcome: ")
     DECLARE topic_measure_reltn_id = f8 WITH protect, noconstant(0.0)
     SELECT INTO "nl:"
      FROM pca_topic_measure_reltn ptmr
      PLAN (ptmr
       WHERE ptmr.pca_quality_measure_id=measure_id)
      DETAIL
       topic_measure_reltn_id = ptmr.pca_topic_measure_reltn_id
      WITH nocounter
     ;end select
     CALL checkforerrors("Error 031 - Could not retrieve measure id: ")
     IF (topic_measure_reltn_id > 0)
      DELETE  FROM pca_topic_measure_target ptmt
       PLAN (ptmt
        WHERE ptmt.pca_topic_measure_reltn_id=topic_measure_reltn_id)
       WITH nocounter
      ;end delete
      CALL checkforerrors("Error 032 - Could not delete from pca_topic_measure_target: ")
     ENDIF
     DELETE  FROM pca_topic_measure_reltn ptmr
      PLAN (ptmr
       WHERE ptmr.pca_quality_measure_id=measure_id)
      WITH nocounter
     ;end delete
     CALL checkforerrors("Error 033 - Could not delete from pca_topic_measure_reltn: ")
     DELETE  FROM pca_quality_measure pqm
      PLAN (pqm
       WHERE pqm.measure_cd=measure_cd
        AND pqm.display_txt=measure_display
        AND pqm.description_txt=measure_description)
      WITH nocounter
     ;end delete
     CALL checkforerrors("Error 034 - Could not delete NQF 64 measure: ")
     SET stat = alterlist(drr_validate_table->list,2)
     SET drr_validate_table->list[1].table_name = "PCA_ENCNTR_MEASURE3193DRR"
     SET drr_validate_table->list[2].table_name = "PCA_PERSON_MEASURE2536DRR"
     SET drr_shadow_cnt = drr_table_and_ccldef_exists()
     IF (drr_shadow_cnt=2)
      DELETE  FROM pca_encntr_measure3193drr pmor_shadow
       PLAN (pmor_shadow
        WHERE pmor_shadow.pca_quality_measure_id=measure_id)
       WITH nocounter
      ;end delete
      CALL checkforerrors("Error 030_shadow - Could not delete from pca_encntr_measure3193drr: ")
      DELETE  FROM pca_person_measure2536drr pemo_shadow
       PLAN (pemo_shadow
        WHERE pemo_shadow.pca_quality_measure_id=measure_id)
       WITH nocounter
      ;end delete
      CALL checkforerrors("Error 028_shadow - Could not delete from pca_person_measure2536drr: ")
     ELSEIF ( NOT (drr_shadow_cnt IN (0, 2)))
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed shadow table check: ",drr_validate_table->
       msg_returned)
      GO TO exit_script
     ELSEIF (drr_shadow_cnt=0)
      CALL echo("Shadow tables pca_encntr_measure3193drr and pca_person_measure2536drr do not exist")
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE checkforerrors(errormessage)
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat(errormessage,errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
END GO
