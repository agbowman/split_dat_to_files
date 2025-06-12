CREATE PROGRAM dcp_pregnancy_chk_labor:dba
 RECORD reply(
   1 prsnl_id = f8
   1 labor_start_dt_tm = dq8
   1 start_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failure_ind = i2 WITH protect, noconstant(false)
 DECLARE zero_ind = i2 WITH protect, noconstant(false)
 DECLARE status = i2 WITH protect, noconstant(0)
 DECLARE startlabor = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"LABORSTART"))
 DECLARE cancellabor = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"LABORCANCEL"))
 DECLARE checkactivepregnancy(argpersonid=f8) = f8
 DECLARE checkactivepregnancyorg(argpersonid=f8,argencntrid=f8,argorgsecoverride=i2) = f8
 SUBROUTINE checkactivepregnancy(argpersonid)
   RETURN(checkactivepregnancyorg(argpersonid,0,0))
 END ;Subroutine
 SUBROUTINE checkactivepregnancyorg(argpersonid,argencntrid,argorgsecoverride)
   CALL echo("[TRACE]: CheckActivePregnancy")
   DECLARE retval = f8 WITH noconstant(0.0), private
   RECORD actchkrequest(
     1 patient_id = f8
     1 encntr_id = f8
     1 org_sec_override = i2
   )
   SET actchkrequest->patient_id = argpersonid
   SET actchkrequest->encntr_id = argencntrid
   SET actchkrequest->org_sec_override = argorgsecoverride
   EXECUTE dcp_chk_active_preg  WITH replace("REQUEST",actchkrequest), replace("REPLY",actchkreply)
   IF ((actchkreply->status_data.status="F"))
    CALL echo("[FAIL]: DCP_CHK_ACTIVE_PREG failed")
   ELSEIF ((actchkreply->status_data.status="Z"))
    SET retval = 0.0
   ELSE
    CALL echo("[TRACE]: Active Pregnancy found for patient")
    SET retval = actchkreply->pregnancy_id
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET modify = predeclare
 IF ((request->pregnancy_id <= 0.0))
  CALL findpregbyperson(null)
 ENDIF
 CALL queryforlaboraction(null)
#failure
 IF (failure_ind=true)
  CALL echo("*Check Labor Script failed*")
 ELSEIF (zero_ind=true)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE findpregbyperson(null)
   IF ((request->patient_id <= 0.0))
    SET reply->status_data.subeventstatus.operationname = "GetActivePregByPerson"
    SET reply->status_data.subeventstatus.operationstatus = "No pregnancy id or person_id was given"
    SET failure_ind = true
    GO TO failure
   ENDIF
   DECLARE pregid = f8 WITH noconstant(0), public
   SET pregid = checkactivepregnancyorg(request->person_id,request->encntr_id,request->
    org_sec_override)
   IF (pregid <= 0.0)
    CALL echo("[ZERO]: Active pregnancy could not be found")
    SET reply->status_data.subeventstatus.operationname = "GetActivePregByPerson"
    SET reply->status_data.subeventstatus.operationstatus = "No active pregnancy found for patient"
    SET failure_ind = true
    GO TO failure
   ENDIF
   SET request->pregnancy_id = pregid
   CALL echo(build("[TRACE] Pregnancy found for patient:",request->pregnancy_id))
 END ;Subroutine
 SUBROUTINE queryforlaboraction(null)
  SELECT INTO "nl:"
   FROM pregnancy_action pa
   WHERE (pa.pregnancy_id=request->pregnancy_id)
    AND pa.action_type_cd IN (startlabor, cancellabor)
   ORDER BY pa.updt_dt_tm DESC
   HEAD REPORT
    IF (pa.action_type_cd=startlabor)
     CALL echo(build("action:",pa.action_type_cd)), reply->labor_start_dt_tm = pa.action_dt_tm, reply
     ->start_tz = pa.action_tz,
     reply->prsnl_id = pa.prsnl_id
    ELSE
     zero_ind = true
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET zero_ind = true
  ENDIF
 END ;Subroutine
END GO
