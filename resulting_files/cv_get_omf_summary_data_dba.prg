CREATE PROGRAM cv_get_omf_summary_data:dba
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
 IF (validate(cv_omf_rec,"notdefined") != "notdefined")
  CALL echo("cv_omf_rec  is already defined!")
 ELSE
  RECORD cv_omf_rec(
    1 dataset[*]
      2 dataset_id = f8
    1 person_id = f8
    1 encntr_id = f8
    1 cv_case_nbr = f8
    1 source_cd = f8
    1 reference_nbr = vc
    1 top_parent_event_id = f8
    1 case_abstr_data[*]
      2 group_type_cd = f8
      2 event_type_cd = f8
      2 event_cd = f8
      2 event_id = f8
      2 nomenclature_id = f8
      2 result_val = vc
      2 result_cd = f8
      2 task_assay_cd = f8
      2 group_type_meaning = c12
    1 proc_data[*]
      2 event_type_cd = f8
      2 proc_physician_id = f8
      2 proc_start_dt_tm = dq8
      2 proc_end_dt_tm = dq8
      2 proc_abstr_data[*]
        3 event_type_cd = f8
        3 group_type_cd = f8
        3 event_cd = f8
        3 event_id = f8
        3 nomenclature_id = f8
        3 result_val = vc
        3 result_cd = f8
        3 task_assay_cd = f8
        3 group_type_meaning = c12
      2 lesion[*]
        3 les_abstr_data[*]
          4 group_type_cd = f8
          4 event_type_cd = f8
          4 event_cd = f8
          4 event_id = f8
          4 nomenclature_id = f8
          4 result_val = vc
          4 result_cd = f8
          4 task_assay_cd = f8
          4 group_type_meaning = c12
  )
 ENDIF
 IF (validate(reply,"notdefined") != "notdefined")
  CALL echo("reply  is already defined!")
 ELSE
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
 SET date = "dd-mm-yyyy hh:mm:ss.cc;;d"
 CALL echo("CV_GET_OMF_SUMMARY_DATA ")
 CALL echo(build("Today's error log date is",format(curdate,date)))
 SET reply->status_data.status = "F"
 SET icasecount = 0
 SET iprocount = 0
 SET iabstr_count = 0
 SET iptacount = 0
 SET iptcaabstr_count = 0
 SET ilescnt = 0
 SET iparentcount = 0
 SET iparentevent = 1
 SET ilesabstrcnt = 0
 SET bptcadone = "TRUE"
 SET iptcacount = 0
 SET lesioncnt = 0
 SET bselection = "FALSE"
 SET blesionselect = "FALSE"
 SET icabgcount = 0
 SET istscount = 0
 SET event_cd = 0
 SET iabstrcount = 0
 SET bcase = 1
 SET result_val = fillstring(100," ")
 SET cv_omf_rec->top_parent_event_id = top_parent_event_id
 EXECUTE cv_get_surg_case_id
 SET cv_omf_rec->encntr_id = register->rec[1].encntr_id
 SET cv_omf_rec->person_id = register->rec[1].person_id
 SELECT INTO "NL:"
  event_cd = register->rec[d1.seq].event_cd, parent_event_id = register->rec[d1.seq].parent_event_id,
  dataset_id = ref.dataset_id,
  ref.event_type_cd, ref.task_assay_cd, cer.nomenclature_id,
  register->rec[d1.seq].result_val, cv.cdf_meaning, ref.group_type_cd
  FROM code_value cv,
   cv_xref ref,
   dummyt d,
   ce_coded_result cer,
   (dummyt d1  WITH seq = value(size(register->rec,5)))
  PLAN (d1)
   JOIN (ref
   WHERE (ref.event_cd=register->rec[d1.seq].event_cd))
   JOIN (cv
   WHERE ref.event_type_cd=cv.code_value
    AND cv.code_set=22309
    AND cv.active_ind=1
    AND ((cv.begin_effective_dt_tm=null) OR (cv.begin_effective_dt_tm != null
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((cv.end_effective_dt_tm=null) OR (cv.end_effective_dt_tm != null
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))) )) )
   JOIN (d)
   JOIN (cer
   WHERE (register->rec[d1.seq].event_id=cer.event_id))
  ORDER BY cv.collation_seq, parent_event_id, dataset_id
  HEAD REPORT
   bptcaproc = "YES"
  HEAD cv.collation_seq
   iabstrcount = 0, bcase = 0
   IF (cv.cdf_meaning != "LESSION")
    IF (cv.cdf_meaning != "CASE")
     iprocount = (iprocount+ 1), iprosize = alterlist(cv_omf_rec->proc_data,iprocount), cv_omf_rec->
     proc_data[iprocount].event_type_cd = ref.event_type_cd
    ENDIF
    IF (cv.cdf_meaning="PTCA")
     iptcacount = iprocount
    ENDIF
   ENDIF
   IF (cv.cdf_meaning="LESION")
    blesiondata = 1
   ENDIF
   IF (cv.cdf_meaning="CASE")
    bcase = 1
   ENDIF
  HEAD parent_event_id
   idatasetid = 0
   IF (blesiondata=1)
    lesioncnt = (lesioncnt+ 1), stat = alterlist(cv_omf_rec->proc_data[iptcacount].lesion,lesioncnt)
   ENDIF
  HEAD dataset_id
   idatasetid = (idatasetid+ 1), stat = alterlist(cv_omf_rec->dataset,idatasetid), cv_omf_rec->
   dataset[idatasetid].dataset_id = ref.dataset_id
  DETAIL
   bselection = "TRUE", iabstrcount = (iabstrcount+ 1)
   IF (cv.cdf_meaning != "LESION")
    IF (bcase=1)
     stat = alterlist(cv_omf_rec->case_abstr_data,iabstrcount),
     CALL echo("                          Processing Case Abstract Data"), cv_omf_rec->
     case_abstr_data[iabstrcount].event_cd = register->rec[d1.seq].event_cd,
     cv_omf_rec->case_abstr_data[iabstrcount].event_id = register->rec[d1.seq].event_id, cv_omf_rec->
     case_abstr_data[iabstrcount].group_type_cd = ref.group_type_cd, cv_omf_rec->case_abstr_data[
     iabstrcount].event_type_cd = ref.event_type_cd,
     cv_omf_rec->case_abstr_data[iabstrcount].result_cd = cer.result_cd, cv_omf_rec->case_abstr_data[
     iabstrcount].result_val = register->rec[d1.seq].result_val, cv_omf_rec->case_abstr_data[
     iabstrcount].nomenclature_id = cer.nomenclature_id,
     cv_omf_rec->case_abstr_data[iabstrcount].task_assay_cd = ref.task_assay_cd
    ELSE
     CALL echo("                               Processing Abstract Data"), stat = alterlist(
      cv_omf_rec->proc_data[iprocount].proc_abstr_data,iabstrcount), cv_omf_rec->proc_data[iprocount]
     .proc_abstr_data[iabstrcount].group_type_cd = ref.group_type_cd,
     cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].event_type_cd = ref.event_type_cd,
     cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].nomenclature_id = cer
     .nomenclature_id, cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].result_cd = cer
     .result_cd,
     cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].event_cd = register->rec[d1.seq].
     event_cd, cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].event_id = register->
     rec[d1.seq].event_id, cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].result_val
      = register->rec[d1.seq].result_val,
     cv_omf_rec->proc_data[iprocount].proc_abstr_data[iabstrcount].task_assay_cd = ref.task_assay_cd
    ENDIF
   ENDIF
   IF (blesiondata=1)
    stat = alterlist(cv_omf_rec->proc_data[iptcacount].lesion[lesioncnt].les_abstr_data,iabstrcount),
    cv_omf_rec->proc_data[iptcacount].lesion[lesioncnt].les_abstr_data[iabstrcount].event_cd =
    register->rec[d1.seq].event_cd, cv_omf_rec->proc_data[iptcacount].lesion[lesioncnt].
    les_abstr_data[iabstrcount].event_id = register->rec[d1.seq].event_id,
    cv_omf_rec->proc_data[iptcacount].lesion[lesioncnt].les_abstr_data[iabstrcount].result_val =
    register->rec[d1.seq].result_val, cv_omf_rec->proc_data[iptcacount].lesion[lesioncnt].
    les_abstr_data[iabstrcount].result_cd = cer.result_cd, cv_omf_rec->proc_data[iptcacount].lesion[
    lesioncnt].les_abstr_data[iabstrcount].nomenclature_id = cer.nomenclature_id,
    cv_omf_rec->proc_data[iptcacount].lesion[lesioncnt].les_abstr_data[iabstrcount].group_type_cd =
    ref.group_type_cd, cv_omf_rec->proc_data[iptcacount].lesion[lesioncnt].les_abstr_data[iabstrcount
    ].event_type_cd = ref.event_type_cd, cv_omf_rec->proc_data[iptcacount].lesion[lesioncnt].
    les_abstr_data[iabstrcount].task_assay_cd = ref.task_assay_cd
   ENDIF
  WITH outerjoin = d, nocounter
 ;end select
 IF (bselection="FALSE")
  GO TO selection_failure
 ENDIF
 EXECUTE cv_ins_updt_omf_summary_tables
 CALL echo(build("iProcount",iprocount))
 CALL echo("echorecord")
 CALL echo(build("Omf Lesion data count =  ",iabstrcount))
 CALL echo(build("iPTCACount            =  ",iptcacount))
 CALL echo(build("Lesion count          =  ",lesioncnt))
 CALL echo("*******************************************************")
 CALL echo("*****************************************************")
 CALL echo(build("cv_case_nbr   *****",cv_omf_rec->cv_case_nbr))
 CALL echo(build("Top most parent event_id  = ",cv_omf_rec->top_parent_event_id))
 CALL echo(build("Source code   = ",cv_omf_rec->source_cd))
 CALL echo("*****************************************************")
 CALL echo("*****************************************************")
 CALL echo("*******************************************************")
 CALL echo("*******************************************************")
 CALL echo("Calling Dr Zhan's Script")
 CALL echo("*******************************************************")
 CALL echo("*******************************************************")
 CALL echo("*******************************************************")
#selection_failure
 IF (bselection="FALSE")
  CALL echo("The select statement Failed at the non Lesion Level")
  SET reply->status_data.subeventstatus[1].operationname = "NonLesion Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "NonLesion"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "get nonlesion dataset"
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
#lesion_failure
 IF (blesionselect="FALSE")
  CALL echo("The select statement Failed at the Lesion Level")
  SET reply->status_data.subeventstatus[1].operationname = "lesion Selection"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "lesion"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "get lesion dataset"
  SET reply->status_data.status = "F"
 ENDIF
#exit_script
 IF (bselection="TRUE")
  SET reply->status_data.status = "T"
 ENDIF
 IF (blesionselect="TRUE")
  SET reply->status_data.status = "T"
 ENDIF
#end_program
END GO
