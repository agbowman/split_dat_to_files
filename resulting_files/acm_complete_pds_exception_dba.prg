CREATE PROGRAM acm_complete_pds_exception:dba
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE (loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      CALL echo(build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
        '"',",",option_flag,") not found, CURPROG [",curprog,
        "]"))
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 CALL echo("*****pm_post_doc_subs.inc - 666833*****")
 CALL echo("*****pm_post_doc_recipients.inc - 666833*****")
 CALL echo("*****pm_post_doc_recipients.inc - 792841*****")
 IF ((validate(ipm_logmsg_exists,- (999))=- (999)))
  DECLARE pm_get_error(error=i2) = vc
  DECLARE ipmmsglvl_audit = i2 WITH constant(2)
  DECLARE ipmmsglvl_debug = i2 WITH constant(4)
  DECLARE ipmmsglvl_info = i2 WITH constant(3)
  DECLARE ipmmsglvl_error = i2 WITH constant(0)
  DECLARE ipmmsglvl_warning = i2 WITH constant(1)
  DECLARE pm_log_handle = i4 WITH public, noconstant(0)
  DECLARE pm_log_status = i4 WITH public, noconstant(0)
  DECLARE cscript_name = c32 WITH public, noconstant(" ")
  DECLARE ipm_logmsg_exists = i2 WITH public, noconstant(1)
  SUBROUTINE (pm_logmsg(spm_message=vc,ipm_loglevel=i2) =null)
    IF ((ipm_loglevel > - (1))
     AND textlen(trim(spm_message,3)) > 0)
     CALL uar_syscreatehandle(pm_log_handle,pm_log_status)
     IF (pm_log_handle != 0)
      CALL uar_sysevent(pm_log_handle,ipm_loglevel,cscript_name,nullterm(spm_message))
      CALL uar_sysdestroyhandle(pm_log_handle)
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 SUBROUTINE (prepareejstransaction(hsrvreq=i4(ref),hsrvrep=i4(ref),hsrvmsg=i4(ref),reqnumber=i4) =i2)
   SET hsrvmsg = uar_srvselectmessage(reqnumber)
   IF (hsrvmsg=0)
    RETURN(false)
   ENDIF
   SET hsrvreq = uar_srvcreaterequest(hsrvmsg)
   SET hsrvrep = uar_srvcreatereply(hsrvmsg)
 END ;Subroutine
 SUBROUTINE (cleanupsrvhandles(hsrvreq=i4,hsrvrep=i4,hsrvmsg=i4,hsrvstatus=i4) =i2)
   IF (hsrvreq)
    CALL uar_srvdestroyinstance(hsrvreq)
   ENDIF
   IF (hsrvrep)
    CALL uar_srvdestroyinstance(hsrvrep)
   ENDIF
   IF (hsrvmsg)
    CALL uar_srvdestroyinstance(hsrvmsg)
   ENDIF
   IF (hsrvstatus)
    CALL uar_srvdestroyinstance(hsrvstatus)
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(sch_practice_site_get_by_id_req,0)))
  RECORD sch_practice_site_get_by_id_req(
    1 practicesiteid = f8
  ) WITH protect
 ENDIF
 IF ( NOT (validate(sch_practice_site_get_by_id_rep,0)))
  RECORD sch_practice_site_get_by_id_rep(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 practicesiteid = f8
    1 primaryentityname = vc
    1 primaryentityid = f8
    1 displayname = vc
    1 practicesitetypecd = f8
    1 opendttm = dq8
    1 closedttm = dq8
    1 practicesiteattributes[*]
      2 practicesiteattributecd = f8
    1 relatedorglocations[*]
      2 id = f8
      2 parententityname = vc
      2 isprimary = i2
      2 display = vc
    1 schedulingsystemcd = f8
    1 email = vc
    1 businessaddress[*]
      2 street1 = vc
      2 street2 = vc
      2 street3 = vc
      2 street4 = vc
      2 city = vc
      2 state = vc
      2 country = vc
      2 zipcode = vc
    1 businessphone[*]
      2 phone = vc
      2 extension = vc
      2 formatcd = f8
    1 businessfax[*]
      2 phone = vc
      2 extension = vc
      2 formatcd = f8
    1 appointmenttypesynonyms[*]
      2 appointmenttypesynonymcd = f8
    1 practicesitespecialty[*]
      2 primaryid = i4
      2 practicesitespecialtycd = f8
  ) WITH protect
 ENDIF
 DECLARE retrievepracticesitebyid(null) = null
 SUBROUTINE retrievepracticesitebyid(null)
   DECLARE l_retrieve_practice_site_by_id_req = i4 WITH protect, constant(113325)
   DECLARE hretrievepracticesitebyidsrvmsg = i4 WITH protect, noconstant(0)
   DECLARE hretrievepracticesitebyidsrvreq = i4 WITH protect, noconstant(0)
   DECLARE hretrievepracticesitebyidsrvrep = i4 WITH protect, noconstant(0)
   DECLARE hstatusdata = i4 WITH protect, noconstant(0)
   DECLARE hpracticesitetype = i4 WITH protect, noconstant(0)
   DECLARE hpracticesiteattribute = i4 WITH protect, noconstant(0)
   DECLARE lpracticesiteattrcnt = i4 WITH protect, noconstant(0)
   DECLARE lpracticesiteattridx = i4 WITH protect, noconstant(0)
   DECLARE hrelatedorglocation = i4 WITH protect, noconstant(0)
   DECLARE lrelatedorgloccnt = i4 WITH protect, noconstant(0)
   DECLARE lrelatedorglocidx = i4 WITH protect, noconstant(0)
   DECLARE hschedulingsystem = i4 WITH protect, noconstant(0)
   DECLARE hbusinessaddress = i4 WITH protect, noconstant(0)
   DECLARE lbusinessaddresscnt = i4 WITH protect, noconstant(0)
   DECLARE lbusinessaddressidx = i4 WITH protect, noconstant(0)
   DECLARE hbusinessphone = i4 WITH protect, noconstant(0)
   DECLARE lbusinessphonecnt = i4 WITH protect, noconstant(0)
   DECLARE lbusinessphoneidx = i4 WITH protect, noconstant(0)
   DECLARE hbusinessphoneformat = i4 WITH protect, noconstant(0)
   DECLARE hbusinessfax = i4 WITH protect, noconstant(0)
   DECLARE lbusinessfaxcnt = i4 WITH protect, noconstant(0)
   DECLARE lbusinessfaxidx = i4 WITH protect, noconstant(0)
   DECLARE hbusinessfaxformat = i4 WITH protect, noconstant(0)
   DECLARE happttypesynonym = i4 WITH protect, noconstant(0)
   DECLARE lappttypesyncnt = i4 WITH protect, noconstant(0)
   DECLARE lappttypesynidx = i4 WITH protect, noconstant(0)
   DECLARE hpracsitespecialty = i4 WITH protect, noconstant(0)
   DECLARE lpracsitespecialtycnt = i4 WITH protect, noconstant(0)
   DECLARE lpracsitespecialtyidx = i4 WITH protect, noconstant(0)
   DECLARE hsubeventstatus = i4 WITH protect, noconstant(0)
   DECLARE lsubeventstatuscnt = i4 WITH protect, noconstant(0)
   DECLARE lsubeventstatusidx = i4 WITH protect, noconstant(0)
   DECLARE serrormsg = vc WITH protect, noconstant("")
   DECLARE sscriptmsg = vc WITH protect, noconstant("")
   DECLARE iloglevel = i2 WITH protect, noconstant(ipmmsglvl_error)
   IF ( NOT (prepareejstransaction(hretrievepracticesitebyidsrvreq,hretrievepracticesitebyidsrvrep,
    hretrievepracticesitebyidsrvmsg,l_retrieve_practice_site_by_id_req)))
    SET sscriptmsg = "RetrievePracticeSiteById - Failed to prepare the EJS transaction"
    CALL pm_logmsg(serrormsg,iloglevel)
    RETURN
   ENDIF
   IF ((sch_practice_site_get_by_id_req->practicesiteid > 0))
    CALL uar_srvsetdouble(hretrievepracticesitebyidsrvreq,"practice_site_id",
     sch_practice_site_get_by_id_req->practicesiteid)
   ELSE
    SET sscriptmsg = "RetrievePracticeSiteById - practice site id is invalid"
    CALL pm_logmsg(serrormsg,iloglevel)
    RETURN
   ENDIF
   SET stat = uar_srvexecute(hretrievepracticesitebyidsrvmsg,hretrievepracticesitebyidsrvreq,
    hretrievepracticesitebyidsrvrep)
   IF (stat != 0)
    SET sscriptmsg = concat("RetrievePracticeSiteById - uar_SrvExecute() failed with a ",stat,
     " exit code.")
    CALL pm_logmsg(serrormsg,iloglevel)
    RETURN
   ENDIF
   SET hstatusdata = uar_srvgetstruct(hretrievepracticesitebyidsrvrep,"status_data")
   IF (uar_srvgetstringptr(hstatusdata,"status") != "F")
    SET sch_practice_site_get_by_id_rep->practicesiteid = uar_srvgetdouble(
     hretrievepracticesitebyidsrvrep,"practice_site_id")
    SET sch_practice_site_get_by_id_rep->primaryentityname = uar_srvgetstringptr(
     hretrievepracticesitebyidsrvrep,"primary_entity_name")
    SET sch_practice_site_get_by_id_rep->primaryentityid = uar_srvgetdouble(
     hretrievepracticesitebyidsrvrep,"primary_entity_id")
    SET sch_practice_site_get_by_id_rep->displayname = uar_srvgetstringptr(
     hretrievepracticesitebyidsrvrep,"display_name")
    SET hpracticesitetype = uar_srvgetstruct(hretrievepracticesitebyidsrvrep,"practice_site_type")
    SET sch_practice_site_get_by_id_rep->practicesitetypecd = uar_srvgetdouble(hpracticesitetype,"id"
     )
    SET stat = uar_srvgetdate(hretrievepracticesitebyidsrvrep,nullterm("open_dt_tm"),
     sch_practice_site_get_by_id_rep->opendttm)
    SET stat = uar_srvgetdate(hretrievepracticesitebyidsrvrep,nullterm("close_dt_tm"),
     sch_practice_site_get_by_id_rep->closedttm)
    SET lpracticesiteattrcnt = uar_srvgetitemcount(hretrievepracticesitebyidsrvrep,
     "practice_site_attributes")
    SET stat = alterlist(sch_practice_site_get_by_id_rep->practicesiteattributes,lpracticesiteattrcnt
     )
    FOR (lpracticesiteattridx = 1 TO lpracticesiteattrcnt)
     SET hpracticesiteattribute = uar_srvgetitem(hretrievepracticesitebyidsrvrep,
      "practice_site_attributes",(lpracticesiteattridx - 1))
     SET sch_practice_site_get_by_id_rep->practicesiteattributes[lpracticesiteattridx].
     practicesiteattributecd = uar_srvgetdouble(hpracticesiteattribute,"id")
    ENDFOR
    SET lrelatedorgloccnt = uar_srvgetitemcount(hretrievepracticesitebyidsrvrep,
     "related_org_locations")
    SET stat = alterlist(sch_practice_site_get_by_id_rep->relatedorglocations,lrelatedorgloccnt)
    FOR (lrelatedorglocidx = 1 TO lrelatedorgloccnt)
      SET hrelatedorglocation = uar_srvgetitem(hretrievepracticesitebyidsrvrep,
       "related_org_locations",(lrelatedorglocidx - 1))
      SET sch_practice_site_get_by_id_rep->relatedorglocations[lrelatedorglocidx].id =
      uar_srvgetdouble(hrelatedorglocation,"id")
      SET sch_practice_site_get_by_id_rep->relatedorglocations[lrelatedorglocidx].parententityname =
      uar_srvgetstringptr(hrelatedorglocation,"parent_entity_name")
      SET sch_practice_site_get_by_id_rep->relatedorglocations[lrelatedorglocidx].isprimary =
      uar_srvgetshort(hrelatedorglocation,"isPrimary")
      SET sch_practice_site_get_by_id_rep->relatedorglocations[lrelatedorglocidx].display =
      uar_srvgetstringptr(hrelatedorglocation,"display")
    ENDFOR
    SET hschedulingsystem = uar_srvgetstruct(hretrievepracticesitebyidsrvrep,"scheduling_system")
    SET sch_practice_site_get_by_id_rep->schedulingsystemcd = uar_srvgetdouble(hschedulingsystem,"id"
     )
    SET sch_practice_site_get_by_id_rep->email = uar_srvgetstringptr(hretrievepracticesitebyidsrvrep,
     "email")
    SET lbusinessaddresscnt = uar_srvgetitemcount(hretrievepracticesitebyidsrvrep,"business_address")
    SET stat = alterlist(sch_practice_site_get_by_id_rep->businessaddress,lbusinessaddresscnt)
    FOR (lbusinessaddressidx = 1 TO lbusinessaddresscnt)
      SET hbusinessaddress = uar_srvgetitem(hretrievepracticesitebyidsrvrep,"business_address",(
       lbusinessaddressidx - 1))
      SET sch_practice_site_get_by_id_rep->businessaddress[lbusinessaddressidx].street1 =
      uar_srvgetstringptr(hbusinessaddress,"street1")
      SET sch_practice_site_get_by_id_rep->businessaddress[lbusinessaddressidx].street2 =
      uar_srvgetstringptr(hbusinessaddress,"street2")
      SET sch_practice_site_get_by_id_rep->businessaddress[lbusinessaddressidx].street3 =
      uar_srvgetstringptr(hbusinessaddress,"street3")
      SET sch_practice_site_get_by_id_rep->businessaddress[lbusinessaddressidx].street4 =
      uar_srvgetstringptr(hbusinessaddress,"street4")
      SET sch_practice_site_get_by_id_rep->businessaddress[lbusinessaddressidx].city =
      uar_srvgetstringptr(hbusinessaddress,"city")
      SET sch_practice_site_get_by_id_rep->businessaddress[lbusinessaddressidx].state =
      uar_srvgetstringptr(hbusinessaddress,"state")
      SET sch_practice_site_get_by_id_rep->businessaddress[lbusinessaddressidx].country =
      uar_srvgetstringptr(hbusinessaddress,"country")
      SET sch_practice_site_get_by_id_rep->businessaddress[lbusinessaddressidx].zipcode =
      uar_srvgetstringptr(hbusinessaddress,"zipcode")
    ENDFOR
    SET lbusinessphonecnt = uar_srvgetitemcount(hretrievepracticesitebyidsrvrep,"business_phone")
    SET stat = alterlist(sch_practice_site_get_by_id_rep->businessphone,lbusinessphonecnt)
    FOR (lbusinessphoneidx = 1 TO lbusinessphonecnt)
      SET hbusinessphone = uar_srvgetitem(hretrievepracticesitebyidsrvrep,"business_phone",(
       lbusinessphoneidx - 1))
      SET sch_practice_site_get_by_id_rep->businessphone[lbusinessphoneidx].phone =
      uar_srvgetstringptr(hbusinessphone,"phone")
      SET sch_practice_site_get_by_id_rep->businessphone[lbusinessphoneidx].extension =
      uar_srvgetstringptr(hbusinessphone,"extension")
      SET hbusinessphoneformat = uar_srvgetstruct(hbusinessphone,"format")
      SET sch_practice_site_get_by_id_rep->businessphone[lbusinessphoneidx].formatcd =
      uar_srvgetdouble(hbusinessphoneformat,"id")
    ENDFOR
    SET lbusinessfaxcnt = uar_srvgetitemcount(hretrievepracticesitebyidsrvrep,"business_fax")
    SET stat = alterlist(sch_practice_site_get_by_id_rep->businessfax,lbusinessfaxcnt)
    FOR (lbusinessfaxidx = 1 TO lbusinessfaxcnt)
      SET hbusinessfax = uar_srvgetitem(hretrievepracticesitebyidsrvrep,"business_fax",(
       lbusinessfaxidx - 1))
      SET sch_practice_site_get_by_id_rep->businessfax[lbusinessfaxidx].phone = uar_srvgetstringptr(
       hbusinessfax,"phone")
      SET sch_practice_site_get_by_id_rep->businessfax[lbusinessfaxidx].extension =
      uar_srvgetstringptr(hbusinessfax,"extension")
      SET hbusinessfaxformat = uar_srvgetstruct(hbusinessfax,"format")
      SET sch_practice_site_get_by_id_rep->businessfax[lbusinessfaxidx].formatcd = uar_srvgetdouble(
       hbusinessfaxformat,"id")
    ENDFOR
    SET lappttypesyncnt = uar_srvgetitemcount(hretrievepracticesitebyidsrvrep,
     "appointment_type_synonyms")
    SET stat = alterlist(sch_practice_site_get_by_id_rep->appointmenttypesynonyms,lappttypesyncnt)
    FOR (lappttypesynidx = 1 TO lappttypesyncnt)
     SET happttypesynonym = uar_srvgetitem(hretrievepracticesitebyidsrvrep,
      "appointment_type_synonyms",(lappttypesynidx - 1))
     SET sch_practice_site_get_by_id_rep->appointmenttypesynonyms[lappttypesynidx].
     appointmenttypesynonymcd = uar_srvgetdouble(happttypesynonym,"id")
    ENDFOR
    SET lpracsitespecialtycnt = uar_srvgetitemcount(hretrievepracticesitebyidsrvrep,
     "practice_site_specialty")
    SET stat = alterlist(sch_practice_site_get_by_id_rep->practicesitespecialty,lpracsitespecialtycnt
     )
    FOR (lpracsitespecialtyidx = 1 TO lpracsitespecialtycnt)
      SET hpracsitespecialty = uar_srvgetitem(hretrievepracticesitebyidsrvrep,
       "practice_site_specialty",(lpracsitespecialtyidx - 1))
      SET sch_practice_site_get_by_id_rep->practicesitespecialty[lpracsitespecialtyidx].primaryid =
      uar_srvgetlong(hpracsitespecialty,"primaryId")
      SET sch_practice_site_get_by_id_rep->practicesitespecialty[lpracsitespecialtyidx].
      practicesitespecialtycd = uar_srvgetdouble(hpracsitespecialty,"specialty_cd")
    ENDFOR
    SET sscriptmsg = "RetrievePracticeSiteById - Practice Site retrieved successfully"
    SET iloglevel = ipmmsglvl_info
   ELSE
    SET serrormsg = concat("status: ",uar_srvgetstringptr(hstatusdata,"status"))
    SET serrormsg = concat("codified_failure_reason: ",uar_srvgetstringptr(hstatusdata,
      "codified_failure_reason"),serrormsg)
    SET lsubeventstatuscnt = uar_srvgetitemcount(hstatusdata,"subeventstatus")
    FOR (lsubeventstatusidx = 1 TO lsubeventstatuscnt)
      SET hsubeventstatus = uar_srvgetitem(hstatusdata,"subeventstatus",(lsubeventstatusidx - 1))
      SET serrormsg = concat("OperationName: ",uar_srvgetstringptr(hsubeventstatus,"OperationName"),
       serrormsg)
      SET serrormsg = concat("OperationStatus: ",uar_srvgetstringptr(hsubeventstatus,
        "OperationStatus"),serrormsg)
      SET serrormsg = concat("TargetObjectName: ",uar_srvgetstringptr(hsubeventstatus,
        "TargetObjectName"),serrormsg)
      SET serrormsg = concat("TargetObjectValue: ",uar_srvgetstringptr(hsubeventstatus,
        "TargetObjectValue"),serrormsg)
    ENDFOR
    SET serrormsg = concat("EJS Transaction failed : ",serrormsg)
    CALL pm_logmsg(serrormsg,iloglevel)
    SET sscriptmsg = "RetrievePracticeSiteById - Failed to retrieve practice site"
   ENDIF
   CALL pm_logmsg(serrormsg,iloglevel)
   CALL cleanupsrvhandles(hretrievepracticesitebyidsrvreq,hretrievepracticesitebyidsrvrep,
    hretrievepracticesitebyidsrvmsg,hstatusdata)
 END ;Subroutine
 IF ((validate(ipm_logmsg_exists,- (999))=- (999)))
  DECLARE pm_get_error(error=i2) = vc
  DECLARE ipmmsglvl_audit = i2 WITH constant(2)
  DECLARE ipmmsglvl_debug = i2 WITH constant(4)
  DECLARE ipmmsglvl_info = i2 WITH constant(3)
  DECLARE ipmmsglvl_error = i2 WITH constant(0)
  DECLARE ipmmsglvl_warning = i2 WITH constant(1)
  DECLARE pm_log_handle = i4 WITH public, noconstant(0)
  DECLARE pm_log_status = i4 WITH public, noconstant(0)
  DECLARE cscript_name = c32 WITH public, noconstant(" ")
  DECLARE ipm_logmsg_exists = i2 WITH public, noconstant(1)
  SUBROUTINE (pm_logmsg(spm_message=vc,ipm_loglevel=i2) =null)
    IF ((ipm_loglevel > - (1))
     AND textlen(trim(spm_message,3)) > 0)
     CALL uar_syscreatehandle(pm_log_handle,pm_log_status)
     IF (pm_log_handle != 0)
      CALL uar_sysevent(pm_log_handle,ipm_loglevel,cscript_name,nullterm(spm_message))
      CALL uar_sysdestroyhandle(pm_log_handle)
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(sch_rfrl_get_by_encounter_req,0)))
  RECORD sch_rfrl_get_by_encounter_req(
    1 encounterid = f8
    1 personid = f8
    1 loadindicators
      2 fromreferralind = i2
      2 fromrelatedentity = i2
      2 fromappointment = i2
  ) WITH protect
 ENDIF
 IF ( NOT (validate(sch_rfrl_get_by_encounter_rep,0)))
  RECORD sch_rfrl_get_by_encounter_rep(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 exceptioninformation[*]
      2 exceptiontype = vc
      2 entitytype = vc
      2 entityid = f8
    1 referrals[*]
      2 referralid = f8
      2 encounterassociationtypes
        3 referral = f8
        3 relatedentity = f8
        3 appointment = f8
      2 requestavailability = vc
  ) WITH protect
 ENDIF
 DECLARE retrievereferralsbyencounter(null) = null
 SUBROUTINE retrievereferralsbyencounter(null)
   DECLARE l_retrieve_rfrls_by_encntr_req = i4 WITH protect, constant(113124)
   DECLARE hretrieverfrlsbyencntrsrvmsg = i4 WITH protect, noconstant(0)
   DECLARE hretrieverfrlsbyencntrsrvreq = i4 WITH protect, noconstant(0)
   DECLARE hretrieverfrlsbyencntrsrvrep = i4 WITH protect, noconstant(0)
   DECLARE htransactionstatus = i4 WITH protect, noconstant(0)
   DECLARE hencntrassoctypes = i4 WITH protect, noconstant(0)
   DECLARE hreferral = i4 WITH protect, noconstant(0)
   DECLARE lreferralcnt = i4 WITH protect, noconstant(0)
   DECLARE lreferralidx = i4 WITH protect, noconstant(0)
   DECLARE hexceptioninformation = i4 WITH protect, noconstant(0)
   DECLARE bsuccessindicator = i2 WITH protect, noconstant(false)
   DECLARE serrormsg = vc WITH protect, noconstant("")
   DECLARE sscriptmsg = vc WITH protect, noconstant("")
   DECLARE iloglevel = i2 WITH protect, noconstant(ipmmsglvl_error)
   IF ( NOT (prepareejstransaction(hretrieverfrlsbyencntrsrvreq,hretrieverfrlsbyencntrsrvrep,
    hretrieverfrlsbyencntrsrvmsg,l_retrieve_rfrls_by_encntr_req)))
    SET sscriptmsg = "RetrieveReferralsByEncounter - Failed to prepare the EJS transaction"
    CALL pm_logmsg(sscriptmsg,iloglevel)
    RETURN
   ENDIF
   IF ((sch_rfrl_get_by_encounter_req->encounterid > 0))
    CALL uar_srvsetdouble(hretrieverfrlsbyencntrsrvreq,"encounterId",sch_rfrl_get_by_encounter_req->
     encounterid)
    IF ((sch_rfrl_get_by_encounter_req->personid > 0))
     CALL uar_srvsetdouble(hretrieverfrlsbyencntrsrvreq,"personId",sch_rfrl_get_by_encounter_req->
      personid)
    ENDIF
    SET hloadindicators = uar_srvgetstruct(hretrieverfrlsbyencntrsrvreq,"loadIndicators")
    CALL uar_srvsetshort(hloadindicators,"fromReferralInd",sch_rfrl_get_by_encounter_req->
     loadindicators.fromreferralind)
    CALL uar_srvsetshort(hloadindicators,"fromRelatedEntity",sch_rfrl_get_by_encounter_req->
     loadindicators.fromrelatedentity)
    CALL uar_srvsetshort(hloadindicators,"fromAppointment",sch_rfrl_get_by_encounter_req->
     loadindicators.fromappointment)
   ELSE
    SET sscriptmsg = "RetrieveReferralsByEncounter - encounter id is invalid"
    CALL pm_logmsg(sscriptmsg,iloglevel)
    RETURN
   ENDIF
   SET stat = uar_srvexecute(hretrieverfrlsbyencntrsrvmsg,hretrieverfrlsbyencntrsrvreq,
    hretrieverfrlsbyencntrsrvrep)
   IF (stat != 0)
    SET sscriptmsg = concat("RetrieveReferralsByEncounter - uar_SrvExecute() failed with a ",stat,
     " exit code.")
    CALL pm_logmsg(sscriptmsg,iloglevel)
    RETURN
   ENDIF
   SET htransactionstatus = uar_srvgetstruct(hretrieverfrlsbyencntrsrvrep,"transactionStatus")
   SET bsuccessindicator = uar_srvgetshort(htransactionstatus,"successIndicator")
   IF (bsuccessindicator=true)
    SET lreferralcnt = uar_srvgetitemcount(hretrieverfrlsbyencntrsrvrep,"referrals")
    SET stat = alterlist(sch_rfrl_get_by_encounter_rep->referrals,lreferralcnt)
    FOR (lreferralidx = 1 TO lreferralcnt)
      SET hreferral = uar_srvgetitem(hretrieverfrlsbyencntrsrvrep,"referrals",(lreferralidx - 1))
      SET sch_rfrl_get_by_encounter_rep->referrals[lreferralidx].referralid = uar_srvgetdouble(
       hreferral,"referralId")
      SET hencntrassoctypes = uar_srvgetstruct(hreferral,"encounterAssociationTypes")
      SET sch_rfrl_get_by_encounter_rep->referrals[lreferralidx].encounterassociationtypes.referral
       = uar_srvgetshort(hencntrassoctypes,"referral")
      SET sch_rfrl_get_by_encounter_rep->referrals[lreferralidx].encounterassociationtypes.
      relatedentity = uar_srvgetshort(hencntrassoctypes,"relatedEntity")
      SET sch_rfrl_get_by_encounter_rep->referrals[lreferralidx].encounterassociationtypes.
      appointment = uar_srvgetshort(hencntrassoctypes,"appointment")
      SET sch_rfrl_get_by_encounter_rep->referrals[lreferralidx].requestavailability =
      uar_srvgetstringptr(hreferral,"requestAvailability")
    ENDFOR
    SET sscriptmsg = "RetrieveReferralsByEncounter - Referrals retrieved successfully"
    SET iloglevel = ipmmsglvl_info
   ELSE
    SET serrormsg = uar_srvgetstringptr(htransactionstatus,"debugErrorMessage")
    IF (uar_srvgetitemcount(hretrieverfrlsbyencntrsrvrep,"exceptionInformation")=1)
     SET stat = alterlist(sch_rfrl_get_by_encounter_rep->exceptioninformation,1)
     SET hexceptioninformation = uar_srvgetitem(hretrieverfrlsbyencntrsrvrep,"exceptionInformation",0
      )
     SET sch_rfrl_get_by_encounter_rep->exceptioninformation[1].entityid = uar_srvgetdouble(
      hexceptioninformation,"entityId")
     SET sch_rfrl_get_by_encounter_rep->exceptioninformation[1].entitytype = uar_srvgetstringptr(
      hexceptioninformation,"entityType")
     SET sch_rfrl_get_by_encounter_rep->exceptioninformation[1].exceptiontype = uar_srvgetstringptr(
      hexceptioninformation,"exceptionType")
     SET serrormsg = concat("Entity Id : ",sch_rfrl_get_by_encounter_rep->exceptioninformation[1].
      entityid,serrormsg)
     SET serrormsg = concat("Entity Type : ",sch_rfrl_get_by_encounter_rep->exceptioninformation[1].
      entitytype,serrormsg)
     SET serrormsg = concat("Exception Type : ",sch_rfrl_get_by_encounter_rep->exceptioninformation[1
      ].exceptiontype,serrormsg)
    ENDIF
    SET serrormsg = concat("EJS Transaction failed : ",serrormsg)
    CALL pm_logmsg(serrormsg,iloglevel)
    SET sscriptmsg = "RetrieveReferralsByEncounter - Failed to retrieve referral(s)"
   ENDIF
   CALL pm_logmsg(serrormsg,iloglevel)
   CALL cleanupsrvhandles(hretrieverfrlsbyencntrsrvreq,hretrieverfrlsbyencntrsrvrep,
    hretrieverfrlsbyencntrsrvmsg,htransactionstatus)
 END ;Subroutine
 IF ((validate(ipm_logmsg_exists,- (999))=- (999)))
  DECLARE pm_get_error(error=i2) = vc
  DECLARE ipmmsglvl_audit = i2 WITH constant(2)
  DECLARE ipmmsglvl_debug = i2 WITH constant(4)
  DECLARE ipmmsglvl_info = i2 WITH constant(3)
  DECLARE ipmmsglvl_error = i2 WITH constant(0)
  DECLARE ipmmsglvl_warning = i2 WITH constant(1)
  DECLARE pm_log_handle = i4 WITH public, noconstant(0)
  DECLARE pm_log_status = i4 WITH public, noconstant(0)
  DECLARE cscript_name = c32 WITH public, noconstant(" ")
  DECLARE ipm_logmsg_exists = i2 WITH public, noconstant(1)
  SUBROUTINE (pm_logmsg(spm_message=vc,ipm_loglevel=i2) =null)
    IF ((ipm_loglevel > - (1))
     AND textlen(trim(spm_message,3)) > 0)
     CALL uar_syscreatehandle(pm_log_handle,pm_log_status)
     IF (pm_log_handle != 0)
      CALL uar_sysevent(pm_log_handle,ipm_loglevel,cscript_name,nullterm(spm_message))
      CALL uar_sysdestroyhandle(pm_log_handle)
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(sch_rfrl_get_by_ids_req,0)))
  RECORD sch_rfrl_get_by_ids_req(
    1 referralids[*]
      2 referralid = f8
    1 loadindicators
      2 loadreferraldata = i2
      2 loadrelatedentities = i2
      2 loadordercomment = i2
      2 loadcomments = i2
      2 loaddocuments = i2
      2 loadpatienthealthplanreltninfo = i2
      2 loadhealthplanauthorizationinfo = i2
      2 loadhealthplanauthdetails = i2
      2 loadhealthplanauthcontactphone = i2
      2 loaddiagnoses = i2
      2 loadreferralstatusinfo = i2
      2 loadreferralcustom = i2
  ) WITH protect
 ENDIF
 IF ( NOT (validate(sch_rfrl_get_by_ids_rep,0)))
  RECORD sch_rfrl_get_by_ids_rep(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 exceptioninformation[*]
      2 exceptiontype = vc
      2 entitytype = vc
      2 entityid = f8
    1 referrals[*]
      2 referralid = f8
      2 version = i4
      2 patientid = f8
      2 referralprioritycd = f8
      2 createdatetime = dq8
      2 updatedatetime = dq8
      2 referfromproviderid = f8
      2 referfromprovidername = vc
      2 refertoproviderid = f8
      2 refertoprovidername = vc
      2 referfromorganizationid = f8
      2 referfromorganizationname = vc
      2 referfrompracticesiteid = f8
      2 referfrompracticesitename = vc
      2 refertoorganizationid = f8
      2 refertoorganizationname = vc
      2 refertopracticesiteid = f8
      2 refertopracticesitename = vc
      2 medicalservicecd = f8
      2 referralreason = vc
      2 referralstatuscd = f8
      2 externalscheduleddatetime = dq8
      2 admitbookingtypecd = f8
      2 createsystemcd = f8
      2 referralwrittendatetime = dq8
      2 referralreceiveddatetime = dq8
      2 referralsourcecd = f8
      2 waitstatuscd = f8
      2 servicetyperequestedcd = f8
      2 standbycd = f8
      2 suspectedcancertypecd = f8
      2 intendedbookingtypecd = f8
      2 treatmentcompleteddatetime = dq8
      2 responsibleproviderid = f8
      2 requestedstartdatetime = dq8
      2 servicebydatetime = dq8
      2 servicecategorycd = f8
      2 instructionstostaff = vc
      2 treatmenttodate = vc
      2 waitlistremovaldatetime = dq8
      2 outboundencounterid = f8
      2 orderid = f8
      2 inboundassignedpersonnelid = f8
      2 inboundassignedpersonnelname = vc
      2 outboundassignedpersonnelid = f8
      2 outboundassignedpersonnelname = vc
      2 referfromlocationid = f8
      2 referfromlocationname = vc
      2 healthcareguaranteedatetime = dq8
      2 administrativeproblemcd = f8
      2 waittimedays = i4
      2 inboundencounterids[*]
        3 inboundencounterid = f8
      2 schedulingeventids[*]
        3 schedulingeventid = f8
      2 ordercomment = vc
      2 comments[*]
        3 id = f8
        3 typemeaning = vc
        3 commenttext = vc
        3 creationuseridentifier = vc
        3 creationusername = vc
        3 lastmodificationuseridentifier = vc
        3 lastmodificationusername = vc
        3 creationdatetime = dq8
        3 lastmodificationdatetime = dq8
      2 documents[*]
        3 id = f8
        3 eventid = f8
        3 mediaobjectidentifier = vc
        3 mediaobjectversion = i4
        3 blobhandle = gvc
        3 createdatetime = dq8
        3 displayname = vc
      2 patienthealthplanreltns[*]
        3 id = f8
        3 patienthealthplanreltnid = f8
        3 priority = i4
        3 healthplanid = f8
        3 healthplanname = vc
        3 healthplanauthorizations[*]
          4 id = f8
          4 servicebegindatetime = dq8
          4 serviceenddatetime = dq8
          4 typemeaning = vc
          4 authorizationnumber = vc
          4 numberauthorized = i4
          4 numberauthorizedqualifiercd = f8
          4 authorizationstatuscd = f8
          4 servicetypecd = f8
          4 contactname = vc
          4 formatcd = f8
          4 number = vc
          4 extension = vc
          4 formattednumber = vc
      2 diagnoses[*]
        3 id = f8
        3 nomenclatureid = f8
        3 nomenclaturesourceidentifier = vc
        3 nomenclaturedescription = vc
        3 priority = i4
      2 referralstatuscd = f8
      2 codifiedactionreason = f8
      2 freetextactionreason = vc
      2 actiondatetime = dq8
      2 referralsubstatuscd = f8
      2 referralcustomfields[*]
        3 referralcustomfieldid = f8
        3 referralcustomfieldkey = vc
        3 referralcustomfieldvaluetype = vc
        3 referralcustomvaluestring = vc
        3 referralcustomvaluedouble = f8
        3 referralcustomvaluedate = dq8
        3 referralcustomvalueboolean = i2
        3 referralcustomversion = i4
  ) WITH protect
 ENDIF
 DECLARE retrievereferralsbyids(null) = null
 SUBROUTINE retrievereferralsbyids(null)
   DECLARE l_retrieve_rfrls_by_ids_req = i4 WITH protect, constant(113120)
   DECLARE hretrieverfrlsbyidssrvmsg = i4 WITH protect, noconstant(0)
   DECLARE hretrieverfrlsbyidssrvreq = i4 WITH protect, noconstant(0)
   DECLARE hretrieverfrlsbyidssrvrep = i4 WITH protect, noconstant(0)
   DECLARE hauthdetailsloadindicators = i4 WITH protect, noconstant(0)
   DECLARE hauthorizationloadindicators = i4 WITH protect, noconstant(0)
   DECLARE hhealthplanreltnloadindicators = i4 WITH protect, noconstant(0)
   DECLARE hloadindicators = i4 WITH protect, noconstant(0)
   DECLARE hreferrallist = i4 WITH protect, noconstant(0)
   DECLARE hreferrals = i4 WITH protect, noconstant(0)
   DECLARE lreferralscnt = i4 WITH protect, noconstant(0)
   DECLARE lreferralsidx = i4 WITH protect, noconstant(0)
   DECLARE hreferral = i4 WITH protect, noconstant(0)
   DECLARE hrelatedentities = i4 WITH protect, noconstant(0)
   DECLARE hinboundencounterid = i4 WITH protect, noconstant(0)
   DECLARE linboundencounteridscnt = i4 WITH protect, noconstant(0)
   DECLARE linboundencounteridsidx = i4 WITH protect, noconstant(0)
   DECLARE hschedulingeventid = i4 WITH protect, noconstant(0)
   DECLARE lschedulingeventidscnt = i4 WITH protect, noconstant(0)
   DECLARE lschedulingeventidsidx = i4 WITH protect, noconstant(0)
   DECLARE hordercomment = i4 WITH protect, noconstant(0)
   DECLARE hcomment = i4 WITH protect, noconstant(0)
   DECLARE lcommentscnt = i4 WITH protect, noconstant(0)
   DECLARE lcommentsidx = i4 WITH protect, noconstant(0)
   DECLARE hdocument = i4 WITH protect, noconstant(0)
   DECLARE ldocumentscnt = i4 WITH protect, noconstant(0)
   DECLARE ldocumentsidx = i4 WITH protect, noconstant(0)
   DECLARE hpatienthealthplanreltns = i4 WITH protect, noconstant(0)
   DECLARE lpatienthealthplanreltnscnt = i4 WITH protect, noconstant(0)
   DECLARE lpatienthealthplanreltnsidx = i4 WITH protect, noconstant(0)
   DECLARE hpatienthealthplanreltninfo = i4 WITH protect, noconstant(0)
   DECLARE hhealthplanauthorizations = i4 WITH protect, noconstant(0)
   DECLARE lhealthplanauthorizationscnt = i4 WITH protect, noconstant(0)
   DECLARE lhealthplanauthorizationsidx = i4 WITH protect, noconstant(0)
   DECLARE hhealthplanauthorizationinfo = i4 WITH protect, noconstant(0)
   DECLARE hhealthplanauthorizationdetails = i4 WITH protect, noconstant(0)
   DECLARE hhealthplanauthdetailsinfo = i4 WITH protect, noconstant(0)
   DECLARE hhealthplanauthcontactphone = i4 WITH protect, noconstant(0)
   DECLARE hdiagnosis = i4 WITH protect, noconstant(0)
   DECLARE ldiagnosescnt = i4 WITH protect, noconstant(0)
   DECLARE ldiagnosesidx = i4 WITH protect, noconstant(0)
   DECLARE hreferralstatusinfo = i4 WITH protect, noconstant(0)
   DECLARE hreferralcustomfield = i4 WITH protect, noconstant(0)
   DECLARE lreferralcustomfieldscnt = i4 WITH protect, noconstant(0)
   DECLARE lreferralcustomfieldsidx = i4 WITH protect, noconstant(0)
   DECLARE hexceptioninformation = i4 WITH protect, noconstant(0)
   DECLARE htransactionstatus = i4 WITH protect, noconstant(0)
   DECLARE bsuccessindicator = i2 WITH protect, noconstant(false)
   DECLARE serrormsg = vc WITH protect, noconstant("")
   DECLARE sscriptmsg = vc WITH protect, noconstant("")
   DECLARE iloglevel = i2 WITH protect, noconstant(ipmmsglvl_error)
   IF ( NOT (prepareejstransaction(hretrieverfrlsbyidssrvreq,hretrieverfrlsbyidssrvrep,
    hretrieverfrlsbyidssrvmsg,l_retrieve_rfrls_by_ids_req)))
    SET sscriptmsg = "RetrieveReferralsByIds - Failed to prepare the EJS transaction"
    CALL pm_logmsg(sscriptmsg,iloglevel)
    RETURN
   ENDIF
   FOR (lreferralsidx = 1 TO size(sch_rfrl_get_by_ids_req->referralids,5))
     IF ((sch_rfrl_get_by_ids_req->referralids[lreferralsidx].referralid > 0))
      SET hreferrallist = uar_srvadditem(hretrieverfrlsbyidssrvreq,"referralIds")
      CALL uar_srvsetdouble(hreferrallist,"referralId",sch_rfrl_get_by_ids_req->referralids[
       lreferralsidx].referralid)
     ELSE
      SET sscriptmsg = "RetrieveReferralsByIds - Referral ID is invalid"
      CALL pm_logmsg(sscriptmsg,iloglevel)
      RETURN
     ENDIF
   ENDFOR
   SET hloadindicators = uar_srvgetstruct(hretrieverfrlsbyidssrvreq,"loadIndicators")
   CALL uar_srvsetshort(hloadindicators,"loadReferralData",sch_rfrl_get_by_ids_req->loadindicators.
    loadreferraldata)
   CALL uar_srvsetshort(hloadindicators,"loadRelatedEntities",sch_rfrl_get_by_ids_req->loadindicators
    .loadrelatedentities)
   CALL uar_srvsetshort(hloadindicators,"loadOrderComment",sch_rfrl_get_by_ids_req->loadindicators.
    loadordercomment)
   CALL uar_srvsetshort(hloadindicators,"loadComments",sch_rfrl_get_by_ids_req->loadindicators.
    loadcomments)
   CALL uar_srvsetshort(hloadindicators,"loadDocuments",sch_rfrl_get_by_ids_req->loadindicators.
    loaddocuments)
   SET hhealthplanreltnloadindicators = uar_srvgetstruct(hloadindicators,
    "healthPlanReltnLoadIndicators")
   CALL uar_srvsetshort(hhealthplanreltnloadindicators,"loadPatientHealthPlanReltnInfo",
    sch_rfrl_get_by_ids_req->loadindicators.loadpatienthealthplanreltninfo)
   SET hauthorizationloadindicators = uar_srvgetstruct(hhealthplanreltnloadindicators,
    "authorizationLoadIndicators")
   CALL uar_srvsetshort(hauthorizationloadindicators,"loadHealthPlanAuthorizationInfo",
    sch_rfrl_get_by_ids_req->loadindicators.loadhealthplanauthorizationinfo)
   SET hauthdetailsloadindicators = uar_srvgetstruct(hauthorizationloadindicators,
    "authDetailsLoadIndicators")
   CALL uar_srvsetshort(hauthdetailsloadindicators,"loadHealthPlanAuthDetails",
    sch_rfrl_get_by_ids_req->loadindicators.loadhealthplanauthdetails)
   CALL uar_srvsetshort(hauthdetailsloadindicators,"loadHealthPlanAuthContactPhone",
    sch_rfrl_get_by_ids_req->loadindicators.loadhealthplanauthcontactphone)
   CALL uar_srvsetshort(hloadindicators,"loadDiagnoses",sch_rfrl_get_by_ids_req->loadindicators.
    loaddiagnoses)
   CALL uar_srvsetshort(hloadindicators,"loadReferralStatusInfo",sch_rfrl_get_by_ids_req->
    loadindicators.loadreferralstatusinfo)
   CALL uar_srvsetshort(hloadindicators,"loadReferralCustom",sch_rfrl_get_by_ids_req->loadindicators.
    loadreferralcustom)
   SET stat = uar_srvexecute(hretrieverfrlsbyidssrvmsg,hretrieverfrlsbyidssrvreq,
    hretrieverfrlsbyidssrvrep)
   IF (stat != 0)
    SET sscriptmsg = concat("RetrieveReferralsByIds - uar_SrvExecute() failed with a ",stat,
     " exit code.")
    CALL pm_logmsg(sscriptmsg,iloglevel)
    RETURN
   ENDIF
   SET htransactionstatus = uar_srvgetstruct(hretrieverfrlsbyidssrvrep,"transactionStatus")
   SET bsuccessindicator = uar_srvgetshort(htransactionstatus,"successIndicator")
   IF (bsuccessindicator=true)
    SET lreferralscnt = uar_srvgetitemcount(hretrieverfrlsbyidssrvrep,"referrals")
    SET stat = alterlist(sch_rfrl_get_by_ids_rep->referrals,lreferralscnt)
    FOR (lreferralsidx = 1 TO lreferralscnt)
      SET hreferrals = uar_srvgetitem(hretrieverfrlsbyidssrvrep,"referrals",(lreferralsidx - 1))
      SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralid = uar_srvgetdouble(hreferrals,
       "referralId")
      SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].version = uar_srvgetlong(hreferrals,
       "version")
      SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patientid = uar_srvgetdouble(hreferrals,
       "patientId")
      IF (uar_srvgetitemcount(hreferrals,"referral")=1)
       SET hreferral = uar_srvgetitem(hreferrals,"referral",0)
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralprioritycd = uar_srvgetdouble(
        hreferral,"referralPriorityCd")
       SET stat = uar_srvgetdate(hreferral,nullterm("createDateTime"),sch_rfrl_get_by_ids_rep->
        referrals[lreferralsidx].createdatetime)
       SET stat = uar_srvgetdate(hreferral,nullterm("updateDateTime"),sch_rfrl_get_by_ids_rep->
        referrals[lreferralsidx].updatedatetime)
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referfromproviderid = uar_srvgetdouble(
        hreferral,"referFromProviderId")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referfromprovidername =
       uar_srvgetstringptr(hreferral,"referFromProviderName")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].refertoproviderid = uar_srvgetdouble(
        hreferral,"referToProviderId")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].refertoprovidername =
       uar_srvgetstringptr(hreferral,"referToProviderName")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referfromorganizationid =
       uar_srvgetdouble(hreferral,"referFromOrganizationId")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referfromorganizationname =
       uar_srvgetstringptr(hreferral,"referFromOrganizationName")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referfrompracticesiteid =
       uar_srvgetdouble(hreferral,"referFromPracticeSiteId")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referfrompracticesitename =
       uar_srvgetstringptr(hreferral,"referFromPracticeSiteName")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].refertoorganizationid = uar_srvgetdouble
       (hreferral,"referToOrganizationId")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].refertoorganizationname =
       uar_srvgetstringptr(hreferral,"referToOrganizationName")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].refertopracticesiteid = uar_srvgetdouble
       (hreferral,"referToPracticeSiteId")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].refertopracticesitename =
       uar_srvgetstringptr(hreferral,"referToPracticeSiteName")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].medicalservicecd = uar_srvgetdouble(
        hreferral,"medicalServiceCd")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralreason = uar_srvgetstringptr(
        hreferral,"referralReason")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralstatuscd = uar_srvgetdouble(
        hreferral,"referralStatusCd")
       SET stat = uar_srvgetdate(hreferral,nullterm("externalScheduledDateTime"),
        sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].externalscheduleddatetime)
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].admitbookingtypecd = uar_srvgetdouble(
        hreferral,"admitBookingTypeCd")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].createsystemcd = uar_srvgetdouble(
        hreferral,"createSystemCd")
       SET stat = uar_srvgetdate(hreferral,nullterm("referralWrittenDateTime"),
        sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralwrittendatetime)
       SET stat = uar_srvgetdate(hreferral,nullterm("referralReceivedDateTime"),
        sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralreceiveddatetime)
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralsourcecd = uar_srvgetdouble(
        hreferral,"referralSourceCd")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].waitstatuscd = uar_srvgetdouble(
        hreferral,"waitStatusCd")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].servicetyperequestedcd =
       uar_srvgetdouble(hreferral,"serviceTypeRequestedCd")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].standbycd = uar_srvgetdouble(hreferral,
        "standByCd")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].suspectedcancertypecd = uar_srvgetdouble
       (hreferral,"suspectedCancerTypeCd")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].intendedbookingtypecd = uar_srvgetdouble
       (hreferral,"intendedBookingTypeCd")
       SET stat = uar_srvgetdate(hreferral,nullterm("treatmentCompletedDateTime"),
        sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].treatmentcompleteddatetime)
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].responsibleproviderid = uar_srvgetdouble
       (hreferral,"responsibleProviderId")
       SET stat = uar_srvgetdate(hreferral,nullterm("requestedStartDateTime"),sch_rfrl_get_by_ids_rep
        ->referrals[lreferralsidx].requestedstartdatetime)
       SET stat = uar_srvgetdate(hreferral,nullterm("serviceByDateTime"),sch_rfrl_get_by_ids_rep->
        referrals[lreferralsidx].servicebydatetime)
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].servicecategorycd = uar_srvgetdouble(
        hreferral,"serviceCategoryCd")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].instructionstostaff =
       uar_srvgetstringptr(hreferral,"instructionsToStaff")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].treatmenttodate = uar_srvgetstringptr(
        hreferral,"treatmentToDate")
       SET stat = uar_srvgetdate(hreferral,nullterm("waitlistRemovalDateTime"),
        sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].waitlistremovaldatetime)
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].outboundencounterid = uar_srvgetdouble(
        hreferral,"outboundEncounterId")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].orderid = uar_srvgetdouble(hreferral,
        "orderId")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].inboundassignedpersonnelid =
       uar_srvgetdouble(hreferral,"inboundAssignedPersonnelId")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].inboundassignedpersonnelname =
       uar_srvgetstringptr(hreferral,"inboundAssignedPersonnelName")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].outboundassignedpersonnelid =
       uar_srvgetdouble(hreferral,"outboundAssignedPersonnelId")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].outboundassignedpersonnelname =
       uar_srvgetstringptr(hreferral,"outboundAssignedPersonnelName")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referfromlocationid = uar_srvgetdouble(
        hreferral,"referFromLocationId")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referfromlocationname =
       uar_srvgetstringptr(hreferral,"referFromLocationName")
       SET stat = uar_srvgetdate(hreferral,nullterm("healthcareGuaranteeDateTime"),
        sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].healthcareguaranteedatetime)
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].administrativeproblemcd =
       uar_srvgetdouble(hreferral,"administrativeProblemCd")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].waittimedays = uar_srvgetlong(hreferral,
        "waitTimeDays")
      ENDIF
      IF (uar_srvgetitemcount(hreferrals,"relatedEntities")=1)
       SET hrelatedentities = uar_srvgetitem(hreferrals,"relatedEntities",0)
       SET linboundencounteridscnt = uar_srvgetitemcount(hrelatedentities,"inboundEncounterIds")
       IF (linboundencounteridscnt > 0)
        SET stat = alterlist(sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].inboundencounterids,
         linboundencounteridscnt)
        FOR (linboundencounteridsidx = 1 TO linboundencounteridscnt)
         SET hinboundencounterid = uar_srvgetitem(hrelatedentities,"inboundEncounterIds",(
          linboundencounteridsidx - 1))
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].inboundencounterids[
         linboundencounteridsidx].inboundencounterid = uar_srvgetdouble(hinboundencounterid,
          "inboundEncounterId")
        ENDFOR
       ENDIF
       SET lschedulingeventidscnt = uar_srvgetitemcount(hrelatedentities,"schedulingEventIds")
       IF (lschedulingeventidscnt > 0)
        SET stat = alterlist(sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].schedulingeventids,
         lschedulingeventidscnt)
        FOR (lschedulingeventidsidx = 1 TO lschedulingeventidscnt)
         SET hschedulingeventid = uar_srvgetitem(hrelatedentities,"schedulingEventIds",(
          lschedulingeventidsidx - 1))
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].schedulingeventids[
         lschedulingeventidsidx].schedulingeventid = uar_srvgetdouble(hschedulingeventid,
          "schedulingEventId")
        ENDFOR
       ENDIF
      ENDIF
      IF (uar_srvgetitemcount(hreferrals,"orderComment")=1)
       SET hordercomment = uar_srvgetitem(hreferrals,"orderComment",0)
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].ordercomment = uar_srvgetstringptr(
        hordercomment,"orderComment")
      ENDIF
      SET lcommentscnt = uar_srvgetitemcount(hreferrals,"comments")
      IF (lcommentscnt > 0)
       SET stat = alterlist(sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].comments,lcommentscnt)
       FOR (lcommentsidx = 1 TO lcommentscnt)
         SET hcomment = uar_srvgetitem(hreferrals,"comments",(lcommentsidx - 1))
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].comments[lcommentsidx].id =
         uar_srvgetdouble(hcomment,"id")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].comments[lcommentsidx].typemeaning =
         uar_srvgetstringptr(hcomment,"typeMeaning")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].comments[lcommentsidx].commenttext =
         uar_srvgetstringptr(hcomment,"commentText")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].comments[lcommentsidx].
         creationuseridentifier = uar_srvgetstringptr(hcomment,"creationUserIdentifier")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].comments[lcommentsidx].
         creationusername = uar_srvgetstringptr(hcomment,"creationUserName")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].comments[lcommentsidx].
         lastmodificationuseridentifier = uar_srvgetstringptr(hcomment,
          "lastModificationUserIdentifier")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].comments[lcommentsidx].
         lastmodificationusername = uar_srvgetstringptr(hcomment,"lastModificationUserName")
         SET stat = uar_srvgetdate(hcomment,nullterm("creationDateTime"),sch_rfrl_get_by_ids_rep->
          referrals[lreferralsidx].comments[lcommentsidx].creationdatetime)
         SET stat = uar_srvgetdate(hcomment,nullterm("lastModificationDateTime"),
          sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].comments[lcommentsidx].
          lastmodificationdatetime)
       ENDFOR
      ENDIF
      SET ldocumentscnt = uar_srvgetitemcount(hreferrals,"documents")
      IF (ldocumentscnt > 0)
       SET stat = alterlist(sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].documents,ldocumentscnt
        )
       FOR (ldocumentsidx = 1 TO ldocumentscnt)
         SET hdocument = uar_srvgetitem(hreferrals,"documents",(ldocumentsidx - 1))
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].documents[ldocumentsidx].id =
         uar_srvgetdouble(hdocument,"id")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].documents[ldocumentsidx].eventid =
         uar_srvgetdouble(hdocument,"eventId")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].documents[ldocumentsidx].
         mediaobjectidentifier = uar_srvgetstringptr(hdocument,"mediaObjectIdentifier")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].documents[ldocumentsidx].
         mediaobjectversion = uar_srvgetlong(hdocument,"mediaObjectVersion")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].documents[ldocumentsidx].blobhandle =
         uar_srvgetstringptr(hdocument,"blobHandle")
         SET stat = uar_srvgetdate(hdocument,nullterm("createDateTime"),sch_rfrl_get_by_ids_rep->
          referrals[lreferralsidx].documents[ldocumentsidx].createdatetime)
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].documents[ldocumentsidx].displayname
          = uar_srvgetstringptr(hdocument,"displayName")
       ENDFOR
      ENDIF
      SET lpatienthealthplanreltnscnt = uar_srvgetitemcount(hreferrals,"patientHealthPlanReltns")
      IF (lpatienthealthplanreltnscnt > 0)
       SET stat = alterlist(sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns,
        lpatienthealthplanreltnscnt)
       FOR (lpatienthealthplanreltnsidx = 1 TO lpatienthealthplanreltnscnt)
         SET hpatienthealthplanreltns = uar_srvgetitem(hreferrals,"patientHealthPlanReltns",(
          lpatienthealthplanreltnsidx - 1))
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
         lpatienthealthplanreltnsidx].id = uar_srvgetdouble(hpatienthealthplanreltns,"id")
         IF (uar_srvgetitemcount(hpatienthealthplanreltns,"patientHealthPlanReltnInfo")=1)
          SET hpatienthealthplanreltninfo = uar_srvgetitem(hpatienthealthplanreltns,
           "patientHealthPlanReltnInfo",0)
          SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
          lpatienthealthplanreltnsidx].patienthealthplanreltnid = uar_srvgetdouble(
           hpatienthealthplanreltninfo,"patientHealthPlanReltnId")
          SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
          lpatienthealthplanreltnsidx].priority = uar_srvgetlong(hpatienthealthplanreltninfo,
           "priority")
          SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
          lpatienthealthplanreltnsidx].healthplanid = uar_srvgetdouble(hpatienthealthplanreltninfo,
           "healthPlanId")
          SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
          lpatienthealthplanreltnsidx].healthplanname = uar_srvgetstringptr(
           hpatienthealthplanreltninfo,"healthPlanName")
         ENDIF
         SET lhealthplanauthorizationscnt = uar_srvgetitemcount(hreferrals,"healthPlanAuthorizations"
          )
         IF (lhealthplanauthorizationscnt > 0)
          SET stat = alterlist(sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].
           healthplanauthorizations,lhealthplanauthorizationscnt)
          FOR (lhealthplanauthorizationsidx = 1 TO lhealthplanauthorizationscnt)
            SET hhealthplanauthorizations = uar_srvgetitem(hpatienthealthplanreltns,
             "healthPlanAuthorizations",(lhealthplanauthorizationsidx - 1))
            SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].healthplanauthorizations[
            lhealthplanauthorizationsidx].id = uar_srvgetdouble(healthplanauthorizations,"id")
            IF (uar_srvgetitemcount(hhealthplanauthorizations,"healthPlanAuthorizationInfo")=1)
             SET hhealthplanauthorizationinfo = uar_srvgetitem(hhealthplanauthorizations,
              "healthPlanAuthorizationInfo",0)
             SET stat = uar_srvgetdate(hhealthplanauthorizationinfo,nullterm("serviceBeginDateTime"),
              sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
              lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
              servicebegindatetime)
             SET stat = uar_srvgetdate(hhealthplanauthorizationinfo,nullterm("serviceEndDateTime"),
              sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
              lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
              serviceenddatetime)
             SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
             lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
             typemeaning = uar_srvgetstringptr(hhealthplanauthorizationinfo,"typeMeaning")
             SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
             lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
             authorizationnumber = uar_srvgetstringptr(hhealthplanauthorizationinfo,
              "authorizationNumber")
             SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
             lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
             numberauthorized = uar_srvgetlong(hhealthplanauthorizationinfo,"numberAuthorized")
             SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
             lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
             numberauthorizedqualifiercd = uar_srvgetdouble(hhealthplanauthorizationinfo,
              "numberAuthorizedQualifierCd")
             SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
             lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
             authorizationstatuscd = uar_srvgetdouble(hhealthplanauthorizationinfo,
              "authorizationStatusCd")
             SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
             lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
             servicetypecd = uar_srvgetdouble(hhealthplanauthorizationinfo,"serviceTypeCd")
            ENDIF
            IF (uar_srvgetitemcount(hhealthplanauthorizations,"healthPlanAuthorizationDetails")=1)
             SET hhealthplanauthorizationdetails = uar_srvgetitem(hhealthplanauthorizations,
              "healthPlanAuthorizationDetails",0)
             IF (uar_srvgetitemcount(hhealthplanauthorizationdetails,"healthPlanAuthDetailsInfo")=1)
              SET hhealthplanauthdetailsinfo = uar_srvgetitem(hhealthplanauthorizationdetails,
               "healthPlanAuthDetailsInfo",0)
              SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
              lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
              contactname = uar_srvgetstringptr(hhealthplanauthdetailsinfo,"contactName")
             ENDIF
             IF (uar_srvgetitemcount(hhealthplanauthorizationdetails,"healthPlanAuthContactPhone")=1)
              SET hhealthplanauthcontactphone = uar_srvgetitem(hhealthplanauthorizationdetails,
               "healthPlanAuthContactPhone",0)
              SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
              lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
              formatcd = uar_srvgetdouble(hhealthplanauthcontactphone,"formatCd")
              SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
              lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
              number = uar_srvgetstringptr(hhealthplanauthcontactphone,"number")
              SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
              lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
              extension = uar_srvgetstringptr(hhealthplanauthcontactphone,"extension")
              SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].patienthealthplanreltns[
              lpatienthealthplanreltnsidx].healthplanauthorizations[lhealthplanauthorizationsidx].
              formattednumber = uar_srvgetstringptr(hhealthplanauthcontactphone,"formattedNumber")
             ENDIF
            ENDIF
          ENDFOR
         ENDIF
       ENDFOR
      ENDIF
      SET ldiagnosescnt = uar_srvgetitemcount(hreferrals,"diagnoses")
      IF (ldiagnosescnt > 0)
       SET stat = alterlist(sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].diagnoses,ldiagnosescnt
        )
       FOR (ldiagnosesidx = 1 TO ldiagnosescnt)
         SET hdiagnosis = uar_srvgetitem(hreferrals,"diagnoses",(ldiagnosesidx - 1))
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].diagnoses[ldiagnosesidx].id =
         uar_srvgetdouble(hdiagnosis,"id")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].diagnoses[ldiagnosesidx].
         nomenclatureid = uar_srvgetdouble(hdiagnosis,"nomenclatureId")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].diagnoses[ldiagnosesidx].
         nomenclaturesourceidentifier = uar_srvgetstringptr(hdiagnosis,"nomenclatureSourceIdentifier"
          )
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].diagnoses[ldiagnosesidx].
         nomenclaturedescription = uar_srvgetstringptr(hdiagnosis,"nomenclatureDescription")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].diagnoses[ldiagnosesidx].priority =
         uar_srvgetlong(hdiagnosis,"priority")
       ENDFOR
      ENDIF
      IF (uar_srvgetitemcount(hreferrals,"referralStatusInfo")=1)
       SET hreferralstatusinfo = uar_srvgetitem(hreferrals,"referralStatusInfo",0)
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralstatuscd = uar_srvgetdouble(
        hreferralstatusinfo,"referralStatusCd")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].codifiedactionreason = uar_srvgetdouble(
        hreferralstatusinfo,"codifiedActionReason")
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].freetextactionreason =
       uar_srvgetstringptr(hreferralstatusinfo,"freetextActionReason")
       SET stat = uar_srvgetdate(hreferralstatusinfo,nullterm("actionDateTime"),
        sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].actiondatetime)
       SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralsubstatuscd = uar_srvgetdouble(
        hreferralstatusinfo,"referralSubstatusCd")
      ENDIF
      SET lreferralcustomfieldscnt = uar_srvgetitemcount(hreferrals,"referralCustomFields")
      IF (lreferralcustomfieldscnt > 0)
       SET stat = alterlist(sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralcustomfields,
        lreferralcustomfieldscnt)
       FOR (lreferralcustomfieldsidx = 1 TO lreferralcustomfieldscnt)
         SET hreferralcustomfield = uar_srvgetitem(hreferrals,"referralCustomFields",(
          lreferralcustomfieldsidx - 1))
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralcustomfields[
         lreferralcustomfieldsidx].referralcustomfieldid = uar_srvgetdouble(hreferralcustomfield,
          "referralCustomFieldId")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralcustomfields[
         lreferralcustomfieldsidx].referralcustomfieldkey = uar_srvgetstringptr(hreferralcustomfield,
          "referralCustomFieldKey")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralcustomfields[
         lreferralcustomfieldsidx].referralcustomfieldvaluetype = uar_srvgetstringptr(
          hreferralcustomfield,"referralCustomFieldValueType")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralcustomfields[
         lreferralcustomfieldsidx].referralcustomvaluestring = uar_srvgetstringptr(
          hreferralcustomfield,"referralCustomValueString")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralcustomfields[
         lreferralcustomfieldsidx].referralcustomvaluedouble = uar_srvgetdouble(hreferralcustomfield,
          "referralCustomValueDouble")
         SET stat = uar_srvgetdate(hreferralcustomfield,nullterm("referralCustomValueDate"),
          sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralcustomfields[
          lreferralcustomfieldsidx].referralcustomvaluedate)
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralcustomfields[
         lreferralcustomfieldsidx].referralcustomvalueboolean = uar_srvgetshort(hreferralcustomfield,
          "referralCustomValueBoolean")
         SET sch_rfrl_get_by_ids_rep->referrals[lreferralsidx].referralcustomfields[
         lreferralcustomfieldsidx].referralcustomversion = uar_srvgetlong(hreferralcustomfield,
          "referralCustomVersion")
       ENDFOR
      ENDIF
    ENDFOR
    SET sscriptmsg = "RetrieveReferralsByIds - Referrals successfully retrieved"
    SET iloglevel = ipmmsglvl_info
   ELSE
    SET serrormsg = uar_srvgetstringptr(htransactionstatus,"debugErrorMessage")
    IF (uar_srvgetitemcount(hretrieverfrlsbyidssrvrep,"exceptionInformation")=1)
     SET stat = alterlist(sch_rfrl_get_by_ids_rep->exceptioninformation,1)
     SET hexceptioninformation = uar_srvgetitem(hretrieverfrlsbyidssrvrep,"exceptionInformation",0)
     SET sch_rfrl_get_by_ids_rep->exceptioninformation[1].entityid = uar_srvgetdouble(
      hexceptioninformation,"entityId")
     SET sch_rfrl_get_by_ids_rep->exceptioninformation[1].entitytype = uar_srvgetstringptr(
      hexceptioninformation,"entityType")
     SET sch_rfrl_get_by_ids_rep->exceptioninformation[1].exceptiontype = uar_srvgetstringptr(
      hexceptioninformation,"exceptionType")
     SET serrormsg = concat("Entity Id : ",sch_rfrl_get_by_ids_rep->exceptioninformation[1].entityid,
      serrormsg)
     SET serrormsg = concat("Entity Type : ",sch_rfrl_get_by_ids_rep->exceptioninformation[1].
      entitytype,serrormsg)
     SET serrormsg = concat("Exception Type : ",sch_rfrl_get_by_ids_rep->exceptioninformation[1].
      exceptiontype,serrormsg)
    ENDIF
    SET serrormsg = concat("EJS Transaction failed : ",serrormsg)
    CALL pm_logmsg(serrormsg,iloglevel)
    SET sscriptmsg = "RetrieveReferralsByIds - Failed to retrieve referral(s)"
   ENDIF
   CALL pm_logmsg(sscriptmsg,iloglevel)
   CALL cleanupsrvhandles(hretrieverfrlsbyidssrvreq,hretrieverfrlsbyidssrvrep,
    hretrieverfrlsbyidssrvmsg,htransactionstatus)
 END ;Subroutine
 IF ( NOT (validate(related_person_info,0)))
  RECORD related_person_info(
    1 related_person_count = i4
    1 related_persons[*]
      2 related_person_id = f8
  ) WITH protect
 ENDIF
 SUBROUTINE (fillrelatedpersonid(dpersonid=f8) =null)
   DECLARE dcopycorrespondenceyescode = f8 WITH protect, noconstant(0.0)
   SET stat = initrec(related_person_info)
   SET stat = uar_get_meaning_by_codeset(23044,"YES",1,dcopycorrespondenceyescode)
   SELECT DISTINCT INTO "nl:"
    ppr.related_person_id
    FROM person_person_reltn ppr
    WHERE ppr.person_id=dpersonid
     AND ppr.copy_correspondence_cd=dcopycorrespondenceyescode
     AND ppr.active_ind=1
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate)
    DETAIL
     related_person_info->related_person_count += 1, stat = alterlist(related_person_info->
      related_persons,related_person_info->related_person_count), related_person_info->
     related_persons[related_person_info->related_person_count].related_person_id = ppr
     .related_person_id
    WITH nocounter
   ;end select
   IF (bdebugme)
    IF (curqual > 0)
     CALL echo("** related_person_info record. FillRelatedPersonId subroutine. **")
     CALL echorecord(related_person_info)
    ELSE
     CALL echo("** No rows qualified for Related Persons. Exiting FillRelatedPersonId subroutine. **"
      )
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (getreferralidbyencounter(dpersonid=f8,dencounterid=f8) =f8)
   DECLARE dreferralid = f8 WITH protect, noconstant(0.0)
   SET stat = initrec(sch_rfrl_get_by_encounter_req)
   SET sch_rfrl_get_by_encounter_req->encounterid = dencounterid
   SET sch_rfrl_get_by_encounter_req->personid = dpersonid
   SET sch_rfrl_get_by_encounter_req->loadindicators.fromreferralind = 1
   SET sch_rfrl_get_by_encounter_req->loadindicators.fromrelatedentity = 1
   SET sch_rfrl_get_by_encounter_req->loadindicators.fromappointment = 1
   CALL retrievereferralsbyencounter(null)
   IF ((sch_rfrl_get_by_encounter_rep->status_data.status="F"))
    IF (bdebugme)
     CALL echo("** Failed to retrieve Referral Id. **")
    ENDIF
   ELSEIF ((sch_rfrl_get_by_encounter_rep->referrals[1].referralid > 0))
    SET dreferralid = sch_rfrl_get_by_encounter_rep->referrals[1].referralid
   ELSEIF (bdebugme)
    CALL echo("** Invalid Referral Id. Exiting GetReferralIdByEncounter subroutine. **")
   ENDIF
   RETURN(dreferralid)
 END ;Subroutine
 SUBROUTINE (getreferfromorganizationid(dreferralid=f8) =f8)
   DECLARE dreferfromorganizationid = f8 WITH protect, noconstant(0.0)
   SET stat = initrec(sch_rfrl_get_by_ids_req)
   SET stat = alterlist(sch_rfrl_get_by_ids_req->referralids,1)
   SET sch_rfrl_get_by_ids_req->referralids[1].referralid = dreferralid
   SET sch_rfrl_get_by_ids_req->loadindicators.loadreferraldata = 1
   SET sch_rfrl_get_by_ids_req->loadindicators.loadcomments = 1
   SET sch_rfrl_get_by_ids_req->loadindicators.loadreferralstatusinfo = 1
   CALL retrievereferralsbyids(null)
   IF ((sch_rfrl_get_by_ids_rep->status_data.status="F"))
    IF (bdebugme)
     CALL echo(
      "** Failed to retrieve Referral Information. Exiting GetReferFromOrganizationId subroutine. **"
      )
    ENDIF
   ELSEIF (size(sch_rfrl_get_by_ids_rep->referrals,5) > 0)
    IF ((sch_rfrl_get_by_ids_rep->referrals[1].referfromorganizationid > 0))
     SET dreferfromorganizationid = sch_rfrl_get_by_ids_rep->referrals[1].referfromorganizationid
    ELSEIF ((sch_rfrl_get_by_ids_rep->referrals[1].referfrompracticesiteid > 0))
     SET dreferfromorganizationid = getpracticesiteorganizationid(sch_rfrl_get_by_ids_rep->referrals[
      1].referfrompracticesiteid)
    ELSEIF (bdebugme)
     CALL echo(
      "** Invalid ReferFromOrganization Id. Exiting GetReferFromOrganizationId subroutine. **")
    ENDIF
   ELSEIF (bdebugme)
    CALL echo(
     "** Failed to retrieve Referral Information. Exiting GetReferFromOrganizationId subroutine. **")
   ENDIF
   RETURN(dreferfromorganizationid)
 END ;Subroutine
 SUBROUTINE (getpracticesiteorganizationid(drefertopracticesiteid=f8) =f8)
   DECLARE dpracticesiteorganizationid = f8 WITH protect, noconstant(0.0)
   SET stat = initrec(sch_practice_site_get_by_id_req)
   SET sch_practice_site_get_by_id_req->practicesiteid = drefertopracticesiteid
   CALL retrievepracticesitebyid(null)
   IF (size(sch_practice_site_get_by_id_rep->relatedorglocations,5) > 0
    AND (sch_practice_site_get_by_id_rep->relatedorglocations[1].id > 0))
    SET dpracticesiteorganizationid = sch_practice_site_get_by_id_rep->relatedorglocations[1].id
   ELSE
    IF (bdebugme)
     CALL echo(
      "** Invalid Practice Site Organization Id. Exiting GetPracticeSiteOrganizationId subroutine. **"
      )
    ENDIF
   ENDIF
   RETURN(dpracticesiteorganizationid)
 END ;Subroutine
 SUBROUTINE (getreferringorganizationid(dpersonid=f8,dencounterid=f8) =f8)
   DECLARE dreferralid = f8 WITH protect, noconstant(0.0)
   DECLARE dreferringorganizationid = f8 WITH protect, noconstant(0.0)
   IF (((dpersonid=0.0) OR (dencounterid=0.0)) )
    IF (bdebugme)
     CALL echo(
      "** Invalid Person Id or Encounter Id. Exiting GetReferringOrganizationId subroutine. **")
    ENDIF
    RETURN(dreferringorganizationid)
   ENDIF
   SET dreferralid = getreferralidbyencounter(dpersonid,dencounterid)
   IF (dreferralid > 0)
    SET dreferringorganizationid = getreferfromorganizationid(dreferralid)
   ELSEIF (bdebugme)
    CALL echo("** No valid Referral Found. Exiting GetReferringOrganizationId subroutine. **")
   ENDIF
   RETURN(dreferringorganizationid)
 END ;Subroutine
 SUBROUTINE (getpcporganizationid(dpersonid=f8) =f8)
   DECLARE dprimarycarephysiciancode = f8 WITH protect, noconstant(0.0)
   DECLARE dregpracticecode = f8 WITH protect, noconstant(0.0)
   DECLARE dpcporganizationid = f8 WITH protect, noconstant(0.0)
   SET stat = uar_get_meaning_by_codeset(331,"PCP",1,dprimarycarephysiciancode)
   SET stat = uar_get_meaning_by_codeset(338,"REGPRACTICE",1,dregpracticecode)
   SELECT INTO "nl:"
    FROM person_prsnl_reltn ppr,
     person_org_reltn por
    PLAN (ppr
     WHERE ppr.person_id=dpersonid
      AND ppr.person_prsnl_r_cd=dprimarycarephysiciancode
      AND ppr.active_ind=1
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (por
     WHERE por.person_id=ppr.person_id
      AND por.person_org_reltn_cd=dregpracticecode
      AND por.active_ind=1
      AND por.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     dpcporganizationid = por.organization_id
    WITH nocounter
   ;end select
   IF (bdebugme
    AND curqual=0)
    CALL echo(
     "** No rows qualified for PCP Organization. Exiting GetPCPOrganizationId subroutine. **")
   ENDIF
   RETURN(dpcporganizationid)
 END ;Subroutine
 IF ((validate(bpostdocsubinc,- (9))=- (9)))
  DECLARE bpostdocsubinc = i2 WITH noconstant(false)
  FREE RECORD my_flex_rules
  RECORD my_flex_rules(
    1 mode = i4
    1 qual_cnt = i4
    1 qual[*]
      2 sch_flex_id = f8
      2 mnemonic = vc
      2 description = vc
      2 flex_type_cd = f8
      2 flex_type_meaning = vc
      2 info_sch_text_id = f8
      2 info_sch_text = vc
      2 text_updt_cnt = i4
      2 updt_cnt = i4
      2 active_ind = i2
      2 candidate_id = f8
      2 pft_ruleset_grouping = i2
      2 token_qual_cnt = i4
      2 token_qual[*]
        3 updt_cnt = i4
        3 seq_nbr = i4
        3 flex_orient_cd = f8
        3 flex_orient_mean = c12
        3 flex_token_cd = f8
        3 flex_token_disp = vc
        3 flex_token_mean = c12
        3 token_type_cd = f8
        3 token_type_meaning = c12
        3 data_type_cd = f8
        3 data_type_meaning = c12
        3 data_source_cd = f8
        3 data_source_meaning = c12
        3 flex_eval_cd = f8
        3 flex_eval_meaning = c12
        3 precedence = i4
        3 dynamic_text = vc
        3 oe_field_id = f8
        3 filter_id = f8
        3 filter_table = vc
        3 oe_field_display = vc
        3 dt_tm_value = dq8
        3 string_value = vc
        3 double_value = f8
        3 parent_table = vc
        3 parent_id = f8
        3 parent_meaning = c12
        3 display_table = vc
        3 display_id = f8
        3 display_meaning = c12
        3 mnemonic = vc
        3 description = vc
        3 font_size = i4
        3 font_name = vc
        3 bold = i4
        3 italic = i4
        3 strikethru = i4
        3 underline = i4
        3 candidate_id = f8
        3 offset_units = i4
        3 offset_units_cd = f8
        3 offset_units_meaning = c12
        3 dynamic_xml_text = gvc
        3 found = i2
        3 udf_double_value = f8
        3 udf_string_value = vc
        3 udf_dt_tm_value = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
  IF ((validate(bdebugme,- (9))=- (9)))
   DECLARE bdebugme = i2 WITH noconstant(false)
  ENDIF
  SUBROUTINE (s_queuemsg(s_null_index=i2) =vc)
    DECLARE smessage = vc WITH protect, noconstant("<ConfirmReq>")
    SET smessage = build(smessage,"<PDSInfo>")
    SET smessage = build(smessage,"<DomainName>")
    SET smessage = build(smessage,reqdata->domain)
    SET smessage = build(smessage,"</DomainName>")
    SET smessage = build(smessage,"<FromOrganizationId>")
    SET smessage = build(smessage,val_reply->def_org_id)
    SET smessage = build(smessage,"</FromOrganizationId>")
    SET smessage = build(smessage,"<NHSNumber>")
    SET smessage = build(smessage,val_reply->nhs_number)
    SET smessage = build(smessage,"</NHSNumber>")
    SET smessage = build(smessage,"</PDSInfo>")
    SET smessage = build(smessage,"<PostDocInfo>")
    SET smessage = build(smessage,"<PersonId>")
    SET smessage = build(smessage,val_req->person_id)
    SET smessage = build(smessage,"</PersonId>")
    SET smessage = build(smessage,"<EncntrId>")
    IF ((val_req->encntr_id > 0.0))
     SET smessage = build(smessage,val_req->encntr_id)
    ELSE
     SET smessage = build(smessage,"0")
    ENDIF
    SET smessage = build(smessage,"</EncntrId>")
    SET smessage = build(smessage,"<PMPostDocId>")
    SET smessage = build(smessage,pdr_reply->list[lfor].pm_post_doc_ref_id)
    SET smessage = build(smessage,"</PMPostDocId>")
    SET smessage = build(smessage,"<DocObjName>")
    SET smessage = build(smessage,pdr_reply->list[lfor].document_object_name)
    SET smessage = build(smessage,"</DocObjName>")
    SET smessage = build(smessage,"<ActionObjName>")
    SET smessage = build(smessage,pdr_reply->list[lfor].action_object_name)
    SET smessage = build(smessage,"</ActionObjName>")
    SET smessage = build(smessage,"<PrintInd>")
    SET smessage = build(smessage,pdr_reply->list[lfor].batch_print_ind)
    SET smessage = build(smessage,"</PrintInd>")
    SET smessage = build(smessage,"<NumCopies>")
    SET smessage = build(smessage,pdr_reply->list[lfor].copies_nbr)
    SET smessage = build(smessage,"</NumCopies>")
    SET smessage = build(smessage,"<OutputDestCd>")
    IF ((pdr_reply->list[lfor].output_dest_cd > 0.0))
     SET smessage = build(smessage,pdr_reply->list[lfor].output_dest_cd)
    ELSE
     SET smessage = build(smessage,"0")
    ENDIF
    SET smessage = build(smessage,"</OutputDestCd>")
    SET smessage = build(smessage,"</PostDocInfo>")
    SET smessage = build(smessage,"</ConfirmReq>")
    RETURN(smessage)
  END ;Subroutine
  IF ((validate(pm_get_pds_pref_def,- (9))=- (9)))
   DECLARE pm_get_pds_pref_def = i2 WITH constant(0)
   IF ((validate(dq_parser_rec->buffer_count,- (99))=- (99)))
    CALL echo("*****inside pm_dynamic_query include file *****")
    FREE RECORD dq_parser_rec
    RECORD dq_parser_rec(
      1 buffer_count = i2
      1 plan_count = i2
      1 set_count = i2
      1 table_count = i2
      1 with_count = i2
      1 buffer[*]
        2 line = vc
    )
    SET dq_parser_rec->buffer_count = 0
    SET dq_parser_rec->plan_count = 0
    SET dq_parser_rec->set_count = 0
    SET dq_parser_rec->table_count = 0
    SET dq_parser_rec->with_count = 0
    DECLARE dq_add_detail(dqad_dummy) = null
    DECLARE dq_add_footer(dqaf_target) = null
    DECLARE dq_add_header(dqah_target) = null
    DECLARE dq_add_line(dqal_line) = null
    DECLARE dq_get_line(dqgl_idx) = vc
    DECLARE dq_upt_line(dqul_idx,dqul_line) = null
    DECLARE dq_add_planjoin(dqap_range) = null
    DECLARE dq_add_set(dqas_to,dqas_from) = null
    DECLARE dq_add_table(dqat_table_name,dqat_table_alias) = null
    DECLARE dq_add_with(dqaw_control_option) = null
    DECLARE dq_begin_insert(dqbi_dummy) = null
    DECLARE dq_begin_select(dqbs_distinct_ind,dqbs_output_device) = null
    DECLARE dq_begin_update(dqbu_dummy) = null
    DECLARE dq_echo_query(dqeq_level) = null
    DECLARE dq_end_query(dqes_dummy) = null
    DECLARE dq_execute(dqe_reset) = null
    DECLARE dq_reset_query(dqrb_dummy) = null
    SUBROUTINE dq_add_detail(dqad_dummy)
      CALL dq_add_line("detail")
    END ;Subroutine
    SUBROUTINE dq_add_footer(dqaf_target)
      IF (size(trim(dqaf_target),1) > 0)
       CALL dq_add_line(concat("foot ",dqaf_target))
      ELSE
       CALL dq_add_line("foot report")
      ENDIF
    END ;Subroutine
    SUBROUTINE dq_add_header(dqah_target)
      IF (size(trim(dqah_target),1) > 0)
       CALL dq_add_line(concat("head ",dqah_target))
      ELSE
       CALL dq_add_line("head report")
      ENDIF
    END ;Subroutine
    SUBROUTINE dq_add_line(dqal_line)
      SET dq_parser_rec->buffer_count += 1
      IF (mod(dq_parser_rec->buffer_count,10)=1)
       SET stat = alterlist(dq_parser_rec->buffer,(dq_parser_rec->buffer_count+ 9))
      ENDIF
      SET dq_parser_rec->buffer[dq_parser_rec->buffer_count].line = trim(dqal_line,3)
    END ;Subroutine
    SUBROUTINE dq_get_line(dqgl_idx)
      IF (dqgl_idx > 0
       AND dqgl_idx <= size(dq_parser_rec->buffer,5))
       RETURN(dq_parser_rec->buffer[dqgl_idx].line)
      ENDIF
    END ;Subroutine
    SUBROUTINE dq_upt_line(dqul_idx,dqul_line)
      IF (dqul_idx > 0
       AND dqul_idx <= size(dq_parser_rec->buffer,5))
       SET dq_parser_rec->buffer[dqul_idx].line = dqul_line
      ENDIF
    END ;Subroutine
    SUBROUTINE dq_add_planjoin(dqap_range)
      DECLARE dqap_str = vc WITH private, noconstant(" ")
      IF ((dq_parser_rec->plan_count > 0))
       SET dqap_str = "join"
      ELSE
       SET dqap_str = "plan"
      ENDIF
      IF (size(trim(dqap_range),1) > 0)
       CALL dq_add_line(concat(dqap_str," ",dqap_range," where"))
       SET dq_parser_rec->plan_count += 1
      ELSE
       CALL dq_add_line("where ")
      ENDIF
    END ;Subroutine
    SUBROUTINE dq_add_set(dqas_to,dqas_from)
     IF ((dq_parser_rec->set_count > 0))
      CALL dq_add_line(concat(",",dqas_to," = ",dqas_from))
     ELSE
      CALL dq_add_line(concat("set ",dqas_to," = ",dqas_from))
     ENDIF
     SET dq_parser_rec->set_count += 1
    END ;Subroutine
    SUBROUTINE dq_add_table(dqat_table_name,dqat_table_alias)
      DECLARE dqat_str = vc WITH private, noconstant(" ")
      IF ((dq_parser_rec->table_count > 0))
       SET dqat_str = concat(" , ",dqat_table_name)
      ELSE
       SET dqat_str = concat(" from ",dqat_table_name)
      ENDIF
      IF (size(trim(dqat_table_alias),1) > 0)
       SET dqat_str = concat(dqat_str," ",dqat_table_alias)
      ENDIF
      SET dq_parser_rec->table_count += 1
      CALL dq_add_line(dqat_str)
    END ;Subroutine
    SUBROUTINE dq_add_with(dqaw_control_option)
     IF ((dq_parser_rec->with_count > 0))
      CALL dq_add_line(concat(",",dqaw_control_option))
     ELSE
      CALL dq_add_line(concat("with ",dqaw_control_option))
     ENDIF
     SET dq_parser_rec->with_count += 1
    END ;Subroutine
    SUBROUTINE dq_begin_insert(dqbi_dummy)
     CALL dq_reset_query(1)
     CALL dq_add_line("insert")
    END ;Subroutine
    SUBROUTINE dq_begin_select(dqbs_distinct_ind,dqbs_output_device)
      DECLARE dqbs_str = vc WITH noconstant(" ")
      CALL dq_reset_query(1)
      IF (dqbs_distinct_ind=0)
       SET dqbs_str = "select"
      ELSE
       SET dqbs_str = "select distinct"
      ENDIF
      IF (size(trim(dqbs_output_device),1) > 0)
       SET dqbs_str = concat(dqbs_str," into ",dqbs_output_device)
      ENDIF
      CALL dq_add_line(dqbs_str)
    END ;Subroutine
    SUBROUTINE dq_begin_update(dqbu_dummy)
     CALL dq_reset_query(1)
     CALL dq_add_line("update")
    END ;Subroutine
    SUBROUTINE dq_echo_query(dqeq_level)
      DECLARE dqeq_i = i4 WITH private, noconstant(0)
      DECLARE dqeq_j = i4 WITH private, noconstant(0)
      IF (dqeq_level=1)
       CALL echo("-------------------------------------------------------------------")
       CALL echo("Parser Buffer Echo:")
       CALL echo("-------------------------------------------------------------------")
       FOR (dqeq_i = 1 TO dq_parser_rec->buffer_count)
         CALL echo(dq_parser_rec->buffer[dqeq_i].line)
       ENDFOR
       CALL echo("-------------------------------------------------------------------")
      ELSEIF (dqeq_level=2)
       IF (validate(reply->debug[1].line,"-9") != "-9")
        SET dqeq_j = size(reply->debug,5)
        SET stat = alterlist(reply->debug,((dqeq_j+ size(dq_parser_rec->buffer,5))+ 4))
        SET reply->debug[(dqeq_j+ 1)].line =
        "-------------------------------------------------------------------"
        SET reply->debug[(dqeq_j+ 2)].line = "Parser Buffer Echo:"
        SET reply->debug[(dqeq_j+ 3)].line =
        "-------------------------------------------------------------------"
        FOR (dqeq_i = 1 TO dq_parser_rec->buffer_count)
          SET reply->debug[((dqeq_j+ dqeq_i)+ 3)].line = dq_parser_rec->buffer[dqeq_i].line
        ENDFOR
        SET reply->debug[((dqeq_j+ dq_parser_rec->buffer_count)+ 4)].line =
        "-------------------------------------------------------------------"
       ENDIF
      ENDIF
    END ;Subroutine
    SUBROUTINE dq_end_query(dqes_dummy)
     CALL dq_add_line(" go")
     SET stat = alterlist(dq_parser_rec->buffer,dq_parser_rec->buffer_count)
    END ;Subroutine
    SUBROUTINE dq_execute(dqe_reset)
      IF (checkprg("PM_DQ_EXECUTE_PARSER") > 0)
       EXECUTE pm_dq_execute_parser  WITH replace("TEMP_DQ_PARSER_REC","DQ_PARSER_REC")
       IF (dqe_reset=1)
        SET stat = initrec(dq_parser_rec)
       ENDIF
      ELSE
       DECLARE dqe_i = i4 WITH private, noconstant(0)
       FOR (dqe_i = 1 TO dq_parser_rec->buffer_count)
         CALL parser(dq_parser_rec->buffer[dqe_i].line,1)
       ENDFOR
       IF (dqe_reset=1)
        CALL dq_reset_query(1)
       ENDIF
      ENDIF
    END ;Subroutine
    SUBROUTINE dq_reset_query(dqrb_dummy)
      SET stat = alterlist(dq_parser_rec->buffer,0)
      SET dq_parser_rec->buffer_count = 0
      SET dq_parser_rec->plan_count = 0
      SET dq_parser_rec->set_count = 0
      SET dq_parser_rec->table_count = 0
      SET dq_parser_rec->with_count = 0
    END ;Subroutine
   ENDIF
   IF ((validate(pm_create_req_def,- (9))=- (9)))
    DECLARE pm_create_req_def = i2 WITH constant(0)
    DECLARE cr_hmsg = i4 WITH noconstant(0)
    DECLARE cr_hmsgtype = i4 WITH noconstant(0)
    DECLARE cr_hinst = i4 WITH noconstant(0)
    DECLARE cr_hitem = i4 WITH noconstant(0)
    DECLARE cr_llevel = i4 WITH noconstant(0)
    DECLARE cr_lcnt = i4 WITH noconstant(0)
    DECLARE cr_lcharlen = i4 WITH noconstant(0)
    DECLARE cr_siterator = i4 WITH noconstant(0)
    DECLARE cr_lfieldtype = i4 WITH noconstant(0)
    DECLARE cr_sfieldname = vc WITH noconstant(" ")
    DECLARE cr_blist = i2 WITH noconstant(false)
    DECLARE cr_bfound = i2 WITH noconstant(false)
    DECLARE cr_esrvstring = i4 WITH constant(1)
    DECLARE cr_esrvshort = i4 WITH constant(2)
    DECLARE cr_esrvlong = i4 WITH constant(3)
    DECLARE cr_esrvdouble = i4 WITH constant(6)
    DECLARE cr_esrvasis = i4 WITH constant(7)
    DECLARE cr_esrvlist = i4 WITH constant(8)
    DECLARE cr_esrvstruct = i4 WITH constant(9)
    DECLARE cr_esrvuchar = i4 WITH constant(10)
    DECLARE cr_esrvulong = i4 WITH constant(12)
    DECLARE cr_esrvdate = i4 WITH constant(13)
    FREE RECORD cr_stack
    RECORD cr_stack(
      1 list[10]
        2 hinst = i4
        2 siterator = i4
    )
    SUBROUTINE (cr_createrequest(mode=i2,req_id=i4,req_name=vc) =i2)
      SET cr_llevel = 1
      CALL dq_reset_query(null)
      CALL dq_add_line(concat("free record ",req_name," go"))
      CALL dq_add_line(concat("record ",req_name))
      CALL dq_add_line("(")
      SET cr_hmsg = uar_srvselectmessage(req_id)
      IF (cr_hmsg != 0)
       IF (mode=0)
        SET cr_hinst = uar_srvcreaterequest(cr_hmsg)
       ELSE
        SET cr_hinst = uar_srvcreatereply(cr_hmsg)
       ENDIF
      ELSE
       SET reply->status_data.operationname = "INVALID_hMsg"
       SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
       RETURN(false)
      ENDIF
      IF (cr_hinst > 0)
       SET cr_sfieldname = uar_srvfirstfield(cr_hinst,cr_siterator)
       SET cr_sfieldname = trim(cr_sfieldname,3)
       CALL cr_pushstack(cr_hinst,cr_siterator)
      ELSE
       SET reply->status_data.operationname = "INVALID_hInst"
       SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
       IF (cr_hinst)
        CALL uar_srvdestroyinstance(cr_hinst)
        SET cr_hinst = 0
       ENDIF
       RETURN(false)
      ENDIF
      WHILE (textlen(cr_sfieldname) > 0)
        SET cr_lfieldtype = uar_srvgettype(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname))
        CASE (cr_lfieldtype)
         OF cr_esrvstruct:
          SET cr_hitem = 0
          SET cr_hitem = uar_srvgetstruct(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname))
          IF (cr_hitem > 0)
           SET cr_siterator = 0
           CALL cr_pushstack(cr_hitem,cr_siterator)
           CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname))
           SET cr_llevel += 1
           SET cr_blist = true
          ELSE
           SET reply->status_data.operationname = "INVALID_hItem"
           SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
           SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
           IF (cr_hinst)
            CALL uar_srvdestroyinstance(cr_hinst)
            SET cr_hinst = 0
           ENDIF
           RETURN(false)
          ENDIF
         OF cr_esrvlist:
          SET cr_hitem = 0
          SET cr_hitem = uar_srvadditem(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname))
          IF (cr_hitem > 0)
           SET cr_siterator = 0
           CALL cr_pushstack(cr_hitem,cr_siterator)
           CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname,"[*]"))
           SET cr_llevel += 1
           SET cr_blist = true
          ELSE
           SET reply->status_data.operationname = "INVALID_hInst"
           SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
           SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
           IF (cr_hinst)
            CALL uar_srvdestroyinstance(cr_hinst)
            SET cr_hinst = 0
           ENDIF
           RETURN(false)
          ENDIF
         OF cr_esrvstring:
          SET cr_lcharlen = uar_srvgetstringmax(cr_stack->list[cr_lcnt].hinst,nullterm(cr_sfieldname)
           )
          IF (cr_lcharlen > 0)
           CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = c",cnvtstring(
              cr_lcharlen)))
          ELSE
           CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = vc"))
          ENDIF
         OF cr_esrvuchar:
          CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = c1"))
         OF cr_esrvshort:
          CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = i2"))
         OF cr_esrvlong:
          CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = i4"))
         OF cr_esrvulong:
          CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = ui4"))
         OF cr_esrvdouble:
          CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = f8"))
         OF cr_esrvdate:
          CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = dq8"))
         OF cr_esrvasis:
          CALL dq_add_line(concat(cnvtstring(cr_llevel)," ",cr_sfieldname," = gvc"))
         ELSE
          SET reply->status_data.operationname = "INVALID_SrvType"
          SET reply->status_data.subeventstatus[1].targetobjectname = "CREATE_REQUEST"
          SET reply->status_data.subeventstatus[1].targetobjectvalue = "GET"
          IF (cr_hinst)
           CALL uar_srvdestroyinstance(cr_hinst)
           SET cr_hinst = 0
          ENDIF
          RETURN(false)
        ENDCASE
        SET cr_sfieldname = ""
        IF (cr_blist)
         SET cr_sfieldname = uar_srvfirstfield(cr_stack->list[cr_lcnt].hinst,cr_stack->list[cr_lcnt].
          siterator)
         SET cr_sfieldname = trim(cr_sfieldname,3)
         SET cr_blist = false
        ELSE
         SET cr_sfieldname = uar_srvnextfield(cr_stack->list[cr_lcnt].hinst,cr_stack->list[cr_lcnt].
          siterator)
         SET cr_sfieldname = trim(cr_sfieldname,3)
         IF (textlen(cr_sfieldname) <= 0)
          SET cr_bfound = false
          WHILE (cr_bfound != true)
            CALL cr_popstack(null)
            IF ((cr_stack->list[cr_lcnt].hinst > 0)
             AND cr_lcnt > 0)
             SET cr_sfieldname = uar_srvnextfield(cr_stack->list[cr_lcnt].hinst,cr_stack->list[
              cr_lcnt].siterator)
             SET cr_sfieldname = trim(cr_sfieldname,3)
            ELSE
             SET cr_bfound = true
            ENDIF
            IF (textlen(cr_sfieldname) > 0)
             SET cr_bfound = true
            ENDIF
          ENDWHILE
         ENDIF
        ENDIF
      ENDWHILE
      IF (mode=1)
       CALL dq_add_line("1  status_data")
       CALL dq_add_line("2  status  = c1")
       CALL dq_add_line("2  subeventstatus[1]")
       CALL dq_add_line("3  operationname = c15")
       CALL dq_add_line("3  operationstatus = c1")
       CALL dq_add_line("3  targetobjectname = c15")
       CALL dq_add_line("3  targetobjectvalue = vc")
      ENDIF
      CALL dq_add_line(")  with persistscript")
      CALL dq_end_query(null)
      CALL dq_execute(null)
      IF (cr_hinst)
       CALL uar_srvdestroyinstance(cr_hinst)
       SET cr_hinst = 0
      ENDIF
      RETURN(true)
    END ;Subroutine
    SUBROUTINE (cr_popstack(dummyvar=i2) =null)
     SET cr_lcnt -= 1
     SET cr_llevel -= 1
    END ;Subroutine
    SUBROUTINE (cr_pushstack(hval=i4,lval=i4) =null)
      SET cr_lcnt += 1
      IF (mod(cr_lcnt,10)=1
       AND cr_lcnt != 1)
       SET stat = alterlist(cr_stack->list,(cr_lcnt+ 9))
      ENDIF
      SET cr_stack->list[cr_lcnt].hinst = hval
      SET cr_stack->list[cr_lcnt].siterator = lval
    END ;Subroutine
   ENDIF
   SUBROUTINE (getpdsorgpref(dorgid=f8,bpdsmsg=i2(ref),bpdsconfirm=i2(ref)) =null)
     DECLARE bpmprefcreatereq = i2 WITH noconstant(false), private
     DECLARE ltotalpref = i4 WITH noconstant(0), private
     DECLARE ltotalentry = i4 WITH noconstant(0), private
     DECLARE ltotalvalue = i4 WITH noconstant(0), private
     DECLARE svalue = vc WITH noconstant(""), private
     DECLARE sorgid = vc WITH noconstant(""), private
     DECLARE lpos = i2 WITH noconstant(0), private
     SET bpdsmsg = false
     SET bpdsconfirm = false
     SET bpmprefcreatereq = cr_createrequest(0,4299400,"pref_request")
     IF (bpmprefcreatereq != true)
      RETURN(false)
     ENDIF
     SET stat = alterlist(pref_request->pref,1)
     SET stat = alterlist(pref_request->pref[1].contexts,2)
     SET pref_request->pref[1].contexts[1].context = "organization"
     SET sorgid = build(dorgid)
     SET lpos = findstring(".",sorgid,1,1)
     SET pref_request->pref[1].contexts[1].context_id = build(substring(1,lpos,sorgid),"00")
     SET pref_request->pref[1].contexts[2].context = "default"
     SET pref_request->pref[1].contexts[2].context_id = "system"
     SET pref_request->pref[1].section = "workflow"
     SET pref_request->pref[1].section_id = "pds messages"
     SET stat = alterlist(pref_request->pref[1].entries,2)
     SET pref_request->pref[1].entries[1].entry = "pds messaging"
     SET pref_request->pref[1].entries[2].entry = "pds confirm message"
     RECORD pref_reply(
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
     EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
     IF ((pref_reply->status_data.status="S"))
      SET ltotalpref = size(pref_reply->pref,5)
      IF (ltotalpref > 0)
       SET ltotalentry = size(pref_reply->pref[1].entries,5)
       IF (ltotalentry > 0)
        FOR (lprefcnt = 1 TO ltotalentry)
         IF ((pref_reply->pref[1].entries[lprefcnt].entry="pds messaging")
          AND (pref_reply->pref[1].entries[lprefcnt].pref_exists_ind=true))
          SET ltotalvalue = size(pref_reply->pref[1].entries[lprefcnt].values,5)
          IF (ltotalvalue > 0)
           IF ((pref_reply->pref[1].entries[lprefcnt].values[1].value="1"))
            SET bpdsmsg = true
           ELSE
            SET bpdsmsg = false
           ENDIF
          ENDIF
         ENDIF
         IF ((pref_reply->pref[1].entries[lprefcnt].entry="pds confirm message")
          AND (pref_reply->pref[1].entries[lprefcnt].pref_exists_ind=true))
          SET ltotalvalue = size(pref_reply->pref[1].entries[lprefcnt].values,5)
          IF (ltotalvalue > 0)
           IF ((pref_reply->pref[1].entries[lprefcnt].values[1].value="1"))
            SET bpdsconfirm = true
           ELSE
            SET bpdsconfirm = false
           ENDIF
          ENDIF
         ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
     IF ((validate(bdebugme,- (99)) != - (99)))
      IF (bdebugme)
       CALL echorecord(pref_reply)
      ENDIF
     ENDIF
     FREE RECORD pref_request
     FREE RECORD pref_reply
   END ;Subroutine
  ENDIF
  SUBROUTINE (checkprocessexception(dpersonid=f8) =i2)
    DECLARE dholdcomplete = f8 WITH noconstant(0.0)
    DECLARE dexceptvalue = f8 WITH protect, constant(uar_get_code_by("MEANING",30700,"PDSEXCEPTION"))
    DECLARE dstatusvalue = f8 WITH protect, constant(uar_get_code_by("MEANING",254591,"INPROCESS"))
    SET stat = uar_get_meaning_by_codeset(254591,"HOLDCOMPLETE",1,dholdcomplete)
    IF (dexceptvalue != 0
     AND dstatusvalue != 0)
     SELECT INTO "nl:"
      FROM pm_post_process ppp
      WHERE ppp.person_id=dpersonid
       AND ppp.pm_post_process_type_cd=dexceptvalue
       AND ppp.process_status_cd IN (dstatusvalue, dholdcomplete)
       AND ppp.active_ind=1
      WITH nocounter
     ;end select
     IF (bdebugme)
      CALL echo("***PM Inside CheckProcessException")
      CALL echo(curqual)
     ENDIF
     IF (curqual > 0)
      RETURN(true)
     ELSE
      RETURN(false)
     ENDIF
    ELSE
     RETURN(false)
    ENDIF
  END ;Subroutine
  SUBROUTINE (checkandlockprocessexception(dpersonid=f8) =i2)
    DECLARE dsysretrievevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",30700,
      "SYSRETRIEVE"))
    DECLARE dinretrievevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",254591,
      "INRETRIEVE"))
    DECLARE dinerrorvalue = f8 WITH protect, constant(uar_get_code_by("MEANING",254591,"INERROR"))
    IF (dsysretrievevalue != 0)
     SELECT INTO "nl:"
      FROM pm_post_process ppp
      WHERE ppp.person_id=dpersonid
       AND ppp.pm_post_process_type_cd=dsysretrievevalue
       AND ppp.process_status_cd IN (dinretrievevalue, dinerrorvalue)
       AND ppp.active_ind=1
      WITH nocounter, forupdatewait(ppp)
     ;end select
     IF (bdebugme)
      CALL echo("***PM Inside CheckAndLockProcessException")
      CALL echo(curqual)
     ENDIF
     IF (curqual > 0)
      RETURN(true)
     ELSE
      CALL releaselockprocessexception(dpersonid)
      RETURN(false)
     ENDIF
    ELSE
     RETURN(false)
    ENDIF
  END ;Subroutine
  SUBROUTINE (releaselockprocessexception(dpersonid=f8) =i2)
    DECLARE dsysretrievevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",30700,
      "SYSRETRIEVE"))
    DECLARE dinretrievevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",254591,
      "INRETRIEVE"))
    DECLARE dinerrorvalue = f8 WITH protect, constant(uar_get_code_by("MEANING",254591,"INERROR"))
    IF (dsysretrievevalue != 0)
     UPDATE  FROM pm_post_process ppp
      SET ppp.person_id = dpersonid
      WHERE ppp.person_id=dpersonid
       AND ppp.pm_post_process_type_cd=dsysretrievevalue
       AND ppp.process_status_cd IN (dinretrievevalue, dinerrorvalue)
       AND ppp.active_ind=1
      WITH nocounter
     ;end update
     COMMIT
     IF (bdebugme)
      CALL echo("***PM Inside ReleaseLockProcessException")
      CALL echo(curqual)
     ENDIF
     IF (curqual > 0)
      RETURN(true)
     ELSE
      RETURN(false)
     ENDIF
    ELSE
     RETURN(false)
    ENDIF
  END ;Subroutine
  SUBROUTINE (triggerpdsretrieve(dpersonid=f8) =i2)
    DECLARE dnhsaliascodeforpdsretrieve = f8 WITH constant(uar_get_code_by("MEANING",4,"SSN"))
    DECLARE pdsret_reqid = i4 WITH constant(115604)
    DECLARE hpdsretmsg = i4 WITH noconstant(0)
    DECLARE hpdsretreq = i4 WITH noconstant(0)
    DECLARE hpdsretrep = i4 WITH noconstant(0)
    DECLARE snhsnumber = vc WITH noconstant("")
    DECLARE dprimaryssnaliaspoolcd = f8 WITH noconstant(0)
    DECLARE dnhscontributorsystem = f8 WITH constant(uar_get_code_by("MEANING",89,"NHS"))
    IF (dnhsaliascodeforpdsretrieve > 0.0
     AND dnhscontributorsystem > 0.0)
     SELECT INTO "nl:"
      FROM esi_alias_trans eat
      WHERE eat.contributor_system_cd=dnhscontributorsystem
       AND eat.alias_entity_alias_type_cd=dnhsaliascodeforpdsretrieve
       AND eat.esi_assign_auth="2.16.840.1.113883.2.1.4.1"
       AND eat.active_ind=1
      DETAIL
       dprimaryssnaliaspoolcd = eat.alias_pool_cd
      WITH nocounter
     ;end select
     IF (dnhsaliascodeforpdsretrieve > 0.0)
      SELECT INTO "nl:"
       pa.person_alias_id
       FROM person_patient pp,
        person_alias pa
       PLAN (pp
        WHERE pp.person_id=dpersonid
         AND pp.active_ind=1
         AND cnvtint(trim(pp.source_version_number,3)) > 0)
        JOIN (pa
        WHERE pa.person_id=pp.person_id
         AND pa.active_ind=1
         AND pa.person_alias_type_cd=dnhsaliascodeforpdsretrieve
         AND pa.alias_pool_cd=dprimaryssnaliaspoolcd
         AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
       DETAIL
        snhsnumber = trim(pa.alias,3)
        IF (bdebugme)
         CALL echo(build("NHS number = ",snhsnumber))
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    IF (textlen(trim(snhsnumber,3)) > 0)
     SET hpdsretmsg = uar_srvselectmessage(pdsret_reqid)
     IF (hpdsretmsg=0)
      IF (bdebugme)
       CALL echo("***PM TriggerPDSRetrieve - uar_SrvSelectMessage failed")
      ENDIF
      RETURN(false)
     ENDIF
     SET hpdsretreq = uar_srvcreaterequest(hpdsretmsg)
     IF (hpdsretreq=0)
      IF (bdebugme)
       CALL echo("***PM TriggerPDSRetrieve - uar_SrvCreateRequest failed")
      ENDIF
      RETURN(false)
     ENDIF
     SET hpdsretrep = uar_srvcreatereply(hpdsretmsg)
     IF (hpdsretrep=0)
      IF (bdebugme)
       CALL echo("***PM TriggerPDSRetrieve - uar_SrvCreateReply failed")
      ENDIF
      RETURN(false)
     ENDIF
     SET stat = uar_srvsetdouble(hpdsretreq,"patientId",dpersonid)
     SET stat = uar_srvsetstring(hpdsretreq,"nhsNumber",nullterm(snhsnumber))
     SET iret = uar_srvexecute(hpdsretmsg,hpdsretreq,hpdsretrep)
     IF (bdebugme)
      CALL echo("iRet:")
      CALL echo(iret)
      CASE (iret)
       OF 0:
        CALL echo("***PM TriggerPDSRetrieve - Successful Srv Execute ")
       OF 1:
        CALL echo(
         "***PM TriggerPDSRetrieve - Srv Execute failed - Communication Error - Server may be down")
       OF 2:
        CALL echo(
         "***PM TriggerPDSRetrieve - SrvSelectMessage failed -- May need to perfrom CCLSECLOGIN")
       OF 3:
        CALL echo("Failed to allocate either the Request or Reply Handle")
      ENDCASE
     ENDIF
     IF (iret != 0)
      RETURN(false)
     ENDIF
     CALL uar_srvdestroymessage(hpdsretmsg)
     CALL uar_srvdestroyinstance(hpdsretreq)
     CALL uar_srvdestroyinstance(hpdsretrep)
    ENDIF
    RETURN(true)
  END ;Subroutine
  SUBROUTINE (addschjob(dvalueid=f8,drefid=f8,svaluename=vc,sdocname=vc) =i2)
    IF (bdebugme)
     CALL echo("***PM Calling Insert on AddSchJob")
    ENDIF
    DECLARE djobstatuscd = f8 WITH protect, constant(uar_get_code_by("MEANING",23062,"PERFORM"))
    INSERT  FROM sch_job
     SET active_ind = 1, active_status_cd = reqdata->active_status_cd, active_status_dt_tm =
      cnvtdatetime(curdate,curtime),
      active_status_prsnl_id = reqinfo->updt_id, beg_effective_dt_tm = cnvtdatetime(sysdate), display
       = "ERM_PMPOSTDOC",
      job_class = sdocname, job_key = "ERM_PMPOSTDOC", job_state_cd = 0.0,
      job_status_cd = djobstatuscd, key_entity_id = drefid, key_entity_name = "PM_POST_DOC_REF",
      parent_entity_id = dvalueid, parent_entity_name = svaluename, request_dt_tm = cnvtdatetime(
       sysdate),
      sch_job_id = seq(sch_action_seq,nextval), updt_applctx = reqinfo->updt_applctx, updt_cnt = 1,
      updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = reqinfo->updt_id, updt_task = reqinfo->
      updt_task
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     RETURN(true)
    ELSE
     RETURN(false)
    ENDIF
  END ;Subroutine
  SUBROUTINE (getpdsdefinedorg(dummyvar=i2) =null)
    DECLARE pdsdeforg_id = f8 WITH constant(uar_get_code_by("MEANING",20790,"PDSDEFORG"))
    DECLARE bpds = i2 WITH noconstant(false)
    DECLARE bpdsconfirmmsg = i2 WITH noconstant(false)
    DECLARE dnhsaliascode = f8 WITH constant(uar_get_code_by("MEANING",4,"SSN"))
    IF (bdebugme)
     CALL echo("***PM GetPDSDefinedOrg, PDSDEFORG value")
     CALL echo(pdsdeforg_id)
    ENDIF
    IF (pdsdeforg_id > 0.0)
     SELECT INTO "nl:"
      cve.code_value
      FROM code_value_extension cve
      WHERE cve.code_value=pdsdeforg_id
       AND cve.field_name="OPTION"
       AND cve.code_set=20790
      DETAIL
       val_reply->def_org_id = cnvtreal(trim(cve.field_value,3))
       IF ((val_reply->def_org_id > 0.0))
        rec_cnt += 1
       ENDIF
       IF (bdebugme)
        CALL echo(cve.code_value)
       ENDIF
      WITH nocounter
     ;end select
     IF ((val_reply->def_org_id > 0))
      CALL getpdsorgpref(val_reply->def_org_id,bpds,bpdsconfirmmsg)
      CALL echo(build2("*** PDS Pref = ",bpds))
      IF (bpds=true)
       SET rec_cnt += 1
      ENDIF
      CALL echo(build2("*** PDS Confirm Pref = ",bpdsconfirmmsg))
      IF (bpdsconfirmmsg=true)
       SET rec_cnt += 1
      ENDIF
     ENDIF
     CALL echo(build2("*** rec_cnt = ",rec_cnt))
     IF (rec_cnt >= 3)
      IF (dnhsaliascode > 0.0)
       SELECT INTO "nl:"
        pa.person_alias_id
        FROM person_alias pa
        WHERE (pa.person_id=val_req->person_id)
         AND pa.active_ind=1
         AND pa.person_alias_type_cd=dnhsaliascode
         AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
        DETAIL
         mq_flag = true, val_reply->nhs_number = trim(pa.alias,3)
         IF (bdebugme)
          CALL echo(build("NHS number = ",val_reply->nhs_number))
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE (updatemq(dummyvar=i2) =null)
    DECLARE strqueuename = c20 WITH noconstant("PM.UK.CORRESPONDENCE")
    DECLARE strdatatype = vc WITH noconstant("MQSTR")
    DECLARE ierr = i4 WITH noconstant(0)
    DECLARE ispecific = i4 WITH noconstant(0)
    SET strqueuemsg = s_queuemsg(1)
    SET mq_flag = uar_si_insert_mq(nullterm(strqueuename),nullterm(strqueuemsg),textlen(nullterm(
       strqueuemsg)),nullterm(strdatatype),ierr,
     ispecific)
    IF (bdebugme)
     CALL echo("** Message generated to be inserted to queue **")
     CALL echo(strqueuemsg)
     CALL echo(build("iErr =",ierr))
    ENDIF
    IF (ierr > 0)
     SET mq_flag = false
    ENDIF
    SET mq_handle = 0
    SET mq_status = 0
    CALL uar_syscreatehandle(mq_handle,mq_status)
    IF (mq_handle != 0)
     IF (ierr > 0)
      CALL uar_sysevent(mq_handle,0,spfmtstring,build("***uar_si_insert_mq() error=",ierr))
     ELSE
      CALL uar_sysevent(mq_handle,2,spfmtstring,build("***PM rules insert ",val_req->person_id,
        " to queue"))
     ENDIF
     CALL uar_sysdestroyhandle(mq_handle)
    ENDIF
  END ;Subroutine
  SUBROUTINE (processdocuments(lindex=i4,dpersonid=f8,dencntrid=f8,dscheventid=f8,dschid=f8,
   dschactionid=f8) =i2)
    DECLARE dskipdecprint207902cd = f8 WITH protect, constant(uar_get_code_by("MEANING",207902,
      "SKIPDECPRINT"))
    DECLARE bpatientdeceased = i2 WITH protect, noconstant(false)
    DECLARE blank_date = dq8 WITH protect, noconstant(cnvtdatetime("01-JAN-1800 00:00:00.00"))
    DECLARE lpostdocindex = i4 WITH protect, noconstant(0)
    DECLARE dreferringorganizationid = f8 WITH protect, noconstant(0.0)
    DECLARE dpcporganizationid = f8 WITH protect, noconstant(0.0)
    IF (dskipdecprint207902cd > 0.0)
     SELECT INTO "nl:"
      p.person_id
      FROM person p
      PLAN (p
       WHERE p.person_id=dpersonid
        AND p.deceased_dt_tm != null
        AND p.deceased_dt_tm > cnvtdatetime(blank_date))
      DETAIL
       bpatientdeceased = true
      WITH nocounter
     ;end select
     IF (bpatientdeceased=true)
      RETURN(true)
     ENDIF
    ENDIF
    IF (textlen(trim(pdr_reply->list[lindex].document_object_name,3)) > 0)
     IF (bdebugme)
      CALL echo(build2("** Document Object: ",trim(pdr_reply->list[lindex].document_object_name,3)))
     ENDIF
     CALL echo("*****pm_post_doc_req.inc - 666833*****")
     FREE RECORD pdd_req
     RECORD pdd_req(
       1 mode = i2
       1 pm_post_doc[*]
         2 action_flag = i4
         2 parent_entity_name = c32
         2 parent_entity_id = f8
         2 pm_post_doc_id = f8
         2 pm_post_doc_ref_id = f8
         2 manual_create_ind = i2
         2 print_dt_tm = dq8
         2 create_dt_tm = dq8
         2 schedule_id = f8
         2 sch_action_id = f8
         2 document_object_name = vc
         2 document_type_cd = f8
         2 related_person_id = f8
         2 referring_organization_id = f8
         2 primary_care_organization_id = f8
     ) WITH protect
     FREE RECORD pdd_reply
     RECORD pdd_reply(
       1 mode = i2
       1 pm_post_doc[*]
         2 pm_post_doc_id = f8
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     SET stat = alterlist(pdd_req->pm_post_doc,1)
     SET pdd_req->pm_post_doc[lpostdocindex].document_object_name = trim(pdr_reply->list[lindex].
      document_object_name,3)
     SET pdd_req->pm_post_doc[lpostdocindex].document_type_cd = pdr_reply->list[lindex].
     document_type_cd
     IF (validate(pdr_reply->list[lindex].related_person_doc_obj_name)
      AND textlen(trim(pdr_reply->list[lindex].related_person_doc_obj_name,3)) > 0)
      CALL fillrelatedpersonid(dpersonid)
      IF ((related_person_info->related_person_count > 0))
       SET stat = alterlist(pdd_req->pm_post_doc,(size(pdd_req->pm_post_doc,5)+ related_person_info->
        related_person_count))
       FOR (lpostdocindex = 1 TO related_person_info->related_person_count)
         SET pdd_req->pm_post_doc[(lpostdocindex+ 1)].related_person_id = related_person_info->
         related_persons[lpostdocindex].related_person_id
         SET pdd_req->pm_post_doc[(lpostdocindex+ 1)].document_object_name = trim(pdr_reply->list[
          lindex].related_person_doc_obj_name,3)
         SET pdd_req->pm_post_doc[(lpostdocindex+ 1)].document_type_cd = pdr_reply->list[lindex].
         related_person_doc_type_cd
       ENDFOR
      ENDIF
     ENDIF
     IF (validate(pdr_reply->list[lindex].ref_org_doc_obj_name)
      AND textlen(trim(pdr_reply->list[lindex].ref_org_doc_obj_name,3)) > 0)
      SET dreferringorganizationid = getreferringorganizationid(dpersonid,dencntrid)
      IF (dreferringorganizationid > 0.0)
       SET lpostdocindex = (size(pdd_req->pm_post_doc,5)+ 1)
       SET stat = alterlist(pdd_req->pm_post_doc,lpostdocindex)
       SET pdd_req->pm_post_doc[lpostdocindex].referring_organization_id = dreferringorganizationid
       SET pdd_req->pm_post_doc[lpostdocindex].document_object_name = trim(pdr_reply->list[lindex].
        ref_org_doc_obj_name,3)
       SET pdd_req->pm_post_doc[lpostdocindex].document_type_cd = pdr_reply->list[lindex].
       ref_org_doc_type_cd
      ENDIF
     ENDIF
     IF (validate(pdr_reply->list[lindex].primary_care_doc_obj_name)
      AND textlen(trim(pdr_reply->list[lindex].primary_care_doc_obj_name,3)) > 0)
      SET dpcporganizationid = getpcporganizationid(dpersonid)
      IF (dpcporganizationid > 0.0)
       SET lpostdocindex = (size(pdd_req->pm_post_doc,5)+ 1)
       SET stat = alterlist(pdd_req->pm_post_doc,lpostdocindex)
       SET pdd_req->pm_post_doc[lpostdocindex].primary_care_organization_id = dpcporganizationid
       SET pdd_req->pm_post_doc[lpostdocindex].document_object_name = trim(pdr_reply->list[lindex].
        primary_care_doc_obj_name,3)
       SET pdd_req->pm_post_doc[lpostdocindex].document_type_cd = pdr_reply->list[lindex].
       primary_care_doc_type_cd
      ENDIF
     ENDIF
     FOR (lpostdocindex = 1 TO size(pdd_req->pm_post_doc,5))
       SET pdd_req->pm_post_doc[lpostdocindex].action_flag = 3
       IF (dscheventid > 0)
        SET pdd_req->pm_post_doc[lpostdocindex].parent_entity_name = "SCH_EVENT"
        SET pdd_req->pm_post_doc[lpostdocindex].parent_entity_id = dscheventid
       ELSEIF (dencntrid > 0)
        SET pdd_req->pm_post_doc[lpostdocindex].parent_entity_name = "ENCOUNTER"
        SET pdd_req->pm_post_doc[lpostdocindex].parent_entity_id = dencntrid
       ELSE
        SET pdd_req->pm_post_doc[lpostdocindex].parent_entity_name = "PERSON"
        SET pdd_req->pm_post_doc[lpostdocindex].parent_entity_id = dpersonid
       ENDIF
       SET pdd_req->pm_post_doc[lpostdocindex].schedule_id = dschid
       SET pdd_req->pm_post_doc[lpostdocindex].sch_action_id = dschactionid
       SET pdd_req->pm_post_doc[lpostdocindex].pm_post_doc_ref_id = pdr_reply->list[lindex].
       pm_post_doc_ref_id
     ENDFOR
     IF (bdebugme)
      CALL echo("** pm_ens_post_doc request **")
      CALL echorecord(pdd_req)
      CALL echo("** Calling pm_ens_post_doc **")
     ENDIF
     EXECUTE pm_ens_post_doc  WITH replace("REQUEST","PDD_REQ"), replace("REPLY","PDD_REPLY")
     IF ((pdd_reply->status_data.status != "S"))
      SET reply->status_data.subeventstatus[1].operationname = spfmtstring
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "PM_ENS_POST_DOC"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "Call to pm_ens_post_doc failed"
      RETURN(false)
     ENDIF
     IF (bdebugme)
      CALL echo("** pm_ens_post_doc reply **")
      CALL echorecord(pdd_reply)
     ENDIF
    ENDIF
    IF (((textlen(trim(pdr_reply->list[lfor].document_object_name,3)) > 0) OR (textlen(trim(pdr_reply
      ->list[lfor].action_object_name,3)) > 0)) )
     CALL echo("*****pm_gen_post_doc_req.inc - 666833*****")
     FREE RECORD gen_req
     RECORD gen_req(
       1 pm_post_doc_id = f8
       1 person_id = f8
       1 encntr_id = f8
       1 sch_event_id = f8
       1 schedule_id = f8
       1 document_object_name = vc
       1 action_object_name = vc
       1 print_ind = i2
       1 copies_nbr = i4
       1 output_dest_cd = f8
       1 running_from_ops_ind = i2
       1 related_person_id = f8
     ) WITH protect
     FREE RECORD gen_reply
     RECORD gen_reply(
       1 mode = i2
       1 list[*]
         2 pm_post_doc_id = f8
         2 doc_file_dir = vc
         2 doc_file_name = vc
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     )
     FOR (lpostdocindex = 1 TO size(pdd_reply->pm_post_doc,5))
       IF ((pdd_reply->pm_post_doc[lpostdocindex].pm_post_doc_id > 0))
        IF (bdebugme)
         CALL echo(build2("** Action Object: ",trim(pdr_reply->list[lindex].action_object_name,3)))
        ENDIF
        SET gen_req->person_id = dpersonid
        SET gen_req->encntr_id = dencntrid
        IF (dscheventid > 0)
         SET gen_req->sch_event_id = dscheventid
        ENDIF
        IF (dschid > 0)
         SET gen_req->schedule_id = dschid
        ENDIF
        IF ((validate(pdd_reply->mode,- (9)) != - (9)))
         SET gen_req->pm_post_doc_id = pdd_reply->pm_post_doc[lpostdocindex].pm_post_doc_id
        ENDIF
        IF (validate(gen_req->related_person_id))
         SET gen_req->related_person_id = 0.0
        ENDIF
        IF (validate(pdd_req->pm_post_doc[lpostdocindex].related_person_id)
         AND (pdd_req->pm_post_doc[lpostdocindex].related_person_id > 0.0))
         SET gen_req->document_object_name = pdr_reply->list[lindex].related_person_doc_obj_name
         SET gen_req->related_person_id = pdd_req->pm_post_doc[lpostdocindex].related_person_id
        ELSEIF (validate(pdd_req->pm_post_doc[lpostdocindex].referring_organization_id)
         AND (pdd_req->pm_post_doc[lpostdocindex].referring_organization_id > 0.0))
         SET gen_req->document_object_name = pdr_reply->list[lindex].ref_org_doc_obj_name
        ELSEIF (validate(pdd_req->pm_post_doc[lpostdocindex].primary_care_organization_id)
         AND (pdd_req->pm_post_doc[lpostdocindex].primary_care_organization_id > 0.0))
         SET gen_req->document_object_name = pdr_reply->list[lindex].primary_care_doc_obj_name
        ELSEIF (textlen(trim(pdr_reply->list[lindex].document_object_name,3)) > 0)
         SET gen_req->document_object_name = pdr_reply->list[lindex].document_object_name
        ELSE
         SET gen_req->document_object_name = ""
        ENDIF
        IF (textlen(trim(pdr_reply->list[lindex].action_object_name,3)) > 0)
         SET gen_req->action_object_name = pdr_reply->list[lindex].action_object_name
        ELSE
         SET gen_req->action_object_name = ""
        ENDIF
        IF ((pdr_reply->list[lindex].batch_print_ind != true))
         SET gen_req->print_ind = true
         SET gen_req->copies_nbr = pdr_reply->list[lindex].copies_nbr
         IF ((pdr_reply->list[lindex].output_dest_cd > 0))
          SET gen_req->output_dest_cd = pdr_reply->list[lindex].output_dest_cd
         ELSE
          IF ((validate(requestin->request.output_dest_cd,- (99.0)) != - (99.0)))
           SET gen_req->output_dest_cd = requestin->request.output_dest_cd
          ELSE
           IF ((validate(requestin->request.pm_output_dest_cd,- (99.0)) != - (99.0)))
            SET gen_req->output_dest_cd = requestin->request.pm_output_dest_cd
           ENDIF
          ENDIF
         ENDIF
         IF (bdebugme)
          CALL echo(build2("** Output_dest_cd:",gen_req->output_dest_cd))
         ENDIF
        ENDIF
        IF (bdebugme)
         CALL echo("** pm_gen_post_doc request **")
         CALL echorecord(gen_req)
        ENDIF
        EXECUTE pm_gen_post_doc  WITH replace("REQUEST","GEN_REQ"), replace("REPLY","GEN_REPLY")
        IF ((gen_reply->status_data.status != "S"))
         SET reply->status_data.subeventstatus[1].operationname = spfmtstring
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "PM_GEN_POST_DOC"
         SET reply->status_data.subeventstatus[1].targetobjectvalue =
         "Call to pm_gen_post_doc failed"
         RETURN(false)
        ENDIF
        IF (bdebugme)
         CALL echo("** pm_gen_post_doc reply **")
         CALL echorecord(gen_reply)
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    RETURN(true)
  END ;Subroutine
  SUBROUTINE (getflexrules(lmode=i4) =i2)
    IF (bdebugme)
     CALL echo("*** GetFlexRules - Start ***")
    ENDIF
    DECLARE bflexdone = i2 WITH noconstant(false)
    DECLARE lflextotal = i4 WITH noconstant(0)
    DECLARE lflextemp = i4 WITH noconstant(0)
    DECLARE lflextemp2 = i4 WITH noconstant(0)
    DECLARE lloop = i4 WITH noconstant(0)
    DECLARE lloop2 = i4 WITH noconstant(0)
    DECLARE lloop3 = i4 WITH noconstant(0)
    DECLARE llistsize = i4 WITH noconstant(0)
    DECLARE llistsize2 = i4 WITH noconstant(0)
    DECLARE lsizecnt = i4 WITH noconstant(0)
    IF ((validate(my_flex_rules->mode,- (99))=- (99)))
     SET reply->status_data.subeventstatus[1].operationname = "PFMT_PM_RULES_*"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "GetSliceRules()"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "my_flex_rules structure does not exist"
     RETURN(false)
    ENDIF
    SET llistsize = my_flex_rules->qual_cnt
    IF (llistsize <= 0)
     SET reply->status_data.subeventstatus[1].operationname = "PFMT_PM_RULES_*"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "GetSliceRules()"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "lListSize = 0"
     RETURN(false)
    ENDIF
    FREE RECORD sch_flex_by_id_req
    RECORD sch_flex_by_id_req(
      1 call_echo_ind = i2
      1 qual[*]
        2 sch_flex_id = f8
      1 mode = i2
    ) WITH protect
    SET sch_flex_by_id_req->mode = 1
    SET stat = alterlist(sch_flex_by_id_req->qual,llistsize)
    FOR (lloop = 1 TO llistsize)
      SET sch_flex_by_id_req->qual[lloop].sch_flex_id = my_flex_rules->qual[lloop].sch_flex_id
    ENDFOR
    IF (bdebugme)
     CALL echo("*** SCH_FLEX_BY_ID_REQ ***")
     CALL echorecord(sch_flex_by_id_req)
    ENDIF
    EXECUTE sch_get_flex_by_id  WITH replace("REQUEST","SCH_FLEX_BY_ID_REQ"), replace("REPLY",
     "MY_FLEX_RULES")
    IF (bdebugme)
     CALL echo("*** my_flex_rules ***")
     CALL echorecord(my_flex_rules)
    ENDIF
    IF ((my_flex_rules->status_data.status != "S"))
     SET reply->status_data.subeventstatus[1].operationname = "PFMT_PM_RULES_*"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "GetSliceRules()"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Call to sch_get_flex_by_id failed"
     RETURN(false)
    ENDIF
    FOR (lloop = 1 TO llistsize)
      FREE RECORD tempflex
      RECORD tempflex(
        1 list[*]
          2 sch_flex_id = f8
      ) WITH protect
      SET lflextemp = 0
      SET llistsize2 = my_flex_rules->qual[lloop].token_qual_cnt
      FOR (lloop2 = 1 TO llistsize2)
        IF (trim(my_flex_rules->qual[lloop].token_qual[lloop2].flex_token_mean,3)="D_FLEXSTRING")
         SET lflextemp += 1
         SET stat = alterlist(tempflex->list,lflextemp)
         SET tempflex->list[lflextemp].sch_flex_id = my_flex_rules->qual[lloop].token_qual[lloop2].
         parent_id
        ENDIF
      ENDFOR
      SET bflexdone = false
      WHILE (bflexdone != true)
        IF (lflextemp > 0)
         SET lflextotal = lflextemp
         FREE RECORD sch_flex_req
         RECORD sch_flex_req(
           1 call_echo_ind = i2
           1 qual[*]
             2 sch_flex_id = f8
           1 mode = i2
         ) WITH protect
         SET sch_flex_req->mode = 1
         SET stat = alterlist(sch_flex_req->qual,lflextotal)
         FOR (lflextemp = 1 TO lflextotal)
           SET sch_flex_req->qual[lflextemp].sch_flex_id = tempflex->list[lflextemp].sch_flex_id
         ENDFOR
         FREE RECORD sch_flex_reply
         RECORD sch_flex_reply(
           1 qual_cnt = i4
           1 qual[*]
             2 sch_flex_id = f8
             2 mnemonic = vc
             2 description = vc
             2 flex_type_cd = f8
             2 flex_type_meaning = vc
             2 info_sch_text_id = f8
             2 info_sch_text = vc
             2 text_updt_cnt = i4
             2 updt_cnt = i4
             2 active_ind = i2
             2 candidate_id = f8
             2 pft_ruleset_grouping = i2
             2 token_qual_cnt = i4
             2 token_qual[*]
               3 updt_cnt = i4
               3 seq_nbr = i4
               3 flex_orient_cd = f8
               3 flex_orient_mean = c12
               3 flex_token_cd = f8
               3 flex_token_disp = vc
               3 flex_token_mean = c12
               3 token_type_cd = f8
               3 token_type_meaning = c12
               3 data_type_cd = f8
               3 data_type_meaning = c12
               3 data_source_cd = f8
               3 data_source_meaning = c12
               3 flex_eval_cd = f8
               3 flex_eval_meaning = c12
               3 precedence = i4
               3 dynamic_text = vc
               3 oe_field_id = f8
               3 filter_id = f8
               3 filter_table = vc
               3 oe_field_display = vc
               3 dt_tm_value = dq8
               3 string_value = vc
               3 double_value = f8
               3 parent_table = vc
               3 parent_id = f8
               3 parent_meaning = c12
               3 display_table = vc
               3 display_id = f8
               3 display_meaning = c12
               3 mnemonic = vc
               3 description = vc
               3 font_size = i4
               3 font_name = vc
               3 bold = i4
               3 italic = i4
               3 strikethru = i4
               3 underline = i4
               3 candidate_id = f8
               3 offset_units = i4
               3 offset_units_cd = f8
               3 offset_units_meaning = c12
               3 dynamic_xml_text = gvc
               3 found = i2
               3 udf_double_value = f8
               3 udf_string_value = vc
               3 udf_dt_tm_value = dq8
           1 status_data
             2 status = c1
             2 subeventstatus[1]
               3 operationname = c25
               3 operationstatus = c1
               3 targetobjectname = c25
               3 targetobjectvalue = vc
         ) WITH protect
         IF (bdebugme)
          CALL echo("*** SCH_FLEX_REQ ***")
          CALL echorecord(sch_flex_req)
         ENDIF
         EXECUTE sch_get_flex_by_id  WITH replace("REQUEST","SCH_FLEX_REQ"), replace("REPLY",
          "SCH_FLEX_REPLY")
         IF (bdebugme)
          CALL echo("*** SCH_FLEX_REPLY ***")
          CALL echorecord(sch_flex_reply)
         ENDIF
         IF ((sch_flex_reply->status_data.status != "S"))
          SET reply->status_data.subeventstatus[1].targetobjectname = "PFMT_PM_RULES_*"
          SET reply->status_data.subeventstatus[1].operationstatus = "F"
          SET reply->status_data.subeventstatus[1].targetobjectname = "GetSliceRules()"
          SET reply->status_data.subeventstatus[1].targetobjectvalue =
          "Call to sch_get_flex_by_id 2 failed"
          RETURN(false)
         ENDIF
         FREE RECORD tempflex
         RECORD tempflex(
           1 list[*]
             2 sch_flex_id = f8
         ) WITH protect
         SET lflextemp2 = 0
         FOR (lflextemp = 1 TO sch_flex_reply->qual_cnt)
          SET llistsize2 = sch_flex_reply->qual[lflextemp].token_qual_cnt
          IF (llistsize2 > 0)
           FOR (lloop3 = 1 TO llistsize2)
             IF (trim(sch_flex_reply->qual[lflextemp].token_qual[lloop3].flex_token_mean,3)=
             "D_FLEXSTRING")
              SET lflextemp2 += 1
              SET stat = alterlist(tempflex->list,lflextemp2)
              SET tempflex->list[lflextemp2].sch_flex_id = sch_flex_reply->qual[lflextemp].
              token_qual[lloop3].parent_id
             ENDIF
             SET lloop2 = (my_flex_rules->qual[lloop].token_qual_cnt+ 1)
             SET my_flex_rules->qual[lloop].token_qual_cnt = lloop2
             SET stat = alterlist(my_flex_rules->qual[lloop].token_qual,lloop2)
             SET my_flex_rules->qual[lloop].token_qual[lloop2].flex_token_mean = sch_flex_reply->
             qual[lflextemp].token_qual[lloop3].flex_token_mean
             SET my_flex_rules->qual[lloop].token_qual[lloop2].data_type_meaning = sch_flex_reply->
             qual[lflextemp].token_qual[lloop3].data_type_meaning
             SET my_flex_rules->qual[lloop].token_qual[lloop2].double_value = sch_flex_reply->qual[
             lflextemp].token_qual[lloop3].double_value
             SET my_flex_rules->qual[lloop].token_qual[lloop2].string_value = sch_flex_reply->qual[
             lflextemp].token_qual[lloop3].string_value
             SET my_flex_rules->qual[lloop].token_qual[lloop2].dt_tm_value = sch_flex_reply->qual[
             lflextemp].token_qual[lloop3].dt_tm_value
             SET my_flex_rules->qual[lloop].token_qual[lloop2].filter_id = sch_flex_reply->qual[
             lflextemp].token_qual[lloop3].filter_id
             SET my_flex_rules->qual[lloop].token_qual[lloop2].oe_field_id = sch_flex_reply->qual[
             lflextemp].token_qual[lloop3].oe_field_id
             SET my_flex_rules->qual[lloop].token_qual[lloop2].parent_id = sch_flex_reply->qual[
             lflextemp].token_qual[lloop3].parent_id
           ENDFOR
          ENDIF
         ENDFOR
         SET lflextemp = 0
         IF (lflextemp2 > 0)
          SET lflextemp = lflextemp2
         ELSE
          SET bflexdone = true
         ENDIF
        ELSE
         SET bflexdone = true
        ENDIF
      ENDWHILE
    ENDFOR
    IF (bflexdone)
     IF (bdebugme)
      CALL echo("*** my_flex_rules After Flex String Check ***")
      CALL echorecord(my_flex_rules)
     ENDIF
    ENDIF
    FREE RECORD sch_flex_by_id_req
    FREE RECORD sch_flex_req
    FREE RECORD sch_flex_reply
    FREE RECORD tempflex
    RETURN(true)
  END ;Subroutine
 ENDIF
 DECLARE ppp_type_cd = f8 WITH protect, constant(loadcodevalue(30700,"PDSEXCEPTION",0))
 DECLARE sys_retrieve_cd = f8 WITH protect, constant(loadcodevalue(30700,"SYSRETRIEVE",0))
 DECLARE proc_stat_cd_complete = f8 WITH protect, constant(loadcodevalue(254591,"COMPLETE",0))
 DECLARE in_retrieve_cd = f8 WITH protect, constant(loadcodevalue(254591,"INRETRIEVE",0))
 DECLARE in_error_cd = f8 WITH protect, constant(loadcodevalue(254591,"INERROR",0))
 DECLARE in_printing_cd = f8 WITH protect, constant(loadcodevalue(254591,"INPRINTING",0))
 DECLARE skip_dec_print_cd = f8 WITH protect, constant(loadcodevalue(207902,"SKIPDECPRINT",1))
 DECLARE temp_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE temp_pds_exception_id = f8 WITH protect, noconstant(0.0)
 DECLARE comparison_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE min_sentinel_date = dq8 WITH protect, constant(cnvtdatetime("01-JAN-1800 00:00:00.00"))
 SUBROUTINE (complete_post_processing(person_id=f8,complete_status=vc(ref)) =null)
   SET complete_status->status = "S"
   IF ((request->person_id=0))
    EXECUTE sch_msgview "ACM_COMPLETE_PDS_EXCEPTION", nullterm(build(
      "***** ACM_COMPLETE_PDS_EXCEPTION - no person_id complete_post_processing stopped")), 1
    RETURN
   ENDIF
   RECORD pds_exceptions(
     1 pds_exception_cnt = i4
     1 pds_exception_list[*]
       2 pds_exception_id = f8
       2 updt_status = i2
   )
   SELECT INTO "nl:"
    FROM pm_post_process ppp
    WHERE ppp.person_id=person_id
     AND ppp.pm_post_process_type_cd=sys_retrieve_cd
     AND ppp.active_ind=1
    HEAD REPORT
     pds_exception_cnt = 0
    DETAIL
     pds_exception_cnt += 1
     IF (mod(pds_exception_cnt,10)=1)
      stat = alterlist(pds_exceptions->pds_exception_list,(pds_exception_cnt+ 9))
     ENDIF
     pds_exceptions->pds_exception_list[pds_exception_cnt].pds_exception_id = ppp.pm_post_process_id
    FOOT REPORT
     stat = alterlist(pds_exceptions->pds_exception_list,pds_exception_cnt), pds_exceptions->
     pds_exception_cnt = pds_exception_cnt
    WITH nocounter, forupdatewait(ppp)
   ;end select
   IF ((pds_exceptions->pds_exception_cnt > 0))
    UPDATE  FROM (dummyt d  WITH seq = value(pds_exceptions->pds_exception_cnt)),
      pm_post_process ppp
     SET ppp.process_status_cd = in_printing_cd, ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp.updt_dt_tm =
      cnvtdatetime(sysdate),
      ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx = reqinfo->updt_applctx, ppp.updt_task =
      reqinfo->updt_task
     PLAN (d
      WHERE (pds_exceptions->pds_exception_cnt > 0))
      JOIN (ppp
      WHERE (ppp.pm_post_process_id=pds_exceptions->pds_exception_list[d.seq].pds_exception_id))
     WITH nocounter, status(pds_exceptions->pds_exception_list[d.seq].updt_status)
    ;end update
    FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
      IF ((pds_exceptions->pds_exception_list[index].updt_status != 1))
       SET failed = update_error
       SET table_name = "PM_POST_PROCESS"
       ROLLBACK
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   COMMIT
   CALL process_pending_documents(person_id,complete_status)
   IF ((complete_status->status="F"))
    ROLLBACK
    IF ((pds_exceptions->pds_exception_cnt > 0))
     UPDATE  FROM (dummyt d  WITH seq = value(pds_exceptions->pds_exception_cnt)),
       pm_post_process ppp
      SET ppp.process_status_cd = in_error_cd, ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp.updt_dt_tm =
       cnvtdatetime(sysdate),
       ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx = reqinfo->updt_applctx, ppp.updt_task =
       reqinfo->updt_task
      PLAN (d
       WHERE (pds_exceptions->pds_exception_cnt > 0))
       JOIN (ppp
       WHERE (ppp.pm_post_process_id=pds_exceptions->pds_exception_list[d.seq].pds_exception_id))
      WITH nocounter, status(pds_exceptions->pds_exception_list[d.seq].updt_status)
     ;end update
     FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
       IF ((pds_exceptions->pds_exception_list[index].updt_status != 1))
        SET failed = update_error
        SET table_name = "PM_POST_PROCESS"
        GO TO exit_script
       ENDIF
     ENDFOR
     COMMIT
    ENDIF
   ELSE
    IF ((pds_exceptions->pds_exception_cnt > 0))
     DELETE  FROM (dummyt d  WITH seq = value(pds_exceptions->pds_exception_cnt)),
       pm_post_process ppp
      SET ppp.seq = 1
      PLAN (d
       WHERE (pds_exceptions->pds_exception_cnt > 0))
       JOIN (ppp
       WHERE (ppp.pm_post_process_id=pds_exceptions->pds_exception_list[d.seq].pds_exception_id))
      WITH nocounter, status(pds_exceptions->pds_exception_list[d.seq].updt_status)
     ;end delete
     FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
       IF ((pds_exceptions->pds_exception_list[index].updt_status != 1))
        SET failed = delete_error
        SET table_name = "PM_POST_PROCESS"
        GO TO exit_script
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (complete_pds_exception(pds_exception_id=f8,person_id=f8,source_version_number=vc,
  complete_status=vc(ref)) =f8)
   SET complete_status->status = "S"
   IF (((person_id > 0
    AND pds_exception_id > 0) OR (person_id=0.0
    AND pds_exception_id=0.0)) )
    SET complete_status->status = "F"
    SET complete_status->operationname =
    "Either the person_id or the pds_exception_id must be populated, not both"
    RETURN
   ENDIF
   FREE RECORD pds_exceptions
   RECORD pds_exceptions(
     1 pds_exception_cnt = i4
     1 pds_exception_list[*]
       2 pds_exception_id = f8
       2 updt_status = i2
   )
   IF (person_id > 0)
    SELECT INTO "nl:"
     FROM pm_post_process ppp
     WHERE ppp.person_id=person_id
      AND ppp.pm_post_process_type_cd=ppp_type_cd
      AND ppp.active_ind=1
     HEAD REPORT
      pds_exception_cnt = 0
     DETAIL
      pds_exception_cnt += 1
      IF (ppp.comparison_person_id > 0)
       comparison_person_id = ppp.comparison_person_id
      ENDIF
      IF (mod(pds_exception_cnt,10)=1)
       stat = alterlist(pds_exceptions->pds_exception_list,(pds_exception_cnt+ 9))
      ENDIF
      pds_exceptions->pds_exception_list[pds_exception_cnt].pds_exception_id = ppp.pm_post_process_id
     FOOT REPORT
      stat = alterlist(pds_exceptions->pds_exception_list,pds_exception_cnt), pds_exceptions->
      pds_exception_cnt = pds_exception_cnt
     WITH nocounter
    ;end select
   ELSEIF (pds_exception_id > 0)
    SET stat = alterlist(pds_exceptions->pds_exception_list,1)
    SET pds_exceptions->pds_exception_list[1].pds_exception_id = pds_exception_id
    SET pds_exceptions->pds_exception_cnt = 1
    SELECT INTO "nl:"
     FROM pm_post_process ppp
     WHERE ppp.pm_post_process_id=pds_exception_id
      AND ppp.pm_post_process_type_cd=ppp_type_cd
      AND ppp.active_ind=1
     DETAIL
      comparison_person_id = ppp.comparison_person_id
     WITH nocounter
    ;end select
   ENDIF
   SET pm_post_process_updt_status = 0
   SET source_version_number_trim = trim(source_version_number)
   FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
     SET temp_pds_exception_id = pds_exceptions->pds_exception_list[index].pds_exception_id
     IF (source_version_number != null
      AND source_version_number_trim != "")
      UPDATE  FROM pm_post_process ppp
       SET ppp.process_status_cd = proc_stat_cd_complete, ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp
        .updt_dt_tm = cnvtdatetime(sysdate),
        ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx = reqinfo->updt_applctx, ppp.updt_task =
        reqinfo->updt_task,
        ppp.source_version_number = source_version_number_trim, ppp.comparison_person_id = 0
       WHERE ppp.pm_post_process_id=temp_pds_exception_id
        AND ppp.pm_post_process_type_cd=ppp_type_cd
       WITH status(pm_post_process_updt_status)
      ;end update
     ELSE
      UPDATE  FROM pm_post_process ppp
       SET ppp.process_status_cd = proc_stat_cd_complete, ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp
        .updt_dt_tm = cnvtdatetime(sysdate),
        ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx = reqinfo->updt_applctx, ppp.updt_task =
        reqinfo->updt_task,
        ppp.comparison_person_id = 0
       WHERE ppp.pm_post_process_id=temp_pds_exception_id
        AND ppp.pm_post_process_type_cd=ppp_type_cd
       WITH status(pm_post_process_updt_status)
      ;end update
     ENDIF
     IF (pm_post_process_updt_status <= 0)
      SET complete_status->status = "Z"
      SET complete_status->operationname = "Unable to update PM_POST_PROCESS"
     ENDIF
     DELETE  FROM address a
      WHERE a.parent_entity_id=temp_pds_exception_id
       AND a.parent_entity_name="PM_POST_PROCESS"
     ;end delete
     DELETE  FROM phone ph
      WHERE ph.parent_entity_id=temp_pds_exception_id
       AND ph.parent_entity_name="PM_POST_PROCESS"
     ;end delete
   ENDFOR
   IF (comparison_person_id > 0)
    DELETE  FROM address a
     WHERE a.parent_entity_id=comparison_person_id
      AND a.parent_entity_name="PERSON"
    ;end delete
    DELETE  FROM phone ph
     WHERE ph.parent_entity_id=comparison_person_id
      AND ph.parent_entity_name="PERSON"
    ;end delete
    FREE RECORD acm_request
    RECORD acm_request(
      1 call_echo_ind = i2
      1 force_updt_ind = i2
      1 transaction_info_qual[*]
        2 transaction_id = f8
        2 pm_hist_tracking_id = f8
        2 transaction_dt_tm = dq8
        2 transaction_reason_cd = f8
        2 transaction_reason = vc
        2 transaction = c4
        2 person_id = f8
        2 person_idx = i4
        2 encntr_id = f8
        2 encntr_idx = i4
      1 person_qual[*]
        2 autopsy_cd = f8
        2 beg_effective_dt_tm = dq8
        2 birth_dt_cd = f8
        2 birth_dt_tm = dq8
        2 cause_of_death = vc
        2 cause_of_death_cd = f8
        2 citizenship_cd = f8
        2 conception_dt_tm = dq8
        2 confid_level_cd = f8
        2 contributor_system_cd = f8
        2 data_status_dt_tm = dq8
        2 deceased_cd = f8
        2 deceased_dt_tm = dq8
        2 deceased_source_cd = f8
        2 end_effective_dt_tm = dq8
        2 ethnic_grp_cd = f8
        2 ft_entity_id = f8
        2 ft_entity_idx = i4
        2 ft_entity_name = vc
        2 language_cd = f8
        2 language_dialect_cd = f8
        2 last_encntr_dt_tm = dq8
        2 marital_type_cd = f8
        2 military_base_location = vc
        2 military_rank_cd = f8
        2 military_service_cd = f8
        2 mother_maiden_name = vc
        2 name_first = vc
        2 name_first_key = vc
        2 name_first_phonetic = vc
        2 name_first_synonym_id = f8
        2 name_first_synonym_idx = i4
        2 name_full_formatted = vc
        2 name_last = vc
        2 name_last_key = vc
        2 name_last_phonetic = vc
        2 name_middle = vc
        2 name_middle_key = vc
        2 name_phonetic = vc
        2 nationality_cd = f8
        2 person_id = f8
        2 person_type_cd = f8
        2 race_cd = f8
        2 religion_cd = f8
        2 sex_age_change_ind = i2
        2 sex_cd = f8
        2 species_cd = f8
        2 vet_military_status_cd = f8
        2 vip_cd = f8
        2 action_flag = i2
        2 active_ind = i2
        2 active_status_cd = f8
        2 chg_str = vc
        2 data_status_cd = f8
        2 updt_cnt = i4
        2 pm_hist_tracking_id = f8
        2 transaction_dt_tm = dq8
        2 birth_tz = i4
        2 abs_birth_dt_tm = dq8
        2 birth_prec_flag = i4
        2 age_at_death = i4
        2 age_at_death_unit_cd = f8
        2 age_at_death_prec_mod_flag = i4
        2 deceased_tz = i4
        2 deceased_dt_tm_prec_flag = i4
      1 person_name_qual[*]
        2 beg_effective_dt_tm = dq8
        2 contributor_system_cd = f8
        2 end_effective_dt_tm = dq8
        2 name_degree = vc
        2 name_first = vc
        2 name_first_key = vc
        2 name_format_cd = f8
        2 name_full = vc
        2 name_initials = vc
        2 name_last = vc
        2 name_last_key = vc
        2 name_middle = vc
        2 name_middle_key = vc
        2 name_prefix = vc
        2 name_suffix = vc
        2 name_title = vc
        2 name_type_cd = f8
        2 person_id = f8
        2 person_idx = i4
        2 person_name_id = f8
        2 action_flag = i2
        2 active_ind = i2
        2 active_status_cd = f8
        2 chg_str = vc
        2 data_status_cd = f8
        2 updt_cnt = i4
        2 pm_hist_tracking_id = f8
        2 transaction_dt_tm = dq8
        2 source_identifier = vc
        2 name_type_seq = i4
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    IF (validate(add_action)=0)
     DECLARE add_action = i2 WITH constant(1)
     DECLARE chg_action = i2 WITH constant(2)
     DECLARE del_action = i2 WITH constant(3)
     DECLARE act_action = i2 WITH constant(4)
     DECLARE ina_action = i2 WITH constant(5)
    ENDIF
    SELECT INTO "nl:"
     pn.person_name_id
     FROM person_name pn
     WHERE pn.person_id=comparison_person_id
     HEAD REPORT
      name_size = 0
     DETAIL
      name_size += 1
      IF (mod(name_size,10)=1)
       stat = alterlist(acm_request->person_name_qual,(name_size+ 9))
      ENDIF
      acm_request->person_name_qual[name_size].person_name_id = pn.person_name_id, acm_request->
      person_name_qual[name_size].action_flag = del_action
     FOOT REPORT
      stat = alterlist(acm_request->person_name_qual,name_size)
     WITH nocounter
    ;end select
    EXECUTE acm_write_person_name
    IF ((reply->status_data.status="F"))
     SET complete_status->status = "Z"
     SET complete_status->operationname = "failed executing acm_del_person_name"
    ENDIF
    SET stat = alterlist(acm_request->person_qual,1)
    SET acm_request->person_qual[1].person_id = comparison_person_id
    SET acm_request->person_qual[1].action_flag = del_action
    EXECUTE acm_write_person
    IF ((reply->status_data.status="F"))
     SET complete_status->status = "Z"
     SET complete_status->operationname = "failed executing acm_del_person"
    ENDIF
   ENDIF
   IF (pds_exception_id > 0)
    SELECT INTO "nl:"
     ppp.person_id
     FROM pm_post_process ppp
     WHERE ppp.pm_post_process_id=pds_exception_id
     DETAIL
      temp_person_id = ppp.person_id
     WITH nocounter
    ;end select
    IF (temp_person_id <= 0)
     SET complete_status->status = "F"
     SET complete_status->operationname = "No matching person_id for pds_exception_id"
     RETURN
    ENDIF
   ELSE
    SET temp_person_id = person_id
   ENDIF
   IF ((pds_exceptions->pds_exception_cnt > 0))
    UPDATE  FROM (dummyt d  WITH seq = value(pds_exceptions->pds_exception_cnt)),
      pm_post_process ppp
     SET ppp.process_status_cd = in_printing_cd, ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp.updt_dt_tm =
      cnvtdatetime(sysdate),
      ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx = reqinfo->updt_applctx, ppp.updt_task =
      reqinfo->updt_task
     PLAN (d
      WHERE (pds_exceptions->pds_exception_cnt > 0))
      JOIN (ppp
      WHERE (ppp.pm_post_process_id=pds_exceptions->pds_exception_list[d.seq].pds_exception_id))
     WITH nocounter, status(pds_exceptions->pds_exception_list[d.seq].updt_status)
    ;end update
    FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
      IF ((pds_exceptions->pds_exception_list[index].updt_status != 1))
       SET failed = update_error
       SET table_name = "PM_POST_PROCESS"
       ROLLBACK
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
   COMMIT
   CALL process_pending_documents(temp_person_id,complete_status)
   IF ((complete_status->status="F"))
    ROLLBACK
    IF ((pds_exceptions->pds_exception_cnt > 0))
     UPDATE  FROM (dummyt d  WITH seq = value(pds_exceptions->pds_exception_cnt)),
       pm_post_process ppp
      SET ppp.process_status_cd = in_error_cd, ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp.updt_dt_tm =
       cnvtdatetime(sysdate),
       ppp.updt_id = reqinfo->updt_id, ppp.updt_applctx = reqinfo->updt_applctx, ppp.updt_task =
       reqinfo->updt_task
      PLAN (d
       WHERE (pds_exceptions->pds_exception_cnt > 0))
       JOIN (ppp
       WHERE (ppp.pm_post_process_id=pds_exceptions->pds_exception_list[d.seq].pds_exception_id))
      WITH nocounter, status(pds_exceptions->pds_exception_list[d.seq].updt_status)
     ;end update
     FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
       IF ((pds_exceptions->pds_exception_list[index].updt_status != 1))
        SET failed = update_error
        SET table_name = "PM_POST_PROCESS"
        GO TO exit_script
       ENDIF
     ENDFOR
     COMMIT
    ENDIF
   ELSE
    IF ((pds_exceptions->pds_exception_cnt > 0))
     DELETE  FROM (dummyt d  WITH seq = value(pds_exceptions->pds_exception_cnt)),
       pm_post_process ppp
      SET ppp.seq = 1
      PLAN (d
       WHERE (pds_exceptions->pds_exception_cnt > 0))
       JOIN (ppp
       WHERE (ppp.pm_post_process_id=pds_exceptions->pds_exception_list[d.seq].pds_exception_id))
      WITH nocounter, status(pds_exceptions->pds_exception_list[d.seq].updt_status)
     ;end delete
     FOR (index = 1 TO pds_exceptions->pds_exception_cnt)
       IF ((pds_exceptions->pds_exception_list[index].updt_status != 1))
        SET failed = delete_error
        SET table_name = "PM_POST_PROCESS"
        GO TO exit_script
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
   RETURN(temp_person_id)
 END ;Subroutine
 SUBROUTINE (process_pending_documents(person_id=f8,complete_status=vc(ref)) =f8)
   CALL echo("*****pm_get_post_doc_ref_reply.inc - 666833*****")
   FREE RECORD pdr_reply
   RECORD pdr_reply(
     1 mode = i2
     1 list[*]
       2 pm_post_doc_ref_id = f8
       2 prev_pm_post_doc_ref_id = f8
       2 process_name = vc
       2 sch_flex_id = f8
       2 request_number_cd = f8
       2 action_object_name = vc
       2 document_object_name = vc
       2 document_type_cd = f8
       2 output_dest_cd = f8
       2 copies_nbr = i4
       2 time_based_ops_ind = i2
       2 time_based_object_name = vc
       2 batch_print_ind = i2
       2 mnemonic = vc
       2 organizations[*]
         3 organization_id = f8
       2 related_person_doc_obj_name = vc
       2 related_person_doc_type_cd = f8
       2 ref_org_doc_obj_name = vc
       2 ref_org_doc_type_cd = f8
       2 primary_care_doc_obj_name = vc
       2 primary_care_doc_type_cd = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   DECLARE encounter_cnt = i4 WITH noconstant(0)
   DECLARE lfor = i4 WITH constant(1)
   DECLARE spfmtstring = vc WITH constant("ACM_COMPLETE_PDS_EXCEPTION")
   DECLARE job_status_cd = f8 WITH noconstant(0.0)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE sch_job_cnt = i4 WITH noconstant(0)
   SET stat = uar_get_meaning_by_codeset(23062,"PERFORM",1,job_status_cd)
   FREE RECORD sch_job_xref
   RECORD sch_job_xref(
     1 sch_jobs[*]
       2 sch_job_id = f8
       2 parent_entity_id = f8
       2 parent_entity_name = c32
       2 pm_post_doc_ref_id = f8
       2 encounter_id = f8
   )
   SELECT INTO "nl:"
    sj.sch_job_id, sj.parent_entity_id, sj.parent_entity_name,
    sj.key_entity_id
    FROM sch_job sj
    WHERE sj.parent_entity_id=person_id
     AND sj.parent_entity_name="PERSON"
     AND trim(sj.job_key)="ERM_PMPOSTDOC"
     AND ((sj.job_status_cd+ 0)=job_status_cd)
     AND ((sj.active_ind+ 0)=1)
     AND ((sj.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate))
    HEAD REPORT
     sch_job_cnt = 0
    DETAIL
     IF (mod(sch_job_cnt,10)=0)
      stat = alterlist(sch_job_xref->sch_jobs,(sch_job_cnt+ 10))
     ENDIF
     sch_job_cnt += 1, sch_job_xref->sch_jobs[sch_job_cnt].sch_job_id = sj.sch_job_id, sch_job_xref->
     sch_jobs[sch_job_cnt].parent_entity_id = sj.parent_entity_id,
     sch_job_xref->sch_jobs[sch_job_cnt].parent_entity_name = sj.parent_entity_name, sch_job_xref->
     sch_jobs[sch_job_cnt].pm_post_doc_ref_id = sj.key_entity_id
    FOOT REPORT
     null
   ;end select
   SELECT INTO "nl:"
    sj.sch_job_id, sj.parent_entity_id, sj.parent_entity_name,
    sj.key_entity_id
    FROM encounter e,
     sch_job sj
    PLAN (e
     WHERE e.person_id=person_id
      AND ((e.active_ind+ 0)=1)
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((e.end_effective_dt_tm+ 0) > cnvtdatetime(sysdate)))
     JOIN (sj
     WHERE sj.parent_entity_id=e.encntr_id
      AND sj.parent_entity_name="ENCOUNTER"
      AND trim(sj.job_key)="ERM_PMPOSTDOC"
      AND ((sj.job_status_cd+ 0)=job_status_cd)
      AND ((sj.active_ind+ 0)=1)
      AND ((sj.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate)))
    HEAD REPORT
     null
    DETAIL
     IF (mod(sch_job_cnt,10)=0)
      stat = alterlist(sch_job_xref->sch_jobs,(sch_job_cnt+ 10))
     ENDIF
     sch_job_cnt += 1, sch_job_xref->sch_jobs[sch_job_cnt].sch_job_id = sj.sch_job_id, sch_job_xref->
     sch_jobs[sch_job_cnt].parent_entity_id = sj.parent_entity_id,
     sch_job_xref->sch_jobs[sch_job_cnt].parent_entity_name = sj.parent_entity_name, sch_job_xref->
     sch_jobs[sch_job_cnt].pm_post_doc_ref_id = sj.key_entity_id
    FOOT REPORT
     null
   ;end select
   SELECT INTO "nl:"
    sj.sch_job_id, sj.parent_entity_id, sj.parent_entity_name,
    sj.key_entity_id, sep.encntr_id
    FROM sch_event_patient sep,
     sch_job sj
    PLAN (sep
     WHERE sep.person_id=person_id
      AND ((sep.active_ind+ 0)=1)
      AND sep.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((sep.end_effective_dt_tm+ 0) > cnvtdatetime(sysdate)))
     JOIN (sj
     WHERE sj.parent_entity_id=sep.sch_event_id
      AND sj.parent_entity_name="SCH_EVENT"
      AND trim(sj.job_key)="ERM_PMPOSTDOC"
      AND ((sj.job_status_cd+ 0)=job_status_cd)
      AND ((sj.active_ind+ 0)=1)
      AND ((sj.beg_effective_dt_tm+ 0) <= cnvtdatetime(sysdate)))
    HEAD REPORT
     null
    DETAIL
     IF (mod(sch_job_cnt,10)=0)
      stat = alterlist(sch_job_xref->sch_jobs,(sch_job_cnt+ 10))
     ENDIF
     sch_job_cnt += 1, sch_job_xref->sch_jobs[sch_job_cnt].sch_job_id = sj.sch_job_id, sch_job_xref->
     sch_jobs[sch_job_cnt].parent_entity_id = sj.parent_entity_id,
     sch_job_xref->sch_jobs[sch_job_cnt].parent_entity_name = sj.parent_entity_name, sch_job_xref->
     sch_jobs[sch_job_cnt].pm_post_doc_ref_id = sj.key_entity_id, sch_job_xref->sch_jobs[sch_job_cnt]
     .encounter_id = sep.encntr_id
    FOOT REPORT
     stat = alterlist(sch_job_xref->sch_jobs,sch_job_cnt)
   ;end select
   DECLARE acm_complete_j = i4 WITH noconstant(0)
   DECLARE k = i4 WITH noconstant(0)
   DECLARE bcreatereq = i2 WITH noconstant(0)
   DECLARE listcnt = i4 WITH noconstant(0)
   DECLARE bprocessdoc = i2 WITH noconstant(0)
   DECLARE is_patient_deceased = i2 WITH protect, noconstant(false)
   IF (skip_dec_print_cd > 0.0)
    SELECT INTO "nl:"
     p.person_id
     FROM person p
     PLAN (p
      WHERE p.person_id=person_id
       AND ((p.deceased_dt_tm+ 0) != null)
       AND ((p.deceased_dt_tm+ 0) > cnvtdatetime(min_sentinel_date)))
     DETAIL
      is_patient_deceased = true
     WITH nocounter
    ;end select
   ENDIF
   IF (is_patient_deceased=false)
    FOR (acm_complete_j = 1 TO sch_job_cnt)
      FREE RECORD pdr_req
      RECORD pdr_req(
        1 action_flag = i4
        1 pm_post_doc_ref_id = f8
        1 document_type_cd = f8
        1 request_number_cd = f8
      )
      SET pdr_req->action_flag = 0
      SET pdr_req->pm_post_doc_ref_id = sch_job_xref->sch_jobs[acm_complete_j].pm_post_doc_ref_id
      EXECUTE pm_get_post_doc_ref  WITH replace("REQUEST","PDR_REQ"), replace("REPLY","PDR_REPLY")
      IF ((pdr_reply->status_data.status != "S"))
       SET complete_status->operationname = "Failure on call to pm_get_post_doc_ref"
       SET complete_status->status = "F"
       RETURN
      ENDIF
      SET listcnt = size(pdr_reply->list,5)
      IF (listcnt > 0)
       IF ((sch_job_xref->sch_jobs[acm_complete_j].parent_entity_name="PERSON"))
        SET bprocessdoc = processdocuments(1,sch_job_xref->sch_jobs[acm_complete_j].parent_entity_id,
         0.0,0.0,0.0,
         0.0)
       ELSEIF ((sch_job_xref->sch_jobs[acm_complete_j].parent_entity_name="ENCOUNTER"))
        SET bprocessdoc = processdocuments(1,person_id,sch_job_xref->sch_jobs[acm_complete_j].
         parent_entity_id,0.0,0.0,
         0.0)
       ELSE
        SET bprocessdoc = processdocuments(1,person_id,sch_job_xref->sch_jobs[acm_complete_j].
         encounter_id,sch_job_xref->sch_jobs[acm_complete_j].parent_entity_id,0.0,
         0.0)
       ENDIF
       IF (bprocessdoc=false)
        SET complete_status->status = "F"
        RETURN
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (sch_job_cnt > 0)
    DELETE  FROM sch_job sj
     WHERE expand(i,1,sch_job_cnt,sj.sch_job_id,sch_job_xref->sch_jobs[i].sch_job_id)
    ;end delete
   ENDIF
   RETURN(person_id)
 END ;Subroutine
 SUBROUTINE (update_nhs_status_cd(nhs_status_cd=f8,person_alias_id=f8,complete_status=vc(ref)) =null)
   FREE RECORD person_alias_request
   RECORD person_alias_request(
     1 call_echo_ind = i2
     1 person_alias_qual = i4
     1 esi_ensure_type = c3
     1 mode = i2
     1 person_alias[*]
       2 action_type = c3
       2 new_person = c1
       2 person_alias_id = f8
       2 person_id = f8
       2 pm_hist_tracking_id = f8
       2 transaction_dt_tm = dq8
       2 active_ind_ind = i2
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 alias_pool_cd = f8
       2 person_alias_type_cd = f8
       2 alias = vc
       2 person_alias_sub_type_cd = f8
       2 check_digit = i4
       2 check_digit_method_cd = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 data_status_cd = f8
       2 data_status_dt_tm = dq8
       2 data_status_prsnl_id = f8
       2 contributor_system_cd = f8
       2 visit_seq_nbr = i4
       2 health_card_province = c3
       2 health_card_ver_code = c3
       2 health_card_type = c32
       2 health_card_issue_dt_tm = dq8
       2 health_card_expiry_dt_tm = dq8
       2 updt_cnt = i4
       2 assign_authority_sys_cd = f8
       2 person_alias_status_cd = f8
       2 contributor_system_cd = f8
       2 visit_seq_nbr = i4
       2 health_card_province = c3
       2 health_card_ver_code = c3
       2 health_card_type = c32
       2 health_card_issue_dt_tm = dq8
       2 health_card_expiry_dt_tm = dq8
       2 updt_cnt = i4
       2 assign_authority_sys_cd = dq8
       2 person_alias_status_cd = dq8
   )
   SET person_alias_request->person_alias_qual = 1
   SET stat = alterlist(person_alias_request->person_alias,1)
   SET person_alias_request->person_alias[1].action_type = "UPT"
   SET person_alias_request->person_alias[1].person_alias_id = person_alias_id
   SET person_alias_request->person_alias[1].person_id = 0
   SET person_alias_request->person_alias[1].person_alias_type_cd = 0
   SET person_alias_request->person_alias[1].person_alias_status_cd = nhs_status_cd
   SET person_alias_request->person_alias[1].data_status_cd = reqdata->data_status_cd
   SET person_alias_request->person_alias[1].alias = " "
   SET person_alias_request->person_alias[1].health_card_province = " "
   SET person_alias_request->person_alias[1].health_card_ver_code = " "
   SET person_alias_request->person_alias[1].health_card_type = " "
   FREE RECORD person_alias_reply
   RECORD person_alias_reply(
     1 person_alias_qual = i4
     1 person_alias[*]
       2 person_alias_id = f8
       2 pm_hist_tracking_id = f8
       2 assign_authority_sys_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   EXECUTE pm_upt_person_alias  WITH replace("REQUEST","PERSON_ALIAS_REQUEST"), replace("REPLY",
    "PERSON_ALIAS_REPLY")
   IF ((person_alias_reply->status_data.status="F"))
    SET complete_status->status = "F"
    SET complete_status->operationname = "Failed updating NHS status code"
    RETURN
   ENDIF
 END ;Subroutine
 DECLARE nhs_status_cd = f8 WITH constant(request->nhs_status_cd)
 DECLARE ssn_cd = f8 WITH protect, constant(loadcodevalue(4,"SSN",0))
 DECLARE local_person_id = f8 WITH protect, noconstant(0.0)
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug_cnt = i4
   1 debug[*]
     2 line = vc
   1 person_qual_cnt = i4
   1 person_qual[*]
     2 person_id = f8
     2 status = i2
   1 person_name_qual_cnt = i4
   1 person_name_qual[*]
     2 person_name_id = f8
     2 status = i2
 )
 FREE RECORD complete_status
 RECORD complete_status(
   1 status = c1
   1 operationname = c25
 )
 CALL complete_post_processing(request->person_id,complete_status)
 SET local_person_id = complete_pds_exception(request->pds_exception_id,request->person_id,request->
  source_version_number,complete_status)
 IF ((request->person_id > 0))
  SET local_person_id = request->person_id
 ENDIF
 IF ((complete_status->status="F"))
  SET failed = true
  GO TO exit_script
 ENDIF
 IF ((request->nhs_status_cd > 0)
  AND local_person_id > 0)
  SET dpersonaliasid = 0.0
  SELECT INTO "nl:"
   FROM person_alias pa
   PLAN (pa
    WHERE pa.person_id=local_person_id
     AND pa.person_alias_type_cd=ssn_cd
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   DETAIL
    dpersonaliasid = pa.person_alias_id
   WITH nocounter
  ;end select
  CALL update_nhs_status_cd(request->nhs_status_cd,dpersonaliasid,complete_status)
 ENDIF
 SET reply->status_data.status = complete_status->status
 IF ((reply->status_data.status="F"))
  SET failed = true
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed=false)
  SET reqinfo->commit_ind = true
  IF ((reply->status_data.status="Z"))
   SET reply->status_data.subeventstatus.operationname = complete_status->operationname
  ENDIF
 ELSE
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "F"
  SET failed = execute_error
  SET table_name = complete_status->operationname
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 += 1
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
END GO
