CREATE PROGRAM cnt_upd_cvuid_alias:dba
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&DISPLAY&106&",trim(c.display))
  WHERE c.code_set=106
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&DISPLAY&72&",trim(c.display))
  WHERE c.code_set=72
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&DISPLAY&&221",trim(c.display))
  WHERE c.code_set=221
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&DISPLAY&226&",trim(c.display))
  WHERE c.code_set=226
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&DISPLAY&2052&",trim(c.display))
  WHERE c.code_set=2052
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&DISPLAY&54&",trim(c.display))
  WHERE c.code_set=54
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&DISPLAY&71&",trim(c.display))
  WHERE c.code_set=71
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&DISPLAY&1902&",trim(c.display))
  WHERE c.code_set=1902
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&DISPLAY&14003&",trim(c.display))
  WHERE c.code_set=14003
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&MEAN&401&",trim(c.cdf_meaning))
  WHERE c.code_set=401
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&MEAN&400&",trim(c.cdf_meaning))
  WHERE c.code_set=400
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&MEAN&89&",trim(c.cdf_meaning))
  WHERE c.code_set=89
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&MEAN&15849&",trim(c.cdf_meaning))
  WHERE c.code_set=15849
  WITH check
 ;end update
 UPDATE  FROM cnt_code_value_key c
  SET c.code_value_uid_alias = concat("&MEAN&6009&",trim(c.cdf_meaning))
  WHERE c.code_set=6009
  WITH check
 ;end update
 FREE RECORD d_key
 RECORD d_key(
   1 lst[*]
     2 uid = vc
     2 disp_key = vc
 )
 DECLARE dkey_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM cnt_code_value_key c
  PLAN (c
   WHERE c.code_set IN (1636, 289, 340, 57, 16529)
    AND c.code_value_uid_alias = null)
  DETAIL
   dkey_cnt = (dkey_cnt+ 1), stat = alterlist(d_key->lst,dkey_cnt), d_key->lst[dkey_cnt].uid = c
   .code_value_uid
   CASE (c.code_set)
    OF 1636:
     d_key->lst[dkey_cnt].disp_key = concat("&DISPLAY_KEY&1636&",cnvtupper(cnvtalphanum(c.display)))
    OF 289:
     d_key->lst[dkey_cnt].disp_key = concat("&DISPLAY_KEY&289&",cnvtupper(cnvtalphanum(c.display)))
    OF 340:
     d_key->lst[dkey_cnt].disp_key = concat("&DISPLAY_KEY&340&",cnvtupper(cnvtalphanum(c.display)))
    OF 57:
     d_key->lst[dkey_cnt].disp_key = concat("&DISPLAY_KEY&57&",cnvtupper(cnvtalphanum(c.display)))
    OF 16529:
     d_key->lst[dkey_cnt].disp_key = concat("&DISPLAY_KEY&16529&",cnvtupper(cnvtalphanum(c.display)))
   ENDCASE
  WITH check
 ;end select
 CALL echorecord(d_key)
 IF (size(d_key->lst,5) > 0)
  UPDATE  FROM cnt_code_value_key c,
    (dummyt d  WITH seq = size(d_key->lst,5))
   SET c.code_value_uid_alias = d_key->lst[d.seq].disp_key
   PLAN (d)
    JOIN (c
    WHERE (c.code_value_uid=d_key->lst[d.seq].uid))
   WITH check
  ;end update
 ENDIF
 DECLARE cnt_upd_cds(up_flag=i2) = i2
 SUBROUTINE cnt_upd_cds(up_flag)
   IF (up_flag IN (0, 2))
    UPDATE  FROM cnt_dta c
     SET c.activity_type_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.activity_type_cduid), c.activity_type_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.activity_type_cduid)
     WHERE c.activity_type_cduid="&*"
      AND c.activity_type_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.activity_type_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_dta c
     SET c.default_result_type_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.default_result_type_cduid), c.default_result_type_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.default_result_type_cduid)
     WHERE c.default_result_type_cduid="&*"
      AND c.default_result_type_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.default_result_type_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_dta c
     SET c.event_code_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.event_code_cduid), c.event_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.event_code_cduid)
     WHERE c.event_code_cduid="&*"
      AND c.event_code_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.event_code_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_data_map c
     SET c.service_resource_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.service_resource_cduid), c.service_resource_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.service_resource_cduid)
     WHERE c.service_resource_cduid="&*"
      AND c.service_resource_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.service_resource_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_rrf_ar_r c
     SET c.result_process_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.result_process_cduid), c.result_process_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.result_process_cduid)
     WHERE c.result_process_cduid="&*"
      AND c.result_process_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.result_process_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_rrf c
     SET c.encntr_type_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.encntr_type_cduid), c.encntr_type_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.encntr_type_cduid)
     WHERE c.encntr_type_cduid="&*"
      AND c.encntr_type_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.encntr_type_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_rrf c
     SET c.units_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.units_cduid), c.units_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.units_cduid)
     WHERE c.units_cduid="&*"
      AND c.units_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.units_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_rrf_key c
     SET c.age_from_units_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.age_from_units_cduid), c.age_from_units_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.age_from_units_cduid)
     WHERE c.age_from_units_cduid="&*"
      AND c.age_from_units_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.age_from_units_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_rrf_key c
     SET c.age_to_units_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.age_to_units_cduid), c.age_to_units_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.age_to_units_cduid)
     WHERE c.age_to_units_cduid="&*"
      AND c.age_to_units_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.age_to_units_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_rrf_key c
     SET c.service_resource_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.service_resource_cduid), c.service_resource_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.service_resource_cduid)
     WHERE c.service_resource_cduid="&*"
      AND c.service_resource_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.service_resource_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_rrf_key c
     SET c.sex_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.sex_cduid), c.sex_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.sex_cduid)
     WHERE c.sex_cduid="&*"
      AND c.sex_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.sex_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_rrf_key c
     SET c.species_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.species_cduid), c.species_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.species_cduid)
     WHERE c.species_cduid="&*"
      AND c.species_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.species_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_rrf_key c
     SET c.specimen_type_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.specimen_type_cduid), c.specimen_type_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.specimen_type_cduid)
     WHERE c.specimen_type_cduid="&*"
      AND c.specimen_type_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.specimen_type_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_dta c
     SET c.bb_result_type_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.bb_result_type_cduid), c.bb_result_type_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.bb_result_type_cduid)
     WHERE c.bb_result_type_cduid="&*"
      AND c.bb_result_type_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.bb_result_type_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
   ENDIF
   IF (up_flag IN (0, 1))
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
   ENDIF
   IF (up_flag IN (0, 3))
    UPDATE  FROM cnt_powerform c
     SET c.form_event_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.form_event_cduid), c.form_event_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.form_event_cduid)
     WHERE c.form_event_cduid="&*"
      AND c.form_event_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.form_event_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_input c
     SET c.event_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.event_cduid), c.event_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.event_cduid)
     WHERE c.event_cduid="&*"
      AND c.event_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.event_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
    UPDATE  FROM cnt_grid c
     SET c.int_event_cduid =
      (SELECT
       cv.code_value_uid
       FROM cnt_code_value_key cv
       WHERE cv.code_value_uid_alias=c.int_event_cduid), c.int_event_cd =
      (SELECT
       cv2.code_value
       FROM cnt_code_value_key cv2
       WHERE cv2.code_value_uid_alias=c.int_event_cduid)
     WHERE c.int_event_cduid="&*"
      AND c.int_event_cduid IN (
     (SELECT
      cv.code_value_uid_alias
      FROM cnt_code_value_key cv
      WHERE c.int_event_cduid=cv.code_value_uid_alias))
     WITH nocounter
    ;end update
   ENDIF
   COMMIT
 END ;Subroutine
 CALL cnt_upd_cds(0)
END GO
