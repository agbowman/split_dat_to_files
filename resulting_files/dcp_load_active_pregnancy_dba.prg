CREATE PROGRAM dcp_load_active_pregnancy:dba
 RECORD reply(
   1 pregnancy_id = f8
   1 problem_id = f8
   1 patient_id = f8
   1 org_id = f8
   1 confirmation_dt_tm = dq8
   1 preg_start_dt_tm = dq8
   1 preg_end_dt_tm = dq8
   1 pregnancy_entities[*]
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 component_cd = f8
     2 component_disp = c40
     2 component_desc = vc
     2 component_mean = c12
     2 pregnancy_entity_id = f8
   1 confirmation_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD chkrequest(
   1 patient_id = f8
   1 encntr_id = f8
   1 org_sec_override = i2
 )
 DECLARE failure_ind = i2 WITH protect, noconstant(false)
 DECLARE zero_ind = i2 WITH protect, noconstant(false)
 DECLARE status = i2 WITH protect, noconstant(0)
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
 IF ((request->problem_id <= 0.0))
  DECLARE pregid = f8 WITH noconstant(0)
  SET pregid = checkactivepregnancyorg(request->patient_id,request->encntr_id,request->
   org_sec_override)
  IF (pregid <= 0.0)
   CALL echo("[ZERO] Active pregnancy not found")
   SET zero_ind = true
   GO TO failure
  ENDIF
  SET reply->pregnancy_id = pregid
 ENDIF
 CALL querypregnancy(null)
#failure
 IF (failure_ind=true)
  CALL echo("*Load Active Pregnancy Script failed*")
 ELSEIF (zero_ind=true)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE querypregnancy(null)
  SELECT
   IF ((request->problem_id > 0.0))
    PLAN (pi
     WHERE (pi.problem_id=request->problem_id)
      AND pi.active_ind=true
      AND pi.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
      AND pi.historical_ind=0)
     JOIN (per
     WHERE per.pregnancy_id=outerjoin(pi.pregnancy_id)
      AND per.active_ind=outerjoin(true))
   ELSE
    PLAN (pi
     WHERE (pi.pregnancy_id=reply->pregnancy_id)
      AND pi.active_ind=true
      AND pi.preg_end_dt_tm=cnvtdatetime("31-DEC-2100")
      AND pi.historical_ind=0)
     JOIN (per
     WHERE per.pregnancy_id=outerjoin(pi.pregnancy_id)
      AND per.active_ind=outerjoin(true))
   ENDIF
   INTO "nl:"
   FROM pregnancy_instance pi,
    pregnancy_entity_r per
   HEAD REPORT
    reply->patient_id = pi.person_id, reply->org_id = pi.organization_id, reply->pregnancy_id = pi
    .pregnancy_id,
    reply->problem_id = pi.problem_id, reply->confirmation_dt_tm = cnvtdatetime(pi.confirmed_dt_tm),
    reply->confirmation_tz = pi.confirmed_tz,
    reply->preg_start_dt_tm = pi.preg_start_dt_tm, reply->preg_end_dt_tm = pi.preg_end_dt_tm
   HEAD per.pregnancy_entity_id
    status = alterlist(reply->pregnancy_entities,10), idx = 0
   DETAIL
    idx = (idx+ 1)
    IF (mod(idx,10)=1)
     status = alterlist(reply->pregnancy_entities,(idx+ 9))
    ENDIF
    reply->pregnancy_entities[idx].pregnancy_entity_id = per.pregnancy_entity_id, reply->
    pregnancy_entities[idx].parent_entity_id = per.parent_entity_id, reply->pregnancy_entities[idx].
    parent_entity_name = per.parent_entity_name,
    reply->pregnancy_entities[idx].component_cd = per.component_type_cd
   FOOT  per.pregnancy_entity_id
    status = alterlist(reply->pregnancy_entities,idx)
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   CALL echo("[ZERO] No pregnancy was found")
   SET zero_ind = true
   GO TO failure
  ENDIF
 END ;Subroutine
END GO
