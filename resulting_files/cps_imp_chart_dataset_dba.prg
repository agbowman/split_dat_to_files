CREATE PROGRAM cps_imp_chart_dataset:dba
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
 DECLARE log_file = c25 WITH public, constant("cps_imp_chart_dataset.log")
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
 DECLARE max_dknt = i4 WITH public, noconstant(0)
 DECLARE max_pknt = i4 WITH public, noconstant(0)
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_IMP_CHART_DATASET BEG : ",format(cnvtdatetime(
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
 FREE RECORD trequest
 RECORD trequest(
   1 qual[*]
     2 chart_definition_id = f8
     2 action_seq = i4
     2 action_ind = i2
     2 chart_source_cd = f8
     2 chart_type_cd = f8
     2 sex_cd = f8
     2 min_age = f8
     2 max_age = f8
     2 chart_title = vc
     2 x_type_cd = f8
     2 y_type_cd = f8
     2 y_axis_min_val = f8
     2 y_axis_max_val = f8
     2 y_axis_unit_cd = f8
     2 x_axis_section1_min_val = f8
     2 x_axis_section1_max_val = f8
     2 x_axis_section2_min_val = f8
     2 x_axis_section2_max_val = f8
     2 x_axis_section2_multiplier = f8
     2 x_axis_section1_unit_cd = f8
     2 x_axis_section2_unit_cd = f8
     2 version = vc
     2 active_ind = i2
     2 dqual[*]
       3 ref_dataset_id = f8
       3 action_seq = i4
       3 action_ind = i2
       3 chart_definition_id = f8
       3 display_name = vc
       3 display_type_cd = f8
       3 active_ind = i2
       3 point[*]
         4 ref_datapoint_id = f8
         4 action_seq = i4
         4 action_ind = i2
         4 x_val = f8
         4 y_val = f8
         4 active_ind = i2
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  chart_ord = build(trim(requestin->list_0[d.seq].chart_source_disp_key),trim(requestin->list_0[d.seq
    ].chart_type_meaning),trim(requestin->list_0[d.seq].chart_sex_meaning),trim(requestin->list_0[d
    .seq].chart_min_age),trim(requestin->list_0[d.seq].chart_max_age),
   trim(requestin->list_0[d.seq].chart_y_axis_unit_display)), dataset_ord = build(trim(requestin->
    list_0[d.seq].set_display_name),trim(requestin->list_0[d.seq].set_display_type_meaning)),
  datapoint_ord = build(trim(requestin->list_0[d.seq].point_x_val),trim(requestin->list_0[d.seq].
    point_y_val))
  FROM (dummyt d  WITH seq = value(reqin_size))
  PLAN (d
   WHERE d.seq > 0)
  ORDER BY chart_ord, dataset_ord, datapoint_ord
  HEAD REPORT
   x = 1, temp_chart_ord = fillstring(255," "), temp_dataset_ord = fillstring(255," "),
   temp_datapoint_ord = fillstring(255," "), cknt = 0, stat = alterlist(trequest->qual,1000)
  HEAD chart_ord
   cknt = (cknt+ 1)
   IF (mod(cknt,1000)=1
    AND cknt != 1)
    stat = alterlist(trequest->qual,(cknt+ 9))
   ENDIF
   trequest->qual[cknt].chart_source_cd = uar_get_code_by("DISPLAYKEY",255550,nullterm(requestin->
     list_0[d.seq].chart_source_disp_key))
   IF ( NOT ((trequest->qual[cknt].chart_source_cd > 0)))
    msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
    concat(s_error,"Failed to find CHART_SOURCE_CD for DISPLAY_KEY ",trim(requestin->list_0[d.seq].
      chart_source_disp_key)," from CODE_SET 255550."),
    err_level = 2,
    CALL cancel(1)
   ENDIF
   trequest->qual[cknt].chart_type_cd = uar_get_code_by("MEANING",255551,nullterm(requestin->list_0[d
     .seq].chart_type_meaning))
   IF ( NOT ((trequest->qual[cknt].chart_type_cd > 0)))
    msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
    concat(s_error,"Failed to find CHART_TYPE_CD for MEANING ",trim(requestin->list_0[d.seq].
      chart_type_meaning)," from CODE_SET 255551."),
    err_level = 2,
    CALL cancel(1)
   ENDIF
   trequest->qual[cknt].sex_cd = uar_get_code_by("MEANING",57,nullterm(requestin->list_0[d.seq].
     chart_sex_meaning))
   IF ( NOT ((trequest->qual[cknt].sex_cd > 0)))
    msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
    concat(s_error,"Failed to find SEX_CD for MEANING ",trim(requestin->list_0[d.seq].
      chart_sex_meaning)," from CODE_SET 57."),
    err_level = 2,
    CALL cancel(1)
   ENDIF
   trequest->qual[cknt].min_age = cnvtreal(requestin->list_0[d.seq].chart_min_age), trequest->qual[
   cknt].max_age = cnvtreal(requestin->list_0[d.seq].chart_max_age), trequest->qual[cknt].chart_title
    = trim(requestin->list_0[d.seq].chart_title),
   trequest->qual[cknt].x_type_cd = uar_get_code_by("MEANING",255553,nullterm(requestin->list_0[d.seq
     ].chart_x_type_meaning))
   IF ( NOT ((trequest->qual[cknt].x_type_cd > 0)))
    msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
    concat(s_error,"Failed to find X_TYPE_CD for MEANING ",trim(requestin->list_0[d.seq].
      chart_x_type_meaning)," from CODE_SET 255553."),
    err_level = 2,
    CALL cancel(1)
   ENDIF
   trequest->qual[cknt].y_type_cd = uar_get_code_by("MEANING",255553,nullterm(requestin->list_0[d.seq
     ].chart_y_type_meaning))
   IF ( NOT ((trequest->qual[cknt].y_type_cd > 0)))
    msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
    concat(s_error,"Failed to find Y_TYPE_CD for MEANING ",trim(requestin->list_0[d.seq].
      chart_y_type_meaning)," from CODE_SET 255553."),
    err_level = 2,
    CALL cancel(1)
   ENDIF
   trequest->qual[cknt].y_axis_min_val = cnvtreal(requestin->list_0[d.seq].chart_y_axis_min_val),
   trequest->qual[cknt].y_axis_max_val = cnvtreal(requestin->list_0[d.seq].chart_y_axis_max_val),
   trequest->qual[cknt].y_axis_unit_cd = uar_get_code_by("DISPLAY",54,nullterm(requestin->list_0[d
     .seq].chart_y_axis_unit_display))
   IF ( NOT ((trequest->qual[cknt].y_axis_unit_cd > 0)))
    msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
    concat(s_error,"Failed to find Y_AXIS_UNIT_CD for DISPLAY ",trim(requestin->list_0[d.seq].
      chart_y_axis_unit_display)," from CODE_SET 54."),
    err_level = 2,
    CALL cancel(1)
   ENDIF
   trequest->qual[cknt].x_axis_section1_min_val = cnvtreal(requestin->list_0[d.seq].
    chart_x_axis_section1_min_val), trequest->qual[cknt].x_axis_section1_max_val = cnvtreal(requestin
    ->list_0[d.seq].chart_x_axis_section1_max_val), trequest->qual[cknt].x_axis_section2_min_val =
   cnvtreal(requestin->list_0[d.seq].chart_x_axis_section2_min_val),
   trequest->qual[cknt].x_axis_section2_max_val = cnvtreal(requestin->list_0[d.seq].
    chart_x_axis_section2_max_val), trequest->qual[cknt].x_axis_section2_multiplier = cnvtreal(
    requestin->list_0[d.seq].chart_x_axis_section2_multiplier), trequest->qual[cknt].
   x_axis_section1_unit_cd = uar_get_code_by("DISPLAY",54,nullterm(requestin->list_0[d.seq].
     chart_x_axis_section1_unit_display))
   IF ( NOT ((trequest->qual[cknt].x_axis_section1_unit_cd > 0)))
    msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
    concat(s_error,"Failed to find X_AXIS_SECTION1_UNIT_CD for DISPLAY ",trim(requestin->list_0[d.seq
      ].chart_x_axis_section1_unit_display)," from CODE_SET 54."),
    err_level = 2,
    CALL cancel(1)
   ENDIF
   IF (nullterm(requestin->list_0[d.seq].chart_x_axis_section2_unit_display) > " ")
    trequest->qual[cknt].x_axis_section2_unit_cd = uar_get_code_by("DISPLAY",54,nullterm(requestin->
      list_0[d.seq].chart_x_axis_section2_unit_display))
    IF ( NOT ((trequest->qual[cknt].x_axis_section2_unit_cd > 0)))
     msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
     concat(s_error,"Failed to find X_AXIS_SECTION2_UNIT_CD for DISPLAY ",trim(requestin->list_0[d
       .seq].chart_x_axis_section2_unit_display)," from CODE_SET 54."),
     err_level = 2,
     CALL cancel(1)
    ENDIF
   ENDIF
   trequest->qual[cknt].version = trim(requestin->list_0[d.seq].chart_version), trequest->qual[cknt].
   active_ind = cnvtint(requestin->list_0[d.seq].chart_active_ind), dknt = 0,
   stat = alterlist(trequest->qual[cknt].dqual,1000)
  HEAD dataset_ord
   dknt = (dknt+ 1)
   IF (mod(dknt,1000)=1
    AND dknt != 1)
    stat = alterlist(trequest->qual[cknt].dqual,(dknt+ 9))
   ENDIF
   trequest->qual[cknt].dqual[dknt].display_name = trim(requestin->list_0[d.seq].set_display_name),
   trequest->qual[cknt].dqual[dknt].display_type_cd = uar_get_code_by("MEANING",255552,nullterm(
     requestin->list_0[d.seq].set_display_type_meaning))
   IF ( NOT ((trequest->qual[cknt].dqual[dknt].display_type_cd > 0)))
    msg_knt = (msg_knt+ 1), stat = alterlist(err_log->msg,msg_knt), err_log->msg[msg_knt].err_msg =
    concat(s_error,"Failed to find DISPLAY_TYPE_CD for MEANING ",trim(requestin->list_0[d.seq].
      set_display_type_meaning)," from CODE_SET 255552."),
    err_level = 2,
    CALL cancel(1)
   ENDIF
   trequest->qual[cknt].dqual[dknt].active_ind = cnvtint(requestin->list_0[d.seq].set_active_ind),
   pknt = 0, stat = alterlist(trequest->qual[cknt].dqual[dknt].point,1000)
  DETAIL
   pknt = (pknt+ 1)
   IF (mod(pknt,1000)=1
    AND pknt != 1)
    stat = alterlist(trequest->qual[cknt].dqual[dknt].point,(pknt+ 9))
   ENDIF
   trequest->qual[cknt].dqual[dknt].point[pknt].x_val = cnvtreal(requestin->list_0[d.seq].point_x_val
    ), trequest->qual[cknt].dqual[dknt].point[pknt].y_val = cnvtreal(requestin->list_0[d.seq].
    point_y_val), trequest->qual[cknt].dqual[dknt].point[pknt].active_ind = cnvtint(requestin->
    list_0[d.seq].point_active_ind)
  FOOT  dataset_ord
   IF (max_pknt <= pknt)
    max_pknt = pknt
   ENDIF
   stat = alterlist(trequest->qual[cknt].dqual[dknt].point,pknt)
  FOOT  chart_ord
   IF (max_dknt <= dknt)
    max_dknt = dknt
   ENDIF
   stat = alterlist(trequest->qual[cknt].dqual,dknt)
  FOOT REPORT
   stat = alterlist(trequest->qual,cknt)
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
 CALL echo("***   Ensure Chart Definition")
 CALL echo("***")
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"BEG Ensure Chart Definition : ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 FREE RECORD treply
 RECORD treply(
   1 qual[*]
     2 chart_definition_id = f8
     2 action_ind = i2
     2 last_action_seq = i4
     2 chart_source_cd = f8
     2 chart_type_cd = f8
     2 sex_cd = f8
     2 min_age = f8
     2 max_age = f8
     2 chart_title = vc
     2 version = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 EXECUTE cps_ens_chart_def  WITH replace("REQUEST","TREQUEST"), replace("REPLY","TREPLY")
 CALL echo("***")
 CALL echo(build("***   cps_ens_chart_def status :",treply->status_data.status))
 CALL echo("***")
 IF ((treply->status_data.status != "S"))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_error,"Executing CPS_ENS_CHART_DEF")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(treply->status_data.subeventstatus[1].
    targetobjectvalue))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(treply->status_data.subeventstatus[1].
    operationname))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(treply->status_data.subeventstatus[1].
    targetobjectname))
  SET err_level = 2
  FREE RECORD treply
  GO TO exit_script
 ENDIF
 FREE RECORD treply
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"END Ensure Chart Definition : ",format(
   cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL echo("***")
 CALL echo("***   Ensure REF_DATASET")
 CALL echo("***")
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"BEG Ensure REF_DATASET : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 FREE RECORD treq
 RECORD treq(
   1 qual[*]
     2 ref_dataset_id = f8
     2 action_seq = i4
     2 action_ind = i2
     2 chart_definition_id = f8
     2 display_name = vc
     2 display_type_cd = f8
     2 active_ind = i2
     2 point[*]
       3 ref_datapoint_id = f8
       3 action_seq = i4
       3 action_ind = i2
       3 x_val = f8
       3 y_val = f8
       3 active_ind = i2
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(trequest->qual,5))),
   (dummyt d2  WITH seq = value(max_dknt)),
   (dummyt d3  WITH seq = value(max_pknt))
  PLAN (d1
   WHERE d1.seq > 0
    AND (trequest->qual[d1.seq].chart_definition_id > 0))
   JOIN (d2
   WHERE d2.seq > 0
    AND d2.seq <= size(trequest->qual[d1.seq].dqual,5))
   JOIN (d3
   WHERE d3.seq > 0
    AND d3.seq <= size(trequest->qual[d1.seq].dqual[d2.seq].point,5))
  ORDER BY d1.seq, d2.seq, d3.seq
  HEAD REPORT
   knt = 0, stat = alterlist(treq->qual,1000)
  HEAD d1.seq
   x = 1
  HEAD d2.seq
   knt = (knt+ 1)
   IF (mod(knt,1000)=1
    AND knt != 1)
    stat = alterlist(treq->qual,(knt+ 9))
   ENDIF
   treq->qual[knt].chart_definition_id = trequest->qual[d1.seq].chart_definition_id, treq->qual[knt].
   display_name = trequest->qual[d1.seq].dqual[d2.seq].display_name, treq->qual[knt].display_type_cd
    = trequest->qual[d1.seq].dqual[d2.seq].display_type_cd,
   treq->qual[knt].active_ind = trequest->qual[d1.seq].dqual[d2.seq].active_ind, pknt = 0, stat =
   alterlist(treq->qual[knt].point,1000)
  DETAIL
   pknt = (pknt+ 1)
   IF (mod(pknt,1000)=1
    AND pknt != 1)
    stat = alterlist(treq->qual[knt].point,(pknt+ 9))
   ENDIF
   treq->qual[knt].point[pknt].x_val = trequest->qual[d1.seq].dqual[d2.seq].point[d3.seq].x_val, treq
   ->qual[knt].point[pknt].y_val = trequest->qual[d1.seq].dqual[d2.seq].point[d3.seq].y_val, treq->
   qual[knt].point[pknt].active_ind = trequest->qual[d1.seq].dqual[d2.seq].point[d3.seq].active_ind
  FOOT  d2.seq
   stat = alterlist(treq->qual[knt].point,pknt)
  FOOT REPORT
   stat = alterlist(treq->qual,knt)
  WITH nocounter
 ;end select
 FREE RECORD trequest
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_error,"Building REF_DATASET Record")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(serrmsg))
  SET err_level = 2
  GO TO exit_script
 ENDIF
 FREE RECORD treply
 RECORD treply(
   1 qual[*]
     2 ref_dataset_id = f8
     2 action_seq = i4
     2 action_ind = i2
     2 chart_definition_id = f8
     2 display_name = vc
     2 display_type_cd = f8
     2 active_ind = i2
     2 point[*]
       3 ref_datapoint_id = f8
       3 action_seq = i4
       3 action_ind = i2
       3 x_val = f8
       3 y_val = f8
       3 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 EXECUTE cps_ens_ref_dataset  WITH replace("REQUEST","TREQ"), replace("REPLY","TREPLY")
 CALL echo("***")
 CALL echo(build("***   cps_ens_ref_dataset status :",treply->status_data.status))
 CALL echo("***")
 FREE RECORD treq
 IF ((treply->status_data.status != "S"))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_error,"Executing CPS_ENS_REF_DATASET")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(treply->status_data.subeventstatus[1].
    targetobjectvalue))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(treply->status_data.subeventstatus[1].
    operationname))
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(s_msg,trim(treply->status_data.subeventstatus[1].
    targetobjectname))
  SET err_level = 2
  FREE RECORD treply
  GO TO exit_script
 ENDIF
 FREE RECORD treply
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat(s_info,"END Ensure REF_DATASET : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 IF (err_level=2)
  CALL echo("***")
  CALL echo(concat("***   CPS_IMP_CHART_DATASET>> FAILURE: Examine the ",
    "ccluserdir:cps_imp_chart_dataset.log file to learn more."))
  CALL echo("***")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_IMP_CHART_DATASET END : <FAILURE> ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  ROLLBACK
  SET reqinfo->commit_ind = 3
 ELSEIF (err_level=1)
  CALL echo("***")
  CALL echo(concat("***   CPS_IMP_CHART_DATASET>> WARNING: Examine the ",
    "ccluserdir:cps_imp_chart_dataset.log file to learn more."))
  CALL echo("***")
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_IMP_CHART_DATASET END : <WARNING> ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
  ROLLBACK
  SET reqinfo->commit_ind = 3
 ELSE
  CALL echo("***")
  CALL echo(concat("***   CPS_IMP_CHART_DATASET>> SUCCESS: Examine the ",
    "ccluserdir:cps_imp_chart_dataset.log file to learn more."))
  CALL echo("***")
  SET reqinfo->commit_ind = 1
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("CPS_IMP_CHART_DATASET END : <SUCCESS> ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 ENDIF
 CALL error_logging(dvar)
 FREE RECORD err_log
 GO TO end_program
 SUBROUTINE error_logging(lvar)
   CALL echo("***")
   CALL echo("***   LOGGING")
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
 SET cps_script_version = "002 01/21/04 SF3151"
END GO
