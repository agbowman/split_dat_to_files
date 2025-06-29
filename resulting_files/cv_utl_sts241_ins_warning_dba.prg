CREATE PROGRAM cv_utl_sts241_ins_warning:dba
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_date = vc WITH protect, constant("31-DEC-2100 00:00:00")
  DECLARE cv_log_debug = i4 WITH protect, constant(4)
  DECLARE cv_log_info = i4 WITH protect, constant(3)
  DECLARE cv_log_audit = i4 WITH protect, constant(2)
  DECLARE cv_log_warning = i4 WITH protect, constant(1)
  DECLARE cv_log_error = i4 WITH protect, constant(0)
  DECLARE cv_log_handle_cnt = i4 WITH protect, noconstant(1)
  DECLARE cv_log_handle = i4 WITH protect
  DECLARE cv_log_status = i4 WITH protect
  DECLARE cv_log_error_file = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_string = c32000 WITH protect, noconstant(fillstring(32000," "))
  DECLARE cv_err_msg = c100 WITH protect, noconstant(fillstring(100," "))
  DECLARE cv_log_err_num = i4 WITH protect
  DECLARE cv_log_file_name = vc WITH protect, noconstant(build("cer_temp:CV_DEFAULT",format(
     cnvtdatetime(curdate,curtime3),"HHMMSS;;q"),".dat"))
  DECLARE cv_log_struct_file_name = vc WITH protect, noconstant(build("cer_temp:",curprog))
  DECLARE cv_log_struct_file_nbr = i4 WITH protect
  DECLARE cv_log_event = vc WITH protect, noconstant("CV_DEFAULT_LOG")
  DECLARE cv_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_def_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_log_echo_level = i4 WITH protect, noconstant(cv_log_debug)
  SET cv_log_level = reqdata->loglevel
  SET cv_def_log_level = reqdata->loglevel
  SET cv_log_echo_level = reqdata->loglevel
  IF (cv_log_level >= cv_log_info)
   SET cv_log_error_file = 1
  ELSE
   SET cv_log_error_file = 0
  ENDIF
  DECLARE cv_log_chg_to_default = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_time = i4 WITH protect, noconstant(1)
  DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH protect
  DECLARE cv_chk_err_label = vc WITH protect, noconstant("EXIT_SCRIPT")
  DECLARE num_event = i4 WITH protect
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 DECLARE cv_log_createhandle(dummy=i2) = null
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 DECLARE cv_log_current_default(dummy=i2) = null
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 DECLARE cv_echo(string=vc) = null
 SUBROUTINE cv_echo(string)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message(log_message_param=vc) = null
 SUBROUTINE cv_log_message(log_message_param)
   SET cv_log_err_num = (cv_log_err_num+ 1)
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATETIME"))
   ENDIF
   IF (cv_log_chg_to_default=1)
    SET cv_log_level = cv_def_log_level
   ENDIF
   IF (cv_log_echo_level > cv_log_audit)
    CALL echo(cv_err_msg)
   ENDIF
   IF (cv_log_error_file=1)
    SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message_status(object_name_param=vc,operation_status_param=c1,operation_name_param=vc,
  target_object_value_param=vc) = null
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 DECLARE cv_check_err(opname=vc,opstatus=c1,targetname=vc) = null
 SUBROUTINE cv_check_err(opname,opstatus,targetname)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode=0)
    RETURN
   ENDIF
   WHILE (ierrcode != 0)
     CALL cv_log_message_status(targetname,opstatus,opname,serrmsg)
     CALL cv_log_message(serrmsg)
     SET ierrcode = error(serrmsg,0)
     SET reply->status_data.status = "F"
   ENDWHILE
   IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
    GO TO cv_chk_err_label
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD internal(
   1 dataset_id = f8
   1 msg_illegal[*]
     2 xref_id = f8
   1 msg_illegal_long_text_id = f8
   1 msg_illegal_tool[*]
     2 xref_id = f8
   1 msg_illegal_tool_long_text_id = f8
   1 msg_reportwarn[*]
     2 xref_id = f8
   1 msg_reportwarn_long_text_id = f8
   1 msg_reportwarn_tool[*]
     2 xref_id = f8
   1 msg_reportwarn_tool_long_text_id = f8
   1 msg_report[*]
     2 xref_id = f8
   1 msg_report_long_text_id = f8
   1 msg_report_tool[*]
     2 xref_id = f8
   1 msg_report_tool_long_text_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE failure = c1 WITH public, noconstant("F")
 DECLARE warning_on = c1 WITH public, noconstant("F")
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE err_message = vc WITH public, noconstant(" ")
 DECLARE the_new_line = vc WITH public, noconstant(" ")
 SET the_new_line = concat(char(13),char(10))
 SET cv_log_my_files = 1
 CALL cv_log_message("get dataset_id")
 SELECT INTO "nl:"
  *
  FROM cv_dataset d
  WHERE trim(d.dataset_internal_name,3)="STS02"
  DETAIL
   internal->dataset_id = d.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure attempting to retrieve dataset_id")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  *
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name IN ("ST02_VENDORID", "ST02_SOFTVRSN", "ST02_DATAVRSN", "ST02_RECORDID",
  "ST02_PATID")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_illegal,cnt), internal->msg_illegal[cnt].xref_id =
   x.xref_id
  WITH nocounter
 ;end select
 IF (cnt != 5)
  SET warning_on = "T"
  SET err_message = build("ST02_VENDORID failed: expect (5), actual (",trim(cnvtstring(cnt),3),")",
   the_new_line)
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)"##################;RP0"
  FROM dual
  DETAIL
   internal->msg_illegal_long_text_id = cnvtint(nextseqnum)
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text =
   "It is illegal for this data to be missing, contact administrator to fix it!", l.parent_entity_id
    = internal->dataset_id,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = 0, l.updt_id = 0,
   l.updt_task = 0, l.updt_applctx = 0, l.active_ind = 1,
   l.active_status_cd = 58, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l
   .active_status_prsnl_id = 0,
   l.long_text_id = internal->msg_illegal_long_text_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure inserting long_text illegal message")
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO size(internal->msg_illegal,5))
   UPDATE  FROM cv_xref x
    SET x.error_text_id = internal->msg_illegal_long_text_id
    WHERE (x.xref_id=internal->msg_illegal[idx].xref_id)
    WITH nocounter
   ;end update
 ENDFOR
 SELECT INTO "NL:"
  *
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name IN ("ST02_PARTICID")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_illegal_tool,cnt), internal->msg_illegal_tool[cnt].
   xref_id = x.xref_id
  WITH nocounter
 ;end select
 IF (cnt != 1)
  SET warning_on = "T"
  SET err_message = build(err_message,"ST02_PARTICID failed: expect (1), actual (",trim(cnvtstring(
     cnt),3),")",the_new_line)
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)"##################;RP0"
  FROM dual
  DETAIL
   internal->msg_illegal_tool_long_text_id = cnvtint(nextseqnum)
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text =
   "It is illegal for this data to be missing, add it with Orgtool!", l.parent_entity_id = internal->
   dataset_id,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = 0, l.updt_id = 0,
   l.updt_task = 0, l.updt_applctx = 0, l.active_ind = 1,
   l.active_status_cd = 58, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l
   .active_status_prsnl_id = 0,
   l.long_text_id = internal->msg_illegal_tool_long_text_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure inserting long_text illegal message with tool!")
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO size(internal->msg_illegal_tool,5))
   UPDATE  FROM cv_xref x
    SET x.error_text_id = internal->msg_illegal_tool_long_text_id
    WHERE (x.xref_id=internal->msg_illegal_tool[idx].xref_id)
    WITH nocounter
   ;end update
 ENDFOR
 SELECT INTO "NL:"
  *
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name IN ("ST02_SURGDT", "ST02_OPCAB", "ST02_OPAORTIC", "ST02_OPMITRAL",
  "ST02_OPTRICUS",
  "ST02_OPPULM", "ST02_OPOCARD", "ST02_OPONCARD", "ST02_DISLOCTN", "ST02_MORTALTY",
  "ST02_MTDCSTAT", "ST02_MT30STAT", "ST02_MTOPD", "ST02_MTDATE", "ST02_MTLOCATN",
  "ST02_MTCAUSE")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_reportwarn,cnt), internal->msg_reportwarn[cnt].
   xref_id = x.xref_id
  WITH nocounter
 ;end select
 IF (cnt != 16)
  SET warning_on = "T"
  SET err_message = build(err_message,"ST02_SURGDT failed: expect (16), actual (",trim(cnvtstring(cnt
     ),3),")",the_new_line)
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)"##################;RP0"
  FROM dual
  DETAIL
   internal->msg_reportwarn_long_text_id = cnvtint(nextseqnum)
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text =
   "Missing data may make the record unacceptable for analysis in the national database!", l
   .parent_entity_id = internal->dataset_id,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = 0, l.updt_id = 0,
   l.updt_task = 0, l.updt_applctx = 0, l.active_ind = 1,
   l.active_status_cd = 58, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l
   .active_status_prsnl_id = 0,
   l.long_text_id = internal->msg_reportwarn_long_text_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure inserting long_text report and warn message")
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO size(internal->msg_reportwarn,5))
   UPDATE  FROM cv_xref x
    SET x.warning_text_id = internal->msg_reportwarn_long_text_id
    WHERE (x.xref_id=internal->msg_reportwarn[idx].xref_id)
    WITH nocounter
   ;end update
 ENDFOR
 SELECT INTO "NL:"
  *
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name IN ("ST02_AGE", "ST02_GENDER")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_reportwarn_tool,cnt), internal->
   msg_reportwarn_tool[cnt].xref_id = x.xref_id
  WITH nocounter
 ;end select
 IF (cnt != 2)
  SET warning_on = "T"
  SET err_message = build(err_message,"ST02_AGE failed: expect (2), actual (",trim(cnvtstring(cnt),3),
   ")",the_new_line)
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)"##################;RP0"
  FROM dual
  DETAIL
   internal->msg_reportwarn_tool_long_text_id = cnvtint(nextseqnum)
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text =
   "Missing data may make the record unacceptable for analysis, add it with Pmhnareg tool!", l
   .parent_entity_id = internal->dataset_id,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = 0, l.updt_id = 0,
   l.updt_task = 0, l.updt_applctx = 0, l.active_ind = 1,
   l.active_status_cd = 58, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l
   .active_status_prsnl_id = 0,
   l.long_text_id = internal->msg_reportwarn_tool_long_text_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure inserting long_text report and warn message with tool!")
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO size(internal->msg_reportwarn_tool,5))
   UPDATE  FROM cv_xref x
    SET x.warning_text_id = internal->msg_reportwarn_tool_long_text_id
    WHERE (x.xref_id=internal->msg_reportwarn_tool[idx].xref_id)
    WITH nocounter
   ;end update
 ENDFOR
 SELECT INTO "NL:"
  x.xref_id
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name IN ("ST02_ADMITDT", "ST02_DOB", "ST02_DISCHDT", "ST02_HOSPNAME",
  "ST02_HOSPSTAT",
  "ST02_HOSPZIP", "ST02_MEDRECN", "ST02_PATFNAME", "ST02_PATLNAME", "ST02_PATMINIT",
  "ST02_PATZIP", "ST02_RACE", "ST02_SSN")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_report_tool,cnt), internal->msg_report_tool[cnt].
   xref_id = x.xref_id
  WITH nocounter
 ;end select
 IF (cnt != 13)
  SET warning_on = "T"
  SET err_message = build(err_message,"ST02_ADMITDT failed: expect (13), actual (",trim(cnvtstring(
     cnt),3),")",the_new_line)
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)"##################;RP0"
  FROM dual
  DETAIL
   internal->msg_report_tool_long_text_id = cnvtint(nextseqnum)
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text =
   "Data is missing, add it with Pmhnareg tool!", l.parent_entity_id = internal->dataset_id,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = 0, l.updt_id = 0,
   l.updt_task = 0, l.updt_applctx = 0, l.active_ind = 1,
   l.active_status_cd = 58, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l
   .active_status_prsnl_id = 0,
   l.long_text_id = internal->msg_report_tool_long_text_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure inserting long_text report message")
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO size(internal->msg_report_tool,5))
   UPDATE  FROM cv_xref x
    SET x.warning_text_id = internal->msg_report_tool_long_text_id
    WHERE (x.xref_id=internal->msg_report_tool[idx].xref_id)
    WITH nocounter
   ;end update
 ENDFOR
 SELECT INTO "NL:"
  *
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name IN ("ST02_REFCARD", "ST02_REFPHYS", "ST02_SAMEDAY", "ST02_ICUINHRS",
  "ST02_ICUREADM",
  "ST02_TOTHRICU", "ST02_WEIGHTKG", "ST02_HEIGHTCM", "ST02_SMOKER", "ST02_FHCAD",
  "ST02_DIABETES", "ST02_HYPRCHOL", "ST02_CREATLST", "ST02_RENFAIL", "ST02_HYPERTN",
  "ST02_CVA", "ST02_INFENDO", "ST02_CHRLUNGD", "ST02_IMMSUPP", "ST02_PVD",
  "ST02_CVD", "ST02_PRCVINT", "ST02_MI", "ST02_CHF", "ST02_ANGINA",
  "ST02_CARSHOCK", "ST02_RESUSC", "ST02_ARRHYTH", "ST02_CLASSCCS", "ST02_CLASSNYH",
  "ST02_MEDDIG", "ST02_MEDBETA", "ST02_MEDACEI", "ST02_MEDNITIV", "ST02_MEDAPLT",
  "ST02_MEDACOAG", "ST02_MEDDIUR", "ST02_MEDINOTR", "ST02_MEDSTER", "ST02_MEDASA",
  "ST02_NUMDISV", "ST02_LMAINDIS", "ST02_HDEFD", "ST02_HDPAD", "ST02_VDSTENA",
  "ST02_VDSTENM", "ST02_VDSTENT", "ST02_VDSTENP", "ST02_VDINSUFA", "ST02_VDINSUFM",
  "ST02_VDINSUFT", "ST02_VDINSUFP", "ST02_SURGEON", "ST02_STATUS", "ST02_CPBUSED",
  "ST02_INDMNINV", "ST02_PRIMINC", "ST02_NUMINCIS", "ST02_CNVSTDIN", "ST02_CANNULAT",
  "ST02_AORTOCCL", "ST02_CORSHUNT", "ST02_SUTRTECH", "ST02_VSLSTBLZ", "ST02_IMATECHN",
  "ST02_FLOWPTCY", "ST02_SISTARTT", "ST02_SISTOPT", "ST02_XCLAMPTM", "ST02_PERFUSTM",
  "ST02_CPLEGIA", "ST02_IABP", "ST02_VAD", "ST02_BLDPROD", "ST02_VENTHRSI",
  "ST02_VENTHRS", "ST02_COMPLICS", "ST02_DCASA", "ST02_DCACE", "ST02_DCBETA",
  "ST02_DCLIPID", "ST02_DCANTPLT", "ST02_READM30", "ST02_EMERGRSN", "ST02_HDEFMETH",
  "ST02_SURGGRP", "ST02_ANGUNSTT", "ST02_URGNTRSN", "ST02_ICUADHRS", "ST02_SMOKCURR",
  "ST02_DIABCTRL", "ST02_DIALYSIS", "ST02_CVAWHEN", "ST02_INFENDTY", "ST02_CVDTYPE",
  "ST02_PRCBNUM", "ST02_PRCNNUM", "ST02_PRCAB", "ST02_PRVALVE", "ST02_PROTHCAR",
  "ST02_PRPTCA", "ST02_PRPTINTV", "ST02_STNTINTV", "ST02_THRMBLYS", "ST02_THRINTVL",
  "ST02_PRNSBALL", "ST02_MIWHEN", "ST02_ANGTYPE", "ST02_CARSHTYP", "ST02_ARRHYTYP",
  "ST02_HDEF", "ST02_HDPAMEAN", "ST02_VDGRADA", "ST02_CABUNPLN", "ST02_DISTART",
  "ST02_DISTVEIN", "ST02_IMAARTUS", "ST02_NUMIMADA", "ST02_RADARTUS", "ST02_NUMRADDA",
  "ST02_NUMGEPDA", "ST02_VSAOIMTY", "ST02_VSAOIM", "ST02_VSAOIMSZ", "ST02_VSAOEXTY",
  "ST02_VSAOEX", "ST02_VSAOEXSZ", "ST02_VSMIIMTY", "ST02_VSMIIM", "ST02_VSMIIMSZ",
  "ST02_VSMIEXTY", "ST02_VSMIEX", "ST02_VSMIEXSZ", "ST02_VSTRIMTY", "ST02_VSTRIM",
  "ST02_VSTRIMSZ", "ST02_VSTREXTY", "ST02_VSTREX", "ST02_VSTREXSZ", "ST02_VSPUIMTY",
  "ST02_VSPUIM", "ST02_VSPUIMSZ", "ST02_VSPUEXTY", "ST02_VSPUEX", "ST02_VSPUEXSZ",
  "ST02_CONVCPB", "ST02_CNVINDIC", "ST02_IABPWHEN", "ST02_IABPIND", "ST02_REINTUB",
  "ST02_READMRSN", "ST02_VENTHRSA")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_report,cnt), internal->msg_report[cnt].xref_id = x
   .xref_id
  WITH nocounter
 ;end select
 IF (cnt != 152)
  SET warning_on = "T"
  SET err_message = build(err_message,"ST02_REFCARD failed: expect (152), actual (",trim(cnvtstring(
     cnt),3),")",the_new_line)
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)"##################;RP0"
  FROM dual
  DETAIL
   internal->msg_report_long_text_id = cnvtint(nextseqnum)
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text = "Data is missing!", l.parent_entity_id =
   internal->dataset_id,
   l.updt_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = 0, l.updt_id = 0,
   l.updt_task = 0, l.updt_applctx = 0, l.active_ind = 1,
   l.active_status_cd = 58, l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l
   .active_status_prsnl_id = 0,
   l.long_text_id = internal->msg_report_long_text_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure inserting long_text report message")
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO size(internal->msg_report,5))
   UPDATE  FROM cv_xref x
    SET x.warning_text_id = internal->msg_report_long_text_id
    WHERE (x.xref_id=internal->msg_report[idx].xref_id)
    WITH nocounter
   ;end update
 ENDFOR
#exit_script
 IF (failure="T")
  SET reqinfo->commit_ind = 0
  CALL echo("*********************************")
  CALL echo("Update failed, action rollbacked!")
  CALL echo("*********************************")
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo("*********************************")
  CALL echo("Update success, action committed!")
  CALL echo("*********************************")
 ENDIF
 IF (warning_on="T")
  CALL echo("Please copy and send the following message to Cerner")
  CALL echo(err_message)
  CALL echo("*********************************")
 ENDIF
 DECLARE cv_log_destroyhandle(dummy=i2) = null
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE cv_log_destroyhandle(dummy)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt = (cv_log_handle_cnt - 1)
   ENDIF
 END ;Subroutine
END GO
