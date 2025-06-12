CREATE PROGRAM acm_notify_profit_for_reg_mod:dba
 IF (validate(reply,"-999")="-999")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(notifyprofitforregmodforencounter,char(128))=char(128))
  SUBROUTINE (notifyprofitforregmodforencounter(encntrid=f8,pmdata=vc(ref)) =i2)
    DECLARE encntrcnt = i4 WITH protect, noconstant(0)
    DECLARE ephcdvalue = f8 WITH protect, noconstant(0.0)
    FREE RECORD holdsrequest
    RECORD holdsrequest(
      1 objarray[*]
        2 pft_encntr_id = f8
        2 pe_status_reason_cd = f8
        2 reason_comment = vc
        2 reapply_ind = i4
    )
    FREE RECORD holdsreply
    RECORD holdsreply(
      1 pft_status_data
        2 status = c1
        2 subeventstatus[*]
          3 status = c1
          3 table_name = vc
          3 pk_values = vc
      1 mod_objs[*]
        2 entity_type = vc
        2 mod_recs[*]
          3 table_name = vc
          3 pk_values = vc
          3 mod_flds[*]
            4 field_name = vc
            4 field_type = vc
            4 field_value_obj = vc
            4 field_value_db = vc
      1 failure_stack
        2 failures[*]
          3 programname = vc
          3 routinename = vc
          3 message = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    IF (((checkprg("PFT_RM_PROCESS_REG_MODS")=0) OR (checkprg("PFT_APPLY_BILL_HOLD_SUSPENSION")=0)) )
     RETURN(false)
    ENDIF
    SET stat = uar_get_meaning_by_codeset(24450,"PENDREGMOD",1,ephcdvalue)
    IF (ephcdvalue <= 0.0)
     RETURN(false)
    ENDIF
    SELECT INTO "nl:"
     FROM encounter e,
      pft_encntr pe
     PLAN (e
      WHERE e.encntr_id=encntrid)
      JOIN (pe
      WHERE pe.encntr_id=e.encntr_id
       AND pe.active_ind=true
       AND  NOT ( EXISTS (
      (SELECT
       psr.pe_status_reason_cd
       FROM pe_status_reason psr
       WHERE psr.pft_encntr_id=pe.pft_encntr_id
        AND psr.pe_status_reason_cd=ephcdvalue
        AND psr.active_ind=true))))
     ORDER BY pe.pft_encntr_id
     HEAD pe.pft_encntr_id
      encntrcnt += 1, stat = alterlist(holdsrequest->objarray,encntrcnt), holdsrequest->objarray[
      encntrcnt].pft_encntr_id = pe.pft_encntr_id,
      holdsrequest->objarray[encntrcnt].pe_status_reason_cd = ephcdvalue, holdsrequest->objarray[
      encntrcnt].reapply_ind = true
     WITH nocounter
    ;end select
    IF (size(holdsrequest->objarray,5) > 0)
     EXECUTE pft_apply_bill_hold_suspension  WITH replace("REQUEST",holdsrequest), replace("REPLY",
      holdsreply)
     IF ((holdsreply->status_data.status != "S"))
      RETURN(false)
     ENDIF
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 SET reply->status_data.status = "S"
 IF ((request->encntr_id <= 0.0))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "REQUEST"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ENCNTR_ID"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "ENCNTR_ID must be greater than 0.0 in the request to notify ProFit that a registration modification occurred for an encounter."
 ELSEIF (uar_get_code_by("MEANING",207902,"NOTIFYPROFIT") > 0.0)
  IF (notifyprofitforregmodforencounter(request->encntr_id,request) != true)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "EXECUTE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "NotifyProFitForRegMod"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "ProFit notification that a registration modification    occurred for an encounter failed."
  ENDIF
 ENDIF
END GO
