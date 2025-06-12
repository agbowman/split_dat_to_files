CREATE PROGRAM cps_imp_chart_datastats:dba
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
 DECLARE log_file = c27 WITH public, constant("cps_imp_chart_datastats.log")
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
 SET err_log->msg[msg_knt].err_msg = concat("CPS_IMP_CHART_DATASTATS BEG : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL echo("***")
 CALL echo("***   Verify Requestin Valid")
 CALL echo("***")
 IF (reqin_size < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_warning,"No data passed in request")
  SET err_level = 1
  GO TO exit_script
 ENDIF
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
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  chart_ord = build(trim(requestin->list_0[d.seq].chart_source_disp_key),trim(requestin->list_0[d.seq
    ].chart_type_meaning),trim(requestin->list_0[d.seq].chart_sex_meaning),trim(requestin->list_0[d
    .seq].chart_min_age),trim(requestin->list_0[d.seq].chart_max_age),
   trim(requestin->list_0[d.seq].chart_y_axis_unit_display)), x_min_val = cnvtreal(requestin->list_0[
   d.seq].stat_x_min_val), x_max_val = cnvtreal(requestin->list_0[d.seq].stat_x_max_val)
  FROM (dummyt d  WITH seq = value(reqin_size))
  PLAN (d
   WHERE d.seq > 0)
  ORDER BY chart_ord, x_min_val, x_max_val
  HEAD REPORT
   knt = 0, stat = alterlist(treq->qual,1000)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,1000)=1
    AND knt != 1)
    stat = alterlist(treq->qual,(knt+ 9))
   ENDIF
   treq->qual[knt].chart_source_cd = uar_get_code_by("DISPLAYKEY",255550,nullterm(requestin->list_0[d
     .seq].chart_source_disp_key))
   IF ( NOT ((treq->qual[knt].chart_source_cd > 0)))
    msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
    concat(s_error,"Failed to find CHART_SOURCE_CD for DISPLAY_KEY ",trim(requestin->list_0[d.seq].
      chart_source_disp_key)," from CODE_SET 255550."),
    err_level = 2,
    CALL cancel(1)
   ENDIF
   treq->qual[knt].chart_type_cd = uar_get_code_by("MEANING",255551,nullterm(requestin->list_0[d.seq]
     .chart_type_meaning))
   IF ( NOT ((treq->qual[knt].chart_type_cd > 0)))
    msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
    concat(s_error,"Failed to find CHART_TYPE_CD for MEANING ",trim(requestin->list_0[d.seq].
      chart_type_meaning)," from CODE_SET 255551."),
    err_level = 2,
    CALL cancel(1)
   ENDIF
   treq->qual[knt].chart_sex_cd = uar_get_code_by("MEANING",57,nullterm(requestin->list_0[d.seq].
     chart_sex_meaning))
   IF ( NOT ((treq->qual[knt].chart_sex_cd > 0)))
    msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
    concat(s_error,"Failed to find SEX_CD for MEANING ",trim(requestin->list_0[d.seq].
      chart_sex_meaning)," from CODE_SET 57."),
    err_level = 2,
    CALL cancel(1)
   ENDIF
   treq->qual[knt].chart_y_axis_unit_cd = uar_get_code_by("DISPLAY",54,nullterm(requestin->list_0[d
     .seq].chart_y_axis_unit_display))
   IF ( NOT ((treq->qual[knt].chart_y_axis_unit_cd > 0)))
    msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
    concat(s_error,"Failed to find CHART_Y_AXIS_UNIT_CD for DISPLAY ",trim(requestin->list_0[d.seq].
      chart_y_axis_unit_display)," from CODE_SET 54."),
    err_level = 2,
    CALL cancel(1)
   ENDIF
   treq->qual[knt].chart_min_age = cnvtreal(requestin->list_0[d.seq].chart_min_age), treq->qual[knt].
   chart_max_age = cnvtreal(requestin->list_0[d.seq].chart_max_age), treq->qual[knt].x_min_val =
   x_min_val,
   treq->qual[knt].x_max_val = x_max_val, treq->qual[knt].median_value = cnvtreal(requestin->list_0[d
    .seq].stat_median_value), treq->qual[knt].mean_value = cnvtreal(requestin->list_0[d.seq].
    stat_mean_value),
   treq->qual[knt].coeffnt_var_value = cnvtreal(requestin->list_0[d.seq].stat_coeffnt_var_value),
   treq->qual[knt].std_dev_value = cnvtreal(requestin->list_0[d.seq].stat_std_dev_value), treq->qual[
   knt].box_cox_power_value = cnvtreal(requestin->list_0[d.seq].stat_box_cox_power_value),
   treq->qual[knt].active_ind = cnvtint(requestin->list_0[d.seq].stat_active_ind)
  FOOT REPORT
   stat = alterlist(treq->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_error,"Parsing Requestin")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(serrmsg))
  SET err_level = 2
  GO TO exit_script
 ELSEIF (err_level=2)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_error,"Parsing Requestin")
  SET msg_knt = (msg_knt+ 1)
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
 FREE RECORD request
 RECORD request(
   1 qual[*]
     2 ref_datastats_id = f8
     2 action_seq = i4
     2 action_ind = i2
     2 chart_definition_id = f8
     2 x_min_val = f8
     2 x_max_val = f8
     2 median_value = f8
     2 mean_value = f8
     2 coeffnt_var_value = f8
     2 std_dev_value = f8
     2 box_cox_power_value = f8
     2 active_ind = i2
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(treq->qual,5))),
   chart_definition cd
  PLAN (d
   WHERE d.seq > 0)
   JOIN (cd
   WHERE (cd.chart_source_cd=treq->qual[d.seq].chart_source_cd)
    AND (cd.chart_type_cd=treq->qual[d.seq].chart_type_cd)
    AND (cd.sex_cd=treq->qual[d.seq].chart_sex_cd)
    AND (cd.min_age=treq->qual[d.seq].chart_min_age)
    AND (cd.max_age=treq->qual[d.seq].chart_max_age)
    AND (cd.y_axis_unit_cd=treq->qual[d.seq].chart_y_axis_unit_cd))
  HEAD REPORT
   knt = 0, stat = alterlist(request->qual,1000)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,1000)=1
    AND knt != 1)
    stat = alterlist(request->qual,(knt+ 9))
   ENDIF
   request->qual[knt].chart_definition_id = cd.chart_definition_id, request->qual[knt].x_min_val =
   treq->qual[d.seq].x_min_val, request->qual[knt].x_max_val = treq->qual[d.seq].x_max_val,
   request->qual[knt].median_value = treq->qual[d.seq].median_value, request->qual[knt].mean_value =
   treq->qual[d.seq].mean_value, request->qual[knt].coeffnt_var_value = treq->qual[d.seq].
   coeffnt_var_value,
   request->qual[knt].std_dev_value = treq->qual[d.seq].std_dev_value, request->qual[knt].
   box_cox_power_value = treq->qual[d.seq].box_cox_power_value, request->qual[knt].active_ind = treq
   ->qual[d.seq].active_ind
  FOOT REPORT
   stat = alterlist(request->qual,knt)
  WITH nocounter
 ;end select
 FREE RECORD treq
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_error,"Getting CHART_DEFINITION_ID")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(serrmsg))
  SET err_level = 2
  FREE RECORD request
  FREE RECORD treq
  GO TO exit_script
 ENDIF
 FREE RECORD treq
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"END Get Chart Definition Ids : ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 IF (size(request->qual,5) < 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_warning,"No Chart Definitions Found")
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Ensure REF_DATASTATS")
 CALL echo("***")
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"BEG Ensure REF_DATASTATS : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 FREE RECORD reply
 RECORD reply(
   1 qual[*]
     2 ref_datastats_id = f8
     2 last_action_seq = i4
     2 action_ind = i2
     2 chart_definition_id = f8
     2 x_min_val = f8
     2 x_max_val = f8
     2 median_value = f8
     2 mean_value = f8
     2 coeffnt_var_value = f8
     2 std_dev_value = f8
     2 box_cox_power_value = f8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 EXECUTE cps_ens_ref_datastats
 IF ((reply->status_data.status != "S"))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_error,"Executing CPS_ENS_REF_DATASTATS")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(reply->status_data.subeventstatus[1].
    targetobjectvalue))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(reply->status_data.subeventstatus[1].
    operationname))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(reply->status_data.subeventstatus[1].
    targetobjectname))
  SET err_level = 2
  FREE RECORD reply
  FREE RECORD request
  GO TO exit_script
 ENDIF
 FREE RECORD reply
 FREE RECORD request
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"END Ensure REF_DATASTATS : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (err_level=2)
  CALL echo("***")
  CALL echo(concat("***   CPS_IMP_CHART_DATASTATS>> FAILURE: Examine the ",
    "ccluserdir:cps_imp_chart_datastats.log file to learn more."))
  CALL echo("***")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_IMP_CHART_DATASTATS END : <FAILURE> ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  ROLLBACK
  SET reqinfo->commit_ind = 3
 ELSEIF (err_level=1)
  CALL echo("***")
  CALL echo(concat("***   CPS_IMP_CHART_DATASTATS>> WARNING: Examine the ",
    "ccluserdir:cps_imp_chart_datastats.log file to learn more."))
  CALL echo("***")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_IMP_CHART_DATASTATS END : <WARNING> ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  ROLLBACK
  SET reqinfo->commit_ind = 3
 ELSE
  CALL echo("***")
  CALL echo(concat("***   CPS_IMP_CHART_DATASTATS>> SUCCESS: Examine the ",
    "ccluserdir:cps_imp_chart_datastats.log file to learn more."))
  CALL echo("***")
  SET reqinfo->commit_ind = 1
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_IMP_CHART_DATASTATS END : <SUCCESS> ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
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
    PLAN (d
     WHERE d.seq > 0)
    DETAIL
     row + 1, col 0, out_string
    WITH nocounter, append, format = variable,
     noformfeed, maxrow = value((msg_knt+ 1)), maxcol = 150
   ;end select
 END ;Subroutine
#end_program
 SET cps_script_version = "002 01/16/04 SF3151"
END GO
