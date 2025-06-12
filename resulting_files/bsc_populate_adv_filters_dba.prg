CREATE PROGRAM bsc_populate_adv_filters:dba
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
 SET readme_data->message = "Readme Failed: Starting script bsc_populate_adv_filters..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE fdcompid = i4 WITH protect, noconstant(0)
 DECLARE cordered = f8 WITH protect, noconstant(0.0)
 DECLARE cinprocess = f8 WITH protect, noconstant(0.0)
 DECLARE cfuture = f8 WITH protect, noconstant(0.0)
 DECLARE cincomplete = f8 WITH protect, noconstant(0.0)
 DECLARE csuspended = f8 WITH protect, noconstant(0.0)
 DECLARE cmedstudent = f8 WITH protect, noconstant(0.0)
 DECLARE cdiscontinued = f8 WITH protect, noconstant(0.0)
 DECLARE ccanceled = f8 WITH protect, noconstant(0.0)
 DECLARE ccompleted = f8 WITH protect, noconstant(0.0)
 DECLARE cpending = f8 WITH protect, noconstant(0.0)
 DECLARE cdeleted = f8 WITH protect, noconstant(0.0)
 DECLARE cvoidedwrslt = f8 WITH protect, noconstant(0.0)
 DECLARE ctransfer = f8 WITH protect, noconstant(0.0)
 DECLARE cmar = f8 WITH protect, noconstant(0.0)
 DECLARE cmarsummary = f8 WITH protect, noconstant(0.0)
 DECLARE conetime = f8 WITH protect, noconstant(0.0)
 DECLARE corderstatus = f8 WITH protect, noconstant(0.0)
 DECLARE cactivetasks = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set IN (6004, 4002134, 4002135)
    AND cv.active_ind=1)
  DETAIL
   CASE (cv.code_set)
    OF 6004:
     CASE (cv.cdf_meaning)
      OF "ORDERED":
       cordered = cv.code_value
      OF "INPROCESS":
       cinprocess = cv.code_value
      OF "FUTURE":
       cfuture = cv.code_value
      OF "INCOMPLETE":
       cincomplete = cv.code_value
      OF "SUSPENDED":
       csuspended = cv.code_value
      OF "MEDSTUDENT":
       cmedstudent = cv.code_value
      OF "DISCONTINUED":
       cdiscontinued = cv.code_value
      OF "CANCELED":
       ccanceled = cv.code_value
      OF "COMPLETED":
       ccompleted = cv.code_value
      OF "PENDING":
       cpending = cv.code_value
      OF "DELETED":
       cdeleted = cv.code_value
      OF "VOIDEDWRSLT":
       cvoidedwrslt = cv.code_value
      OF "TRANS/CANCEL":
       ctransfer = cv.code_value
     ENDCASE
    OF 4002134:
     CASE (cv.cdf_meaning)
      OF "MAR":
       cmar = cv.code_value
      OF "MARSUMMARY":
       cmarsummary = cv.code_value
     ENDCASE
    OF 4002135:
     CASE (cv.cdf_meaning)
      OF "ONETIME":
       conetime = cv.code_value
      OF "ORDERSTATUS":
       corderstatus = cv.code_value
      OF "ACTIVETASKS":
       cactivetasks = cv.code_value
     ENDCASE
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="All Medications"
   AND cfg.person_id=0
   AND cfg.component_cd=cmar
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR All Medications***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name = "All Medications",
    cfg.component_cd = cmar, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR All Meds to comp_filter_group:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cordered,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cORDERED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cinprocess,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cINPROCESS:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cfuture,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cFUTURE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cincomplete,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cINCOMPLETE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(csuspended,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cSUSPENDED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cmedstudent,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cMEDSTUDENT:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cdiscontinued,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cDISCONTINUED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(ccanceled,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cCANCELED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(ccompleted,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cCOMPLETED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cpending,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cPENDING:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cdeleted,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cDELETED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cvoidedwrslt,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cVOIDEDWRSLT:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(ctransfer,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Meds cTRANSFER:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR All Medications***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="All Medications"
   AND cfg.person_id=0
   AND cfg.component_cd=cmarsummary
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR SUMM All Medications***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name = "All Medications",
    cfg.component_cd = cmarsummary, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->
    updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR SUMM All Meds to comp_filter_group:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cordered,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cORDERED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cinprocess,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cINPROCESS:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cfuture,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cFUTURE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cincomplete,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cINCOMPLETE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(csuspended,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cSUSPENDED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cmedstudent,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cMEDSTUDENT:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cdiscontinued,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cDISCONTINUED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(ccanceled,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cCANCELED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(ccompleted,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cCOMPLETED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cpending,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cPENDING:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cdeleted,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cDELETED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cvoidedwrslt,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cVOIDEDWRSLT:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(ctransfer,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Meds cTRANSFER:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR SUMM All Medications***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="All Active Medications"
   AND cfg.person_id=0
   AND cfg.component_cd=cmar
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR All Active Medications***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name =
    "All Active Medications",
    cfg.component_cd = cmar, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR All Active Meds to comp_filter_group:",errmsg
    )
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cordered,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Active Meds cORDERED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cinprocess,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Active Meds cINPROCESS:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cfuture,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Active Meds cFUTURE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cincomplete,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Active Meds cINCOMPLETE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(csuspended,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Active Meds cSUSPENDED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cmedstudent,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Active Meds cMEDSTUDENT:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR All Active Medications***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="All Active Medications"
   AND cfg.person_id=0
   AND cfg.component_cd=cmarsummary
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR SUMM All Active Medications***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name =
    "All Active Medications",
    cfg.component_cd = cmarsummary, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->
    updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR SUMM All Active Meds to comp_filter_group:",
    errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cordered,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Active Meds cORDERED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cinprocess,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Active Meds cINPROCESS:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cfuture,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Active Meds cFUTURE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cincomplete,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Active Meds cINCOMPLETE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(csuspended,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Active Meds cSUSPENDED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cmedstudent,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Active Meds cMEDSTUDENT:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR SUMM All Active Medications***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="All Inactive Medications"
   AND cfg.person_id=0
   AND cfg.component_cd=cmar
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR All Inactive Medications***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name =
    "All Inactive Medications",
    cfg.component_cd = cmar, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR All Inactive Meds to comp_filter_group:",
    errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cdiscontinued,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Inactive Meds cDISCONTINUED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(ccanceled,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Inactive Meds cCANCELED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(ccompleted,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Inactive Meds cCOMPLETED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cpending,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Inactive Meds cPENDING:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cdeleted,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Inactive Meds cDELETED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cvoidedwrslt,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Inactive Meds cVOIDEDWRSLT:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(ctransfer,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Inactive Meds cTRANSFER:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR All Inactive Medications***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="All Inactive Medications"
   AND cfg.person_id=0
   AND cfg.component_cd=cmarsummary
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR SUMM All Inactive Medications***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name =
    "All Inactive Medications",
    cfg.component_cd = cmarsummary, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->
    updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR SUMM All Inactive Meds to comp_filter_group:",
    errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cdiscontinued,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Inactive Meds cDISCONTINUED:",errmsg
    )
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(ccanceled,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Inactive Meds cCANCELED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(ccompleted,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Inactive Meds cCOMPLETED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cpending,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Inactive Meds cPENDING:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cdeleted,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Inactive Meds cDELETED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cvoidedwrslt,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Inactive Meds cVOIDEDWRSLT:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(ctransfer,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Inactive Meds cTRANSFER:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR SUMM All Inactive Medications***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="All Suspended, Incomplete, and Pending Complete Medications"
   AND cfg.person_id=0
   AND cfg.component_cd=cmar
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR All Suspended, Incomplete, and Pending Complete Medications***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name =
    "All Suspended, Incomplete, and Pending Complete Medications",
    cfg.component_cd = cmar, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR All Suspended to comp_filter_group:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cincomplete,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Suspended cINCOMPLETE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(csuspended,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Suspended cSUSPENDED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cpending,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR All Suspended cPENDING:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR All Suspended, Incomplete, and Pending Complete Medications***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="All Suspended, Incomplete, and Pending Complete Medications"
   AND cfg.person_id=0
   AND cfg.component_cd=cmarsummary
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR SUMM All Suspended, Incomplete, and Pending Complete Medications***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name =
    "All Suspended, Incomplete, and Pending Complete Medications",
    cfg.component_cd = cmarsummary, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->
    updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR SUMM All Suspended to comp_filter_group:",
    errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cincomplete,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Suspended cINCOMPLETE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(csuspended,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Suspended cSUSPENDED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cpending,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM All Suspended cPENDING:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR SUMM All Suspended, Incomplete, and Pending Complete Medications***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="All Orders with Active Tasks in Time Range Medications"
   AND cfg.person_id=0
   AND cfg.component_cd=cmar
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR All Orders with Active Tasks in Time Range Medications***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name =
    "All Orders with Active Tasks in Time Range Medications",
    cfg.component_cd = cmar, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR Active Tasks to comp_filter_group:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = cactivetasks,
    cfgi.filter_item_value_txt = "YES", cfgi.updt_id = reqinfo->updt_id, cfgi.updt_task = reqinfo->
    updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR Active Tasks - YES:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR All Orders with Active Tasks in Time Range Medications***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="All Orders with Active Tasks in Time Range Medications"
   AND cfg.person_id=0
   AND cfg.component_cd=cmarsummary
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR SUMM All Orders with Active Tasks in Time Range Medications***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name =
    "All Orders with Active Tasks in Time Range Medications",
    cfg.component_cd = cmarsummary, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->
    updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR SUMM Active Tasks to comp_filter_group:",
    errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = cactivetasks,
    cfgi.filter_item_value_txt = "YES", cfgi.updt_id = reqinfo->updt_id, cfgi.updt_task = reqinfo->
    updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM Active Tasks - YES",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR SUMM All Orders with Active Tasks in Time Range Medications***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="One Time Doses - Active and Inactive"
   AND cfg.person_id=0
   AND cfg.component_cd=cmar
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR One Time Doses - Active and Inactive***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name =
    "One Time Doses - Active and Inactive",
    cfg.component_cd = cmar, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR One Time Doses to comp_filter_group:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = conetime,
    cfgi.filter_item_value_txt = "YES", cfgi.updt_id = reqinfo->updt_id, cfgi.updt_task = reqinfo->
    updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR One Time Doses - YES:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR One Time Doses - Active and Inactive***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="One Time Doses - Active and Inactive"
   AND cfg.person_id=0
   AND cfg.component_cd=cmarsummary
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR SUMM One Time Doses - Active and Inactive***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name =
    "One Time Doses - Active and Inactive",
    cfg.component_cd = cmarsummary, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->
    updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR SUMM One Time Doses to comp_filter_group:",
    errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = conetime,
    cfgi.filter_item_value_txt = "YES", cfgi.updt_id = reqinfo->updt_id, cfgi.updt_task = reqinfo->
    updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM One Time Doses - YES:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR SUMM One Time Doses - Active and Inactive***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="One Time Doses - Active"
   AND cfg.person_id=0
   AND cfg.component_cd=cmar
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR One Time Doses - Active***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name =
    "One Time Doses - Active",
    cfg.component_cd = cmar, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed to add MAR Active One Time Doses to comp_filter_group:",
    errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cordered,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR Active One Time Doses cORDERED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cinprocess,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR Active One Time Doses cINPROCESS:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cfuture,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR Active One Time Doses cFUTURE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cincomplete,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR Active One Time Doses cINCOMPLETE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(csuspended,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR Active One Time Doses cSUSPENDED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cmedstudent,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR Active One Time Doses cMEDSTUDENT:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = conetime,
    cfgi.filter_item_value_txt = "YES", cfgi.updt_id = reqinfo->updt_id, cfgi.updt_task = reqinfo->
    updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR Active One Time Doses - YES:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR One Time Doses - Active***")
 ENDIF
 SELECT INTO "nl:"
  FROM comp_filter_group cfg
  WHERE cfg.filter_name="One Time Doses - Active"
   AND cfg.person_id=0
   AND cfg.component_cd=cmarsummary
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("***Adding MAR SUMM One Time Doses - Active***")
  SELECT INTO "nl:"
   num = seq(medadmin_seq,nextval)
   FROM dual
   DETAIL
    fdcompid = num
   WITH nocounter
  ;end select
  INSERT  FROM comp_filter_group cfg
   SET cfg.comp_filter_group_id = fdcompid, cfg.person_id = 0, cfg.filter_name =
    "One Time Doses - Active",
    cfg.component_cd = cmarsummary, cfg.updt_id = reqinfo->updt_id, cfg.updt_task = reqinfo->
    updt_task,
    cfg.updt_applctx = reqinfo->updt_applctx, cfg.updt_cnt = 0, cfg.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat(
    "Failed to add MAR SUMM Active One Time Doses to comp_filter_group:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cordered,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM Active One Time Doses cORDERED:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cinprocess,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM Active One Time Doses cINPROCESS:",
    errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cfuture,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM Active One Time Doses cFUTURE:",errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cincomplete,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM Active One Time Doses cINCOMPLETE:",
    errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(csuspended,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM Active One Time Doses cSUSPENDED:",
    errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = corderstatus,
    cfgi.filter_item_value_txt = cnvtstring(cmedstudent,20), cfgi.updt_id = reqinfo->updt_id, cfgi
    .updt_task = reqinfo->updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM Active One Time Doses cMEDSTUDENT:",
    errmsg)
   GO TO exit_script
  ENDIF
  INSERT  FROM comp_filter_group_item cfgi
   SET cfgi.comp_filter_group_item_id = seq(medadmin_seq,nextval), cfgi.comp_filter_group_id =
    fdcompid, cfgi.component_filter_type_cd = conetime,
    cfgi.filter_item_value_txt = "YES", cfgi.updt_id = reqinfo->updt_id, cfgi.updt_task = reqinfo->
    updt_task,
    cfgi.updt_applctx = reqinfo->updt_applctx, cfgi.updt_cnt = 0, cfgi.updt_dt_tm = cnvtdatetime(
     curdate,curtime3)
   WITH nocounter
  ;end insert
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   SET readme_data->message = concat("Failed adding MAR SUMM Active One Time Doses - YES:",errmsg)
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("***Skipping MAR SUMM One Time Doses - Active***")
 ENDIF
#exit_script
 IF (errcode > 0)
  CALL echo(concat("Insertion error - ",errmsg))
  ROLLBACK
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Success:MAR Advanced Filters tables populated"
  COMMIT
 ENDIF
 SET last_mod = "002"
 SET mod_date = "10/25/2011"
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
