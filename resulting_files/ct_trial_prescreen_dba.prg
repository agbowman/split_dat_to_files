CREATE PROGRAM ct_trial_prescreen:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Execution Mode:" = "",
  "Evaluation Start Date" = curdate,
  "Evaluation End Date" = curdate,
  "Encounter types to be considered:" = 0,
  "Facility to be evaluated:" = 0,
  "Protocols to be Considered:" = "",
  "For Report Order By:" = 0,
  "Gender" = 0.000000,
  "Age Qualifier" = 0.000000,
  "Age 1 (years)" = 0,
  "Age 2 (years)" = 0,
  "Evaluation By:" = 0
  WITH outdev, execmode, startdate,
  enddate, encntrtypecd, facilitycd,
  triggername, orderby, gender,
  qualifier, age1, age2,
  evalby
 RECORD eksctrequesttobechunked(
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 sex_cd = f8
     2 birth_dt_tm = dq8
     2 race_cd = f8
 )
 RECORD paramlists(
   1 etypecnt = i4
   1 eanyflag = i2
   1 equal[*]
     2 etypecd = f8
   1 faccnt = i4
   1 fanyflag = i2
   1 fqual[*]
     2 faccd = f8
   1 protcnt = i4
   1 pqual[*]
     2 primary_mnemonic = vc
 )
 RECORD consolidated_chunks_reply(
   1 ctfndind = i2
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 ctcnt = i4
     2 ctqual[*]
       3 pt_prot_prescreen_id = f8
       3 primary_mnemonic = vc
       3 prot_master_id = f8
       3 comment = vc
 )
 RECORD ct_get_pref_request(
   1 pref_entry = vc
 )
 RECORD ct_get_pref_reply(
   1 pref_value = i4
   1 pref_values[*]
     2 values = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD runpsjobrequest(
   1 type_flag = i2
   1 job_details = vc
 )
 SUBROUTINE (buildjobdetails(temp=i2) =i2)
   RECORD details_request(
     1 startdttm = dq8
     1 enddttm = dq8
     1 eanyflag = i2
     1 enctrlist[*]
       2 etypecd = f8
     1 fanyflag = i2
     1 facilitylist[*]
       2 faccd = f8
     1 protlist[*]
       2 primary_mnemonic = vc
     1 agequalifiercd = f8
     1 age1 = i4
     1 age2 = i4
     1 gendercd = f8
   )
   RECORD details_reply(
     1 jobdetails = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET details_request->startdttm = cnvtdatetime(startdttm)
   SET details_request->enddttm = cnvtdatetime(enddttm)
   SET details_request->eanyflag = paramlists->eanyflag
   IF ((paramlists->etypecnt > 0))
    SET stat = alterlist(details_request->enctrlist,paramlists->etypecnt)
    FOR (indx = 1 TO paramlists->etypecnt)
      SET details_request->enctrlist[indx].etypecd = paramlists->equal[indx].etypecd
    ENDFOR
   ENDIF
   SET details_request->fanyflag = paramlists->fanyflag
   IF ((paramlists->faccnt > 0))
    SET stat = alterlist(details_request->facilitylist,paramlists->faccnt)
    FOR (indx = 1 TO paramlists->faccnt)
      SET details_request->facilitylist[indx].faccd = paramlists->fqual[indx].faccd
    ENDFOR
   ENDIF
   SET checkprotcnt = size(eksctrequest->checkct,5)
   IF (checkprotcnt > 0)
    SET stat = alterlist(details_request->protlist,checkprotcnt)
    FOR (indx = 1 TO checkprotcnt)
      SET details_request->protlist[indx].primary_mnemonic = eksctrequest->checkct[indx].
      primary_mnemonic
    ENDFOR
   ENDIF
   SET details_request->agequalifiercd = agequal
   SET details_request->age1 = age1value
   SET details_request->age2 = age2value
   SET details_request->gendercd = persongender
   EXECUTE ct_get_prescreen_job_details  WITH replace("REQUEST","DETAILS_REQUEST"), replace("REPLY",
    "DETAILS_REPLY")
   SET runpsjobrequest->job_details = details_reply->jobdetails
   CALL echo(build("Job details are:",runpsjobrequest->job_details))
   RETURN(1)
 END ;Subroutine
 RECORD label(
   1 rpt_title = vc
   1 rpt_patient = vc
   1 rpt_encounter = vc
   1 rpt_gender = vc
   1 rpt_age = vc
   1 rpt_reg_dt = vc
   1 rpt_race = vc
   1 rpt_facility = vc
   1 rpt_pt_inquiry_rpt = vc
   1 rpt_pt_view_prescreen = vc
 )
 DECLARE updatequeryforevaluationby(dummy) = null WITH protect
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
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE rpt_title_test = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "TEST_SCREENING_PRESCREEN_RPT","Test Pre-Screening"))
 DECLARE rpt_title = vc WITH constant(uar_i18ngetmessage(i18nhandle,"SCREENING_PRESCREEN_RPT",
   "Pre-Screening"))
 SET label->rpt_title = uar_i18ngetmessage(i18nhandle,"SCREENING_PRESCREEN_RPT","Pre-Screening")
 SET label->rpt_patient = uar_i18ngetmessage(i18nhandle,"PATIENT_PRESCREEN_RPT","Patient (person_id)"
  )
 SET label->rpt_encounter = uar_i18ngetmessage(i18nhandle,"ENCNTR_PRESCREEN_RPT",
  "Encounter Type (encntr_id)")
 SET label->rpt_gender = uar_i18ngetmessage(i18nhandle,"GENDER_PRESCREEN_RPT","Gender")
 SET label->rpt_age = uar_i18ngetmessage(i18nhandle,"AGE_PRESCREEN_RPT","Age")
 SET label->rpt_reg_dt = uar_i18ngetmessage(i18nhandle,"REG_DT_PRESCREEN_RPT",
  "Registration Date/Time")
 SET label->rpt_race = uar_i18ngetmessage(i18nhandle,"RACE_PRESCREEN_RPT","Race")
 SET label->rpt_facility = uar_i18ngetmessage(i18nhandle,"FACILITY_PRESCREEN_RPT","Facility")
 SET label->rpt_pt_inquiry_rpt = uar_i18ngetmessage(i18nhandle,"PT_INQUIRY_RPT",
  "Patient Inquiry Report")
 DECLARE encntrtypecd = f8 WITH public, noconstant(0.0)
 DECLARE facilitycd = f8 WITH public, noconstant(0.0)
 DECLARE startdttm = dq8 WITH public
 DECLARE enddttm = dq8 WITH public
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE outline = vc WITH public
 DECLARE eparse = c20 WITH public
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE num2 = i4 WITH public, noconstant(0)
 DECLARE screener_id = f8 WITH public, noconstant(0.0)
 DECLARE tmpexpression = vc WITH public
 DECLARE tmpparam = vc WITH public
 DECLARE toutputdev = vc WITH public
 DECLARE pmnemonic = vc WITH public
 DECLARE callingcnt = i2 WITH public, noconstant(0)
 DECLARE bset = i2 WITH public, noconstant(0)
 DECLARE prot_cnt = i2 WITH public, noconstant(0)
 DECLARE bfound = i2 WITH public, noconstant(0)
 DECLARE person_cnt = i4 WITH public, noconstant(0)
 DECLARE i = i4 WITH public, noconstant(0)
 DECLARE j = i4 WITH public, noconstant(0)
 DECLARE k = i4 WITH public, noconstant(0)
 DECLARE totallinestr = vc WITH public
 DECLARE datestr = vc WITH public
 DECLARE screenerstr = vc WITH public
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE mrn_count = i4 WITH public, noconstant(0)
 DECLARE title = vc WITH public
 DECLARE length = i2 WITH public, noconstant(0)
 DECLARE match_count = i4 WITH public, noconstant(0)
 DECLARE pooldisp = vc WITH public
 DECLARE mrn_cd = f8 WITH public, noconstant(0.0)
 DECLARE lastrow = i2 WITH public, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE faccnt = i4 WITH public, noconstant(0)
 DECLARE persongender = f8 WITH public, noconstant(0.0)
 DECLARE personage = i2 WITH public, noconstant(0)
 DECLARE agequal = f8 WITH public, noconstant(0.0)
 DECLARE age1value = i4 WITH public, noconstant(0)
 DECLARE age2value = i4 WITH public, noconstant(0)
 DECLARE genderqual = vc WITH public
 DECLARE age_qual = vc WITH public
 DECLARE equal_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE grtrthan_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE grtrthaneq_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE lessthan_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE lessthaneq_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE notequal_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE between_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE agestartdttm = dq8 WITH public
 DECLARE ageenddttm = dq8 WITH public
 DECLARE age1lookback = vc WITH public
 DECLARE age2lookback = vc WITH public
 DECLARE minutes_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE hours_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE days_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE weeks_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE months_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE years_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE age1unit = f8 WITH public, noconstant(0.0)
 DECLARE indx = i4 WITH public, noconstant(0)
 DECLARE checkprotcnt = i4 WITH public, noconstant(0)
 DECLARE pendingjob = f8 WITH public, constant(uar_get_code_by("MEANING",17917,"PENDING"))
 DECLARE pending_job_ind = i2 WITH public, noconstant(0)
 DECLARE label = vc WITH public
 DECLARE evaluationbywherestring = vc WITH protect, noconstant("")
 DECLARE appointmentwherestring = vc WITH protect, noconstant("")
 DECLARE active_cd = f8 WITH public, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE active_encntr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"ACTIVE"))
 DECLARE discharged_encntr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",261,"DISCHARGED"))
 DECLARE pending_job_created_ind = i2 WITH public, noconstant(0)
 DECLARE prescreen_parent_job_id = f8 WITH public, noconstant(0.0)
 DECLARE chunks = i4 WITH public, noconstant(0)
 DECLARE chunk_index = i4 WITH protect, noconstant(0)
 DECLARE nested_index_from = i4 WITH protect, noconstant(0)
 DECLARE nested_index_to = i4 WITH protect, noconstant(0)
 DECLARE ndx1 = i4 WITH protect, noconstant(0)
 DECLARE recordindex = i4 WITH protect, noconstant(0)
 DECLARE chunk_size = i4 WITH protect, constant(20000)
 DECLARE last_chunk_remove = i4 WITH protect, noconstant(0)
 DECLARE reply_index = i4 WITH protect, noconstant(0)
 DECLARE reply_chunk = i4 WITH protect, noconstant(0)
 DECLARE chunk_reply_index = i4 WITH protect, noconstant(0)
 DECLARE chunk_reply_ctqual_index = i4 WITH protect, noconstant(0)
 DECLARE chunked_reply_size = i4 WITH protect, noconstant(0)
 DECLARE eksctreply_index = i4 WITH protect, noconstant(0)
 DECLARE eksctreply_ctcnt_index = i4 WITH protect, noconstant(0)
 DECLARE chunked_reply_qual_ctcnt = i4 WITH protect, noconstant(0)
 DECLARE chunk_reply_index_size = i4 WITH protect, noconstant(0)
 DECLARE consolidated_chunks_reply_ctcnt = i4 WITH protect, noconstant(0)
 DECLARE consolidated_chunks_reply_size = i4 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
 IF (( $EXECMODE="PRESCREENT"))
  SET label->rpt_title = rpt_title_test
 ELSE
  SET label->rpt_title = rpt_title
 ENDIF
 RECORD org_sec_reply(
   1 orgsecurityflag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
 CALL echo(build("org_sec_reply->OrgSecurityFlag: ",org_sec_reply->orgsecurityflag))
 SET match_count = 0
 SET datestr = format(cnvtdatetime(sysdate),"@MEDIUMDATETIME")
 RECORD protlist(
   1 protqual[*]
     2 primary_mnemonic = vc
     2 init_service = vc
     2 prot_master_id = f8
     2 personcnt = i4
     2 personqual[*]
       3 person_id = f8
       3 comment = vc
 )
 SET stat = uar_get_meaning_by_codeset(17913,"EQUAL",1,equal_type_cd)
 SET stat = uar_get_meaning_by_codeset(17913,"GRTRTHAN",1,grtrthan_type_cd)
 SET stat = uar_get_meaning_by_codeset(17913,"GRTRTHANEQ",1,grtrthaneq_type_cd)
 SET stat = uar_get_meaning_by_codeset(17913,"LESSTHAN",1,lessthan_type_cd)
 SET stat = uar_get_meaning_by_codeset(17913,"LESSTHANEQ",1,lessthaneq_type_cd)
 SET stat = uar_get_meaning_by_codeset(17913,"NOTEQUAL",1,notequal_type_cd)
 SET stat = uar_get_meaning_by_codeset(17913,"BETWEEN",1,between_type_cd)
 SET stat = uar_get_meaning_by_codeset(340,"MINUTES",1,minutes_type_cd)
 SET stat = uar_get_meaning_by_codeset(340,"HOURS",1,hours_type_cd)
 SET stat = uar_get_meaning_by_codeset(340,"DAYS",1,days_type_cd)
 SET stat = uar_get_meaning_by_codeset(340,"WEEKS",1,weeks_type_cd)
 SET stat = uar_get_meaning_by_codeset(340,"MONTHS",1,months_type_cd)
 SET stat = uar_get_meaning_by_codeset(340,"YEARS",1,years_type_cd)
 RECORD eksctrequest(
   1 opsind = i2
   1 execmodeflag = i2
   1 screenerid = f8
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 accession_id = f8
     2 sex_cd = f8
     2 birth_dt_tm = dq8
     2 race_cd = f8
     2 currentct[*]
       3 prot_master_id = f8
       3 primary_mnemonic = vc
   1 checkct[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
 )
 RECORD eksctreply(
   1 ctfndind = i2
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 ctcnt = i4
     2 ctqual[*]
       3 pt_prot_prescreen_id = f8
       3 primary_mnemonic = vc
       3 prot_master_id = f8
       3 comment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE req = i4
 DECLARE happ = i4
 DECLARE htask = i4
 DECLARE hreq = i4
 DECLARE hreply = i4
 DECLARE crmstatus = i4
 SET ecrmok = 0
 SET null = 0
 IF (validate(recdate,"Y")="Y"
  AND validate(recdate,"N")="N")
  RECORD recdate(
    1 datetime = dq8
  )
 ENDIF
 SUBROUTINE srvrequest(dparam)
   IF (eksctrequest->opsind)
    SET req = 3091003
   ELSE
    SET req = 3091002
   ENDIF
   SET happ = 0
   SET app = 3055000
   SET task = 4801
   SET endapp = 0
   SET endtask = 0
   SET endreq = 0
   CALL echo(concat("curenv = ",build(curenv)))
   IF (curenv=0)
    CALL echo("Calling srv, crm, cclsec")
    EXECUTE srvrtl
    EXECUTE crmrtl
    IF ( NOT (xxcclseclogin->loggedin))
     EXECUTE cclseclogin
    ENDIF
    SET crmstatus = uar_crmbeginapp(app,happ)
    CALL echo(concat("beginapp status = ",build(crmstatus)))
    IF (happ)
     SET endapp = 1
    ENDIF
   ELSE
    SET happ = uar_crmgetapphandle()
   ENDIF
   IF (happ > 0)
    SET crmstatus = uar_crmbegintask(happ,task,htask)
    IF (crmstatus != ecrmok)
     CALL echo("Invalid CrmBeginTask return status")
     SET retval = - (1)
    ELSE
     SET endtask = 1
     SET crmstatus = uar_crmbeginreq(htask,0,req,hreq)
     IF (crmstatus != ecrmok)
      SET retval = - (1)
      CALL echo(concat("Invalid CrmBeginReq return status of ",build(crmstatus)))
     ELSEIF (hreq=null)
      SET retval = - (1)
      CALL echo("Invalid hReq handle")
     ELSE
      SET endreq = 1
      SET request_handle = hreq
      SET heksctrequest = uar_crmgetrequest(hreq)
      IF (heksctrequest=null)
       SET retval = - (1)
       CALL echo("Invalid request handle return from CrmGetRequest")
      ELSE
       SET stat = uar_srvsetshort(heksctrequest,"OPSIND",eksctrequest->opsind)
       SET stat = uar_srvsetshort(heksctrequest,"EXECMODEFLAG",eksctrequest->execmodeflag)
       SET stat = uar_srvsetdouble(heksctrequest,"SCREENERID",eksctrequest->screenerid)
       FOR (ndx1 = 1 TO size(eksctrequest->qual,5))
        SET hqual = uar_srvadditem(heksctrequest,"QUAL")
        IF (hqual=null)
         CALL echo("QUAL","Invalid handle")
        ELSE
         SET stat = uar_srvsetdouble(hqual,"PERSON_ID",eksctrequest->qual[ndx1].person_id)
         SET stat = uar_srvsetdouble(hqual,"SEX_CD",eksctrequest->qual[ndx1].sex_cd)
         SET recdate->datetime = eksctrequest->qual[ndx1].birth_dt_tm
         SET stat = uar_srvsetdate2(hqual,"BIRTH_DT_TM",recdate)
         SET stat = uar_srvsetdouble(hqual,"ENCNTR_ID",eksctrequest->qual[ndx1].encntr_id)
         SET stat = uar_srvsetdouble(hqual,"ACCESSION_ID",eksctrequest->qual[ndx1].accession_id)
         SET stat = uar_srvsetdouble(hqual,"ORDER_ID",eksctrequest->qual[ndx1].order_id)
         SET stat = uar_srvsetdouble(hqual,"RACE_CD",eksctrequest->qual[ndx1].race_cd)
         FOR (ndx2 = 1 TO size(eksctrequest->qual[ndx1].currentct,5))
          SET hdata = uar_srvadditem(hqual,"CURRENTCT")
          IF (hdata=null)
           CALL echo("CURRENTCT","Invalid handle")
          ELSE
           SET stat = uar_srvsetstring(hdata,"PRIMARY_MNEMONIC",nullterm(eksctrequest->qual[ndx1].
             currentct[ndx2].primary_mnemonic))
           SET stat = uar_srvsetdouble(hdata,"PROT_MASTER_ID_ID",eksctrequest->qual[ndx1].currentct[
            ndx2].prot_master_id)
          ENDIF
         ENDFOR
         SET retval = 100
        ENDIF
       ENDFOR
       FOR (ndx1 = 1 TO size(eksctrequest->checkct,5))
        SET hqual = uar_srvadditem(heksctrequest,"CHECKCT")
        IF (hqual=null)
         CALL echo("CHECKCT","Invalid handle")
        ELSE
         SET stat = uar_srvsetdouble(hqual,"PROT_MASTER_ID",eksctrequest->checkct[ndx1].
          prot_master_id)
         SET stat = uar_srvsetstring(hqual,"PRIMARY_MNEMONIC",nullterm(eksctrequest->checkct[ndx1].
           primary_mnemonic))
        ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (crmstatus=ecrmok)
    CALL echo(concat("**** Begin perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
       "dd-mmm-yyyy;;d")," ",
      format(curtime3,"hh:mm:ss.cc;3;m")))
    SET crmstatus = uar_crmperform(hreq)
    CALL echo(concat("**** End perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
       "dd-mmm-yyyy;;d")," ",
      format(curtime3,"hh:mm:ss.cc;3;m")))
    IF (crmstatus != ecrmok)
     SET retval = - (1)
     CALL echo("Invalid CrmPerform return status")
    ELSE
     SET retval = 100
     CALL echo("CrmPerform was successful")
     IF (req=3091002)
      SET hreply = uar_crmgetreply(hreq)
      IF (hreply=null)
       CALL echo("Error in CrmGetReply, invalid handle returned.")
      ELSE
       CALL echo("Retrieving reply message...")
       SET eksctreply->ctfndind = uar_srvgetshort(hreply,"ctFndInd")
       SET cur_qualcnt = uar_srvgetitemcount(hreply,"qual")
       SET stat = alterlist(eksctreply->qual,cur_qualcnt)
       FOR (cur_qual = 1 TO cur_qualcnt)
        SET hquallist = uar_srvgetitem(hreply,"qual",(cur_qual - 1))
        IF (hquallist=null)
         CALL echo("Invalid hQualList handle returned from SrvGetItem")
         SET cur_qual = cur_qualcnt
        ELSE
         SET eksctreply->qual[cur_qual].person_id = uar_srvgetdouble(hquallist,"person_id")
         SET eksctreply->qual[cur_qual].encntr_id = uar_srvgetdouble(hquallist,"encntr_id")
         SET eksctreply->qual[cur_qual].ctcnt = uar_srvgetlong(hquallist,"ctCnt")
         SET cur_ctqualcnt = uar_srvgetitemcount(hquallist,"ctQual")
         IF (cur_ctqualcnt)
          SET stat = alterlist(eksctreply->qual[cur_qual].ctqual,cur_ctqualcnt)
          CALL echo(concat(build(cur_ctqualcnt)," entries are in ctQual"))
          FOR (cur_ctqual = 1 TO cur_ctqualcnt)
           SET hctquallist = uar_srvgetitem(hquallist,"ctQual",(cur_ctqual - 1))
           IF (hctquallist=null)
            CALL echo("Invalid hctQualList handle returned from SrvGetItem")
            SET cur_ctqual = cur_ctqualcnt
           ELSE
            SET eksctreply->qual[cur_qual].ctqual[cur_ctqual].pt_prot_prescreen_id = uar_srvgetdouble
            (hctquallist,"pt_prot_prescreen_id")
            SET eksctreply->qual[cur_qual].ctqual[cur_ctqual].prot_master_id = uar_srvgetdouble(
             hctquallist,"prot_master_id")
            SET eksctreply->qual[cur_qual].ctqual[cur_ctqual].primary_mnemonic = uar_srvgetstringptr(
             hctquallist,"primary_mnemonic")
            SET eksctreply->qual[cur_qual].ctqual[cur_ctqual].comment = uar_srvgetstringptr(
             hctquallist,"comment")
           ENDIF
          ENDFOR
         ENDIF
        ENDIF
       ENDFOR
       CALL echorecord(eksctreply)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET retval = - (1)
    CALL echo("CrmPerform not executed do to begin request error")
   ENDIF
   IF (endreq)
    CALL echo("Ending CRM Request")
    CALL uar_crmendreq(hreq)
   ENDIF
   IF (endtask)
    CALL echo("Ending CRM Task")
    CALL uar_crmendtask(htask)
   ENDIF
   IF (endapp)
    CALL echo("Ending CRM App")
    CALL uar_crmendapp(happ)
   ENDIF
 END ;Subroutine
 CALL echo(concat("$startDate = ",build( $STARTDATE)))
 CALL echo(concat("$endDate = ",build( $ENDDATE)))
 CALL echo(concat("reflect $encntrTypeCd = ",reflect(parameter(5,0))))
 CALL echo(concat("reflect $facilityCd = ",reflect(parameter(6,0))))
 CALL echo(concat("reflect $startDate = ",reflect( $STARTDATE)))
 CALL echo(concat("reflect $triggerName = ",reflect(parameter(7,0))))
 CALL echo(concat("Execution Mode = ", $EXECMODE))
 CALL echo(concat("Order By = ",cnvtstring( $ORDERBY)))
 IF (( $EXECMODE="PATIENTINQ"))
  SET eksctrequest->execmodeflag = - (1)
 ELSEIF (( $EXECMODE="PRESCREEN"))
  SET eksctrequest->execmodeflag = 1
 ELSEIF (( $EXECMODE="PRESCREENT"))
  SET eksctrequest->execmodeflag = 0
 ENDIF
 IF ((eksctrequest->execmodeflag >= 0))
  SET ct_get_pref_request->pref_entry = "trial_screener_run_mode"
  EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","CT_GET_PREF_REQUEST"), replace("REPLY",
   "CT_GET_PREF_REPLY")
  SET eksctrequest->opsind = ct_get_pref_reply->pref_value
 ELSE
  SET eksctrequest->opsind = 0
 ENDIF
 IF ((eksctrequest->opsind=1)
  AND (eksctrequest->execmodeflag=0))
  SET runpsjobrequest->type_flag = 1
 ELSEIF ((eksctrequest->opsind=1)
  AND (eksctrequest->execmodeflag=1))
  SET runpsjobrequest->type_flag = 2
 ELSE
  SET runpsjobrequest->type_flag = 0
 ENDIF
 SET eparse = reflect(parameter(7,0))
 CALL echo(concat("eParse = ",eparse))
 SET bset = 0
 IF (eparse="C1")
  RECORD calling_reply(
    1 skip = i2
    1 org_security_ind = i2
    1 org_security_fnd = i2
    1 protocol_list[*]
      2 prot_master_id = f8
      2 primary_mnemonic = vc
  )
  SET calling_reply->skip = 1
  SET calling_reply->org_security_ind = org_sec_reply->orgsecurityflag
  SET calling_reply->org_security_fnd = 1
  EXECUTE ct_get_protocol_access 1 WITH replace("PROTLIST","CALLING_REPLY")
  SET bset = 1
  SET callingcnt = size(calling_reply->protocol_list,5)
  SET stat = alterlist(eksctrequest->checkct,callingcnt)
  FOR (indx = 1 TO callingcnt)
   SET eksctrequest->checkct[indx].primary_mnemonic = calling_reply->protocol_list[indx].
   primary_mnemonic
   SET eksctrequest->checkct[indx].prot_master_id = calling_reply->protocol_list[indx].prot_master_id
  ENDFOR
  SET paramlists->protcnt = callingcnt
 ELSEIF (substring(1,1,eparse)="L")
  CALL echo("$triggerName is a list")
  SET cnt = 1
  CALL echo(parameter(7,cnt))
  WHILE (reflect(parameter(7,cnt)) > " ")
    CALL echo(parameter(7,cnt))
    IF (mod(cnt,10)=1)
     SET stat = alterlist(paramlists->pqual,(cnt+ 9))
    ENDIF
    SET paramlists->pqual[cnt].primary_mnemonic = parameter(7,cnt)
    SET cnt += 1
  ENDWHILE
  SET paramlists->protcnt = (cnt - 1)
  SET stat = alterlist(paramlists->pqual,paramlists->protcnt)
 ELSE
  SET paramlists->protcnt = 1
  SET stat = alterlist(paramlists->pqual,paramlists->protcnt)
  SET paramlists->pqual[1].primary_mnemonic = parameter(7,1)
 ENDIF
 IF (bset=0)
  SET stat = alterlist(eksctrequest->checkct,paramlists->protcnt)
  FOR (indx = 1 TO paramlists->protcnt)
    SET eksctrequest->checkct[indx].primary_mnemonic = paramlists->pqual[indx].primary_mnemonic
  ENDFOR
  SELECT INTO "nl:"
   pm.prot_master_id
   FROM prot_master pm,
    (dummyt d  WITH seq = size(eksctrequest->checkct,5))
   PLAN (d)
    JOIN (pm
    WHERE (pm.primary_mnemonic=eksctrequest->checkct[d.seq].primary_mnemonic)
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
   DETAIL
    eksctrequest->checkct[d.seq].prot_master_id = pm.prot_master_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((eksctrequest->opsind=1)
  AND (eksctrequest->execmodeflag=1))
  SET pending_job_ind = 0
  SELECT INTO "nl:"
   pm.prot_master_id
   FROM ct_prescreen_job cp,
    ct_prot_prescreen_job_info cpi,
    (dummyt d  WITH seq = size(eksctrequest->checkct,5))
   PLAN (d)
    JOIN (cpi
    WHERE (cpi.prot_master_id=eksctrequest->checkct[d.seq].prot_master_id)
     AND cpi.completed_flag=0)
    JOIN (cp
    WHERE cp.ct_prescreen_job_id=cpi.ct_prescreen_job_id
     AND cp.job_status_cd=pendingjob)
   DETAIL
    pending_job_ind = 1
   WITH nocounter
  ;end select
  IF (pending_job_ind=1)
   GO TO endprogram
  ENDIF
 ENDIF
 IF ( NOT (curenv))
  SET screener_id = 0.0
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE p.username=curuser
    AND p.active_ind=1
   DETAIL
    screener_id = p.person_id, screenerstr = p.name_full_formatted
   WITH nocounter
  ;end select
 ELSE
  SET screener_id = reqinfo->updt_id
 ENDIF
 SET eksctrequest->screenerid = screener_id
 IF (((eksctrequest->opsind) OR ((eksctrequest->execmodeflag=- (1)))) )
  SET toutputdev =  $OUTDEV
 ELSE
  SET toutputdev = "nl:"
 ENDIF
 SET startdttm = cnvtdatetime(cnvtdate( $STARTDATE),0)
 SET enddttm = cnvtdatetime(cnvtdate( $ENDDATE),2359)
 CALL echo(concat("startDtTm = ",format(startdttm,";;q")))
 CALL echo(concat("endDtTm = ",format(enddttm,";;q")))
 SET paramlists->eanyflag = 0
 SET eparse = reflect(parameter(5,0))
 CALL echo(concat("eParse for encounter type parameter = ",eparse))
 IF (eparse="C1")
  SET paramlists->eanyflag = 1
 ELSEIF (substring(1,1,eparse)="L")
  CALL echo("$encntrTypeCd is a list")
  SET cnt = 1
  WHILE (parameter(5,cnt) > 0)
    CALL echo(parameter(5,cnt))
    IF (mod(cnt,10)=1)
     SET stat = alterlist(paramlists->equal,(cnt+ 9))
    ENDIF
    SET paramlists->equal[cnt].etypecd = parameter(5,cnt)
    SET cnt += 1
  ENDWHILE
  SET paramlists->etypecnt = (cnt - 1)
  SET stat = alterlist(paramlists->equal,paramlists->etypecnt)
 ELSE
  SET paramlists->etypecnt = 1
  SET stat = alterlist(paramlists->equal,1)
  SET paramlists->equal[1].etypecd = parameter(5,1)
 ENDIF
 SET paramlists->fanyflag = 0
 SET eparse = reflect(parameter(6,0))
 CALL echo(concat("eParse for facility parameter = ",eparse))
 IF (eparse="C1")
  IF ((org_sec_reply->orgsecurityflag=0))
   SET paramlists->fanyflag = 1
  ELSE
   RECORD calling_fac_reply(
     1 skip = i2
     1 org_security_ind = i2
     1 org_security_fnd = i2
     1 facility_list[*]
       2 facility_display = vc
       2 facility_cd = f8
   )
   SET calling_fac_reply->skip = 1
   SET calling_fac_reply->org_security_ind = org_sec_reply->orgsecurityflag
   SET calling_fac_reply->org_security_fnd = 1
   EXECUTE ct_get_facility_list  WITH replace("FACILITYLIST","CALLING_FAC_REPLY")
   SET bset = 1
   SET faccnt = size(calling_fac_reply->facility_list,5)
   SET stat = alterlist(paramlists->fqual,faccnt)
   FOR (indx = 1 TO faccnt)
     SET paramlists->fqual[indx].faccd = calling_fac_reply->facility_list[indx].facility_cd
   ENDFOR
   SET paramlists->faccnt = faccnt
  ENDIF
 ELSEIF (substring(1,1,eparse)="L")
  CALL echo("$facilityCd is a list")
  SET cnt = 1
  WHILE (parameter(6,cnt) > 0)
    CALL echo(parameter(6,cnt))
    IF (mod(cnt,10)=1)
     SET stat = alterlist(paramlists->fqual,(cnt+ 9))
    ENDIF
    SET paramlists->fqual[cnt].faccd = parameter(6,cnt)
    SET cnt += 1
  ENDWHILE
  SET paramlists->faccnt = (cnt - 1)
  SET stat = alterlist(paramlists->fqual,paramlists->faccnt)
 ELSE
  SET paramlists->faccnt = 1
  SET stat = alterlist(paramlists->fqual,paramlists->faccnt)
  SET paramlists->fqual[1].faccd = parameter(6,1)
 ENDIF
 SET persongender = cnvtreal( $GENDER)
 IF (persongender=0.0)
  SET genderqual = "1=1"
 ELSE
  SET genderqual = "p.sex_cd = personGender"
 ENDIF
 SET agequal = cnvtreal( $QUALIFIER)
 SET age1value = cnvtint( $AGE1)
 SET age2value = cnvtint( $AGE2)
 SET age_qual = "1=1"
 SET agestartdttm = cnvtdatetime(sysdate)
 SET ageenddttm = cnvtdatetime(sysdate)
 CASE (agequal)
  OF grtrthan_type_cd:
   IF (age1value > 0)
    SET age1lookback = build("'",(age1value+ 1),";Y'")
    SET agestartdttm = cnvtlookbehind(age1lookback)
    SET agestartdttm = datetimeadd(agestartdttm,1)
    SET age2lookback = build("'",150,";Y'")
    SET ageenddttm = cnvtlookbehind(age2lookback)
    SET age_qual = build(
     "p.birth_dt_tm BETWEEN cnvtdatetime(ageEndDtTm) AND cnvtdatetime(ageStartDtTm)")
   ENDIF
  OF grtrthaneq_type_cd:
   IF (age1value > 0)
    SET age1lookback = build("'",age1value,";Y'")
    SET agestartdttm = cnvtlookbehind(age1lookback)
    SET age2lookback = build("'",150,";Y'")
    SET ageenddttm = cnvtlookbehind(age2lookback)
    SET age_qual = build(
     "p.birth_dt_tm BETWEEN cnvtdatetime(ageEndDtTm) AND cnvtdatetime(ageStartDtTm)")
   ENDIF
  OF lessthan_type_cd:
   IF (age1value > 0)
    SET agestartdttm = cnvtdatetime(sysdate)
    SET age1lookback = build("'",age1value,";Y'")
    SET ageenddttm = cnvtlookbehind(age1lookback)
    SET ageenddttm = datetimeadd(ageenddttm,1)
    SET age_qual = build(
     "p.birth_dt_tm BETWEEN cnvtdatetime(ageEndDtTm) AND cnvtdatetime(ageStartDtTm)")
   ENDIF
  OF lessthaneq_type_cd:
   IF (age1value > 0)
    SET agestartdttm = cnvtdatetime(sysdate)
    SET age1lookback = build("'",(age1value+ 1),";Y'")
    SET ageenddttm = cnvtlookbehind(age1lookback)
    SET ageenddttm = datetimeadd(ageenddttm,1)
    SET age_qual = build(
     "p.birth_dt_tm BETWEEN cnvtdatetime(ageEndDtTm) AND cnvtdatetime(ageStartDtTm)")
   ENDIF
  OF between_type_cd:
   IF (age1value >= 0
    AND age2value > 0)
    SET age1lookback = build("'",age1value,";Y'")
    SET agestartdttm = cnvtlookbehind(age1lookback)
    SET age2lookback = build("'",(age2value+ 1),";Y'")
    SET ageenddttm = cnvtlookbehind(age2lookback)
    SET ageenddttm = datetimeadd(ageenddttm,1)
    SET age_qual = build(
     "p.birth_dt_tm BETWEEN cnvtdatetime(ageEndDtTm) AND cnvtdatetime(ageStartDtTm)")
   ENDIF
 ENDCASE
 CALL echorecord(paramlists)
 CALL updatequeryforevaluationby(null)
 SET cnt = 0
 SELECT
  IF (( $EVALBY < 2))DISTINCT INTO "nl:"
   e.person_id, e.encntr_id, p.sex_cd,
   p.birth_dt_tm
   FROM encounter e,
    person p
   PLAN (e
    WHERE (((paramlists->eanyflag=1)) OR (expand(num,1,paramlists->etypecnt,e.encntr_type_cd,
     paramlists->equal[num].etypecd)))
     AND (((paramlists->fanyflag=1)) OR (expand(num2,1,paramlists->faccnt,e.loc_facility_cd,
     paramlists->fqual[num2].faccd)))
     AND parser(evaluationbywherestring))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND parser(genderqual))
   ORDER BY p.name_last_key, p.name_first_key, p.name_middle_key,
    p.person_id, e.reg_dt_tm DESC
  ELSEIF (( $EVALBY=2))DISTINCT INTO "nl:"
   e.person_id, e.encntr_id, p.sex_cd,
   p.birth_dt_tm
   FROM encounter e,
    person p,
    sch_appt sa
   PLAN (e
    WHERE (((paramlists->eanyflag=1)) OR (expand(num,1,paramlists->etypecnt,e.encntr_type_cd,
     paramlists->equal[num].etypecd)))
     AND (((paramlists->fanyflag=1)) OR (expand(num2,1,paramlists->faccnt,e.loc_facility_cd,
     paramlists->fqual[num2].faccd)))
     AND parser(evaluationbywherestring))
    JOIN (p
    WHERE p.person_id=e.person_id
     AND parser(genderqual))
    JOIN (sa
    WHERE parser(appointmentwherestring))
   ORDER BY p.name_last_key, p.name_first_key, p.name_middle_key,
    p.person_id, e.reg_dt_tm DESC
  ELSE
  ENDIF
  HEAD REPORT
   cnt = 0, personage = (datetimediff(cnvtdatetime(sysdate),p.birth_dt_tm,1)/ 365.25)
  HEAD p.person_id
   bfound = 0
   IF (age_qual != "1=1")
    IF (parser(age_qual))
     bfound = 1
    ELSE
     bfound = 0
    ENDIF
   ELSE
    bfound = 1
   ENDIF
   IF (bfound=1)
    interest = " ", cnt += 1
    IF (mod(cnt,100)=1)
     stat = alterlist(eksctrequesttobechunked->qual,(cnt+ 99))
    ENDIF
    eksctrequesttobechunked->qual[cnt].person_id = e.person_id, eksctrequesttobechunked->qual[cnt].
    sex_cd = p.sex_cd, eksctrequesttobechunked->qual[cnt].birth_dt_tm = p.birth_dt_tm,
    eksctrequesttobechunked->qual[cnt].encntr_id = e.encntr_id, eksctrequesttobechunked->qual[cnt].
    race_cd = p.race_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(eksctrequesttobechunked->qual,cnt)
  WITH nocounter, maxcol = 300
 ;end select
 CALL echo(concat("cnt = ",build(cnt),"     $execMode = ",build( $EXECMODE)))
 CALL echorecord(eksctrequesttobechunked)
 IF (mod(cnt,chunk_size)=0)
  SET chunks = (cnt/ chunk_size)
 ELSE
  SET chunks = ((cnt/ chunk_size)+ 1)
 ENDIF
 FOR (chunk_index = 1 TO chunks)
   SET nested_index_from = (((chunk_index - 1) * chunk_size)+ 1)
   SET nested_index_to = (nested_index_from+ (chunk_size - 1))
   IF (nested_index_to > cnt)
    SET nested_index_to = cnt
   ENDIF
   SET stat = alterlist(eksctrequest->qual,((nested_index_to - nested_index_from)+ 1))
   SET recordindex = 0
   FOR (ndx1 = nested_index_from TO nested_index_to)
     SET recordindex += 1
     SET eksctrequest->qual[recordindex].person_id = eksctrequesttobechunked->qual[ndx1].person_id
     SET eksctrequest->qual[recordindex].sex_cd = eksctrequesttobechunked->qual[ndx1].sex_cd
     SET eksctrequest->qual[recordindex].birth_dt_tm = eksctrequesttobechunked->qual[ndx1].
     birth_dt_tm
     SET eksctrequest->qual[recordindex].encntr_id = eksctrequesttobechunked->qual[ndx1].encntr_id
     SET eksctrequest->qual[recordindex].race_cd = eksctrequesttobechunked->qual[ndx1].race_cd
   ENDFOR
   IF (cnt
    AND ( $EXECMODE != "PATIENTINQ"))
    IF ((eksctrequest->opsind=1))
     CALL buildjobdetails(0)
    ENDIF
    CALL echorecord(eksctrequest)
    EXECUTE ct_run_prescreen  WITH replace("REQUEST","EKSCTREQUEST"), replace("REPLY","PSCRN_REPLY"),
    replace("JOBDETAILREQUEST","RUNPSJOBREQUEST")
    IF ( NOT (eksctrequest->opsind)
     AND ( $EXECMODE != "PATIENTINQ"))
     IF (size(eksctreply->qual,5) > 0)
      SET chunked_reply_size += ((nested_index_to - nested_index_from)+ 1)
      SET stat = alterlist(consolidated_chunks_reply->qual,chunked_reply_size)
      SET reply_chunk += 1
      SET chunk_reply_index_size = size(eksctreply->qual,5)
      FOR (chunk_reply_index = 1 TO chunk_reply_index_size)
        SET reply_index += 1
        SET consolidated_chunks_reply->qual[reply_index].person_id = eksctreply->qual[
        chunk_reply_index].person_id
        SET consolidated_chunks_reply->qual[reply_index].encntr_id = eksctreply->qual[
        chunk_reply_index].encntr_id
        SET consolidated_chunks_reply->qual[reply_index].ctcnt = eksctreply->qual[chunk_reply_index].
        ctcnt
        SET chunked_reply_qual_ctcnt = consolidated_chunks_reply->qual[reply_index].ctcnt
        IF (chunked_reply_qual_ctcnt)
         SET stat = alterlist(consolidated_chunks_reply->qual[reply_index].ctqual,
          chunked_reply_qual_ctcnt)
         FOR (chunk_reply_ctqual_index = 1 TO chunked_reply_qual_ctcnt)
           SET consolidated_chunks_reply->qual[reply_index].ctqual[chunk_reply_ctqual_index].
           pt_prot_prescreen_id = eksctreply->qual[chunk_reply_index].ctqual[chunk_reply_ctqual_index
           ].pt_prot_prescreen_id
           SET consolidated_chunks_reply->qual[reply_index].ctqual[chunk_reply_ctqual_index].
           primary_mnemonic = eksctreply->qual[chunk_reply_index].ctqual[chunk_reply_ctqual_index].
           primary_mnemonic
           SET consolidated_chunks_reply->qual[reply_index].ctqual[chunk_reply_ctqual_index].
           prot_master_id = eksctreply->qual[chunk_reply_index].ctqual[chunk_reply_ctqual_index].
           prot_master_id
           SET consolidated_chunks_reply->qual[reply_index].ctqual[chunk_reply_ctqual_index].comment
            = eksctreply->qual[chunk_reply_index].ctqual[chunk_reply_ctqual_index].comment
         ENDFOR
        ENDIF
      ENDFOR
      IF (reply_chunk=chunks)
       SET consolidated_chunks_reply_size = size(consolidated_chunks_reply->qual,5)
       SET stat = alterlist(eksctreply->qual,consolidated_chunks_reply_size)
       FOR (eksctreply_index = 1 TO consolidated_chunks_reply_size)
         SET eksctreply->qual[eksctreply_index].person_id = consolidated_chunks_reply->qual[
         eksctreply_index].person_id
         SET eksctreply->qual[eksctreply_index].encntr_id = consolidated_chunks_reply->qual[
         eksctreply_index].encntr_id
         SET eksctreply->qual[eksctreply_index].ctcnt = consolidated_chunks_reply->qual[
         eksctreply_index].ctcnt
         SET consolidated_chunks_reply_ctcnt = consolidated_chunks_reply->qual[eksctreply_index].
         ctcnt
         IF (consolidated_chunks_reply_ctcnt)
          SET stat = alterlist(eksctreply->qual[eksctreply_index].ctqual,
           consolidated_chunks_reply_ctcnt)
          FOR (eksctreply_ctcnt_index = 1 TO consolidated_chunks_reply_ctcnt)
            SET eksctreply->qual[eksctreply_index].ctqual[eksctreply_ctcnt_index].
            pt_prot_prescreen_id = consolidated_chunks_reply->qual[eksctreply_index].ctqual[
            eksctreply_ctcnt_index].pt_prot_prescreen_id
            SET eksctreply->qual[eksctreply_index].ctqual[eksctreply_ctcnt_index].primary_mnemonic =
            consolidated_chunks_reply->qual[eksctreply_index].ctqual[eksctreply_ctcnt_index].
            primary_mnemonic
            SET eksctreply->qual[eksctreply_index].ctqual[eksctreply_ctcnt_index].prot_master_id =
            consolidated_chunks_reply->qual[eksctreply_index].ctqual[eksctreply_ctcnt_index].
            prot_master_id
            SET eksctreply->qual[eksctreply_index].ctqual[eksctreply_ctcnt_index].comment =
            consolidated_chunks_reply->qual[eksctreply_index].ctqual[eksctreply_ctcnt_index].comment
          ENDFOR
         ELSE
          SET stat = alterlist(eksctreply->qual[eksctreply_index].ctqual,0)
         ENDIF
       ENDFOR
       CALL echorecord(eksctreply)
      ENDIF
      IF (( $ORDERBY=0))
       FOR (i = 1 TO size(eksctreply->qual,5))
         FOR (j = 1 TO eksctreply->qual[i].ctcnt)
           IF (prot_cnt=0)
            SET prot_cnt += 1
            SET stat = alterlist(protlist->protqual,prot_cnt)
            SET protlist->protqual[prot_cnt].primary_mnemonic = eksctreply->qual[i].ctqual[j].
            primary_mnemonic
            SET protlist->protqual[prot_cnt].prot_master_id = eksctreply->qual[i].ctqual[j].
            prot_master_id
            SET person_cnt = (size(protlist->protqual[prot_cnt].personqual,5)+ 1)
            SET stat = alterlist(protlist->protqual[prot_cnt].personqual,person_cnt)
            SET protlist->protqual[prot_cnt].personqual[person_cnt].person_id = eksctreply->qual[i].
            person_id
            SET protlist->protqual[prot_cnt].personqual[person_cnt].comment = eksctreply->qual[i].
            ctqual[j].comment
            SET protlist->protqual[prot_cnt].personcnt = person_cnt
           ELSE
            SET bfound = 0
            SET person_cnt = 0
            FOR (k = 1 TO prot_cnt)
             IF ((protlist->protqual[k].prot_master_id=eksctreply->qual[i].ctqual[j].prot_master_id))
              SET bfound = 1
              SET person_cnt = (size(protlist->protqual[k].personqual,5)+ 1)
              SET stat = alterlist(protlist->protqual[k].personqual,person_cnt)
              SET protlist->protqual[k].personqual[person_cnt].person_id = eksctreply->qual[i].
              person_id
              SET protlist->protqual[k].personqual[person_cnt].comment = eksctreply->qual[i].ctqual[j
              ].comment
              SET protlist->protqual[k].personcnt = person_cnt
             ENDIF
             IF (bfound=1)
              SET k = prot_cnt
             ENDIF
            ENDFOR
            IF (bfound=0)
             SET prot_cnt += 1
             SET stat = alterlist(protlist->protqual,prot_cnt)
             SET protlist->protqual[prot_cnt].primary_mnemonic = eksctreply->qual[i].ctqual[j].
             primary_mnemonic
             SET protlist->protqual[prot_cnt].prot_master_id = eksctreply->qual[i].ctqual[j].
             prot_master_id
             SET person_cnt = (size(protlist->protqual[prot_cnt].personqual,5)+ 1)
             SET stat = alterlist(protlist->protqual[prot_cnt].personqual,person_cnt)
             SET protlist->protqual[prot_cnt].personqual[person_cnt].person_id = eksctreply->qual[i].
             person_id
             SET protlist->protqual[prot_cnt].personqual[person_cnt].comment = eksctreply->qual[i].
             ctqual[j].comment
             SET protlist->protqual[prot_cnt].personcnt = person_cnt
            ENDIF
           ENDIF
         ENDFOR
       ENDFOR
       IF (prot_cnt > 0)
        SELECT INTO "nl:"
         FROM (dummyt d1  WITH seq = size(protlist->protqual,5)),
          prot_master pm
         PLAN (d1)
          JOIN (pm
          WHERE (pm.prot_master_id=protlist->protqual[d1.seq].prot_master_id))
         DETAIL
          protlist->protqual[d1.seq].init_service = uar_get_code_display(pm.initiating_service_cd)
         WITH nocounter
        ;end select
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE updatequeryforevaluationby(dummy)
  SET appointmentwherestring = "1=1"
  IF (( $EVALBY=0))
   SET evaluationbywherestring =
   "e.reg_dt_tm BETWEEN cnvtdatetime(startDtTm) and cnvtdatetime(endDtTm)"
  ELSEIF (( $EVALBY=1))
   SET evaluationbywherestring =
"(e.active_ind = 1 and e.active_status_cd = ACTIVE_CD and e.reg_dt_tm <=                         cnvtdatetime(endDtTm)) AND\
 ((e.encntr_status_cd = DISCHARGED_ENCNTR_CD and e.disch_dt_tm >=                         cnvtdatetime(startDtTm)) OR (e.e\
ncntr_status_cd = ACTIVE_ENCNTR_CD and e.disch_dt_tm is NULL))\
"
  ELSEIF (( $EVALBY=2))
   SET evaluationbywherestring = "e.encntr_id > 0.0"
   SET appointmentwherestring =
"((sa.active_ind = 1 AND sa.encntr_id = e.encntr_id)                         AND (sa.beg_dt_tm BETWEEN cnvtdatetime(startDt\
Tm) AND cnvtdatetime(endDtTm))                         AND (sa.state_meaning in ('SCHEDULED', 'RESCHEDULED','CHECKED IN','\
CHECKED OUT','CONFIRMED')))\
"
  ENDIF
 END ;Subroutine
 GO TO endprogram
#endprogram
 SET last_mod = "014"
 SET mod_date = "Jan 14, 2019"
END GO
