CREATE PROGRAM ams_inactivate_powerplan_util:dba
 PAINT
 DECLARE numrows = i4 WITH constant(20), protect
 DECLARE numcols = i4 WITH constant(75), protect
 DECLARE soffrow = i4 WITH constant(6), protect
 DECLARE soffcol = i4 WITH constant(3), protect
 DECLARE quesrow = i4 WITH constant(22), protect
 DECLARE maxrows = i4 WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE arow = i4 WITH protect
 DECLARE rowstr = c75 WITH protect
 DECLARE pick = i4 WITH protect
 DECLARE ccl_ver = i4 WITH protect, noconstant(cnvtint(build(currev,currevminor,currevminor2)))
 DECLARE status = c1 WITH protect, noconstant("F")
 DECLARE debug_ind = i2 WITH protect
 DECLARE statusstr = vc WITH protect
 DECLARE last_mod = vc WITH protect
 DECLARE i = i4 WITH protect
 RECORD log(
   1 qual_cnt = i4
   1 qual[*]
     2 smsgtype = c12
     2 dmsg_dt_tm = dq8
     2 smsg = vc
 ) WITH protect
 DECLARE validatelogin(null) = null WITH protect
 DECLARE clearscreen(null) = null WITH protect
 DECLARE drawmenu(title=vc,detailline=vc,warningline=vc) = null WITH protect
 DECLARE emailfile(vcrecep=vc,vcfrom=vc,vcsubj=vc,vcbody=vc,vcfile=vc) = i2 WITH protect
 DECLARE getclient(null) = vc WITH protect
 DECLARE gethnaemail(null) = vc WITH protect
 DECLARE addlogmsg(msgtype=vc,msg=vc) = null WITH protect
 DECLARE createlogfile(filename=vc) = null WITH protect
 DECLARE drawscrollbox(begrow=i4,begcol=i4,endrow=i4,endcol=i4) = null WITH protect
 DECLARE downarrow(newrow=c75) = null WITH protect
 DECLARE uparrow(newrow=c75) = null WITH protect
 SUBROUTINE validatelogin(null)
   EXECUTE cclseclogin
   SET message = nowindow
   IF ((xxcclseclogin->loggedin != 1))
    SET status = "F"
    SET statusstr = "You must be logged in securely. Please run the program again."
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE clearscreen(null)
   DECLARE i = i4 WITH protect
   SET i = soffrow
   WHILE (i <= numrows)
    CALL clear(i,soffcol,numcols)
    SET i = (i+ 1)
   ENDWHILE
   CALL clear((numrows+ 2),soffcol,numcols)
 END ;Subroutine
 SUBROUTINE drawmenu(title,detailline,warningline)
   CALL clear(1,1)
   CALL box((soffrow - 5),(soffcol - 1),(numrows+ 3),(numcols+ 3))
   CALL video(r)
   CALL text((soffrow - 4),soffcol,title)
   CALL text((soffrow - 3),soffcol,detailline)
   CALL video(b)
   CALL text((soffrow - 2),soffcol,warningline)
   CALL video(n)
   CALL line((soffrow - 1),(soffcol - 1),(numcols+ 2),xhor)
   CALL line((soffrow+ 15),(soffcol - 1),(numcols+ 2),xhor)
   CALL text((soffrow+ 16),soffcol,"Choose an option:")
 END ;Subroutine
 SUBROUTINE emailfile(vcrecep,vcfrom,vcsubj,vcbody,vcfile)
   DECLARE retval = i2
   RECORD email_request(
     1 recepstr = vc
     1 fromstr = vc
     1 subjectstr = vc
     1 bodystr = vc
     1 filenamestr = vc
   ) WITH protect
   RECORD email_reply(
     1 status = c1
     1 errorstr = vc
   ) WITH protect
   SET email_request->recepstr = vcrecep
   SET email_request->fromstr = vcfrom
   SET email_request->subjectstr = vcsubj
   SET email_request->bodystr = vcbody
   SET email_request->filenamestr = vcfile
   EXECUTE ams_run_email_file  WITH replace("REQUEST",email_request), replace("REPLY",email_reply)
   IF ((email_reply->status="S"))
    SET retval = 1
   ELSE
    SET retval = 0
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE getclient(null)
   DECLARE retval = vc WITH protect, noconstant("")
   SET retval = logical("CLIENT_MNEMONIC")
   IF (retval="")
    SELECT INTO "nl:"
     d.info_char
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      retval = trim(d.info_char)
     WITH nocounter
    ;end select
   ENDIF
   IF (retval="")
    SET retval = "unknown"
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE gethnaemail(null)
   DECLARE retval = vc WITH protect
   SELECT INTO "nl:"
    p.email
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
    DETAIL
     retval = trim(p.email)
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE addlogmsg(msgtype,msg)
   SET log->qual_cnt = (log->qual_cnt+ 1)
   IF (mod(log->qual_cnt,50)=1)
    SET stat = alterlist(log->qual,(log->qual_cnt+ 49))
   ENDIF
   SET log->qual[log->qual_cnt].smsgtype = msgtype
   SET log->qual[log->qual_cnt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_cnt].smsg = msg
 END ;Subroutine
 SUBROUTINE createlogfile(filename)
   DECLARE logcnt = i4 WITH protect
   IF (ccl_ver >= 871)
    SET modify = filestream
   ENDIF
   SET stat = alterlist(log->qual,log->qual_cnt)
   FREE SET output_log
   SET logical output_log value(nullterm(concat("CCLUSERDIR:",trim(cnvtlower(filename)))))
   SELECT INTO output_log
    FROM (dummyt d  WITH seq = 1)
    HEAD REPORT
     outline = fillstring(254," ")
    DETAIL
     FOR (logcnt = 1 TO log->qual_cnt)
       outline = trim(substring(1,254,concat(format(log->qual[logcnt].smsgtype,"############")," :: ",
          format(log->qual[logcnt].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[logcnt
           ].smsg)))), col 0, outline
       IF ((logcnt != log->qual_cnt))
        row + 1
       ENDIF
     ENDFOR
    WITH nocounter, formfeed = none, format = stream,
     append, maxcol = 255, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE drawscrollbox(begrow,begcol,endrow,endcol)
  CALL box(begrow,begcol,endrow,endcol)
  CALL scrollinit((begrow+ 1),(begcol+ 1),(endrow - 1),(endcol - 1))
 END ;Subroutine
 SUBROUTINE downarrow(newrow)
   IF (arow=maxrows)
    CALL scrolldown(maxrows,maxrows,newrow)
   ELSE
    SET arow = (arow+ 1)
    CALL scrolldown((arow - 1),arow,newrow)
   ENDIF
 END ;Subroutine
 SUBROUTINE uparrow(newrow)
   IF (arow=1)
    CALL scrollup(arow,arow,rowstr)
   ELSE
    SET arow = (arow - 1)
    CALL scrollup((arow+ 1),arow,rowstr)
   ENDIF
 END ;Subroutine
 IF (validate(debug,0))
  IF (debug=1)
   SET debug_ind = 1
  ELSE
   SET debug_ind = 0
   SET trace = callecho
   SET trace = notest
   SET trace = nordbdebug
   SET trace = nordbbind
   SET trace = noechoinput
   SET trace = noechoinput2
   SET trace = noechorecord
   SET trace = noshowuar
   SET trace = noechosub
   SET trace = nowarning
   SET trace = nowarning2
   SET message = noinformation
   SET trace = nocost
  ENDIF
 ELSE
  SET debug_ind = 0
  SET trace = callecho
  SET trace = notest
  SET trace = nordbdebug
  SET trace = nordbbind
  SET trace = noechoinput
  SET trace = noechoinput2
  SET trace = noechorecord
  SET trace = noshowuar
  SET trace = noechosub
  SET trace = nowarning
  SET trace = nowarning2
  SET message = noinformation
  SET trace = nocost
 ENDIF
 SET last_mod = "005"
 DECLARE incrementimportcount(inccnt=i4) = i2 WITH protect
 DECLARE readinputfile(filename=vc) = null WITH protect
 DECLARE validatedata(null) = i4 WITH protect
 DECLARE createerrorcsv(filename=vc) = null WITH protect
 DECLARE performupdates(null) = null WITH protect
 DECLARE blankfilemode(null) = null WITH protect
 DECLARE getcustomizedplans(null) = i4 WITH protect
 DECLARE updatecustomizedplans(null) = null WITH protect
 DECLARE title_line = c75 WITH protect, constant(
  "                      AMS Inactivate PowerPlan Utility                      ")
 DECLARE detail_line = c75 WITH protect, constant(
  "                      Inactivate and rename PowerPlans                      ")
 DECLARE script_name = c29 WITH protect, constant("AMS_INACTIVATE_POWERPLAN_UTIL")
 DECLARE from_str = vc WITH protect, constant("ams_inactivate_powerplan_util@cerner.com")
 DECLARE delim = vc WITH protect, constant(",")
 DECLARE error_plan_dup_sheet = vc WITH protect, constant(
  "New PowerPlan name exists multiple times in import sheet. ")
 DECLARE error_plan_dup = vc WITH protect, constant("New PowerPlan name already exists. ")
 DECLARE error_plan_dup_prsnl = vc WITH protect, constant(
  "New PowerPlan name already exists as personal plan. Owner: ")
 DECLARE error_plan_not_found = vc WITH protect, constant("Current PowerPlan name not found. ")
 DECLARE logfilename = vc WITH protect, noconstant(" ")
 DECLARE errorfilename = vc WITH protect, noconstant(" ")
 DECLARE errorcnt = i4 WITH protect
 DECLARE emailfailstr = vc WITH protect, constant("Email failed. Manually grab file from CCLUSERDIR")
 DECLARE printrow = i4 WITH protect
 SET logfilename = concat("ams_inactivate_powerplan_util_",cnvtlower(format(cnvtdatetime(curdate,
     curtime3),"dd_mmm_yyyy_hh_mm;;q")),".log")
 SET errorfilename = cnvtlower(concat(getclient(null),"_",trim(curdomain),"_powerplan_errors.csv"))
 RECORD import_data(
   1 list[*]
     2 error_str = vc
     2 pathway_catalog_id = f8
     2 curr_description = vc
     2 new_description = vc
     2 duplicate_ind = i2
     2 dup_pathway_catalog_id = f8
     2 owner_name = vc
     2 pw_cat_synonym_id = f8
     2 cross_encntr_ind = i2
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 pathway_type_cd = f8
     2 display_method_cd = f8
     2 updt_cnt = i4
     2 sub_phase_ind = i2
     2 hide_flexed_comp_ind = i2
     2 cycle_ind = i2
     2 standard_cycle_nbr = i4
     2 default_view_mean = c12
     2 diagnosis_capture_ind = i2
     2 provider_prompt_ind = i2
     2 allow_copy_forward_ind = i2
     2 auto_initiate_ind = i2
     2 alerts_on_plan_ind = i2
     2 alerts_on_plan_upd_ind = i2
     2 cycle_begin_nbr = i4
     2 cycle_end_nbr = i4
     2 cycle_label_cd = f8
     2 cycle_display_end_ind = i2
     2 cycle_lock_end_ind = i2
     2 cycle_increment_nbr = i4
     2 default_action_inpt_future_cd = f8
     2 default_action_inpt_now_cd = f8
     2 default_action_outpt_future_cd = f8
     2 default_action_outpt_now_cd = f8
     2 optional_ind = i2
     2 future_ind = i2
     2 default_visit_type_flag = i2
     2 prompt_on_selection_ind = i2
     2 pathway_class_cd = f8
     2 period_nbr = i4
     2 period_custom_label = c40
     2 route_for_review_ind = i2
     2 default_start_time_txt = c10
     2 primary_ind = i2
     2 uuid = vc
     2 reschedule_reason_accept_flag = i2
     2 restricted_actions_bitmask = i4
     2 open_by_default_ind = i2
     2 fac_list[*]
       3 facility_cd = f8
 ) WITH protect
 RECORD dcp_request(
   1 version_flag = i2
   1 parent_cat_id = f8
   1 planlist[*]
     2 action_type = c12
     2 pathway_catalog_id = f8
     2 type_mean = c12
     2 active_ind = i2
     2 cross_encntr_ind = i2
     2 description = vc
     2 comment_remove_ind = i2
     2 comment_text_id = f8
     2 comment_text = vc
     2 comment_updt_cnt = i4
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 pathway_type_cd = f8
     2 display_method_cd = f8
     2 updt_cnt = i4
     2 comp_r_updt_flag = i2
     2 complist[*]
       3 action_type = c12
       3 pathway_comp_id = f8
       3 sequence = i4
       3 comp_type_cd = f8
       3 comp_type_mean = c12
       3 dcp_clin_cat_cd = f8
       3 dcp_clin_sub_cat_cd = f8
       3 linked_to_tf_ind = i2
       3 persistent_ind = i2
       3 required_ind = i2
       3 include_ind = i2
       3 comp_text_id = f8
       3 comp_text = vc
       3 comp_text_updt_cnt = i4
       3 synonym_id = f8
       3 updt_cnt = i4
       3 remove_os_ind = i2
       3 outcome_catalog_id = f8
       3 duration_qty = i4
       3 duration_unit_cd = f8
       3 target_type_cd = f8
       3 expand_qty = i4
       3 expand_unit_cd = f8
       3 comp_label = vc
       3 offset_quantity = f8
       3 offset_unit_cd = f8
       3 sub_phase_catalog_id = f8
       3 ordsentlist[*]
         4 order_sentence_id = f8
         4 order_sentence_seq = i4
         4 iv_comp_syn_id = f8
         4 normalized_dose_unit_ind = i2
         4 missing_required_ind = i2
       3 cross_phase_group_desc = c40
       3 cross_phase_group_nbr = f8
       3 chemo_ind = i2
       3 chemo_related_ind = i2
       3 default_os_ind = i2
       3 min_tolerance_interval = i4
       3 min_tolerance_interval_unit_cd = f8
       3 uuid = vc
     2 compreltnlist[*]
       3 pathway_comp_s_id = f8
       3 pathway_comp_t_id = f8
       3 type_mean = c12
       3 offset_quantity = f8
       3 offset_unit_cd = f8
       3 pathway_catalog_id = f8
     2 flex_parent_entity_id = f8
     2 display_description = vc
     2 group_updt_flag = i2
     2 compgrouplist[*]
       3 pw_comp_group_id = f8
       3 type_mean = c12
       3 memberlist[*]
         4 pathway_comp_id = f8
         4 comp_seq = i4
     2 sub_phase_ind = i2
     2 hide_flexed_comp_ind = i2
     2 cycle_ind = i2
     2 standard_cycle_nbr = i4
     2 default_view_mean = c12
     2 diagnosis_capture_ind = i2
     2 provider_prompt_ind = i2
     2 allow_copy_forward_ind = i2
     2 auto_initiate_ind = i2
     2 alerts_on_plan_ind = i2
     2 alerts_on_plan_upd_ind = i2
     2 cycle_begin_nbr = i4
     2 cycle_end_nbr = i4
     2 cycle_label_cd = f8
     2 cycle_display_end_ind = i2
     2 cycle_lock_end_ind = i2
     2 cycle_increment_nbr = i4
     2 default_action_inpt_future_cd = f8
     2 default_action_inpt_now_cd = f8
     2 default_action_outpt_future_cd = f8
     2 default_action_outpt_now_cd = f8
     2 optional_ind = i2
     2 future_ind = i2
     2 default_visit_type_flag = i2
     2 prompt_on_selection_ind = i2
     2 pathway_class_cd = f8
     2 period_nbr = i4
     2 period_custom_label = c40
     2 synonymlist[*]
       3 action_flag = i2
       3 pw_cat_synonym_id = f8
       3 synonym_name = vc
     2 route_for_review_ind = i2
     2 default_start_time_txt = c10
     2 primary_ind = i2
     2 uuid = vc
     2 reschedule_reason_accept_flag = i2
     2 restricted_actions_bitmask = i4
     2 open_by_default_ind = i2
   1 remove_plan_reltn_ind = i2
   1 planreltnlist[*]
     2 pw_cat_s_id = f8
     2 pw_cat_t_id = f8
     2 type_mean = c12
     2 offset_qty = i4
     2 offset_unit_cd = f8
   1 pwevidencereltnlist[*]
     2 del_evidence_ind = i2
     2 new_evidence_ind = i2
     2 pw_evidence_reltn_id = f8
     2 pathway_catalog_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_sub_cat_cd = f8
     2 pathway_comp_id = f8
     2 type_mean = c12
     2 evidence_locator = vc
     2 ref_text_reltn_id = f8
     2 evidence_sequence = i4
   1 facilityflexlist[*]
     2 facility_cd = f8
   1 problem_diag_updt_flag = i2
   1 problemdiaglist[*]
     2 concept_cki = vc
   1 compphasereltnlist[*]
     2 pw_comp_cat_reltn_id = f8
     2 pathway_comp_id = f8
     2 pathway_catalog_id = f8
     2 type_mean = c12
     2 add_ind = i2
     2 remove_ind = i2
 ) WITH protect
 RECORD dcp_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD custom_plan_request(
   1 pathway_catalog_id = f8
 ) WITH protect
 RECORD updt_custom_plan_request(
   1 status_flag = i2
   1 customized_plans[*]
     2 pathway_customized_plan_id = f8
 ) WITH protect
 CALL validatelogin(null)
 IF (debug_ind=1)
  CALL addlogmsg("INFO","Beginning ams_inactivate_powerplan_util")
 ENDIF
