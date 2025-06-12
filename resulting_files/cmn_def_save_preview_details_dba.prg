CREATE PROGRAM cmn_def_save_preview_details:dba
 PROMPT
  "OUTDEV : " = "MINE",
  "DEFINITION DETAILS" = ""
  WITH outdev, definition_details_json
 DECLARE PUBLIC::errorcheck(replystructure=vc(ref),operation=vc) = null
 SUBROUTINE PUBLIC::errorcheck(replystructure,operation)
   DECLARE errormsg = c255 WITH protect, noconstant("")
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    WHILE (errorcode != 0)
      SET replystructure->status_data.subeventstatus[1].operationname = operation
      SET replystructure->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode,10)
      SET replystructure->status_data.subeventstatus[1].targetobjectvalue = errormsg
      SET replystructure->status_data.status = "F"
      IF ((reqdata->loglevel >= 4))
       CALL echo(errormsg)
      ENDIF
      SET errorcode = error(errormsg,0)
    ENDWHILE
    GO TO exit_script
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(pex_error_and_exit_subroutines_inc)))
  EXECUTE pex_error_and_exit_subroutines
  DECLARE pex_error_and_exit_subroutines_inc = i2 WITH protect
 ENDIF
 RECORD save_preview_reply(
   1 mp_mpage_def_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE PUBLIC::main_cdspd(null) = null WITH private
 DECLARE PUBLIC::insert_preview_details(driver_script_name=vc,parameter_txt=vc) = f8 WITH protect
 CALL main_cdspd(null)
 SUBROUTINE PUBLIC::main_cdspd(null)
   DECLARE stat = i4 WITH protect, noconstant(0)
   DECLARE parameter_txt = vc WITH protect, constant(validate(save_preview_request->parameter_txt,"")
    )
   IF (validate(request->blob_in))
    DECLARE blobin = vc WITH protect, constant(request->blob_in)
    SET stat = cnvtjsontorec(blobin)
    IF (stat=0)
     CALL exit_with_status("F",curprog,"F","Main_CDSPD",build2(
       "Failed to convert blob_in input json data",request->blob_in),
      save_preview_reply)
    ENDIF
   ELSE
    SET stat = cnvtjsontorec( $DEFINITION_DETAILS_JSON)
    IF (stat=0)
     CALL exit_with_status("F",curprog,"F","Main_CDSPD",build2("Failed to convert input json data",
        $DEFINITION_DETAILS_JSON),
      save_preview_reply)
    ENDIF
   ENDIF
   IF ( NOT (validate(save_preview_request)))
    CALL exit_with_status("F",curprog,"F","Main_CDSPD","No request structure defined.",
     save_preview_reply)
   ENDIF
   SET save_preview_reply->mp_mpage_def_id = insert_preview_details(save_preview_request->
    driver_script_name,validate(save_preview_request->parameter_txt,""))
   SET save_preview_reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
 END ;Subroutine
 SUBROUTINE PUBLIC::insert_preview_details(driver_script_name,parameter_txt)
   DECLARE mp_mpage_def_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    nextseqnum = seq(mpages_seq,nextval)
    FROM dual
    DETAIL
     mp_mpage_def_id = nextseqnum
    WITH format, nocounter
   ;end select
   CALL errorcheck(save_preview_reply,"Get_Seq_Insert_Preview_Details")
   INSERT  FROM mp_mpage_def md
    SET md.mp_mpage_def_id = mp_mpage_def_id, md.mpage_meaning = cnvtstring(mp_mpage_def_id,22), md
     .driver_script_name = driver_script_name,
     md.parameter_txt = parameter_txt, md.def_type_flag = 2, md.updt_cnt = 0,
     md.updt_applctx = reqinfo->updt_applctx, md.updt_task = reqinfo->updt_task, md.updt_id = reqinfo
     ->updt_id,
     md.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   ;end insert
   CALL errorcheck(save_preview_reply,"Insert_Preview_Details")
   RETURN(mp_mpage_def_id)
 END ;Subroutine
#exit_script
 IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
  CALL echorecord(save_preview_reply)
 ENDIF
 SET _memory_reply_string = cnvtrectojson(save_preview_reply)
END GO
