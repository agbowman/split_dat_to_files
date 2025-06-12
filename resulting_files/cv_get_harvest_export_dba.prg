CREATE PROGRAM cv_get_harvest_export:dba
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
 DECLARE geteventcd(prmmeaning=vc) = f8
 DECLARE getcvcontrol(paramdatasetid=f8,paramuniquestring=vc) = i4
 DECLARE getseason(paramdatecd=f8) = c1
 DECLARE getcuryr(paramdatecd=f8) = i4
 DECLARE fmt_mean = c12 WITH protect
 DECLARE iret = i2 WITH protect
 DECLARE the_dta = f8 WITH protect
 DECLARE return_ec = f8 WITH protect
 DECLARE return_nbr = i4 WITH protect
 DECLARE fall_mean = c12 WITH protect
 DECLARE spring_mean = c12 WITH protect
 DECLARE fall_cd = f8 WITH protect
 DECLARE spring_cd = f8 WITH protect
 DECLARE fall_any_mean = c12 WITH protect
 DECLARE spring_any_mean = c12 WITH protect
 DECLARE fall_any_cd = f8 WITH protect
 DECLARE spring_any_cd = f8 WITH protect
 DECLARE cv_date_set = i4 WITH protect
 DECLARE retseason = c1 WITH protect
 DECLARE century19 = i2 WITH protect
 DECLARE century20 = i2 WITH protect
 DECLARE ret_yr = i4 WITH protect
 SUBROUTINE geteventcd(prmmeaning)
   IF (size(trim(prmmeaning)) > 12)
    CALL echo(build("String too long to be CDF meaning:",prmmeaning))
    RETURN(0.0)
   ENDIF
   SET fmt_mean = trim(prmmeaning)
   SET the_dta = 0.0
   SET return_ec = 0.0
   SET the_dta = uar_get_code_by("MEANING",14003,nullterm(fmt_mean))
   IF (the_dta=0.0)
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=14003
      AND cv.cdf_meaning=fmt_mean
      AND cv.active_ind=1
     DETAIL
      the_dta = cv.code_value
     WITH nocounter, maxqual(cv,1)
    ;end select
   ENDIF
   IF (the_dta=0.0)
    CALL echo(build("Could not locate CDF meaning in CS 14003:",fmt_mean))
    RETURN(0.0)
   ENDIF
   SELECT INTO "nl:"
    FROM discrete_task_assay dta
    WHERE dta.task_assay_cd=the_dta
    DETAIL
     return_ec = dta.event_cd
    WITH nocounter
   ;end select
   RETURN(return_ec)
 END ;Subroutine
 SUBROUTINE getcvcontrol(paramdatasetid,paramuniquestring)
   SET return_nbr = 0
   SELECT INTO "nl:"
    FROM dm_prefs dp
    WHERE dp.pref_domain IN ("CVNET", "CVNet")
     AND dp.parent_entity_id=paramdatasetid
     AND dp.parent_entity_name="CV_DATASET"
     AND cnvtupper(trim(dp.pref_section,3))=cnvtupper(trim(paramuniquestring,3))
    DETAIL
     return_nbr = dp.pref_nbr
    WITH nocounter
   ;end select
   RETURN(return_nbr)
 END ;Subroutine
 SUBROUTINE getseason(paramdatecd)
   SET cv_date_set = 25832
   SET fall_mean = "FALLCURYEAR"
   SET spring_mean = "SPRINGCURYR"
   SET fall_any_mean = "FALLANYYEAR"
   SET spring_any_mean = "SPRINGANYYR"
   SET spring_cd = uar_get_code_by("MEANING",cv_date_set,spring_mean)
   SET fall_cd = uar_get_code_by("MEANING",cv_date_set,fall_mean)
   SET spring_any_cd = uar_get_code_by("MEANING",cv_date_set,spring_any_mean)
   SET fall_any_cd = uar_get_code_by("MEANING",cv_date_set,fall_any_mean)
   IF (((spring_cd=paramdatecd) OR (spring_any_cd=paramdatecd)) )
    SET retseason = "S"
   ENDIF
   IF (((fall_cd=paramdatecd) OR (fall_any_cd=paramdatecd)) )
    SET retseason = "F"
   ENDIF
   RETURN(retseason)
 END ;Subroutine
 SUBROUTINE getcuryr(paramdatecd)
   SET century19 = 0
   SET century20 = 0
   SET cv_date_set = 25832
   SET fall_mean = "FALLCURYEAR"
   SET spring_mean = "SPRINGCURYR"
   SET fall_any_mean = "FALLANYYEAR"
   SET spring_any_mean = "SPRINGANYYR"
   SET spring_cd = uar_get_code_by("MEANING",cv_date_set,spring_mean)
   SET fall_cd = uar_get_code_by("MEANING",cv_date_set,fall_mean)
   SET spring_any_cd = uar_get_code_by("MEANING",cv_date_set,spring_any_mean)
   SET fall_any_cd = uar_get_code_by("MEANING",cv_date_set,fall_any_mean)
   IF (((spring_cd=paramdatecd) OR (fall_cd=paramdatecd)) )
    SET ret_yr = 0
   ENDIF
   IF (((spring_any_cd=paramdatecd) OR (fall_any_cd=paramdatecd)) )
    SET paramdatedisp = uar_get_code_display(paramdatecd)
    SET century19 = findstring("19",trim(paramdatedisp,3))
    SET century20 = findstring("20",trim(paramdatedisp,3))
    IF (century19 > 0)
     SET ret_yr = cnvtint(substring(century19,4,trim(paramdatedisp,3)))
    ELSEIF (century20 > 0)
     SET ret_yr = cnvtint(substring(century20,4,trim(paramdatedisp,3)))
    ELSE
     SET ret_yr = 0
    ENDIF
   ENDIF
   RETURN(ret_yr)
 END ;Subroutine
 IF ( NOT (validate(fu_event,0)))
  RECORD fu_event(
    1 event[*]
      2 parent_event_id = f8
      2 cv_case_id = f8
      2 num_reasons = i4
      2 sub_event[*]
        3 event_id = f8
        3 event_cd = f8
        3 result_val = vc
        3 nomenclature_id = f8
        3 translate_value = vc
        3 position = i4
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
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
  )
 ENDIF
 IF ( NOT (validate(header,0)))
  RECORD header(
    1 hd_rows[*]
      2 the_header = vc
      2 file_name = vc
      2 file_id = f8
  )
 ENDIF
 FREE RECORD suppress
 RECORD suppress(
   1 dataset[*]
     2 dataset_id = f8
     2 file[*]
       3 file_id = f8
       3 field[*]
         4 position = i4
 )
 CALL echorecord(request,"cer_temp:cv_export_req.txt")
 DECLARE dmvcurid = f8 WITH protect
 DECLARE dmvprevid = f8 WITH protect
 DECLARE dmvcurdtcd = f8 WITH protect
 DECLARE dmvprevdtcd = f8 WITH protect
 DECLARE smvcurdtmean = vc WITH protect
 DECLARE smvprevdtmean = vc WITH protect
 DECLARE sfailed = c1 WITH protect, noconstant("F")
 DECLARE stat = i4 WITH protect
 DECLARE max_file = i4 WITH protect
 DECLARE acc_or_sts_ind = i2 WITH protect
 DECLARE export_sts_flag = i2 WITH protect
 DECLARE export_sts02_flag = i2 WITH protect
 DECLARE export_both_sts_flag = i2 WITH protect
 DECLARE export_both_sts2_flag = i2 WITH protect
 DECLARE export_sts03_flag = i2 WITH protect
 SET acc_or_sts_ind = getcvcontrol(request->dataset_id,"CV_FLAG_CTRL_ACC_OR_STS_ETC")
 SET export_sts_flag = getcvcontrol(request->dataset_id,"CV_EXECUTE_STS_IN_EXPORT")
 SET export_sts02_flag = getcvcontrol(request->dataset_id,"CV_EXECUTE_STS02_IN_EXPORT")
 SET export_both_sts_flag = getcvcontrol(request->dataset_id,"CV_EXPORT_BOTH_STS_FLAG")
 SET export_both_sts2_flag = getcvcontrol(request->dataset_id,"CV_EXPORT_BOTH_STS2_FLAG")
 SET export_sts03_flag = getcvcontrol(request->dataset_id,"CV_EXECUTE_STS03_IN_EXPORT")
 DECLARE cv_acc_transnum_str = vc WITH protect
 DECLARE dataset_ctrl_str = vc WITH protect, noconstant("cd.dataset_id = request->dataset_id")
 DECLARE acc_admin_line = vc WITH protect
 DECLARE cv_dataset_string = vc WITH protect
 DECLARE surg_dt_str = vc WITH protect, noconstant("ccad.event_cd = surg_dt_ec")
 DECLARE filerow = vc WITH protect
 DECLARE accv3_ind = i2 WITH protect
 DECLARE registry_version = i2 WITH protect
 SET registry_version = getcvcontrol(request->dataset_id,"REGISTRY_VERSION")
 IF (((export_both_sts_flag=1) OR (((export_both_sts2_flag=1) OR ((request->file_type_ind=2))) )) )
  SET dataset_ctrl_str = "cd.DATASET_INTERNAL_NAME like 'STS*'"
 ENDIF
 CALL echo(build("dataset_ctrl_str: ",dataset_ctrl_str))
 IF ((request->file_type_ind=2))
  SELECT INTO "nl:"
   cd.dataset_internal_name, cd.dataset_id, cd.case_date_mean
   FROM cv_dataset cd
   WHERE cd.dataset_internal_name="STS*"
   ORDER BY cd.dataset_internal_name
   DETAIL
    dmvprevid = dmvcurid, smvprevdtmean = smvcurdtmean, dmvcurid = cd.dataset_id,
    smvcurdtmean = cd.case_date_mean
   WITH nocounter
  ;end select
  CALL echo(build("Current Dataset ID  =",dmvcurid))
  CALL echo(build("Previous Dataset ID =",dmvprevid))
  IF (dmvprevid > 0.0)
   SET cv_dataset_string = build("ccdr.dataset_id in (",dmvprevid,",",dmvcurid,")")
   SET dmvcurdtcd = geteventcd(smvcurdtmean)
   SET dmvprevdtcd = geteventcd(smvprevdtmean)
   SET surg_dt_str = build("ccad.event_cd in (",dmvprevdtcd,",",dmvcurdtcd,")")
  ELSE
   SET cv_dataset_string = build("ccdr.dataset_id =",request->dataset_id)
   CALL echo("No second STS dataset found, reverting to non-multi-version")
   SET request->file_type_ind = 1
  ENDIF
 ELSE
  SET cv_dataset_string = build("ccdr.dataset_id = ",request->dataset_id)
 ENDIF
 CALL echo(build("cv_dataset_string: ",cv_dataset_string))
 DECLARE status_cd = f8 WITH protect
 DECLARE status_mean = c12 WITH protect, noconstant("ERROR")
 DECLARE status_cd_str = vc WITH protect, noconstant("0=0")
 SET stat = uar_get_meaning_by_codeset(25973,status_mean,1,status_cd)
 CALL echo(build("STATUS_CD=",status_cd))
 IF (((export_sts_flag=1) OR (((export_sts02_flag=1) OR (export_sts03_flag=1)) )) )
  IF ((request->status_type_ind > 0))
   SET status_cd_str = "(ccdr.status_cd != STATUS_CD) and (ccdr.status_cd > 0.0)"
  ENDIF
 ENDIF
 DECLARE case_date_mean = c12 WITH protect
 DECLARE surg_dt_ec = f8 WITH protect
 SELECT INTO "nl:"
  FROM cv_dataset cd
  WHERE (cd.dataset_id=request->dataset_id)
  DETAIL
   case_date_mean = cd.case_date_mean
  WITH nocounter
 ;end select
 CALL echo(build("request->dataset_id: ",request->dataset_id))
 CALL echo(build("CASE_DATE_MEAN: ",case_date_mean))
 SET surg_dt_ec = geteventcd(case_date_mean)
 CALL echo(build("SURG_DT_EC: ",surg_dt_ec))
 DECLARE search_file_raw = vc WITH protect, constant("_RAW")
 DECLARE search_file_cmb = vc WITH protect, constant("_CMB")
 DECLARE file_id_str = vc WITH protect, noconstant("0=0")
 IF (acc_or_sts_ind=2)
  CASE (request->file_type_ind)
   OF 0:
    SET file_id_str = "(df.file_nbr = 1 or df.file_nbr = 2)"
   OF 1:
    SET file_id_str = "(df.file_nbr = 1)"
   OF 2:
    SET file_id_str = "(df.file_nbr = 3)"
  ENDCASE
 ELSEIF (acc_or_sts_ind=1
  AND registry_version=3)
  CASE (request->file_type_ind)
   OF 0:
    SET file_id_str = "(df.file_nbr between 1 and 9)"
   OF 1:
    SET file_id_str = "(df.file_nbr between 10 and 18)"
  ENDCASE
 ELSE
  SET file_id_str = "(0=0)"
 ENDIF
 DECLARE part_nbr_str = vc WITH private, noconstant("0=0")
 IF (size(trim(request->part_nbr)) > 0)
  SET part_nbr_str = "ccdr.participant_nbr = request->part_nbr"
 ELSE
  CALL cv_log_message("No participant selected, export aborted")
  SET sfailed = "T"
  GO TO exit_script
 ENDIF
 DECLARE facility_str = vc WITH private, noconstant("0=0")
 IF ((request->loc_facility_cd != 0.0))
  SET facility_str = "c.hospital_cd = request->loc_facility_cd"
 ENDIF
 DECLARE vert_bar = c1 WITH protect, constant("|")
 DECLARE short_str = vc WITH protect
 SELECT INTO "nl:"
  cxf.display_name
  FROM cv_dataset_file df,
   cv_xref_field cxf
  PLAN (df
   WHERE (df.dataset_id=request->dataset_id)
    AND parser(file_id_str))
   JOIN (cxf
   WHERE df.file_id=cxf.file_id)
  ORDER BY df.file_id, cxf.position
  HEAD REPORT
   hd_cnt = 0, stat = alterlist(header->hd_rows,5)
  HEAD df.file_id
   short_str_cnt = 0, hd_cnt = (hd_cnt+ 1)
   IF (hd_cnt > size(header->hd_rows,5))
    stat = alterlist(header->hd_rows,(hd_cnt+ 9))
   ENDIF
   header->hd_rows[hd_cnt].file_id = df.file_id, header->hd_rows[hd_cnt].file_name = df.name
  DETAIL
   short_str_cnt = (short_str_cnt+ 1), short_str = cxf.display_name
   IF (short_str_cnt=1
    AND registry_version=3
    AND acc_or_sts_ind=1)
    header->hd_rows[hd_cnt].the_header = concat("TRANSNUM|PARTID|",short_str)
   ELSEIF (short_str_cnt=1
    AND ((registry_version != 3) OR (acc_or_sts_ind != 1)) )
    header->hd_rows[hd_cnt].the_header = concat(short_str)
   ELSE
    header->hd_rows[hd_cnt].the_header = concat(header->hd_rows[hd_cnt].the_header,vert_bar,short_str
     )
   ENDIF
  FOOT REPORT
   stat = alterlist(header->hd_rows,hd_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Header building failed!")
 ELSE
  CALL echo("Header building success!")
  CALL echorecord(header)
 ENDIF
 DECLARE proc_ec_test = vc WITH protect
 DECLARE minimum_age = i4 WITH protect
 DECLARE fu_only = c1 WITH protect, noconstant("F")
 IF (acc_or_sts_ind=1)
  SET minimum_age = 18
  IF (registry_version >= 3)
   SET accv3_ind = 1
  ENDIF
  IF (trim(request->part_nbr)="")
   SET sfailed = "T"
   CALL cv_log_message("ACC export requires selection of a participant")
   GO TO exit_script
  ENDIF
  CALL echo("Execute ACC Section!!")
  CALL echo(build("facility_str: ",facility_str))
  CALL echo(build("start date: ",format(request->start_dt,"mm/dd/yyyy;;d")))
  CALL echo(build("stop date: ",format(request->stop_dt,"mm/dd/yyyy;;d")))
  SELECT INTO "NL:"
   nextseqnum = seq(cv_acc_transnum_seq,nextval)
   FROM dual
   DETAIL
    cv_acc_transnum_str = cnvtstring(nextseqnum)
   WITH format
  ;end select
  CALL echo(build("cv_acc_transnum_str: ",cv_acc_transnum_str))
  IF (accv3_ind=0)
   DECLARE proctyp_ec = f8 WITH protect
   SET proctyp_ec = geteventcd("AC02VPROCTYP")
   SET proc_ec_test = "ccad.event_cd = PROCTYP_EC "
  ENDIF
  CALL echo(build("proc_ec_test:",proc_ec_test))
  FREE RECORD cv_proc_case
  RECORD cv_proc_case(
    1 list[*]
      2 cv_case_id = f8
  )
  DECLARE case_cnt = i4 WITH protect
  SET stat = alterlist(cv_proc_case->list,0)
  CALL echo(build("accv3_ind =",accv3_ind))
  SELECT
   IF (accv3_ind=1)
    FROM cv_case cc,
     cv_case_dataset_r ccdr
    PLAN (cc
     WHERE cc.pat_disch_dt_tm BETWEEN cnvtdatetime(cnvtdate(request->start_dt),0) AND cnvtdatetime(
      cnvtdate(request->stop_dt),235959)
      AND cc.cv_case_id != 0.0)
     JOIN (ccdr
     WHERE ccdr.cv_case_id=cc.cv_case_id
      AND (ccdr.dataset_id=request->dataset_id)
      AND (ccdr.participant_nbr=request->part_nbr))
    WITH nocounter
   ELSE
   ENDIF
   INTO "nl:"
   form_type_mean = uar_get_code_meaning(cc.form_type_cd), ccdr.case_dataset_r_id, null_age = nullind
   (cc.age)
   FROM cv_case_abstr_data ccad,
    cv_case cc,
    cv_case_dataset_r ccdr
   PLAN (cc
    WHERE cc.pat_disch_dt_tm BETWEEN cnvtdatetime(cnvtdate(request->start_dt),0) AND cnvtdatetime(
     cnvtdate(request->stop_dt),235959)
     AND cc.cv_case_id != 0.0)
    JOIN (ccdr
    WHERE parser(status_cd_str)
     AND ccdr.cv_case_id=cc.cv_case_id
     AND (ccdr.dataset_id=request->dataset_id)
     AND (ccdr.participant_nbr=request->part_nbr))
    JOIN (ccad
    WHERE ccdr.cv_case_id=ccad.cv_case_id
     AND ccad.event_cd=proctyp_ec)
   ORDER BY cc.encntr_id, form_type_mean, cc.case_dt_tm,
    cc.form_id
   HEAD REPORT
    case_cnt = 0, stat = alterlist(cv_proc_case->list,10)
   HEAD cc.encntr_id
    IF (null_age=0
     AND cc.age < minimum_age)
     exclude_case = 1
    ELSE
     exclude_case = 0
    ENDIF
   DETAIL
    IF (exclude_case=0)
     case_cnt = (case_cnt+ 1)
     IF (case_cnt > size(cv_proc_case->list,5))
      stat = alterlist(cv_proc_case->list,(case_cnt+ 9))
     ENDIF
     cv_proc_case->list[case_cnt].cv_case_id = cc.cv_case_id
    ENDIF
   FOOT REPORT
    stat = alterlist(cv_proc_case->list,case_cnt)
   WITH nocounter
  ;end select
  CALL echorecord(cv_proc_case)
  SET fu_only = "F"
  DECLARE total_file = i4 WITH protect, noconstant(8)
  IF (accv3_ind)
   SET total_file = 9
  ENDIF
  SET stat = alterlist(reply->files,total_file)
  DECLARE file_str = vc WITH protect
  IF (((accv3_ind=1
   AND (request->file_type_ind=0)) OR (accv3_ind=0)) )
   FOR (file_nbr = 1 TO total_file)
    SET file_str = cnvtstring(file_nbr)
    SET reply->files[file_nbr].filename = concat("D",trim(request->part_nbr),trim(file_str))
   ENDFOR
  ENDIF
  IF (accv3_ind=1)
   CALL accadmin(null)
  ENDIF
  SELECT INTO "nl:"
   cc.encntr_id, cc.chart_dt_tm, df.file_id
   FROM (dummyt d  WITH seq = value(size(header->hd_rows,5))),
    (dummyt d1  WITH seq = value(size(cv_proc_case->list,5))),
    cv_case cc,
    cv_case_dataset_r ccdr,
    cv_dataset_file df,
    cv_case_file_row cf,
    long_text l
   PLAN (cc
    WHERE cc.pat_disch_dt_tm BETWEEN cnvtdatetime(cnvtdate(request->start_dt),0) AND cnvtdatetime(
     cnvtdate(request->stop_dt),235959))
    JOIN (d1
    WHERE (cc.cv_case_id=cv_proc_case->list[d1.seq].cv_case_id))
    JOIN (ccdr
    WHERE parser(status_cd_str)
     AND ccdr.cv_case_id=cc.cv_case_id
     AND (ccdr.dataset_id=request->dataset_id)
     AND parser(part_nbr_str))
    JOIN (df
    WHERE df.dataset_id=ccdr.dataset_id)
    JOIN (d
    WHERE cnvtupper(trim(df.name))=cnvtupper(trim(header->hd_rows[d.seq].file_name))
     AND (df.file_id=header->hd_rows[d.seq].file_id))
    JOIN (cf
    WHERE cf.file_id=df.file_id
     AND cf.case_dataset_r_id=ccdr.case_dataset_r_id)
    JOIN (l
    WHERE l.long_text_id=cf.long_text_id)
   ORDER BY df.file_id, cc.encntr_id, cnvtdatetime(cc.chart_dt_tm) DESC
   HEAD REPORT
    cntf = 0, cntn = 0, clear = "F",
    encntr_holder = 0
    IF (accv3_ind=1)
     stat = alterlist(reply->files[1].info_line,1), reply->files[1].info_line[1].new_line = build(
      cv_acc_transnum_str,df.delimiter,request->part_nbr,acc_admin_line), low_bound = 2,
     top_bound = total_file
    ELSE
     top_bound = (total_file - 1), low_bound = 1
    ENDIF
   HEAD cf.file_id
    cntf = df.file_nbr
    IF (cntf > 9)
     cntf = (cntf - 9)
    ENDIF
    IF (cntf <= top_bound)
     cntn = 0
    ENDIF
    IF ((request->file_type_ind=1))
     cntn = (cntn+ 1), stat = alterlist(reply->files[cntf].info_line,cntn), reply->files[cntf].
     info_line[cntn].new_line = header->hd_rows[d.seq].the_header
    ENDIF
   DETAIL
    CALL echo(concat("cntf:",cnvtstring(cntf),", cntn",cnvtstring(cntn),", cfr_id:",
     cnvtstring(cf.cv_case_file_row_id)))
    IF (cntf <= top_bound
     AND cntf >= low_bound)
     IF (cc.encntr_id=encntr_holder
      AND cntn > 0)
      clear = "T"
     ELSE
      clear = "F"
     ENDIF
     encntr_holder = cc.encntr_id
     IF (cntf=1
      AND cntn > 0)
      col 0
     ELSEIF (cntf=2
      AND clear="T"
      AND cntn > 0)
      col 0, clear = "F"
     ELSE
      cntn = (cntn+ 1), stat = alterlist(reply->files[cntf].info_line,cntn)
      IF (accv3_ind > 0)
       reply->files[cntf].info_line[cntn].new_line = build(cv_acc_transnum_str,df.delimiter,request->
        part_nbr,l.long_text)
      ELSE
       reply->files[cntf].info_line[cntn].new_line = build(cv_acc_transnum_str,l.long_text,4)
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET fu_only = "T"
  ENDIF
  IF (accv3_ind=1
   AND (request->file_type_ind=1))
   SELECT INTO "nl:"
    FROM cv_dataset_file cdf
    WHERE (cdf.dataset_id=request->dataset_id)
     AND cdf.file_nbr > 9
    DETAIL
     reply->files[(cdf.file_nbr - 9)].filename = concat(trim(cdf.name),".",trim(cdf.extension))
    WITH nocounter
   ;end select
  ENDIF
  IF (accv3_ind=0)
   DECLARE dof_mean = c12 WITH protect, constant("AC02XDOF")
   DECLARE dof_ec = f8 WITH protect
   SET dof_ec = geteventcd(dof_mean)
   DECLARE read_reason_mean = c12 WITH protect, constant("AC02XRREASON")
   DECLARE read_reason_ec = f8 WITH protect
   SET read_reason_ec = geteventcd(read_reason_mean)
   DECLARE death_mean = c12 WITH protect, constant("AC02XDEATH")
   DECLARE death_ec = f8 WITH protect
   SET death_ec = geteventcd(death_mean)
   IF (fu_only="T")
    SELECT INTO "nl:"
     cc.encntr_id, cc.chart_dt_tm, df.file_id
     FROM (dummyt d  WITH seq = value(size(header->hd_rows,5))),
      (dummyt d1  WITH seq = value(size(cv_proc_case->list,5))),
      cv_case cc,
      cv_case_dataset_r ccdr,
      cv_case_abstr_data ccad,
      cv_dataset_file df,
      cv_case_file_row cf,
      long_text l
     PLAN (cc)
      JOIN (d1
      WHERE (cc.cv_case_id=cv_proc_case->list[d1.seq].cv_case_id))
      JOIN (ccdr
      WHERE parser(status_cd_str)
       AND ccdr.cv_case_id=cc.cv_case_id
       AND (ccdr.dataset_id=request->dataset_id)
       AND parser(part_nbr_str))
      JOIN (ccad
      WHERE ccdr.cv_case_id=ccad.cv_case_id
       AND ccad.event_cd=dof_ec
       AND ccad.result_dt_tm BETWEEN cnvtdatetime(cnvtdate(request->start_dt),0) AND cnvtdatetime(
       cnvtdate(request->stop_dt),235959))
      JOIN (df
      WHERE df.dataset_id=ccdr.dataset_id)
      JOIN (d
      WHERE cnvtupper(trim(df.name))=cnvtupper(trim(header->hd_rows[d.seq].file_name))
       AND (df.file_id=header->hd_rows[d.seq].file_id))
      JOIN (cf
      WHERE df.file_id=cf.file_id
       AND cf.case_dataset_r_id=ccdr.case_dataset_r_id)
      JOIN (l
      WHERE cf.long_text_id=l.long_text_id)
     ORDER BY df.file_id, cc.encntr_id, cnvtdatetime(cc.chart_dt_tm) DESC
     HEAD REPORT
      cntf = 0, cntn = 0, clear = "F",
      encntr_holder = 0
     HEAD cf.file_id
      cntf = df.file_nbr
      IF (cntf < 2)
       cntn = 0
      ENDIF
     DETAIL
      IF (cntf < 2
       AND cntf > 0)
       IF (cc.encntr_id=encntr_holder
        AND cntn > 0)
        clear = "T"
       ELSE
        clear = "F"
       ENDIF
       encntr_holder = cc.encntr_id
       IF (cntf=1
        AND cntn > 0)
        col 0
       ELSEIF (cntf=2
        AND clear="T"
        AND cntn > 0)
        col 0, clear = "F"
       ELSE
        cntn = (cntn+ 1), stat = alterlist(reply->files[cntf].info_line,cntn), reply->files[cntf].
        info_line[cntn].new_line = build(cv_acc_transnum_str,l.long_text)
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL echo("No file 1 build up")
    ENDIF
   ENDIF
   SELECT DISTINCT INTO "nl:"
    ccad.event_id
    FROM (dummyt d1  WITH seq = value(size(cv_proc_case->list,5))),
     cv_case_dataset_r ccdr,
     cv_case_abstr_data ccad,
     clinical_event ce
    PLAN (ccdr
     WHERE (ccdr.dataset_id=request->dataset_id)
      AND parser(part_nbr_str)
      AND parser(status_cd_str))
     JOIN (d1
     WHERE (ccdr.cv_case_id=cv_proc_case->list[d1.seq].cv_case_id))
     JOIN (ccad
     WHERE ccdr.cv_case_id=ccad.cv_case_id
      AND ccad.event_cd=dof_ec
      AND ccad.result_dt_tm BETWEEN cnvtdatetime(cnvtdate(request->start_dt),0) AND cnvtdatetime(
      cnvtdate(request->stop_dt),235959))
     JOIN (ce
     WHERE ce.event_id=ccad.event_id)
    ORDER BY ce.parent_event_id
    HEAD REPORT
     event_cnt = 0
    DETAIL
     event_cnt = (event_cnt+ 1), stat = alterlist(fu_event->event,event_cnt), fu_event->event[
     event_cnt].parent_event_id = ce.parent_event_id,
     fu_event->event[event_cnt].cv_case_id = ccad.cv_case_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_log_message("No follow_up conducted in selected date range! Exit the program")
   ELSE
    SET event_cnt = size(fu_event->event,5)
    SET x = 0
    FOR (x = 1 TO event_cnt)
     SET stat = alterlist(fu_event->event[x].sub_event,8)
     FOR (y = 1 TO 8)
      IF (y=6)
       SET fu_event->event[x].sub_event[y].event_cd = death_ec
      ENDIF
      SET fu_event->event[x].sub_event[y].position = y
     ENDFOR
    ENDFOR
    DECLARE sub_event = i4 WITH public, noconstant(0)
    SELECT INTO "nl:"
     FROM clinical_event ce,
      cv_case_abstr_data ccad,
      cv_xref cx,
      cv_xref_field cxf,
      (dummyt d  WITH seq = value(size(fu_event->event,5)))
     PLAN (d)
      JOIN (ce
      WHERE (ce.parent_event_id=fu_event->event[d.seq].parent_event_id)
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
      JOIN (ccad
      WHERE ccad.event_id=ce.event_id)
      JOIN (cx
      WHERE cx.event_cd=ccad.event_cd)
      JOIN (cxf
      WHERE cx.xref_id=cxf.xref_id)
     ORDER BY ce.parent_event_id, cxf.position
     HEAD ce.parent_event_id
      cnt = 0, fu_event->event[d.seq].num_reasons = 0
     DETAIL
      IF (cxf.position > 3)
       IF (ccad.event_cd=read_reason_ec
        AND cxf.position=8)
        fu_event->event[d.seq].num_reasons = (fu_event->event[d.seq].num_reasons+ 1)
        IF ((fu_event->event[d.seq].num_reasons > 1))
         cnt = (cnt+ 1), stat = alterlist(fu_event->event[d.seq].sub_event,(cxf.position+ cnt)),
         fu_event->event[d.seq].sub_event[(cxf.position+ cnt)].event_id = ce.event_id,
         fu_event->event[d.seq].sub_event[(cxf.position+ cnt)].event_cd = ccad.event_cd, fu_event->
         event[d.seq].sub_event[(cxf.position+ cnt)].result_val = ccad.result_val, fu_event->event[d
         .seq].sub_event[(cxf.position+ cnt)].nomenclature_id = ccad.nomenclature_id,
         fu_event->event[d.seq].sub_event[(cxf.position+ cnt)].translate_value = ccad.result_val,
         fu_event->event[d.seq].sub_event[(cxf.position+ cnt)].position = cxf.position
        ELSE
         fu_event->event[d.seq].sub_event[cxf.position].event_id = ce.event_id, fu_event->event[d.seq
         ].sub_event[cxf.position].event_cd = ccad.event_cd, fu_event->event[d.seq].sub_event[cxf
         .position].result_val = ccad.result_val,
         fu_event->event[d.seq].sub_event[cxf.position].nomenclature_id = ccad.nomenclature_id,
         fu_event->event[d.seq].sub_event[cxf.position].translate_value = ccad.result_val, fu_event->
         event[d.seq].sub_event[cxf.position].position = cxf.position
        ENDIF
       ELSE
        fu_event->event[d.seq].sub_event[cxf.position].event_id = ce.event_id, fu_event->event[d.seq]
        .sub_event[cxf.position].event_cd = ccad.event_cd, fu_event->event[d.seq].sub_event[cxf
        .position].result_val = ccad.result_val,
        fu_event->event[d.seq].sub_event[cxf.position].nomenclature_id = ccad.nomenclature_id,
        fu_event->event[d.seq].sub_event[cxf.position].translate_value = ccad.result_val, fu_event->
        event[d.seq].sub_event[cxf.position].position = cxf.position
       ENDIF
       IF ((sub_event < (8+ cnt)))
        sub_event = (8+ cnt)
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    DECLARE part_str = vc WITH protect
    SELECT INTO "nl:"
     FROM cv_case cc,
      cv_case_dataset_r ccdr,
      (dummyt d  WITH seq = value(event_cnt)),
      (dummyt d1  WITH seq = value(sub_event))
     PLAN (d)
      JOIN (d1
      WHERE d1.seq <= size(fu_event->event[d.seq].sub_event,5))
      JOIN (ccdr
      WHERE (ccdr.dataset_id=request->dataset_id)
       AND parser(part_nbr_str)
       AND (fu_event->event[d.seq].cv_case_id=ccdr.cv_case_id))
      JOIN (cc
      WHERE ccdr.cv_case_id=cc.cv_case_id)
     ORDER BY d1.seq, cc.person_id, fu_event->event[d.seq].parent_event_id
     DETAIL
      CASE (d1.seq)
       OF 1:
        fu_event->event[d.seq].sub_event[d1.seq].translate_value = cv_acc_transnum_str,fu_event->
        event[d.seq].sub_event[d1.seq].position = 1
       OF 2:
        part_str = trim(ccdr.participant_nbr),
        IF (size(part_str,1)=5)
         fu_event->event[d.seq].sub_event[d1.seq].translate_value = build("0",part_str)
        ELSEIF (size(part_str,1)=4)
         fu_event->event[d.seq].sub_event[d1.seq].translate_value = build("00",part_str)
        ELSEIF (size(part_str,1)=3)
         fu_event->event[d.seq].sub_event[d1.seq].translate_value = build("000",part_str)
        ELSEIF (size(part_str,1)=2)
         fu_event->event[d.seq].sub_event[d1.seq].translate_value = build("0000",part_str)
        ELSEIF (size(part_str,1)=1)
         fu_event->event[d.seq].sub_event[d1.seq].translate_value = build("00000",part_str)
        ELSE
         fu_event->event[d.seq].sub_event[d1.seq].translate_value = part_str
        ENDIF
        ,fu_event->event[d.seq].sub_event[d1.seq].position = 2
       OF 3:
        fu_event->event[d.seq].sub_event[d1.seq].translate_value = cnvtstring(cc.person_id),fu_event
        ->event[d.seq].sub_event[d1.seq].position = 3
      ENDCASE
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(event_cnt)),
      (dummyt d1  WITH seq = value(sub_event)),
      cv_response cr
     PLAN (d)
      JOIN (d1
      WHERE d1.seq <= size(fu_event->event[d.seq].sub_event,5))
      JOIN (cr
      WHERE (cr.nomenclature_id=fu_event->event[d.seq].sub_event[d1.seq].nomenclature_id)
       AND cnvtupper(trim(cr.field_type))="A"
       AND cr.nomenclature_id != 0.0)
     DETAIL
      fu_event->event[d.seq].sub_event[d1.seq].translate_value = trim(cr.a2)
     WITH nocounter
    ;end select
    DECLARE vital_mean = c12 WITH protect, constant("AC02XVITAL")
    DECLARE vital_ec = f8 WITH protect
    SET vital_ec = geteventcd(vital_mean)
    DECLARE xreadm_mean = c12 WITH protect, constant("AC02XREADM")
    DECLARE xreadm_ec = f8 WITH protect
    SET xreadm_ec = geteventcd(xreadm_mean)
    DECLARE file_seq = i2 WITH protect, constant(8)
    DECLARE vital_val = c2 WITH protect
    DECLARE xreadm_val = c2 WITH protect
    SELECT INTO "nl:"
     position = fu_event->event[d.seq].sub_event[d1.seq].position, translate_val = fu_event->event[d
     .seq].sub_event[d1.seq].translate_value
     FROM (dummyt d  WITH seq = value(event_cnt)),
      (dummyt d1  WITH seq = value(sub_event))
     PLAN (d)
      JOIN (d1
      WHERE d1.seq <= size(fu_event->event[d.seq].sub_event,5))
     ORDER BY d.seq, position, translate_val
     HEAD REPORT
      stat = alterlist(reply->files[file_seq].info_line,10), sub_cnt = 0
     HEAD d.seq
      vital_val = " ", xreadm_val = " ", fu_reason_cnt = 0,
      sub_cnt = (sub_cnt+ 1)
      IF (sub_cnt > size(reply->files[file_seq].info_line,5))
       stat = alterlist(reply->files[file_seq].info_line,(sub_cnt+ 9))
      ENDIF
     DETAIL
      IF (d1.seq < 4)
       trans_val = fu_event->event[d.seq].sub_event[d1.seq].translate_value, reply->files[file_seq].
       info_line[sub_cnt].new_line = build(reply->files[file_seq].info_line[sub_cnt].new_line,
        trans_val,"|")
      ELSE
       IF (size(trim(fu_event->event[d.seq].sub_event[d1.seq].translate_value,3))=0)
        trans_val = "9"
       ELSE
        trans_val = fu_event->event[d.seq].sub_event[d1.seq].translate_value
       ENDIF
       IF ((fu_event->event[d.seq].sub_event[d1.seq].event_cd=vital_ec)
        AND trim(fu_event->event[d.seq].sub_event[d1.seq].translate_value,3)="3")
        vital_val = "3"
       ELSEIF ((fu_event->event[d.seq].sub_event[d1.seq].event_cd=vital_ec)
        AND trim(fu_event->event[d.seq].sub_event[d1.seq].translate_value)="1")
        vital_val = "1"
       ENDIF
       IF ((fu_event->event[d.seq].sub_event[d1.seq].event_cd=xreadm_ec)
        AND trim(fu_event->event[d.seq].sub_event[d1.seq].translate_value)="0")
        xreadm_val = "0"
       ENDIF
       IF (vital_val="1"
        AND (fu_event->event[d.seq].sub_event[d1.seq].event_cd=death_ec))
        trans_val = "0"
       ENDIF
       IF (xreadm_val="0"
        AND (fu_event->event[d.seq].sub_event[d1.seq].event_cd=read_reason_ec))
        trans_val = "0"
       ENDIF
       IF (vital_val="3"
        AND (fu_event->event[d.seq].sub_event[d1.seq].event_cd != vital_ec))
        trans_val = "9"
       ENDIF
       IF ((fu_event->event[d.seq].sub_event[d1.seq].event_cd=read_reason_ec))
        fu_reason_cnt = (fu_reason_cnt+ 1)
        IF ((fu_event->event[d.seq].num_reasons > 1)
         AND (fu_event->event[d.seq].num_reasons > fu_reason_cnt))
         IF (vital_val != "3"
          AND xreadm_val != "0")
          reply->files[file_seq].info_line[sub_cnt].new_line = build(reply->files[file_seq].
           info_line[sub_cnt].new_line,trans_val)
         ENDIF
        ELSE
         reply->files[file_seq].info_line[sub_cnt].new_line = build(reply->files[file_seq].info_line[
          sub_cnt].new_line,trans_val,"|")
        ENDIF
       ELSE
        reply->files[file_seq].info_line[sub_cnt].new_line = build(reply->files[file_seq].info_line[
         sub_cnt].new_line,trans_val,"|")
       ENDIF
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->files[file_seq].info_line,sub_cnt)
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ENDIF
 IF (((export_sts_flag=1) OR (((export_sts02_flag=1) OR (export_sts03_flag=1)) )) )
  DECLARE ncurcnt = i4 WITH protect
  DECLARE nprevcnt = i4 WITH protect
  DECLARE ndiffcnt = i4 WITH protect
  DECLARE smvpadding = vc WITH protect
  IF ((request->file_type_ind=2))
   SET file_id_str = build("(df.file_nbr = 3 and df.dataset_id =",dmvcurid,
    ") or (df.file_nbr = 1 and df.dataset_id = ",dmvprevid,")")
   SELECT INTO "nl:"
    pos = xf.position
    FROM cv_dataset_file df,
     cv_xref_field xf
    PLAN (df
     WHERE df.dataset_id=dmvprevid
      AND df.file_nbr=1)
     JOIN (xf
     WHERE xf.file_id=df.file_id)
    FOOT REPORT
     nprevcnt = max(pos)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    pos = xf.position
    FROM cv_dataset_file df,
     cv_xref_field xf
    PLAN (df
     WHERE df.dataset_id=dmvcurid
      AND df.file_nbr=3)
     JOIN (xf
     WHERE xf.file_id=df.file_id)
    FOOT REPORT
     ncurcnt = max(pos)
    WITH nocounter
   ;end select
   IF (ncurcnt > nprevcnt)
    SET smvpadding = "|"
    IF ((ncurcnt > (nprevcnt+ 1)))
     FOR (ndiffcnt = (nprevcnt+ 2) TO ncurcnt)
      SET smvpadding = concat(smvpadding,"|")
      CALL echo(smvpadding)
     ENDFOR
    ENDIF
   ENDIF
  ENDIF
  CALL echo("Execute STS Section!")
  CALL echo(build("start date: ",format(request->start_dt,"mm/dd/yyyy;;d")))
  CALL echo(build("stop date: ",format(request->stop_dt,"mm/dd/yyyy;;d")))
  CALL echo(build("facility_str:",facility_str))
  CALL echo(build("cv_dataset_string: ",cv_dataset_string))
  CALL echo(build("status_cd_str:",status_cd_str))
  CALL echo(build("part_nbr_str: ",part_nbr_str))
  CALL echo(build("file_id_str: ",file_id_str))
  CALL echo(build("surg_dt_str: ",surg_dt_str))
  SELECT INTO "nl:"
   FROM cv_xref cx,
    dm_prefs dp,
    cv_xref_field cxf,
    cv_dataset_file df
   PLAN (dp
    WHERE dp.pref_domain="CVNET"
     AND dp.pref_section=concat("OPTIONAL_FIELD_",trim(request->part_nbr))
     AND cnvtupper(dp.pref_str)="N")
    JOIN (cx
    WHERE cx.xref_internal_name=dp.pref_name
     AND cx.active_ind=1)
    JOIN (cxf
    WHERE cxf.xref_id=cx.xref_id
     AND cxf.active_ind=1)
    JOIN (df
    WHERE df.file_id=cxf.file_id
     AND df.dataset_id=cx.dataset_id
     AND df.active_ind=1
     AND parser(file_id_str))
   ORDER BY df.dataset_id, df.file_id, cxf.position
   HEAD REPORT
    cntd = 0
   HEAD df.dataset_id
    cntd = (cntd+ 1), cntfile = 0, stat = alterlist(suppress->dataset,cntd),
    suppress->dataset[cntd].dataset_id = df.dataset_id
   HEAD df.file_id
    cntfile = (cntfile+ 1), cntfield = 0, stat = alterlist(suppress->dataset[cntd].file,cntfile),
    suppress->dataset[cntd].file[cntfile].file_id = df.file_id
   HEAD cxf.position
    cntfield = (cntfield+ 1), stat = alterlist(suppress->dataset[cntd].file[cntfile].field,cntfield),
    suppress->dataset[cntd].file[cntfile].field[cntfield].position = (cxf.position - 1)
   DETAIL
    col 0
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL cv_log_message("STS Optional field(s) found with dm_prefs.pref_str='N'")
   CALL echorecord(suppress)
  ELSE
   CALL cv_log_message("No STS optional field(s) found with dm_prefs.pref_str='N'")
  ENDIF
  DECLARE dsize = i4 WITH protect
  DECLARE fsize = i4 WITH protect
  SELECT INTO "nl:"
   df.name, df.extension
   FROM cv_case c,
    cv_case_abstr_data ccad,
    cv_case_dataset_r ccdr,
    cv_dataset_file df,
    cv_case_file_row cf,
    long_text l
   PLAN (ccad
    WHERE parser(surg_dt_str)
     AND ccad.result_dt_tm BETWEEN cnvtdatetime(cnvtdate(request->start_dt),0) AND cnvtdatetime(
     cnvtdate(request->stop_dt),235959))
    JOIN (c
    WHERE ccad.cv_case_id=c.cv_case_id
     AND parser(facility_str))
    JOIN (ccdr
    WHERE parser(status_cd_str)
     AND ccdr.cv_case_id=c.cv_case_id
     AND parser(cv_dataset_string)
     AND parser(part_nbr_str))
    JOIN (df
    WHERE df.dataset_id=ccdr.dataset_id
     AND parser(file_id_str))
    JOIN (cf
    WHERE df.file_id=cf.file_id
     AND cf.case_dataset_r_id=ccdr.case_dataset_r_id)
    JOIN (l
    WHERE cf.long_text_id=l.long_text_id)
   ORDER BY df.name, df.file_id
   HEAD REPORT
    cntf = 0, cntl = 0, dindex = 0,
    findex = 0, kntindex = 0, dsize = 0,
    fsize = 0, max_field_idx = 0
   HEAD df.name
    CALL echo(concat("Processing df.name =",df.name))
    IF ((((request->file_type_ind != 2)) OR (cntf=0)) )
     cntl = 1, cntf = (cntf+ 1), stat = alterlist(reply->files,cntf),
     reply->files[cntf].filename = concat(trim(df.name),".",trim(df.extension)), reply->files[cntf].
     filename = replace(reply->files[cntf].filename,"_CMB","_",0), reply->files[cntf].filename =
     replace(reply->files[cntf].filename,"PARTNBR_",request->part_nbr,0),
     stat = alterlist(reply->files[cntf].info_line,cntl), reply->files[cntf].info_line[cntl].new_line
      = header->hd_rows[cntf].the_header
    ENDIF
   HEAD df.file_id
    CALL echo(concat("Processing df.file_id =",cnvtstring(df.file_id))), dindex = 0, dsize = size(
     suppress->dataset,5)
    IF (dsize > 0)
     FOR (kntindex = 1 TO dsize)
       IF ((suppress->dataset[kntindex].dataset_id=df.dataset_id))
        dindex = kntindex, kntindex = size(suppress->dataset,5)
       ENDIF
     ENDFOR
    ENDIF
    findex = 0, max_field_idx = 0
    IF (dindex > 0)
     fsize = size(suppress->dataset[dindex].file,5)
     IF (fsize > 0)
      FOR (kntindex = 1 TO fsize)
        IF ((suppress->dataset[dindex].file[kntindex].file_id=df.file_id))
         findex = kntindex, max_field_idx = size(suppress->dataset[dindex].file[findex].field,5),
         kntindex = size(suppress->dataset[dindex].file,5)
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   DETAIL
    cntl = (cntl+ 1), stat = alterlist(reply->files[cntf].info_line,cntl)
    IF (dindex > 0
     AND findex > 0)
     filerow = " ", delim_cnt = 0, next_pos = 0,
     pos = 1, last_pos = 1, field_idx = 1
     WHILE (pos > 0)
       IF (pos=1
        AND substring(1,1,l.long_text)="|")
        IF ((suppress->dataset[dindex].file[findex].field[field_idx].position=0))
         field_idx = 2
        ENDIF
        delim_cnt = 1
       ENDIF
       WHILE (pos > 0
        AND (delim_cnt < suppress->dataset[dindex].file[findex].field[field_idx].position))
        pos = findstring("|",l.long_text,(pos+ 1)),delim_cnt = (delim_cnt+ 1)
       ENDWHILE
       IF (pos=0)
        filerow = concat(filerow,substring(last_pos,((size(l.long_text)+ 1) - last_pos),l.long_text))
       ELSE
        IF (pos=1)
         next_pos = findstring("|",l.long_text)
        ELSE
         filerow = concat(filerow,substring(last_pos,((pos+ 1) - last_pos),l.long_text)), next_pos =
         findstring("|",l.long_text,(pos+ 1))
        ENDIF
        IF (next_pos > 0)
         delim_cnt = (delim_cnt+ 1), last_pos = next_pos, pos = next_pos
         IF (field_idx < max_field_idx)
          field_idx = (field_idx+ 1)
         ELSE
          filerow = concat(filerow,substring(next_pos,((size(l.long_text)+ 1) - next_pos),l.long_text
            )), pos = 0
         ENDIF
        ELSE
         pos = 0
        ENDIF
       ENDIF
     ENDWHILE
     reply->files[cntf].info_line[cntl].new_line = filerow
    ELSE
     reply->files[cntf].info_line[cntl].new_line = l.long_text
    ENDIF
    IF ((request->file_type_ind=2)
     AND df.dataset_id=dmvprevid)
     reply->files[cntf].info_line[cntl].new_line = concat(reply->files[cntf].info_line[cntl].new_line,
      smvpadding)
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET sfailed = "T"
   GO TO get_data_failure
  ENDIF
  EXECUTE cv_get_harvest_verification
 ENDIF
 GO TO exit_script
 SUBROUTINE accadmin(null)
   DECLARE g_acc_mds_output = vc WITH protect
   DECLARE g_acc_timeframe = vc WITH protect
   SELECT INTO "nl:"
    FROM dm_prefs dp
    WHERE dp.pref_domain="CVNET"
     AND (dp.parent_entity_id=request->dataset_id)
     AND dp.pref_nbr=cnvtint(request->part_nbr)
     AND dp.pref_section IN ("ADMIN_FILE_ROW", "MINIMUM_DATA_SET")
    DETAIL
     CASE (dp.pref_section)
      OF "ADMIN_FILE_ROW":
       acc_admin_line = dp.pref_str
      OF "MINIMUM_DATA_SET":
       IF (dp.pref_str="Y")
        g_acc_mds_output = "1"
       ELSE
        g_acc_mds_output = "2"
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_log_message("ACC admin line not found, aborting export")
    SET sfailed = "T"
    GO TO exit_script
   ENDIF
   SET acc_admin_line = replace(value(acc_admin_line),"<MDS>",value(g_acc_mds_output),0)
   IF ((request->date_cd > 0.0))
    SELECT INTO "nl:"
     cve.field_value
     FROM code_value_extension cve
     WHERE (cve.code_value=request->date_cd)
      AND cve.field_name="TRANSLATE"
     DETAIL
      g_acc_timeframe = cve.field_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL cv_log_message("Predefined date range not found, aborting export")
     SET sfailed = "T"
     GO TO exit_script
    ENDIF
    SET acc_admin_line = replace(value(acc_admin_line),"<TIMEFRAM>",value(g_acc_timeframe),0)
   ELSE
    CALL cv_log_message("Predefined date range not used for ACC, timeframe will not export")
   ENDIF
 END ;Subroutine
#get_data_failure
 IF (sfailed="T")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Get CVNet Harvest Data"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV Data tables"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Get file name and content"
 ENDIF
#exit_script
 IF (sfailed="T")
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
 DECLARE cv_get_harvest_export_vrsn = vc WITH private, constant("MOD 034 BM9013 05/23/07")
END GO
