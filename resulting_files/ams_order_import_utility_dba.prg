CREATE PROGRAM ams_order_import_utility:dba
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
 DECLARE importmode(null) = null WITH protect
 DECLARE blankfilemode(null) = null WITH protect
 DECLARE readinputfile(filename=vc) = null WITH protect
 DECLARE validatedata(null) = i4 WITH protect
 DECLARE processvirtualviews(vvstr=vc,pos=i4) = null WITH protect
 DECLARE getfacilitycd(disp=vc) = f8 WITH protect
 DECLARE createerrorcsv(filename=vc) = null WITH protect
 DECLARE performupdates(null) = null WITH protect
 DECLARE incrementimportcount(inccnt=i4) = i2 WITH protect
 DECLARE createblankimportfile(filename=vc) = null WITH protect
 DECLARE title_line = c75 WITH protect, constant(
  "                          AMS Order Import Utility                          ")
 DECLARE detail_line = c75 WITH protect, constant(
  "                         Create new shell orderables                        ")
 DECLARE script_name = c24 WITH protect, constant("AMS_ORDER_IMPORT_UTILITY")
 DECLARE from_str = vc WITH protect, constant("ams_order_import_utility@cerner.com")
 DECLARE delim = vc WITH protect, constant(",")
 DECLARE syn_type_primary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE ord_cat_contributor_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13016,"ORD CAT"
   ))
 DECLARE error_syn_dup_sheet = vc WITH protect, constant(
  "Synonym exists multiple times in import sheet. ")
 DECLARE error_dup_prim_mnemonic = vc WITH protect, constant(
  "Orderable already exists in the order catalog. ")
 DECLARE error_dup_synonym = vc WITH protect, constant(
  "Synonym already exists in the order catalog. ")
 DECLARE error_invalid_catalog_type = vc WITH protect, constant("Catalog Type not found. ")
 DECLARE error_invalid_activity_type = vc WITH protect, constant("Activity Type not found. ")
 DECLARE error_invalid_oef = vc WITH protect, constant("Order Entry Format not found. ")
 DECLARE error_invalid_orderable_type = vc WITH protect, constant("Orderable Type is not valid. ")
 DECLARE error_invalid_clinical_category = vc WITH protect, constant("Clinical Category not found. ")
 DECLARE logfilename = vc WITH protect, noconstant(" ")
 DECLARE errorfilename = vc WITH protect, noconstant(" ")
 DECLARE errorcnt = i4 WITH protect
 DECLARE emailfailstr = vc WITH protect, constant("Email failed. Manually grab file from CCLUSERDIR")
 DECLARE synpos = i4 WITH protect
 SET logfilename = concat("ams_order_import_utility_",cnvtlower(format(cnvtdatetime(curdate,curtime3),
    "dd_mmm_yyyy_hh_mm;;q")),".log")
 SET errorfilename = cnvtlower(concat(getclient(null),"_",trim(curdomain),"_orderable_errors.csv"))
 RECORD import_data(
   1 list[*]
     2 error_str = vc
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 description = vc
     2 mnemonic = vc
     2 oe_format_id = f8
     2 oe_format_disp = vc
     2 hide_flag = i2
     2 fac_list[*]
       3 facility_cd = f8
       3 facility_disp = vc
     2 complete_upon_order_ind = i2
     2 auto_cancel_ind = i2
     2 disable_order_comment_ind = i2
     2 bill_only_ind = i2
     2 orderable_type_flag = i2
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_cat_disp = vc
 ) WITH protect
 RECORD orm_request(
   1 stop_type_cd = f8
   1 stop_duration = i2
   1 stop_duration_unit_cd = f8
   1 ic_auto_verify_flag = i2
   1 discern_auto_verify_flag = i2
   1 ref_text_mask = i4
   1 cki = c255
   1 auto_cancel_ind = i2
   1 setup_time = i2
   1 cleanup_time = i2
   1 consent_form_ind = i2
   1 modifiable_flag = i2
   1 active_ind = i2
   1 catalog_type_cd = f8
   1 dcp_clin_cat_cd = f8
   1 activity_type_cd = f8
   1 activity_subtype_cd = f8
   1 requisition_format_cd = f8
   1 requisition_routing_cd = f8
   1 inst_restriction_ind = i2
   1 schedule_ind = i2
   1 description = c100
   1 iv_ingredient_ind = i2
   1 print_req_ind = i2
   1 oe_format_id = f8
   1 orderable_type_flag = i2
   1 complete_upon_order_ind = i2
   1 quick_chart_ind = i2
   1 comment_template_flag = i2
   1 prep_info_flag = i2
   1 dup_checking_ind = i2
   1 order_review_ind = i2
   1 bill_only_ind = i2
   1 cont_order_method_flag = i2
   1 consent_form_format_cd = f8
   1 consent_form_routing_cd = f8
   1 dc_display_days = i4
   1 dc_interaction_days = i4
   1 mdx_gcr_id = f8
   1 form_id = f8
   1 form_level = i4
   1 disable_order_comment_ind = i2
   1 orc_text = vc
   1 mnemonic_cnt = i4
   1 qual_mnemonic[*]
     2 mnemonic = c100
     2 cki = c255
     2 ref_text_mask = i4
     2 rx_mask = i4
     2 mnemonic_type_cd = f8
     2 order_sentence_id = f8
     2 active_ind = i2
     2 ing_rate_conversion_ind = i2
     2 orderable_type_flag = i2
     2 hide_flag = i2
     2 virtual_view = vc
     2 oe_format_id = f8
     2 concentration_strength = f8
     2 concentration_strength_unit_cd = f8
     2 concentration_volume = f8
     2 concentration_volume_unit_cd = f8
     2 health_plan_view = c255
     2 witness_flag = i2
     2 high_alert_ind = i2
     2 high_alert_long_text = vc
     2 high_alert_notify_ind = i2
     2 qual_facility[*]
       3 facility_cd = f8
     2 intermittent_ind = i2
     2 display_additives_first_ind = i2
     2 rounding_rule_cd = f8
   1 review_cnt = i4
   1 qual_review[*]
     2 action_type_cd = f8
     2 nurse_review_flag = i2
     2 doctor_cosign_flag = i2
     2 rx_verify_flag = i2
   1 surgical_proc_ind = i2
   1 def_proc_dur = i4
   1 def_wound_class_cd = f8
   1 def_case_level_cd = f8
   1 spec_req_ind = i2
   1 frozen_section_req_ind = i2
   1 def_anesth_type_cd = f8
   1 surg_specialty_id = f8
   1 dup_cnt = i4
   1 qual_dup[*]
     2 dup_check_seq = i4
     2 exact_hit_action_cd = f8
     2 min_behind = i4
     2 min_behind_action_cd = f8
     2 min_ahead = i4
     2 min_ahead_action_cd = f8
     2 active_ind = i2
     2 outpat_exact_hit_action_cd = f8
     2 outpat_min_behind = i4
     2 outpat_min_behind_action_cd = f8
     2 outpat_min_ahead = i4
     2 outpat_min_ahead_action_cd = f8
     2 outpat_flex_ind = i2
   1 dept_disp_name = vc
   1 vetting_approval_flag = i2
 ) WITH protect
 RECORD orm_reply(
   1 ockey = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD request(
   1 nbr_of_recs = i2
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 ext_owner_cd = f8
     2 ext_description = c100
     2 ext_short_desc = c50
     2 build_ind = i2
     2 careset_ind = i2
     2 workload_only_ind = i2
     2 child_qual = i2
     2 price_qual = i2
     2 prices[*]
       3 price_sched_id = f8
       3 price = f8
     2 billcode_qual = i2
     2 billcodes[*]
       3 billcode_sched_cd = f8
       3 billcode = c25
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
       3 ext_description = c100
       3 ext_short_desc = c50
       3 build_ind = i2
       3 ext_owner_cd = f8
   1 logical_domain_id = f8
   1 logical_domain_enabled_ind = i2
 ) WITH protect
 RECORD reply(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
   1 qual[*]
     2 bill_item_id = f8
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 price_sched_id = f8
     2 price_sched_items_id = f8
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[10]
     2 bill_item_mod_id = f8
   1 actioncnt = i2
   1 actionlist[*]
     2 action1 = vc
     2 action2 = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c20
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 ) WITH protect
 CALL validatelogin(null)
 IF (debug_ind=1)
  CALL addlogmsg("INFO","Beginning ams_order_import_utility")
 ENDIF
 SET status = "S"
#main_menu
 CALL drawmenu(title_line,detail_line,"")
 CALL text((soffrow+ 5),(soffcol+ 26),"1 Import orderables")
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
   CALL clearscreen(null)
   SET stat = initrec(import_data)
   WHILE (done=0)
     CALL text(soffrow,soffcol,"Enter filename to read orders from:")
     CALL accept((soffrow+ 1),(soffcol+ 1),"P(74);C")
     IF (cnvtupper(curaccept)="*.CSV*")
      CALL clear((soffrow+ 2),soffcol,numcols)
      SET stat = findfile(curaccept)
      IF (stat=1)
       CALL clear((soffrow+ 2),soffcol,numcols)
       SET done = 1
       CALL text((soffrow+ 2),soffcol,"Reading orders from file...")
       CALL readinputfile(curaccept)
       CALL text((soffrow+ 2),(soffcol+ 27),"done")
       CALL text((soffrow+ 3),soffcol,"Checking for invalid orderables...")
       SET errorcnt = validatedata(null)
       IF (errorcnt=0)
        CALL text((soffrow+ 3),(soffcol+ 34),"done")
        CALL text((soffrow+ 4),soffcol,"Importing orderables...")
        CALL performupdates(null)
        CALL text((soffrow+ 4),(soffcol+ 23),"done")
        CALL text(quesrow,soffcol,"Commit?:")
        CALL accept(quesrow,(soffcol+ 8),"A;CU"
         WHERE curaccept IN ("Y", "N"))
        IF (curaccept="Y")
         COMMIT
        ELSE
         ROLLBACK
        ENDIF
       ELSE
        CALL text((soffrow+ 4),soffcol,
         "Error(s) found. At least one of the orderables in the file has an error.")
        SET done = 0
        WHILE (done=0)
          CALL text((soffrow+ 6),soffcol,"Enter filename to export errors to:")
          CALL accept((soffrow+ 7),(soffcol+ 1),"P(74);C",errorfilename)
          IF (cnvtupper(curaccept)="*.CSV*")
           CALL clear((soffrow+ 8),soffcol,numcols)
           SET done = 1
           SET errorfilename = trim(cnvtlower(curaccept))
           CALL createerrorcsv(errorfilename)
           CALL text((soffrow+ 8),soffcol,"Do you want to email the file?:")
           CALL accept((soffrow+ 8),(soffcol+ 31),"A;CU","Y"
            WHERE curaccept IN ("Y", "N"))
           IF (curaccept="Y")
            CALL text((soffrow+ 9),soffcol,"Enter recepient's email address:")
            CALL accept((soffrow+ 10),(soffcol+ 1),"P(74);C",gethnaemail(null)
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
       CALL text((soffrow+ 2),soffcol,
        "File not found. Make sure file exists in CCLUSERDIR or include logical.")
      ENDIF
     ELSEIF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ELSE
      CALL text((soffrow+ 2),soffcol,"File must have .csv extension")
     ENDIF
   ENDWHILE
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE blankfilemode(null)
   DECLARE blankfilename = vc WITH protect, noconstant("new_orders_template.csv")
   CALL clearscreen(null)
   SET done = 0
   WHILE (done=0)
     CALL text(soffrow,soffcol,"Enter blank template filename:")
     CALL accept((soffrow+ 1),(soffcol+ 1),"P(74);C",blankfilename)
     IF (cnvtupper(curaccept)="*.CSV*")
      CALL clear((soffrow+ 2),soffcol,numcols)
      SET done = 1
      SET blankfilename = trim(cnvtlower(curaccept))
      CALL createblankimportfile(blankfilename)
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
 SUBROUTINE readinputfile(filename)
   DECLARE catalog_type_pos = i2 WITH protect
   DECLARE activity_type_pos = i2 WITH protect
   DECLARE description_pos = i2 WITH protect
   DECLARE mnemonic_pos = i2 WITH protect
   DECLARE oef_pos = i2 WITH protect
   DECLARE hide_flag_pos = i2 WITH protect
   DECLARE virtual_view_pos = i2 WITH protect
   DECLARE complete_pos = i2 WITH protect
   DECLARE cancel_on_disch_pos = i2 WITH protect
   DECLARE disable_ord_comment_pos = i2 WITH protect
   DECLARE bill_only_pos = i2 WITH protect
   DECLARE orderable_type_pos = i2 WITH protect
   DECLARE clinical_category_pos = i2 WITH protect
   DECLARE header_catalog_type = vc WITH protect, constant("CATALOG")
   DECLARE header_activity_type = vc WITH protect, constant("ACTIVITY")
   DECLARE header_description = vc WITH protect, constant("DESCRIPTION")
   DECLARE header_mnemonic = vc WITH protect, constant("SYNONYM")
   DECLARE header_oef = vc WITH protect, constant("FORMAT")
   DECLARE header_hide_flag = vc WITH protect, constant("HIDE")
   DECLARE header_virtual_view = vc WITH protect, constant("VIRTUAL")
   DECLARE header_complete = vc WITH protect, constant("COMPLETE")
   DECLARE header_cancel_on_disch = vc WITH protect, constant("CANCEL")
   DECLARE header_disable_ord_comment = vc WITH protect, constant("DISABLE")
   DECLARE header_bill_only = vc WITH protect, constant("BILL")
   DECLARE header_orderable_type = vc WITH protect, constant("ORDERABLE")
   DECLARE header_clinical_category = vc WITH protect, constant("CLINICAL")
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
      AND trim(piece(r.line,delim,catalog_type_pos,notfnd,3)) != notfnd
      AND textlen(trim(piece(r.line,delim,catalog_type_pos,notfnd,3))) > 0
      AND status != "F")
      cnt = (cnt+ 1)
      IF (mod(cnt,100)=1)
       stat = alterlist(import_data->list,(cnt+ 99))
      ENDIF
      piecenum = 1, str = ""
      WHILE (str != notfnd)
        str = piece(r.line,delim,piecenum,notfnd,3)
        CASE (piecenum)
         OF catalog_type_pos:
          import_data->list[cnt].catalog_type_disp = trim(str)
         OF activity_type_pos:
          import_data->list[cnt].activity_type_disp = trim(str)
         OF description_pos:
          import_data->list[cnt].description = trim(str)
         OF mnemonic_pos:
          import_data->list[cnt].mnemonic = trim(str)
         OF oef_pos:
          import_data->list[cnt].oe_format_disp = trim(str)
         OF hide_flag_pos:
          import_data->list[cnt].hide_flag = evaluate(cnvtupper(trim(str)),"YES",1,0)
         OF virtual_view_pos:
          CALL processvirtualviews(str,cnt)
         OF complete_pos:
          import_data->list[cnt].complete_upon_order_ind = evaluate(cnvtupper(trim(str)),"YES",1,0)
         OF cancel_on_disch_pos:
          import_data->list[cnt].auto_cancel_ind = evaluate(cnvtupper(trim(str)),"YES",1,0)
         OF disable_ord_comment_pos:
          import_data->list[cnt].disable_order_comment_ind = evaluate(cnvtupper(trim(str)),"YES",1,0)
         OF bill_only_pos:
          import_data->list[cnt].bill_only_ind = evaluate(cnvtupper(trim(str)),"YES",1,0)
         OF orderable_type_pos:
          IF (cnvtupper(trim(str))="DEPT*")
           import_data->list[cnt].orderable_type_flag = 5
          ELSEIF (cnvtupper(trim(str))="FREE*")
           import_data->list[cnt].orderable_type_flag = 10
          ELSEIF (cnvtupper(trim(str))="NORMAL*")
           import_data->list[cnt].orderable_type_flag = 0
          ELSE
           import_data->list[cnt].orderable_type_flag = - (1)
          ENDIF
         OF clinical_category_pos:
          import_data->list[cnt].dcp_clin_cat_disp = trim(str)
        ENDCASE
        piecenum = (piecenum+ 1)
      ENDWHILE
     ELSEIF (firstrow=1
      AND trim(piece(r.line,delim,1,notfnd,3)) > " ")
      firstrow = 0, piecenum = 1, str = ""
      WHILE (str != cnvtupper(notfnd))
        str = cnvtupper(piece(r.line,delim,piecenum,notfnd,3))
        IF (findstring(header_catalog_type,str))
         catalog_type_pos = piecenum
        ELSEIF (findstring(header_activity_type,str))
         activity_type_pos = piecenum
        ELSEIF (findstring(header_description,str))
         description_pos = piecenum
        ELSEIF (findstring(header_mnemonic,str))
         mnemonic_pos = piecenum
        ELSEIF (findstring(header_oef,str))
         oef_pos = piecenum
        ELSEIF (findstring(header_hide_flag,str))
         hide_flag_pos = piecenum
        ELSEIF (findstring(header_virtual_view,str))
         virtual_view_pos = piecenum
        ELSEIF (findstring(header_complete,str))
         complete_pos = piecenum
        ELSEIF (findstring(header_cancel_on_disch,str))
         cancel_on_disch_pos = piecenum
        ELSEIF (findstring(header_disable_ord_comment,str))
         disable_ord_comment_pos = piecenum
        ELSEIF (findstring(header_bill_only,str))
         bill_only_pos = piecenum
        ELSEIF (findstring(header_orderable_type,str))
         orderable_type_pos = piecenum
        ELSEIF (findstring(header_clinical_category,str))
         clinical_category_pos = piecenum
        ENDIF
        piecenum = (piecenum+ 1)
      ENDWHILE
      IF (catalog_type_pos=0)
       status = "F", statusstr = build2(statusstr,"Catalog type header not found. ")
      ELSEIF (activity_type_pos=0)
       status = "F", statusstr = build2(statusstr,"Activity type header not found. ")
      ELSEIF (description_pos=0)
       status = "F", statusstr = build2(statusstr,"Description header not found. ")
      ELSEIF (mnemonic_pos=0)
       status = "F", statusstr = build2(statusstr,"Synonym header not found. ")
      ELSEIF (oef_pos=0)
       status = "F", statusstr = build2(statusstr,"Order entry format header not found. ")
      ELSEIF (hide_flag_pos=0)
       status = "F", statusstr = build2(statusstr,"Hide flag header not found. ")
      ELSEIF (virtual_view_pos=0)
       status = "F", statusstr = build2(statusstr,"Virtual view header not found. ")
      ELSEIF (complete_pos=0)
       status = "F", statusstr = build2(statusstr,"Complete on order header not found. ")
      ELSEIF (cancel_on_disch_pos=0)
       status = "F", statusstr = build2(statusstr,"Cancel order upon discharge header not found. ")
      ELSEIF (disable_ord_comment_pos=0)
       status = "F", statusstr = build2(statusstr,"Disable order comment header not found. ")
      ELSEIF (bill_only_pos=0)
       status = "F", statusstr = build2(statusstr,"Bill only orderable header not found. ")
      ELSEIF (orderable_type_pos=0)
       status = "F", statusstr = build2(statusstr,"Orderable type header not found. ")
      ELSEIF (clinical_category_pos=0)
       status = "F", statusstr = build2(statusstr,"Clinical category header not found. ")
      ENDIF
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
   IF (status="F")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE processvirtualviews(vvstr,pos)
   DECLARE faccnt = i4 WITH protect
   DECLARE str = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE piecenum = i4 WITH protect
   IF (debug_ind=1)
    CALL addlogmsg("INFO","Inside processVirtualViews()")
    CALL addlogmsg("INFO",build2("pos = ",trim(cnvtstring(pos))))
    CALL addlogmsg("INFO",build2("vvStr = ",vvstr))
   ENDIF
   IF (cnvtupper(trim(vvstr))="ALL")
    SET faccnt = 1
    SET stat = alterlist(import_data->list[pos].fac_list,faccnt)
    SET import_data->list[pos].fac_list[faccnt].facility_cd = 0.0
    SET import_data->list[pos].fac_list[faccnt].facility_disp = vvstr
   ELSEIF (findstring(delim,trim(vvstr)) > 0)
    SET piecenum = 1
    SET str = ""
    WHILE (str != notfnd)
     SET str = piece(vvstr,delim,piecenum,notfnd,3)
     IF (str != notfnd)
      SET faccnt = (faccnt+ 1)
      SET stat = alterlist(import_data->list[pos].fac_list,faccnt)
      SET import_data->list[pos].fac_list[faccnt].facility_disp = trim(str)
      SET piecenum = (piecenum+ 1)
     ENDIF
    ENDWHILE
   ELSEIF (((cnvtupper(trim(vvstr))="NONE") OR (cnvtupper(trim(vvstr))="")) )
    SET faccnt = 0
   ELSE
    SET faccnt = 1
    SET stat = alterlist(import_data->list[pos].fac_list,faccnt)
    SET import_data->list[pos].fac_list[faccnt].facility_disp = vvstr
   ENDIF
 END ;Subroutine
 SUBROUTINE validatedata(null)
   DECLARE errorcnt = i4 WITH protect
   DECLARE faccd = f8 WITH protect
   DECLARE j = i4 WITH protect
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(import_data->list,5))),
     code_value cv
    PLAN (d)
     JOIN (cv
     WHERE cv.code_set=6000
      AND cv.active_ind=1
      AND cv.display_key=cnvtalphanum(cnvtupper(import_data->list[d.seq].catalog_type_disp)))
    DETAIL
     import_data->list[d.seq].catalog_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(import_data->list,5))),
     code_value cv
    PLAN (d)
     JOIN (cv
     WHERE cv.code_set=106
      AND cv.active_ind=1
      AND cv.display_key=cnvtalphanum(cnvtupper(import_data->list[d.seq].activity_type_disp)))
    DETAIL
     import_data->list[d.seq].activity_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(import_data->list,5))),
     code_value cv
    PLAN (d)
     JOIN (cv
     WHERE cv.code_set=16389
      AND cv.active_ind=1
      AND cv.display_key=cnvtalphanum(cnvtupper(import_data->list[d.seq].dcp_clin_cat_disp)))
    DETAIL
     import_data->list[d.seq].dcp_clin_cat_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(import_data->list,5))),
     order_catalog oc
    PLAN (d)
     JOIN (oc
     WHERE (oc.primary_mnemonic=import_data->list[d.seq].mnemonic))
    DETAIL
     errorcnt = (errorcnt+ 1), import_data->list[d.seq].error_str = build2(import_data->list[d.seq].
      error_str,error_dup_prim_mnemonic)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(import_data->list,5))),
     order_catalog_synonym ocs
    PLAN (d)
     JOIN (ocs
     WHERE ocs.mnemonic_key_cap=cnvtupper(import_data->list[d.seq].mnemonic)
      AND ocs.mnemonic_type_cd=syn_type_primary_cd)
    DETAIL
     errorcnt = (errorcnt+ 1), import_data->list[d.seq].error_str = build2(import_data->list[d.seq].
      error_str,error_dup_synonym)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(import_data->list,5))),
     order_entry_format_parent oefp
    PLAN (d)
     JOIN (oefp
     WHERE (oefp.catalog_type_cd=import_data->list[d.seq].catalog_type_cd)
      AND cnvtupper(oefp.oe_format_name)=cnvtupper(import_data->list[d.seq].oe_format_disp))
    DETAIL
     import_data->list[d.seq].oe_format_id = oefp.oe_format_id
    WITH nocounter
   ;end select
   FOR (i = 1 TO size(import_data->list,5))
     SET synpos = i
     WHILE (synpos > 0)
      SET synpos = locateval(cnt,(synpos+ 1),size(import_data->list,5),import_data->list[i].mnemonic,
       import_data->list[cnt].mnemonic)
      IF (synpos > 0)
       IF (findstring(error_syn_dup_sheet,import_data->list[i].error_str)=0)
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[i].error_str = build2(import_data->list[i].error_str,
         error_syn_dup_sheet)
       ENDIF
       IF (findstring(error_syn_dup_sheet,import_data->list[synpos].error_str)=0)
        SET errorcnt = (errorcnt+ 1)
        SET import_data->list[synpos].error_str = build2(import_data->list[synpos].error_str,
         error_syn_dup_sheet)
       ENDIF
      ENDIF
     ENDWHILE
     IF ((import_data->list[i].catalog_type_cd=0.0))
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_str = build2(import_data->list[i].error_str,
       error_invalid_catalog_type)
     ENDIF
     IF ((import_data->list[i].activity_type_cd=0.0))
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_str = build2(import_data->list[i].error_str,
       error_invalid_activity_type)
     ENDIF
     IF ((import_data->list[i].dcp_clin_cat_cd=0.0)
      AND textlen(import_data->list[i].dcp_clin_cat_disp) > 0)
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_str = build2(import_data->list[i].error_str,
       error_invalid_clinical_category)
     ENDIF
     IF ((import_data->list[i].oe_format_id=0.0))
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_str = build2(import_data->list[i].error_str,error_invalid_oef)
     ENDIF
     FOR (j = 1 TO size(import_data->list[i].fac_list,5))
       IF (cnvtupper(import_data->list[i].fac_list[j].facility_disp) != "ALL")
        SET faccd = getfacilitycd(import_data->list[i].fac_list[j].facility_disp)
        IF (faccd < 0.0)
         SET errorcnt = (errorcnt+ 1)
         SET import_data->list[i].error_str = build2(import_data->list[i].error_str,"Facility ",
          import_data->list[i].fac_list[j].facility_disp," not found. ")
        ELSE
         SET import_data->list[i].fac_list[j].facility_cd = faccd
        ENDIF
       ENDIF
     ENDFOR
     IF ((import_data->list[i].orderable_type_flag=- (1)))
      SET errorcnt = (errorcnt+ 1)
      SET import_data->list[i].error_str = build2(import_data->list[i].error_str,
       error_invalid_orderable_type)
     ENDIF
   ENDFOR
   IF (debug_ind=1)
    CALL addlogmsg("INFO","import_data record after being filled out by validateData()")
    CALL echorecord(import_data,logfilename,1)
    CALL addlogmsg("INFO",build2("Returning errorCnt = ",trim(cnvtstring(errorcnt)),
      " in validateData()"))
   ENDIF
   RETURN(errorcnt)
 END ;Subroutine
 SUBROUTINE getfacilitycd(disp)
   DECLARE retval = f8 WITH noconstant(- (1.0)), protect
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="FACILITY"
     AND cv.active_ind=1
     AND cv.display=disp
     AND cv.display_key=cnvtalphanum(cnvtupper(disp))
    DETAIL
     retval = cv.code_value
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE performupdates(null)
   DECLARE ordcnt = i4 WITH protect
   SET stat = initrec(request)
   SET stat = alterlist(request->qual,size(import_data->list,5))
   SET request->nbr_of_recs = size(import_data->list,5)
   FOR (ordcnt = 1 TO size(import_data->list,5))
     CALL clear((soffrow+ 5),soffcol,numcols)
     CALL text((soffrow+ 5),soffcol,build2(trim(cnvtstring(ordcnt))," of ",trim(cnvtstring(size(
          import_data->list,5)))))
     SET stat = initrec(orm_request)
     SET stat = alterlist(orm_request->qual_mnemonic,1)
     SET stat = alterlist(orm_request->qual_mnemonic[1].qual_facility,size(import_data->list[ordcnt].
       fac_list,5))
     SET orm_request->catalog_type_cd = import_data->list[ordcnt].catalog_type_cd
     SET orm_request->activity_type_cd = import_data->list[ordcnt].activity_type_cd
     SET orm_request->description = import_data->list[ordcnt].description
     SET orm_request->active_ind = 1
     SET orm_request->complete_upon_order_ind = import_data->list[ordcnt].complete_upon_order_ind
     SET orm_request->auto_cancel_ind = import_data->list[ordcnt].auto_cancel_ind
     SET orm_request->disable_order_comment_ind = import_data->list[ordcnt].disable_order_comment_ind
     SET orm_request->bill_only_ind = import_data->list[ordcnt].bill_only_ind
     SET orm_request->orderable_type_flag = import_data->list[ordcnt].orderable_type_flag
     SET orm_request->oe_format_id = import_data->list[ordcnt].oe_format_id
     SET orm_request->dcp_clin_cat_cd = import_data->list[ordcnt].dcp_clin_cat_cd
     SET orm_request->mnemonic_cnt = 1
     SET orm_request->qual_mnemonic[1].mnemonic = import_data->list[ordcnt].mnemonic
     SET orm_request->qual_mnemonic[1].mnemonic_type_cd = syn_type_primary_cd
     SET orm_request->qual_mnemonic[1].active_ind = 1
     SET orm_request->qual_mnemonic[1].hide_flag = import_data->list[ordcnt].hide_flag
     SET orm_request->qual_mnemonic[1].oe_format_id = import_data->list[ordcnt].oe_format_id
     FOR (j = 1 TO size(import_data->list[ordcnt].fac_list,5))
       SET orm_request->qual_mnemonic[1].qual_facility[j].facility_cd = import_data->list[ordcnt].
       fac_list[j].facility_cd
     ENDFOR
     IF (debug_ind=1)
      CALL addlogmsg("INFO","orm_request record after being loaded by performUpdates()")
      CALL addlogmsg("INFO",build2(trim(cnvtstring(ordcnt))," of ",trim(cnvtstring(size(import_data->
           list,5)))))
      CALL echorecord(orm_request,logfilename,1)
     ENDIF
     EXECUTE orm_add_ocentry  WITH replace("REQUEST",orm_request), replace("REPLY",orm_reply)
     IF (debug_ind=1)
      CALL addlogmsg("INFO","orm_reply record after orm_add_ocentry in performUpdates()")
      CALL echorecord(orm_reply,logfilename,1)
     ENDIF
     IF ((orm_reply->status_data.status="S"))
      SET request->qual[ordcnt].action = 0
      SET request->qual[ordcnt].ext_id = orm_reply->ockey
      SET request->qual[ordcnt].ext_contributor_cd = ord_cat_contributor_cd
      SET request->qual[ordcnt].parent_qual_ind = 1
      SET request->qual[ordcnt].ext_owner_cd = orm_request->activity_type_cd
      SET request->qual[ordcnt].ext_description = trim(orm_request->description)
      SET request->qual[ordcnt].ext_short_desc = trim(orm_request->description)
     ELSE
      SET status = "F"
      SET statusstr = "Error encountered in orm_add_ocentry"
      GO TO exit_script
     ENDIF
   ENDFOR
   IF (debug_ind=1)
    CALL addlogmsg("INFO","request record after being loaded by performUpdates()")
    CALL echorecord(request,logfilename,1)
   ENDIF
   SET trace = nocallecho
   EXECUTE afc_add_reference_api
   SET trace = callecho
   IF (debug_ind=1)
    CALL addlogmsg("INFO","reply record after afc_add_reference_api in performUpdates()")
    CALL echorecord(reply,logfilename,1)
   ENDIF
   IF ((reply->status_data.status != "S"))
    SET status = "F"
    SET statusstr = "Error encountered in afc_add_reference_api"
    GO TO exit_script
   ENDIF
   SET stat = incrementimportcount(size(import_data->list,5))
   IF (stat=0)
    SET status = "F"
    SET statusstr = "Error encountered in incrementImportCount() incrementing count"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE createerrorcsv(filename)
  SELECT INTO value(filename)
   DETAIL
    row 0, col 0, "At least one of the orderables below has an error.",
    row + 1, col 0,
    "Review the error messages and update the import sheet accordingly before running the import again."
   WITH pcformat('"',delim), maxcol = 20000, maxrow = 1
  ;end select
  SELECT INTO value(filename)
   error_message = substring(1,1000,import_data->list[d1.seq].error_str), catalog_type = substring(1,
    1000,import_data->list[d1.seq].catalog_type_disp), activity_type = substring(1,1000,import_data->
    list[d1.seq].activity_type_disp),
   description = substring(1,1000,import_data->list[d1.seq].description), synonym = substring(1,1000,
    import_data->list[d1.seq].mnemonic), order_entry_format = substring(1,1000,import_data->list[d1
    .seq].oe_format_disp),
   hide_flag = substring(1,1000,evaluate(import_data->list[d1.seq].hide_flag,1,"Yes","No")),
   virtual_views = substring(1,1000,import_data->list[d1.seq].fac_list[1].facility_disp),
   complete_on_order = substring(1,1000,evaluate(import_data->list[d1.seq].complete_upon_order_ind,1,
     "Yes","No")),
   cancel_order_upon_discharge = substring(1,1000,evaluate(import_data->list[d1.seq].auto_cancel_ind,
     1,"Yes","No")), disable_order_comment = substring(1,1000,evaluate(import_data->list[d1.seq].
     disable_order_comment_ind,1,"Yes","No")), bill_only_orderable = substring(1,1000,evaluate(
     import_data->list[d1.seq].bill_only_ind,1,"Yes","No")),
   orderable_type = substring(1,1000,evaluate(import_data->list[d1.seq].orderable_type_flag,0,
     "Normal Orderable",5,"Department Only Orderable",
     10,"Free Text Orderable")), clinical_category = substring(1,1000,import_data->list[d1.seq].
    dcp_clin_cat_disp)
   FROM (dummyt d1  WITH seq = value(size(import_data->list,5)))
   PLAN (d1)
   WITH format = stream, pcformat('"',delim,1), format
  ;end select
 END ;Subroutine
 SUBROUTINE createblankimportfile(filename)
   SELECT INTO value(filename)
    catalog_type = "", activity_type = "", description = "",
    synonym = "", order_entry_format = "", hide_flag = "",
    virtual_views = "", complete_on_order = "", cancel_order_upon_discharge = "",
    disable_order_comment = "", bill_only_orderable = "", orderable_type = "",
    clinical_category = ""
    FROM (dummyt d1  WITH seq = 1)
    PLAN (d1)
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
 END ;Subroutine
 SUBROUTINE incrementimportcount(inccnt)
   DECLARE pref_domain = c11 WITH protect, constant("AMS_TOOLKIT")
   DECLARE retval = i2 WITH noconstant(0), protect
   DECLARE found = i2 WITH noconstant(0), protect
   DECLARE infonbr = i4 WITH protect
   DECLARE lastupdt = dq8 WITH protect
   DECLARE infodetail = vc WITH protect, constant("Total number of orderables imported by program:")
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
 SET last_mod = "001"
END GO
