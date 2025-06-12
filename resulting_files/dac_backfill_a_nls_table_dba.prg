CREATE PROGRAM dac_backfill_a_nls_table:dba
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
 SET readme_data->message = "Readme failed: starting script dac_backfill_a_nls_table..."
 DECLARE dbant_errmsg = vc WITH protect, noconstant("")
 IF (sbr_check_for_a_nls(null)=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-successed; this is not an _A_NLS domain."
  GO TO exit_script
 ENDIF
 IF (sbr_get_ora_major_version(null) < 10)
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success; this readme does not run on Oracle prior to version 10"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM user_objects uo
  WHERE uo.object_name="CERN_NLS_SORT"
   AND uo.object_type="FUNCTION"
  WITH nocounter
 ;end select
 IF (error(dbant_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for CERN_NLS_SORT: ",dbant_errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message =
  "Auto-success; the backfill will be taken care of later as part of a mass backfill"
  GO TO exit_script
 ENDIF
 DECLARE dbant_tablename = vc WITH protect, noconstant("")
 DECLARE dbant_donlsbackfillind = i2 WITH protect, noconstant(0)
 SET dbant_tablename = cnvtupper(trim(backfill_request->table_name,3))
 SET dbant_donlsbackfillind = backfill_request->do_nls_backfill_ind
 IF (dbant_donlsbackfillind=1)
  EXECUTE dac_create_nls_trigger value(dbant_tablename)
  IF ((readme_data->status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 EXECUTE dac_create_a_nls_triggers value(dbant_tablename)
 IF ((readme_data->status != "S"))
  GO TO exit_script
 ENDIF
 EXECUTE dac_execute_nls_backfill
 IF ((readme_data->status != "S"))
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = concat("Success: table '",dbant_tablename,"' has been backfilled")
#exit_script
END GO
