CREATE PROGRAM dac_create_nls_trigger:dba
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
 FREE RECORD dm_sql_reply
 RECORD dm_sql_reply(
   1 status = c1
   1 msg = vc
 )
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
 SET readme_data->message = "Readme failed: starting script dac_create_nls_trigger..."
 IF (sbr_check_for_a_nls(null)=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success; this environment does not use _A_NLS functionality."
  GO TO exit_script
 ENDIF
 FREE RECORD dcnt_columns
 RECORD dcnt_columns(
   1 columns[*]
     2 column_name = vc
     2 column_length = i4
   1 nls_columns[*]
     2 base_column_name = vc
     2 nls_column_name = vc
     2 nls_column_length = i4
 )
 DECLARE dcnt_tablename = vc WITH protect, noconstant("")
 DECLARE dcnt_columncount = i4 WITH protect, noconstant(0)
 DECLARE dcnt_nlscolumncount = i4 WITH protect, noconstant(0)
 DECLARE dcnt_columnidx = i4 WITH protect, noconstant(0)
 DECLARE dcnt_nlscolumnname = vc WITH protect, noconstant("")
 DECLARE dcnt_triggername = vc WITH protect, noconstant("")
 DECLARE dcnt_createtriggerstmt = vc WITH protect, noconstant("")
 DECLARE dcnt_errmsg = vc WITH protect, noconstant("")
 DECLARE dcnt_loop = i4 WITH protect, noconstant(0)
 DECLARE dcnt_lvalidx = i4 WITH protect, noconstant(0)
 SET dcnt_tablename = cnvtupper(trim( $1,3))
 SELECT INTO "nl:"
  FROM user_tab_columns utc
  WHERE utc.table_name=dcnt_tablename
  DETAIL
   dcnt_columncount = (dcnt_columncount+ 1)
   IF (mod(dcnt_columncount,10)=1)
    stat = alterlist(dcnt_columns->columns,(dcnt_columncount+ 9))
   ENDIF
   dcnt_columns->columns[dcnt_columncount].column_name = utc.column_name, dcnt_columns->columns[
   dcnt_columncount].column_length = utc.data_length
  FOOT REPORT
   stat = alterlist(dcnt_columns->columns,dcnt_columncount)
  WITH nocounter
 ;end select
 IF (error(dcnt_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to find columns for table '",dcnt_tablename,"': ",
   dcnt_errmsg)
  GO TO exit_script
 ELSEIF (dcnt_columncount=0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("No columns found for table '",dcnt_tablename,"'")
  GO TO exit_script
 ENDIF
 FOR (dcnt_loop = 1 TO dcnt_columncount)
   IF ((dcnt_columns->columns[dcnt_loop].column_name != patstring("*_NLS")))
    SET dcnt_nlscolumnname = concat(dcnt_columns->columns[dcnt_loop].column_name,"_NLS")
    SET dcnt_columnidx = locateval(dcnt_lvalidx,1,dcnt_columncount,dcnt_nlscolumnname,dcnt_columns->
     columns[dcnt_lvalidx].column_name)
    IF (dcnt_columnidx > 0)
     SET dcnt_nlscolumncount = (dcnt_nlscolumncount+ 1)
     SET stat = alterlist(dcnt_columns->nls_columns,dcnt_nlscolumncount)
     SET dcnt_columns->nls_columns[dcnt_nlscolumncount].base_column_name = dcnt_columns->columns[
     dcnt_loop].column_name
     SET dcnt_columns->nls_columns[dcnt_nlscolumncount].nls_column_name = dcnt_nlscolumnname
     SET dcnt_columns->nls_columns[dcnt_nlscolumncount].nls_column_length = dcnt_columns->columns[
     dcnt_columnidx].column_length
    ENDIF
   ENDIF
 ENDFOR
 IF (error(dcnt_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed in matching of _NLS column names: ",dcnt_errmsg)
  GO TO exit_script
 ENDIF
 IF (dcnt_nlscolumncount=0)
  SET readme_data->status = "F"
  SET readme_data->message = "No NLS columns matched"
  GO TO exit_script
 ENDIF
 SET dcnt_triggername = build("TRG_",dcnt_tablename,"_NLS")
 SET dcnt_createtriggerstmt = concat("CREATE OR REPLACE TRIGGER ",dcnt_triggername,char(10),
  "BEFORE INSERT OR UPDATE OF ",dcnt_columns->nls_columns[1].base_column_name)
 FOR (dcnt_loop = 2 TO dcnt_nlscolumncount)
   SET dcnt_createtriggerstmt = concat(dcnt_createtriggerstmt,", ",dcnt_columns->nls_columns[
    dcnt_loop].base_column_name)
 ENDFOR
 SET dcnt_createtriggerstmt = concat(dcnt_createtriggerstmt,char(10)," ON ",dcnt_tablename,char(10),
  "FOR EACH ROW ",char(10),"BEGIN ",char(10),"  :new.",
  dcnt_columns->nls_columns[1].nls_column_name," := rtrim(substr(NLSSORT(:new.",dcnt_columns->
  nls_columns[1].base_column_name,"), 1, ",build(dcnt_columns->nls_columns[1].nls_column_length),
  "));",char(10))
 FOR (dcnt_loop = 2 TO dcnt_nlscolumncount)
   SET dcnt_createtriggerstmt = concat(dcnt_createtriggerstmt,"  :new.",dcnt_columns->nls_columns[
    dcnt_loop].nls_column_name," := rtrim(substr(NLSSORT(:new.",dcnt_columns->nls_columns[dcnt_loop].
    base_column_name,
    "), 1, ",build(dcnt_columns->nls_columns[dcnt_loop].nls_column_length),"));",char(10))
 ENDFOR
 SET dcnt_createtriggerstmt = concat("rdb asis(^ ",dcnt_createtriggerstmt,"end; ^) go")
 CALL parser(dcnt_createtriggerstmt)
 IF (error(dcnt_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to create NLS trigger for table '",dcnt_tablename,"': ",
   dcnt_errmsg)
  GO TO exit_script
 ENDIF
 EXECUTE dm_readme_include_sql_chk value(dcnt_triggername), "TRIGGER"
 IF ((dm_sql_reply->status="F"))
  SET readme_data->status = "F"
  SET readme_data->message = dm_sql_reply->msg
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = concat("NLS trigger created for table '",dcnt_tablename,"'")
#exit_script
 FREE RECORD dcnt_columns
END GO
