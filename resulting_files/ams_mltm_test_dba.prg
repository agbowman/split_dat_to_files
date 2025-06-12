CREATE PROGRAM ams_mltm_test:dba
 PAINT
 DECLARE setlogginglevel(null) = null WITH protect
 DECLARE starttimer(null) = null WITH protect
 DECLARE stoptimer(null) = f8 WITH protect
 DECLARE addmsg(smsg=vc,iprefix=i4) = null WITH protect
 DECLARE printmsgs(null) = null WITH protect
 DECLARE handleuserinput(susername=vc,safterdate=vc) = i2 WITH protect
 DECLARE lookupprsnlid(susername=vc) = f8 WITH protect
 DECLARE testvirtualviews(null) = i4 WITH protect
 DECLARE testallsynsloaded(null) = i4 WITH protect
 DECLARE loadtestcatvalues(stestcatalogname=vc) = i2 WITH protect
 DECLARE ensurenewcatalogs(ipasscnt=i4(ref),ifailcnt=i4(ref)) = i4 WITH protect
 DECLARE testcatreviewsettings(null) = i2 WITH protect
 DECLARE loadtesttaskvalues(ftestcatalogcd=f8) = i2 WITH protect
 DECLARE testtasks(null) = i2 WITH protect
 DECLARE testtaskchartpositions(null) = i2 WITH protect
 DECLARE testesh(null) = i2 WITH protect
 DECLARE clearscreen(null) = null WITH protect
 DECLARE testtallman(null) = i4 WITH protect
 DECLARE loadtallmanfile(sfilename=vc) = i2 WITH protect
 DECLARE gettallmanmnemonic(stallmanstr=vc,sorigmnemonic=vc) = vc WITH protect
 DECLARE createcsvfile(null) = i2 WITH protect
 DECLARE gethnaemail(null) = vc WITH protect
 DECLARE testclinicalcategories(null) = i2 WITH protect
 DECLARE createrxordsentcsv(null) = i2 WITH protect
 DECLARE last_mod = vc WITH protect
 DECLARE debug_ind = i2 WITH protect
 DECLARE qtimerbegin = dq8 WITH protect
 DECLARE qtimerend = dq8 WITH protect
 DECLARE micurmsg = i4 WITH protect
 DECLARE cdtyperxmnem = f8 WITH constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC")), protect
 DECLARE cdpharmcat = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE cdpharmact = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY")), protect
 DECLARE cdtaskcat = f8 WITH constant(uar_get_code_by("MEANING",13016,"TASKCAT")), protect
 DECLARE gipassedtest = i2 WITH constant(0), protect
 DECLARE gifailedtest = i2 WITH constant(1), protect
 DECLARE ginoresults = i2 WITH constant(2), protect
 DECLARE errorind = i2 WITH protect
 DECLARE errorstr = vc WITH protect
 DECLARE numrows = i4 WITH constant(20), protect
 DECLARE numcols = i4 WITH constant(75), protect
 DECLARE soffrow = i4 WITH constant(6), protect
 DECLARE soffcol = i4 WITH constant(3), protect
 DECLARE regex_combo_drug = cv WITH constant("[-/]"), protect
 DECLARE script_name = c13 WITH protect, constant("AMS_MLTM_TEST")
 DECLARE msautotestcatalogname = vc WITH constant("MLTMAutoTest"), protect
 DECLARE michecktallman = i2 WITH protect
 DECLARE micheckallusers = i2 WITH protect
 DECLARE mfuserprsnlid = f8 WITH protect
 DECLARE msinputusername = vc WITH protect
 DECLARE mdafterdttm = dq8 WITH protect
 DECLARE ipassedtestcnt = i4 WITH protect
 DECLARE ifailedtestcnt = i4 WITH protect
 DECLARE stat = i2 WITH protect
 DECLARE tmanfilename = vc WITH protect
 DECLARE delim = vc WITH constant(","), protect
 DECLARE comboind = i2 WITH protect
 DECLARE micreatecsv = i2 WITH protect
 SET micurmsg = 0
 SET micheckallusers = 0
 SET mfuserprsnlid = 0.0
 SET msinputusername = ""
 SET ipassedtestcnt = 0
 SET ifailedtestcnt = 0
 SET stat = 0
 RECORD msg(
   1 msg_buf[*]
     2 msg_text = c255
 )
 RECORD new_ord_catalog(
   1 catalog_list[*]
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 description = vc
     2 cki = vc
     2 immunization_ind = i2
     2 dcp_clin_cat_cd = f8
 )
 RECORD new_tasks(
   1 task_list[*]
     2 reference_task_id = f8
     2 task_description = vc
     2 linked_catalog_cd = f8
     2 linked_primary = vc
 )
 RECORD cat_test_values(
   1 test_catalog_cd = f8
   1 primary_mnemonic = vc
   1 description = vc
   1 auto_cancel_ind = i2
   1 bill_only_ind = i2
   1 complete_upon_order_ind = i2
   1 consent_form_format_cd = f8
   1 consent_form_ind = i2
   1 consent_form_routing_cd = f8
   1 cont_order_method_flag = i2
   1 dc_display_days = i4
   1 dc_interaction_days = i4
   1 discern_auto_verify_flag = i2
   1 ic_auto_verify_flag = i2
   1 orderable_type_flag = i2
   1 print_req_ind = i2
   1 requisition_format_cd = f8
   1 requisition_routing_cd = f8
   1 stop_duration = i4
   1 stop_duration_unit_cd = f8
   1 stop_type_cd = f8
   1 review_settings[*]
     2 action_type_cd = f8
     2 action_type_disp = vc
     2 nurse_review_flag = i2
     2 doctor_cosign_flag = i2
     2 rx_verify_flag = i2
     2 cosign_required_ind = i2
     2 review_required_ind = i2
 )
 RECORD task_test_values(
   1 reference_task_id = f8
   1 task_description = vc
   1 allpositionchart_ind = i2
   1 capture_bill_info_ind = i2
   1 grace_period_mins = i4
   1 ignore_req_ind = i2
   1 overdue_min = i4
   1 overdue_units = i4
   1 quick_chart_done_ind = i2
   1 quick_chart_ind = i2
   1 reschedule_time = i4
   1 retain_time = i4
   1 retain_units = i4
   1 task_activity_cd = f8
   1 task_type_cd = f8
   1 position_chart_list[*]
     2 position_cd = f8
     2 position_name = vc
 )
 FREE RECORD tman
 RECORD tman(
   1 search_list_sz = i4
   1 search_list[*]
     2 tallman_str = vc
     2 tallman_str_cap = vc
     2 tallman_str_search = vc
 )
 FREE RECORD new_synonyms
 RECORD new_synonyms(
   1 list_sz = i4
   1 synonym_list[*]
     2 primary_mnemonic = vc
     2 synonym_id = f8
     2 synonym = vc
     2 synonym_key = vc
 )
 FREE RECORD email_request
 RECORD email_request(
   1 recepstr = vc
   1 fromstr = vc
   1 subjectstr = vc
   1 bodystr = vc
   1 filenamestr = vc
 )
 FREE RECORD email_reply
 RECORD email_reply(
   1 status = c1
   1 errorstr = vc
 )
 EXECUTE ams_define_toolkit_common
#main_menu
 EXECUTE cclseclogin
 IF ((xxcclseclogin->loggedin != 1))
  SET errorind = 1
  SET errorstr = "You must be logged in securely. Please run the program again."
  GO TO exit_script
 ENDIF
 CALL clear(1,1)
 CALL box((soffrow - 5),(soffcol - 1),(numrows+ 3),(numcols+ 3))
 CALL video(r)
 CALL text((soffrow - 4),soffcol,
  "                          AMS Multum Test Utility                          ")
 CALL text((soffrow - 3),soffcol,
  "           Utility will perfom automated testing of Multum loads           ")
 CALL video(n)
 CALL line((soffrow - 1),(soffcol - 1),(numcols+ 2),xhor)
#invalid_user
 CALL text(soffrow,soffcol,"Enter username who performed the Multum load (or ALL):")
 CALL accept(soffrow,(soffcol+ 55),"P(20);CU","ALL")
 IF (curaccept="ALL")
  SET micheckallusers = 1
 ELSE
  SET mfuserprsnlid = lookupprsnlid(curaccept)
 ENDIF
 CALL clear((soffrow+ 1),soffcol,numcols)
 CALL text((soffrow+ 1),soffcol,"Enter date of Bedrock Multum load steps:")
 CALL accept((soffrow+ 1),(soffcol+ 41),"NNDNNDNNNN;C",format(curdate,"MM/DD/YYYY;;D")
  WHERE format(cnvtdate(cnvtalphanum(curaccept)),"MM/DD/YYYY;;D")=curaccept)
 SET mdafterdttm = cnvtdatetime(cnvtdate(cnvtalphanum(curaccept)),0000)
