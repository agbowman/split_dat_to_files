CREATE PROGRAM ags_exe_claim_load:dba
 IF (validate(reply,"!")="!")
  FREE RECORD reply
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript
 ENDIF
 CALL echo("***")
 CALL echo("***   BEG AGS_EXE_CLAIM_LOAD")
 CALL echo("***")
 EXECUTE ccluarxrtl
 EXECUTE cclseclogin2
 IF (validate(ags_get_code_defined,0)=0)
  EXECUTE ags_get_code
 ENDIF
 IF (validate(ags_log_header_defined,0)=0)
  EXECUTE ags_log_header
 ENDIF
 IF (get_script_status(0) != esuccessful)
  GO TO exit_script
 ENDIF
 FREE RECORD email
 RECORD email(
   1 qual_knt = i4
   1 qual[*]
     2 address = vc
     2 send_flag = i2
 )
 DECLARE eknt = i4 WITH public, noconstant(0)
 DECLARE bs_length = i4 WITH public, noconstant(0)
 DECLARE par_file_name = vc WITH public, noconstant("")
 DECLARE working_batch_selection = vc WITH public, noconstant("")
 DECLARE ipos = i4 WITH protect, noconstant(1)
 DECLARE npos = i4 WITH protect, noconstant(0)
 DECLARE spos = i4 WITH protect, noconstant(0)
 DECLARE field_name = vc WITH protect, noconstant("")
 DECLARE field_data = vc WITH protect, noconstant("")
 DECLARE testing_flag = i2 WITH public, noconstant(0)
 CALL echo("***")
 CALL echo("***   BEG Parse Batch Selection")
 CALL echo("***")
 CALL echo(concat("***   batch_selection :",trim(request->batch_selection)))
 CALL echo("***")
 SET bs_length = textlen(trim(request->batch_selection))
 IF (bs_length < 3)
  CALL ags_set_status_block(eattribute,ezero,"BATCH_SELECTION",concat(
    "Invalid Length of less then 3 : ",trim(request->batch_selection)))
  GO TO skip_parse
 ENDIF
 IF (cnvtupper(substring(1,10,request->batch_selection))="<PAR_FILE|")
  SET par_file_name = cnvtlower(trim(substring(11,(bs_length - 11),request->batch_selection)))
  CALL echo("***")
  CALL echo(concat("***   par_file_name :",par_file_name))
  CALL echo("***")
  IF (findfile(value(par_file_name)))
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(nullterm(par_file_name))
   DEFINE rtl2 "file_loc"
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    the_line = r.line
    FROM rtl2t r
    HEAD REPORT
     working_batch_selection = trim(the_line)
    WITH nocounter
   ;end select
   FREE DEFINE rtl2
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    CALL ags_set_status_block(eselect,efailure,"READ PARAMETER FILE",trim(serrmsg))
    GO TO exit_script
   ENDIF
  ELSE
   CALL ags_set_status_block(eattribute,efailure,"FIND PARAMETER FILE",concat(
     "Failed to find file : ",trim(par_file_name)))
   GO TO exit_script
  ENDIF
 ELSE
  SET working_batch_selection = trim(request->batch_selection)
 ENDIF
 CALL echo("***")
 CALL echo(concat("***   working_batch_selection :",trim(working_batch_selection)))
 CALL echo("***")
 SET bs_length = textlen(trim(working_batch_selection))
 IF (bs_length <= 5)
  CALL ags_set_status_block(eattribute,efailure,"WORKING_BATCH_SELECTION",trim(
    working_batch_selection))
  GO TO exit_script
 ENDIF
 WHILE (ipos < bs_length)
   SET ipos = findstring("<",working_batch_selection,ipos)
   IF (ipos < 1)
    CALL ags_set_status_block(eattribute,efailure,"WORKING_BATCH_SELECTION",concat(
      "'<' not present : ",trim(working_batch_selection)))
    GO TO exit_script
   ENDIF
   SET npos = findstring(">",working_batch_selection,(ipos+ 1))
   IF (npos < 1)
    CALL ags_set_status_block(eattribute,efailure,"WORKING_BATCH_SELECTION",concat(
      "'>' not present : ",trim(working_batch_selection)))
    GO TO exit_script
   ENDIF
   SET spos = findstring("|",working_batch_selection,(ipos+ 1))
   IF (spos < 1)
    CALL ags_set_status_block(eattribute,efailure,"WORKING_BATCH_SELECTION",concat(
      "'|' not present : ",trim(working_batch_selection)))
    GO TO exit_script
   ENDIF
   SET field_name = trim(cnvtupper(substring((ipos+ 1),((spos - ipos) - 1),working_batch_selection)))
   SET field_data = trim(substring((spos+ 1),((npos - spos) - 1),working_batch_selection))
   CALL echo("***")
   CALL echo(concat("***   FIELD_NAME :",field_name))
   CALL echo(concat("***   FIELD_DATA :",field_data))
   CALL echo("***")
   IF ((( NOT (field_data > " ")) OR ( NOT (field_name > " "))) )
    CALL ags_set_status_block(eattribute,efailure,"WORKING_BATCH_SELECTION",concat(
      "Invalid FIELD_DATA : ",field_data))
    GO TO exit_script
   ENDIF
   IF ( NOT (field_name > " "))
    CALL ags_set_status_block(eattribute,efailure,"WORKING_BATCH_SELECTION",concat(
      "Invalid FIELD_NAME : ",field_name))
    GO TO exit_script
   ENDIF
   CASE (field_name)
    OF "EMAIL":
     SET sstatus_email = field_data
     SET eknt = (eknt+ 1)
     SET stat = alterlist(email->qual,eknt)
     SET email->qual_knt = eknt
     SET email->qual[eknt].address = field_data
    OF "SEND_FLAG":
     IF (eknt > 0)
      SET email->qual[eknt].send_flag = cnvtint(field_data)
     ENDIF
    OF "TEST_FLAG":
     SET testing_flag = cnvtint(field_data)
    ELSE
     CALL ags_set_status_block(eattribute,efailure,"WORKING_BATCH_SELECTION",concat(
       "Unknown FIELD_NAME : ",field_name))
     GO TO exit_script
   ENDCASE
   SET ipos = (npos+ 1)
 ENDWHILE
 CALL ags_set_status_block(eattribute,esuccessful,"TESTING_FLAG",concat("TESTING_FLAG :: ",trim(
    cnvtstring(testing_flag))))
 FOR (eidx = 1 TO email->qual_knt)
   CALL ags_set_status_block(eattribute,esuccessful,"CONSENT_CDF",concat("EMAIL :: ",trim(email->
      qual[eidx].address)," SEND_FLAG :: ",trim(cnvtstring(email->qual[eidx].send_flag))))
 ENDFOR
