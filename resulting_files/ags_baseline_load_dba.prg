CREATE PROGRAM ags_baseline_load:dba
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
 FREE RECORD msg_rec
 RECORD msg_rec(
   1 qual_knt = i4
   1 qual[*]
     2 line = vc
 )
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
 FREE RECORD request
 RECORD request(
   1 batch_selection = vc
   1 debug_logging = i4
   1 ags_task_id = f8
   1 require_ssn = i4
   1 consent_cdf = vc
   1 check_for_dups = i2
 )
 FREE RECORD load_rec
 RECORD load_rec(
   1 qual_knt = i4
   1 qual[*]
     2 job_id = f8
     2 load_type = i4
 )
 FREE RECORD file_rec
 RECORD file_rec(
   1 qual_knt = i4
   1 qual[*]
     2 file_type = c40
     2 file = vc
 )
 SET file_rec->qual_knt = 10
 SET stat = alterlist(file_rec->qual,file_rec->qual_knt)
 SET file_rec->qual[1].file_type = "PRSNL_ORG"
 SET file_rec->qual[1].file = "ags_baseline_provider"
 SET file_rec->qual[2].file_type = "PRSNL_ORG"
 SET file_rec->qual[2].file = "ags_baseline_provider"
 SET file_rec->qual[3].file_type = "PERSON"
 SET file_rec->qual[3].file = "ags_baseline_person"
 SET file_rec->qual[4].file_type = "CLAIM"
 SET file_rec->qual[4].file = "ags_baseline_claim"
 SET file_rec->qual[5].file_type = "RESULT"
 SET file_rec->qual[5].file = "ags_baseline_result"
 SET file_rec->qual[6].file_type = "MEDS"
 SET file_rec->qual[6].file = "ags_baseline_meds"
 SET file_rec->qual[7].file_type = "IMMUN"
 SET file_rec->qual[7].file = "ags_baseline_immun"
 SET file_rec->qual[8].file_type = "CLAIMDETAIL"
 SET file_rec->qual[8].file = "ags_baseline_claim_detail"
 SET file_rec->qual[9].file_type = "PLAN"
 SET file_rec->qual[9].file = "ags_baseline_plan"
 SET file_rec->qual[10].file_type = "ALL"
 SET file_rec->qual[10].file = "ags_baseline"
 DECLARE exit_now = i2 WITH protect, noconstant(false)
 DECLARE undo_option = i2 WITH protect, noconstant(true)
 DECLARE job_row_knt = i4 WITH protect, noconstant(0)
 DECLARE data_row_knt = i4 WITH protect, noconstant(0)
 DECLARE working_job_id = f8 WITH public, noconstant(0.0)
 DECLARE working_task_id = f8 WITH public, noconstant(0.0)
 DECLARE working_file_type = vc WITH public, noconstant("")
 DECLARE working_file = c40 WITH public, noconstant("")
 DECLARE working_domain = vc WITH public, noconstant("")
 DECLARE working_path = vc WITH public, noconstant("")
 DECLARE data_not_loaded = i2 WITH public, noconstant(false)
 DECLARE do_purge = i2 WITH public, noconstant(true)
 DECLARE load_type = i4 WITH public, noconstant(0)
 DECLARE load_knt = i4 WITH public, noconstant(0)
 DECLARE status = vc WITH public, noconstant("")
 DECLARE stat_msg = vc WITH public, noconstant("")
 DECLARE msg_line_nbr = i2 WITH public, noconstant(0)
 DECLARE msg_wknt = i2 WITH public, noconstant(0)
 DECLARE start_idx = i2 WITH public, noconstant(1)
 DECLARE stop_idx = i2 WITH public, noconstant(1)
 DECLARE s_the_msg = vc WITH public, noconstant("")
 DECLARE d_job_id = f8 WITH public, noconstant(0.0)
 DECLARE i_load_type = i4 WITH public, noconstant(0)
 DECLARE s_file_type = vc WITH public, noconstant("")
 DECLARE log_msg(s_the_msg=vc) = i2
 DECLARE log_load(d_job_id=f8,i_load_type=i4) = i2
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
 SET working_path = concat("/cerner/d_",cnvtlower(working_domain),"/data/cern_test/baseline/")
 SET accept = video(n)
 CALL video(n)
 CALL clear(1,1)
 CALL box(1,1,23,80)
 CALL line(3,1,80,xhor)
 CALL text(2,3,"AGS BASELINE LOAD PROGRAM")
 CALL box(4,3,22,78)
 CALL line(6,3,76,xhor)
 CALL text(5,4," Data Directory")
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
 SET data_not_loaded = true
 SET job_row_knt = 0
 SET undo_option = false
 SET working_job_id = 0.0
 CALL video(n)
 CALL clear(1,1)
 CALL box(1,1,23,80)
 CALL line(3,1,80,xhor)
 CALL text(2,3,"AGS BASELINE LOAD PROGRAM")
 CALL box(4,3,22,78)
 CALL line(6,3,76,xhor)
 CALL text(5,4," Load Menu")
 CALL text(7,4," 1. Org")
 CALL text(9,4," 2. Prsnl")
 CALL text(11,4," 3. Person")
 CALL text(13,4," 4. Claim")
 CALL text(15,4," 5. Result")
 CALL text(7,36," 6. Meds")
 CALL text(9,36," 7. Immun")
 CALL text(11,36," 8. Claim Detail")
 CALL text(13,36," 9. Plan")
 CALL text(15,36,"10. ALL")
 CALL text(21,4," 0 - Exit")
 CALL text(24,2,"Select an item number:  ")
 CALL accept(24,25,"9(2);H",11
  WHERE curaccept >= 0
   AND curaccept <= 11)
 SET load_type = curaccept
 IF (load_type=0)
  GO TO exit_script
 ELSEIF (load_type > 0
  AND load_type <= 10)
  SET working_file_type = file_rec->qual[load_type].file_type
  SET working_file = file_rec->qual[load_type].file
  IF (load_type=10)
   SET start_idx = 1
   SET stop_idx = 9
   SET undo_option = false
  ELSE
   SET start_idx = load_type
   SET stop_idx = load_type
   SET undo_option = true
  ENDIF
 ELSE
  GO TO main_menu
 ENDIF
 CALL log_msg("BEGIN LOAD")
 CALL log_msg(concat("> Path: ",working_path))
 CALL log_msg(concat("> File: ",working_file))
 FOR (load_idx = start_idx TO stop_idx)
   SET working_job_id = 0.0
   SET working_task_id = 0.0
   SET working_file_type = file_rec->qual[load_idx].file_type
   SET working_file = file_rec->qual[load_idx].file
   SET stat = initrec(reply)
   SET stat = initrec(request)
   SET all_data_successful = true
   CALL ags_set_status_block(ecustom,esuccessful,"Reply Reset","Script defaults to Success")
   SELECT INTO "nl:"
    FROM ags_job j
    WHERE j.filename=concat(working_file,".csv")
     AND j.status != "PURGED"
    DETAIL
     data_not_loaded = false, working_job_id = j.ags_job_id
    WITH nocounter
   ;end select
   IF (working_job_id < 1)
    IF ( NOT (findfile(value(concat(working_path,trim(working_file),".par")))))
     CALL log_msg(concat("> FAILED: ",trim(working_file_type)," - ",trim(working_file),
       ".par not found"))
    ELSEIF ( NOT (findfile(value(concat(working_path,trim(working_file),".ctl")))))
     CALL log_msg(concat("> FAILED: ",trim(working_file_type)," - ",trim(working_file),
       ".ctl not found"))
    ELSEIF ( NOT (findfile(value(concat(working_path,trim(working_file),".csv")))))
     CALL log_msg(concat("> FAILED: ",trim(working_file_type)," - ",trim(working_file),
       ".csv not found"))
    ELSE
     SET request->batch_selection = concat("<par_file|",working_path,trim(working_file),".par>")
     EXECUTE ags_import_data_files
     SET working_job_id = reply->ags_job_id
     IF (get_script_status(0)=efailure)
      CALL log_msg(concat("> FAILED: ",trim(working_file_type)," IMPORT: status<",trim(reply->
         status_data.status),"> : AGS_JOB_ID<",
        trim(cnvtstring(working_job_id)),">"))
      SET working_job_id = 0
     ENDIF
    ENDIF
   ENDIF
   IF (valid_job(working_job_id,working_file_type))
    SELECT INTO "nl:"
     FROM ags_task t
     WHERE t.ags_job_id=working_job_id
     DETAIL
      request->consent_cdf = "YES", request->require_ssn = 0, request->ags_task_id = t.ags_task_id,
      request->debug_logging = edebuglevel, working_task_id = t.ags_task_id
     WITH nocounter
    ;end select
    IF (working_task_id > 0)
     SET undo_option = false
     CASE (load_idx)
      OF 1:
       EXECUTE ags_org_load working_task_id
       SELECT INTO "nl:"
        FROM ags_org_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
         AND a.stat_msg=""
        DETAIL
         all_data_successful = false
        WITH nocounter
       ;end select
      OF 2:
       EXECUTE ags_prsnl_load working_task_id
       SELECT INTO "nl:"
        FROM ags_prsnl_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
         AND a.stat_msg=""
        DETAIL
         all_data_successful = false
        WITH nocounter
       ;end select
      OF 3:
       EXECUTE ags_person_load
       SELECT INTO "nl:"
        FROM ags_person_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
         AND a.stat_msg=""
        DETAIL
         all_data_successful = false
        WITH nocounter
       ;end select
      OF 4:
       EXECUTE ags_claim_load
       SELECT INTO "nl:"
        FROM ags_claim_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
         AND a.stat_msg=""
        DETAIL
         all_data_successful = false
        WITH nocounter
       ;end select
      OF 5:
       EXECUTE ags_result_load working_task_id
       SELECT INTO "nl:"
        FROM ags_result_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
         AND a.stat_msg=""
        DETAIL
         all_data_successful = false
        WITH nocounter
       ;end select
      OF 6:
       EXECUTE ags_meds_load working_task_id
       SELECT INTO "nl:"
        FROM ags_meds_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
         AND a.stat_msg=""
        DETAIL
         all_data_successful = false
        WITH nocounter
       ;end select
      OF 7:
       EXECUTE ags_immun_load working_task_id
       SELECT INTO "nl:"
        FROM ags_immun_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
         AND a.stat_msg=""
        DETAIL
         all_data_successful = false
        WITH nocounter
       ;end select
      OF 8:
       EXECUTE ags_claimdet_load working_task_id
       SELECT INTO "nl:"
        FROM ags_claim_detail_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
         AND a.stat_msg=""
        DETAIL
         all_data_successful = false
        WITH nocounter
       ;end select
      OF 9:
       EXECUTE ags_plan_load working_task_id
       SELECT INTO "nl:"
        FROM ags_plan_data a
        WHERE a.ags_job_id=working_job_id
         AND a.status != "COMPLETE"
         AND a.stat_msg=""
        DETAIL
         all_data_successful = false
        WITH nocounter
       ;end select
      ELSE
       CALL log_msg(concat("Illegal load_idx ",cnvtstring(load_idx)))
     ENDCASE
     IF (get_script_status(0) != efailure)
      IF (all_data_successful=true)
       CALL log_msg(concat("> SUCCESS: ",trim(working_file_type)," - AGS_JOB_ID<",trim(cnvtstring(
           working_job_id)),">"))
      ELSE
       CALL log_msg(concat("> ERROR: ",trim(working_file_type)," - AGS_JOB_ID<",trim(cnvtstring(
           working_job_id)),"> ",
         "One or more rows did not load, check stat_msg in data table"))
      ENDIF
     ENDIF
    ELSE
     CALL log_msg(concat("> FAILED: ",trim(working_file_type)," - AGS_JOB_ID<",trim(cnvtstring(
         working_job_id)),"> ",
       " - AGS_TASK_ID<",trim(cnvtstring(working_task_id)),">"))
    ENDIF
   ENDIF
 ENDFOR
 CALL log_msg(concat("END LOAD"))
 SET stat = initrec(reply)
 CALL ags_set_status_block(ecustom,esuccessful,"Reply Reset","Script defaults to Success")
 GO TO msg_menu