#main_menu
 CALL drawmenu(title_line,detail_line,"")
 CALL text((soffrow+ 5),(soffcol+ 26),"1 Import PowerPlans to inactivate")
 CALL text((soffrow+ 6),(soffcol+ 26),"2 Create blank import file")
 CALL text((soffrow+ 7),(soffcol+ 26),"3 Exit")
 CALL accept(quesrow,(soffcol+ 18),"9;",3
  WHERE curaccept IN (1, 2, 3))
 CASE (curaccept)
  OF 1:
   CALL importmode(null)
  OF 2:
   CALL blankfilemode(null)
  OF 3:
   GO TO exit_script
 ENDCASE
 SUBROUTINE importmode(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE done = i2 WITH protect
   DECLARE inputfile = vc WITH protect
   DECLARE plancnt = i4 WITH protect
   DECLARE updtcustplanind = i2 WITH protect
   CALL clearscreen(null)
   SET stat = initrec(import_data)
   WHILE (done=0)
     SET printrow = soffrow
     CALL text(printrow,soffcol,"Enter filename to read PowerPlans from:")
     SET printrow = (printrow+ 1)
     CALL accept(printrow,(soffcol+ 1),"P(74);C")
     SET printrow = (printrow+ 1)
     IF (cnvtupper(curaccept)="*.CSV*")
      CALL clear(printrow,soffcol,numcols)
      SET stat = findfile(curaccept)
      IF (stat=1)
       CALL clear(printrow,soffcol,numcols)
       SET inputfile = curaccept
       SET done = 1
       CALL text(printrow,soffcol,
        "Should users be required to create a new plan favorite based on changes")
       SET printrow = (printrow+ 1)
       CALL text(printrow,soffcol,"that have been made?:")
       CALL accept(printrow,(soffcol+ 21),"A;CU"
        WHERE curaccept IN ("Y", "N"))
       IF (curaccept="Y")
        SET updtcustplanind = 1
       ELSE
        SET updtcustplanind = 0
       ENDIF
       SET printrow = (printrow+ 2)
       CALL text(printrow,soffcol,"Reading PowerPlans from file...")
       CALL readinputfile(inputfile)
       CALL text(printrow,(soffcol+ 31),"done")
       SET printrow = (printrow+ 1)
       CALL text(printrow,soffcol,"Checking for duplicate PowerPlans...")
       SET errorcnt = validatedata(null)
       IF (errorcnt=0)
        CALL text(printrow,(soffcol+ 36),"done")
        IF (updtcustplanind=1)
         SET printrow = (printrow+ 1)
         CALL text(printrow,soffcol,"Checking for favorite PowerPlans...")
         SET plancnt = getcustomizedplans(null)
         CALL text(printrow,(soffcol+ 35),"done")
         SET printrow = (printrow+ 1)
         CALL text(printrow,soffcol,build2("Found ",trim(cnvtstring(plancnt))," favorite PowerPlans")
          )
         IF (plancnt > 0)
          SET printrow = (printrow+ 1)
          CALL text(printrow,soffcol,"Updating favorite PowerPlans...")
          CALL updatecustomizedplans(null)
          CALL text(printrow,(soffcol+ 31),"done")
         ENDIF
        ENDIF
        SET printrow = (printrow+ 1)
        CALL text(printrow,soffcol,"Inactivating PowerPlans...")
        SET printrow = (printrow+ 1)
        CALL performupdates(null)
        CALL text((printrow - 1),(soffcol+ 26),"done")
        CALL text(quesrow,soffcol,"Commit?:")
        CALL accept(quesrow,(soffcol+ 8),"A;CU"
         WHERE curaccept IN ("Y", "N"))
        IF (curaccept="Y")
         COMMIT
        ELSE
         ROLLBACK
        ENDIF
       ELSE
        CALL text(printrow,soffcol,
         "Error(s) found. At least one of the PowerPlans in the file has an error.")
        SET printrow = (printrow+ 2)
        SET done = 0
        WHILE (done=0)
          CALL text(printrow,soffcol,"Enter filename to export errors to:")
          SET printrow = (printrow+ 1)
          CALL accept(printrow,(soffcol+ 1),"P(74);C",errorfilename)
          SET printrow = (printrow+ 1)
          IF (cnvtupper(curaccept)="*.CSV*")
           CALL clear(printrow,soffcol,numcols)
           SET done = 1
           SET errorfilename = trim(cnvtlower(curaccept))
           CALL createerrorcsv(errorfilename)
           CALL text(printrow,soffcol,"Do you want to email the file?:")
           CALL accept(printrow,(soffcol+ 31),"A;CU","Y"
            WHERE curaccept IN ("Y", "N"))
           IF (curaccept="Y")
            SET printrow = (printrow+ 1)
            CALL text(printrow,soffcol,"Enter recepient's email address:")
            SET printrow = (printrow+ 1)
            CALL accept(printrow,(soffcol+ 1),"P(74);C",gethnaemail(null)
             WHERE trim(curaccept)="*@*.*")
            IF (emailfile(curaccept,from_str,"","",errorfilename))
             CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
            ELSE
             CALL text((soffrow+ 14),soffcol,emailfailstr)
            ENDIF
            CALL text(quesrow,soffcol,"Continue?:")
            CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
             WHERE curaccept IN ("Y"))
           ENDIF
          ELSEIF (cnvtupper(curaccept)="QUIT")
           GO TO main_menu
          ELSE
           CALL text((soffrow+ 9),soffcol,"File must have .csv extension")
          ENDIF
        ENDWHILE
       ENDIF
      ELSE
       CALL text(printrow,soffcol,
        "File not found. Make sure file exists in CCLUSERDIR or include logical.")
      ENDIF
     ELSEIF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ELSE
      CALL text(printrow,soffcol,"File must have .csv extension")
     ENDIF
   ENDWHILE
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE validatedata(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE planpos = i4 WITH protect
   DECLARE faccnt = i4 WITH protect
   SELECT INTO "nl:"
    pc.pathway_catalog_id
    FROM (dummyt d  WITH seq = value(size(import_data->list,5))),
     pathway_catalog pc,
     pw_cat_synonym pcs,
     pw_cat_flex pcf
    PLAN (d)
     JOIN (pc
     WHERE pc.description_key=cnvtupper(import_data->list[d.seq].curr_description)
      AND pc.active_ind=1
      AND pc.type_mean IN ("CAREPLAN", "PATHWAY")
      AND pc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (pcs
     WHERE pcs.pathway_catalog_id=pc.pathway_catalog_id
      AND pcs.primary_ind=1)
     JOIN (pcf
     WHERE pcf.pathway_catalog_id=outerjoin(pc.pathway_catalog_id)
      AND pcf.parent_entity_name=outerjoin("CODE_VALUE"))
    ORDER BY pc.description_key, pc.pathway_catalog_id, d.seq
    HEAD d.seq
     import_data->list[d.seq].pathway_catalog_id = pc.pathway_catalog_id, import_data->list[d.seq].
     pw_cat_synonym_id = pcs.pw_cat_synonym_id, import_data->list[d.seq].cross_encntr_ind = pc
     .cross_encntr_ind,
     import_data->list[d.seq].duration_qty = pc.duration_qty, import_data->list[d.seq].
     duration_unit_cd = pc.duration_unit_cd, import_data->list[d.seq].pathway_type_cd = pc
     .pathway_type_cd,
     import_data->list[d.seq].display_method_cd = pc.display_method_cd, import_data->list[d.seq].
     updt_cnt = pc.updt_cnt, import_data->list[d.seq].sub_phase_ind = pc.sub_phase_ind,
     import_data->list[d.seq].hide_flexed_comp_ind = pc.hide_flexed_comp_ind, import_data->list[d.seq
     ].cycle_ind = pc.cycle_ind, import_data->list[d.seq].standard_cycle_nbr = pc.standard_cycle_nbr,
     import_data->list[d.seq].default_view_mean = pc.default_view_mean, import_data->list[d.seq].
     diagnosis_capture_ind = pc.diagnosis_capture_ind, import_data->list[d.seq].provider_prompt_ind
      = pc.provider_prompt_ind,
     import_data->list[d.seq].allow_copy_forward_ind = pc.allow_copy_forward_ind, import_data->list[d
     .seq].auto_initiate_ind = pc.auto_initiate_ind, import_data->list[d.seq].alerts_on_plan_ind = pc
     .alerts_on_plan_ind,
     import_data->list[d.seq].alerts_on_plan_upd_ind = pc.alerts_on_plan_ind, import_data->list[d.seq
     ].cycle_begin_nbr = pc.cycle_begin_nbr, import_data->list[d.seq].cycle_end_nbr = pc
     .cycle_end_nbr,
     import_data->list[d.seq].cycle_label_cd = pc.cycle_label_cd, import_data->list[d.seq].
     cycle_display_end_ind = pc.cycle_display_end_ind, import_data->list[d.seq].cycle_lock_end_ind =
     pc.cycle_lock_end_ind,
     import_data->list[d.seq].cycle_increment_nbr = pc.cycle_increment_nbr, import_data->list[d.seq].
     default_action_inpt_future_cd = pc.default_action_inpt_future_cd, import_data->list[d.seq].
     default_action_inpt_now_cd = pc.default_action_inpt_now_cd,
     import_data->list[d.seq].default_action_outpt_future_cd = pc.default_action_outpt_future_cd,
     import_data->list[d.seq].default_action_outpt_now_cd = pc.default_action_outpt_now_cd,
     import_data->list[d.seq].optional_ind = pc.optional_ind,
     import_data->list[d.seq].future_ind = pc.future_ind, import_data->list[d.seq].
     default_visit_type_flag = pc.default_visit_type_flag, import_data->list[d.seq].
     prompt_on_selection_ind = pc.prompt_on_selection_ind,
     import_data->list[d.seq].pathway_class_cd = pc.pathway_class_cd, import_data->list[d.seq].
     period_nbr = pc.period_nbr, import_data->list[d.seq].period_custom_label = pc
     .period_custom_label,
     import_data->list[d.seq].route_for_review_ind = pc.route_for_review_ind, import_data->list[d.seq
     ].default_start_time_txt = pc.default_start_time_txt, import_data->list[d.seq].primary_ind = pc
     .primary_ind,
     import_data->list[d.seq].uuid = pc.pathway_uuid, import_data->list[d.seq].
     reschedule_reason_accept_flag = pc.reschedule_reason_accept_flag, import_data->list[d.seq].
     restricted_actions_bitmask = validate(pc.restricted_actions_bitmask,0),
     import_data->list[d.seq].open_by_default_ind = validate(pc.open_by_default_ind,0), faccnt = 0
    DETAIL
     faccnt = (faccnt+ 1)
     IF (mod(faccnt,10)=1)
      stat = alterlist(import_data->list[d.seq].fac_list,(faccnt+ 9))
     ENDIF
     import_data->list[d.seq].fac_list[faccnt].facility_cd = pcf.parent_entity_id
    FOOT  pc.pathway_catalog_id
     IF (mod(faccnt,10) != 0)
      stat = alterlist(import_data->list[d.seq].fac_list,faccnt)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    pc.pathway_catalog_id
    FROM (dummyt d  WITH seq = value(size(import_data->list,5))),
     pathway_catalog pc
    PLAN (d)
     JOIN (pc
     WHERE pc.description_key=cnvtupper(import_data->list[d.seq].new_description)
      AND ((pc.type_mean IN ("PATHWAY", "CAREPLAN")) OR (nullind(pc.type_mean)=1))
      AND pc.end_effective_dt_tm=cnvtdatetime("31-DEC-2100")
      AND (pc.pathway_catalog_id != import_data->list[d.seq].pathway_catalog_id)
      AND pc.ref_owner_person_id=0)
    DETAIL
     errorcnt = (errorcnt+ 1), import_data->list[d.seq].duplicate_ind = 1, import_data->list[d.seq].
     dup_pathway_catalog_id = pc.pathway_catalog_id,
     import_data->list[d.seq].error_str = error_plan_dup
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    pc.pathway_catalog_id, name = trim(pr.name_full_formatted)
    FROM (dummyt d  WITH seq = value(size(import_data->list,5))),
     pathway_catalog pc,
     prsnl pr
    PLAN (d)
     JOIN (pc
     WHERE pc.description_key=cnvtupper(import_data->list[d.seq].new_description)
      AND pc.type_mean IN ("CAREPLAN", "TAPERPLAN")
      AND (pc.pathway_catalog_id != import_data->list[d.seq].pathway_catalog_id)
      AND pc.active_ind=1
      AND pc.ref_owner_person_id != 0.0)
     JOIN (pr
     WHERE pr.person_id=pc.ref_owner_person_id)
    ORDER BY name
    DETAIL
     errorcnt = (errorcnt+ 1), import_data->list[d.seq].duplicate_ind = 1, import_data->list[d.seq].
     dup_pathway_catalog_id = pc.pathway_catalog_id,
     import_data->list[d.seq].owner_name = pr.name_full_formatted, import_data->list[d.seq].error_str
      = build2(error_plan_dup_prsnl,pr.name_full_formatted)
    WITH nocounter
   ;end select
   FOR (i = 1 TO size(import_data->list,5))
     IF ((import_data->list[i].pathway_catalog_id=0.0))
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_str = build2(import_data->list[i].error_str,error_plan_not_found
       )
     ENDIF
     SET planpos = i
     WHILE (planpos > 0)
      SET planpos = locateval(cnt,(planpos+ 1),size(import_data->list,5),import_data->list[i].
       new_description,import_data->list[cnt].new_description)
      IF (planpos > 0)
       IF (findstring(error_plan_dup_sheet,import_data->list[i].error_str)=0)
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_str = build2(import_data->list[i].error_str,
         error_plan_dup_sheet)
       ENDIF
       IF (findstring(error_plan_dup_sheet,import_data->list[planpos].error_str)=0)
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[planpos].error_str = build2(import_data->list[planpos].error_str,
         error_plan_dup_sheet)
       ENDIF
      ENDIF
     ENDWHILE
   ENDFOR
   IF (debug_ind=1)
    CALL addlogmsg("INFO","import_data record after being filled out by validateData()")
    CALL echorecord(import_data,logfilename,1)
    CALL addlogmsg("INFO",build2("Returning errorCnt = ",trim(cnvtstring(errorcnt)),
      " in validateData()"))
   ENDIF
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE readinputfile(filename)
   DECLARE current_plan_pos = i2 WITH protect, constant(1)
   DECLARE new_plan_pos = i2 WITH protect, constant(2)
   DECLARE str = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE piecenum = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   FREE DEFINE rtl2
   DEFINE rtl2 filename
   IF (debug_ind=1)
    CALL addlogmsg("INFO",build2("Starting to read input file: ",filename))
   ENDIF
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     cnt = 0, firstrow = 1
    DETAIL
     IF (firstrow != 1
      AND trim(piece(r.line,delim,current_plan_pos,notfnd,3)) != notfnd
      AND textlen(trim(piece(r.line,delim,current_plan_pos,notfnd,3))) > 0)
      cnt = (cnt+ 1)
      IF (mod(cnt,100)=1)
       stat = alterlist(import_data->list,(cnt+ 99))
      ENDIF
      piecenum = 1, str = ""
      WHILE (str != notfnd)
        str = piece(r.line,delim,piecenum,notfnd,3)
        CASE (piecenum)
         OF current_plan_pos:
          import_data->list[cnt].curr_description = trim(str)
         OF new_plan_pos:
          import_data->list[cnt].new_description = trim(substring(1,100,str))
        ENDCASE
        piecenum = (piecenum+ 1)
      ENDWHILE
     ELSEIF (firstrow=1
      AND trim(piece(r.line,delim,current_plan_pos,notfnd,3)) > " ")
      firstrow = 0
     ENDIF
    FOOT REPORT
     IF (mod(cnt,100) != 0)
      stat = alterlist(import_data->list,cnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL addlogmsg("INFO","import_data record after being loaded by readInputFile()")
    CALL echorecord(import_data,logfilename,1)
   ENDIF
 END ;Subroutine
 SUBROUTINE performupdates(null)
   DECLARE plancnt = i4 WITH protect
   DECLARE faccnt = i4 WITH protect
   SET trace = nocallecho
   FOR (plancnt = 1 TO size(import_data->list,5))
     CALL clear(printrow,soffcol,numcols)
     CALL text(printrow,soffcol,build2(trim(cnvtstring(plancnt))," of ",trim(cnvtstring(size(
          import_data->list,5)))))
     SET stat = initrec(dcp_request)
     SET stat = alterlist(dcp_request->planlist,1)
     SET stat = alterlist(dcp_request->planlist[1].synonymlist,1)
     SET dcp_request->version_flag = 0
     SET dcp_request->parent_cat_id = import_data->list[plancnt].pathway_catalog_id
     SET dcp_request->planlist[1].action_type = "MODIFY"
     SET dcp_request->planlist[1].pathway_catalog_id = import_data->list[plancnt].pathway_catalog_id
     SET dcp_request->planlist[1].type_mean = "CAREPLAN"
     SET dcp_request->planlist[1].active_ind = 0
     SET dcp_request->planlist[1].cross_encntr_ind = import_data->list[plancnt].cross_encntr_ind
     SET dcp_request->planlist[1].description = import_data->list[plancnt].new_description
     SET dcp_request->planlist[1].comment_remove_ind = 0
     SET dcp_request->planlist[1].comment_text_id = 0.00
     SET dcp_request->planlist[1].comment_text = ""
     SET dcp_request->planlist[1].comment_updt_cnt = 0
     SET dcp_request->planlist[1].duration_qty = import_data->list[plancnt].duration_qty
     SET dcp_request->planlist[1].duration_unit_cd = import_data->list[plancnt].duration_unit_cd
     SET dcp_request->planlist[1].pathway_type_cd = import_data->list[plancnt].pathway_type_cd
     SET dcp_request->planlist[1].display_method_cd = import_data->list[plancnt].display_method_cd
     SET dcp_request->planlist[1].updt_cnt = import_data->list[plancnt].updt_cnt
     SET dcp_request->planlist[1].comp_r_updt_flag = 0
     SET dcp_request->planlist[1].flex_parent_entity_id = 0.00
     SET dcp_request->planlist[1].display_description = import_data->list[plancnt].new_description
     SET dcp_request->planlist[1].group_updt_flag = 0
     SET dcp_request->planlist[1].sub_phase_ind = import_data->list[plancnt].sub_phase_ind
     SET dcp_request->planlist[1].hide_flexed_comp_ind = import_data->list[plancnt].
     hide_flexed_comp_ind
     SET dcp_request->planlist[1].cycle_ind = import_data->list[plancnt].cycle_ind
     SET dcp_request->planlist[1].standard_cycle_nbr = import_data->list[plancnt].standard_cycle_nbr
     SET dcp_request->planlist[1].default_view_mean = import_data->list[plancnt].default_view_mean
     SET dcp_request->planlist[1].diagnosis_capture_ind = import_data->list[plancnt].
     diagnosis_capture_ind
     SET dcp_request->planlist[1].provider_prompt_ind = import_data->list[plancnt].
     provider_prompt_ind
     SET dcp_request->planlist[1].allow_copy_forward_ind = import_data->list[plancnt].
     allow_copy_forward_ind
     SET dcp_request->planlist[1].auto_initiate_ind = import_data->list[plancnt].auto_initiate_ind
     SET dcp_request->planlist[1].alerts_on_plan_ind = import_data->list[plancnt].alerts_on_plan_ind
     SET dcp_request->planlist[1].alerts_on_plan_upd_ind = import_data->list[plancnt].
     alerts_on_plan_upd_ind
     SET dcp_request->planlist[1].cycle_begin_nbr = import_data->list[plancnt].cycle_begin_nbr
     SET dcp_request->planlist[1].cycle_end_nbr = import_data->list[plancnt].cycle_end_nbr
     SET dcp_request->planlist[1].cycle_label_cd = import_data->list[plancnt].cycle_label_cd
     SET dcp_request->planlist[1].cycle_display_end_ind = import_data->list[plancnt].
     cycle_display_end_ind
     SET dcp_request->planlist[1].cycle_lock_end_ind = import_data->list[plancnt].cycle_lock_end_ind
     SET dcp_request->planlist[1].cycle_increment_nbr = import_data->list[plancnt].
     cycle_increment_nbr
     SET dcp_request->planlist[1].default_action_inpt_future_cd = import_data->list[plancnt].
     default_action_inpt_future_cd
     SET dcp_request->planlist[1].default_action_inpt_now_cd = import_data->list[plancnt].
     default_action_inpt_now_cd
     SET dcp_request->planlist[1].default_action_outpt_future_cd = import_data->list[plancnt].
     default_action_outpt_future_cd
     SET dcp_request->planlist[1].default_action_outpt_now_cd = import_data->list[plancnt].
     default_action_outpt_now_cd
     SET dcp_request->planlist[1].optional_ind = import_data->list[plancnt].optional_ind
     SET dcp_request->planlist[1].future_ind = import_data->list[plancnt].future_ind
     SET dcp_request->planlist[1].default_visit_type_flag = import_data->list[plancnt].
     default_visit_type_flag
     SET dcp_request->planlist[1].prompt_on_selection_ind = import_data->list[plancnt].
     prompt_on_selection_ind
     SET dcp_request->planlist[1].pathway_class_cd = import_data->list[plancnt].pathway_class_cd
     SET dcp_request->planlist[1].period_nbr = import_data->list[plancnt].period_nbr
     SET dcp_request->planlist[1].period_custom_label = import_data->list[plancnt].
     period_custom_label
     SET dcp_request->planlist[1].synonymlist[1].action_flag = 3
     SET dcp_request->planlist[1].synonymlist[1].pw_cat_synonym_id = import_data->list[plancnt].
     pw_cat_synonym_id
     SET dcp_request->planlist[1].synonymlist[1].synonym_name = import_data->list[plancnt].
     new_description
     SET dcp_request->planlist[1].route_for_review_ind = import_data->list[plancnt].
     route_for_review_ind
     SET dcp_request->planlist[1].default_start_time_txt = import_data->list[plancnt].
     default_start_time_txt
     SET dcp_request->planlist[1].primary_ind = import_data->list[plancnt].primary_ind
     SET dcp_request->planlist[1].uuid = import_data->list[plancnt].uuid
     SET dcp_request->planlist[1].reschedule_reason_accept_flag = import_data->list[plancnt].
     reschedule_reason_accept_flag
     SET dcp_request->remove_plan_reltn_ind = 0
     SET dcp_request->problem_diag_updt_flag = 0
     SET stat = alterlist(dcp_request->facilityflexlist,size(import_data->list[plancnt].fac_list,5))
     FOR (faccnt = 1 TO size(import_data->list[plancnt].fac_list,5))
       SET dcp_request->facilityflexlist[faccnt].facility_cd = import_data->list[plancnt].fac_list[
       faccnt].facility_cd
     ENDFOR
     IF (debug_ind=1)
      CALL addlogmsg("INFO","dcp_request record after being loaded by performUpdates()")
      CALL addlogmsg("INFO",build2(trim(cnvtstring(plancnt))," of ",trim(cnvtstring(size(import_data
           ->list,5)))))
      CALL echorecord(dcp_request,logfilename,1)
     ENDIF
     EXECUTE dcp_upd_plan_catalog  WITH replace("REQUEST",dcp_request), replace("REPLY",dcp_reply)
     IF (debug_ind=1)
      CALL addlogmsg("INFO","dcp_reply record after dcp_upd_plan_catalog in performUpdates()")
      CALL echorecord(dcp_reply,logfilename,1)
     ENDIF
     IF ((dcp_reply->status_data.status != "S"))
      SET trace = callecho
      SET status = "F"
      SET statusstr = "Error encountered in dcp_upd_plan_catalog"
      GO TO exit_script
     ENDIF
   ENDFOR
   SET trace = callecho
   SET stat = incrementimportcount(size(import_data->list,5))
   IF (stat=0)
    SET status = "F"
    SET statusstr = "Error encountered in incrementImportCount() incrementing count"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE createerrorcsv(filename)
   SELECT INTO value(filename)
    error_message = substring(1,1000,import_data->list[d1.seq].error_str), current_plan_name =
    substring(1,1000,import_data->list[d1.seq].curr_description), new_plan_name = substring(1,1000,
     import_data->list[d1.seq].new_description)
    FROM (dummyt d1  WITH seq = value(size(import_data->list,5)))
    PLAN (d1)
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
 END ;Subroutine
 SUBROUTINE blankfilemode(null)
   DECLARE blankfilename = vc WITH protect, noconstant("inactivate_powerplans_template.csv")
   CALL clearscreen(null)
   SET done = 0
   WHILE (done=0)
     CALL text(soffrow,soffcol,"Enter blank template filename:")
     CALL accept((soffrow+ 1),(soffcol+ 1),"P(74);C",blankfilename)
     IF (cnvtupper(curaccept)="*.CSV*")
      CALL clear((soffrow+ 2),soffcol,numcols)
      SET done = 1
      SET blankfilename = trim(cnvtlower(curaccept))
      SELECT INTO value(blankfilename)
       current_plan_name = "", new_plan_name = ""
       FROM (dummyt d1  WITH seq = 1)
       PLAN (d1)
       WITH format = stream, pcformat('"',delim,1), format
      ;end select
      CALL text((soffrow+ 2),soffcol,"Do you want to email the file?:")
      CALL accept((soffrow+ 2),(soffcol+ 31),"A;CU","Y"
       WHERE curaccept IN ("Y", "N"))
      IF (curaccept="Y")
       CALL text((soffrow+ 3),soffcol,"Enter recepient's email address:")
       CALL accept((soffrow+ 4),(soffcol+ 1),"P(74);C",gethnaemail(null)
        WHERE trim(curaccept)="*@*.*")
       IF (emailfile(curaccept,from_str,"","",blankfilename))
        CALL text((soffrow+ 14),soffcol,"Emailed file successfully")
       ELSE
        CALL text((soffrow+ 14),soffcol,emailfailstr)
       ENDIF
       CALL text(quesrow,soffcol,"Continue?:")
       CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
        WHERE curaccept IN ("Y"))
      ENDIF
     ELSEIF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ELSE
      CALL text((soffrow+ 9),soffcol,"File must have .csv extension")
     ENDIF
   ENDWHILE
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE getcustomizedplans(null)
   DECLARE retval = i4 WITH protect
   DECLARE ownercnt = i4 WITH protect
   DECLARE custplancnt = i4 WITH protect
   FOR (i = 1 TO size(import_data->list,5))
     SET custom_plan_request->pathway_catalog_id = import_data->list[i].pathway_catalog_id
     IF (debug_ind=1)
      CALL addlogmsg("INFO",build2(
        "inside getCustomizedPlans() calling server for pathway_catalog_id = ",trim(cnvtstring(
          import_data->list[i].pathway_catalog_id))))
     ENDIF
     SET stat = tdbexecute(600030,3202004,601472,"REC",custom_plan_request,
      "REC",custom_plan_reply)
     IF (stat=0)
      IF ((custom_plan_reply->status_data.status="S"))
       FOR (ownercnt = 1 TO size(custom_plan_reply->owners,5))
         FOR (custplancnt = 1 TO size(custom_plan_reply->owners[ownercnt].customized_plans,5))
           SET retval = (retval+ 1)
           IF (mod(retval,100)=1)
            SET stat = alterlist(updt_custom_plan_request->customized_plans,(retval+ 99))
           ENDIF
           SET updt_custom_plan_request->customized_plans[retval].pathway_customized_plan_id =
           custom_plan_reply->owners[ownercnt].customized_plans[custplancnt].
           pathway_customized_plan_id
         ENDFOR
       ENDFOR
      ELSEIF ((custom_plan_reply->status_data.status="F"))
       SET status = "F"
       SET statusstr = build2("Error finding customized plans for pathway_catalog_id: ",
        custom_plan_request->pathway_catalog_id)
       GO TO exit_script
      ENDIF
     ELSE
      SET status = "F"
      SET statusstr = "Error encountered calling QueryRelatedCustomizedPlans"
      GO TO exit_script
     ENDIF
   ENDFOR
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE updatecustomizedplans(null)
   IF (debug_ind=1)
    CALL addlogmsg("INFO","updt_custom_plan_request inside updateCustomizedPlans()")
    CALL echorecord(updt_custom_plan_request,logfilename,1)
   ENDIF
   SET updt_custom_plan_request->status_flag = 3
   SET stat = tdbexecute(600030,3202004,601421,"REC",updt_custom_plan_request,
    "REC",updt_custom_plan_reply)
   IF (stat=0)
    IF ((updt_custom_plan_reply->status_data.status="F"))
     SET status = "F"
     SET statusstr = "Error updating customized plans"
     GO TO exit_script
    ENDIF
   ELSE
    SET status = "F"
    SET statusstr = "Error encountered calling ChangeCustomizePlanStatuses"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE incrementimportcount(inccnt)
   DECLARE pref_domain = c11 WITH protect, constant("AMS_TOOLKIT")
   DECLARE retval = i2 WITH noconstant(0), protect
   DECLARE found = i2 WITH noconstant(0), protect
   DECLARE infonbr = i4 WITH protect
   DECLARE lastupdt = dq8 WITH protect
   DECLARE infodetail = vc WITH protect, constant(
    "Total number of PowerPlans inactivated by program:")
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=pref_domain
     AND d.info_name=script_name
    DETAIL
     found = 1, infonbr = (d.info_number+ inccnt), lastupdt = d.updt_dt_tm
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = pref_domain, d.info_name = script_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = inccnt, d.info_char = trim(infodetail), d.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      d.updt_cnt = 0, d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
     WITH nocounter
    ;end insert
    IF (curqual=1)
     SET retval = 1
    ENDIF
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = infonbr, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = (d
      .updt_cnt+ 1),
      d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
     WHERE d.info_domain=pref_domain
      AND d.info_name=script_name
     WITH nocounter
    ;end update
    IF (curqual=1)
     SET retval = 1
    ENDIF
   ENDIF
   RETURN(retval)
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF (status="F")
  ROLLBACK
  CALL echo(statusstr)
 ENDIF
 IF (debug_ind=1)
  CALL addlogmsg("ERROR",statusstr)
  CALL createlogfile(logfilename)
 ENDIF
 SET last_mod = "000"
END GO
