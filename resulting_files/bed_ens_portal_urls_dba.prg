CREATE PROGRAM bed_ens_portal_urls:dba
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
 DECLARE code_value_table_name = vc WITH protect, constant("CODE_VALUE")
 DECLARE invitation_provided_code_type = i4 WITH protect, constant(1)
 DECLARE patient_declined_code_type = i4 WITH protect, constant(2)
 DECLARE updatingeffectiverow = i2 WITH protect, noconstant(0)
 DECLARE createportalreltnattribute(reltnid=f8,eventcd=f8,type=i2) = f8
 SUBROUTINE createportalreltnattribute(reltnid,eventcd,type)
   SET updatingeffectiverow = 0
   FREE RECORD url_reltn_attr
   RECORD url_reltn_attr(
     1 br_prtl_url_se_r_cd_r_id = f8
     1 br_portal_url_svc_entity_r_id = f8
     1 portal_attr_cd_value = f8
     1 code_type_flag = i4
     1 beg_effective_dt_tm = f8
     1 active_ind = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM br_prtl_url_se_r_cd_r prtl_r
    PLAN (prtl_r
     WHERE prtl_r.br_portal_url_svc_entity_r_id=reltnid
      AND prtl_r.code_type_flag=type
      AND prtl_r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     IF (prtl_r.active_ind=0)
      IF (eventcd > 0.0)
       updatingeffectiverow = 1
      ENDIF
     ELSE
      IF (prtl_r.portal_attr_cd_value != eventcd)
       updatingeffectiverow = 1
      ENDIF
     ENDIF
     IF (updatingeffectiverow=1)
      url_reltn_attr->br_prtl_url_se_r_cd_r_id = prtl_r.br_prtl_url_se_r_cd_r_id, url_reltn_attr->
      br_portal_url_svc_entity_r_id = prtl_r.br_portal_url_svc_entity_r_id, url_reltn_attr->
      portal_attr_cd_value = prtl_r.portal_attr_cd_value,
      url_reltn_attr->code_type_flag = prtl_r.code_type_flag, url_reltn_attr->beg_effective_dt_tm =
      prtl_r.beg_effective_dt_tm, url_reltn_attr->active_ind = prtl_r.active_ind
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get existing effective row")
   IF (updatingeffectiverow=1)
    SET newid = 0.0
    SELECT INTO "nl:"
     j = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      newid = cnvtreal(j)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Failed to get new relation attribute id")
    INSERT  FROM br_prtl_url_se_r_cd_r prtl_r
     SET prtl_r.br_prtl_url_se_r_cd_r_id = newid, prtl_r.orig_prtl_url_se_r_cd_r_id = url_reltn_attr
      ->br_prtl_url_se_r_cd_r_id, prtl_r.br_portal_url_svc_entity_r_id = url_reltn_attr->
      br_portal_url_svc_entity_r_id,
      prtl_r.portal_attr_cd_value = url_reltn_attr->portal_attr_cd_value, prtl_r.code_type_flag =
      url_reltn_attr->code_type_flag, prtl_r.active_ind = url_reltn_attr->active_ind,
      prtl_r.beg_effective_dt_tm = cnvtdatetime(url_reltn_attr->beg_effective_dt_tm), prtl_r
      .end_effective_dt_tm = cnvtdatetime(curdate,curtime3), prtl_r.updt_id = reqinfo->updt_id,
      prtl_r.updt_cnt = 0, prtl_r.updt_applctx = reqinfo->updt_applctx, prtl_r.updt_task = reqinfo->
      updt_task,
      prtl_r.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed to insert history of prtl attribute.")
    IF (eventcd > 0)
     UPDATE  FROM br_prtl_url_se_r_cd_r prtl_r
      SET prtl_r.active_ind = 1, prtl_r.portal_attr_cd_value = eventcd, prtl_r.beg_effective_dt_tm =
       cnvtdatetime(curdate,curtime3),
       prtl_r.updt_dt_tm = cnvtdatetime(curdate,curtime3), prtl_r.updt_id = reqinfo->updt_id, prtl_r
       .updt_task = reqinfo->updt_task,
       prtl_r.updt_cnt = (prtl_r.updt_cnt+ 1), prtl_r.updt_applctx = reqinfo->updt_applctx
      WHERE prtl_r.br_portal_url_svc_entity_r_id=reltnid
       AND prtl_r.code_type_flag=type
       AND prtl_r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end update
     CALL bederrorcheck("Failed to update existing row.")
    ELSE
     UPDATE  FROM br_prtl_url_se_r_cd_r prtl_r
      SET prtl_r.active_ind = 0, prtl_r.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), prtl_r
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       prtl_r.updt_id = reqinfo->updt_id, prtl_r.updt_task = reqinfo->updt_task, prtl_r.updt_cnt = (
       prtl_r.updt_cnt+ 1),
       prtl_r.updt_applctx = reqinfo->updt_applctx
      WHERE prtl_r.br_portal_url_svc_entity_r_id=reltnid
       AND prtl_r.code_type_flag=type
       AND prtl_r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end update
     CALL bederrorcheck("Failed to inactivate row.")
    ENDIF
   ELSEIF (eventcd > 0.0)
    SELECT INTO "nl:"
     FROM br_prtl_url_se_r_cd_r prtl_r
     PLAN (prtl_r
      WHERE prtl_r.br_portal_url_svc_entity_r_id=reltnid
       AND prtl_r.code_type_flag=type
       AND prtl_r.portal_attr_cd_value=eventcd
       AND prtl_r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     WITH nocounter
    ;end select
    CALL bederrorcheck("Failed to find end-effective row.")
    IF (curqual=0)
     SET newid = 0.0
     SELECT INTO "nl:"
      j = seq(bedrock_seq,nextval)
      FROM dual
      DETAIL
       newid = cnvtreal(j)
      WITH nocounter
     ;end select
     CALL bederrorcheck("Failed to get new relation attribute id")
     INSERT  FROM br_prtl_url_se_r_cd_r prtl_attr
      SET prtl_attr.br_prtl_url_se_r_cd_r_id = newid, prtl_attr.orig_prtl_url_se_r_cd_r_id = newid,
       prtl_attr.br_portal_url_svc_entity_r_id = reltnid,
       prtl_attr.portal_attr_cd_value = eventcd, prtl_attr.code_type_flag = type, prtl_attr
       .active_ind = 1,
       prtl_attr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), prtl_attr.end_effective_dt_tm
        = cnvtdatetime("31-DEC-2100"), prtl_attr.updt_id = reqinfo->updt_id,
       prtl_attr.updt_cnt = 0, prtl_attr.updt_applctx = reqinfo->updt_applctx, prtl_attr.updt_task =
       reqinfo->updt_task,
       prtl_attr.updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WITH nocounter
     ;end insert
     CALL bederrorcheck("Failed to insert url reltn attribute")
     RETURN(newid)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE alias_pool_code_set = i4 WITH protect, constant(263)
 DECLARE alias_type_code_set = i4 WITH protect, constant(4)
 DECLARE ensureportalurls(dummyvar=i2) = null
 DECLARE createportalurl(portalurl=vc) = f8
 DECLARE createportalurlsvcentreltn(urlid=f8,parentname=vc,parentid=f8) = f8
 DECLARE createportalreltnattribute(reltnid=f8,eventcd=f8,type=i2) = f8
 DECLARE addportalurls(x=i4) = null
 DECLARE modifyportalurls(x=i4) = null
 DECLARE modifyccnsandeps(x=i4) = null
 DECLARE modifyaliases(x=i4) = null
 DECLARE inactivateportalurls(x=i4) = null
 SET data_partition_ind = 0
 RANGE OF b IS br_portal_url
 SET data_partition_ind = validate(b.logical_domain_id)
 FREE RANGE b
 IF (data_partition_ind=1)
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
 ENDIF
 CALL ensureportalurls(0)
 SUBROUTINE ensureportalurls(dummyvar)
   FOR (x = 1 TO size(request->urls,5))
     IF ((request->urls[x].action_flag=0))
      CALL modifyccnsandeps(x)
      CALL modifyaliases(x)
     ELSEIF ((request->urls[x].action_flag=1))
      CALL addportalurls(x)
     ELSEIF ((request->urls[x].action_flag=2))
      CALL modifyportalurls(x)
     ELSEIF ((request->urls[x].action_flag=3))
      CALL inactivateportalurls(x)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE createportalurl(portalurl)
   SET br_url_id = 0.0
   SELECT INTO "nl:"
    j = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     br_url_id = cnvtreal(j)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get new url id")
   INSERT  FROM br_portal_url bpu
    SET bpu.br_portal_url_id = br_url_id, bpu.br_portal_url = portalurl, bpu.logical_domain_id =
     acm_get_curr_logical_domain_rep->logical_domain_id,
     bpu.active_ind = 1, bpu.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpu
     .end_effective_dt_tm = cnvtdatetime("31-DEC-2100"),
     bpu.updt_id = reqinfo->updt_id, bpu.updt_cnt = 0, bpu.updt_applctx = reqinfo->updt_applctx,
     bpu.updt_task = reqinfo->updt_task, bpu.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Failed to insert new url.")
   RETURN(br_url_id)
 END ;Subroutine
 SUBROUTINE createportalurlsvcentreltn(urlid,parentname,parentid)
   SET br_url_svc_entity_r_id = 0.0
   SELECT INTO "nl:"
    j = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     br_url_svc_entity_r_id = cnvtreal(j)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get url reltn id")
   INSERT  FROM br_portal_url_svc_entity_r bpuser
    SET bpuser.br_portal_url_svc_entity_r_id = br_url_svc_entity_r_id, bpuser.br_portal_url_id =
     urlid, bpuser.parent_entity_name = parentname,
     bpuser.parent_entity_id = parentid, bpuser.active_ind = 1, bpuser.beg_effective_dt_tm =
     cnvtdatetime(curdate,curtime3),
     bpuser.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), bpuser.updt_id = reqinfo->updt_id,
     bpuser.updt_cnt = 0,
     bpuser.updt_applctx = reqinfo->updt_applctx, bpuser.updt_task = reqinfo->updt_task, bpuser
     .updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Failed to insert url reltn entity.")
   RETURN(br_url_svc_entity_r_id)
 END ;Subroutine
 SUBROUTINE addportalurls(x)
   SET new_url_id = createportalurl(request->urls[x].url)
   FOR (y = 1 TO size(request->urls[x].ccns,5))
     CALL createportalurlsvcentreltn(new_url_id,"BR_CCN",request->urls[x].ccns[y].ccn_id)
   ENDFOR
   FOR (y = 1 TO size(request->urls[x].eligible_providers,5))
     CALL createportalurlsvcentreltn(new_url_id,"BR_ELIGIBLE_PROVIDER",request->urls[x].
      eligible_providers[y].eligible_provider_id)
   ENDFOR
   FOR (y = 1 TO size(request->urls[x].alias_pools,5))
     CALL createportalurlsvcentreltn(new_url_id,code_value_table_name,request->urls[x].alias_pools[y]
      .code_value)
   ENDFOR
   FOR (y = 1 TO size(request->urls[x].alias_types,5))
     CALL createportalurlsvcentreltn(new_url_id,code_value_table_name,request->urls[x].alias_types[y]
      .code_value)
   ENDFOR
 END ;Subroutine
 SUBROUTINE modifyportalurls(x)
   DECLARE ccn_temp_size = i4 WITH protect, noconstant(0)
   DECLARE ep_temp_size = i4 WITH protect, noconstant(0)
   DECLARE alias_pools_size = i4 WITH protect, noconstant(0)
   DECLARE alias_types_size = i4 WITH protect, noconstant(0)
   DECLARE ccn_request_exists_ind = i4 WITH protect, noconstant(0)
   DECLARE ccn_request_size = i4 WITH protect, noconstant(size(request->urls[x].ccns,5))
   DECLARE ep_request_exists_ind = i4 WITH protect, noconstant(0)
   DECLARE ep_request_size = i4 WITH protect, noconstant(size(request->urls[x].eligible_providers,5))
   DECLARE alias_request_exists_ind = i4 WITH protect, noconstant(0)
   DECLARE ap_request_size = i4 WITH protect, noconstant(size(request->urls[x].alias_pools,5))
   DECLARE at_request_size = i4 WITH protect, noconstant(size(request->urls[x].alias_types,5))
   DECLARE i = i4 WITH protect, noconstant(0)
   IF ( NOT (validate(ccn_temp,0)))
    RECORD ccn_temp(
      1 ccns[*]
        2 ccn_id = f8
        2 br_portal_url_svc_entity_r_id = f8
        2 invitation_provided_event_code
          3 event_cd = f8
        2 patient_declined_event_code
          3 event_cd = f8
    )
   ENDIF
   IF ( NOT (validate(ep_temp,0)))
    RECORD ep_temp(
      1 eligible_providers[*]
        2 eligible_provider_id = f8
        2 br_portal_url_svc_entity_r_id = f8
        2 invitation_provided_event_code
          3 event_cd = f8
        2 patient_declined_event_code
          3 event_cd = f8
    )
   ENDIF
   IF ( NOT (validate(alias_pools_temp,0)))
    RECORD alias_pools_temp(
      1 aliases[*]
        2 code_value = f8
    )
   ENDIF
   IF ( NOT (validate(alias_types_temp,0)))
    RECORD alias_types_temp(
      1 aliases[*]
        2 code_value = f8
    )
   ENDIF
   SELECT INTO "nl:"
    FROM br_portal_url_svc_entity_r bpuser
    WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
     AND bpuser.parent_entity_name="BR_CCN"
     AND bpuser.active_ind=1
    DETAIL
     ccn_request_exists_ind = 0
     IF (ccn_request_size > 0)
      i = 0, ccn_request_exists_ind = locateval(i,1,ccn_request_size,bpuser.parent_entity_id,request
       ->urls[x].ccns[i].ccn_id)
     ENDIF
     IF (((ccn_request_exists_ind=0) OR ((request->urls[x].ccns[ccn_request_exists_ind].action_flag
      != 3))) )
      ccn_temp_size = (ccn_temp_size+ 1), stat = alterlist(ccn_temp->ccns,ccn_temp_size), ccn_temp->
      ccns[ccn_temp_size].ccn_id = bpuser.parent_entity_id,
      ccn_temp->ccns[ccn_temp_size].br_portal_url_svc_entity_r_id = bpuser
      .br_portal_url_svc_entity_r_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ccn_temp_size)),
     br_prtl_url_se_r_cd_r bpuser_r
    PLAN (d)
     JOIN (bpuser_r
     WHERE (bpuser_r.br_portal_url_svc_entity_r_id=ccn_temp->ccns[d.seq].
     br_portal_url_svc_entity_r_id)
      AND bpuser_r.active_ind=1
      AND bpuser_r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND bpuser_r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY bpuser_r.br_portal_url_svc_entity_r_id
    DETAIL
     IF (((ccn_request_exists_ind=0) OR ((request->urls[x].ccns[ccn_request_exists_ind].action_flag
      != 3))) )
      IF (bpuser_r.code_type_flag=invitation_provided_code_type)
       ccn_temp->ccns[d.seq].invitation_provided_event_code.event_cd = bpuser_r.portal_attr_cd_value
      ELSE
       ccn_temp->ccns[d.seq].patient_declined_event_code.event_cd = bpuser_r.portal_attr_cd_value
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("02 Failed to get existing ccn relations")
   SELECT INTO "nl:"
    FROM br_portal_url_svc_entity_r bpuser
    WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
     AND bpuser.parent_entity_name="BR_ELIGIBLE_PROVIDER"
     AND bpuser.active_ind=1
    DETAIL
     ep_request_exists_ind = 0
     IF (ep_request_size > 0)
      i = 0, ep_request_exists_ind = locateval(i,1,ep_request_size,bpuser.parent_entity_id,request->
       urls[x].eligible_providers[i].eligible_provider_id)
     ENDIF
     IF (((ep_request_exists_ind=0) OR ((request->urls[x].eligible_providers[ep_request_exists_ind].
     action_flag != 3))) )
      ep_temp_size = (ep_temp_size+ 1), stat = alterlist(ep_temp->eligible_providers,ep_temp_size),
      ep_temp->eligible_providers[ep_temp_size].eligible_provider_id = bpuser.parent_entity_id,
      ep_temp->eligible_providers[ep_temp_size].br_portal_url_svc_entity_r_id = bpuser
      .br_portal_url_svc_entity_r_id
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("01 Failed to get existing ep relations")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ep_temp_size)),
     br_prtl_url_se_r_cd_r bpuser_r
    PLAN (d)
     JOIN (bpuser_r
     WHERE (bpuser_r.br_portal_url_svc_entity_r_id=ep_temp->eligible_providers[d.seq].
     br_portal_url_svc_entity_r_id)
      AND bpuser_r.active_ind=1
      AND bpuser_r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND bpuser_r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY bpuser_r.br_portal_url_svc_entity_r_id
    DETAIL
     IF (((ep_request_exists_ind=0) OR ((request->urls[x].eligible_providers[ep_request_exists_ind].
     action_flag != 3))) )
      IF (bpuser_r.code_type_flag=invitation_provided_code_type)
       ep_temp->eligible_providers[d.seq].invitation_provided_event_code.event_cd = bpuser_r
       .portal_attr_cd_value
      ELSE
       ep_temp->eligible_providers[d.seq].patient_declined_event_code.event_cd = bpuser_r
       .portal_attr_cd_value
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("02 Failed to get existing ep relations")
   SELECT INTO "nl:"
    FROM br_portal_url_svc_entity_r bpuser,
     code_value cv
    PLAN (bpuser
     WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
      AND bpuser.parent_entity_name=code_value_table_name
      AND bpuser.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=bpuser.parent_entity_id
      AND cv.code_set=alias_pool_code_set)
    ORDER BY bpuser.parent_entity_id, cv.code_value
    DETAIL
     alias_request_exists_ind = 0
     IF (ap_request_size > 0)
      i = 0, alias_request_exists_ind = locateval(i,1,ap_request_size,bpuser.parent_entity_id,request
       ->urls[x].alias_pools[i].code_value)
     ENDIF
     IF (((alias_request_exists_ind=0) OR ((request->urls[x].alias_pools[alias_request_exists_ind].
     action_flag != 3))) )
      alias_pools_size = (alias_pools_size+ 1), stat = alterlist(alias_pools_temp->aliases,
       alias_pools_size), alias_pools_temp->aliases[alias_pools_size].code_value = bpuser
      .parent_entity_id
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get existing alias pools")
   SELECT INTO "nl:"
    FROM br_portal_url_svc_entity_r bpuser,
     code_value cv
    PLAN (bpuser
     WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
      AND bpuser.parent_entity_name=code_value_table_name
      AND bpuser.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=bpuser.parent_entity_id
      AND cv.code_set=alias_type_code_set)
    ORDER BY bpuser.parent_entity_id, cv.code_value
    DETAIL
     alias_request_exists_ind = 0
     IF (at_request_size > 0)
      i = 0, alias_request_exists_ind = locateval(i,1,at_request_size,bpuser.parent_entity_id,request
       ->urls[x].alias_types[i].code_value)
     ENDIF
     IF (((alias_request_exists_ind=0) OR ((request->urls[x].alias_types[alias_request_exists_ind].
     action_flag != 3))) )
      alias_types_size = (alias_types_size+ 1), stat = alterlist(alias_types_temp->aliases,
       alias_types_size), alias_types_temp->aliases[alias_types_size].code_value = bpuser
      .parent_entity_id
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to get existing alias types")
   CALL inactivateportalurls(x)
   SET new_url_id = createportalurl(request->urls[x].url)
   FOR (y = 1 TO size(ccn_temp->ccns,5))
     DECLARE reltnid = f8 WITH protect, noconstant(0)
     SET reltnid = createportalurlsvcentreltn(new_url_id,"BR_CCN",ccn_temp->ccns[y].ccn_id)
     CALL createportalreltnattribute(reltnid,ccn_temp->ccns[y].invitation_provided_event_code.
      event_cd,invitation_provided_code_type)
     CALL createportalreltnattribute(reltnid,ccn_temp->ccns[y].patient_declined_event_code.event_cd,
      patient_declined_code_type)
   ENDFOR
   FOR (y = 1 TO ccn_request_size)
     IF ((request->urls[x].ccns[y].action_flag=1))
      DECLARE reltnid = f8 WITH protect, noconstant(0)
      SET reltnid = createportalurlsvcentreltn(new_url_id,"BR_CCN",request->urls[x].ccns[y].ccn_id)
      CALL createportalreltnattribute(reltnid,request->urls[x].ccns[y].invitation_provided_event_code
       .event_cd,invitation_provided_code_type)
      CALL createportalreltnattribute(reltnid,request->urls[x].ccns[y].patient_declined_event_code.
       event_cd,patient_declined_code_type)
     ENDIF
   ENDFOR
   FOR (z = 1 TO size(ep_temp->eligible_providers,5))
     DECLARE reltnid = f8 WITH protect, noconstant(0)
     SET reltnid = createportalurlsvcentreltn(new_url_id,"BR_ELIGIBLE_PROVIDER",ep_temp->
      eligible_providers[z].eligible_provider_id)
     CALL createportalreltnattribute(reltnid,ep_temp->eligible_providers[z].
      invitation_provided_event_code.event_cd,invitation_provided_code_type)
     CALL createportalreltnattribute(reltnid,ep_temp->eligible_providers[z].
      patient_declined_event_code.event_cd,patient_declined_code_type)
   ENDFOR
   FOR (z = 1 TO ep_request_size)
     IF ((request->urls[x].eligible_providers[z].action_flag=1))
      DECLARE reltnid = f8 WITH protect, noconstant(0)
      SET reltnid = createportalurlsvcentreltn(new_url_id,"BR_ELIGIBLE_PROVIDER",request->urls[x].
       eligible_providers[z].eligible_provider_id)
      CALL createportalreltnattribute(reltnid,request->urls[x].eligible_providers[z].
       invitation_provided_event_code.event_cd,invitation_provided_code_type)
      CALL createportalreltnattribute(reltnid,request->urls[x].eligible_providers[z].
       patient_declined_event_code.event_cd,patient_declined_code_type)
     ENDIF
   ENDFOR
   FOR (y = 1 TO alias_pools_size)
     CALL createportalurlsvcentreltn(new_url_id,code_value_table_name,alias_pools_temp->aliases[y].
      code_value)
   ENDFOR
   FOR (y = 1 TO alias_types_size)
     CALL createportalurlsvcentreltn(new_url_id,code_value_table_name,alias_types_temp->aliases[y].
      code_value)
   ENDFOR
   FOR (y = 1 TO ap_request_size)
     IF ((request->urls[x].alias_pools[y].action_flag=1))
      CALL createportalurlsvcentreltn(new_url_id,code_value_table_name,request->urls[x].alias_pools[y
       ].code_value)
     ENDIF
   ENDFOR
   FOR (y = 1 TO at_request_size)
     IF ((request->urls[x].alias_types[y].action_flag=1))
      CALL createportalurlsvcentreltn(new_url_id,code_value_table_name,request->urls[x].alias_types[y
       ].code_value)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE modifyccnsandeps(x)
  FOR (y = 1 TO size(request->urls[x].ccns,5))
    IF ((request->urls[x].ccns[y].action_flag=1))
     DECLARE reltnid = f8 WITH protect, noconstant(0)
     SET reltnid = createportalurlsvcentreltn(request->urls[x].url_id,"BR_CCN",request->urls[x].ccns[
      y].ccn_id)
     CALL createportalreltnattribute(reltnid,request->urls[x].ccns[y].invitation_provided_event_code.
      event_cd,invitation_provided_code_type)
     CALL createportalreltnattribute(reltnid,request->urls[x].ccns[y].patient_declined_event_code.
      event_cd,patient_declined_code_type)
    ELSEIF ((request->urls[x].ccns[y].action_flag=3))
     DECLARE reltnid = f8 WITH protect, noconstant(0)
     SELECT INTO "nl:"
      FROM br_portal_url_svc_entity_r bpuser
      PLAN (bpuser
       WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
        AND (bpuser.parent_entity_id=request->urls[x].ccns[y].ccn_id)
        AND bpuser.parent_entity_name="BR_CCN"
        AND bpuser.active_ind=1
        AND bpuser.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND bpuser.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      DETAIL
       reltnid = bpuser.br_portal_url_svc_entity_r_id
      WITH nocounter
     ;end select
     CALL createportalreltnattribute(reltnid,0.0,invitation_provided_code_type)
     CALL createportalreltnattribute(reltnid,0.0,patient_declined_code_type)
     UPDATE  FROM br_portal_url_svc_entity_r bpuser
      SET bpuser.active_ind = 0, bpuser.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpuser
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       bpuser.updt_id = reqinfo->updt_id, bpuser.updt_task = reqinfo->updt_task, bpuser.updt_cnt = (
       bpuser.updt_cnt+ 1),
       bpuser.updt_applctx = reqinfo->updt_applctx
      WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
       AND (bpuser.parent_entity_id=request->urls[x].ccns[y].ccn_id)
       AND bpuser.parent_entity_name="BR_CCN"
      WITH nocounter
     ;end update
     CALL bederrorcheck("Failed to inactivate ccn relations.")
    ELSEIF ((request->urls[x].ccns[y].action_flag != 3))
     DECLARE reltnid = f8 WITH protect, noconstant(0)
     SELECT INTO "nl:"
      FROM br_portal_url_svc_entity_r bpuser
      PLAN (bpuser
       WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
        AND (bpuser.parent_entity_id=request->urls[x].ccns[y].ccn_id)
        AND bpuser.parent_entity_name="BR_CCN"
        AND bpuser.active_ind=1
        AND bpuser.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND bpuser.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      DETAIL
       reltnid = bpuser.br_portal_url_svc_entity_r_id
      WITH nocounter
     ;end select
     IF (reltnid > 0.0)
      CALL createportalreltnattribute(reltnid,request->urls[x].ccns[y].invitation_provided_event_code
       .event_cd,invitation_provided_code_type)
      CALL createportalreltnattribute(reltnid,request->urls[x].ccns[y].patient_declined_event_code.
       event_cd,patient_declined_code_type)
     ENDIF
    ENDIF
  ENDFOR
  FOR (z = 1 TO size(request->urls[x].eligible_providers,5))
    IF ((request->urls[x].eligible_providers[z].action_flag=1))
     DECLARE reltnid = f8 WITH protect, noconstant(0)
     SET reltnid = createportalurlsvcentreltn(request->urls[x].url_id,"BR_ELIGIBLE_PROVIDER",request
      ->urls[x].eligible_providers[z].eligible_provider_id)
     CALL createportalreltnattribute(reltnid,request->urls[x].eligible_providers[z].
      invitation_provided_event_code.event_cd,invitation_provided_code_type)
     CALL createportalreltnattribute(reltnid,request->urls[x].eligible_providers[z].
      patient_declined_event_code.event_cd,patient_declined_code_type)
    ELSEIF ((request->urls[x].eligible_providers[z].action_flag=3))
     DECLARE reltnid = f8 WITH protect, noconstant(0)
     SELECT INTO "nl:"
      FROM br_portal_url_svc_entity_r bpuser
      PLAN (bpuser
       WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
        AND (bpuser.parent_entity_id=request->urls[x].eligible_providers[z].eligible_provider_id)
        AND bpuser.parent_entity_name="BR_ELIGIBLE_PROVIDER"
        AND bpuser.active_ind=1
        AND bpuser.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND bpuser.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      DETAIL
       reltnid = bpuser.br_portal_url_svc_entity_r_id
      WITH nocounter
     ;end select
     CALL createportalreltnattribute(reltnid,0.0,invitation_provided_code_type)
     CALL createportalreltnattribute(reltnid,0.0,patient_declined_code_type)
     UPDATE  FROM br_portal_url_svc_entity_r bpuser
      SET bpuser.active_ind = 0, bpuser.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpuser
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       bpuser.updt_id = reqinfo->updt_id, bpuser.updt_task = reqinfo->updt_task, bpuser.updt_cnt = (
       bpuser.updt_cnt+ 1),
       bpuser.updt_applctx = reqinfo->updt_applctx
      WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
       AND (bpuser.parent_entity_id=request->urls[x].eligible_providers[z].eligible_provider_id)
       AND bpuser.parent_entity_name="BR_ELIGIBLE_PROVIDER"
      WITH nocounter
     ;end update
     CALL bederrorcheck("Failed to inactivate ep relations.")
    ELSEIF ((request->urls[x].eligible_providers[z].action_flag != 3))
     DECLARE reltnid = f8 WITH protect, noconstant(0)
     SELECT INTO "nl:"
      FROM br_portal_url_svc_entity_r bpuser
      PLAN (bpuser
       WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
        AND (bpuser.parent_entity_id=request->urls[x].eligible_providers[z].eligible_provider_id)
        AND bpuser.parent_entity_name="BR_ELIGIBLE_PROVIDER"
        AND bpuser.active_ind=1
        AND bpuser.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND bpuser.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      DETAIL
       reltnid = bpuser.br_portal_url_svc_entity_r_id
      WITH nocounter
     ;end select
     IF (reltnid > 0.0)
      CALL createportalreltnattribute(reltnid,request->urls[x].eligible_providers[z].
       invitation_provided_event_code.event_cd,invitation_provided_code_type)
      CALL createportalreltnattribute(reltnid,request->urls[x].eligible_providers[z].
       patient_declined_event_code.event_cd,patient_declined_code_type)
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE modifyaliases(x)
  FOR (y = 1 TO size(request->urls[x].alias_pools,5))
    IF ((request->urls[x].alias_pools[y].action_flag=3))
     UPDATE  FROM br_portal_url_svc_entity_r bpuser
      SET bpuser.active_ind = 0, bpuser.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpuser
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       bpuser.updt_id = reqinfo->updt_id, bpuser.updt_task = reqinfo->updt_task, bpuser.updt_cnt = (
       bpuser.updt_cnt+ 1),
       bpuser.updt_applctx = reqinfo->updt_applctx
      WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
       AND (bpuser.parent_entity_id=request->urls[x].alias_pools[y].code_value)
       AND bpuser.parent_entity_name=code_value_table_name
      WITH nocounter
     ;end update
     CALL bederrorcheck("Failed to inactivate alias pools.")
    ELSEIF ((request->urls[x].alias_pools[y].action_flag=1))
     CALL createportalurlsvcentreltn(request->urls[x].url_id,code_value_table_name,request->urls[x].
      alias_pools[y].code_value)
    ENDIF
  ENDFOR
  FOR (y = 1 TO size(request->urls[x].alias_types,5))
    IF ((request->urls[x].alias_types[y].action_flag=3))
     UPDATE  FROM br_portal_url_svc_entity_r bpuser
      SET bpuser.active_ind = 0, bpuser.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpuser
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       bpuser.updt_id = reqinfo->updt_id, bpuser.updt_task = reqinfo->updt_task, bpuser.updt_cnt = (
       bpuser.updt_cnt+ 1),
       bpuser.updt_applctx = reqinfo->updt_applctx
      WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
       AND (bpuser.parent_entity_id=request->urls[x].alias_types[y].code_value)
       AND bpuser.parent_entity_name=code_value_table_name
      WITH nocounter
     ;end update
     CALL bederrorcheck("Failed to inactivate alias types.")
    ELSEIF ((request->urls[x].alias_types[y].action_flag=1))
     CALL createportalurlsvcentreltn(request->urls[x].url_id,code_value_table_name,request->urls[x].
      alias_types[y].code_value)
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE inactivateportalurls(x)
   UPDATE  FROM br_portal_url bpu
    SET bpu.active_ind = 0, bpu.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpu.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     bpu.updt_id = reqinfo->updt_id, bpu.updt_task = reqinfo->updt_task, bpu.updt_cnt = (bpu.updt_cnt
     + 1),
     bpu.updt_applctx = reqinfo->updt_applctx
    WHERE (bpu.br_portal_url_id=request->urls[x].url_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("Failed to inactivate url.")
   FREE RECORD relations
   RECORD relations(
     1 relation[*]
       2 br_portal_url_svc_entity_r_id = f8
   ) WITH protect
   DECLARE relation_count = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_portal_url_svc_entity_r bpuser
    PLAN (bpuser
     WHERE (bpuser.br_portal_url_id=request->urls[x].url_id))
    DETAIL
     relation_count = (relation_count+ 1), stat = alterlist(relations->relation,relation_count),
     relations->relation[relation_count].br_portal_url_svc_entity_r_id = bpuser
     .br_portal_url_svc_entity_r_id
    WITH nocounter
   ;end select
   FOR (y = 1 TO relation_count)
    CALL createportalreltnattribute(relations->relation[y].br_portal_url_svc_entity_r_id,0.0,
     invitation_provided_code_type)
    CALL createportalreltnattribute(relations->relation[y].br_portal_url_svc_entity_r_id,0.0,
     patient_declined_code_type)
   ENDFOR
   UPDATE  FROM br_portal_url_svc_entity_r bpuser
    SET bpuser.active_ind = 0, bpuser.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), bpuser
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     bpuser.updt_id = reqinfo->updt_id, bpuser.updt_task = reqinfo->updt_task, bpuser.updt_cnt = (
     bpuser.updt_cnt+ 1),
     bpuser.updt_applctx = reqinfo->updt_applctx
    WHERE (bpuser.br_portal_url_id=request->urls[x].url_id)
    WITH nocounter
   ;end update
   CALL bederrorcheck("Failed to inactivate url relations.")
 END ;Subroutine
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
END GO
