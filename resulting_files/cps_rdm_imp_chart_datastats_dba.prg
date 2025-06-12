CREATE PROGRAM cps_rdm_imp_chart_datastats:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script cps_rdm_imp_chart_datastats.prg..."
 DECLARE ierrcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE log_file = c27 WITH public, constant("cps_rdm_imp_chart_datastats.log")
 DECLARE tab_3 = c3 WITH public, constant("   ")
 DECLARE s_warning = c13 WITH public, constant("   WARNING : ")
 DECLARE s_error = c13 WITH public, constant("   ERROR   : ")
 DECLARE s_info = c13 WITH public, constant("   INFO    : ")
 DECLARE s_msg = c13 WITH public, constant("   MESSAGE : ")
 FREE RECORD err_log
 RECORD err_log(
   1 msg_qual = i4
   1 msg[*]
     2 err_msg = vc
 )
 DECLARE msg_knt = i4 WITH public, noconstant(0)
 DECLARE err_level = i2 WITH public, noconstant(0)
 DECLARE dvar = i2 WITH public, noconstant(0)
 DECLARE reqin_size = i4 WITH public, constant(size(requestin->list_0,5))
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_RDM_IMP_CHART_DATASTATS BEG : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL echo("***")
 CALL echo("***   Parse Requestin")
 CALL echo("***")
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"BEG Parsing Requestin : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 FREE RECORD treq
 RECORD treq(
   1 qual[*]
     2 chart_source_cd = f8
     2 chart_type_cd = f8
     2 chart_sex_cd = f8
     2 chart_min_age = f8
     2 chart_max_age = f8
     2 chart_y_axis_unit_cd = f8
     2 x_min_val = f8
     2 x_max_val = f8
     2 median_value = f8
     2 mean_value = f8
     2 coeffnt_var_value = f8
     2 std_dev_value = f8
     2 box_cox_power_value = f8
     2 active_ind = i2
     2 ref_datastats_id = f8
     2 chart_definition_id = f8
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET stat = alterlist(treq->qual,size(requestin->list_0,5))
 FOR (knt = 1 TO size(requestin->list_0,5))
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=255550
     AND (cv.display_key=requestin->list_0[knt].chart_source_disp_key)
     AND cv.active_ind=1
    DETAIL
     treq->qual[knt].chart_source_cd = cv.code_value
    WITH nocounter
   ;end select
   IF ( NOT ((treq->qual[knt].chart_source_cd > 0)))
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat(s_error,
     "Failed to find CHART_SOURCE_CD for DISPLAY_KEY ",trim(requestin->list_0[knt].
      chart_source_disp_key)," from CODE_SET 255550.")
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to find CHART_SOURCE_CD for DISPLAY_KEY ",trim(
      requestin->list_0[knt].chart_source_disp_key)," from CODE_SET 255550.",errmsg)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=255551
     AND (cv.cdf_meaning=requestin->list_0[knt].chart_type_meaning)
     AND cv.active_ind=1
    DETAIL
     treq->qual[knt].chart_type_cd = cv.code_value
    WITH nocounter
   ;end select
   IF ( NOT ((treq->qual[knt].chart_type_cd > 0)))
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat(s_error,"Failed to find CHART_TYPE_CD for MEANING ",
     trim(requestin->list_0[knt].chart_type_meaning)," from CODE_SET 255551.")
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to find CHART_TYPE_CD for MEANING ",trim(requestin->
      list_0[knt].chart_type_meaning)," from CODE_SET 255551.",errmsg)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=57
     AND (cv.cdf_meaning=requestin->list_0[knt].chart_sex_meaning)
     AND cv.active_ind=1
    DETAIL
     treq->qual[knt].chart_sex_cd = cv.code_value
    WITH nocounter
   ;end select
   IF ( NOT ((treq->qual[knt].chart_sex_cd > 0)))
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat(s_error,"Failed to find SEX_CD for MEANING ",trim(
      requestin->list_0[knt].chart_sex_meaning)," from CODE_SET 57.")
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to find SEX_CD for MEANING ",trim(requestin->list_0[knt
      ].chart_sex_meaning)," from CODE_SET 57.",errmsg)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=54
     AND (cv.display=requestin->list_0[knt].chart_y_axis_unit_display)
     AND cv.active_ind=1
    DETAIL
     treq->qual[knt].chart_y_axis_unit_cd = cv.code_value
    WITH nocounter
   ;end select
   IF ( NOT ((treq->qual[knt].chart_y_axis_unit_cd > 0)))
    SET msg_knt = (msg_knt+ 1)
    SET stat = alterlist(err_log->msg,msg_knt)
    SET err_log->msg[msg_knt].err_msg = concat(s_error,
     "Failed to find CHART_Y_AXIS_UNIT_CD for DISPLAY ",trim(requestin->list_0[knt].
      chart_y_axis_unit_display)," from CODE_SET 54.")
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to find CHART_Y_AXIS_UNIT_CD for DISPLAY ",trim(
      requestin->list_0[knt].chart_y_axis_unit_display)," from CODE_SET 54.",errmsg)
    GO TO exit_script
   ENDIF
   SET treq->qual[knt].chart_min_age = cnvtreal(requestin->list_0[knt].chart_min_age)
   SET treq->qual[knt].chart_max_age = cnvtreal(requestin->list_0[knt].chart_max_age)
   SET treq->qual[knt].x_min_val = cnvtreal(requestin->list_0[knt].stat_x_min_val)
   SET treq->qual[knt].x_max_val = cnvtreal(requestin->list_0[knt].stat_x_max_val)
   SET treq->qual[knt].median_value = cnvtreal(requestin->list_0[knt].stat_median_value)
   SET treq->qual[knt].mean_value = cnvtreal(requestin->list_0[knt].stat_mean_value)
   SET treq->qual[knt].coeffnt_var_value = cnvtreal(requestin->list_0[knt].stat_coeffnt_var_value)
   SET treq->qual[knt].std_dev_value = cnvtreal(requestin->list_0[knt].stat_std_dev_value)
   SET treq->qual[knt].box_cox_power_value = cnvtreal(requestin->list_0[knt].stat_box_cox_power_value
    )
   SET treq->qual[knt].active_ind = cnvtint(requestin->list_0[knt].stat_active_ind)
 ENDFOR
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_error,"Parsing Requestin")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(serrmsg))
  SET err_level = 2
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure: Parsing Requestin:",errmsg)
  GO TO exit_script
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"END Parsing Requestin : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL echo("***")
 CALL echo("***   Get Chart Definition Ids")
 CALL echo("***")
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"BEG Get Chart Definition Ids : ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(treq->qual,5))),
   chart_definition cd
  PLAN (d)
   JOIN (cd
   WHERE (cd.chart_source_cd=treq->qual[d.seq].chart_source_cd)
    AND (cd.chart_type_cd=treq->qual[d.seq].chart_type_cd)
    AND (cd.sex_cd=treq->qual[d.seq].chart_sex_cd)
    AND (cd.min_age=treq->qual[d.seq].chart_min_age)
    AND (cd.max_age=treq->qual[d.seq].chart_max_age)
    AND (cd.y_axis_unit_cd=treq->qual[d.seq].chart_y_axis_unit_cd))
  HEAD REPORT
   knt = 0
  DETAIL
   knt = (knt+ 1), treq->qual[knt].chart_definition_id = cd.chart_definition_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_error,"Getting CHART_DEFINITION_ID")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(serrmsg))
  SET err_level = 2
  FREE RECORD treq
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure getting CHART_DEFINITION_ID:",errmsg)
  GO TO exit_script
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"END Get Chart Definition Ids : ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 IF (knt < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_warning,"No Chart Definitions Found")
  SET readme_data->status = "F"
  SET readme_data->message = concat("No Chart Definitions Found",errmsg)
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Ensure REF_DATASTATS")
 CALL echo("***")
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"BEG RDM Ensure REF_DATASTATS : ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 EXECUTE cps_rdm_ens_ref_datastats
 IF ((readme_data->status="F"))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_error,"Executing CPS_ENS_REF_DATASTATS")
  SET err_level = 2
  FREE RECORD treq
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure executing CPS_RDM_ENS_REF_DATASTATS:",errmsg)
  GO TO exit_script
 ENDIF
 FREE RECORD treq
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"END RDM Ensure REF_DATASTATS : ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (err_level=2)
  CALL echo("***")
  CALL echo(concat("***   CPS_RDM_IMP_CHART_DATASTATS>> FAILURE: Examine the ",
    "ccluserdir:cps_rdm_imp_chart_datastats.log file to learn more."))
  CALL echo("***")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_RDM_IMP_CHART_DATASTATS END : <FAILURE> ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  ROLLBACK
 ELSEIF (err_level=1)
  CALL echo("***")
  CALL echo(concat("***   CPS_RDM_IMP_CHART_DATASTATS>> WARNING: Examine the ",
    "ccluserdir:cps_rdm_imp_chart_datastats.log file to learn more."))
  CALL echo("***")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_RDM_IMP_CHART_DATASTATS END : <WARNING> ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  ROLLBACK
 ELSE
  CALL echo("***")
  CALL echo(concat("***   CPS_RDM_IMP_CHART_DATASTATS>> SUCCESS: Examine the ",
    "ccluserdir:cps_rdm_imp_chart_datastats.log file to learn more."))
  CALL echo("***")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_RDM_IMP_CHART_DATASTATS END : <SUCCESS> ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "Success: cps_rdm_imp_chart_datastats finished successfully"
 ENDIF
 CALL error_logging(dvar)
 FREE RECORD err_log
 GO TO end_program
 SUBROUTINE error_logging(lvar)
   CALL echo("***")
   CALL echo("***   ERROR_LOGGING")
   CALL echo("***")
   SET err_log->msg_qual = msg_knt
   SELECT INTO value(log_file)
    out_string = substring(1,132,err_log->msg[d.seq].err_msg)
    FROM (dummyt d  WITH seq = value(err_log->msg_qual))
    PLAN (d)
    DETAIL
     row + 1, col 0, out_string
    WITH nocounter, append, format = variable,
     noformfeed, maxrow = value((msg_knt+ 1)), maxcol = 150
   ;end select
 END ;Subroutine
#end_program
 SET cps_script_version = "000 12/18/08 JD5581"
END GO
