CREATE PROGRAM dcp_get_contact_info:dba
 FREE RECORD reply
 RECORD reply(
   1 contact_info[*]
     2 person_name = vc
     2 role_name = vc
     2 organization_name = vc
     2 phone_num = vc
     2 pager_num = vc
     2 email_addr = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE bus_phone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 DECLARE pager_bus_phone_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"PAGER BUS"))
 DECLARE active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE prot_amend_id = f8 WITH protect, noconstant(0.0)
 DECLARE person_id = f8 WITH protect, noconstant(0.0)
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF ((request->prot_master_id > 0))
  SELECT
   pm.prot_master_id, pa.prot_master_id, pa.amendment_dt_tm,
   pa.prot_amendment_id, pr.prot_amendment_id, pr.primary_contact_ind,
   pr.end_effective_dt_tm, pr.person_id, p.person_id,
   pr.organization_id, o.organization_id
   FROM prot_master pm,
    prot_amendment pa,
    prot_role pr,
    organization o,
    prsnl p
   PLAN (pm
    WHERE (pm.prot_master_id=request->prot_master_id))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_status_cd=pm.prot_status_cd
     AND pa.amendment_dt_tm <= cnvtdatetime(curdate,curtime3))
    JOIN (pr
    WHERE pr.prot_amendment_id=pa.prot_amendment_id
     AND pr.primary_contact_ind=1
     AND pr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE p.person_id=pr.person_id)
    JOIN (o
    WHERE o.organization_id=outerjoin(pr.organization_id))
   DETAIL
    stat = alterlist(reply->contact_info,1), reply->contact_info[1].person_name = trim(p
     .name_full_formatted), reply->contact_info[1].role_name = trim(uar_get_code_display(pr
      .prot_role_cd)),
    reply->contact_info[1].organization_name = trim(o.org_name), reply->contact_info[1].email_addr =
    trim(p.email), person_id = p.person_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL report_failure("SELECT","Z","DCP_GET_CONTACT_INFO",
    "Did not find the primary contact for the protocol.")
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM phone ph
   WHERE ph.parent_entity_id=person_id
    AND ph.parent_entity_name="PERSON"
    AND ((ph.phone_type_cd=pager_bus_phone_cd) OR (ph.phone_type_cd=bus_phone_cd))
    AND ph.active_ind=1
    AND ph.active_status_cd=active_cd
   DETAIL
    IF (ph.phone_type_cd=pager_bus_phone_cd)
     reply->contact_info[1].pager_num = cnvtphone(ph.phone_num,ph.phone_format_cd)
    ELSEIF (ph.phone_type_cd=bus_phone_cd)
     reply->contact_info[1].phone_num = cnvtphone(ph.phone_num,ph.phone_format_cd)
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  CALL report_failure("REQUEST","Z","DCP_GET_CONTACT_INFO",
   "Request person_id or prot_master_id are not > 0")
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   IF (opstatus="F")
    SET failed = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
 SET cstatus = "S"
#exit_script
 SET reply->status_data.status = cstatus
 CALL echorecord(reply)
END GO
