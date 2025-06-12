CREATE PROGRAM cv_utl_add_sts2_header:dba
 DECLARE header_row = vc
 SET header_row = fillstring(32000," ")
 SET header_row = "VendorID|SoftVrsn|DataVrsn|ParticID|RecordID|PatID|RecComp|DOB|Age|Gender|"
 SET header_row = concat(header_row,"PatZIP|Race|HospName|HospZIP|HospStat|AdmitDt|SurgDt|")
 SET header_row = concat(header_row,
  "DischDt|SameDay|ICUInHrs|ICUReadm|ICUAdHrs|TotHrICU|WeightKg|HeightCm|Smoker|SmokCurr|")
 SET header_row = concat(header_row,
  "FHCAD|Diabetes|DiabCtrl|Hyprchol|CreatLst|RenFail|Dialysis|Hypertn|CVA|CVAWhen|InfEndo|")
 SET header_row = concat(header_row,
  "InfEndTy|ChrLungD|ImmSupp|PVD|CVD|CVDType|PrCVInt|PrCBNum|PrCNNum|PrCAB|PrValve|")
 SET header_row = concat(header_row,
  "PrOthCar|PrPTCA|PrPTIntv|PrNSStnt|StntIntv|Thrmblys|ThrIntvl|PrNSBall|")
 SET header_row = concat(header_row,"MI|MIWhen|CHF|Angina|AngType|AngUnstT|CarShock|CarShTyp|Resusc|"
  )
 SET header_row = concat(header_row,
  "Arrhyth|ArrhyTyp|ClassCCS|ClassNYH|MedDig|MedBeta|MedACEI|MedNitIV|")
 SET header_row = concat(header_row,
  "MedAPlt|MedACoag|MedDiur|MedInotr|MedSter|MedASA|NumDisV|LMainDis|")
 SET header_row = concat(header_row,
  "HDEFD|HDEF|HDEFMeth|HDPAD|HDPAMean|VDStenA|VDGradA|VDStenM|VDStenT|")
 SET header_row = concat(header_row,
  "VDStenP|VDInsufA|VDInsufM|VDInsufT|VDInsufP|Surgeon|SurgGrp|Status|")
 SET header_row = concat(header_row,
  "UrgntRsn|EmergRsn|OpCAB|OpAortic|OpMitral|OpTricus|OpPulm|OpOCard|")
 SET header_row = concat(header_row,"OpONCard|CABUnpln|DistArt|DistVein|IMAArtUs|NumIMADA|RadArtUs|")
 SET header_row = concat(header_row,
  "NumRadDA|NumGEPDA|VSAoImTy|VSAoIm|VSAoImSz|VSAoExTy|VSAoEx|VSAoExSz|")
 SET header_row = concat(header_row,
  "VSMiImTy|VSMiIm|VSMiImSz|VSMiExTy|VSMiEx|VSMiExSz|VSTrImTy|VSTrIm|")
 SET header_row = concat(header_row,
  "VSTrImSz|VSTrExTy|VSTrEx|VSTrExSz|VSPuImTy|VSPuIm|VSPuImSz|VSPuExTy|")
 SET header_row = concat(header_row,
  "VSPuEx|VSPuExSz|CPBUsed|ConvCPB|IndMnInv|PrimInc|NumIncis|CnvStdIn|")
 SET header_row = concat(header_row,"CnvIndic|Cannulat|AortOccl|CorShunt|SutrTech|VslStblz|IMATechn|"
  )
 SET header_row = concat(header_row,
  "FlowPtcy|OCarLVA|OCarVSD|OCarASD|OCarBati|OCarSVR|OCarCong|OCarLasr|")
 SET header_row = concat(header_row,"OCarTrma|OCarCrTx|OCarPace|OCarAICD|OCarOthr|ONCAoAn|ONCCarEn|")
 SET header_row = concat(header_row,"ONCOVasc|ONCOThor|SIStartT|SIStopT|XClampTm|PerfusTm|Cplegia|")
 SET header_row = concat(header_row,"IABP|IABPWhen|IABPInd|VAD|BldProd|VentHrsI|ReIntub|VentHrs|")
 SET header_row = concat(header_row,"Complics|COpReBld|COpReVlv|COpReGft|COpReOth|COpReNon|")
 SET header_row = concat(header_row,"COpPerMI|CIStDeep|CIThor|CILeg|CISeptic|CIUTI|CNStrokP|")
 SET header_row = concat(header_row,
  "CNStrokT|CNComa|CPVntLng|CPPulEmb|CPPneum|CRenFail|CRenDial|CVaAoDis|")
 SET header_row = concat(header_row,"CVaIlFem|CVaLbIsc|COtHtBlk|COtArrst|COtCoag|COtTamp|")
 SET header_row = concat(header_row,
  "COtGI|COtMSF|COtAFib|DCASA|DCACE|DCBeta|DCLipid|DCAntPlt|DisLoctn|")
 SET header_row = concat(header_row,
  "Mortalty|MtDCStat|Mt30Stat|MtOpD|MtDate|MtLocatn|MtCause|Readm30|")
 SET header_row = concat(header_row,
  "ReadmRsn|PredMort|PredDeep|PredReop|PredStro|PredVent|PredRenF|PredMM|")
 SET header_row = concat(header_row,"Pred6D|Pred14D|")
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  SET null_date = "31-DEC-2100 00:00:00"
  SET cv_log_debug = 5
  SET cv_log_info = 4
  SET cv_log_audit = 3
  SET cv_log_warning = 2
  SET cv_log_error = 1
  SET cv_log_handle_cnt = 1
  SET cv_log_handle = 0
  SET cv_log_status = 0
  SET cv_log_level = 0
  SET cv_log_echo_level = 0
  SET cv_log_error_time = 0
  SET cv_log_error_file = 1
  SET cv_log_error_string = fillstring(32000," ")
  SET cv_err_msg = fillstring(100," ")
  SET cv_log_err_num = 0
  SET cv_log_file_name = build("cer_temp:CV_DEFAULT",format(cnvtdatetime(curdate,curtime3),
    "HHMMSS;;q"),".dat")
  SET cv_log_struct_file_name = build("cer_temp:",curprog)
  SET cv_log_struct_file_nbr = 0
  SET cv_log_event = "CV_DEFAULT_LOG"
  SET cv_log_level = cv_log_debug
  SET cv_def_log_level = cv_log_debug
  SET cv_log_echo_level = cv_log_debug
  SET cv_log_chg_to_default = 1
  SET cv_log_error_time = 1
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
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
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
   ENDIF
   SET reply->status_data.subeventstatus[num_event].targetobjectname = object_name_param
   SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
   SET reply->status_data.subeventstatus[num_event].operationname = operation_name_param
   SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
 SET cv_dataset_id = 0.0
 SET dataset_internal_name = "STS02"
 SELECT INTO "nl:"
  *
  FROM cv_dataset cd
  WHERE trim(cnvtupper(cd.dataset_internal_name))=dataset_internal_name
  DETAIL
   cv_dataset_id = cd.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("No such dataset in cv_dataset table!")
 ENDIF
 RECORD files(
   1 file_list[*]
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 long_text_id = f8
     2 ins_upd_ind = i2
 )
 SELECT INTO "nl:"
  *
  FROM cv_dataset_file cdf
  WHERE cdf.dataset_id=cv_dataset_id
   AND cdf.file_id > 0
  HEAD REPORT
   file_cnt = 0
  DETAIL
   file_cnt = (file_cnt+ 1), stat = alterlist(files->file_list,file_cnt), files->file_list[file_cnt].
   parent_entity_name = cdf.name,
   files->file_list[file_cnt].parent_entity_id = cdf.file_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No such dataset in cv_dataset_file table!")
 ENDIF
 FOR (i = 1 TO size(files->file_list,5))
   SELECT INTO "nl:"
    *
    FROM long_text lt
    PLAN (lt
     WHERE trim(lt.parent_entity_name)=trim(files->file_list[i].parent_entity_name)
      AND (lt.parent_entity_id=files->file_list[i].parent_entity_id)
      AND lt.parent_entity_id > 0)
    DETAIL
     files->file_list[i].long_text_id = lt.long_text_id, files->file_list[i].ins_upd_ind = 1
    WITH nocounter
   ;end select
 ENDFOR
 IF (curqual=0)
  CALL cv_log_message("No header_row in long_text table, do insertion!")
 ENDIF
 FOR (i = 1 TO size(files->file_list,5))
   IF ((files->file_list[i].ins_upd_ind=0))
    INSERT  FROM long_text lt
     SET lt.long_text_id = cnvtint(seq(card_vas_seq,nextval)), lt.long_text = header_row, lt
      .parent_entity_id = files->file_list[i].parent_entity_id,
      lt.parent_entity_name = files->file_list[i].parent_entity_name, lt.active_ind = 1, lt
      .active_status_cd = reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
      updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      lt.updt_cnt = 0, lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task,
      lt.updt_applctx = reqinfo->updt_applctx
     PLAN (lt
      WHERE (files->file_list[i].ins_upd_ind=0))
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL cv_log_message("Failed in inserting header row to long_text table!")
    ENDIF
   ENDIF
 ENDFOR
 SET updt_cnt = 0
 SELECT INTO "nl:"
  lt.updt_cnt
  FROM long_text lt,
   (dummyt d  WITH seq = value(size(files->file_list,5)))
  PLAN (d
   WHERE (files->file_list[d.seq].ins_upd_ind=1))
   JOIN (lt
   WHERE (lt.long_text_id=files->file_list[d.seq].long_text_id))
  DETAIL
   updt_cnt = (updt_cnt+ 1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failed in select long_text to get updt_cnt!")
 ENDIF
 SELECT INTO "nl:"
  lt.updt_cnt
  FROM long_text lt,
   (dummyt d  WITH seq = value(size(files->file_list,5)))
  PLAN (d
   WHERE (files->file_list[d.seq].ins_upd_ind=1))
   JOIN (lt
   WHERE (lt.long_text_id=files->file_list[d.seq].long_text_id))
  WITH nocounter, forupdate(lt)
 ;end select
 IF (curqual != updt_cnt)
  CALL cv_log_message("Failed in select long_text for lock the row, program continue!")
 ENDIF
 SET temp_cnt = 0
 FOR (k = 1 TO size(files->file_list,5))
  UPDATE  FROM long_text lt
   SET lt.long_text = header_row, lt.parent_entity_id = files->file_list[k].parent_entity_id, lt
    .parent_entity_name = files->file_list[k].parent_entity_name,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt
    .updt_cnt = (lt.updt_cnt+ 1),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx
   PLAN (lt
    WHERE (files->file_list[k].long_text_id > 0)
     AND (files->file_list[k].ins_upd_ind=1)
     AND (lt.long_text_id=files->file_list[k].long_text_id))
   WITH nocounter
  ;end update
  IF (curqual != 0)
   SET temp_cnt = (temp_cnt+ 1)
  ENDIF
 ENDFOR
 CALL echorecord(files)
 IF (((temp_cnt != updt_cnt) OR (updt_cnt=0)) )
  CALL cv_log_message("Failed in updating header row in long_text table!")
 ELSE
  CALL cv_log_message("Success in updating header row in long_text table!")
 ENDIF
 COMMIT
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