#skip_parse
 CALL echo("***")
 CALL echo("***   END Parse Batch Selection")
 CALL echo("***")
 CALL echo("***")
 CALL echo("***   BEG Load CLAIM Data")
 CALL echo("***")
 FREE RECORD work
 RECORD work(
   1 qual_knt = i4
   1 qual[*]
     2 ags_job_id = f8
     2 ags_task_id = f8
     2 sending_system = vc
     2 timers_flag = i2
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM ags_task t,
   ags_job j
  PLAN (t
   WHERE t.task_type="CLAIM"
    AND t.status="WAITING")
   JOIN (j
   WHERE j.ags_job_id=t.ags_job_id)
  ORDER BY j.sending_system, t.ags_task_id
  HEAD REPORT
   knt = 0, stat = alterlist(work->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(work->qual,(knt+ 9))
   ENDIF
   work->qual[knt].ags_job_id = t.ags_job_id, work->qual[knt].ags_task_id = t.ags_task_id, work->
   qual[knt].sending_system = j.sending_system,
   work->qual[knt].timers_flag = t.timers_flag
  FOOT REPORT
   work->qual_knt = knt, stat = alterlist(work->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL ags_set_status_block(eselect,efailure,"GET CLAIM DATA",trim(serrmsg))
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echorecord(work)
 CALL echo("***")
 IF ((work->qual_knt < 1))
  GO TO skip_claim_load
 ENDIF
 FREE RECORD rclaimload
 RECORD rclaimload(
   1 debug_logging = i4
   1 ags_task_id = f8
 )
 FOR (exe_idx = 1 TO work->qual_knt)
   SET rclaimload->ags_task_id = work->qual[exe_idx].ags_task_id
   SET rclaimload->debug_logging = work->qual[exe_idx].timers_flag
   EXECUTE ags_claim_load  WITH replace("REQUEST","RCLAIMLOAD")
   IF (get_script_status(0)=efailure)
    CALL ags_set_status_block(ecustom,efailure,"AGS_CLAIM_LOAD",concat("Load for ags_task_id ",
      cnvtstring(rclaimload->ags_task_id)," FAILED"))
    GO TO exit_script
   ENDIF
 ENDFOR
#skip_claim_load
 CALL echo("***")
 CALL echo("***   END Load CLAIM Data")
 CALL echo("***")
#exit_script
 CALL ags_log_trailer(0)
 CALL echo("***")
 CALL echo("***   END AGS_EXE_CLAIM_LOAD")
 CALL echo("***")
 SET script_ver = "002 11/22/06"
END GO
