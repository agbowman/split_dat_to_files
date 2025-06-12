CREATE PROGRAM ct_pt_rpt_shell:dba
 RECORD ct_request_struct(
   1 output_dest_cd = f8
   1 file_name = vc
   1 copies = i4
   1 output_handle_id = f8
   1 number_of_copies = i4
   1 transmit_dt_tm = dq8
   1 priority_value = i4
   1 report_title = vc
   1 server = vc
   1 country_code = c3
   1 area_code = c10
   1 exchange = c10
   1 suffix = c50
 )
 RECORD ct_reply_struct(
   1 sts = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE rpt_heading = vc WITH public, noconstant("")
 DECLARE pm = vc WITH public, noconstant("")
 DECLARE ln = vc WITH public, constant(fillstring(150,"_"))
 DECLARE err_msg = vc WITH public, noconstant("")
 DECLARE err_num = i4 WITH public, noconstant(0)
 DECLARE lastnmsort = vc WITH public, noconstant("")
 DECLARE lastnm = vc WITH public, noconstant("")
 DECLARE prot = vc WITH public, noconstant("")
 DECLARE personid = f8 WITH public, noconstant(0.0)
 DECLARE tmp_str2 = vc WITH protected, noconstant("")
 DECLARE prot_cnt = i4 WITH public, noconstant(0)
 DECLARE mrn_size = i4 WITH public, noconstant(0)
 DECLARE tmp_prot = f8 WITH public, noconstant(0.0)
 DECLARE multi_prot_ind = i2 WITH public, noconstant(0)
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE temp_time = c6 WITH public, noconstant("")
 DECLARE hold_file = c40 WITH public, noconstant("")
 DECLARE squeuename = vc WITH public, noconstant("")
 DECLARE boutputdest = i2 WITH public, noconstant(0)
 DECLARE estimated_row = i4 WITH public, noconstant(0)
 DECLARE temp_row = i4 WITH public, noconstant(0)
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE tmp_mrn = vc WITH protect, noconstant("")
 DECLARE tmp_apool = vc WITH protect, noconstant("")
 DECLARE tmp_mrn_pool = vc WITH protect, noconstant("")
 DECLARE tmp_ln = vc WITH protect, noconstant("")
 DECLARE tmp_fn = vc WITH protect, noconstant("")
 DECLARE tmp_prot_mnem = vc WITH protect, noconstant("")
 DECLARE tmp_amendment = vc WITH protect, noconstant("")
 DECLARE tmp_rev = vc WITH protect, noconstant("")
 DECLARE tmp_dt_on = vc WITH protect, noconstant("")
 DECLARE tmp_dt_off = vc WITH protect, noconstant("")
 DECLARE tmp_off_study_reason = vc WITH protect, noconstant("")
 DECLARE tmp_stratum = vc WITH protect, noconstant("")
 DECLARE tmp_cohort = vc WITH protect, noconstant("")
 DECLARE tmp_followup = vc WITH protect, noconstant("")
 DECLARE tmp_dt_not_rtnd = vc WITH protect, noconstant("")
 DECLARE tmp_reason = vc WITH protect, noconstant("")
 DECLARE tmp_dt_returned = vc WITH protect, noconstant("")
 DECLARE tmp_dt_signed = vc WITH protect, noconstant("")
 DECLARE tmp_dt_off_tx = vc WITH protect, noconstant("")
 DECLARE tmp_off_tx_reason = vc WITH protect, noconstant("")
 DECLARE tmp_prot_accession_nbr = vc WITH protect, noconstant("")
 DECLARE therapeutic_cd = f8 WITH protect, noconstant(0.0)
 DECLARE therapeutic_ind = i2 WITH protect, noconstant(0)
 DECLARE tempspaces = vc WITH protect, noconstant("")
 DECLARE tmp_str_labels = vc WITH protect, noconstant("")
 DECLARE delimiter = c1 WITH protect, constant(",")
 DECLARE exec_timestamp = vc WITH protect, noconstant("")
 DECLARE formatted_report = i2 WITH protect, constant(0)
 DECLARE delimited_report = i2 WITH protect, constant(1)
 DECLARE colheadertop = vc WITH protect, noconstant("")
 DECLARE colheaderbottom = vc WITH protect, noconstant("")
 SET bstat = uar_get_meaning_by_codeset(17275,"THERAPEUTIC",1,therapeutic_cd)
 SET temp_time = cnvtstring(curtime3,6,0,r)
 SET hold_file = build("CER_PRINT:","CT_VIEW_",temp_time,".DAT")
 SET boutputdest = false
 SET squeuename = ""
 SET reply->node = curnode
 SET reply->status_data.status = "F"
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
 DECLARE m_s_still_registered = vc WITH constant(uar_i18ngetmessage(i18nhandle,"STILL_REGISTERED",
   "Still Registered Patients"))
 DECLARE m_s_still_on_study = vc WITH constant(uar_i18ngetmessage(i18nhandle,"STILL_ON_STUDY",
   "On Study Patients"))
 DECLARE m_s_all_registered = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ALL_REGISTERED",
   "All Patients Registered"))
 DECLARE m_s_all_enrolled = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ALL_ENROLLED",
   "All Enrolled Patients"))
 DECLARE m_s_time_stamp = vc WITH constant(uar_i18ngetmessage(i18nhandle,"TIME_STAMP",
   "Report execution time:"))
 DECLARE m_s_consent_pending = vc WITH constant(uar_i18ngetmessage(i18nhandle,"CONSENT_PENDING",
   "Protocols with Consents Pending Signature"))
 DECLARE m_s_to_be_verified = vc WITH constant(uar_i18ngetmessage(i18nhandle,"TO_BE_VERIFIED",
   "Patients To Be Verified"))
 DECLARE m_s_returned_consents = vc WITH constant(uar_i18ngetmessage(i18nhandle,"RETURNED_CONSENTS",
   "Protocols with Returned Consent Documents"))
 DECLARE m_s_not_returned_consents = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "NOT_RETURNED_CONSENTS","Protocols with Not Returned Consent Documents"))
 DECLARE m_s_for = vc WITH constant(uar_i18ngetmessage(i18nhandle,"FOR","for"))
 DECLARE m_s_last_name = vc WITH constant(uar_i18ngetmessage(i18nhandle,"LAST_NAME","Last Name"))
 DECLARE m_s_first_name = vc WITH constant(uar_i18ngetmessage(i18nhandle,"FIRST_NAME","First Name"))
 DECLARE m_s_mrn = vc WITH constant(uar_i18ngetmessage(i18nhandle,"MRN","MRN"))
 DECLARE m_s_participant_id = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PARTICIPANT_ID",
   "Participant ID"))
 DECLARE m_s_enrollment_id = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ENROLLMENT_ID",
   "Enrollment ID"))
 DECLARE m_s_primary_mnemonic = vc WITH constant(uar_i18ngetmessage(i18nhandle,"PRIMARY_MNEMONIC",
   "Primary Mnemonic"))
 DECLARE m_s_amendment = vc WITH constant(uar_i18ngetmessage(i18nhandle,"AMENDMENT","Amendment"))
 DECLARE m_s_revision = vc WITH constant(uar_i18ngetmessage(i18nhandle,"REVISION","Revision"))
 DECLARE m_s_registered_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"REGISTERED_DATE",
   "Registered Date"))
 DECLARE m_s_on_study_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ON_STUDY_DATE",
   "On Study Date"))
 DECLARE m_s_off_tx_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"OFF_TX_DATE",
   "Off Treatment Date"))
 DECLARE m_s_off_tx_reason = vc WITH constant(uar_i18ngetmessage(i18nhandle,"OFF_TX_REASON",
   "Off Treatment Reason"))
 DECLARE m_s_removal_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"REMOVAL_DATE",
   "Removal Date"))
 DECLARE m_s_removal_reason = vc WITH constant(uar_i18ngetmessage(i18nhandle,"REMOVAL_REASON",
   "Removal Reason"))
 DECLARE m_s_off_study_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"OFF_STUDY_DATE",
   "Off Study Date"))
 DECLARE m_s_off_study_reason = vc WITH constant(uar_i18ngetmessage(i18nhandle,"OFF_STUDY_REASON",
   "Off Study Reason"))
 DECLARE m_s_stratum = vc WITH constant(uar_i18ngetmessage(i18nhandle,"STRATUM","Stratum"))
 DECLARE m_s_cohort = vc WITH constant(uar_i18ngetmessage(i18nhandle,"COHORT","Cohort"))
 DECLARE m_s_end_report = vc WITH constant(uar_i18ngetmessage(i18nhandle,"END_REPORT",
   "*** End of Report ***"))
 DECLARE m_s_total = vc WITH constant(uar_i18ngetmessage(i18nhandle,"TOTAL","Total = "))
 DECLARE m_s_consent_type = vc WITH constant(uar_i18ngetmessage(i18nhandle,"CONSENT_TYPE",
   "Consent Type"))
 DECLARE m_s_consent_released = vc WITH constant(uar_i18ngetmessage(i18nhandle,"CONSENT_RELEASED",
   "Consent Released"))
 DECLARE m_s_init_prot = vc WITH constant(uar_i18ngetmessage(i18nhandle,"INIT_PROT",
   "Initial Protocol"))
 DECLARE m_s_not_returned = vc WITH constant(uar_i18ngetmessage(i18nhandle,"NOT_RETURNED",
   "Not Returned"))
 DECLARE m_s_reason_not_ret = vc WITH constant(uar_i18ngetmessage(i18nhandle,"REASON_NOT_RET",
   "Reason Not Returned"))
 DECLARE m_s_consent_signed = vc WITH constant(uar_i18ngetmessage(i18nhandle,"CONSENT_SIGNED",
   "Consent Signed"))
 DECLARE m_s_consent_returned = vc WITH constant(uar_i18ngetmessage(i18nhandle,"CONSENT_RETURNED",
   "Consent Returned"))
 DECLARE m_s_dash = vc WITH constant(uar_i18ngetmessage(i18nhandle,"DASH","-"))
 DECLARE m_s_semi = vc WITH constant(uar_i18ngetmessage(i18nhandle,"SEMI",";"))
 IF ((request->formattype=delimited_report))
  SET exec_timestamp = concat(m_s_time_stamp," ",format(curdate,"@SHORTDATE"))
 ELSE
  SET exec_timestamp = concat("Report execution time:"," ",format(curdate,"@SHORTDATE"))
 ENDIF
 SET exec_timestamp = concat(exec_timestamp," ",format(curtime2,"@TIMEWITHSECONDS"))
 IF ((((request->reporttypeflag=1)) OR ((request->reporttypeflag=2))) )
  IF ((request->formattype=delimited_report))
   IF ((request->ptqualifier=1))
    IF ((request->registry_only_ind=1))
     SET rpt_heading = m_s_still_registered
    ELSE
     SET rpt_heading = m_s_still_on_study
    ENDIF
   ELSE
    IF ((request->registry_only_ind=1))
     SET rpt_heading = m_s_all_registered
    ELSE
     SET rpt_heading = m_s_all_enrolled
    ENDIF
   ENDIF
  ELSE
   IF ((request->ptqualifier=1))
    IF ((request->registry_only_ind=1))
     SET rpt_heading = "Still Registered Patients"
    ELSE
     SET rpt_heading = "On Study Patients"
    ENDIF
   ELSE
    IF ((request->registry_only_ind=1))
     SET rpt_heading = "All Patients Registered"
    ELSE
     SET rpt_heading = "All Enrolled Patients"
    ENDIF
   ENDIF
  ENDIF
  SET tmp_prot = 0.0
  SET multi_prot_ind = 0
  SET tmp_prot_mnem = ""
  FOR (num = 1 TO size(request->enrolls,5))
    IF (num=1)
     SET tmp_prot = request->enrolls[num].prot_master_id
     SET tmp_prot_mnem = request->enrolls[num].prot_mnemonic
    ELSEIF ((request->enrolls[num].prot_master_id != tmp_prot))
     SET num = size(request->enrolls,5)
     SET multi_prot_ind = 1
    ENDIF
  ENDFOR
  SET therapeutic_ind = 0
  SELECT INTO "nl:"
   FROM prot_master pm,
    (dummyt d  WITH seq = value(size(request->enrolls,5)))
   PLAN (d)
    JOIN (pm
    WHERE (pm.prot_master_id=request->enrolls[d.seq].prot_master_id))
   DETAIL
    IF (pm.prot_type_cd=therapeutic_cd
     AND therapeutic_ind=0)
     therapeutic_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  IF ((((request->protocolid > 0.0)) OR (multi_prot_ind=0)) )
   IF ((request->protocolid > 0.0))
    SELECT INTO "nl:"
     FROM prot_master p
     WHERE (p.prot_master_id=request->protocolid)
     DETAIL
      tmp_prot_mnem = p.primary_mnemonic
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->formattype=delimited_report))
    SET rpt_heading = concat(rpt_heading," ",m_s_for," ",tmp_prot_mnem)
   ELSE
    SET rpt_heading = concat(rpt_heading," for ",tmp_prot_mnem)
   ENDIF
  ENDIF
  SET prot_cnt = 0
  SET mrn_size = 0
  IF ((request->formattype=delimited_report))
   SELECT INTO value(hold_file)
    prot = substring(1,200,request->enrolls[d.seq].prot_mnemonic), lastnm = substring(1,100,request->
     enrolls[d.seq].lastname), lastnmsort = cnvtlower(substring(1,100,request->enrolls[d.seq].
      lastname)),
    personid = request->enrolls[d.seq].personid
    FROM (dummyt d  WITH seq = value(size(request->enrolls,5)))
    ORDER BY prot, lastnmsort
    HEAD REPORT
     total_pt_cnt = 0, row + 1, col 0,
     rpt_heading, row + 1, col 0,
     exec_timestamp, row + 1
     IF (therapeutic_ind=1)
      IF ((request->registry_only_ind=1))
       tmp_str_labels = concat(m_s_last_name,",",m_s_first_name,",",m_s_mrn,
        ",",m_s_participant_id,",",m_s_primary_mnemonic,",",
        m_s_amendment,",",m_s_revision,",",m_s_registered_date,
        ",",m_s_off_tx_date,",",m_s_off_tx_reason,",",
        m_s_removal_date,",",m_s_removal_reason,",",m_s_stratum,
        ",",m_s_cohort)
      ELSE
       tmp_str_labels = concat(m_s_last_name,",",m_s_first_name,",",m_s_mrn,
        ",",m_s_enrollment_id,",",m_s_primary_mnemonic,",",
        m_s_amendment,",",m_s_revision,",",m_s_on_study_date,
        ",",m_s_off_tx_date,",",m_s_off_tx_reason,",",
        m_s_off_study_date,",",m_s_off_study_reason,",",m_s_stratum,
        ",",m_s_cohort)
      ENDIF
     ELSE
      IF ((request->registry_only_ind=1))
       tmp_str_labels = concat(m_s_last_name,",",m_s_first_name,",",m_s_mrn,
        ",",m_s_participant_id,",",m_s_primary_mnemonic,",",
        m_s_amendment,",",m_s_revision,",",m_s_registered_date,
        ",",m_s_removal_date,",",m_s_removal_reason,",",
        m_s_stratum,",",m_s_cohort)
      ELSE
       tmp_str_labels = concat(m_s_last_name,",",m_s_first_name,",",m_s_mrn,
        ",",m_s_enrollment_id,",",m_s_primary_mnemonic,",",
        m_s_amendment,",",m_s_revision,",",m_s_on_study_date,
        ",",m_s_off_study_date,",",m_s_off_study_reason,",",
        m_s_stratum,",",m_s_cohort)
      ENDIF
     ENDIF
     col 0, tmp_str_labels, row + 1
    DETAIL
     total_pt_cnt = (total_pt_cnt+ 1), tmp_ln = request->enrolls[d.seq].lastname, tmp_fn = request->
     enrolls[d.seq].firstname,
     tmp_prot_accession_nbr = request->enrolls[d.seq].protaccessionnbr, tmp_protocol = request->
     enrolls[d.seq].prot_mnemonic
     IF ((request->enrolls[d.seq].cur_amendmentnbr > 0))
      tmp_amendment = concat(m_s_amendment," ",trim(cnvtstring(request->enrolls[d.seq].
         cur_amendmentnbr)))
     ELSE
      tmp_amendment = m_s_init_prot
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].cur_revisionnbrtxt IN ("", " ", null))))
      tmp_rev = trim(request->enrolls[d.seq].cur_revisionnbrtxt)
     ENDIF
     IF ((request->enrolls[d.seq].dateoffstudy > 0)
      AND (request->enrolls[d.seq].dateoffstudy < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_off = format(request->enrolls[d.seq].dateoffstudy,"@SHORTDATE")
     ELSE
      tmp_dt_off = ""
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].removalreason_disp IN ("", " ", null))))
      tmp_off_study_reason = request->enrolls[d.seq].removalreason_disp
     ELSE
      tmp_off_study_reason = ""
     ENDIF
     IF ((request->enrolls[d.seq].dateofftherapy > 0)
      AND (request->enrolls[d.seq].dateofftherapy < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_off_tx = format(request->enrolls[d.seq].dateofftherapy,"@SHORTDATE")
     ELSE
      tmp_dt_off_tx = ""
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].txremovalreason_disp IN ("", " ", null))))
      tmp_off_tx_reason = request->enrolls[d.seq].txremovalreason_disp
     ELSE
      tmp_off_tx_reason = ""
     ENDIF
     IF ((request->enrolls[d.seq].dateonstudy > 0)
      AND (request->enrolls[d.seq].dateonstudy < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_on = format(request->enrolls[d.seq].dateonstudy,"@SHORTDATE")
     ELSE
      tmp_dt_on = ""
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].stratumlabel IN ("", " ", null))))
      tmp_stratum = request->enrolls[d.seq].stratumlabel
     ELSE
      tmp_stratum = ""
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].cohort_label IN ("", " ", null))))
      tmp_cohort = request->enrolls[d.seq].cohort_label
     ELSE
      tmp_cohort = ""
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].followup_status IN ("", " ", null))))
      tmp_followup = request->enrolls[d.seq].followup_status
     ELSE
      tmp_followup = ""
     ENDIF
     mrn_size = size(request->enrolls[d.seq].mrns,5), tmp_mrn_pool = ""
     FOR (z = 1 TO mrn_size)
       tmp_apool = trim(request->enrolls[d.seq].mrns[z].alias_pool_disp), tmp_mrn = trim(request->
        enrolls[d.seq].mrns[z].mrn)
       IF (z=1)
        IF (size(trim(tmp_apool),1) > 0)
         tmp_mrn_pool = concat(tmp_apool," ",m_s_dash," ",tmp_mrn)
        ELSE
         tmp_mrn_pool = tmp_mrn
        ENDIF
       ELSE
        IF (size(trim(tmp_apool),1) > 0)
         tmp_mrn_pool = concat(tmp_mrn_pool,m_s_semi," ",tmp_apool," ",
          m_s_dash," ",tmp_mrn)
        ELSE
         tmp_mrn_pool = concat(tmp_mrn_pool,m_s_semi," ",tmp_mrn)
        ENDIF
       ENDIF
     ENDFOR
     IF (therapeutic_ind=1)
      tempstr = concat(concat('"',trim(tmp_ln),'"'),delimiter,concat('"',trim(tmp_fn),'"'),delimiter,
       concat('"',trim(tmp_mrn_pool),'"'),
       delimiter,concat('"',trim(tmp_prot_accession_nbr),'"'),delimiter,concat('"',trim(tmp_protocol),
        '"'),delimiter,
       concat('"',trim(tmp_amendment),'"'),delimiter,concat('"',trim(tmp_rev),'"'),delimiter,concat(
        '"',trim(tmp_dt_on),'"'),
       delimiter,concat('"',trim(tmp_dt_off_tx),'"'),delimiter,concat('"',trim(tmp_off_tx_reason),'"'
        ),delimiter,
       concat('"',trim(tmp_dt_off),'"'),delimiter,concat('"',trim(tmp_off_study_reason),'"'),
       delimiter,concat('"',trim(tmp_stratum),'"'),
       delimiter,concat('"',trim(tmp_cohort),'"'))
     ELSE
      tempstr = concat(concat('"',trim(tmp_ln),'"'),delimiter,concat('"',trim(tmp_fn),'"'),delimiter,
       concat('"',trim(tmp_mrn_pool),'"'),
       delimiter,concat('"',trim(tmp_prot_accession_nbr),'"'),delimiter,concat('"',trim(tmp_protocol),
        '"'),delimiter,
       concat('"',trim(tmp_amendment),'"'),delimiter,concat('"',trim(tmp_rev),'"'),delimiter,concat(
        '"',trim(tmp_dt_on),'"'),
       delimiter,concat('"',trim(tmp_dt_off),'"'),delimiter,concat('"',trim(tmp_off_study_reason),'"'
        ),delimiter,
       concat('"',trim(tmp_stratum),'"'),delimiter,concat('"',trim(tmp_cohort),'"'))
     ENDIF
     row + 1, col 0, tempstr
    FOOT REPORT
     IF (total_pt_cnt > 1)
      row + 2, tmp_str3 = concat(m_s_total," ",trim(cnvtstring(total_pt_cnt))), col 0,
      tmp_str3, row + 2, tempstr = m_s_end_report,
      col 0, tempstr
     ENDIF
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ELSE
   SET rpt_heading = concat("{CENTER/",rpt_heading,"/11/0}")
   IF (therapeutic_ind=1)
    IF ((request->registry_only_ind=1))
     SET colheadertop = concat(fillstring(91," "),"Registered","  ","Off Treatment","  ",
      "Off Treatment","            ","Removal  ","  ","Removal")
     SET colheaderbottom = concat("{U} Last Name","    ","First Name","   ","MRN",
      fillstring(32," "),"Participant ID","     ","Amd","  ",
      "Rev","  ","Date","        ","Date",
      "           ","Reason",fillstring(19," "),"Date","       ",
      "Reason",fillstring(20," "),"Stratum","     ","Cohort",
      "   {ENDU}")
    ELSE
     SET colheadertop = concat(fillstring(91," "),"On Study","    ","Off Treatment","  ",
      "Off Treatment","            ","Off Study","  ","Off Study")
     SET colheaderbottom = concat("{U} Last Name","    ","First Name","   ","MRN",
      fillstring(32," "),"Enrollment ID ","     ","Amd","  ",
      "Rev","  ","Date","        ","Date",
      "           ","Reason",fillstring(19," "),"Date","       ",
      "Reason",fillstring(20," "),"Stratum","     ","Cohort",
      "   {ENDU}")
    ENDIF
   ELSE
    IF ((request->registry_only_ind=1))
     SET colheadertop = concat(fillstring(103," "),"Registered","  ","Removal","    ",
      "Removal")
     SET colheaderbottom = concat("{U} Last Name","    ","First Name","   ","MRN",
      fillstring(32," "),"Participant ID","     ","Amendment","  ",
      "Revision","   ","Date","        ","Date",
      "       ","Reason",fillstring(21," "),"Stratum","     ",
      "Cohort",fillstring(30," "),"{ENDU}")
    ELSE
     SET colheadertop = concat(fillstring(103," "),"On Study","    ","Off Study","  ",
      "Off Study")
     SET colheaderbottom = concat("{U} Last Name","    ","First Name","   ","MRN",
      fillstring(32," "),"Enrollment ID ","     ","Amendment","  ",
      "Revision","   ","Date","        ","Date",
      "       ","Reason",fillstring(21," "),"Stratum","     ",
      "Cohort",fillstring(30," "),"{ENDU}")
    ENDIF
   ENDIF
   SELECT INTO value(hold_file)
    prot = substring(1,200,request->enrolls[d.seq].prot_mnemonic), lastnm = substring(1,100,request->
     enrolls[d.seq].lastname), lastnmsort = cnvtlower(substring(1,100,request->enrolls[d.seq].
      lastname)),
    personid = request->enrolls[d.seq].personid
    FROM (dummyt d  WITH seq = value(size(request->enrolls,5)))
    ORDER BY prot, lastnmsort
    HEAD REPORT
     total_prot_cnt = 0, number_of_prots = 0, estimated_prot = 0
    HEAD PAGE
     "{PS/792 0 translate 90 rotate/}", row + 1, col 1,
     "{B}{CPI/15}", rpt_heading, row + 2,
     col 0, "{B}{CPI/19}", colheadertop,
     row + 1, col 0, "{B}",
     colheaderbottom, row + 1
    HEAD prot
     estimated_row = 0
     FOR (protindex = 1 TO value(size(request->enrolls,5)))
      estimated_row = (estimated_row+ 1),
      IF ((request->enrolls[protindex].prot_mnemonic=request->enrolls[d.seq].prot_mnemonic))
       IF (size(request->enrolls[protindex].mrns,5) > 1)
        estimated_row = ((estimated_row+ size(request->enrolls[protindex].mrns,5)) - 1)
       ENDIF
      ENDIF
     ENDFOR
     estimated_row = (estimated_row+ 5), cntr = 0
     IF (estimated_row < 54)
      IF (((estimated_row+ row) >= 55))
       BREAK
      ENDIF
     ENDIF
     prot_cnt = 0
     IF (multi_prot_ind=1)
      row + 1, str6 = substring(1,15,request->enrolls[d.seq].prot_mnemonic), col 4,
      "{B}{CPI/19}", str6, row + 2
     ENDIF
     number_of_prots = (number_of_prots+ 1)
    HEAD personid
     prot_cnt = (prot_cnt+ 1)
    DETAIL
     tmp_ln = substring(1,12,request->enrolls[d.seq].lastname), tmp_fn = substring(1,12,request->
      enrolls[d.seq].firstname)
     IF (size(request->enrolls[d.seq].protaccessionnbr,1) > 10)
      tmp_prot_accession_nbr = substring(1,15,trim(request->enrolls[d.seq].protaccessionnbr))
     ELSE
      tmp_prot_accession_nbr = request->enrolls[d.seq].protaccessionnbr
     ENDIF
     IF ((request->enrolls[d.seq].cur_amendmentnbr > 0))
      IF (therapeutic_ind=1)
       tmp_amendment = trim(cnvtstring(request->enrolls[d.seq].cur_amendmentnbr))
      ELSE
       tmp_amendment = concat("Amd ",trim(cnvtstring(request->enrolls[d.seq].cur_amendmentnbr)))
      ENDIF
     ELSE
      IF (therapeutic_ind=1)
       tmp_amendment = "IP"
      ELSE
       tmp_amendment = "Init Prot"
      ENDIF
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].cur_revisionnbrtxt IN ("", " ", null))))
      tmp_rev = substring(1,9,trim(request->enrolls[d.seq].cur_revisionnbrtxt))
     ELSE
      tmp_rev = "--"
     ENDIF
     IF ((request->enrolls[d.seq].dateoffstudy > 0)
      AND (request->enrolls[d.seq].dateoffstudy < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_off = format(request->enrolls[d.seq].dateoffstudy,"@SHORTDATE")
     ELSE
      tmp_dt_off = "--"
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].removalreason_disp IN ("", " ", null))))
      tmp_off_study_reason = request->enrolls[d.seq].removalreason_disp
     ELSE
      tmp_off_study_reason = "--"
     ENDIF
     IF ((request->enrolls[d.seq].dateofftherapy > 0)
      AND (request->enrolls[d.seq].dateofftherapy < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_off_tx = format(request->enrolls[d.seq].dateofftherapy,"@SHORTDATE")
     ELSE
      tmp_dt_off_tx = "--"
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].txremovalreason_disp IN ("", " ", null))))
      tmp_off_tx_reason = request->enrolls[d.seq].txremovalreason_disp
     ELSE
      tmp_off_tx_reason = "--"
     ENDIF
     IF ((request->enrolls[d.seq].dateonstudy > 0)
      AND (request->enrolls[d.seq].dateonstudy < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_on = format(request->enrolls[d.seq].dateonstudy,"@SHORTDATE")
     ELSE
      tmp_dt_on = "--"
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].stratumlabel IN ("", " ", null))))
      tmp_stratum = substring(1,10,request->enrolls[d.seq].stratumlabel)
     ELSE
      tmp_stratum = "--"
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].cohort_label IN ("", " ", null))))
      tmp_cohort = substring(1,10,request->enrolls[d.seq].cohort_label)
     ELSE
      tmp_cohort = "--"
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].followup_status IN ("", " ", null))))
      tmp_followup = substring(1,11,request->enrolls[d.seq].followup_status)
     ELSE
      tmp_followup = "--"
     ENDIF
     mrn_size = size(request->enrolls[d.seq].mrns,5)
     FOR (z = 1 TO mrn_size)
       tmp_apool = trim(substring(1,10,request->enrolls[d.seq].mrns[z].alias_pool_disp)), tmp_mrn =
       substring(1,20,request->enrolls[d.seq].mrns[z].mrn), tmp_mrn_pool = concat(tmp_apool," - ",
        tmp_mrn)
       IF (z > 1)
        tmp_ln = "", tmp_fn = "", tmp_prot_accession_nbr = "",
        tmp_amendment = "", tmp_rev = "", tmp_dt_on = "",
        tmp_dt_off = "", tmp_off_study_reason = "", tmp_stratum = "",
        tmp_cohort = "", tmp_followup = "", tmp_dt_off_tx = "",
        tmp_off_tx_reason = ""
       ENDIF
       col 1, tmp_ln, col 14,
       tmp_fn, col 27, tmp_mrn_pool,
       col 62, tmp_prot_accession_nbr, col 81,
       tmp_amendment
       IF (therapeutic_ind=1)
        col 86, tmp_rev, col 91,
        tmp_dt_on, col 103, tmp_dt_off_tx,
        col 118, tmp_off_tx_reason, col 143,
        tmp_dt_off, col 154, tmp_off_study_reason,
        col 180, tmp_stratum, col 192,
        tmp_cohort
       ELSE
        col 92, tmp_rev, col 103,
        tmp_dt_on, col 115, tmp_dt_off,
        col 126, tmp_off_study_reason, col 153,
        tmp_stratum, col 165, tmp_cohort
       ENDIF
       row + 1
     ENDFOR
     IF (mrn_size=0)
      tmp_mrn_pool = "", col 1, tmp_ln,
      col 14, tmp_fn, col 27,
      tmp_mrn_pool, col 62, tmp_prot_accession_nbr,
      col 81, tmp_amendment
      IF (therapeutic_ind=1)
       col 86, tmp_rev, col 91,
       tmp_dt_on, col 103, tmp_dt_off_tx,
       col 118, tmp_off_tx_reason, col 143,
       tmp_dt_off, col 154, tmp_off_study_reason,
       col 180, tmp_stratum, col 192,
       tmp_cohort
      ELSE
       col 92, tmp_rev, col 103,
       tmp_dt_on, col 115, tmp_dt_off,
       col 126, tmp_off_study_reason, col 153,
       tmp_stratum, col 165, tmp_cohort
      ENDIF
      row + 1
     ENDIF
     IF (row > 53)
      BREAK
     ENDIF
    FOOT  prot
     total_prot_cnt = (total_prot_cnt+ prot_cnt), tempstr = concat("{U}",fillstring(201," "),"{ENDU}"
      ), col 0,
     tempstr, row + 2, tmp_str2 = concat("Total for ",request->enrolls[d.seq].prot_mnemonic," = ",
      trim(cnvtstring(prot_cnt))),
     col 4, "{B}", tmp_str2,
     row + 2
    FOOT PAGE
     str9 = concat("Page "," ",cnvtstring(curpage)), str8 = concat("{CENTER/",str9,"/11/0}"),
     temp_row = row,
     row 56, col 1, str8
    FOOT REPORT
     IF (number_of_prots > 1)
      row temp_row, row + 2, tmp_str3 = concat("Total for All PROTOCOLS = ",trim(cnvtstring(
         total_prot_cnt))),
      col 0, "{B}", tmp_str3,
      str9 = concat("Page "," ",cnvtstring(curpage)), str8 = concat("{CENTER/",str9,"/11/0}"), row 56,
      col 1, str8
     ENDIF
    WITH dio = postscript, maxcol = 300
   ;end select
  ENDIF
 ELSEIF ((request->reporttypeflag=3))
  SET index = 1
  IF ((request->formattype=delimited_report))
   SET rpt_heading = m_s_consent_pending
  ELSE
   SET rpt_heading = "Protocols with Consents Pending Signature"
  ENDIF
  SET tmp_prot = 0.0
  SET multi_prot_ind = 0
  SET tmp_prot_mnem = ""
  FOR (num = 1 TO size(request->consents,5))
    IF (num=1)
     SET tmp_prot = request->consents[num].protocolid
     SET tmp_prot_mnem = request->consents[num].protalias
    ELSEIF ((request->consents[num].protocolid != tmp_prot))
     SET num = size(request->consents,5)
     SET multi_prot_ind = 1
    ENDIF
  ENDFOR
  IF (((size(request->protocols,5)=1
   AND value(size(request->consents,5)) > 0) OR (multi_prot_ind=0)) )
   IF (multi_prot_ind=0)
    SELECT INTO "nl:"
     FROM prot_master p
     WHERE (p.prot_master_id=request->consents[1].protocolid)
     DETAIL
      tmp_prot_mnem = p.primary_mnemonic
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->formattype=delimited_report))
    SET rpt_heading = concat(rpt_heading," ",m_s_for," ",tmp_prot_mnem)
   ELSE
    SET rpt_heading = concat(substring(16,27,rpt_heading)," for ",tmp_prot_mnem)
   ENDIF
  ENDIF
  SET prot_cnt = 0
  SET mrn_size = 0
  IF ((request->formattype=delimited_report))
   SELECT INTO value(hold_file)
    prot = substring(1,200,request->consents[d.seq].protalias), lastnm = substring(1,100,request->
     consents[d.seq].lastname), lastnmsort = cnvtlower(substring(1,100,request->consents[d.seq].
      lastname)),
    personid = request->consents[d.seq].personid
    FROM (dummyt d  WITH seq = value(size(request->consents,5)))
    ORDER BY prot, lastnmsort
    HEAD REPORT
     total_pt_cnt = 0, row + 1, col 0,
     rpt_heading, row + 1, col 0,
     exec_timestamp, row + 1, tmp_str_labels = concat(m_s_last_name,",",m_s_first_name,",",m_s_mrn,
      ",",m_s_primary_mnemonic,",",m_s_amendment,",",
      m_s_revision,",",m_s_consent_type,",",m_s_consent_released,
      ",",m_s_stratum,",",m_s_cohort),
     col 0, tmp_str_labels, row + 1
    DETAIL
     total_pt_cnt = (total_pt_cnt+ 1), tmp_ln = request->consents[d.seq].lastname, tmp_fn = request->
     consents[d.seq].firstname,
     tmp_protocol = request->consents[d.seq].protalias
     IF ((request->consents[d.seq].cur_amendmentnbr > 0))
      tmp_amendment = concat(m_s_amendment," ",cnvtstring(request->consents[d.seq].cur_amendmentnbr))
     ELSE
      tmp_amendment = m_s_init_prot
     ENDIF
     IF ( NOT ((request->consents[d.seq].cur_revisionnbrtxt IN ("", " ", null))))
      tmp_rev = request->consents[d.seq].cur_revisionnbrtxt
     ELSE
      tmp_rev = ""
     ENDIF
     IF ( NOT ((request->consents[d.seq].reasonforcon_disp IN ("", " ", null))))
      tmp_cons_type = request->consents[d.seq].reasonforcon_disp
     ELSE
      tmp_cons_type = ""
     ENDIF
     IF ((request->consents[d.seq].dateconissued > 0)
      AND (request->consents[d.seq].dateconissued < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_issued = format(request->consents[d.seq].dateconissued,"@SHORTDATE")
     ELSE
      tmp_dt_issued = ""
     ENDIF
     IF ( NOT ((request->consents[d.seq].stratumlabel IN ("", " ", null))))
      tmp_stratum = request->consents[d.seq].stratumlabel
     ELSE
      tmp_stratum = ""
     ENDIF
     IF ( NOT ((request->consents[d.seq].cohort_label IN ("", " ", null))))
      tmp_cohort = request->consents[d.seq].cohort_label
     ELSE
      tmp_cohort = ""
     ENDIF
     mrn_size = size(request->consents[d.seq].mrns,5)
     FOR (z = 1 TO mrn_size)
       tmp_apool = request->consents[d.seq].mrns[z].alias_pool_disp, tmp_mrn = request->consents[d
       .seq].mrns[z].mrn
       IF (z=1)
        IF (size(trim(tmp_apool),1) > 0)
         tmp_mrn_pool = concat(tmp_apool," ",m_s_dash," ",tmp_mrn)
        ELSE
         tmp_mrn_pool = tmp_mrn
        ENDIF
       ELSE
        IF (size(trim(tmp_apool),1) > 0)
         tmp_mrn_pool = concat(tmp_mrn_pool,m_s_semi," ",tmp_apool," ",
          m_s_dash," ",tmp_mrn)
        ELSE
         tmp_mrn_pool = concat(tmp_mrn_pool,m_s_semi," ",tmp_mrn)
        ENDIF
       ENDIF
     ENDFOR
     tempstr = concat(concat('"',trim(tmp_ln),'"'),delimiter,concat('"',trim(tmp_fn),'"'),delimiter,
      concat('"',trim(tmp_mrn_pool),'"'),
      delimiter,concat('"',trim(tmp_protocol),'"'),delimiter,concat('"',trim(tmp_amendment),'"'),
      delimiter,
      concat('"',trim(tmp_rev),'"'),delimiter,concat('"',trim(tmp_cons_type),'"'),delimiter,concat(
       '"',trim(tmp_dt_issued),'"'),
      delimiter,concat('"',trim(tmp_stratum),'"'),delimiter,concat('"',trim(tmp_cohort),'"')), row +
     1, col 0,
     tempstr
    FOOT REPORT
     IF (total_pt_cnt > 1)
      row + 2, tmp_str3 = concat(m_s_total," ",trim(cnvtstring(total_pt_cnt))), col 0,
      tmp_str3, row + 2, tempstr = m_s_end_report,
      col 0, tempstr
     ENDIF
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ELSE
   SELECT INTO value(hold_file)
    prot = substring(1,200,request->consents[d.seq].protalias), lastnm = substring(1,100,request->
     consents[d.seq].lastname), lastnmsort = cnvtlower(substring(1,100,request->consents[d.seq].
      lastname)),
    personid = request->consents[d.seq].personid
    FROM (dummyt d  WITH seq = value(size(request->consents,5)))
    ORDER BY prot, lastnmsort
    HEAD REPORT
     total_prot_cnt = 0, number_of_prots = 0, estimated_prot = 0,
     "{PS/792 0 translate 90 rotate/}", row + 1, rpt_heading = concat("{CENTER/",rpt_heading,"/11/0}"
      ),
     col 1, "{B}{CPI/10}", rpt_heading,
     row + 2
    HEAD PAGE
     IF (curpage > 1)
      "{PS/792 0 translate 90 rotate/}", row + 1, col 1,
      "{B}{CPI/10}", rpt_heading, row + 2
     ENDIF
     84spc = fillstring(84," "), str = concat(84spc,"Consent","      ","Consent"), col 0,
     "{B}{CPI/14}", str, row + 1,
     str2 = concat("    Last Name","    ","First Name","   ","MRN",
      "                               ","Amendment"," ","Revision","  ",
      "Type","         ","Released","    ","Stratum",
      "    ","Cohort","                       _"), col 0, "{B}{U}{CPI/14}",
     str2, row + 1
    HEAD prot
     estimated_row = 0
     FOR (protindex = 1 TO value(size(request->consents,5)))
      estimated_row = (estimated_row+ 1),
      IF ((request->consents[protindex].protalias=request->consents[d.seq].protalias))
       IF (size(request->consents[protindex].mrns,5) > 1)
        estimated_row = ((estimated_row+ size(request->consents[protindex].mrns,5)) - 1)
       ENDIF
      ENDIF
     ENDFOR
     estimated_row = (estimated_row+ 5), cntr = 0
     IF (estimated_row < 54)
      IF (((estimated_row+ row) >= 55))
       BREAK,
       CALL echo("Test")
      ENDIF
     ENDIF
     prot_cnt = 0
     IF (((size(request->protocols,5) > 1) OR (multi_prot_ind=1)) )
      row + 2, str3 = substring(1,15,request->consents[d.seq].protalias), col 4,
      "{B}{CPI/14}", str3, row + 2
     ENDIF
     number_of_prots = (number_of_prots+ 1)
    HEAD personid
     filler = 1
    DETAIL
     prot_cnt = (prot_cnt+ 1), tmp_ln = substring(1,12,request->consents[d.seq].lastname), tmp_fn =
     substring(1,12,request->consents[d.seq].firstname)
     IF ((request->consents[d.seq].cur_amendmentnbr > 0))
      tmp_amendment = concat("Amd ",cnvtstring(request->consents[d.seq].cur_amendmentnbr))
     ELSE
      tmp_amendment = "Init Prot"
     ENDIF
     IF ( NOT ((request->consents[d.seq].cur_revisionnbrtxt IN ("", " ", null))))
      tmp_rev = substring(1,9,trim(request->consents[d.seq].cur_revisionnbrtxt))
     ELSE
      tmp_rev = "--"
     ENDIF
     IF ( NOT ((request->consents[d.seq].reasonforcon_disp IN ("", " ", null))))
      tmp_cons_type = substring(1,12,request->consents[d.seq].reasonforcon_disp)
     ELSE
      tmp_cons_type = "--"
     ENDIF
     IF ((request->consents[d.seq].dateconissued > 0)
      AND (request->consents[d.seq].dateconissued < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_issued = format(request->consents[d.seq].dateconissued,"@SHORTDATE")
     ELSE
      tmp_dt_issued = "   --"
     ENDIF
     IF ( NOT ((request->consents[d.seq].stratumlabel IN ("", " ", null))))
      tmp_stratum = substring(1,10,request->consents[d.seq].stratumlabel)
     ELSE
      tmp_stratum = "--"
     ENDIF
     IF ( NOT ((request->consents[d.seq].cohort_label IN ("", " ", null))))
      tmp_cohort = substring(1,10,request->consents[d.seq].cohort_label)
     ELSE
      tmp_cohort = "--"
     ENDIF
     mrn_size = size(request->consents[d.seq].mrns,5)
     FOR (z = 1 TO mrn_size)
       tmp_apool = substring(1,10,request->consents[d.seq].mrns[z].alias_pool_disp), tmp_mrn =
       substring(1,20,request->consents[d.seq].mrns[z].mrn), tmp_mrn_pool = concat(tmp_apool," - ",
        tmp_mrn)
       IF (z > 1)
        tmp_ln = " ", tmp_fn = " ", tmp_prot_accession_nbr = "",
        tmp_amendment = "", tmp_rev = "", tmp_cons_type = "",
        tmp_dt_issued = "", tmp_stratum = "", tmp_cohort = ""
       ENDIF
       col 4, tmp_ln, col 17,
       tmp_fn, col 30, tmp_mrn_pool,
       col 64, tmp_amendment, col 74,
       tmp_rev, col 84, tmp_cons_type,
       col 97, tmp_dt_issued, col 109,
       tmp_stratum, col 120, tmp_cohort,
       row + 1
     ENDFOR
     IF (mrn_size=0)
      tmp_mrn_pool = "", col 4, tmp_ln,
      col 17, tmp_fn, col 30,
      tmp_mrn_pool, col 64, tmp_amendment,
      col 74, tmp_rev, col 84,
      tmp_cons_type, col 97, tmp_dt_issued,
      col 109, tmp_stratum, col 120,
      tmp_cohort, row + 1
     ENDIF
     IF (row > 53)
      BREAK
     ENDIF
    FOOT  prot
     total_prot_cnt = (total_prot_cnt+ prot_cnt), col 0, ln,
     row + 2
     IF (value(size(request->consents,5)) > 0)
      tmp_str2 = concat("Total for ",request->consents[d.seq].protalias," = ",trim(cnvtstring(
         prot_cnt))), col 4, "{B}",
      tmp_str2, row + 2
     ENDIF
    FOOT PAGE
     str9 = concat("Page "," ",cnvtstring(curpage)), str8 = concat("{CENTER/",str9,"/11/0}"),
     temp_row = row,
     row 56, col 1, str8
    FOOT REPORT
     IF (number_of_prots > 1)
      row temp_row, row + 2, tmp_str3 = concat("Total for All PROTOCOLS = ",trim(cnvtstring(
         total_prot_cnt))),
      col 0, "{B}", tmp_str3,
      str9 = concat("Page "," ",cnvtstring(curpage)), str8 = concat("{CENTER/",str9,"/11/0}"), row 56,
      col 1, str8
     ENDIF
    WITH dio = postscript, maxcol = 300
   ;end select
  ENDIF
 ELSEIF ((request->reporttypeflag=4))
  SET index = 1
  IF ((request->formattype=delimited_report))
   SET rpt_heading = m_s_to_be_verified
  ELSE
   SET rpt_heading = "Patients To Be Verified"
  ENDIF
  SET tmp_prot = 0.0
  SET multi_prot_ind = 0
  SET tmp_prot_mnem = ""
  FOR (num = 1 TO size(request->enrolls,5))
    IF (num=1)
     SET tmp_prot = request->enrolls[num].protocolid
     SET tmp_prot_mnem = request->enrolls[num].protalias
    ELSEIF ((request->enrolls[num].protocolid != tmp_prot))
     SET num = size(request->enrolls,5)
     SET multi_prot_ind = 1
    ENDIF
  ENDFOR
  IF (((size(request->protocols,5)=1
   AND value(size(request->enrolls,5)) > 0) OR (multi_prot_ind=0)) )
   IF (multi_prot_ind=1)
    SELECT INTO "nl:"
     FROM prot_master p
     WHERE (p.prot_master_id=request->enrolls[1].protocolid)
     DETAIL
      tmp_prot_mnem = p.primary_mnemonic
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->formattype=delimited_report))
    SET rpt_heading = concat(rpt_heading," ",m_s_for," ",tmp_prot_mnem)
   ELSE
    SET rpt_heading = concat(rpt_heading," for ",tmp_prot_mnem)
   ENDIF
  ENDIF
  SET prot_cnt = 0
  SET mrn_size = 0
  IF ((request->formattype=delimited_report))
   SELECT INTO value(hold_file)
    prot = substring(1,200,request->enrolls[d.seq].protalias), lastnm = substring(1,100,request->
     enrolls[d.seq].lastname), lastnmsort = cnvtlower(substring(1,100,request->enrolls[d.seq].
      lastname)),
    personid = request->enrolls[d.seq].personid
    FROM (dummyt d  WITH seq = value(size(request->enrolls,5)))
    ORDER BY prot, lastnmsort
    HEAD REPORT
     total_pt_cnt = 0, row + 1, col 0,
     rpt_heading, row + 1, col 0,
     exec_timestamp, row + 1
     IF ((request->registry_only_ind=1))
      tmp_str_labels = concat(m_s_last_name,",",m_s_first_name,",",m_s_mrn,
       ",",m_s_participant_id,",",m_s_primary_mnemonic,",",
       m_s_amendment,",",m_s_revision,",",m_s_registered_date,
       ",",m_s_stratum,",",m_s_cohort)
     ELSE
      tmp_str_labels = concat(m_s_last_name,",",m_s_first_name,",",m_s_mrn,
       ",",m_s_enrollment_id,",",m_s_primary_mnemonic,",",
       m_s_amendment,",",m_s_revision,",",m_s_on_study_date,
       ",",m_s_stratum,",",m_s_cohort)
     ENDIF
     col 0, tmp_str_labels, row + 1
    DETAIL
     total_pt_cnt = (total_pt_cnt+ 1), tmp_ln = request->enrolls[d.seq].lastname, tmp_fn = request->
     enrolls[d.seq].firstname,
     tmp_prot_accession_nbr = request->enrolls[d.seq].protaccessionnbr, tmp_protocol = request->
     enrolls[d.seq].protalias
     IF ((request->enrolls[d.seq].cur_amendmentnbr > 0))
      tmp_amendment = concat(m_s_amendment," ",trim(cnvtstring(request->enrolls[d.seq].
         cur_amendmentnbr)))
     ELSE
      tmp_amendment = m_s_init_prot
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].cur_revisionnbrtxt IN ("", " ", null))))
      tmp_rev = trim(request->enrolls[d.seq].cur_revisionnbrtxt)
     ELSE
      tmp_rev = ""
     ENDIF
     IF ((request->enrolls[d.seq].dateonstudy > 0)
      AND (request->enrolls[d.seq].dateonstudy < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_on = format(request->enrolls[d.seq].dateonstudy,"@SHORTDATE")
     ELSE
      tmp_dt_on = ""
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].stratumlabel IN ("", " ", null))))
      tmp_stratum = request->enrolls[d.seq].stratumlabel
     ELSE
      tmp_stratum = ""
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].cohort_label IN ("", " ", null))))
      tmp_cohort = request->enrolls[d.seq].cohort_label
     ELSE
      tmp_cohort = ""
     ENDIF
     mrn_size = size(request->enrolls[d.seq].mrns,5), tmp_mrn_pool = ""
     FOR (z = 1 TO mrn_size)
       tmp_apool = trim(request->enrolls[d.seq].mrns[z].alias_pool_disp), tmp_mrn = trim(request->
        enrolls[d.seq].mrns[z].mrn)
       IF (z=1)
        IF (size(trim(tmp_apool),1) > 0)
         tmp_mrn_pool = concat(tmp_apool," ",m_s_dash," ",tmp_mrn)
        ELSE
         tmp_mrn_pool = tmp_mrn
        ENDIF
       ELSE
        IF (size(trim(tmp_apool),1) > 0)
         tmp_mrn_pool = concat(tmp_mrn_pool,m_s_semi," ",tmp_apool," ",
          m_s_dash," ",tmp_mrn)
        ELSE
         tmp_mrn_pool = concat(tmp_mrn_pool,m_s_semi," ",tmp_mrn)
        ENDIF
       ENDIF
     ENDFOR
     tempstr = concat(concat('"',trim(tmp_ln),'"'),delimiter,concat('"',trim(tmp_fn),'"'),delimiter,
      concat('"',trim(tmp_mrn_pool),'"'),
      delimiter,concat('"',trim(tmp_prot_accession_nbr),'"'),delimiter,concat('"',trim(tmp_protocol),
       '"'),delimiter,
      concat('"',trim(tmp_amendment),'"'),delimiter,concat('"',trim(tmp_rev),'"'),delimiter,concat(
       '"',trim(tmp_dt_on),'"'),
      delimiter,concat('"',trim(tmp_stratum),'"'),delimiter,concat('"',trim(tmp_cohort),'"')), row +
     1, col 0,
     tempstr
    FOOT REPORT
     IF (total_pt_cnt > 1)
      row + 2, tmp_str3 = concat(m_s_total," ",trim(cnvtstring(total_pt_cnt))), col 0,
      tmp_str3, row + 2, tempstr = m_s_end_report,
      col 0, tempstr
     ENDIF
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ELSE
   SELECT INTO value(hold_file)
    prot = substring(1,200,request->enrolls[d.seq].protalias), lastnm = substring(1,100,request->
     enrolls[d.seq].lastname), lastnmsort = cnvtlower(substring(1,100,request->enrolls[d.seq].
      lastname)),
    personid = request->enrolls[d.seq].personid
    FROM (dummyt d  WITH seq = value(size(request->enrolls,5)))
    ORDER BY prot, lastnmsort
    HEAD REPORT
     total_prot_cnt = 0, number_of_prots = 0, estimated_prot = 0,
     "{PS/792 0 translate 90 rotate/}", row + 1, rpt_heading = concat("{CENTER/",rpt_heading,"/11/0}"
      ),
     col 1, "{B}{CPI/10}", rpt_heading,
     row + 1
    HEAD PAGE
     IF (curpage > 1)
      "{PS/792 0 translate 90 rotate/}", row + 1, col 1,
      "{B}{CPI/10}", rpt_heading, row + 1
     ENDIF
     106spc = fillstring(104," ")
     IF ((request->registry_only_ind=1))
      str = concat(106spc,"Registered")
     ELSE
      str = concat(106spc,"On Study")
     ENDIF
     col 0, "{B}{CPI/13}", str,
     row + 1
     IF ((request->registry_only_ind=1))
      str2 = concat("  Last Name","   ","First Name","    ","MRN",
       "                                ","Participant ID","    ","Amendment","    ",
       "Revision","     ","Date","    ","Stratum",
       "    ","Cohort","             _")
     ELSE
      str2 = concat("  Last Name","   ","First Name","    ","MRN",
       "                                ","Enrollment ID","    ","Amendment","    ",
       "Revision","     ","Date","    ","Stratum",
       "    ","Cohort","             _")
     ENDIF
     col 0, "{B}{U}", str2,
     row + 1
    HEAD prot
     estimated_row = 0
     FOR (protindex = 1 TO value(size(request->enrolls,5)))
      estimated_row = (estimated_row+ 1),
      IF ((request->enrolls[protindex].protalias=request->enrolls[d.seq].protalias))
       IF (size(request->enrolls[protindex].mrns,5) > 1)
        estimated_row = ((estimated_row+ size(request->enrolls[protindex].mrns,5)) - 1)
       ENDIF
      ENDIF
     ENDFOR
     estimated_row = (estimated_row+ 5), cntr = 0
     IF (estimated_row < 54)
      IF (((estimated_row+ row) >= 55))
       BREAK
      ENDIF
     ENDIF
     prot_cnt = 0
     IF (((size(request->protocols,5) > 1) OR (multi_prot_ind=1)) )
      row + 1, str3 = substring(1,15,request->enrolls[d.seq].protalias), col 4,
      "{B}{CPI/10}", str3, row + 1,
      col 4, "{CPI/13}", row + 1
     ENDIF
     number_of_prots = (number_of_prots+ 1)
    HEAD personid
     filler = 1, prot_cnt = (prot_cnt+ 1)
    DETAIL
     tmp_ln = substring(1,12,request->enrolls[d.seq].lastname), tmp_fn = substring(1,12,request->
      enrolls[d.seq].firstname)
     IF (size(request->enrolls[d.seq].protaccessionnbr,1) > 10)
      tmp_prot_accession_nbr = substring(1,15,trim(request->enrolls[d.seq].protaccessionnbr))
     ELSE
      tmp_prot_accession_nbr = request->enrolls[d.seq].protaccessionnbr
     ENDIF
     IF ((request->enrolls[d.seq].cur_amendmentnbr > 0))
      tmp_amendment = concat("Amd ",cnvtstring(request->enrolls[d.seq].cur_amendmentnbr))
     ELSE
      tmp_amendment = "Init Prot"
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].cur_revisionnbrtxt IN ("", " ", null))))
      tmp_rev = substring(1,9,trim(request->enrolls[d.seq].cur_revisionnbrtxt))
     ELSE
      tmp_rev = "--"
     ENDIF
     IF ((request->enrolls[d.seq].dateonstudy > 0)
      AND (request->enrolls[d.seq].dateonstudy < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_study = format(request->enrolls[d.seq].dateonstudy,"@SHORTDATE")
     ELSE
      tmp_dt_study = "   --"
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].stratumlabel IN ("", " ", null))))
      tmp_stratum = substring(1,10,request->enrolls[d.seq].stratumlabel)
     ELSE
      tmp_stratum = "--"
     ENDIF
     IF ( NOT ((request->enrolls[d.seq].cohort_label IN ("", " ", null))))
      tmp_cohort = substring(1,10,request->enrolls[d.seq].cohort_label)
     ELSE
      tmp_cohort = "--"
     ENDIF
     mrn_size = size(request->enrolls[d.seq].mrns,5)
     FOR (z = 1 TO mrn_size)
       tmp_mrn = substring(1,14,request->enrolls[d.seq].mrns[z].mrn), tmp_apool = substring(1,10,
        request->enrolls[d.seq].mrns[z].alias_pool_disp), tmp_mrn = substring(1,20,request->enrolls[d
        .seq].mrns[z].mrn),
       tmp_mrn_pool = concat(tmp_apool," - ",tmp_mrn)
       IF (z > 1)
        tmp_ln = " ", tmp_fn = " ", tmp_prot_accession_nbr = "",
        tmp_amendment = "", tmp_rev = "", tmp_cons_type = "",
        tmp_dt_issued = "", tmp_stratum = "", tmp_cohort = ""
       ENDIF
       col 2, tmp_ln, col 14,
       tmp_fn, col 28, tmp_mrn_pool,
       col 63, tmp_prot_accession_nbr, col 80,
       tmp_amendment, col 93, tmp_rev,
       col 104, tmp_dt_study, col 114,
       tmp_stratum, col 125, tmp_cohort,
       row + 1
     ENDFOR
     IF (mrn_size=0)
      tmp_mrn_pool = "", col 2, tmp_ln,
      col 14, tmp_fn, col 28,
      tmp_mrn_pool, col 63, tmp_prot_accession_nbr,
      col 80, tmp_amendment, col 93,
      tmp_rev, col 104, tmp_dt_study,
      col 114, tmp_stratum, col 125,
      tmp_cohort, row + 1
     ENDIF
     IF (row > 52)
      BREAK
     ENDIF
    FOOT  prot
     total_prot_cnt = (total_prot_cnt+ prot_cnt), col 0, ln,
     row + 2
     IF (value(size(request->enrolls,5)) > 0)
      tmp_str2 = concat("Total for ",request->enrolls[d.seq].protalias," = ",trim(cnvtstring(prot_cnt
         ))), col 4, "{B}",
      tmp_str2, row + 2
     ENDIF
    FOOT PAGE
     str9 = concat("Page "," ",cnvtstring(curpage)), str8 = concat("{CENTER/",str9,"/11/0}"),
     temp_row = row,
     row 56, col 1, str8
    FOOT REPORT
     IF (number_of_prots > 1)
      row temp_row, row + 2, tmp_str3 = concat("Total for All PROTOCOLS = ",trim(cnvtstring(
         total_prot_cnt))),
      col 0, "{B}", tmp_str3,
      str9 = concat("Page "," ",cnvtstring(curpage)), str8 = concat("{CENTER/",str9,"/11/0}"), row 56,
      col 1, str8
     ENDIF
    WITH dio = postscript, maxcol = 300, format = variable
   ;end select
  ENDIF
 ELSEIF ((request->reporttypeflag=5))
  SET index = 1
  IF ((request->formattype=delimited_report))
   SET rpt_heading = m_s_returned_consents
  ELSE
   SET rpt_heading = "Protocols with Returned Consent Documents"
  ENDIF
  SET tmp_prot = 0.0
  SET multi_prot_ind = 0
  SET tmp_prot_mnem = ""
  FOR (num = 1 TO size(request->consents,5))
    IF (num=1)
     SET tmp_prot = request->consents[num].protocolid
     SET tmp_prot_mnem = request->consents[num].protalias
    ELSEIF ((request->consents[num].protocolid != tmp_prot))
     SET num = size(request->consents,5)
     SET multi_prot_ind = 1
    ENDIF
  ENDFOR
  IF (((size(request->protocols,5)=1
   AND value(size(request->consents,5)) > 0) OR (multi_prot_ind=0)) )
   IF (multi_prot_ind=0)
    SELECT INTO "nl:"
     FROM prot_master p
     WHERE (p.prot_master_id=request->consents[1].protocolid)
     DETAIL
      tmp_prot_mnem = p.primary_mnemonic
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->formattype=delimited_report))
    SET rpt_heading = concat(rpt_heading," ",m_s_for," ",tmp_prot_mnem)
   ELSE
    SET rpt_heading = concat(substring(16,26,rpt_heading)," for ",tmp_prot_mnem)
   ENDIF
  ENDIF
  SET prot_cnt = 0
  SET mrn_size = 0
  IF ((request->formattype=delimited_report))
   SELECT INTO value(hold_file)
    prot = substring(1,200,request->consents[d.seq].protalias), lastnm = substring(1,100,request->
     consents[d.seq].lastname), lastnmsort = cnvtlower(substring(1,100,request->consents[d.seq].
      lastname)),
    personid = request->consents[d.seq].personid
    FROM (dummyt d  WITH seq = value(size(request->consents,5)))
    ORDER BY prot, lastnmsort
    HEAD REPORT
     total_pt_cnt = 0, row + 1, col 0,
     rpt_heading, row + 1, col 0,
     exec_timestamp, row + 1, tmp_str_labels = concat(m_s_last_name,",",m_s_first_name,",",m_s_mrn,
      ",",m_s_enrollment_id,",",m_s_primary_mnemonic,",",
      m_s_amendment,",",m_s_revision,",",m_s_consent_type,
      ",",m_s_consent_released,",",m_s_consent_signed,",",
      m_s_consent_returned),
     col 0, tmp_str_labels, row + 1
    DETAIL
     total_pt_cnt = (total_pt_cnt+ 1), tmp_ln = request->consents[d.seq].lastname, tmp_fn = request->
     consents[d.seq].firstname,
     tmp_prot_accession_nbr = request->consents[d.seq].protaccessionnbr, tmp_protocol = request->
     consents[d.seq].protalias
     IF ((request->consents[d.seq].cur_amendmentnbr > 0))
      tmp_amendment = concat(m_s_amendment," ",cnvtstring(request->consents[d.seq].cur_amendmentnbr))
     ELSE
      tmp_amendment = m_s_init_prot
     ENDIF
     IF ( NOT ((request->consents[d.seq].cur_revisionnbrtxt IN ("", " ", null))))
      tmp_rev = request->consents[d.seq].cur_revisionnbrtxt
     ELSE
      tmp_rev = ""
     ENDIF
     IF ( NOT ((request->consents[d.seq].reasonforcon_disp IN ("", " ", null))))
      tmp_cons_type = request->consents[d.seq].reasonforcon_disp
     ELSE
      tmp_cons_type = ""
     ENDIF
     IF ((request->consents[d.seq].dateconissued > 0)
      AND (request->consents[d.seq].dateconissued < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_issued = format(request->consents[d.seq].dateconissued,"@SHORTDATE")
     ELSE
      tmp_dt_issued = ""
     ENDIF
     IF ((request->consents[d.seq].dateconsigned > 0)
      AND (request->consents[d.seq].dateconsigned < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_signed = format(request->consents[d.seq].dateconsigned,"@SHORTDATE")
     ELSE
      tmp_dt_signed = ""
     ENDIF
     IF ((request->consents[d.seq].dateconreturned > 0)
      AND (request->consents[d.seq].dateconreturned < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_returned = format(request->consents[d.seq].dateconreturned,"@SHORTDATE")
     ELSE
      tmp_dt_returned = ""
     ENDIF
     mrn_size = size(request->consents[d.seq].mrns,5)
     FOR (z = 1 TO mrn_size)
       tmp_apool = request->consents[d.seq].mrns[z].alias_pool_disp, tmp_mrn = request->consents[d
       .seq].mrns[z].mrn
       IF (z=1)
        IF (size(trim(tmp_apool),1) > 0)
         tmp_mrn_pool = concat(tmp_apool," ",m_s_dash," ",tmp_mrn)
        ELSE
         tmp_mrn_pool = tmp_mrn
        ENDIF
       ELSE
        IF (size(trim(tmp_apool),1) > 0)
         tmp_mrn_pool = concat(tmp_mrn_pool,m_s_semi," ",tmp_apool," ",
          m_s_dash," ",tmp_mrn)
        ELSE
         tmp_mrn_pool = concat(tmp_mrn_pool,m_s_semi," ",tmp_mrn)
        ENDIF
       ENDIF
     ENDFOR
     tempstr = concat(concat('"',trim(tmp_ln),'"'),delimiter,concat('"',trim(tmp_fn),'"'),delimiter,
      concat('"',trim(tmp_mrn_pool),'"'),
      delimiter,concat('"',trim(tmp_prot_accession_nbr),'"'),delimiter,concat('"',trim(tmp_protocol),
       '"'),delimiter,
      concat('"',trim(tmp_amendment),'"'),delimiter,concat('"',trim(tmp_rev),'"'),delimiter,concat(
       '"',trim(tmp_cons_type),'"'),
      delimiter,concat('"',trim(tmp_dt_issued),'"'),delimiter,concat('"',trim(tmp_dt_signed),'"'),
      delimiter,
      concat('"',trim(tmp_dt_returned),'"')), row + 1, col 0,
     tempstr
    FOOT REPORT
     IF (total_pt_cnt > 1)
      row + 2, tmp_str3 = concat(m_s_total," ",trim(cnvtstring(total_pt_cnt))), col 0,
      tmp_str3, row + 2, tempstr = m_s_end_report,
      col 0, tempstr
     ENDIF
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ELSE
   SELECT INTO value(hold_file)
    prot = substring(1,200,request->consents[d.seq].protalias), lastnm = substring(1,100,request->
     consents[d.seq].lastname), lastnmsort = cnvtlower(substring(1,100,request->consents[d.seq].
      lastname)),
    personid = request->consents[d.seq].personid
    FROM (dummyt d  WITH seq = value(size(request->consents,5)))
    ORDER BY prot, lastnmsort
    HEAD REPORT
     total_prot_cnt = 0, number_of_prots = 0, estimated_prot = 0,
     "{PS/792 0 translate 90 rotate/}", row + 1, rpt_heading = concat("{CENTER/",rpt_heading,"/11/0}"
      ),
     col 1, "{B}{CPI/10}", rpt_heading,
     row + 2
    HEAD PAGE
     IF (curpage > 1)
      "{PS/792 0 translate 90 rotate/}", row + 1, col 1,
      "{B}{CPI/10}", rpt_heading, row + 2
     ENDIF
     99spc = fillstring(99," "), str = concat(99spc,"Consent","          ","Consent","   ",
      "Consent","   ","Consent"), col 0,
     "{B}{CPI/14}", str, row + 1,
     str2 = concat("    Last Name","   ","First Name","   ","MRN",
      "                             ","Enrollment ID","    ","Amendment","  ",
      "Revision","  ","Type","             ","Released",
      "  ","Signed","    ","Returned               _"), col 0, "{B}{U}",
     str2, row + 1
    HEAD prot
     estimated_row = 0
     FOR (protindex = 1 TO value(size(request->consents,5)))
      estimated_row = (estimated_row+ 1),
      IF ((request->consents[protindex].protalias=request->consents[d.seq].protalias))
       IF (size(request->consents[protindex].mrns,5) > 1)
        estimated_row = ((estimated_row+ size(request->consents[protindex].mrns,5)) - 1)
       ENDIF
      ENDIF
     ENDFOR
     estimated_row = (estimated_row+ 5), cntr = 0
     IF (estimated_row < 54)
      IF (((estimated_row+ row) >= 55))
       BREAK
      ENDIF
     ENDIF
     prot_cnt = 0
     IF (((size(request->protocols,5) > 1) OR (multi_prot_ind=1)) )
      row + 2, str3 = substring(1,15,request->consents[d.seq].protalias), col 4,
      "{B}{CPI/10}", str3, row + 1,
      col 4, "{CPI/14}", row + 1
     ENDIF
     number_of_prots = (number_of_prots+ 1)
    HEAD personid
     filler = 1
    DETAIL
     tmp_ln = substring(1,12,request->consents[d.seq].lastname), tmp_fn = substring(1,12,request->
      consents[d.seq].firstname)
     IF ( NOT ((request->consents[d.seq].protaccessionnbr IN ("", " ", null))))
      tmp_prot_accession_nbr = substring(1,15,trim(request->consents[d.seq].protaccessionnbr))
     ELSE
      tmp_prot_accession_nbr = "--"
     ENDIF
     IF ((request->consents[d.seq].cur_amendmentnbr > 0))
      tmp_amendment = concat("Amd ",cnvtstring(request->consents[d.seq].cur_amendmentnbr))
     ELSE
      tmp_amendment = "Init Prot"
     ENDIF
     IF ( NOT ((request->consents[d.seq].cur_revisionnbrtxt IN ("", " ", null))))
      tmp_rev = substring(1,9,trim(request->consents[d.seq].cur_revisionnbrtxt))
     ELSE
      tmp_rev = "--"
     ENDIF
     IF ( NOT ((request->consents[d.seq].reasonforcon_disp IN ("", " ", null))))
      tmp_cons_type = substring(1,15,request->consents[d.seq].reasonforcon_disp)
     ELSE
      tmp_cons_type = "--"
     ENDIF
     IF ( NOT ((request->consents[d.seq].reasonnotreturned_disp IN ("", " ", null))))
      tmp_reason = substring(1,32,request->consents[d.seq].reasonnotreturned_disp)
     ELSE
      tmp_reason = "--"
     ENDIF
     IF ((request->consents[d.seq].dateconissued > 0)
      AND (request->consents[d.seq].dateconissued < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_issued = format(request->consents[d.seq].dateconissued,"@SHORTDATE")
     ELSE
      tmp_dt_issued = "   --"
     ENDIF
     IF ((request->consents[d.seq].dateconreturned > 0)
      AND (request->consents[d.seq].dateconreturned < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_returned = format(request->consents[d.seq].dateconreturned,"@SHORTDATE")
     ELSE
      tmp_dt_returned = "   --"
     ENDIF
     IF ((request->consents[d.seq].dateconsigned > 0)
      AND (request->consents[d.seq].dateconsigned < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_signed = format(request->consents[d.seq].dateconsigned,"@SHORTDATE")
     ELSE
      tmp_dt_signed = "   --"
     ENDIF
     mrn_size = size(request->consents[d.seq].mrns,5), prot_cnt = (prot_cnt+ 1)
     FOR (z = 1 TO mrn_size)
       tmp_apool = substring(1,10,request->consents[d.seq].mrns[z].alias_pool_disp), tmp_mrn =
       substring(1,20,request->consents[d.seq].mrns[z].mrn), tmp_mrn_pool = concat(tmp_apool," - ",
        tmp_mrn)
       IF (z > 1)
        tmp_ln = " ", tmp_fn = " ", tmp_prot_accession_nbr = "",
        tmp_amendment = "", tmp_rev = "", tmp_cons_type = "",
        tmp_dt_issued = "", tmp_dt_signed = "", tmp_dt_returned = ""
       ENDIF
       col 4, tmp_ln, col 16,
       tmp_fn, col 29, tmp_mrn_pool,
       col 61, tmp_prot_accession_nbr, col 78,
       tmp_amendment, col 89, tmp_rev,
       col 99, tmp_cons_type, col 116,
       tmp_dt_issued, col 126, tmp_dt_signed,
       col 136, tmp_dt_returned, row + 1
     ENDFOR
     IF (mrn_size=0)
      tmp_mrn_pool = "", col 4, tmp_ln,
      col 16, tmp_fn, col 29,
      tmp_mrn_pool, col 61, tmp_prot_accession_nbr,
      col 78, tmp_amendment, col 89,
      tmp_rev, col 99, tmp_cons_type,
      col 116, tmp_dt_issued, col 126,
      tmp_dt_signed, col 136, tmp_dt_returned,
      row + 1
     ENDIF
     IF (row > 53)
      BREAK
     ENDIF
    FOOT  prot
     total_prot_cnt = (total_prot_cnt+ prot_cnt), col 0, ln,
     row + 2
     IF (value(size(request->consents,5)) > 0)
      tmp_str2 = concat("Total for ",request->consents[d.seq].protalias," = ",trim(cnvtstring(
         prot_cnt))), col 4, "{B}",
      tmp_str2, row + 2
     ENDIF
    FOOT PAGE
     str9 = concat("Page "," ",cnvtstring(curpage)), str8 = concat("{CENTER/",str9,"/11/0}"),
     temp_row = row,
     row 56, col 1, str8
    FOOT REPORT
     IF (number_of_prots > 1)
      row temp_row, row + 2, tmp_str3 = concat("Total for All PROTOCOLS = ",trim(cnvtstring(
         total_prot_cnt))),
      col 0, "{B}", tmp_str3,
      str9 = concat("Page "," ",cnvtstring(curpage)), str8 = concat("{CENTER/",str9,"/11/0}"), row 56,
      col 1, str8
     ENDIF
    WITH dio = postscript, maxcol = 300
   ;end select
  ENDIF
 ELSEIF ((request->reporttypeflag=6))
  SET index = 1
  IF ((request->formattype=delimited_report))
   SET rpt_heading = m_s_not_returned_consents
  ELSE
   SET rpt_heading = "Protocols with Not Returned Consent Documents"
  ENDIF
  SET tmp_prot = 0.0
  SET multi_prot_ind = 0
  SET tmp_prot_mnem = ""
  FOR (num = 1 TO size(request->consents,5))
    IF (num=1)
     SET tmp_prot = request->consents[num].protocolid
     SET tmp_prot_mnem = request->consents[num].protalias
    ELSEIF ((request->consents[num].protocolid != tmp_prot))
     SET num = size(request->consents,5)
     SET multi_prot_ind = 1
    ENDIF
  ENDFOR
  IF (((size(request->protocols,5)=1
   AND value(size(request->consents,5)) > 0) OR (multi_prot_ind=0)) )
   IF (multi_prot_ind=0)
    SELECT INTO "nl:"
     FROM prot_master p
     WHERE (p.prot_master_id=request->consents[1].protocolid)
     DETAIL
      tmp_prot_mnem = p.primary_mnemonic
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->formattype=delimited_report))
    SET rpt_heading = concat(rpt_heading," ",m_s_for," ",tmp_prot_mnem)
   ELSE
    SET rpt_heading = concat(substring(16,30,rpt_heading)," for ",tmp_prot_mnem)
   ENDIF
  ENDIF
  SET prot_cnt = 0
  SET mrn_size = 0
  IF ((request->formattype=delimited_report))
   SELECT INTO value(hold_file)
    prot = substring(1,200,request->consents[d.seq].protalias), lastnm = substring(1,100,request->
     consents[d.seq].lastname), lastnmsort = cnvtlower(substring(1,100,request->consents[d.seq].
      lastname)),
    personid = request->consents[d.seq].personid
    FROM (dummyt d  WITH seq = value(size(request->consents,5)))
    ORDER BY prot, lastnmsort
    HEAD REPORT
     total_pt_cnt = 0, row + 1, col 0,
     rpt_heading, row + 1, col 0,
     exec_timestamp, row + 1, tmp_str_labels = concat(m_s_last_name,",",m_s_first_name,",",m_s_mrn,
      ",",m_s_enrollment_id,",",m_s_primary_mnemonic,",",
      m_s_amendment,",",m_s_revision,",",m_s_consent_type,
      ",",m_s_consent_released,",",m_s_not_returned,",",
      m_s_reason_not_ret),
     col 0, tmp_str_labels, row + 1
    DETAIL
     total_pt_cnt = (total_pt_cnt+ 1), tmp_ln = request->consents[d.seq].lastname, tmp_fn = request->
     consents[d.seq].firstname,
     tmp_prot_accession_nbr = request->consents[d.seq].protaccessionnbr, tmp_protocol = request->
     consents[d.seq].protalias
     IF ((request->consents[d.seq].cur_amendmentnbr > 0))
      tmp_amendment = concat(m_s_amendment," ",cnvtstring(request->consents[d.seq].cur_amendmentnbr))
     ELSE
      tmp_amendment = m_s_init_prot
     ENDIF
     IF ( NOT ((request->consents[d.seq].cur_revisionnbrtxt IN ("", " ", null))))
      tmp_rev = request->consents[d.seq].cur_revisionnbrtxt
     ELSE
      tmp_rev = ""
     ENDIF
     IF ( NOT ((request->consents[d.seq].reasonforcon_disp IN ("", " ", null))))
      tmp_cons_type = request->consents[d.seq].reasonforcon_disp
     ELSE
      tmp_cons_type = ""
     ENDIF
     IF ((request->consents[d.seq].dateconissued > 0)
      AND (request->consents[d.seq].dateconissued < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_issued = format(request->consents[d.seq].dateconissued,"@SHORTDATE")
     ELSE
      tmp_dt_issued = ""
     ENDIF
     IF ((request->consents[d.seq].dateconnotreturned > 0)
      AND (request->consents[d.seq].dateconnotreturned < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_not_rtnd = format(request->consents[d.seq].dateconnotreturned,"@SHORTDATE")
     ELSE
      tmp_dt_not_rtnd = ""
     ENDIF
     IF ( NOT ((request->consents[d.seq].reasonnotreturned_disp IN ("", " ", null))))
      tmp_reason = request->consents[d.seq].reasonnotreturned_disp
     ELSE
      tmp_reason = ""
     ENDIF
     mrn_size = size(request->consents[d.seq].mrns,5)
     FOR (z = 1 TO mrn_size)
       tmp_apool = request->consents[d.seq].mrns[z].alias_pool_disp, tmp_mrn = request->consents[d
       .seq].mrns[z].mrn
       IF (z=1)
        IF (size(trim(tmp_apool),1) > 0)
         tmp_mrn_pool = concat(tmp_apool," ",m_s_dash," ",tmp_mrn)
        ELSE
         tmp_mrn_pool = tmp_mrn
        ENDIF
       ELSE
        IF (size(trim(tmp_apool),1) > 0)
         tmp_mrn_pool = concat(tmp_mrn_pool,m_s_semi," ",tmp_apool," ",
          m_s_dash," ",tmp_mrn)
        ELSE
         tmp_mrn_pool = concat(tmp_mrn_pool,m_s_semi," ",tmp_mrn)
        ENDIF
       ENDIF
     ENDFOR
     tempstr = concat(concat('"',trim(tmp_ln),'"'),delimiter,concat('"',trim(tmp_fn),'"'),delimiter,
      concat('"',trim(tmp_mrn_pool),'"'),
      delimiter,concat('"',trim(tmp_prot_accession_nbr),'"'),delimiter,concat('"',trim(tmp_protocol),
       '"'),delimiter,
      concat('"',trim(tmp_amendment),'"'),delimiter,concat('"',trim(tmp_rev),'"'),delimiter,concat(
       '"',trim(tmp_cons_type),'"'),
      delimiter,concat('"',trim(tmp_dt_issued),'"'),delimiter,concat('"',trim(tmp_dt_not_rtnd),'"'),
      delimiter,
      concat('"',trim(tmp_reason),'"')), row + 1, col 0,
     tempstr
    FOOT REPORT
     IF (total_pt_cnt > 1)
      row + 2, tmp_str3 = concat(m_s_total," ",trim(cnvtstring(total_pt_cnt))), col 0,
      tmp_str3, row + 2, tempstr = m_s_end_report,
      col 0, tempstr
     ENDIF
    WITH format = crstream, formfeed = none, maxcol = 1500,
     nocounter
   ;end select
  ELSE
   SELECT INTO value(hold_file)
    prot = substring(1,200,request->consents[d.seq].protalias), lastnm = substring(1,100,request->
     consents[d.seq].lastname), lastnmsort = cnvtlower(substring(1,100,request->consents[d.seq].
      lastname)),
    personid = request->consents[d.seq].personid
    FROM (dummyt d  WITH seq = value(size(request->consents,5)))
    ORDER BY prot, lastnmsort
    HEAD REPORT
     total_prot_cnt = 0, number_of_prots = 0, estimated_prot = 0,
     "{PS/792 0 translate 90 rotate/}", row + 1, rpt_heading = concat("{CENTER/",rpt_heading,"/11/0}"
      ),
     col 1, "{B}{CPI/10}", rpt_heading,
     row + 2
    HEAD PAGE
     IF (curpage > 1)
      "{PS/792 0 translate 90 rotate/}", row + 1, col 1,
      "{B}{CPI/10}", rpt_heading, row + 2
     ENDIF
     88spc = fillstring(88," "), str = concat(88spc,"Consent","       ","Consent","   ",
      "Not"), col 0,
     "{B}{CPI/15}", str, row + 1,
     str2 = concat(" Last Name","    ","First Name","   ","MRN",
      "                               ","Enrollment ID","    ","Amd","  ",
      "Rev","  ","Type","          ","Released",
      "  ","Returned","  ","Reason Not Returned               _"), col 0, "{B}{U}",
     str2, row + 1
    HEAD prot
     estimated_row = 0
     FOR (protindex = 1 TO value(size(request->consents,5)))
      estimated_row = (estimated_row+ 1),
      IF ((request->consents[protindex].protalias=request->consents[d.seq].protalias))
       IF (size(request->consents[protindex].mrns,5) > 1)
        estimated_row = ((estimated_row+ size(request->consents[protindex].mrns,5)) - 1)
       ENDIF
      ENDIF
     ENDFOR
     estimated_row = (estimated_row+ 5), cntr = 0
     IF (estimated_row < 54)
      IF (((estimated_row+ row) >= 55))
       BREAK
      ENDIF
     ENDIF
     prot_cnt = 0
     IF (((size(request->protocols,5) > 1) OR (multi_prot_ind=1)) )
      row + 2, str3 = substring(1,15,request->consents[d.seq].protalias), col 4,
      "{B}{CPI/10}", str3, row + 1,
      col 4, "{CPI/15}", row + 1
     ENDIF
     number_of_prots = (number_of_prots+ 1)
    HEAD personid
     filler = 1
    DETAIL
     tmp_ln = substring(1,12,request->consents[d.seq].lastname), tmp_fn = substring(1,12,request->
      consents[d.seq].firstname)
     IF ( NOT ((request->consents[d.seq].protaccessionnbr IN ("", " ", null))))
      tmp_prot_accession_nbr = substring(1,15,trim(request->consents[d.seq].protaccessionnbr))
     ELSE
      tmp_prot_accession_nbr = "--"
     ENDIF
     IF ((request->consents[d.seq].cur_amendmentnbr > 0))
      tmp_amendment = cnvtstring(request->consents[d.seq].cur_amendmentnbr)
     ELSE
      tmp_amendment = "IP"
     ENDIF
     IF ( NOT ((request->consents[d.seq].cur_revisionnbrtxt IN ("", " ", null))))
      tmp_rev = substring(1,9,trim(request->consents[d.seq].cur_revisionnbrtxt))
     ELSE
      tmp_rev = "--"
     ENDIF
     IF ( NOT ((request->consents[d.seq].reasonforcon_disp IN ("", " ", null))))
      tmp_cons_type = substring(1,12,request->consents[d.seq].reasonforcon_disp)
     ELSE
      tmp_cons_type = "--"
     ENDIF
     IF ( NOT ((request->consents[d.seq].reasonnotreturned_disp IN ("", " ", null))))
      tmp_reason = substring(1,32,request->consents[d.seq].reasonnotreturned_disp)
     ELSE
      tmp_reason = "--"
     ENDIF
     IF ((request->consents[d.seq].dateconissued > 0)
      AND (request->consents[d.seq].dateconissued < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_issued = format(request->consents[d.seq].dateconissued,"@SHORTDATE")
     ELSE
      tmp_dt_issued = "   --"
     ENDIF
     IF ((request->consents[d.seq].dateconnotreturned > 0)
      AND (request->consents[d.seq].dateconnotreturned < cnvtdatetime("31-DEC-2100 00:00:00")))
      tmp_dt_not_rtnd = format(request->consents[d.seq].dateconnotreturned,"@SHORTDATE")
     ELSE
      tmp_dt_not_rtnd = "   --"
     ENDIF
     IF ( NOT ((request->consents[d.seq].stratumlabel IN ("", " ", null))))
      tmp_stratum = substring(1,10,request->consents[d.seq].stratumlabel)
     ELSE
      tmp_stratum = "--"
     ENDIF
     mrn_size = size(request->consents[d.seq].mrns,5), prot_cnt = (prot_cnt+ 1)
     FOR (z = 1 TO mrn_size)
       tmp_apool = substring(1,10,request->consents[d.seq].mrns[z].alias_pool_disp), tmp_mrn =
       substring(1,20,request->consents[d.seq].mrns[z].mrn), tmp_mrn_pool = concat(tmp_apool," - ",
        tmp_mrn)
       IF (z > 1)
        tmp_ln = " ", tmp_fn = " ", tmp_prot_accession_nbr = "",
        tmp_amendment = "", tmp_rev = "", tmp_cons_type = "",
        tmp_dt_issued = "", tmp_dt_not_rtnd = "", tmp_reason = ""
       ENDIF
       col 1, tmp_ln, col 14,
       tmp_fn, col 27, tmp_mrn_pool,
       col 61, tmp_prot_accession_nbr, col 78,
       tmp_amendment, col 83, tmp_rev,
       col 88, tmp_cons_type, col 102,
       tmp_dt_issued, col 112, tmp_dt_not_rtnd,
       col 122, tmp_reason, row + 1
     ENDFOR
     IF (mrn_size=0)
      tmp_mrn_pool = "", col 1, tmp_ln,
      col 14, tmp_fn, col 27,
      tmp_mrn_pool, col 61, tmp_prot_accession_nbr,
      col 78, tmp_amendment, col 83,
      tmp_rev, col 88, tmp_cons_type,
      col 102, tmp_dt_issued, col 112,
      tmp_dt_not_rtnd, col 122, tmp_reason,
      row + 1
     ENDIF
     IF (row > 52)
      BREAK
     ENDIF
    FOOT  prot
     total_prot_cnt = (total_prot_cnt+ prot_cnt), col 0, ln,
     row + 2
     IF (value(size(request->consents,5)) > 0)
      tmp_str2 = concat("Total for ",request->consents[d.seq].protalias," = ",trim(cnvtstring(
         prot_cnt))), col 4, "{B}",
      tmp_str2, row + 2
     ENDIF
    FOOT PAGE
     str9 = concat("Page "," ",cnvtstring(curpage)), str8 = concat("{CENTER/",str9,"/11/0}"),
     temp_row = row,
     row 56, col 1, str8
    FOOT REPORT
     IF (number_of_prots > 1)
      row temp_row, row + 2, tmp_str3 = concat("Total for All PROTOCOLS = ",trim(cnvtstring(
         total_prot_cnt))),
      col 0, "{B}", tmp_str3,
      str9 = concat("Page "," ",cnvtstring(curpage)), str8 = concat("{CENTER/",str9,"/11/0}"), row 56,
      col 1, str8
     ENDIF
    WITH dio = postscript, maxcol = 300
   ;end select
  ENDIF
 ELSE
  CALL echo("INVALID SELECTION")
  GO TO exit_script
 ENDIF
 IF ((((request->output_dest_cd > 0)) OR (textlen(trim(request->outputdevice,3)) > 0)) )
  IF ((request->output_dest_cd > 0))
   SELECT INTO "nl:"
    FROM output_dest od,
     device d
    PLAN (od
     WHERE (od.output_dest_cd=request->output_dest_cd))
     JOIN (d
     WHERE d.device_cd=od.device_cd)
    DETAIL
     squeuename = d.name
    WITH nocounter
   ;end select
  ENDIF
  IF (((textlen(trim(request->outputdevice,3))=0) OR ((request->output_dest_cd > 0)
   AND (request->outputdevice != squeuename))) )
   IF ((request->output_dest_cd > 0))
    SET boutputdest = true
    SET ct_request_struct->file_name = hold_file
    SET ct_request_struct->output_dest_cd = request->output_dest_cd
    SET ct_request_struct->copies = 1
    SET ct_request_struct->number_of_copies = 1
    SET ct_request_struct->transmit_dt_tm = cnvtdatetime(curdate,curtime3)
    SET ct_request_struct->priority_value = 0
    SET ct_request_struct->report_title = rpt_heading
    SET ct_request_struct->country_code = " "
    SET ct_request_struct->area_code = " "
    SET ct_request_struct->exchange = " "
    SET ct_request_struct->suffix = " "
   ENDIF
  ELSE
   SET hold_file = value(request->outputdevice)
  ENDIF
 ELSE
  SET reply->filename = hold_file
 ENDIF
 IF (boutputdest)
  EXECUTE sys_outputdest_print  WITH replace("REQUEST","CT_REQUEST_STRUCT"), replace("REPLY",
   "CT_REPLY_STRUCT")
  IF ((ct_reply_struct->sts=1))
   CALL echo("CT_Reply_Struct->Sts = 1")
   COMMIT
   SET reply->filename = hold_file
  ELSE
   CALL echo("CT_Reply_Struct->Sts != 1")
   GO TO exit_script
  ENDIF
 ENDIF
 SET err_num = error(err_msg,0)
 CALL echo(build("ERROR CODE:"," ",err_num))
 CALL echo(concat("ERROR MSG ",err_msg))
 IF (err_num=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  IF ((((request->reporttypeflag=1)) OR ((request->reporttypeflag=2))) )
   SET reply->status_data.subeventstatus[1].operationname = "ct_drv_pt_enrolled"
  ELSEIF ((request->reporttypeflag=3))
   SET reply->status_data.subeventstatus[1].operationname = "ct_drv_pt_cnsnt_nt_rtrn"
  ELSEIF ((request->reporttypeflag=4))
   SET reply->status_data.subeventstatus[1].operationname = "ct_drv_pt_pndng_vrfctn"
  ELSEIF ((((request->reporttypeflag=5)) OR ((request->reporttypeflag=6))) )
   SET reply->status_data.subeventstatus[1].operationname = "ct_drv_pt_consent_list"
  ENDIF
  SET reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
  SET reply->status_data.subeventstatus[1].targetobjectname = "ct_pt_rpt_shell"
 ENDIF
 SET last_mod = "008"
 SET mod_date = "Sep 12, 2013"
#exit_script
END GO
