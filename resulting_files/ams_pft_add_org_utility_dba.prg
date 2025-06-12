CREATE PROGRAM ams_pft_add_org_utility:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Logical Domain:" = 0,
  "Billing entity to associate:" = 0,
  "Create based on client:" = 0,
  "Organization name:" = "",
  "Short name:" = "",
  "Business address:" = "",
  "Line 2:" = "",
  "City:" = "",
  "State:" = 0,
  "Zip code:" = "",
  "County:" = 0,
  "Country" = 0,
  "Busisness phone:" = "",
  "Time zone:" = 0,
  "Account description:" = ""
  WITH outdev, logicaldomainid, billingentityid,
  copyfromclientorgid, orgnamestr, orgshortnamestr,
  addressline1str, addressline2str, citystr,
  statecd, zipcodestr, countycd,
  countrycd, phonestr, timezoneid,
  acctdescstr
 EXECUTE ams_define_toolkit_common
 DECLARE addorg(null) = null WITH protect
 DECLARE addorgtobillingentity(null) = null WITH protect
 DECLARE addorgtoorggroup(null) = null WITH protect
 DECLARE addorgtoaliaspool(null) = null WITH protect
 DECLARE addorgtochargetiers(null) = null WITH protect
 DECLARE createacctfororg(null) = null WITH protect
 DECLARE addpprfiltersfororg(null) = null WITH protect
 DECLARE script_name = vc WITH protect, constant("AMS_PFT_ADD_ORG_UTILITY")
 DECLARE client_org_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",278,"CLIENT"))
 DECLARE employer_org_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",278,"EMPLOYER"))
 DECLARE address_bussiness_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,
   "BUSINESS"))
 DECLARE phone_bussiness_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"BUSINESS")
  )
 DECLARE default_phone_form_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",281,
   "DEFAULT"))
 DECLARE max_rows = i4 WITH protect, constant(59)
 DECLARE i = i4 WITH protect
 DECLARE status = c1 WITH protect
 DECLARE statusmsg = vc WITH protect
 DECLARE neworgid = f8 WITH protect
 DECLARE newfacilitycd = f8 WITH protect
 DECLARE copyfromfacilitycd = f8 WITH protect
 DECLARE logicaldomainid = f8 WITH protect
 DECLARE clientbillorgtypecd = f8 WITH protect
 DECLARE techbillorgtypecd = f8 WITH protect
 DECLARE tempstr = vc WITH protect
 DECLARE prevtask = i4 WITH protect
 DECLARE billingentityname = vc WITH protect
 DECLARE accttempname = vc WITH protect
 DECLARE clientfilterind = i2 WITH protect
 DECLARE orggroupname = vc WITH protect
 IF (validate(debug,0)=0)
  DECLARE debug = i2 WITH protect, noconstant(0)
 ENDIF
 RECORD org_groups(
   1 list[*]
     2 name = vc
 ) WITH protect
 RECORD task_types(
   1 list[*]
     2 task_type_cd = f8
 ) WITH protect
 RECORD charge_tiers(
   1 list[*]
     2 type = vc
     2 display = vc
 ) WITH protect
 RECORD pool_request(
   1 alias_pools[*]
     2 action_flag = i2
     2 code_value = f8
     2 type_code_value = f8
     2 name = vc
     2 mnemonic = vc
     2 fsi_id = f8
     2 duplicate_flag = i4
     2 sys_assign_flag = i4
     2 format_mask = vc
     2 orgs[*]
       3 action_flag = i2
       3 id = f8
     2 unsecured_char_count = i4
     2 security_char = vc
 ) WITH protect
 IF (debug=1)
  CALL echo(build2("*** Beginning ",script_name," ***"))
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   logicaldomainid = p.logical_domain_id
  WITH nocounter
 ;end select
 CALL addorg(null)
 CALL addorgtobillingentity(null)
 CALL addorgtoorggroup(null)
 CALL addorgtoaliaspool(null)
 CALL addorgtochargetiers(null)
 CALL createacctfororg(null)
 CALL addpprfiltersfororg(null)
