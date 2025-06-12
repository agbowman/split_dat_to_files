CREATE PROGRAM cmn_mpns_swap_list:dba
 PROMPT
  "config swap info:   " = ""
  WITH configswapinfojson
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 IF ( NOT (validate(pex_error_and_exit_subroutines_inc)))
  EXECUTE pex_error_and_exit_subroutines
  DECLARE pex_error_and_exit_subroutines_inc = i2 WITH protect
 ENDIF
 IF ( NOT (validate(swap_operation_reply)))
  RECORD swap_operation_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE PUBLIC::main(null) = null WITH private
 DECLARE PUBLIC::process_viewpoint_list(null) = null WITH protect
 DECLARE PUBLIC::process_mpages_list(null) = null WITH protect
 DECLARE PUBLIC::execute_cmn_mpns_perform_swap(requested_name=vc,replacement_name=vc) = null WITH
 protect
 CALL main(null)
 SUBROUTINE PUBLIC::main(null)
   SET reply->status_data.status = "F"
   SET stat = cnvtjsontorec( $CONFIGSWAPINFOJSON)
   CALL process_viewpoint_list(null)
   CALL process_mpages_list(null)
   SET reqinfo->commit_ind = 1
   CALL exit_with_status("S",curprog,"S","","",
    reply)
 END ;Subroutine
 SUBROUTINE PUBLIC::process_viewpoint_list(null)
   DECLARE requested_name = vc WITH protect, noconstant("")
   DECLARE replacement_name = vc WITH protect, noconstant("")
   DECLARE requested_meaning = vc WITH protect, noconstant("")
   DECLARE replacement_meaning = vc WITH protect, noconstant("")
   DECLARE failure_message = vc WITH protect, noconstant("")
   DECLARE viewpoint_cnt = i4 WITH protect, noconstant(0)
   DECLARE mpage_cnt = i4 WITH protect, noconstant(0)
   FOR (viewpoint_cnt = 1 TO size(configswapdata->viewpoints,5))
     SET requested_name = configswapdata->viewpoints[viewpoint_cnt].requested_name
     SET replacement_name = configswapdata->viewpoints[viewpoint_cnt].replacement_name
     CALL execute_cmn_mpns_perform_swap(requested_name,replacement_name)
     IF ((swap_operation_reply->status_data.status="S"))
      FOR (mpage_cnt = 1 TO size(configswapdata->viewpoints[viewpoint_cnt].mpages,5))
        SET requested_name = configswapdata->viewpoints[viewpoint_cnt].mpages[mpage_cnt].
        requested_name
        SET replacement_name = configswapdata->viewpoints[viewpoint_cnt].mpages[mpage_cnt].
        replacement_name
        SET requested_meaning = configswapdata->viewpoints[viewpoint_cnt].mpages[mpage_cnt].
        requested_meaning
        SET replacement_meaning = configswapdata->viewpoints[viewpoint_cnt].mpages[mpage_cnt].
        replacement_meaning
        CALL execute_cmn_mpns_perform_swap(requested_meaning,replacement_meaning)
        IF ((swap_operation_reply->status_data.status="F"))
         SET failure_message = build2("Error occurred while swapping mpage names ",requested_name,
          " and ",replacement_name,": ",
          swap_operation_reply->status_data.subeventstatus.targetobjectvalue)
         CALL exit_with_status("F",curprog,"F","Process_Name_Swap_List",failure_message,
          reply)
        ENDIF
      ENDFOR
     ELSE
      SET failure_message = build2("Error occurred while swapping view point names ",requested_name,
       " and ",replacement_name)
      CALL exit_with_status("F",curprog,"F","Process_Name_Swap_List",failure_message,
       reply)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE PUBLIC::process_mpages_list(null)
   DECLARE requested_name = vc WITH protect, noconstant("")
   DECLARE replacement_name = vc WITH protect, noconstant("")
   DECLARE requested_meaning = vc WITH protect, noconstant("")
   DECLARE replacement_meaning = vc WITH protect, noconstant("")
   DECLARE failure_message = vc WITH protect, noconstant("")
   DECLARE mpage_cnt = i4 WITH protect, noconstant(0)
   FOR (mpage_cnt = 1 TO size(configswapdata->mpages,5))
     SET requested_name = configswapdata->mpages[mpage_cnt].requested_name
     SET replacement_name = configswapdata->mpages[mpage_cnt].replacement_name
     SET requested_meaning = configswapdata->mpages[mpage_cnt].requested_meaning
     SET replacement_meaning = configswapdata->mpages[mpage_cnt].replacement_meaning
     CALL execute_cmn_mpns_perform_swap(requested_meaning,replacement_meaning)
     IF ((swap_operation_reply->status_data.status="F"))
      SET failure_message = build2("Error occurred while swapping mpage names ",requested_name,
       " and ",replacement_name,": ",
       swap_operation_reply->status_data.subeventstatus.targetobjectvalue)
      CALL exit_with_status("F",curprog,"F","Process_Mpages_List",failure_message,
       reply)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE PUBLIC::execute_cmn_mpns_perform_swap(requested_name,replacement_name)
   EXECUTE cmn_mpns_perform_swap value(requested_name), value(replacement_name)
 END ;Subroutine
#exit_script
 IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
  CALL echo( $CONFIGSWAPINFOJSON)
  CALL echorecord(reply)
 ENDIF
END GO
