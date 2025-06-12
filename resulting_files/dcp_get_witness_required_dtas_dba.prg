CREATE PROGRAM dcp_get_witness_required_dtas:dba
 RECORD reply(
   1 qual[*]
     2 value = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dfunctiontimer = f8 WITH protect
 DECLARE dstarttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE slastmod = c14 WITH protect, noconstant("000 08/11/2008")
 DECLARE bdebugind = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind))
  IF ((request->debug_ind=1))
   CALL echo("Debugging has been enabled")
   SET bdebugind = 1
  ENDIF
 ENDIF
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE cclerrorcheck(scriptname=vc) = i2
 SUBROUTINE cclerrorcheck(scriptname)
   DECLARE errormessage = vc WITH protect
   DECLARE errorcount = i2
   DECLARE retval = i2 WITH protect, noconstant(0)
   DECLARE errorcode = i2 WITH protect, noconstant(error(errormessage,0))
   IF (errorcode > 0)
    CALL echo("**************************************")
    CALL echo(build("A CCL error has been detected in script(",scriptname,") for user id (",reqinfo->
      updt_id,")"))
    WHILE (errorcode != 0)
      CALL echo("----")
      CALL echo(build("errorCode: ",errorcode))
      CALL echo(build("errorMessage: ",errormessage))
      SET errorcode = error(errormessage,0)
    ENDWHILE
    CALL echo("**************************************")
    CALL reportfailure("CCL Error","F",scriptname,
     "A CCL error has been detected.  Please check the script logs for details.")
    SET retval = 1
    SET reqinfo->commit_ind = 0
   ENDIF
   RETURN(retval)
 END ;Subroutine
 DECLARE ndtacnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM code_value_extension cve,
   discrete_task_assay dta
  PLAN (cve
   WHERE cve.code_set=14003
    AND cve.field_name="dta_witness_required_ind"
    AND cve.field_value="1")
   JOIN (dta
   WHERE dta.task_assay_cd=cve.code_value)
  HEAD dta.task_assay_cd
   ndtacnt = (ndtacnt+ 1)
   IF (mod(ndtacnt,50)=1)
    stat = alterlist(reply->qual,(ndtacnt+ 49))
   ENDIF
   reply->qual[ndtacnt].name = dta.mnemonic, reply->qual[ndtacnt].value = dta.task_assay_cd
  FOOT REPORT
   stat = alterlist(reply->qual,ndtacnt)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL cclerrorcheck("dcp_get_witness_required_dtas")
 IF (bdebugind=1)
  CALL echo("*******************************************************")
  CALL echo(build("Last Mod = ",slastmod))
  CALL echo("*******************************************************")
  CALL echo("*******************************************************")
  CALL echo(build("Total Time = ",datetimediff(cnvtdatetime(curdate,curtime3),dstarttime,5)))
  CALL echo("*******************************************************")
  CALL echo("*******************************************************")
  CALL echorecord(reply)
  CALL echo("*******************************************************")
 ENDIF
END GO
