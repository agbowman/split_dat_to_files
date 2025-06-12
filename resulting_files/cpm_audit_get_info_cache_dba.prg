CREATE PROGRAM cpm_audit_get_info_cache:dba
 EXECUTE sacrtl
 EXECUTE srvcore
 SUBROUTINE (querykey(key_str=vc,curs=i4(ref)) =vc)
   DECLARE str_max_length = i4 WITH noconstant(132)
   DECLARE buf2 = c132 WITH noconstant(fillstring(132," "))
   DECLARE ret = i4 WITH noconstant(0)
   SET ret = uar_srvquerykey(0,nullterm(key_str),buf2,str_max_length,curs)
   IF (ret=0)
    SET buf2 = ""
   ENDIF
   RETURN(buf2)
 END ;Subroutine
 SUBROUTINE (getkeystring(key_str=vc) =vc)
   DECLARE str_max_length = i4 WITH noconstant(132)
   DECLARE buf = c132 WITH noconstant(fillstring(132," "))
   DECLARE ret = i4 WITH noconstant(0)
   SET ret = uar_srvgetkeystring(0,nullterm(key_str),buf,str_max_length)
   IF (ret=0)
    SET buf = ""
   ENDIF
   RETURN(buf)
 END ;Subroutine
 SUBROUTINE (getexpandind(_reccnt=i4(value),_bindcnt=i4(value,200)) =i2)
   DECLARE nexpandval = i4 WITH private, noconstant(1)
   DECLARE ncurrentverion = i4 WITH private, constant(cnvtint(build(currev,currevminor,currevminor2))
    )
   IF (ncurrentverion >= 8102)
    SET nexpandval = 2
   ENDIF
   RETURN(evaluate(floor(((_reccnt - 1)/ _bindcnt)),0,0,nexpandval))
 END ;Subroutine
 IF (validate(execmsgrtl,999)=999)
  DECLARE execmsgrtl = i2 WITH constant(1), persist
  DECLARE emsglog_commit = i4 WITH constant(0), persist
  DECLARE emsglvl_error = i4 WITH constant(0), persist
  DECLARE emsglvl_warning = i4 WITH constant(1), persist
  DECLARE emsglvl_audit = i4 WITH constant(2), persist
  DECLARE emsglvl_info = i4 WITH constant(3), persist
  DECLARE emsglvl_debug = i4 WITH constant(4), persist
  EXECUTE msgrtl
  DECLARE msg_default = i4 WITH persist
  SET msg_default = uar_msgdefhandle()
 ENDIF
 DECLARE msgout = vc WITH noconstant("")
 DECLARE prsnl_alias_code_set = i4 WITH constant(320)
 DECLARE person_alias_code_set = i4 WITH constant(4)
 DECLARE logon_nhs = i2 WITH constant(1)
 DECLARE sensitivity_code_set = i4 WITH constant(4002394)
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
 IF ((validate(passive_check_define,- (99))=- (99)))
  DECLARE passive_check_define = i4 WITH constant(1)
  DECLARE column_exists(stable,scolumn) = i4
  SUBROUTINE column_exists(stable,scolumn)
    DECLARE ce_flag = i4
    SET ce_flag = 0
    DECLARE ce_temp = vc WITH noconstant("")
    SET stable = cnvtupper(stable)
    SET scolumn = cnvtupper(scolumn)
    IF (((currev=8
     AND currevminor=2
     AND currevminor2 >= 4) OR (((currev=8
     AND currevminor > 2) OR (currev > 8)) )) )
     SET ce_temp = build('"',stable,".",scolumn,'"')
     SET stat = checkdic(parser(ce_temp),"A",0)
     IF (stat > 0)
      SET ce_flag = 1
     ENDIF
    ELSE
     SELECT INTO "nl:"
      l.attr_name
      FROM dtableattr a,
       dtableattrl l
      WHERE a.table_name=stable
       AND l.attr_name=scolumn
       AND l.structtype="F"
       AND btest(l.stat,11)=0
      DETAIL
       ce_flag = 1
      WITH nocounter
     ;end select
    ENDIF
    RETURN(ce_flag)
  END ;Subroutine
 ENDIF
 DECLARE check_active_ind_person_cvr = i4 WITH noconstant(column_exists("PERSON_CODE_VALUE_R",
   "ACTIVE_IND"))
 DECLARE sizediff = i4 WITH noconstant(0)
 IF (validate(setsizelimits,999)=999)
  DECLARE setsizelimits = i2 WITH constant(1), persist
  DECLARE maxparticipantname = i4 WITH constant(256), persist
  DECLARE maxparticipantidtype = i4 WITH constant(64), persist
  DECLARE maxparticipantrolecd = i4 WITH constant(64), persist
  DECLARE maxparticipanttype = i4 WITH constant(64), persist
  DECLARE maxrelationcreationreason = i4 WITH constant(128), persist
  DECLARE maxrelationcreatedby = i4 WITH constant(128), persist
  DECLARE maxrelationcreationtype = i4 WITH constant(32), persist
  DECLARE maxrelationtype = i4 WITH constant(32), persist
  DECLARE maxdatalifecycle = i4 WITH constant(64), persist
  DECLARE maxexternalsource = i4 WITH constant(64), persist
  DECLARE maxeventname = i4 WITH constant(64), persist
  DECLARE maxeventtype = i4 WITH constant(64), persist
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
 RECORD scriptreply(
   1 participant[1]
     2 participant_id = f8
     2 participant_name = vc
     2 person_id = f8
     2 encntr_id = f8
     2 relationship_creation_reason = vc
     2 relationship_creation_dt_tm = dq8
     2 relationship_created_by = vc
     2 relationship_creation_type = vc
     2 relationship_type = vc
   1 status = c1
 )
 RECORD encntrlist(
   1 participant[*]
     2 person_id = f8
     2 encntr_id = f8
     2 participant_type_flag = i2
     2 event_pos = i4
     2 part_pos = i4
     2 skip_person_data = i2
 )
 RECORD personlist(
   1 participant[*]
     2 person_id = f8
     2 encntr_id = f8
     2 participant_type_flag = i2
     2 event_pos = i4
     2 part_pos = i4
     2 skip_person_data = i2
 )
 RECORD uniquelist(
   1 participant[*]
     2 encntr_id = f8
 )
 RECORD encntrorgdetails(
   1 encounters[*]
     2 encntr_id = f8
     2 cao_id = f8
     2 cao_org_name = vc
     2 cao_alias = vc
     2 cao_alias_type = vc
     2 care_provider_org_id = f8
     2 care_giver_org_name = vc
     2 care_giver_alias = vc
     2 care_giver_alias_type = vc
 )
 RECORD encntrorgdetailsrequest(
   1 orgs[*]
     2 org_id = f8
 )
 RECORD encntrorgdetailsreply(
   1 orgs[*]
     2 chart_access_org
       3 org_id = f8
       3 org_alias = vc
       3 org_alias_type = vc
       3 org_alias_type_cd = f8
       3 org_name = vc
       3 care_giver_id = f8
     2 care_giver
       3 org_id = f8
       3 org_alias = vc
       3 org_alias_type = vc
       3 org_alias_type_cd = f8
       3 org_name = vc
 )
 DECLARE etype_script = i2 WITH constant(0)
 DECLARE etype_person = i2 WITH constant(1)
 DECLARE etype_encntr = i2 WITH constant(2)
 DECLARE executeacmscript(null) = null
 DECLARE queryprsnlinfo(null) = null
 DECLARE queryprsnlalias(null) = null
 DECLARE queryprsnlaliasandinfo(null) = null
 DECLARE getpersoninformation(null) = null
 SUBROUTINE getpersoninformation(null)
   DECLARE expandidx = i4 WITH protect, noconstant(0)
   DECLARE locateidx = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE encntritr = i4 WITH noconstant(0)
   DECLARE personcnt = i4 WITH noconstant(0)
   FOR (encntritr = 1 TO encntrcnt)
     IF (validate(encntrlist->participant[encntritr].skip_person_data,0)=0)
      SET personcnt += 1
      SET stat = alterlist(personlist->participant,personcnt)
      SET personlist->participant[personcnt].person_id = encntrlist->participant[encntritr].person_id
      SET personlist->participant[personcnt].encntr_id = encntrlist->participant[encntritr].encntr_id
      SET personlist->participant[personcnt].participant_type_flag = encntrlist->participant[
      encntritr].participant_type_flag
      SET personlist->participant[personcnt].event_pos = encntrlist->participant[encntritr].event_pos
      SET personlist->participant[personcnt].part_pos = encntrlist->participant[encntritr].part_pos
      SET personlist->participant[personcnt].skip_person_data = encntrlist->participant[encntritr].
      skip_person_data
     ENDIF
   ENDFOR
   SELECT INTO "nl:"
    p.name_full_formatted
    FROM person p
    PLAN (p
     WHERE expand(expandidx,1,personcnt,p.person_id,personlist->participant[expandidx].person_id))
    DETAIL
     idx = locateval(locateidx,1,encntrcnt,p.person_id,encntrlist->participant[locateidx].person_id),
     eventidx = encntrlist->participant[idx].event_pos, partidx = encntrlist->participant[idx].
     part_pos,
     reply->event_list[eventidx].participants[partidx].person_id = p.person_id, reply->event_list[
     eventidx].participants[partidx].person_name = p.name_full_formatted
     IF ((encntrlist->participant[idx].participant_type_flag=etype_person))
      reply->event_list[eventidx].participants[partidx].vip_display = uar_get_code_display(p.vip_cd)
     ENDIF
     IF ((encntrlist->participant[idx].participant_type_flag=etype_person)
      AND size(trim(reply->event_list[eventidx].participants[partidx].participant_name)) <= 0)
      reply->event_list[eventidx].participants[partidx].participant_name = p.name_full_formatted
     ENDIF
    WITH nocounter, expand = value(getexpandind(personcnt))
   ;end select
 END ;Subroutine
 SUBROUTINE (checkforuniqueness(participant_id=f8) =i2)
   DECLARE uniqueencntr = i2 WITH protected, noconstant(1)
   DECLARE idx = i4 WITH noconstant(0), protected
   DECLARE encntr_pos = i4 WITH noconstant(0), protected
   SET encntrsize = size(uniquelist->participant,5)
   SET encntr_pos = locateval(idx,0,encntrsize,participant_id,uniquelist->participant[idx].encntr_id)
   IF (encntr_pos=0)
    SET stat = alterlist(uniquelist->participant,(encntrsize+ 1))
    SET uniquelist->participant[(encntrsize+ 1)].encntr_id = participant_id
   ELSE
    SET uniqueencntr = 0
   ENDIF
   RETURN(uniqueencntr)
 END ;Subroutine
 SUBROUTINE executeacmscript(null)
   DECLARE temp_user_id = f8 WITH protect, noconstant(reqinfo->updt_id)
   SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
   SET reqinfo->updt_id = request->prsnl_id
   EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST","acm_get_curr_logical_domain_req"),
   replace("REPLY","acm_get_curr_logical_domain_rep")
   SET reqinfo->updt_id = temp_user_id
 END ;Subroutine
 SUBROUTINE (decorateauditsource(auditsource=vc) =vc)
   DECLARE auditsourceout = vc WITH protect, noconstant(auditsource)
   DECLARE logical_domain_id = f8 WITH protect, noconstant(- (1))
   DECLARE caching_enabled = i1 WITH protect, noconstant(0)
   IF ((auditinfo->logical_domain_enabled=0))
    RETURN(auditsourceout)
   ENDIF
   IF (validate(request->logical_domain_id)=1)
    IF ((request->logical_domain_id >= 0))
     SET logical_domain_id = request->logical_domain_id
    ENDIF
   ENDIF
   IF (validate(request->caching_enabled)=1)
    SET caching_enabled = request->caching_enabled
   ENDIF
   IF (logical_domain_id < 0)
    CALL executeacmscript(null)
    IF ((acm_get_curr_logical_domain_rep->status_block.status_ind != true))
     RETURN(auditsourceout)
    ENDIF
    SET logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
    IF (caching_enabled=0)
     DECLARE logicaldomainname = vc WITH protect, noconstant("")
     SELECT INTO "nl:"
      FROM logical_domain ld
      WHERE ld.logical_domain_id=logical_domain_id
      ORDER BY ld.mnemonic
      HEAD REPORT
       logicaldomainname = ld.mnemonic
      FOOT REPORT
       col + 0
      WITH nocounter
     ;end select
     SET auditsourceout = build2(auditsource,"/",trim(logicaldomainname,3))
     RETURN(auditsourceout)
    ENDIF
   ELSEIF (logical_domain_id=0)
    SET auditsourceout = build2(auditsource,"/",trim("Default Logical Domain/id:0",3))
    RETURN(auditsourceout)
   ENDIF
   IF (validate(request->logical_domain_id)=1)
    SET auditsourceout = build2(auditsourceout,"/id:",trim(cnvtstring(logical_domain_id,20)))
   ENDIF
   RETURN(auditsourceout)
 END ;Subroutine
 SUBROUTINE queryprsnlinfo(null)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.person_id=request->prsnl_id)
    HEAD REPORT
     reply->user_name = p.username, reply->prsnl_name = p.name_full_formatted
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE queryprsnlalias(null)
   SELECT INTO "nl:"
    FROM (parser(prsnl_alias_source) pas)
    WHERE (pas.person_id=request->prsnl_id)
     AND parser(type_code_field)=prsnl_alias_cd
     AND pas.active_ind=1
     AND pas.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pas.end_effective_dt_tm >= cnvtdatetime(sysdate)
    HEAD REPORT
     reply->prsnl_alias = trim(pas.alias)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE queryprsnlaliasandinfo(null)
   SELECT INTO "nl:"
    FROM prsnl p,
     (parser(prsnl_alias_source) pas),
     dummyt d
    PLAN (p
     WHERE (p.person_id=request->prsnl_id))
     JOIN (d)
     JOIN (pas
     WHERE p.person_id=pas.person_id
      AND parser(type_code_field)=prsnl_alias_cd
      AND pas.active_ind=1
      AND pas.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND pas.end_effective_dt_tm >= cnvtdatetime(sysdate))
    HEAD REPORT
     reply->user_name = p.username, reply->prsnl_name = p.name_full_formatted, reply->prsnl_alias =
     trim(pas.alias)
    WITH outerjoin(d), nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE logtruncationmsg(fieldname,charactercnt)
  SET msgout = build("{{field::",fieldname,"}}{{characterCnt::",charactercnt,"}}{{context::",
   request->context,"}}")
  CALL uar_msgwrite(msg_default,emsglog_commit,nullterm("CPMAUDIT_Truncate"),emsglvl_audit,nullterm(
    msgout))
 END ;Subroutine
 SUBROUTINE (PUBLIC::lookuppersonnelinformation(null) =null)
   DECLARE prsnl_alias = vc WITH noconstant("")
   DECLARE prsnl_alias_key = vc WITH noconstant("")
   DECLARE prsnl_alias_source = vc WITH noconstant("")
   DECLARE prsnl_alias_cd = f8 WITH noconstant(0.0)
   DECLARE skip_prsnl_name_flag = i1 WITH noconstant(0)
   DECLARE skip_prsnl_alias_flag = i1 WITH noconstant(0)
   DECLARE type_code_field = vc WITH noconstant("")
   DECLARE curs = i4 WITH noconstant(0)
   DECLARE prsnl_alias_key_path = vc WITH constant(
    "/Config/System/Framework/Security/Auditing/Participants/User/Aliases/")
   CALL getaliasconfiguration(null)
   IF (validate(request->skip_prsnl_name)=1)
    IF ((request->skip_prsnl_name=1))
     SET skip_prsnl_name_flag = 1
    ENDIF
   ENDIF
   IF (validate(request->prsnl_alias)=1)
    IF (skip_prsnl_name_flag=1)
     SET skip_prsnl_alias_flag = 1
     SET prsnl_alias = request->prsnl_alias
     SET reply->prsnl_alias = prsnl_alias
    ENDIF
   ENDIF
   IF (skip_prsnl_name_flag=1)
    IF (prsnl_alias_key != ""
     AND skip_prsnl_alias_flag != 1
     AND (request->prsnl_id != 0))
     CALL queryprsnlalias(null)
    ENDIF
    RETURN
   ENDIF
   IF ((request->prsnl_id != 0))
    IF (prsnl_alias_key != "")
     CALL queryprsnlaliasandinfo(null)
    ELSE
     CALL queryprsnlinfo(null)
    ENDIF
   ENDIF
   IF (trim(reply->user_name) <= "")
    SET reply->user_name = request->user_name
   ENDIF
 END ;Subroutine
 SUBROUTINE (PUBLIC::getaliasconfiguration(null) =null)
   SET prsnl_alias_key = trim(querykey(prsnl_alias_key_path,curs))
   IF (prsnl_alias_key="")
    RETURN
   ENDIF
   SET prsnl_alias_source = cnvtupper(trim(getkeystring(build(prsnl_alias_key_path,prsnl_alias_key,
       "/source"))))
   SET type_code_field = build2("pas.",prsnl_alias_source,"_TYPE_CD")
   IF (prsnl_alias_source="PRSNL_ALIAS")
    SET prsnl_alias_cd = uar_get_code_by("DISPLAYKEY",prsnl_alias_code_set,nullterm(prsnl_alias_key))
   ELSEIF (prsnl_alias_source="PERSON_ALIAS")
    SET prsnl_alias_cd = uar_get_code_by("DISPLAYKEY",person_alias_code_set,nullterm(prsnl_alias_key)
     )
   ELSE
    SET prsnl_alias_cd = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE (PUBLIC::main(null) =null)
   SET reply->audit_version = request->audit_version
   SET reply->event_dt_tm = cnvtdatetimeutc(cnvtdatetimeutc(request->event_dt_tm,2),3)
   SET reply->outcome_ind = request->outcome_ind
   SET reply->prsnl_id = request->prsnl_id
   SET reply->role_cd = request->role_cd
   SET reply->role = uar_get_code_display(request->role_cd)
   SET reply->enterprise_site = request->enterprise_site
   SET reply->audit_source = decorateauditsource(request->audit_source)
   SET reply->audit_source_type = request->audit_source_type
   SET reply->network_acc_type = request->network_acc_type
   SET reply->network_acc_id = request->network_acc_id
   SET reply->context = request->context
   IF (validate(reply->role_profile_details.purpose_name)=1)
    SET reply->role_profile_details.purpose_name = uar_get_code_display(reply->role_profile_details.
     purpose_id)
   ENDIF
   CALL lookuppersonnelinformation(null)
   DECLARE logintype = i2 WITH noconstant(- (1))
   DECLARE saccurrenttrust = f8 WITH noconstant(- (1.0))
   SET logintype = uar_sacgetuserlogontype()
   IF (logintype=logon_nhs)
    SET saccurrenttrust = uar_sacgetusercurrenttrust()
    IF (saccurrenttrust > 0)
     SELECT INTO "nl:"
      FROM organization o
      WHERE o.organization_id=saccurrenttrust
      DETAIL
       reply->user_organization_name = o.org_name
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   DECLARE subeventcnt = i4 WITH noconstant(0)
   DECLARE encntrcnt = i4 WITH noconstant(0)
   DECLARE encntrcaocnt = i4 WITH noconstant(0)
   DECLARE eventcnt = i4 WITH noconstant(0)
   DECLARE partcnt = i4 WITH noconstant(0)
   DECLARE eventitr = i4 WITH noconstant(0)
   DECLARE partitr = i4 WITH noconstant(0)
   DECLARE scriptname = vc WITH noconstant("")
   DECLARE idtype = vc WITH noconstant("")
   DECLARE idtypesize = i4 WITH noconstant(0)
   DECLARE idtypeend = vc WITH noconstant("")
   DECLARE partnamesize = i4 WITH noconstant(0)
   DECLARE externalsourcesize = i4 WITH noconstant(0)
   SET eventcnt = size(request->event_list,5)
   SET stat = alterlist(reply->event_list,eventcnt)
   FOR (eventitr = 1 TO eventcnt)
     SET sizediff = (size(request->event_list[eventitr].event_name) - maxeventname)
     IF (sizediff > 0)
      CALL logtruncationmsg("event_name",sizediff)
      SET reply->event_list[eventitr].event_name = substring(1,maxeventname,request->event_list[
       eventitr].event_name)
     ELSE
      SET reply->event_list[eventitr].event_name = request->event_list[eventitr].event_name
     ENDIF
     SET sizediff = (size(request->event_list[eventitr].event_type) - maxeventtype)
     IF (sizediff > 0)
      CALL logtruncationmsg("event_type",sizediff)
      SET reply->event_list[eventitr].event_type = substring(1,maxeventtype,request->event_list[
       eventitr].event_type)
     ELSE
      SET reply->event_list[eventitr].event_type = request->event_list[eventitr].event_type
     ENDIF
     SET partcnt = size(request->event_list[eventitr].participants,5)
     SET replypartitr = 0
     SET stat = initrec(uniquelist)
     FOR (partitr = 1 TO partcnt)
       SET addtoreply = 1
       SET idtype = cnvtupper(request->event_list[eventitr].participants[partitr].participant_id_type
        )
       IF (trim(idtype,4)="ENCOUNTER")
        SET addtoreply = checkforuniqueness(request->event_list[eventitr].participants[partitr].
         participant_id)
       ENDIF
       IF (addtoreply=1)
        SET replypartitr += 1
        SET stat = alterlist(reply->event_list[eventitr].participants,replypartitr)
        SET sizediff = (size(request->event_list[eventitr].participants[partitr].participant_type) -
        maxparticipanttype)
        IF (sizediff > 0)
         CALL logtruncationmsg("participant_type",sizediff)
         SET reply->event_list[eventitr].participants[replypartitr].participant_type = substring(1,
          maxparticipanttype,request->event_list[eventitr].participants[partitr].participant_type)
        ELSE
         SET reply->event_list[eventitr].participants[replypartitr].participant_type = request->
         event_list[eventitr].participants[partitr].participant_type
        ENDIF
        SET sizediff = (size(request->event_list[eventitr].participants[partitr].participant_role_cd)
         - maxparticipantrolecd)
        IF (sizediff > 0)
         CALL logtruncationmsg("participant_role_cd",sizediff)
         SET reply->event_list[eventitr].participants[replypartitr].participant_role_cd = substring(1,
          maxparticipantrolecd,request->event_list[eventitr].participants[partitr].
          participant_role_cd)
        ELSE
         SET reply->event_list[eventitr].participants[replypartitr].participant_role_cd = request->
         event_list[eventitr].participants[partitr].participant_role_cd
        ENDIF
        SET sizediff = (size(request->event_list[eventitr].participants[partitr].participant_id_type)
         - maxparticipantidtype)
        IF (sizediff > 0)
         CALL logtruncationmsg("participant_id_type",sizediff)
         SET reply->event_list[eventitr].participants[replypartitr].participant_id_type = substring(1,
          maxparticipantidtype,request->event_list[eventitr].participants[partitr].
          participant_id_type)
        ELSE
         SET reply->event_list[eventitr].participants[replypartitr].participant_id_type = request->
         event_list[eventitr].participants[partitr].participant_id_type
        ENDIF
        SET sizediff = (size(request->event_list[eventitr].participants[partitr].data_life_cycle) -
        maxdatalifecycle)
        IF (sizediff > 0)
         CALL logtruncationmsg("data_life_cycle",sizediff)
         SET reply->event_list[eventitr].participants[replypartitr].data_life_cycle = substring(1,
          maxdatalifecycle,request->event_list[eventitr].participants[partitr].data_life_cycle)
        ELSE
         SET reply->event_list[eventitr].participants[replypartitr].data_life_cycle = request->
         event_list[eventitr].participants[partitr].data_life_cycle
        ENDIF
        SET sizediff = (size(request->event_list[eventitr].participants[partitr].external_source) -
        maxexternalsource)
        IF (sizediff > 0)
         CALL logtruncationmsg("external_source",sizediff)
         SET reply->event_list[eventitr].participants[replypartitr].external_source = trim(substring(
           1,maxexternalsource,request->event_list[eventitr].participants[partitr].external_source))
        ELSE
         SET reply->event_list[eventitr].participants[replypartitr].external_source = trim(request->
          event_list[eventitr].participants[partitr].external_source)
        ENDIF
        SET externalsourcesize = size(reply->event_list[eventitr].participants[replypartitr].
         external_source)
        SET reply->event_list[eventitr].participants[replypartitr].participant_id = request->
        event_list[eventitr].participants[partitr].participant_id
        SET sizediff = (size(request->event_list[eventitr].participants[partitr].participant_name) -
        maxparticipantname)
        IF (sizediff > 0)
         CALL logtruncationmsg("participant_name",sizediff)
         SET reply->event_list[eventitr].participants[replypartitr].participant_name = substring(1,
          maxparticipantname,request->event_list[eventitr].participants[partitr].participant_name)
        ELSE
         SET reply->event_list[eventitr].participants[replypartitr].participant_name = request->
         event_list[eventitr].participants[partitr].participant_name
        ENDIF
        IF ((reply->event_list[eventitr].participants[replypartitr].participant_id > 0)
         AND externalsourcesize <= 0)
         SET partnamesize = size(trim(reply->event_list[eventitr].participants[replypartitr].
           participant_name))
         SET idtypesize = size(reply->event_list[eventitr].participants[replypartitr].
          participant_id_type)
         SET idtype = cnvtupper(reply->event_list[eventitr].participants[replypartitr].
          participant_id_type)
         IF (idtypesize >= 5)
          SET idtypeend = substring((idtypesize - 4),5,idtype)
         ELSE
          SET idtypeend = ""
         ENDIF
         IF (idtypeend=" CODE"
          AND partnamesize <= 0)
          SET reply->event_list[eventitr].participants[replypartitr].participant_name =
          uar_get_code_display(reply->event_list[eventitr].participants[replypartitr].participant_id)
         ELSEIF (trim(idtype,4)="PATIENT")
          SET encntrcnt += 1
          SET stat = alterlist(encntrlist->participant,encntrcnt)
          SET encntrlist->participant[encntrcnt].participant_type_flag = etype_person
          SET encntrlist->participant[encntrcnt].person_id = reply->event_list[eventitr].
          participants[replypartitr].participant_id
          IF (validate(request->event_list[eventitr].participants[replypartitr].skip_person_data)=1)
           SET encntrlist->participant[encntrcnt].skip_person_data = request->event_list[eventitr].
           participants[replypartitr].skip_person_data
          ENDIF
          SET encntrlist->participant[encntrcnt].event_pos = eventitr
          SET encntrlist->participant[encntrcnt].part_pos = replypartitr
         ELSEIF (trim(idtype,4)="ENCOUNTER")
          SET encntrcnt += 1
          SET stat = alterlist(encntrlist->participant,encntrcnt)
          SET encntrlist->participant[encntrcnt].participant_type_flag = etype_encntr
          SET encntrlist->participant[encntrcnt].encntr_id = reply->event_list[eventitr].
          participants[replypartitr].participant_id
          SET encntrlist->participant[encntrcnt].event_pos = eventitr
          SET encntrlist->participant[encntrcnt].part_pos = replypartitr
         ELSE
          SET scriptname = cnvtupper(concat("ppr_aud_",trim(idtype,4)))
          IF (checkprg(scriptname) <= 0)
           SET msgout = concat("{{Execute::F}}{{Script::",scriptname,"}}{{Context::",trim(request->
             context),"}}")
           CALL uar_msgwrite(msg_default,emsglog_commit,nullterm("CPMAUDIT_Script"),emsglvl_audit,
            nullterm(msgout))
           IF (partnamesize <= 0)
            SET reply->event_list[eventitr].participants[replypartitr].participant_name =
            "No Additional Data"
           ENDIF
          ELSE
           SET scriptreply->participant[1].participant_id = request->event_list[eventitr].
           participants[partitr].participant_id
           SET scriptreply->status = "S"
           SET scriptreply->participant[1].participant_name = ""
           SET scriptreply->participant[1].person_id = 0
           SET scriptreply->participant[1].encntr_id = 0
           SET scriptreply->participant[1].relationship_creation_reason = ""
           SET scriptreply->participant[1].relationship_creation_dt_tm = 0
           SET scriptreply->participant[1].relationship_created_by = ""
           SET scriptreply->participant[1].relationship_creation_type = ""
           SET scriptreply->participant[1].relationship_type = ""
           EXECUTE value(scriptname)  WITH replace(reply,scriptreply)
           IF ((((scriptreply->participant[1].person_id > 0)) OR ((scriptreply->participant[1].
           encntr_id > 0))) )
            SET encntrcnt += 1
            SET stat = alterlist(encntrlist->participant,encntrcnt)
            SET encntrlist->participant[encntrcnt].participant_type_flag = etype_script
            SET encntrlist->participant[encntrcnt].encntr_id = scriptreply->participant[1].encntr_id
            SET encntrlist->participant[encntrcnt].person_id = scriptreply->participant[1].person_id
            SET encntrlist->participant[encntrcnt].event_pos = eventitr
            SET encntrlist->participant[encntrcnt].part_pos = replypartitr
           ENDIF
           IF (partnamesize <= 0)
            SET sizediff = (size(scriptreply->participant[1].participant_name) - maxparticipantname)
            IF (sizediff > 0)
             CALL logtruncationmsg("participant_name",sizediff)
             SET reply->event_list[eventitr].participants[replypartitr].participant_name = substring(
              1,maxparticipantname,scriptreply->participant[1].participant_name)
            ELSE
             SET reply->event_list[eventitr].participants[replypartitr].participant_name =
             scriptreply->participant[1].participant_name
            ENDIF
           ENDIF
           SET sizediff = (size(scriptreply->participant[1].relationship_creation_reason) -
           maxrelationcreationreason)
           IF (sizediff > 0)
            CALL logtruncationmsg("relationship_creation_reason",sizediff)
            SET reply->event_list[eventitr].participants[replypartitr].relationship_creation_reason
             = substring(1,maxrelationcreationreason,scriptreply->participant[1].
             relationship_creation_reason)
           ELSE
            SET reply->event_list[eventitr].participants[replypartitr].relationship_creation_reason
             = scriptreply->participant[1].relationship_creation_reason
           ENDIF
           SET reply->event_list[eventitr].participants[replypartitr].relationship_creation_dt_tm =
           cnvtdatetimeutc(cnvtdatetimeutc(scriptreply->participant[1].relationship_creation_dt_tm,2),
            3)
           SET sizediff = (size(scriptreply->participant[1].relationship_created_by) -
           maxrelationcreatedby)
           IF (sizediff > 0)
            CALL logtruncationmsg("relationship_created_by",sizediff)
            SET reply->event_list[eventitr].participants[replypartitr].relationship_created_by =
            substring(1,maxrelationcreatedby,scriptreply->participant[1].relationship_created_by)
           ELSE
            SET reply->event_list[eventitr].participants[replypartitr].relationship_created_by =
            scriptreply->participant[1].relationship_created_by
           ENDIF
           SET sizediff = (size(scriptreply->participant[1].relationship_creation_type) -
           maxrelationcreationtype)
           IF (sizediff > 0)
            CALL logtruncationmsg("relationship_creation_type",sizediff)
            SET reply->event_list[eventitr].participants[replypartitr].relationship_creation_type =
            substring(1,maxrelationcreationtype,scriptreply->participant[1].
             relationship_creation_type)
           ELSE
            SET reply->event_list[eventitr].participants[replypartitr].relationship_creation_type =
            scriptreply->participant[1].relationship_creation_type
           ENDIF
           SET sizediff = (size(scriptreply->participant[1].relationship_type) - maxrelationtype)
           IF (sizediff > 0)
            CALL logtruncationmsg("relationship_type",sizediff)
            SET reply->event_list[eventitr].participants[replypartitr].relationship_type = substring(
             1,maxrelationtype,scriptreply->participant[1].relationship_type)
           ELSE
            SET reply->event_list[eventitr].participants[replypartitr].relationship_type =
            scriptreply->participant[1].relationship_type
           ENDIF
          ENDIF
          CALL echo(build("Complete Participant Name:",reply->event_list[eventitr].participants[
            replypartitr].participant_name))
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   CALL echo(build("Encntr Cnt:",encntrcnt))
   IF (encntrcnt > 0)
    DECLARE eventidx = i4 WITH noconstant(0)
    DECLARE partidx = i4 WITH noconstant(0)
    DECLARE aliastype = vc WITH noconstant("")
    DECLARE encntrorgdetailsidx = i4 WITH noconstant(0)
    DECLARE idx = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     e.chart_access_organization_id
     FROM encounter e,
      (dummyt d  WITH seq = value(encntrcnt))
     PLAN (d
      WHERE (encntrlist->participant[d.seq].encntr_id > 0))
      JOIN (e
      WHERE (e.encntr_id=encntrlist->participant[d.seq].encntr_id)
       AND e.chart_access_organization_id > 0)
     DETAIL
      encntrcaocnt += 1, stat = alterlist(encntrorgdetails->encounters,encntrcaocnt),
      encntrorgdetails->encounters[encntrcaocnt].cao_id = e.chart_access_organization_id,
      encntrorgdetails->encounters[encntrcaocnt].encntr_id = e.encntr_id
     WITH nocounter
    ;end select
    DECLARE encntr_org_details_index = i4 WITH noconstant(0)
    DECLARE script_reply_cnt = i4 WITH noconstant(0)
    DECLARE script_reply_index = i4 WITH noconstant(0)
    DECLARE encntr_care_giver_details_cnt = i4 WITH noconstant(0)
    DECLARE idx = i4 WITH protect, noconstant(0)
    SET stat = alterlist(encntrorgdetailsrequest->orgs,encntrcaocnt)
    FOR (encntr_org_details_index = 1 TO encntrcaocnt)
      SET encntrorgdetailsrequest->orgs[encntr_org_details_index].org_id = encntrorgdetails->
      encounters[encntr_org_details_index].cao_id
    ENDFOR
    IF (checkprg("CPM_AUDIT_GET_ORG_DETAILS") > 0)
     EXECUTE cpm_audit_get_org_details  WITH replace(request,encntrorgdetailsrequest), replace(reply,
      encntrorgdetailsreply)
     SET script_reply_cnt = size(encntrorgdetailsreply->orgs,5)
     FOR (script_reply_index = 1 TO script_reply_cnt)
       SET encntrorgdetails->encounters[script_reply_index].cao_org_name = encntrorgdetailsreply->
       orgs[script_reply_index].chart_access_org.org_name
       SET encntrorgdetails->encounters[script_reply_index].cao_alias = encntrorgdetailsreply->orgs[
       script_reply_index].chart_access_org.org_alias
       SET encntrorgdetails->encounters[script_reply_index].cao_alias_type = encntrorgdetailsreply->
       orgs[script_reply_index].chart_access_org.org_alias_type
       SET encntrorgdetails->encounters[script_reply_index].care_provider_org_id =
       encntrorgdetailsreply->orgs[script_reply_index].care_giver.org_id
       SET encntrorgdetails->encounters[script_reply_index].care_giver_org_name =
       encntrorgdetailsreply->orgs[script_reply_index].care_giver.org_name
       SET encntrorgdetails->encounters[script_reply_index].care_giver_alias = encntrorgdetailsreply
       ->orgs[script_reply_index].care_giver.org_alias
       SET encntrorgdetails->encounters[script_reply_index].care_giver_alias_type =
       encntrorgdetailsreply->orgs[script_reply_index].care_giver.org_alias_type
     ENDFOR
    ENDIF
    SELECT INTO "nl:"
     o.org_name, e.person_id, ea.alias
     FROM encounter e,
      organization o,
      encntr_alias ea,
      (dummyt d  WITH seq = value(encntrcnt))
     PLAN (d
      WHERE (encntrlist->participant[d.seq].encntr_id > 0))
      JOIN (e
      WHERE (e.encntr_id=encntrlist->participant[d.seq].encntr_id))
      JOIN (o
      WHERE (o.organization_id= Outerjoin(e.organization_id)) )
      JOIN (ea
      WHERE (ea.encntr_id= Outerjoin(e.encntr_id)) )
     DETAIL
      eventidx = encntrlist->participant[d.seq].event_pos, partidx = encntrlist->participant[d.seq].
      part_pos
      IF ((encntrlist->participant[d.seq].participant_type_flag=etype_encntr)
       AND size(trim(reply->event_list[eventidx].participants[partidx].participant_name)) <= 0)
       reply->event_list[eventidx].participants[partidx].participant_name = "Encounter"
      ENDIF
      reply->event_list[eventidx].participants[partidx].vip_display = uar_get_code_display(e.vip_cd),
      reply->event_list[eventidx].participants[partidx].encounter_id = e.encntr_id, reply->
      event_list[eventidx].participants[partidx].encounter_org = o.org_name,
      reply->event_list[eventidx].participants[partidx].medical_service = uar_get_code_display(e
       .med_service_cd), reply->event_list[eventidx].participants[partidx].location =
      uar_get_code_display(e.location_cd), reply->event_list[eventidx].participants[partidx].
      encounter_confid_level = uar_get_code_display(e.confid_level_cd),
      reply->event_list[eventidx].participants[partidx].admit_dt_tm = cnvtdatetimeutc(cnvtdatetimeutc
       (e.beg_effective_dt_tm,2),3), reply->event_list[eventidx].participants[partidx].
      discharge_dt_tm = cnvtdatetimeutc(cnvtdatetimeutc(e.disch_dt_tm,2),3), reply->event_list[
      eventidx].participants[partidx].encounter_type = uar_get_code_display(e.encntr_type_cd),
      reply->event_list[eventidx].participants[partidx].encounter_status = uar_get_code_display(e
       .encntr_status_cd), reply->event_list[eventidx].participants[partidx].facility =
      uar_get_code_display(e.loc_facility_cd), reply->event_list[eventidx].participants[partidx].
      building = uar_get_code_display(e.loc_building_cd),
      reply->event_list[eventidx].participants[partidx].nurse_unit = uar_get_code_display(e
       .loc_nurse_unit_cd), reply->event_list[eventidx].participants[partidx].room =
      uar_get_code_display(e.loc_room_cd), reply->event_list[eventidx].participants[partidx].bed =
      uar_get_code_display(e.loc_bed_cd)
      IF ((encntrlist->participant[d.seq].person_id <= 0))
       encntrlist->participant[d.seq].person_id = e.person_id
      ENDIF
      aliastype = uar_get_code_meaning(ea.encntr_alias_type_cd)
      IF (aliastype="MRN")
       reply->event_list[eventidx].participants[partidx].encounter_mrn = ea.alias
      ELSEIF (aliastype="FIN NBR")
       reply->event_list[eventidx].participants[partidx].encounter_fin = ea.alias
      ENDIF
      IF (validate(reply->event_list[eventidx].participants[partidx].participant_care_giver.org_id)=1
      )
       encntrorgdetailsidx = locateval(idx,1,encntrcnt,e.encntr_id,encntrorgdetails->encounters[idx].
        encntr_id), reply->event_list[eventidx].participants[partidx].participant_care_giver.org_id
        = encntrorgdetails->encounters[encntrorgdetailsidx].care_provider_org_id, reply->event_list[
       eventidx].participants[partidx].participant_care_giver.org_alias = encntrorgdetails->
       encounters[encntrorgdetailsidx].care_giver_alias,
       reply->event_list[eventidx].participants[partidx].participant_care_giver.org_alias_type =
       encntrorgdetails->encounters[encntrorgdetailsidx].care_giver_alias_type, reply->event_list[
       eventidx].participants[partidx].participant_care_giver.org_name = encntrorgdetails->
       encounters[encntrorgdetailsidx].care_giver_org_name, reply->event_list[eventidx].participants[
       partidx].participant_chart_access_org.org_id = encntrorgdetails->encounters[
       encntrorgdetailsidx].cao_id,
       reply->event_list[eventidx].participants[partidx].participant_chart_access_org.org_alias =
       encntrorgdetails->encounters[encntrorgdetailsidx].cao_alias, reply->event_list[eventidx].
       participants[partidx].participant_chart_access_org.org_alias_type = encntrorgdetails->
       encounters[encntrorgdetailsidx].cao_alias_type, reply->event_list[eventidx].participants[
       partidx].participant_chart_access_org.org_name = encntrorgdetails->encounters[
       encntrorgdetailsidx].cao_org_name
      ENDIF
     WITH nocounter
    ;end select
    CALL getpersoninformation(null)
   ENDIF
   DECLARE person_alias_key = vc WITH noconstant("")
   DECLARE person_alias_source = vc WITH noconstant("")
   DECLARE person_alias_cd = f8 WITH noconstant(0.0)
   SET curs = 0
   DECLARE person_alias_key_path = vc WITH constant(
    "/Config/System/Framework/Security/Auditing/Participants/Person/Aliases/")
   SET person_alias_key = trim(querykey(person_alias_key_path,curs))
   IF (person_alias_key != "")
    SET person_alias_source = cnvtupper(trim(getkeystring(build(person_alias_key_path,
        person_alias_key,"/source"))))
    IF (person_alias_source="PERSON_ALIAS")
     SET person_alias_cd = uar_get_code_by("DISPLAYKEY",person_alias_code_set,nullterm(
       person_alias_key))
     SELECT INTO "nl:"
      FROM person_alias pa,
       (dummyt d1  WITH seq = eventcnt),
       (dummyt d2  WITH seq = 1)
      PLAN (d1
       WHERE maxrec(d2,size(reply->event_list[d1.seq].participants,5)))
       JOIN (d2)
       JOIN (pa
       WHERE (pa.person_id=reply->event_list[d1.seq].participants[d2.seq].person_id)
        AND pa.person_alias_type_cd=person_alias_cd
        AND pa.person_id != 0
        AND pa.active_ind=1
        AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
      DETAIL
       reply->event_list[d1.seq].participants[d2.seq].person_alias = pa.alias
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RECORD personid_nonzero(
     1 list[*]
       2 pid = f8
       2 code_display = vc
   )
   DECLARE idx = i4 WITH noconstant(0), protected
   DECLARE idx1 = i4 WITH noconstant(0), protected
   DECLARE idx2 = i4 WITH noconstant(0), protected
   DECLARE k = i4 WITH noconstant(0), protected
   DECLARE sensitivity_pos = i4 WITH noconstant(- (1)), protected
   FOR (idx = 1 TO eventcnt)
     FOR (idx1 = 1 TO size(reply->event_list[idx].participants,5))
       IF ((reply->event_list[idx].participants[idx1].person_id != 0))
        SET k += 1
        SET stat = alterlist(personid_nonzero->list,k)
        SET personid_nonzero->list[k].pid = reply->event_list[idx].participants[idx1].person_id
       ENDIF
     ENDFOR
   ENDFOR
   SET k = 0
   SELECT
    IF (check_active_ind_person_cvr)
     PLAN (pr
      WHERE expand(idx1,1,size(personid_nonzero->list,5),pr.person_id,personid_nonzero->list[idx1].
       pid)
       AND pr.code_set=sensitivity_code_set
       AND pr.active_ind=1
       AND pr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
      JOIN (cv
      WHERE cv.code_value=pr.code_value
       AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv.active_ind=1)
    ELSE
     PLAN (pr
      WHERE expand(idx1,1,size(personid_nonzero->list,5),pr.person_id,personid_nonzero->list[idx1].
       pid)
       AND pr.code_set=sensitivity_code_set)
      JOIN (cv
      WHERE cv.code_value=pr.code_value
       AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
       AND cv.active_ind=1)
    ENDIF
    INTO "nl:"
    FROM person_code_value_r pr,
     code_value cv
    DETAIL
     k += 1, personid_nonzero->list[k].code_display = uar_get_code_display(pr.code_value)
    WITH nocounter
   ;end select
   FOR (idx = 1 TO eventcnt)
     FOR (idx1 = 1 TO size(reply->event_list[idx].participants,5))
       IF ((reply->event_list[idx].participants[idx1].person_id != 0))
        SET sensitivity_pos = locateval(idx2,1,size(personid_nonzero->list,5),reply->event_list[idx].
         participants[idx1].person_id,personid_nonzero->list[idx2].pid)
        IF (sensitivity_pos != 0)
         SET reply->event_list[idx].participants[idx1].sensitivity_codes = build(reply->event_list[
          idx].participants[idx1].sensitivity_codes,";",personid_nonzero->list[sensitivity_pos].
          code_display)
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   FREE RECORD personid_nonzero
   FREE RECORD uniquelist
 END ;Subroutine
 CALL main(null)
END GO
