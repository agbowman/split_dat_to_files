CREATE PROGRAM cv_utl_add_sts_header:dba
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
 IF (validate(files,"notdefined") != "notdefined")
  CALL echo("Files Record is already defined!")
 ELSE
  RECORD files(
    1 file_list[*]
      2 parent_entity_name = vc
      2 parent_entity_id = f8
      2 long_text_id = f8
      2 ins_upd_ind = i2
  )
 ENDIF
 DECLARE failure = c1 WITH public, noconstant("F")
 DECLARE header_row = vc WITH public, noconstant(" ")
 SET header_row =
 "VendorID|SoftVrsn|DataVrsn|ParticID|RecordID|CostLink|STSTLink|PatID|DOB|Age|Gender|PatZIP|Race|HospName|HospZIP|"
 SET header_row = concat(header_row,
  "HospStat|AdmitDt|SurgDt|DischDt|SameDay|WeightKg|HeightCm|Smoker|SmokCurr|FHCAD|Diabetes|")
 SET header_row = concat(header_row,
  "DiabCtrl|Hyprchol|RenFail|CreatLst|Dialysis|Hypertn|CVA|CVAWhen|InfEndo|InfEndTy|ChrLungD|")
 SET header_row = concat(header_row,
  "ImmSupp|PVD|CVD|CVDType|PrCVInt|PrCBNum|PrCNNum|PrCAB|PrValve|PrOthCar|PrPTCA|PrPTIntv|")
 SET header_row = concat(header_row,
  "PrNSStnt|Thrmblys|ThrIntvl|PrNSBall|MI|MIWhen|CHF|Angina|AngType|AngUnstT|CarShock|")
 SET header_row = concat(header_row,
  "CarShTyp|Resusc|Arrhyth|ArrhyTyp|ClassCCS|ClassNYH|MedDig|MedBeta|MedNitIV|MedACoag|")
 SET header_row = concat(header_row,
  "MedDiur|MedInotr|MedSter|MedASA|NumDisV|LMainDis|HDEF|HDEFMeth|HDPAMean|VDStenA|VDStenM|")
 SET header_row = concat(header_row,
  "VDStenT|VDStenP|VDInsufA|VDInsufM|VDInsufT|VDInsufP|Surgeon|SurgGrp|Status|UrgntRsn|")
 SET header_row = concat(header_row,
  "EmergRsn|OpCAB|OpAortic|OpMitral|OpTricus|OpPulm|OpOCard|OpONCard|PredMort|")
 SET header_row = concat(header_row,
  "CABUnpln|DistArt|DistVein|IMAArtUs|NumIMADA|RadArtUs|NumRadDA|NumGEPDA|VSAoImTy|VSAoIm|")
 SET header_row = concat(header_row,
  "VSAoImSz|VSAoExTy|VSAoEx|VSAoExSz|VSMiImTy|VSMiIm|VSMiImSz|VSMiExTy|VSMiEx|VSMiExSz|")
 SET header_row = concat(header_row,
  "VSTrImTy|VSTrIm|VSTrImSz|VSTrExTy|VSTrEx|VSTrExSz|VSPuImTy|VSPuIm|VSPuImSz|VSPuExTy|")
 SET header_row = concat(header_row,
  "VSPuEx|VSPuExSz|IndMnInv|PrimInc|NumIncis|CnvStdIn|CnvIndic|CPBUsed|Cannulat|AortOccl|")
 SET header_row = concat(header_row,"CorShunt|SutrTech|VslStblz|IMATechn|FlowPtcy|OCarLVA|OCarVSD|")
 SET header_row = concat(header_row,
  "OCarASD|OCarBati|OCarCong|OCarLasr|OCarTrma|OCarCrTx|OCarPace|OCarAICD|OCarOthr|ONCAoAn|")
 SET header_row = concat(header_row,
  "ONCCarEn|ONCOVasc|ONCOThor|XClampTm|PerfusTm|Cplegia|IABP|IABPWhen|IABPInd|VAD|BldProd|")
 SET header_row = concat(header_row,
  "VentHrs|Complics|COpReBld|COpReVlv|COpReGft|COpReOth|COpReNon|COpPerMI|CIStDeep|CIThor|")
 SET header_row = concat(header_row,
  "CILeg|CISeptic|CIUTI|CNStrokP|CNStrokT|CNComa|CPVntLng|CPPulEmb|CPPneum|CRenFail|CVaAoDis|")
 SET header_row = concat(header_row,
  "CVaIlFem|CVaLbIsc|COtHtBlk|COtArrst|COtCoag|COtTamp|COtGI|COtMSF|COtAFib|MtDCStat|Mt30Stat|")
 SET header_row = concat(header_row,
  "MtDate|MtLocatn|MtCause|MtOpD|Readm30|ReadmRsn|ICUInHrs|ICUReadm|ICUAdHrs|TotHrICU|")
 SET header_row = concat(header_row,
  "StntIntv|MedACEI|MedAPlt|VDGradA|HDEFD|HDPAD|ConvCPB|OCarSVR|SIStartT|SIStopT|")
 SET header_row = concat(header_row,
  "VentHrsI|VentHrsA|ReIntub|CRenDial|DCASA|DCACE|DCBeta|DCLipid|DCAntPlt|DisLoctn|")
 SET header_row = concat(header_row,
  "Mortalty|PredDeep|PredReop|PredStro|PredVent|PredRenF|PredMM|Pred6D|Pred14D")
 DECLARE cv_dataset_id = f8 WITH public, noconstant(0.0)
 DECLARE dataset_internal_name = vc WITH public, noconstant("STS")
 DECLARE dataset_cnt = i2 WITH public, noconstant(0)
