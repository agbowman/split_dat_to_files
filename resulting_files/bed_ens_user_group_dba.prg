CREATE PROGRAM bed_ens_user_group:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 prsnl_group_id = f8
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
 DECLARE validaterequestdata(dummyvar=i2) = i2
 DECLARE addnewusergroup(dummyvar=i2) = i2
 DECLARE updateusergroup(dummyvar=i2) = i2
 DECLARE updateusergroupattributes(dummyvar=i2) = i2
 DECLARE updateusergrouppersonnelrelations(dummyvar=i2) = i2
 DECLARE getusergroupname(typecd=f8) = vc
 DECLARE inactivateexistingpersonnel(dummyvar=i2) = i2
 DECLARE handlemedicalservices(typecd=f8) = i2
 DECLARE auditevent(auditeventflag=i2,mode=i2,participantid=f8,participantname=vc) = i2
 DECLARE prepareandauditaddedpersonnel(addedpersonnelrec=vc(ref),usergroupid=f8) = i2
 DECLARE prepareandauditremovedpersonnel(usergroupid=f8) = i2
 DECLARE addchartaccess(usergroupid=f8,orgid=f8) = i2
 DECLARE deletechartaccess(usergroupid=f8,orgid=f8) = i2
 DECLARE configurechartaccess(dummyvar=i2) = i2
 DECLARE logicaldomainid = f8 WITH protect, constant(bedgetlogicaldomain(0))
 IF ( NOT (validate(cs4000380_chartaccess_cd)))
  DECLARE cs4000380_chartaccess_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",4000380,
    "CHARTACCESS"))
 ENDIF
 DECLARE audit_event_add_user_group = i2 WITH protect, constant(1)
 DECLARE audit_event_modify_user_group = i2 WITH protect, constant(2)
 DECLARE audit_event_user_to_user_group = i2 WITH protect, constant(3)
 DECLARE usergroupname = vc WITH protect, noconstant("")
 DECLARE usergroupid = f8 WITH protect, noconstant(request->prsnl_group_id)
 DECLARE end_effective_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00.00"))
 IF ((cs4000380_chartaccess_cd=- (1)))
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=4000380
    AND cv.cdf_meaning="CHARTACCESS"
   DETAIL
    cs4000380_chartaccess_cd = cv.code_value
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 004: Failed to get code_value from 4000380 code_set")
 ENDIF
 IF ( NOT (validaterequestdata(0)))
  CALL bederror("Invalid request data.")
 ENDIF
 SET usergroupname = getusergroupname(request->prsnl_type_cd)
 IF (usergroupid=0)
  CALL addnewusergroup(0)
 ELSE
  CALL updateusergroup(0)
 ENDIF
