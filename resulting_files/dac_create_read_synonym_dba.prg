CREATE PROGRAM dac_create_read_synonym:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dac_create_read_synonym..."
 DECLARE dcrs_errmsg = vc WITH protect, noconstant("")
 IF (sbr_check_for_a_nls(null)=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success: This environment does not use _A_NLS functionality."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM user_objects uo
  WHERE uo.object_name="CERN_NLS_SORT_PATMATCH"
   AND uo.object_type="FUNCTION"
  WITH nocounter
 ;end select
 IF (error(dcrs_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to look up CERN_NLS_SORT_PATMATCH: ",dcrs_errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message = "CERN_NLS_SORT_PATMATCH function does not exist"
  GO TO exit_script
 ENDIF
 CALL parser(
  "rdb asis(^ create or replace public synonym CERN_NLS_SORT_PATMATCH for V500.CERN_NLS_SORT_PATMATCH ^) go"
  )
 IF (error(dcrs_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to create synonym: ",dcrs_errmsg)
  GO TO exit_script
 ENDIF
 CALL parser("rdb asis(^ GRANT EXECUTE ON CERN_NLS_SORT_PATMATCH TO PUBLIC ^) go")
 IF (error(dcrs_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to grant privileges on 'CERN_NLS_SORT_PATMATCH' to PUBLIC: ",dcrs_errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
