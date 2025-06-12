CREATE PROGRAM bed_get_user_group_prsnl:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 personnel[*]
      2 prsnl_id = f8
      2 prsnl_name = vc
      2 prsnl_active_ind = i2
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD prsnl_req(
   1 physician_only_ind = i2
   1 position_list[*]
     2 position_cd = f8
   1 name_first = vc
   1 name_last = vc
   1 username = vc
   1 inc_inactive_ind = i2
   1 inc_unauth_ind = i2
   1 max_reply = i4
   1 submit_by = vc
   1 load
     2 get_bus_address_ind = i2
     2 get_bus_phone_ind = i2
     2 get_specialties_ind = i2
     2 get_org_cnt_ind = i2
     2 get_specialty_cnt_ind = i2
     2 get_org_ind = i2
   1 person_id = f8
   1 username_only_ind = i2
   1 organizations[*]
     2 id = f8
   1 organization_groups[*]
     2 id = f8
   1 load_orgs_and_groups_ind = i2
   1 external_ind = i2
 )
 RECORD prsnl_rep(
   1 prsnl_list[*]
     2 user_group_assoc_ind = i2
     2 person_id = f8
     2 org_cnt = i2
     2 org_ind = i2
     2 specialty_cnt = i2
     2 name_full_formatted = vc
     2 username = vc
     2 active_ind = i2
     2 auth_ind = i2
     2 slist[*]
       3 specialty_id = f8
       3 specialty_value = vc
       3 specialty_name = vc
     2 address_list[*]
       3 address_id = f8
       3 address_type_code_value = f8
       3 address_type_disp = vc
       3 address_type_mean = vc
       3 address_type_seq = i4
       3 street_addr = vc
       3 street_addr2 = vc
       3 street_addr3 = vc
       3 street_addr4 = vc
       3 city = vc
       3 state = vc
       3 state_code_value = f8
       3 state_disp = vc
       3 zipcode = vc
       3 country_code_value = f8
       3 country_disp = vc
       3 county_code_value = f8
       3 county_disp = vc
       3 contact_name = vc
       3 residence_type_code_value = f8
       3 residence_type_disp = vc
       3 residence_type_mean = vc
       3 comment_txt = vc
       3 active_ind = i2
     2 phone_list[*]
       3 phone_id = f8
       3 phone_type_code_value = f8
       3 phone_type_disp = vc
       3 phone_type_mean = vc
       3 phone_format_code_value = f8
       3 phone_format_disp = vc
       3 phone_format_mean = vc
       3 sequence = i4
       3 phone_num = vc
       3 phone_formatted = vc
       3 description = vc
       3 contact = vc
       3 call_instruction = vc
       3 extension = vc
       3 paging_code = vc
       3 operation_hours = vc
       3 active_ind = i2
     2 position_code_value = f8
     2 position_display = vc
     2 position_mean = vc
     2 organizations[*]
       3 id = f8
       3 name = vc
     2 organization_groups[*]
       3 id = f8
       3 name = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 external_ind = i2
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 IF ( NOT (validate(error_flag)))
  DECLARE error_flag = vc WITH protect, noconstant("N")
 ENDIF
 IF ( NOT (validate(ierrcode)))
  DECLARE ierrcode = i4 WITH protect, noconstant(0)
 ENDIF
 IF ( NOT (validate(serrmsg)))
  DECLARE serrmsg = vc WITH protect, noconstant("")
 ENDIF
 IF ( NOT (validate(discerncurrentversion)))
  DECLARE discerncurrentversion = i4 WITH constant(cnvtint(build(format(currev,"##;P0"),format(
      currevminor,"##;P0"),format(currevminor2,"##;P0"))))
 ENDIF
 IF (validate(bedbeginscript,char(128))=char(128))
  DECLARE bedbeginscript(dummyvar=i2) = null
  SUBROUTINE bedbeginscript(dummyvar)
    SET reply->status_data.status = "F"
    SET serrmsg = fillstring(132," ")
    SET ierrcode = error(serrmsg,1)
    SET error_flag = "N"
  END ;Subroutine
 ENDIF
 IF (validate(bederror,char(128))=char(128))
  DECLARE bederror(errordescription=vc) = null
  SUBROUTINE bederror(errordescription)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
    GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bedexitsuccess,char(128))=char(128))
  DECLARE bedexitsuccess(dummyvar=i2) = null
  SUBROUTINE bedexitsuccess(dummyvar)
   SET error_flag = "N"
   GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bederrorcheck,char(128))=char(128))
  DECLARE bederrorcheck(errordescription=vc) = null
  SUBROUTINE bederrorcheck(errordescription)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    CALL bederror(errordescription)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedexitscript,char(128))=char(128))
  DECLARE bedexitscript(commitind=i2) = null
  SUBROUTINE bedexitscript(commitind)
   CALL bederrorcheck("Descriptive error message not provided.")
   IF (error_flag="N")
    SET reply->status_data.status = "S"
    IF (commitind)
     SET reqinfo->commit_ind = 1
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    IF (commitind)
     SET reqinfo->commit_ind = 0
    ENDIF
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedlogmessage,char(128))=char(128))
  DECLARE bedlogmessage(subroutinename=vc,message=vc) = null
  SUBROUTINE bedlogmessage(subroutinename,message)
    CALL echo("==================================================================")
    CALL echo(build2(curprog," : ",subroutinename,"() :",message))
    CALL echo("==================================================================")
  END ;Subroutine
 ENDIF
 IF (validate(bedgetlogicaldomain,char(128))=char(128))
  DECLARE bedgetlogicaldomain(dummyvar=i2) = f8
  SUBROUTINE bedgetlogicaldomain(dummyvar)
    DECLARE logicaldomainid = f8 WITH protect, noconstant(0)
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
    SET logicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
    RETURN(logicaldomainid)
  END ;Subroutine
 ENDIF
 SUBROUTINE logdebugmessage(message_header,message)
  IF (validate(debug,0)=1)
   CALL bedlogmessage(message_header,message)
  ENDIF
  RETURN(true)
 END ;Subroutine
 IF (validate(bedgetexpandind,char(128))=char(128))
  DECLARE bedgetexpandind(_reccnt=i4(value),_bindcnt=i4(value,200)) = i2
  SUBROUTINE bedgetexpandind(_reccnt,_bindcnt)
    DECLARE nexpandval = i4 WITH noconstant(1)
    IF (discerncurrentversion >= 81002)
     SET nexpandval = 2
    ENDIF
    RETURN(evaluate(floor(((_reccnt - 1)/ _bindcnt)),0,0,nexpandval))
  END ;Subroutine
 ENDIF
 IF (validate(getfeaturetoggle,char(128))=char(128))
  DECLARE getfeaturetoggle(pfeaturetogglekey=vc,psystemidentifier=vc) = i2
  SUBROUTINE getfeaturetoggle(pfeaturetogglekey,psystemidentifier)
    DECLARE isfeatureenabled = i2 WITH noconstant(false)
    DECLARE syscheckfeaturetoggleexistind = i4 WITH noconstant(0)
    DECLARE pftgetdminfoexistind = i4 WITH noconstant(0)
    SET syscheckfeaturetoggleexistind = checkprg("SYS_CHECK_FEATURE_TOGGLE")
    SET pftgetdminfoexistind = checkprg("PFT_GET_DM_INFO")
    IF (syscheckfeaturetoggleexistind > 0
     AND pftgetdminfoexistind > 0)
     RECORD featuretogglerequest(
       1 togglename = vc
       1 username = vc
       1 positioncd = f8
       1 systemidentifier = vc
       1 solutionname = vc
     ) WITH protect
     RECORD featuretogglereply(
       1 togglename = vc
       1 isenabled = i2
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     ) WITH protect
     SET featuretogglerequest->togglename = pfeaturetogglekey
     SET featuretogglerequest->systemidentifier = psystemidentifier
     EXECUTE sys_check_feature_toggle  WITH replace("REQUEST",featuretogglerequest), replace("REPLY",
      featuretogglereply)
     IF (validate(debug,false))
      CALL echorecord(featuretogglerequest)
      CALL echorecord(featuretogglereply)
     ENDIF
     IF ((featuretogglereply->status_data.status="S"))
      SET isfeatureenabled = featuretogglereply->isenabled
      CALL logdebugmessage("getFeatureToggle",build("Feature Toggle for Key - ",pfeaturetogglekey,
        " : ",isfeatureenabled))
     ELSE
      CALL logdebugmessage("getFeatureToggle","Call to sys_check_feature_toggle failed")
     ENDIF
    ELSE
     CALL logdebugmessage("getFeatureToggle",build2("sys_check_feature_toggle.prg and / or ",
       " pft_get_dm_info.prg do not exist in domain.",
       " Contact Patient Accounting Team for assistance."))
    ENDIF
    RETURN(isfeatureenabled)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isfeaturetoggleenabled)))
  DECLARE isfeaturetoggleenabled(pparentfeaturekey=vc,pchildfeaturekey=vc,psystemidentifier=vc) = i2
  SUBROUTINE isfeaturetoggleenabled(pparentfeaturekey,pchildfeaturekey,psystemidentifier)
    DECLARE isparentfeatureenabled = i2 WITH noconstant(false)
    DECLARE ischildfeatureenabled = i2 WITH noconstant(false)
    SET isparentfeatureenabled = getfeaturetoggle(pparentfeaturekey,psystemidentifier)
    IF (isparentfeatureenabled)
     SET ischildfeatureenabled = getfeaturetoggle(pchildfeaturekey,psystemidentifier)
    ENDIF
    CALL logdebugmessage("isFeatureToggleEnabled",build2(" Parent Feature Toggle - ",
      pparentfeaturekey," value is = ",isparentfeatureenabled," and Child Feature Toggle - ",
      pchildfeaturekey," value is = ",ischildfeatureenabled))
    RETURN(ischildfeatureenabled)
  END ;Subroutine
 ENDIF
 CALL bedbeginscript(0)
 DECLARE num = i4 WITH protect, noconstant(1)
 DECLARE req_pos_cnt = i4 WITH protect, constant(size(request->positions,5))
 DECLARE req_org_cnt = i4 WITH protect, constant(size(request->organizations,5))
 DECLARE req_org_grp_cnt = i4 WITH protect, constant(size(request->organization_groups,5))
 DECLARE prsnl_cnt = i4 WITH protect, noconstant(0)
 DECLARE rep_prsnl_cnt = i4 WITH protect, noconstant(0)
 DECLARE asso_prsnl_cnt = i4 WITH protect, noconstant(0)
 IF ((request->prsnl_association_ind=0))
  SET prsnl_req->physician_only_ind = request->physician_only_ind
  SET stat = alterlist(prsnl_req->position_list,req_pos_cnt)
  FOR (num = 1 TO req_pos_cnt)
    SET prsnl_req->position_list[num].position_cd = request->positions[num].id
  ENDFOR
  SET prsnl_req->name_first = request->name_first
  SET prsnl_req->name_last = request->name_last
  SET prsnl_req->username = request->username
  SET prsnl_req->inc_inactive_ind = request->inc_inactive_ind
  SET prsnl_req->username_only_ind = request->username_only_ind
  FOR (num = 1 TO req_org_cnt)
    SET prsnl_req->organizations[num].position_cd = request->organizations[num].id
  ENDFOR
  FOR (num = 1 TO req_org_grp_cnt)
    SET prsnl_req->organization_groups[num].position_cd = request->organization_groups[num].id
  ENDFOR
  SET prsnl_req->max_reply = request->max_reply
  EXECUTE bed_get_personnel_list_b  WITH replace("REQUEST",prsnl_req), replace("REPLY",prsnl_rep)
  IF ((prsnl_rep->status_data.status="F"))
   CALL bederror("prsnl_rep Fail")
  ELSEIF (prsnl_rep->too_many_results_ind)
   SET stat = alterlist(reply->personnel,0)
   SET reply->too_many_results_ind = true
  ENDIF
  SET prsnl_cnt = size(prsnl_rep->prsnl_list,5)
  IF (prsnl_cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = prsnl_cnt),
     prsnl_group_reltn pgr
    PLAN (d)
     JOIN (pgr
     WHERE (pgr.prsnl_group_id=request->user_group_id)
      AND pgr.active_ind=true
      AND (pgr.person_id=prsnl_rep->prsnl_list[d.seq].person_id)
      AND pgr.prsnl_group_reltn_id > 0)
    DETAIL
     prsnl_rep->prsnl_list[d.seq].user_group_assoc_ind = true
    WITH nocounter
   ;end select
   CALL bederrorcheck("user_group_assoc_ind")
   FOR (num = 1 TO prsnl_cnt)
     IF ((((request->user_group_id=0)) OR ((request->prsnl_association_ind=prsnl_rep->prsnl_list[num]
     .user_group_assoc_ind))) )
      SET rep_prsnl_cnt = (rep_prsnl_cnt+ 1)
      SET stat = alterlist(reply->personnel,rep_prsnl_cnt)
      SET reply->personnel[rep_prsnl_cnt].prsnl_id = prsnl_rep->prsnl_list[num].person_id
      SET reply->personnel[rep_prsnl_cnt].prsnl_name = prsnl_rep->prsnl_list[num].name_full_formatted
      SET reply->personnel[rep_prsnl_cnt].prsnl_active_ind = prsnl_rep->prsnl_list[num].active_ind
     ENDIF
   ENDFOR
   IF ((rep_prsnl_cnt > request->max_reply)
    AND (request->max_reply > 0))
    SET stat = alterlist(reply->personnel,0)
    SET reply->too_many_results_ind = true
   ENDIF
  ENDIF
 ELSE
  DECLARE plistparse = vc
  SET plistparse = "p.person_id > 0 and p.name_full_formatted > ' '"
  SET positioncnt = size(request->positions,5)
  IF ((request->name_last > " "))
   SET plistparse = concat(plistparse," and p.name_last_key = '",nullterm(cnvtalphanum(cnvtupper(trim
       (request->name_last)))),"*'")
  ENDIF
  IF ((request->name_first > " "))
   SET plistparse = concat(plistparse," and p.name_first_key = '",nullterm(cnvtalphanum(cnvtupper(
       trim(request->name_first)))),"*'")
  ENDIF
  IF ((request->username > " "))
   SET plistparse = concat(plistparse," and cnvtupper(p.username) = '",trim(cnvtupper(request->
      username)),"*'")
  ENDIF
  IF ((request->physician_only_ind=1))
   SET plistparse = concat(plistparse," and p.physician_ind = 1")
  ENDIF
  IF ((request->inc_inactive_ind=0))
   SET plistparse = concat(plistparse," and p.active_ind = 1")
  ENDIF
  IF ((request->username_only_ind=1))
   SET plistparse = concat(plistparse," and p.username != NULL and p.username > '  *' ")
  ENDIF
  IF (positioncnt > 0)
   FOR (i = 1 TO positioncnt)
     IF (i=1)
      SET plistparse = build(plistparse," and ((p.position_cd = ",request->positions[i].id,")")
     ELSE
      SET plistparse = build(plistparse," or (p.position_cd = ",request->positions[i].id,")")
     ENDIF
   ENDFOR
   SET plistparse = concat(plistparse,")")
  ENDIF
  SET org_filter_cnt = 0
  SET org_grp_filter_cnt = 0
  IF (validate(request->organizations))
   SET org_filter_cnt = size(request->organizations,5)
   SET org_grp_filter_cnt = size(request->organization_groups,5)
   DECLARE orgparse = vc
   DECLARE orggrpparse = vc
   IF (org_filter_cnt > 0)
    SET orgparse = build(orgparse," por.organization_id in (")
    FOR (o = 1 TO org_filter_cnt)
      IF (o=1)
       SET orgparse = build(orgparse,request->organizations[o].id)
      ELSE
       SET orgparse = build(orgparse,", ",request->organizations[o].id)
      ENDIF
    ENDFOR
    SET orgparse = build(orgparse,")")
   ELSEIF (org_grp_filter_cnt > 0)
    SET orggrpparse = build(orggrpparse," os.org_set_id in (")
    FOR (o = 1 TO org_grp_filter_cnt)
      IF (o=1)
       SET orggrpparse = build(orggrpparse,request->organization_groups[o].id)
      ELSE
       SET orggrpparse = build(orggrpparse,", ",request->organization_groups[o].id)
      ENDIF
    ENDFOR
    SET orggrpparse = build(orggrpparse,")")
   ENDIF
  ENDIF
  IF (org_filter_cnt > 0)
   SELECT DISTINCT INTO "nl:"
    FROM prsnl_group_reltn pgr,
     prsnl p,
     prsnl_org_reltn por
    PLAN (pgr
     WHERE pgr.active_ind=true
      AND (pgr.prsnl_group_id=request->user_group_id)
      AND pgr.prsnl_group_reltn_id > 0)
     JOIN (p
     WHERE p.person_id=pgr.person_id
      AND parser(plistparse))
     JOIN (por
     WHERE parser(orgparse)
      AND por.person_id=p.person_id
      AND por.active_ind=true)
    DETAIL
     asso_prsnl_cnt = (asso_prsnl_cnt+ 1), stat = alterlist(reply->personnel,asso_prsnl_cnt), reply->
     personnel[asso_prsnl_cnt].prsnl_id = pgr.person_id,
     reply->personnel[asso_prsnl_cnt].prsnl_name = p.name_full_formatted, reply->personnel[
     asso_prsnl_cnt].prsnl_active_ind = p.active_ind
    WITH nocounter
   ;end select
   CALL bederrorcheck("user_group_assoc_ind")
  ELSEIF (org_grp_filter_cnt > 0)
   SELECT DISTINCT INTO "nl:"
    FROM prsnl_group_reltn pgr,
     prsnl p,
     org_set_prsnl_r os
    PLAN (pgr
     WHERE pgr.active_ind=true
      AND (pgr.prsnl_group_id=request->user_group_id)
      AND pgr.prsnl_group_reltn_id > 0)
     JOIN (p
     WHERE p.person_id=pgr.person_id
      AND parser(plistparse))
     JOIN (os
     WHERE parser(orggrpparse)
      AND os.prsnl_id=p.person_id
      AND os.active_ind=true)
    DETAIL
     asso_prsnl_cnt = (asso_prsnl_cnt+ 1), stat = alterlist(reply->personnel,asso_prsnl_cnt), reply->
     personnel[asso_prsnl_cnt].prsnl_id = pgr.person_id,
     reply->personnel[asso_prsnl_cnt].prsnl_name = p.name_full_formatted, reply->personnel[
     asso_prsnl_cnt].prsnl_active_ind = p.active_ind
    WITH nocounter
   ;end select
   CALL bederrorcheck("user_group_assoc_ind")
  ELSE
   SELECT INTO "nl:"
    FROM prsnl_group_reltn pgr,
     prsnl p
    PLAN (pgr
     WHERE (pgr.prsnl_group_id=request->user_group_id)
      AND pgr.active_ind=true
      AND pgr.prsnl_group_reltn_id > 0)
     JOIN (p
     WHERE parser(plistparse)
      AND p.person_id=pgr.person_id)
    DETAIL
     asso_prsnl_cnt = (asso_prsnl_cnt+ 1), stat = alterlist(reply->personnel,asso_prsnl_cnt), reply->
     personnel[asso_prsnl_cnt].prsnl_id = pgr.person_id,
     reply->personnel[asso_prsnl_cnt].prsnl_name = p.name_full_formatted, reply->personnel[
     asso_prsnl_cnt].prsnl_active_ind = p.active_ind
    WITH nocounter
   ;end select
   CALL bederrorcheck("user_group_assoc_ind")
  ENDIF
  IF ((asso_prsnl_cnt > request->max_reply)
   AND (request->max_reply > 0))
   SET stat = alterlist(reply->personnel,0)
   SET reply->too_many_results_ind = true
  ENDIF
 ENDIF
#exit_script
 CALL bedexitscript(0)
END GO
