CREATE PROGRAM ct_get_contact_info:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 contact_info[*]
      2 prot_amendment_id = f8
      2 prot_master_id = f8
      2 person_id = f8
      2 prot_role_id = f8
      2 person_name = vc
      2 role_name = vc
      2 organization_name = vc
      2 phone_num = vc
      2 pager_num = vc
      2 email_addr = vc
      2 alphapager = vc
    1 primary_contacts[*]
      2 primary_contact_info[*]
        3 prot_amendment_id = f8
        3 prot_master_id = f8
        3 person_id = f8
        3 prot_role_id = f8
        3 person_name = vc
        3 role_name = vc
        3 organization_name = vc
        3 phone_num = vc
        3 pager_num = vc
        3 email_addr = vc
        3 alphapager = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE bus_phone_cd = f8 WITH protect, noconstant(0.0)
 DECLARE alpha_phone_cd = f8 WITH protect, noconstant(0.0)
 DECLARE primary_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prot_size = i2 WITH protect, noconstant(0)
 DECLARE email_source = i2 WITH protect, noconstant(0)
 DECLARE contactcountcntr = i2 WITH protect, noconstant(0)
 DECLARE contactcount = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE aplphapager_cd = f8 WITH constant(uar_get_code_by("MEANING",212,"ALPHAPAGER"))
 DECLARE email_cd = f8 WITH constant(uar_get_code_by("MEANING",212,"EMAIL"))
 DECLARE protamendmentid = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET prot_size = size(request->protocols,5)
 SET stat = uar_get_meaning_by_codeset(43,"BUSINESS",1,bus_phone_cd)
 SET stat = uar_get_meaning_by_codeset(43,"PAGER BUS",1,alpha_phone_cd)
 RECORD ct_get_pref_request(
   1 pref_entry = vc
 )
 RECORD ct_get_pref_reply(
   1 pref_value = i4
   1 pref_values[*]
     2 values = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET ct_get_pref_request->pref_entry = "email_address_source"
 EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","CT_GET_PREF_REQUEST"), replace("REPLY",
  "CT_GET_PREF_REPLY")
 SET email_source = ct_get_pref_reply->pref_value
 CALL echo(build("email source: ",email_source))
 IF ((request->person_id > 0))
  SELECT INTO "nl:"
   pr.*
   FROM prsnl p
   PLAN (p
    WHERE (p.person_id=request->person_id))
   DETAIL
    stat = alterlist(reply->contact_info,1), reply->contact_info[1].person_id = p.person_id, reply->
    contact_info[1].person_name = p.name_full_formatted
    IF (email_source=0)
     reply->contact_info[1].email_addr = p.email
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL report_failure("SELECT","Z","CT_GET_CONTACT_INFO",
    "Did not find the contact information for this person..")
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   ph.*
   FROM phone ph
   PLAN (ph
    WHERE (ph.parent_entity_id=request->person_id)
     AND ph.parent_entity_name="PERSON"
     AND ((ph.phone_type_cd=alpha_phone_cd) OR (ph.phone_type_cd=bus_phone_cd))
     AND ph.active_ind=1)
   DETAIL
    IF (ph.phone_type_cd=alpha_phone_cd)
     reply->contact_info[1].pager_num = cnvtphone(ph.phone_num,ph.phone_format_cd)
    ELSEIF (ph.phone_type_cd=bus_phone_cd)
     reply->contact_info[1].phone_num = cnvtphone(ph.phone_num,ph.phone_format_cd)
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM address a
   PLAN (a
    WHERE a.parent_entity_name="PERSON"
     AND a.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND (a.parent_entity_id=request->person_id)
     AND a.address_type_cd=aplphapager_cd)
   DETAIL
    reply->contact_info[1].alphapager = a.street_addr
   WITH nocounter
  ;end select
  IF (email_source=1)
   SELECT INTO "nl:"
    FROM address a
    PLAN (a
     WHERE a.parent_entity_name="PERSON"
      AND a.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND (a.parent_entity_id=request->person_id)
      AND a.address_type_cd=email_cd
      AND a.address_type_seq=1)
    DETAIL
     reply->contact_info[1].email_addr = a.street_addr
    WITH nocounter
   ;end select
  ENDIF
 ELSEIF (prot_size > 0)
  SET stat = alterlist(reply->primary_contacts,prot_size)
  FOR (index = 1 TO prot_size)
    SET contactcount = 0
    IF ((request->protocols[index].prot_amendment_id=0))
     CALL echo("Request from PowerChart")
     SELECT INTO "nl:"
      pa.*
      FROM prot_amendment pa
      PLAN (pa
       WHERE (pa.prot_master_id=request->protocols[index].prot_master_id)
        AND pa.amendment_dt_tm <= cnvtdatetime(sysdate))
      ORDER BY pa.amendment_dt_tm, pa.amendment_nbr
      DETAIL
       protamendmentid = pa.prot_amendment_id
      WITH nocounter
     ;end select
    ELSE
     CALL echo("Request from POM")
     SET protamendmentid = request->protocols[index].prot_amendment_id
    ENDIF
    SELECT INTO "nl:"
     pr.*
     FROM prot_role pr,
      organization o,
      prsnl p
     PLAN (pr
      WHERE pr.prot_amendment_id=protamendmentid
       AND pr.primary_contact_ind=1
       AND pr.primary_contact_rank_nbr > 0
       AND pr.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (p
      WHERE p.person_id=pr.person_id)
      JOIN (o
      WHERE o.organization_id=pr.organization_id)
     ORDER BY pr.primary_contact_rank_nbr, p.name_last, p.name_first
     HEAD REPORT
      contactcount = 0
     DETAIL
      contactcount += 1
      IF (mod(contactcount,10)=1)
       stat = alterlist(reply->primary_contacts[index].primary_contact_info,(contactcount+ 9))
      ENDIF
      reply->primary_contacts[index].primary_contact_info[contactcount].prot_amendment_id = pr
      .prot_amendment_id, reply->primary_contacts[index].primary_contact_info[contactcount].
      prot_master_id = request->protocols[index].prot_master_id, reply->primary_contacts[index].
      primary_contact_info[contactcount].person_id = p.person_id,
      reply->primary_contacts[index].primary_contact_info[contactcount].prot_role_id = pr
      .prot_role_id, reply->primary_contacts[index].primary_contact_info[contactcount].person_name =
      p.name_full_formatted, reply->primary_contacts[index].primary_contact_info[contactcount].
      role_name = uar_get_code_display(pr.prot_role_cd),
      reply->primary_contacts[index].primary_contact_info[contactcount].organization_name = o
      .org_name
      IF (email_source=0)
       reply->primary_contacts[index].primary_contact_info[contactcount].email_addr = p.email
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->primary_contacts[index].primary_contact_info,contactcount),
      contactcountcntr = contactcount
     WITH nocounter
    ;end select
    CALL echo(contactcount)
    CALL echo("RankDefined")
    SELECT INTO "nl:"
     pr.*
     FROM prot_role pr,
      organization o,
      prsnl p
     PLAN (pr
      WHERE pr.prot_amendment_id=protamendmentid
       AND pr.primary_contact_ind=1
       AND pr.primary_contact_rank_nbr=0
       AND pr.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (p
      WHERE p.person_id=pr.person_id)
      JOIN (o
      WHERE o.organization_id=pr.organization_id)
     ORDER BY pr.primary_contact_rank_nbr, p.name_last, p.name_first
     HEAD REPORT
      stat = alterlist(reply->primary_contacts[index].primary_contact_info,(contactcountcntr+ 10))
     DETAIL
      contactcountcntr += 1
      IF (mod(contactcountcntr,10)=1)
       stat = alterlist(reply->primary_contacts[index].primary_contact_info,(contactcountcntr+ 9))
      ENDIF
      reply->primary_contacts[index].primary_contact_info[contactcountcntr].prot_amendment_id = pr
      .prot_amendment_id, reply->primary_contacts[index].primary_contact_info[contactcountcntr].
      prot_master_id = request->protocols[index].prot_master_id, reply->primary_contacts[index].
      primary_contact_info[contactcountcntr].person_id = p.person_id,
      reply->primary_contacts[index].primary_contact_info[contactcountcntr].prot_role_id = pr
      .prot_role_id, reply->primary_contacts[index].primary_contact_info[contactcountcntr].
      person_name = p.name_full_formatted, reply->primary_contacts[index].primary_contact_info[
      contactcountcntr].role_name = uar_get_code_display(pr.prot_role_cd),
      reply->primary_contacts[index].primary_contact_info[contactcountcntr].organization_name = o
      .org_name
      IF (email_source=0)
       reply->primary_contacts[index].primary_contact_info[contactcountcntr].email_addr = p.email
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->primary_contacts[index].primary_contact_info,contactcountcntr)
     WITH nocounter
    ;end select
    CALL echo(contactcountcntr)
    CALL echo("RankNOTDefined")
    IF (contactcountcntr > 0)
     FOR (count = 1 TO contactcountcntr)
       SELECT INTO "nl:"
        ph.*
        FROM phone ph
        PLAN (ph
         WHERE (ph.parent_entity_id=reply->primary_contacts[index].primary_contact_info[count].
         person_id)
          AND ph.parent_entity_name="PERSON"
          AND ((ph.phone_type_cd=alpha_phone_cd) OR (ph.phone_type_cd=bus_phone_cd))
          AND ph.active_ind=1)
        DETAIL
         IF (ph.phone_type_cd=alpha_phone_cd)
          reply->primary_contacts[index].primary_contact_info[count].pager_num = cnvtphone(ph
           .phone_num,ph.phone_format_cd)
         ELSEIF (ph.phone_type_cd=bus_phone_cd)
          reply->primary_contacts[index].primary_contact_info[count].phone_num = cnvtphone(ph
           .phone_num,ph.phone_format_cd)
         ENDIF
        WITH nocounter
       ;end select
       SELECT INTO "nl:"
        FROM address a
        PLAN (a
         WHERE a.parent_entity_name="PERSON"
          AND a.end_effective_dt_tm > cnvtdatetime(sysdate)
          AND (a.parent_entity_id=reply->primary_contacts[index].primary_contact_info[count].
         person_id)
          AND a.address_type_cd=aplphapager_cd)
        DETAIL
         reply->primary_contacts[index].primary_contact_info[count].alphapager = a.street_addr
        WITH nocounter
       ;end select
       IF (email_source=1)
        SELECT INTO "nl:"
         FROM address a
         PLAN (a
          WHERE a.parent_entity_name="PERSON"
           AND a.end_effective_dt_tm > cnvtdatetime(sysdate)
           AND (a.parent_entity_id=reply->primary_contacts[index].primary_contact_info[count].
          person_id)
           AND a.address_type_cd=email_cd
           AND a.address_type_seq=1)
         DETAIL
          reply->primary_contacts[index].primary_contact_info[count].email_addr = a.street_addr
         WITH nocounter
        ;end select
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 GO TO exit_script
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   IF (opstatus="F")
    SET failed = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "004"
 SET mod_date = "Jun 22, 2018"
END GO