#exit_script
 IF (status="S")
  COMMIT
  CALL updtdminfo(script_name,1.0)
 ELSE
  ROLLBACK
 ENDIF
 SET currrow = 1
 SELECT INTO  $OUTDEV
  FROM dummyt d
  HEAD REPORT
   SUBROUTINE cclrtf_print(par_flag,par_startcol,par_numcol,par_blob,par_bloblen,par_check)
     m_output_buffer_len = 0, blob_out = fillstring(32768," "), blob_buf = fillstring(200," "),
     blob_len = 0, m_linefeed = concat(char(10)), textindex = 0,
     numcol = par_numcol, whiteflag = 0,
     CALL uar_rtf(par_blob,par_bloblen,blob_out,size(blob_out),m_output_buffer_len,par_flag),
     m_output_buffer_len = minval(m_output_buffer_len,size(trim(blob_out)))
     IF (m_output_buffer_len > 0)
      m_cc = 1
      WHILE (m_cc > 0)
       m_cc2 = findstring(m_linefeed,blob_out,m_cc),
       IF (m_cc2)
        blob_len = (m_cc2 - m_cc)
        IF (blob_len <= par_numcol)
         m_blob_buf = substring(m_cc,blob_len,blob_out), col par_startcol
         IF (par_check)
          CALL print(trim(check(m_blob_buf)))
         ELSE
          CALL print(trim(m_blob_buf))
         ENDIF
         row + 1
        ELSE
         m_blobbuf = substring(m_cc,blob_len,blob_out),
         CALL cclrtf_printline(par_startcol,par_numcol,m_blobbuf,blob_len,par_check), row + 1
        ENDIF
        IF (m_cc2 >= m_output_buffer_len)
         m_cc = 0
        ELSE
         m_cc = (m_cc2+ 1)
        ENDIF
       ELSE
        blob_len = ((m_output_buffer_len - m_cc)+ 1), m_blobbuf = substring(m_cc,blob_len,blob_out),
        CALL cclrtf_printline(par_startcol,par_numcol,m_blobbuf,blob_len,par_check),
        m_cc = 0
       ENDIF
      ENDWHILE
     ENDIF
   END ;Subroutine report
   ,
   SUBROUTINE cclrtf_printline(par_startcol,par_numcol,blob_out,blob_len,par_check)
     textindex = 0, numcol = par_numcol, whiteflag = 0,
     lastline = 0, m_linefeed = concat(char(10)), m_maxchar = concat(char(128)),
     m_find = 0
     WHILE (blob_len > 0)
       IF (blob_len <= par_numcol)
        numcol = blob_len, lastline = 1
       ENDIF
       textindex = (m_cc+ par_numcol)
       IF (lastline=0)
        whiteflag = 0
        WHILE (whiteflag=0)
         IF (((substring(textindex,1,blob_out)=" ") OR (substring(textindex,1,blob_out)=m_linefeed))
         )
          whiteflag = 1
         ELSE
          textindex = (textindex - 1)
         ENDIF
         ,
         IF (((textindex=m_cc) OR (textindex=0)) )
          textindex = (m_cc+ par_numcol), whiteflag = 1
         ENDIF
        ENDWHILE
        numcol = ((textindex - m_cc)+ 1)
       ENDIF
       m_blob_buf = substring(m_cc,numcol,blob_out)
       IF (m_blob_buf > " ")
        col par_startcol
        IF (par_check)
         CALL print(trim(check(m_blob_buf)))
        ELSE
         CALL print(trim(m_blob_buf))
        ENDIF
        row + 1
       ELSE
        blob_len = 0
       ENDIF
       m_cc = (m_cc+ numcol)
       IF (blob_len > numcol)
        blob_len = (blob_len - numcol)
       ELSE
        blob_len = 0
       ENDIF
     ENDWHILE
   END ;Subroutine report
  DETAIL
   row currrow,
   CALL center("Organization Build Report",0,100), currrow = (currrow+ 3)
   IF (status="S")
    tempstr = "Success!", col 5, row currrow,
    tempstr, currrow = (currrow+ 3), col 5,
    row currrow, "Organization", currrow = (currrow+ 1),
    tempstr = fillstring(90,"-"), col 5, row currrow,
    tempstr, currrow = (currrow+ 1), col 5,
    row currrow,  $ORGNAMESTR, currrow = (currrow+ 1),
    col 5, row currrow,  $ORGSHORTNAMESTR,
    currrow = (currrow+ 1), col 5, row currrow,
     $ADDRESSLINE1STR, currrow = (currrow+ 1)
    IF (textlen(trim( $ADDRESSLINE2STR)) > 0)
     col 5, row currrow,  $ADDRESSLINE2STR,
     currrow = (currrow+ 1)
    ENDIF
    tempstr = ""
    IF (textlen(trim( $CITYSTR)) > 0)
     tempstr = trim( $CITYSTR)
    ENDIF
    IF (( $STATECD > 0.0))
     IF (textlen(trim( $CITYSTR)) > 0)
      tempstr = build2(trim(tempstr),", ",trim(uar_get_code_display( $STATECD)))
     ELSE
      tempstr = trim(uar_get_code_display( $STATECD))
     ENDIF
    ENDIF
    IF (textlen(trim( $ZIPCODESTR)) > 0)
     tempstr = build2(trim(tempstr)," ", $ZIPCODESTR)
    ENDIF
    IF (textlen(trim(tempstr)) > 0)
     col 5, row currrow, tempstr,
     currrow = (currrow+ 1)
    ENDIF
    IF (( $COUNTYCD > 0.0))
     tempstr = trim(uar_get_code_display( $COUNTYCD)), col 5, row currrow,
     tempstr, currrow = (currrow+ 1)
    ENDIF
    IF (( $COUNTRYCD > 0.0))
     tempstr = trim(uar_get_code_display( $COUNTRYCD)), col 5, row currrow,
     tempstr, currrow = (currrow+ 1)
    ENDIF
    IF (textlen(trim( $PHONESTR)) > 0)
     col 5, row currrow,  $PHONESTR,
     currrow = (currrow+ 1)
    ENDIF
    currrow = (currrow+ 1), col 5, row currrow,
    "Organization Groups", currrow = (currrow+ 1), tempstr = fillstring(90,"-"),
    col 5, row currrow, tempstr,
    currrow = (currrow+ 1)
    FOR (i = 1 TO size(org_groups->list,5))
      tempstr = org_groups->list[i].name, col 5, row currrow,
      tempstr
      IF (currrow >= max_rows)
       currrow = 1, BREAK
      ENDIF
      currrow = (currrow+ 1)
    ENDFOR
    currrow = (currrow+ 1), col 5, row currrow,
    "Alias Pools", currrow = (currrow+ 1), tempstr = fillstring(90,"-"),
    col 5, row currrow, tempstr,
    currrow = (currrow+ 1)
    FOR (i = 1 TO size(pool_request->alias_pools,5))
      tempstr = pool_request->alias_pools[i].name, col 5, row currrow,
      tempstr
      IF (currrow >= max_rows)
       currrow = 1, BREAK
      ENDIF
      currrow = (currrow+ 1)
    ENDFOR
    IF ((currrow >= (max_rows - 6)))
     currrow = 1, BREAK
    ENDIF
    currrow = (currrow+ 1), col 5, row currrow,
    "Charge Tiers", currrow = (currrow+ 1), tempstr = fillstring(90,"-"),
    col 5, row currrow, tempstr,
    currrow = (currrow+ 1)
    FOR (i = 1 TO size(charge_tiers->list,5))
      tempstr = build2(charge_tiers->list[i].type,": ",charge_tiers->list[i].display), col 5, row
      currrow,
      tempstr, currrow = (currrow+ 1)
    ENDFOR
    IF ((currrow >= (max_rows - 6)))
     currrow = 1, BREAK
    ENDIF
    currrow = (currrow+ 1), col 5, row currrow,
    "Account", currrow = (currrow+ 1), tempstr = fillstring(90,"-"),
    col 5, row currrow, tempstr,
    currrow = (currrow+ 1), tempstr = build2("Billing entity: ",billingentityname), col 5,
    row currrow, tempstr, currrow = (currrow+ 1),
    tempstr = build2("Account template: ",accttempname), col 5, row currrow,
    tempstr, currrow = (currrow+ 1), tempstr = build2("Account: ", $ACCTDESCSTR),
    col 5, row currrow, tempstr,
    currrow = (currrow+ 1)
    IF ((currrow >= (max_rows - 4)))
     currrow = 1, BREAK
    ENDIF
    currrow = (currrow+ 1), col 5, row currrow,
    "PPR Filters", currrow = (currrow+ 1), tempstr = fillstring(90,"-"),
    col 5, row currrow, tempstr,
    currrow = (currrow+ 1)
    IF (clientfilterind=1)
     tempstr = build2(trim(uar_get_code_display(copyfromfacilitycd))," client filter of ",trim(
       uar_get_code_display(newfacilitycd))), col 5, row currrow,
     tempstr
     IF (currrow >= max_rows)
      currrow = 1, BREAK
     ENDIF
     currrow = (currrow+ 2)
    ENDIF
    IF (currrow >= max_rows)
     currrow = 1, BREAK
    ENDIF
    tempstr = build2(trim(uar_get_code_display(newfacilitycd))," task filters:"), col 5, row currrow,
    tempstr, currrow = (currrow+ 1)
    FOR (i = 1 TO size(task_types->list,5))
      tempstr = trim(uar_get_code_display(task_types->list[i].task_type_cd)), col 10, row currrow,
      tempstr
      IF (currrow >= max_rows)
       currrow = 1, BREAK
      ENDIF
      currrow = (currrow+ 1)
    ENDFOR
   ELSE
    col 5, row currrow, "ERROR: Script failed to complete successfully.",
    currrow = (currrow+ 3), col 5, row currrow,
    CALL cclrtf_print(0,5,90,statusmsg,32000,1)
   ENDIF
  WITH nocounter, dio = 8, maxcol = 100
 ;end select
 IF (debug=1)
  CALL echo(build2("*** Ending ",script_name," ***"))
 ENDIF
 SUBROUTINE addorg(null)
   RECORD org_request(
     1 audit_mode_ind = i2
     1 org[*]
       2 organization_id = f8
       2 org_name = vc
       2 org_prefix = c5
       2 federal_tax_id_nbr = vc
       2 start_ind = i2
       2 action_flag = i2
       2 org_type[*]
         3 org_type_code_value = f8
         3 org_type_mean = vc
         3 action_flag = i2
       2 address[*]
         3 address_id = f8
         3 street_addr1 = vc
         3 street_addr2 = vc
         3 street_addr3 = vc
         3 street_addr4 = vc
         3 city = vc
         3 state_code_value = f8
         3 state_mean = vc
         3 county = vc
         3 county_code_value = f8
         3 zipcode = vc
         3 country = vc
         3 country_code_value = f8
         3 address_type_code_value = f8
         3 address_type_mean = vc
         3 contact_name = vc
         3 comment_txt = vc
         3 action_flag = i2
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
         3 sequence = i4
       2 phone[*]
         3 phone_id = f8
         3 phone_type_code_value = f8
         3 phone_type_mean = vc
         3 phone_format_code_value = f8
         3 phone_format_mean = vc
         3 phone_num = vc
         3 sequence = i4
         3 description = vc
         3 contact = vc
         3 call_instruction = vc
         3 extension = vc
         3 paging_code = vc
         3 action_flag = i2
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
         3 contact_method_code_value = f8
         3 contributor_system_code_value = f8
       2 instr[*]
         3 br_instr_id = f8
         3 action_flag = i2
         3 br_instr_org_reltn_id = f8
         3 model_disp = vc
         3 robotics_ind = i2
         3 point_of_care_ind = i2
         3 multiplexor_ind = i2
         3 uni_ind = i2
         3 bi_ind = i2
         3 hq_ind = i2
         3 model = vc
         3 manufacturer = vc
         3 itype = vc
         3 interface_ind = i2
         3 activity_type_mean = vc
       2 facility
         3 code_value = f8
         3 description = vc
         3 display = vc
         3 mean = vc
         3 time_zone_id = f8
         3 action_flag = i2
       2 acute_care_ind = i2
       2 outreach_ind = i2
       2 begin_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 org_alias[*]
         3 action_flag = i2
         3 org_alias_id = f8
         3 alias = vc
         3 org_alias_type_code_value = f8
         3 alias_pool_code_value = f8
       2 research_accounts[*]
         3 action_flag = i2
         3 research_account_id = f8
         3 name = vc
         3 description = vc
         3 account_nbr = vc
         3 encounter_type_code_value = f8
       2 active_ind = i2
   ) WITH protect
   RECORD org_reply(
     1 qual[*]
       2 organization_id = f8
       2 facility_code_value = f8
     1 error_msg = vc
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET stat = alterlist(org_request->org,1)
   SET org_request->org[1].org_name = trim( $ORGNAMESTR)
   SET org_request->org[1].action_flag = 1
   SET org_request->org[1].active_ind = 1
   SET org_request->org[1].begin_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET org_request->org[1].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
   SET stat = alterlist(org_request->org[1].org_type,2)
   SET org_request->org[1].org_type[1].action_flag = 1
   SET org_request->org[1].org_type[1].org_type_code_value = client_org_type_cd
   SET org_request->org[1].org_type[2].action_flag = 1
   SET org_request->org[1].org_type[2].org_type_code_value = employer_org_type_cd
   SET stat = alterlist(org_request->org[1].address,1)
   SET org_request->org[1].address[1].action_flag = 1
   SET org_request->org[1].address[1].address_type_code_value = address_bussiness_type_cd
   SET org_request->org[1].address[1].street_addr1 = trim( $ADDRESSLINE1STR)
   SET org_request->org[1].address[1].street_addr2 = trim( $ADDRESSLINE2STR)
   SET org_request->org[1].address[1].city = trim( $CITYSTR)
   SET org_request->org[1].address[1].state_code_value =  $STATECD
   SET org_request->org[1].address[1].county_code_value =  $COUNTYCD
   SET org_request->org[1].address[1].zipcode =  $ZIPCODESTR
   SET org_request->org[1].address[1].country_code_value =  $COUNTRYCD
   SET stat = alterlist(org_request->org[1].phone,1)
   SET org_request->org[1].phone[1].action_flag = 1
   SET org_request->org[1].phone[1].phone_type_code_value = phone_bussiness_type_cd
   SET org_request->org[1].phone[1].phone_format_code_value = default_phone_form_type_cd
   SET org_request->org[1].phone[1].phone_format_mean = "DEFAULT"
   SET org_request->org[1].phone[1].phone_num =  $PHONESTR
   SET org_request->org[1].phone[1].sequence = 1
   SET org_request->org[1].facility.action_flag = 1
   SET org_request->org[1].facility.description = trim( $ORGNAMESTR)
   SET org_request->org[1].facility.display = trim( $ORGSHORTNAMESTR)
   SET org_request->org[1].facility.time_zone_id =  $TIMEZONEID
   IF (debug=1)
    CALL echo("org_request after being loaded by addOrg()")
    CALL echorecord(org_request)
   ENDIF
   SET prevtask = reqinfo->updt_task
   SET reqinfo->updt_task = - (3202004)
   EXECUTE bed_ens_organization  WITH replace("REQUEST",org_request), replace("REPLY",org_reply)
   SET reqinfo->updt_task = prevtask
   IF ((org_reply->status_data.status="S"))
    SET status = "S"
    IF ((org_reply->qual[1].organization_id != 0.0))
     SET neworgid = org_reply->qual[1].organization_id
     SET newfacilitycd = org_reply->qual[1].facility_code_value
    ELSE
     SET status = "F"
     SET statusmsg = "Organization_id returned from bed_ens_organization is 0.0"
     GO TO exit_script
    ENDIF
   ELSE
    SET status = "F"
    SET statusmsg = org_reply->error_msg
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE addorgtobillingentity(null)
   RECORD org_be_request(
     1 disable_qual = i4
     1 disable_reltn[*]
       2 organization_id = f8
       2 billing_entity_id = f8
     1 add_qual = i4
     1 add_reltn[*]
       2 organization_id = f8
       2 billing_entity_id = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
   ) WITH protect
   RECORD org_be_reply(
     1 add_qual = i4
     1 add_reltn[*]
       2 be_org_reltn_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[2]
         3 operationname = c8
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
   ) WITH protect
   SET org_be_request->add_qual = 1
   SET stat = alterlist(org_be_request->add_reltn,1)
   SET org_be_request->add_reltn[1].organization_id = neworgid
   SET org_be_request->add_reltn[1].billing_entity_id =  $BILLINGENTITYID
   SET org_be_request->add_reltn[1].beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
   SET org_be_request->add_reltn[1].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
   SET prevtask = reqinfo->updt_task
   SET reqinfo->updt_task = - (3202004)
   EXECUTE pft_add_be_org_reltn  WITH replace("REQUEST",org_be_request), replace("REPLY",org_be_reply
    )
   SET reqinfo->updt_task = prevtask
   IF ((org_be_reply->status_data.status="S"))
    SET status = "S"
   ELSE
    SET status = "F"
    SET statusmsg = "Error associating new organization to billing entity"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE addorgtoorggroup(null)
   DECLARE orggroupcnt = i4 WITH protect
   RECORD org_grp_request(
     1 reqqual[*]
       2 name = vc
       2 desc = vc
       2 org_set_id = f8
       2 active_ind = i2
       2 action_flag = i2
       2 org[*]
         3 org_set_org_r_id = f8
         3 organization_id = f8
         3 action_flag = i2
   ) WITH protect
   RECORD org_grp_reply(
     1 repqual[*]
       2 org_set_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SELECT
    *
    FROM org_set_org_r osor,
     org_set os
    PLAN (osor
     WHERE (osor.organization_id= $COPYFROMCLIENTORGID))
     JOIN (os
     WHERE os.org_set_id=osor.org_set_id
      AND os.active_ind=1
      AND os.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND os.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     orggroupcnt = (orggroupcnt+ 1), stat = alterlist(org_grp_request->reqqual,orggroupcnt),
     org_grp_request->reqqual[orggroupcnt].org_set_id = os.org_set_id,
     org_grp_request->reqqual[orggroupcnt].active_ind = 1, stat = alterlist(org_grp_request->reqqual[
      orggroupcnt].org,1), org_grp_request->reqqual[orggroupcnt].org[1].action_flag = 1,
     org_grp_request->reqqual[orggroupcnt].org[1].organization_id = neworgid, stat = alterlist(
      org_groups->list,orggroupcnt), org_groups->list[orggroupcnt].name = os.name
    WITH nocounter
   ;end select
   IF (debug=1)
    CALL echo("org_grp_request after being loaded by addOrgToOrgGroup()")
    CALL echorecord(org_grp_request)
   ENDIF
   IF (orggroupcnt > 0)
    SET prevtask = reqinfo->updt_task
    SET reqinfo->updt_task = - (3202004)
    EXECUTE bed_ens_organization_group  WITH replace("REQUEST",org_grp_request), replace("REPLY",
     org_grp_reply)
    SET reqinfo->updt_task = prevtask
    IF ((org_grp_reply->status_data.status="S"))
     SET status = "S"
    ELSE
     SET status = "F"
     SET statusmsg = "Error adding organization to org group"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addorgtoaliaspool(null)
   DECLARE poolcnt = i4 WITH protect
   RECORD pool_reply(
     1 alias_pools[*]
       2 code_value = f8
     1 error_msg = vc
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SELECT INTO "nl:"
    ap.description
    FROM org_alias_pool_reltn oapr,
     alias_pool ap
    PLAN (oapr
     WHERE (oapr.organization_id= $COPYFROMCLIENTORGID)
      AND oapr.active_ind=1
      AND oapr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND oapr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (ap
     WHERE ap.alias_pool_cd=oapr.alias_pool_cd)
    ORDER BY cnvtupper(ap.description)
    DETAIL
     poolcnt = (poolcnt+ 1)
     IF (mod(poolcnt,10)=1)
      stat = alterlist(pool_request->alias_pools,(poolcnt+ 9))
     ENDIF
     pool_request->alias_pools[poolcnt].code_value = oapr.alias_pool_cd, pool_request->alias_pools[
     poolcnt].type_code_value = oapr.alias_entity_alias_type_cd, pool_request->alias_pools[poolcnt].
     name = uar_get_code_display(ap.alias_pool_cd),
     stat = alterlist(pool_request->alias_pools[poolcnt].orgs,1), pool_request->alias_pools[poolcnt].
     orgs[1].action_flag = 1, pool_request->alias_pools[poolcnt].orgs[1].id = neworgid
    FOOT REPORT
     IF (mod(poolcnt,10) != 0)
      stat = alterlist(pool_request->alias_pools,poolcnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug=1)
    CALL echo("pool_request after being loaded by addOrgToAliasPool()")
    CALL echorecord(pool_request)
   ENDIF
   IF (poolcnt > 0)
    SET prevtask = reqinfo->updt_task
    SET reqinfo->updt_task = - (3202004)
    EXECUTE bed_ens_alias_pool  WITH replace("REQUEST",pool_request), replace("REPLY",pool_reply)
    SET reqinfo->updt_task = prevtask
    IF ((pool_reply->status_data.status="S"))
     SET status = "S"
    ELSE
     SET status = "F"
     SET statusmsg = "Error adding alias pools to organization"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addorgtochargetiers(null)
   DECLARE tiercnt = i4 WITH protect
   RECORD request(
     1 bill_org_payor_qual = i4
     1 bill_org_payor[*]
       2 action = vc
       2 organization_id = f8
       2 org_payor_id = f8
       2 bill_org_type_cd = f8
       2 bill_org_type_id = f8
       2 bill_org_type_string = vc
       2 bill_org_type_ind = i2
       2 interface_file_cd = f8
       2 priority = i4
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 parent_entity_name = vc
   ) WITH protect
   RECORD reply(
     1 bill_org_payor_qual = i4
     1 bill_org_payor[*]
       2 org_payor_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[2]
         3 operationname = c8
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
   ) WITH protect
   SELECT INTO "nl:"
    FROM bill_org_payor bop
    PLAN (bop
     WHERE (bop.organization_id= $COPYFROMCLIENTORGID)
      AND bop.active_ind=1
      AND bop.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND bop.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     tiercnt = (tiercnt+ 1), request->bill_org_payor_qual = tiercnt, stat = alterlist(request->
      bill_org_payor,tiercnt),
     stat = alterlist(charge_tiers->list,tiercnt), request->bill_org_payor[tiercnt].action = "ADD",
     request->bill_org_payor[tiercnt].organization_id = neworgid,
     request->bill_org_payor[tiercnt].bill_org_type_cd = bop.bill_org_type_cd, request->
     bill_org_payor[tiercnt].bill_org_type_id = bop.bill_org_type_id, request->bill_org_payor[tiercnt
     ].priority = bop.priority,
     request->bill_org_payor[tiercnt].bill_org_type_ind = bop.bill_org_type_ind, charge_tiers->list[
     tiercnt].type = trim(uar_get_code_display(bop.bill_org_type_cd)), charge_tiers->list[tiercnt].
     display = trim(uar_get_code_display(bop.bill_org_type_id))
    WITH nocounter
   ;end select
   IF (debug=1)
    CALL echo("request after being loaded by addOrgToChargeTiers()")
    CALL echorecord(request)
   ENDIF
   IF (tiercnt > 0)
    SET prevtask = reqinfo->updt_task
    SET reqinfo->updt_task = - (951034)
    EXECUTE afc_ens_bill_org_payor
    SET reqinfo->updt_task = prevtask
    IF ((reply->status_data.status="S"))
     SET status = "S"
    ELSE
     SET status = "F"
     SET statusmsg = "Error adding charge tiers"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE createacctfororg(null)
   DECLARE status_man_create_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18734,
     "MAN CREATE"))
   DECLARE ar_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18736,"A/R"))
   DECLARE client_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",20849,"CLIENT"))
   DECLARE client_role_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18936,"CLIENT"))
   DECLARE bill_freq_monthly_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002205,
     "MONTHLY"))
   DECLARE accttemplateid = f8 WITH protect
   RECORD pft_request(
     1 ext_acct_id_txt = vc
     1 acct_desc = c250
     1 acct_templ_id = f8
     1 status_reason_cd = f8
     1 beg_effective_dt_tm = dq8
     1 end_effective_dt_tm = dq8
     1 prsnl_sec_ind = i2
     1 dunning_ind = i2
     1 col_letter_ind = i2
     1 send_col_ind = i2
     1 consolidation_ind = i2
     1 suppress_flag = i2
     1 global_override_ind = i2
     1 person_qual = i4
     1 person[*]
       2 person_id = f8
       2 role_type_cd = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
     1 org_qual = i4
     1 org[*]
       2 org_id = f8
       2 role_type_cd = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
     1 client_billing_frequency_cd = f8
   ) WITH protect
   RECORD pft_reply(
     1 acct_id = f8
     1 ext_acct_id_txt = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c8
         3 operationstatus = c1
         3 targetobjectname = c5
         3 targetobjectvalue = c100
   ) WITH protect
   SELECT INTO "nl:"
    FROM billing_entity be,
     be_at_reltn bar,
     acct_template at
    PLAN (be
     WHERE (be.billing_entity_id= $BILLINGENTITYID)
      AND be.active_ind=1)
     JOIN (bar
     WHERE bar.billing_entity_id=be.billing_entity_id
      AND bar.active_ind=1
      AND bar.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND bar.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (at
     WHERE at.acct_templ_id=bar.acct_templ_id
      AND at.acct_type_cd=ar_type_cd
      AND at.acct_sub_type_cd=client_type_cd)
    DETAIL
     accttemplateid = at.acct_templ_id, billingentityname = be.be_name, accttempname = at
     .acct_templ_name
    WITH nocounter
   ;end select
   IF (accttemplateid > 0)
    SET pft_request->acct_desc = trim( $ACCTDESCSTR)
    SET pft_request->acct_templ_id = accttemplateid
    SET pft_request->status_reason_cd = status_man_create_cd
    SET pft_request->beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    SET pft_request->end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
    SET pft_request->client_billing_frequency_cd = bill_freq_monthly_cd
    SET pft_request->org_qual = 1
    SET stat = alterlist(pft_request->org,1)
    SET pft_request->org[1].org_id = neworgid
    SET pft_request->org[1].role_type_cd = client_role_type_cd
    SET pft_request->org[1].beg_effective_dt_tm = pft_request->beg_effective_dt_tm
    SET pft_request->org[1].end_effective_dt_tm = pft_request->end_effective_dt_tm
    IF (debug=1)
     CALL echo("pft_request after being loaded by createAcctForOrg()")
     CALL echorecord(pft_request)
    ENDIF
    SET prevtask = reqinfo->updt_task
    SET reqinfo->updt_task = - (4051502)
    EXECUTE pft_add_acct  WITH replace("REQUEST",pft_request), replace("REPLY",pft_reply)
    SET reqinfo->updt_task = prevtask
    IF ((reply->status_data.status="S"))
     SET status = "S"
    ELSE
     SET status = "F"
     SET statusmsg = "Error creating new A/R Client account for organization"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addpprfiltersfororg(null)
   DECLARE client_filter_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30620,
     "ORGCLIENT"))
   DECLARE task_type_filter_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",30620,
     "CS6026"))
   DECLARE facility_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
   DECLARE filtercnt = i4 WITH protect
   DECLARE taskcnt = i4 WITH protect
   RECORD ppr_request(
     1 validate_refdata_ind = i2
     1 delete_all_ind = i2
     1 filter_entity[*]
       2 filter_type_cd = f8
       2 filter_type_data_id = f8
       2 filter_entity1_id = f8
       2 filter_entity1_name = c30
       2 filter_entity2_id = f8
       2 filter_entity2_name = c30
       2 filter_entity3_id = f8
       2 filter_entity3_name = c30
       2 filter_entity4_id = f8
       2 filter_entity4_name = c30
       2 filter_entity5_id = f8
       2 filter_entity5_name = c30
       2 action_flag = i2
       2 safe_for_action = i2
       2 values[*]
         3 parent_entity_id = f8
         3 parent_entity_name = vc
         3 exclusion_filter_ind = i2
         3 beg_effective_dt_tm = dq8
         3 end_effective_dt_tm = dq8
         3 filter_entity_reltn_id = f8
         3 action_flag_values = i2
         3 validated_data = i2
   ) WITH protect
   RECORD ppr_reply(
     1 filter_entity[*]
       2 filter_type_data_id = f8
       2 festatus = i4
       2 feerrnum = i4
       2 feerrmsg = c132
       2 values[*]
         3 filter_entity_reltn_id = f8
         3 valstatus = i4
         3 errnum = i4
         3 errmsg = c132
     1 scriptstatus = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SELECT INTO "nl:"
    FROM filter_entity_reltn fer
    PLAN (fer
     WHERE fer.filter_type_cd=client_filter_type_cd
      AND fer.filter_entity1_name="LOCATION"
      AND fer.parent_entity_name="ORGANIZATION"
      AND (fer.parent_entity_id= $COPYFROMCLIENTORGID))
    DETAIL
     clientfilterind = 1, filtercnt = (filtercnt+ 1), stat = alterlist(ppr_request->filter_entity,
      filtercnt),
     ppr_request->filter_entity[filtercnt].filter_type_cd = client_filter_type_cd, ppr_request->
     filter_entity[filtercnt].filter_entity1_id = fer.filter_entity1_id, ppr_request->filter_entity[
     filtercnt].filter_entity1_name = fer.filter_entity1_name,
     ppr_request->filter_entity[filtercnt].action_flag = 1
     IF (filtercnt=1)
      copyfromfacilitycd = fer.filter_entity1_id
     ENDIF
     stat = alterlist(ppr_request->filter_entity[filtercnt].values,1), ppr_request->filter_entity[
     filtercnt].values[1].parent_entity_id = neworgid, ppr_request->filter_entity[filtercnt].values[1
     ].parent_entity_name = fer.parent_entity_name,
     ppr_request->filter_entity[filtercnt].values[1].action_flag_values = 1
    WITH nocounter
   ;end select
   SET ppr_request->validate_refdata_ind = 1
   SET ppr_request->delete_all_ind = 0
   SELECT INTO "nl:"
    FROM filter_entity_reltn fer,
     code_value cv
    PLAN (fer
     WHERE fer.filter_type_cd=task_type_filter_type_cd
      AND fer.filter_entity1_name="LOCATION"
      AND fer.filter_entity1_id=copyfromfacilitycd
      AND fer.parent_entity_name="CODE_VALUE")
     JOIN (cv
     WHERE cv.code_value=fer.parent_entity_id
      AND cv.active_ind=1)
    ORDER BY cv.display_key
    DETAIL
     taskcnt = (taskcnt+ 1)
     IF (mod(taskcnt,10)=1)
      stat = alterlist(task_types->list,(taskcnt+ 9))
     ENDIF
     task_types->list[taskcnt].task_type_cd = fer.parent_entity_id
    FOOT REPORT
     IF (mod(taskcnt,10) != 0)
      stat = alterlist(task_types->list,taskcnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (taskcnt > 0)
    SET filtercnt = (filtercnt+ 1)
    SET stat = alterlist(ppr_request->filter_entity,filtercnt)
    SET ppr_request->filter_entity[filtercnt].filter_type_cd = task_type_filter_type_cd
    SET ppr_request->filter_entity[filtercnt].filter_entity1_id = newfacilitycd
    SET ppr_request->filter_entity[filtercnt].filter_entity1_name = "LOCATION"
    SET ppr_request->filter_entity[filtercnt].action_flag = 1
    SET stat = alterlist(ppr_request->filter_entity[filtercnt].values,size(task_types->list,5))
    FOR (taskcnt = 1 TO size(task_types->list,5))
      SET ppr_request->filter_entity[filtercnt].values[taskcnt].parent_entity_id = task_types->list[
      taskcnt].task_type_cd
      SET ppr_request->filter_entity[filtercnt].values[taskcnt].parent_entity_name = "CODE_VALUE"
      SET ppr_request->filter_entity[filtercnt].values[taskcnt].action_flag_values = 1
    ENDFOR
   ENDIF
   IF (debug=1)
    CALL echo("ppr_request after being loaded by addPPRFiltersForOrg()")
    CALL echorecord(ppr_request)
   ENDIF
   SET prevtask = reqinfo->updt_task
   SET reqinfo->updt_task = - (4290310)
   EXECUTE ppr_ens_filter_ref  WITH replace("REQUEST",ppr_request), replace("REPLY",ppr_reply)
   SET reqinfo->updt_task = prevtask
   IF ((reply->status_data.status="S"))
    SET status = "S"
   ELSE
    SET status = "F"
    SET statusmsg = "Error creating PPR filters"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SET last_mod = "000"
END GO
