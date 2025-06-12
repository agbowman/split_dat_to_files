CREATE PROGRAM bed_get_organization_groups:dba
 IF ( NOT (validate(reply)))
  RECORD reply(
    01 oslist[*]
      02 name = vc
      02 active_ind = i2
      02 description = vc
      02 org_set_id = f8
      02 org[*]
        03 org_set_org_r_id = f8
        03 organization_id = f8
        03 org_name = vc
        03 active_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  )
 ENDIF
 IF ( NOT (validate(temp,0)))
  RECORD temp(
    01 oslist[*]
      02 name = vc
      02 active_ind = i2
      02 description = vc
      02 org_set_id = f8
      02 org[*]
        03 org_set_org_r_id = f8
        03 organization_id = f8
        03 org_name = vc
        03 active_ind = i2
        03 logical_domain_id = f8
  )
 ENDIF
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
 DECLARE issamelogicaldomain(locationcd=f8) = i4
 SET only_active_prsnl_ind = 0
 IF (validate(request->load_active_personnel_ind))
  IF ((request->load_active_personnel_ind=1))
   SET only_active_prsnl_ind = 1
  ENDIF
 ENDIF
 SET max_cnt = 0
 IF (validate(request->max_reply))
  SET max_cnt = request->max_reply
 ENDIF
 DECLARE search_txt = vc
 SET search_txt = " "
 IF (validate(request->search_txt))
  SET search_txt = trim(cnvtupper(request->search_txt))
 ENDIF
 SET search_type_flag = " "
 IF (validate(request->search_type_flag))
  SET search_type_flag = request->search_type_flag
 ENDIF
 DECLARE req_os_cnt = i4
 SET req_os_cnt = size(request->oslist,5)
 SET os_cnt = 0
 SET reply->status_data.status = "F"
 DECLARE osparse = vc
 SET osparse = " os.org_set_id > 0"
 IF (search_txt > " ")
  IF (search_type_flag="S")
   SET osparse = build2(osparse," and trim(cnvtupper(os.description)) = ","'",search_txt,"*'")
  ELSE
   SET osparse = build2(osparse," and trim(cnvtupper(os.description)) = ","'*",search_txt,"*'")
  ENDIF
 ENDIF
 CALL echo(osparse)
 IF (req_os_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = req_os_cnt),
    org_set os
   PLAN (d1)
    JOIN (os
    WHERE (os.org_set_id=request->oslist[d1.seq].org_set_id))
   ORDER BY os.name
   HEAD os.org_set_id
    os_cnt = (os_cnt+ 1), stat = alterlist(temp->oslist,os_cnt), temp->oslist[os_cnt].name = os.name,
    temp->oslist[os_cnt].org_set_id = os.org_set_id, temp->oslist[os_cnt].description = os
    .description, temp->oslist[os_cnt].active_ind = os.active_ind
   WITH nocounter
  ;end select
 ELSEIF (only_active_prsnl_ind=1)
  SELECT INTO "nl:"
   FROM org_set os,
    org_set_prsnl_r ospr,
    prsnl p
   PLAN (os
    WHERE parser(osparse))
    JOIN (ospr
    WHERE ospr.org_set_id=os.org_set_id
     AND ospr.active_ind=1
     AND ospr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((ospr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (ospr.end_effective_dt_tm=
    null)) )
    JOIN (p
    WHERE p.person_id=ospr.prsnl_id
     AND p.active_ind=1)
   ORDER BY os.name
   HEAD os.org_set_id
    os_cnt = (os_cnt+ 1), stat = alterlist(temp->oslist,os_cnt), temp->oslist[os_cnt].name = os.name,
    temp->oslist[os_cnt].org_set_id = os.org_set_id, temp->oslist[os_cnt].description = os
    .description, temp->oslist[os_cnt].active_ind = os.active_ind
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM org_set os
   PLAN (os
    WHERE parser(osparse))
   ORDER BY os.name
   HEAD os.org_set_id
    os_cnt = (os_cnt+ 1), stat = alterlist(temp->oslist,os_cnt), temp->oslist[os_cnt].name = os.name,
    temp->oslist[os_cnt].org_set_id = os.org_set_id, temp->oslist[os_cnt].description = os
    .description, temp->oslist[os_cnt].active_ind = os.active_ind
   WITH nocounter
  ;end select
 ENDIF
 SET data_partition_ind = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF o IS organization
   SET field_found = validate(o.logical_domain_id)
   FREE RANGE o
   IF (field_found=1)
    SET data_partition_ind = 1
    FREE SET acm_get_acc_logical_domains_req
    RECORD acm_get_acc_logical_domains_req(
      1 write_mode_ind = i2
      1 concept = i4
    )
    FREE SET acm_get_acc_logical_domains_rep
    RECORD acm_get_acc_logical_domains_rep(
      1 logical_domain_grp_id = f8
      1 logical_domains_cnt = i4
      1 logical_domains[*]
        2 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_acc_logical_domains_req->write_mode_ind = 0
    SET acm_get_acc_logical_domains_req->concept = 3
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 DECLARE otrparse = vc
 SET orgtypecnt = size(request->org_type,5)
 SET otrparse = "otr.organization_id = osor.organization_id"
 IF (orgtypecnt > 0
  AND (request->org_type[1].org_type_code_value > 0.0))
  FOR (i = 1 TO orgtypecnt)
    IF (i=1)
     SET otrparse = build(otrparse," and ((otr.org_type_cd = ",request->org_type[i].
      org_type_code_value,")")
    ELSE
     SET otrparse = build(otrparse," or (otr.org_type_cd = ",request->org_type[i].org_type_code_value,
      ")")
    ENDIF
  ENDFOR
  SET otrparse = concat(otrparse,")")
 ENDIF
 SET o_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = os_cnt),
   org_set_org_r osor,
   org_type_reltn otr,
   organization o
  PLAN (d)
   JOIN (osor
   WHERE (osor.org_set_id=temp->oslist[d.seq].org_set_id)
    AND ((osor.active_ind=1) OR ((request->load_inactive_child_ind=1))) )
   JOIN (otr
   WHERE parser(otrparse))
   JOIN (o
   WHERE o.organization_id=otr.organization_id
    AND ((o.active_ind=1) OR ((request->load_inactive_child_ind=1))) )
  ORDER BY d.seq, o.org_name_key
  HEAD d.seq
   o_cnt = 0
  HEAD osor.org_set_org_r_id
   o_cnt = (o_cnt+ 1), stat = alterlist(temp->oslist[d.seq].org,o_cnt), temp->oslist[d.seq].org[o_cnt
   ].org_set_org_r_id = osor.org_set_org_r_id,
   temp->oslist[d.seq].org[o_cnt].organization_id = o.organization_id, temp->oslist[d.seq].org[o_cnt]
   .org_name = o.org_name, temp->oslist[d.seq].org[o_cnt].active_ind = osor.active_ind,
   temp->oslist[d.seq].org[o_cnt].logical_domain_id = o.logical_domain_id
  WITH nocounter
 ;end select
 DECLARE os_size = i4
 DECLARE orig_org_size = i4
 SET os_size = size(temp->oslist,5)
 SET indexi = 1
 FOR (i = 1 TO os_size)
   SET orig_org_size = size(temp->oslist[i].org,5)
   SET stat = alterlist(reply->oslist,os_size)
   SET reply->oslist[indexi].name = temp->oslist[i].name
   SET reply->oslist[indexi].org_set_id = temp->oslist[i].org_set_id
   SET reply->oslist[indexi].description = temp->oslist[i].description
   SET reply->oslist[indexi].active_ind = temp->oslist[i].active_ind
   SET indexj = 1
   FOR (j = 1 TO orig_org_size)
     IF (issamelogicaldomain(temp->oslist[i].org[j].logical_domain_id))
      SET stat = alterlist(reply->oslist[indexi].org,indexj)
      SET reply->oslist[indexi].org[indexj].org_set_org_r_id = temp->oslist[i].org[j].
      org_set_org_r_id
      SET reply->oslist[indexi].org[indexj].organization_id = temp->oslist[i].org[j].organization_id
      SET reply->oslist[indexi].org[indexj].org_name = temp->oslist[i].org[j].org_name
      SET reply->oslist[indexi].org[indexj].active_ind = temp->oslist[i].org[j].active_ind
      SET indexj = (indexj+ 1)
     ENDIF
   ENDFOR
   IF (size(reply->oslist[indexi].org,5) < 1
    AND orig_org_size != 0)
    SET indexi = (indexi - 1)
   ENDIF
   SET indexi = (indexi+ 1)
 ENDFOR
 SET stat = alterlist(reply->oslist,(indexi - 1))
 SET org_set_count = size(reply->oslist,5)
 IF (org_set_count > 0)
  SET reply->status_data.status = "S"
  IF (max_cnt > 0
   AND org_set_count > max_cnt)
   SET stat = alterlist(reply->oslist,0)
   SET reply->too_many_results_ind = 1
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SUBROUTINE issamelogicaldomain(logicaldomainid)
   CALL bedlogmessage("isSameLogicalDomain","Entering ...")
   IF (data_partition_ind=1)
    IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
     FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
       IF ((logicaldomainid=acm_get_acc_logical_domains_rep->logical_domains[d].logical_domain_id))
        CALL bedlogmessage("isSameLogicalDomain","Exiting ...")
        RETURN(1)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   CALL bederrorcheck("ERROR 001: Error in checking logical domain.")
   CALL bedlogmessage("isSameLogicalDomain","Exiting ...")
   RETURN(0)
 END ;Subroutine
#exit_script
 CALL echorecord(reply)
END GO
