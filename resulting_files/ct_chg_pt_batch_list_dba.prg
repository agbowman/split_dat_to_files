CREATE PROGRAM ct_chg_pt_batch_list:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 elist[*]
      2 person_id = f8
      2 status = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE batchlistremoveperson(prot_master_id=f8,person_id=f8) = i2
 SUBROUTINE batchlistremoveperson(prot_master_id,person_id)
   CALL echo(build("BatchListRemovePerson::prot_master_id = ",prot_master_id))
   CALL echo(build("BatchListRemovePerson::person_id = ",person_id))
   DELETE  FROM ct_pt_prot_batch_list bl
    WHERE bl.person_id=person_id
     AND bl.prot_master_id=prot_master_id
    WITH nocounter
   ;end delete
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE insert_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE lock_error = i2 WITH private, constant(3)
 DECLARE duplication_error = i2 WITH private, constant(4)
 DECLARE delete_error = i2 WITH private, constant(5)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE fail_flag = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE enrolled_ind = i2 WITH protect, noconstant(0)
 DECLARE consent_pending_ind = i2 WITH protect, noconstant(0)
 DECLARE exists_ind = i2 WITH protect, noconstant(0)
 DECLARE enroll_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",17349,"ENROLLING"))
 SET reply->status_data.status = "F"
 SET cnt = 0
 CALL echo(build("size(request->plist, 5) =",size(request->plist,5)))
 FOR (idx = 1 TO size(request->plist,5))
   CALL echo(build("idx = ",idx))
   SET enrolled_ind = 0
   SET consent_pending_ind = 0
   SET exists_ind = 0
   IF ((request->plist[idx].delete_ind=1))
    IF (batchlistremoveperson(request->prot_master_id,request->plist[idx].person_id)=1)
     SET fail_flag = delete_error
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Error deleting from ct_pt_prot_batch_list table."
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM ct_pt_prot_batch_list bl
     WHERE (bl.person_id=request->plist[idx].person_id)
      AND (bl.prot_master_id=request->prot_master_id)
     DETAIL
      CALL echo("PATIENT ALREADY IN LIST"), exists_ind = 1
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM pt_prot_reg ppr
     PLAN (ppr
      WHERE (ppr.prot_master_id=request->prot_master_id)
       AND (ppr.person_id=request->plist[idx].person_id)
       AND ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     DETAIL
      enrolled_ind = 1
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     pc.person_id, pm.prot_master_id, reason_disp = uar_get_code_meaning(pc.reason_for_consent_cd)
     FROM prot_master pm,
      prot_amendment pa,
      pt_consent pc
     PLAN (pm
      WHERE (pm.prot_master_id=request->prot_master_id))
      JOIN (pa
      WHERE pa.prot_master_id=pm.prot_master_id)
      JOIN (pc
      WHERE pc.prot_amendment_id=pa.prot_amendment_id
       AND (pc.person_id=request->plist[idx].person_id)
       AND pc.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
       AND pc.consent_signed_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
       AND pc.not_returned_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
     DETAIL
      IF (reason_disp="ENROLLING")
       CALL echo("PATIENT HAS CONSENT PENDING SIGNATURE"), consent_pending_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    IF (enrolled_ind=0
     AND exists_ind=0
     AND consent_pending_ind=0)
     CALL echo("Inserting record")
     INSERT  FROM ct_pt_prot_batch_list bl
      SET bl.ct_pt_prot_batch_list_id = seq(protocol_def_seq,nextval), bl.prot_master_id = request->
       prot_master_id, bl.person_id = request->plist[idx].person_id,
       bl.updt_dt_tm = cnvtdatetime(curdate,curtime3), bl.updt_id = reqinfo->updt_id, bl.updt_task =
       reqinfo->updt_task,
       bl.updt_applctx = reqinfo->updt_applctx, bl.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET fail_flag = insert_error
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "Error inserting into ct_pt_prot_batch_list table."
      GO TO check_error
     ENDIF
    ELSE
     SET cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      SET stat = alterlist(reply->elist,(cnt+ 9))
     ENDIF
     SET reply->elist[cnt].person_id = request->plist[cnt].person_id
     IF (consent_pending_ind=1)
      SET reply->elist[cnt].status = "C"
     ELSEIF (enrolled_ind=1)
      SET reply->elist[cnt].status = "E"
     ELSEIF (exists_ind=1)
      SET reply->elist[cnt].status = "Z"
     ENDIF
     IF (((enrolled_ind=1) OR (consent_pending_ind=1))
      AND exists_ind=1)
      IF (batchlistremoveperson(request->prot_master_id,request->plist[idx].person_id)=1)
       SET fail_flag = delete_error
       SET reply->status_data.subeventstatus[1].targetobjectvalue =
       "Error deleting from ct_pt_prot_batch_list table."
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->elist,cnt)
 IF (cnt > 0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("size(reply->status_data->subeventstatus, 5) = ",size(reply->status_data.
    subeventstatus,5)))
#check_error
 IF (fail_flag=0)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.status = "F"
    CALL echo("INSERT_ERROR")
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.status = "F"
   OF duplication_error:
    SET reply->status_data.subeventstatus[1].operationname = "DUPLICATE KEY"
    SET reply->status_data.status = "D"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE ERROR"
    SET reply->status_data.status = "R"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "000"
 SET mod_date = "February 12, 2009"
END GO
