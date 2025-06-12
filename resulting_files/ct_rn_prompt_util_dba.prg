CREATE PROGRAM ct_rn_prompt_util:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select action" = 0,
  "Protocols" = 0,
  "Password" = "",
  "Activate protocol in order to run through the Research Network?" = 1
  WITH outdev, action, prots,
  pwd, activate_prot
 FREE RECORD core_request
 RECORD core_request(
   1 cd_value_list[*]
     2 action_type_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE RECORD core_reply
 RECORD core_reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE hash(input=vc) = c100
 SUBROUTINE hash(input)
   DECLARE output = vc WITH protected, noconstant(aesencrypt((1+ mod(size(input),5)),input,size(input
      )))
   DECLARE limit = i4 WITH protected, noconstant(size(input))
   IF (limit < 7)
    SET limit = (limit+ 6)
   ENDIF
   FOR (i = 1 TO limit)
    SET output = build(aesencrypt((1+ mod(i,5)),output,size(output)),output)
    SET output = substring((1+ mod(i,7)),100,output)
   ENDFOR
   SET output = substring(1,100,cnvtrawhex(output))
   RETURN(output)
 END ;Subroutine
 DECLARE sendfilemsa(outfile=vc,statusfile=vc) = vc WITH protect
 DECLARE checkmsalogicals(null) = i2 WITH protect
 DECLARE executemsaclient(outfile=vc,statusfile=vc) = i2 WITH protect
 DECLARE checkmsastatus(null) = i2 WITH protect
 SUBROUTINE sendfilemsa(outfile,statusfile)
   DECLARE error_msg = vc WITH protect, noconstant("")
   DECLARE retval = i2 WITH protect, noconstant(0)
   SET retval = checkmsalogicals(null)
   IF (retval=0)
    CALL echo("MSA Logicals not defined.")
    SET error_msg = "ct_msa_send.inc: MSA Logicals not defined."
    RETURN(error_msg)
   ENDIF
   SET retval = findfile(concat("cer_temp:",outfile))
   IF (retval=0)
    CALL echo(concat("Unable to locate file: ",outfile))
    SET error_msg = concat("ct_msa_send.inc: Unable to locate file - ",outfile)
    RETURN(error_msg)
   ENDIF
   SET retval = executemsaclient(outfile,statusfile)
   IF (retval=0)
    CALL echo("Error in ExecuteMSAClient.")
    SET error_msg = "ct_msa_send.inc: Error in ExecuteMSAClient."
    RETURN(error_msg)
   ENDIF
   SET retval = checkmsastatus(outfile,statusfile)
   IF (retval=0)
    CALL echo("Error in CheckMSAStatus.")
    SET error_msg = "ct_msa_send.inc:Error in CheckMSAStatus."
    RETURN(error_msg)
   ENDIF
   RETURN(error_msg)
 END ;Subroutine
 SUBROUTINE checkmsalogicals(null)
   DECLARE msa_status = i2 WITH noconstant(0)
   IF (logical("MSA_SERVER")=null)
    CALL echo("ERROR: MSA_SERVER logical is not setup")
    SET msa_status = 1
   ENDIF
   IF (logical("CLIENT_MNEMONIC")=null)
    CALL echo("ERROR: CLIENT_MNEMONIC logical is not setup")
    SET msa_status = 1
   ENDIF
   IF (msa_status=1)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE executemsaclient(outfile,statusfile)
   DECLARE dclcmd = vc WITH protect, noconstant("")
   DECLARE status = i4 WITH protect, noconstant(0)
   IF (cursys="AIX")
    SET dclcmd = concat("$cer_exe/msaclient -file ","$cer_temp/",outfile," | grep 'Status' > ",
     "$cer_temp/",
     statusfile)
   ELSE
    SET dclcmd = concat("pipe mcr cer_exe:msaclient -file ",outfile,
     " | search sys$input Status/out = ",statusfile)
   ENDIF
   CALL echo(build2("ExecuteMSAClient::dclcmd = ",dclcmd))
   CALL dcl(dclcmd,size(dclcmd),status)
   IF (status=0)
    CALL echo("ERROR: msaclient call failed")
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE checkmsastatus(outfile,statusfile)
   DECLARE msa_status = i2 WITH protect, noconstant(0)
   IF (findfile(concat("cer_temp:",statusfile)) > 0)
    FREE DEFINE rtl2
    DEFINE rtl2 concat("cer_temp:",statusfile)
    SELECT INTO "nl:"
     a.line
     FROM rtl2t a
     DETAIL
      IF (findstring("<Code>0</Code>",trim(a.line)) > 0)
       CALL echo(concat(outfile," was sent successfully at ",format(curtime2,"##:##:##"))),
       msa_status = 1
      ENDIF
     WITH nocounter, maxrec = 1
    ;end select
   ENDIF
   IF (msa_status=1)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE script_date = f8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE rn_prot_cd = f8 WITH protect, noconstant(0.0)
 DECLARE error_ind = i2 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE status_text = vc WITH protect, noconstant(" ")
 DECLARE prot_master_id = f8 WITH protect, noconstant(0.0)
 DECLARE prot_password = c100 WITH protect, noconstant("")
 DECLARE network_flag = i2 WITH protect, noconstant(0)
 DECLARE prot_mnemonic = vc WITH protect, noconstant("")
 DECLARE user_name = vc WITH protect, noconstant("")
 DECLARE xml_str = vc WITH protect, noconstant("")
 DECLARE xml_filename = vc WITH protect, noconstant("")
 DECLARE msa_error_msg = vc WITH protect, noconstant("")
 SET status_text = uar_i18ngetmessage(i18nhandle,"STAT_SUCCESS",
  "The protocol was updated successfully")
 SET prot_master_id =  $PROTS
 IF (((( $ACTION=0)) OR (((( $ACTION=1)) OR (((( $ACTION=4)) OR (( $ACTION=5))) )) )) )
  SELECT DISTINCT
   rpc.rn_protocol_cd
   FROM ct_rn_prot_config rpc
   PLAN (rpc
    WHERE rpc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND rpc.prot_master_id=prot_master_id)
   DETAIL
    rn_prot_cd = rpc.rn_protocol_cd
   WITH nocounter
  ;end select
 ENDIF
 IF (((( $ACTION=0)) OR (((( $ACTION=1)) OR (((( $ACTION=4)) OR (( $ACTION=5))) )) )) )
  IF (rn_prot_cd > 0)
   SET stat = alterlist(core_request->cd_value_list,1)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_value=rn_prot_cd
    DETAIL
     core_request->cd_value_list[1].action_type_flag = 2, core_request->cd_value_list[1].cki = cv.cki,
     core_request->cd_value_list[1].code_set = cv.code_set,
     core_request->cd_value_list[1].code_value = rn_prot_cd, core_request->cd_value_list[1].
     collation_seq = cv.collation_seq, core_request->cd_value_list[1].concept_cki = cv.concept_cki,
     core_request->cd_value_list[1].definition = cv.definition, core_request->cd_value_list[1].
     description = cv.description, core_request->cd_value_list[1].display = cv.display,
     core_request->cd_value_list[1].begin_effective_dt_tm = cnvtdatetime(script_date), core_request->
     cd_value_list[1].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), core_request->
     cd_value_list[1].display_key = cv.display_key
     IF (((( $ACTION=0)) OR (((( $ACTION=5)
      AND ( $ACTIVATE_PROT=1)) OR (( $ACTION=4))) )) )
      core_request->cd_value_list[1].active_ind = 1
     ELSEIF (( $ACTION=1))
      core_request->cd_value_list[1].active_ind = 0
     ELSE
      core_request->cd_value_list[1].active_ind = cv.active_ind
     ENDIF
     IF (( $ACTION=4))
      core_request->cd_value_list[1].cdf_meaning = "DATAEXTR"
     ELSEIF (( $ACTION=5))
      core_request->cd_value_list[1].cdf_meaning = ""
     ELSE
      core_request->cd_value_list[1].cdf_meaning = cv.cdf_meaning
     ENDIF
    WITH nocounter
   ;end select
   EXECUTE core_ens_cd_value  WITH replace("REQUEST",core_request), replace("REPLY","CORE_REPLY")
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_value=rn_prot_cd
    DETAIL
     IF (((( $ACTION=0)) OR (( $ACTION=4)))
      AND cv.active_ind != 1)
      status_text = uar_i18ngetmessage(i18nhandle,"UNABLE_ACTIVATE",
       "Unable to activate the selected protocol."), error_ind = 1
     ELSEIF (( $ACTION=1)
      AND cv.active_ind != 0)
      status_text = uar_i18ngetmessage(i18nhandle,"UNABLE_INACTIVATE",
       "Unable to inactivate the selected protocol."), error_ind = 1
     ELSEIF (( $ACTION=4)
      AND cv.cdf_meaning != "DATAEXTR")
      status_text = uar_i18ngetmessage(i18nhandle,"UNABLE_ENABLE_DE",
       "Unable to enable data extraction for the selected protocol."), error_ind = 1
     ELSEIF (( $ACTION=5)
      AND ( $ACTIVATE_PROT=1)
      AND cv.active_ind != 1
      AND cv.cdf_meaning="DATAEXTR")
      status_text = uar_i18ngetmessage(i18nhandle,"UNABLE_DISABLE_DE",
       "Unable to disable data extraction for the selected protocol."), error_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (error_ind=0
    AND ((( $ACTION=4)) OR (( $ACTION=5))) )
    UPDATE  FROM ct_rn_prot_run rpr
     SET rpr.next_run_dt_tm = cnvtdatetime(script_date), rpr.updt_dt_tm = cnvtdatetime(script_date),
      rpr.updt_id = reqinfo->updt_id,
      rpr.updt_applctx = reqinfo->updt_applctx, rpr.updt_task = reqinfo->updt_task, rpr.updt_cnt = (
      rpr.updt_cnt+ 1)
     WHERE rpr.prot_master_id=prot_master_id
      AND rpr.run_group_id=0
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET status_text = uar_i18ngetmessage(i18nhandle,"ERROR_SETTING_RUN",
      "Error setting the next run.")
     GO TO exit_script
    ENDIF
   ENDIF
  ELSE
   SET status_text = uar_i18ngetmessage(i18nhandle,"UNABLE_CHANGE",
    "Unable to change the selected protocol.  A code value could not be identified for this protocol."
    )
  ENDIF
 ELSEIF (((( $ACTION=2)) OR (( $ACTION=3))) )
  SELECT INTO "nl:"
   FROM ct_rn_prot_config rpc,
    prot_master pm
   PLAN (rpc
    WHERE rpc.prot_master_id=prot_master_id
     AND rpc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (pm
    WHERE pm.prot_master_id=rpc.prot_master_id)
   DETAIL
    prot_password = rpc.prot_password, prot_mnemonic = pm.primary_mnemonic
   WITH nocounter
  ;end select
  IF (hash( $PWD)=prot_password)
   INSERT  FROM prot_master pm
    (pm.prot_master_id, pm.accession_nbr_last, pm.accession_nbr_prefix,
    pm.accession_nbr_sig_dig, pm.beg_effective_dt_tm, pm.collab_site_org_id,
    pm.display_ind, pm.end_effective_dt_tm, pm.initiating_service_cd,
    pm.initiating_service_desc, pm.network_flag, pm.parent_prot_master_id,
    pm.participation_type_cd, pm.peer_review_indicator_cd, pm.prev_prot_master_id,
    pm.primary_mnemonic, pm.primary_mnemonic_key, pm.program_cd,
    pm.prot_phase_cd, pm.prot_purpose_cd, pm.prot_status_cd,
    pm.prot_type_cd, pm.research_sponsor_org_id, pm.screener_ind,
    pm.updt_dt_tm, pm.updt_id, pm.updt_task,
    pm.updt_applctx, pm.updt_cnt)(SELECT
     seq(protocol_def_seq,nextval), pm1.accession_nbr_last, pm1.accession_nbr_prefix,
     pm1.accession_nbr_sig_dig, pm1.beg_effective_dt_tm, pm1.collab_site_org_id,
     pm1.display_ind, cnvtdatetime(script_date), pm1.initiating_service_cd,
     pm1.initiating_service_desc, pm1.network_flag, pm1.parent_prot_master_id,
     pm1.participation_type_cd, pm1.peer_review_indicator_cd, pm1.prev_prot_master_id,
     pm1.primary_mnemonic, pm1.primary_mnemonic_key, pm1.program_cd,
     pm1.prot_phase_cd, pm1.prot_purpose_cd, pm1.prot_status_cd,
     pm1.prot_type_cd, pm1.research_sponsor_org_id, pm1.screener_ind,
     pm1.updt_dt_tm, pm1.updt_id, pm1.updt_task,
     pm1.updt_applctx, pm1.updt_cnt
     FROM prot_master pm1
     WHERE pm1.prot_master_id=prot_master_id)
   ;end insert
   IF (curqual=0)
    SET status_text = uar_i18ngetmessage(i18nhandle,"PROT_INSERT_ERR",
     "Error inserting previous record into the prot_master table.")
    GO TO exit_script
   ENDIF
   IF (( $ACTION=2))
    SET network_flag = 1
   ELSEIF (( $ACTION=3))
    SET network_flag = 2
   ENDIF
   UPDATE  FROM prot_master pm
    SET pm.network_flag = network_flag, pm.updt_dt_tm = cnvtdatetime(curdate,curtime), pm.updt_id =
     reqinfo->updt_id,
     pm.updt_cnt = (pm.updt_cnt+ 1), pm.beg_effective_dt_tm = cnvtdatetime(script_date)
    WHERE pm.prot_master_id=prot_master_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET status_text = uar_i18ngetmessage(i18nhandle,"PROT_UPT_ERR",
     "Error updating the original prot_master record.")
    GO TO exit_script
   ENDIF
   IF (( $ACTION=2))
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE (p.person_id=reqinfo->updt_id))
     DETAIL
      user_name = p.username
     WITH nocounter
    ;end select
    SET xml_str = concat(
     '<RESEARCHNETWORK xmlns="http://www.cerner.com/Engineering/ClientData/RESEARCHNETWORK/1">',
     "<ClientDomain>",trim(curdomain),"</ClientDomain>","<ConvertedStudyList>",
     "<Study>","<Id>",prot_mnemonic,"</Id>","<ConvertDate>",
     "<DateTime>",format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSSCC;;D"),"</DateTime>",
     "<UTC_Offset>",build(curutcdiff),
     "</UTC_Offset>","</ConvertDate>","<PersonnelUserName>",user_name,"</PersonnelUserName>",
     "</Study>","</ConvertedStudyList>","</RESEARCHNETWORK>")
    SET xml_filename = "rn_convert.xml"
    SET status_filename = "rn_convert.tmp"
    SELECT INTO trim(concat("cer_temp:",xml_filename))
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      col 0, xml_str
     WITH nocounter, format = variable, maxcol = 32000
    ;end select
    SET msa_error_msg = sendfilemsa(xml_filename,status_filename)
    IF (size(trim(msa_error_msg)) > 0)
     CALL echo(msa_error_msg)
     SET status_text = uar_i18nbuildmessage(i18nhandle,"CNVT_SUCC_MSA_FAIL",
      "%1 was successfully converted, but there was an error sending the report. Please contact your system administrator.",
      "s",nullterm(prot_mnemonic))
    ELSE
     SET status_text = uar_i18nbuildmessage(i18nhandle,"CONVERT_SUCCESS",
      "%1 was successfully converted.","s",nullterm(prot_mnemonic))
    ENDIF
   ELSE
    SET status_text = uar_i18nbuildmessage(i18nhandle,"REVERT_SUCCESS",
     "%1 was successfully reverted.","s",nullterm(prot_mnemonic))
   ENDIF
  ELSE
   CALL echo("Incorrect password")
   SET status_text = uar_i18ngetmessage(i18nhandle,"INVALID_PWD",
    "The entered password is not valid for the selected protocol.")
  ENDIF
 ELSE
  SET status_text = uar_i18ngetmessage(i18nhandle,"INVALID_ACTION",
   "Invalid action, no protocols were updated.")
 ENDIF
#exit_script
 SELECT INTO  $OUTDEV
  WHERE 1=1
  DETAIL
   col 0, status_text, row + 1
  WITH nocounter, maxcol = 225
 ;end select
 SET last_mod = "000"
 SET mod_date = "July 21, 2009"
END GO
