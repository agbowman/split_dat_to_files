CREATE PROGRAM cmn_def_preview_mpages:dba
 PROMPT
  "OUTDEV : " = "MINE",
  "MP MPAGE DEF ID" = 0.0
  WITH outdev, mp_mpage_def_id
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
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE PUBLIC::main_cdpm(null) = null WITH private
 DECLARE PUBLIC::get_mpage_definition(_mp_mpage_def_id=f8,report_name=vc(ref),report_param=vc(ref))
  = null WITH protect
 DECLARE report_name = vc WITH protect, noconstant("")
 DECLARE report_param = vc WITH protect, noconstant("")
 DECLARE usr_person_id = f8 WITH protect, constant(reqinfo->updt_id)
 DECLARE usr_position_cd = f8 WITH protect, constant(reqinfo->position_cd)
 CALL main_cdpm(null)
 SUBROUTINE PUBLIC::main_cdpm(null)
   CALL get_mpage_definition( $MP_MPAGE_DEF_ID,report_name,report_param)
   SET trace = recpersist
   EXECUTE mp_driver_substitute report_name, report_param, usr_person_id,
   0.0, 0.0, usr_person_id,
   usr_position_cd, "", "",
   "powerchart.exe"
   SET trace = norecpersist
 END ;Subroutine
 SUBROUTINE PUBLIC::get_mpage_definition(_mp_mpage_def_id,report_name,report_param)
   SELECT INTO "nl:"
    FROM mp_mpage_def mmd
    PLAN (mmd
     WHERE mmd.mp_mpage_def_id=_mp_mpage_def_id
      AND mmd.def_type_flag=2)
    DETAIL
     report_name = mmd.driver_script_name, report_param = mmd.parameter_txt
    WITH nocounter
   ;end select
   CALL errorcheck(reply,"Get_MPage_Definition")
   CALL check_error_status(curqual,0,0,build("mp_mpage_def_record not found (",_mp_mpage_def_id,")"),
    reply)
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="F"))
  IF (validate(_memory_reply_string)=true)
   SET _memory_reply_string = cnvtrectojson(reply)
  ENDIF
 ENDIF
 IF ((((reqdata->loglevel >= 4)) OR (validate(debug_ind,0) > 0)) )
  CALL echorecord(reply)
 ENDIF
END GO
