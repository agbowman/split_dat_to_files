CREATE PROGRAM dcp_pregnancy_maint_labor:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failure_ind = i2 WITH protect, noconstant(false)
 DECLARE status = i2 WITH protect, noconstant(0)
 DECLARE action_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE action_tz = i4 WITH protect, noconstant(0)
 DECLARE action_dt_tm = dq8 WITH protect, noconstant
 DECLARE startlabor = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"LABORSTART"))
 DECLARE cancellabor = f8 WITH protect, constant(uar_get_code_by("MEANING",4002114,"LABORCANCEL"))
 DECLARE preg_inst_id = f8 WITH protect, noconstant(0.0)
 DECLARE checkforactivepreg(null) = null
 DECLARE performlaboraction(null) = null
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
 IF ((request->action_flag=0))
  SET action_type_cd = startlabor
  SET action_dt_tm = request->labor_start_dt_tm
  SET action_tz = request->start_tz
 ELSEIF ((request->action_flag=1))
  SET action_type_cd = cancellabor
  SET action_dt_tm = request->labor_cancel_dt_tm
  SET action_tz = request->cancel_tz
 ELSE
  SET failure_ind = true
  GO TO failure
 ENDIF
 CALL performlaboraction(null)
#failure
 IF (failure_ind=true)
  CALL echo("*Maint Labor Script failed*")
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE findpregbyperson(null)
  IF ((request->patient_id <= 0.0))
   SET reply->status_data.subeventstatus.operationname = "GetActivePregByPerson"
   SET reply->status_data.subeventstatus.operationstatus = "No pregnancy id or person_id was given"
   SET failure_ind = true
   GO TO failure
  ENDIF
  CALL checkforactivepreg(null)
 END ;Subroutine
 SUBROUTINE checkforactivepreg(null)
   CALL echo("[TRACE]: CheckForActivePreg")
   FREE RECORD actchkrequest
   RECORD actchkrequest(
     1 patient_id = f8
     1 encntr_id = f8
     1 org_sec_override = i2
   )
   SET actchkrequest->patient_id = request->person_id
   SET actchkrequest->encntr_id = request->encntr_id
   SET actchkrequest->org_sec_override = request->org_sec_override
   EXECUTE dcp_chk_active_preg  WITH replace("REQUEST",actchkrequest), replace("REPLY",actchkreply)
   IF ((actchkreply->status_data.status="F"))
    CALL echo("[FAIL]: DCP_CHK_ACTIVE_PREG failed")
   ELSEIF ((actchkreply->status_data.status="Z"))
    CALL echo("[ZERO]: No active pregnancy found")
   ELSE
    CALL echo("[TRACE]: Active Pregnancy found for patient")
   ENDIF
   IF ((actchkreply->pregnancy_id <= 0.0))
    SET reply->status_data.subeventstatus.operationname = "GetActivePregByPerson"
    SET reply->status_data.subeventstatus.operationstatus = "No active pregnancy found for patient"
    SET failure_ind = true
    GO TO failure
   ENDIF
   SET request->pregnancy_id = actchkreply->pregnancy_id
   SET preg_inst_id = actchkreply->pregnancy_instance_id
 END ;Subroutine
 SUBROUTINE performlaboraction(null)
   INSERT  FROM pregnancy_action pa
    SET pa.pregnancy_action_id = seq(pregnancy_seq,nextval), pa.pregnancy_instance_id = preg_inst_id,
     pa.pregnancy_id = request->pregnancy_id,
     pa.prsnl_id = request->prsnl_id, pa.action_type_cd = action_type_cd, pa.action_dt_tm =
     cnvtdatetime(action_dt_tm),
     pa.action_tz = action_tz, pa.updt_id = reqinfo->updt_id, pa.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     pa.updt_applctx = reqinfo->updt_applctx, pa.updt_cnt = 0, pa.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
 END ;Subroutine
END GO
