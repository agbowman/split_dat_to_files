CREATE PROGRAM cnt_imp_nomen
 CALL parser("dm2_set_context 'FIRE_REFCHG_TRG','NO' go")
 COMMIT
 SET curalias ar_struct request->term_obj_list[ar_a].term_obj
 DECLARE n_uid = vc WITH noconstant("")
 DECLARE nk_uid = vc WITH noconstant("")
 DECLARE ar_a = i4 WITH noconstant(0)
 DECLARE new_ar = i2 WITH noconstant(0)
 CALL parser("rdb alter table CNT_ALPHA_RESPONSE disable constraint XFK1CNT_ALPHA_RESPONSE go")
 CALL parser("rdb alter table CNT_DATA_MAP       disable constraint XFK1CNT_DATA_MAP       go")
 CALL parser("rdb alter table CNT_DTA            disable constraint XFK1CNT_DTA            go")
 CALL parser("rdb alter table CNT_DTA_RRF_R      disable constraint XFK1CNT_DTA_RRF_R      go")
 CALL parser("rdb alter table CNT_DTA_RRF_R      disable constraint XFK2CNT_DTA_RRF_R      go")
 CALL parser("rdb alter table CNT_INPUT          disable constraint XFK1CNT_INPUT          go")
 CALL parser("rdb alter table CNT_INPUT          disable constraint XFK2CNT_INPUT          go")
 CALL parser("rdb alter table CNT_INPUT_KEY      disable constraint XFK1CNT_INPUT_KEY      go")
 CALL parser("rdb alter table CNT_PF_SECTION_R   disable constraint XFK1CNT_PF_SECTION_R   go")
 CALL parser("rdb alter table CNT_PF_SECTION_R   disable constraint XFK2CNT_PF_SECTION_R   go")
 CALL parser("rdb alter table CNT_POWERFORM      disable constraint XFK1CNT_POWERFORM      go")
 CALL parser("rdb alter table CNT_REF_TEXT       disable constraint XFK1CNT_REF_TEXT       go")
 CALL parser("rdb alter table CNT_RRF            disable constraint XFK1CNT_RRF            go")
 CALL parser("rdb alter table CNT_RRF_AR_R       disable constraint XFK1CNT_RRF_AR_R       go")
 CALL parser("rdb alter table CNT_RRF_AR_R       disable constraint XFK2CNT_RRF_AR_R       go")
 CALL parser("rdb alter table CNT_SECTION        disable constraint XFK1CNT_SECTION        go")
 CALL parser("rdb alter table CNT_DTA_RRF_R      disable constraint XFK2CNT_DTA_RRF_R go")
 DECLARE log_txt = vc WITH noconstant("")
 DECLARE tmp_alpha_resp_key_id = f8 WITH noconstant(0.0)
 DECLARE new_schema_ind = i2 WITH noconstant(0)
 DECLARE rec_size = i4 WITH noconstant(0)
 DECLARE cv_loop = i4 WITH noconstant(0)
 DECLARE cark_source = vc WITH noconstant("")
 FREE RECORD requestin_nomen
 RECORD requestin_nomen(
   1 list_0[*]
     2 code_set = i4
     2 code_value = f8
     2 active_ind = i2
     2 display = vc
     2 description = vc
     2 definition = vc
     2 cdf_meaning = vc
     2 cki = vc
     2 concept_cki = vc
     2 code_value_uid = vc
     2 event_set_name = vc
 )
 RANGE OF c IS cnt_alpha_response
 SET new_schema_ind = validate(c.concept_identifier)
 FREE RANGE c
 SELECT INTO "nl:"
  FROM cnt_uid_alias a
  WHERE a.cnt_uid_alias_id > 0
  WITH check
 ;end select
 IF (curqual < 1)
  EXECUTE kia_sqlldr "cnt_uid_alias", "cnt_uid_alias.csv", 1
 ENDIF
 SET log_txt = ""
 SET log_txt = "Begin Nomenclature Load"
 CALL cnt_imp_nomen_log("kia_imp_ins_nomen_cm.log",log_txt,0)
 SET rec_size = size(request->term_obj_list,5)
 IF (rec_size >= 1)
  IF (validate(request->term_obj_list[1].term_obj.code_value_list)=1)
   SET stat = alterlist(requestin_nomen->list_0,size(request->term_obj_list[1].term_obj.
     code_value_list,5))
   FOR (cv_loop = 1 TO size(request->term_obj_list[1].term_obj.code_value_list,5))
     SET requestin_nomen->list_0[cv_loop].code_set = request->term_obj_list[1].term_obj.
     code_value_list[cv_loop].code_obj.code_set
     SET requestin_nomen->list_0[cv_loop].code_value = request->term_obj_list[1].term_obj.
     code_value_list[cv_loop].code_obj.code_value
     SET requestin_nomen->list_0[cv_loop].active_ind = request->term_obj_list[1].term_obj.
     code_value_list[cv_loop].code_obj.active_ind
     SET requestin_nomen->list_0[cv_loop].display = request->term_obj_list[1].term_obj.
     code_value_list[cv_loop].code_obj.display
     SET requestin_nomen->list_0[cv_loop].description = request->term_obj_list[1].term_obj.
     code_value_list[cv_loop].code_obj.description
     SET requestin_nomen->list_0[cv_loop].definition = request->term_obj_list[1].term_obj.
     code_value_list[cv_loop].code_obj.definition
     SET requestin_nomen->list_0[cv_loop].cdf_meaning = request->term_obj_list[1].term_obj.
     code_value_list[cv_loop].code_obj.cdf_meaning
     SET requestin_nomen->list_0[cv_loop].cki = request->term_obj_list[1].term_obj.code_value_list[
     cv_loop].code_obj.cki
     SET requestin_nomen->list_0[cv_loop].concept_cki = request->term_obj_list[1].term_obj.
     code_value_list[cv_loop].code_obj.concept_cki
     SET requestin_nomen->list_0[cv_loop].code_value_uid = request->term_obj_list[1].term_obj.
     code_value_list[cv_loop].code_obj.code_value_uid
     SET requestin_nomen->list_0[cv_loop].event_set_name = request->term_obj_list[1].term_obj.
     code_value_list[cv_loop].code_obj.event_set_name
   ENDFOR
   EXECUTE kia_imp_code_value_key  WITH replace("REQUESTIN",requestin_nomen)
   IF ((request->term_obj_list[1].term_obj.ar_guid="DUMMY"))
    GO TO end_of_script
   ENDIF
  ENDIF
 ENDIF
 FOR (ar_a = 1 TO size(request->term_obj_list,5))
   SET new_ar = true
   SET nk_uid = ""
   SET tmp_alpha_resp_key_id = 0.0
   IF ((ar_struct->ar_guid > " "))
    SET nk_uid = ar_struct->ar_guid
    SELECT INTO "nl:"
     FROM cnt_alpha_response_key c
     PLAN (c
      WHERE (c.ar_uid=ar_struct->ar_guid))
     DETAIL
      new_ar = false, tmp_alpha_resp_key_id = c.cnt_alpha_response_key_id
     WITH check
    ;end select
   ELSE
    SET nk_uid = build("TEMP!",ar_struct->source_string)
    SELECT INTO "nl:"
     FROM cnt_uid_alias c
     PLAN (c
      WHERE c.cnt_uid_alias=nk_uid
       AND c.cnt_uid_domain="CNT_ALPHA_RESPONSE_KEY")
     DETAIL
      nk_uid = c.cnt_uid
     WITH check
    ;end select
    SELECT INTO "nl:"
     FROM cnt_alpha_response_key c
     PLAN (c
      WHERE c.ar_uid=nk_uid)
     DETAIL
      new_ar = false, cark_source = c.source_string, tmp_alpha_resp_key_id = c
      .cnt_alpha_response_key_id
     WITH check
    ;end select
   ENDIF
   IF (new_ar=false
    AND (cark_source != ar_struct->source_string))
    DELETE  FROM cnt_alpha_response_key c
     WHERE (c.ar_uid=ar_struct->ar_guid)
     WITH check
    ;end delete
    COMMIT
   ENDIF
   IF (new_ar=true)
    SELECT INTO "nl:"
     tmp_id = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      tmp_alpha_resp_key_id = tmp_id
     WITH format, counter
    ;end select
   ENDIF
   INSERT  FROM cnt_alpha_response_key c
    SET c.ar_uid = nk_uid, c.cnt_alpha_response_key_id = tmp_alpha_resp_key_id, c.principle_type_cd
      = 0.0,
     c.principle_type_cduid =
     IF ((ar_struct->principle_type_cduid > " ")) trim(ar_struct->principle_type_cduid)
     ELSEIF (trim(ar_struct->principle_type_mean) > " ") concat("&MEAN&401&",trim(ar_struct->
        principle_type_mean))
     ELSE " "
     ENDIF
     , c.source_identifier = ar_struct->source_identifier, c.nomenclature_id = 0.0,
     c.source_string = ar_struct->source_string, c.source_vocabulary_cd = 0.0, c
     .source_vocabulary_cduid =
     IF ((ar_struct->source_vocabulary_cduid > " ")) trim(ar_struct->source_vocabulary_cduid)
     ELSEIF (trim(ar_struct->source_vocabulary_mean) > " ") concat("&MEAN&400&",trim(ar_struct->
        source_vocabulary_mean))
     ELSE " "
     ENDIF
     ,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0, c.updt_dt_tm = sysdate,
     c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task
    WITH check
   ;end insert
   IF (curqual=0)
    SET log_txt = ""
    SET log_txt = build("Failed to Insert to CNT_ALPHA_RESPONSE_KEY: ",nk_uid)
    CALL cnt_imp_nomen_log("kia_imp_ins_nomen_cm.log",log_txt,1)
    SET reply->status_data.status = "Z"
   ELSE
    SET log_txt = ""
    SET log_txt = build("Inserted Nomenclature: ",nk_uid)
    CALL cnt_imp_nomen_log("kia_imp_ins_nomen_cm.log",log_txt,1)
   ENDIF
   IF (new_ar=false)
    DELETE  FROM cnt_alpha_response c
     WHERE c.ar_uid=nk_uid
     WITH check
    ;end delete
   ENDIF
   IF (((curqual > 0) OR (new_ar=false)) )
    UPDATE  FROM cnt_rrf_ar_r c
     SET c.cnt_alpha_response_key_id = tmp_alpha_resp_key_id
     WHERE c.ar_uid=nk_uid
     WITH nocounter
    ;end update
    IF (new_schema_ind=1)
     INSERT  FROM cnt_alpha_response c
      SET c.active_ind = 1, c.ar_internal_uid = " ", c.ar_uid = nk_uid,
       c.beg_effective_dt_tm = cnvtdatetime(ar_struct->beg_effective_dt_tm), c.cmti = ar_struct->cmti,
       c.cnt_alpha_response_id = seq(reference_seq,nextval),
       c.cnt_alpha_response_key_id = tmp_alpha_resp_key_id, c.concept_cki = ar_struct->concept_cki, c
       .concept_identifier = ar_struct->concept_identifier,
       c.contributor_system_cd = 0.0, c.contributor_system_cduid =
       IF ((ar_struct->contributor_system_cduid > " ")) trim(ar_struct->contributor_system_cduid)
       ELSEIF (trim(ar_struct->contributor_system_mean) > " ") concat("&MEAN&89&",trim(ar_struct->
          contributor_system_mean))
       ELSE " "
       ENDIF
       , c.end_effective_dt_tm = cnvtdatetime(ar_struct->end_effective_dt_tm),
       c.mnemonic = ar_struct->mnemonic, c.primary_cterm_ind = ar_struct->primary_cterm, c
       .primary_vterm_ind = ar_struct->primary_vterm,
       c.short_string = ar_struct->short_string, c.string_identifier = ar_struct->string_identifier,
       c.vocab_axis_cd = 0.0,
       c.vocab_axis_cduid =
       IF (trim(ar_struct->vocab_axis_cduid) > " ") trim(ar_struct->vocab_axis_cduid)
       ELSEIF (trim(ar_struct->vocab_axis_mean) > " ") concat("&MEAN&15849&",trim(ar_struct->
          vocab_axis_mean))
       ELSE " "
       ENDIF
       , c.language_cd = 0.0, c.language_cduid =
       IF (trim(ar_struct->language_cduid) > " ") trim(ar_struct->language_cduid)
       ELSEIF (trim(ar_struct->language_mean) > " ") concat("&MEAN&36&",trim(ar_struct->language_mean
          ))
       ELSE " "
       ENDIF
       ,
       c.concept_source_cd = 0.0, c.concept_source_cduid =
       IF (trim(ar_struct->concept_source_cduid) > " ") trim(ar_struct->concept_source_cduid)
       ELSEIF (trim(ar_struct->concept_source_mean) > " ") concat("&MEAN&12100&",trim(ar_struct->
          concept_source_mean))
       ELSE " "
       ENDIF
       , c.data_status_cd = 0.0,
       c.data_status_cduid =
       IF (trim(ar_struct->data_status_cduid) > " ") trim(ar_struct->data_status_cduid)
       ELSEIF (trim(ar_struct->data_status_mean) > " ") concat("&MEAN&8&",trim(ar_struct->
          data_status_mean))
       ELSE " "
       ENDIF
       , c.string_source_cd = 0.0, c.string_source_cduid =
       IF (trim(ar_struct->string_source_cduid) > " ") trim(ar_struct->string_source_cduid)
       ELSEIF (trim(ar_struct->string_source_mean) > " ") concat("&MEAN&12100&",trim(ar_struct->
          string_source_mean))
       ELSE " "
       ENDIF
       ,
       c.string_status_cd = 0.0, c.string_status_cduid =
       IF (trim(ar_struct->string_status_cduid) > " ") trim(ar_struct->string_status_cduid)
       ELSEIF (trim(ar_struct->string_status_mean) > " ") concat("&MEAN&12103&",trim(ar_struct->
          string_status_mean))
       ELSE " "
       ENDIF
       , c.term_source_cd = 0.0,
       c.term_source_cduid =
       IF (trim(ar_struct->term_source_cduid) > " ") trim(ar_struct->term_source_cduid)
       ELSEIF (trim(ar_struct->term_source_mean) > " ") concat("&MEAN&12100&",trim(ar_struct->
          term_source_mean))
       ELSE " "
       ENDIF
       , c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0,
       c.updt_dt_tm = sysdate, c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task
      WITH check
     ;end insert
    ELSE
     INSERT  FROM cnt_alpha_response c
      SET c.active_ind = 1, c.ar_internal_uid = " ", c.ar_uid = nk_uid,
       c.beg_effective_dt_tm = cnvtdatetime(ar_struct->beg_effective_dt_tm), c.cmti = ar_struct->cmti,
       c.cnt_alpha_response_id = seq(reference_seq,nextval),
       c.cnt_alpha_response_key_id = tmp_alpha_resp_key_id, c.concept_cki = ar_struct->concept_cki, c
       .contributor_system_cd = 0.0,
       c.contributor_system_cduid =
       IF ((ar_struct->contributor_system_cduid > " ")) trim(ar_struct->contributor_system_cduid)
       ELSEIF (trim(ar_struct->contributor_system_mean) > " ") concat("&MEAN&89&",trim(ar_struct->
          contributor_system_mean))
       ELSE " "
       ENDIF
       , c.end_effective_dt_tm = cnvtdatetime(ar_struct->end_effective_dt_tm), c.mnemonic = ar_struct
       ->mnemonic,
       c.primary_cterm_ind = ar_struct->primary_cterm, c.primary_vterm_ind = ar_struct->primary_vterm,
       c.short_string = ar_struct->short_string,
       c.vocab_axis_cd = 0.0, c.vocab_axis_cduid =
       IF (trim(ar_struct->vocab_axis_cduid) > " ") trim(ar_struct->vocab_axis_cduid)
       ELSEIF (trim(ar_struct->vocab_axis_mean) > " ") concat("&MEAN&15849&",trim(ar_struct->
          vocab_axis_mean))
       ELSE " "
       ENDIF
       , c.updt_applctx = reqinfo->updt_applctx,
       c.updt_cnt = 0, c.updt_dt_tm = sysdate, c.updt_id = reqinfo->updt_id,
       c.updt_task = reqinfo->updt_task
      WITH check
     ;end insert
    ENDIF
    IF (curqual < 1)
     SET log_txt = ""
     SET log_txt = build("Failed to Insert to CNT_ALPHA_RESPONSE: ",nk_uid)
     CALL cnt_imp_nomen_log("kia_imp_ins_nomen_cm.log",log_txt,1)
     SET reply->status_data.status = "Z"
    ENDIF
   ENDIF
   COMMIT
 ENDFOR
 UPDATE  FROM cnt_alpha_response_key c
  SET c.source_vocabulary_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.source_vocabulary_cduid), c.source_vocabulary_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.source_vocabulary_cduid)
  WHERE c.source_vocabulary_cduid="&*"
   AND c.source_vocabulary_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.source_vocabulary_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_alpha_response_key c
  SET c.source_vocabulary_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.source_vocabulary_cduid)
  WHERE c.source_vocabulary_cd=0.0
   AND c.source_vocabulary_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.source_vocabulary_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_alpha_response_key c
  SET c.principle_type_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.principle_type_cduid), c.principle_type_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.principle_type_cduid)
  WHERE c.principle_type_cduid="&*"
   AND c.principle_type_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.principle_type_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_alpha_response_key c
  SET c.principle_type_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.principle_type_cduid)
  WHERE c.principle_type_cd=0.0
   AND c.principle_type_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.principle_type_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_alpha_response c
  SET c.vocab_axis_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.vocab_axis_cduid), c.vocab_axis_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.vocab_axis_cduid)
  WHERE c.vocab_axis_cduid="&*"
   AND c.vocab_axis_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.vocab_axis_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_alpha_response c
  SET c.vocab_axis_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.vocab_axis_cduid)
  WHERE c.vocab_axis_cd=0.0
   AND c.vocab_axis_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.vocab_axis_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_alpha_response c
  SET c.contributor_system_cduid =
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE cv.code_value_uid_alias=c.contributor_system_cduid), c.contributor_system_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid_alias=c.contributor_system_cduid)
  WHERE c.contributor_system_cduid="&*"
   AND c.contributor_system_cduid IN (
  (SELECT
   cv.code_value_uid_alias
   FROM cnt_code_value_key cv
   WHERE c.contributor_system_cduid=cv.code_value_uid_alias))
  WITH nocounter
 ;end update
 UPDATE  FROM cnt_alpha_response c
  SET c.contributor_system_cd =
   (SELECT
    cv2.code_value
    FROM cnt_code_value_key cv2
    WHERE cv2.code_value_uid=c.contributor_system_cduid)
  WHERE c.contributor_system_cd=0.0
   AND c.contributor_system_cduid IN (
  (SELECT
   cv.code_value_uid
   FROM cnt_code_value_key cv
   WHERE c.contributor_system_cduid=cv.code_value_uid
    AND cv.cnt_code_value_key_id != 0.00))
  WITH nocounter
 ;end update
 IF (new_schema_ind=1)
  UPDATE  FROM cnt_alpha_response c
   SET c.language_cduid =
    (SELECT
     cv.code_value_uid
     FROM cnt_code_value_key cv
     WHERE cv.code_value_uid_alias=c.language_cduid), c.language_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid_alias=c.language_cduid)
   WHERE c.language_cduid="&*"
    AND c.language_cduid IN (
   (SELECT
    cv.code_value_uid_alias
    FROM cnt_code_value_key cv
    WHERE c.language_cduid=cv.code_value_uid_alias))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_alpha_response c
   SET c.language_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid=c.language_cduid)
   WHERE c.language_cd=0.0
    AND c.language_cduid IN (
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE c.language_cduid=cv.code_value_uid
     AND cv.cnt_code_value_key_id != 0.00))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_alpha_response c
   SET c.concept_source_cduid =
    (SELECT
     cv.code_value_uid
     FROM cnt_code_value_key cv
     WHERE cv.code_value_uid_alias=c.concept_source_cduid), c.concept_source_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid_alias=c.concept_source_cduid)
   WHERE c.concept_source_cduid="&*"
    AND c.concept_source_cduid IN (
   (SELECT
    cv.code_value_uid_alias
    FROM cnt_code_value_key cv
    WHERE c.concept_source_cduid=cv.code_value_uid_alias))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_alpha_response c
   SET c.concept_source_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid=c.concept_source_cduid)
   WHERE c.concept_source_cd=0.0
    AND c.concept_source_cduid IN (
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE c.concept_source_cduid=cv.code_value_uid
     AND cv.cnt_code_value_key_id != 0.00))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_alpha_response c
   SET c.data_status_cduid =
    (SELECT
     cv.code_value_uid
     FROM cnt_code_value_key cv
     WHERE cv.code_value_uid_alias=c.data_status_cduid), c.data_status_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid_alias=c.data_status_cduid)
   WHERE c.data_status_cduid="&*"
    AND c.data_status_cduid IN (
   (SELECT
    cv.code_value_uid_alias
    FROM cnt_code_value_key cv
    WHERE c.data_status_cduid=cv.code_value_uid_alias))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_alpha_response c
   SET c.data_status_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid=c.data_status_cduid)
   WHERE c.data_status_cd=0.0
    AND c.data_status_cduid IN (
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE c.data_status_cduid=cv.code_value_uid
     AND cv.cnt_code_value_key_id != 0.00))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_alpha_response c
   SET c.string_source_cduid =
    (SELECT
     cv.code_value_uid
     FROM cnt_code_value_key cv
     WHERE cv.code_value_uid_alias=c.string_source_cduid), c.string_source_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid_alias=c.string_source_cduid)
   WHERE c.string_source_cduid="&*"
    AND c.string_source_cduid IN (
   (SELECT
    cv.code_value_uid_alias
    FROM cnt_code_value_key cv
    WHERE c.string_source_cduid=cv.code_value_uid_alias))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_alpha_response c
   SET c.string_source_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid=c.string_source_cduid)
   WHERE c.string_source_cd=0.0
    AND c.string_source_cduid IN (
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE c.string_source_cduid=cv.code_value_uid
     AND cv.cnt_code_value_key_id != 0.00))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_alpha_response c
   SET c.string_status_cduid =
    (SELECT
     cv.code_value_uid
     FROM cnt_code_value_key cv
     WHERE cv.code_value_uid_alias=c.string_status_cduid), c.string_status_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid_alias=c.string_status_cduid)
   WHERE c.string_status_cduid="&*"
    AND c.string_status_cduid IN (
   (SELECT
    cv.code_value_uid_alias
    FROM cnt_code_value_key cv
    WHERE c.string_status_cduid=cv.code_value_uid_alias))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_alpha_response c
   SET c.string_status_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid=c.string_status_cduid)
   WHERE c.string_status_cd=0.0
    AND c.string_status_cduid IN (
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE c.string_status_cduid=cv.code_value_uid
     AND cv.cnt_code_value_key_id != 0.00))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_alpha_response c
   SET c.term_source_cduid =
    (SELECT
     cv.code_value_uid
     FROM cnt_code_value_key cv
     WHERE cv.code_value_uid_alias=c.term_source_cduid), c.term_source_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid_alias=c.term_source_cduid)
   WHERE c.term_source_cduid="&*"
    AND c.term_source_cduid IN (
   (SELECT
    cv.code_value_uid_alias
    FROM cnt_code_value_key cv
    WHERE c.term_source_cduid=cv.code_value_uid_alias))
   WITH nocounter
  ;end update
  UPDATE  FROM cnt_alpha_response c
   SET c.term_source_cd =
    (SELECT
     cv2.code_value
     FROM cnt_code_value_key cv2
     WHERE cv2.code_value_uid=c.term_source_cduid)
   WHERE c.term_source_cd=0.0
    AND c.term_source_cduid IN (
   (SELECT
    cv.code_value_uid
    FROM cnt_code_value_key cv
    WHERE c.term_source_cduid=cv.code_value_uid
     AND cv.cnt_code_value_key_id != 0.00))
   WITH nocounter
  ;end update
 ENDIF
 SUBROUTINE (cnt_imp_nomen_log(lf_name=vc,txt=vc,app_ind=i2) =i2)
   IF (app_ind=true)
    SELECT INTO value(lf_name)
     FROM dual
     DETAIL
      col 0, txt, row + 1
     WITH append
    ;end select
   ELSE
    SELECT INTO value(lf_name)
     FROM dual
     DETAIL
      col 0, txt, row + 1
     WITH check
    ;end select
   ENDIF
 END ;Subroutine
#end_of_script
 COMMIT
 SET log_txt = ""
 SET log_txt = "End Nomenclature Load"
 CALL cnt_imp_nomen_log("kia_imp_ins_nomen_cm.log",log_txt,1)
 CALL parser("dm2_set_context 'FIRE_REFCHG_TRG','YES' go")
END GO
