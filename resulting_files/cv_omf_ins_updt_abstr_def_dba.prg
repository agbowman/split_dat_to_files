CREATE PROGRAM cv_omf_ins_updt_abstr_def:dba
 CALL echo("CV_OMF_INS_UPDT_ABSTR_DEF called... ")
 SET cdf_meaning = fillstring(12," ")
 SET v_curr_dt_tm = cnvtdatetime(curdate,curtime3)
 SET v_filter_ind = 1
 IF ((omf_prologue_cv->14170_raw=0))
  SET code_value = 0
  SET code_set = 14170
  SET cdf_meaning = "RAW"
  EXECUTE cpm_get_cd_for_cdf
  SET omf_prologue_cv->14170_raw = code_value
 ENDIF
 IF ((omf_prologue_cv->14194_none=0))
  SET code_value = 0
  SET code_set = 14194
  SET cdf_meaning = "NONE"
  EXECUTE cpm_get_cd_for_cdf
  SET omf_prologue_cv->14194_none = code_value
 ENDIF
 IF ((omf_prologue_cv->14194_sum=0))
  SET code_value = 0
  SET code_set = 14194
  SET cdf_meaning = "SUM"
  EXECUTE cpm_get_cd_for_cdf
  SET omf_prologue_cv->14194_sum = code_value
 ENDIF
 IF ((omf_prologue_cv->14268_bool=0))
  SET code_value = 0
  SET code_set = 14268
  SET cdf_meaning = "BOOL"
  EXECUTE cpm_get_cd_for_cdf
  SET omf_prologue_cv->14268_bool = code_value
 ENDIF
 IF ((omf_prologue_cv->14268_c=0))
  SET code_value = 0
  SET code_set = 14268
  SET cdf_meaning = "C"
  EXECUTE cpm_get_cd_for_cdf
  SET omf_prologue_cv->14268_c = code_value
 ENDIF
 IF ((omf_prologue_cv->14268_dq8=0))
  SET code_value = 0
  SET code_set = 14268
  SET cdf_meaning = "DQ8"
  EXECUTE cpm_get_cd_for_cdf
  SET omf_prologue_cv->14268_dq8 = code_value
 ENDIF
 IF ((omf_prologue_cv->14268_f8=0))
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=14268
    AND cv.cdf_meaning="F8"
    AND cv.display_key="CODESET"
   DETAIL
    omf_prologue_cv->14268_f8 = cv.code_value
   WITH nocounter
  ;end select
 ENDIF
 IF ((omf_prologue_cv->14268_i2=0))
  SET code_value = 0
  SET code_set = 14268
  SET cdf_meaning = "I2"
  EXECUTE cpm_get_cd_for_cdf
  SET omf_prologue_cv->14268_i2 = code_value
 ENDIF
 IF ((omf_prologue_cv->14268_i4=0))
  SET code_value = 0
  SET code_set = 14268
  SET cdf_meaning = "I4"
  EXECUTE cpm_get_cd_for_cdf
  SET omf_prologue_cv->14268_i4 = code_value
 ENDIF
 IF ((omf_prologue_cv->14268_provider=0))
  SET code_value = 0
  SET code_set = 14268
  SET cdf_meaning = "PROVIDER"
  EXECUTE cpm_get_cd_for_cdf
  SET omf_prologue_cv->14268_provider = code_value
 ENDIF
 IF ((omf_prologue_cv->14268_vc=0))
  SET code_value = 0
  SET code_set = 14268
  SET cdf_meaning = "VC"
  EXECUTE cpm_get_cd_for_cdf
  SET omf_prologue_cv->14268_vc = code_value
 ENDIF
 FREE SET omf_abstract
 RECORD omf_abstract(
   1 data[*]
     2 abstract_def_cd = f8
     2 indicator_cd = f8
     2 key_indicator_cd = f8
     2 group_by_ind = i2
     2 data_type_flag = i2
     2 align_flag = i2
     2 indicator_type_cd = f8
     2 totals_cd = f8
     2 help_description_str = vc
     2 select_list_name = vc
     2 column_str = vc
     2 filter_ind = i2
     2 filter_meaning = vc
     2 filter_description = vc
 )
 FREE SET omf_abstract_view
 RECORD omf_abstract_view(
   1 data[*]
     2 view_cd = f8
     2 str_seq = i4
 )
 FREE SET action
 RECORD action(
   1 row[*]
     2 app_action = i1
 )
 SET v_contributor_source = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=73
   AND cv.cdf_meaning="CVNet"
   AND cv.active_ind=1
  DETAIL
   v_contributor_source = cv.code_value
  WITH counter
 ;end select
 SET v_cnt = 0
 SELECT INTO "nl:"
  oav.view_cd, oav.str_seq
  FROM omf_abstract_view oav
  WHERE oav.contributor_source_cd=v_contributor_source
  DETAIL
   v_cnt = (v_cnt+ 1), stat = alterlist(omf_abstract_view->data,v_cnt), omf_abstract_view->data[v_cnt
   ].view_cd = oav.view_cd,
   omf_abstract_view->data[v_cnt].str_seq = oav.str_seq
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  afd.abstract_field_def_cd
  FROM abstract_field_def afd,
   (dummyt d1  WITH seq = value(size(requestin->request.qual,5)))
  PLAN (d1)
   JOIN (afd
   WHERE (afd.abstract_desc=requestin->request.qual[d1.seq].abstract_desc)
    AND (afd.display_label=requestin->request.qual[d1.seq].display_label)
    AND afd.active_ind=1)
  DETAIL
   stat = alterlist(omf_abstract->data,d1.seq), omf_abstract->data[d1.seq].abstract_def_cd = afd
   .abstract_field_def_cd
  WITH nocounter
 ;end select
 CALL echo(build("abstract_def_cd = ",omf_abstract->data[1].abstract_def_cd))
 CALL echo(build("contributor_source_cd = ",v_contributor_source))
 SET stat = alterlist(action->row,size(requestin->request.qual,5))
 SELECT INTO "nl:"
  oad.abstract_def_cd
  FROM omf_abstract_def oad,
   (dummyt d  WITH seq = value(size(omf_abstract->data,5)))
  PLAN (d)
   JOIN (oad
   WHERE (oad.abstract_def_cd=omf_abstract->data[d.seq].abstract_def_cd))
  DETAIL
   IF (oad.abstract_def_cd > 0)
    action->row[d.seq].app_action = 1
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 UPDATE  FROM omf_abstract_def oad,
   (dummyt d  WITH seq = value(size(requestin->request.qual,5)))
  SET oad.contributor_source_cd = v_contributor_source, oad.indicator_cd = 0.0, oad.omf_fact_ind =
   requestin->request.qual[d.seq].omf_fact_ind,
   oad.updt_id = 0, oad.updt_cnt = 0, oad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   oad.updt_task = 0, oad.updt_applctx = 0
  PLAN (d
   WHERE (action->row[d.seq].app_action=1))
   JOIN (oad
   WHERE (oad.abstract_def_cd=omf_abstract->data[d.seq].abstract_def_cd))
  WITH nocounter, outerjoin = d
 ;end update
 INSERT  FROM omf_abstract_def oad,
   (dummyt d  WITH seq = value(size(requestin->request.qual,5)))
  SET oad.abstract_def_cd = omf_abstract->data[d.seq].abstract_def_cd, oad.contributor_source_cd =
   v_contributor_source, oad.indicator_cd = 0.0,
   oad.omf_fact_ind = requestin->request.qual[d.seq].omf_fact_ind, oad.updt_id = 0, oad.updt_cnt = 0,
   oad.updt_dt_tm = cnvtdatetime(curdate,curtime3), oad.updt_task = 0, oad.updt_applctx = 0
  PLAN (d
   WHERE (action->row[d.seq].app_action=0))
   JOIN (oad)
  WITH nocounter, outerjoin = d
 ;end insert
 SET v_cnt = 0
 FOR (v_cnt = 1 TO size(requestin->request.qual,5))
   SET omf_abstract->data[v_cnt].indicator_cd = omf_create_indicator(v_cnt)
 ENDFOR
 UPDATE  FROM omf_abstract_def oad,
   (dummyt d  WITH seq = value(size(omf_abstract->data,5)))
  SET oad.indicator_cd = omf_abstract->data[d.seq].indicator_cd, oad.updt_cnt = (oad.updt_cnt+ 1),
   oad.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d)
   JOIN (oad
   WHERE (oad.abstract_def_cd=omf_abstract->data[d.seq].abstract_def_cd))
  WITH nocounter, outerjoin = d
 ;end update
 FREE SET action
 RECORD action(
   1 row[*]
     2 app_action = i1
 )
 SET stat = alterlist(action->row,size(omf_abstract->data,5))
 SELECT INTO "nl:"
  oi.indicator_cd
  FROM omf_indicator oi,
   (dummyt d  WITH seq = value(size(omf_abstract->data,5)))
  PLAN (d)
   JOIN (oi
   WHERE (oi.indicator_cd=omf_abstract->data[d.seq].indicator_cd))
  DETAIL
   IF (oi.indicator_cd > 0)
    action->row[d.seq].app_action = 1
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 UPDATE  FROM omf_indicator oi,
   (dummyt d  WITH seq = value(size(omf_abstract->data,5)))
  SET oi.key_indicator_cd = omf_abstract->data[d.seq].key_indicator_cd, oi.str_seq = 1, oi
   .group_by_ind = omf_abstract->data[d.seq].group_by_ind,
   oi.data_type_flag = omf_abstract->data[d.seq].data_type_flag, oi.align_flag = omf_abstract->data[d
   .seq].align_flag, oi.indicator_type_cd = omf_abstract->data[d.seq].indicator_type_cd,
   oi.totals_cd = omf_abstract->data[d.seq].totals_cd, oi.help_description_str = omf_abstract->data[d
   .seq].help_description_str, oi.select_list_name = omf_abstract->data[d.seq].select_list_name,
   oi.column_str = omf_abstract->data[d.seq].column_str, oi.filter_ind = omf_abstract->data[d.seq].
   filter_ind, oi.filter_meaning = omf_abstract->data[d.seq].filter_meaning,
   oi.filter_description = omf_abstract->data[d.seq].filter_description
  PLAN (d
   WHERE (action->row[d.seq].app_action=1))
   JOIN (oi
   WHERE (oi.indicator_cd=omf_abstract->data[d.seq].indicator_cd))
  WITH nocounter
 ;end update
 INSERT  FROM omf_indicator oi,
   (dummyt d  WITH seq = value(size(omf_abstract->data,5)))
  SET oi.indicator_cd = omf_abstract->data[d.seq].indicator_cd, oi.key_indicator_cd = omf_abstract->
   data[d.seq].key_indicator_cd, oi.str_seq = 1,
   oi.group_by_ind = omf_abstract->data[d.seq].group_by_ind, oi.data_type_flag = omf_abstract->data[d
   .seq].data_type_flag, oi.align_flag = omf_abstract->data[d.seq].align_flag,
   oi.indicator_type_cd = omf_abstract->data[d.seq].indicator_type_cd, oi.totals_cd = omf_abstract->
   data[d.seq].totals_cd, oi.help_description_str = omf_abstract->data[d.seq].help_description_str,
   oi.select_list_name = omf_abstract->data[d.seq].select_list_name, oi.column_str = omf_abstract->
   data[d.seq].column_str, oi.filter_ind = omf_abstract->data[d.seq].filter_ind,
   oi.filter_meaning = omf_abstract->data[d.seq].filter_meaning, oi.filter_description = omf_abstract
   ->data[d.seq].filter_description
  PLAN (d
   WHERE (action->row[d.seq].app_action=0))
   JOIN (oi)
  WITH nocounter
 ;end insert
 FOR (v_cnt = 1 TO size(omf_abstract_view->data,5))
   INSERT  FROM omf_view_indicator ovi,
     (dummyt d  WITH seq = value(size(omf_abstract->data,5)))
    SET ovi.view_cd = omf_abstract_view->data[v_cnt].view_cd, ovi.indicator_cd = omf_abstract->data[d
     .seq].indicator_cd, ovi.view_str_seq1 = omf_abstract_view->data[v_cnt].str_seq,
     ovi.view_str_seq2 = 0, ovi.view_str_seq3 = 0
    PLAN (d
     WHERE (action->row[d.seq].app_action=0))
     JOIN (ovi)
    WITH nocounter
   ;end insert
 ENDFOR
 COMMIT
 GO TO end_program
 SUBROUTINE omf_create_indicator(is1_request_seq)
   SET vs1_indicator_display = fillstring(40," ")
   SET vs1_filter_description = fillstring(50," ")
   SET vs1_filter_meaning = fillstring(12," ")
   SET vs1_indicator_cd = 0
   SET vs1_field_type_cd = 0
   SET next_code = 0.0
   SET vs1_indicator_display = concat("OMFABS PROFILE ",cnvtstring(omf_abstract->data[is1_request_seq
     ].abstract_def_cd))
   SET vs1_field_type_cd = cnvtint(requestin->request.qual[is1_request_seq].abstract_field_type_cd)
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=14265
     AND cv.cdf_meaning="INDICATOR"
     AND cv.display=trim(vs1_indicator_display)
    DETAIL
     vs1_indicator_cd = cv.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    EXECUTE cpm_next_code
    INSERT  FROM code_value cv
     SET cv.code_value = next_code, cv.code_set = 14265, cv.cdf_meaning = "INDICATOR",
      cv.display = trim(vs1_indicator_display), cv.display_key = cnvtupper(cnvtalphanum(
        vs1_indicator_display)), cv.description = trim(vs1_indicator_display),
      cv.active_ind = 1, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_task = 0,
      cv.updt_cnt = 0, cv.updt_id = 0, cv.updt_applctx = 0
    ;end insert
    SET vs1_indicator_cd = next_code
   ENDIF
   IF ((requestin->request.qual[is1_request_seq].omf_fact_ind=0))
    SET omf_abstract->data[is1_request_seq].key_indicator_cd = vs1_indicator_cd
    SET omf_abstract->data[is1_request_seq].group_by_ind = 1
    SET omf_abstract->data[is1_request_seq].align_flag = 2
    SET omf_abstract->data[is1_request_seq].indicator_type_cd = omf_prologue_cv->14170_raw
    SET omf_abstract->data[is1_request_seq].totals_cd = omf_prologue_cv->14194_none
    SET omf_abstract->data[is1_request_seq].help_description_str = trim(requestin->request.qual[
     is1_request_seq].abstract_desc)
    SET omf_abstract->data[is1_request_seq].filter_ind = v_filter_ind
    SET omf_abstract->data[is1_request_seq].data_type_flag = 3
    SET vs1_filter_description = trim(requestin->request.qual[is1_request_seq].abstract_desc)
    SET omf_abstract->data[is1_request_seq].filter_description = vs1_filter_description
    SET omf_abstract->data[is1_request_seq].select_list_name = concat("I",trim(cnvtstring(
       omf_abstract->data[is1_request_seq].abstract_def_cd)))
    SET omf_abstract->data[is1_request_seq].column_str = concat("omf_get_abstract_desc(",trim(
      cnvtstring(omf_abstract->data[is1_request_seq].abstract_def_cd)),", oes.encntr_id)")
    IF ((omf_prologue_cv->14268_dq8=requestin->request.qual[is1_request_seq].abstract_field_type_cd))
     SET omf_abstract->data[is1_request_seq].filter_ind = 0
     SET omf_abstract->data[is1_request_seq].filter_meaning = ""
     SET omf_abstract->data[is1_request_seq].filter_description = ""
     SET vs1_filter_meaning = "DATE"
     SET vs1_key_indicator_cd = 0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=14265
       AND cv.cdf_meaning="INDICATOR"
       AND cv.display=concat(trim(vs1_indicator_display),"filter")
      DETAIL
       vs1_key_indicator_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      EXECUTE cpm_next_code
      INSERT  FROM code_value cv
       SET cv.code_value = next_code, cv.code_set = 14265, cv.cdf_meaning = "INDICATOR",
        cv.display = concat(trim(vs1_indicator_display),"filter"), cv.display_key = cnvtupper(
         cnvtalphanum(concat(trim(vs1_indicator_display),"FILTER"))), cv.description = concat(trim(
          vs1_indicator_display),"filter"),
        cv.active_ind = 1, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_task = 0,
        cv.updt_cnt = 0, cv.updt_id = 0, cv.updt_applctx = 0
      ;end insert
      SET vs1_key_indicator_cd = next_code
     ENDIF
     SET omf_abstract->data[is1_request_seq].key_indicator_cd = vs1_key_indicator_cd
     SELECT INTO "nl:"
      oi.indicator_cd
      FROM omf_indicator oi
      WHERE oi.indicator_cd=vs1_key_indicator_cd
      WITH nocounter
     ;end select
     IF (curqual > 0)
      UPDATE  FROM omf_indicator oi
       SET oi.key_indicator_cd = 0, oi.str_seq = 1, oi.group_by_ind = 0,
        oi.data_type_flag = 2, oi.align_flag = 2, oi.indicator_type_cd = omf_prologue_cv->14170_raw,
        oi.totals_cd = omf_prologue_cv->14194_none, oi.select_list_name = concat("F",trim(cnvtstring(
           omf_abstract->data[is1_request_seq].abstract_def_cd))), oi.column_str = concat(
         "cnvtdatetime(omf_get_abstract_date(",trim(cnvtstring(omf_abstract->data[is1_request_seq].
           abstract_def_cd)),", oes.encntr_id))"),
        oi.filter_ind = v_filter_ind, oi.filter_meaning = vs1_filter_meaning, oi.filter_description
         = vs1_filter_description
       WHERE oi.indicator_cd=vs1_key_indicator_cd
       WITH nocounter
      ;end update
     ELSE
      INSERT  FROM omf_indicator oi
       SET oi.indicator_cd = vs1_key_indicator_cd, oi.key_indicator_cd = 0, oi.str_seq = 1,
        oi.group_by_ind = 0, oi.data_type_flag = 2, oi.align_flag = 2,
        oi.indicator_type_cd = omf_prologue_cv->14170_raw, oi.totals_cd = omf_prologue_cv->14194_none,
        oi.select_list_name = concat("F",trim(cnvtstring(omf_abstract->data[is1_request_seq].
           abstract_def_cd))),
        oi.column_str = concat("cnvtdatetime(omf_get_abstract_date(",trim(cnvtstring(omf_abstract->
           data[is1_request_seq].abstract_def_cd)),", oes.encntr_id))"), oi.filter_ind = v_filter_ind,
        oi.filter_meaning = vs1_filter_meaning,
        oi.filter_description = vs1_filter_description
       WITH nocounter
      ;end insert
     ENDIF
     FOR (vs1_cnt = 1 TO size(omf_abstract_view->data,5))
      SELECT INTO "nl:"
       ovi.view_cd, ovi.indicator_cd
       FROM omf_view_indicator ovi
       WHERE (ovi.view_cd=omf_abstract_view->data[vs1_cnt].view_cd)
        AND ovi.indicator_cd=vs1_key_indicator_cd
       WITH nocounter
      ;end select
      IF (curqual=0)
       INSERT  FROM omf_view_indicator ovi
        SET ovi.view_cd = omf_abstract_view->data[vs1_cnt].view_cd, ovi.indicator_cd =
         vs1_key_indicator_cd, ovi.view_str_seq1 = omf_abstract_view->data[vs1_cnt].str_seq,
         ovi.view_str_seq2 = 0, ovi.view_str_seq3 = 0
        WITH nocounter
       ;end insert
      ENDIF
     ENDFOR
     SET vs1_group_indicator_cd = 0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=14265
       AND cv.cdf_meaning="INDICATOR"
       AND cv.display=concat(trim(vs1_indicator_display),"group")
      DETAIL
       vs1_group_indicator_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      EXECUTE cpm_next_code
      INSERT  FROM code_value cv
       SET cv.code_value = next_code, cv.code_set = 14265, cv.cdf_meaning = "INDICATOR",
        cv.display = concat(trim(vs1_indicator_display),"group"), cv.display_key = cnvtupper(
         cnvtalphanum(concat(trim(vs1_indicator_display),"GROUP"))), cv.description = concat(trim(
          vs1_indicator_display),"group"),
        cv.active_ind = 1, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_task = 0,
        cv.updt_cnt = 0, cv.updt_id = 0, cv.updt_applctx = 0
      ;end insert
      SET vs1_group_indicator_cd = next_code
     ENDIF
     SELECT INTO "nl:"
      oi.indicator_cd
      FROM omf_indicator oi
      WHERE oi.indicator_cd=vs1_group_indicator_cd
      WITH nocounter
     ;end select
     IF (curqual > 0)
      UPDATE  FROM omf_indicator oi
       SET oi.key_indicator_cd = 0, oi.str_seq = 1, oi.group_by_ind = 1,
        oi.data_type_flag = 3, oi.align_flag = 4, oi.indicator_type_cd = omf_prologue_cv->14170_raw,
        oi.totals_cd = omf_prologue_cv->14194_none, oi.select_list_name = concat("G",trim(cnvtstring(
           omf_abstract->data[is1_request_seq].abstract_def_cd))), oi.column_str = concat(
         "omf_get_abstract_date(",trim(cnvtstring(omf_abstract->data[is1_request_seq].abstract_def_cd
           )),", oes.encntr_id)"),
        oi.filter_ind = 0, oi.filter_meaning = "", oi.filter_description = ""
       WHERE oi.indicator_cd=vs1_group_indicator_cd
       WITH nocounter
      ;end update
     ELSE
      INSERT  FROM omf_indicator oi
       SET oi.indicator_cd = vs1_group_indicator_cd, oi.key_indicator_cd = 0, oi.str_seq = 1,
        oi.group_by_ind = 1, oi.data_type_flag = 3, oi.align_flag = 4,
        oi.indicator_type_cd = omf_prologue_cv->14170_raw, oi.totals_cd = omf_prologue_cv->14194_none,
        oi.select_list_name = concat("G",trim(cnvtstring(omf_abstract->data[is1_request_seq].
           abstract_def_cd))),
        oi.column_str = concat("omf_get_abstract_date(",trim(cnvtstring(omf_abstract->data[
           is1_request_seq].abstract_def_cd)),", oes.encntr_id)"), oi.filter_ind = 0, oi
        .filter_meaning = "",
        oi.filter_description = ""
       WITH nocounter
      ;end insert
      INSERT  FROM omf_calc_indicator oci
       SET oci.indicator_cd = vs1_indicator_cd, oci.calc_indicator_cd = vs1_group_indicator_cd
       WITH nocounter
      ;end insert
     ENDIF
     FOR (vs1_cnt = 1 TO size(omf_abstract_view->data,5))
      SELECT INTO "nl:"
       ovi.view_cd, ovi.indicator_cd
       FROM omf_view_indicator ovi
       WHERE (ovi.view_cd=omf_abstract_view->data[vs1_cnt].view_cd)
        AND ovi.indicator_cd=vs1_group_indicator_cd
       WITH nocounter
      ;end select
      IF (curqual=0)
       INSERT  FROM omf_view_indicator ovi
        SET ovi.view_cd = omf_abstract_view->data[vs1_cnt].view_cd, ovi.indicator_cd =
         vs1_group_indicator_cd, ovi.view_str_seq1 = omf_abstract_view->data[vs1_cnt].str_seq,
         ovi.view_str_seq2 = 0, ovi.view_str_seq3 = 0
        WITH nocounter
       ;end insert
      ENDIF
     ENDFOR
    ELSEIF ((((omf_prologue_cv->14268_provider=requestin->request.qual[is1_request_seq].
    abstract_field_type_cd)) OR ((omf_prologue_cv->14268_f8=requestin->request.qual[is1_request_seq].
    abstract_field_type_cd))) )
     SET omf_abstract->data[is1_request_seq].filter_ind = 0
     SET omf_abstract->data[is1_request_seq].filter_meaning = ""
     SET omf_abstract->data[is1_request_seq].filter_description = ""
     IF ((omf_prologue_cv->14268_provider=requestin->request.qual[is1_request_seq].
     abstract_field_type_cd))
      SET vs1_filter_meaning = "PHYSICIAN"
     ELSEIF ((omf_prologue_cv->14268_f8=requestin->request.qual[is1_request_seq].
     abstract_field_type_cd))
      SET vs1_filter_meaning = trim(cnvtstring(omf_abstract->data[is1_request_seq].abstract_def_cd))
      SET v_filter_meaning_ind = 0
      SELECT INTO "nl:"
       filter_meaning
       FROM omf_filter_meaning
       WHERE filter_meaning=trim(cnvtstring(omf_abstract->data[is1_request_seq].abstract_def_cd))
       DETAIL
        v_filter_meaning_ind = 1
       WITH nocounter
      ;end select
      IF (v_filter_meaning_ind=0)
       INSERT  FROM omf_filter_meaning
        SET filter_meaning = trim(cnvtstring(omf_abstract->data[is1_request_seq].abstract_def_cd)),
         filter_script = 950168, display_function = "omf_get_cv_display",
         show_all_ind = 1, filter_pe_name = "CODE_VALUE", val1 = "omf_code_set_active_list",
         val2 = cnvtstring(requestin->request.qual[is1_request_seq].codeset_nbr)
       ;end insert
      ENDIF
     ENDIF
     SET vs1_key_indicator_cd = 0
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=14265
       AND cv.cdf_meaning="INDICATOR"
       AND cv.display=concat(trim(vs1_indicator_display),"filter")
      DETAIL
       vs1_key_indicator_cd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual=0)
      EXECUTE cpm_next_code
      INSERT  FROM code_value cv
       SET cv.code_value = next_code, cv.code_set = 14265, cv.cdf_meaning = "INDICATOR",
        cv.display = concat(trim(vs1_indicator_display),"filter"), cv.display_key = cnvtupper(
         cnvtalphanum(concat(trim(vs1_indicator_display),"FILTER"))), cv.description = concat(trim(
          vs1_indicator_display),"filter"),
        cv.active_ind = 1, cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_task = 0,
        cv.updt_cnt = 0, cv.updt_id = 0, cv.updt_applctx = 0
      ;end insert
      SET vs1_key_indicator_cd = next_code
     ENDIF
     SET omf_abstract->data[is1_request_seq].key_indicator_cd = vs1_key_indicator_cd
     SELECT INTO "nl:"
      oi.indicator_cd
      FROM omf_indicator oi
      WHERE oi.indicator_cd=vs1_key_indicator_cd
      WITH nocounter
     ;end select
     IF (curqual > 0)
      UPDATE  FROM omf_indicator oi
       SET oi.key_indicator_cd = 0, oi.str_seq = 1, oi.group_by_ind = 1,
        oi.data_type_flag = 1, oi.align_flag = 2, oi.indicator_type_cd = omf_prologue_cv->14170_raw,
        oi.totals_cd = omf_prologue_cv->14194_none, oi.select_list_name = concat("F",trim(cnvtstring(
           omf_abstract->data[is1_request_seq].abstract_def_cd))), oi.column_str = concat(
         "omf_get_abstract_cd(",trim(cnvtstring(omf_abstract->data[is1_request_seq].abstract_def_cd)),
         ", oes.encntr_id)"),
        oi.filter_ind = v_filter_ind, oi.filter_meaning = vs1_filter_meaning, oi.filter_description
         = vs1_filter_description
       WHERE oi.indicator_cd=vs1_key_indicator_cd
       WITH nocounter
      ;end update
     ELSE
      INSERT  FROM omf_indicator oi
       SET oi.indicator_cd = vs1_key_indicator_cd, oi.key_indicator_cd = 0, oi.str_seq = 1,
        oi.group_by_ind = 1, oi.data_type_flag = 1, oi.align_flag = 2,
        oi.indicator_type_cd = omf_prologue_cv->14170_raw, oi.totals_cd = omf_prologue_cv->14194_none,
        oi.select_list_name = concat("F",trim(cnvtstring(omf_abstract->data[is1_request_seq].
           abstract_def_cd))),
        oi.column_str = concat("omf_get_abstract_cd(",trim(cnvtstring(omf_abstract->data[
           is1_request_seq].abstract_def_cd)),", oes.encntr_id)"), oi.filter_ind = v_filter_ind, oi
        .filter_meaning = vs1_filter_meaning,
        oi.filter_description = vs1_filter_description
       WITH nocounter
      ;end insert
     ENDIF
     FOR (vs1_cnt = 1 TO size(omf_abstract_view->data,5))
      SELECT INTO "nl:"
       ovi.view_cd, ovi.indicator_cd
       FROM omf_view_indicator ovi
       WHERE (ovi.view_cd=omf_abstract_view->data[vs1_cnt].view_cd)
        AND ovi.indicator_cd=vs1_key_indicator_cd
       WITH nocounter
      ;end select
      IF (curqual=0)
       INSERT  FROM omf_view_indicator ovi
        SET ovi.view_cd = omf_abstract_view->data[vs1_cnt].view_cd, ovi.indicator_cd =
         vs1_key_indicator_cd, ovi.view_str_seq1 = omf_abstract_view->data[vs1_cnt].str_seq,
         ovi.view_str_seq2 = 0, ovi.view_str_seq3 = 0
        WITH nocounter
       ;end insert
      ENDIF
     ENDFOR
    ELSE
     SET omf_abstract->data[is1_request_seq].filter_meaning = "PROFILE ABS"
    ENDIF
   ELSEIF ((requestin->request.qual[is1_request_seq].omf_fact_ind=1))
    SET omf_abstract->data[is1_request_seq].key_indicator_cd = 0
    SET omf_abstract->data[is1_request_seq].group_by_ind = 0
    SET omf_abstract->data[is1_request_seq].align_flag = 4
    SET omf_abstract->data[is1_request_seq].indicator_type_cd = omf_prologue_cv->14170_raw
    SET omf_abstract->data[is1_request_seq].totals_cd = omf_prologue_cv->14194_sum
    SET omf_abstract->data[is1_request_seq].help_description_str = trim(requestin->request.qual[
     is1_request_seq].abstract_desc)
    SET omf_abstract->data[is1_request_seq].filter_ind = 0
    SET omf_abstract->data[is1_request_seq].data_type_flag = 1
    SET omf_abstract->data[is1_request_seq].select_list_name = concat("I",trim(cnvtstring(
       omf_abstract->data[is1_request_seq].abstract_def_cd)))
    SET omf_abstract->data[is1_request_seq].column_str = concat("sum(omf_get_abstract_nbr(",trim(
      cnvtstring(omf_abstract->data[is1_request_seq].abstract_def_cd)),", oes.encntr_id))")
   ENDIF
   RETURN(vs1_indicator_cd)
 END ;Subroutine
#end_program
 CALL echo("OMF_INS_PROFILE_ABSTRACT_DEF exiting... ")
END GO
