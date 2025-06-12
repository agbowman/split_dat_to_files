CREATE PROGRAM dac_a_nls_transition:dba
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
 DECLARE sbr_check_for_a_nls(null) = i2 WITH protect, noconstant(0)
 DECLARE sbr_load_csv(null) = null
 DECLARE sbr_get_nls_lang(null) = vc WITH protect, noconstant("")
 IF ( NOT (validate(dcfan_columns,0)))
  FREE RECORD dcfan_columns
  RECORD dcfan_columns(
    1 rows[*]
      2 nls_language = vc
      2 nls_sort_value = vc
  )
 ENDIF
 SUBROUTINE sbr_check_for_a_nls(null)
   IF ( NOT (validate(dcfan_columns->rows[1].nls_language,0)))
    CALL sbr_load_csv(null)
   ENDIF
   SELECT INTO "nl:"
    FROM v$nls_parameters v,
     (dummyt d  WITH seq = value(size(dcfan_columns->rows,5)))
    PLAN (d)
     JOIN (v
     WHERE v.parameter="NLS_LANGUAGE"
      AND (v.value=dcfan_columns->rows[d.seq].nls_language))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE sbr_load_csv(null)
   DECLARE istart = i2 WITH protect, noconstant(0)
   DECLARE iend = i2 WITH protect, noconstant(0)
   DECLARE rowcnt = i2 WITH protect, noconstant(0)
   DECLARE csvfile = vc WITH protect, constant("cer_install:dac_a_nls_languages.csv")
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc csvfile
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    FROM rtl2t r
    HEAD REPORT
     rowcnt = - (1)
    DETAIL
     IF (size(trim(r.line),1) > 0)
      rowcnt = (rowcnt+ 1)
      IF (rowcnt > 0)
       IF (mod(rowcnt,10)=1)
        stat = alterlist(dcfan_columns->rows,(rowcnt+ 9))
       ENDIF
       istart = 1, iend = 1
       WHILE (iend > 0)
         iend = findstring(",",r.line,istart,0)
         IF (iend > 0)
          dcfan_columns->rows[rowcnt].nls_language = substring(istart,(iend - istart),r.line)
         ELSE
          dcfan_columns->rows[rowcnt].nls_sort_value = substring(istart,(size(r.line,1) - istart),r
           .line)
         ENDIF
         istart = (iend+ 1)
       ENDWHILE
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(dcfan_columns->rows,rowcnt)
    WITH nocounter
   ;end select
   FREE DEFINE rtl2
 END ;Subroutine
 SUBROUTINE sbr_get_nls_lang(null)
   IF ( NOT (validate(dcfan_columns->rows[1].nls_language,0)))
    CALL sbr_load_csv(null)
   ENDIF
   DECLARE dcfan_nls_sort = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM v$nls_parameters v,
     (dummyt d  WITH seq = value(size(dcfan_columns->rows,5)))
    PLAN (d)
     JOIN (v
     WHERE v.parameter="NLS_LANGUAGE"
      AND (v.value=dcfan_columns->rows[d.seq].nls_language))
    DETAIL
     dcfan_nls_sort = dcfan_columns->rows[d.seq].nls_sort_value
    WITH nocounter
   ;end select
   RETURN(dcfan_nls_sort)
 END ;Subroutine
 DECLARE sbr_get_ora_major_version(null) = i4
 SUBROUTINE sbr_get_ora_major_version(null)
   DECLARE dcov_ora_version = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    p.version
    FROM product_component_version p
    WHERE cnvtupper(p.product)="ORACLE*"
    DETAIL
     dcov_ora_version = cnvtint(substring(1,findstring(".",p.version,1,0),p.version))
    WITH nocounter
   ;end select
   RETURN(dcov_ora_version)
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dac_a_nls_transition..."
 IF (sbr_get_ora_major_version(null) < 10)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Auto-successing; this readme does not run on Oracle prior to version 10"
  GO TO exit_script
 ENDIF
 DECLARE dant_ccl_revision = i4 WITH protect, noconstant(0)
 DECLARE dant_table_idx = i4 WITH protect, noconstant(0)
 DECLARE dant_table_cnt = i4 WITH protect, noconstant(0)
 DECLARE dant_max_trigger_count = i4 WITH protect, noconstant(0)
 DECLARE dant_trigger_idx = i4 WITH protect, noconstant(0)
 DECLARE dant_nls_trigger_cnt = i4 WITH protect, noconstant(0)
 DECLARE dant_missing_trg_count = i4 WITH protect, noconstant(0)
 DECLARE dant_disable_stmt = vc WITH protect, noconstant("")
 DECLARE dant_err_msg = vc WITH protect, noconstant("")
 DECLARE dant_nls_lang = vc WITH protect, noconstant("")
 FREE RECORD dant_columns
 RECORD dant_columns(
   1 tables[*]
     2 suffixed_table_name = vc
     2 trigger_cnt = i4
     2 triggers[*]
       3 trigger_name = vc
       3 trigger_exists_ind = i2
 )
 FREE RECORD dant_nls_triggers
 RECORD dant_nls_triggers(
   1 triggers[*]
     2 trigger_name = vc
 )
 IF (sbr_check_for_a_nls(null)=0)
  SET readme_data->status = "S"
  SET readme_data->message = "This is not an NLS domain; auto-successing"
  GO TO exit_script
 ENDIF
 SET dant_ccl_revision = (((currev * 10000)+ (currevminor * 100))+ currevminor2)
 IF (dant_ccl_revision < 80502)
  SET readme_data->status = "F"
  SET readme_data->message = concat("This readme requires minimum CCL 8.5.2; current version is ",
   build(currev),".",build(currevminor),".",
   build(currevminor2))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dtd.suffixed_table_name, column_count = count(*)
  FROM user_tab_columns utc,
   dm_tables_doc dtd
  PLAN (utc
   WHERE utc.column_name="*_A_NLS")
   JOIN (dtd
   WHERE dtd.table_name=utc.table_name)
  GROUP BY dtd.suffixed_table_name
  DETAIL
   dant_table_cnt = (dant_table_cnt+ 1), stat = alterlist(dant_columns->tables,dant_table_cnt),
   dant_columns->tables[dant_table_cnt].suffixed_table_name = dtd.suffixed_table_name,
   dant_columns->tables[dant_table_cnt].trigger_cnt = column_count, dant_max_trigger_count = maxval(
    dant_max_trigger_count,column_count)
  WITH nocounter
 ;end select
 FOR (dant_table_idx = 1 TO dant_table_cnt)
  SET stat = alterlist(dant_columns->tables[dant_table_idx].triggers,dant_columns->tables[
   dant_table_idx].trigger_cnt)
  FOR (dant_trigger_idx = 1 TO dant_columns->tables[dant_table_idx].trigger_cnt)
    SET dant_columns->tables[dant_table_idx].triggers[dant_trigger_idx].trigger_name = build("TRG_",
     dant_columns->tables[dant_table_idx].suffixed_table_name,"_ANLS",dant_trigger_idx)
  ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM user_triggers ut,
   (dummyt d1  WITH seq = value(dant_table_cnt)),
   (dummyt d2  WITH seq = value(dant_max_trigger_count))
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= dant_columns->tables[d1.seq].trigger_cnt))
   JOIN (ut
   WHERE (ut.trigger_name=dant_columns->tables[d1.seq].triggers[d2.seq].trigger_name))
  DETAIL
   dant_columns->tables[d1.seq].triggers[d2.seq].trigger_exists_ind = 1
  WITH nocounter
 ;end select
 FOR (dant_table_idx = 1 TO dant_table_cnt)
   FOR (dant_trigger_idx = 1 TO dant_columns->tables[dant_table_idx].trigger_cnt)
     IF ((dant_columns->tables[dant_table_idx].triggers[dant_trigger_idx].trigger_exists_ind=0))
      SET dant_missing_trg_count = (dant_missing_trg_count+ 1)
      IF (dant_missing_trg_count=1)
       SET dant_err_msg = dant_columns->tables[dant_table_idx].triggers[dant_trigger_idx].
       trigger_name
      ELSE
       SET dant_err_msg = concat(dant_err_msg,", ",dant_columns->tables[dant_table_idx].triggers[
        dant_trigger_idx].trigger_name)
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 IF (dant_missing_trg_count > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(build(dant_missing_trg_count)," trigger(s) missing: ",
   dant_err_msg)
  GO TO exit_script
 ENDIF
 SET dant_nls_lang = sbr_get_nls_lang(null)
 DELETE  FROM dm_info di
  WHERE di.info_domain="NLS"
   AND di.info_name="NLSSORT"
  WITH nocounter
 ;end delete
 IF (error(dant_err_msg,0) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to delete previous NLSSORT row: ",dant_err_msg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 IF (dant_ccl_revision >= 80506)
  INSERT  FROM dm_info di
   SET di.info_domain = "NLS", di.info_name = "NLSSORT", di.info_char = concat(dant_nls_lang,"_AI"),
    di.updt_cnt = 0, di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (error(dant_err_msg,0) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to create NLSSORT row: ",dant_err_msg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM user_triggers ut
  WHERE ut.trigger_name="*_NLS"
   AND ut.trigger_name != "*_ANLS"
   AND ut.status="ENABLED"
  DETAIL
   dant_nls_trigger_cnt = (dant_nls_trigger_cnt+ 1), stat = alterlist(dant_nls_triggers->triggers,
    dant_nls_trigger_cnt), dant_nls_triggers->triggers[dant_nls_trigger_cnt].trigger_name = ut
   .trigger_name
  WITH nocounter
 ;end select
 FOR (dant_trigger_idx = 1 TO dant_nls_trigger_cnt)
   SET dant_disable_stmt = concat("rdb asis(^ ALTER TRIGGER ",dant_nls_triggers->triggers[
    dant_trigger_idx].trigger_name," DISABLE ^) go")
   CALL parser(dant_disable_stmt)
   IF (error(dant_err_msg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to disable trigger '",dant_nls_triggers->triggers[
     dant_trigger_idx].trigger_name,"': ",dant_err_msg)
    GO TO exit_script
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Success: final configuration steps for *_A_NLS have completed"
#exit_script
 FREE RECORD dant_columns
 FREE RECORD dant_nls_triggers
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
