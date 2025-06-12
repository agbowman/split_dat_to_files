CREATE PROGRAM bed_ens_rel_org_prsnl:dba
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
 FREE SET org_set
 RECORD org_set(
   1 os_list[*]
     2 org_set_id = f8
     2 org_list[*]
       3 org_id = f8
       3 active_ind = i2
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
 DECLARE org_cnt = i4 WITH protect
 DECLARE person_cnt = i4 WITH protect
 DECLARE por_active_ind = i2 WITH protect
 DECLARE por_end_eff_date = dq8 WITH protect
 DECLARE new_prsnl_org_reltn_id = f8 WITH protect
 DECLARE scount = i4 WITH protect
 DECLARE tot_scount = i4 WITH protect
 DECLARE tot_ocount = i4 WITH protect
 DECLARE org_cnt = i4 WITH protect
 DECLARE confid_change = f8 WITH protect
 DECLARE add_flag = i4 WITH protect
 DECLARE org_size = i4 WITH protect
 DECLARE updateorgsetprsnl(org_counter=i2,person_counter=i2) = null
 SET scount = 0
 SET tot_scount = 0
 SET tot_ocount = 0
 DECLARE active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE inactive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 DECLARE def_confid_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",87,"ROUTCLINICAL"))
 SET org_cnt = 0
 SET org_cnt = size(request->org_list,5)
 SET person_cnt = 0
 SET person_cnt = size(request->person_list,5)
 IF ((((request->org_list[1].org_id=0)) OR (org_cnt=0)) )
  CALL bederror("No organizations in request structure.")
 ENDIF
 IF ((request->action_flag=1))
  FOR (x = 1 TO org_cnt)
    SELECT INTO "nl:"
     FROM organization o
     WHERE (o.organization_id=request->org_list[x].org_id)
      AND o.active_ind=1
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL bederror(concat("No active org exists for: ",cnvtstring(request->org_list[x].org_id)))
    ENDIF
    FOR (y = 1 TO person_cnt)
      SELECT INTO "nl:"
       FROM prsnl p
       WHERE (p.person_id=request->person_list[y].person_id)
       WITH nocounter
      ;end select
      IF (curqual=0)
       CALL bederror(concat("No personnel row exists for: ",cnvtstring(request->person_list[y].
          person_id)))
      ENDIF
      SELECT INTO "NL:"
       FROM prsnl_org_reltn por
       WHERE (por.organization_id=request->org_list[x].org_id)
        AND (por.person_id=request->person_list[y].person_id)
       DETAIL
        por_end_eff_date = por.end_effective_dt_tm
       WITH nocounter
      ;end select
      IF (curqual=0)
       SELECT INTO "nl:"
        next_seq_value = seq(prsnl_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_prsnl_org_reltn_id = next_seq_value
        WITH format, counter
       ;end select
       IF (curqual=0)
        CALL bederror(concat("Error generating new org-prsnl relationship id for org: ",cnvtstring(
           request->org_list[x].org_id),"  prsnl: ",cnvtstring(request->person_list[y].person_id),"."
          ))
       ELSE
        INSERT  FROM prsnl_org_reltn por
         SET por.prsnl_org_reltn_id = new_prsnl_org_reltn_id, por.organization_id = request->
          org_list[x].org_id, por.person_id = request->person_list[y].person_id,
          por.confid_level_cd =
          IF ((request->person_list[y].confid_level_code_value > 0)) request->person_list[y].
           confid_level_code_value
          ELSE def_confid_cd
          ENDIF
          , por.updt_id = reqinfo->updt_id, por.updt_cnt = 0,
          por.updt_applctx = reqinfo->updt_applctx, por.updt_task = reqinfo->updt_task, por
          .updt_dt_tm = cnvtdatetime(curdate,curtime3),
          por.active_ind = 1, por.active_status_cd = active_cd, por.active_status_dt_tm =
          cnvtdatetime(curdate,curtime3),
          por.active_status_prsnl_id = reqinfo->updt_id, por.beg_effective_dt_tm = cnvtdatetime(
           curdate,curtime3), por.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
         WITH nocounter
        ;end insert
        IF (curqual=0)
         CALL bederror(concat("Error inserting org-prsnl relationship for Org: ",cnvtstring(request->
            org_list[x].org_id),"  Prsnl: ",cnvtstring(request->person_list[y].person_id),"."))
        ENDIF
       ENDIF
      ELSEIF (por_end_eff_date < cnvtdatetime(curdate,curtime3))
       UPDATE  FROM prsnl_org_reltn por
        SET por.updt_id = reqinfo->updt_id, por.updt_cnt = (por.updt_cnt+ 1), por.updt_applctx =
         reqinfo->updt_applctx,
         por.updt_task = reqinfo->updt_task, por.updt_dt_tm = cnvtdatetime(curdate,curtime3), por
         .active_ind = 1,
         por.active_status_cd = active_cd, por.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
         por.active_status_prsnl_id = reqinfo->updt_id,
         por.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), por.end_effective_dt_tm =
         cnvtdatetime("31-DEC-2100")
        WHERE (por.person_id=request->person_list[y].person_id)
         AND (por.organization_id=request->org_list[x].org_id)
        WITH nocounter
       ;end update
       IF (curqual=0)
        CALL bederror(concat("Error activating org-prsnl relationship for Org: ",cnvtstring(request->
           org_list[x].org_id),"  Prsnl: ",cnvtstring(request->person_list[y].person_id),"."))
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 IF ((request->action_flag=3))
  FOR (x = 1 TO org_cnt)
    SELECT INTO "nl:"
     FROM organization o
     WHERE (o.organization_id=request->org_list[x].org_id)
      AND o.active_ind=1
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL bederror(concat("No active org exists for: ",cnvtstring(request->org_list[x].org_id)))
    ENDIF
    FOR (y = 1 TO person_cnt)
      CALL echo(build("person id = ",request->person_list[y].person_id))
      SELECT INTO "nl:"
       FROM prsnl p
       WHERE (p.person_id=request->person_list[y].person_id)
       WITH nocounter
      ;end select
      CALL echo(build("curqual = ",curqual))
      IF (curqual=0)
       CALL bederror(concat("No personnel row exists for: ",cnvtstring(request->person_list[y].
          person_id)))
      ENDIF
      SET confid_change = 0.0
      SELECT INTO "nl:"
       FROM prsnl_org_reltn por
       PLAN (por
        WHERE (por.person_id=request->person_list[y].person_id)
         AND (por.organization_id=request->org_list[x].org_id)
         AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
       DETAIL
        confid_change = por.confid_level_cd
       WITH nocounter
      ;end select
      IF ((((request->person_list[y].person_action_flag=1)) OR ((request->person_list[y].
      person_action_flag=2))) )
       IF (curqual=0)
        SELECT INTO "nl:"
         next_seq_value = seq(prsnl_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          new_prsnl_org_reltn_id = next_seq_value
         WITH format, counter
        ;end select
        IF (curqual=0)
         EXECUTE bederror concat("Error generating new org-prsnl relationship id for org: ",
          cnvtstring(request->org_list[x].org_id),"  prsnl: ",cnvtstring(request->person_list[y].
           person_id),".")
        ENDIF
        INSERT  FROM prsnl_org_reltn por
         SET por.prsnl_org_reltn_id = new_prsnl_org_reltn_id, por.organization_id = request->
          org_list[x].org_id, por.person_id = request->person_list[y].person_id,
          por.confid_level_cd = request->person_list[y].confid_level_code_value, por.updt_id =
          reqinfo->updt_id, por.updt_cnt = 0,
          por.updt_applctx = reqinfo->updt_applctx, por.updt_task = reqinfo->updt_task, por
          .updt_dt_tm = cnvtdatetime(curdate,curtime3),
          por.active_ind = 1, por.active_status_cd = active_cd, por.active_status_dt_tm =
          cnvtdatetime(curdate,curtime3),
          por.active_status_prsnl_id = reqinfo->updt_id, por.beg_effective_dt_tm = cnvtdatetime(
           curdate,curtime3), por.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
         WITH nocounter
        ;end insert
       ELSEIF ((confid_change != request->person_list[y].confid_level_code_value))
        UPDATE  FROM prsnl_org_reltn por
         SET por.updt_id = reqinfo->updt_id, por.updt_cnt = (por.updt_cnt+ 1), por.updt_applctx =
          reqinfo->updt_applctx,
          por.updt_task = reqinfo->updt_task, por.updt_dt_tm = cnvtdatetime(curdate,curtime3), por
          .active_ind = 1,
          por.confid_level_cd = request->person_list[y].confid_level_code_value, por.active_status_cd
           = active_cd, por.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
          por.active_status_prsnl_id = reqinfo->updt_id, por.beg_effective_dt_tm = cnvtdatetime(
           curdate,curtime3), por.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
         WHERE (por.person_id=request->person_list[y].person_id)
          AND (por.organization_id=request->org_list[x].org_id)
         WITH nocounter
        ;end update
       ENDIF
      ELSEIF ((request->person_list[y].person_action_flag=3))
       SET add_flag = 0
       SELECT INTO "nl:"
        FROM prsnl_org_reltn por
        PLAN (por
         WHERE (por.person_id=request->person_list[y].person_id)
          AND (por.organization_id=request->org_list[x].org_id))
        DETAIL
         add_flag = por.active_ind
        WITH nocounter
       ;end select
       IF (curqual > 0
        AND add_flag=1)
        UPDATE  FROM prsnl_org_reltn por
         SET por.updt_id = reqinfo->updt_id, por.updt_cnt = (por.updt_cnt+ 1), por.updt_applctx =
          reqinfo->updt_applctx,
          por.updt_task = reqinfo->updt_task, por.updt_dt_tm = cnvtdatetime(curdate,curtime3), por
          .end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
         WHERE (por.person_id=request->person_list[y].person_id)
          AND (por.organization_id=request->org_list[x].org_id)
         WITH nocounter
        ;end update
       ENDIF
      ENDIF
      SELECT INTO "NL:"
       FROM org_set_org_r os
       WHERE os.active_ind=1
        AND (os.organization_id=request->org_list[x].org_id)
       HEAD REPORT
        stat = alterlist(org_set->os_list,10), scount = 0, tot_scount = 0
       DETAIL
        scount = (scount+ 1), tot_scount = (tot_scount+ 1)
        IF (scount > 10)
         stat = alterlist(org_set->os_list,(tot_scount+ 10)), scount = 1
        ENDIF
        org_set->os_list[tot_scount].org_set_id = os.org_set_id
       FOOT REPORT
        stat = alterlist(org_set->os_list,tot_scount)
       WITH nocounter
      ;end select
      IF (tot_scount > 0)
       SELECT INTO "NL:"
        FROM (dummyt d  WITH seq = tot_scount),
         org_set_org_r os,
         org_set_prsnl_r op,
         prsnl_org_reltn por
        PLAN (d)
         JOIN (op
         WHERE (op.prsnl_id=request->person_list[y].person_id)
          AND (op.org_set_id=org_set->os_list[d.seq].org_set_id)
          AND op.active_ind=1)
         JOIN (os
         WHERE (os.org_set_id=org_set->os_list[d.seq].org_set_id)
          AND (os.organization_id != request->org_list[x].org_id)
          AND os.active_ind=1)
         JOIN (por
         WHERE por.person_id=outerjoin(request->person_list[y].person_id)
          AND por.organization_id=outerjoin(os.organization_id))
        ORDER BY os.organization_id
        HEAD REPORT
         tot_ocount = 0
        HEAD os.organization_id
         tot_ocount = (tot_ocount+ 1), stat = alterlist(org_set->os_list[d.seq].org_list,tot_ocount),
         org_set->os_list[d.seq].org_list[tot_ocount].org_id = os.organization_id
         IF (por.prsnl_org_reltn_id > 0)
          org_set->os_list[d.seq].org_list[tot_ocount].active_ind = por.active_ind
         ELSE
          org_set->os_list[d.seq].org_list[tot_ocount].active_ind = 3
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
      FOR (o = 1 TO tot_scount)
        CALL updateorgsetprsnl(o,y)
        SET org_size = size(org_set->os_list[o].org_list,5)
        FOR (oo = 1 TO org_size)
          IF ((org_set->os_list[o].org_list[oo].active_ind=3))
           SELECT INTO "nl:"
            next_seq_value = seq(prsnl_seq,nextval)"##################;rp0"
            FROM dual
            DETAIL
             new_prsnl_org_reltn_id = next_seq_value
            WITH format, counter
           ;end select
           IF (curqual=0)
            CALL bederror(concat("Error generating new org-prsnl relationship id for org: ",
              cnvtstring(request->org_list[x].org_id),"  prsnl: ",cnvtstring(request->person_list[y].
               person_id),"."))
           ENDIF
           INSERT  FROM prsnl_org_reltn por
            SET por.prsnl_org_reltn_id = new_prsnl_org_reltn_id, por.organization_id = org_set->
             os_list[o].org_list[oo].org_id, por.person_id = request->person_list[y].person_id,
             por.confid_level_cd =
             IF ((request->person_list[y].confid_level_code_value > 0)) request->person_list[y].
              confid_level_code_value
             ELSE def_confid_cd
             ENDIF
             , por.updt_id = reqinfo->updt_id, por.updt_cnt = 0,
             por.updt_applctx = reqinfo->updt_applctx, por.updt_task = reqinfo->updt_task, por
             .updt_dt_tm = cnvtdatetime(curdate,curtime3),
             por.active_ind = 1, por.active_status_cd = active_cd, por.active_status_dt_tm =
             cnvtdatetime(curdate,curtime3),
             por.active_status_prsnl_id = reqinfo->updt_id, por.beg_effective_dt_tm = cnvtdatetime(
              curdate,curtime3), por.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
            WITH nocounter
           ;end insert
          ELSEIF ((org_set->os_list[o].org_list[oo].active_ind=0))
           UPDATE  FROM prsnl_org_reltn por
            SET por.updt_id = reqinfo->updt_id, por.updt_cnt = (por.updt_cnt+ 1), por.updt_applctx =
             reqinfo->updt_applctx,
             por.updt_task = reqinfo->updt_task, por.updt_dt_tm = cnvtdatetime(curdate,curtime3), por
             .active_ind = 1,
             por.active_status_cd = active_cd, por.active_status_dt_tm = cnvtdatetime(curdate,
              curtime3), por.active_status_prsnl_id = reqinfo->updt_id,
             por.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), por.end_effective_dt_tm =
             cnvtdatetime("31-DEC-2100")
            WHERE (por.person_id=request->person_list[y].person_id)
             AND (por.organization_id=org_set->os_list[o].org_list[oo].org_id)
            WITH nocounter
           ;end update
          ENDIF
        ENDFOR
      ENDFOR
    ENDFOR
  ENDFOR
 ENDIF
 SUBROUTINE updateorgsetprsnl(org_counter,person_counter)
   UPDATE  FROM org_set_prsnl_r os
    SET os.updt_id = reqinfo->updt_id, os.updt_cnt = (os.updt_cnt+ 1), os.updt_applctx = reqinfo->
     updt_applctx,
     os.updt_task = reqinfo->updt_task, os.updt_dt_tm = cnvtdatetime(curdate,curtime3), os.active_ind
      = 0,
     os.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (os.org_set_id=org_set->os_list[org_counter].org_set_id)
     AND (os.prsnl_id=request->person_list[person_counter].person_id)
    WITH nocounter
   ;end update
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