#exit_script
 SET reply->prsnl_group_id = usergroupid
 CALL bedexitscript(1)
 SUBROUTINE validaterequestdata(dummyvar)
   CALL bedlogmessage("validateRequestData","Entering ...")
   IF ((request->prsnl_type_cd=0))
    CALL bedlogmessage("validateRequestData",build2("Invalid request. Invalid prsnl_type_cd: ",
      request->prsnl_type_cd))
    RETURN(false)
   ENDIF
   IF (size(request->personnel_to_add,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(request->personnel_to_add,5)),
      prsnl p
     PLAN (d
      WHERE (request->personnel_to_add[d.seq].prsnl_id > 0))
      JOIN (p
      WHERE (p.person_id=request->personnel_to_add[d.seq].prsnl_id)
       AND p.logical_domain_id != logicaldomainid)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL bedlogmessage("validateRequestData",
      "One of the given prnsl_id does not belong to the user's logical domain.")
     RETURN(false)
    ENDIF
   ENDIF
   IF (size(request->personnel_to_remove,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(request->personnel_to_remove,5)),
      prsnl p
     PLAN (d
      WHERE (request->personnel_to_remove[d.seq].prsnl_id > 0))
      JOIN (p
      WHERE (p.person_id=request->personnel_to_remove[d.seq].prsnl_id)
       AND p.logical_domain_id != logicaldomainid)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL bedlogmessage("validateRequestData",
      "One of the given prnsl_id does not belong to the user's logical domain.")
     RETURN(false)
    ENDIF
   ENDIF
   CALL bedlogmessage("validateRequestData","Exiting ...")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE getusergroupname(typecd)
   DECLARE usergroupname = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_value=typecd
     AND cv.active_ind=true
    DETAIL
     usergroupname = cv.display
    WITH nocounter
   ;end select
   RETURN(usergroupname)
 END ;Subroutine
 SUBROUTINE addnewusergroup(dummyvar)
   CALL bedlogmessage("addNewUserGroup","Entering ...")
   SELECT INTO "nl:"
    id = seq(prsnl_seq,nextval)
    FROM dual
    DETAIL
     usergroupid = cnvtreal(id)
    WITH format, counter
   ;end select
   INSERT  FROM prsnl_group pg
    SET pg.active_ind = 1, pg.active_status_cd = reqdata->active_status_cd, pg.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     pg.active_status_prsnl_id = reqinfo->updt_id, pg.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), pg.contributor_system_cd = reqdata->contributor_system_cd,
     pg.data_status_cd = reqdata->data_status_cd, pg.data_status_dt_tm = cnvtdatetime(curdate,
      curtime3), pg.data_status_prsnl_id = reqinfo->updt_id,
     pg.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pg.prsnl_group_class_cd =
     request->prsnl_class_cd, pg.prsnl_group_desc = request->prsnl_group_desc,
     pg.prsnl_group_id = usergroupid, pg.prsnl_group_name = usergroupname, pg.prsnl_group_name_key =
     cnvtupper(usergroupname),
     pg.prsnl_group_type_cd = request->prsnl_type_cd, pg.service_resource_cd = request->
     service_resource_cd, pg.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     pg.updt_id = reqinfo->updt_id, pg.updt_task = reqinfo->updt_task, pg.updt_applctx = reqinfo->
     updt_applctx,
     pg.updt_cnt = 0
    WITH nocounter
   ;end insert
   CALL bederrorcheck("Error inserting into prsnl_group table")
   CALL handlemedicalservices(request->prsnl_type_cd)
   CALL updateusergrouppersonnelrelations(0)
   CALL configurechartaccess(0)
   CALL auditevent(audit_event_add_user_group,0,usergroupid,usergroupname)
   CALL bedlogmessage("addNewUserGroup","Exiting ...")
 END ;Subroutine
 SUBROUTINE updateusergroup(dummyvar)
   CALL bedlogmessage("updateUserGroup","Entering ...")
   DECLARE typecd = f8 WITH protect, noconstant(0)
   DECLARE logeventind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl_group pg
    PLAN (pg
     WHERE pg.prsnl_group_id=usergroupid
      AND pg.prsnl_group_name=usergroupname
      AND (pg.active_ind=request->active_ind)
      AND (pg.prsnl_group_type_cd=request->prsnl_type_cd)
      AND (pg.prsnl_group_class_cd=request->prsnl_class_cd)
      AND (pg.prsnl_group_desc=request->prsnl_group_desc)
      AND (pg.service_resource_cd=request->service_resource_cd))
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failure in updateUserGroup()")
   IF (curqual=0)
    CALL updateusergroupattributes(0)
    SET logeventind = 1
   ENDIF
   SELECT INTO "nl:"
    FROM prsnl_group pg
    PLAN (pg
     WHERE pg.prsnl_group_id=usergroupid)
    DETAIL
     typecd = pg.prsnl_group_type_cd
    WITH nocounter
   ;end select
   CALL handlemedicalservices(typecd)
   CALL configurechartaccess(0)
   IF ((request->active_ind=0)
    AND (request->inactivate_existing_prsnl_reltn=1))
    CALL inactivateexistingpersonnel(0)
   ENDIF
   IF (((size(request->personnel_to_add,5) > 0) OR (size(request->personnel_to_remove,5) > 0)) )
    CALL updateusergrouppersonnelrelations(0)
    SET logeventind = 1
   ENDIF
   IF (logeventind=1)
    CALL auditevent(audit_event_modify_user_group,0,usergroupid,usergroupname)
   ENDIF
   CALL bedlogmessage("updateUserGroup","Exiting ...")
 END ;Subroutine
 SUBROUTINE inactivateexistingpersonnel(dummyvar)
   DECLARE pcnt = i4 WITH protect, noconstant(0)
   FREE RECORD prnsltoinactivate
   RECORD prnsltoinactivate(
     1 list[*]
       2 prsnl_group_reltn_id = f8
   )
   SELECT INTO "nl:"
    FROM prsnl_group_reltn pgr,
     person p
    PLAN (pgr
     WHERE pgr.prsnl_group_id=usergroupid
      AND pgr.active_ind=true)
     JOIN (p
     WHERE p.person_id=pgr.person_id
      AND p.logical_domain_id=logicaldomainid)
    ORDER BY pgr.prsnl_group_reltn_id
    HEAD pgr.prsnl_group_reltn_id
     pcnt = (pcnt+ 1), stat = alterlist(prnsltoinactivate->list,pcnt), prnsltoinactivate->list[pcnt].
     prsnl_group_reltn_id = pgr.prsnl_group_reltn_id
    WITH nocounter
   ;end select
   UPDATE  FROM prsnl_group_reltn pgr,
     (dummyt dt  WITH seq = pcnt)
    SET pgr.active_ind = 0, pgr.active_status_cd = reqdata->inactive_status_cd, pgr
     .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
     pgr.active_status_prsnl_id = reqinfo->updt_id, pgr.end_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), pgr.data_status_cd = reqdata->data_status_cd,
     pgr.data_status_dt_tm = cnvtdatetime(curdate,curtime3), pgr.data_status_prsnl_id = reqinfo->
     updt_id, pgr.updt_cnt = (pgr.updt_cnt+ 1),
     pgr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pgr.updt_id = reqinfo->updt_id, pgr.updt_task
      = reqinfo->updt_task,
     pgr.updt_applctx = reqinfo->updt_applctx
    PLAN (dt)
     JOIN (pgr
     WHERE (pgr.prsnl_group_reltn_id=prnsltoinactivate->list[dt.seq].prsnl_group_reltn_id))
    WITH nocounter
   ;end update
   CALL bederrorcheck("inactivate existing prsnl reltn")
 END ;Subroutine
 SUBROUTINE updateusergroupattributes(dummyvar)
   CALL bedlogmessage("updateUserGroupAttributes","Entering ...")
   IF ((request->active_ind=0))
    SET end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   ENDIF
   UPDATE  FROM prsnl_group pg
    SET pg.prsnl_group_name = usergroupname, pg.prsnl_group_name_key = cnvtupper(usergroupname), pg
     .active_ind = request->active_ind,
     pg.prsnl_group_type_cd = request->prsnl_type_cd, pg.prsnl_group_class_cd = request->
     prsnl_class_cd, pg.prsnl_group_desc = request->prsnl_group_desc,
     pg.service_resource_cd = request->service_resource_cd, pg.updt_applctx = reqinfo->updt_applctx,
     pg.updt_cnt = (pg.updt_cnt+ 1),
     pg.updt_dt_tm = cnvtdatetime(curdate,curtime3), pg.end_effective_dt_tm = cnvtdatetime(
      end_effective_dt_tm), pg.updt_id = reqinfo->updt_id,
     pg.updt_task = reqinfo->updt_task
    WHERE pg.prsnl_group_id=usergroupid
    WITH nocounter
   ;end update
   CALL bederrorcheck("Failed to update prsnl_group table")
   CALL bedlogmessage("updateUserGroupAttributes","Exiting ...")
 END ;Subroutine
 SUBROUTINE updateusergrouppersonnelrelations(dummyvar)
   CALL bedlogmessage("updateUserGroupPersonnelRelations","Entering ...")
   DECLARE addcnt = i4 WITH protect, noconstant(size(request->personnel_to_add,5))
   DECLARE remcnt = i4 WITH protect, noconstant(size(request->personnel_to_remove,5))
   DECLARE usergroupname = vc WITH protect, noconstant("")
   IF (addcnt > 0)
    RECORD padd(
      1 personnel_to_add[*]
        2 prsnl_id = f8
        2 exists_ind = i2
    )
    SET stat = alterlist(padd->personnel_to_add,addcnt)
    FOR (i = 1 TO addcnt)
      SET padd->personnel_to_add[i].prsnl_id = request->personnel_to_add[i].prsnl_id
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = addcnt),
      prsnl_group_reltn pgr
     PLAN (d
      WHERE (padd->personnel_to_add[d.seq].prsnl_id > 0))
      JOIN (pgr
      WHERE pgr.prsnl_group_id=usergroupid
       AND (pgr.person_id=padd->personnel_to_add[d.seq].prsnl_id)
       AND pgr.active_ind=true)
     DETAIL
      padd->personnel_to_add[d.seq].exists_ind = 1
     WITH nocounter
    ;end select
    INSERT  FROM prsnl_group_reltn pgr,
      (dummyt dt  WITH seq = value(addcnt))
     SET pgr.seq = 1, pgr.prsnl_group_reltn_id = seq(prsnl_seq,nextval), pgr.person_id = padd->
      personnel_to_add[dt.seq].prsnl_id,
      pgr.prsnl_group_id = usergroupid, pgr.primary_ind = 0, pgr.updt_cnt = 0,
      pgr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pgr.updt_id = reqinfo->updt_id, pgr.updt_task
       = reqinfo->updt_task,
      pgr.updt_applctx = reqinfo->updt_applctx, pgr.active_ind = 1, pgr.active_status_cd = reqdata->
      active_status_cd,
      pgr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), pgr.active_status_prsnl_id = reqinfo
      ->updt_id, pgr.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      pgr.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), pgr.data_status_cd = reqdata
      ->data_status_cd, pgr.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
      pgr.data_status_prsnl_id = reqinfo->updt_id, pgr.contributor_system_cd = reqdata->
      contributor_system_cd
     PLAN (dt
      WHERE (padd->personnel_to_add[dt.seq].exists_ind=0))
      JOIN (pgr
      WHERE (pgr.person_id=padd->personnel_to_add[dt.seq].prsnl_id))
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failure in updateUserGroupPersonnelRelations()")
    CALL prepareandauditaddedpersonnel(padd,usergroupid)
   ENDIF
   IF (size(request->personnel_to_remove,5) > 0)
    UPDATE  FROM prsnl_group_reltn pgr,
      (dummyt dt  WITH seq = value(size(request->personnel_to_remove,5)))
     SET pgr.active_ind = 0, pgr.updt_applctx = reqinfo->updt_applctx, pgr.updt_cnt = (pgr.updt_cnt+
      1),
      pgr.updt_dt_tm = cnvtdatetime(curdate,curtime3), pgr.updt_id = reqinfo->updt_id, pgr.updt_task
       = reqinfo->updt_task
     PLAN (dt)
      JOIN (pgr
      WHERE (pgr.person_id=request->personnel_to_remove[dt.seq].prsnl_id)
       AND pgr.active_ind=true
       AND pgr.prsnl_group_id=usergroupid)
     WITH nocounter
    ;end update
    CALL bederrorcheck("Failure in updateUserGroupPersonnelRelations()")
    CALL prepareandauditremovedpersonnel(usergroupid)
   ENDIF
   CALL bedlogmessage("updateUserGroupPersonnelRelations","Exiting ...")
 END ;Subroutine
 SUBROUTINE handlemedicalservices(typecd)
   CALL bedlogmessage("handleMedicalServices","Entering ...")
   DELETE  FROM code_value_group cvg
    WHERE cvg.parent_code_value=typecd
     AND cvg.code_set=357
     AND cvg.child_code_value > 0
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Failure in handleMedicalServices() - delete failed.")
   IF (size(request->medical_services,5) > 0)
    INSERT  FROM code_value_group cvg,
      (dummyt dt  WITH seq = size(request->medical_services,5))
     SET cvg.child_code_value = request->medical_services[dt.seq].medical_service_cd, cvg
      .parent_code_value = typecd, cvg.code_set = 357,
      cvg.updt_applctx = reqinfo->updt_applctx, cvg.updt_cnt = 0, cvg.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      cvg.updt_id = reqinfo->updt_id, cvg.updt_task = reqinfo->updt_task
     PLAN (dt)
      JOIN (cvg)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failure in handleMedicalServices() - insert failed.")
   ENDIF
   CALL bedlogmessage("handleMedicalServices","Exiting ...")
 END ;Subroutine
 SUBROUTINE auditevent(auditeventflag,mode,participantid,participantname)
   CALL bedlogmessage("auditEvent","Entering ...")
   CASE (auditeventflag)
    OF audit_event_add_user_group:
     EXECUTE cclaudit mode, nullterm("Maintain User"), nullterm("Add User Group"),
     nullterm("System Object"), nullterm("Resource"), nullterm("User Group Name"),
     nullterm("Origination/Creation"), participantid, nullterm(participantname)
    OF audit_event_modify_user_group:
     EXECUTE cclaudit mode, nullterm("Maintain User"), nullterm("Maintain User Group"),
     nullterm("System Object"), nullterm("Resource"), nullterm("User Group Name"),
     nullterm("Amendment"), participantid, nullterm(participantname)
    OF audit_event_user_to_user_group:
     EXECUTE cclaudit mode, nullterm("Maintain User"), nullterm("User Groupings"),
     nullterm("Person"), nullterm("Provider"), nullterm("Provider"),
     nullterm("Amendment"), participantid, nullterm(participantname)
   ENDCASE
   CALL bedlogmessage("auditEvent","Exiting ...")
 END ;Subroutine
 SUBROUTINE prepareandauditaddedpersonnel(addedpersonnelrec,usergroupid)
   CALL bedlogmessage("prepareAndAuditAddedPersonnel","Entering ...")
   DECLARE addedpersonnelsize = i4 WITH protect, constant(size(addedpersonnelrec->personnel_to_add,5)
    )
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE personname = vc WITH protect, noconstant("")
   DECLARE auditmode = i2 WITH protect, noconstant(0)
   FREE RECORD adduser
   RECORD adduser(
     1 list[*]
       2 id = f8
       2 name = vc
   )
   SET stat = alterlist(adduser->list,addedpersonnelsize)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = addedpersonnelsize),
     prsnl p
    PLAN (d
     WHERE (addedpersonnelrec->personnel_to_add[d.seq].exists_ind=0))
     JOIN (p
     WHERE (p.person_id=addedpersonnelrec->personnel_to_add[d.seq].prsnl_id))
    DETAIL
     cnt = (cnt+ 1), adduser->list[cnt].id = addedpersonnelrec->personnel_to_add[d.seq].prsnl_id,
     adduser->list[cnt].name = trim(p.name_full_formatted,3)
    WITH nocounter
   ;end select
   SET stat = alterlist(adduser->list,cnt)
   IF (cnt=1)
    SET personname = build2("Added: ",adduser->list[1].name)
    CALL auditevent(audit_event_user_to_user_group,0,adduser->list[1].id,personname)
   ELSE
    FOR (i = 1 TO cnt)
     IF (i=1)
      SET auditmode = 1
     ELSEIF (i < cnt)
      SET auditmode = 2
     ELSE
      SET auditmode = 3
     ENDIF
     CALL auditevent(audit_event_user_to_user_group,auditmode,adduser->list[1].id,build2("Added: ",
       adduser->list[i].name))
    ENDFOR
   ENDIF
   CALL bedlogmessage("prepareAndAuditAddedPersonnel","Exiting ...")
 END ;Subroutine
 SUBROUTINE prepareandauditremovedpersonnel(usergroupid)
   CALL bedlogmessage("prepareAndAuditRemovedPersonnel","Entering ...")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE usergroupname = vc WITH protect, noconstant("")
   FREE RECORD remuser
   RECORD remuser(
     1 list[*]
       2 id = f8
       2 name = vc
   )
   SET stat = alterlist(remuser->list,size(request->personnel_to_remove,5))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(request->personnel_to_remove,5)),
     prsnl p
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=request->personnel_to_remove[d.seq].prsnl_id))
    DETAIL
     cnt = (cnt+ 1), remuser->list[cnt].id = p.person_id, remuser->list[cnt].name = build2(
      "Removed: ",trim(p.name_full_formatted,3))
    WITH nocounter
   ;end select
   SET stat = alterlist(remuser->list,cnt)
   IF (cnt=1)
    CALL auditevent(audit_event_user_to_user_group,0,remuser->list[1].id,remuser->list[1].name)
   ELSE
    FOR (i = 1 TO cnt)
     IF (i=1)
      SET auditmode = 1
     ELSEIF (i < cnt)
      SET auditmode = 2
     ELSE
      SET auditmode = 3
     ENDIF
     CALL auditevent(audit_event_user_to_user_group,auditmode,remuser->list[1].id,remuser->list[i].
      name)
    ENDFOR
   ENDIF
   CALL bedlogmessage("prepareAndAuditRemovedPersonnel","Exiting ...")
 END ;Subroutine
 SUBROUTINE addchartaccess(usergroupid,orgid)
   CALL bedlogmessage("addChartAccess","Entering ...")
   DECLARE id = f8 WITH protect, noconstant(0.0)
   DECLARE alreadyexists = i2 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM prsnl_group_org_reltn p
    PLAN (p
     WHERE p.prsnl_group_id=usergroupid
      AND p.organization_id=orgid
      AND p.reltn_type_cd=cs4000380_chartaccess_cd)
    DETAIL
     alreadyexists = 1
    WITH nocounter
   ;end select
   IF (alreadyexists != 1)
    SELECT INTO "nl:"
     nextseqnum = seq(prsnl_seq,nextval)
     FROM dual
     DETAIL
      id = cnvtreal(nextseqnum)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 001: Failed to get new id for chart access relation.")
    INSERT  FROM prsnl_group_org_reltn p
     SET p.prsnl_group_org_reltn_id = id, p.prsnl_group_id = usergroupid, p.organization_id = orgid,
      p.reltn_type_cd = cs4000380_chartaccess_cd, p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
      updt_task
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error 002: Failed to get new id for chart access relation.")
   ENDIF
   CALL bedlogmessage("addChartAccess","Exiting ...")
 END ;Subroutine
 SUBROUTINE deletechartaccess(usergroupid,orgid)
   CALL bedlogmessage("deleteChartAccess","Entering ...")
   DELETE  FROM prsnl_group_org_reltn p
    WHERE p.prsnl_group_id=usergroupid
     AND p.organization_id=orgid
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error 003: Failed to delete chart access")
   CALL bedlogmessage("deleteChartAccess","Exiting ...")
 END ;Subroutine
 SUBROUTINE configurechartaccess(dummyvar)
   CALL bedlogmessage("configureChartAccess","Entering ...")
   IF (validate(request->chart_access_orgs))
    FOR (i = 1 TO size(request->chart_access_orgs,5))
      IF ((request->chart_access_orgs[i].action_flag=1))
       CALL addchartaccess(usergroupid,request->chart_access_orgs[i].org_id)
      ELSEIF ((request->chart_access_orgs[i].action_flag=3))
       CALL deletechartaccess(usergroupid,request->chart_access_orgs[i].org_id)
      ENDIF
    ENDFOR
   ENDIF
   CALL bedlogmessage("configureChartAccess","Exiting ...")
 END ;Subroutine
END GO
