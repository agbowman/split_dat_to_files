CREATE PROGRAM drr_ext_svcccl_wrapper:dba
 IF ( NOT (validate(reply,0)))
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
 RECORD script_request(
   1 person_id = f8
   1 process = vc
 )
 RECORD script_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE build_parser_call() = vc
 DECLARE validate_request() = i2
 DECLARE map_reply() = null
 DECLARE parser_call = vc WITH noconstant("")
 DECLARE repcnt = i4 WITH noconstant(0)
 DECLARE errormsg = vc WITH noconstant("")
 SET script_request->person_id = request->person_id
 SET script_request->process = request->process
 IF (validate_request(null)=0)
  GO TO exit_script
 ENDIF
 SET parser_call = build_parser_call(null)
 CALL parser(parser_call)
 IF (error(errormsg,0) != 0)
  SET reply->status_data.status = "F"
  CALL set_status_record("F","Call child script",errormsg,request->script_name)
  GO TO exit_script
 ENDIF
 CALL map_reply(null)
 SUBROUTINE build_parser_call(null)
   DECLARE parser_str = vc WITH noconstant(""), protect
   SET parser_str = concat("execute ",request->script_name,
    " with REPLACE(request,script_request), replace(reply, script_reply) go")
   RETURN(parser_str)
 END ;Subroutine
 SUBROUTINE validate_request(null)
   DECLARE process = vc WITH constant("Validate request")
   DECLARE object = vc WITH constant("drr_ext_svcccl_wrapper")
   DECLARE valid = i2 WITH noconstant(1)
   IF ((request->process=""))
    CALL set_status_record("F",process,"Process type cannot be empty.",object)
    SET valid = 0
   ENDIF
   IF ((request->script_name=""))
    CALL set_status_record("F",process,"The script name cannot be empty.",object)
    SET valid = 0
   ELSEIF (checkdic(cnvtupper(request->script_name),"P",0) != 2)
    CALL set_status_record("F",process,concat("The script ",request->script_name,
      " does not exist or is not accessible."),object)
    SET valid = 0
   ENDIF
   IF ((request->person_id <= 0))
    CALL set_status_record("F",process,"The person id should be greater than 0.",object)
    SET valid = 0
   ENDIF
   RETURN(valid)
 END ;Subroutine
 SUBROUTINE map_reply(null)
  IF ((script_reply->status_data.status != "S"))
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  FOR (i = 1 TO size(script_reply->status_data.subeventstatus,5))
    CALL set_status_record(script_reply->status_data.subeventstatus[i].operationstatus,script_reply->
     status_data.subeventstatus[i].operationname,script_reply->status_data.subeventstatus[i].
     targetobjectvalue,script_reply->status_data.subeventstatus[i].targetobjectname)
  ENDFOR
 END ;Subroutine
 SUBROUTINE (set_status_record(sub_status=c1,sub_process=vc,sub_message=vc,sub_object=vc) =null)
   SET repcnt += 1
   IF (repcnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,repcnt)
   ENDIF
   SET reply->status_data.subeventstatus[repcnt].operationname = sub_process
   SET reply->status_data.subeventstatus[repcnt].operationstatus = sub_status
   SET reply->status_data.subeventstatus[repcnt].targetobjectname = sub_object
   SET reply->status_data.subeventstatus[repcnt].targetobjectvalue = sub_message
 END ;Subroutine
#exit_script
END GO
