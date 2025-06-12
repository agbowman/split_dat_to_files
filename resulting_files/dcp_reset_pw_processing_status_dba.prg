CREATE PROGRAM dcp_reset_pw_processing_status:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE s_script_name = vc WITH protect, constant("dcp_reset_pw_processing_status")
 DECLARE l_list_count = i4 WITH protect, constant(value(size(request->phases,5)))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE icheckupdatecount = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(5," "))
 DECLARE icounter = i4 WITH protect, noconstant(0)
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET reply->status_data.status = "S"
 IF (l_list_count < 1)
  CALL set_script_status("Z","BEGIN","Z",s_script_name,"The pathway list was empty.")
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO l_list_count)
  SELECT INTO "nl:"
   ppa.pathway_id
   FROM pw_processing_action ppa
   WHERE (ppa.pathway_id=request->phases[idx].pathway_id)
   DETAIL
    icheckupdatecount = ppa.processing_updt_cnt
   WITH forupdate(ppa), nocounter
  ;end select
  IF (curqual > 0)
   IF (icheckupdatecount <= 0)
    DELETE  FROM pw_processing_action ppa2
     WHERE (ppa2.pathway_id=request->phases[idx].pathway_id)
     WITH nocounter
    ;end delete
    IF (curqual=1)
     SET icounter = (icounter+ 1)
    ENDIF
   ELSE
    UPDATE  FROM pw_processing_action ppa3
     SET ppa3.processing_updt_cnt = (ppa3.processing_updt_cnt - 1), ppa3.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), ppa3.updt_id = reqinfo->updt_id,
      ppa3.updt_task = reqinfo->updt_task, ppa3.updt_cnt = (ppa3.updt_cnt+ 1), ppa3.updt_applctx =
      reqinfo->updt_applctx
     WHERE (ppa3.pathway_id=request->phases[idx].pathway_id)
     WITH nocounter
    ;end update
    IF (curqual=1)
     SET icounter = (icounter+ 1)
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 IF (icounter=0)
  CALL set_script_status("F","UPDATE","F",s_script_name,"The pathway id does not exists.")
  GO TO exit_script
 ENDIF
 IF (icounter < l_list_count)
  CALL set_script_status("F","UPDATE","F",s_script_name,"Could not acquire locks for pathway id.")
  GO TO exit_script
 ENDIF
 SUBROUTINE set_script_status(cstatus,soperationname,coperationstatus,stargetobjectname,
  stargetobjectvalue)
   SET reply->status_data.status = cstatus
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim(
     soperationname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(
    coperationstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,trim
    (stargetobjectname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(
    stargetobjectvalue)
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="Z"))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SET last_mod = "001"
END GO
