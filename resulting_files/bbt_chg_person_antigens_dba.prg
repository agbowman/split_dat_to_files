CREATE PROGRAM bbt_chg_person_antigens:dba
 DECLARE script_name = c40 WITH public, constant("BBT_CHG_PERSON_ANTIGENS")
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FOR (i = 1 TO size(request->antigenlist,5))
   SELECT INTO "nl:"
    pa.person_antigen_id
    FROM person_antigen pa
    WHERE (pa.person_antigen_id=request->antigenlist[i].person_antigen_id)
     AND (pa.updt_cnt=request->antigenlist[i].updt_cnt)
    WITH nocounter, forupdate(pa)
   ;end select
   IF (curqual=0)
    CALL fill_out_status_data("F","PERSON_ANTIGEN",concat("[",
      "FAILED to find PERSON_ANTIGEN --person_antigen_id = ",trim(cnvtstring(request->antigenlist[i].
        person_antigen_id,32,2)),", ","updt_cnt=",
      trim(cnvtstring(request->antigenlist[i].updt_cnt,2,0)),".","]"))
    GO TO exit_script
   ENDIF
   UPDATE  FROM person_antigen pa
    SET pa.active_ind = 0, pa.updt_cnt = (pa.updt_cnt+ 1), pa.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     pa.removed_prsnl_id = reqinfo->updt_id, pa.removed_dt_tm = cnvtdatetime(curdate,curtime3), pa
     .removal_reason_cd = request->antigenlist[i].removal_reason_cd,
     pa.removal_notes = request->antigenlist[i].removal_comment, pa.updt_id = reqinfo->updt_id, pa
     .updt_task = reqinfo->updt_task,
     pa.updt_applctx = reqinfo->updt_applctx
    WHERE (pa.person_antigen_id=request->antigenlist[i].person_antigen_id)
     AND (pa.updt_cnt=request->antigenlist[i].updt_cnt)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL fill_out_status_data("F","PERSON_ANTIGEN",concat("[",
      "Failed to update the active_ind for the ",trim(cnvtstring(request->antigen[i].
        person_antigen_id,32,0)),".","]"))
    GO TO exit_script
   ENDIF
 ENDFOR
 DECLARE fill_out_status_data(status=c1,target_object_name=c25,target_object_value=vc) = null
 SUBROUTINE fill_out_status_data(status,target_object_name,target_object_value)
   SET reply->status_data.status = status
   SET reply->status_data.subeventstatus[1].operationstatus = status
   SET reply->status_data.subeventstatus[1].operationname = script_name
   SET reply->status_data.subeventstatus[1].targetobjectname = target_object_name
   SET reply->status_data.subeventstatus[1].targetobjectvalue = target_object_value
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