#msg_menu
 CALL video(n)
 CALL clear(1,1)
 CALL box(1,1,23,80)
 CALL line(3,1,80,xhor)
 CALL text(2,3,"AGS BASELINE LOAD PROGRAM")
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
      ") for FILE_TYPE (",trim(temp_file_type),")"))
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
    CALL log_msg(concat("> FAILED: Selecting AGS_JOB_ID (",trim(cnvtstring(working_job_id)),
      ") for FILE_TYPE (",trim(temp_file_type),")"))
    RETURN(false)
   ENDIF
   IF (found_job=false)
    CALL log_msg(concat("> FAILED: Finding AGS_JOB_ID (",trim(cnvtstring(working_job_id)),
      ") for FILE_TYPE (",trim(temp_file_type),")"))
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
 SUBROUTINE log_load(temp_job_id,temp_load_type)
   SET load_rec->qual_knt = (load_rec->qual_knt+ 1)
   SET stat = alterlist(load_rec->qual,load_rec->qual_knt)
   SET load_rec->qual[load_rec->qual_knt].job_id = temp_job_id
   SET load_rec->qual[load_rec->qual_knt].load_type = temp_load_type
   RETURN(true)
 END ;Subroutine
 SUBROUTINE clean_up(empty)
   CASE (load_rec->qual[load_rec->qual_knt].load_type)
    OF 1:
     EXECUTE ags_org_purge value("J"), value(load_rec->qual[load_rec->qual_knt].job_id)
     DELETE  FROM ags_org_data a
      WHERE (a.ags_job_id=load_rec->qual[load_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 2:
     EXECUTE ags_prsnl_purge value("J"), value(load_rec->qual[load_rec->qual_knt].job_id)
     DELETE  FROM ags_prsnl_data a
      WHERE (a.ags_job_id=load_rec->qual[load_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 3:
     EXECUTE ags_person_purge value("J"), value(load_rec->qual[load_rec->qual_knt].job_id)
     DELETE  FROM ags_person_data a
      WHERE (a.ags_job_id=load_rec->qual[load_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 4:
     EXECUTE ags_claim_purge value("J"), value(load_rec->qual[load_rec->qual_knt].job_id)
     DELETE  FROM ags_claim_data a
      WHERE (a.ags_job_id=load_rec->qual[load_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 5:
     EXECUTE ags_result_purge value("J"), value(load_rec->qual[load_rec->qual_knt].job_id)
     DELETE  FROM ags_result_data a
      WHERE (a.ags_job_id=load_rec->qual[load_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 6:
     EXECUTE ags_meds_purge value("J"), value(load_rec->qual[load_rec->qual_knt].job_id)
     DELETE  FROM ags_meds_data a
      WHERE (a.ags_job_id=load_rec->qual[load_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 7:
     EXECUTE ags_immun_purge value("J"), value(load_rec->qual[load_rec->qual_knt].job_id)
     DELETE  FROM ags_immun_data a
      WHERE (a.ags_job_id=load_rec->qual[load_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 8:
     EXECUTE ags_claim_detail_purge value("J"), value(load_rec->qual[load_rec->qual_knt].job_id)
     DELETE  FROM ags_claim_detail_data a
      WHERE (a.ags_job_id=load_rec->qual[load_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    OF 9:
     EXECUTE ags_plan_purge value("J"), value(load_rec->qual[load_rec->qual_knt].job_id)
     DELETE  FROM ags_plan_data a
      WHERE (a.ags_job_id=load_rec->qual[load_rec->qual_knt].job_id)
      WITH nocounter
     ;end delete
    ELSE
     RETURN(false)
   ENDCASE
   DELETE  FROM ags_task a
    WHERE (a.ags_job_id=load_rec->qual[load_rec->qual_knt].job_id)
     AND a.ags_task_id > 0
    WITH nocounter
   ;end delete
   DELETE  FROM ags_job a
    WHERE (a.ags_job_id=load_rec->qual[load_rec->qual_knt].job_id)
     AND a.ags_job_id > 0
    WITH nounter
   ;end delete
   COMMIT
   SET load_rec->qual_knt = (load_rec->qual_knt - 1)
   SET stat = alterlist(load_rec->qual,load_rec->qual_knt)
   RETURN(true)
 END ;Subroutine
#exit_script
 IF ((load_rec->qual_knt > 0))
  CALL video(n)
  CALL clear(1,1)
  CALL box(1,1,23,80)
  CALL line(3,1,80,xhor)
  CALL text(2,3,"AGS BASELINE LOAD PROGRAM")
  CALL box(4,3,22,78)
  CALL line(6,3,76,xhor)
  CALL text(5,4," Exit Script")
  CALL text(7,4," 1. Purge load data in error")
  CALL text(9,4," 2. Leave load data in error")
  CALL text(21,4,"0 - Main Menu")
  CALL text(24,2,"Select an item number:  ")
  CALL accept(24,25,"9;",1
   WHERE curaccept >= 0
    AND curaccept <= 2)
  CASE (curaccept)
   OF 1:
    WHILE ((load_rec->qual_knt > 0))
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
 SET script_ver = "000 12/08/06"
 CALL ags_log_status(0)
 CALL video(l)
 SET message = information
 SET trace = callecho
END GO
