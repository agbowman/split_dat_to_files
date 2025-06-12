CREATE PROGRAM bed_aud_pft_trans_dist:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 billing_entity_list[*]
      2 billing_entity_id = f8
    1 account_type_list[*]
      2 account_type = i2
    1 distribution_method_cd_list[*]
      2 distribution_method_cd = f8
    1 start_effective_date = dq8
    1 end_effective_date = dq8
    1 modified_by_list[*]
      2 modified_by = f8
    1 modified_from_date = dq8
    1 modified_to_date = dq8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i8
      2 total_items = i8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD tempreply
 RECORD tempreply(
   1 transdistconfiglist[*]
     2 billing_entity_name = vc
     2 account_type = vc
     2 distribution_method_cd = f8
     2 start_effective_date = dq8
     2 end_effective_date = dq8
     2 trans_dist_id = f8
     2 is_active = i2
     2 created_date_time = dq8
     2 created_by_id = f8
     2 created_by_name = vc
     2 modified_date_time = dq8
     2 modified_by_id = f8
     2 modified_by_name = vc
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
 DECLARE gettransactiondistributiondetails(null) = null
 DECLARE populatereportreplycolumns(null) = null
 DECLARE createreportreply(null) = null
 DECLARE trans_dist_config_cnt = i4 WITH protect, noconstant(0)
 DECLARE queryexecuted = i2 WITH protect, noconstant(0)
 DECLARE maxvalue = f8 WITH protect, noconstant(1000)
 DECLARE parsestring = vc
 DECLARE billingentityparser = vc
 DECLARE modbyparser = vc
 DECLARE distmethodparser = vc
 DECLARE accounttypeparser = vc
 DECLARE accounttype = vc WITH protect, noconstant("")
 DECLARE billingentitycnt = f8 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 CALL gettransactiondistributiondetails(null)
 CALL populatereportreplycolumns(null)
 CALL createreportreply(null)
 SUBROUTINE gettransactiondistributiondetails(null)
   SET parsestring = build(parsestring,"td.active_ind = TRUE")
   IF (cnvtdatetime(request->start_effective_date) != 0)
    SET parsestring = build(parsestring,
     " and td.beg_effective_dt_tm >= cnvtdatetime(request->start_effective_date)")
   ENDIF
   IF (cnvtdatetime(request->end_effective_date) != 0)
    SET parsestring = build(parsestring,
     " and  td.end_effective_dt_tm <= cnvtdatetime(request->end_effective_date)")
   ENDIF
   IF (cnvtdatetime(request->modified_from_date) != 0)
    SET parsestring = build(parsestring,
     " and td.updt_dt_tm >= cnvtdatetime(request->modified_from_date)")
   ENDIF
   IF (cnvtdatetime(request->modified_to_date) != 0)
    SET parsestring = build(parsestring,
     " and td.updt_dt_tm <=  cnvtdatetime(request->modified_to_date)")
   ENDIF
   IF (size(request->distribution_method_cd_list,5) > 0)
    FOR (i = 1 TO size(request->distribution_method_cd_list,5))
      SET distmethodparser = build(distmethodparser,request->distribution_method_cd_list[i].
       distribution_method_cd,",")
    ENDFOR
    SET distmethodparser = replace(distmethodparser,",","",2)
    SET parsestring = build(parsestring," and td.distribution_method_cd in (",distmethodparser,")")
   ENDIF
   IF (size(request->account_type_list,5) > 0)
    FOR (i = 1 TO size(request->account_type_list,5))
      SET accounttypeparser = build(accounttypeparser,request->account_type_list[i].account_type,",")
    ENDFOR
    SET accounttypeparser = replace(accounttypeparser,",","",2)
    SET parsestring = build(parsestring," and td.account_type_flag in (",accounttypeparser,")")
   ENDIF
   IF (size(request->modified_by_list,5) > 0)
    FOR (i = 1 TO size(request->modified_by_list,5))
      SET modbyparser = build(modbyparser,request->modified_by_list[i].modified_by,",")
    ENDFOR
    SET modbyparser = replace(modbyparser,",","",2)
    SET parsestring = build(parsestring," and td.updt_id in(",modbyparser,")")
   ENDIF
   SET billingentitycnt = 0
   IF (size(request->billing_entity_list,5) > 0)
    FOR (i = 1 TO size(request->billing_entity_list,5))
      IF (billingentitycnt > 999)
       SET billingentityparser = replace(billingentityparser,",","",2)
       SET billingentityparser = build(billingentityparser,") or td.billing_entity_id in (")
       SET billingentitycnt = 0
      ENDIF
      SET billingentityparser = build(billingentityparser,request->billing_entity_list[i].
       billing_entity_id,",")
      SET billingentitycnt = (billingentitycnt+ 1)
    ENDFOR
    SET billingentityparser = replace(billingentityparser,",","",2)
    SET parsestring = build(parsestring," and td.billing_entity_id in (",billingentityparser,")")
   ENDIF
   SELECT INTO "nl:"
    FROM pft_trans_dist_config td,
     prsnl prsnl,
     billing_entity be
    PLAN (td
     WHERE td.pft_trans_dist_config_id > 0.0
      AND parser(parsestring))
     JOIN (be
     WHERE be.billing_entity_id=td.billing_entity_id
      AND be.active_ind=true)
     JOIN (prsnl
     WHERE prsnl.person_id IN (td.updt_id, td.create_prsnl_id)
      AND prsnl.active_ind=true)
    DETAIL
     trans_dist_config_cnt = (trans_dist_config_cnt+ 1), stat = alterlist(tempreply->
      transdistconfiglist,trans_dist_config_cnt), tempreply->transdistconfiglist[
     trans_dist_config_cnt].billing_entity_name = be.be_name,
     tempreply->transdistconfiglist[trans_dist_config_cnt].account_type = evaluate(td
      .account_type_flag,0,"Self Pay",1,"Client"), tempreply->transdistconfiglist[
     trans_dist_config_cnt].distribution_method_cd = td.distribution_method_cd, tempreply->
     transdistconfiglist[trans_dist_config_cnt].start_effective_date = cnvtdatetime(td
      .beg_effective_dt_tm),
     tempreply->transdistconfiglist[trans_dist_config_cnt].end_effective_date = cnvtdatetime(td
      .end_effective_dt_tm), tempreply->transdistconfiglist[trans_dist_config_cnt].trans_dist_id = td
     .pft_trans_dist_config_id, tempreply->transdistconfiglist[trans_dist_config_cnt].is_active = td
     .active_ind,
     tempreply->transdistconfiglist[trans_dist_config_cnt].created_date_time = td.create_dt_tm,
     tempreply->transdistconfiglist[trans_dist_config_cnt].modified_date_time = cnvtdatetime(td
      .updt_dt_tm)
     IF (prsnl.person_id=td.create_prsnl_id)
      tempreply->transdistconfiglist[trans_dist_config_cnt].created_by_id = td.create_prsnl_id,
      tempreply->transdistconfiglist[trans_dist_config_cnt].created_by_name = prsnl
      .name_full_formatted
     ENDIF
     IF (prsnl.person_id=td.updt_id)
      tempreply->transdistconfiglist[trans_dist_config_cnt].modified_by_id = td.updt_id, tempreply->
      transdistconfiglist[trans_dist_config_cnt].modified_by_name = prsnl.name_full_formatted
     ENDIF
    WITH nocounter
   ;end select
   IF (trans_dist_config_cnt=0)
    GO TO exit_script
   ENDIF
   IF ((request->skip_volume_check_ind=0))
    IF (trans_dist_config_cnt > 10000)
     SET reply->high_volume_flag = 2
     GO TO exit_script
    ELSEIF (trans_dist_config_cnt > 3000)
     SET reply->high_volume_flag = 1
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE populatereportreplycolumns(null)
   SET stat = alterlist(reply->collist,7)
   SET reply->collist[1].header_text = "Billing Entity"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Distribution Method"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "Distribution Account"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Start Effective Date"
   SET reply->collist[4].data_type = 4
   SET reply->collist[4].hide_ind = 0
   SET reply->collist[5].header_text = "End Effective Date"
   SET reply->collist[5].data_type = 4
   SET reply->collist[5].hide_ind = 0
   SET reply->collist[6].header_text = "Modified By"
   SET reply->collist[6].data_type = 1
   SET reply->collist[6].hide_ind = 0
   SET reply->collist[7].header_text = "Modified Date"
   SET reply->collist[7].data_type = 4
   SET reply->collist[7].hide_ind = 0
 END ;Subroutine
 SUBROUTINE createreportreply(null)
   DECLARE row_nbr = i4 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   FOR (x = 1 TO trans_dist_config_cnt)
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
     SET reply->rowlist[row_nbr].celllist[1].string_value = tempreply->transdistconfiglist[x].
     billing_entity_name
     SET reply->rowlist[row_nbr].celllist[2].string_value = uar_get_code_display(tempreply->
      transdistconfiglist[x].distribution_method_cd)
     SET reply->rowlist[row_nbr].celllist[3].string_value = tempreply->transdistconfiglist[x].
     account_type
     SET reply->rowlist[row_nbr].celllist[4].date_value = tempreply->transdistconfiglist[x].
     start_effective_date
     SET reply->rowlist[row_nbr].celllist[5].date_value = tempreply->transdistconfiglist[x].
     end_effective_date
     SET reply->rowlist[row_nbr].celllist[6].string_value = tempreply->transdistconfiglist[x].
     modified_by_name
     SET reply->rowlist[row_nbr].celllist[7].date_value = tempreply->transdistconfiglist[x].
     modified_date_time
   ENDFOR
 END ;Subroutine
#labelexit_script
#exit_script
 CALL bedexitscript(1)
END GO
