CREATE PROGRAM bed_ens_por_products:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 orders_to_inactivate[*]
     2 catalog_code_value = f8
     2 description = vc
     2 primary_mnemonic = vc
     2 dept_name = vc
     2 catalog_type_code_value = f8
     2 activity_type_code_value = f8
     2 activity_subtype_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 DECLARE rx_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC"))
 DECLARE sys_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
 DECLARE cur_ord_id = f8 WITH protect
 DECLARE cur_syn_id = f8 WITH protect
 FOR (x = 1 TO size(request->items,5))
   SET cur_ord_id = 0.0
   SET cur_syn_id = 0.0
   SELECT INTO "nl:"
    FROM order_catalog_item_r o
    WHERE (o.item_id=request->items[x].item_id)
    DETAIL
     cur_ord_id = o.catalog_cd, cur_syn_id = o.synonym_id
    WITH nocounter
   ;end select
   IF (cur_ord_id > 0)
    SET inact_ind = 1
    SELECT INTO "nl:"
     FROM order_catalog_item_r o
     WHERE o.catalog_cd=cur_ord_id
      AND (o.item_id != request->items[x].item_id)
     DETAIL
      inact_ind = 0
     WITH nocounter
    ;end select
    IF (inact_ind=1)
     SELECT INTO "nl:"
      FROM order_catalog oc
      WHERE oc.catalog_cd=cur_ord_id
       AND oc.cki > " "
      DETAIL
       inact_ind = 0
      WITH nocounter
     ;end select
    ENDIF
    IF (inact_ind=1)
     SET osize = size(reply->orders_to_inactivate,5)
     SET stat = alterlist(reply->orders_to_inactivate,(osize+ 1))
     SELECT INTO "nl:"
      FROM order_catalog oc
      WHERE oc.catalog_cd=cur_ord_id
      DETAIL
       reply->orders_to_inactivate[(osize+ 1)].activity_subtype_code_value = oc.activity_subtype_cd,
       reply->orders_to_inactivate[(osize+ 1)].activity_type_code_value = oc.activity_type_cd, reply
       ->orders_to_inactivate[(osize+ 1)].catalog_code_value = oc.catalog_cd,
       reply->orders_to_inactivate[(osize+ 1)].catalog_type_code_value = oc.catalog_type_cd, reply->
       orders_to_inactivate[(osize+ 1)].dept_name = oc.dept_display_name, reply->
       orders_to_inactivate[(osize+ 1)].description = oc.description,
       reply->orders_to_inactivate[(osize+ 1)].primary_mnemonic = oc.primary_mnemonic
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   UPDATE  FROM order_catalog_item_r o
    SET o.catalog_cd = request->items[x].catalog_code_value, o.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), o.updt_id = reqinfo->updt_id,
     o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->updt_applctx, o.updt_cnt = (o
     .updt_cnt+ 1)
    WHERE (o.item_id=request->items[x].item_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL bederror(concat("Unable to update row for item_id: ",trim(cnvtstring(request->items[x].
        item_id))," on order_catalog_item_r."))
   ENDIF
   UPDATE  FROM order_catalog_synonym ocs
    SET ocs.catalog_cd = request->items[x].catalog_code_value, ocs.updt_dt_tm = cnvtdatetime(curdate,
      curtime3), ocs.updt_id = reqinfo->updt_id,
     ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->updt_applctx, ocs.updt_cnt = (
     ocs.updt_cnt+ 1)
    WHERE (ocs.item_id=request->items[x].item_id)
     AND ocs.mnemonic_type_cd=rx_code_value
    WITH nocounter
   ;end update
   DELETE  FROM synonym_item_r s
    WHERE (s.item_id=request->items[x].item_id)
    WITH nocounter
   ;end delete
   DELETE  FROM synonym_item_r s
    WHERE s.synonym_id=cur_syn_id
    WITH nocounter
   ;end delete
   SET moe_id = 0.0
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_oe_defaults mod
    PLAN (mdf
     WHERE (mdf.item_id=request->items[x].item_id)
      AND mdf.flex_type_cd=sys_code_value)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.parent_entity_name="MED_OE_DEFAULTS")
     JOIN (mod
     WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id)
    DETAIL
     moe_id = mod.med_oe_defaults_id
    WITH nocounter
   ;end select
   UPDATE  FROM med_oe_defaults moe
    SET moe.ord_as_synonym_id = 0, moe.updt_dt_tm = cnvtdatetime(curdate,curtime3), moe.updt_id =
     reqinfo->updt_id,
     moe.updt_task = reqinfo->updt_task, moe.updt_applctx = reqinfo->updt_applctx, moe.updt_cnt = (
     moe.updt_cnt+ 1)
    WHERE moe.med_oe_defaults_id=moe_id
    WITH nocounter
   ;end update
 ENDFOR
#exit_script
 CALL bedexitscript(1)
END GO
