CREATE PROGRAM dac_execute_nls_backfill:dba
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
 IF (validate(backfill_request->table_name,"Z")="Z")
  RECORD backfill_request(
    1 table_name = vc
    1 do_nls_backfill_ind = i2
    1 columns[*]
      2 column_name = vc
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dac_execute_nls_backfill..."
 IF (sbr_check_for_a_nls(null)=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-successed; this is not an _A_NLS domain."
  GO TO exit_script
 ENDIF
 FREE RECORD denb_columns
 RECORD denb_columns(
   1 columns[*]
     2 base_column_name = vc
     2 nls_column_name = vc
     2 a_nls_column_name = vc
     2 nls_column_length = i4
     2 a_nls_column_length = i4
     2 base_column_default_value = vc
     2 a_nls_default_value = vc
 )
 FREE RECORD denb_executerequest
 RECORD denb_executerequest(
   1 table_name = vc
   1 update_stmt = vc
 )
 FREE RECORD denb_executereply
 RECORD denb_executereply(
   1 update_count = i4
 )
 FREE RECORD denb_pkcolumns
 RECORD denb_pkcolumns(
   1 columns[*]
     2 column_name = vc
 )
 DECLARE denb_tablename = vc WITH protect, noconstant("")
 DECLARE denb_columncount = i4 WITH protect, noconstant(0)
 DECLARE denb_anlscolcount = i4 WITH protect, noconstant(0)
 DECLARE denb_donlsbackfillind = i2 WITH protect, noconstant(0)
 DECLARE denb_updatequery = vc WITH protect, noconstant("")
 DECLARE denb_updatesetclause = vc WITH protect, noconstant(" ")
 DECLARE denb_updatewhereclause = vc WITH protect, noconstant(" ")
 DECLARE denb_subwhereclause = vc WITH protect, noconstant("")
 DECLARE denb_haspreviouscolumnind = i2 WITH protect, noconstant(0)
 DECLARE denb_nlslang = vc WITH protect, constant(sbr_get_nls_lang(null))
 DECLARE denb_basecolumnname = vc WITH protect, noconstant("")
 DECLARE denb_currentcolumnname = vc WITH protect, noconstant("")
 DECLARE denb_columnindex = i4 WITH protect, noconstant(0)
 DECLARE denb_pkcolumncount = i4 WITH protect, noconstant(0)
 DECLARE denb_batchsize = i4 WITH protect, constant(50000)
 DECLARE denb_hasdefaultrowind = i2 WITH protect, noconstant(0)
 DECLARE denb_pkindexname = vc WITH protect, noconstant("")
 DECLARE denb_pkcolumnwhere = vc WITH protect, noconstant(" ")
 DECLARE denb_pkqualify = vc WITH protect, noconstant("")
 DECLARE denb_errmsg = vc WITH protect, noconstant("")
 DECLARE denb_loop = i4 WITH protect, noconstant(0)
 DECLARE denb_lvalidx = i4 WITH protect, noconstant(0)
 SET denb_tablename = cnvtupper(trim(backfill_request->table_name,3))
 SET denb_donlsbackfillind = backfill_request->do_nls_backfill_ind
 SELECT INTO "nl:"
  FROM user_objects uo
  WHERE uo.object_name="CERN_NLS_SORT"
   AND uo.object_type="FUNCTION"
  WITH nocounter
 ;end select
 IF (error(denb_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for CERN_NLS_SORT: ",denb_errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message = "The CERN_NLS_SORT function does not exist in the database."
  GO TO exit_script
 ENDIF
 IF (size(backfill_request->columns,5) > 0)
  SET denb_columncount = size(backfill_request->columns,5)
  SELECT INTO "nl:"
   FROM user_tab_columns utc,
    (dummyt d  WITH seq = value(denb_columncount))
   PLAN (d)
    JOIN (utc
    WHERE utc.table_name=denb_tablename
     AND utc.column_name=cnvtupper(backfill_request->columns[d.seq].column_name))
   HEAD REPORT
    columncnt = 0
   DETAIL
    columncnt = (columncnt+ 1), stat = alterlist(denb_columns->columns,columncnt), denb_columns->
    columns[columncnt].base_column_name = utc.column_name
    IF (utc.data_default > " "
     AND utc.data_default != "NULL"
     AND isnumeric(utc.data_default)=0)
     denb_columns->columns[columncnt].base_column_default_value = utc.data_default
    ELSE
     denb_columns->columns[columncnt].base_column_default_value = "NULL"
    ENDIF
   WITH nocounter
  ;end select
  IF (error(denb_errmsg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed in look-up of columns: ",denb_errmsg)
   GO TO exit_script
  ENDIF
  IF (size(denb_columns->columns,5) != denb_columncount)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Unable to find all columns; ",build(size(denb_columns->columns,
      5))," != ",build(denb_columncount))
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM user_tab_columns utc,
    (dummyt d  WITH seq = value(denb_columncount))
   PLAN (d)
    JOIN (utc
    WHERE utc.table_name=denb_tablename
     AND ((utc.column_name=concat(denb_columns->columns[d.seq].base_column_name,"_NLS")
     AND 1=denb_donlsbackfillind) OR (utc.column_name=concat(denb_columns->columns[d.seq].
     base_column_name,"_A_NLS"))) )
   DETAIL
    IF (utc.column_name=patstring("*_A_NLS"))
     denb_columns->columns[d.seq].a_nls_column_name = utc.column_name, denb_columns->columns[d.seq].
     a_nls_column_length = utc.data_length, denb_anlscolcount = (denb_anlscolcount+ 1)
     IF (utc.data_default > " "
      AND utc.data_default != "NULL")
      denb_columns->columns[d.seq].a_nls_default_value = utc.data_default
     ELSE
      denb_columns->columns[d.seq].a_nls_default_value = "NULL"
     ENDIF
    ELSEIF (utc.column_name=patstring("*_NLS")
     AND denb_donlsbackfillind=1)
     denb_columns->columns[d.seq].nls_column_name = utc.column_name, denb_columns->columns[d.seq].
     nls_column_length = utc.data_length
    ENDIF
   WITH nocounter
  ;end select
  IF (error(denb_errmsg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed in look-up of _NLS/_A_NLS columns: ",denb_errmsg)
   GO TO exit_script
  ENDIF
  IF (denb_anlscolcount != denb_columncount)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Not all _A_NLS columns found on table '",denb_tablename,
    "' for specified columns: ",build(denb_anlscolcount)," != ",
    build(denb_columncount))
   GO TO exit_script
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM user_tab_columns utc
   WHERE utc.table_name=denb_tablename
    AND utc.column_name=patstring("*_NLS")
   DETAIL
    IF (utc.column_name=patstring("*_A_NLS"))
     denb_currentcolumnname = utc.column_name, denb_basecolumnname = substring(1,(textlen(
       denb_currentcolumnname) - 6),utc.column_name), denb_columnindex = locateval(denb_lvalidx,1,
      denb_columncount,denb_basecolumnname,denb_columns->columns[denb_lvalidx].base_column_name)
     IF (denb_columnindex=0)
      denb_columncount = (denb_columncount+ 1), stat = alterlist(denb_columns->columns,
       denb_columncount), denb_columnindex = denb_columncount
     ENDIF
     denb_columns->columns[denb_columnindex].a_nls_column_name = denb_currentcolumnname, denb_columns
     ->columns[denb_columnindex].a_nls_column_length = utc.data_length, denb_columns->columns[
     denb_columnindex].base_column_name = denb_basecolumnname
     IF (utc.data_default > " "
      AND utc.data_default != "NULL")
      denb_columns->columns[denb_columnindex].a_nls_default_value = utc.data_default
     ELSE
      denb_columns->columns[denb_columnindex].a_nls_default_value = "NULL"
     ENDIF
    ELSEIF (utc.column_name=patstring("*_NLS")
     AND denb_donlsbackfillind=1)
     denb_currentcolumnname = utc.column_name, denb_basecolumnname = substring(1,(textlen(
       denb_currentcolumnname) - 4),utc.column_name), denb_columnindex = locateval(denb_lvalidx,1,
      denb_columncount,denb_basecolumnname,denb_columns->columns[denb_lvalidx].base_column_name)
     IF (denb_columnindex=0)
      denb_columncount = (denb_columncount+ 1), stat = alterlist(denb_columns->columns,
       denb_columncount), denb_columnindex = denb_columncount
     ENDIF
     denb_columns->columns[denb_columnindex].nls_column_name = denb_currentcolumnname, denb_columns->
     columns[denb_columnindex].nls_column_length = utc.data_length, denb_columns->columns[
     denb_columnindex].base_column_name = denb_basecolumnname
    ENDIF
   WITH nocounter
  ;end select
  IF (error(denb_errmsg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed in dynamic build of _NLS/_A_NLS columns: ",denb_errmsg)
   GO TO exit_script
  ELSEIF (denb_columncount=0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("No qualifying columns found on table '",denb_tablename,"'")
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM user_tab_columns utc,
    (dummyt d  WITH seq = value(denb_columncount))
   PLAN (d)
    JOIN (utc
    WHERE utc.table_name=denb_tablename
     AND (utc.column_name=denb_columns->columns[d.seq].base_column_name))
   DETAIL
    IF (utc.data_default > " "
     AND utc.data_default != "NULL"
     AND isnumeric(utc.data_default)=0)
     denb_columns->columns[d.seq].base_column_default_value = utc.data_default
    ELSE
     denb_columns->columns[d.seq].base_column_default_value = "NULL"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FOR (denb_loop = 1 TO denb_columncount)
  IF ((denb_columns->columns[denb_loop].a_nls_column_length > 0))
   IF (denb_haspreviouscolumnind=1)
    SET denb_updatesetclause = concat(denb_updatesetclause,",")
    SET denb_updatewhereclause = concat(denb_updatewhereclause," OR")
   ENDIF
   SET denb_updatesetclause = concat(denb_updatesetclause,denb_columns->columns[denb_loop].
    a_nls_column_name," = ","substr(nvl(cern_nls_sort(",denb_columns->columns[denb_loop].
    base_column_name,
    ", 'NLS_SORT=",denb_nlslang,"_AI'), ' '), 1, ",build(denb_columns->columns[denb_loop].
     a_nls_column_length),")")
   SET denb_subwhereclause = denb_columns->columns[denb_loop].a_nls_column_name
   IF ((denb_columns->columns[denb_loop].a_nls_default_value="NULL"))
    SET denb_subwhereclause = concat(denb_subwhereclause," IS NULL")
   ELSE
    SET denb_subwhereclause = concat(denb_subwhereclause," = ",denb_columns->columns[denb_loop].
     a_nls_default_value)
   ENDIF
   IF ((denb_columns->columns[denb_loop].base_column_default_value="NULL"))
    SET denb_subwhereclause = concat(denb_subwhereclause," AND ",denb_columns->columns[denb_loop].
     base_column_name," IS NOT NULL")
   ELSE
    SET denb_subwhereclause = concat(denb_subwhereclause," AND ",denb_columns->columns[denb_loop].
     base_column_name," != ",denb_columns->columns[denb_loop].base_column_default_value)
   ENDIF
   SET denb_updatewhereclause = concat(denb_updatewhereclause," (",denb_subwhereclause,")")
   SET denb_haspreviouscolumnind = 1
  ENDIF
  IF ((denb_columns->columns[denb_loop].nls_column_length > 0))
   IF (denb_haspreviouscolumnind=1)
    SET denb_updatesetclause = concat(denb_updatesetclause,",")
   ENDIF
   SET denb_updatesetclause = concat(denb_updatesetclause,denb_columns->columns[denb_loop].
    nls_column_name," = ","nvl(substr(nlssort(",denb_columns->columns[denb_loop].base_column_name,
    "), 1, ",build(denb_columns->columns[denb_loop].nls_column_length),"), ' ')")
   SET denb_updatewhereclause = concat(denb_updatewhereclause,evaluate(denb_haspreviouscolumnind,1,
     concat(" OR ",denb_columns->columns[denb_loop].nls_column_name," IS NULL"),concat(denb_columns->
      columns[denb_loop].nls_column_name," IS NULL")))
   SET denb_haspreviouscolumnind = 1
  ENDIF
 ENDFOR
 IF (error(denb_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to build update query: ",denb_errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_tables_doc dtd
  WHERE dtd.table_name=denb_tablename
  DETAIL
   denb_hasdefaultrowind = dtd.default_row_ind
  WITH nocounter
 ;end select
 IF (error(denb_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for default row indicator: ",denb_errmsg)
  GO TO exit_script
 ENDIF
 SET denb_updatequery = concat("UPDATE ",denb_tablename," SET ",denb_updatesetclause," WHERE (",
  denb_updatewhereclause,")")
 IF (denb_hasdefaultrowind=1)
  SELECT INTO "nl:"
   FROM user_constraints uc
   WHERE uc.table_name=denb_tablename
    AND uc.constraint_type="P"
   DETAIL
    denb_pkindexname = uc.constraint_name
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM user_ind_columns uic
   WHERE uic.index_name=denb_pkindexname
    AND uic.table_name=denb_tablename
   ORDER BY uic.column_position
   DETAIL
    denb_pkcolumncount = (denb_pkcolumncount+ 1), stat = alterlist(denb_pkcolumns->columns,
     denb_pkcolumncount), denb_pkcolumns->columns[denb_pkcolumncount].column_name = uic.column_name
   WITH nocounter
  ;end select
  IF (error(denb_errmsg,0) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to look up PK columns: ",denb_errmsg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   null_yes = nullind(utc.data_default)
   FROM user_tab_columns utc,
    (dummyt d  WITH seq = value(denb_pkcolumncount))
   PLAN (d)
    JOIN (utc
    WHERE utc.table_name=denb_tablename
     AND (utc.column_name=denb_pkcolumns->columns[d.seq].column_name))
   DETAIL
    IF (d.seq > 1)
     denb_pkcolumnwhere = concat(denb_pkcolumnwhere," AND")
    ENDIF
    IF (null_yes=1)
     denb_pkqualify = "IS NOT NULL"
    ELSE
     denb_pkqualify = concat("!= ",utc.data_default)
    ENDIF
    IF (utc.data_type IN ("FLOAT", "NUMBER"))
     denb_pkcolumnwhere = concat(denb_pkcolumnwhere," ",denb_pkcolumns->columns[d.seq].column_name,
      " + 0 ",denb_pkqualify)
    ELSEIF (utc.data_type IN ("VARCHAR2", "CHAR"))
     denb_pkcolumnwhere = concat(denb_pkcolumnwhere," TRIM(",denb_pkcolumns->columns[d.seq].
      column_name,") ",denb_pkqualify)
    ENDIF
   WITH nocounter
  ;end select
  SET denb_updatequery = concat(denb_updatequery," AND (",denb_pkcolumnwhere,")")
 ENDIF
 SET denb_updatequery = concat(denb_updatequery," AND rownum <= ",build(denb_batchsize))
 SET denb_executerequest->table_name = denb_tablename
 SET denb_executerequest->update_stmt = denb_updatequery
 SET denb_executereply->update_count = denb_batchsize
 WHILE ((denb_executereply->update_count >= denb_batchsize))
  EXECUTE dac_execute_backfill  WITH replace("REQUEST","DENB_EXECUTEREQUEST"), replace("REPLY",
   "DENB_EXECUTEREPLY")
  IF ((readme_data->status != "S"))
   GO TO exit_script
  ENDIF
 ENDWHILE
 SET readme_data->status = "S"
 SET readme_data->message = concat("Success: table '",denb_tablename,"' has been backfilled")
#exit_script
 FREE RECORD denb_executerequest
 FREE RECORD denb_executereply
 FREE RECORD denb_columns
 FREE RECORD denb_pkcolumns
END GO
