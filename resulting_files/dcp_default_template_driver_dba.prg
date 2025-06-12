CREATE PROGRAM dcp_default_template_driver:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 template_cd = f8
    1 person_id = f8
    1 encntr_id = f8
    1 prsnl_id = f8
    1 order_id = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 default_result_list[*]
      2 nomenclature_id = f8
      2 result_cd = f8
      2 result_set = i4
    1 text_val = vc
    1 long_val = i4
    1 double_val = f8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SUBROUTINE (errorcheck(opname=vc,targetname=vc) =i2)
   DECLARE problemcount = i2
   SET problemcount = errorchecknosetcommitind(opname,targetname)
   IF (problemcount > 0)
    SET reqinfo->commit_ind = 2
   ENDIF
   RETURN(problemcount)
 END ;Subroutine
 SUBROUTINE (errorchecknosetcommitind(opname=vc,targetname=vc) =i2)
   DECLARE errormessage = vc
   DECLARE errorcode = i2
   DECLARE errorcount = i2
   DECLARE retval = i2
   SET retval = 0
   SET errorcode = error(errormessage,0)
   IF (errorcode != 0)
    IF (validate(reply)=1)
     SET errorcount = size(reply->status_data.subeventstatus,5)
     WHILE (errorcode != 0
      AND errorcount < 50)
       SET retval = 1
       SET reply->status_data.status = "F"
       SET errorcount += 1
       SET stat = alterlist(reply->status_data.subeventstatus,errorcount)
       SET reply->status_data.subeventstatus[errorcount].operationname = opname
       SET reply->status_data.subeventstatus[errorcount].operationstatus = "F"
       SET reply->status_data.subeventstatus[errorcount].targetobjectname = targetname
       SET reply->status_data.subeventstatus[errorcount].targetobjectvalue = errormessage
       SET errorcode = error(errormessage,0)
     ENDWHILE
    ELSE
     SET retval = 1
    ENDIF
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE (frnaddreplytimestampname(opname=vc,starttime=f8) =i2)
  IF (validate(reply)=1)
   DECLARE timeentryindex = i2
   SET timeentryindex = (1+ size(reply->status_data.subeventstatus,5))
   SET stat = alterlist(reply->status_data.subeventstatus,timeentryindex)
   SET reply->status_data.subeventstatus[timeentryindex].operationname = opname
   SET reply->status_data.subeventstatus[timeentryindex].operationstatus = "T"
   SET reply->status_data.subeventstatus[timeentryindex].targetobjectname = "Elapsed Time in Script"
   SET reply->status_data.subeventstatus[timeentryindex].targetobjectvalue = build2(cnvtint((curtime3
      - starttime)),"0 ms")
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE (frnaddreplytimestamp(starttime=f8) =i2)
  IF (validate(reply)=1)
   DECLARE timeentryindex = i2
   SET timeentryindex = (1+ size(reply->status_data.subeventstatus,5))
   SET stat = alterlist(reply->status_data.subeventstatus,timeentryindex)
   SET reply->status_data.subeventstatus[timeentryindex].operationname = ""
   SET reply->status_data.subeventstatus[timeentryindex].operationstatus = "T"
   SET reply->status_data.subeventstatus[timeentryindex].targetobjectname = "Elapsed Time in Script"
   SET reply->status_data.subeventstatus[timeentryindex].targetobjectvalue = build2(cnvtint((curtime3
      - starttime)),"0 ms")
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE (frnadderror(opname=vc,targetname=vc) =i2)
  IF (validate(reply)=1)
   DECLARE icount = i4
   SET icount = (1+ size(reply->status_data.subeventstatus,5))
   SET stat = alterlist(reply->status_data.subeventstatus,icount)
   SET reply->status_data.subeventstatus[icount].operationname = targetname
   SET reply->status_data.subeventstatus[icount].operationstatus = "F"
   SET reply->status_data.subeventstatus[icount].targetobjectname = targetname
   SET reply->status_data.subeventstatus[icount].targetobjectvalue = opname
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE (frnaddstatus(opname=vc,targetname=vc,targetvalue=vc,operationstatus=vc) =i2)
  IF (validate(reply)=1)
   DECLARE icount = i4
   SET icount = (1+ size(reply->status_data.subeventstatus,5))
   SET stat = alterlist(reply->status_data.subeventstatus,icount)
   SET reply->status_data.subeventstatus[icount].operationname = opname
   SET reply->status_data.subeventstatus[icount].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[icount].targetobjectname = targetname
   SET reply->status_data.subeventstatus[icount].targetobjectvalue = targetvalue
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE (frnmsgwrite(sdomainname=vc,seventname=vc,smessage=vc) =i2)
   DECLARE ilogtype = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain=sdomainname
     AND di.info_name="fn_log"
    DETAIL
     ilogtype = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   IF (ilogtype=1)
    DECLARE emsglog_commit = i4 WITH constant(0)
    DECLARE emsglvl_debug = i4 WITH constant(4)
    DECLARE hmsg = i4 WITH noconstant(0)
    EXECUTE msgrtl
    SET hmsg = uar_msgopen("fn_log")
    CALL uar_msgsetlevel(hmsg,emsglvl_debug)
    CALL uar_msgwrite(hmsg,emsglog_commit,nullterm(seventname),emsglvl_debug,nullterm(smessage))
    CALL uar_msgclose(hmsg)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SET reply->status_data.status = "S"
 SET program_name = fillstring(50," ")
 DECLARE errorstr = vc
 DECLARE scriptexists = i2 WITH noconstant(0)
 IF ((request->template_cd > 0))
  SET program_name = cnvtupper(trim(uar_get_definition(request->template_cd)))
  SET scriptexists = checkprg(program_name)
  CALL echo(build("scriptexists = ",scriptexists))
  IF (scriptexists=0)
   SET reply->status_data.status = "F"
   SET errorstr = build("program(",program_name,") was not found in the object library")
   CALL frnadderror(errorstr,program_name)
   GO TO exit_program
  ENDIF
  EXECUTE value(program_name)
 ENDIF
#exit_program
 CALL echorecord(reply)
END GO
