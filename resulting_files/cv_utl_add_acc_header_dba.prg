CREATE PROGRAM cv_utl_add_acc_header:dba
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
 RECORD acc_hd(
   1 hd[*]
     2 row = vc
     2 file_name = vc
     2 parent_entity_id = f8
     2 action_ind = i2
     2 long_text_id = f8
 )
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
 SET failed = "F"
 SET updt_cnt = 0
 SET num_files = 8
 SET stat = alterlist(acc_hd->hd,num_files)
 SET acc_hd->hd[1].row = "TRANSNUM|VENDOR|SFTVERS|NCDRVERS|PARTID|HOSP|"
 SET acc_hd->hd[1].file_name = "D9999991"
 SET acc_hd->hd[2].row =
 "TRANSNUM|PARTID|DPATID|DLNAME|DFNAME|DMINIT|DSSNO|DGENDER|DRACE|DDOB|ADOA|ADOD|ASTATUS|APAYOR|ANOPCI|"
 SET acc_hd->hd[2].row = concat(acc_hd->hd[2].row,
  "AMULT|ADCDSA|ADTCSA|MDST|MDTDEATH|MDEATH|MLOCDETH|RHEIGHT|RWEIGHT|RFCAD|")
 SET acc_hd->hd[2].row = concat(acc_hd->hd[2].row,
  "RCHF|RDIAB|RRF|RCLD|RCVD|RPVD|RMI|RHYPR|RSMKS|RHCL|PPCI|PDTPCI|PCAB|")
 SET acc_hd->hd[2].row = concat(acc_hd->hd[2].row,
  "PDTCAB|PVASU|PDTVASU|CSCHF|CSNYHA|CSISCH|CSANGT|CSANG|CSACS|")
 SET acc_hd->hd[2].file_name = "D9999992"
 SET acc_hd->hd[3].row =
 "TRANSNUM|PARTID|DPATID|ADOA|VDOP|VPROCNUM|VPROCTYP|VFLUORO|VCATHPCI|VTHRM|VBLOCK|VHEPARIN|"
 SET acc_hd->hd[3].row = concat(acc_hd->hd[3].row,
  "VASPIRIN|VCT|VIABP|VCPB|VLVNT|VLVST|VEFTEST|VLVEF|VDOM|VLM|VPLAD|VOLAD|")
 SET acc_hd->hd[3].row = concat(acc_hd->hd[3].row,
  "VRCA|VCIRC|VENTRY|VCLDEV|OPPMI|OCKULM|OCKBASE|OCKPEAK|OSHOCK|OCAR|OCVA|")
 SET acc_hd->hd[3].row = concat(acc_hd->hd[3].row,
  "OTAMP|OVASCBL|OVASCOCC|OVASCLDP|OVASCDIS|OVASCPSA|OVASCAVF|OCONRST|OCHF|")
 SET acc_hd->hd[3].row = concat(acc_hd->hd[3].row,"ORF|OEPCI|OUCAB")
 SET acc_hd->hd[3].file_name = "D9999993"
 SET acc_hd->hd[4].row =
 "TRANSNUM|PARTID|DPATID|ADOA|VDOP|VPROCNUM|CNAME|CSSNO|CURG|CCSHK|CVHD|CESDA|CISCH|CPFT|"
 SET acc_hd->hd[4].row = concat(acc_hd->hd[4].row,"CHDOE|CPLHT|CVDMITRL|CVDTRISC|CVDAORTA|CVDPULM|")
 SET acc_hd->hd[4].file_name = "D9999994"
 SET acc_hd->hd[5].row =
 "TRANSNUM|PARTID|DPATID|ADOA|VDOP|VPROCNUM|PNAME|PSSNO|PURG|PCORLES|PAMIP|PDOST|PDOBSD|PCSHK|"
 SET acc_hd->hd[5].row = concat(acc_hd->hd[5].row,"PATT|PSUCC|PREST|")
 SET acc_hd->hd[5].file_name = "D9999995"
 SET acc_hd->hd[6].row =
 "TRANSNUM|PARTID|DPATID|ADOA|VDOP|VPROCNUM|LLSNO|LSEGT|LGUIDE|LPRSTN|LPSSTN|LPRTIMI|LPSTIMI|LPDL|"
 SET acc_hd->hd[6].row = concat(acc_hd->hd[6].row,"LIGRT|LGRLC|LLEST|LDISS|LACCL|LSURE|LPERF|")
 SET acc_hd->hd[6].file_name = "D9999996"
 SET acc_hd->hd[7].row = "TRANSNUM|PARTID|DPATID|ADOA|VDOP|VPROCNUM|LLSNO|LDEVNUM|LDDEVICE|LDPTD|"
 SET acc_hd->hd[7].file_name = "D9999997"
 SET acc_hd->hd[8].row = "TRANSNUM|PARTID|DPATID|XDOF|XVITAL|XDEATH|XREADM|XRREASON|"
 SET acc_hd->hd[8].file_name = "D9999998"
 SET cv_dataset_id = 0.0
 SET failed = "F"
 SET dataset_internal_name = "ACC02"
 SET cnt = 0
 FOR (idx = 1 TO size(acc_hd->hd,5))
   SELECT INTO "nl:"
    *
    FROM cv_dataset cd,
     cv_dataset_file cdf
    PLAN (cdf
     WHERE cnvtupper(trim(cdf.name))=cnvtupper(trim(acc_hd->hd[idx].file_name)))
     JOIN (cd
     WHERE cd.dataset_internal_name=dataset_internal_name
      AND cd.dataset_id=cdf.dataset_id)
    DETAIL
     acc_hd->hd[idx].parent_entity_id = cdf.file_id
    WITH nocounter
   ;end select
 ENDFOR
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
  CALL cv_log_message("No such dataset or file_id in cv_dataset, cv_dataset_file tables!")
 ENDIF
 FOR (x = 1 TO size(acc_hd->hd,5))
   SELECT INTO "nl:"
    *
    FROM long_text lt
    PLAN (lt
     WHERE lt.parent_entity_name="CV_DATASET_FILE"
      AND (lt.parent_entity_id=acc_hd->hd[x].parent_entity_id))
    DETAIL
     acc_hd->hd[x].long_text_id = lt.long_text_id, acc_hd->hd[x].action_ind = 1
    WITH nocounter
   ;end select
 ENDFOR
 IF (curqual=0)
  CALL cv_log_message("There is a no acc header_row in long_text table, perform insertion!")
 ENDIF
 CALL echorecord(acc_hd)
 FOR (k = 1 TO size(acc_hd->hd,5))
   IF ((acc_hd->hd[k].action_ind=0))
    INSERT  FROM long_text lt
     SET lt.long_text_id = cnvtint(seq(card_vas_seq,nextval)), lt.long_text = acc_hd->hd[k].row, lt
      .parent_entity_id = acc_hd->hd[k].parent_entity_id,
      lt.parent_entity_name = "CV_DATASET_FILE", lt.active_ind = 1, lt.active_status_cd = reqdata->
      active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_cnt = 0, lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task,
      lt.updt_applctx = reqinfo->updt_applctx
     PLAN (lt
      WHERE (acc_hd->hd[k].action_ind=0))
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 IF (curqual=0)
  CALL cv_log_message("No record to insert into long_text table!")
 ELSE
  CALL cv_log_message("Records were inserted into long_text table!")
 ENDIF
 SELECT INTO "nl:"
  lt.updt_cnt
  FROM long_text lt,
   (dummyt d  WITH seq = value(size(acc_hd->hd,5)))
  PLAN (d
   WHERE (acc_hd->hd[d.seq].action_ind=1))
   JOIN (lt
   WHERE (lt.long_text_id=acc_hd->hd[d.seq].long_text_id))
  DETAIL
   updt_cnt = (updt_cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("No record to update in long_text table!")
 ENDIF
 SELECT INTO "nl:"
  lt.updt_cnt
  FROM long_text lt,
   (dummyt d  WITH seq = value(size(acc_hd->hd,5)))
  PLAN (d
   WHERE (acc_hd->hd[d.seq].action_ind=1))
   JOIN (lt
   WHERE (lt.long_text_id=acc_hd->hd[d.seq].long_text_id))
  WITH nocounter, forupdate(lt)
 ;end select
 IF (curqual != updt_cnt)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("Failed in locking rows in long_text!")
  GO TO exit_script
 ENDIF
 SET suc_cnt = 0
 FOR (i = 1 TO size(acc_hd->hd,5))
  UPDATE  FROM long_text lt
   SET lt.long_text_id = acc_hd->hd[i].long_text_id, lt.long_text = acc_hd->hd[i].row, lt
    .parent_entity_id = acc_hd->hd[i].parent_entity_id,
    lt.parent_entity_name = "CV_DATASET_FILE", lt.active_ind = 1, lt.active_status_cd = reqdata->
    active_status_cd,
    lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
    updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task,
    lt.updt_applctx = reqinfo->updt_applctx
   PLAN (lt
    WHERE (acc_hd->hd[i].action_ind=1)
     AND (lt.long_text_id=acc_hd->hd[i].long_text_id))
   WITH nocounter
  ;end update
  IF (curqual != 0)
   SET suc_cnt = (suc_cnt+ 1)
  ENDIF
 ENDFOR
 IF (((suc_cnt != updt_cnt) OR (updt_cnt=0)) )
  CALL cv_log_message("Failed in updating header row in long_text table!")
 ELSE
  CALL cv_log_message("Success in updating header row in long_text table!")
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
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