#next_dataset
 SELECT INTO "nl:"
  *
  FROM cv_dataset cd
  WHERE trim(cd.dataset_internal_name)=dataset_internal_name
  DETAIL
   cv_dataset_id = cd.dataset_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("No such dataset in cv_dataset table!")
 ENDIF
 SELECT INTO "nl:"
  *
  FROM cv_dataset_file cdf
  WHERE cdf.dataset_id=cv_dataset_id
   AND cdf.file_id > 0
  HEAD REPORT
   file_cnt = 0
  DETAIL
   file_cnt = (file_cnt+ 1), stat = alterlist(files->file_list,file_cnt), files->file_list[file_cnt].
   parent_entity_name = "CV_DATASET_FILE",
   files->file_list[file_cnt].parent_entity_id = cdf.file_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No such dataset in cv_dataset_file table!")
  SET failure = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  *
  FROM long_text lt,
   (dummyt d  WITH seq = value(size(files->file_list,5)))
  PLAN (d)
   JOIN (lt
   WHERE lt.parent_entity_name=trim(cnvtupper(files->file_list[d.seq].parent_entity_name))
    AND (lt.parent_entity_id=files->file_list[d.seq].parent_entity_id)
    AND lt.parent_entity_id > 0)
  DETAIL
   files->file_list[d.seq].long_text_id = lt.long_text_id, files->file_list[d.seq].ins_upd_ind = 1
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No header_row in long_text table, do insertion!")
 ENDIF
 INSERT  FROM long_text lt,
   (dummyt d  WITH seq = value(size(files->file_list,5)))
  SET lt.long_text_id = cnvtint(seq(long_data_seq,nextval)), lt.long_text = header_row, lt
   .parent_entity_id = files->file_list[d.seq].parent_entity_id,
   lt.parent_entity_name = files->file_list[d.seq].parent_entity_name, lt.active_ind = 1, lt
   .active_status_cd = reqdata->active_status_cd,
   lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
   updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   lt.updt_cnt = 0, lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task,
   lt.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (files->file_list[d.seq].ins_upd_ind=0))
   JOIN (lt)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL cv_log_message("Failed in inserting header row to long_text table!")
 ENDIF
 SET updt_cnt = 0
 SELECT INTO "nl:"
  lt.*
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
  lt.*
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
 UPDATE  FROM long_text lt,
   (dummyt d  WITH seq = value(size(files->file_list,5)))
  SET lt.long_text = header_row, lt.parent_entity_id = files->file_list[d.seq].parent_entity_id, lt
   .parent_entity_name = files->file_list[d.seq].parent_entity_name,
   lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   lt.active_status_prsnl_id = reqinfo->updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt
   .updt_cnt = (lt.updt_cnt+ 1),
   lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (files->file_list[d.seq].long_text_id > 0))
   JOIN (lt
   WHERE (files->file_list[d.seq].ins_upd_ind=1)
    AND (lt.long_text_id=files->file_list[d.seq].long_text_id))
  WITH nocounter
 ;end update
 IF (curqual != updt_cnt)
  CALL cv_log_message(build("Failed in updating header row in long_text table for--",
    dataset_internal_name))
 ELSE
  CALL cv_log_message(build("Success in updating header row in long_text table for--",
    dataset_internal_name))
 ENDIF
 SET dataset_cnt = (dataset_cnt+ 1)
 IF (dataset_cnt=1)
  SET dataset_internal_name = "STS02"
  CALL cv_log_message("*****************************************")
  CALL cv_log_message("Starting process STS 2.41 dataset header!")
  CALL cv_log_message("*****************************************")
  GO TO next_dataset
 ENDIF
#exit_script
 IF (failure="T")
  CALL echo("Update is roll backed!")
  ROLLBACK
 ELSE
  CALL echo("Update is already Committed!")
  COMMIT
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
