CREATE PROGRAM dac_backfill_a_nls_columns:dba
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
 IF (validate(backfill_request->table_name,"Z")="Z")
  RECORD backfill_request(
    1 table_name = vc
    1 do_nls_backfill_ind = i2
    1 columns[*]
      2 column_name = vc
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script dac_backfill_a_nls_columns..."
 IF (sbr_get_ora_major_version(null) < 10)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Auto-successing; this readme does not run on Oracle prior to version 10"
  GO TO exit_script
 ENDIF
 DECLARE dbanc_table_cnt = i4 WITH protect, noconstant(0)
 DECLARE dbanc_err_msg = vc WITH protect, noconstant("")
 DECLARE dbanc_loop = i4 WITH protect, noconstant(0)
 IF (sbr_check_for_a_nls(null)=0)
  SET readme_data->status = "S"
  SET readme_data->message = "This is not an NLS domain; auto-successing"
  GO TO exit_script
 ENDIF
 FREE RECORD dbanc_tables
 RECORD dbanc_tables(
   1 tables[*]
     2 table_name = vc
 )
 SELECT DISTINCT INTO "nl:"
  utc.table_name
  FROM user_tab_columns utc
  WHERE utc.column_name="*_A_NLS"
   AND findstring("$",utc.table_name)=0
  HEAD REPORT
   suffix_pos = 0
  DETAIL
   dbanc_table_cnt = (dbanc_table_cnt+ 1)
   IF (mod(dbanc_table_cnt,50)=1)
    stat = alterlist(dbanc_tables->tables,(dbanc_table_cnt+ 49))
   ENDIF
   dbanc_tables->tables[dbanc_table_cnt].table_name = utc.table_name
  FOOT REPORT
   stat = alterlist(dbanc_tables->tables,dbanc_table_cnt)
  WITH nocounter
 ;end select
 IF (error(dbanc_err_msg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to build list of tables: ",dbanc_err_msg)
  GO TO exit_script
 ENDIF
 SET dbanc_table_cnt = size(dbanc_tables->tables,5)
 IF (dbanc_table_cnt=0)
  SET readme_data->status = "S"
  SET readme_data->message = concat("No *_A_NLS columns; auto-successing")
  GO TO exit_script
 ENDIF
 FOR (dbanc_loop = 1 TO dbanc_table_cnt)
  SELECT INTO "nl:"
   FROM user_tables ut
   WHERE (ut.table_name=dbanc_tables->tables[dbanc_loop].table_name)
   WITH nocounter
  ;end select
  IF (error(dbanc_err_msg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to check USER_TABLES for '",dbanc_tables->tables[
    dbanc_loop].table_name,"':",dbanc_err_msg)
   GO TO exit_script
  ELSEIF (curqual > 0)
   SET backfill_request->table_name = dbanc_tables->tables[dbanc_loop].table_name
   EXECUTE dac_execute_nls_backfill
   IF ((readme_data->status != "S"))
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Success: *_A_NLS columns have all been backfilled"
#exit_script
 FREE RECORD dbanc_tables
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
