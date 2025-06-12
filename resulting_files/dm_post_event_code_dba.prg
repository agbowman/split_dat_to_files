CREATE PROGRAM dm_post_event_code:dba
 SET i_event_cd_disp_key = cnvtupper(cnvtalphanum(dm_post_event_code->event_cd_disp))
 SET cnt = 0.0
 SELECT INTO "nl:"
  y = count(*)
  FROM code_value_event_r dpec
  WHERE (dpec.parent_cd=dm_post_event_code->parent_cd)
   AND (dpec.flex1_cd=dm_post_event_code->flex1_cd)
   AND (dpec.flex2_cd=dm_post_event_code->flex2_cd)
   AND (dpec.flex3_cd=dm_post_event_code->flex3_cd)
   AND (dpec.flex4_cd=dm_post_event_code->flex4_cd)
   AND (dpec.flex5_cd=dm_post_event_code->flex5_cd)
  DETAIL
   cnt = y
  WITH nocounter
 ;end select
 SET dm_post_event_code->event_cd = 0
 IF (cnt=0)
  SET event_code_exists = 0
  SELECT INTO "nl:"
   vec.event_cd
   FROM v500_event_code vec
   WHERE vec.event_cd_disp_key=i_event_cd_disp_key
    AND (vec.event_cd_disp=dm_post_event_code->event_cd_disp)
   DETAIL
    dm_post_event_code->event_cd = vec.event_cd, event_code_exists = 1
   WITH nocounter
  ;end select
  SET code_value_cnt = 0
  IF (event_code_exists=1)
   SELECT INTO "nl:"
    y = count(*)
    FROM code_value cv
    WHERE (cv.code_value=dm_post_event_code->event_cd)
    DETAIL
     code_value_cnt = y
    WITH nocounter
   ;end select
  ENDIF
  IF (event_code_exists=0)
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     dm_post_event_code->event_cd = y
    WITH nocounter
   ;end select
   SET i_def_docmnt_format_cd = 0.0
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE (cv.cdf_meaning=dm_post_event_code->format)
     AND cv.code_set=23
    DETAIL
     i_def_docmnt_format_cd = cv.code_value
    WITH nocounter
   ;end select
   SET i_def_docmnt_storage_cd = 0.0
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE (cv.cdf_meaning=dm_post_event_code->storage)
     AND cv.code_set=25
    DETAIL
     i_def_docmnt_storage_cd = cv.code_value
    WITH nocounter
   ;end select
   SET i_def_event_class_cd = 0.0
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE (cv.cdf_meaning=dm_post_event_code->event_class)
     AND cv.code_set=53
    DETAIL
     i_def_event_class_cd = cv.code_value
    WITH nocounter
   ;end select
   SET i_def_event_confid_level_cd = 0.0
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE (cv.cdf_meaning=dm_post_event_code->event_confid_level)
     AND cv.code_set=87
    DETAIL
     i_def_event_confid_level_cd = cv.code_value
    WITH nocounter
   ;end select
   SET i_event_cd_subclass_cd = 0.0
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE (cv.cdf_meaning=dm_post_event_code->event_subclass)
     AND cv.code_set=102
    DETAIL
     i_event_cd_subclass_cd = cv.code_value
    WITH nocounter
   ;end select
  ENDIF
  IF (((event_code_exists=0) OR (code_value_cnt=0)) )
   SET i_code_status_cd = 0.0
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE (cv.cdf_meaning=dm_post_event_code->status)
     AND cv.code_set=48
    DETAIL
     i_code_status_cd = cv.code_value
    WITH nocounter
   ;end select
   SET i_event_code_status_cd = 0.0
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE (cv.cdf_meaning=dm_post_event_code->event_code_status)
     AND cv.code_set=8
    DETAIL
     i_event_code_status_cd = cv.code_value
    WITH nocounter
   ;end select
   INSERT  FROM code_value cv
    (cv.display, cv.code_set, cv.display_key,
    cv.description, cv.definition, cv.collation_seq,
    cv.active_type_cd, cv.active_ind, cv.active_dt_tm,
    cv.updt_dt_tm, cv.updt_id, cv.updt_cnt,
    cv.updt_task, cv.updt_applctx, cv.begin_effective_dt_tm,
    cv.end_effective_dt_tm, cv.data_status_cd, cv.data_status_dt_tm,
    cv.data_status_prsnl_id, cv.active_status_prsnl_id, cv.code_value)
    VALUES(dm_post_event_code->event_cd_disp, 72, i_event_cd_disp_key,
    dm_post_event_code->event_cd_descr, dm_post_event_code->event_cd_definition, 1,
    i_code_status_cd, 1, cnvtdatetime(curdate,curtime3),
    cnvtdatetime(curdate,curtime3), 12087, 1,
    12087, 12087, cnvtdatetime(curdate,curtime3),
    cnvtdatetime("31-dec-2100"), i_event_code_status_cd, cnvtdatetime(curdate,curtime3),
    0, 0, dm_post_event_code->event_cd)
   ;end insert
   IF (event_code_exists=0)
    INSERT  FROM v500_event_code
     (event_cd, event_cd_definition, event_cd_descr,
     event_cd_disp, event_cd_disp_key, code_status_cd,
     def_docmnt_format_cd, def_docmnt_storage_cd, def_event_class_cd,
     def_event_confid_level_cd, event_add_access_ind, event_cd_subclass_cd,
     event_chg_access_ind, event_set_name, event_code_status_cd,
     updt_dt_tm, updt_applctx, updt_cnt,
     updt_id, updt_task)
     VALUES(dm_post_event_code->event_cd, dm_post_event_code->event_cd_definition, dm_post_event_code
     ->event_cd_descr,
     dm_post_event_code->event_cd_disp, i_event_cd_disp_key, i_code_status_cd,
     i_def_docmnt_format_cd, i_def_docmnt_storage_cd, i_def_event_class_cd,
     i_def_event_confid_level_cd, 0, i_event_cd_subclass_cd,
     0, dm_post_event_code->event_set_name, i_event_code_status_cd,
     cnvtdatetime(curdate,curtime3), 12087, 1,
     12087, 12087)
    ;end insert
   ENDIF
  ENDIF
  INSERT  FROM code_value_event_r
   (event_cd, parent_cd, flex1_cd,
   flex2_cd, flex3_cd, flex4_cd,
   flex5_cd, updt_dt_tm, updt_id,
   updt_cnt, updt_task, updt_applctx)
   VALUES(dm_post_event_code->event_cd, dm_post_event_code->parent_cd, dm_post_event_code->flex1_cd,
   dm_post_event_code->flex2_cd, dm_post_event_code->flex3_cd, dm_post_event_code->flex4_cd,
   dm_post_event_code->flex5_cd, cnvtdatetime(curdate,curtime3), 12087,
   1, 12087, 12087)
  ;end insert
  COMMIT
 ENDIF
END GO
