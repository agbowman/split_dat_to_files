CREATE PROGRAM cps_get_scd_note_list:dba
 IF (validate(reply,"0")="0")
  FREE RECORD reply
  RECORD reply(
    1 notes[*]
      2 scd_story_id = f8
      2 encounter_id = f8
      2 person_id = f8
      2 person_name = vc
      2 story_type_cd = f8
      2 story_type_mean = vc
      2 title = vc
      2 story_completion_status_cd = f8
      2 story_completion_status_mean = vc
      2 story_completion_status_disp = vc
      2 author_id = f8
      2 author_name = vc
      2 event_id = f8
      2 event_cd = f8
      2 active_ind = i2
      2 result_status_cd = f8
      2 result_status_mean = vc
      2 result_status_disp = vc
      2 update_lock_user_id = f8
      2 update_lock_user_name = vc
      2 update_lock_dt_tm = dq8
      2 updt_id = f8
      2 updt_name = vc
      2 updt_dt_tm = dq8
      2 entry_mode_cd = f8
      2 entry_mode_mean = vc
      2 concepts[*]
        3 concept_cki = vc
        3 concept_display = vc
        3 concept_type_flag = i2
        3 diagnosis_group_id = f8
      2 patterns[*]
        3 scr_pattern_id = f8
        3 scr_paragraph_type_id = f8
        3 pattern_type_cd = f8
        3 pattern_type_mean = vc
        3 display = vc
        3 definition = vc
      2 paragraphs[*]
        3 scr_paragraph_type_id = f8
        3 sentences[*]
          4 scd_sentence_id = f8
          4 canonical_sentence_pattern_id = f8
          4 scr_term_hier_id = f8
      2 event_end_dt_tm = dq8
      2 event_end_tz = i4
    1 patterns[*]
      2 scr_pattern_id = f8
      2 cki_source = vc
      2 cki_identifier = vc
      2 pattern_type_cd = f8
      2 pattern_type_mean = vc
      2 display = vc
      2 definition = vc
      2 updt_cnt = i4
      2 active_status_cd = f8
      2 active_status_mean = vc
      2 active_ind = i2
      2 updt_dt_tm = dq8
      2 updt_name = vc
      2 entry_mode_cd = f8
      2 entry_mode_mean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 cps_error
      2 cnt = i4
      2 data[*]
        3 code = i4
        3 severity_level = i4
        3 supp_err_txt = c32
        3 def_msg = vc
        3 row_data
          4 lvl_1_idx = i4
          4 lvl_2_idx = i4
          4 lvl_3_idx = i4
  )
 ENDIF
 DECLARE cps_lock = i4 WITH public, constant(100)
 DECLARE cps_no_seq = i4 WITH public, constant(101)
 DECLARE cps_updt_cnt = i4 WITH public, constant(102)
 DECLARE cps_insuf_data = i4 WITH public, constant(103)
 DECLARE cps_update = i4 WITH public, constant(104)
 DECLARE cps_insert = i4 WITH public, constant(105)
 DECLARE cps_delete = i4 WITH public, constant(106)
 DECLARE cps_select = i4 WITH public, constant(107)
 DECLARE cps_auth = i4 WITH public, constant(108)
 DECLARE cps_inval_data = i4 WITH public, constant(109)
 DECLARE cps_ens_note_story_not_locked = i4 WITH public, constant(110)
 DECLARE cps_lock_msg = c33 WITH public, constant("Failed to lock all requested rows")
 DECLARE cps_no_seq_msg = c34 WITH public, constant("Failed to get next sequence number")
 DECLARE cps_updt_cnt_msg = c28 WITH public, constant("Failed to match update count")
 DECLARE cps_insuf_data_msg = c38 WITH public, constant("Request did not supply sufficient data")
 DECLARE cps_update_msg = c24 WITH public, constant("Failed on update request")
 DECLARE cps_insert_msg = c24 WITH public, constant("Failed on insert request")
 DECLARE cps_delete_msg = c24 WITH public, constant("Failed on delete request")
 DECLARE cps_select_msg = c24 WITH public, constant("Failed on select request")
 DECLARE cps_auth_msg = c34 WITH public, constant("Failed on authorization of request")
 DECLARE cps_inval_data_msg = c35 WITH public, constant("Request contained some invalid data")
 DECLARE cps_success = i4 WITH public, constant(0)
 DECLARE cps_success_info = i4 WITH public, constant(1)
 DECLARE cps_success_warn = i4 WITH public, constant(2)
 DECLARE cps_deadlock = i4 WITH public, constant(3)
 DECLARE cps_script_fail = i4 WITH public, constant(4)
 DECLARE cps_sys_fail = i4 WITH public, constant(5)
 SUBROUTINE cps_add_error(cps_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
   SET reply->cps_error.cnt += 1
   SET errcnt = reply->cps_error.cnt
   SET stat = alterlist(reply->cps_error.data,errcnt)
   SET reply->cps_error.data[errcnt].code = cps_errcode
   SET reply->cps_error.data[errcnt].severity_level = severity_level
   SET reply->cps_error.data[errcnt].supp_err_txt = supp_err_txt
   SET reply->cps_error.data[errcnt].def_msg = def_msg
   SET reply->cps_error.data[errcnt].row_data.lvl_1_idx = idx1
   SET reply->cps_error.data[errcnt].row_data.lvl_2_idx = idx2
   SET reply->cps_error.data[errcnt].row_data.lvl_3_idx = idx3
 END ;Subroutine
 DECLARE story_count = i4 WITH public, constant(size(request->story_ids,5))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE status = i4 WITH public, noconstant(0)
 DECLARE serrmsg = vc WITH public, noconstant(fillstring(150," "))
 DECLARE table_name = vc WITH public, noconstant(fillstring(50," "))
 DECLARE errcnt = i4 WITH public, noconstant(0)
 DECLARE retrievenotelist(null) = null
 DECLARE retrievemacrolist(null) = null
 DECLARE retrievepatterns(null) = null
 DECLARE retrievepatternsnotetype(null) = null
 DECLARE retrievepcnotelist(null) = null
 SET reply->status_data.status = "F"
 CALL retrievepatterns(null)
 IF (status != 0)
  GO TO exit_script
 ENDIF
 IF ((request->encounter_id=0)
  AND (request->user_id=0)
  AND (request->person_id=0)
  AND (request->type_mean != "PRE"))
  CALL cps_add_error(cps_inval_data,cps_script_fail,"No encounter/user/person given",
   cps_inval_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 IF ((((request->type_mean="PREPARA")) OR ((((request->type_mean="PRESENT")) OR ((request->type_mean=
 "PRETERM"))) )) )
  CALL retrievemacrolist(null)
 ELSEIF ((request->type_mean="PRE"))
  CALL retrievepcnotelist(null)
 ELSE
  CALL retrievenotelist(null)
 ENDIF
#exit_script
 IF (status != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
 ENDIF
 SUBROUTINE (buildstorywhere(bpcn=i2) =null)
   IF ((request->encounter_id != 0))
    CALL buildwhereclause(" ss.encounter_id = request->encounter_id ")
   ENDIF
   IF ((request->person_id != 0))
    IF ((request->encounter_id != 0))
     CALL buildwhereclause(" ss.person_id + 0 = request->person_id ")
    ELSE
     CALL buildwhereclause(" ss.person_id = request->person_id ")
    ENDIF
   ENDIF
   IF ((request->completion_status_cd != 0))
    CALL buildwhereclause(" ss.story_completion_status_cd = request->completion_status_cd ")
   ENDIF
   IF ((request->status_flag=0))
    CALL buildwhereclause(" ss.active_ind = 1 ")
   ELSEIF ((request->status_flag=2))
    CALL buildwhereclause(" ss.active_ind = 0 ")
   ENDIF
   IF ((request->type_cd != 0))
    CALL buildwhereclause(" ss.story_type_cd = request->type_cd ")
   ENDIF
   IF ((request->entry_mode_filter_ind=1))
    CALL buildwhereclause(" ss.entry_mode_cd = request->entry_mode_cd ")
   ELSEIF ((request->entry_mode_filter_ind=2))
    CALL buildwhereclause(" (ss.entry_mode_cd = request->entry_mode_cd or ss.entry_mode_cd = 0) ")
   ENDIF
 END ;Subroutine
 SUBROUTINE (buildwhereclause(new_where_clause=vc) =null WITH protect)
   IF (textlen(trim(story_where_clause))=0)
    SET story_where_clause = new_where_clause
   ELSE
    SET story_where_clause = concat(story_where_clause," and ",new_where_clause)
   ENDIF
 END ;Subroutine
 SUBROUTINE retrievenotelist(null)
   IF (story_count != 0)
    SET serrmsg = "Selective note retrieval unimplemented"
    SET status = 1
    RETURN
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE story_where_clause = vc WITH protect
   DECLARE datestring = vc WITH constant("31-DEC-2100 00:00:00")
   CALL buildstorywhere(0)
   CALL echo(build("story_where -> ",story_where_clause))
   SELECT
    IF ((request->pattern_id != 0))
     FROM scd_story ss,
      scd_story_pattern ssp,
      scr_pattern pat,
      clinical_event ce,
      scd_story_pattern ssp2
     PLAN (ss
      WHERE parser(story_where_clause))
      JOIN (ssp2
      WHERE (ssp2.scr_pattern_id=request->pattern_id)
       AND ss.scd_story_id=ssp2.scd_story_id)
      JOIN (ssp
      WHERE ssp.scd_story_id=ss.scd_story_id)
      JOIN (pat
      WHERE (pat.scr_pattern_id= Outerjoin(ssp.scr_pattern_id)) )
      JOIN (ce
      WHERE ce.event_id=ss.event_id
       AND ((((ce.clinsig_updt_dt_tm+ 0)=null)) OR (((ce.clinsig_updt_dt_tm+ 0) <= ce.updt_dt_tm)))
       AND ((ce.event_id=0) OR (ce.valid_until_dt_tm=cnvtdatetime(datestring))) )
    ELSE
    ENDIF
    INTO "nl:"
    FROM scd_story ss,
     scd_story_pattern ssp,
     scr_pattern pat,
     clinical_event ce
    PLAN (ss
     WHERE parser(story_where_clause))
     JOIN (ssp
     WHERE ssp.scd_story_id=ss.scd_story_id)
     JOIN (pat
     WHERE (pat.scr_pattern_id= Outerjoin(ssp.scr_pattern_id)) )
     JOIN (ce
     WHERE ce.event_id=ss.event_id
      AND ((((ce.clinsig_updt_dt_tm+ 0)=null)) OR (((ce.clinsig_updt_dt_tm+ 0) <= ce.updt_dt_tm)))
      AND ((ce.event_id=0) OR (ce.valid_until_dt_tm=cnvtdatetime(datestring))) )
    ORDER BY ss.scd_story_id, pat.scr_pattern_id, ce.clinical_event_id DESC,
     ce.event_id
    HEAD ss.scd_story_id
     idx += 1
     IF (mod(idx,10)=1)
      stat = alterlist(reply->notes,(idx+ 9))
     ENDIF
     pat_idx = 0, reply->notes[idx].scd_story_id = ss.scd_story_id, reply->notes[idx].story_type_cd
      = ss.story_type_cd,
     reply->notes[idx].title = ss.title, reply->notes[idx].story_completion_status_cd = ss
     .story_completion_status_cd, reply->notes[idx].author_id = ss.author_id,
     reply->notes[idx].person_id = ss.person_id, reply->notes[idx].event_id = ss.event_id, reply->
     notes[idx].event_cd = ce.event_cd,
     reply->notes[idx].encounter_id = ss.encounter_id, reply->notes[idx].active_ind = ss.active_ind,
     reply->notes[idx].update_lock_user_id = ss.update_lock_user_id,
     reply->notes[idx].update_lock_dt_tm = ss.update_lock_dt_tm, reply->notes[idx].updt_dt_tm = ss
     .updt_dt_tm, reply->notes[idx].updt_id = ss.updt_id,
     reply->notes[idx].entry_mode_cd = ss.entry_mode_cd
    HEAD ce.event_id
     IF (ss.event_id != 0)
      reply->notes[idx].result_status_cd = ce.result_status_cd, reply->notes[idx].updt_dt_tm = ce
      .clinsig_updt_dt_tm, reply->notes[idx].updt_id = ce.updt_id,
      reply->notes[idx].event_end_dt_tm = ce.event_end_dt_tm, reply->notes[idx].event_end_tz = ce
      .event_end_tz, reply->notes[idx].entry_mode_cd = ce.entry_mode_cd
     ENDIF
    HEAD ce.clinical_event_id
     IF (ce.event_id != 0.0
      AND ce.clinsig_updt_dt_tm=ce.updt_dt_tm)
      reply->notes[idx].updt_id = ce.updt_id
     ENDIF
    DETAIL
     pat_idx += 1
     IF (mod(pat_idx,10)=1)
      stat = alterlist(reply->notes[idx].patterns,(pat_idx+ 9))
     ENDIF
     reply->notes[idx].patterns[pat_idx].scr_pattern_id = pat.scr_pattern_id, reply->notes[idx].
     patterns[pat_idx].pattern_type_cd = pat.pattern_type_cd, reply->notes[idx].patterns[pat_idx].
     scr_paragraph_type_id = ssp.scr_paragraph_type_id,
     reply->notes[idx].patterns[pat_idx].display = pat.display, reply->notes[idx].patterns[pat_idx].
     definition = pat.definition
    FOOT  ss.scd_story_id
     stat = alterlist(reply->notes[idx].patterns,pat_idx)
    FOOT REPORT
     stat = alterlist(reply->notes,idx)
    WITH nocounter
   ;end select
   CALL populateconcept(idx)
 END ;Subroutine
 SUBROUTINE retrievepcnotelist(null)
   IF (story_count != 0
    AND (request->pattern_id != 0.0))
    SET serrmsg = "Selective PCN retrieval by pattern id is unimplemented"
    SET status = 1
    GO TO exit_script
   ENDIF
   DECLARE cur_size = i4 WITH protect, constant(size(reply->patterns,5))
   DECLARE concepts = i4 WITH protect, constant(size(request->concept_qual,5))
   IF (story_count != 0
    AND cur_size != 0)
    SET serrmsg = "Selective PCN retrieval unimplemented with concepts"
    SET status = 1
    GO TO exit_script
   ENDIF
   IF (cur_size=0
    AND ((concepts != 0) OR ((((request->note_type_id != 0.0)) OR ((request->event_cd != 0.0))) )) )
    SET reply->status_data.status = "Z"
    RETURN
   ENDIF
   DECLARE filter_by_org_ind = i2 WITH protect, noconstant(0)
   IF ((request->filter_by_user_org_ind=1)
    AND validate(ccldminfo->mode,0)
    AND (ccldminfo->sec_org_reltn=1))
    SET filter_by_org_ind = 1
    FREE RECORD sac_org
    IF (validate(_sacrtl_org_inc_,99999)=99999)
     DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
     RECORD sac_org(
       1 organizations[*]
         2 organization_id = f8
         2 confid_cd = f8
         2 confid_level = i4
     )
     EXECUTE secrtl
     EXECUTE sacrtl
     DECLARE orgcnt = i4 WITH protected, noconstant(0)
     DECLARE secstat = i2
     DECLARE logontype = i4 WITH protect, noconstant(- (1))
     DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
     DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
     DECLARE dynorg_enabled = i4 WITH constant(1)
     DECLARE dynorg_disabled = i4 WITH constant(0)
     DECLARE logontype_nhs = i4 WITH constant(1)
     DECLARE logontype_legacy = i4 WITH constant(0)
     DECLARE confid_cnt = i4 WITH protected, noconstant(0)
     RECORD confid_codes(
       1 list[*]
         2 code_value = f8
         2 coll_seq = f8
     )
     CALL uar_secgetclientlogontype(logontype)
     CALL echo(build("logontype:",logontype))
     IF (logontype != logontype_nhs)
      SET dynamic_org_ind = dynorg_disabled
     ENDIF
     IF (logontype=logontype_nhs)
      SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
        DECLARE scur_trust = vc
        DECLARE pref_val = vc
        DECLARE is_enabled = i4 WITH constant(1)
        DECLARE is_disabled = i4 WITH constant(0)
        SET scur_trust = cnvtstring(dtrustid)
        SET scur_trust = concat(scur_trust,".00")
        IF ( NOT (validate(pref_req,0)))
         RECORD pref_req(
           1 write_ind = i2
           1 delete_ind = i2
           1 pref[*]
             2 contexts[*]
               3 context = vc
               3 context_id = vc
             2 section = vc
             2 section_id = vc
             2 subgroup = vc
             2 entries[*]
               3 entry = vc
               3 values[*]
                 4 value = vc
         )
        ENDIF
        IF ( NOT (validate(pref_rep,0)))
         RECORD pref_rep(
           1 pref[*]
             2 section = vc
             2 section_id = vc
             2 subgroup = vc
             2 entries[*]
               3 pref_exists_ind = i2
               3 entry = vc
               3 values[*]
                 4 value = vc
           1 status_data
             2 status = c1
             2 subeventstatus[1]
               3 operationname = c25
               3 operationstatus = c1
               3 targetobjectname = c25
               3 targetobjectvalue = vc
         )
        ENDIF
        SET stat = alterlist(pref_req->pref,1)
        SET stat = alterlist(pref_req->pref[1].contexts,2)
        SET stat = alterlist(pref_req->pref[1].entries,1)
        SET pref_req->pref[1].contexts[1].context = "organization"
        SET pref_req->pref[1].contexts[1].context_id = scur_trust
        SET pref_req->pref[1].contexts[2].context = "default"
        SET pref_req->pref[1].contexts[2].context_id = "system"
        SET pref_req->pref[1].section = "workflow"
        SET pref_req->pref[1].section_id = "UK Trust Security"
        SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
        EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
        IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
         RETURN(is_enabled)
        ELSE
         RETURN(is_disabled)
        ENDIF
      END ;Subroutine
      DECLARE hprop = i4 WITH protect, noconstant(0)
      DECLARE tmpstat = i2
      DECLARE spropname = vc
      DECLARE sroleprofile = vc
      SET hprop = uar_srvcreateproperty()
      SET tmpstat = uar_secgetclientattributesext(5,hprop)
      SET spropname = uar_srvfirstproperty(hprop)
      SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
      SELECT INTO "nl:"
       FROM prsnl_org_reltn_type prt,
        prsnl_org_reltn por
       PLAN (prt
        WHERE prt.role_profile=sroleprofile
         AND prt.active_ind=1
         AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
        JOIN (por
        WHERE (por.organization_id= Outerjoin(prt.organization_id))
         AND (por.person_id= Outerjoin(prt.prsnl_id))
         AND (por.active_ind= Outerjoin(1))
         AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
         AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
       ORDER BY por.prsnl_org_reltn_id
       DETAIL
        orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
        sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
        confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
        sac_org->organizations[1].confid_level =
        IF (confid_cd > 0) confid_cd
        ELSE 0
        ENDIF
       WITH maxrec = 1
      ;end select
      SET dcur_trustid = sac_org->organizations[1].organization_id
      SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
      CALL uar_srvdestroyhandle(hprop)
     ENDIF
     IF (dynamic_org_ind=dynorg_disabled)
      SET confid_cnt = 0
      SELECT INTO "NL:"
       c.code_value, c.collation_seq
       FROM code_value c
       WHERE c.code_set=87
       DETAIL
        confid_cnt += 1
        IF (mod(confid_cnt,10)=1)
         secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
        ENDIF
        confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
        coll_seq = c.collation_seq
       WITH nocounter
      ;end select
      SET secstat = alterlist(confid_codes->list,confid_cnt)
      SELECT DISTINCT INTO "nl:"
       FROM prsnl_org_reltn por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.active_ind=1
        AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
       HEAD REPORT
        IF (orgcnt > 0)
         secstat = alterlist(sac_org->organizations,100)
        ENDIF
       DETAIL
        orgcnt += 1
        IF (mod(orgcnt,100)=1)
         secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
        ENDIF
        sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
        orgcnt].confid_cd = por.confid_level_cd
       FOOT REPORT
        secstat = alterlist(sac_org->organizations,orgcnt)
       WITH nocounter
      ;end select
      SELECT INTO "NL:"
       FROM (dummyt d1  WITH seq = value(orgcnt)),
        (dummyt d2  WITH seq = value(confid_cnt))
       PLAN (d1)
        JOIN (d2
        WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
       DETAIL
        sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
       WITH nocounter
      ;end select
     ELSEIF (dynamic_org_ind=dynorg_enabled)
      DECLARE nhstrustchild_org_org_reltn_cd = f8
      SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
      SELECT INTO "nl:"
       FROM org_org_reltn oor
       PLAN (oor
        WHERE oor.organization_id=dcur_trustid
         AND oor.active_ind=1
         AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
         AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
         AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
       HEAD REPORT
        IF (orgcnt > 0)
         secstat = alterlist(sac_org->organizations,10)
        ENDIF
       DETAIL
        IF (oor.related_org_id > 0)
         orgcnt += 1
         IF (mod(orgcnt,10)=1)
          secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
         ENDIF
         sac_org->organizations[orgcnt].organization_id = oor.related_org_id
        ENDIF
       FOOT REPORT
        secstat = alterlist(sac_org->organizations,orgcnt)
       WITH nocounter
      ;end select
     ELSE
      CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
     ENDIF
    ENDIF
    IF (size(sac_org->organizations,5)=0)
     SET stat = alterlist(sac_org->organizations,1)
     SET sac_org->organizations[1].organization_id = 0.0
    ENDIF
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE expand_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_idx_story = i4 WITH protect, noconstant(0)
   DECLARE expand_idx_patt = i4 WITH protect, noconstant(0)
   DECLARE expand_sac_orgs_idx = i4 WITH protect, noconstant(0)
   DECLARE story_where_clause = vc WITH protect
   CALL buildstorywhere(1)
   CALL echo(build("story_where -> ",story_where_clause))
   DECLARE author_clause = vc WITH protect, noconstant(" 0 = 0 ")
   IF ((request->shared_note_ind=1))
    IF ((((request->encounter_id != 0)) OR ((request->person_id != 0))) )
     SET author_clause = " (ss.author_id + 0 = 0) "
    ELSE
     SET author_clause = " (ss.author_id = 0) "
    ENDIF
    CALL echo(build("author -> ",author_clause))
   ENDIF
   DECLARE full_story_clause = vc WITH protect, noconstant("")
   SET full_story_clause = concat(story_where_clause," and ",author_clause)
   IF (filter_by_org_ind=1
    AND (request->shared_note_ind=1))
    DECLARE total_orgs = i4 WITH protect, constant(size(sac_org->organizations,5))
    IF ((((request->pattern_id != 0)) OR (cur_size != 0)) )
     INSERT  FROM shared_value_gttd sv
      (sv.source_entity_value, sv.source_entity_name)(SELECT DISTINCT
       sso.scd_story_id, "PC_SCD_STORY_ID"
       FROM scd_story_org_reltn sso,
        scd_story_pattern ssp
       WHERE expand(expand_sac_orgs_idx,1,total_orgs,sso.organization_id,sac_org->organizations[
        expand_sac_orgs_idx].organization_id)
        AND ssp.scd_story_id=sso.scd_story_id
        AND (((ssp.scr_pattern_id=request->pattern_id)) OR (expand(expand_idx,1,cur_size,ssp
        .scr_pattern_id,reply->patterns[expand_idx].scr_pattern_id)))
       WITH nocounter, expand = 1)
     ;end insert
    ELSEIF (story_count=0)
     INSERT  FROM shared_value_gttd sv
      (sv.source_entity_value, sv.source_entity_name)(SELECT DISTINCT
       sso.scd_story_id, "PC_SCD_STORY_ID"
       FROM scd_story_org_reltn sso
       WHERE expand(expand_sac_orgs_idx,1,total_orgs,sso.organization_id,sac_org->organizations[
        expand_sac_orgs_idx].organization_id)
       WITH nocounter, expand = 1)
     ;end insert
    ELSE
     INSERT  FROM shared_value_gttd sv
      (sv.source_entity_value, sv.source_entity_name)(SELECT DISTINCT
       sso.scd_story_id, "PC_SCD_STORY_ID"
       FROM scd_story_org_reltn sso
       WHERE expand(expand_sac_orgs_idx,1,total_orgs,sso.organization_id,sac_org->organizations[
        expand_sac_orgs_idx].organization_id)
        AND expand(expand_idx_story,1,story_count,sso.scd_story_id,request->story_ids[
        expand_idx_story].story_id)
       WITH nocounter, expand = 1)
     ;end insert
    ENDIF
    SET idx = 0
    SELECT INTO "nl:"
     FROM shared_value_gttd sv,
      scd_story ss
     PLAN (sv
      WHERE sv.source_entity_name="PC_SCD_STORY_ID")
      JOIN (ss
      WHERE parser(full_story_clause)
       AND ss.scd_story_id=sv.source_entity_value)
     ORDER BY ss.scd_story_id
     HEAD ss.scd_story_id
      idx += 1
      IF (mod(idx,100)=1)
       stat = alterlist(reply->notes,(idx+ 99))
      ENDIF
      reply->notes[idx].scd_story_id = ss.scd_story_id, reply->notes[idx].story_type_cd = ss
      .story_type_cd, reply->notes[idx].title = ss.title,
      reply->notes[idx].story_completion_status_cd = ss.story_completion_status_cd, reply->notes[idx]
      .author_id = ss.author_id, reply->notes[idx].person_id = 0.0,
      reply->notes[idx].event_id = 0.0, reply->notes[idx].event_cd = 0.0, reply->notes[idx].
      encounter_id = 0.0,
      reply->notes[idx].active_ind = ss.active_ind, reply->notes[idx].update_lock_user_id = ss
      .update_lock_user_id, reply->notes[idx].update_lock_dt_tm = ss.update_lock_dt_tm,
      reply->notes[idx].updt_dt_tm = ss.updt_dt_tm, reply->notes[idx].updt_id = ss.updt_id, reply->
      notes[idx].entry_mode_cd = ss.entry_mode_cd
     WITH nocounter
    ;end select
   ELSEIF ((request->shared_note_ind=1))
    SELECT
     IF ((((request->pattern_id != 0)) OR (cur_size != 0)) )
      FROM scd_story ss,
       scd_story_pattern ssp
      PLAN (ss
       WHERE parser(full_story_clause))
       JOIN (ssp
       WHERE ssp.scd_story_id=ss.scd_story_id
        AND (((ssp.scr_pattern_id=request->pattern_id)) OR (expand(expand_idx_patt,1,cur_size,ssp
        .scr_pattern_id,reply->patterns[expand_idx_patt].scr_pattern_id))) )
     ELSEIF (story_count=0)
      FROM scd_story ss
      PLAN (ss
       WHERE parser(full_story_clause))
     ELSE
      FROM scd_story ss
      PLAN (ss
       WHERE parser(full_story_clause)
        AND expand(expand_idx_story,1,story_count,ss.scd_story_id,request->story_ids[expand_idx_story
        ].story_id))
     ENDIF
     INTO "nl:"
     ORDER BY ss.scd_story_id
     HEAD ss.scd_story_id
      idx += 1
      IF (mod(idx,100)=1)
       stat = alterlist(reply->notes,(idx+ 99))
      ENDIF
      reply->notes[idx].scd_story_id = ss.scd_story_id, reply->notes[idx].story_type_cd = ss
      .story_type_cd, reply->notes[idx].title = ss.title,
      reply->notes[idx].story_completion_status_cd = ss.story_completion_status_cd, reply->notes[idx]
      .author_id = ss.author_id, reply->notes[idx].person_id = 0.0,
      reply->notes[idx].event_id = 0.0, reply->notes[idx].event_cd = 0.0, reply->notes[idx].
      encounter_id = 0.0,
      reply->notes[idx].active_ind = ss.active_ind, reply->notes[idx].update_lock_user_id = ss
      .update_lock_user_id, reply->notes[idx].update_lock_dt_tm = ss.update_lock_dt_tm,
      reply->notes[idx].updt_dt_tm = ss.updt_dt_tm, reply->notes[idx].updt_id = ss.updt_id, reply->
      notes[idx].entry_mode_cd = ss.entry_mode_cd
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->user_id != 0))
    IF ((((request->encounter_id != 0)) OR ((request->person_id != 0))) )
     SET author_clause = " ss.author_id + 0= request->user_id "
    ELSE
     SET author_clause = " ss.author_id = request->user_id "
    ENDIF
    CALL echo(build("author -> ",author_clause))
   ELSE
    SET author_clause = " 0 = 0 "
   ENDIF
   SET full_story_clause = concat(story_where_clause," and ",author_clause)
   SET expand_idx_story = 0
   SET expand_idx_patt = 0
   SELECT
    IF ((((request->pattern_id != 0)) OR (cur_size != 0)) )
     FROM scd_story ss,
      scd_story_pattern ssp
     PLAN (ss
      WHERE parser(full_story_clause))
      JOIN (ssp
      WHERE ssp.scd_story_id=ss.scd_story_id
       AND (((ssp.scr_pattern_id=request->pattern_id)) OR (expand(expand_idx_patt,1,cur_size,ssp
       .scr_pattern_id,reply->patterns[expand_idx_patt].scr_pattern_id))) )
    ELSEIF (story_count=0)
     FROM scd_story ss
     PLAN (ss
      WHERE parser(full_story_clause))
    ELSE
     FROM scd_story ss
     PLAN (ss
      WHERE parser(full_story_clause)
       AND expand(expand_idx_story,1,story_count,ss.scd_story_id,request->story_ids[expand_idx_story]
       .story_id))
    ENDIF
    INTO "nl:"
    ORDER BY ss.scd_story_id
    HEAD ss.scd_story_id
     idx += 1
     IF (mod(idx,100)=1)
      stat = alterlist(reply->notes,(idx+ 99))
     ENDIF
     reply->notes[idx].scd_story_id = ss.scd_story_id, reply->notes[idx].story_type_cd = ss
     .story_type_cd, reply->notes[idx].title = ss.title,
     reply->notes[idx].story_completion_status_cd = ss.story_completion_status_cd, reply->notes[idx].
     author_id = ss.author_id, reply->notes[idx].person_id = 0.0,
     reply->notes[idx].event_id = 0.0, reply->notes[idx].event_cd = 0.0, reply->notes[idx].
     encounter_id = 0.0,
     reply->notes[idx].active_ind = ss.active_ind, reply->notes[idx].update_lock_user_id = ss
     .update_lock_user_id, reply->notes[idx].update_lock_dt_tm = ss.update_lock_dt_tm,
     reply->notes[idx].updt_dt_tm = ss.updt_dt_tm, reply->notes[idx].updt_id = ss.updt_id, reply->
     notes[idx].entry_mode_cd = ss.entry_mode_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->notes,idx)
   FREE RECORD pattern_info
   RECORD pattern_info(
     1 patterns[*]
       2 scr_pattern_id = f8
       2 index_count = i4
       2 indexes[*]
         3 note_index = i4
         3 pattern_index = i4
   )
   SET expand_idx = 0
   DECLARE reply_story_count = i4 WITH protect, constant(idx)
   DECLARE struct_idx = i4 WITH protect, noconstant(0)
   DECLARE cur_idx = i4 WITH protect, noconstant(0)
   DECLARE pat_idx = i4 WITH protect, noconstant(0)
   DECLARE locate_pat_idx = i4 WITH protect, noconstant(0)
   DECLARE story_idx = i4 WITH protect, noconstant(1)
   DECLARE inewindexsize = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM scd_story_pattern ssp
    PLAN (ssp
     WHERE expand(expand_idx,1,reply_story_count,ssp.scd_story_id,reply->notes[expand_idx].
      scd_story_id))
    ORDER BY ssp.scd_story_id
    HEAD ssp.scd_story_id
     cur_idx = 0, inewindexsize = 0, pat_idx = 0,
     story_idx = locateval(cur_idx,1,reply_story_count,ssp.scd_story_id,reply->notes[cur_idx].
      scd_story_id)
    DETAIL
     IF (story_idx > 0)
      pat_idx += 1
      IF (mod(pat_idx,10)=1)
       stat = alterlist(reply->notes[story_idx].patterns,(pat_idx+ 9))
      ENDIF
      reply->notes[story_idx].patterns[pat_idx].scr_pattern_id = ssp.scr_pattern_id, reply->notes[
      story_idx].patterns[pat_idx].scr_paragraph_type_id = ssp.scr_paragraph_type_id, cur_idx = 0,
      locate_pat_idx = locateval(cur_idx,1,struct_idx,ssp.scr_pattern_id,pattern_info->patterns[
       cur_idx].scr_pattern_id)
      IF (locate_pat_idx=0)
       struct_idx += 1
       IF (mod(struct_idx,10)=1)
        stat = alterlist(pattern_info->patterns,(struct_idx+ 9))
       ENDIF
       pattern_info->patterns[struct_idx].scr_pattern_id = ssp.scr_pattern_id, pattern_info->
       patterns[struct_idx].index_count = 1, stat = alterlist(pattern_info->patterns[struct_idx].
        indexes,10),
       pattern_info->patterns[struct_idx].indexes[1].note_index = story_idx, pattern_info->patterns[
       struct_idx].indexes[1].pattern_index = pat_idx
      ELSE
       inewindexsize = (pattern_info->patterns[locate_pat_idx].index_count+ 1), pattern_info->
       patterns[locate_pat_idx].index_count = inewindexsize
       IF (mod(inewindexsize,10)=1)
        stat = alterlist(pattern_info->patterns[locate_pat_idx].indexes,(inewindexsize+ 9))
       ENDIF
       pattern_info->patterns[locate_pat_idx].indexes[inewindexsize].note_index = story_idx,
       pattern_info->patterns[locate_pat_idx].indexes[inewindexsize].pattern_index = pat_idx
      ENDIF
     ENDIF
    FOOT  ssp.scd_story_id
     stat = alterlist(reply->notes[story_idx].patterns,pat_idx)
    FOOT REPORT
     stat = alterlist(pattern_info->patterns,struct_idx)
    WITH nocounter, expand = 1
   ;end select
   IF (story_count != 0)
    SET stat = alterlist(request->story_ids,story_count)
   ENDIF
   SET expand_idx = 0
   DECLARE noteidx = i4 WITH protect, noconstant(0)
   DECLARE patidx = i4 WITH protect, noconstant(0)
   DECLARE locate_idx = i4 WITH protect, noconstant(0)
   DECLARE pattern_info_size = i4 WITH protect, constant(size(pattern_info->patterns,5))
   DECLARE icnt = i4 WITH protect, noconstant(0)
   IF (pattern_info_size != 0)
    SELECT INTO "NL:"
     FROM scr_pattern pat
     PLAN (pat
      WHERE expand(expand_idx,1,pattern_info_size,pat.scr_pattern_id,pattern_info->patterns[
       expand_idx].scr_pattern_id))
     DETAIL
      IF (pat.scr_pattern_id != 0.0)
       locate_idx = locateval(expand_idx,1,pattern_info_size,pat.scr_pattern_id,pattern_info->
        patterns[expand_idx].scr_pattern_id)
       IF (locate_idx > 0)
        FOR (icnt = 1 TO pattern_info->patterns[expand_idx].index_count)
          noteidx = pattern_info->patterns[locate_idx].indexes[icnt].note_index, patidx =
          pattern_info->patterns[locate_idx].indexes[icnt].pattern_index, reply->notes[noteidx].
          patterns[patidx].scr_pattern_id = pat.scr_pattern_id,
          reply->notes[noteidx].patterns[patidx].pattern_type_cd = pat.pattern_type_cd, reply->notes[
          noteidx].patterns[patidx].display = pat.display, reply->notes[noteidx].patterns[patidx].
          definition = pat.definition
        ENDFOR
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL populateconcept(idx)
   FREE RECORD sac_org
   FREE RECORD pattern_info
 END ;Subroutine
 SUBROUTINE (populateconcept(idx=i4) =null)
  IF (idx > 0)
   DECLARE expand_cnt = i4 WITH protect, noconstant(0)
   DECLARE expand_cnt2 = i4 WITH protect, noconstant(0)
   DECLARE expand_start_cnt = i4 WITH protect, noconstant(1)
   DECLARE expand_size_cnt = i4 WITH protect, constant(200)
   DECLARE loop_count_concept = i4 WITH private, noconstant(ceil((cnvtreal(idx)/ expand_size_cnt)))
   DECLARE new_size_cnt = i4 WITH protect, constant((loop_count_concept * expand_size_cnt))
   DECLARE note_count = i4 WITH private, constant(size(reply->notes,5))
   IF (note_count != new_size_cnt)
    SET stat = alterlist(reply->notes,new_size_cnt)
    FOR (pad_idx = (idx+ 1) TO new_size_cnt)
      SET reply->notes[pad_idx].scd_story_id = reply->notes[note_count].scd_story_id
    ENDFOR
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(loop_count_concept)),
     scd_story_concept ssc
    PLAN (d
     WHERE initarray(expand_start_cnt,evaluate(d.seq,1,1,(expand_start_cnt+ expand_size_cnt))))
     JOIN (ssc
     WHERE expand(expand_cnt,expand_start_cnt,(expand_start_cnt+ (expand_size_cnt - 1)),ssc
      .scd_story_id,reply->notes[expand_cnt].scd_story_id))
    ORDER BY ssc.scd_story_id
    HEAD REPORT
     concept_idx = 0
    HEAD ssc.scd_story_id
     expand_cnt = 1, concept_idx = 0
    DETAIL
     concept_idx += 1, expand_cnt2 = expand_cnt, expand_cnt = locateval(expand_cnt,expand_cnt2,size(
       reply->notes,5),ssc.scd_story_id,reply->notes[expand_cnt].scd_story_id)
     IF (mod(concept_idx,10)=1)
      stat = alterlist(reply->notes[expand_cnt].concepts,(concept_idx+ 9))
     ENDIF
     reply->notes[expand_cnt].concepts[concept_idx].concept_cki = ssc.concept_cki, reply->notes[
     expand_cnt].concepts[concept_idx].concept_display = ssc.concept_display, reply->notes[expand_cnt
     ].concepts[concept_idx].concept_type_flag = ssc.concept_type_flag,
     reply->notes[expand_cnt].concepts[concept_idx].diagnosis_group_id = ssc.diagnosis_group_id
    FOOT  ssc.scd_story_id
     stat = alterlist(reply->notes[expand_cnt].concepts,concept_idx)
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->notes,note_count)
  ENDIF
  IF (idx=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 END ;Subroutine
 SUBROUTINE retrievemacrolist(null)
   IF (story_count != 0)
    SET serrmsg = "Selective macro retrieval unimplemented"
    SET status = 1
    RETURN
   ENDIF
   DECLARE pre_term_cd = f8 WITH protect, noconstant(0.0)
   DECLARE pre_sent_cd = f8 WITH protect, noconstant(0.0)
   DECLARE pre_para_cd = f8 WITH protect, noconstant(0.0)
   DECLARE scd_story_where = vc WITH protect
   DECLARE scd_story_length = i4 WITH protect, noconstant(0)
   DECLARE story_idx = i4 WITH protect, noconstant(0)
   DECLARE expand_idx = i4 WITH protect, noconstant(0)
   IF ((request->type_mean="PREPARA"))
    SET pre_para_cd = request->type_cd
    SET stat = uar_get_meaning_by_codeset(15749,"PRESENT",1,pre_sent_cd)
    SET stat = uar_get_meaning_by_codeset(15749,"PRETERM",1,pre_term_cd)
   ELSEIF ((request->type_mean="PRESENT"))
    SET pre_sent_cd = request->type_cd
    SET stat = uar_get_meaning_by_codeset(15749,"PRETERM",1,pre_term_cd)
    SET stat = uar_get_meaning_by_codeset(15749,"PREPARA",1,pre_para_cd)
   ELSE
    SET pre_term_cd = request->type_cd
    SET stat = uar_get_meaning_by_codeset(15749,"PREPARA",1,pre_para_cd)
    SET stat = uar_get_meaning_by_codeset(15749,"PRESENT",1,pre_sent_cd)
   ENDIF
   IF (pre_sent_cd=0.0)
    SET table_name = "CODE_VALUE"
    SET serrmsg = "Failed to find the code_value for cdf_meaning PRESENT from code_set 15749"
    SET status = 1
    GO TO exit_script
   ENDIF
   IF (pre_para_cd=0.0)
    SET table_name = "CODE_VALUE"
    SET serrmsg = "Failed to find the code_value for cdf_meaning PREPARA from code_set 15749"
    SET status = 1
    GO TO exit_script
   ENDIF
   IF (pre_term_cd=0.0)
    SET table_name = "CODE_VALUE"
    SET serrmsg = "Failed to find the code_value for cdf_meaning PRETERM from code_set 15749"
    SET status = 1
    GO TO exit_script
   ENDIF
   DECLARE filter_by_org_ind = i2 WITH protect, noconstant(0)
   IF ((request->filter_by_user_org_ind=1)
    AND validate(ccldminfo->mode,0)
    AND (ccldminfo->sec_org_reltn=1))
    SET filter_by_org_ind = 1
    FREE RECORD sac_org
    IF (validate(_sacrtl_org_inc_,99999)=99999)
     DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
     RECORD sac_org(
       1 organizations[*]
         2 organization_id = f8
         2 confid_cd = f8
         2 confid_level = i4
     )
     EXECUTE secrtl
     EXECUTE sacrtl
     DECLARE orgcnt = i4 WITH protected, noconstant(0)
     DECLARE secstat = i2
     DECLARE logontype = i4 WITH protect, noconstant(- (1))
     DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
     DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
     DECLARE dynorg_enabled = i4 WITH constant(1)
     DECLARE dynorg_disabled = i4 WITH constant(0)
     DECLARE logontype_nhs = i4 WITH constant(1)
     DECLARE logontype_legacy = i4 WITH constant(0)
     DECLARE confid_cnt = i4 WITH protected, noconstant(0)
     RECORD confid_codes(
       1 list[*]
         2 code_value = f8
         2 coll_seq = f8
     )
     CALL uar_secgetclientlogontype(logontype)
     CALL echo(build("logontype:",logontype))
     IF (logontype != logontype_nhs)
      SET dynamic_org_ind = dynorg_disabled
     ENDIF
     IF (logontype=logontype_nhs)
      SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
        DECLARE scur_trust = vc
        DECLARE pref_val = vc
        DECLARE is_enabled = i4 WITH constant(1)
        DECLARE is_disabled = i4 WITH constant(0)
        SET scur_trust = cnvtstring(dtrustid)
        SET scur_trust = concat(scur_trust,".00")
        IF ( NOT (validate(pref_req,0)))
         RECORD pref_req(
           1 write_ind = i2
           1 delete_ind = i2
           1 pref[*]
             2 contexts[*]
               3 context = vc
               3 context_id = vc
             2 section = vc
             2 section_id = vc
             2 subgroup = vc
             2 entries[*]
               3 entry = vc
               3 values[*]
                 4 value = vc
         )
        ENDIF
        IF ( NOT (validate(pref_rep,0)))
         RECORD pref_rep(
           1 pref[*]
             2 section = vc
             2 section_id = vc
             2 subgroup = vc
             2 entries[*]
               3 pref_exists_ind = i2
               3 entry = vc
               3 values[*]
                 4 value = vc
           1 status_data
             2 status = c1
             2 subeventstatus[1]
               3 operationname = c25
               3 operationstatus = c1
               3 targetobjectname = c25
               3 targetobjectvalue = vc
         )
        ENDIF
        SET stat = alterlist(pref_req->pref,1)
        SET stat = alterlist(pref_req->pref[1].contexts,2)
        SET stat = alterlist(pref_req->pref[1].entries,1)
        SET pref_req->pref[1].contexts[1].context = "organization"
        SET pref_req->pref[1].contexts[1].context_id = scur_trust
        SET pref_req->pref[1].contexts[2].context = "default"
        SET pref_req->pref[1].contexts[2].context_id = "system"
        SET pref_req->pref[1].section = "workflow"
        SET pref_req->pref[1].section_id = "UK Trust Security"
        SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
        EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
        IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
         RETURN(is_enabled)
        ELSE
         RETURN(is_disabled)
        ENDIF
      END ;Subroutine
      DECLARE hprop = i4 WITH protect, noconstant(0)
      DECLARE tmpstat = i2
      DECLARE spropname = vc
      DECLARE sroleprofile = vc
      SET hprop = uar_srvcreateproperty()
      SET tmpstat = uar_secgetclientattributesext(5,hprop)
      SET spropname = uar_srvfirstproperty(hprop)
      SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
      SELECT INTO "nl:"
       FROM prsnl_org_reltn_type prt,
        prsnl_org_reltn por
       PLAN (prt
        WHERE prt.role_profile=sroleprofile
         AND prt.active_ind=1
         AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
        JOIN (por
        WHERE (por.organization_id= Outerjoin(prt.organization_id))
         AND (por.person_id= Outerjoin(prt.prsnl_id))
         AND (por.active_ind= Outerjoin(1))
         AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
         AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
       ORDER BY por.prsnl_org_reltn_id
       DETAIL
        orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
        sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
        confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
        sac_org->organizations[1].confid_level =
        IF (confid_cd > 0) confid_cd
        ELSE 0
        ENDIF
       WITH maxrec = 1
      ;end select
      SET dcur_trustid = sac_org->organizations[1].organization_id
      SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
      CALL uar_srvdestroyhandle(hprop)
     ENDIF
     IF (dynamic_org_ind=dynorg_disabled)
      SET confid_cnt = 0
      SELECT INTO "NL:"
       c.code_value, c.collation_seq
       FROM code_value c
       WHERE c.code_set=87
       DETAIL
        confid_cnt += 1
        IF (mod(confid_cnt,10)=1)
         secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
        ENDIF
        confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
        coll_seq = c.collation_seq
       WITH nocounter
      ;end select
      SET secstat = alterlist(confid_codes->list,confid_cnt)
      SELECT DISTINCT INTO "nl:"
       FROM prsnl_org_reltn por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.active_ind=1
        AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
       HEAD REPORT
        IF (orgcnt > 0)
         secstat = alterlist(sac_org->organizations,100)
        ENDIF
       DETAIL
        orgcnt += 1
        IF (mod(orgcnt,100)=1)
         secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
        ENDIF
        sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
        orgcnt].confid_cd = por.confid_level_cd
       FOOT REPORT
        secstat = alterlist(sac_org->organizations,orgcnt)
       WITH nocounter
      ;end select
      SELECT INTO "NL:"
       FROM (dummyt d1  WITH seq = value(orgcnt)),
        (dummyt d2  WITH seq = value(confid_cnt))
       PLAN (d1)
        JOIN (d2
        WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
       DETAIL
        sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
       WITH nocounter
      ;end select
     ELSEIF (dynamic_org_ind=dynorg_enabled)
      DECLARE nhstrustchild_org_org_reltn_cd = f8
      SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
      SELECT INTO "nl:"
       FROM org_org_reltn oor
       PLAN (oor
        WHERE oor.organization_id=dcur_trustid
         AND oor.active_ind=1
         AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
         AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
         AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
       HEAD REPORT
        IF (orgcnt > 0)
         secstat = alterlist(sac_org->organizations,10)
        ENDIF
       DETAIL
        IF (oor.related_org_id > 0)
         orgcnt += 1
         IF (mod(orgcnt,10)=1)
          secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
         ENDIF
         sac_org->organizations[orgcnt].organization_id = oor.related_org_id
        ENDIF
       FOOT REPORT
        secstat = alterlist(sac_org->organizations,orgcnt)
       WITH nocounter
      ;end select
     ELSE
      CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
     ENDIF
    ENDIF
    IF (size(sac_org->organizations,5)=0)
     SET stat = alterlist(sac_org->organizations,1)
     SET sac_org->organizations[1].organization_id = 0.0
    ENDIF
   ENDIF
   SET scd_story_where = "s.story_type_cd in (pre_para_cd, pre_sent_cd, pre_term_cd)"
   IF ((request->completion_status_cd != 0))
    SET scd_story_where = concat(scd_story_where,
     " and s.story_completion_status_cd = request->completion_status_cd")
   ENDIF
   IF ((request->status_flag=0))
    SET scd_story_where = concat(scd_story_where," and s.active_ind = 1")
   ELSEIF ((request->status_flag=2))
    SET scd_story_where = concat(scd_story_where," and s.active_ind = 0")
   ENDIF
   IF ((request->entry_mode_filter_ind=1))
    SET scd_story_where = concat(scd_story_where," and s.entry_mode_cd = request->entry_mode_cd")
   ELSEIF ((request->entry_mode_filter_ind=2))
    SET scd_story_where = concat(scd_story_where,
     " and (s.entry_mode_cd = request->entry_mode_cd or s.entry_mode_cd = 0)")
   ENDIF
   CALL echo(build("scd_story_where-> ",scd_story_where))
   IF (filter_by_org_ind=1
    AND (request->shared_note_ind=1))
    DECLARE total_orgs = i4 WITH protect, constant(size(sac_org->organizations,5))
    INSERT  FROM shared_value_gttd sv
     (sv.source_entity_value, sv.source_entity_name)(SELECT DISTINCT
      sso.scd_story_id, "MACRO_SCD_STORY_ID"
      FROM scd_story_org_reltn sso
      WHERE expand(expand_idx,1,total_orgs,sso.organization_id,sac_org->organizations[expand_idx].
       organization_id)
       AND sso.scd_story_id != 0.0
      WITH nocounter, expand = 1)
    ;end insert
    SELECT INTO "nl:"
     FROM shared_value_gttd sv,
      scd_story s
     PLAN (sv
      WHERE sv.source_entity_name="MACRO_SCD_STORY_ID")
      JOIN (s
      WHERE s.scd_story_id=sv.source_entity_value
       AND parser(scd_story_where))
     ORDER BY s.scd_story_id
     HEAD s.scd_story_id
      story_idx += 1
      IF (mod(story_idx,100)=1)
       stat = alterlist(reply->notes,(story_idx+ 99))
      ENDIF
      reply->notes[story_idx].scd_story_id = s.scd_story_id, reply->notes[story_idx].encounter_id =
      0.0, reply->notes[story_idx].person_id = 0.0,
      reply->notes[story_idx].story_type_cd = s.story_type_cd, reply->notes[story_idx].title = s
      .title, reply->notes[story_idx].story_completion_status_cd = s.story_completion_status_cd,
      reply->notes[story_idx].author_id = s.author_id, reply->notes[story_idx].event_id = 0.0, reply
      ->notes[story_idx].active_ind = s.active_ind,
      reply->notes[story_idx].update_lock_user_id = s.update_lock_user_id, reply->notes[story_idx].
      update_lock_dt_tm = s.update_lock_dt_tm, reply->notes[story_idx].updt_id = s.updt_id,
      reply->notes[story_idx].updt_dt_tm = s.updt_dt_tm, reply->notes[story_idx].entry_mode_cd = s
      .entry_mode_cd
     WITH nocounter
    ;end select
   ELSEIF ((request->shared_note_ind=1))
    SELECT INTO "nl:"
     FROM scd_story s
     PLAN (s
      WHERE parser(scd_story_where)
       AND s.author_id=0)
     ORDER BY s.scd_story_id
     HEAD s.scd_story_id
      story_idx += 1
      IF (mod(story_idx,100)=1)
       stat = alterlist(reply->notes,(story_idx+ 99))
      ENDIF
      reply->notes[story_idx].scd_story_id = s.scd_story_id, reply->notes[story_idx].encounter_id =
      0.0, reply->notes[story_idx].person_id = 0.0,
      reply->notes[story_idx].story_type_cd = s.story_type_cd, reply->notes[story_idx].title = s
      .title, reply->notes[story_idx].story_completion_status_cd = s.story_completion_status_cd,
      reply->notes[story_idx].author_id = s.author_id, reply->notes[story_idx].event_id = 0.0, reply
      ->notes[story_idx].active_ind = s.active_ind,
      reply->notes[story_idx].update_lock_user_id = s.update_lock_user_id, reply->notes[story_idx].
      update_lock_dt_tm = s.update_lock_dt_tm, reply->notes[story_idx].updt_id = s.updt_id,
      reply->notes[story_idx].updt_dt_tm = s.updt_dt_tm, reply->notes[story_idx].entry_mode_cd = s
      .entry_mode_cd
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM scd_story s
    PLAN (s
     WHERE parser(scd_story_where)
      AND (s.author_id=request->user_id))
    ORDER BY s.scd_story_id
    HEAD s.scd_story_id
     story_idx += 1
     IF (mod(story_idx,100)=1)
      stat = alterlist(reply->notes,(story_idx+ 99))
     ENDIF
     reply->notes[story_idx].scd_story_id = s.scd_story_id, reply->notes[story_idx].encounter_id =
     0.0, reply->notes[story_idx].person_id = 0.0,
     reply->notes[story_idx].story_type_cd = s.story_type_cd, reply->notes[story_idx].title = s.title,
     reply->notes[story_idx].story_completion_status_cd = s.story_completion_status_cd,
     reply->notes[story_idx].author_id = s.author_id, reply->notes[story_idx].event_id = 0.0, reply->
     notes[story_idx].active_ind = s.active_ind,
     reply->notes[story_idx].update_lock_user_id = s.update_lock_user_id, reply->notes[story_idx].
     update_lock_dt_tm = s.update_lock_dt_tm, reply->notes[story_idx].updt_id = s.updt_id,
     reply->notes[story_idx].updt_dt_tm = s.updt_dt_tm, reply->notes[story_idx].entry_mode_cd = s
     .entry_mode_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->notes,story_idx)
   DECLARE total_stories = i4 WITH protect, constant(story_idx)
   DECLARE para_idx = i4 WITH protect, noconstant(0)
   DECLARE cur_idx = i4 WITH protect, noconstant(0)
   SET expand_idx = 0
   SELECT INTO "nl:"
    FROM scd_paragraph sp,
     scd_sentence ss
    PLAN (ss
     WHERE expand(expand_idx,1,total_stories,ss.scd_story_id,reply->notes[expand_idx].scd_story_id))
     JOIN (sp
     WHERE sp.scd_paragraph_id=ss.scd_paragraph_id)
    ORDER BY sp.scd_story_id, sp.scd_paragraph_id
    HEAD sp.scd_story_id
     cur_idx = 0, story_idx = locateval(cur_idx,1,total_stories,sp.scd_story_id,reply->notes[cur_idx]
      .scd_story_id), para_idx = 0
    HEAD sp.scd_paragraph_id
     IF (story_idx != 0)
      para_idx += 1, stat = alterlist(reply->notes[story_idx].paragraphs,para_idx), reply->notes[
      story_idx].paragraphs[para_idx].scr_paragraph_type_id = sp.scr_paragraph_type_id,
      sent_idx = 0
     ENDIF
    DETAIL
     IF (story_idx != 0
      AND para_idx != 0)
      sent_idx += 1
      IF (mod(sent_idx,10)=1)
       stat = alterlist(reply->notes[story_idx].paragraphs[para_idx].sentences,(sent_idx+ 9))
      ENDIF
      reply->notes[story_idx].paragraphs[para_idx].sentences[sent_idx].scd_sentence_id = ss
      .scd_sentence_id, reply->notes[story_idx].paragraphs[para_idx].sentences[sent_idx].
      canonical_sentence_pattern_id = ss.canonical_sentence_pattern_id, reply->notes[story_idx].
      paragraphs[para_idx].sentences[sent_idx].scr_term_hier_id = ss.scr_term_hier_id
     ENDIF
    FOOT  sp.scd_paragraph_id
     IF (story_idx != 0
      AND para_idx != 0)
      stat = alterlist(reply->notes[story_idx].paragraphs[para_idx].sentences,sent_idx)
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   IF (total_stories=0)
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   FREE RECORD sac_org
 END ;Subroutine
 SUBROUTINE retrievepatterns(null)
   DECLARE concept_count = i4 WITH protect, constant(size(request->concept_qual,5))
   IF (((concept_count != 0) OR ((((request->note_type_id != 0.0)) OR ((request->event_cd != 0.0)))
   ))
    AND story_count != 0)
    SET serrmsg = "Selective note retrieval and pattern retrieval unimplemented"
    SET status = 1
    RETURN
   ENDIF
   IF (concept_count=0
    AND (request->note_type_id=0.0)
    AND (request->event_cd=0.0))
    RETURN
   ENDIF
   FREE RECORD patrn_list_request
   RECORD patrn_list_request(
     1 selection_options
       2 query_type = i2
       2 encounter_id = f8
       2 nomenclature_id = f8
       2 name = vc
       2 concept_source_cd = f8
       2 concept_source_mean = vc
       2 concept_identifier = vc
       2 cki_source = vc
       2 cki_identifier = vc
       2 pattern_id = f8
       2 concept_qual[*]
         3 concept_source_cd = f8
         3 concept_source_mean = vc
         3 concept_identifier = vc
       2 note_type_id = f8
       2 pattern_ids[*]
         3 pattern_id = f8
       2 event_cd = f8
     1 pattern_type_cd = f8
     1 pattern_type_mean = vc
     1 all_status_ind = i2
     1 exact_match_ind = i2
     1 continuation_ind = i2
     1 max_list_size = i2
     1 entry_mode_filter_ind = i2
     1 entry_mode_cd = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
     1 cps_error
       2 cnt = i4
       2 data[*]
         3 code = i4
         3 severity_level = i4
         3 supp_err_txt = c32
         3 def_msg = vc
         3 row_data
           4 lvl_1_idx = i4
           4 lvl_2_idx = i4
           4 lvl_3_idx = i4
   )
   SET patrn_list_request->entry_mode_cd = request->entry_mode_cd
   SET patrn_list_request->entry_mode_filter_ind = request->entry_mode_filter_ind
   SET patrn_list_request->max_list_size = request->max_list_size
   SET patrn_list_request->selection_options.note_type_id = request->note_type_id
   SET patrn_list_request->selection_options.event_cd = request->event_cd
   IF (concept_count != 0)
    CALL retrievepatternsfromconcepts(concept_count)
   ELSE
    CALL retrievepatternsfromnotetype(null)
   ENDIF
   FREE RECORD patrn_list_request
 END ;Subroutine
 SUBROUTINE (retrievepatternsfromconcepts(concept_count=i4) =null)
   SET patrn_list_request->selection_options.query_type = 3
   SET stat = alterlist(patrn_list_request->selection_options.concept_qual,concept_count)
   DECLARE idx = i4 WITH protect, noconstant(0)
   FOR (idx = 1 TO concept_count)
     SET patrn_list_request->selection_options.concept_qual[idx].concept_identifier = request->
     concept_qual[idx].concept_identifier
     SET patrn_list_request->selection_options.concept_qual[idx].concept_source_cd = request->
     concept_qual[idx].concept_source_cd
     SET patrn_list_request->selection_options.concept_qual[idx].concept_source_mean = request->
     concept_qual[idx].concept_source_mean
   ENDFOR
   EXECUTE scdpatlistbyconcept parser("pat.active_ind = 1"), parser(
    IF ((request->entry_mode_filter_ind=1)) "pat.entry_mode_cd = request->entry_mode_cd"
    ELSEIF ((request->entry_mode_filter_ind=2))
     "(pat.entry_mode_cd = request->entry_mode_cd) or (pat.entry_mode_cd = 0.0)"
    ELSE "0 = 0"
    ENDIF
    ), parser("0 = 0") WITH replace(request,patrn_list_request)
 END ;Subroutine
 SUBROUTINE retrievepatternsfromnotetype(null)
  SET patrn_list_request->selection_options.query_type = 6
  EXECUTE scdpatlistbynotetype parser("pat.active_ind = 1"), parser(
   IF ((request->entry_mode_filter_ind=1)) "pat.entry_mode_cd = request->entry_mode_cd"
   ELSEIF ((request->entry_mode_filter_ind=2))
    "(pat.entry_mode_cd = request->entry_mode_cd) or (pat.entry_mode_cd = 0.0)"
   ELSE "0 = 0"
   ENDIF
   ), parser("0 = 0") WITH replace(request,patrn_list_request)
 END ;Subroutine
END GO
