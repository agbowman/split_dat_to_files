CREATE PROGRAM ce_merge_event_sets:dba
 DECLARE insrt_and_upd = f8 WITH constant(1.0)
 DECLARE del = f8 WITH constant(2.0)
 DECLARE event_set_codeset = i4 WITH constant(93)
 DECLARE dcc_exist_ind = i2 WITH protect, noconstant(0)
 DECLARE errorcheck(null) = null
 DECLARE setrddscontext(null) = null
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0.0
 CALL setrddscontext(null)
 CALL errorcheck(null)
 DELETE  FROM shared_list_gttd
  WHERE 1=1
 ;end delete
 CALL errorcheck(null)
 INSERT  FROM shared_list_gttd t
  (t.source_entity_id, t.source_entity_value)(SELECT
   c.code_value, insrt_and_upd
   FROM (
    (
    (SELECT
     cv_snp.code_value, cv_snp.description, cv_snp.display,
     cv_snp.concept_cki
     FROM kia_event_set_code_value_snp cv_snp
     WHERE ((cv_snp.code_set=event_set_codeset) MINUS (
     (SELECT
      cv.code_value, cv.description, cv.display,
      cv.concept_cki
      FROM code_value cv
      WHERE cv.code_set=event_set_codeset))) ))
    c)
   WITH nocounter)
 ;end insert
 CALL errorcheck(null)
 INSERT  FROM shared_list_gttd t
  (t.source_entity_id, t.source_entity_value)(SELECT
   code_value, del
   FROM code_value
   WHERE ((code_set=event_set_codeset) MINUS (
   (SELECT
    code_value, del
    FROM kia_event_set_code_value_snp
    WHERE code_set=event_set_codeset))) )
 ;end insert
 CALL errorcheck(null)
 MERGE INTO code_value c
 USING (SELECT
  cv_snp.*
  FROM kia_event_set_code_value_snp cv_snp,
   shared_list_gttd t
  WHERE cv_snp.code_value=t.source_entity_id
   AND t.source_entity_value=insrt_and_upd)
 MC ON (mc.code_value=c.code_value)
 WHEN MATCHED THEN
 (UPDATE
  SET c.display = mc.display, c.display_key = mc.display_key, c.code_set = mc.code_set,
   c.cdf_meaning = mc.cdf_meaning, c.collation_seq = mc.collation_seq, c.description = mc.description,
   c.definition = mc.definition, c.active_type_cd = mc.active_type_cd, c.active_ind = mc.active_ind,
   c.active_dt_tm = mc.active_dt_tm, c.inactive_dt_tm = mc.inactive_dt_tm, c.updt_id = mc.updt_id,
   c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_cnt = mc.updt_cnt, c.updt_task = mc.updt_task,
   c.updt_applctx = mc.updt_applctx, c.begin_effective_dt_tm = mc.begin_effective_dt_tm, c
   .end_effective_dt_tm = mc.end_effective_dt_tm,
   c.data_status_cd = mc.data_status_cd, c.data_status_dt_tm = mc.data_status_dt_tm, c
   .data_status_prsnl_id = mc.data_status_prsnl_id,
   c.active_status_prsnl_id = mc.active_status_prsnl_id, c.cki = mc.cki, c.display_key_nls = mc
   .display_key_nls,
   c.concept_cki = mc.concept_cki, c.display_key_a_nls = mc.display_key_a_nls
  WHERE c.code_value=mc.code_value
 ;end update
 )
 WHEN NOT MATCHED THEN
 (INSERT  FROM c
  (c.code_value, c.code_set, c.display,
  c.display_key, c.description, c.cdf_meaning,
  c.collation_seq, c.definition, c.active_type_cd,
  c.active_ind, c.active_dt_tm, c.inactive_dt_tm,
  c.updt_id, c.updt_cnt, c.updt_task,
  c.updt_applctx, c.begin_effective_dt_tm, c.end_effective_dt_tm,
  c.data_status_cd, c.data_status_dt_tm, c.data_status_prsnl_id,
  c.active_status_prsnl_id, c.cki, c.display_key_nls,
  c.concept_cki, c.display_key_a_nls, c.updt_dt_tm)
  VALUES(mc.code_value, mc.code_set, mc.display,
  mc.display_key, mc.description, mc.cdf_meaning,
  mc.collation_seq, mc.definition, mc.active_type_cd,
  mc.active_ind, mc.active_dt_tm, mc.inactive_dt_tm,
  mc.updt_id, mc.updt_cnt, mc.updt_task,
  mc.updt_applctx, mc.begin_effective_dt_tm, mc.end_effective_dt_tm,
  mc.data_status_cd, mc.data_status_dt_tm, mc.data_status_prsnl_id,
  mc.active_status_prsnl_id, mc.cki, mc.display_key_nls,
  mc.concept_cki, mc.display_key_a_nls, cnvtdatetime(sysdate))
 ;end insert
 )
 WITH nocounter
 CALL errorcheck(null)
 DELETE  FROM code_value c
  WHERE c.code_value IN (
  (SELECT
   t.source_entity_id
   FROM shared_list_gttd t
   WHERE t.source_entity_value=del))
 ;end delete
 CALL errorcheck(null)
 DELETE  FROM shared_list_gttd
  WHERE 1=1
 ;end delete
 CALL errorcheck(null)
 INSERT  FROM shared_list_gttd t
  (t.source_entity_id, t.source_entity_value)(SELECT
   c.event_set_cd, insrt_and_upd
   FROM (
    (
    (SELECT
     esc_snp.event_set_cd, esc_snp.event_set_cd_descr, esc_snp.event_set_cd_disp,
     esc_snp.event_set_name, esc_snp.event_set_icon_name, esc_snp.event_set_color_name,
     esc_snp.accumulation_ind, esc_snp.display_association_ind, esc_snp.category_flag,
     esc_snp.combine_format, esc_snp.grouping_rule_flag, esc_snp.operation_display_flag,
     esc_snp.operation_formula, esc_snp.show_if_no_data_ind
     FROM kia_event_set_code_snp esc_snp
     WHERE ((1=1) MINUS (
     (SELECT
      esc.event_set_cd, esc.event_set_cd_descr, esc.event_set_cd_disp,
      esc.event_set_name, esc.event_set_icon_name, esc.event_set_color_name,
      esc.accumulation_ind, esc.display_association_ind, esc.category_flag,
      esc.combine_format, esc.grouping_rule_flag, esc.operation_display_flag,
      esc.operation_formula, esc.show_if_no_data_ind
      FROM v500_event_set_code esc
      WHERE 1=1))) ))
    c)
   WITH nocounter)
 ;end insert
 CALL errorcheck(null)
 INSERT  FROM shared_list_gttd t
  (t.source_entity_id, t.source_entity_value)(SELECT
   event_set_cd, del
   FROM v500_event_set_code
   WHERE ((1=1) MINUS (
   (SELECT
    event_set_cd, del
    FROM kia_event_set_code_snp
    WHERE 1=1))) )
 ;end insert
 CALL errorcheck(null)
 DELETE  FROM v500_event_set_code esc
  WHERE esc.event_set_cd IN (
  (SELECT
   t.source_entity_id
   FROM shared_list_gttd t
   WHERE t.source_entity_value=del))
 ;end delete
 CALL errorcheck(null)
 UPDATE  FROM v500_event_set_code
  SET updt_cnt = (updt_cnt+ 1), updt_dt_tm = cnvtdatetime(sysdate)
  WHERE event_set_name="ALL OCF EVENT SETS"
 ;end update
 CALL errorcheck(null)
 IF (curqual=0)
  SET error_msg = "Unable to increment updt_cnt for ALL OCF EVENT SETS"
  SET error_code = error(error_msg,0)
  SET reply->error_code = error_code
  SET reply->error_msg = error_msg
  IF ((reply->error_code != 0.0))
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 MERGE INTO v500_event_set_code esc
 USING (SELECT
  esc_snp.*
  FROM kia_event_set_code_snp esc_snp,
   shared_list_gttd t
  WHERE esc_snp.event_set_cd=t.source_entity_id
   AND t.source_entity_value=insrt_and_upd)
 MC ON (mc.event_set_cd=esc.event_set_cd)
 WHEN MATCHED THEN
 (UPDATE
  SET esc.event_set_cd_descr = mc.event_set_cd_descr, esc.event_set_name = mc.event_set_name, esc
   .accumulation_ind = mc.accumulation_ind,
   esc.category_flag = mc.category_flag, esc.code_status_cd = mc.code_status_cd, esc.combine_format
    = mc.combine_format,
   esc.display_association_ind = mc.display_association_ind, esc.event_set_color_name = mc
   .event_set_color_name, esc.event_set_icon_name = mc.event_set_icon_name,
   esc.event_set_cd_disp = mc.event_set_cd_disp, esc.event_set_cd_definition = mc
   .event_set_cd_definition, esc.event_set_cd_disp_key = mc.event_set_cd_disp_key,
   esc.grouping_rule_flag = mc.grouping_rule_flag, esc.event_set_name_key = mc.event_set_name_key,
   esc.leaf_event_cd_count = mc.leaf_event_cd_count,
   esc.operation_display_flag = mc.operation_display_flag, esc.operation_formula = mc
   .operation_formula, esc.primitive_event_set_count = mc.primitive_event_set_count,
   esc.show_if_no_data_ind = mc.show_if_no_data_ind, esc.event_set_status_cd = mc.event_set_status_cd,
   esc.updt_applctx = mc.updt_applctx,
   esc.updt_cnt = mc.updt_cnt, esc.updt_id = mc.updt_id, esc.updt_task = mc.updt_task,
   esc.updt_dt_tm = cnvtdatetime(sysdate)
  WHERE esc.event_set_cd=mc.event_set_cd
 ;end update
 )
 WHEN NOT MATCHED THEN
 (INSERT  FROM esc
  (esc.event_set_cd, esc.event_set_cd_descr, esc.event_set_name,
  esc.accumulation_ind, esc.event_set_cd_disp, esc.category_flag,
  esc.combine_format, esc.display_association_ind, esc.event_set_color_name,
  esc.event_set_icon_name, esc.event_set_cd_definition, esc.grouping_rule_flag,
  esc.leaf_event_cd_count, esc.operation_display_flag, esc.operation_formula,
  esc.primitive_event_set_count, esc.show_if_no_data_ind, esc.event_set_cd_disp_key,
  esc.code_status_cd, esc.event_set_name_key, esc.event_set_status_cd,
  esc.updt_applctx, esc.updt_cnt, esc.updt_id,
  esc.updt_task, esc.updt_dt_tm)
  VALUES(mc.event_set_cd, mc.event_set_cd_descr, mc.event_set_name,
  mc.accumulation_ind, mc.event_set_cd_disp, mc.category_flag,
  mc.combine_format, mc.display_association_ind, mc.event_set_color_name,
  mc.event_set_icon_name, mc.event_set_cd_definition, mc.grouping_rule_flag,
  mc.leaf_event_cd_count, mc.operation_display_flag, mc.operation_formula,
  mc.primitive_event_set_count, mc.show_if_no_data_ind, mc.event_set_cd_disp_key,
  mc.code_status_cd, mc.event_set_name_key, mc.event_set_status_cd,
  mc.updt_applctx, mc.updt_cnt, mc.updt_id,
  mc.updt_task, cnvtdatetime(sysdate))
 ;end insert
 )
 WITH nocounter
 CALL errorcheck(null)
 DELETE  FROM shared_list_gttd
  WHERE 1=1
 ;end delete
 CALL errorcheck(null)
 INSERT  FROM shared_list_gttd t
  (t.source_entity_id, t.source_entity_seq, t.source_entity_nbr,
  t.source_entity_value)(SELECT
   c.event_set_cd, c.parent_event_set_cd, c.event_set_collating_seq,
   insrt_and_upd
   FROM (
    (
    (SELECT
     esc_snp.event_set_cd, esc_snp.parent_event_set_cd, esc_snp.event_set_collating_seq
     FROM kia_event_set_canon_snp esc_snp
     WHERE ((1=1) MINUS (
     (SELECT
      esc.event_set_cd, esc.parent_event_set_cd, esc.event_set_collating_seq
      FROM v500_event_set_canon esc
      WHERE 1=1))) ))
    c)
   WITH nocounter)
 ;end insert
 CALL errorcheck(null)
 INSERT  FROM shared_list_gttd t
  (t.source_entity_id, t.source_entity_seq, t.source_entity_nbr,
  t.source_entity_value)(SELECT
   event_set_cd, parent_event_set_cd, event_set_collating_seq,
   del
   FROM v500_event_set_canon
   WHERE ((1=1) MINUS (
   (SELECT
    event_set_cd, parent_event_set_cd, event_set_collating_seq,
    del
    FROM kia_event_set_canon_snp
    WHERE 1=1))) )
 ;end insert
 CALL errorcheck(null)
 MERGE INTO v500_event_set_canon esc
 USING (SELECT
  esc_snp.*
  FROM kia_event_set_canon_snp esc_snp,
   shared_list_gttd t
  WHERE esc_snp.event_set_cd=t.source_entity_id
   AND esc_snp.parent_event_set_cd=t.source_entity_seq
   AND esc_snp.event_set_collating_seq=t.source_entity_nbr
   AND t.source_entity_value=insrt_and_upd)
 MC ON (mc.event_set_cd=esc.event_set_cd
  AND mc.parent_event_set_cd=esc.parent_event_set_cd
  AND mc.event_set_collating_seq=esc.event_set_collating_seq)
 WHEN MATCHED THEN
 (UPDATE
  SET esc.event_set_status_cd = mc.event_set_status_cd, esc.event_set_explode_ind = mc
   .event_set_explode_ind, esc.updt_applctx = mc.updt_applctx,
   esc.updt_cnt = mc.updt_cnt, esc.updt_id = mc.updt_id, esc.updt_task = mc.updt_task,
   esc.updt_dt_tm = cnvtdatetime(sysdate)
  WHERE esc.event_set_cd=mc.event_set_cd
   AND esc.parent_event_set_cd=mc.parent_event_set_cd
   AND esc.event_set_collating_seq=mc.event_set_collating_seq
 ;end update
 )
 WHEN NOT MATCHED THEN
 (INSERT  FROM esc
  (esc.event_set_cd, esc.parent_event_set_cd, esc.event_set_collating_seq,
  esc.event_set_status_cd, esc.event_set_explode_ind, esc.updt_applctx,
  esc.updt_cnt, esc.updt_id, esc.updt_task,
  esc.updt_dt_tm)
  VALUES(mc.event_set_cd, mc.parent_event_set_cd, mc.event_set_collating_seq,
  mc.event_set_status_cd, mc.event_set_explode_ind, mc.updt_applctx,
  mc.updt_cnt, mc.updt_id, mc.updt_task,
  cnvtdatetime(sysdate))
 ;end insert
 )
 WITH nocounter
 CALL errorcheck(null)
 DELETE  FROM v500_event_set_canon esc
  WHERE  EXISTS (
  (SELECT
   1
   FROM shared_list_gttd t
   WHERE t.source_entity_value=del
    AND esc.event_set_cd=t.source_entity_id
    AND esc.parent_event_set_cd=t.source_entity_seq
    AND esc.event_set_collating_seq=t.source_entity_nbr))
 ;end delete
 CALL errorcheck(null)
 DELETE  FROM shared_list_gttd
  WHERE 1=1
 ;end delete
 CALL errorcheck(null)
 INSERT  FROM shared_list_gttd t
  (t.source_entity_id, t.source_entity_seq, t.source_entity_nbr,
  t.source_entity_value)(SELECT
   c.event_cd, c.event_set_cd, c.event_set_level,
   insrt_and_upd
   FROM (
    (
    (SELECT
     ese_snp.event_cd, ese_snp.event_set_cd, ese_snp.event_set_level
     FROM kia_event_set_explode_snp ese_snp
     WHERE ((1=1) MINUS (
     (SELECT
      ese.event_cd, ese.event_set_cd, ese.event_set_level
      FROM v500_event_set_explode ese
      WHERE 1=1))) ))
    c)
   WITH nocounter)
 ;end insert
 CALL errorcheck(null)
 INSERT  FROM shared_list_gttd t
  (t.source_entity_id, t.source_entity_seq, t.source_entity_nbr,
  t.source_entity_value)(SELECT
   event_cd, event_set_cd, event_set_level,
   del
   FROM v500_event_set_explode
   WHERE ((1=1) MINUS (
   (SELECT
    event_cd, event_set_cd, event_set_level,
    del
    FROM kia_event_set_explode_snp
    WHERE 1=1))) )
 ;end insert
 CALL errorcheck(null)
 MERGE INTO v500_event_set_explode ese
 USING (SELECT
  ese_snp.*
  FROM kia_event_set_explode_snp ese_snp,
   shared_list_gttd t
  WHERE ese_snp.event_cd=t.source_entity_id
   AND ese_snp.event_set_cd=t.source_entity_seq
   AND ese_snp.event_set_level=t.source_entity_nbr
   AND t.source_entity_value=insrt_and_upd)
 MC ON (mc.event_cd=ese.event_cd
  AND mc.event_set_cd=ese.event_set_cd
  AND mc.event_set_level=ese.event_set_level)
 WHEN MATCHED THEN
 (UPDATE
  SET ese.event_set_status_cd = mc.event_set_status_cd, ese.updt_applctx = mc.updt_applctx, ese
   .updt_cnt = mc.updt_cnt,
   ese.updt_id = mc.updt_id, ese.updt_task = mc.updt_task, ese.updt_dt_tm = cnvtdatetime(sysdate)
  WHERE ese.event_set_cd=mc.event_set_cd
   AND ese.event_cd=mc.event_cd
   AND ese.event_set_level=mc.event_set_level
 ;end update
 )
 WHEN NOT MATCHED THEN
 (INSERT  FROM ese
  (ese.event_cd, ese.event_set_cd, ese.event_set_level,
  ese.event_set_status_cd, ese.updt_applctx, ese.updt_cnt,
  ese.updt_id, ese.updt_task, ese.updt_dt_tm)
  VALUES(mc.event_cd, mc.event_set_cd, mc.event_set_level,
  mc.event_set_status_cd, mc.updt_applctx, mc.updt_cnt,
  mc.updt_id, mc.updt_task, cnvtdatetime(sysdate))
 ;end insert
 )
 WITH nocounter
 CALL errorcheck(null)
 DELETE  FROM v500_event_set_explode ese
  WHERE  EXISTS (
  (SELECT
   1
   FROM shared_list_gttd t
   WHERE t.source_entity_value=del
    AND ese.event_cd=t.source_entity_id
    AND ese.event_set_cd=t.source_entity_seq
    AND ese.event_set_level=t.source_entity_nbr))
 ;end delete
 CALL errorcheck(null)
 SUBROUTINE setrddscontext(null)
  SELECT INTO "nl:"
   uo.object_name, uo.object_type, uo.status
   FROM user_objects uo
   WHERE uo.object_type="PROCEDURE"
    AND uo.object_name="DM2_CONTEXT_CONTROL"
    AND uo.status="VALID"
   DETAIL
    dcc_exist_ind = 1
   WITH nocounter
  ;end select
  IF (dcc_exist_ind=1)
   CALL parser(concat("RDB ASIS(^ BEGIN DM2_CONTEXT_CONTROL('RDDS UPDT_ID','",trim(cnvtstring(request
       ->updt_id,20,1)),"'); END; ^) GO"),1)
  ENDIF
 END ;Subroutine
 SUBROUTINE errorcheck(null)
   SET error_code = error(error_msg,0)
   SET reply->error_code = error_code
   SET reply->error_msg = error_msg
   IF ((reply->error_code != 0.0))
    ROLLBACK
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
END GO
