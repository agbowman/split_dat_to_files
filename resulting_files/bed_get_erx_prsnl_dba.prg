CREATE PROGRAM bed_get_erx_prsnl:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 prsnl[*]
      2 prsnl_id = f8
      2 name_first = vc
      2 name_middle = vc
      2 name_last = vc
      2 name_full_formatted = vc
      2 name_prefix = vc
      2 name_suffix = vc
      2 spi[*]
        3 prsnl_alias_id = f8
        3 alias = vc
        3 unassociated_ind = i2
      2 erx_reltns[*]
        3 prsnl_reltn_id = f8
        3 prsnl_reltn_type_code_value = f8
        3 parent_entity_name = vc
        3 parent_entity_id = f8
        3 display_seq = i4
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
        3 service_level_mask = i4
        3 status_code_value = f8
        3 error_code_value = f8
        3 error_desc = vc
        3 child_reltns[*]
          4 prsnl_reltn_child_id = f8
          4 parent_entity_name = vc
          4 parent_entity_id = f8
          4 display_seq = i4
      2 npi[*]
        3 prsnl_alias_id = f8
        3 alias = vc
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_rep
 RECORD temp_rep(
   1 prsnl[*]
     2 org_valid_ind = i2
     2 erx_reltn_valid_ind = i2
     2 erx_in_progress_ind = i2
     2 prsnl_id = f8
     2 name_first = vc
     2 name_middle = vc
     2 name_last = vc
     2 name_full_formatted = vc
     2 name_prefix = vc
     2 name_suffix = vc
     2 spi_cnt = i2
     2 spi[*]
       3 prsnl_alias_id = f8
       3 alias = vc
       3 unassociated_ind = i2
     2 reltn_cnt = i2
     2 erx_reltns[*]
       3 load_reltn_ind = i2
       3 prsnl_reltn_id = f8
       3 prsnl_reltn_type_code_value = f8
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 display_seq = i4
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 service_level_mask = i4
       3 status_code_value = f8
       3 error_code_value = f8
       3 error_desc = vc
       3 child_cnt = i2
       3 child_reltns[*]
         4 prsnl_reltn_child_id = f8
         4 parent_entity_name = vc
         4 parent_entity_id = f8
         4 display_seq = i4
     2 npi[*]
       3 prsnl_alias_id = f8
       3 alias = vc
     2 unassociated_spis_ind = i2
 )
 FREE SET temp_erx_prsnl
 RECORD temp_erx_prsnl(
   1 prsnl[*]
     2 prsnl_id = f8
 )
 SET reply->status_data.status = "F"
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
 DECLARE max_cnt = i4 WITH protect, noconstant(0)
 DECLARE prep_cnt = i4 WITH protect, noconstant(0)
 DECLARE auth_cd = f8 WITH protect, noconstant(0.0)
 DECLARE active_code = f8 WITH protect, noconstant(0.0)
 DECLARE npi_code = f8 WITH protect, noconstant(0.0)
 DECLARE spi_code = f8 WITH protect, noconstant(0.0)
 DECLARE prsnl_code = f8 WITH protect, noconstant(0.0)
 DECLARE erx_delivered = f8 WITH protect, noconstant(0.0)
 DECLARE erx_in_progress = f8 WITH protect, noconstant(0.0)
 DECLARE reltn_type_code_value = f8 WITH protect, noconstant(0.0)
 DECLARE positioncnt = i4 WITH protect, noconstant(0)
 DECLARE prsnl_reltn_cnt = i4 WITH protect, noconstant(0)
 DECLARE acnt = i4 WITH protect, noconstant(0)
 DECLARE atcnt = i4 WITH protect, noconstant(0)
 DECLARE org_filter_cnt = i4 WITH protect, noconstant(0)
 DECLARE num1 = i4 WITH protect, noconstant(1)
 IF ((request->max_reply > 0))
  SET max_cnt = request->max_reply
 ELSE
  SET max_cnt = 1000
 ENDIF
 DECLARE pparse = vc
 DECLARE eparse = vc
 SET pparse = " p.person_id > 0 "
 SET eparse = " e.prsnl_reltn_id = p.prsnl_reltn_id "
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
 SET active_code = uar_get_code_by("MEANING",48,"ACTIVE")
 SET npi_code = uar_get_code_by("MEANING",320,"NPI")
 SET spi_code = uar_get_code_by("MEANING",320,"SPI")
 SET prsnl_code = uar_get_code_by("MEANING",213,"PRSNL")
 SET erx_delivered = uar_get_code_by("MEANING",3401,"DELIVERED")
 SET erx_in_progress = uar_get_code_by("MEANING",3401,"IN PROGRESS")
 SET reltn_type_code_value = uar_get_code_by("MEANING",30300,"EPRESCRELTN")
 SET positioncnt = size(request->position_list,5)
 SET prsnl_reltn_cnt = size(request->prsnl_reltns,5)
 IF (validate(request->error_ind)
  AND (request->error_ind=1))
  SET eparse = build2(eparse," and e.status_cd != ",erx_delivered," and e.status_cd != ",
   erx_in_progress)
 ENDIF
 DECLARE pr_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 IF (prsnl_reltn_cnt > 0)
  SELECT INTO "nl:"
   FROM prsnl_reltn p,
    eprescribe_detail e
   PLAN (p
    WHERE expand(idx,1,prsnl_reltn_cnt,p.parent_entity_id,request->prsnl_reltns[idx].parent_entity_id
     )
     AND p.reltn_type_cd=reltn_type_code_value
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (e
    WHERE parser(eparse)
     AND  EXISTS (
    (SELECT
     1
     FROM prsnl_reltn_child c
     WHERE c.prsnl_reltn_id=e.prsnl_reltn_id
      AND c.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))))
   ORDER BY p.person_id
   DETAIL
    pr_cnt = (pr_cnt+ 1), stat = alterlist(temp_erx_prsnl->prsnl,pr_cnt), temp_erx_prsnl->prsnl[
    pr_cnt].prsnl_id = p.person_id
   WITH nocounter, expand = 1
  ;end select
  IF (pr_cnt=0
   AND (request->erx_reltn_ind=1))
   GO TO exit_script
  ENDIF
  IF (pr_cnt > 0)
   IF ((request->erx_reltn_ind=1))
    SET pparse =
    " expand(NUM1, 1, size(temp_erx_prsnl->prsnl, 5), p.person_id, temp_erx_prsnl->prsnl[NUM1].prsnl_id) "
   ELSE
    SET pparse =
    " not expand(NUM1, 1, size(temp_erx_prsnl->prsnl, 5), p.person_id, temp_erx_prsnl->prsnl[NUM1].prsnl_id) "
   ENDIF
  ENDIF
 ENDIF
 IF ((request->name_last > " "))
  SET pparse = concat(pparse," and p.name_last_key = '",nullterm(cnvtalphanum(cnvtupper(trim(request
       ->name_last)))),"*'")
 ENDIF
 IF ((request->name_first > " "))
  SET pparse = concat(pparse," and p.name_first_key = '",nullterm(cnvtalphanum(cnvtupper(trim(request
       ->name_first)))),"*'")
 ENDIF
 IF ((request->username > " "))
  SET pparse = concat(pparse," and cnvtupper(p.username) = '",trim(cnvtupper(request->username)),"*'"
   )
 ENDIF
 IF ((request->physician_only_ind=1))
  SET pparse = concat(pparse," and p.physician_ind = 1")
 ENDIF
 IF ((request->inc_inactive_ind=0))
  SET pparse = concat(pparse," and p.active_ind = 1 ",
   " and p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) ")
 ENDIF
 IF ((request->inc_unauth_ind=0))
  SET pparse = build(pparse," and p.data_status_cd  = ",auth_cd)
 ENDIF
 IF (positioncnt > 0)
  SET pparse = build(pparse," and p.position_cd in (")
  FOR (i = 1 TO positioncnt)
    IF (i=1)
     SET pparse = build(pparse,request->position_list[i].position_code_value)
    ELSE
     SET pparse = build(pparse,",",request->position_list[i].position_code_value)
    ENDIF
  ENDFOR
  SET pparse = build(pparse,")")
 ENDIF
 SET org_filter_cnt = size(request->organizations,5)
 DECLARE orgparse = vc
 IF (org_filter_cnt > 0)
  SET orgparse = build(orgparse," por.organization_id in (")
  FOR (o = 1 TO org_filter_cnt)
    IF (o=1)
     SET orgparse = build(orgparse,request->organizations[o].org_id)
    ELSE
     SET orgparse = build(orgparse,", ",request->organizations[o].org_id)
    ENDIF
  ENDFOR
  SET orgparse = build(orgparse,")")
 ENDIF
 DECLARE data_partition_ind = i2 WITH protect, noconstant(0)
 DECLARE prg_exists_ind = i2 WITH protect, noconstant(0)
 DECLARE field_found = i2 WITH protect, noconstant(0)
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF p IS prsnl
   SET field_found = validate(p.logical_domain_id)
   FREE RANGE p
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
    SET acm_get_acc_logical_domains_req->concept = 2
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET pparse = concat(pparse," and p.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET pparse = build(pparse,acm_get_acc_logical_domains_rep->logical_domains[d].logical_domain_id,
       ")")
     ELSE
      SET pparse = build(pparse,acm_get_acc_logical_domains_rep->logical_domains[d].logical_domain_id,
       ",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 DECLARE pcnt = i4 WITH protect, noconstant(0)
 DECLARE listcnt = i4 WITH protect, noconstant(0)
 DECLARE npi_alias_cnt = i4 WITH protect, noconstant(0)
 DECLARE alias_cnt = i4 WITH protect, noconstant(0)
 SELECT
  IF (prsnl_reltn_cnt > 0
   AND pr_cnt > 0)
   WITH nocounter, expand = 2
  ELSE
   WITH nocounter
  ENDIF
  INTO "nl:"
  total_count = count(1)
  FROM prsnl p,
   person_name pn
  PLAN (p
   WHERE parser(pparse))
   JOIN (pn
   WHERE pn.person_id=p.person_id
    AND pn.active_ind=1
    AND pn.name_type_cd=prsnl_code
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND  EXISTS (
   (SELECT
    1
    FROM prsnl_alias ap
    WHERE ap.person_id=pn.person_id
     AND ap.prsnl_alias_type_cd=npi_code
     AND ap.active_ind=1
     AND ap.active_status_cd=active_code
     AND ap.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))))
  DETAIL
   pcnt = total_count
  WITH nocounter
 ;end select
 CALL logdebugmessage("eparse : ",eparse)
 CALL logdebugmessage("pparse : ",pparse)
 IF (pcnt=0)
  GO TO exit_script
 ENDIF
 IF (pcnt > max_cnt)
  SET reply->too_many_results_ind = 1
  GO TO exit_script
 ENDIF
 SELECT
  IF (prsnl_reltn_cnt > 0
   AND pr_cnt > 0)
   WITH nocounter, expand = 2
  ELSE
   WITH nocounter
  ENDIF
  INTO "nl:"
  FROM prsnl p,
   person_name pn,
   prsnl_alias ap
  PLAN (p
   WHERE parser(pparse))
   JOIN (pn
   WHERE pn.person_id=p.person_id
    AND pn.active_ind=1
    AND pn.name_type_cd=prsnl_code
    AND pn.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (ap
   WHERE ap.person_id=p.person_id
    AND ap.prsnl_alias_type_cd=npi_code
    AND ap.active_ind=1
    AND ap.active_status_cd=active_code
    AND ap.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
  ORDER BY p.person_id, ap.prsnl_alias_id
  HEAD REPORT
   pcnt = 0, listcnt = 0, stat = alterlist(temp_rep->prsnl,100)
  HEAD p.person_id
   pcnt = (pcnt+ 1), listcnt = (listcnt+ 1), npi_alias_cnt = 0
   IF (listcnt > 100)
    listcnt = 1, stat = alterlist(temp_rep->prsnl,(pcnt+ 100))
   ENDIF
   temp_rep->prsnl[pcnt].prsnl_id = p.person_id, temp_rep->prsnl[pcnt].name_full_formatted = pn
   .name_full, temp_rep->prsnl[pcnt].name_first = pn.name_first,
   temp_rep->prsnl[pcnt].name_last = pn.name_last, temp_rep->prsnl[pcnt].name_middle = pn.name_middle,
   temp_rep->prsnl[pcnt].name_prefix = pn.name_title,
   temp_rep->prsnl[pcnt].name_suffix = pn.name_suffix
  HEAD ap.prsnl_alias_id
   npi_alias_cnt = (npi_alias_cnt+ 1), stat = alterlist(temp_rep->prsnl[pcnt].npi,npi_alias_cnt),
   temp_rep->prsnl[pcnt].npi[npi_alias_cnt].prsnl_alias_id = ap.prsnl_alias_id,
   temp_rep->prsnl[pcnt].npi[npi_alias_cnt].alias = ap.alias
  FOOT REPORT
   stat = alterlist(temp_rep->prsnl,pcnt)
  WITH nocounter
 ;end select
 IF (org_filter_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(pcnt)),
    prsnl_org_reltn por
   PLAN (d)
    JOIN (por
    WHERE parser(orgparse)
     AND (por.person_id=temp_rep->prsnl[d.seq].prsnl_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   ORDER BY d.seq
   HEAD d.seq
    temp_rep->prsnl[d.seq].org_valid_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(pcnt)),
   prsnl_alias pa
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_id=temp_rep->prsnl[d.seq].prsnl_id)
    AND pa.prsnl_alias_type_cd=spi_code
    AND pa.active_ind=1
    AND pa.active_status_cd=active_code
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq
  HEAD d.seq
   acnt = 0, atcnt = 0, stat = alterlist(temp_rep->prsnl[d.seq].spi,10)
  DETAIL
   acnt = (acnt+ 1), atcnt = (atcnt+ 1)
   IF (acnt > 10)
    stat = alterlist(temp_rep->prsnl[d.seq].spi,(atcnt+ 10)), acnt = 1
   ENDIF
   temp_rep->prsnl[d.seq].spi[atcnt].alias = pa.alias, temp_rep->prsnl[d.seq].spi[atcnt].
   prsnl_alias_id = pa.prsnl_alias_id
  FOOT  d.seq
   stat = alterlist(temp_rep->prsnl[d.seq].spi,atcnt), temp_rep->prsnl[d.seq].spi_cnt = atcnt
  WITH nocounter
 ;end select
 SET alias_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(pcnt)),
   prsnl_reltn p,
   prsnl_reltn_child c,
   eprescribe_detail e
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=temp_rep->prsnl[d.seq].prsnl_id)
    AND p.reltn_type_cd=reltn_type_code_value
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (e
   WHERE parser(eparse))
   JOIN (c
   WHERE c.prsnl_reltn_id=p.prsnl_reltn_id
    AND c.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq, p.prsnl_reltn_id, c.display_seq
  HEAD d.seq
   rcnt = 0, rtcnt = 0, stat = alterlist(temp_rep->prsnl[d.seq].erx_reltns,10),
   alias_cnt = temp_rep->prsnl[d.seq].spi_cnt
  HEAD p.prsnl_reltn_id
   rcnt = (rcnt+ 1), rtcnt = (rtcnt+ 1)
   IF (rcnt > 10)
    stat = alterlist(temp_rep->prsnl[d.seq].erx_reltns,(rtcnt+ 10)), rcnt = 1
   ENDIF
   IF (e.status_cd=0)
    temp_rep->prsnl[d.seq].erx_in_progress_ind = 1
   ENDIF
   temp_rep->prsnl[d.seq].erx_reltns[rtcnt].prsnl_reltn_id = p.prsnl_reltn_id, temp_rep->prsnl[d.seq]
   .erx_reltns[rtcnt].display_seq = p.display_seq, temp_rep->prsnl[d.seq].erx_reltns[rtcnt].
   parent_entity_id = p.parent_entity_id,
   temp_rep->prsnl[d.seq].erx_reltns[rtcnt].parent_entity_name = p.parent_entity_name, temp_rep->
   prsnl[d.seq].erx_reltns[rtcnt].prsnl_reltn_type_code_value = p.reltn_type_cd, temp_rep->prsnl[d
   .seq].erx_reltns[rtcnt].service_level_mask = e.service_level_nbr,
   temp_rep->prsnl[d.seq].erx_reltns[rtcnt].beg_effective_dt_tm = e.beg_effective_dt_tm, temp_rep->
   prsnl[d.seq].erx_reltns[rtcnt].end_effective_dt_tm = e.end_effective_dt_tm, temp_rep->prsnl[d.seq]
   .erx_reltns[rtcnt].status_code_value = e.status_cd,
   temp_rep->prsnl[d.seq].erx_reltns[rtcnt].error_code_value = e.error_cd, temp_rep->prsnl[d.seq].
   erx_reltns[rtcnt].error_desc = e.error_desc, ccnt = 0,
   ctcnt = 0, stat = alterlist(temp_rep->prsnl[d.seq].erx_reltns[rtcnt].child_reltns,10)
  DETAIL
   IF (c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ccnt = (ccnt+ 1), ctcnt = (ctcnt+ 1)
    IF (ccnt > 10)
     stat = alterlist(temp_rep->prsnl[d.seq].erx_reltns[rtcnt].child_reltns,(ctcnt+ 10)), ccnt = 1
    ENDIF
    temp_rep->prsnl[d.seq].erx_reltns[rtcnt].child_reltns[ctcnt].display_seq = c.display_seq,
    temp_rep->prsnl[d.seq].erx_reltns[rtcnt].child_reltns[ctcnt].parent_entity_id = c
    .parent_entity_id, temp_rep->prsnl[d.seq].erx_reltns[rtcnt].child_reltns[ctcnt].
    parent_entity_name = c.parent_entity_name,
    temp_rep->prsnl[d.seq].erx_reltns[rtcnt].child_reltns[ctcnt].prsnl_reltn_child_id = c
    .prsnl_reltn_child_id
   ELSEIF (c.end_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
    FOR (i = 1 TO alias_cnt)
      IF ((c.parent_entity_id=temp_rep->prsnl[d.seq].spi[i].prsnl_alias_id))
       ccnt = (ccnt+ 1), ctcnt = (ctcnt+ 1)
       IF (ccnt > 10)
        stat = alterlist(temp_rep->prsnl[d.seq].erx_reltns[rtcnt].child_reltns,(ctcnt+ 10)), ccnt = 1
       ENDIF
       temp_rep->prsnl[d.seq].erx_reltns[rtcnt].child_reltns[ctcnt].display_seq = c.display_seq,
       temp_rep->prsnl[d.seq].erx_reltns[rtcnt].child_reltns[ctcnt].parent_entity_id = c
       .parent_entity_id, temp_rep->prsnl[d.seq].erx_reltns[rtcnt].child_reltns[ctcnt].
       parent_entity_name = c.parent_entity_name,
       temp_rep->prsnl[d.seq].erx_reltns[rtcnt].child_reltns[ctcnt].prsnl_reltn_child_id = c
       .prsnl_reltn_child_id, i = (alias_cnt+ 1)
      ENDIF
    ENDFOR
   ENDIF
  FOOT  p.prsnl_reltn_id
   stat = alterlist(temp_rep->prsnl[d.seq].erx_reltns[rtcnt].child_reltns,ctcnt), temp_rep->prsnl[d
   .seq].erx_reltns[rtcnt].child_cnt = ctcnt
  FOOT  d.seq
   stat = alterlist(temp_rep->prsnl[d.seq].erx_reltns,rtcnt), temp_rep->prsnl[d.seq].reltn_cnt =
   rtcnt
  WITH nocounter
 ;end select
 DECLARE prsnl_spi_alias_cnt = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(pcnt))
  PLAN (d)
  ORDER BY d.seq
  HEAD d.seq
   erx_cnt = size(temp_rep->prsnl[d.seq].erx_reltns,5), prsnl_spi_alias_cnt = temp_rep->prsnl[d.seq].
   spi_cnt
  DETAIL
   pos = 0
   FOR (i = 1 TO temp_rep->prsnl[d.seq].spi_cnt)
     temp_rep->prsnl[d.seq].spi[i].unassociated_ind = 1
   ENDFOR
   FOR (i = 1 TO prsnl_spi_alias_cnt)
     FOR (e = 1 TO erx_cnt)
      erx_child_cnt = size(temp_rep->prsnl[d.seq].erx_reltns[e].child_reltns,5),
      FOR (c = 1 TO erx_child_cnt)
        IF ((temp_rep->prsnl[d.seq].spi[i].prsnl_alias_id=temp_rep->prsnl[d.seq].erx_reltns[e].
        child_reltns[c].parent_entity_id)
         AND (temp_rep->prsnl[d.seq].erx_reltns[e].child_reltns[c].parent_entity_name="PRSNL_ALIAS"))
         temp_rep->prsnl[d.seq].spi[i].unassociated_ind = 0
        ENDIF
      ENDFOR
     ENDFOR
   ENDFOR
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->prsnl,pcnt)
 DECLARE index = i4
 IF (validate(request->unassociated_spi_ind,0)=1)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(temp_rep->prsnl,5))
   PLAN (d
    WHERE (temp_rep->prsnl[d.seq].prsnl_id > 0))
   HEAD d.seq
    index = 1
   DETAIL
    stat = locateval(index,1,size(temp_rep->prsnl[d.seq].spi,5),1,temp_rep->prsnl[d.seq].spi[index].
     unassociated_ind)
    IF (stat > 0)
     temp_rep->prsnl[d.seq].unassociated_spis_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE reltn_pass_ind = i2 WITH protect, noconstant(0)
 DECLARE found_reltn_ind = i4 WITH protect, noconstant(0)
 FOR (p = 1 TO pcnt)
   SET reltn_pass_ind = 0
   IF (prsnl_reltn_cnt > 0)
    SET reltn_pass_ind = 0
    SET found_reltn_ind = 0
    FOR (r = 1 TO temp_rep->prsnl[p].reltn_cnt)
      SET pos = 0
      SET num = 0
      SET pos = locateval(num,1,prsnl_reltn_cnt,temp_rep->prsnl[p].erx_reltns[r].parent_entity_id,
       request->prsnl_reltns[num].parent_entity_id,
       temp_rep->prsnl[p].erx_reltns[r].parent_entity_name,request->prsnl_reltns[num].
       parent_entity_name)
      IF (pos > 0)
       SET found_reltn_ind = 1
       SET temp_rep->prsnl[p].erx_reltns[r].load_reltn_ind = 1
       IF (validate(request->inprogress_erx_reltn_ind,0)=1
        AND (request->inprogress_erx_reltn_ind=0)
        AND (temp_rep->prsnl[p].erx_reltns[r].status_code_value=0))
        SET found_reltn_ind = 2
       ENDIF
      ENDIF
    ENDFOR
    IF ((((request->erx_reltn_ind=0)
     AND found_reltn_ind=0) OR ((request->erx_reltn_ind=1)
     AND found_reltn_ind=1)) )
     SET reltn_pass_ind = 1
    ENDIF
   ELSE
    SET reltn_pass_ind = 1
   ENDIF
   IF (validate(request->inprogress_erx_reltn_ind,0)=1
    AND (request->inprogress_erx_reltn_ind=0))
    IF ((temp_rep->prsnl[p].spi_cnt=0)
     AND (temp_rep->prsnl[p].erx_in_progress_ind=1))
     SET reltn_pass_ind = 0
    ENDIF
   ENDIF
   IF ((((temp_rep->prsnl[p].org_valid_ind=1)
    AND org_filter_cnt > 0) OR (org_filter_cnt=0))
    AND reltn_pass_ind=1)
    IF (((validate(request->unassociated_spi_ind,0)=1
     AND (temp_rep->prsnl[p].unassociated_spis_ind=1)) OR (validate(request->unassociated_spi_ind,0)=
    0)) )
     SET prep_cnt = (prep_cnt+ 1)
     SET reply->prsnl[prep_cnt].prsnl_id = temp_rep->prsnl[p].prsnl_id
     SET reply->prsnl[prep_cnt].name_first = temp_rep->prsnl[p].name_first
     SET reply->prsnl[prep_cnt].name_full_formatted = temp_rep->prsnl[p].name_full_formatted
     SET reply->prsnl[prep_cnt].name_last = temp_rep->prsnl[p].name_last
     SET reply->prsnl[prep_cnt].name_middle = temp_rep->prsnl[p].name_middle
     SET reply->prsnl[prep_cnt].name_prefix = temp_rep->prsnl[p].name_prefix
     SET reply->prsnl[prep_cnt].name_suffix = temp_rep->prsnl[p].name_suffix
     SET stat = alterlist(reply->prsnl[prep_cnt].erx_reltns,temp_rep->prsnl[p].reltn_cnt)
     DECLARE rep_reltn = i4 WITH protect, noconstant(0)
     DECLARE child_prsnl_reltn_cnt = i4 WITH protect, noconstant(0)
     FOR (r = 1 TO temp_rep->prsnl[p].reltn_cnt)
       IF ((request->erx_reltn_ind=1)
        AND ((prsnl_reltn_cnt=0) OR (prsnl_reltn_cnt > 0
        AND (temp_rep->prsnl[p].erx_reltns[r].load_reltn_ind=1))) )
        SET rep_reltn = (rep_reltn+ 1)
        SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].beg_effective_dt_tm = temp_rep->prsnl[p].
        erx_reltns[r].beg_effective_dt_tm
        SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].display_seq = temp_rep->prsnl[p].erx_reltns[
        r].display_seq
        SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].end_effective_dt_tm = temp_rep->prsnl[p].
        erx_reltns[r].end_effective_dt_tm
        SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].parent_entity_id = temp_rep->prsnl[p].
        erx_reltns[r].parent_entity_id
        SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].parent_entity_name = temp_rep->prsnl[p].
        erx_reltns[r].parent_entity_name
        SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].prsnl_reltn_id = temp_rep->prsnl[p].
        erx_reltns[r].prsnl_reltn_id
        SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].prsnl_reltn_type_code_value = temp_rep->
        prsnl[p].erx_reltns[r].prsnl_reltn_type_code_value
        SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].service_level_mask = temp_rep->prsnl[p].
        erx_reltns[r].service_level_mask
        SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].status_code_value = temp_rep->prsnl[p].
        erx_reltns[r].status_code_value
        SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].error_code_value = temp_rep->prsnl[p].
        erx_reltns[r].error_code_value
        SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].error_desc = temp_rep->prsnl[p].erx_reltns[r
        ].error_desc
        SET child_prsnl_reltn_cnt = size(temp_rep->prsnl[p].erx_reltns[r].child_reltns,5)
        SET stat = alterlist(reply->prsnl[prep_cnt].erx_reltns[rep_reltn].child_reltns,
         child_prsnl_reltn_cnt)
        FOR (c = 1 TO child_prsnl_reltn_cnt)
          SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].child_reltns[c].display_seq = temp_rep->
          prsnl[p].erx_reltns[r].child_reltns[c].display_seq
          SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].child_reltns[c].parent_entity_id =
          temp_rep->prsnl[p].erx_reltns[r].child_reltns[c].parent_entity_id
          SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].child_reltns[c].parent_entity_name =
          temp_rep->prsnl[p].erx_reltns[r].child_reltns[c].parent_entity_name
          SET reply->prsnl[prep_cnt].erx_reltns[rep_reltn].child_reltns[c].prsnl_reltn_child_id =
          temp_rep->prsnl[p].erx_reltns[r].child_reltns[c].prsnl_reltn_child_id
        ENDFOR
       ENDIF
     ENDFOR
     SET stat = alterlist(reply->prsnl[prep_cnt].erx_reltns,rep_reltn)
     SET stat = alterlist(reply->prsnl[prep_cnt].spi,temp_rep->prsnl[p].spi_cnt)
     FOR (a = 1 TO temp_rep->prsnl[p].spi_cnt)
       SET reply->prsnl[prep_cnt].spi[a].alias = temp_rep->prsnl[p].spi[a].alias
       SET reply->prsnl[prep_cnt].spi[a].prsnl_alias_id = temp_rep->prsnl[p].spi[a].prsnl_alias_id
       SET reply->prsnl[prep_cnt].spi[a].unassociated_ind = temp_rep->prsnl[p].spi[a].
       unassociated_ind
     ENDFOR
     DECLARE npi_size = i4 WITH protect, noconstant(size(temp_rep->prsnl[p].npi,5))
     SET stat = alterlist(reply->prsnl[prep_cnt].npi,npi_size)
     FOR (n = 1 TO npi_size)
      SET reply->prsnl[prep_cnt].npi[n].alias = temp_rep->prsnl[p].npi[n].alias
      SET reply->prsnl[prep_cnt].npi[n].prsnl_alias_id = temp_rep->prsnl[p].npi[n].prsnl_alias_id
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->prsnl,prep_cnt)
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
