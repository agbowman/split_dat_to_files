CREATE PROGRAM bed_ens_rln_coll_req:dba
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
 DECLARE alternate_cntnr_exists = i2 WITH protect, noconstant(0)
 RECORD tempcollinfo(
   1 coll_info_list[*]
     2 coll_info_seq = f8
     2 specimen_type_cd = f8
     2 min_vol_amt = f8
     2 spec_handling_cd = f8
     2 coll_class_cd = f8
 )
 FREE RECORD service_resource_rec
 RECORD service_resource_rec(
   1 service_resource_cd_list[*]
     2 service_resource_cd = f8
 )
 FREE RECORD sequence_rec
 RECORD sequence_rec(
   1 sequence_list[*]
     2 sequence = f8
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
 DECLARE updatecontainer(dummyvar=i2) = i2
 DECLARE updatecollectionclass(dummyvar=i2) = i2
 DECLARE updatealternatecontainer(dummyvar=i2) = i2
 DECLARE updatealternatecollectionclass(dummyvar=i2) = i2
 DECLARE openlogfile(dummyvar=i2) = i2
 DECLARE logmessage(msg=vc) = i2
 DECLARE msg_var = i4 WITH protect, noconstant(0)
 DECLARE msg = vc WITH protect, noconstant("")
 DECLARE num_coll_req = i4 WITH protect
 CALL openlogfile(0)
 CALL logmessage("start script execution")
 DECLARE iter_record = i4 WITH noconstant(0)
 SET stat = alterlist(service_resource_rec->service_resource_cd_list,100)
 SET stat = alterlist(sequence_rec->sequence_list,100)
 SELECT INTO "nl:"
  FROM service_resource sr,
   organization o,
   code_value cv,
   code_value cv2
  WHERE expand(iter_record,1,size(request->location_list,5),sr.location_cd,request->location_list[
   iter_record].location_cd)
   AND o.organization_id=sr.organization_id
   AND sr.organization_id != 0
   AND cv.code_value=sr.location_cd
   AND cv.cdf_meaning="LAB"
   AND cv2.code_value=sr.service_resource_cd
   AND cv2.cdf_meaning="BENCH"
  HEAD REPORT
   sv_cnt = 0
  DETAIL
   sv_cnt = (sv_cnt+ 1)
   IF (mod(sv_cnt,10)=1)
    stat = alterlist(service_resource_rec->service_resource_cd_list,(sv_cnt+ 9))
   ENDIF
   service_resource_rec->service_resource_cd_list[sv_cnt].service_resource_cd = sr
   .service_resource_cd
  FOOT REPORT
   stat = alterlist(service_resource_rec->service_resource_cd_list,sv_cnt)
  WITH nocounter, expand = value(bedgetexpandind(size(service_resource_rec->service_resource_cd_list,
      5)))
 ;end select
 CALL logmessage("Populated service_resource_cd")
 SELECT INTO "nl:"
  FROM collection_info_qualifiers ciq
  WHERE (ciq.catalog_cd=request->orderable_cd)
   AND expand(iter_record,1,size(service_resource_rec->service_resource_cd_list,5),ciq
   .service_resource_cd,service_resource_rec->service_resource_cd_list[iter_record].
   service_resource_cd)
  HEAD REPORT
   sv_cnt = 0
  DETAIL
   sv_cnt = (sv_cnt+ 1)
   IF (mod(sv_cnt,10)=1)
    stat = alterlist(sequence_rec->sequence_list,(sv_cnt+ 9))
   ENDIF
   sequence_rec->sequence_list[sv_cnt].sequence = ciq.sequence
  FOOT REPORT
   stat = alterlist(sequence_rec->sequence_list,sv_cnt)
  WITH nocounter, expand = value(bedgetexpandind(size(sequence_rec->sequence_list,5)))
 ;end select
 CALL logmessage("Populated sequence value")
 SELECT INTO "nl:"
  FROM alt_collection_info aci
  WHERE (aci.catalog_cd=request->orderable_cd)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET alternate_cntnr_exists = 1
 ENDIF
 IF ((request->alternate_container_ind=0))
  IF ((request->change_flag=1))
   IF ((request->old_container_cd > 0)
    AND (request->new_container_cd > 0))
    CALL logmessage("Calling updateContainer()")
    CALL updatecontainer(0)
    CALL logmessage("Finished updateContainer()")
   ENDIF
  ENDIF
 ELSE
  IF ((request->change_flag=1))
   CALL logmessage("Calling updateAlternateContainer()")
   CALL updatealternatecontainer(0)
   CALL logmessage("Finised updateAlternateContainer()")
  ENDIF
 ENDIF
 IF ((request->change_flag=2))
  IF ((request->old_coll_class_cd > 0)
   AND (request->new_coll_class_cd > 0))
   CALL logmessage("Calling updateCollectionClass()")
   CALL updatecollectionclass(0)
   CALL logmessage("Finished updateCollectionClass()")
   CALL logmessage("Calling updateAlternateCollectionClas()")
   CALL updatealternatecollectionclass(0)
   CALL logmessage("Finished updateAlternateCollectionClas()")
  ENDIF
 ENDIF
#exit_script
 CALL logmessage("Finished script execution")
 CALL bedexitscript(1)
 SUBROUTINE updatecontainer(dummyvar)
   DECLARE iter_sr_resource = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM collection_info_qualifiers ciq
    WHERE (ciq.spec_cntnr_cd=request->new_container_cd)
     AND (ciq.catalog_cd=request->orderable_cd)
     AND expand(iter_sr_resource,1,size(service_resource_rec->service_resource_cd_list,5),ciq
     .service_resource_cd,service_resource_rec->service_resource_cd_list[iter_sr_resource].
     service_resource_cd)
    WITH nocounter, expand = value(bedgetexpandind(size(service_resource_rec->
        service_resource_cd_list,5)))
   ;end select
   IF (curqual != size(service_resource_rec->service_resource_cd_list,5))
    UPDATE  FROM collection_info_qualifiers ciq
     SET ciq.spec_cntnr_cd = request->new_container_cd, ciq.updt_dt_tm = cnvtdatetime(curdate,curtime
       ), ciq.updt_id = reqinfo->updt_id,
      ciq.updt_cnt = (ciq.updt_cnt+ 1), ciq.updt_task = reqinfo->updt_task, ciq.updt_applctx =
      reqinfo->updt_applctx
     WHERE (ciq.spec_cntnr_cd=request->old_container_cd)
      AND (ciq.catalog_cd=request->orderable_cd)
      AND expand(iter_sr_resource,1,size(service_resource_rec->service_resource_cd_list,5),ciq
      .service_resource_cd,service_resource_rec->service_resource_cd_list[iter_sr_resource].
      service_resource_cd)
     WITH nocounter, expand = value(bedgetexpandind(size(service_resource_rec->
        service_resource_cd_list,5)))
    ;end update
   ENDIF
   IF (curqual=0)
    CALL logmessage("Failed to update container on collection_info_qualifiers table.")
    CALL bederrorcheck("Failed to update container on collection_info_qualifiers table.")
   ENDIF
 END ;Subroutine
 SUBROUTINE updatecollectionclass(dummyvar)
   DECLARE iter_coll_class = i4 WITH noconstant(0)
   UPDATE  FROM collection_info_qualifiers ciq
    SET ciq.coll_class_cd = request->new_coll_class_cd, ciq.updt_dt_tm = cnvtdatetime(curdate,curtime
      ), ciq.updt_id = reqinfo->updt_id,
     ciq.updt_cnt = (ciq.updt_cnt+ 1), ciq.updt_task = reqinfo->updt_task, ciq.updt_applctx = reqinfo
     ->updt_applctx
    WHERE (ciq.coll_class_cd=request->old_coll_class_cd)
     AND (ciq.catalog_cd=request->orderable_cd)
     AND expand(iter_coll_class,1,size(service_resource_rec->service_resource_cd_list,5),ciq
     .service_resource_cd,service_resource_rec->service_resource_cd_list[iter_coll_class].
     service_resource_cd)
    WITH nocounter, expand = value(bedgetexpandind(size(service_resource_rec->
       service_resource_cd_list,5)))
   ;end update
   CALL logmessage("Failed to update collection class on collection_info_qualifiers table.")
   CALL bederrorcheck("Failed to update collection class on collection_info_qualifiers table.")
 END ;Subroutine
 SUBROUTINE updatealternatecontainer(dummyvar)
  DECLARE iter_list = i4 WITH noconstant(0)
  IF (alternate_cntnr_exists=1
   AND (request->new_container_cd != 0.0)
   AND (request->old_container_cd != 0.0))
   CALL logmessage("Alternate Container Exist , new and old are != 0")
   SELECT INTO "nl:"
    FROM alt_collection_info aci,
     collection_info_qualifiers ciq
    WHERE (aci.spec_cntnr_cd=request->new_container_cd)
     AND (aci.catalog_cd=request->orderable_cd)
     AND ciq.sequence=aci.coll_info_seq
     AND expand(iter_list,1,size(service_resource_rec->service_resource_cd_list,5),ciq
     .service_resource_cd,service_resource_rec->service_resource_cd_list[iter_list].
     service_resource_cd)
    WITH nocounter, expand = value(bedgetexpandind(size(service_resource_rec->
        service_resource_cd_list,5)))
   ;end select
   IF (curqual != size(service_resource_rec->service_resource_cd_list,5))
    SET msg = concat("Updating Alternate Container for order: ",cnvtstring(request->orderable_cd))
    CALL logmessage(msg)
    UPDATE  FROM alt_collection_info aci
     SET aci.spec_cntnr_cd = request->new_container_cd, aci.updt_dt_tm = cnvtdatetime(curdate,curtime
       ), aci.updt_id = reqinfo->updt_id,
      aci.updt_cnt = (aci.updt_cnt+ 1), aci.updt_task = reqinfo->updt_task, aci.updt_applctx =
      reqinfo->updt_applctx
     WHERE (aci.catalog_cd=request->orderable_cd)
      AND (aci.spec_cntnr_cd=request->old_container_cd)
      AND expand(iter_list,1,size(sequence_rec->sequence_list,5),aci.coll_info_seq,sequence_rec->
      sequence_list[iter_list].sequence)
     WITH nocounter, expand = 2
    ;end update
   ENDIF
  ELSEIF (alternate_cntnr_exists=1
   AND (request->old_container_cd != 0.0))
   SET msg = concat("Deleting Alternate Container for order: ",cnvtstring(request->orderable_cd))
   CALL logmessage(msg)
   DELETE  FROM alt_collection_info aci
    WHERE (aci.catalog_cd=request->orderable_cd)
     AND (aci.spec_cntnr_cd=request->old_container_cd)
     AND expand(iter_list,1,size(sequence_rec->sequence_list,5),aci.coll_info_seq,sequence_rec->
     sequence_list[iter_list].sequence)
    WITH nocounter, expand = value(bedgetexpandind(size(sequence_rec->sequence_list,5)))
   ;end delete
  ELSE
   SELECT INTO "nl:"
    FROM alt_collection_info aci,
     collection_info_qualifiers ciq
    WHERE (aci.spec_cntnr_cd=request->new_container_cd)
     AND (aci.catalog_cd=request->orderable_cd)
     AND ciq.sequence=aci.coll_info_seq
     AND expand(iter_list,1,size(service_resource_rec->service_resource_cd_list,5),ciq
     .service_resource_cd,service_resource_rec->service_resource_cd_list[iter_list].
     service_resource_cd)
    WITH nocounter, expand = value(bedgetexpandind(size(service_resource_rec->
        service_resource_cd_list,5)))
   ;end select
   IF (curqual != size(service_resource_rec->service_resource_cd_list,5))
    SET stat = alterlist(tempcollinfo->coll_info_list,100)
    SELECT INTO "nl:"
     FROM collection_info_qualifiers ciq
     WHERE (ciq.catalog_cd=request->orderable_cd)
      AND expand(iter_list,1,size(service_resource_rec->service_resource_cd_list,5),ciq
      .service_resource_cd,service_resource_rec->service_resource_cd_list[iter_list].
      service_resource_cd)
     HEAD REPORT
      coll_cnt = 0
     DETAIL
      coll_cnt = (coll_cnt+ 1)
      IF (mod(coll_cnt,10)=1)
       stat = alterlist(tempcollinfo->coll_info_list,(coll_cnt+ 9))
      ENDIF
      tempcollinfo->coll_info_list[coll_cnt].coll_info_seq = ciq.sequence, tempcollinfo->
      coll_info_list[coll_cnt].min_vol_amt = ciq.min_vol, tempcollinfo->coll_info_list[coll_cnt].
      spec_handling_cd = ciq.spec_hndl_cd,
      tempcollinfo->coll_info_list[coll_cnt].specimen_type_cd = ciq.specimen_type_cd, tempcollinfo->
      coll_info_list[coll_cnt].coll_class_cd = ciq.coll_class_cd
     FOOT REPORT
      stat = alterlist(tempcollinfo->coll_info_list,coll_cnt)
     WITH nocounter, expand = value(bedgetexpandind(size(service_resource_rec->
         service_resource_cd_list,5)))
    ;end select
    SET num_coll_req = size(tempcollinfo->coll_info_list,5)
    FOR (num_coll_req_seq = 1 TO num_coll_req)
     SELECT INTO "n1:"
      FROM alt_collection_info aci
      WHERE (aci.coll_info_seq=tempcollinfo->coll_info_list[num_coll_req_seq].coll_info_seq)
       AND (aci.spec_cntnr_cd=request->new_container_cd)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET msg = concat("Inserting Alternate Container for order: ",cnvtstring(request->orderable_cd))
      CALL logmessage(msg)
      INSERT  FROM alt_collection_info aci
       SET aci.alt_collection_info_id = seq(reference_seq,nextval), aci.catalog_cd = request->
        orderable_cd, aci.specimen_type_cd = tempcollinfo->coll_info_list[num_coll_req_seq].
        specimen_type_cd,
        aci.coll_info_seq = tempcollinfo->coll_info_list[num_coll_req_seq].coll_info_seq, aci
        .spec_cntnr_cd = request->new_container_cd, aci.min_vol_amt = tempcollinfo->coll_info_list[
        num_coll_req_seq].min_vol_amt,
        aci.coll_class_cd = tempcollinfo->coll_info_list[num_coll_req_seq].coll_class_cd, aci
        .spec_hndl_cd = tempcollinfo->coll_info_list[num_coll_req_seq].spec_handling_cd, aci
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        aci.updt_id = reqinfo->updt_id, aci.updt_task = reqinfo->updt_task, aci.updt_applctx =
        reqinfo->updt_applctx,
        aci.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       CALL bederrorcheck("Failed to insert alt container on alt_collection_info table.")
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE updatealternatecollectionclass(dummyvar)
   DECLARE iter_seq_list = i4 WITH noconstant(0)
   SET msg = concat("Updating Collection Class for Order: ",cnvtstring(request->orderable_cd))
   CALL logmessage(msg)
   UPDATE  FROM alt_collection_info aci
    SET aci.coll_class_cd = request->new_coll_class_cd, aci.updt_dt_tm = cnvtdatetime(curdate,curtime
      ), aci.updt_id = reqinfo->updt_id,
     aci.updt_cnt = (aci.updt_cnt+ 1), aci.updt_task = reqinfo->updt_task, aci.updt_applctx = reqinfo
     ->updt_applctx
    WHERE (aci.catalog_cd=request->orderable_cd)
     AND (aci.coll_class_cd=request->old_coll_class_cd)
     AND expand(iter_seq_list,1,size(sequence_rec->sequence_list,5),aci.coll_info_seq,sequence_rec->
     sequence_list[iter_seq_list].sequence)
    WITH nocounter, expand = value(bedgetexpandind(size(sequence_rec->sequence_list,5)))
   ;end update
   IF (curqual=0)
    CALL bederrorcheck("Failed to update collection class on alt_collection_info table.")
   ENDIF
 END ;Subroutine
 SUBROUTINE openlogfile(dummyvar)
   SELECT INTO "ccluserdir:bed_save_rln_coll_req.log"
    msg_var
    HEAD REPORT
     curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
     col + 1, "Bedrock Save RLN collection requirement Log"
    DETAIL
     row + 2, col 2, " "
    WITH nocounter, format = variable, noformfeed,
     maxcol = 400, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logmessage(msg)
   SELECT INTO "ccluserdir:bed_save_rln_coll_req.log"
    msg_var
    DETAIL
     row + 1, col 0, msg
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 400, maxrow = 1
   ;end select
 END ;Subroutine
END GO
