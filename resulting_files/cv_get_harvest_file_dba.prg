CREATE PROGRAM cv_get_harvest_file:dba
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
 IF (validate(reply,"notdefined") != "notdefined")
  CALL cv_log_message("reply  is already defined !")
 ELSE
  RECORD reply(
    1 files[*]
      2 filename = vc
      2 info_line[*]
        3 new_line = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 cases_in_error_cnt = i4
  )
 ENDIF
 DECLARE stat = i4 WITH protect
 DECLARE file_cnt = i4 WITH protect
 DECLARE line_nbr = i4 WITH protect
 DECLARE err_case_cnt = i4 WITH protect
 DECLARE err_cnt = i4 WITH protect
 DECLARE case_date_meaning = vc WITH protect
 DECLARE case_dt_dta = f8 WITH protect
 DECLARE case_dt_ec = f8 WITH protect
 IF ((request->date_cd > 0))
  IF (validate(request_date,"notdefined") != "notdefined")
   CALL cv_log_message("request_date is already defined !")
  ELSE
   RECORD request_date(
     1 date_range[*]
       2 code_value = f8
       2 date_meaning = c12
       2 date_display = vc
       2 from_date_str = vc
       2 to_date_str = vc
       2 from_date = dq8
       2 to_date = dq8
   )
  ENDIF
  IF (validate(reply_date,"notdefined") != "notdefined")
   CALL cv_log_message("reply_date is already defined !")
  ELSE
   RECORD reply_date(
     1 date_range[*]
       2 to_date_str = vc
       2 from_date_str = vc
       2 to_date = dq8
       2 from_date = dq8
       2 translated_val = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  SET stat = alterlist(request_date->date_range,1)
  SET request_date->date_range[1].code_value = request->date_cd
  EXECUTE cv_get_date_range  WITH replace("REQUEST","REQUEST_DATE"), replace("REPLY","REPLY_DATE")
  FOR (i = 1 TO size(reply_date->date_range,5))
   SET request->start_dt = reply_date->date_range[i].from_date
   SET request->stop_dt = reply_date->date_range[i].to_date
  ENDFOR
 ELSE
  SET request->from_date_str = format(request->start_dt,"DD_MMM_YYYY;;D")
  SET request->to_date_str = format(request->stop_dt,"DD_MMM_YYYY;;D")
 ENDIF
 DECLARE g_status_noerror_cd = f8 WITH protect
 DECLARE g_status_error_cd = f8 WITH protect
 IF (validate(cv_internal_status,"notdefined")="notdefined")
  RECORD cv_internal_status(
    1 status[*]
      2 meaning = c12
      2 display = vc
      2 code_value = f8
  )
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=25973
   AND cv.cdf_meaning > " "
   AND cv.active_ind=1
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(cv_internal_status->status,cnt), cv_internal_status->status[cnt].
   meaning = cv.cdf_meaning,
   cv_internal_status->status[cnt].display = cv.display, cv_internal_status->status[cnt].code_value
    = cv.code_value
   IF (cv.cdf_meaning="HARVNOERROR")
    g_status_noerror_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="ERROR")
    g_status_error_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(request)
 EXECUTE cv_get_harvest_export
 CALL echorecord(reply)
 IF ( NOT (validate(err_request,0)))
  RECORD err_request(
    1 dataset_id = f8
    1 dateflag = i4
    1 maxqual = i4
    1 part_nbr[*]
      2 part_nbr = vc
    1 loc_facility[*]
      2 loc_facility_cd = f8
    1 personnel[*]
      2 person_id = f8
    1 person[*]
      2 person_id = f8
    1 status[*]
      2 status_cd = f8
    1 start_dt = dq8
    1 stop_dt = dq8
    1 date_cd = f8
    1 records[*]
      2 record_id = f8
    1 proc_type[*]
      2 proc_type_cd = f8
    1 patient[*]
      2 patient_id = vc
    1 physician[*]
      2 physician_id = f8
    1 omit_normal_data_ind = i2
    1 encounter[*]
      2 encntr_id = f8
  )
 ENDIF
 IF ( NOT (validate(temp_text,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
 ENDIF
 IF ( NOT (validate(case_date,0)))
  RECORD case_date(
    1 date = dq8
  )
 ENDIF
 SET err_request->dataset_id = request->dataset_id
 IF (size(trim(request->part_nbr)) > 0)
  SET stat = alterlist(err_request->part_nbr,1)
  SET err_request->part_nbr[1].part_nbr = request->part_nbr
 ENDIF
 IF ((request->loc_facility_cd > 0.0))
  SET stat = alterlist(err_request->loc_facility,1)
  SET err_request->loc_facility[1].loc_facility_cd = request->loc_facility_cd
 ENDIF
 SET err_request->start_dt = request->start_dt
 SET err_request->stop_dt = request->stop_dt
 SET err_request->date_cd = request->date_cd
 SET file_cnt = size(reply->files,5)
 SET file_cnt = (size(reply->files,5)+ 1)
 SET stat = alterlist(reply->files,file_cnt)
 SET reply->files[file_cnt].filename = "ErrorLog.txt"
 SET line_nbr = 0
 DECLARE filesub(linein=vc,stringin=vc,filecnt=i4) = f8
 DECLARE sepline = vc WITH protect, noconstant(
  "**************************************** Start ****************************************")
 DECLARE headinfo = vc WITH protect, noconstant("Head Information:")
 DECLARE spaceline = vc WITH protect, noconstant("  ")
 DECLARE dataid = vc WITH protect, noconstant(cnvtstring(request->dataset_id))
 DECLARE datasetstr = vc WITH protect, noconstant(concat("Dataset ID:     ",dataid))
 DECLARE partnbrstr = vc WITH protect, noconstant(concat("Participant Number:   ",request->part_nbr))
 DECLARE cdmeaning = vc WITH protect, noconstant(uar_get_code_display(request->loc_facility_cd))
 DECLARE start_dt_str = vc WITH protect, noconstant(format(request->start_dt,"DD-MMM-YYYY;;D"))
 DECLARE startstr = vc WITH protect, noconstant(concat("Start Date:    ",start_dt_str))
 DECLARE stop_dt_str = vc WITH protect, noconstant(format(request->stop_dt,"DD-MMM-YYYY;;D"))
 DECLARE stopstr = vc WITH protect, noconstant(concat("Stop Date:     ",stop_dt_str))
 DECLARE locfacstr = vc WITH protect
 DECLARE export_person_name = vc WITH protect
 IF ((request->loc_facility_cd=0.0))
  SET cdmeaning = "All"
 ENDIF
 SET locfacstr = concat("Location Facility: ",cdmeaning)
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM person p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   export_person_name = build("Exported by : ",p.name_full_formatted)
  WITH nocounter
 ;end select
 CALL filesub(line_nbr,sepline,file_cnt)
 CALL filesub(line_nbr,headinfo,file_cnt)
 CALL filesub(line_nbr,spaceline,file_cnt)
 CALL filesub(line_nbr,datasetstr,file_cnt)
 CALL filesub(line_nbr,partnbrstr,file_cnt)
 CALL filesub(line_nbr,locfacstr,file_cnt)
 CALL filesub(line_nbr,export_person_name,file_cnt)
 CALL filesub(line_nbr,startstr,file_cnt)
 CALL filesub(line_nbr,stopstr,file_cnt)
 DECLARE thenum = vc WITH protect
 DECLARE breakline = vc WITH protect
 DECLARE caselable = vc WITH protect
 DECLARE casehead = vc WITH protect
 DECLARE name_full_formatted = vc WITH protect
 DECLARE person_id = vc WITH protect
 DECLARE encntr_id = vc WITH protect
 DECLARE ptname = vc WITH protect
 DECLARE psid = vc WITH protect
 DECLARE ecntid = vc WITH protect
 DECLARE case_id = vc WITH protect
 DECLARE caseid = vc WITH protect
 DECLARE recordidstr = vc WITH protect
 DECLARE recordstr = vc WITH protect
 DECLARE harvestdate = vc WITH protect
 DECLARE chart_dt_tm = vc WITH protect
 DECLARE harvest_dt_tm = vc WITH protect
 DECLARE chartdate = vc WITH protect
 DECLARE case_dt = vc WITH protect
 DECLARE sgdttm = vc WITH protect
 DECLARE case_err_msg = vc WITH protect
 DECLARE msg_fld = vc WITH protect
 DECLARE fieldhead = vc WITH protect
 DECLARE endline = vc WITH protect
 DECLARE detailcasefromaudit(n=i4) = null WITH protect
 DECLARE auditfordataset(dataset_id=f8) = null WITH protect
 DECLARE prevdatasetid = f8 WITH protect
 DECLARE stempline = vc WITH protect
 DECLARE prevdispname = vc WITH protect
 DECLARE curdispname = vc WITH protect
 IF ((request->file_type_ind=2))
  SELECT
   d.dataset_id, d.display_name
   FROM cv_dataset d
   WHERE d.dataset_internal_name="STS*"
   ORDER BY d.dataset_internal_name
   HEAD REPORT
    l_dprevid = 0.0, l_sprevdispname = ""
   DETAIL
    IF ((d.dataset_id=request->dataset_id))
     prevdatasetid = l_dprevid, prevdispname = l_sprevdispname, curdispname = d.display_name
    ENDIF
    l_dprevdispname = d.display_name, l_dprevid = d.dataset_id
   WITH nocounter
  ;end select
  IF (prevdatasetid > 0.0)
   SET stempline =
   "************************ Multiple Datasets in Export *****************************"
   CALL filesub(line_nbr,stempline,file_cnt)
   SET stempline = concat("Dataset Name: ",prevdispname)
   CALL filesub(line_nbr,stempline,file_cnt)
   SET stempline =
   "************************ Begin First Dataset *************************************"
   CALL filesub(line_nbr,stempline,file_cnt)
   CALL auditfordataset(prevdatasetid)
   SET stempline =
   "************************ Begin Second Dataset ************************************"
   CALL filesub(line_nbr,stempline,file_cnt)
   SET stempline = concat("Dataset Name : ",prevdispname)
   CALL filesub(line_nbr,stempline,file_cnt)
  ENDIF
 ENDIF
 CALL auditfordataset(request->dataset_id)
 SET endline = "************************************ The End *************************************"
 CALL filesub(line_nbr,endline,file_cnt)
 EXECUTE cv_log_struct  WITH replace("REQUEST","REPLY")
 SUBROUTINE auditfordataset(dataset_id)
   FREE RECORD err_reply
   RECORD err_reply(
     1 caserec[*]
       2 case_id = f8
       2 error_msg = vc
       2 status_cd = f8
       2 status_disp = vc
       2 status_mean = vc
       2 chart_dt_tm = dq8
       2 person_id = f8
       2 encntr_id = f8
       2 name_full_formatted = vc
       2 form_id = f8
       2 form_ref_id = f8
       2 record_id = f8
       2 fieldrec[*]
         3 field_name = vc
         3 field_val = vc
         3 error_msg = vc
         3 status_cd = f8
         3 status_disp = vc
         3 status_mean = vc
         3 translated_val = vc
         3 case_field_id = f8
         3 long_text_id = f8
         3 dev_idx = i2
         3 lesion_idx = i2
         3 form_idx = i2
       2 sub_case[*]
         3 case_id = f8
         3 form_type_mean = vc
         3 form_id = f8
         3 form_ref_id = f8
     1 files[*]
       2 filename = vc
       2 info_line[*]
         3 new_line = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
     1 max_sub_case_cnt = i4
     1 case_ids[*]
       2 cv_case_id = f8
   )
   SET err_request->dataset_id = dataset_id
   EXECUTE cv_get_harvest_audit  WITH replace("REQUEST","ERR_REQUEST"), replace("REPLY","ERR_REPLY")
   EXECUTE cv_log_struct  WITH replace("REQUEST","ERR_REPLY")
   SET err_case_cnt = size(err_reply->caserec,5)
   DECLARE totalcases = vc
   SET totalcases = cnvtstring(err_case_cnt)
   DECLARE casetotal = vc
   SET casetotal = concat("Total Cases:    ",totalcases)
   CALL filesub(line_nbr,casetotal,file_cnt)
   DECLARE datasetinternalname = vc
   DECLARE surgdt2_cd = f8
   DECLARE surgdt3_cd = f8
   DECLARE mtopd2_cd = f8
   DECLARE mtopd3_cd = f8
   DECLARE operativedeathtotal = vc
   DECLARE surgdt_cnt = i4
   DECLARE mtopd_cnt = i4
   SELECT INTO "nl:"
    FROM cv_dataset cvd
    WHERE (cvd.dataset_id=request->dataset_id)
    DETAIL
     datasetinternalname = cvd.dataset_internal_name
    WITH nocounter
   ;end select
   IF ((request->file_type_ind=2))
    IF (((datasetinternalname="STS02") OR (datasetinternalname="STS03")) )
     SELECT INTO "nl:"
      FROM cv_xref x
      WHERE x.xref_internal_name IN ("ST02_SURGDT", "STS03_SURGDT", "ST02_MTOPD", "STS03_MTOPD")
      DETAIL
       CASE (x.xref_internal_name)
        OF "ST02_SURGDT":
         surgdt2_cd = x.event_cd
        OF "STS03_SURGDT":
         surgdt3_cd = x.event_cd
        OF "ST02_MTOPD":
         mtopd2_cd = x.event_cd
        OF "STS03_MTOPD":
         mtopd3_cd = x.event_cd
       ENDCASE
      WITH nocounter
     ;end select
     SELECT DISTINCT INTO "nl:"
      FROM cv_case_abstr_data cad,
       cv_case_abstr_data cad2,
       cv_case_abstr_data cad3,
       cv_case_dataset_r ccdr,
       cv_case cvc
      PLAN (cad
       WHERE cad.event_cd IN (surgdt2_cd, surgdt3_cd)
        AND cad.result_dt_tm BETWEEN cnvtdatetime(request->start_dt) AND cnvtdatetime(request->
        stop_dt))
       JOIN (cad2
       WHERE cad2.event_cd=outerjoin(mtopd2_cd)
        AND cad2.cv_case_id=outerjoin(cad.cv_case_id))
       JOIN (cad3
       WHERE cad3.event_cd=outerjoin(mtopd3_cd)
        AND cad3.cv_case_id=outerjoin(cad.cv_case_id))
       JOIN (ccdr
       WHERE ccdr.cv_case_id=cad.cv_case_id
        AND (ccdr.participant_nbr=request->part_nbr))
       JOIN (cvc
       WHERE cvc.cv_case_id=cad.cv_case_id
        AND (((cvc.hospital_cd=request->loc_facility_cd)) OR ((request->loc_facility_cd=0))) )
      ORDER BY cad.cv_case_id
      HEAD REPORT
       surgdt_cnt = 0, mtopd_cnt = 0
      DETAIL
       surgdt_cnt = (surgdt_cnt+ 1)
       IF (((cad2.result_val="Yes") OR (cad3.result_val="Yes")) )
        mtopd_cnt = (mtopd_cnt+ 1)
       ENDIF
      WITH nocounter
     ;end select
     SET operativedeathtotal = concat("Operative Deaths:  ",cnvtstring(mtopd_cnt))
     CALL filesub(line_nbr,operativedeathtotal,file_cnt)
    ENDIF
   ELSEIF ((request->file_type_ind < 2)
    AND datasetinternalname="STS02")
    SELECT INTO "nl:"
     FROM cv_xref x
     WHERE x.xref_internal_name IN ("ST02_SURGDT", "ST02_MTOPD")
     DETAIL
      CASE (x.xref_internal_name)
       OF "ST02_SURGDT":
        surgdt2_cd = x.event_cd
       OF "ST02_MTOPD":
        mtopd2_cd = x.event_cd
      ENDCASE
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     FROM cv_case_abstr_data cad,
      cv_case_abstr_data cad2,
      cv_case_dataset_r ccdr,
      cv_case cvc
     PLAN (cad
      WHERE cad.event_cd=surgdt2_cd
       AND cad.result_dt_tm BETWEEN cnvtdatetime(request->start_dt) AND cnvtdatetime(request->stop_dt
       ))
      JOIN (cad2
      WHERE cad2.event_cd=outerjoin(mtopd2_cd)
       AND cad2.cv_case_id=outerjoin(cad.cv_case_id))
      JOIN (ccdr
      WHERE ccdr.cv_case_id=cad.cv_case_id
       AND (ccdr.participant_nbr=request->part_nbr))
      JOIN (cvc
      WHERE cvc.cv_case_id=cad.cv_case_id
       AND (((cvc.hospital_cd=request->loc_facility_cd)) OR ((request->loc_facility_cd=0.0))) )
     ORDER BY cad.cv_case_id
     HEAD REPORT
      surgdt_cnt = 0, mtopd_cnt = 0
     DETAIL
      surgdt_cnt = (surgdt_cnt+ 1)
      IF (cad2.result_val="Yes")
       mtopd_cnt = (mtopd_cnt+ 1)
      ENDIF
     WITH nocounter
    ;end select
    SET operativedeathtotal = concat("Operative Deaths:  ",cnvtstring(mtopd_cnt))
    CALL filesub(line_nbr,operativedeathtotal,file_cnt)
   ELSEIF ((request->file_type_ind < 2)
    AND datasetinternalname="STS03")
    SELECT INTO "nl:"
     FROM cv_xref x
     WHERE x.xref_internal_name IN ("STS03_SURGDT", "STS03_MTOPD")
     DETAIL
      CASE (x.xref_internal_name)
       OF "STS03_SURGDT":
        surgdt3_cd = x.event_cd
       OF "STS03_MTOPD":
        mtopd3_cd = x.event_cd
      ENDCASE
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     FROM cv_case_abstr_data cad,
      cv_case_abstr_data cad2,
      cv_case_dataset_r ccdr,
      cv_case cvc
     PLAN (cad
      WHERE cad.event_cd IN (surgdt3_cd)
       AND cad.result_dt_tm BETWEEN cnvtdatetime(request->start_dt) AND cnvtdatetime(request->stop_dt
       ))
      JOIN (cad2
      WHERE cad2.event_cd=outerjoin(mtopd3_cd)
       AND cad2.cv_case_id=outerjoin(cad.cv_case_id))
      JOIN (ccdr
      WHERE ccdr.cv_case_id=cad.cv_case_id
       AND (ccdr.participant_nbr=request->part_nbr))
      JOIN (cvc
      WHERE cvc.cv_case_id=cad.cv_case_id
       AND (((cvc.hospital_cd=request->loc_facility_cd)) OR ((request->loc_facility_cd=0.0))) )
     ORDER BY cad.cv_case_id
     HEAD REPORT
      surgdt_cnt = 0, mtopd_cnt = 0
     DETAIL
      surgdt_cnt = (surgdt_cnt+ 1)
      IF (cad2.result_val="Yes")
       mtopd_cnt = (mtopd_cnt+ 1)
      ENDIF
     WITH nocounter
    ;end select
    SET operativedeathtotal = concat("Operative Deaths:  ",cnvtstring(mtopd_cnt))
    CALL filesub(line_nbr,operativedeathtotal,file_cnt)
   ENDIF
   IF (err_case_cnt=0)
    DECLARE msg_case = vc
    SET msg_case =
    "******************************* No Errors & Warnings *****************************"
    CALL filesub(line_nbr,msg_case,file_cnt)
   ENDIF
   IF (validate(reply->files,"-1") != "-1")
    SET err_cnt = size(reply->files[file_cnt].info_line,5)
   ENDIF
   SET case_date_meaning = fillstring(12," ")
   SELECT INTO "nl:"
    FROM cv_dataset d
    WHERE d.dataset_id != 0.0
     AND (d.dataset_id=err_request->dataset_id)
    DETAIL
     case_date_meaning = d.case_date_mean
    WITH nocounter
   ;end select
   SET case_dt_dta = 0.0
   SET case_dt_ec = 0.0
   SET stat = uar_get_meaning_by_codeset(14003,case_date_meaning,1,case_dt_dta)
   SELECT INTO "nl:"
    FROM discrete_task_assay dta
    WHERE dta.task_assay_cd=case_dt_dta
    DETAIL
     case_dt_ec = dta.event_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_log_message("Case Date Event Code not found!")
   ENDIF
   FOR (n = 1 TO err_case_cnt)
     CALL detailcasefromaudit(n)
   ENDFOR
 END ;Subroutine
 SUBROUTINE detailcasefromaudit(err_case_cnt)
   SET spaceline = " "
   SET thenum = cnvtstring(n)
   SET breakline = "************************************"
   SET caselable = concat(breakline," Case ",thenum," of ",totalcases,
    " ",breakline)
   SET casehead = "Case Header:"
   SET name_full_formatted = err_reply->caserec[n].name_full_formatted
   SET person_id = cnvtstring(err_reply->caserec[n].person_id)
   SET encntr_id = cnvtstring(err_reply->caserec[n].encntr_id)
   SET ptname = concat("Patient Name:  ",name_full_formatted)
   SET psid = concat("Person ID: ",person_id)
   SET ecntid = concat("Encounter ID:  ",encntr_id)
   SET case_id = cnvtstring(err_reply->caserec[n].case_id)
   SET caseid = concat("Case ID: ",case_id)
   DECLARE recordidstr = vc WITH protect
   DECLARE recordstr = vc WITH protect
   DECLARE harvestdate = vc WITH protect
   DECLARE err_fld_cnt = i4 WITH protect
   DECLARE record_id = f8 WITH protect
   IF ((((err_reply->caserec[n].status_cd=g_status_error_cd)) OR ((err_reply->caserec[n].status_cd=
   0.0))) )
    SET reply->cases_in_error_cnt = (reply->cases_in_error_cnt+ 1)
   ENDIF
   SELECT INTO "nl:"
    FROM cv_case_dataset_r ccdr
    WHERE (ccdr.cv_case_id=err_reply->caserec[n].case_id)
    DETAIL
     record_id = ccdr.registry_nbr, harvest_dt_tm = format(ccdr.updt_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")
    WITH nocounter
   ;end select
   SET recordidstr = cnvtstring(record_id)
   SET recordstr = concat("Record ID:  ",recordidstr)
   SET harvestdate = concat("Harvest Date: ",harvest_dt_tm)
   SET chart_dt_tm = format(err_reply->caserec[n].chart_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D")
   SET chartdate = concat("Chart Date: ",chart_dt_tm)
   SELECT INTO "nl:"
    FROM cv_case_abstr_data ccad
    WHERE (ccad.cv_case_id=err_reply->caserec[n].case_id)
     AND ccad.event_cd=case_dt_ec
    DETAIL
     case_date->date = ccad.result_dt_tm
    WITH nocounter
   ;end select
   SET case_dt = format(case_date->date,"DD-MMM-YYYY;;D")
   SET sgdttm = concat("Case Date: ",case_dt)
   SET case_err_msg = err_reply->caserec[n].error_msg
   SET err_fld_cnt = size(err_reply->caserec[n].fieldrec,5)
   CALL filesub(line_nbr,spaceline,file_cnt)
   CALL filesub(line_nbr,caselable,file_cnt)
   CALL filesub(line_nbr,casehead,file_cnt)
   CALL filesub(line_nbr,spaceline,file_cnt)
   CALL filesub(line_nbr,ptname,file_cnt)
   CALL filesub(line_nbr,psid,file_cnt)
   CALL filesub(line_nbr,ecntid,file_cnt)
   CALL filesub(line_nbr,caseid,file_cnt)
   CALL filesub(line_nbr,recordstr,file_cnt)
   CALL filesub(line_nbr,harvestdate,file_cnt)
   CALL filesub(line_nbr,chartdate,file_cnt)
   CALL filesub(line_nbr,sgdttm,file_cnt)
   CALL filesub(line_nbr,case_err_msg,file_cnt)
   IF ((err_reply->caserec[n].status_cd=g_status_noerror_cd))
    SET msg_fld = "****************************** No Field Errors ******************************"
    CALL filesub(line_nbr,msg_fld,file_cnt)
   ELSE
    SET fieldhead = "Field Header: "
    SET spaceline = "  "
    CALL filesub(line_nbr,fieldhead,file_cnt)
    CALL filesub(line_nbr,spaceline,file_cnt)
   ENDIF
   FOR (icnt = 1 TO size(cv_internal_status->status,5))
     IF ((cv_internal_status->status[icnt].meaning != "HARVNOERROR"))
      CALL createlogforstatus(cv_internal_status->status[icnt].code_value,cv_internal_status->status[
       icnt].display,n)
     ENDIF
   ENDFOR
   SET spaceline = " "
   CALL filesub(line_nbr,spaceline,file_cnt)
 END ;Subroutine
 SUBROUTINE createlogforstatus(param_status_cd,param_status_disp,param_case_idx)
   DECLARE errinfo = vc WITH protect
   DECLARE errheader = vc WITH protect
   DECLARE field_name = vc WITH protect
   DECLARE fld_str = vc WITH protect
   DECLARE err_fld_cnt = i4 WITH protect
   DECLARE i = i4 WITH protect
   SET i = 0
   FOR (m = 1 TO err_fld_cnt)
     IF ((err_reply->caserec[param_case_idx].fieldrec[m].status_cd=param_status_cd))
      SET i = (i+ 1)
      IF (i=1)
       SET spaceline = "                 "
       SET errheader = concat("Fields with ",param_status_disp,": ")
       CALL filesub(line_nbr,spaceline,file_cnt)
       CALL filesub(line_nbr,errheader,file_cnt)
       CALL filesub(line_nbr,spaceline,file_cnt)
      ENDIF
      SET spaceline = "                 "
      SET field_name = err_reply->caserec[param_case_idx].fieldrec[m].field_name
      SET fld_str = concat("  ",field_name)
      CALL filesub(line_nbr,spaceline,file_cnt)
      CALL filesub(line_nbr,fld_str,file_cnt)
      SELECT INTO "nl:"
       FROM dummyt
       HEAD REPORT
        left_margin = 12, right_margin = 80, spaces = 32,
        lf = 10, cr = 13, tab = 9,
        tabptr = 0, line = fillstring(125,"-"), print_text = fillstring(10000," "),
        text = fillstring(100," "), copiedtext = fillstring(108," "), tabspace = fillstring(4," "),
        max_text_len = 0, ptr = 0, start_col = 0,
        start_pos = 0, last_space_pos = 0, last_new_line = 0,
        text_len = 0, print_max_row = maxrow, print_dio_ind = 0,
        adjusted_initial_start_col = 4, cnt = 0,
        MACRO (print_comments_routine)
         IF (adjusted_initial_start_col=0)
          start_col = left_margin
         ELSE
          start_col = adjusted_initial_start_col
         ENDIF
         tabspace = "   ", start_pos = 0, last_space_pos = 0,
         text_len = 0, text = "", ptr = 1,
         max_text_len = size(trim(print_text),3), cnt = 0
         WHILE (ptr <= max_text_len)
           text_char = substring(ptr,1,print_text)
           IF (ichar(text_char) < spaces)
            IF (((ichar(text_char)=cr) OR (ichar(text_char) != lf
             AND ichar(text_char) != tab)) )
             IF (start_pos > 0)
              text = substring(start_pos,text_len,print_text), col start_col, text,
              cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt), temp_text->qual[cnt].text = text
              IF (tabptr > 0)
               copiedtext = build(char(9),substring(start_pos,text_len,print_text)), tabptr = 0, col
               start_col,
               copiedtext, cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt),
               temp_text->qual[cnt].text = copiedtext, copiedtext = ""
              ELSE
               tabptr = 0, col start_col, text,
               cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt), temp_text->qual[cnt].text =
               copiedtext
              ENDIF
             ELSE
              col start_col, " "
             ENDIF
             IF (last_new_line=0)
              row + 1, last_new_line = 1
              IF ((row >= (print_max_row - 2)))
               BREAK
              ENDIF
             ELSE
              last_new_line = 0
             ENDIF
             IF (print_dio_ind=1)
              start_col = (left_margin - 1)
             ELSE
              start_col = left_margin
             ENDIF
             start_pos = 0, last_space_pos = 0, text_len = 0,
             text = ""
            ENDIF
            IF (((ichar(text_char) != cr) OR (ichar(text_char)=lf
             AND ichar(text_char) != tab)) )
             last_new_line = 0
             IF (text_len > 0)
              text = substring(start_pos,text_len,print_text), cnt = (cnt+ 1), stat = alterlist(
               temp_text->qual,cnt),
              temp_text->qual[cnt].text = text
              IF (tabptr > 0)
               copiedtext = concat(tabspace,substring(start_pos,text_len,print_text)), tabptr = 0,
               col start_col,
               copiedtext, cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt),
               temp_text->qual[cnt].text = copiedtext, copiedtext = ""
              ELSE
               tabptr = 0, col start_col, text,
               cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt), temp_text->qual[cnt].text =
               copiedtext
              ENDIF
              start_col = (size(text,2)+ left_margin)
             ENDIF
             start_col = (start_col+ 1)
             IF (start_col >= right_margin)
              row + 1
              IF (print_dio_ind=1)
               start_col = (left_margin - 1)
              ELSE
               start_col = left_margin
              ENDIF
             ENDIF
             IF ((row >= (print_max_row - 2)))
              BREAK
             ENDIF
             start_pos = (ptr+ 1), last_space_pos = 0, text_len = 0,
             text = ""
            ENDIF
            IF (ichar(text_char)=tab)
             tabptr = ptr
            ENDIF
           ELSEIF (ichar(text_char) >= spaces)
            IF (start_pos=0)
             start_pos = ptr
            ENDIF
            IF (ichar(text_char)=spaces)
             last_space_pos = ptr
            ENDIF
            text_len = (text_len+ 1)
            IF (((start_col+ text_len) >= right_margin))
             IF (last_space_pos > 0)
              text_len = ((last_space_pos - start_pos)+ 1), ptr = last_space_pos
             ENDIF
             text = substring(start_pos,text_len,print_text)
             IF (tabptr > 0)
              copiedtext = concat(tabspace,substring(start_pos,(text_len+ 4),print_text)), tabptr = 0,
              col start_col,
              copiedtext, cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt),
              temp_text->qual[cnt].text = copiedtext, copiedtext = ""
             ELSE
              tabptr = 0, col start_col, text,
              cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt), temp_text->qual[cnt].text = text
             ENDIF
             col start_col, text, row + 1,
             start_col = left_margin, start_pos = 0, last_space_pos = 0,
             text_len = 0, text = ""
             IF ((row >= (print_max_row - 2)))
              BREAK
             ENDIF
            ENDIF
           ELSE
            text_len = (text_len+ 1)
           ENDIF
           ptr = (ptr+ 1)
         ENDWHILE
         IF (text_len > 0)
          text = substring(start_pos,text_len,print_text), col start_col, text,
          cnt = (cnt+ 1), stat = alterlist(temp_text->qual,cnt), temp_text->qual[cnt].text = text,
          row + 1, start_col = left_margin, start_pos = 0,
          last_space_pos = 0, text_len = 0, text = ""
          IF ((row >= (print_max_row - 2)))
           BREAK
          ENDIF
         ENDIF
         print_text = fillstring(10000," ")
        ENDMACRO
       DETAIL
        cnt = 0, stat = alterlist(temp_text->qual,0), stat = alterlist(temp_text->qual,125),
        print_text = err_reply->caserec[param_case_idx].fieldrec[m].error_msg
        IF (size(trim(print_text)) > 0)
         print_comments_routine
         FOR (var = 1 TO cnt)
          errinfo = concat("    ",temp_text->qual[var].text),
          CALL filesub(line_nbr,errinfo,file_cnt)
         ENDFOR
        ENDIF
       WITH nocounter, maxcol = 10000
      ;end select
      IF (curqual=0)
       SET cv_log_level = cv_log_info
       CALL cv_log_message("Failed in select from dummyt dual table!")
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE filesub(linein,stringin,filecnt)
   DECLARE stringout = vc WITH protect
   SET line_nbr = linein
   SET line_nbr = (line_nbr+ 1)
   SET stringout = stringin
   SET file_cnt = filecnt
   IF (validate(reply->files,"-1") != "-1")
    SET stat = alterlist(reply->files[file_cnt].info_line,line_nbr)
    SET reply->files[file_cnt].info_line[line_nbr].new_line = stringout
   ELSE
    SET stat = 0
   ENDIF
 END ;Subroutine
#exit_script
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
 DECLARE cv_get_harvest_file_vrsn = vc WITH private, constant("016 05/23/2007 BM9013")
END GO
