CREATE PROGRAM dac_pi_anls_backfill:dba
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
 DECLARE sbr_check_for_a_nls(null) = i2
 DECLARE sbr_get_nls_lang(null) = vc
 SUBROUTINE sbr_check_for_a_nls(null)
   DECLARE dcfan_nls_lang_log = vc WITH protect, noconstant(trim(cnvtupper(logical("LANG")),3))
   IF (dcfan_nls_lang_log != "EN_US"
    AND textlen(dcfan_nls_lang_log) > 0)
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM v$nls_parameters v
    WHERE ((v.parameter="NLS_LANGUAGE"
     AND value != "AMERICAN") OR (v.parameter="NLS_SORT"
     AND  NOT (v.value IN ("AMERICAN", "BINARY"))))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE sbr_get_nls_lang(null)
   DECLARE dcfan_nls_lang = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM v$nls_parameters v
    WHERE v.parameter="NLS_LANGUAGE"
    DETAIL
     dcfan_nls_lang = trim(v.value,3)
    WITH nocounter
   ;end select
   RETURN(dcfan_nls_lang)
 END ;Subroutine
 IF (validate(backfill_request->table_name,"Z")="Z")
  RECORD backfill_request(
    1 table_name = vc
    1 do_nls_backfill_ind = i2
    1 columns[*]
      2 column_name = vc
  )
 ENDIF
 FREE RECORD dpab_table
 RECORD dpab_table(
   1 tables[8]
     2 name = vc
 )
 DECLARE dpab_errmsg = vc WITH protect, noconstant("")
 DECLARE dpab_loop = i4 WITH protect, noconstant(0)
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dac_pi_anls_backfill..."
 IF (sbr_check_for_a_nls(null)=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success; this environment does not use _A_NLS functionality."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM user_objects uo
  WHERE uo.object_name="CERN_NLS_SORT"
   AND uo.object_type="FUNCTION"
  WITH nocounter
 ;end select
 IF (error(dpab_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to look up CERN_NLS_SORT: ",dpab_errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success; the backfill will be taken care of by the main script"
  GO TO exit_script
 ENDIF
 SET dpab_table->tables[1].name = "WH_CLN_PERSON"
 SET dpab_table->tables[2].name = "WH_CLN_PERSONNEL_REF"
 SET dpab_table->tables[3].name = "WH_CLN_REQUESTER_REF"
 SET dpab_table->tables[4].name = "WH_CLN_SCH_DEF_SCHED_REF"
 SET dpab_table->tables[5].name = "WH_ERR_PERSON"
 SET dpab_table->tables[6].name = "WH_ERR_PERSONNEL_REF"
 SET dpab_table->tables[7].name = "WH_ERR_REQUESTER_REF"
 SET dpab_table->tables[8].name = "WH_ERR_SCH_DEF_SCHED_REF"
 FOR (dpab_loop = 1 TO size(dpab_table->tables))
   SET backfill_request->table_name = cnvtupper(dpab_table->tables[dpab_loop].name)
   EXECUTE dac_backfill_a_nls_table
   IF ((readme_data->status="F"))
    GO TO exit_script
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "All tables were backfilled"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
