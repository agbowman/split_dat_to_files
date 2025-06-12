CREATE PROGRAM dcp_ens_pw_maint_criteria:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE criteria_cnt = i4 WITH constant(value(size(request->criterialist,5)))
 DECLARE updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE insert_maintenance_criteria(idx=i4) = c1
 DECLARE update_maintenance_criteria(idx=i4) = c1
 DECLARE remove_maintenance_criteria(idx=i4) = c1
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 FOR (i = 1 TO criteria_cnt)
   IF ((request->criterialist[i].add_ind=1))
    SET cstatus = insert_maintenance_criteria(i)
    IF (cstatus="F")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->criterialist[i].modify_ind=1))
    SET cstatus = update_maintenance_criteria(i)
    IF (cstatus="F")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->criterialist[i].remove_ind=1))
    SET cstatus = remove_maintenance_criteria(i)
    IF (cstatus="F")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE insert_maintenance_criteria(idx)
   INSERT  FROM pw_maintenance_criteria pmc
    SET pmc.pw_maintenance_criteria_id = seq(reference_seq,nextval), pmc.encounter_type_flag =
     request->criterialist[idx].encounter_type_flag, pmc.time_qty = request->criterialist[idx].
     time_qty,
     pmc.time_unit_cd = request->criterialist[idx].time_unit_cd, pmc.type_mean = request->
     criterialist[idx].type_mean, pmc.version_pw_cat_id = request->criterialist[idx].
     version_pw_cat_id,
     pmc.updt_applctx = reqinfo->updt_applctx, pmc.updt_cnt = 0, pmc.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     pmc.updt_id = reqinfo->updt_id, pmc.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_ENS_MAINT_CRITERIA",
     "Unable to insert PW_MAINTENANCE_CRITERIA record")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE update_maintenance_criteria(idx)
   SET updt_cnt = 0
   SELECT INTO "n1:"
    pmc.*
    FROM pw_maintenance_criteria pmc
    WHERE (pmc.pw_maintenance_criteria_id=request->criterialist[idx].pw_maintenance_criteria_id)
    HEAD REPORT
     updt_cnt = pmc.updt_cnt
    WITH forupdate(pmc), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_ENS_MAINT_CRITERIA",
     "Unable to lock PW_MAINTENANCE_CRITERIA record")
    RETURN("F")
   ENDIF
   IF ((updt_cnt != request->criterialist[idx].updt_cnt))
    CALL report_failure("UPDATE","F","DCP_ENS_MAINT_CRITERIA",
     "UPDT_CNT does not match request->updt_cnt for PW_MAINTENANCE_CRITERIA record")
    RETURN("F")
   ENDIF
   UPDATE  FROM pw_maintenance_criteria pmc
    SET pmc.time_qty = request->criterialist[idx].time_qty, pmc.time_unit_cd = request->criterialist[
     idx].time_unit_cd, pmc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pmc.updt_id = reqinfo->updt_id, pmc.updt_task = reqinfo->updt_task, pmc.updt_applctx = reqinfo->
     updt_applctx,
     pmc.updt_cnt = (pmc.updt_cnt+ 1)
    WHERE (pmc.pw_maintenance_criteria_id=request->criterialist[idx].pw_maintenance_criteria_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_ENS_MAINT_CRITERIA",
     "Unable to update PW_MAINTENANCE_CRITERIA record")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE remove_maintenance_criteria(idx)
   DELETE  FROM pw_maintenance_criteria pmc
    WHERE (pmc.pw_maintenance_criteria_id=request->criterialist[idx].pw_maintenance_criteria_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    CALL report_failure("REMOVE","F","DCP_ENS_MAINT_CRITERIA",
     "Unable to remove PW_MAINTENANCE_CRITERIA record")
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cstatus="S")
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SET reply->status_data.status = cstatus
END GO
