CREATE PROGRAM cv_utl_sts235_ins_warning:dba
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
   1 msg_reportwarn[*]
     2 xref_id = f8
   1 msg_reportwarn_long_text_id = f8
   1 msg_report[*]
     2 xref_id = f8
   1 msg_report_long_text_id = f8
 )
 SET reply->status_data.status = "F"
 SET failure = "F"
 DECLARE cnt = i4
 SET cv_log_my_files = 1
 CALL cv_log_message("get dataset_id")
 SELECT INTO "NL:"
  *
  FROM cv_dataset d
  WHERE trim(d.dataset_internal_name,3)="STS"
  DETAIL
   internal->dataset_id = d.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure = "T"
  CALL cv_log_message("Failure attempting to retrieve dataset_id")
  GO TO exit_script
 ENDIF
 SET cnt = 0
 SELECT INTO "NL:"
  *
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name IN ("STS_SOFTVRSN", "STS_PARTICID", "STS_RECORDID", "STS_VENDORID",
  "STS_DATAVRSN",
  "STS_PATID")
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_illegal,cnt), internal->msg_illegal[cnt].xref_id =
   x.xref_id
  WITH nocounter
 ;end select
 IF (cnt != 6)
  SET failure = "T"
  CALL cv_log_message(build("Failure in selecting illegal xref_id's:",cnt))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)"##################;RP0"
  FROM dual
  DETAIL
   internal->msg_illegal_long_text_id = cnvtint(nextseqnum)
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text = "It is illegal for this data to be missing",
   l.parent_entity_id = internal->dataset_id,
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
 SET cnt = 0
 SELECT INTO "NL:"
  *
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name IN ("STS_OPPULM", "STS_OPTRICUS", "STS_OPAORTIC", "STS_OPCAB",
  "STS_OPMITRAL",
  "STS_OPONCARD", "STS_MTDCSTAT", "STS_SURGDT", "STS_MTOPD", "STS_MT30STAT",
  "STS_OPOCARD")
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_reportwarn,cnt), internal->msg_reportwarn[cnt].
   xref_id = x.xref_id
  WITH nocounter
 ;end select
 IF (cnt != 11)
  SET failure = "T"
  CALL cv_log_message("Failure in selecting report and warn xref_id's")
  GO TO exit_script
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
   "Missing data may make the record unacceptable for analysis in the national database", l
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
 SET cnt = 0
 SELECT INTO "NL:"
  *
  FROM cv_xref x
  WHERE (x.dataset_id=internal->dataset_id)
   AND x.xref_internal_name IN ("STS_ADMITDT", "STS_ANGINA", "STS_ANGTYPE", "STS_ANGUNSTT",
  "STS_AORTOCCL",
  "STS_ARRHYTH", "STS_ARRHYTYP", "STS_BLDPROD", "STS_CABUNPLN", "STS_CANNULAT",
  "STS_CARSHOCK", "STS_CARSHTYP", "STS_CHF", "STS_CHRLUNGD", "STS_CILEG",
  "STS_CISEPTIC", "STS_CISTDEEP", "STS_CITHOR", "STS_CIUTI", "STS_CLASSCCS",
  "STS_CLASSNYH", "STS_CNCOMA", "STS_CNSTROKP", "STS_CNSTROKT", "STS_CNVINDIC",
  "STS_CNVSTDIN", "STS_COMPLICS", "STS_COPPERMI", "STS_COPREBLD", "STS_COPREGFT",
  "STS_COPRENON", "STS_COPREOTH", "STS_COPREVLV", "STS_CORSHUNT", "STS_COTAFIB",
  "STS_COTARRST", "STS_COTCOAG", "STS_COTGI", "STS_COTHTBLK", "STS_COTMSF",
  "STS_COTTAMP", "STS_CPBUSED", "STS_CPLEGIA", "STS_CPPNEUM", "STS_CPPULEMB",
  "STS_CPVNTLNG", "STS_CREATLST", "STS_CRENFAIL", "STS_CVA", "STS_CVAAODIS",
  "STS_CVAILFEM", "STS_CVALBISC", "STS_CVAWHEN", "STS_CVD", "STS_CVDTYPE",
  "STS_DIABCTRL", "STS_DIABETES", "STS_DIALYSIS", "STS_DISCHDT", "STS_DISTART",
  "STS_DISTVEIN", "STS_DOB", "STS_EMERGRSN", "STS_FHCAD", "STS_FLOWPTCY",
  "STS_GENDER", "STS_HDEF", "STS_HDEFMETH", "STS_HDPAMEAN", "STS_HEIGHTCM",
  "STS_HOSPNAME", "STS_HOSPSTAT", "STS_HOSPZIP", "STS_HYPERTN", "STS_HYPRCHOL",
  "STS_IABP", "STS_IABPIND", "STS_IABPWHEN", "STS_IMAARTUS", "STS_IMATECHN",
  "STS_IMMSUPP", "STS_INDMNINV", "STS_INFENDO", "STS_INFENDTY", "STS_ISCHTCFX",
  "STS_ISCHTLAD", "STS_ISCHTRCA", "STS_LMAINDIS", "STS_MEDACOAG", "STS_MEDASA",
  "STS_MEDBETA", "STS_MEDDIG", "STS_MEDDIUR", "STS_MEDINOTR", "STS_MEDNITIV",
  "STS_MEDRECN", "STS_MEDSTER", "STS_MI", "STS_MIWHEN", "STS_MTCAUSE",
  "STS_MTDATE", "STS_MTLOCATN", "STS_NUMDISV", "STS_NUMGEPDA", "STS_NUMIMADA",
  "STS_NUMINCIS", "STS_NUMRADDA", "STS_OCARAICD", "STS_OCARASD", "STS_OCARBATI",
  "STS_OCARCONG", "STS_OCARCRTX", "STS_OCARLASR", "STS_OCARLVA", "STS_OCAROTHR",
  "STS_OCARPACE", "STS_OCARTRMA", "STS_OCARVSD", "STS_ONCAOAN", "STS_ONCCAREN",
  "STS_ONCOTHOR", "STS_ONCOVASC", "STS_OPMININV", "STS_PATFNAME", "STS_PATLNAME",
  "STS_PATMINIT", "STS_PATZIP", "STS_PAYOR", "STS_PERFUSTM", "STS_PRCAB",
  "STS_PRCBNUM", "STS_PRCNNUM", "STS_PRCVINT", "STS_PRIMINC", "STS_PRNSBALL",
  "STS_PROTHCAR", "STS_PRPTCA", "STS_PRPTINTV", "STS_PRVALVE", "STS_PVD",
  "STS_RACE", "STS_RADARTUS", "STS_READM30", "STS_READMRSN", "STS_REFCARD",
  "STS_REFPHYS", "STS_RENFAIL", "STS_RESUSC", "STS_SAMEDAY", "STS_SMOKCURR",
  "STS_SMOKER", "STS_SSN", "STS_STATUS", "STS_SURGEON", "STS_SURGGRP",
  "STS_SUTRTECH", "STS_THRINTVL", "STS_THRMBLYS", "STS_URGNTRSN", "STS_VAD",
  "STS_VDINSUFA", "STS_VDINSUFM", "STS_VDINSUFP", "STS_VDINSUFT", "STS_VDSTENA",
  "STS_VDSTENM", "STS_VDSTENP", "STS_VDSTENT", "STS_VENTHRS", "STS_VSAOEX",
  "STS_VSAOEXSZ", "STS_VSAOEXTY", "STS_VSAOIM", "STS_VSAOIMSZ", "STS_VSAOIMTY",
  "STS_VSLSTBLZ", "STS_VSMIEX", "STS_VSMIEXSZ", "STS_VSMIEXTY", "STS_VSMIIM",
  "STS_VSMIIMSZ", "STS_VSMIIMTY", "STS_VSPUEX", "STS_VSPUEXSZ", "STS_VSPUEXTY",
  "STS_VSPUIM", "STS_VSPUIMSZ", "STS_VSPUIMTY", "STS_VSTREX", "STS_VSTREXSZ",
  "STS_VSTREXTY", "STS_VSTRIM", "STS_VSTRIMSZ", "STS_VSTRIMTY", "STS_WEIGHTKG",
  "STS_XCLAMPTM")
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->msg_report,cnt), internal->msg_report[cnt].xref_id = x
   .xref_id
  WITH nocounter
 ;end select
 IF (cnt != 196)
  SET failure = "T"
  CALL cv_log_message("Failure in selecting report xref_id's")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  nextseqnum = seq(long_data_seq,nextval)"##################;RP0"
  FROM dual
  DETAIL
   internal->msg_report_long_text_id = cnvtint(nextseqnum)
  WITH nocounter
 ;end select
 INSERT  FROM long_text l
  SET l.parent_entity_name = "CV_DATASET", l.long_text = "Data is missing", l.parent_entity_id =
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
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
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
