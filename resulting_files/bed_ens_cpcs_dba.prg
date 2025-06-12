CREATE PROGRAM bed_ens_cpcs:dba
 IF ( NOT (validate(history_cpc_rec,0)))
  RECORD history_cpc_rec(
    1 br_cpc_id = f8
    1 logical_domain_id = f8
    1 br_cpc_name = vc
    1 tax_id_nbr_txt = vc
    1 cpc_site_id_txt = vc
    1 active_ind = i2
    1 orig_br_cpc_id = f8
    1 beg_effective_dt_tm = dq8
    1 end_effective_dt_tm = dq8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(history_cpc_ep_reltn,0)))
  RECORD history_cpc_ep_reltn(
    1 br_cpc_elig_prov_reltn_id = f8
    1 br_cpc_id = f8
    1 br_eligible_provider_id = f8
    1 active_ind = i2
    1 orig_br_cpc_elig_prov_reltn_id = f8
    1 beg_effective_dt_tm = dq8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(history_cpc_loc_reltn,0)))
  RECORD history_cpc_loc_reltn(
    1 br_cpc_loc_reltn_id = f8
    1 br_cpc_id = f8
    1 location_id = f8
    1 active_ind = i2
    1 orig_br_cpc_loc_reltn_id = f8
    1 beg_effective_dt_tm = dq8
  ) WITH protect
 ENDIF
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
 DECLARE no_change_flag = i4 WITH protect, constant(0)
 DECLARE add_flag = i4 WITH protect, constant(1)
 DECLARE update_flag = i4 WITH protect, constant(2)
 DECLARE delete_flag = i4 WITH protect, constant(3)
 IF ( NOT (validate(cs43_business_cd)))
  DECLARE cs43_business_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS"))
 ENDIF
 IF ( NOT (validate(cs212_business_cd)))
  DECLARE cs212_business_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"BUSINESS"))
 ENDIF
 DECLARE size_of_eps = i4 WITH protect, noconstant(size(request->cpc.eligible_providers,5))
 DECLARE size_of_locs = i4 WITH protect, noconstant(size(request->cpc.units,5))
 DECLARE logical_domain_id = f8 WITH protect, noconstant(bedgetlogicaldomain(0))
 DECLARE addcpc(dummyvar=i2) = null
 DECLARE modifycpc(dummyvar=i2) = null
 DECLARE removecpc(dummyvar=i2) = null
 DECLARE handleeps(dummyvar=i2) = null
 DECLARE associateep(currentep=i4) = null
 DECLARE deassociateep(currentep=i4) = null
 DECLARE handleunits(currentloc=i4) = null
 DECLARE associateunits(currentloc=i4) = null
 DECLARE deassociateunits(dummyvar=i2) = null
 DECLARE handleaddressadd(dummyvar=i2) = null
 DECLARE handleaddressmodify(dummyvar=i2) = null
 DECLARE handlephoneadd(dummyvar=i2) = null
 DECLARE handlephonemodify(dummyvar=i2) = null
 DECLARE getnextbedrockseqvalue(dummyvar=i2) = f8
 IF (validate(debug,0)=1)
  CALL bedlogmessage("CPC information")
  CALL echorecord(request->cpc)
 ENDIF
 CASE (request->cpc.action_flag)
  OF no_change_flag:
   SET dummyvar = 0
  OF add_flag:
   CALL addcpc(0)
  OF update_flag:
   CALL modifycpc(0)
  OF delete_flag:
   CALL removecpc(0)
  ELSE
   CALL bederror("Error001: Invalid CPC action flag.")
 ENDCASE
 IF (size_of_eps > 0)
  CALL handleeps(0)
 ENDIF
 IF (size(request->cpc.units,5) > 0)
  CALL handleunits(0)
 ENDIF
 IF ((request->cpc.address.action_flag=add_flag))
  CALL handleaddressadd(0)
 ELSEIF ((request->cpc.address.action_flag=update_flag))
  CALL handleaddressmodify(0)
 ENDIF
 IF ((request->cpc.phone.action_flag=add_flag))
  CALL handlephoneadd(0)
 ELSEIF ((request->cpc.phone.action_flag=update_flag))
  CALL handlephonemodify(0)
 ENDIF
 SUBROUTINE addcpc(dummyvar)
   SET new_cpc_id = getnextbedrockseqvalue(0)
   SELECT INTO "nl:"
    FROM br_cpc cpc
    WHERE (cpc.br_cpc_name=request->cpc.cpc_name)
     AND (cpc.tax_id_nbr_txt=request->cpc.cpc_tin)
     AND (cpc.cpc_site_id_txt=request->cpc.cpc_practice_site_id)
     AND cpc.active_ind=0
     AND cpc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
    DETAIL
     history_cpc_rec->br_cpc_id = cpc.br_cpc_id, history_cpc_rec->logical_domain_id = cpc
     .logical_domain_id, history_cpc_rec->br_cpc_name = cpc.br_cpc_name,
     history_cpc_rec->tax_id_nbr_txt = cpc.tax_id_nbr_txt, history_cpc_rec->cpc_site_id_txt = cpc
     .cpc_site_id_txt, history_cpc_rec->active_ind = cpc.active_ind,
     history_cpc_rec->orig_br_cpc_id = cpc.orig_br_cpc_id, history_cpc_rec->beg_effective_dt_tm =
     cnvtdatetime(cpc.beg_effective_dt_tm), history_cpc_rec->end_effective_dt_tm = cnvtdatetime(cpc
      .end_effective_dt_tm)
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "Error001: Error while checking if an inactive effective CPC exists with this name/tin/siteid.")
   IF (curqual=1)
    INSERT  FROM br_cpc cpc
     SET cpc.br_cpc_id = new_cpc_id, cpc.logical_domain_id = history_cpc_rec->logical_domain_id, cpc
      .br_cpc_name = history_cpc_rec->br_cpc_name,
      cpc.tax_id_nbr_txt = history_cpc_rec->tax_id_nbr_txt, cpc.cpc_site_id_txt = history_cpc_rec->
      cpc_site_id_txt, cpc.active_ind = history_cpc_rec->active_ind,
      cpc.orig_br_cpc_id = history_cpc_rec->orig_br_cpc_id, cpc.beg_effective_dt_tm = cnvtdatetime(
       history_cpc_rec->beg_effective_dt_tm), cpc.end_effective_dt_tm = cnvtdatetime(curdate,curtime3
       ),
      cpc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpc.updt_applctx = reqinfo->updt_applctx, cpc
      .updt_cnt = 0,
      cpc.updt_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error002: Error while inserting a history row on br_cpc table")
    UPDATE  FROM br_cpc cpc
     SET cpc.active_ind = 1, cpc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cpc.updt_dt_tm
       = cnvtdatetime(curdate,curtime3),
      cpc.updt_applctx = reqinfo->updt_applctx, cpc.updt_task = reqinfo->updt_task, cpc.updt_id =
      reqinfo->updt_id,
      cpc.updt_cnt = (cpc.updt_cnt+ 1)
     WHERE (cpc.br_cpc_id=history_cpc_rec->br_cpc_id)
     WITH nocounter
    ;end update
    CALL bederrorcheck("Error003: Error while updating the 'current' row for this CPC")
    SET request->cpc.cpc_id = history_cpc_rec->br_cpc_id
   ELSE
    INSERT  FROM br_cpc cpc
     SET cpc.br_cpc_id = new_cpc_id, cpc.logical_domain_id = logical_domain_id, cpc.br_cpc_name =
      request->cpc.cpc_name,
      cpc.tax_id_nbr_txt = request->cpc.cpc_tin, cpc.cpc_site_id_txt = request->cpc.
      cpc_practice_site_id, cpc.active_ind = 1,
      cpc.orig_br_cpc_id = new_cpc_id, cpc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cpc
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
      cpc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpc.updt_applctx = reqinfo->updt_applctx, cpc
      .updt_task = reqinfo->updt_task,
      cpc.updt_id = reqinfo->updt_id, cpc.updt_cnt = 1
     WITH nocounter
    ;end insert
    SET request->cpc.cpc_id = new_cpc_id
   ENDIF
   CALL bederrorcheck("Error004: Unsuccessful addition of this CPC.")
 END ;Subroutine
 SUBROUTINE modifycpc(dummyvar)
   SET new_cpc_id = getnextbedrockseqvalue(0)
   SELECT INTO "nl:"
    FROM br_cpc cpc
    WHERE (cpc.br_cpc_id=request->cpc.cpc_id)
    DETAIL
     history_cpc_rec->br_cpc_id = cpc.br_cpc_id, history_cpc_rec->logical_domain_id = cpc
     .logical_domain_id, history_cpc_rec->br_cpc_name = cpc.br_cpc_name,
     history_cpc_rec->tax_id_nbr_txt = cpc.tax_id_nbr_txt, history_cpc_rec->cpc_site_id_txt = cpc
     .cpc_site_id_txt, history_cpc_rec->active_ind = cpc.active_ind,
     history_cpc_rec->orig_br_cpc_id = cpc.orig_br_cpc_id, history_cpc_rec->beg_effective_dt_tm =
     cnvtdatetime(cpc.beg_effective_dt_tm), history_cpc_rec->end_effective_dt_tm = cnvtdatetime(cpc
      .end_effective_dt_tm)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error005: Error while gettign the to-be-modified cpc")
   INSERT  FROM br_cpc cpc
    SET cpc.br_cpc_id = new_cpc_id, cpc.logical_domain_id = history_cpc_rec->logical_domain_id, cpc
     .br_cpc_name = history_cpc_rec->br_cpc_name,
     cpc.tax_id_nbr_txt = history_cpc_rec->tax_id_nbr_txt, cpc.cpc_site_id_txt = history_cpc_rec->
     cpc_site_id_txt, cpc.active_ind = history_cpc_rec->active_ind,
     cpc.orig_br_cpc_id = history_cpc_rec->orig_br_cpc_id, cpc.beg_effective_dt_tm = cnvtdatetime(
      history_cpc_rec->beg_effective_dt_tm), cpc.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     cpc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpc.updt_applctx = reqinfo->updt_applctx, cpc
     .updt_cnt = 0,
     cpc.updt_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error006: Error while inserting a historical ineffective row")
   UPDATE  FROM br_cpc cpc
    SET cpc.active_ind = 1, cpc.br_cpc_name = request->cpc.cpc_name, cpc.tax_id_nbr_txt = request->
     cpc.cpc_tin,
     cpc.cpc_site_id_txt = request->cpc.cpc_practice_site_id, cpc.beg_effective_dt_tm = cnvtdatetime(
      curdate,curtime3), cpc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cpc.updt_applctx = reqinfo->updt_applctx, cpc.updt_task = reqinfo->updt_task, cpc.updt_id =
     reqinfo->updt_id,
     cpc.updt_cnt = (cpc.updt_cnt+ 1)
    WHERE (cpc.br_cpc_id=history_cpc_rec->br_cpc_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error007: Unsuccessful modification of this CPC.")
 END ;Subroutine
 SUBROUTINE removecpc(dummyvar)
   DELETE  FROM address a
    WHERE (a.parent_entity_id=request->cpc.cpc_id)
   ;end delete
   DELETE  FROM phone p
    WHERE (p.parent_entity_id=request->cpc.cpc_id)
   ;end delete
   SELECT INTO "nl:"
    FROM br_cpc_loc_reltn bclr
    WHERE (bclr.br_cpc_id=request->cpc.cpc_id)
     AND bclr.active_ind=1
     AND bclr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
    DETAIL
     size_of_locs = (size_of_locs+ 1), stat = alterlist(request->cpc.units,size_of_locs), request->
     cpc.units[size_of_locs].unit_code_value = bclr.location_cd,
     request->cpc.units[size_of_locs].action_flag = delete_flag
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error008: Error while getting the locations")
   CALL handleunits(0)
   SELECT INTO "nl:"
    FROM br_cpc_elig_prov_reltn bcepr
    WHERE (bcepr.br_cpc_id=request->cpc.cpc_id)
     AND bcepr.active_ind=1
     AND bcepr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
    DETAIL
     size_of_eps = (size_of_eps+ 1), stat = alterlist(request->cpc.eligible_providers,size_of_eps),
     request->cpc.eligible_providers[size_of_eps].eligible_provider_id = bcepr
     .br_eligible_provider_id,
     request->cpc.eligible_providers[size_of_eps].action_flag = delete_flag
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error009: Error while getting the locations")
   CALL handleeps(0)
   SELECT INTO "nl:"
    FROM br_cpc cpc
    WHERE (cpc.br_cpc_id=request->cpc.cpc_id)
    DETAIL
     history_cpc_rec->logical_domain_id = cpc.logical_domain_id, history_cpc_rec->br_cpc_name = cpc
     .br_cpc_name, history_cpc_rec->tax_id_nbr_txt = cpc.tax_id_nbr_txt,
     history_cpc_rec->cpc_site_id_txt = cpc.cpc_site_id_txt, history_cpc_rec->active_ind = cpc
     .active_ind, history_cpc_rec->orig_br_cpc_id = cpc.orig_br_cpc_id,
     history_cpc_rec->beg_effective_dt_tm = cnvtdatetime(cpc.beg_effective_dt_tm)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error010: Error while getting the to-be-removed cpc.")
   SET history_cpc_rec->br_cpc_id = getnextbedrockseqvalue(0)
   INSERT  FROM br_cpc cpc
    SET cpc.br_cpc_id = history_cpc_rec->br_cpc_id, cpc.logical_domain_id = history_cpc_rec->
     logical_domain_id, cpc.br_cpc_name = history_cpc_rec->br_cpc_name,
     cpc.tax_id_nbr_txt = history_cpc_rec->tax_id_nbr_txt, cpc.cpc_site_id_txt = history_cpc_rec->
     cpc_site_id_txt, cpc.active_ind = history_cpc_rec->active_ind,
     cpc.orig_br_cpc_id = history_cpc_rec->orig_br_cpc_id, cpc.beg_effective_dt_tm = cnvtdatetime(
      history_cpc_rec->beg_effective_dt_tm), cpc.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     cpc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpc.updt_applctx = reqinfo->updt_applctx, cpc
     .updt_cnt = 0,
     cpc.updt_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error011: Error while writing a proper history row while removing a cpc.")
   UPDATE  FROM br_cpc cpc
    SET cpc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cpc.active_ind = 0, cpc.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     cpc.updt_applctx = reqinfo->updt_applctx, cpc.updt_task = reqinfo->updt_task, cpc.updt_id =
     reqinfo->updt_id,
     cpc.updt_cnt = (cpc.updt_cnt+ 1)
    WHERE (cpc.br_cpc_id=request->cpc.cpc_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck(
    "Error012: Error while updating the current row to have the active_ind = 0 for the request->cpc_id"
    )
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE handleeps(dummyvar)
   SET x = 0
   FOR (x = 1 TO size_of_eps)
     IF ((request->cpc.eligible_providers[x].action_flag=delete_flag))
      CALL deassociateep(x)
     ENDIF
   ENDFOR
   CALL bederrorcheck("Error013: Error while iterating the list of EPs")
   SET x = 0
   FOR (x = 1 TO size_of_eps)
     IF ((request->cpc.eligible_providers[x].action_flag=add_flag))
      CALL associateep(x)
     ENDIF
   ENDFOR
   CALL bederrorcheck("Error014: Error while iterating the list of EPs")
 END ;Subroutine
 SUBROUTINE associateep(currentep)
   SELECT INTO "nl:"
    FROM br_cpc_elig_prov_reltn reltn
    WHERE (reltn.br_eligible_provider_id=request->cpc.eligible_providers[currentep].
    eligible_provider_id)
     AND (reltn.br_cpc_id=request->cpc.cpc_id)
     AND reltn.active_ind=0
     AND reltn.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
    DETAIL
     history_cpc_ep_reltn->br_cpc_elig_prov_reltn_id = reltn.br_cpc_elig_prov_reltn_id,
     history_cpc_ep_reltn->br_cpc_id = reltn.br_cpc_id, history_cpc_ep_reltn->br_eligible_provider_id
      = reltn.br_eligible_provider_id,
     history_cpc_ep_reltn->active_ind = reltn.active_ind, history_cpc_ep_reltn->
     orig_br_cpc_elig_prov_reltn_id = reltn.orig_br_cpc_elig_prov_reltn_id, history_cpc_ep_reltn->
     beg_effective_dt_tm = cnvtdatetime(reltn.beg_effective_dt_tm)
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "Error015: Error while checking if an inactive effective CPC-EP reltion row exists. ")
   IF (curqual=1)
    UPDATE  FROM br_cpc_elig_prov_reltn reltn
     SET reltn.active_ind = 1, reltn.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), reltn
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      reltn.updt_applctx = reqinfo->updt_applctx, reltn.updt_task = reqinfo->updt_task, reltn.updt_id
       = reqinfo->updt_id,
      reltn.updt_cnt = (reltn.updt_cnt+ 1)
     WHERE (reltn.br_cpc_elig_prov_reltn_id=history_cpc_ep_reltn->br_cpc_elig_prov_reltn_id)
     WITH nocounter
    ;end update
    CALL bederrorcheck("Error016: Error while updating the 'current' cpc-ep relation")
    SET history_cpc_ep_reltn->br_cpc_elig_prov_reltn_id = getnextbedrockseqvalue(0)
    INSERT  FROM br_cpc_elig_prov_reltn reltn
     SET reltn.br_cpc_elig_prov_reltn_id = history_cpc_ep_reltn->br_cpc_elig_prov_reltn_id, reltn
      .br_cpc_id = history_cpc_ep_reltn->br_cpc_id, reltn.br_eligible_provider_id =
      history_cpc_ep_reltn->br_eligible_provider_id,
      reltn.active_ind = history_cpc_ep_reltn->active_ind, reltn.orig_br_cpc_elig_prov_reltn_id =
      history_cpc_ep_reltn->orig_br_cpc_elig_prov_reltn_id, reltn.beg_effective_dt_tm = cnvtdatetime(
       history_cpc_ep_reltn->beg_effective_dt_tm),
      reltn.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), reltn.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), reltn.updt_applctx = reqinfo->updt_applctx,
      reltn.updt_cnt = 0, reltn.updt_id = reqinfo->updt_id, reltn.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error017: Error while inserting a histroy for the cpc-ep relation")
   ELSE
    SET br_cpc_elig_prov_reltn_id = getnextbedrockseqvalue(0)
    INSERT  FROM br_cpc_elig_prov_reltn reltn
     SET reltn.br_cpc_elig_prov_reltn_id = br_cpc_elig_prov_reltn_id, reltn.br_cpc_id = request->cpc.
      cpc_id, reltn.br_eligible_provider_id = request->cpc.eligible_providers[currentep].
      eligible_provider_id,
      reltn.active_ind = 1, reltn.orig_br_cpc_elig_prov_reltn_id = br_cpc_elig_prov_reltn_id, reltn
      .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      reltn.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), reltn.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), reltn.updt_applctx = reqinfo->updt_applctx,
      reltn.updt_cnt = 0, reltn.updt_id = reqinfo->updt_id, reltn.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error018: Unsuccessful handling of the EPs for this CPC.")
   ENDIF
 END ;Subroutine
 SUBROUTINE deassociateep(currentep)
   SELECT INTO "nl:"
    FROM br_cpc_elig_prov_reltn reltn
    WHERE (reltn.br_eligible_provider_id=request->cpc.eligible_providers[currentep].
    eligible_provider_id)
     AND reltn.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
     AND (reltn.br_cpc_id=request->cpc.cpc_id)
     AND reltn.active_ind=1
    DETAIL
     history_cpc_ep_reltn->br_cpc_id = reltn.br_cpc_id, history_cpc_ep_reltn->br_eligible_provider_id
      = reltn.br_eligible_provider_id, history_cpc_ep_reltn->active_ind = reltn.active_ind,
     history_cpc_ep_reltn->orig_br_cpc_elig_prov_reltn_id = reltn.br_cpc_elig_prov_reltn_id,
     history_cpc_ep_reltn->beg_effective_dt_tm = reltn.beg_effective_dt_tm
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error019: Error while selecting an existing active-effective cpc-ep relation")
   SET history_cpc_ep_reltn->br_cpc_elig_prov_reltn_id = getnextbedrockseqvalue(0)
   INSERT  FROM br_cpc_elig_prov_reltn reltn
    SET reltn.br_cpc_elig_prov_reltn_id = history_cpc_ep_reltn->br_cpc_elig_prov_reltn_id, reltn
     .br_cpc_id = history_cpc_ep_reltn->br_cpc_id, reltn.br_eligible_provider_id =
     history_cpc_ep_reltn->br_eligible_provider_id,
     reltn.active_ind = history_cpc_ep_reltn->active_ind, reltn.orig_br_cpc_elig_prov_reltn_id =
     history_cpc_ep_reltn->orig_br_cpc_elig_prov_reltn_id, reltn.beg_effective_dt_tm = cnvtdatetime(
      history_cpc_ep_reltn->beg_effective_dt_tm),
     reltn.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), reltn.updt_dt_tm = cnvtdatetime(
      curdate,curtime3), reltn.updt_applctx = reqinfo->updt_applctx,
     reltn.updt_cnt = 0, reltn.updt_id = reqinfo->updt_id, reltn.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error020: Error while inserting a histroy for the cpc-ep relation")
   UPDATE  FROM br_cpc_elig_prov_reltn reltn
    SET reltn.active_ind = 0, reltn.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), reltn
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     reltn.updt_applctx = reqinfo->updt_applctx, reltn.updt_task = reqinfo->updt_task, reltn.updt_id
      = reqinfo->updt_id,
     reltn.updt_cnt = (reltn.updt_cnt+ 1)
    WHERE (reltn.br_cpc_elig_prov_reltn_id=history_cpc_ep_reltn->orig_br_cpc_elig_prov_reltn_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error021: Error while updating the 'current' cpc-ep relation")
 END ;Subroutine
 SUBROUTINE handleunits(dummyvar)
  FOR (i = 1 TO size(request->cpc.units,5))
    IF ((request->cpc.units[i].action_flag=add_flag))
     CALL associateunits(i)
    ELSEIF ((request->cpc.units[i].action_flag=delete_flag))
     CALL deassociateunits(i)
    ENDIF
  ENDFOR
  CALL bederrorcheck("Error022: Unsuccessful handling of the locations for this CPC.")
 END ;Subroutine
 SUBROUTINE associateunits(currentloc)
   SELECT INTO "nl:"
    FROM br_cpc_loc_reltn bclr
    WHERE (bclr.location_cd=request->cpc.units[currentloc].unit_code_value)
     AND (bclr.br_cpc_id=request->cpc.cpc_id)
     AND bclr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
     AND bclr.active_ind=0
    DETAIL
     history_cpc_loc_reltn->br_cpc_loc_reltn_id = bclr.br_cpc_loc_reltn_id, history_cpc_loc_reltn->
     br_cpc_id = bclr.br_cpc_id, history_cpc_loc_reltn->location_id = bclr.location_cd,
     history_cpc_loc_reltn->active_ind = bclr.active_ind, history_cpc_loc_reltn->
     orig_br_cpc_loc_reltn_id = bclr.orig_br_cpc_loc_reltn_id, history_cpc_loc_reltn->
     beg_effective_dt_tm = cnvtdatetime(bclr.beg_effective_dt_tm)
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "Error023: Error while getting the already existing logically deleted location-cpc relation, if it exists."
    )
   IF (curqual=1)
    SET next_br_cpc_loc_reltn_id = getnextbedrockseqvalue(0)
    INSERT  FROM br_cpc_loc_reltn bclr
     SET bclr.br_cpc_loc_reltn_id = next_br_cpc_loc_reltn_id, bclr.br_cpc_id = history_cpc_loc_reltn
      ->br_cpc_id, bclr.location_cd = history_cpc_loc_reltn->location_id,
      bclr.active_ind = 0, bclr.orig_br_cpc_loc_reltn_id = history_cpc_loc_reltn->
      orig_br_cpc_loc_reltn_id, bclr.beg_effective_dt_tm = cnvtdatetime(history_cpc_loc_reltn->
       beg_effective_dt_tm),
      bclr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bclr.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), bclr.updt_applctx = reqinfo->updt_applctx,
      bclr.updt_task = reqinfo->updt_task, bclr.updt_id = reqinfo->updt_id, bclr.updt_cnt = 0
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error024: Error while writing a history row on br_cpc_loc_reltn table.")
    UPDATE  FROM br_cpc_loc_reltn bclr
     SET bclr.active_ind = 1, bclr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bclr
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
     WHERE (bclr.br_cpc_loc_reltn_id=history_cpc_loc_reltn->br_cpc_loc_reltn_id)
     WITH nocounter
    ;end update
    CALL bederrorcheck("Error025: Error while updating the current row on br_cpc_loc_reltn table.")
   ELSE
    SET cpc_loc_rel_id = getnextbedrockseqvalue(0)
    INSERT  FROM br_cpc_loc_reltn bclr
     SET bclr.br_cpc_loc_reltn_id = cpc_loc_rel_id, bclr.br_cpc_id = request->cpc.cpc_id, bclr
      .location_cd = request->cpc.units[currentloc].unit_code_value,
      bclr.active_ind = 1, bclr.orig_br_cpc_loc_reltn_id = cpc_loc_rel_id, bclr.beg_effective_dt_tm
       = cnvtdatetime(curdate,curtime3),
      bclr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), bclr.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), bclr.updt_applctx = reqinfo->updt_applctx,
      bclr.updt_task = reqinfo->updt_task, bclr.updt_id = reqinfo->updt_id, bclr.updt_cnt = 0
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error026: Error while inserting a relation row on br_cpc_loc_reltn table.")
   ENDIF
 END ;Subroutine
 SUBROUTINE deassociateunits(currentloc)
   SELECT INTO "nl:"
    FROM br_cpc_loc_reltn bclr
    WHERE (bclr.location_cd=request->cpc.units[currentloc].unit_code_value)
     AND (bclr.br_cpc_id=request->cpc.cpc_id)
     AND bclr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
     AND bclr.active_ind=1
    DETAIL
     history_cpc_loc_reltn->br_cpc_loc_reltn_id = bclr.br_cpc_loc_reltn_id, history_cpc_loc_reltn->
     br_cpc_id = bclr.br_cpc_id, history_cpc_loc_reltn->location_id = bclr.location_cd,
     history_cpc_loc_reltn->active_ind = bclr.active_ind, history_cpc_loc_reltn->
     orig_br_cpc_loc_reltn_id = bclr.orig_br_cpc_loc_reltn_id, history_cpc_loc_reltn->
     beg_effective_dt_tm = cnvtdatetime(bclr.beg_effective_dt_tm)
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "Error027: Error while getting the to-be-logically-deleted row on the br_cpc_loc_reltn table.")
   SET next_br_cpc_loc_reltn_id = getnextbedrockseqvalue(0)
   INSERT  FROM br_cpc_loc_reltn bclr
    SET bclr.br_cpc_loc_reltn_id = next_br_cpc_loc_reltn_id, bclr.br_cpc_id = history_cpc_loc_reltn->
     br_cpc_id, bclr.location_cd = history_cpc_loc_reltn->location_id,
     bclr.active_ind = 1, bclr.orig_br_cpc_loc_reltn_id = history_cpc_loc_reltn->
     orig_br_cpc_loc_reltn_id, bclr.beg_effective_dt_tm = cnvtdatetime(history_cpc_loc_reltn->
      beg_effective_dt_tm),
     bclr.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bclr.updt_dt_tm = cnvtdatetime(
      curdate,curtime3), bclr.updt_applctx = reqinfo->updt_applctx,
     bclr.updt_task = reqinfo->updt_task, bclr.updt_id = reqinfo->updt_id, bclr.updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error028: Error while writing a history row on the br_cpc_loc_reltn table.")
   UPDATE  FROM br_cpc_loc_reltn bclr
    SET bclr.active_ind = 0, bclr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bclr.updt_cnt
      = (bclr.updt_cnt+ 1),
     bclr.updt_applctx = reqinfo->updt_applctx, bclr.updt_task = reqinfo->updt_task, bclr.updt_id =
     reqinfo->updt_id,
     bclr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (bclr.br_cpc_loc_reltn_id=history_cpc_loc_reltn->br_cpc_loc_reltn_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("Error029: Unsuccessful handling of the units for this CPC.")
 END ;Subroutine
 SUBROUTINE handleaddressadd(dummyvar)
   SET new_value = 0.0
   SELECT INTO "nl:"
    z = seq(address_seq,nextval)
    FROM dual
    DETAIL
     new_value = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error030: Problems occurred retrieving next address sequence value.")
   INSERT  FROM address a
    SET a.address_id = new_value, a.active_ind = 1, a.parent_entity_name = "BR_CPC",
     a.parent_entity_id = request->cpc.cpc_id, a.address_type_cd = cs212_business_cd, a.street_addr
      = request->cpc.address.street_addr1,
     a.street_addr2 = request->cpc.address.street_addr2, a.street_addr3 = request->cpc.address.
     street_addr3, a.street_addr4 = request->cpc.address.street_addr4,
     a.city = request->cpc.address.city, a.state_cd = request->cpc.address.state_code_value, a
     .zipcode = request->cpc.address.zipcode,
     a.county_cd = request->cpc.address.county_code_value, a.country_cd = request->cpc.address.
     country_code_value, a.contact_name = request->cpc.address.contact_name,
     a.comment_txt = request->cpc.address.comment_txt, a.updt_cnt = 0, a.updt_applctx = reqinfo->
     updt_applctx,
     a.updt_task = reqinfo->updt_task, a.updt_id = reqinfo->updt_id, a.updt_dt_tm = cnvtdatetime(
      curdate,curtime3)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error031: Unsuccessful insert of address for this CPC.")
 END ;Subroutine
 SUBROUTINE handleaddressmodify(dummyvar)
  UPDATE  FROM address a
   SET a.street_addr = request->cpc.address.street_addr1, a.street_addr2 = request->cpc.address.
    street_addr2, a.street_addr3 = request->cpc.address.street_addr3,
    a.street_addr4 = request->cpc.address.street_addr4, a.city = request->cpc.address.city, a
    .state_cd = request->cpc.address.state_code_value,
    a.zipcode = request->cpc.address.zipcode, a.county_cd = request->cpc.address.county_code_value, a
    .country_cd = request->cpc.address.country_code_value,
    a.contact_name = request->cpc.address.contact_name, a.comment_txt = request->cpc.address.
    comment_txt, a.updt_cnt = (a.updt_cnt+ 1),
    a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task, a.updt_id = reqinfo->
    updt_id,
    a.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (a.address_id=request->cpc.address.address_id)
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error032: Unsuccessful modify of address for this CPC.")
 END ;Subroutine
 SUBROUTINE handlephoneadd(dummyvar)
   SET new_value = 0.0
   SELECT INTO "nl:"
    z = seq(phone_seq,nextval)
    FROM dual
    DETAIL
     new_value = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error030: Problems occurred retrieving next address sequence value.")
   INSERT  FROM phone p
    SET p.phone_id = new_value, p.active_ind = 1, p.phone_format_cd = request->cpc.phone.
     phone_format_code_value,
     p.phone_num = request->cpc.phone.phone_num, p.phone_type_cd = cs43_business_cd, p.contact =
     request->cpc.phone.contact,
     p.call_instruction = request->cpc.phone.call_instruction, p.extension = request->cpc.phone.
     extension, p.parent_entity_name = "BR_CPC",
     p.parent_entity_id = request->cpc.cpc_id, p.active_ind = 1, p.updt_cnt = 0,
     p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_id = reqinfo->
     updt_id,
     p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error033: Unsuccessful handling of the phone addition for this CPC.")
 END ;Subroutine
 SUBROUTINE handlephonemodify(dummyvar)
  UPDATE  FROM phone p
   SET p.phone_format_cd = request->cpc.phone.phone_format_code_value, p.phone_num = request->cpc.
    phone.phone_num, p.contact = request->cpc.phone.contact,
    p.call_instruction = request->cpc.phone.call_instruction, p.extension = request->cpc.phone.
    extension, p.updt_cnt = 0,
    p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_id = reqinfo->
    updt_id,
    p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (p.phone_id=request->cpc.phone.phone_id)
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error034: Unsuccessful handling of the phone modification for this CPC.")
 END ;Subroutine
 SUBROUTINE getnextbedrockseqvalue(dummyvar)
   SET new_value = 0.0
   SELECT INTO "nl:"
    z = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     new_value = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error100: Problems occurred retrieving next bedrock sequence value.")
   RETURN(new_value)
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
