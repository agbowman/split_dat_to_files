CREATE PROGRAM ct_get_pt_consents:dba
 RECORD reply(
   1 highestamendid = f8
   1 highestamendnbr = f8
   1 highestrevisionind = i2
   1 highestrevisionnbrtxt = c30
   1 activeamendid = f8
   1 activeamendnbr = f8
   1 activerevisionind = i2
   1 activerevisionnbrtxt = c30
   1 curdate = dq8
   1 consents[*]
     2 ct_document_version_id = f8
     2 person_id = f8
     2 prot_amendment_id = f8
     2 not_returned_dt_tm = dq8
     2 not_returned_reason_cd = f8
     2 not_returned_reason_disp = vc
     2 not_returned_reason_desc = vc
     2 not_returned_reason_mean = vc
     2 pt_consent_id = f8
     2 consent_id = f8
     2 conupdtcnt = i4
     2 connbr = i4
     2 consenting_person_id = f8
     2 consenting_person_name = vc
     2 consenting_organization_id = f8
     2 consenting_organization_name = vc
     2 consent_signed_dt_tm = dq8
     2 reason_for_consent_cd = f8
     2 reason_for_consent_disp = vc
     2 reason_for_consent_desc = vc
     2 reason_for_consent_mean = vc
     2 consent_received_dt_tm = dq8
     2 consent_released_dt_tm = dq8
     2 conissued_tm_ind = i2
     2 consigned_tm_ind = i2
     2 conreceived_tm_ind = i2
     2 notreturned_tm_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET last_mod = "009"
 SET mod_date = "April 22, 2019"
 SET count = 0
 SET reply->status_data.status = "F"
 SET reply->curdate = cnvtdatetime(sysdate)
 IF ((request->inactivealso=0))
  SET whr2 = "PC.not_returned_dt_tm >= cnvtdatetime(curdate,curtime3)"
 ELSE
  SET whr2 = "1=1"
 ENDIF
 IF ((request->amendmentid=0))
  SET whr1 = "1=1"
 ELSE
  SET whr1 = build("PC.prot_amendment_id = ",request->amendmentid)
 ENDIF
 IF ((request->consentid != 0))
  CALL echo(build("Request->ConsentID != 0"))
  CALL echo(" LOCATOR 1")
  SELECT INTO "nl:"
   pc.*, p.name_full_formatted
   FROM pt_consent pc,
    person p,
    dummyt d1,
    dummyt d2,
    organization orgc
   PLAN (pc
    WHERE (pc.consent_id=request->consentid)
     AND pc.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND parser(whr2))
    JOIN (d1)
    JOIN (p
    WHERE p.person_id=pc.consenting_person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (d2)
    JOIN (orgc
    WHERE orgc.organization_id=pc.consenting_organization_id
     AND orgc.active_ind=1
     AND orgc.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND orgc.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    count += 1, stat = alterlist(reply->consents,count), reply->consents[count].
    ct_document_version_id = pc.ct_document_version_id,
    reply->consents[count].person_id = pc.person_id, reply->consents[count].prot_amendment_id = pc
    .prot_amendment_id, reply->consents[count].not_returned_reason_cd = pc.not_returned_reason_cd,
    reply->consents[count].not_returned_dt_tm = pc.not_returned_dt_tm, reply->consents[count].
    notreturned_tm_ind = pc.not_returned_tm_ind, reply->consents[count].consent_released_dt_tm = pc
    .consent_released_dt_tm,
    reply->consents[count].conissued_tm_ind = pc.consent_released_tm_ind, reply->consents[count].
    pt_consent_id = pc.pt_consent_id, reply->consents[count].consent_id = pc.consent_id,
    reply->consents[count].connbr = pc.consent_nbr, reply->consents[count].conupdtcnt = pc.updt_cnt,
    reply->consents[count].consenting_person_id = pc.consenting_person_id,
    reply->consents[count].consenting_person_name = p.name_full_formatted, reply->consents[count].
    consenting_organization_id = pc.consenting_organization_id, reply->consents[count].
    consenting_organization_name = orgc.org_name,
    reply->consents[count].consent_signed_dt_tm = cnvtdatetime(pc.consent_signed_dt_tm), reply->
    consents[count].consigned_tm_ind = pc.consent_signed_tm_ind, reply->consents[count].
    reason_for_consent_cd = pc.reason_for_consent_cd,
    reply->consents[count].consent_received_dt_tm = pc.consent_received_dt_tm, reply->consents[count]
    .conreceived_tm_ind = pc.consent_received_tm_ind
   WITH nocounter, outerjoin = d1, outerjoin = d2
  ;end select
 ELSE
  CALL echo(build("Request->ConsentID = 0"))
  CALL echo(" LOCATOR 2")
  IF ((request->regid != 0))
   CALL echo(build("Request->RegID = ",request->regid))
   CALL echo(" LOCATOR 3")
   SELECT INTO "nl:"
    pc.*, p.name_full_formatted
    FROM pt_reg_consent_reltn rltn,
     pt_consent pc,
     person p,
     dummyt d1,
     dummyt d2,
     organization orgc
    PLAN (rltn
     WHERE (rltn.reg_id=request->regid))
     JOIN (pc
     WHERE pc.consent_id=rltn.consent_id
      AND pc.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND parser(whr1)
      AND parser(whr2))
     JOIN (d1)
     JOIN (p
     WHERE p.person_id=pc.consenting_person_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (d2)
     JOIN (orgc
     WHERE orgc.organization_id=pc.consenting_organization_id
      AND orgc.active_ind=1
      AND orgc.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND orgc.end_effective_dt_tm >= cnvtdatetime(sysdate))
    DETAIL
     count += 1, stat = alterlist(reply->consents,count), reply->consents[count].
     ct_document_version_id = pc.ct_document_version_id,
     reply->consents[count].person_id = pc.person_id, reply->consents[count].prot_amendment_id = pc
     .prot_amendment_id, reply->consents[count].not_returned_reason_cd = pc.not_returned_reason_cd,
     reply->consents[count].not_returned_dt_tm = pc.not_returned_dt_tm, reply->consents[count].
     notreturned_tm_ind = pc.not_returned_tm_ind, reply->consents[count].consent_released_dt_tm = pc
     .consent_released_dt_tm,
     reply->consents[count].conissued_tm_ind = pc.consent_released_tm_ind, reply->consents[count].
     pt_consent_id = pc.pt_consent_id, reply->consents[count].consent_id = pc.consent_id,
     reply->consents[count].connbr = pc.consent_nbr, reply->consents[count].conupdtcnt = pc.updt_cnt,
     reply->consents[count].consenting_person_id = pc.consenting_person_id,
     reply->consents[count].consenting_person_name = p.name_full_formatted, reply->consents[count].
     consenting_organization_id = pc.consenting_organization_id, reply->consents[count].
     consenting_organization_name = orgc.org_name,
     reply->consents[count].consent_signed_dt_tm = cnvtdatetime(pc.consent_signed_dt_tm), reply->
     consents[count].consigned_tm_ind = pc.consent_signed_tm_ind, reply->consents[count].
     reason_for_consent_cd = pc.reason_for_consent_cd,
     reply->consents[count].consent_received_dt_tm = pc.consent_received_dt_tm, reply->consents[count
     ].conreceived_tm_ind = pc.consent_received_tm_ind
    WITH nocounter, outerjoin = d1
   ;end select
  ELSE
   CALL echo(build("request->RegID = 0"))
   CALL echo(" LOCATOR 4")
   IF ((request->eligid != 0))
    CALL echo(build("Request->EligID = ",request->eligid))
    CALL echo(" LOCATOR 5")
    SELECT INTO "nl:"
     pc.*, p.name_full_formatted
     FROM pt_elig_consent_reltn rltn,
      pt_consent pc,
      person p,
      dummyt d1,
      dummyt d2,
      organization orgc
     PLAN (rltn
      WHERE (rltn.pt_elig_tracking_id=request->eligid))
      JOIN (pc
      WHERE pc.consent_id=rltn.consent_id
       AND pc.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND parser(whr1)
       AND parser(whr2))
      JOIN (d1)
      JOIN (p
      WHERE p.person_id=pc.consenting_person_id
       AND p.active_ind=1
       AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
      JOIN (d2)
      JOIN (orgc
      WHERE orgc.organization_id=pc.consenting_organization_id
       AND orgc.active_ind=1
       AND orgc.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND orgc.end_effective_dt_tm >= cnvtdatetime(sysdate))
     DETAIL
      count += 1, stat = alterlist(reply->consents,count), reply->consents[count].
      ct_document_version_id = pc.ct_document_version_id,
      reply->consents[count].person_id = pc.person_id, reply->consents[count].prot_amendment_id = pc
      .prot_amendment_id, reply->consents[count].not_returned_reason_cd = pc.not_returned_reason_cd,
      reply->consents[count].not_returned_dt_tm = pc.not_returned_dt_tm, reply->consents[count].
      notreturned_tm_ind = pc.not_returned_tm_ind, reply->consents[count].consent_released_dt_tm = pc
      .consent_released_dt_tm,
      reply->consents[count].conissued_tm_ind = pc.consent_released_tm_ind, reply->consents[count].
      pt_consent_id = pc.pt_consent_id, reply->consents[count].consent_id = pc.consent_id,
      reply->consents[count].connbr = pc.consent_nbr, reply->consents[count].conupdtcnt = pc.updt_cnt,
      reply->consents[count].consenting_person_id = pc.consenting_person_id,
      reply->consents[count].consenting_person_name = p.name_full_formatted, reply->consents[count].
      consenting_organization_id = pc.consenting_organization_id, reply->consents[count].
      consenting_organization_name = orgc.org_name,
      reply->consents[count].consent_signed_dt_tm = cnvtdatetime(pc.consent_signed_dt_tm), reply->
      consents[count].consigned_tm_ind = pc.consent_signed_tm_ind, reply->consents[count].
      reason_for_consent_cd = pc.reason_for_consent_cd,
      reply->consents[count].consent_received_dt_tm = pc.consent_received_dt_tm, reply->consents[
      count].conreceived_tm_ind = pc.consent_received_tm_ind
     WITH nocounter, outerjoin = d1
    ;end select
   ELSE
    IF ((request->amendmentid != 0))
     CALL echo(" LOCATOR 6")
     CALL echo(build("Request->EligID = 0 AND Request->RegID = 0"))
     CALL echo(build("Request->PersonID = ",request->personid))
     CALL echo(build("Request->ProtID = ",request->protid))
     CALL echo(build("Request->AmendmentID = ",request->amendmentid))
     SELECT INTO "nl:"
      pc.*, p.name_full_formatted
      FROM pt_consent pc,
       person p,
       dummyt d1,
       dummyt d2,
       organization orgc
      PLAN (pc
       WHERE (pc.person_id=request->personid)
        AND pc.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (pc.prot_amendment_id=request->amendmentid)
        AND parser(whr2))
       JOIN (d1)
       JOIN (p
       WHERE p.person_id=pc.consenting_person_id
        AND p.active_ind=1
        AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
       JOIN (d2)
       JOIN (orgc
       WHERE orgc.organization_id=pc.consenting_organization_id
        AND orgc.active_ind=1
        AND orgc.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND orgc.end_effective_dt_tm >= cnvtdatetime(sysdate))
      DETAIL
       count += 1, stat = alterlist(reply->consents,count), reply->consents[count].
       ct_document_version_id = pc.ct_document_version_id,
       reply->consents[count].person_id = pc.person_id, reply->consents[count].prot_amendment_id = pc
       .prot_amendment_id, reply->consents[count].not_returned_reason_cd = pc.not_returned_reason_cd,
       reply->consents[count].not_returned_dt_tm = pc.not_returned_dt_tm, reply->consents[count].
       notreturned_tm_ind = pc.not_returned_tm_ind, reply->consents[count].consent_released_dt_tm =
       pc.consent_released_dt_tm,
       reply->consents[count].conissued_tm_ind = pc.consent_released_tm_ind, reply->consents[count].
       pt_consent_id = pc.pt_consent_id, reply->consents[count].consent_id = pc.consent_id,
       reply->consents[count].connbr = pc.consent_nbr, reply->consents[count].conupdtcnt = pc
       .updt_cnt, reply->consents[count].consenting_person_id = pc.consenting_person_id,
       reply->consents[count].consenting_person_name = p.name_full_formatted, reply->consents[count].
       consenting_organization_id = pc.consenting_organization_id, reply->consents[count].
       consenting_organization_name = orgc.org_name,
       reply->consents[count].consent_signed_dt_tm = cnvtdatetime(pc.consent_signed_dt_tm), reply->
       consents[count].consigned_tm_ind = pc.consent_signed_tm_ind, reply->consents[count].
       reason_for_consent_cd = pc.reason_for_consent_cd,
       reply->consents[count].consent_received_dt_tm = pc.consent_received_dt_tm, reply->consents[
       count].conreceived_tm_ind = pc.consent_received_tm_ind
      WITH nocounter, outerjoin = d1
     ;end select
    ELSE
     CALL echo(" LOCATOR 7")
     CALL echo(build("Request->EligID = 0 AND Request->RegID = 0"))
     CALL echo(build("Request->PersonID = ",request->personid))
     CALL echo(build("Request->ProtID = ",request->protid))
     CALL echo(build("Request->AmendmentID = ",request->amendmentid))
     SELECT INTO "nl:"
      pc.*, p.name_full_formatted
      FROM prot_master pr_m,
       prot_amendment pr_am,
       pt_consent pc,
       person p,
       dummyt d1,
       dummyt d2,
       organization orgc
      PLAN (pr_m
       WHERE (pr_m.prot_master_id=request->protid))
       JOIN (pr_am
       WHERE pr_am.prot_master_id=pr_m.prot_master_id)
       JOIN (pc
       WHERE pc.prot_amendment_id=pr_am.prot_amendment_id
        AND (pc.person_id=request->personid)
        AND pc.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND parser(whr2)
        AND  NOT (pc.consent_id IN (
       (SELECT
        rltn.consent_id
        FROM pt_reg_consent_reltn rltn,
         pt_prot_reg reg
        WHERE rltn.reg_id=reg.reg_id
         AND reg.off_study_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")
         AND reg.end_effective_dt_tm >= cnvtdatetime(sysdate)
         AND (reg.person_id=request->personid)
         AND (reg.prot_master_id=request->protid)))))
       JOIN (d1)
       JOIN (p
       WHERE p.person_id=pc.consenting_person_id
        AND p.active_ind=1
        AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
       JOIN (d2)
       JOIN (orgc
       WHERE orgc.organization_id=pc.consenting_organization_id
        AND orgc.active_ind=1
        AND orgc.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND orgc.end_effective_dt_tm >= cnvtdatetime(sysdate))
      DETAIL
       count += 1,
       CALL echo(build("Count = ",count)), stat = alterlist(reply->consents,count),
       reply->consents[count].ct_document_version_id = pc.ct_document_version_id, reply->consents[
       count].person_id = pc.person_id, reply->consents[count].prot_amendment_id = pc
       .prot_amendment_id,
       reply->consents[count].not_returned_reason_cd = pc.not_returned_reason_cd, reply->consents[
       count].not_returned_dt_tm = pc.not_returned_dt_tm, reply->consents[count].notreturned_tm_ind
        = pc.not_returned_tm_ind,
       reply->consents[count].consent_released_dt_tm = pc.consent_released_dt_tm, reply->consents[
       count].conissued_tm_ind = pc.consent_released_tm_ind, reply->consents[count].pt_consent_id =
       pc.pt_consent_id,
       reply->consents[count].consent_id = pc.consent_id, reply->consents[count].connbr = pc
       .consent_nbr, reply->consents[count].conupdtcnt = pc.updt_cnt,
       reply->consents[count].consenting_person_id = pc.consenting_person_id, reply->consents[count].
       consenting_person_name = p.name_full_formatted, reply->consents[count].
       consenting_organization_id = pc.consenting_organization_id,
       reply->consents[count].consenting_organization_name = orgc.org_name, reply->consents[count].
       consent_signed_dt_tm = cnvtdatetime(pc.consent_signed_dt_tm), reply->consents[count].
       consigned_tm_ind = pc.consent_signed_tm_ind,
       reply->consents[count].reason_for_consent_cd = pc.reason_for_consent_cd, reply->consents[count
       ].consent_received_dt_tm = pc.consent_received_dt_tm, reply->consents[count].
       conreceived_tm_ind = pc.consent_received_tm_ind
      WITH nocounter, outerjoin = d1
     ;end select
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF ((request->protid != 0))
  SET activeamdnbr = 0
  SET activeamdid = 0
  SET activerevisionind = 0
  SET activerevisionnbrtxt = ""
  SET pmid = request->protid
  EXECUTE ct_get_active_a_nbr
  SET reply->activeamendid = activeamdid
  SET reply->activeamendnbr = activeamdnbr
  SET reply->activerevisionind = activerevisionind
  SET reply->activerevisionnbrtxt = activerevisionnbrtxt
  SET highestamdnbr = 0
  SET highestamdid = 0
  SET pmid = request->protid
  EXECUTE ct_get_highest_a_nbr
  SET reply->highestamendid = highestamdid
  SET reply->highestamendnbr = highestamdnbr
 ENDIF
 FOR (i = 1 TO count)
  CALL echo(build("Consent Id: ",reply->consents[i].pt_consent_id))
  CALL echo(build("Consenting Person:",reply->consents[i].consenting_person_name))
 ENDFOR
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSEIF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo(build("Status: ",reply->status_data.status))
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd += 1
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
