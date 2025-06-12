CREATE PROGRAM bed_get_trans_serv_details:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 facilities[*]
      2 facility_cd = f8
      2 organization_id = f8
      2 defined_ind = i2
      2 transaction_services[*]
        3 transaction_service_cd = f8
        3 user_name = vc
        3 password = vc
        3 payers[*]
          4 payer_id = f8
          4 display = vc
        3 alternate_payers[*]
          4 payer_id = f8
          4 display = vc
        3 transaction_urls[*]
          4 transaction_cdf = vc
          4 transaction_url = vc
        3 trans_automated_msg_details
          4 partner_id = vc
          4 sftp_location = vc
          4 folder_location = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE bed_is_logical_domain(dummyvar=i2) = i2
 DECLARE bed_get_logical_domain(dummyvar=i2) = f8
 SUBROUTINE bed_is_logical_domain(dummyvar)
   RETURN(checkprg("ACM_GET_CURR_LOGICAL_DOMAIN"))
 END ;Subroutine
 SUBROUTINE bed_get_logical_domain(dummyvar)
  IF (bed_is_logical_domain(null))
   IF (validate(ld_concept_person)=0)
    DECLARE ld_concept_person = i2 WITH public, constant(1)
   ENDIF
   IF (validate(ld_concept_prsnl)=0)
    DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
   ENDIF
   IF (validate(ld_concept_organization)=0)
    DECLARE ld_concept_organization = i2 WITH public, constant(3)
   ENDIF
   IF (validate(ld_concept_healthplan)=0)
    DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
   ENDIF
   IF (validate(ld_concept_alias_pool)=0)
    DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
   ENDIF
   IF (validate(ld_concept_minvalue)=0)
    DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
   ENDIF
   IF (validate(ld_concept_maxvalue)=0)
    DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
   ENDIF
   RECORD acm_get_curr_logical_domain_req(
     1 concept = i4
   )
   RECORD acm_get_curr_logical_domain_rep(
     1 logical_domain_id = f8
     1 status_block
       2 status_ind = i2
       2 error_code = i4
   )
   SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
   EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
   replace("REPLY",acm_get_curr_logical_domain_rep)
   IF ( NOT (acm_get_curr_logical_domain_rep->status_block.status_ind)
    AND checkfun("BEDERROR"))
    CALL bederror(build("Logical Domain Error: ",acm_get_curr_logical_domain_rep->status_block.
      error_code))
   ENDIF
   RETURN(acm_get_curr_logical_domain_rep->logical_domain_id)
  ENDIF
  RETURN(null)
 END ;Subroutine
 DECLARE request_size = i4 WITH protect, constant(size(request->facilities,5))
 DECLARE logical_domain_id = f8 WITH protect, constant(bed_get_logical_domain(0))
 DECLARE increase_list_amount = i4 WITH protect, constant(10)
 DECLARE cs48active = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE facility_count = i4 WITH protect, noconstant(0)
 DECLARE transaction_service_count = i4 WITH protect, noconstant(0)
 DECLARE payer_count = i4 WITH protect, noconstant(0)
 DECLARE alt_payer_count = i4 WITH protect, noconstant(0)
 DECLARE transaction_url_count = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 IF (request_size > 0)
  SET stat = alterlist(reply->facilities,request_size)
  FOR (x = 1 TO request_size)
    SET reply->facilities[x].facility_cd = request->facilities[x].facility_cd
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = request_size),
    location loc,
    org_trans_ident oti
   PLAN (d)
    JOIN (loc
    WHERE (loc.location_cd=request->facilities[d.seq].facility_cd)
     AND loc.active_ind=1
     AND loc.active_status_cd=cs48active)
    JOIN (oti
    WHERE oti.logical_domain_id=logical_domain_id
     AND oti.organization_id=loc.organization_id)
   DETAIL
    reply->facilities[d.seq].defined_ind = 1, reply->facilities[d.seq].organization_id = oti
    .organization_id
   WITH nocounter
  ;end select
  CALL bederrorcheck(
   "FACORGDETAIL ERROR: Error getting defined indicator and org id for selected facility.")
  IF ((request->return_transactions_ind=1))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = request_size),
     org_trans_ident oti,
     org_trans_payer_reltn otpr,
     organization o1,
     organization o2,
     org_trans_url_reltn otur,
     org_trans_ident_auto_msg otiam
    PLAN (d)
     JOIN (oti
     WHERE oti.logical_domain_id=logical_domain_id
      AND (oti.organization_id=reply->facilities[d.seq].organization_id))
     JOIN (otpr
     WHERE otpr.org_trans_ident_id=outerjoin(oti.org_trans_ident_id))
     JOIN (o1
     WHERE o1.organization_id=outerjoin(otpr.payer_org_id))
     JOIN (o2
     WHERE o2.organization_id=outerjoin(otpr.alt_payer_org_id))
     JOIN (otur
     WHERE otur.org_trans_ident_id=outerjoin(oti.org_trans_ident_id))
     JOIN (otiam
     WHERE otiam.org_trans_ident_id=outerjoin(oti.org_trans_ident_id))
    ORDER BY d.seq, oti.organization_id, oti.transaction_type_cd,
     o1.organization_id, o2.organization_id, otur.transaction_url_cd
    HEAD oti.organization_id
     facility_count = (facility_count+ 1), stat = alterlist(reply->facilities[facility_count].
      transaction_services,increase_list_amount)
    HEAD oti.transaction_type_cd
     IF (oti.transaction_type_cd > 0.0)
      transaction_service_count = (transaction_service_count+ 1)
      IF (mod(transaction_service_count,increase_list_amount))
       stat = alterlist(reply->facilities[facility_count].transaction_services,(
        transaction_service_count+ increase_list_amount))
      ENDIF
      reply->facilities[facility_count].transaction_services[transaction_service_count].
      transaction_service_cd = oti.transaction_type_cd, reply->facilities[facility_count].
      transaction_services[transaction_service_count].user_name = oti.org_username, reply->
      facilities[facility_count].transaction_services[transaction_service_count].password = oti
      .org_passkey,
      stat = alterlist(reply->facilities[facility_count].transaction_services[
       transaction_service_count].payers,increase_list_amount), stat = alterlist(reply->facilities[
       facility_count].transaction_services[transaction_service_count].alternate_payers,
       increase_list_amount), stat = alterlist(reply->facilities[facility_count].
       transaction_services[transaction_service_count].transaction_urls,increase_list_amount)
     ENDIF
    HEAD o1.organization_id
     IF (o1.organization_id > 0)
      payer_count = (payer_count+ 1)
      IF (mod(payer_count,increase_list_amount))
       stat = alterlist(reply->facilities[facility_count].transaction_services[
        transaction_service_count].payers,(payer_count+ increase_list_amount))
      ENDIF
      reply->facilities[facility_count].transaction_services[transaction_service_count].payers[
      payer_count].payer_id = o1.organization_id, reply->facilities[facility_count].
      transaction_services[transaction_service_count].payers[payer_count].display = o1.org_name
     ENDIF
    HEAD o2.organization_id
     IF (o2.organization_id > 0)
      alt_payer_count = (alt_payer_count+ 1)
      IF (mod(alt_payer_count,increase_list_amount))
       stat = alterlist(reply->facilities[facility_count].transaction_services[
        transaction_service_count].alternate_payers,(alt_payer_count+ increase_list_amount))
      ENDIF
      reply->facilities[facility_count].transaction_services[transaction_service_count].
      alternate_payers[alt_payer_count].payer_id = o2.organization_id, reply->facilities[
      facility_count].transaction_services[transaction_service_count].alternate_payers[
      alt_payer_count].display = o2.org_name
     ENDIF
    HEAD otur.transaction_url_cd
     IF (otur.transaction_url_cd > 0.0)
      transaction_url_count = (transaction_url_count+ 1)
      IF (mod(transaction_url_count,increase_list_amount))
       stat = alterlist(reply->facilities[facility_count].transaction_services[
        transaction_service_count].transaction_urls,(transaction_url_count+ increase_list_amount))
      ENDIF
      reply->facilities[facility_count].transaction_services[transaction_service_count].
      transaction_urls[transaction_url_count].transaction_cdf = uar_get_code_meaning(otur
       .transaction_url_cd), reply->facilities[facility_count].transaction_services[
      transaction_service_count].transaction_urls[transaction_url_count].transaction_url = otur
      .transaction_url_text
     ENDIF
    HEAD otiam.org_trans_ident_auto_msg_id
     IF (otiam.org_trans_ident_auto_msg_id > 0.0)
      reply->facilities[facility_count].transaction_services[transaction_service_count].
      trans_automated_msg_details.partner_id = otiam.org_partner_ident, reply->facilities[
      facility_count].transaction_services[transaction_service_count].trans_automated_msg_details.
      sftp_location = otiam.org_sftp_location_path, reply->facilities[facility_count].
      transaction_services[transaction_service_count].trans_automated_msg_details.folder_location =
      otiam.org_folder_location_path
     ENDIF
    FOOT  oti.transaction_type_cd
     stat = alterlist(reply->facilities[facility_count].transaction_services[
      transaction_service_count].payers,payer_count), stat = alterlist(reply->facilities[
      facility_count].transaction_services[transaction_service_count].alternate_payers,
      alt_payer_count), payer_count = 0,
     alt_payer_count = 0, transaction_url_count = 0
    FOOT  otur.transaction_url_cd
     stat = alterlist(reply->facilities[facility_count].transaction_services[
      transaction_service_count].transaction_urls,transaction_url_count)
    FOOT  oti.organization_id
     stat = alterlist(reply->facilities[facility_count].transaction_services,
      transaction_service_count), transaction_service_count = 0
    WITH nocounter
   ;end select
   CALL bederrorcheck("TRANSERVDETAIL ERROR: Error getting details for selected facility/service.")
  ENDIF
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
