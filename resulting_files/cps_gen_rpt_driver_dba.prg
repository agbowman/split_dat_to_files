CREATE PROGRAM cps_gen_rpt_driver:dba
 FREE RECORD treq
 RECORD treq(
   1 output_device = vc
   1 script_name = vc
   1 person_cnt = i4
   1 person[*]
     2 person_id = f8
   1 visit_cnt = i4
   1 visit[*]
     2 encntr_id = f8
   1 prsnl_cnt = i4
   1 prsnl[*]
     2 prsnl_id = f8
   1 nv_cnt = i4
   1 nv[*]
     2 pvc_name = vc
     2 pvc_value = vc
   1 batch_selection = vc
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = vc
    1 cur_node = vc
    1 rpt_list[*]
      2 file_name_full_path = vc
      2 file_format = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE program_name = vc WITH noconstant(""), protect
 DECLARE lknt = i4 WITH noconstant(0), protect
 DECLARE i_typeflag = i2 WITH noconstant(0), protect
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
 SET stat = moverec(request,treq)
 IF (stat=0)
  SET failed = input_error
  SET table_name = "MOVEREC"
  SET serrmsg = "MOVEREC failed to copy request to treq"
  GO TO exit_program
 ENDIF
 CALL echo("***")
 CALL echo("***   Validate Request")
 CALL echo("***")
 IF ( NOT (trim(request->script_name) > " "))
  SET failed = input_error
  SET table_name = "REQUEST"
  SET serrmsg = "REQUEST->SCRIPT_NAME must be valued"
  GO TO exit_program
 ELSE
  SET program_name = cnvtupper(trim(request->script_name))
  IF (substring(1,6,cnvtupper(request->script_name))="##ST##")
   SET program_name = "CV_GET_CLIN_NOTE_DOC"
  ENDIF
 ENDIF
 IF ((request->person_cnt > 0))
  SET lknt = request->person_cnt
  SET i_typeflag = 1
  SET stat = alterlist(reply->rpt_list,lknt)
 ELSEIF ((request->visit_cnt > 0))
  SET lknt = request->visit_cnt
  SET i_typeflag = 2
  SET stat = alterlist(reply->rpt_list,lknt)
 ELSEIF ((request->prsnl_cnt > 0))
  SET lknt = request->prsnl_cnt
  SET i_typeflag = 3
  SET stat = alterlist(reply->rpt_list,lknt)
 ELSE
  SET failed = input_error
  SET table_name = "REQUEST"
  SET serrmsg = "Unable to determine report CNT"
  GO TO exit_program
 ENDIF
 FOR (idx = 1 TO lknt)
   CALL echo("***")
   CALL echo("***   Generate File Name")
   CALL echo("***")
   EXECUTE cpm_create_file_name "rpt", "dat"
   IF ((cpm_cfn_info->status_data.status != "S"))
    SET failed = exe_error
    SET table_name = "CPM_CREATE_FILE_NAME"
    SET serrmsg = substring(1,132,cpm_cfn_info->status_data.targetobjectvalue)
    GO TO exit_program
   ENDIF
   SET request->output_device = trim(cpm_cfn_info->file_name_path)
   SET reply->rpt_list[idx].file_name_full_path = trim(cpm_cfn_info->file_name_full_path)
   IF (i_typeflag=1)
    SET request->person_cnt = 1
    SET stat = alterlist(request->person,1)
    SET request->person[1].person_id = treq->person[idx].person_id
   ELSEIF (i_typeflag=2)
    SET request->visit_cnt = 1
    SET stat = alterlist(request->visit,1)
    SET request->visit[1].encntr_id = treq->visit[idx].encntr_id
   ELSEIF (i_typeflag=3)
    SET request->prsnl_cnt = 1
    SET stat = alterlist(request->prsnl,1)
    SET request->prsnl[1].prsnl_id = treq->prsnl[idx].prsnl_id
   ELSE
    SET failed = input_error
    SET table_name = "REQUEST"
    SET serrmsg = "Unable to determine report CNT"
    GO TO exit_program
   ENDIF
   CALL echo("***")
   CALL echo(build("***   Execute Report Script :",program_name))
   CALL echo("***")
   SET modify = nopredeclare
   EXECUTE value(program_name)
   SET modify = nopredeclare
   IF ((reply->status_data.status="F"))
    SET failed = exe_error
    SET table_name = trim(program_name)
    GO TO exit_script
   ENDIF
   CALL echo("***")
   CALL echo("***   Get File Format")
   CALL echo("***")
   EXECUTE cps_get_file_format value(reply->rpt_list[idx].file_name_full_path)
   IF (c_cpsstatus="S")
    SET reply->rpt_list[idx].file_format = str_fileformat
   ELSE
    IF ((reply->status_data.status != "Z"))
     SET failed = exe_error
     SET table_name = "CPS_GET_FILE_FORMAT"
     SET serrmsg = substring(1,132,str_cpsstatusmsg)
     GO TO exit_program
    ENDIF
   ENDIF
 ENDFOR
#exit_program
 IF ((request->script_name="DCP_RPT_PVPATLIST"))
  IF ((request->nv[1].pvc_name="LISTNAME"))
   DECLARE list_counter = i4 WITH noconstant(0)
   FOR (list_counter = 1 TO request->nv_cnt)
     EXECUTE cclaudit 0, "Run Report", "PowerChart",
     "System Object", "Report", "Patient List",
     "Report", 0.0, request->nv[list_counter].pvc_value
   ENDFOR
  ELSE
   EXECUTE cclaudit 0, "Run Report", "PowerChart",
   "System Object", "Report", "Report",
   "Report", 0.0, request->script_name
  ENDIF
 ELSE
  DECLARE slifecycle = vc WITH noconstant("")
  IF ((request->output_device=""))
   SET slifecycle = "Access/Use"
  ELSE
   SET slifecycle = "Report"
  ENDIF
  IF ((treq->person_cnt > 0))
   DECLARE person_counter = i4 WITH noconstant(0)
   FOR (person_counter = 1 TO lknt)
    EXECUTE cclaudit 1, "Run Report", "PowerChart",
    "Person", "Patient", "Patient",
    slifecycle, treq->person[person_counter].person_id, ""
    EXECUTE cclaudit 3, "Run Report", "PowerChart",
    "System Object", "Report", "Report",
    slifecycle, 0.0, request->script_name
   ENDFOR
  ELSEIF ((request->visit_cnt > 0))
   DECLARE visit_counter = i4 WITH noconstant(0)
   FOR (visit_counter = 1 TO lknt)
    EXECUTE cclaudit 1, "Run Report", "PowerChart",
    "Encounter", "Patient", "Encounter",
    slifecycle, treq->visit[visit_counter].encntr_id, ""
    EXECUTE cclaudit 3, "Run Report", "PowerChart",
    "System Object", "Report", "Report",
    slifecycle, 0.0, request->script_name
   ENDFOR
  ELSE
   EXECUTE cclaudit 0, "Run Report", "PowerChart",
   "System Object", "Report", "Report",
   slifecycle, 0.0, request->script_name
  ENDIF
 ENDIF
 SET reply->cur_node = curnode
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GENERATE_ID"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=exe_error)
   SET reply->status_data.subeventstatus[1].operationname = "EXECUTION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ENDIF
 IF ((reply->status_data.status != "F")
  AND (reply->status_data.status != "Z"))
  SET reply->status_data.status = "S"
 ENDIF
 SET cps_script_version = "003 10/12/06 NC014668"
END GO
