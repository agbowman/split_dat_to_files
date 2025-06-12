CREATE PROGRAM dispensecategory_discover_keys:dba
 SET modify = predeclare
 RECORD reply(
   1 keys[*]
     2 key_id = vc
     2 changed = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE tracerbegin(programname=vc,version=vc) = null
 SUBROUTINE tracerbegin(programname,version)
  CALL echo("BEGIN",0)
  CALL printnameversion(programname,version)
 END ;Subroutine
 DECLARE tracerend(programname=vc,version=vc) = null
 SUBROUTINE tracerend(programname,version)
  CALL echo("END",0)
  CALL printnameversion(programname,version)
 END ;Subroutine
 DECLARE printnameversion(programname=vc,version=vc) = null
 SUBROUTINE printnameversion(programname,version)
   CALL echo(build(" [",programname,"]"),0)
   CALL echo(" v",0)
   CALL echo(version,0)
   CALL echo(" @",0)
   CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 END ;Subroutine
 DECLARE checkerrors(programname=vc) = i1
 SUBROUTINE checkerrors(programname)
   DECLARE errormessage = vc WITH private, noconstant("")
   DECLARE numberoferrors = i4 WITH private, noconstant(0)
   DECLARE errorcode = i1 WITH private, noconstant(error(errormessage,0))
   IF (errorcode > 0)
    CALL echo("")
    CALL echo(build("Errors encountered while running program [",programname,"]"))
    SET reply->status_data.status = "F"
    WHILE (errorcode != 0
     AND numberoferrors < 20)
      SET numberoferrors = (numberoferrors+ 1)
      CALL echo(errormessage)
      CALL addsubeventstatus(programname,"F","CCL ERROR",errormessage)
      SET errorcode = error(errormessage,0)
    ENDWHILE
   ENDIF
   IF (numberoferrors > 0)
    RETURN(true)
   ELSE
    RETURN(false)
   ENDIF
 END ;Subroutine
 DECLARE addsubeventstatus(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=
  vc) = null
 SUBROUTINE addsubeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   DECLARE stataddsubevent = i4 WITH private, noconstant(0)
   DECLARE subeventstatussize = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5)
    )
   IF (((size(trim(reply->status_data.subeventstatus[subeventstatussize].operationname),1) > 0) OR (
   ((size(trim(reply->status_data.subeventstatus[subeventstatussize].operationstatus),1) > 0) OR (((
   size(trim(reply->status_data.subeventstatus[subeventstatussize].targetobjectname),1) > 0) OR (size
   (trim(reply->status_data.subeventstatus[subeventstatussize].targetobjectvalue),1) > 0)) )) )) )
    SET subeventstatussize = (subeventstatussize+ 1)
    SET stataddsubevent = alter(reply->status_data.subeventstatus,subeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[subeventstatussize].operationname = substring(0,25,
    operationname)
   SET reply->status_data.subeventstatus[subeventstatussize].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[subeventstatussize].targetobjectname = substring(0,25,
    targetobjectname)
   SET reply->status_data.subeventstatus[subeventstatussize].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 DECLARE program_name = vc WITH private, constant("dispensecategory_discover_keys")
 DECLARE program_version = vc WITH private, constant("000")
 DECLARE stat = i4 WITH private, noconstant(0)
 CALL tracerbegin(program_name,program_version)
 DECLARE isrequestvalid(unusedargument=i1) = i1
 DECLARE getupdatedkeys(unusedargument=i1) = null
 IF (isrequestvalid(0))
  CALL getupdatedkeys(0)
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = checkerrors(program_name)
 CALL tracerend(program_name,program_version)
 SUBROUTINE isrequestvalid(unusedargument)
  IF ((request->since <= 0))
   CALL addsubeventstatus("REQUEST","F","since","since was invalid, it was <= 0.")
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE getupdatedkeys(unusedargument)
  DECLARE i = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM dispense_category dc
   PLAN (dc
    WHERE ((dc.dispense_category_cd+ 0) > 0)
     AND dc.updt_dt_tm > cnvtdatetime(request->since))
   HEAD REPORT
    i = 0
   DETAIL
    i = (i+ 1)
    IF (i > size(reply->keys,5))
     stat = alterlist(reply->keys,(i+ 10))
    ENDIF
    reply->keys[i].key_id = trim(cnvtstring(dc.dispense_category_cd)), reply->keys[i].changed = dc
    .updt_dt_tm
   FOOT REPORT
    stat = alterlist(reply->keys,i)
   WITH nocounter
  ;end select
 END ;Subroutine
END GO
