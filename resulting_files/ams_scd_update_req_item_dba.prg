CREATE PROGRAM ams_scd_update_req_item:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the Content Type" = 0,
  "Select the EPs to be updated" = 0,
  "Select the Outstanding required items" = 7141363.000000
  WITH outdev, pcontenttype, pep,
  prequireditem
 DECLARE appid = i4 WITH constant(964700), protect
 DECLARE tskid = i4 WITH constant(964725), protect
 DECLARE reqid = i4 WITH constant(964560), protect
 DECLARE happ = i4 WITH noconstant(0), protect
 DECLARE htask = i4 WITH noconstant(0), protect
 DECLARE hstep = i4 WITH noconstant(0), protect
 DECLARE hrequest = i4 WITH noconstant(0), protect
 DECLARE hreply = i4 WITH noconstant(0), protect
 DECLARE irtn = i4 WITH noconstant(0), protect
 DECLARE epcnt = i4 WITH noconstant(0), protect
 DECLARE patcnt = i4
 DECLARE idx = i4
 DECLARE servname = c41
 DECLARE progname = c41
 DECLARE servicename = vc
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 SET exe_error = 10
 SET script_failed = false
 EXECUTE ams_define_toolkit_common:dba
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 RECORD patternrec(
   1 patternlist[*]
     2 scr_pattern_id = f8
 )
 SET lcheck = substring(1,1,reflect(parameter(3,0)))
 IF (lcheck="L")
  WHILE (lcheck > " ")
    SET patcnt = (patcnt+ 1)
    SET lcheck = substring(1,1,reflect(parameter(3,patcnt)))
    IF (lcheck > " ")
     IF (mod(patcnt,10)=1)
      SET stat = alterlist(patternrec->patternlist,(patcnt+ 9))
     ENDIF
     SET patternrec->patternlist[patcnt].scr_pattern_id = parameter(3,patcnt)
    ENDIF
  ENDWHILE
  SET stat = alterlist(patternrec->patternlist,(patcnt - 1))
 ELSE
  SET stat = alterlist(patternrec->patternlist,1)
  SET patternrec->patternlist[1].scr_pattern_id =  $PEP
 ENDIF
 FREE SET temprequest
 RECORD temprequest(
   1 patterns[*]
     2 action_type = c3
     2 scr_pattern_id = f8
     2 cki_source = vc
     2 cki_identifier = vc
     2 pattern_type_cd = f8
     2 pattern_type_mean = vc
     2 display = vc
     2 definition = vc
     2 active_status_cd = f8
     2 active_status_mean = vc
     2 ignore_updt_cnt_ind = i2
     2 updt_cnt = i4
     2 paragraphs[*]
       3 scr_paragraph_type_id = f8
       3 sequence_number = i4
       3 master_sequence_number = i4
       3 paragraph_actions[*]
         4 scr_action_id = f8
         4 scr_action_cd = f8
     2 sentences[*]
       3 scr_paragraph_type_id = f8
       3 scr_sentence_id = f8
       3 canonical_sentence_pattern_id = f8
       3 sequence_number = i4
       3 sentence_topic_cd = f8
       3 text_format_rule_cd = f8
       3 recommended_cd = f8
       3 default_cd = f8
     2 term_hier[*]
       3 scr_term_hier_id = f8
       3 parent_term_hier_idx = i4
       3 scr_sentence_idx = i4
       3 scr_term_id = f8
       3 cki_source = vc
       3 cki_identifier = vc
       3 recommended_cd = f8
       3 dependency_group = i4
       3 dependency_cd = f8
       3 default_cd = f8
       3 source_term_hier_id = f8
       3 sequence_number = i4
       3 term_type_cd = f8
       3 state_logic_cd = f8
       3 store_cd = f8
       3 concept_identifier = vc
       3 concept_source_cd = f8
       3 concept_cki = vc
       3 visible_cd = f8
       3 youngest_age = f8
       3 oldest_age = f8
       3 restrict_to_sex = vc
       3 eligibility_check_cd = f8
       3 repeat_cd = f8
       3 active_status_cd = f8
       3 term_def[*]
         4 scr_term_def_type_cd = f8
         4 scr_term_def_type_mean = vc
         4 scr_term_def_key = vc
         4 fkey_id = f8
         4 fkey_entity_name = vc
         4 def_text = vc
       3 term_language[*]
         4 display = vc
         4 definition = vc
         4 external_reference_info = vc
         4 text_negation_rule_cd = f8
         4 text_format_rule_cd = f8
         4 text_representation = vc
         4 language_cd = f8
       3 term_actions[*]
         4 scr_action_cd = f8
         4 scr_action_mean = vc
         4 target_entity_blob_idx = i4
         4 target_entity_id = f8
         4 target_entity_name = vc
         4 target_cki_source = vc
         4 target_cki_identifier = vc
         4 expr_id = f8
         4 expr_owner_ind = i2
         4 expr_display = vc
         4 expr_cki = vc
         4 expr_comps[*]
           5 expr_comp_id = f8
           5 expr_id = f8
           5 parent_expr_comp_id = f8
           5 expr_comp_cd = f8
           5 expr_comp_mean = vc
           5 sequence_number = i4
           5 units_cd = f8
           5 units_mean = vc
           5 value_number = i4
           5 value_dt_tm = dq8
           5 value_text = vc
           5 value_fkey_blob_idx = i4
           5 value_fkey_id = f8
           5 value_fkey_entity_name = vc
           5 value_fkey_cki_source = vc
           5 value_fkey_cki_identifier = vc
       3 hier_concept_cki = vc
     2 required_field_enforcement_cd = f8
   1 entry_mode_cd = f8
 )
 FOR (i = 1 TO value(size(patternrec->patternlist,5)))
   SELECT INTO "nl:"
    FROM scr_pattern s
    WHERE (s.scr_pattern_id=patternrec->patternlist[i].scr_pattern_id)
    HEAD REPORT
     epcnt = 0
    HEAD s.scr_pattern_id
     epcnt = (epcnt+ 1)
     IF (mod(epcnt,10)=1)
      stat = alterlist(temprequest->patterns,(epcnt+ 9))
     ENDIF
     temprequest->patterns[epcnt].action_type = "REP", temprequest->patterns[epcnt].cki_source = s
     .cki_source, temprequest->patterns[epcnt].cki_identifier = s.cki_identifier,
     temprequest->patterns[epcnt].pattern_type_cd = s.pattern_type_cd, temprequest->patterns[epcnt].
     display = s.display, temprequest->patterns[epcnt].definition = s.definition,
     temprequest->patterns[epcnt].updt_cnt = (s.updt_cnt+ 1), temprequest->patterns[epcnt].
     active_status_cd = s.active_status_cd, temprequest->patterns[epcnt].
     required_field_enforcement_cd = value( $PREQUIREDITEM),
     temprequest->patterns[epcnt].scr_pattern_id = s.scr_pattern_id, temprequest->entry_mode_cd = s
     .entry_mode_cd
    FOOT REPORT
     stat = alterlist(temprequest->patterns,epcnt)
    WITH nocounter
   ;end select
   CALL echorecord(temprequest)
   EXECUTE cps_add_scd_patrn:dba  WITH replace("REQUEST",temprequest)
   SET irtn = uar_crmbeginapp(appid,happ)
   IF (irtn != 0)
    CALL echo("uar_crm_begin_app failed.")
    GO TO exit_script
   ENDIF
   SET irtn = uar_crmbegintask(happ,tskid,htask)
   IF (irtn != 0)
    CALL echo("uar_crm_begin_task failed.")
    GO TO exit_script
   ENDIF
   SET irtn = uar_crmbeginreq(htask,"",reqid,hstep)
   IF (irtn != 0)
    CALL echo("uar_crm_begin_Request failed.")
    GO TO exit_script
   ENDIF
   SET hrequest = uar_crmgetrequest(hstep)
   IF (hrequest)
    CALL set_rebuild_cache_request(hrequest)
   ENDIF
   CALL uar_get_tdb(reqid,progname,servname)
   SET servicename = trim(servname)
   SET irtn = uar_crmperformas(hstep,servicename)
   SET hreply = uar_crmgetreply(hstep)
   DECLARE set_rebuild_cache_request(hreq=i4) = null
   SUBROUTINE set_rebuild_cache_request(hreq)
     CALL echo("Entering set_rebuild_cache_request")
     DECLARE hpatterns = i4 WITH noconstant(0), protect
     DECLARE hpatterns1 = i4 WITH noconstant(0), protect
     DECLARE hgentoc = i4 WITH noconstant(0), protect
     SET hpatterns = uar_srvadditem(hreq,"patterns")
     CALL echo(hpatterns)
     CALL echo(patternrec->patternlist[i].scr_pattern_id)
     IF (hpatterns)
      SET stat = uar_srvsetdouble(hpatterns,"scr_pattern_id",patternrec->patternlist[i].
       scr_pattern_id)
     ENDIF
     SET stat = uar_srvsetlong(hreq,"generate_toc",1)
     CALL echo("Leaving set_rebuild_cache_request")
   END ;Subroutine
 ENDFOR
 SELECT INTO  $OUTDEV
  FROM dummyt
  HEAD REPORT
   col 0, "Script executed Successfully."
  WITH nocounter
 ;end select
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET last_mod = "001 12/21/15 ZA030646  Initial Release"
END GO
