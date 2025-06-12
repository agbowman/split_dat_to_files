CREATE PROGRAM ags_regression_test:dba
 IF (validate(reply,"!")="!")
  FREE RECORD reply
  RECORD reply(
    1 ags_job_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript
 ENDIF
 EXECUTE cclseclogin2
 IF (validate(ags_get_code_defined,0)=0)
  EXECUTE ags_get_code
 ENDIF
 IF (validate(ags_log_header_defined,0)=0)
  EXECUTE ags_log_header
 ENDIF
 IF (get_script_status(0) != esuccessful)
  CALL log_msg(concat("> FAILED: AGS_Log_Header - iHigheststatus = ",cnvtstring(ihigheststatus)))
  SET undo_option = false
  SET exit_now = true
  GO TO msg_menu
 ENDIF
 CALL set_log_level(edebuglevel)
 FREE RECORD my_request
 RECORD my_request(
   1 batch_selection = vc
 )
 FREE RECORD msg_rec
 RECORD msg_rec(
   1 qual_knt = i4
   1 qual[*]
     2 line = vc
 )
 FREE RECORD test_rec
 RECORD test_rec(
   1 qual_knt = i4
   1 qual[*]
     2 job_id = f8
     2 test_type = i4
 )
 DECLARE exit_now = i2 WITH protect, noconstant(false)
 DECLARE undo_option = i2 WITH protect, noconstant(true)
 DECLARE job_row_knt = i4 WITH protect, noconstant(0)
 DECLARE data_row_knt = i4 WITH protect, noconstant(0)
 DECLARE working_job_id = f8 WITH public, noconstant(0.0)
 DECLARE working_task_id = f8 WITH public, noconstant(0.0)
 DECLARE working_file_type = vc WITH public, noconstant("")
 DECLARE working_file = vc WITH public, noconstant("")
 DECLARE working_domain = vc WITH public, noconstant("")
 DECLARE working_path = vc WITH public, noconstant("")
 DECLARE test_select = vc WITH public, noconstant("")
 DECLARE data_not_loaded = i2 WITH public, noconstant(false)
 DECLARE do_purge = i2 WITH public, noconstant(true)
 DECLARE test_type = i4 WITH public, noconstant(0)
 DECLARE test_knt = i4 WITH public, noconstant(0)
 DECLARE status = vc WITH public, noconstant("")
 DECLARE stat_msg = vc WITH public, noconstant("")
 DECLARE msg_line_nbr = i2 WITH public, noconstant(0)
 DECLARE msg_wknt = i2 WITH public, noconstant(0)
 DECLARE s_the_msg = vc WITH public, noconstant("")
 DECLARE d_job_id = f8 WITH public, noconstant(0.0)
 DECLARE i_test_type = i4 WITH public, noconstant(0)
 DECLARE s_file_type = vc WITH public, noconstant("")
 DECLARE log_msg(s_the_msg=vc) = i2
 DECLARE log_test(d_job_id=f8,i_test_type=i4) = i2
 DECLARE valid_job(d_job_id=f8,s_file_type=vc) = i2
 DECLARE clean_up(i_empty=i4) = i2
#path_prompt
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_NAME"
  DETAIL
   working_domain = di.info_char
  WITH nocounter
 ;end select
 SET working_path = concat("/cerner/d_",cnvtlower(working_domain),"/data/cern_test/regression/")
 SET accept = video(n)
 CALL video(n)
 CALL clear(1,1)
 CALL box(1,1,23,80)
 CALL line(3,1,80,xhor)
 CALL text(2,3,"AGS REGRESSION TEST PROGRAM")
 CALL box(4,3,22,78)
 CALL line(6,3,76,xhor)
 CALL text(5,4," Regression Test Data Directory")
 CALL text(24,2,"Enter path: ")
 CALL accept(24,14,"X(100);",working_path)
 SET working_path = curaccept
 IF ( NOT (findfile(value(working_path))))
  CALL log_msg(concat("> FAILED: ",working_path," path does not exist"))
  SET undo_option = false
  SET exit_now = true
  GO TO msg_menu
 ENDIF
#main_menu
 CALL video(n)
 CALL clear(1,1)
 CALL box(1,1,23,80)
 CALL line(3,1,80,xhor)
 CALL text(2,3,"AGS REGRESSION TEST PROGRAM")
 CALL box(4,3,22,78)
 CALL line(6,3,76,xhor)
 CALL text(5,4," Test Menu")
 CALL text(7,4," 1. Org")
 CALL text(9,4," 2. Prsnl")
 CALL text(11,4," 3. Person")
 CALL text(13,4," 4. Claim")
 CALL text(15,4," 5. Result")
 CALL text(7,36," 6. Meds")
 CALL text(9,36," 7. Immun")
 CALL text(11,36," 8. Claim Detail")
 CALL text(13,36," 9. Plan")
 CALL text(21,4," 0 - Exit")
 CALL text(24,2,"Select an item number:  ")
 CALL accept(24,25,"9;H",9
  WHERE curaccept >= 0
   AND curaccept <= 9)
 SET test_type = curaccept
 CASE (test_type)
  OF 1:
   SET working_file_type = "PRSNL_ORG"
   SET working_file = "regression_test_org"
  OF 2:
   SET working_file_type = "PRSNL_ORG"
   SET working_file = "regression_test_prsnl"
  OF 3:
   SET working_file_type = "PERSON"
   SET working_file = "regression_test_person"
  OF 4:
   SET working_file_type = "CLAIM"
   SET working_file = "regression_test_claim"
  OF 5:
   SET working_file_type = "RESULT"
   SET working_file = "regression_test_result"
  OF 6:
   SET working_file_type = "MEDS"
   SET working_file = "regression_test_meds"
  OF 7:
   SET working_file_type = "IMMUN"
   SET working_file = "regression_test_immun"
  OF 8:
   SET working_file_type = "CLAIMDETAIL"
   SET working_file = "regression_test_claim_detail"
  OF 9:
   SET working_file_type = "PLAN"
   SET working_file = "regression_test_plan"
  OF 0:
   GO TO exit_script
  ELSE
   GO TO main_menu
 ENDCASE
#purge_menu
 CALL video(n)
 CALL clear(1,1)
 CALL box(1,1,23,80)
 CALL line(3,1,80,xhor)
 CALL text(2,3,"AGS REGRESSION TEST PROGRAM")
 CALL box(4,3,22,78)
 CALL line(6,3,76,xhor)
 CALL text(5,4," Test Types")
 CALL text(7,4," 1. Import + Load")
 CALL text(9,4," 2. Import + Load + Purge")
 CALL text(21,4," 0 - Return to Main Menu")
 CALL text(24,2,"Select an item number:  ")
 CALL accept(24,25,"9;H",2
  WHERE curaccept >= 0
   AND curaccept <= 9)
 CASE (curaccept)
  OF 1:
   SET do_purge = false
  OF 2:
   SET do_purge = true
  OF 0:
   GO TO main_menu
  ELSE
   GO TO purge_menu
 ENDCASE
 SET data_not_loaded = true
 SELECT INTO "nl:"
  FROM ags_job j
  WHERE ((test_type=1
   AND j.filename="*regression_test_org*") OR (((test_type=2
   AND j.filename="*regression_test_prsnl*") OR (((test_type=3
   AND j.filename="*regression_test_person*") OR (((test_type=4
   AND j.filename="*regression_test_claim*") OR (((test_type=5
   AND j.filename="*regression_test_result*") OR (((test_type=6
   AND j.filename="*regression_test_meds*") OR (((test_type=7
   AND j.filename="*regression_test_immun*") OR (((test_type=8
   AND j.filename="*regression_test_claim_detail*") OR (test_type=9
   AND j.filename="*regression_test_plan*")) )) )) )) )) )) )) ))
  DETAIL
   data_not_loaded = false, working_job_id = j.ags_job_id
  WITH nocounter
 ;end select
 IF (data_not_loaded != true)
  CALL log_msg(concat("> FAILED: Duplicate data : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
  SET undo_option = false
  GO TO msg_menu
 ENDIF
 CALL log_msg("BEGIN TEST")
 IF ( NOT (findfile(value(concat(working_path,working_file,".par")))))
  CALL log_msg("> FAILED: path does not contain .par")
  GO TO msg_menu
 ENDIF
 IF ( NOT (findfile(value(concat(working_path,working_file,".ctl")))))
  CALL log_msg("> FAILED: path does not contain .ctl")
  GO TO msg_menu
 ENDIF
 IF ( NOT (findfile(value(concat(working_path,working_file,".csv")))))
  CALL log_msg("> FAILED: path does not contain .csv")
  GO TO msg_menu
 ENDIF
 SET test_select = concat("<par_file|",working_path,working_file,".par>")
 SET my_request->batch_selection = test_select
 CALL log_msg(concat("> Path: ",working_path))
 CALL log_msg(concat("> File: ",working_file))
 SET job_row_knt = 0
 SET undo_option = true
 SET working_job_id = 0.0
 SET stat = initrec(reply)
 CALL log_msg("Executed AGS_IMPORT_DATA_FILES")
 EXECUTE ags_import_data_files  WITH replace("REQUEST","MY_REQUEST")
 SET working_job_id = reply->ags_job_id
 IF ((reply->status_data.status != "S"))
  CALL log_msg(concat("> FAILED: AGS_IMPORT_DATA_FILES : status<",reply->status_data.status,
    "> : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
  CALL log_test(working_job_id,1)
  GO TO msg_menu
 ENDIF
 IF (valid_job(working_job_id,working_file_type))
  SET data_row_knt = 0
  SET working_task_id = 0.0
  CASE (test_type)
   OF 1:
    GO TO org_test
   OF 2:
    GO TO prsnl_test
   OF 3:
    GO TO person_test
   OF 4:
    GO TO claim_test
   OF 5:
    GO TO result_test
   OF 6:
    GO TO meds_test
   OF 7:
    GO TO immun_test
   OF 8:
    GO TO detail_test
   OF 9:
    GO TO plan_test
   ELSE
    GO TO msg_menu
  ENDCASE
 ELSE
  CALL log_msg(concat("> FAILED: INVALID AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
  GO TO msg_menu
 ENDIF
#org_test
 SELECT INTO "nl:"
  FROM ags_org_data a
  WHERE a.ags_job_id=working_job_id
  DETAIL
   data_row_knt = (data_row_knt+ 1)
  WITH nocounter
 ;end select
 IF (job_row_knt != data_row_knt)
  CALL log_msg(concat("> FAILED: Invalid RECORD_COUNT : Job Record Count<",trim(cnvtstring(
      job_row_knt)),"> : Data Rows<",trim(cnvtstring(data_row_knt)),">"))
  CALL log_test(working_job_id,1)
  GO TO msg_menu
 ELSE
  CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),"> : Record Count<",
    trim(cnvtstring(data_row_knt)),">"))
 ENDIF
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE t.ags_job_id=working_job_id
  DETAIL
   working_task_id = t.ags_task_id
  WITH nocounter
 ;end select
 EXECUTE ags_org_load working_task_id
 CALL log_msg(concat("Executed AGS_ORG_LOAD : AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
 IF ((reply->status_data.status != "S"))
  CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
  CALL log_test(working_job_id,1)
 ELSE
  SET data_not_loaded = false
  SELECT INTO "nl:"
   FROM ags_org_data a
   WHERE a.ags_job_id=working_job_id
    AND a.status != "COMPLETE"
   DETAIL
    data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
   WITH nocounter
  ;end select
  IF (data_not_loaded=true)
   CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
     status,"> : msg<",
     stat_msg,">"))
   CALL log_test(working_job_id,1)
  ELSE
   CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
   IF (do_purge=false)
    CALL log_test(working_job_id,1)
    SET undo_option = false
    CALL log_msg(concat("END TEST"))
   ELSE
    EXECUTE ags_org_backout value("J"), value(working_job_id)
    CALL log_msg(concat("Executed AGS_ORG_BACKOUT : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"
      ))
    IF ((reply->status_data.status != "S"))
     CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
     CALL log_test(working_job_id,1)
    ELSE
     SET data_not_loaded = true
     SELECT INTO "nl:"
      FROM ags_org_data a
      WHERE a.ags_job_id=working_job_id
       AND a.status != "BACK OUT"
      DETAIL
       data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
      WITH nocounter
     ;end select
     IF (data_not_loaded=false)
      CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
        status,"> : msg<",
        stat_msg,">"))
      CALL log_test(working_job_id,1)
     ELSE
      CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
      UPDATE  FROM ags_task a
       SET a.mode_flag = 1
       WHERE a.ags_task_id=working_task_id
       WITH nocounter
      ;end update
      EXECUTE ags_org_load working_task_id
      CALL log_msg(concat("Reloaded data AGS_ORG_LOAD : AGS_TASK_ID<",trim(cnvtstring(working_task_id
          )),">"))
      IF ((reply->status_data.status != "S"))
       CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
       CALL log_test(working_job_id,1)
      ELSE
       SET data_not_loaded = false
       SELECT INTO "nl:"
        FROM ags_org_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
        DETAIL
         data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
        WITH nocounter
       ;end select
       IF (data_not_loaded=true)
        CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
          status,"> : msg<",
          stat_msg,">"))
        CALL log_test(working_job_id,1)
       ELSE
        CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
        CALL log_msg(concat("Executed AGS_ORG_PURGE : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
          ">"))
        EXECUTE ags_org_purge value("J"), value(working_job_id)
        IF ((reply->status_data.status != "S"))
         CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
         CALL log_test(working_job_id,1)
        ELSE
         SET data_not_loaded = true
         SELECT INTO "nl:"
          FROM ags_org_data a
          WHERE a.ags_job_id=working_job_id
           AND a.status != "BACK OUT"
          DETAIL
           data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
          WITH nocounter
         ;end select
         IF (data_not_loaded=false)
          CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
            status,"> : msg<",
            stat_msg,">"))
          CALL log_test(working_job_id,1)
         ELSE
          CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          CALL log_msg(concat("Deleted AGS_ORG_DATA : AGS_TASK_ID<",trim(cnvtstring(working_task_id)),
            "> : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          DELETE  FROM ags_org_data a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_task a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_job a
           WHERE a.ags_job_id=working_job_id
           WITH nounter
          ;end delete
          COMMIT
          SET undo_option = false
          CALL log_msg(concat("END TEST"))
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO msg_menu
#prsnl_test
 SELECT INTO "nl:"
  FROM ags_prsnl_data a
  WHERE a.ags_job_id=working_job_id
  DETAIL
   data_row_knt = (data_row_knt+ 1)
  WITH nocounter
 ;end select
 IF (job_row_knt != data_row_knt)
  CALL log_msg(concat("> FAILED: Invalid RECORD_COUNT : Job Record Count<",trim(cnvtstring(
      job_row_knt)),"> : Data Rows<",trim(cnvtstring(data_row_knt)),">"))
  CALL log_test(working_job_id,1)
  GO TO msg_menu
 ELSE
  CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),"> : Record Count<",
    trim(cnvtstring(data_row_knt)),">"))
 ENDIF
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE t.ags_job_id=working_job_id
  DETAIL
   working_task_id = t.ags_task_id
  WITH nocounter
 ;end select
 EXECUTE ags_prsnl_load working_task_id
 CALL log_msg(concat("Executed AGS_PRSNL_LOAD : AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
 IF ((reply->status_data.status != "S"))
  CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
  CALL log_test(working_job_id,2)
 ELSE
  SET data_not_loaded = false
  SELECT INTO "nl:"
   FROM ags_prsnl_data a
   WHERE a.ags_job_id=working_job_id
    AND a.status != "COMPLETE"
   DETAIL
    data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
   WITH nocounter
  ;end select
  IF (data_not_loaded=true)
   CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
     status,"> : msg<",
     stat_msg,">"))
   CALL log_test(working_job_id,2)
  ELSE
   CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
   IF (do_purge=false)
    CALL log_test(working_job_id,2)
    SET undo_option = false
    CALL log_msg(concat("END TEST"))
   ELSE
    EXECUTE ags_prsnl_backout value("J"), value(working_job_id)
    CALL log_msg(concat("Executed AGS_PRSNL_BACKOUT : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
      ">"))
    IF ((reply->status_data.status != "S"))
     CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
     CALL log_test(working_job_id,2)
    ELSE
     SET data_not_loaded = true
     SELECT INTO "nl:"
      FROM ags_prsnl_data a
      WHERE a.ags_job_id=working_job_id
       AND a.status != "BACK OUT"
      DETAIL
       data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
      WITH nocounter
     ;end select
     IF (data_not_loaded=false)
      CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
        status,"> : msg<",
        stat_msg,">"))
      CALL log_test(working_job_id,2)
     ELSE
      CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
      UPDATE  FROM ags_task a
       SET a.mode_flag = 1
       WHERE a.ags_task_id=working_task_id
       WITH nocounter
      ;end update
      EXECUTE ags_prsnl_load working_task_id
      CALL log_msg(concat("Reloaded data AGS_PRSNL_LOAD : AGS_TASK_ID<",trim(cnvtstring(
          working_task_id)),">"))
      IF ((reply->status_data.status != "S"))
       CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
       CALL log_test(working_job_id,2)
      ELSE
       SET data_not_loaded = false
       SELECT INTO "nl:"
        FROM ags_prsnl_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
        DETAIL
         data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
        WITH nocounter
       ;end select
       IF (data_not_loaded=true)
        CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
          status,"> : msg<",
          stat_msg,">"))
        CALL log_test(working_job_id,2)
       ELSE
        CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
        CALL log_msg(concat("Executed AGS_PRSNL_PURGE : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
          ">"))
        EXECUTE ags_prsnl_purge value("J"), value(working_job_id)
        IF ((reply->status_data.status != "S"))
         CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
         CALL log_test(working_job_id,2)
        ELSE
         SET data_not_loaded = true
         SELECT INTO "nl:"
          FROM ags_prsnl_data a
          WHERE a.ags_job_id=working_job_id
           AND a.status != "BACK OUT"
          DETAIL
           data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
          WITH nocounter
         ;end select
         IF (data_not_loaded=false)
          CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
            status,"> : msg<",
            stat_msg,">"))
          CALL log_test(working_job_id,2)
         ELSE
          CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          CALL log_msg(concat("Deleted AGS_PRSNL_DATA : AGS_TASK_ID<",trim(cnvtstring(working_task_id
              )),"> : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          DELETE  FROM ags_prsnl_data a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_task a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_job a
           WHERE a.ags_job_id=working_job_id
           WITH nounter
          ;end delete
          COMMIT
          SET undo_option = false
          CALL log_msg(concat("END TEST"))
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO msg_menu
#person_test
 SELECT INTO "nl:"
  FROM ags_person_data a
  WHERE a.ags_job_id=working_job_id
  DETAIL
   data_row_knt = (data_row_knt+ 1)
  WITH nocounter
 ;end select
 IF (job_row_knt != data_row_knt)
  CALL log_msg(concat("> FAILED: Invalid RECORD_COUNT : Job Record Count<",trim(cnvtstring(
      job_row_knt)),"> : Data Rows<",trim(cnvtstring(data_row_knt)),">"))
  CALL log_test(working_job_id,1)
  GO TO msg_menu
 ELSE
  CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),"> : Record Count<",
    trim(cnvtstring(data_row_knt)),">"))
 ENDIF
 FREE RECORD rpersonload
 RECORD rpersonload(
   1 debug_logging = i4
   1 ags_task_id = f8
   1 require_ssn = i4
   1 consent_cdf = vc
 )
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE t.ags_job_id=working_job_id
  DETAIL
   rpersonload->consent_cdf = "YES", rpersonload->require_ssn = 0, rpersonload->ags_task_id = t
   .ags_task_id,
   rpersonload->debug_logging = t.timers_flag, working_task_id = t.ags_task_id
  WITH nocounter
 ;end select
 EXECUTE ags_person_load  WITH replace("REQUEST","RPERSONLOAD")
 CALL log_msg(concat("Executed AGS_PERSON_LOAD : AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">")
  )
 IF ((reply->status_data.status != "S"))
  CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
  CALL log_test(working_job_id,3)
 ELSE
  SET data_not_loaded = false
  SELECT INTO "nl:"
   FROM ags_person_data a
   WHERE a.ags_job_id=working_job_id
    AND a.status != "COMPLETE"
   DETAIL
    data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
   WITH nocounter
  ;end select
  IF (data_not_loaded=true)
   CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
     status,"> : msg<",
     stat_msg,">"))
   CALL log_test(working_job_id,3)
  ELSE
   CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
   IF (do_purge=false)
    CALL log_test(working_job_id,3)
    SET undo_option = false
    CALL log_msg(concat("END TEST"))
   ELSE
    EXECUTE ags_person_backout value("J"), value(working_job_id)
    CALL log_msg(concat("Executed AGS_PERSON_BACKOUT : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
      ">"))
    IF ((reply->status_data.status != "S"))
     CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
     CALL log_test(working_job_id,3)
    ELSE
     SET data_not_loaded = true
     SELECT INTO "nl:"
      FROM ags_person_data a
      WHERE a.ags_job_id=working_job_id
       AND a.status != "BACK OUT"
      DETAIL
       data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
      WITH nocounter
     ;end select
     IF (data_not_loaded=false)
      CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
        status,"> : msg<",
        stat_msg,">"))
      CALL log_test(working_job_id,3)
     ELSE
      CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
      UPDATE  FROM ags_task a
       SET a.mode_flag = 1
       WHERE a.ags_task_id=working_task_id
       WITH nocounter
      ;end update
      EXECUTE ags_person_load  WITH replace("REQUEST","RPERSONLOAD")
      CALL log_msg(concat("Reloaded data AGS_PERSON_LOAD : AGS_TASK_ID<",trim(cnvtstring(
          working_task_id)),">"))
      IF ((reply->status_data.status != "S"))
       CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
       CALL log_test(working_job_id,3)
      ELSE
       SET data_not_loaded = false
       SELECT INTO "nl:"
        FROM ags_person_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
        DETAIL
         data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
        WITH nocounter
       ;end select
       IF (data_not_loaded=true)
        CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
          status,"> : msg<",
          stat_msg,">"))
        CALL log_test(working_job_id,3)
       ELSE
        CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
        CALL log_msg(concat("Executed AGS_PERSON_PURGE : AGS_JOB_ID<",trim(cnvtstring(working_job_id)
           ),">"))
        EXECUTE ags_person_purge value("J"), value(working_job_id)
        IF ((reply->status_data.status != "S"))
         CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
         CALL log_test(working_job_id,3)
        ELSE
         SET data_not_loaded = true
         SELECT INTO "nl:"
          FROM ags_person_data a
          WHERE a.ags_job_id=working_job_id
           AND a.status != "BACK OUT"
          DETAIL
           data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
          WITH nocounter
         ;end select
         IF (data_not_loaded=false)
          CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
            status,"> : msg<",
            stat_msg,">"))
          CALL log_test(working_job_id,3)
         ELSE
          CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          CALL log_msg(concat("Deleted AGS_PERSON_DATA : AGS_TASK_ID<",trim(cnvtstring(
              working_task_id)),"> : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          DELETE  FROM ags_person_data a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_task a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_job a
           WHERE a.ags_job_id=working_job_id
           WITH nounter
          ;end delete
          COMMIT
          SET undo_option = false
          CALL log_msg(concat("END TEST"))
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO msg_menu
#claim_test
 SELECT INTO "nl:"
  FROM ags_claim_data a
  WHERE a.ags_job_id=working_job_id
  DETAIL
   data_row_knt = (data_row_knt+ 1)
  WITH nocounter
 ;end select
 IF (job_row_knt != data_row_knt)
  CALL log_msg(concat("> FAILED: Invalid RECORD_COUNT : Job Record Count<",trim(cnvtstring(
      job_row_knt)),"> : Data Rows<",trim(cnvtstring(data_row_knt)),">"))
  CALL log_test(working_job_id,1)
  GO TO msg_menu
 ELSE
  CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),"> : Record Count<",
    trim(cnvtstring(data_row_knt)),">"))
 ENDIF
 FREE RECORD rclaimload
 RECORD rclaimload(
   1 debug_logging = i4
   1 ags_task_id = f8
 )
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE t.ags_job_id=working_job_id
  DETAIL
   rclaimload->ags_task_id = t.ags_task_id, rclaimload->debug_logging = t.timers_flag,
   working_task_id = t.ags_task_id
  WITH nocounter
 ;end select
 EXECUTE ags_claim_load  WITH replace("REQUEST","RCLAIMLOAD")
 CALL log_msg(concat("Executed AGS_CLAIM_LOAD : AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
 IF ((reply->status_data.status != "S"))
  CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
  CALL log_test(working_job_id,4)
 ELSE
  SET data_not_loaded = false
  SELECT INTO "nl:"
   FROM ags_claim_data a
   WHERE a.ags_job_id=working_job_id
    AND a.status != "COMPLETE"
   DETAIL
    data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
   WITH nocounter
  ;end select
  IF (data_not_loaded=true)
   CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
     status,"> : msg<",
     stat_msg,">"))
   CALL log_test(working_job_id,4)
  ELSE
   CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
   IF (do_purge=false)
    CALL log_test(working_job_id,4)
    SET undo_option = false
    CALL log_msg(concat("END TEST"))
   ELSE
    EXECUTE ags_claim_backout value("J"), value(working_job_id)
    CALL log_msg(concat("Executed AGS_CLAIM_BACKOUT : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
      ">"))
    IF ((reply->status_data.status != "S"))
     CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
     CALL log_test(working_job_id,4)
    ELSE
     SET data_not_loaded = true
     SELECT INTO "nl:"
      FROM ags_claim_data a
      WHERE a.ags_job_id=working_job_id
       AND a.status != "BACK OUT"
      DETAIL
       data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
      WITH nocounter
     ;end select
     IF (data_not_loaded=false)
      CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
        status,"> : msg<",
        stat_msg,">"))
      CALL log_test(working_job_id,4)
     ELSE
      CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
      UPDATE  FROM ags_task a
       SET a.mode_flag = 1
       WHERE a.ags_task_id=working_task_id
       WITH nocounter
      ;end update
      EXECUTE ags_claim_load  WITH replace("REQUEST","RCLAIMLOAD")
      CALL log_msg(concat("Reloaded data AGS_CLAIM_LOAD : AGS_TASK_ID<",trim(cnvtstring(
          working_task_id)),">"))
      IF ((reply->status_data.status != "S"))
       CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
       CALL log_test(working_job_id,4)
      ELSE
       SET data_not_loaded = false
       SELECT INTO "nl:"
        FROM ags_claim_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
        DETAIL
         data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
        WITH nocounter
       ;end select
       IF (data_not_loaded=true)
        CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
          status,"> : msg<",
          stat_msg,">"))
        CALL log_test(working_job_id,4)
       ELSE
        CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
        CALL log_msg(concat("Executed AGS_CLAIM_PURGE : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
          ">"))
        EXECUTE ags_claim_purge value("J"), value(working_job_id)
        IF ((reply->status_data.status != "S"))
         CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
         CALL log_test(working_job_id,4)
        ELSE
         SET data_not_loaded = true
         SELECT INTO "nl:"
          FROM ags_claim_data a
          WHERE a.ags_job_id=working_job_id
           AND a.status != "BACK OUT"
          DETAIL
           data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
          WITH nocounter
         ;end select
         IF (data_not_loaded=false)
          CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
            status,"> : msg<",
            stat_msg,">"))
          CALL log_test(working_job_id,4)
         ELSE
          CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          CALL log_msg(concat("Deleted AGS_CLAIM_DATA : AGS_TASK_ID<",trim(cnvtstring(working_task_id
              )),"> : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          DELETE  FROM ags_claim_data a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_task a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_job a
           WHERE a.ags_job_id=working_job_id
           WITH nounter
          ;end delete
          COMMIT
          SET undo_option = false
          CALL log_msg(concat("END TEST"))
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO msg_menu
#result_test
 SELECT INTO "nl:"
  FROM ags_result_data a
  WHERE a.ags_job_id=working_job_id
  DETAIL
   data_row_knt = (data_row_knt+ 1)
  WITH nocounter
 ;end select
 IF (job_row_knt != data_row_knt)
  CALL log_msg(concat("> FAILED: Invalid RECORD_COUNT : Job Record Count<",trim(cnvtstring(
      job_row_knt)),"> : Data Rows<",trim(cnvtstring(data_row_knt)),">"))
  CALL log_test(working_job_id,1)
  GO TO msg_menu
 ELSE
  CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),"> : Record Count<",
    trim(cnvtstring(data_row_knt)),">"))
 ENDIF
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE t.ags_job_id=working_job_id
  DETAIL
   working_task_id = t.ags_task_id
  WITH nocounter
 ;end select
 EXECUTE ags_result_load working_task_id
 CALL log_msg(concat("Executed AGS_RESULT_LOAD : AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">")
  )
 IF ((reply->status_data.status != "S"))
  CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
  CALL log_test(working_job_id,5)
 ELSE
  SET data_not_loaded = false
  SELECT INTO "nl:"
   FROM ags_result_data a
   WHERE a.ags_job_id=working_job_id
    AND a.status != "COMPLETE"
   DETAIL
    data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
   WITH nocounter
  ;end select
  IF (data_not_loaded=true)
   CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
     status,"> : msg<",
     stat_msg,">"))
   CALL log_test(working_job_id,5)
  ELSE
   CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
   IF (do_purge=false)
    CALL log_test(working_job_id,5)
    SET undo_option = false
    CALL log_msg(concat("END TEST"))
   ELSE
    EXECUTE ags_result_backout value("J"), value(working_job_id)
    CALL log_msg(concat("Executed AGS_RESULT_BACKOUT : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
      ">"))
    IF ((reply->status_data.status != "S"))
     CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
     CALL log_test(working_job_id,5)
    ELSE
     SET data_not_loaded = true
     SELECT INTO "nl:"
      FROM ags_result_data a
      WHERE a.ags_job_id=working_job_id
       AND a.status != "BACK OUT"
      DETAIL
       data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
      WITH nocounter
     ;end select
     IF (data_not_loaded=false)
      CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
        status,"> : msg<",
        stat_msg,">"))
      CALL log_test(working_job_id,5)
     ELSE
      CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
      UPDATE  FROM ags_task a
       SET a.mode_flag = 1
       WHERE a.ags_task_id=working_task_id
       WITH nocounter
      ;end update
      EXECUTE ags_result_load working_task_id
      CALL log_msg(concat("Reloaded data AGS_RESULT_LOAD : AGS_TASK_ID<",trim(cnvtstring(
          working_task_id)),">"))
      IF ((reply->status_data.status != "S"))
       CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
       CALL log_test(working_job_id,5)
      ELSE
       SET data_not_loaded = false
       SELECT INTO "nl:"
        FROM ags_result_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
        DETAIL
         data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
        WITH nocounter
       ;end select
       IF (data_not_loaded=true)
        CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
          status,"> : msg<",
          stat_msg,">"))
        CALL log_test(working_job_id,5)
       ELSE
        CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
        CALL log_msg(concat("Executed AGS_RESULT_PURGE : AGS_JOB_ID<",trim(cnvtstring(working_job_id)
           ),">"))
        EXECUTE ags_result_purge value("J"), value(working_job_id)
        IF ((reply->status_data.status != "S"))
         CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
         CALL log_test(working_job_id,5)
        ELSE
         SET data_not_loaded = true
         SELECT INTO "nl:"
          FROM ags_result_data a
          WHERE a.ags_job_id=working_job_id
           AND a.status != "BACK OUT"
          DETAIL
           data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
          WITH nocounter
         ;end select
         IF (data_not_loaded=false)
          CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
            status,"> : msg<",
            stat_msg,">"))
          CALL log_test(working_job_id,5)
         ELSE
          CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          CALL log_msg(concat("Deleted AGS_RESULT_DATA : AGS_TASK_ID<",trim(cnvtstring(
              working_task_id)),"> : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          DELETE  FROM ags_result_data a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_task a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_job a
           WHERE a.ags_job_id=working_job_id
           WITH nounter
          ;end delete
          COMMIT
          SET undo_option = false
          CALL log_msg(concat("END TEST"))
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO msg_menu
#meds_test
 SELECT INTO "nl:"
  FROM ags_meds_data a
  WHERE a.ags_job_id=working_job_id
  DETAIL
   data_row_knt = (data_row_knt+ 1)
  WITH nocounter
 ;end select
 IF (job_row_knt != data_row_knt)
  CALL log_msg(concat("> FAILED: Invalid RECORD_COUNT : Job Record Count<",trim(cnvtstring(
      job_row_knt)),"> : Data Rows<",trim(cnvtstring(data_row_knt)),">"))
  CALL log_test(working_job_id,1)
  GO TO msg_menu
 ELSE
  CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),"> : Record Count<",
    trim(cnvtstring(data_row_knt)),">"))
 ENDIF
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE t.ags_job_id=working_job_id
  DETAIL
   working_task_id = t.ags_task_id
  WITH nocounter
 ;end select
 EXECUTE ags_meds_load working_task_id
 CALL log_msg(concat("Executed AGS_MEDS_LOAD : AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
 IF ((reply->status_data.status != "S"))
  CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
  CALL log_test(working_job_id,6)
 ELSE
  SET data_not_loaded = false
  SELECT INTO "nl:"
   FROM ags_meds_data a
   WHERE a.ags_job_id=working_job_id
    AND a.status != "COMPLETE"
   DETAIL
    data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
   WITH nocounter
  ;end select
  IF (data_not_loaded=true)
   CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
     status,"> : msg<",
     stat_msg,">"))
   CALL log_test(working_job_id,6)
  ELSE
   CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
   IF (do_purge=false)
    CALL log_test(working_job_id,6)
    SET undo_option = false
    CALL log_msg(concat("END TEST"))
   ELSE
    EXECUTE ags_meds_backout value("J"), value(working_job_id)
    CALL log_msg(concat("Executed AGS_MEDS_BACKOUT : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
      ">"))
    IF ((reply->status_data.status != "S"))
     CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
     CALL log_test(working_job_id,6)
    ELSE
     SET data_not_loaded = true
     SELECT INTO "nl:"
      FROM ags_meds_data a
      WHERE a.ags_job_id=working_job_id
       AND a.status != "BACK OUT"
      DETAIL
       data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
      WITH nocounter
     ;end select
     IF (data_not_loaded=false)
      CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
        status,"> : msg<",
        stat_msg,">"))
      CALL log_test(working_job_id,6)
     ELSE
      CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
      UPDATE  FROM ags_task a
       SET a.mode_flag = 1
       WHERE a.ags_task_id=working_task_id
       WITH nocounter
      ;end update
      EXECUTE ags_meds_load working_task_id
      CALL log_msg(concat("Reloaded data AGS_MEDS_LOAD : AGS_TASK_ID<",trim(cnvtstring(
          working_task_id)),">"))
      IF ((reply->status_data.status != "S"))
       CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
       CALL log_test(working_job_id,6)
      ELSE
       SET data_not_loaded = false
       SELECT INTO "nl:"
        FROM ags_meds_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
        DETAIL
         data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
        WITH nocounter
       ;end select
       IF (data_not_loaded=true)
        CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
          status,"> : msg<",
          stat_msg,">"))
        CALL log_test(working_job_id,6)
       ELSE
        CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
        CALL log_msg(concat("Executed AGS_MEDS_PURGE : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
          ">"))
        EXECUTE ags_meds_purge value("J"), value(working_job_id)
        IF ((reply->status_data.status != "S"))
         CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
         CALL log_test(working_job_id,6)
        ELSE
         SET data_not_loaded = true
         SELECT INTO "nl:"
          FROM ags_meds_data a
          WHERE a.ags_job_id=working_job_id
           AND a.status != "BACK OUT"
          DETAIL
           data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
          WITH nocounter
         ;end select
         IF (data_not_loaded=false)
          CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
            status,"> : msg<",
            stat_msg,">"))
          CALL log_test(working_job_id,6)
         ELSE
          CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          CALL log_msg(concat("Deleted AGS_MEDS_DATA : AGS_TASK_ID<",trim(cnvtstring(working_task_id)
             ),"> : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          DELETE  FROM ags_meds_data a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_task a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_job a
           WHERE a.ags_job_id=working_job_id
           WITH nounter
          ;end delete
          COMMIT
          SET undo_option = false
          CALL log_msg(concat("END TEST"))
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO msg_menu
#immun_test
 SELECT INTO "nl:"
  FROM ags_immun_data a
  WHERE a.ags_job_id=working_job_id
  DETAIL
   data_row_knt = (data_row_knt+ 1)
  WITH nocounter
 ;end select
 IF (job_row_knt != data_row_knt)
  CALL log_msg(concat("> FAILED: Invalid RECORD_COUNT : Job Record Count<",trim(cnvtstring(
      job_row_knt)),"> : Data Rows<",trim(cnvtstring(data_row_knt)),">"))
  CALL log_test(working_job_id,1)
  GO TO msg_menu
 ELSE
  CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),"> : Record Count<",
    trim(cnvtstring(data_row_knt)),">"))
 ENDIF
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE t.ags_job_id=working_job_id
  DETAIL
   working_task_id = t.ags_task_id
  WITH nocounter
 ;end select
 EXECUTE ags_immun_load working_task_id
 CALL log_msg(concat("Executed AGS_IMMUN_LOAD : AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
 IF ((reply->status_data.status != "S"))
  CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
  CALL log_test(working_job_id,7)
 ELSE
  SET data_not_loaded = false
  SELECT INTO "nl:"
   FROM ags_immun_data a
   WHERE a.ags_job_id=working_job_id
    AND a.status != "COMPLETE"
   DETAIL
    data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
   WITH nocounter
  ;end select
  IF (data_not_loaded=true)
   CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
     status,"> : msg<",
     stat_msg,">"))
   CALL log_test(working_job_id,7)
  ELSE
   CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
   IF (do_purge=false)
    CALL log_test(working_job_id,7)
    SET undo_option = false
    CALL log_msg(concat("END TEST"))
   ELSE
    EXECUTE ags_immun_backout value("J"), value(working_job_id)
    CALL log_msg(concat("Executed AGS_IMMUN_BACKOUT : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
      ">"))
    IF ((reply->status_data.status != "S"))
     CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
     CALL log_test(working_job_id,7)
    ELSE
     SET data_not_loaded = true
     SELECT INTO "nl:"
      FROM ags_immun_data a
      WHERE a.ags_job_id=working_job_id
       AND a.status != "BACK OUT"
      DETAIL
       data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
      WITH nocounter
     ;end select
     IF (data_not_loaded=false)
      CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
        status,"> : msg<",
        stat_msg,">"))
      CALL log_test(working_job_id,7)
     ELSE
      CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
      UPDATE  FROM ags_task a
       SET a.mode_flag = 1
       WHERE a.ags_task_id=working_task_id
       WITH nocounter
      ;end update
      EXECUTE ags_immun_load working_task_id
      CALL log_msg(concat("Reloaded data AGS_IMMUN_LOAD : AGS_TASK_ID<",trim(cnvtstring(
          working_task_id)),">"))
      IF ((reply->status_data.status != "S"))
       CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
       CALL log_test(working_job_id,7)
      ELSE
       SET data_not_loaded = false
       SELECT INTO "nl:"
        FROM ags_immun_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
        DETAIL
         data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
        WITH nocounter
       ;end select
       IF (data_not_loaded=true)
        CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
          status,"> : msg<",
          stat_msg,">"))
        CALL log_test(working_job_id,7)
       ELSE
        CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
        CALL log_msg(concat("Executed AGS_IMMUN_PURGE : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
          ">"))
        EXECUTE ags_immun_purge value("J"), value(working_job_id)
        IF ((reply->status_data.status != "S"))
         CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
         CALL log_test(working_job_id,7)
        ELSE
         SET data_not_loaded = true
         SELECT INTO "nl:"
          FROM ags_immun_data a
          WHERE a.ags_job_id=working_job_id
           AND a.status != "BACK OUT"
          DETAIL
           data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
          WITH nocounter
         ;end select
         IF (data_not_loaded=false)
          CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
            status,"> : msg<",
            stat_msg,">"))
          CALL log_test(working_job_id,7)
         ELSE
          CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          CALL log_msg(concat("Deleted AGS_IMMUN_DATA : AGS_TASK_ID<",trim(cnvtstring(working_task_id
              )),"> : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          DELETE  FROM ags_immun_data a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_task a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_job a
           WHERE a.ags_job_id=working_job_id
           WITH nounter
          ;end delete
          COMMIT
          SET undo_option = false
          CALL log_msg(concat("END TEST"))
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO msg_menu
#detail_test
 SELECT INTO "nl:"
  FROM ags_claim_detail_data a
  WHERE a.ags_job_id=working_job_id
  DETAIL
   data_row_knt = (data_row_knt+ 1)
  WITH nocounter
 ;end select
 IF (job_row_knt != data_row_knt)
  CALL log_msg(concat("> FAILED: Invalid RECORD_COUNT : Job Record Count<",trim(cnvtstring(
      job_row_knt)),"> : Data Rows<",trim(cnvtstring(data_row_knt)),">"))
  CALL log_test(working_job_id,1)
  GO TO msg_menu
 ELSE
  CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),"> : Record Count<",
    trim(cnvtstring(data_row_knt)),">"))
 ENDIF
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE t.ags_job_id=working_job_id
  DETAIL
   working_task_id = t.ags_task_id
  WITH nocounter
 ;end select
 EXECUTE ags_claimdet_load working_task_id
 CALL log_msg(concat("Executed AGS_CLAIMDET_LOAD : AGS_TASK_ID<",trim(cnvtstring(working_task_id)),
   ">"))
 IF ((reply->status_data.status != "S"))
  CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
  CALL log_test(working_job_id,8)
 ELSE
  SET data_not_loaded = false
  SELECT INTO "nl:"
   FROM ags_claim_detail_data a
   WHERE a.ags_job_id=working_job_id
    AND a.status != "COMPLETE"
   DETAIL
    data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
   WITH nocounter
  ;end select
  IF (data_not_loaded=true)
   CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
     status,"> : msg<",
     stat_msg,">"))
   CALL log_test(working_job_id,8)
  ELSE
   CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
   IF (do_purge=false)
    CALL log_test(working_job_id,8)
    SET undo_option = false
    CALL log_msg(concat("END TEST"))
   ELSE
    EXECUTE ags_claim_detail_backout value("J"), value(working_job_id)
    CALL log_msg(concat("Executed AGS_CLAIM_DETAIL_BACKOUT : AGS_JOB_ID<",trim(cnvtstring(
        working_job_id)),">"))
    IF ((reply->status_data.status != "S"))
     CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
     CALL log_test(working_job_id,8)
    ELSE
     SET data_not_loaded = true
     SELECT INTO "nl:"
      FROM ags_claim_detail_data a
      WHERE a.ags_job_id=working_job_id
       AND a.status != "BACK OUT"
      DETAIL
       data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
      WITH nocounter
     ;end select
     IF (data_not_loaded=false)
      CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
        status,"> : msg<",
        stat_msg,">"))
      CALL log_test(working_job_id,8)
     ELSE
      CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
      UPDATE  FROM ags_task a
       SET a.mode_flag = 1
       WHERE a.ags_task_id=working_task_id
       WITH nocounter
      ;end update
      EXECUTE ags_claimdet_load working_task_id
      CALL log_msg(concat("Reloaded data AGS_CLAIMDET_LOAD : AGS_TASK_ID<",trim(cnvtstring(
          working_task_id)),">"))
      IF ((reply->status_data.status != "S"))
       CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
       CALL log_test(working_job_id,8)
      ELSE
       SET data_not_loaded = false
       SELECT INTO "nl:"
        FROM ags_claim_detail_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
        DETAIL
         data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
        WITH nocounter
       ;end select
       IF (data_not_loaded=true)
        CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
          status,"> : msg<",
          stat_msg,">"))
        CALL log_test(working_job_id,8)
       ELSE
        CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
        CALL log_msg(concat("Executed AGS_CLAIM_DETAIL_PURGE : AGS_JOB_ID<",trim(cnvtstring(
            working_job_id)),">"))
        EXECUTE ags_claim_detail_purge value("J"), value(working_job_id)
        IF ((reply->status_data.status != "S"))
         CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
         CALL log_test(working_job_id,8)
        ELSE
         SET data_not_loaded = true
         SELECT INTO "nl:"
          FROM ags_claim_detail_data a
          WHERE a.ags_job_id=working_job_id
           AND a.status != "BACK OUT"
          DETAIL
           data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
          WITH nocounter
         ;end select
         IF (data_not_loaded=false)
          CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
            status,"> : msg<",
            stat_msg,">"))
          CALL log_test(working_job_id,8)
         ELSE
          CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          CALL log_msg(concat("Deleted AGS_CLAIM_DETAIL_DATA : AGS_TASK_ID<",trim(cnvtstring(
              working_task_id)),"> : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          DELETE  FROM ags_claim_detail_data a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_task a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_job a
           WHERE a.ags_job_id=working_job_id
           WITH nounter
          ;end delete
          COMMIT
          SET undo_option = false
          CALL log_msg(concat("END TEST"))
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO msg_menu
#plan_test
 SELECT INTO "nl:"
  FROM ags_plan_data a
  WHERE a.ags_job_id=working_job_id
  DETAIL
   data_row_knt = (data_row_knt+ 1)
  WITH nocounter
 ;end select
 IF (job_row_knt != data_row_knt)
  CALL log_msg(concat("> FAILED: Invalid RECORD_COUNT : Job Record Count<",trim(cnvtstring(
      job_row_knt)),"> : Data Rows<",trim(cnvtstring(data_row_knt)),">"))
  CALL log_test(working_job_id,1)
  GO TO msg_menu
 ELSE
  CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),"> : Record Count<",
    trim(cnvtstring(data_row_knt)),">"))
 ENDIF
 SELECT INTO "nl:"
  FROM ags_task t
  WHERE t.ags_job_id=working_job_id
  DETAIL
   working_task_id = t.ags_task_id
  WITH nocounter
 ;end select
 EXECUTE ags_plan_load working_task_id
 CALL log_msg(concat("Executed AGS_PLAN_LOAD : AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
 IF ((reply->status_data.status != "S"))
  CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
  CALL log_test(working_job_id,8)
 ELSE
  SET data_not_loaded = false
  SELECT INTO "nl:"
   FROM ags_plan_data a
   WHERE a.ags_job_id=working_job_id
    AND a.status != "COMPLETE"
   DETAIL
    data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
   WITH nocounter
  ;end select
  IF (data_not_loaded=true)
   CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
     status,"> : msg<",
     stat_msg,">"))
   CALL log_test(working_job_id,8)
  ELSE
   CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
   IF (do_purge=false)
    CALL log_test(working_job_id,8)
    SET undo_option = false
    CALL log_msg(concat("END TEST"))
   ELSE
    EXECUTE ags_plan_backout value("J"), value(working_job_id)
    CALL log_msg(concat("Executed AGS_PLAN_BACKOUT : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
      ">"))
    IF ((reply->status_data.status != "S"))
     CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
     CALL log_test(working_job_id,8)
    ELSE
     SET data_not_loaded = true
     SELECT INTO "nl:"
      FROM ags_plan_data a
      WHERE a.ags_job_id=working_job_id
       AND a.status != "BACK OUT"
      DETAIL
       data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
      WITH nocounter
     ;end select
     IF (data_not_loaded=false)
      CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
        status,"> : msg<",
        stat_msg,">"))
      CALL log_test(working_job_id,8)
     ELSE
      CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
      UPDATE  FROM ags_task a
       SET a.mode_flag = 1
       WHERE a.ags_task_id=working_task_id
       WITH nocounter
      ;end update
      EXECUTE ags_plan_load working_task_id
      CALL log_msg(concat("Reloaded data AGS_PLAN_LOAD : AGS_TASK_ID<",trim(cnvtstring(
          working_task_id)),">"))
      IF ((reply->status_data.status != "S"))
       CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
       CALL log_test(working_job_id,8)
      ELSE
       SET data_not_loaded = false
       SELECT INTO "nl:"
        FROM ags_plan_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
        DETAIL
         data_not_loaded = true, status = a.status, stat_msg = a.stat_msg
        WITH nocounter
       ;end select
       IF (data_not_loaded=true)
        CALL log_msg(concat("> FAILED: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),"> : status<",
          status,"> : msg<",
          stat_msg,">"))
        CALL log_test(working_job_id,8)
       ELSE
        CALL log_msg(concat("> SUCCESS: AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
        CALL log_msg(concat("Executed AGS_PLAN_PURGE : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),
          ">"))
        EXECUTE ags_plan_purge value("J"), value(working_job_id)
        IF ((reply->status_data.status != "S"))
         CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
         CALL log_test(working_job_id,8)
        ELSE
         SET data_not_loaded = true
         SELECT INTO "nl:"
          FROM ags_plan_data a
          WHERE a.ags_job_id=working_job_id
          DETAIL
           data_not_loaded = false, status = a.status, stat_msg = a.stat_msg
          WITH nocounter
         ;end select
         IF (data_not_loaded=false)
          CALL log_msg(concat("> FAILED: AGS_JOB_ID<",trim(cnvtstring(working_task_id)),"> : status<",
            status,"> : msg<",
            stat_msg,">"))
          CALL log_test(working_job_id,8)
         ELSE
          CALL log_msg(concat("> SUCCESS: AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          CALL log_msg(concat("Purged AGS_PLAN_DATA : AGS_TASK_ID<",trim(cnvtstring(working_task_id)),
            "> : AGS_JOB_ID<",trim(cnvtstring(working_job_id)),">"))
          DELETE  FROM ags_task a
           WHERE a.ags_job_id=working_job_id
           WITH nocounter
          ;end delete
          DELETE  FROM ags_job a
           WHERE a.ags_job_id=working_job_id
           WITH nounter
          ;end delete
          COMMIT
          SET undo_option = false
          CALL log_msg(concat("END TEST"))
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 GO TO msg_menu
#msg_menu
 CALL video(n)
 CALL clear(1,1)
 CALL box(1,1,23,80)
 CALL line(3,1,80,xhor)
 CALL text(2,3,"AGS REGRESSION TEST PROGRAM")
 CALL box(4,3,22,78)
 CALL line(6,3,76,xhor)
 CALL text(5,4," Message Screen")
 IF ((msg_rec->qual_knt < 1))
  CALL text(7,4," Unknown Message")
 ELSE
  SET msg_line_nbr = 7
  SET msg_wknt = 1
  WHILE (msg_line_nbr <= 21
   AND (msg_wknt <= msg_rec->qual_knt))
    CALL text(msg_line_nbr,5,msg_rec->qual[msg_wknt].line)
    SET msg_line_nbr = (msg_line_nbr+ 1)
    SET msg_wknt = (msg_wknt+ 1)
  ENDWHILE
 ENDIF
 SET stat = initrec(msg_rec)
 IF (undo_option=true)
  SET undo_option = false
  CALL text(24,2,"[C]ontinue or [U]ndo:")
  CALL accept(24,25,"A;CU","U"
   WHERE ((curaccept="C") OR (curaccept="U")) )
  IF (curaccept != "C")
   CALL clean_up(0)
  ENDIF
 ELSEIF (exit_now=true)
  SET exit_now = false
  CALL text(24,2,"[C]ontinue or [E]xit:")
  CALL accept(24,25,"A;CU","C"
   WHERE ((curaccept="C") OR (curaccept="E")) )
  IF (curaccept="C")
   GO TO path_prompt
  ELSE
   GO TO finished
  ENDIF
 ELSE
  CALL text(24,2,"[C]ontinue:")
  CALL accept(24,14,"A;CU","C"
   WHERE curaccept="C")
 ENDIF
 GO TO main_menu
 SUBROUTINE valid_job(temp_job_id,temp_file_type)
   DECLARE found_job = i2 WITH protect, noconstant(false)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   IF (temp_job_id < 1)
    CALL log_msg(concat("> FAILED: Validating AGS_JOB_ID (",trim(cnvtstring(working_job_id)),
      ") for FILE_TYPE (",trim(working_file_type),")"))
    RETURN(false)
   ENDIF
   SELECT INTO "nl:"
    FROM ags_job j
    PLAN (j
     WHERE j.ags_job_id=temp_job_id
      AND j.file_type=temp_file_type)
    DETAIL
     found_job = true, job_row_knt = j.record_count
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL log_msg(concat("> FAILED: Validating AGS_JOB_ID (",trim(cnvtstring(working_job_id)),
      ") for FILE_TYPE (",trim(working_file_type),")"))
    RETURN(false)
   ENDIF
   IF (found_job=false)
    CALL log_msg(concat("> FAILED: Validating AGS_JOB_ID (",trim(cnvtstring(working_job_id)),
      ") for FILE_TYPE (",trim(working_file_type),")"))
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE log_msg(temp_msg)
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = temp_msg
   RETURN(true)
 END ;Subroutine
 SUBROUTINE log_test(temp_job_id,temp_test_type)
   SET test_rec->qual_knt = (test_rec->qual_knt+ 1)
   SET stat = alterlist(test_rec->qual,test_rec->qual_knt)
   SET test_rec->qual[test_rec->qual_knt].job_id = temp_job_id
   SET test_rec->qual[test_rec->qual_knt].test_type = temp_test_type
   RETURN(true)
 END ;Subroutine
 SUBROUTINE clean_up(empty)
   CASE (test_rec->qual[test_rec->qual_knt].test_type)
    OF 1:
     EXECUTE ags_org_purge value("J"), value(test_rec->qual[test_rec->qual_knt].job_id)
     DELETE  FROM ags_org_data a
      WHERE (a.ags_job_id=test_rec->qual[test_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 2:
     EXECUTE ags_prsnl_purge value("J"), value(test_rec->qual[test_rec->qual_knt].job_id)
     DELETE  FROM ags_prsnl_data a
      WHERE (a.ags_job_id=test_rec->qual[test_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 3:
     EXECUTE ags_person_purge value("J"), value(test_rec->qual[test_rec->qual_knt].job_id)
     DELETE  FROM ags_person_data a
      WHERE (a.ags_job_id=test_rec->qual[test_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 4:
     EXECUTE ags_claim_purge value("J"), value(test_rec->qual[test_rec->qual_knt].job_id)
     DELETE  FROM ags_claim_data a
      WHERE (a.ags_job_id=test_rec->qual[test_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 5:
     EXECUTE ags_result_purge value("J"), value(test_rec->qual[test_rec->qual_knt].job_id)
     DELETE  FROM ags_result_data a
      WHERE (a.ags_job_id=test_rec->qual[test_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 6:
     EXECUTE ags_meds_purge value("J"), value(test_rec->qual[test_rec->qual_knt].job_id)
     DELETE  FROM ags_meds_data a
      WHERE (a.ags_job_id=test_rec->qual[test_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 7:
     EXECUTE ags_immun_purge value("J"), value(test_rec->qual[test_rec->qual_knt].job_id)
     DELETE  FROM ags_immun_data a
      WHERE (a.ags_job_id=test_rec->qual[test_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 8:
     EXECUTE ags_claim_detail_purge value("J"), value(test_rec->qual[test_rec->qual_knt].job_id)
     DELETE  FROM ags_claim_detail_data a
      WHERE (a.ags_job_id=test_rec->qual[test_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    ELSE
     RETURN(false)
   ENDCASE
   DELETE  FROM ags_task a
    WHERE (a.ags_job_id=test_rec->qual[test_rec->qual_knt].job_id)
     AND a.ags_task_id > 0
    WITH nocounter
   ;end delete
   DELETE  FROM ags_job a
    WHERE (a.ags_job_id=test_rec->qual[test_rec->qual_knt].job_id)
     AND a.ags_job_id > 0
    WITH nounter
   ;end delete
   COMMIT
   SET test_rec->qual_knt = (test_rec->qual_knt - 1)
   SET stat = alterlist(test_rec->qual,test_rec->qual_knt)
   RETURN(true)
 END ;Subroutine
#exit_script
 IF ((test_rec->qual_knt > 0))
  CALL video(n)
  CALL clear(1,1)
  CALL box(1,1,23,80)
  CALL line(3,1,80,xhor)
  CALL text(2,3,"AGS REGRESSION TEST PROGRAM")
  CALL box(4,3,22,78)
  CALL line(6,3,76,xhor)
  CALL text(5,4," Exit Script")
  CALL text(7,4," 1. Purge remaining test data")
  CALL text(9,4," 2. Leave remaining test data")
  CALL text(21,4,"0 - Main Menu")
  CALL text(24,2,"Select an item number:  ")
  CALL accept(24,25,"9;",1
   WHERE curaccept > 0
    AND curaccept <= 9)
  CASE (curaccept)
   OF 1:
    WHILE ((test_rec->qual_knt > 0))
      CALL clean_up(0)
    ENDWHILE
   OF 2:
    GO TO finished
   OF 0:
    GO TO main_menu
   ELSE
    GO TO exit_script
  ENDCASE
 ENDIF
#finished
 CALL clear(1,1)
 SET script_ver = "002 11/22/06"
 CALL video(l)
END GO