#mltm_input
 CALL text((soffrow+ 2),soffcol,"Check if synonyms are in tallman format? (Y)es (N)o:")
 CALL accept((soffrow+ 2),(soffcol+ 53),"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET michecktallman = 1
  CALL text((soffrow+ 3),soffcol,"Should combination drugs be included? (Y)es (N)o:")
  CALL accept((soffrow+ 3),(soffcol+ 50),"A;CU","Y"
   WHERE curaccept IN ("Y", "N"))
  IF (curaccept="Y")
   SET comboind = 1
  ELSE
   SET comboind = 0
  ENDIF
  CALL text((soffrow+ 4),soffcol,"Enter filename to READ tallmans from:")
  CALL accept((soffrow+ 5),(soffcol+ 1),"P(74);CU","CER_INSTALL:TALLMAN.CSV")
  IF (curaccept="*.CSV")
   IF (findfile(curaccept))
    SET tmanfilename = concat(curaccept)
   ELSE
    CALL clear((soffrow+ 6),soffcol,numcols)
    CALL text((soffrow+ 6),soffcol,
     "Input file not found. Include logical if file is not in CCLUSERDIR")
    GO TO mltm_input
   ENDIF
  ELSE
   CALL clear((soffrow+ 6),soffcol,numcols)
   CALL text((soffrow+ 6),soffcol,"Input file must have .csv extension")
   GO TO mltm_input
  ENDIF
 ELSE
  CALL clear((soffrow+ 2),soffcol,numcols)
  CALL clear((soffrow+ 3),soffcol,numcols)
  CALL clear((soffrow+ 4),soffcol,numcols)
  CALL clear((soffrow+ 5),soffcol,numcols)
  CALL clear((soffrow+ 6),soffcol,numcols)
  SET michecktallman = 0
 ENDIF
 CALL clear((soffrow+ 6),soffcol,numcols)
 CALL text((soffrow+ 6),soffcol,
  "Do you want to create and email CSV files with new synonyms and sents?:")
 CALL accept((soffrow+ 6),(soffcol+ 72),"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  SET micreatecsv = 1
  CALL text((soffrow+ 7),soffcol,"Enter recepient's email address:")
  CALL accept((soffrow+ 8),(soffcol+ 1),"P(74);C",gethnaemail(null)
   WHERE curaccept > " ")
  SET email_request->recepstr = curaccept
 ELSE
  SET micreatecsv = 0
 ENDIF
 CALL clear(1,1)
 SET message = nowindow
#end_main_menu
 CALL echo("**Begin Multum Load Testing**")
 CALL setlogginglevel(null)
 CALL echo("Loading test order catalog entry...",0)
 IF (loadtestcatvalues(msautotestcatalogname)=gifailedtest)
  CALL echo("FAILED")
  CALL printmsgs(null)
  CALL echo(build2("  Ensure test order catalog (PrimaryName= ",msautotestcatalogname,
    ") is properly built"))
  CALL echo("Exiting due to Error")
  SET ifailedtestcnt = (ifailedtestcnt+ 1)
  GO TO exit_script
 ENDIF
 CALL echo("done")
 CALL printmsgs(null)
 CALL echo("Testing new synonyms are virtual viewed off...",0)
 IF (testvirtualviews(null)=gipassedtest)
  CALL echo("passed")
  SET ipassedtestcnt = (ipassedtestcnt+ 1)
 ELSE
  CALL echo("FAILED")
  SET ifailedtestcnt = (ifailedtestcnt+ 1)
 ENDIF
 CALL printmsgs(null)
 IF (michecktallman=1)
  IF (loadtallmanfile(tmanfilename) > 0)
   CALL echo("Testing new synonyms are in tallman format...",0)
   IF (testtallman(null)=gipassedtest)
    CALL echo("passed")
    SET ipassedtestcnt = (ipassedtestcnt+ 1)
   ELSE
    CALL echo("FAILED")
    SET ifailedtestcnt = (ifailedtestcnt+ 1)
   ENDIF
   CALL printmsgs(null)
  ELSE
   CALL echo(build2("Check that the file exists in CCLUSERDIR: ",tmanfilename))
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("Not performing tallman check")
 ENDIF
 CALL echo("Testing order catalog settings on new primaries...",0)
 CASE (ensurenewcatalogs(ipassedtestcnt,ifailedtestcnt))
  OF gipassedtest:
   CALL echo("passed")
  OF gifailedtest:
   CALL echo("FAILED")
  OF ginoresults:
   CALL echo("NONE FOUND")
   CALL printmsgs(null)
   CALL echo(
    "  No New Primaries found. Check the ORC file or bedrock to ensure no new primaries should have loaded"
    )
   CALL echo("  Exiting Script. Nothing else to test")
   GO TO exit_script
 ENDCASE
 CALL printmsgs(null)
 CALL echo("Testing review settings on new primaries...",0)
 IF (testcatreviewsettings(null)=gipassedtest)
  CALL echo("passed")
  SET ipassedtestcnt = (ipassedtestcnt+ 1)
 ELSE
  CALL echo("FAILED")
  SET ifailedtestcnt = (ifailedtestcnt+ 1)
 ENDIF
 CALL printmsgs(null)
 CALL echo("Testing clinical category settings on new primaries...",0)
 IF (testclinicalcategories(null)=gipassedtest)
  CALL echo("passed")
  SET ipassedtestcnt = (ipassedtestcnt+ 1)
 ELSE
  CALL echo("FAILED")
  SET ifailedtestcnt = (ifailedtestcnt+ 1)
 ENDIF
 CALL printmsgs(null)
 CALL echo("Loading test task entry...",0)
 IF (loadtesttaskvalues(cat_test_values->test_catalog_cd)=gifailedtest)
  CALL echo("FAIL")
  CALL printmsgs(null)
  CALL echo(build2("  Error: Auto Test TASK not properly built or linked to catalog: ",
    msautotestcatalogname))
  SET ifailedtestcnt = (ifailedtestcnt+ 1)
  GO TO exit_script
 ENDIF
 CALL echo("done")
 CALL printmsgs(null)
 CALL echo("Testing tasks on new primaries...",0)
 IF (testtasks(null)=gipassedtest)
  CALL echo("passed")
  SET ipassedtestcnt = (ipassedtestcnt+ 1)
 ELSE
  CALL echo("FAILED")
  SET ifailedtestcnt = (ifailedtestcnt+ 1)
 ENDIF
 CALL printmsgs(null)
 CALL echo("Testing positions that can chart on new tasks...",0)
 IF (testtaskchartpositions(null)=gipassedtest)
  CALL echo("passed")
  SET ipassedtestcnt = (ipassedtestcnt+ 1)
 ELSE
  CALL echo("FAILED")
  SET ifailedtestcnt = (ifailedtestcnt+ 1)
 ENDIF
 CALL printmsgs(null)
 CALL echo("Testing Medication and Immunization event sets / event codes for new primaries...",0)
 IF (testesh(null)=gipassedtest)
  CALL echo("passed")
  SET ipassedtestcnt = (ipassedtestcnt+ 1)
 ELSE
  CALL echo("FAILED")
  SET ifailedtestcnt = (ifailedtestcnt+ 1)
 ENDIF
 CALL printmsgs(null)
 IF (micreatecsv=1)
  IF (createcsvfile(null)
   AND createrxordsentcsv(null))
   CALL echo("Successfully sent CSV files")
  ELSE
   CALL echo(concat("Emailing file failed: ",email_reply->errorstr))
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE setlogginglevel(null)
   IF (validate(debug,0)=1)
    SET debug_ind = 1
    CALL echo("Debug Mode Enabled")
   ELSE
    SET debug_ind = 0
    SET trace = callecho
    SET trace = notest
    SET trace = noechoinput
    SET trace = noechoinput2
    SET trace = noechorecord
    SET trace = noshowuar
    SET message = noinformation
    SET trace = nocost
   ENDIF
 END ;Subroutine
 SUBROUTINE starttimer(null)
   IF (debug_ind)
    SET qtimerbegin = cnvtdatetime(curdate,curtime3)
   ENDIF
 END ;Subroutine
 SUBROUTINE stoptimer(null)
   DECLARE delapsedtime = f8 WITH protect
   SET delapsedtime = 0.0
   IF (debug_ind)
    SET qtimerend = cnvtdatetime(curdate,curtime3)
    SET delapsedtime = round(datetimediff(qtimerend,qtimerbegin,5),2)
    CALL echo(build("Elapsed Time: ",cnvtstring(delapsedtime,4,2)))
   ENDIF
   RETURN(delapsedtime)
 END ;Subroutine
 SUBROUTINE addmsg(smsg,iprefix)
   SET micurmsg = (micurmsg+ 1)
   IF (micurmsg > size(msg->msg_buf,5))
    SET stat = alterlist(msg->msg_buf,(micurmsg+ 25))
   ENDIF
   CASE (iprefix)
    OF 0:
     SET msg->msg_buf[micurmsg].msg_text = smsg
    OF 1:
     SET msg->msg_buf[micurmsg].msg_text = concat("  *FAIL* ",smsg)
    ELSE
     SET msg->msg_buf[micurmsg].msg_text = smsg
   ENDCASE
 END ;Subroutine
 SUBROUTINE printmsgs(null)
  FOR (idx = 1 TO micurmsg)
    CALL echo(msg->msg_buf[idx].msg_text)
  ENDFOR
  SET micurmsg = 0
 END ;Subroutine
 SUBROUTINE lookupprsnlid(susername)
   DECLARE iprsnlid = f8 WITH protect
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.username=cnvtupper(trim(susername,3))
     AND ((p.active_ind+ 0)=1)
    DETAIL
     iprsnlid = p.person_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL text((soffrow+ 1),soffcol,"User not found. Please enter valid, active username.")
    GO TO invalid_user
   ENDIF
   RETURN(iprsnlid)
 END ;Subroutine
 SUBROUTINE loadtestcatvalues(stestcatalogname)
   CALL starttimer(null)
   DECLARE ireturn = i2 WITH protect
   DECLARE irevactcnt = i4 WITH protect
   SET ireturn = gifailedtest
   SELECT INTO "nl:"
    FROM order_catalog oc,
     order_catalog_review ocr
    PLAN (oc
     WHERE oc.primary_mnemonic=stestcatalogname
      AND oc.catalog_type_cd=cdpharmcat)
     JOIN (ocr
     WHERE oc.catalog_cd=ocr.catalog_cd
      AND ocr.action_type_cd > 0)
    ORDER BY oc.catalog_cd, ocr.action_type_cd
    HEAD oc.catalog_cd
     irevactcnt = 0, cat_test_values->test_catalog_cd = oc.catalog_cd, cat_test_values->
     primary_mnemonic = oc.primary_mnemonic,
     cat_test_values->description = oc.description, cat_test_values->auto_cancel_ind = oc
     .auto_cancel_ind, cat_test_values->bill_only_ind = oc.bill_only_ind,
     cat_test_values->complete_upon_order_ind = oc.complete_upon_order_ind, cat_test_values->
     consent_form_format_cd = oc.consent_form_format_cd, cat_test_values->consent_form_ind = oc
     .consent_form_ind,
     cat_test_values->consent_form_routing_cd = oc.consent_form_routing_cd, cat_test_values->
     cont_order_method_flag = 2, cat_test_values->dc_display_days = oc.dc_display_days,
     cat_test_values->dc_interaction_days = oc.dc_interaction_days, cat_test_values->
     discern_auto_verify_flag = oc.discern_auto_verify_flag, cat_test_values->ic_auto_verify_flag =
     oc.ic_auto_verify_flag,
     cat_test_values->orderable_type_flag = 1, cat_test_values->print_req_ind = oc.print_req_ind,
     cat_test_values->requisition_format_cd = oc.requisition_format_cd,
     cat_test_values->requisition_routing_cd = oc.requisition_routing_cd, cat_test_values->
     stop_duration = oc.stop_duration, cat_test_values->stop_duration_unit_cd = oc
     .stop_duration_unit_cd,
     cat_test_values->stop_type_cd = oc.stop_type_cd
    DETAIL
     ireturn = gipassedtest, irevactcnt = (irevactcnt+ 1)
     IF (irevactcnt > size(cat_test_values->review_settings,5))
      stat = alterlist(cat_test_values->review_settings,(irevactcnt+ 20))
     ENDIF
     cat_test_values->review_settings[irevactcnt].action_type_cd = ocr.action_type_cd,
     cat_test_values->review_settings[irevactcnt].action_type_disp = uar_get_code_display(ocr
      .action_type_cd), cat_test_values->review_settings[irevactcnt].cosign_required_ind = ocr
     .cosign_required_ind,
     cat_test_values->review_settings[irevactcnt].doctor_cosign_flag = ocr.doctor_cosign_flag,
     cat_test_values->review_settings[irevactcnt].nurse_review_flag = ocr.nurse_review_flag,
     cat_test_values->review_settings[irevactcnt].review_required_ind = ocr.review_required_ind,
     cat_test_values->review_settings[irevactcnt].rx_verify_flag = ocr.rx_verify_flag
    FOOT  oc.catalog_cd
     stat = alterlist(cat_test_values->review_settings,irevactcnt)
    WITH nocounter
   ;end select
   IF (ireturn=gifailedtest)
    CALL addmsg(build2("Auto testing order catalog not found: ",stestcatalogname),1)
    RETURN(ireturn)
   ENDIF
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs
    PLAN (ocs
     WHERE (ocs.catalog_cd=cat_test_values->test_catalog_cd)
      AND ocs.active_ind=1
      AND ((ocs.hide_flag=0) OR ( EXISTS (
     (SELECT
      ofr.synonym_id
      FROM ocs_facility_r ofr
      WHERE ofr.synonym_id=ocs.synonym_id)))) )
    DETAIL
     ireturn = gifailedtest,
     CALL addmsg(build2("Auto testing order catalog HideFlag=OFF or VirtualView=ON: ",
      stestcatalogname),1)
    WITH nocounter
   ;end select
   CALL stoptimer(null)
   IF (debug_ind=1)
    CALL echorecord(cat_test_values)
   ENDIF
   RETURN(ireturn)
 END ;Subroutine
 SUBROUTINE testvirtualviews(null)
   CALL starttimer(null)
   DECLARE ireturn = i2
   DECLARE idx = i4
   SET ireturn = gipassedtest
   SELECT INTO "nl:"
    FROM order_catalog_synonym ocs,
     ocs_facility_r ofr
    PLAN (ocs
     WHERE ocs.updt_dt_tm >= cnvtdatetime(mdafterdttm)
      AND ((((ocs.updt_id+ 0)=mfuserprsnlid)) OR (micheckallusers=1))
      AND ((ocs.catalog_type_cd+ 0)=cdpharmcat)
      AND ((ocs.activity_type_cd+ 0)=cdpharmact)
      AND ((ocs.active_ind+ 0)=1)
      AND ocs.active_status_dt_tm >= cnvtdatetime(mdafterdttm))
     JOIN (ofr
     WHERE ocs.synonym_id=ofr.synonym_id)
    ORDER BY ocs.synonym_id
    HEAD ocs.synonym_id
     ireturn = gifailedtest,
     CALL addmsg(build("Synonym Virtual Viewed ON - SynonymId: ",ocs.synonym_id," : ",ocs.mnemonic),1
     )
    WITH nocounter
   ;end select
   CALL stoptimer(null)
   RETURN(ireturn)
 END ;Subroutine
 SUBROUTINE testtallman(null)
   CALL starttimer(null)
   DECLARE ireturn = i2
   DECLARE i = i4 WITH protect
   DECLARE j = i4 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE tallman_mnemonic = vc WITH protect
   DECLARE combodrugprefix = i2 WITH protect
   DECLARE combodrugsuffix = i2 WITH protect
   DECLARE combodrug = i2 WITH protect
   DECLARE partialdrugprefix = i2 WITH protect
   DECLARE partialdrugsuffix = i2 WITH protect
   DECLARE partialdrug = i2 WITH protect
   SET ireturn = gipassedtest
   SELECT INTO "nl:"
    ocs.synonym_id, ocs.updt_dt_tm, ocs.mnemonic,
    synonymtype = uar_get_code_display(ocs.mnemonic_type_cd), ocs.mnemonic_key_cap, oc.catalog_cd,
    oc.primary_mnemonic
    FROM order_catalog_synonym ocs,
     order_catalog oc
    PLAN (ocs
     WHERE ocs.updt_dt_tm >= cnvtdatetime(mdafterdttm)
      AND ((((ocs.updt_id+ 0)=mfuserprsnlid)) OR (micheckallusers=1))
      AND  NOT (((ocs.mnemonic_type_cd+ 0) IN (cdtyperxmnem)))
      AND ((ocs.catalog_type_cd+ 0)=cdpharmcat)
      AND ((ocs.active_ind+ 0)=1)
      AND ocs.active_status_dt_tm >= cnvtdatetime(mdafterdttm))
     JOIN (oc
     WHERE ocs.catalog_cd=oc.catalog_cd)
    ORDER BY cnvtupper(oc.primary_mnemonic), synonymtype, ocs.mnemonic
    HEAD REPORT
     j = 0
    DETAIL
     j = (j+ 1), stat = alterlist(new_synonyms->synonym_list,j), new_synonyms->list_sz = j,
     new_synonyms->synonym_list[j].primary_mnemonic = oc.primary_mnemonic, new_synonyms->
     synonym_list[j].synonym_id = ocs.synonym_id, new_synonyms->synonym_list[j].synonym = ocs
     .mnemonic,
     new_synonyms->synonym_list[j].synonym_key = ocs.mnemonic_key_cap
    WITH nocounter
   ;end select
   FOR (i = 1 TO tman->search_list_sz)
     FOR (idx = 1 TO new_synonyms->list_sz)
       IF ((new_synonyms->synonym_list[idx].synonym_key=patstring(tman->search_list[i].
        tallman_str_search)))
        SET combodrugprefix = operator(cnvtupper(new_synonyms->synonym_list[idx].primary_mnemonic),
         "REGEXPLIKE",concat(regex_combo_drug,tman->search_list[i].tallman_str_cap))
        SET combodrugsuffix = operator(cnvtupper(new_synonyms->synonym_list[idx].primary_mnemonic),
         "REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,regex_combo_drug))
        SET combodrug = bor(combodrugprefix,combodrugsuffix)
        SET partialdrugprefix = operator(cnvtupper(new_synonyms->synonym_list[idx].synonym),
         "REGEXPLIKE",concat("[A-Z]",tman->search_list[i].tallman_str_cap))
        SET partialdrugsuffix = operator(cnvtupper(new_synonyms->synonym_list[idx].synonym),
         "REGEXPLIKE",concat(tman->search_list[i].tallman_str_cap,"[A-Z]"))
        SET partialdrug = bor(partialdrugprefix,partialdrugsuffix)
        IF (debug_ind=1)
         CALL echo("*****************************************")
         CALL echo(new_synonyms->synonym_list[idx].primary_mnemonic)
         CALL echo(new_synonyms->synonym_list[idx].synonym)
         CALL echo(new_synonyms->synonym_list[idx].synonym_id)
         CALL echo(build("ComboDrug: ",combodrug))
         CALL echo(build("ComboDrugPrefix: ",combodrugprefix))
         CALL echo(build("ComboDrugSuffix: ",combodrugsuffix))
         CALL echo(build("PartialDrug: ",partialdrug))
         CALL echo(build("PartialDrugPrefix: ",partialdrugprefix))
         CALL echo(build("PartialDrugSuffix: ",partialdrugsuffix))
        ENDIF
        SET tallman_mnemonic = gettallmanmnemonic(tman->search_list[i].tallman_str,new_synonyms->
         synonym_list[idx].synonym)
        IF ((tallman_mnemonic != new_synonyms->synonym_list[idx].synonym)
         AND partialdrug=0
         AND ((combodrug=0) OR (comboind=1)) )
         SET ireturn = gifailedtest
         CALL addmsg(build("Synonym not in tallman format - SynonymId: ",new_synonyms->synonym_list[
           idx].synonym_id," : ",new_synonyms->synonym_list[idx].synonym),1)
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   CALL stoptimer(null)
   RETURN(ireturn)
 END ;Subroutine
 SUBROUTINE loadtallmanfile(sfilename)
   DECLARE i = i4 WITH protect
   DECLARE tcnt = i4 WITH protect
   DECLARE beg_index = i4 WITH protect
   DECLARE end_index = i4 WITH protect
   DECLARE tstrlen = i4 WITH protect
   CALL echo(build("Reading tallman synonyms from file: ",sfilename))
   FREE DEFINE rtl
   DEFINE rtl sfilename
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    WHERE  NOT (r.line IN (" ", null))
    HEAD REPORT
     tcnt = 0
    DETAIL
     beg_index = 1, end_index = 0, tcnt = (tcnt+ 1)
     IF (mod(tcnt,100)=1)
      stat = alterlist(tman->search_list,(tcnt+ 99))
     ENDIF
     end_index = findstring(delim,r.line,beg_index), tstrlen = (end_index - beg_index)
     IF (end_index > 0)
      tman->search_list[tcnt].tallman_str = substring(beg_index,tstrlen,r.line)
     ELSE
      tman->search_list[tcnt].tallman_str = r.line
     ENDIF
     tman->search_list[tcnt].tallman_str_cap = cnvtupper(tman->search_list[tcnt].tallman_str), tman->
     search_list[tcnt].tallman_str_search = build("*",cnvtupper(tman->search_list[tcnt].tallman_str),
      "*"), beg_index = (end_index+ 1)
    FOOT REPORT
     IF (mod(tcnt,100) != 0)
      stat = alterlist(tman->search_list,tcnt)
     ENDIF
    WITH nocounter
   ;end select
   SET tman->search_list_sz = size(tman->search_list,5)
   RETURN(evaluate(tman->search_list_sz,0,0,1))
 END ;Subroutine
 SUBROUTINE gettallmanmnemonic(stallmanstr,sorigmnemonic)
   DECLARE startpos = i4 WITH protect
   DECLARE endpos = i4 WITH protect
   DECLARE final_str = vc WITH protect
   DECLARE prefix = vc WITH protect
   DECLARE suffix = vc WITH protect
   SET startpos = 1
   SET endpos = findstring(cnvtupper(stallmanstr),cnvtupper(sorigmnemonic))
   SET prefix = notrim(substring(startpos,(endpos - 1),sorigmnemonic))
   SET startpos = (endpos+ textlen(stallmanstr))
   SET endpos = ((textlen(sorigmnemonic) - startpos)+ 1)
   SET suffix = substring(startpos,endpos,sorigmnemonic)
   SET final_str = concat(prefix,stallmanstr,suffix)
   IF (debug_ind=1)
    CALL echo(build("sTallmanStr: ",stallmanstr))
    CALL echo(build("sOrigSynonym: ",sorigmnemonic))
    CALL echo(build("final_str: ",final_str))
   ENDIF
   RETURN(final_str)
 END ;Subroutine
 SUBROUTINE ensurenewcatalogs(ipasscnt,ifailcnt)
   CALL starttimer(null)
   DECLARE icatcnt = i4 WITH protect
   DECLARE iorigfailcnt = i4 WITH protect
   SET icatcnt = 0
   SET iorigfailcnt = ifailcnt
   SELECT INTO "nl: "
    FROM order_catalog oc,
     code_value cv
    PLAN (oc
     WHERE oc.updt_dt_tm >= cnvtdatetime(mdafterdttm)
      AND ((((oc.updt_id+ 0)=mfuserprsnlid)) OR (micheckallusers=1))
      AND ((oc.catalog_type_cd+ 0)=cdpharmcat)
      AND ((oc.activity_type_cd+ 0)=cdpharmact)
      AND ((oc.active_ind+ 0)=1))
     JOIN (cv
     WHERE oc.catalog_cd=cv.code_value
      AND cv.active_dt_tm >= cnvtdatetime(mdafterdttm)
      AND cv.begin_effective_dt_tm >= cnvtdatetime(mdafterdttm))
    ORDER BY oc.primary_mnemonic
    HEAD REPORT
     icatcnt = 0
    DETAIL
     icatcnt = (icatcnt+ 1)
     IF (icatcnt > size(new_ord_catalog->catalog_list,5))
      stat = alterlist(new_ord_catalog->catalog_list,(icatcnt+ 25))
     ENDIF
     new_ord_catalog->catalog_list[icatcnt].catalog_cd = oc.catalog_cd, new_ord_catalog->
     catalog_list[icatcnt].primary_mnemonic = trim(oc.primary_mnemonic), new_ord_catalog->
     catalog_list[icatcnt].description = oc.description,
     new_ord_catalog->catalog_list[icatcnt].cki = oc.cki, new_ord_catalog->catalog_list[icatcnt].
     dcp_clin_cat_cd = oc.dcp_clin_cat_cd
     IF ((((oc.dc_display_days != cat_test_values->dc_display_days)) OR ((oc.dc_interaction_days !=
     cat_test_values->dc_interaction_days))) )
      CALL addmsg(build2("Order Catalog Primary: ",trim(oc.primary_mnemonic),
       " - Discontinue/Interaction Days settings"),1), ifailcnt = (ifailcnt+ 1)
     ELSE
      ipasscnt = (ipasscnt+ 1)
     ENDIF
     IF ((((oc.stop_duration != cat_test_values->stop_duration)) OR ((((oc.stop_duration_unit_cd !=
     cat_test_values->stop_duration_unit_cd)) OR ((oc.stop_type_cd != cat_test_values->stop_type_cd)
     )) )) )
      CALL addmsg(build2("Order Catalog Primary: ",trim(oc.primary_mnemonic)," - Stop Type settings"),
      1), ifailcnt = (ifailcnt+ 1)
     ELSE
      ipasscnt = (ipasscnt+ 1)
     ENDIF
     IF ((((oc.discern_auto_verify_flag != cat_test_values->discern_auto_verify_flag)) OR ((oc
     .ic_auto_verify_flag != cat_test_values->ic_auto_verify_flag))) )
      CALL addmsg(build2("Order Catalog Primary: ",trim(oc.primary_mnemonic),
       " -AutoVerify Eligibility settings"),1), ifailcnt = (ifailcnt+ 1)
     ELSE
      ipasscnt = (ipasscnt+ 1)
     ENDIF
     IF ((((oc.print_req_ind != cat_test_values->print_req_ind)) OR ((((oc.requisition_format_cd !=
     cat_test_values->requisition_format_cd)) OR ((oc.requisition_routing_cd != cat_test_values->
     requisition_routing_cd))) )) )
      CALL addmsg(build2("Order Catalog Primary: ",trim(oc.primary_mnemonic),
       " - Requisitions settings"),1), ifailcnt = (ifailcnt+ 1)
     ELSE
      ipasscnt = (ipasscnt+ 1)
     ENDIF
     IF ((((oc.consent_form_ind != cat_test_values->consent_form_ind)) OR ((((oc
     .consent_form_format_cd != cat_test_values->consent_form_format_cd)) OR ((oc
     .consent_form_routing_cd != cat_test_values->consent_form_routing_cd))) )) )
      CALL addmsg(build2("Order Catalog Primary: ",trim(oc.primary_mnemonic),
       " - Consent Form settings"),1), ifailcnt = (ifailcnt+ 1)
     ELSE
      ipasscnt = (ipasscnt+ 1)
     ENDIF
     IF ((((oc.auto_cancel_ind != cat_test_values->auto_cancel_ind)) OR ((((oc.bill_only_ind !=
     cat_test_values->bill_only_ind)) OR ((oc.complete_upon_order_ind != cat_test_values->
     complete_upon_order_ind))) )) )
      CALL addmsg(build2("Order Catalog Primary: ",trim(oc.primary_mnemonic),
       " - Miscellaneous Indicators section"),1), ifailcnt = (ifailcnt+ 1)
     ELSE
      ipasscnt = (ipasscnt+ 1)
     ENDIF
     IF ((((oc.cont_order_method_flag != cat_test_values->cont_order_method_flag)) OR ((oc
     .orderable_type_flag > cat_test_values->orderable_type_flag))) )
      CALL addmsg(build2("Order Catalog Primary: ",trim(oc.primary_mnemonic),
       " -Continuing Order/Order Type settings"),1), ifailcnt = (ifailcnt+ 1)
     ELSE
      ipasscnt = (ipasscnt+ 1)
     ENDIF
    FOOT REPORT
     stat = alterlist(new_ord_catalog->catalog_list,icatcnt)
    WITH nocounter
   ;end select
   IF (icatcnt=0)
    CALL stoptimer(null)
    RETURN(ginoresults)
   ENDIF
   SELECT INTO "nl:"
    FROM order_catalog oc
    WHERE oc.updt_dt_tm >= cnvtdatetime(mdafterdttm)
     AND ((((oc.updt_id+ 0)=mfuserprsnlid)) OR (micheckallusers=1))
     AND ((oc.catalog_type_cd+ 0)=cdpharmcat)
     AND ((oc.activity_type_cd+ 0)=cdpharmact)
     AND ((oc.active_ind+ 0)=1)
     AND  NOT ( EXISTS (
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=200
      AND cv.code_value=oc.catalog_cd
      AND ((cv.active_ind+ 0)=1))))
    DETAIL
     ifailcnt = (ifailcnt+ 1),
     CALL addmsg(build("Missing active CatalogCd entry on codeset 200. Primary: ",oc.primary_mnemonic,
      "CatalogCd: ",oc.catalog_cd),1)
    WITH nocounter
   ;end select
   CALL loadimmunizationind(null)
   CALL stoptimer(null)
   IF (debug_ind=1)
    CALL echorecord(new_ord_catalog)
    CALL addmsg(build("Number of new primary synonyms: ",icatcnt),0)
   ENDIF
   IF (ifailcnt != iorigfailcnt)
    RETURN(gifailedtest)
   ENDIF
   RETURN(gipassedtest)
 END ;Subroutine
 SUBROUTINE testcatreviewsettings(null)
   CALL starttimer(null)
   DECLARE ireturn = i2 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE inewcatsize = i4 WITH protect
   SET ireturn = gipassedtest
   SET idx = 0
   SET inewcatsize = size(new_ord_catalog->catalog_list,5)
   IF (debug_ind)
    CALL addmsg(build("Comparing catalog review settings with test CatalogCd: ",cat_test_values->
      test_catalog_cd),0)
    CALL addmsg(
     "Checking for review settings matches on actions that exist on test catalog and new catalog",0)
   ENDIF
   SELECT DISTINCT INTO "nl: "
    catalog = uar_get_code_display(ocrnew.catalog_cd), action = uar_get_code_display(ocrnew
     .action_type_cd), tstverify = ocrtst.rx_verify_flag,
    catverify = ocrnew.rx_verify_flag, tstcosign = ocrtst.doctor_cosign_flag, catcosign = ocrnew
    .doctor_cosign_flag,
    tstnurserev = ocrtst.nurse_review_flag, catnurserev = ocrnew.nurse_review_flag
    FROM order_catalog_review ocrtst,
     order_catalog_review ocrnew
    PLAN (ocrtst
     WHERE (ocrtst.catalog_cd=cat_test_values->test_catalog_cd)
      AND ocrtst.action_type_cd > 0)
     JOIN (ocrnew
     WHERE expand(idx,1,inewcatsize,ocrnew.catalog_cd,new_ord_catalog->catalog_list[idx].catalog_cd)
      AND ocrnew.action_type_cd=ocrtst.action_type_cd)
    ORDER BY catalog, action
    HEAD REPORT
     row + 0
    HEAD catalog
     IF (debug_ind)
      CALL addmsg(build(" Checking Catalog - ",ocrnew.catalog_cd," : ",catalog),0)
     ENDIF
    DETAIL
     rxverifyfail = evaluate(ocrtst.rx_verify_flag,ocrnew.rx_verify_flag,0,1), doccosignfail =
     evaluate(ocrtst.doctor_cosign_flag,ocrnew.doctor_cosign_flag,0,1), nurserevfail = evaluate(
      ocrtst.nurse_review_flag,ocrnew.nurse_review_flag,0,1)
     IF (debug_ind)
      CALL addmsg(build2("  ",trim(action)," : ",ocrtst.action_type_cd," RxVerifyFail=",
       rxverifyfail,"DocCoSignFail=",doccosignfail," NurseRevFail=",nurserevfail),0)
     ENDIF
     IF (((rxverifyfail) OR (((doccosignfail) OR (nurserevfail)) )) )
      ireturn = gifailedtest,
      CALL addmsg(build2("Incorrect Order Catalog Review settings: ",trim(catalog)," : ",trim(action)
       ),1)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind)
    CALL addmsg("Checking for review settings set on NEW catalogs that do not exist on TEST catalog",
     0)
   ENDIF
   SET idx = 0
   SELECT DISTINCT INTO "nl: "
    catalog = uar_get_code_display(ocrnew.catalog_cd), action = uar_get_code_display(ocrnew
     .action_type_cd)
    FROM order_catalog_review ocrnew
    PLAN (ocrnew
     WHERE expand(idx,1,inewcatsize,ocrnew.catalog_cd,new_ord_catalog->catalog_list[idx].catalog_cd)
      AND ocrnew.action_type_cd > 0
      AND ((ocrnew.rx_verify_flag > 0) OR (((ocrnew.doctor_cosign_flag > 0) OR (ocrnew
     .nurse_review_flag > 0)) ))
      AND  NOT ( EXISTS (
     (SELECT
      ocrtst.action_type_cd
      FROM order_catalog_review ocrtst
      WHERE (ocrtst.catalog_cd=cat_test_values->test_catalog_cd)
       AND ocrtst.action_type_cd=ocrnew.action_type_cd))))
    ORDER BY catalog, action
    DETAIL
     ireturn = gifailedtest,
     CALL addmsg(build("Order Catalog Review settings shouldn't be set for action: ",catalog," : ",
      action),1)
    WITH nocounter
   ;end select
   IF (debug_ind)
    CALL addmsg("Checking for review settings set on TEST catalog that do not exist on NEW catalogs",
     0)
   ENDIF
   SET idx = 0
   SELECT DISTINCT INTO "nl: "
    catalog = uar_get_code_display(oc.catalog_cd), action = uar_get_code_display(ocrtst
     .action_type_cd)
    FROM order_catalog_review ocrtst,
     order_catalog oc
    PLAN (oc
     WHERE expand(idx,1,inewcatsize,oc.catalog_cd,new_ord_catalog->catalog_list[idx].catalog_cd))
     JOIN (ocrtst
     WHERE (ocrtst.catalog_cd=cat_test_values->test_catalog_cd)
      AND ocrtst.action_type_cd > 0
      AND ((ocrtst.rx_verify_flag > 0) OR (((ocrtst.doctor_cosign_flag > 0) OR (ocrtst
     .nurse_review_flag > 0)) ))
      AND  NOT ( EXISTS (
     (SELECT
      ocrnew.action_type_cd
      FROM order_catalog_review ocrnew
      WHERE ocrnew.catalog_cd=oc.catalog_cd
       AND ocrnew.action_type_cd=ocrtst.action_type_cd))))
    ORDER BY catalog, action
    DETAIL
     ireturn = gifailedtest,
     CALL addmsg(build("Order Catalog Review settings missing for action: ",catalog," : ",action),1)
    WITH nocounter
   ;end select
   CALL stoptimer(null)
   RETURN(ireturn)
 END ;Subroutine
 SUBROUTINE loadtesttaskvalues(ftestcatalogcd)
   CALL starttimer(null)
   DECLARE itasklinkcnt = i4 WITH protect
   DECLARE iposchartcnt = i4 WITH protect
   SET itasklinkcnt = 0
   SELECT INTO "nl:"
    ot.reference_task_id, position = uar_get_code_display(otp.position_cd)
    FROM order_task_xref otx,
     order_task ot,
     order_task_position_xref otp
    PLAN (otx
     WHERE otx.catalog_cd=ftestcatalogcd)
     JOIN (ot
     WHERE ot.reference_task_id=otx.reference_task_id)
     JOIN (otp
     WHERE otp.reference_task_id=outerjoin(ot.reference_task_id))
    ORDER BY ot.reference_task_id, position
    HEAD REPORT
     itasklinkcnt = 0
    HEAD ot.reference_task_id
     iposchartcnt = 0, itasklinkcnt = (itasklinkcnt+ 1), task_test_values->reference_task_id = ot
     .reference_task_id,
     task_test_values->task_description = ot.task_description, task_test_values->allpositionchart_ind
      = ot.allpositionchart_ind, task_test_values->capture_bill_info_ind = ot.capture_bill_info_ind,
     task_test_values->grace_period_mins = ot.grace_period_mins, task_test_values->ignore_req_ind =
     ot.ignore_req_ind, task_test_values->overdue_min = ot.overdue_min,
     task_test_values->overdue_units = ot.overdue_units, task_test_values->quick_chart_done_ind = ot
     .quick_chart_done_ind, task_test_values->quick_chart_ind = ot.quick_chart_ind,
     task_test_values->reschedule_time = ot.reschedule_time, task_test_values->retain_time = ot
     .retain_time, task_test_values->retain_units = ot.retain_units,
     task_test_values->task_activity_cd = ot.task_activity_cd, task_test_values->task_type_cd = ot
     .task_type_cd
    DETAIL
     iposchartcnt = (iposchartcnt+ 1)
     IF (iposchartcnt > size(task_test_values->position_chart_list,5))
      stat = alterlist(task_test_values->position_chart_list,(iposchartcnt+ 20))
     ENDIF
     task_test_values->position_chart_list[iposchartcnt].position_cd = otp.position_cd,
     task_test_values->position_chart_list[iposchartcnt].position_name = uar_get_code_display(otp
      .position_cd)
    FOOT  ot.reference_task_id
     stat = alterlist(task_test_values->position_chart_list,iposchartcnt)
    WITH nocounter
   ;end select
   CALL stoptimer(null)
   IF ((((task_test_values->reference_task_id=0)) OR (itasklinkcnt != 1)) )
    CALL addmsg(build2("Testing TASK not found or correctly linked to test catalog: ",
      msautotestcatalogname),1)
    RETURN(gifailedtest)
   ENDIF
   IF (debug_ind=1)
    CALL echorecord(task_test_values)
   ENDIF
   RETURN(gipassedtest)
 END ;Subroutine
 SUBROUTINE testtasks(null)
   CALL starttimer(null)
   DECLARE idx = i4 WITH protect
   DECLARE ireturn = i2 WITH protect
   DECLARE itasklinkcnt = i4 WITH protect
   DECLARE itotaltaskscnt = i4 WITH protect
   SET ireturn = gipassedtest
   SELECT INTO "nl:"
    catalog = uar_get_code_display(oc.catalog_cd), otx.reference_task_id
    FROM order_catalog oc,
     order_task_xref otx,
     order_task ot,
     bill_item bi
    PLAN (oc
     WHERE expand(idx,1,size(new_ord_catalog->catalog_list,5),oc.catalog_cd,new_ord_catalog->
      catalog_list[idx].catalog_cd))
     JOIN (otx
     WHERE otx.catalog_cd=outerjoin(oc.catalog_cd))
     JOIN (ot
     WHERE ot.reference_task_id=outerjoin(otx.reference_task_id)
      AND ot.active_ind=outerjoin(1))
     JOIN (bi
     WHERE bi.ext_parent_reference_id=outerjoin(ot.reference_task_id)
      AND bi.ext_parent_contributor_cd=outerjoin(cdtaskcat)
      AND bi.ext_child_reference_id=outerjoin(0))
    ORDER BY catalog, otx.reference_task_id
    HEAD REPORT
     itotaltaskscnt = 0
    HEAD oc.catalog_cd
     itasklinkcnt = 0
    DETAIL
     itotaltaskscnt = (itotaltaskscnt+ 1)
     IF (itotaltaskscnt > size(new_tasks->task_list,5))
      stat = alterlist(new_tasks->task_list,(itotaltaskscnt+ 25))
     ENDIF
     new_tasks->task_list[itotaltaskscnt].reference_task_id = ot.reference_task_id, new_tasks->
     task_list[itotaltaskscnt].task_description = ot.task_description, new_tasks->task_list[
     itotaltaskscnt].linked_catalog_cd = otx.catalog_cd,
     new_tasks->task_list[itotaltaskscnt].linked_primary = oc.primary_mnemonic
     IF (debug_ind)
      CALL addmsg(build("Testing - reference_task_id: ",ot.reference_task_id," : ",ot
       .task_description),0)
     ENDIF
     itasklinkcnt = (itasklinkcnt+ 1)
     IF (itasklinkcnt > 1)
      CALL addmsg(build2("Multiple Tasks Linked to Catalog: ",oc.catalog_cd," : ",trim(catalog)),1),
      ireturn = gifailedtest
     ENDIF
     IF (ot.reference_task_id=0.0)
      CALL addmsg(build2("Task Not Built or Linked to Catalog: ",oc.catalog_cd," : ",trim(catalog)),1
      ), ireturn = gifailedtest
     ELSE
      IF ((ot.capture_bill_info_ind != task_test_values->capture_bill_info_ind))
       CALL addmsg(build2("Task: ",trim(ot.task_description)," - Capture Bill Info"),1), ireturn =
       gifailedtest
      ENDIF
      IF ((ot.ignore_req_ind != task_test_values->ignore_req_ind))
       CALL addmsg(build2("Task: ",trim(ot.task_description)," - Ignore Reqd fields adhoc"),1),
       ireturn = gifailedtest
      ENDIF
      IF ((((ot.quick_chart_done_ind != task_test_values->quick_chart_done_ind)) OR ((ot
      .quick_chart_ind != task_test_values->quick_chart_ind))) )
       CALL addmsg(build2("Task: ",trim(ot.task_description),
        " - Chart as Done/Quick Chart/Neither setting"),1), ireturn = gifailedtest
      ENDIF
      IF ((((ot.overdue_min != task_test_values->overdue_min)) OR ((ot.overdue_units !=
      task_test_values->overdue_units))) )
       CALL addmsg(build2("Task: ",trim(ot.task_description)," - Overdue Time"),1), ireturn =
       gifailedtest
      ENDIF
      IF ((((ot.retain_time != task_test_values->retain_time)) OR ((ot.retain_units !=
      task_test_values->retain_units))) )
       IF ((task_test_values->retain_time=0))
        CALL addmsg(build2("Task: ",trim(ot.task_description),
         " - Retention Time should be 0 for medication tasks"),1)
       ELSE
        CALL addmsg(build2("Task: ",trim(ot.task_description)," - Retention Time"),1)
       ENDIF
       ireturn = gifailedtest
      ENDIF
      IF ((ot.task_type_cd != task_test_values->task_type_cd))
       CALL addmsg(build2("Task: ",trim(ot.task_description)," - Task Type"),1), ireturn =
       gifailedtest
      ENDIF
      IF ((ot.task_activity_cd != task_test_values->task_activity_cd))
       CALL addmsg(build2("Task: ",trim(ot.task_description)," - Task Activity type"),1), ireturn =
       gifailedtest
      ENDIF
      IF ((ot.grace_period_mins != task_test_values->grace_period_mins))
       CALL addmsg(build2("Task: ",trim(ot.task_description)," - Grace Period"),1), ireturn =
       gifailedtest
      ENDIF
      IF ((ot.reschedule_time != task_test_values->reschedule_time))
       CALL addmsg(build2("Task: ",trim(ot.task_description)," - Reschedule Time"),1), ireturn =
       gifailedtest
      ENDIF
      IF ((ot.allpositionchart_ind != task_test_values->allpositionchart_ind))
       CALL addmsg(build2("Task: ",trim(ot.task_description)," - All Positions Chart Setting"),1),
       ireturn = gifailedtest
      ENDIF
      IF (bi.ext_parent_reference_id=0)
       CALL addmsg(build2("Task: ",trim(ot.task_description)," - Bill item not found"),1), ireturn =
       gifailedtest
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(new_tasks->task_list,itotaltaskscnt)
    WITH nocounter
   ;end select
   CALL stoptimer(null)
   IF (debug_ind=1)
    CALL echorecord(new_tasks)
   ENDIF
   RETURN(ireturn)
 END ;Subroutine
 SUBROUTINE testtaskchartpositions(null)
   CALL starttimer(null)
   DECLARE ireturn = i2 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE inewtasksize = i4 WITH protect
   SET ireturn = gipassedtest
   IF ((task_test_values->allpositionchart_ind=1))
    IF (debug_ind)
     CALL echo("All Positions Chart on Test Task. Task Positions already tested")
    ENDIF
    RETURN(gipassedtest)
   ENDIF
   SET inewtasksize = size(new_tasks->task_list,5)
   IF (inewtasksize=0)
    IF (debug_ind)
     CALL echo("No New Tasks found to check positions that chart on")
    ENDIF
    RETURN(gipassedtest)
   ENDIF
   IF (debug_ind)
    SELECT INTO "nl:"
     otp.position_cd, tstpos = uar_get_code_display(otp.position_cd)
     FROM order_task_position_xref otp
     WHERE (otp.reference_task_id=task_test_values->reference_task_id)
     ORDER BY tstpos
     HEAD REPORT
      CALL echo("Positions that chart on Test Task:")
     DETAIL
      CALL echo(build(tstpos," - ",otp.position_cd))
     WITH nocounter
    ;end select
   ENDIF
   SELECT DISTINCT INTO "nl:"
    ot.task_description, otpnew.reference_task_id, tstpos = uar_get_code_display(otptst.position_cd)
    FROM order_task_position_xref otptst,
     order_task_position_xref otpnew,
     order_task ot
    PLAN (otptst
     WHERE (otptst.reference_task_id=task_test_values->reference_task_id))
     JOIN (otpnew
     WHERE expand(idx,1,inewtasksize,otpnew.reference_task_id,new_tasks->task_list[idx].
      reference_task_id)
      AND  NOT ( EXISTS (
     (SELECT
      otp.position_cd
      FROM order_task_position_xref otp
      WHERE otp.reference_task_id=otpnew.reference_task_id
       AND otp.position_cd=otptst.position_cd))))
     JOIN (ot
     WHERE otpnew.reference_task_id=ot.reference_task_id
      AND ot.active_ind=1)
    ORDER BY ot.task_description_key, ot.reference_task_id, otptst.position_cd
    HEAD ot.task_description_key
     row + 0
    HEAD ot.reference_task_id
     row + 0
    HEAD otptst.position_cd
     ireturn = gifailedtest,
     CALL addmsg(build("Task:",ot.task_description," - Missing Position Charting:",
      uar_get_code_display(otptst.position_cd)),1)
    WITH nocounter
   ;end select
   SELECT DISTINCT INTO "nl:"
    ot.task_description, otpnew.reference_task_id, tstpos = uar_get_code_display(otpnew.position_cd)
    FROM order_task_position_xref otpnew,
     order_task_position_xref otptst,
     order_task ot
    PLAN (otpnew
     WHERE expand(idx,1,inewtasksize,otpnew.reference_task_id,new_tasks->task_list[idx].
      reference_task_id))
     JOIN (otptst
     WHERE (otptst.reference_task_id=task_test_values->reference_task_id)
      AND  NOT ( EXISTS (
     (SELECT
      otp.position_cd
      FROM order_task_position_xref otp
      WHERE otp.reference_task_id=otptst.reference_task_id
       AND otp.position_cd=otpnew.position_cd))))
     JOIN (ot
     WHERE otpnew.reference_task_id=ot.reference_task_id
      AND ot.active_ind=1)
    ORDER BY ot.task_description_key, ot.reference_task_id, otpnew.position_cd
    HEAD ot.task_description_key
     row + 0
    HEAD ot.reference_task_id
     row + 0
    HEAD otpnew.position_cd
     ireturn = gifailedtest,
     CALL addmsg(build("Task:",ot.task_description," - Position should not chart:",
      uar_get_code_display(otpnew.position_cd)),1)
    WITH nocounter
   ;end select
   CALL stoptimer(null)
   RETURN(ireturn)
 END ;Subroutine
 SUBROUTINE testesh(null)
   CALL starttimer(null)
   DECLARE ireturn = i2 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE inewcatsize = i4 WITH protect
   DECLARE num = i4 WITH protect
   DECLARE pos = i4 WITH protect
   SET ireturn = gipassedtest
   SET inewcatsize = size(new_ord_catalog->catalog_list,5)
   SELECT INTO "nl: "
    oc.primary_mnemonic, oc.catalog_cd, vec.event_cd_disp,
    vec.event_cd, cv1.code_value, vesc.event_set_cd_disp,
    vesc.event_set_cd, cv2.code_value, vesc2.event_set_cd,
    vesc2.event_set_name
    FROM order_catalog oc,
     code_value_event_r cvr,
     v500_event_code vec,
     code_value cv1,
     v500_event_set_explode vese,
     v500_event_set_code vesc,
     code_value cv2,
     v500_event_set_canon vecan,
     v500_event_set_code vesc2
    PLAN (oc
     WHERE expand(idx,1,inewcatsize,oc.catalog_cd,new_ord_catalog->catalog_list[idx].catalog_cd)
      AND ((oc.catalog_cd+ 0) != cat_test_values->test_catalog_cd))
     JOIN (cvr
     WHERE cvr.parent_cd=outerjoin(oc.catalog_cd))
     JOIN (vec
     WHERE vec.event_cd=outerjoin(cvr.event_cd))
     JOIN (cv1
     WHERE cv1.code_value=outerjoin(vec.event_cd)
      AND cv1.code_set=outerjoin(72)
      AND cv1.active_ind=outerjoin(1))
     JOIN (vese
     WHERE vese.event_cd=outerjoin(vec.event_cd)
      AND vese.event_set_level=outerjoin(0))
     JOIN (vesc
     WHERE vesc.event_set_cd=outerjoin(vese.event_set_cd))
     JOIN (cv2
     WHERE cv2.code_value=outerjoin(vesc.event_set_cd)
      AND cv2.code_set=outerjoin(93)
      AND cv2.active_ind=outerjoin(1))
     JOIN (vecan
     WHERE vecan.event_set_cd=outerjoin(vesc.event_set_cd))
     JOIN (vesc2
     WHERE vesc2.event_set_cd=outerjoin(vecan.parent_event_set_cd))
    ORDER BY oc.primary_mnemonic, vesc2.event_set_cd
    HEAD REPORT
     row + 0
    HEAD oc.primary_mnemonic
     row + 0
    HEAD oc.catalog_cd
     imedparentfound = 0, iimmunparentfound = 0
     IF (debug_ind)
      CALL addmsg(build("Checking ESH for Catalog: ",oc.primary_mnemonic," CatalogCd: ",oc.catalog_cd
       ),0)
     ENDIF
     IF (vec.event_cd=0)
      ireturn = gifailedtest,
      CALL addmsg(build("Catalog: ",oc.primary_mnemonic," - Missing or Not Linked to Event Code"),1)
     ELSEIF (cv1.code_value=0)
      ireturn = gifailedtest,
      CALL addmsg(build("EventCode: ",vec.event_cd_disp," : ",vec.event_cd,
       " - Missing active entry on codeset 72"),1)
     ELSEIF (vesc.event_set_cd=0)
      ireturn = gifailedtest,
      CALL addmsg(build("EventCode: ",vec.event_cd_disp," : ",vec.event_cd,
       " - Missing Event Set link"),1)
     ELSEIF (cv2.code_value=0)
      ireturn = gifailedtest,
      CALL addmsg(build("EventSet:",vesc.event_set_cd_disp," :",vesc.event_set_cd,
       " - Missing active entry on codeset 93"),1)
     ENDIF
    DETAIL
     IF (vesc2.event_set_name_key="MEDICATIONS")
      imedparentfound = 1
     ELSEIF (vesc2.event_set_name_key="IMMUNIZATIONS")
      iimmunparentfound = 1
     ENDIF
    FOOT  oc.catalog_cd
     IF (imedparentfound=0)
      ireturn = gifailedtest,
      CALL addmsg(build("EventSet: ",vesc.event_set_cd_disp," : ",vesc.event_set_cd,
       " - not in 'MEDICATIONS' folder"),1)
     ENDIF
     pos = locateval(num,1,size(new_ord_catalog->catalog_list,5),oc.catalog_cd,new_ord_catalog->
      catalog_list[num].catalog_cd)
     IF (iimmunparentfound=0
      AND (new_ord_catalog->catalog_list[pos].immunization_ind=1))
      ireturn = gifailedtest,
      CALL addmsg(build("EventSet:",vesc.event_set_cd_disp," : ",vesc.event_set_cd,
       " - is an IMMUNIZATION not in 'IMMUNIZATIONS' folder"),1)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    oc.primary_mnemonic, vec.event_cd_disp
    FROM order_catalog oc,
     code_value_event_r cvr,
     v500_event_code vec
    PLAN (oc
     WHERE expand(idx,1,inewcatsize,oc.catalog_cd,new_ord_catalog->catalog_list[idx].catalog_cd))
     JOIN (cvr
     WHERE cvr.parent_cd=oc.catalog_cd)
     JOIN (vec
     WHERE vec.event_cd=cvr.event_cd
      AND  NOT ( EXISTS (
     (SELECT
      vesc.event_set_cd
      FROM v500_event_set_code vesc
      WHERE vesc.event_set_name=vec.event_set_name))))
    ORDER BY oc.primary_mnemonic
    DETAIL
     ireturn = gifailedtest,
     CALL addmsg(build("EventCode: ",vec.event_cd_disp," : ",vec.event_cd,
      " - Incorrect EventCode / EventSet Link"),1)
    WITH nocounter
   ;end select
   CALL stoptimer(null)
   RETURN(ireturn)
 END ;Subroutine
 SUBROUTINE loadimmunizationind(null)
   DECLARE cat_size = i4 WITH protect
   SET cat_size = size(new_ord_catalog->catalog_list,5)
   SELECT INTO "nl: "
    mdc.multum_category_id, mcs.sub_category_id, x.drug_identifier
    FROM mltm_drug_categories mdc,
     mltm_category_sub_xref mcs,
     mltm_category_drug_xref x,
     (dummyt d  WITH seq = value(cat_size))
    PLAN (mdc
     WHERE cnvtupper(mdc.category_name)="IMMUNOLOGIC AGENTS")
     JOIN (mcs
     WHERE mcs.multum_category_id=mdc.multum_category_id)
     JOIN (x
     WHERE ((x.multum_category_id=mcs.multum_category_id) OR (x.multum_category_id=mcs
     .sub_category_id)) )
     JOIN (d
     WHERE x.drug_identifier=substring(9,textlen(new_ord_catalog->catalog_list[d.seq].cki),
      new_ord_catalog->catalog_list[d.seq].cki))
    DETAIL
     IF (debug_ind)
      CALL echo(build("Immunization: ",new_ord_catalog->catalog_list[d.seq].cki," : ",new_ord_catalog
       ->catalog_list[d.seq].primary_mnemonic))
     ENDIF
     new_ord_catalog->catalog_list[d.seq].immunization_ind = 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE testclinicalcategories(null)
   DECLARE ireturn = i2 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE num = i4 WITH protect
   DECLARE pos = i4 WITH protect
   DECLARE failmsg = vc WITH protect
   SET ireturn = gipassedtest
   SELECT INTO "nl:"
    mocl.catalog_cki
    FROM mltm_order_catalog_load mocl
    PLAN (mocl
     WHERE expand(idx,1,size(new_ord_catalog->catalog_list,5),mocl.catalog_cki,new_ord_catalog->
      catalog_list[idx].cki)
      AND mocl.mnemonic_type_mean="PRIMARY")
    HEAD REPORT
     pos = 0
    DETAIL
     pos = locateval(num,1,size(new_ord_catalog->catalog_list,5),mocl.catalog_cki,new_ord_catalog->
      catalog_list[num].cki)
     IF ((uar_get_code_by("MEANING",16389,trim(mocl.dcp_clin_cat_mean)) != new_ord_catalog->
     catalog_list[pos].dcp_clin_cat_cd))
      ireturn = gifailedtest, failmsg = build("Catalog: ",new_ord_catalog->catalog_list[pos].
       primary_mnemonic," - Missing or Incorrect Clinical Category"),
      CALL addmsg(failmsg,1)
     ENDIF
    WITH nocounter
   ;end select
   RETURN(ireturn)
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
 SUBROUTINE createcsvfile(null)
   DECLARE retval = i2 WITH protect
   DECLARE filestr = vc WITH protect
   SET filestr = trim(concat("new_multum_syns_",trim(cnvtlower(curdomain)),".csv"))
   SELECT INTO value(filestr)
    primary_synonym = oc.primary_mnemonic, synonym_type = uar_get_code_display(ocs.mnemonic_type_cd),
    synonym_name = ocs.mnemonic,
    ocs.hide_flag, ocs.cki, ocs.synonym_id
    FROM order_catalog_synonym ocs,
     order_catalog oc,
     mltm_order_catalog_load mocl
    PLAN (ocs
     WHERE ocs.updt_dt_tm >= cnvtdatetime(mdafterdttm)
      AND ((((ocs.updt_id+ 0)=mfuserprsnlid)) OR (micheckallusers=1))
      AND ((ocs.catalog_type_cd+ 0)=cdpharmcat)
      AND ((ocs.activity_type_cd+ 0)=cdpharmact)
      AND ((ocs.active_ind+ 0)=1)
      AND ocs.active_status_dt_tm >= cnvtdatetime(mdafterdttm))
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd)
     JOIN (mocl
     WHERE mocl.synonym_cki=ocs.cki)
    ORDER BY cnvtupper(oc.primary_mnemonic), mocl.primary_ind DESC, synonym_type,
     synonym_name
    WITH format = stream, pcformat('"',",",1), format
   ;end select
   IF (curqual > 0)
    SET email_request->filenamestr = filestr
    SET email_request->fromstr = "ams_mltm_test@cerner.com"
    EXECUTE ams_run_email_file  WITH replace("REQUEST",email_request), replace("REPLY",email_reply)
   ENDIF
   IF ((email_reply->status="S"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
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
 SUBROUTINE createrxordsentcsv(null)
   DECLARE retval = i2 WITH protect
   DECLARE filestr = vc WITH protect
   SET filestr = trim(concat("new_rx_ord_sents_",trim(cnvtlower(curdomain)),".csv"))
   SELECT INTO value(filestr)
    oc.primary_mnemonic, synonym = ocs.mnemonic, os.order_sentence_display_line,
    ocs.synonym_id, os.order_sentence_id, os.external_identifier
    FROM order_sentence os,
     order_catalog_synonym ocs,
     order_catalog oc
    PLAN (os
     WHERE os.usage_flag=2
      AND os.external_identifier="BRMUL.OP*"
      AND os.updt_dt_tm > cnvtdatetime(mdafterdttm)
      AND ((os.updt_id=mfuserprsnlid) OR (micheckallusers=1))
      AND os.updt_cnt=0)
     JOIN (ocs
     WHERE ocs.synonym_id=os.parent_entity_id
      AND os.parent_entity_name="ORDER_CATALOG_SYNONYM")
     JOIN (oc
     WHERE oc.catalog_cd=ocs.catalog_cd)
    ORDER BY cnvtupper(oc.primary_mnemonic), cnvtupper(ocs.mnemonic), cnvtupper(os
      .order_sentence_display_line)
    WITH format = stream, pcformat('"',",",1), format
   ;end select
   IF (curqual > 0)
    SET email_request->subjectstr = ""
    SET email_request->filenamestr = filestr
    SET email_request->fromstr = "ams_mltm_test@cerner.com"
    EXECUTE ams_run_email_file  WITH replace("REQUEST",email_request), replace("REPLY",email_reply)
   ENDIF
   IF ((email_reply->status="S"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
#exit_script
 IF (errorind=1)
  CALL clearscreen(null)
  SET message = nowindow
  CALL echo(errorstr)
 ELSE
  CALL echo(build("Number of new primary synonyms found for testing: ",size(new_ord_catalog->
     catalog_list,5)))
  CALL echo(build("Total Passed Tests: ",ipassedtestcnt))
  CALL echo(build("Total Failed Tests: ",ifailedtestcnt))
  CALL echo("**Testing Multum Load Completed**")
  SET trace = nocallecho
  CALL updtdminfo(script_name,cnvtreal(size(new_ord_catalog->catalog_list,5)))
  SET trace = callecho
 ENDIF
 SET last_mod = "010"
END GO
