CREATE PROGRAM bed_ens_trans_services:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD temp_request
 RECORD temp_request(
   1 facilities[*]
     2 code_value = f8
     2 organization_id = f8
     2 services[*]
       3 code_value = f8
       3 user_name = vc
       3 password = vc
       3 action_flag = i2
       3 org_trans_ident_id = f8
       3 payers[*]
         4 organization_id = f8
         4 action_flag = i2
         4 org_trans_payer_reltn_id = f8
       3 alternate_payers[*]
         4 organization_id = f8
         4 action_flag = i2
         4 org_trans_payer_reltn_id = f8
       3 transaction_urls[*]
         4 org_trans_url_reltn_id = f8
         4 trans_url_cd = f8
         4 trans_url_text = vc
         4 action_flag = i2
       3 partner_id = vc
       3 sftp_location = vc
       3 folder_location = vc
 )
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
 DECLARE insert_flag = i2 WITH protect, constant(1)
 DECLARE update_flag = i2 WITH protect, constant(2)
 DECLARE delete_flag = i2 WITH protect, constant(3)
 DECLARE logical_domain_id = f8 WITH protect, constant(bed_get_logical_domain(0))
 DECLARE facility_size = i4 WITH protect, constant(size(request->facilities,5))
 DECLARE cs48active = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE org_trans_ident_auto_msg_id = f8 WITH protect
 DECLARE insert_count = i4 WITH protect, noconstant(0)
 DECLARE update_count = i4 WITH protect, noconstant(0)
 DECLARE delete_count = i4 WITH protect, noconstant(0)
 DECLARE placeitemsintemprequest(dummyvar=i2) = null
 DECLARE insertitems(dummyvar=i2) = null
 DECLARE updateitems(dummyvar=i2) = null
 DECLARE deleteitems(dummyvar=i2) = null
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
 IF (facility_size=0)
  GO TO exit_script
 ENDIF
 CALL placeitemsintemprequest(0)
 IF (insert_count > 0)
  CALL insertitems(0)
 ENDIF
 IF (update_count > 0)
  CALL updateitems(0)
 ENDIF
 IF (delete_count > 0)
  CALL deleteitems(0)
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE placeitemsintemprequest(dummyvar)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE found_index = i4 WITH protect, noconstant(0)
   DECLARE service_size = i4 WITH protect, noconstant(0)
   DECLARE payer_size = i4 WITH protect, noconstant(0)
   DECLARE alternate_payer_size = i4 WITH protect, noconstant(0)
   SET stat = alterlist(temp_request->facilities,facility_size)
   FOR (x = 1 TO facility_size)
     SET temp_request->facilities[x].code_value = request->facilities[x].code_value
     SET service_size = size(request->facilities[x].services,5)
     SET stat = alterlist(temp_request->facilities[x].services,service_size)
     FOR (y = 1 TO service_size)
       SET temp_request->facilities[x].services[y].code_value = request->facilities[x].services[y].
       code_value
       SET temp_request->facilities[x].services[y].user_name = request->facilities[x].services[y].
       user_name
       SET temp_request->facilities[x].services[y].password = request->facilities[x].services[y].
       password
       SET temp_request->facilities[x].services[y].partner_id = request->facilities[x].services[y].
       partner_id
       SET temp_request->facilities[x].services[y].sftp_location = request->facilities[x].services[y]
       .sftp_location
       SET temp_request->facilities[x].services[y].folder_location = request->facilities[x].services[
       y].folder_location
       SET payer_size = size(request->facilities[x].services[y].payers,5)
       SET stat = alterlist(temp_request->facilities[x].services[y].payers,payer_size)
       FOR (z = 1 TO payer_size)
        SET temp_request->facilities[x].services[y].payers[z].organization_id = request->facilities[x
        ].services[y].payers[z].organization_id
        SET temp_request->facilities[x].services[y].payers[z].action_flag = insert_flag
       ENDFOR
       SET alternate_payer_size = size(request->facilities[x].services[y].alternate_payers,5)
       SET stat = alterlist(temp_request->facilities[x].services[y].alternate_payers,
        alternate_payer_size)
       FOR (z = 1 TO alternate_payer_size)
        SET temp_request->facilities[x].services[y].alternate_payers[z].organization_id = request->
        facilities[x].services[y].alternate_payers[z].organization_id
        SET temp_request->facilities[x].services[y].alternate_payers[z].action_flag = insert_flag
       ENDFOR
       SET trans_url_size = size(request->facilities[x].services[y].transaction_urls,5)
       SET stat = alterlist(temp_request->facilities[x].services[y].transaction_urls,trans_url_size)
       FOR (z = 1 TO trans_url_size)
         SET temp_request->facilities[x].services[y].transaction_urls[z].trans_url_cd =
         uar_get_code_by("MEANING",4002709,request->facilities[x].services[y].transaction_urls[z].
          trans_url_cdf)
         SET temp_request->facilities[x].services[y].transaction_urls[z].trans_url_text = request->
         facilities[x].services[y].transaction_urls[z].trans_url_text
         SET temp_request->facilities[x].services[y].transaction_urls[z].action_flag = insert_flag
       ENDFOR
     ENDFOR
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = facility_size),
     (dummyt d2  WITH seq = 1),
     location loc,
     org_trans_ident oti
    PLAN (d1
     WHERE maxrec(d2,size(request->facilities[d1.seq].services,5)))
     JOIN (d2)
     JOIN (loc
     WHERE (loc.location_cd=request->facilities[d1.seq].code_value)
      AND loc.organization_id > 0.0
      AND loc.active_ind=1
      AND loc.active_status_cd=cs48active)
     JOIN (oti
     WHERE oti.logical_domain_id=outerjoin(logical_domain_id)
      AND oti.organization_id=outerjoin(loc.organization_id)
      AND oti.transaction_type_cd=outerjoin(request->facilities[d1.seq].services[d2.seq].code_value))
    ORDER BY d1.seq, d2.seq, loc.organization_id,
     oti.transaction_type_cd
    HEAD loc.organization_id
     temp_request->facilities[d1.seq].organization_id = loc.organization_id
    HEAD oti.transaction_type_cd
     temp_request->facilities[d1.seq].services[d2.seq].org_trans_ident_id = oti.org_trans_ident_id
     IF (trim(temp_request->facilities[d1.seq].services[d2.seq].user_name)=""
      AND trim(temp_request->facilities[d1.seq].services[d2.seq].password)=""
      AND trim(temp_request->facilities[d1.seq].services[d2.seq].partner_id)=""
      AND trim(temp_request->facilities[d1.seq].services[d2.seq].sftp_location)=""
      AND trim(temp_request->facilities[d1.seq].services[d2.seq].folder_location)=""
      AND size(temp_request->facilities[d1.seq].services[d2.seq].payers,5)=0
      AND size(temp_request->facilities[d1.seq].services[d2.seq].alternate_payers,5)=0)
      delete_count = (delete_count+ 1)
      IF (oti.org_trans_ident_id > 0.0)
       temp_request->facilities[d1.seq].services[d2.seq].action_flag = delete_flag
      ENDIF
     ELSEIF (oti.org_trans_ident_id=0.0)
      insert_count = (insert_count+ 1), temp_request->facilities[d1.seq].services[d2.seq].action_flag
       = insert_flag
     ELSE
      update_count = (update_count+ 1), temp_request->facilities[d1.seq].services[d2.seq].action_flag
       = update_flag
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("POPTEMPSTRUCT Error: Error when populating the temporary structure.")
   FOR (x = 1 TO facility_size)
     FOR (y = 1 TO size(temp_request->facilities[x].services,5))
       SELECT INTO "nl:"
        FROM org_trans_payer_reltn otpr
        PLAN (otpr
         WHERE (temp_request->facilities[x].services[y].action_flag != insert_flag)
          AND (otpr.org_trans_ident_id=temp_request->facilities[x].services[y].org_trans_ident_id)
          AND otpr.payer_org_id > 0.0)
        ORDER BY otpr.payer_org_id
        DETAIL
         payer_size = size(temp_request->facilities[x].services[y].payers,5), found_index = locateval
         (index,1,payer_size,otpr.payer_org_id,temp_request->facilities[x].services[y].payers[index].
          organization_id)
         IF (found_index=0)
          payer_size = (payer_size+ 1), stat = alterlist(temp_request->facilities[x].services[y].
           payers,payer_size), temp_request->facilities[x].services[y].payers[payer_size].
          organization_id = otpr.payer_org_id,
          temp_request->facilities[x].services[y].payers[payer_size].action_flag = delete_flag,
          temp_request->facilities[x].services[y].payers[payer_size].org_trans_payer_reltn_id = otpr
          .org_trans_payer_reltn_id
         ELSE
          temp_request->facilities[x].services[y].payers[index].action_flag = update_flag,
          temp_request->facilities[x].services[y].payers[index].org_trans_payer_reltn_id = otpr
          .org_trans_payer_reltn_id
         ENDIF
        WITH nocounter
       ;end select
       CALL bederrorcheck(
        "POPTEMPSTRUCTPAY Error: Error when populating the temporary structure's payer list.")
       SELECT INTO "nl:"
        FROM org_trans_payer_reltn otpr
        PLAN (otpr
         WHERE (temp_request->facilities[x].services[y].action_flag != insert_flag)
          AND (otpr.org_trans_ident_id=temp_request->facilities[x].services[y].org_trans_ident_id)
          AND otpr.alt_payer_org_id > 0.0)
        ORDER BY otpr.alt_payer_org_id
        DETAIL
         alternate_payer_size = size(temp_request->facilities[x].services[y].alternate_payers,5),
         found_index = locateval(index,1,alternate_payer_size,otpr.alt_payer_org_id,temp_request->
          facilities[x].services[y].alternate_payers[index].organization_id)
         IF (found_index=0)
          alternate_payer_size = (alternate_payer_size+ 1), stat = alterlist(temp_request->
           facilities[x].services[y].alternate_payers,alternate_payer_size), temp_request->
          facilities[x].services[y].alternate_payers[alternate_payer_size].organization_id = otpr
          .alt_payer_org_id,
          temp_request->facilities[x].services[y].alternate_payers[alternate_payer_size].action_flag
           = delete_flag, temp_request->facilities[x].services[y].alternate_payers[
          alternate_payer_size].org_trans_payer_reltn_id = otpr.org_trans_payer_reltn_id
         ELSE
          temp_request->facilities[x].services[y].alternate_payers[index].action_flag = update_flag,
          temp_request->facilities[x].services[y].alternate_payers[index].org_trans_payer_reltn_id =
          otpr.org_trans_payer_reltn_id
         ENDIF
        WITH nocounter
       ;end select
       CALL bederrorcheck(
        "POPTEMPSTRUCTALTPAY Error: Error when populating the temporary structure's alternate payer list."
        )
       FOR (z = 1 TO size(temp_request->facilities[x].services[y].transaction_urls,5))
         SELECT INTO "nl:"
          FROM org_trans_url_reltn otur
          WHERE (otur.org_trans_ident_id=temp_request->facilities[x].services[y].org_trans_ident_id)
           AND (otur.transaction_url_cd=temp_request->facilities[x].services[y].transaction_urls[z].
          trans_url_cd)
          DETAIL
           IF (textlen(trim(temp_request->facilities[x].services[y].transaction_urls[z].
             trans_url_text)) > 0)
            temp_request->facilities[x].services[y].transaction_urls[z].action_flag = update_flag
           ELSE
            temp_request->facilities[x].services[y].transaction_urls[z].action_flag = delete_flag
           ENDIF
          WITH nocounter
         ;end select
       ENDFOR
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE insertitems(dummyvar)
   FOR (x = 1 TO facility_size)
     FOR (y = 1 TO size(temp_request->facilities[x].services,5))
       IF ((temp_request->facilities[x].services[y].action_flag=insert_flag))
        SELECT INTO "nl:"
         a = seq(organization_seq,nextval)
         FROM dual d
         DETAIL
          temp_request->facilities[x].services[y].org_trans_ident_id = a
         WITH nocounter
        ;end select
        CALL bederrorcheck("ORGSEQ1 Error: Error getting a new id from organization_seq.")
        INSERT  FROM org_trans_ident oti
         SET oti.logical_domain_id = logical_domain_id, oti.org_trans_ident_id = temp_request->
          facilities[x].services[y].org_trans_ident_id, oti.organization_id = temp_request->
          facilities[x].organization_id,
          oti.transaction_type_cd = temp_request->facilities[x].services[y].code_value, oti
          .org_passkey = trim(temp_request->facilities[x].services[y].password), oti
          .org_submitter_ident = trim(temp_request->facilities[x].services[y].user_name),
          oti.org_username = trim(temp_request->facilities[x].services[y].user_name), oti.updt_cnt =
          0, oti.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          oti.updt_id = reqinfo->updt_id, oti.updt_task = reqinfo->updt_task, oti.updt_applctx =
          reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        CALL bederrorcheck("INSERTSERVICE Error: Issue inserting new service relation.")
        IF (trim(temp_request->facilities[x].services[y].partner_id) > ""
         AND trim(temp_request->facilities[x].services[y].sftp_location) > ""
         AND trim(temp_request->facilities[x].services[y].folder_location) > "")
         SELECT INTO "nl:"
          a = seq(organization_seq,nextval)
          FROM dual d
          DETAIL
           org_trans_ident_auto_msg_id = a
          WITH nocounter
         ;end select
         CALL bederrorcheck(
          "ORGSEQ1 Error: Error getting a new id from organization_seq for autom msg service.")
         INSERT  FROM org_trans_ident_auto_msg otiam
          SET otiam.org_trans_ident_auto_msg_id = org_trans_ident_auto_msg_id, otiam
           .org_trans_ident_id = temp_request->facilities[x].services[y].org_trans_ident_id, otiam
           .org_partner_ident = trim(temp_request->facilities[x].services[y].partner_id),
           otiam.org_sftp_location_path = trim(temp_request->facilities[x].services[y].sftp_location),
           otiam.org_folder_location_path = trim(temp_request->facilities[x].services[y].
            folder_location), otiam.updt_cnt = 0,
           otiam.updt_dt_tm = cnvtdatetime(curdate,curtime3), otiam.updt_id = reqinfo->updt_id, otiam
           .updt_task = reqinfo->updt_task,
           otiam.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         CALL bederrorcheck("INSERTAUTOMSGFIELDS Error: Issue inserting Auto Msg fields.")
        ENDIF
        FOR (z = 1 TO size(temp_request->facilities[x].services[y].payers,5))
          SELECT INTO "nl:"
           a = seq(organization_seq,nextval)
           FROM dual d
           DETAIL
            temp_request->facilities[x].services[y].payers[z].org_trans_payer_reltn_id = a
           WITH nocounter
          ;end select
          CALL bederrorcheck("ORGSEQ2 Error: Error getting a new id from organization_seq.")
          INSERT  FROM org_trans_payer_reltn otpr
           SET otpr.org_trans_payer_reltn_id = temp_request->facilities[x].services[y].payers[z].
            org_trans_payer_reltn_id, otpr.org_trans_ident_id = temp_request->facilities[x].services[
            y].org_trans_ident_id, otpr.payer_org_id = temp_request->facilities[x].services[y].
            payers[z].organization_id,
            otpr.updt_cnt = 0, otpr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otpr.updt_id =
            reqinfo->updt_id,
            otpr.updt_task = reqinfo->updt_task, otpr.updt_applctx = reqinfo->updt_applctx
           WITH nocounter
          ;end insert
          CALL bederrorcheck("INSERTPAYER1 Error: Issue inserting new service-payer relation.")
        ENDFOR
        FOR (z = 1 TO size(temp_request->facilities[x].services[y].alternate_payers,5))
          SELECT INTO "nl:"
           a = seq(organization_seq,nextval)
           FROM dual d
           DETAIL
            temp_request->facilities[x].services[y].alternate_payers[z].org_trans_payer_reltn_id = a
           WITH nocounter
          ;end select
          CALL bederrorcheck("ORGSEQ3 Error: Error getting a new id from organization_seq.")
          INSERT  FROM org_trans_payer_reltn otpr
           SET otpr.org_trans_payer_reltn_id = temp_request->facilities[x].services[y].
            alternate_payers[z].org_trans_payer_reltn_id, otpr.org_trans_ident_id = temp_request->
            facilities[x].services[y].org_trans_ident_id, otpr.alt_payer_org_id = temp_request->
            facilities[x].services[y].alternate_payers[z].organization_id,
            otpr.updt_cnt = 0, otpr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otpr.updt_id =
            reqinfo->updt_id,
            otpr.updt_task = reqinfo->updt_task, otpr.updt_applctx = reqinfo->updt_applctx
           WITH nocounter
          ;end insert
          CALL bederrorcheck("INSERTALTPAYER1 Error: Issue inserting new service-alt payer relation."
           )
        ENDFOR
        FOR (z = 1 TO size(temp_request->facilities[x].services[y].transaction_urls,5))
          SELECT INTO "nl:"
           a = seq(organization_seq,nextval)
           FROM dual d
           DETAIL
            temp_request->facilities[x].services[y].transaction_urls[z].org_trans_url_reltn_id = a
           WITH nocounter
          ;end select
          CALL bederrorcheck("ORGSEQ3 Error: Error getting a new id from organization_seq.")
          INSERT  FROM org_trans_url_reltn otur
           SET otur.org_trans_url_reltn_id = temp_request->facilities[x].services[y].
            transaction_urls[z].org_trans_url_reltn_id, otur.org_trans_ident_id = temp_request->
            facilities[x].services[y].org_trans_ident_id, otur.transaction_url_cd = temp_request->
            facilities[x].services[y].transaction_urls[z].trans_url_cd,
            otur.transaction_url_text = temp_request->facilities[x].services[y].transaction_urls[z].
            trans_url_text, otur.active_ind = 1, otur.updt_cnt = 0,
            otur.updt_dt_tm = cnvtdatetime(curdate,curtime3), otur.updt_id = reqinfo->updt_id, otur
            .updt_task = reqinfo->updt_task,
            otur.updt_applctx = reqinfo->updt_applctx, otur.create_dt_tm = cnvtdatetime(curdate,
             curtime3), otur.create_prsnl_id = reqinfo->updt_id
           WITH nocounter
          ;end insert
          CALL bederrorcheck(
           "INSERTTRANSURL1 Error: Issue inserting new org-transaction url relation.")
        ENDFOR
       ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE updateitems(dummyvar)
   FOR (x = 1 TO facility_size)
     FOR (y = 1 TO size(temp_request->facilities[x].services,5))
       IF ((temp_request->facilities[x].services[y].action_flag=update_flag))
        UPDATE  FROM org_trans_ident oti
         SET oti.org_passkey = trim(temp_request->facilities[x].services[y].password), oti
          .org_submitter_ident = trim(temp_request->facilities[x].services[y].user_name), oti
          .org_username = trim(temp_request->facilities[x].services[y].user_name),
          oti.updt_cnt = (oti.updt_cnt+ 1), oti.updt_dt_tm = cnvtdatetime(curdate,curtime3), oti
          .updt_id = reqinfo->updt_id,
          oti.updt_task = reqinfo->updt_task, oti.updt_applctx = reqinfo->updt_applctx
         WHERE (oti.org_trans_ident_id=temp_request->facilities[x].services[y].org_trans_ident_id)
         WITH nocounter
        ;end update
        CALL bederrorcheck("UPDTSERVICE Error: Error updating the org-service relation.")
        IF (trim(temp_request->facilities[x].services[y].partner_id) > ""
         AND trim(temp_request->facilities[x].services[y].sftp_location) > ""
         AND trim(temp_request->facilities[x].services[y].folder_location) > "")
         UPDATE  FROM org_trans_ident_auto_msg otiam
          SET otiam.org_partner_ident = trim(temp_request->facilities[x].services[y].partner_id),
           otiam.org_sftp_location_path = trim(temp_request->facilities[x].services[y].sftp_location),
           otiam.org_folder_location_path = trim(temp_request->facilities[x].services[y].
            folder_location),
           otiam.updt_cnt = (otiam.updt_cnt+ 1), otiam.updt_dt_tm = cnvtdatetime(curdate,curtime3),
           otiam.updt_id = reqinfo->updt_id,
           otiam.updt_task = reqinfo->updt_task, otiam.updt_applctx = reqinfo->updt_applctx
          WHERE (otiam.org_trans_ident_id=temp_request->facilities[x].services[y].org_trans_ident_id)
          WITH nocounter
         ;end update
         CALL bederrorcheck("UPDTAUTOMSG Error: Error updating the auto msg service new fields.")
        ENDIF
        FOR (z = 1 TO size(temp_request->facilities[x].services[y].payers,5))
          IF ((temp_request->facilities[x].services[y].payers[z].action_flag=insert_flag))
           SELECT INTO "nl:"
            a = seq(organization_seq,nextval)
            FROM dual d
            DETAIL
             temp_request->facilities[x].services[y].payers[z].org_trans_payer_reltn_id = a
            WITH nocounter
           ;end select
           CALL bederrorcheck("ORGSEQ4 Error: Error getting a new id from organization_seq.")
           INSERT  FROM org_trans_payer_reltn otpr
            SET otpr.org_trans_payer_reltn_id = temp_request->facilities[x].services[y].payers[z].
             org_trans_payer_reltn_id, otpr.org_trans_ident_id = temp_request->facilities[x].
             services[y].org_trans_ident_id, otpr.payer_org_id = temp_request->facilities[x].
             services[y].payers[z].organization_id,
             otpr.updt_cnt = 0, otpr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otpr.updt_id =
             reqinfo->updt_id,
             otpr.updt_task = reqinfo->updt_task, otpr.updt_applctx = reqinfo->updt_applctx
            WITH nocounter
           ;end insert
           CALL bederrorcheck("INSERTPAYER2 Error: Issue inserting new service-payer relation.")
          ENDIF
          DELETE  FROM org_trans_payer_reltn otpr
           WHERE (temp_request->facilities[x].services[y].payers[z].action_flag=delete_flag)
            AND (otpr.org_trans_payer_reltn_id=temp_request->facilities[x].services[y].payers[z].
           org_trans_payer_reltn_id)
           WITH nocounter
          ;end delete
          CALL bederrorcheck("DELPAYER1 Error: Error while remove a payer relation.")
        ENDFOR
        FOR (z = 1 TO size(temp_request->facilities[x].services[y].alternate_payers,5))
          IF ((temp_request->facilities[x].services[y].alternate_payers[z].action_flag=insert_flag))
           SELECT INTO "nl:"
            a = seq(organization_seq,nextval)
            FROM dual d
            DETAIL
             temp_request->facilities[x].services[y].alternate_payers[z].org_trans_payer_reltn_id = a
            WITH nocounter
           ;end select
           CALL bederrorcheck("ORGSEQ5 Error: Error getting a new id from organization_seq.")
           INSERT  FROM org_trans_payer_reltn otpr
            SET otpr.org_trans_payer_reltn_id = temp_request->facilities[x].services[y].
             alternate_payers[z].org_trans_payer_reltn_id, otpr.org_trans_ident_id = temp_request->
             facilities[x].services[y].org_trans_ident_id, otpr.alt_payer_org_id = temp_request->
             facilities[x].services[y].alternate_payers[z].organization_id,
             otpr.updt_cnt = 0, otpr.updt_dt_tm = cnvtdatetime(curdate,curtime3), otpr.updt_id =
             reqinfo->updt_id,
             otpr.updt_task = reqinfo->updt_task, otpr.updt_applctx = reqinfo->updt_applctx
            WITH nocounter
           ;end insert
           CALL bederrorcheck(
            "INSERTALTPAYER2 Error: Issue inserting new service-alt payer relation.")
          ENDIF
          DELETE  FROM org_trans_payer_reltn otpr
           WHERE (temp_request->facilities[x].services[y].alternate_payers[z].action_flag=delete_flag
           )
            AND (otpr.org_trans_payer_reltn_id=temp_request->facilities[x].services[y].
           alternate_payers[z].org_trans_payer_reltn_id)
           WITH nocounter
          ;end delete
          CALL bederrorcheck("DELALTPAYER1 Error: Error while remove a alternate payer relation.")
        ENDFOR
        FOR (z = 1 TO size(temp_request->facilities[x].services[y].transaction_urls,5))
          IF ((temp_request->facilities[x].services[y].transaction_urls[z].action_flag=update_flag))
           UPDATE  FROM org_trans_url_reltn otur
            SET otur.transaction_url_text = temp_request->facilities[x].services[y].transaction_urls[
             z].trans_url_text, otur.updt_cnt = (otur.updt_cnt+ 1), otur.updt_dt_tm = cnvtdatetime(
              curdate,curtime3),
             otur.updt_id = reqinfo->updt_id, otur.updt_task = reqinfo->updt_task, otur.updt_applctx
              = reqinfo->updt_applctx
            WHERE (otur.org_trans_ident_id=temp_request->facilities[x].services[y].org_trans_ident_id
            )
             AND (otur.transaction_url_cd=temp_request->facilities[x].services[y].transaction_urls[z]
            .trans_url_cd)
            WITH nocounter
           ;end update
          ELSEIF ((temp_request->facilities[x].services[y].transaction_urls[z].action_flag=
          insert_flag))
           SELECT INTO "nl:"
            a = seq(organization_seq,nextval)
            FROM dual d
            DETAIL
             temp_request->facilities[x].services[y].transaction_urls[z].org_trans_url_reltn_id = a
            WITH nocounter
           ;end select
           CALL bederrorcheck("ORGSEQ3 Error: Error getting a new id from organization_seq.")
           IF (size(temp_request->facilities[x].services,5) > 0)
            INSERT  FROM org_trans_url_reltn otur
             SET otur.org_trans_url_reltn_id = temp_request->facilities[x].services[y].
              transaction_urls[z].org_trans_url_reltn_id, otur.org_trans_ident_id = temp_request->
              facilities[x].services[y].org_trans_ident_id, otur.transaction_url_cd = temp_request->
              facilities[x].services[y].transaction_urls[z].trans_url_cd,
              otur.transaction_url_text = temp_request->facilities[x].services[y].transaction_urls[z]
              .trans_url_text, otur.active_ind = 1, otur.updt_cnt = 0,
              otur.updt_dt_tm = cnvtdatetime(curdate,curtime3), otur.updt_id = reqinfo->updt_id, otur
              .updt_task = reqinfo->updt_task,
              otur.updt_applctx = reqinfo->updt_applctx, otur.create_dt_tm = cnvtdatetime(curdate,
               curtime3), otur.create_prsnl_id = reqinfo->updt_id
             WITH nocounter
            ;end insert
           ENDIF
           CALL bederrorcheck(
            "INSERTTRANSURL1 Error: Issue inserting new org-transaction url relation.")
          ELSEIF ((temp_request->facilities[x].services[y].transaction_urls[z].action_flag=
          delete_flag))
           DELETE  FROM org_trans_url_reltn otur
            WHERE (otur.org_trans_ident_id=temp_request->facilities[x].services[y].org_trans_ident_id
            )
             AND (otur.transaction_url_cd=temp_request->facilities[x].services[y].transaction_urls[z]
            .trans_url_cd)
            WITH nocounter
           ;end delete
           CALL bederrorcheck("DELTRANSURL Error: Error while removeing the transaction url.")
          ENDIF
        ENDFOR
       ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE deleteitems(dummyvar)
   FOR (x = 1 TO facility_size)
     FOR (y = 1 TO size(temp_request->facilities[x].services,5))
       IF ((temp_request->facilities[x].services[y].action_flag=delete_flag))
        FOR (z = 1 TO size(temp_request->facilities[x].services[y].payers,5))
         DELETE  FROM org_trans_payer_reltn otpr
          WHERE (otpr.org_trans_payer_reltn_id=temp_request->facilities[x].services[y].payers[z].
          org_trans_payer_reltn_id)
          WITH nocounter
         ;end delete
         CALL bederrorcheck("DELPAYER2 Error: Error while remove a payer relation.")
        ENDFOR
        FOR (z = 1 TO size(temp_request->facilities[x].services[y].alternate_payers,5))
         DELETE  FROM org_trans_payer_reltn otpr
          WHERE (otpr.org_trans_payer_reltn_id=temp_request->facilities[x].services[y].
          alternate_payers[z].org_trans_payer_reltn_id)
          WITH nocounter
         ;end delete
         CALL bederrorcheck("DELALTPAYER2 Error: Error while remove a alternate payer relation.")
        ENDFOR
        DELETE  FROM org_trans_url_reltn otur
         WHERE (otur.org_trans_ident_id=temp_request->facilities[x].services[y].org_trans_ident_id)
         WITH nocounter
        ;end delete
        CALL bederrorcheck("DELTRANSURL Error: Error while removeing the transaction url.")
        SELECT INTO "nl:"
         FROM org_trans_ident_auto_msg otiam
         WHERE (otiam.org_trans_ident_id=temp_request->facilities[x].services[y].org_trans_ident_id)
         WITH nocounter
        ;end select
        IF (curqual > 0)
         DELETE  FROM org_trans_ident_auto_msg otiam
          WHERE (otiam.org_trans_ident_id=temp_request->facilities[x].services[y].org_trans_ident_id)
          WITH nocounter
         ;end delete
         CALL bederrorcheck("DELAUTOMSGFILEDS Error: Error while remove auto msg fields.")
        ENDIF
        DELETE  FROM org_trans_ident oti
         WHERE oti.logical_domain_id=logical_domain_id
          AND (oti.org_trans_ident_id=temp_request->facilities[x].services[y].org_trans_ident_id)
         WITH nocounter
        ;end delete
        CALL bederrorcheck("DELSERV Error: Error while remove an org-service relation.")
       ENDIF
     ENDFOR
   ENDFOR
 END ;Subroutine
END GO
