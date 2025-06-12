CREATE PROGRAM dcp_prt_forms_activity:dba
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
 DECLARE rtnhandle = i4 WITH public, noconstant(0)
 SET i18nhandle = 0
 SET rtnhandle = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 smodified = vc
   1 sallergy = vc
   1 snoallergy = vc
   1 sreaction = vc
   1 scomment = vc
   1 slastupd = vc
   1 sby = vc
   1 scont = vc
   1 spatname = vc
   1 smrn = vc
   1 sage = vc
   1 sadmitdoc = vc
   1 sgender = vc
   1 sfinnbr = vc
   1 sadmitdt = vc
   1 sloc = vc
   1 spage = vc
   1 sprintdate = vc
   1 sprinttime = vc
   1 sprintdt = vc
   1 sprinttm = vc
   1 sprintby = vc
   1 sprintname = vc
   1 sunauth = vc
   1 sinprogress = vc
   1 sperformedby = vc
   1 sproxyby = vc
   1 senteredon = vc
   1 supdatedon = vc
   1 shomemeds = vc
   1 smeddetails = vc
   1 sallmedsnotview = vc
   1 sproblem = vc
   1 sproblemrecorder = vc
   1 sproblemonsetdt = vc
   1 sproblemqualifier = vc
   1 sproblemconfirmation = vc
   1 sproblemstatus = vc
   1 sdx = vc
   1 sdxtype = vc
   1 sdxonsetdttm = vc
   1 sdxqualifier = vc
   1 sdxconfirmation = vc
   1 sdxonsetdttm = vc
   1 slnnumberchar = vc
   1 sgestationage = vc
   1 sgestationmethod = vc
   1 sgestationcomment = vc
   1 smedlist = vc
   1 snormalorder = vc
   1 sprescriptionorder = vc
   1 shomemeds = vc
   1 spatientownsmeds = vc
   1 schargeonly = vc
   1 ssatellitemeds = vc
   1 sotherorder = vc
   1 ssig = vc
   1 sprovider = vc
   1 sdate = vc
   1 sstatus = vc
   1 sordercompliance = vc
   1 sunabletoobtain = vc
   1 snoknownhomemeds = vc
   1 sperformedby = vc
   1 sperformeddate = vc
   1 spastmedhist = vc
   1 sonsetyear = vc
   1 sonsetage = vc
   1 scomments = vc
   1 sfamhist = vc
   1 shistory = vc
   1 snegative = vc
   1 sunknown = vc
   1 sunableobtain = vc
   1 sobtained = vc
   1 spatientadopted = vc
   1 sdeceased = vc
   1 salive = vc
   1 scauseofdeath = vc
   1 sageatdeath = vc
   1 sprochist = vc
   1 sperformedby = vc
   1 sweeks = vc
   1 sdays = vc
   1 spreghist = vc
   1 sgravida = vc
   1 sparaterm = vc
   1 sparapreterm = vc
   1 sabortions = vc
   1 sliving = vc
   1 spregstart = vc
   1 spregend = vc
   1 scloseddate = vc
   1 sautocloseddate = vc
   1 sdeliverydate = vc
   1 schildname = vc
   1 sfathername = vc
   1 sdeliverymethod = vc
   1 sanesthesia = vc
   1 sdeliveryhosp = vc
   1 spretermlabor = vc
   1 sneonataloutcome = vc
   1 smothercomp = vc
   1 sfetuscomp = vc
   1 sneocomp = vc
   1 snone = vc
   1 sbaby = vc
   1 sanother = vc
   1 ssocialhist = vc
   1 slastupdated = vc
   1 sallproceduresnotview = vc
   1 sallallergiesnotview = vc
   1 sallproblemsnotview = vc
   1 sallpastmedsnotview = vc
   1 sallpregnanciesnotview = vc
   1 sallshxnotview = vc
   1 sallfhxnotview = vc
   1 snogravida = vc
   1 snopregnancy = vc
   1 scommunicationmethod = vc
   1 scommnopreference = vc
   1 scommsendletter = vc
   1 scommphonecall = vc
   1 scommpatientportal = vc
   1 scommsecureemail = vc
 )
 SUBROUTINE fillcaptions(dummyvar)
   SET captions->smodified = trim(uar_i18ngetmessage(i18nhandle,"MODIFIED","modified"))
   SET captions->scomment = trim(uar_i18ngetmessage(i18nhandle,"COMMENT","Comment"))
   SET captions->slastupd = trim(uar_i18ngetmessage(i18nhandle,"LASTUPD","Form Last Updated on"))
   SET captions->sby = trim(uar_i18ngetmessage(i18nhandle,"BY","by"))
   SET captions->scont = trim(uar_i18ngetmessage(i18nhandle,"CONT","cont."))
   SET captions->sallergy = trim(uar_i18ngetmessage(i18nhandle,"ALLERGY","Allergy"))
   SET captions->snoallergy = trim(uar_i18ngetmessage(i18nhandle,"NOALLERGY","Allergies Not Recorded"
     ))
   SET captions->sreaction = trim(uar_i18ngetmessage(i18nhandle,"REACTION","Reaction"))
   SET captions->spatname = trim(uar_i18ngetmessage(i18nhandle,"PATNAME","Patient Name"))
   SET captions->smrn = trim(uar_i18ngetmessage(i18nhandle,"MRN","MRN"))
   SET captions->sage = trim(uar_i18ngetmessage(i18nhandle,"PATDEMOGINFO","DOB / AGE / SEX"))
   SET captions->sadmitdoc = trim(uar_i18ngetmessage(i18nhandle,"ADMITDOC","Admitting Physician"))
   SET captions->sloc = trim(uar_i18ngetmessage(i18nhandle,"LOC","Location"))
   SET captions->sgender = trim(uar_i18ngetmessage(i18nhandle,"GENDER","Gender"))
   SET captions->sfinnbr = trim(uar_i18ngetmessage(i18nhandle,"FINNBR","Financial Num"))
   SET captions->sadmitdt = trim(uar_i18ngetmessage(i18nhandle,"ADMITDT","Admission Date"))
   SET captions->spage = trim(uar_i18ngetmessage(i18nhandle,"PAGE","Page"))
   SET captions->sprintdate = trim(uar_i18ngetmessage(i18nhandle,"PRINTDATE","Print Date"))
   SET captions->sprinttime = trim(uar_i18ngetmessage(i18nhandle,"PRINTDATE","Print Time"))
   SET captions->sprintby = trim(uar_i18ngetmessage(i18nhandle,"PRINTEDBY","Printed by"))
   SET captions->sperformedby = trim(uar_i18ngetmessage(i18nhandle,"PERFORMEDBY","Performed by"))
   SET captions->sproxyby = trim(uar_i18ngetmessage(i18nhandle,"PROXYBY","Proxy by"))
   SET captions->senteredon = trim(uar_i18ngetmessage(i18nhandle,"ENTEREDON","Entered on"))
   SET captions->supdatedon = trim(uar_i18ngetmessage(i18nhandle,"UPDATEDON","Updated on"))
   SET captions->shomemeds = trim(uar_i18ngetmessage(i18nhandle,"HISTORICALMEDS",
     "Historical Medication"))
   SET captions->smeddetails = trim(uar_i18ngetmessage(i18nhandle,"DETAILS","Details"))
   SET captions->sproblem = trim(uar_i18ngetmessage(i18nhandle,"PROBLEM","Problems"))
   SET captions->sproblemrecorder = trim(uar_i18ngetmessage(i18nhandle,"RECBY","Recorded by"))
   SET captions->sproblemonsetdt = trim(uar_i18ngetmessage(i18nhandle,"STATUSDT","Status Date"))
   SET captions->sproblemqualifier = trim(uar_i18ngetmessage(i18nhandle,"QUALIFIER","Qualifier"))
   SET captions->sproblemconfirmation = trim(uar_i18ngetmessage(i18nhandle,"CONFIRMATION",
     "Confirmation"))
   SET captions->sproblemstatus = trim(uar_i18ngetmessage(i18nhandle,"PROBLEMSTATUS","Status"))
   SET captions->sdx = trim(uar_i18ngetmessage(i18nhandle,"DX","Clinical Diagnoses"))
   SET captions->sdxtype = trim(uar_i18ngetmessage(i18nhandle,"DXType","Type"))
   SET captions->sdxqualifier = trim(uar_i18ngetmessage(i18nhandle,"DXQUALIFIER","Qualifier"))
   SET captions->sdxconfirmation = trim(uar_i18ngetmessage(i18nhandle,"DXConfirmation","Confirmation"
     ))
   SET captions->sdxonsetdttm = trim(uar_i18ngetmessage(i18nhandle,"StatusDt","Status Date"))
   SET captions->slnnumberchar = trim(uar_i18ngetmessage(i18nhandle,"LnNumberChar","."))
   SET captions->sgestationage = trim(uar_i18ngetmessage(i18nhandle,"GestAge",
     "Gestational Age at Birth"))
   SET captions->sgestationmethod = trim(uar_i18ngetmessage(i18nhandle,"GestAgeMethod",
     "Gestational Age Method"))
   SET captions->sgestationcomment = trim(uar_i18ngetmessage(i18nhandle,"GESTCOMMENT",
     "Gestational Age Comment"))
   SET captions->smedlist = trim(uar_i18ngetmessage(i18nhandle,"MEDLIST","Medication List"))
   SET captions->ssig = trim(uar_i18ngetmessage(i18nhandle,"SIG","SIG"))
   SET captions->sprovider = trim(uar_i18ngetmessage(i18nhandle,"PROVIDER","Provider"))
   SET captions->sdate = trim(uar_i18ngetmessage(i18nhandle,"DATE","Date"))
   SET captions->sstatus = trim(uar_i18ngetmessage(i18nhandle,"STATUS","Status"))
   SET captions->sordercompliance = trim(uar_i18ngetmessage(i18nhandle,"ORDERCOMPLIANCE",
     "Order Compliance"))
   SET captions->sunabletoobtain = trim(uar_i18ngetmessage(i18nhandle,"UNABLETOOSTAIN",
     "Unable to Obtain"))
   SET captions->snoknownhomemeds = trim(uar_i18ngetmessage(i18nhandle,"NOKNOWNHOMEMEDS",
     "No Known Home Medications"))
   SET captions->sperformedby = trim(uar_i18ngetmessage(i18nhandle,"PERFORMEDBY","Performed By"))
   SET captions->sperformeddate = trim(uar_i18ngetmessage(i18nhandle,"PERFORMEDDATE","Performed Date"
     ))
   SET captions->spastmedhist = trim(uar_i18ngetmessage(i18nhandle,"PASTMEDHIST",
     "Past Medical History"))
   SET captions->sonsetage = trim(uar_i18ngetmessage(i18nhandle,"ONSETAGE","Onset Age"))
   SET captions->sonsetyear = trim(uar_i18ngetmessage(i18nhandle,"ONSETYEAR","Onset Year"))
   SET captions->scomments = trim(uar_i18ngetmessage(i18nhandle,"COMMENTS","Comments"))
   SET captions->sfamhist = trim(uar_i18ngetmessage(i18nhandle,"FAMILYHIST","Family History"))
   SET captions->shistory = trim(uar_i18ngetmessage(i18nhandle,"HIST","History"))
   SET captions->snegative = trim(uar_i18ngetmessage(i18nhandle,"NEGATIVE","Negative"))
   SET captions->sunknown = trim(uar_i18ngetmessage(i18nhandle,"UNKNOWN","Unknown"))
   SET captions->sunableobtain = trim(uar_i18ngetmessage(i18nhandle,"UNABLEOBTAIN","Unable to Obtain"
     ))
   SET captions->sobtained = trim(uar_i18ngetmessage(i18nhandle,"OBTAINED","Obtained"))
   SET captions->spatientadopted = trim(uar_i18ngetmessage(i18nhandle,"PATIENTADOPTED",
     "Patient was adopted"))
   SET captions->sdeceased = trim(uar_i18ngetmessage(i18nhandle,"DECEASED","Deceased"))
   SET captions->salive = trim(uar_i18ngetmessage(i18nhandle,"ALIVE","Alive"))
   SET captions->scauseofdeath = trim(uar_i18ngetmessage(i18nhandle,"CAUSEOFDEATH","Cauase of Death")
    )
   SET captions->sageatdeath = trim(uar_i18ngetmessage(i18nhandle,"AGEATDEATH","Age at Death"))
   SET captions->sprochist = trim(uar_i18ngetmessage(i18nhandle,"PROCEDUREHIST","Procedure History"))
   SET captions->sperformedby = trim(uar_i18ngetmessage(i18nhandle,"PERFORMEDBY","Performed by"))
   SET captions->sweeks = trim(uar_i18ngetmessage(i18nhandle,"WEEKS","Weeks"))
   SET captions->sdays = trim(uar_i18ngetmessage(i18nhandle,"DAYS","Days"))
   SET captions->spreghist = trim(uar_i18ngetmessage(i18nhandle,"GREGHIST","Pregnancy History"))
   SET captions->sgravida = trim(uar_i18ngetmessage(i18nhandle,"GRAVIDA","Gravida"))
   SET captions->sparaterm = trim(uar_i18ngetmessage(i18nhandle,"PARATERM","Para Term"))
   SET captions->sparapreterm = trim(uar_i18ngetmessage(i18nhandle,"PARAPRETERM","Para Preterm"))
   SET captions->sabortions = trim(uar_i18ngetmessage(i18nhandle,"ABORTIONS","Abortions"))
   SET captions->sliving = trim(uar_i18ngetmessage(i18nhandle,"LIVING","Living"))
   SET captions->spregstart = trim(uar_i18ngetmessage(i18nhandle,"PREGSTART","Pregnancy Start"))
   SET captions->spregend = trim(uar_i18ngetmessage(i18nhandle,"PREGEND","Pregnancy End"))
   SET captions->sdeliverydate = trim(uar_i18ngetmessage(i18nhandle,"DELIVERYDATE",
     "Delivery/Outcome Date"))
   SET captions->scloseddate = trim(uar_i18ngetmessage(i18nhandle,"CLOSEDPREGNANCY",
     "Closed Pregnancy"))
   SET captions->sautocloseddate = trim(uar_i18ngetmessage(i18nhandle,"AUTOCLOSEDPREGNANCY",
     "Closed Pregnancy (AUTO-CLOSED)"))
   SET captions->schildname = trim(uar_i18ngetmessage(i18nhandle,"CHILDNAME","Child Name"))
   SET captions->sfathername = trim(uar_i18ngetmessage(i18nhandle,"FATHERNAME","Father Name"))
   SET captions->sdeliverymethod = trim(uar_i18ngetmessage(i18nhandle,"DELIVERYMETHOD",
     "Delivery Method"))
   SET captions->sanesthesia = trim(uar_i18ngetmessage(i18nhandle,"ANESTHESIA","Anesthesia"))
   SET captions->sdeliveryhosp = trim(uar_i18ngetmessage(i18nhandle,"DELIVERYHOSP",
     "Delivery Hospital"))
   SET captions->spretermlabor = trim(uar_i18ngetmessage(i18nhandle,"PRETERMLABOR","Preterm Labor"))
   SET captions->sneonataloutcome = trim(uar_i18ngetmessage(i18nhandle,"NEONATALOUTCOME",
     "Neonatal Outcome"))
   SET captions->smothercomp = trim(uar_i18ngetmessage(i18nhandle,"MOTHERCOMP","Mother Complications"
     ))
   SET captions->sfetuscomp = trim(uar_i18ngetmessage(i18nhandle,"FETUSCOMP","Fetus Complications"))
   SET captions->sneocomp = trim(uar_i18ngetmessage(i18nhandle,"NEOCOMP","Neonatal Complications"))
   SET captions->snone = trim(uar_i18ngetmessage(i18nhandle,"NONE","None"))
   SET captions->sbaby = trim(uar_i18ngetmessage(i18nhandle,"BABY","Baby"))
   SET captions->sanother = trim(uar_i18ngetmessage(i18nhandle,"ANOTHER","Another"))
   SET captions->ssocialhist = trim(uar_i18ngetmessage(i18nhandle,"SocialHistory","Social History"))
   SET captions->slastupdated = trim(uar_i18ngetmessage(i18nhandle,"LastUpdated","Last Updated"))
   SET captions->sallmedsnotview = uar_i18ngetmessage(i18nhandle,"ALLMEDSNOTVIEW",
    "All recorded Medication items on this record may not be viewable.")
   SET captions->sallproceduresnotview = uar_i18ngetmessage(i18nhandle,"ALLPROCEDURESNOTVIEW",
    "All recorded Procedure History items on this record may not be viewable.")
   SET captions->sallallergiesnotview = uar_i18ngetmessage(i18nhandle,"ALLALLERGIESNOTVIEW",
    "All recorded Allergy items on this record may not be viewable.")
   SET captions->sallproblemsnotview = uar_i18ngetmessage(i18nhandle,"ALLPROBLEMSNOTVIEW",
    "All recorded Problem List items on this record may not be viewable.")
   SET captions->sallpastmedsnotview = uar_i18ngetmessage(i18nhandle,"ALLPASTMEDSNOTVIEW",
    "All recorded Past Medical History items on this record may not be viewable.")
   SET captions->sallpregnanciesnotview = uar_i18ngetmessage(i18nhandle,"ALLPREGNANCIESNOTVIEW",
    "All recorded Pregnancy History items on this record may not be viewable.")
   SET captions->sallshxnotview = uar_i18ngetmessage(i18nhandle,"ALLSHXNOTVIEW",
    "All recorded Social History items on this record may not be viewable.")
   SET captions->sallfhxnotview = uar_i18ngetmessage(i18nhandle,"ALLFHXSNOTVIEW",
    "All recorded Family History items on this record may not be viewable.")
   SET captions->snogravida = uar_i18ngetmessage(i18nhandle,"NOGRAVIDA",
    "No gravida / para results documented")
   SET captions->snopregnancy = uar_i18ngetmessage(i18nhandle,"NOPREGNANCY",
    "No pregnancy history documented")
   SET captions->scommunicationmethod = trim(uar_i18ngetmessage(i18nhandle,"COMMUNICATIONMETHOD",
     "Patient Preferred Method of Communication"))
   SET captions->scommnopreference = trim(uar_i18ngetmessage(i18nhandle,"NOPREFERENCE",
     "No Preference"))
   SET captions->scommsendletter = trim(uar_i18ngetmessage(i18nhandle,"SENDLETTER","Send Letter"))
   SET captions->scommphonecall = trim(uar_i18ngetmessage(i18nhandle,"PHONECALL","Phone Call"))
   SET captions->scommpatientportal = trim(uar_i18ngetmessage(i18nhandle,"PATIENTPORTAL",
     "Patient Portal"))
   SET captions->scommsecureemail = trim(uar_i18ngetmessage(i18nhandle,"SECUREEMAIL",
     "Secure Email (%1)"))
   SET captions->snormalorder = trim(uar_i18ngetmessage(i18nhandle,"NORMALORDER","Normal Order"))
   SET captions->sprescriptionorder = trim(uar_i18ngetmessage(i18nhandle,"PRESCRIPTIONORDER",
     "Prescription/Discharge Order"))
   SET captions->shomemeds = trim(uar_i18ngetmessage(i18nhandle,"HOMEMEDS","Home Meds"))
   SET captions->spatientownsmeds = trim(uar_i18ngetmessage(i18nhandle,"PATIENTOWNSMEDS",
     "Patient Owns Meds"))
   SET captions->schargeonly = trim(uar_i18ngetmessage(i18nhandle,"CHARGEONLY","Pharmacy Charge Only"
     ))
   SET captions->ssatellitemeds = trim(uar_i18ngetmessage(i18nhandle,"SATELLITEMEDS","Satellite Meds"
     ))
   SET captions->sotherorder = trim(uar_i18ngetmessage(i18nhandle,"OTHERORDERS","Other Order"))
 END ;Subroutine
 RECORD temp(
   1 dcp_forms_ref_id = f8
   1 description = vc
   1 sect_cnt = i2
   1 person_id = f8
   1 encntr_id = f8
   1 sl[*]
     2 dcp_section_ref_id = f8
     2 dcp_section_instance_id = f8
     2 description = vc
     2 ind = i2
     2 section_seq = i4
     2 section_event_id = f8
     2 input_cnt = i2
     2 il[*]
       3 dcp_input_ref_id = f8
       3 description = vc
       3 input_ref_seq = i4
       3 input_type = i4
       3 module = c20
       3 length = i4
       3 date = dq8
       3 valid_date = dq8
       3 status_ind = i2
       3 doc = vc
       3 ind = i2
       3 event_tag = vc
       3 event_tag2 = vc
       3 event_tag3 = vc
       3 unit = vc
       3 label = vc
       3 list_ln_cnt = i2
       3 list_tag[*]
         4 list_line = vc
       3 note_ind = i2
       3 event_id = f8
       3 note_text = vc
       3 note_cnt = i2
       3 note_qual[*]
         4 note_line = vc
       3 task_assay_cd = f8
       3 event_cd = f8
       3 parent_event_id = f8
       3 nom_cnt = i2
       3 nom_qual[*]
         4 nom_line = vc
       3 cnt = i2
       3 qual[*]
         4 line = vc
         4 label = vc
         4 list_ln_cnt = i2
         4 list_tag[*]
           5 list_line = vc
         4 nom_cnt = i2
         4 nom_qual[*]
           5 nom_line = vc
       3 grid_cnt = i2
       3 grid_qual[*]
         4 event_tag = vc
         4 event_tag2 = vc
         4 ind = i2
         4 doc = vc
         4 date = dq8
         4 label = vc
         4 label_ln_cnt = i2
         4 label_list_tag[*]
           5 label_list_line = vc
         4 length = i4
         4 event_id = f8
         4 status_ind = i2
         4 note_ind = i2
         4 note_text = vc
         4 note_cnt = i2
         4 note_qual[*]
           5 note_line = vc
         4 nom_cnt = i2
         4 nom_qual[*]
           5 nom_line = vc
         4 list_ln_cnt = i2
         4 list_tag[*]
           5 list_line = vc
         4 section = i4
         4 cnt = i2
         4 qual[*]
           5 event_tag = vc
           5 event_tag2 = vc
           5 event_tag3 = vc
           5 ind = i2
           5 doc = vc
           5 date = dq8
           5 label = vc
           5 label_ln_cnt = i2
           5 label_list_tag[*]
             6 label_list_line = vc
           5 length = i4
           5 event_id = f8
           5 status_ind = i2
           5 note_ind = i2
           5 note_text = vc
           5 note_cnt = i2
           5 note_qual[*]
             6 note_line = vc
           5 nom_cnt = i2
           5 nom_qual[*]
             6 nom_line = vc
           5 list_ln_cnt = i2
           5 list_tag[*]
             6 list_line = vc
           5 cell_result = i4
           5 collating_seq = i4
         4 row_result = i4
       3 pvc_name = vc
       3 pvc_value = vc
       3 val_cnt = i2
       3 val_qual[*]
         4 pvc_name = vc
         4 pvc_value = vc
       3 allergy_cnt = i2
       3 allergy_restricted_ind = i2
       3 allergy_qual[*]
         4 a_inst_id = f8
         4 list = vc
         4 alist_ln_cnt = i2
         4 alist_tag[*]
           5 alist_line = vc
         4 reaction_cnt = i2
         4 reaction_qual[*]
           5 rlist = vc
           5 rlist_ln_cnt = i2
           5 rlist_tag[*]
             6 rlist_line = vc
         4 date = dq8
         4 note_ind = i2
         4 note_cnt = i2
         4 note_qual[*]
           5 note_text = vc
           5 note_ln_cnt = i2
           5 nlist_tag[*]
             6 note_line = vc
       3 med_profile_restricted_ind = i2
       3 med_profile_qual[*]
         4 hna_order_mnemonic = vc
         4 hna_order_tag_list[*]
           5 order_tag = vc
         4 order_detail_display_line = vc
         4 order_detail_tag_list[*]
           5 order_detail_tag = vc
       3 problem_list_restricted_ind = i2
       3 problem_list[*]
         4 problem_desc = vc
         4 problem_tag[*]
           5 problem_line = vc
         4 onset_dt_tm = dq8
         4 onset_dt_flag = i2
         4 onset_dt_tm_str = vc
         4 problem_recorder = vc
         4 qualifier_cd = f8
         4 qualifier_disp = vc
         4 confirmation_cd = f8
         4 confirmation_disp = vc
         4 problem_onset_tz = i4
         4 problem_status_disp = vc
       3 diagnosis[*]
         4 diagnosis_desc = vc
         4 diagnosis_tag[*]
           5 diagnosis_line = vc
         4 diagnosis_onset_dt = dq8
         4 diagnosis_onset_dtstr = vc
         4 diagnosis_type_cd = f8
         4 diagnosis_type_disp = vc
         4 diagnosis_qualifier_cd = f8
         4 diagnosis_qualifier_disp = vc
         4 diagnosis_confirmation_cd = f8
         4 diagnosis_confirmation_disp = vc
         4 diagnosis_tz = i4
       3 gestational[*]
         4 gest_age_at_birth_week = i4
         4 gest_age_at_birth_days = i4
         4 gest_age_method = vc
         4 gest_age_concat = vc
         4 gest_comment = vc
         4 gest_tag[*]
           5 gest_line = vc
       3 tracking_cmt[*]
         4 comment_seq = i4
         4 comment_lbl = vc
         4 comment_visible = i2
         4 tracking_comment = vc
         4 tracking_tag[*]
           5 tracking_line = vc
       3 med_list[*]
         4 reference_name = vc
         4 name_lines[*]
           5 name_line = vc
         4 display_line = vc
         4 display_lines[*]
           5 display_ln = vc
         4 comment = vc
         4 comment_lines[*]
           5 comment_line = vc
         4 provider_id = f8
         4 provider_name = vc
         4 order_tz = i4
         4 order_dt_tm_str = vc
         4 order_status = vc
         4 medication_order_type_cd = f8
         4 originally_ordered_as_type
           5 normal_ind = i2
           5 prescription_ind = i2
           5 documented_ind = i2
           5 patients_own_ind = i2
           5 charge_only_ind = i2
           5 satellite_ind = i2
         4 med_type_ind = i2
       3 order_compliance[*]
         4 no_known_home_meds_ind = i2
         4 unable_to_obtain_ind = i2
         4 performed_by_name = vc
         4 performed_dt_tm_str = vc
       3 past_prob_list_restricted_ind = i2
       3 past_prob_list[*]
         4 prob_desc = vc
         4 prob_lines[*]
           5 prob_line = vc
         4 voca_cd_meaning = vc
         4 source_identifier = vc
         4 onset_year = vc
         4 onset_age = vc
         4 life_cycle_status_disp = vc
         4 comments[*]
           5 comment_dt_tm_str = vc
           5 comment_prsnl_name = vc
           5 comment = vc
           5 comment_lines[*]
             6 comment_line = vc
       3 entire_fam_hist_ind = i2
       3 fam_list_restricted_ind = i2
       3 fam_members[*]
         4 related_person_id = f8
         4 memb_entire_hist_ind = i2
         4 memb_name = vc
         4 reltn_disp = vc
         4 name_lines[*]
           5 aline = vc
         4 deceased_cd = f8
         4 cause_of_death = vc
         4 age_at_death_str = vc
         4 age_at_death_unit_disp = vc
         4 memb_birth_dt_tm = dq8
         4 conditions[*]
           5 fhx_value_flag = i2
           5 source_string = vc
           5 src_str_lines[*]
             6 aline = vc
           5 onset_age = i4
           5 onset_age_unit_disp = vc
           5 onset_age_unit_cd_mean = vc
           5 onset_year = i4
           5 onset_lines[*]
             6 aline = vc
           5 condition_status = vc
           5 comments[*]
             6 comment_prsnl_name = vc
             6 comment_dt_tm_str = vc
             6 comment = vc
             6 comment_lines[*]
               7 line = vc
       3 proc_list_restricted_ind = i2
       3 proc_list[*]
         4 proc_id = f8
         4 proc_desc = vc
         4 proc_lines[*]
           5 proc_line = vc
         4 voca_cd_meaning = vc
         4 source_identifier = vc
         4 proc_year = i4
         4 age_at_proc = vc
         4 proc_prsnl_name = vc
         4 proc_location = vc
         4 perform_lines[*]
           5 aline = vc
         4 comments[*]
           5 comment_dt_tm_str = vc
           5 comment_prsnl_name = vc
           5 comment = vc
           5 comment_lines[*]
             6 comment_line = vc
       3 pregnancies_restricted_ind = i2
       3 pregnancies[*]
         4 preg_start_dt_tm_str = vc
         4 preg_end_dt_tm_str = vc
         4 child_list[*]
           5 gestation_age_in_weeks = i4
           5 gestation_age_in_days = i4
           5 child_name = vc
           5 gender_disp = vc
           5 delivery_dt_tm_str = vc
           5 delivery_date_precision_flag = i2
           5 delivery_hospital = vc
           5 delivery_method_disp = vc
           5 anesthesia_disp = vc
           5 birth_weight_disp = vc
           5 preterm_labor_disp = vc
           5 father_name = vc
           5 neonate_outcome_disp = vc
           5 ma_comp_list[*]
             6 complication_disp = vc
           5 fetus_comp_list[*]
             6 complication_disp = vc
           5 neo_comp_list[*]
             6 complication_disp = vc
           5 preterm_labors[*]
             6 preterm_labor = vc
           5 data_str_lines[*]
             6 aline = vc
           5 gestation_term_txt = vc
         4 auto_close_ind = i2
       3 gravida[*]
         4 gravida = i4
         4 fullterm = i4
         4 parapreterm = i4
         4 aborted = i4
         4 living = i4
       3 shx_unable_to_obtain_ind = i2
       3 social_cat_list_restricted_ind = i2
       3 social_cat_list[*]
         4 shx_cat_ref_id = f8
         4 desc = vc
         4 desc_lines[*]
           5 desc_line = vc
         4 assessment_disp = vc
         4 last_updt_prsnl = vc
         4 last_updt_dt_tm = vc
         4 detail_list[*]
           5 shx_activity_grp_id = f8
           5 detail_disp = vc
           5 disp_lines[*]
             6 aline = vc
           5 detail_updt_prsnl = vc
           5 detail_updt_dt_tm = vc
           5 comments[*]
             6 comment_dt_tm = vc
             6 comment_prsnl = vc
             6 comment = vc
             6 comment_lines[*]
               7 aline = vc
       3 comm_pref_list[*]
         4 contact_method_cd = f8
         4 secure_email = vc
         4 desc = vc
         4 desc_lines[*]
           5 desc_line = vc
   1 updated_prsnl[*]
     2 prsnl_id = f8
     2 prsnl_ft = vc
     2 proxy_prsnl_id = f8
     2 proxy_prsnl_ft = vc
     2 update_dt_tm = dq8
     2 activity_tz = i4
     2 update_dt_str = vc
     2 update_qual[*]
       3 update_wrap_str = vc
   1 performed_prsnl_ft = vc
   1 performed_proxy_id = f8
   1 performed_proxy_ft = vc
   1 performed_dt_tm = dq8
   1 performed_tz = i4
   1 performed_dt_str = vc
   1 performed_qual[*]
     2 perform_wrap_str = vc
   1 time_zone_ind = i2
   1 entered_dt_tm = dq8
   1 entered_tz = i4
   1 entered_dt_str = vc
   1 prsnl_ind = i2
   1 last_updt_dt_tm = dq8
   1 last_updt_prsnl = vc
   1 last_updt_str = vc
   1 performed_prsnl_id = f8
   1 form_status_cd = f8
   1 person_prsnl_r_cd = f8
   1 prsnl_position_cd = f8
 )
 DECLARE birth_dt_tm_parameter = dq8 WITH protect, noconstant(0)
 SUBROUTINE (calculate_onset_year(onset_age=i4,onset_age_unit_cd_mean=vc) =i4)
   DECLARE onset_year = i4 WITH protect, noconstant(0)
   DECLARE age_in_year = f8 WITH protect, noconstant(0)
   IF (((onset_age=0) OR (birth_dt_tm_parameter=0)) )
    RETURN(onset_year)
   ENDIF
   CASE (onset_age_unit_cd_mean)
    OF "SECONDS":
     SET age_in_year = ((((onset_age/ 60)/ 60)/ 24)/ 365)
    OF "MINUTES":
     SET age_in_year = (((onset_age/ 60)/ 24)/ 365)
    OF "HOURS":
     SET age_in_year = ((onset_age/ 24)/ 365)
    OF "DAYS":
     SET age_in_year = (onset_age/ 365)
    OF "WEEKS":
     SET age_in_year = ((onset_age * 7)/ 365)
    OF "MONTHS":
     SET age_in_year = ((onset_age * 30)/ 365)
    OF "YEARS":
     SET age_in_year = onset_age
    ELSE
     SET age_in_year = onset_age
   ENDCASE
   SET onset_year = ceil(cnvtreal((age_in_year+ year(birth_dt_tm_parameter))))
   RETURN(onset_year)
 END ;Subroutine
 SUBROUTINE (wrap_text(blob_string=vc,wrap_max_length=i4,wrap_sec_max_length=i4) =null)
   DECLARE lf = vc WITH private, noconstant(char(10))
   DECLARE check = vc WITH private, noconstant(concat(char(13),char(10)))
   DECLARE l = i4 WITH private, noconstant(0)
   DECLARE h = i4 WITH private, noconstant(0)
   DECLARE c = i4 WITH private, noconstant(0)
   DECLARE j = i4 WITH private, noconstant(0)
   DECLARE check_blob = vc WITH private, noconstant(fillstring(65535," "))
   SET check_blob = build(blob_string,lf)
   DECLARE cr = i4 WITH private, noconstant(findstring(lf,check_blob))
   DECLARE length = i4 WITH private, noconstant(textlen(check_blob))
   DECLARE checkstring = vc WITH private, noconstant(fillstring(65535," "))
   SET checkstring = substring(1,(cr - 1),check_blob)
   DECLARE lfcheck = i4 WITH private, noconstant(findstring(check,checkstring))
   SET blob->cnt = 0
   IF (length=0)
    SET pt->line_cnt = 0
    SET stat = alterlist(pt->lns,0)
    SET stat = alterlist(blob->qual,0)
    RETURN
   ENDIF
   WHILE (cr > 0)
     SET blob->line = substring(1,(cr - 1),check_blob)
     SET check_blob = substring((cr+ 1),length,check_blob)
     IF (lfcheck > 0)
      SET check_blob = substring((cr+ 2),length,check_blob)
     ENDIF
     SET blob->cnt += 1
     SET stat = alterlist(blob->qual,blob->cnt)
     SET blob->qual[blob->cnt].line = trim(blob->line)
     SET blob->qual[blob->cnt].sze = textlen(trim(blob->line))
     SET cr = findstring(lf,check_blob)
     SET checkstring = substring(1,(cr - 1),check_blob)
     SET lfcheck = findstring(check,checkstring)
   ENDWHILE
   IF (trim(check_blob) != " ")
    SET blob->cnt += 1
    SET stat = alterlist(blob->qual,blob->cnt)
    SET blob->qual[blob->cnt].line = trim(check_blob)
    SET blob->qual[blob->cnt].sze = textlen(trim(check_blob))
   ENDIF
   FOR (j = 1 TO blob->cnt)
     WHILE ((blob->qual[j].sze > wrap_max_length))
       SET h = l
       SET c = wrap_max_length
       WHILE (c > 0)
        IF (substring(c,1,blob->qual[j].line) IN (" ", "-"))
         SET l += 1
         SET stat = alterlist(pt->lns,l)
         SET pt->lns[l].line = substring(1,c,blob->qual[j].line)
         SET blob->qual[j].line = substring((c+ 1),(blob->qual[j].sze - c),blob->qual[j].line)
         SET c = 1
        ENDIF
        SET c -= 1
       ENDWHILE
       IF (h=l)
        SET l += 1
        SET stat = alterlist(pt->lns,l)
        SET pt->lns[l].line = substring(1,wrap_max_length,blob->qual[j].line)
        SET blob->qual[j].line = substring((wrap_max_length+ 1),(blob->qual[j].sze - wrap_max_length),
         blob->qual[j].line)
       ENDIF
       SET blob->qual[j].sze = size(trim(blob->qual[j].line))
       SET wrap_max_length = wrap_sec_max_length
     ENDWHILE
     SET l += 1
     SET stat = alterlist(pt->lns,l)
     SET pt->lns[l].line = substring(1,blob->qual[j].sze,blob->qual[j].line)
     SET pt->line_cnt = l
     IF (l=1)
      SET wrap_max_length = wrap_sec_max_length
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (medlist_refname_formatting(sect=i4,ctrl=i4,medlistindex=i4) =null)
  DECLARE x = i4 WITH private, noconstant(0)
  IF ((temp->sl[sect].il[ctrl].med_list[medlistindex].reference_name > ""))
   SET pt->line_cnt = 0
   CALL wrap_text(temp->sl[sect].il[ctrl].med_list[medlistindex].reference_name,(m_totalchar - 14),(
    m_totalchar - 14))
   SET stat = alterlist(temp->sl[sect].il[ctrl].med_list[medlistindex].name_lines,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].med_list[medlistindex].name_lines[x].name_line = pt->lns[x].line
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE (medlist_comment_formatting(sect=i4,ctrl=i4,medlistindex=i4) =null)
   DECLARE long_txt = vc WITH protect, noconstant(fillstring(2000," "))
   DECLARE x = i4 WITH private, noconstant(0)
   IF ((temp->sl[sect].il[ctrl].med_list[medlistindex].comment > ""))
    SET pt->line_cnt = 0
    SET long_txt = build(captions->scomment,": ",temp->sl[sect].il[ctrl].med_list[medlistindex].
     comment)
    CALL wrap_text(long_txt,(m_totalchar - 20),(m_totalchar - 20))
    SET stat = alterlist(temp->sl[sect].il[ctrl].med_list[medlistindex].comment_lines,pt->line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].med_list[medlistindex].comment_lines[x].comment_line = pt->lns[x].
      line
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (medlist_displayln_formatting(sect=i4,ctrl=i4,medlistindex=i4) =null)
   DECLARE long_ln = vc WITH protect, noconstant(fillstring(2000," "))
   DECLARE x = i4 WITH private, noconstant(0)
   IF ((temp->sl[sect].il[ctrl].med_list[medlistindex].display_line > ""))
    SET pt->line_cnt = 0
    SET long_ln = build(captions->ssig,": ",temp->sl[sect].il[ctrl].med_list[medlistindex].
     display_line)
    CALL wrap_text(long_ln,(m_totalchar - 20),(m_totalchar - 20))
    SET stat = alterlist(temp->sl[sect].il[ctrl].med_list[medlistindex].display_lines,pt->line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].med_list[medlistindex].display_lines[x].display_ln = pt->lns[x].
      line
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (preg_data_str_formatting(sect=i4,ctrl=i4,pregindex=i4) =null)
   DECLARE long_str = vc WITH private, noconstant(fillstring(65535," "))
   DECLARE macomp_cnt = i4 WITH private, noconstant(0)
   DECLARE macomp_idx = i4 WITH private, noconstant(0)
   DECLARE fetcomp_cnt = i4 WITH private, noconstant(0)
   DECLARE fetcomp_idx = i4 WITH private, noconstant(0)
   DECLARE neocomp_cnt = i4 WITH private, noconstant(0)
   DECLARE neocomp_idx = i4 WITH private, noconstant(0)
   DECLARE prelabor_cnt = i4 WITH private, noconstant(0)
   DECLARE prelabor_idx = i4 WITH private, noconstant(0)
   DECLARE chldcnt = i4 WITH private, noconstant(0)
   DECLARE chldidx = i4 WITH private, noconstant(0)
   DECLARE x = i4 WITH private, noconstant(0)
   SET chldcnt = size(temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list,5)
   FOR (chldidx = 1 TO chldcnt)
     SET long_str = ""
     IF (chldcnt > 1)
      SET long_str = build2("(",captions->sbaby)
      CASE (chldidx)
       OF 1:
        SET long_str = build2(long_str," A): ")
       OF 2:
        SET long_str = build2(long_str," B): ")
       OF 3:
        SET long_str = build2(long_str," C): ")
       OF 4:
        SET long_str = build2(long_str," D): ")
       OF 5:
        SET long_str = build2(long_str," E): ")
       OF 6:
        SET long_str = build2(long_str," F): ")
       OF 7:
        SET long_str = build2(long_str," G): ")
       OF 8:
        SET long_str = build2(long_str," H): ")
       OF 9:
        SET long_str = build2(long_str," I): ")
       OF 10:
        SET long_str = build2(long_str," J): ")
       OF 11:
        SET long_str = build2(long_str," K): ")
       OF 12:
        SET long_str = build2(long_str," L): ")
       OF 13:
        SET long_str = build2(long_str," M): ")
       OF 14:
        SET long_str = build2(long_str," N): ")
       OF 15:
        SET long_str = build2(long_str," O): ")
       OF 16:
        SET long_str = build2(long_str," P): ")
       OF 17:
        SET long_str = build2(long_str," Q): ")
       OF 18:
        SET long_str = build2(long_str," R): ")
       OF 19:
        SET long_str = build2(long_str," S): ")
       OF 20:
        SET long_str = build2(long_str," T): ")
       OF 21:
        SET long_str = build2(long_str," U): ")
       OF 22:
        SET long_str = build2(long_str," V): ")
       OF 23:
        SET long_str = build2(long_str," W): ")
       OF 24:
        SET long_str = build2(long_str," X): ")
       OF 25:
        SET long_str = build2(long_str," Y): ")
       OF 26:
        SET long_str = build2(long_str," Z): ")
       ELSE
        SET long_str = build2(long_str," ",captions->sanother,"): ")
      ENDCASE
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].gestation_age_in_weeks
      > 0))
      SET long_str = build2(long_str,trim(cnvtstring(temp->sl[sect].il[ctrl].pregnancies[pregindex].
         child_list[chldidx].gestation_age_in_weeks))," ",captions->sweeks)
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].gestation_age_in_days >
     0))
      IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].gestation_age_in_weeks
       > 0))
       SET long_str = build2(long_str," ",trim(cnvtstring(temp->sl[sect].il[ctrl].pregnancies[
          pregindex].child_list[chldidx].gestation_age_in_days))," ",captions->sdays,
        "; ")
      ELSE
       SET long_str = build2(long_str,trim(cnvtstring(temp->sl[sect].il[ctrl].pregnancies[pregindex].
          child_list[chldidx].gestation_age_in_days))," ",captions->sdays,"; ")
      ENDIF
     ELSEIF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].gestation_term_txt
      > ""))
      SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
       chldidx].gestation_term_txt,"; ")
     ELSE
      IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].gestation_age_in_weeks
       > 0))
       SET long_str = build2(long_str,"; ")
      ENDIF
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].delivery_method_disp >
     ""))
      SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
       chldidx].delivery_method_disp,"; ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].gender_disp > ""))
      SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
       chldidx].gender_disp,"; ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].birth_weight_disp > ""))
      SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
       chldidx].birth_weight_disp,";  ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].anesthesia_disp > ""))
      SET long_str = build2(long_str,captions->sanesthesia,": ",temp->sl[sect].il[ctrl].pregnancies[
       pregindex].child_list[chldidx].anesthesia_disp,";  ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].delivery_hospital > ""))
      SET long_str = build2(long_str,captions->sdeliveryhosp,": ",temp->sl[sect].il[ctrl].
       pregnancies[pregindex].child_list[chldidx].delivery_hospital,"; ")
     ENDIF
     SET prelabor_cnt = size(temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].
      preterm_labors,5)
     IF (prelabor_cnt > 0)
      SET long_str = build2(long_str,captions->spretermlabor,": ")
      FOR (prelabor_idx = 1 TO prelabor_cnt)
        IF (prelabor_idx=prelabor_cnt)
         SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].preterm_labors[prelabor_idx].preterm_labor,"; ")
        ELSE
         SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].preterm_labors[prelabor_idx].preterm_labor,", ")
        ENDIF
      ENDFOR
     ENDIF
     SET macomp_cnt = size(temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].
      ma_comp_list,5)
     IF (macomp_cnt > 0)
      SET long_str = build2(long_str,captions->smothercomp,": ")
      FOR (macomp_idx = 1 TO macomp_cnt)
        IF (macomp_idx=macomp_cnt)
         SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].ma_comp_list[macomp_idx].complication_disp,"; ")
        ELSE
         SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].ma_comp_list[macomp_idx].complication_disp,", ")
        ENDIF
      ENDFOR
     ELSE
      SET long_str = build2(long_str,captions->smothercomp,": ",captions->snone,"; ")
     ENDIF
     SET fetcomp_cnt = size(temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].
      fetus_comp_list,5)
     IF (fetcomp_cnt > 0)
      SET long_str = build2(long_str,captions->sfetuscomp,": ")
      FOR (fetcomp_idx = 1 TO fetcomp_cnt)
        IF (fetcomp_idx=fetcomp_cnt)
         SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].fetus_comp_list[fetcomp_idx].complication_disp,"; ")
        ELSE
         SET long_str = build2(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].fetus_comp_list[fetcomp_idx].complication_disp,", ")
        ENDIF
      ENDFOR
     ELSE
      SET long_str = build2(long_str,captions->sfetuscomp,": ",captions->snone,"; ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].neonate_outcome_disp >
     ""))
      SET long_str = build2(long_str,captions->sneonataloutcome,": ",temp->sl[sect].il[ctrl].
       pregnancies[pregindex].child_list[chldidx].neonate_outcome_disp,"; ")
     ENDIF
     SET neocomp_cnt = size(temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].
      neo_comp_list,5)
     IF (neocomp_cnt > 0)
      SET long_str = build2(long_str,captions->sneocomp,": ")
      FOR (neocomp_idx = 1 TO neocomp_cnt)
        IF (neocomp_idx=neocomp_cnt)
         SET long_str = concat(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].neo_comp_list[neocomp_idx].complication_disp,"; ")
        ELSE
         SET long_str = concat(long_str,temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[
          chldidx].neo_comp_list[neocomp_idx].complication_disp,", ")
        ENDIF
      ENDFOR
     ELSE
      SET long_str = build2(long_str,captions->sneocomp,": ",captions->snone,"; ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].child_name > ""))
      SET long_str = build2(long_str,captions->schildname,": ",temp->sl[sect].il[ctrl].pregnancies[
       pregindex].child_list[chldidx].child_name,"; ")
     ENDIF
     IF ((temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].father_name > ""))
      SET long_str = build2(long_str,captions->sfathername,": ",temp->sl[sect].il[ctrl].pregnancies[
       pregindex].child_list[chldidx].father_name)
     ENDIF
     IF (( NOT (substring(1,1,long_str))=" "))
      SET pt->line_cnt = 0
      CALL wrap_text(long_str,(m_totalchar - 14),(m_totalchar - 14))
      SET stat = alterlist(temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].
       data_str_lines,pt->line_cnt)
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[sect].il[ctrl].pregnancies[pregindex].child_list[chldidx].data_str_lines[x].
        aline = pt->lns[x].line
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (proc_term_formatting(sect=i4,ctrl=i4,procindex=i4) =null)
   DECLARE proc_str = vc WITH private, noconstant(fillstring(2000," "))
   DECLARE x = i4 WITH private, noconstant(0)
   SET proc_str = temp->sl[sect].il[ctrl].proc_list[procindex].proc_desc
   IF (trim(temp->sl[sect].il[ctrl].proc_list[procindex].voca_cd_meaning) > "")
    SET proc_str = build2(proc_str,"(",temp->sl[sect].il[ctrl].proc_list[procindex].voca_cd_meaning,
     "-",temp->sl[sect].il[ctrl].proc_list[procindex].source_identifier,
     ")")
   ENDIF
   SET pt->line_cnt = 0
   CALL wrap_text(proc_str,(m_totalchar - 8),(m_totalchar - 8))
   SET stat = alterlist(temp->sl[sect].il[ctrl].proc_list[procindex].proc_lines,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].proc_list[procindex].proc_lines[x].proc_line = pt->lns[x].line
   ENDFOR
   DECLARE proc_perform = vc WITH private, noconstant(fillstring(2000," "))
   SET proc_perform = ""
   IF (trim(temp->sl[sect].il[ctrl].proc_list[procindex].proc_prsnl_name) > "")
    SET proc_perform = build2(temp->sl[sect].il[ctrl].proc_list[procindex].proc_prsnl_name)
   ENDIF
   IF ((temp->sl[sect].il[ctrl].proc_list[procindex].proc_year > 0))
    IF (trim(proc_perform) > "")
     SET proc_perform = build2(proc_perform,"/")
    ENDIF
    SET proc_perform = build2(proc_perform,trim(cnvtstring(temp->sl[sect].il[ctrl].proc_list[
       procindex].proc_year)))
   ENDIF
   IF (trim(temp->sl[sect].il[ctrl].proc_list[procindex].proc_location) > "")
    IF (trim(proc_perform) > "")
     SET proc_perform = build2(proc_perform,"/")
    ENDIF
    SET proc_perform = build2(proc_perform,temp->sl[sect].il[ctrl].proc_list[procindex].proc_location
     )
   ENDIF
   IF (trim(proc_perform) > "")
    SET proc_perform = build2(captions->sperformedby,": ",proc_perform)
    SET pt->line_cnt = 0
    CALL wrap_text(proc_perform,(m_totalchar - 8),(m_totalchar - 8))
    SET stat = alterlist(temp->sl[sect].il[ctrl].proc_list[procindex].perform_lines,pt->line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].proc_list[procindex].perform_lines[x].aline = pt->lns[x].line
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (proc_comment_formatting(sect=i4,ctrl=i4,procindex=i4) =null)
   DECLARE comt_cnt = i4 WITH private, noconstant(0)
   DECLARE comt_idx = i4 WITH private, noconstant(0)
   DECLARE x = i4 WITH private, noconstant(0)
   SET comt_cnt = size(temp->sl[sect].il[ctrl].proc_list[procindex].comments,5)
   FOR (comt_idx = 1 TO comt_cnt)
     SET pt->line_cnt = 0
     CALL wrap_text(temp->sl[sect].il[ctrl].proc_list[procindex].comments[comt_idx].comment,(
      m_totalchar - 20),(m_totalchar - 20))
     SET stat = alterlist(temp->sl[sect].il[ctrl].proc_list[procindex].comments[comt_idx].
      comment_lines,pt->line_cnt)
     FOR (x = 1 TO pt->line_cnt)
       SET temp->sl[sect].il[ctrl].proc_list[procindex].comments[comt_idx].comment_lines[x].
       comment_line = pt->lns[x].line
     ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE (past_prob_formatting(sect=i4,ctrl=i4,probindex=i4) =null)
   DECLARE prob_str = vc WITH private, noconstant(fillstring(1000," "))
   DECLARE x = i4 WITH private, noconstant(0)
   SET pt->line_cnt = 0
   SET prob_str = build2(temp->sl[sect].il[ctrl].past_prob_list[probindex].prob_desc)
   IF ((temp->sl[sect].il[ctrl].past_prob_list[probindex].source_identifier > ""))
    SET prob_str = build2(prob_str," ( ",temp->sl[sect].il[ctrl].past_prob_list[probindex].
     voca_cd_meaning,": ",temp->sl[sect].il[ctrl].past_prob_list[probindex].source_identifier,
     " )")
   ENDIF
   CALL wrap_text(prob_str,(m_totalchar - 10),(m_totalchar - 10))
   SET stat = alterlist(temp->sl[sect].il[ctrl].past_prob_list[probindex].prob_lines,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].past_prob_list[probindex].prob_lines[x].prob_line = pt->lns[x].line
   ENDFOR
 END ;Subroutine
 SUBROUTINE (past_prob_comment_formatting(sect=i4,ctrl=i4,probindex=i4) =null)
   DECLARE cmt_cnt = i4 WITH private, noconstant(0)
   DECLARE cmt_idx = i4 WITH private, noconstant(0)
   DECLARE x = i4 WITH private, noconstant(0)
   SET cmt_cnt = size(temp->sl[sect].il[ctrl].past_prob_list[probindex].comments,5)
   FOR (cmt_idx = 1 TO cmt_cnt)
     IF ((temp->sl[sect].il[ctrl].past_prob_list[probindex].comments[cmt_idx].comment > ""))
      SET pt->line_cnt = 0
      CALL wrap_text(temp->sl[sect].il[ctrl].past_prob_list[probindex].comments[cmt_idx].comment,(
       m_totalchar - 20),(m_totalchar - 20))
      SET stat = alterlist(temp->sl[sect].il[ctrl].past_prob_list[probindex].comments[cmt_idx].
       comment_lines,pt->line_cnt)
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[sect].il[ctrl].past_prob_list[probindex].comments[cmt_idx].comment_lines[x].
        comment_line = pt->lns[x].line
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (family_history_name_str_formatting(sect=i4,ctrl=i4,memidx=i4) =null)
   DECLARE name_str = vc WITH private, noconstant(fillstring(800," "))
   DECLARE x = i4 WITH private, noconstant(0)
   SET name_str = ""
   IF (trim(temp->sl[sect].il[ctrl].fam_members[memidx].reltn_disp) > "")
    SET name_str = build2(trim(temp->sl[sect].il[ctrl].fam_members[memidx].reltn_disp),": ")
   ENDIF
   IF (trim(temp->sl[sect].il[ctrl].fam_members[memidx].memb_name) > "")
    SET name_str = build2(name_str,trim(temp->sl[sect].il[ctrl].fam_members[memidx].memb_name))
   ENDIF
   IF ((temp->sl[sect].il[ctrl].fam_members[memidx].deceased_cd=deceased_cd_yes))
    SET name_str = build2(name_str," (",captions->sdeceased,") ")
   ELSE
    SET name_str = build2(name_str," (",captions->salive,") ")
   ENDIF
   IF (name_str > "")
    SET pt->line_cnt = 0
    CALL wrap_text(name_str,(m_totalchar - 12),(m_totalchar - 12))
    SET stat = alterlist(temp->sl[sect].il[ctrl].fam_members[memidx].name_lines,pt->line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].fam_members[memidx].name_lines[x].aline = pt->lns[x].line
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (family_history_condition_str_formatting(sect=i4,ctrl=i4,memidx=i4,conidx=i4) =null)
   DECLARE onset_str = vc WITH private, noconstant(fillstring(100," "))
   DECLARE x = i4 WITH private, noconstant(0)
   IF (trim(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].source_string) > "")
    SET pt->line_cnt = 0
    CALL wrap_text(build(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].source_string,
      ":"),(m_totalchar - 12),(m_totalchar - 12))
    SET stat = alterlist(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].src_str_lines,
     pt->line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].src_str_lines[x].aline = pt
      ->lns[x].line
    ENDFOR
   ENDIF
   SET onset_str = ""
   IF ((temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].onset_age > 0))
    SET onset_str = build2(captions->sonsetage,": ",trim(cnvtstring(temp->sl[sect].il[ctrl].
       fam_members[memidx].conditions[conidx].onset_age))," ",temp->sl[sect].il[ctrl].fam_members[
     memidx].conditions[conidx].onset_age_unit_disp)
   ENDIF
   IF ((temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].onset_year > 0))
    SET onset_str = build2(captions->sonsetyear,": ",trim(cnvtstring(temp->sl[sect].il[ctrl].
       fam_members[memidx].conditions[conidx].onset_year)),"; ",onset_str)
   ENDIF
   IF (onset_str > "")
    SET pt->line_cnt = 0
    CALL wrap_text(onset_str,(m_totalchar - 10),(m_totalchar - 10))
    SET stat = alterlist(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].onset_lines,
     pt->line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].onset_lines[x].aline = pt->
      lns[x].line
    ENDFOR
   ENDIF
   SET cmnt_cnt = size(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].comments,5)
   FOR (cmnt_idx = 1 TO cmnt_cnt)
     IF (trim(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].comments[cmnt_idx].
      comment) > "")
      SET pt->line_cnt = 0
      CALL wrap_text(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].comments[cmnt_idx
       ].comment,(m_totalchar - 22),(m_totalchar - 22))
      SET stat = alterlist(temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].comments[
       cmnt_idx].comment_lines,pt->line_cnt)
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[sect].il[ctrl].fam_members[memidx].conditions[conidx].comments[cmnt_idx].
        comment_lines[x].line = pt->lns[x].line
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (social_data_str_formatting(sect=i4,ctrl=i4,socialindex=i4) =null)
   DECLARE tmpstr = vc WITH private, noconstant(fillstring(65000," "))
   DECLARE cntdet = i4 WITH private, noconstant(0)
   DECLARE idxdet = i4 WITH private, noconstant(0)
   DECLARE cntcmt = i4 WITH private, noconstant(0)
   DECLARE idxcmt = i4 WITH private, noconstant(0)
   DECLARE x = i4 WITH private, noconstant(0)
   SET tmpstr = ""
   SET tmpstr = temp->sl[sect].il[ctrl].social_cat_list[socialindex].desc
   IF (trim(tmpstr) > "")
    SET tmpstr = build2(tmpstr,": ")
   ENDIF
   IF (trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].assessment_disp) > "")
    SET tmpstr = build2(tmpstr,"(",temp->sl[sect].il[ctrl].social_cat_list[socialindex].
     assessment_disp,")")
   ENDIF
   IF (trim(tmpstr) > "")
    SET pt->line_cnt = 0
    CALL wrap_text(tmpstr,(m_totalchar - 10),(m_totalchar - 10))
    SET stat = alterlist(temp->sl[sect].il[ctrl].social_cat_list[socialindex].desc_lines,pt->line_cnt
     )
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].social_cat_list[socialindex].desc_lines[x].desc_line = pt->lns[x].
      line
    ENDFOR
   ENDIF
   SET cntdet = size(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list,5)
   FOR (idxdet = 1 TO cntdet)
     SET tmpstr = ""
     IF (trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].detail_disp)
      > "")
      SET tmpstr = temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].
      detail_disp
     ENDIF
     IF (((trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].
      detail_updt_dt_tm) > "") OR (trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].
      detail_list[idxdet].detail_updt_prsnl) > "")) )
      SET tmpstr = build2(tmpstr,"(",captions->slastupdated,": ",trim(temp->sl[sect].il[ctrl].
        social_cat_list[socialindex].detail_list[idxdet].detail_updt_dt_tm),
       "  ",captions->sby,"  ",trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[
        idxdet].detail_updt_prsnl),")")
     ENDIF
     IF (trim(tmpstr) > "")
      SET pt->line_cnt = 0
      CALL wrap_text(tmpstr,(m_totalchar - 16),(m_totalchar - 16))
      SET stat = alterlist(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].
       disp_lines,pt->line_cnt)
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].disp_lines[x].
        aline = pt->lns[x].line
      ENDFOR
     ENDIF
   ENDFOR
   FOR (idxdet = 1 TO cntdet)
    SET cntcmt = size(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].
     comments,5)
    FOR (idxcmt = 1 TO cntcmt)
      SET pt->line_cnt = 0
      SET tmpstr = ""
      SET tmpstr = temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].comments[
      idxcmt].comment
      IF (((trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].comments[
       idxcmt].comment_dt_tm) > "") OR (trim(temp->sl[sect].il[ctrl].social_cat_list[socialindex].
       detail_list[idxdet].comments[idxcmt].comment_prsnl) > "")) )
       SET tmpstr = build2(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].
        comments[idxcmt].comment_dt_tm," - ",temp->sl[sect].il[ctrl].social_cat_list[socialindex].
        detail_list[idxdet].comments[idxcmt].comment_prsnl,": ",tmpstr)
      ENDIF
      CALL wrap_text(tmpstr,(m_totalchar - 20),(m_totalchar - 20))
      SET stat = alterlist(temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].
       comments[idxcmt].comment_lines,pt->line_cnt)
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[sect].il[ctrl].social_cat_list[socialindex].detail_list[idxdet].comments[idxcmt]
        .comment_lines[x].aline = pt->lns[x].line
      ENDFOR
    ENDFOR
   ENDFOR
 END ;Subroutine
 SUBROUTINE (communication_preference_str_formatting(sect=i4,ctrl=i4,commprefindex=i4) =null)
   DECLARE no_pref_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23042,
     "NOPREFERENCE"))
   DECLARE letter_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23042,
     "LETTER"))
   DECLARE telephone_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23042,
     "TELEPHONE"))
   DECLARE patient_portal_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
     23042,"PATPORTAL"))
   DECLARE email_contact_method_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23042,
     "EMAIL"))
   DECLARE tmpstr = vc WITH private, noconstant(fillstring(65000," "))
   DECLARE tmpemail = vc WITH private, noconstant(fillstring(255," "))
   DECLARE label_length = i4 WITH private, constant(size(captions->scommunicationmethod))
   DECLARE x = i4 WITH private, noconstant(0)
   IF ((temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].contact_method_cd=
   no_pref_contact_method_cd))
    SET tmpstr = captions->scommnopreference
   ELSEIF ((temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].contact_method_cd=
   letter_contact_method_cd))
    SET tmpstr = captions->scommsendletter
   ELSEIF ((temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].contact_method_cd=
   telephone_contact_method_cd))
    SET tmpstr = captions->scommphonecall
   ELSEIF ((temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].contact_method_cd=
   patient_portal_contact_method_cd))
    SET tmpstr = captions->scommpatientportal
   ELSEIF ((temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].contact_method_cd=
   email_contact_method_cd))
    SET tmpemail = ""
    SET tmpemail = trim(temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].secure_email)
    SET tmpstr = trim(uar_i18nbuildmessage(i18nhandle,"SECUREEMAIL",nullterm(captions->
       scommsecureemail),"s",nullterm(tmpemail)))
   ELSE
    SET tmpstr = ""
   ENDIF
   IF (trim(tmpstr) > "")
    SET temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].desc = tmpstr
    SET pt->line_cnt = 0
    CALL wrap_text(tmpstr,(m_totalchar - 50),(m_totalchar - 5))
    SET stat = alterlist(temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].desc_lines,pt->
     line_cnt)
    FOR (x = 1 TO pt->line_cnt)
      SET temp->sl[sect].il[ctrl].comm_pref_list[commprefindex].desc_lines[x].desc_line = pt->lns[x].
      line
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE (reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) =null)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE (fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) =null)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt += 1
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 SET modify = predeclare
 DECLARE dummy_void = i2 WITH constant(0)
 CALL fillcaptions(dummy_void)
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD qual_seqs(
   1 seqs[*]
     2 seq = i4
 )
 RECORD sorted_qual_seqs(
   1 seqs[*]
     2 seq = i4
 )
 RECORD username(
   1 usernamewrap[*]
     2 user = vc
 )
 RECORD footer_record(
   1 footer_qual[*]
     2 foot_string = vc
 )
 RECORD signature_lines(
   1 sign_qual[*]
     2 signature_value = vc
 )
 RECORD birth_temp(
   1 birth_temp_dt = dq8
   1 birth_temp_tz = i4
 )
 DECLARE dio_value = vc WITH protect
 DECLARE doaddoutput = i2 WITH protect, noconstant(0)
 DECLARE generatereply = i2 WITH protect, noconstant(0)
 DECLARE line_count = i4 WITH protect, noconstant(0)
 DECLARE header_line_count = i4 WITH protect, noconstant(0)
 SET generatereply = validate(request->replyind,0)
 SET doaddoutput = 0
 DECLARE normalorder = i2 WITH persist, noconstant(0)
 DECLARE prescriptionorder = i2 WITH persist, noconstant(0)
 DECLARE homemeds = i2 WITH persist, noconstant(0)
 DECLARE patientownsmeds = i2 WITH persist, noconstant(0)
 DECLARE chargeonly = i2 WITH persist, noconstant(0)
 DECLARE satellitemeds = i2 WITH persist, noconstant(0)
 DECLARE otherorder = i2 WITH persist, noconstant(0)
 RECORD reply(
   1 output_line[*]
     2 output = vc
   1 header_line[*]
     2 output = vc
   1 formdescription = vc
   1 performeddttm = dq8
   1 performedprsnlid = f8
   1 formstatuscode = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 performedtz = i4
   1 person_id = f8
   1 encntr_id = f8
 ) WITH persistscript
 IF (generatereply=1)
  IF ((request->prtr_list[1].dio_value=""))
   SET dio_value = "POSTSCRIPT"
  ELSE
   SET dio_value = request->prtr_list[1].dio_value
  ENDIF
 ELSE
  SET dio_value = "POSTSCRIPT"
 ENDIF
 DECLARE chunk_size = i4 WITH protected, constant(64000)
 DECLARE soutput = vc WITH protected, noconstant(fillstring(1024," "))
 DECLARE routput = vc WITH protected, noconstant(fillstring(1024," "))
 DECLARE rtfstring = vc WITH protected, noconstant("")
 SET modify = nopredeclare
 DECLARE unknown_type = i4 WITH public, constant(0)
 DECLARE label_control = i4 WITH public, constant(1)
 DECLARE numeric_control = i4 WITH public, constant(2)
 DECLARE flexunit_control = i4 WITH public, constant(3)
 DECLARE list_control = i4 WITH public, constant(4)
 DECLARE magrid_control = i4 WITH public, constant(5)
 DECLARE freetext_control = i4 WITH public, constant(6)
 DECLARE calculation_control = i4 WITH public, constant(7)
 DECLARE staticunit_control = i4 WITH public, constant(8)
 DECLARE alphacombo_control = i4 WITH public, constant(9)
 DECLARE datetime_control = i4 WITH public, constant(10)
 DECLARE allergy_control = i4 WITH public, constant(11)
 DECLARE imageholder_control = i4 WITH public, constant(12)
 DECLARE rtfeditor_control = i4 WITH public, constant(13)
 DECLARE discrete_grid = i4 WITH public, constant(14)
 DECLARE ralpha_grid = i4 WITH public, constant(15)
 DECLARE comment_control = i4 WITH public, constant(16)
 DECLARE power_grid = i4 WITH public, constant(17)
 DECLARE provider_control = i4 WITH public, constant(18)
 DECLARE ultra_grid = i4 WITH public, constant(19)
 DECLARE tracking_control1 = i4 WITH public, constant(20)
 DECLARE conversion_control = i4 WITH public, constant(21)
 DECLARE numeric_control2 = i4 WITH public, constant(22)
 DECLARE nomenclature_control = i4 WITH public, constant(23)
 DECLARE tracking_control = i4 WITH public, constant(1)
 DECLARE carenet_control = i4 WITH public, constant(2)
 DECLARE medprofile_control = i4 WITH public, constant(1)
 DECLARE problemdx_control = i4 WITH public, constant(2)
 DECLARE pregnancyhistory_control = i4 WITH public, constant(3)
 DECLARE procedurehistory_control = i4 WITH public, constant(4)
 DECLARE familyhistory_control = i4 WITH public, constant(5)
 DECLARE medlist_control = i4 WITH public, constant(6)
 DECLARE pastmedhistory_control = i4 WITH public, constant(7)
 DECLARE socialhistory_control = i4 WITH public, constant(8)
 DECLARE communicationpreference_control = i4 WITH public, constant(9)
 SET modify = predeclare
 DECLARE age = vc WITH protect, noconstant(fillstring(300," "))
 DECLARE pat_name = vc WITH protect, noconstant(fillstring(100," "))
 DECLARE patinfo = i4 WITH protect, noconstant(0)
 DECLARE blob_out = vc WITH protect, noconstant(fillstring(32000," "))
 DECLARE code_value = f8 WITH protect, noconstant(0.0)
 DECLARE code_set = f8 WITH protect, noconstant(0.0)
 DECLARE cdf_meaning = vc WITH protect, noconstant(fillstring(12," "))
 DECLARE room = vc WITH protect, noconstant(fillstring(20," "))
 DECLARE unit = vc WITH protect, noconstant(fillstring(20," "))
 DECLARE bed = vc WITH protect, noconstant(fillstring(20," "))
 DECLARE admitdoc = vc WITH protect, noconstant(fillstring(30," "))
 DECLARE sex = vc WITH protect, noconstant(fillstring(10," "))
 DECLARE mrn = vc WITH protect, noconstant(fillstring(20," "))
 DECLARE finnbr = vc WITH protect, noconstant(fillstring(20," "))
 DECLARE date = vc WITH protect, noconstant(fillstring(20," "))
 DECLARE ycol = i4 WITH protect, noconstant(0)
 DECLARE xcol = i4 WITH protect, noconstant(0)
 DECLARE tempycol = i4 WITH protect, noconstant(0)
 DECLARE maxycol = i4 WITH protect, noconstant(0)
 DECLARE ycolr1 = i4 WITH protect, noconstant(0)
 DECLARE ycolr2 = i4 WITH protect, noconstant(0)
 DECLARE ycolr3 = i4 WITH protect, noconstant(0)
 DECLARE labl_length = i4 WITH protect, noconstant(0)
 DECLARE xxx = vc WITH protect, noconstant(fillstring(40," "))
 DECLARE person_id = f8 WITH protect, noconstant(0)
 DECLARE encntr_id = f8 WITH protect, noconstant(0)
 DECLARE day = vc WITH protect, noconstant(fillstring(2," "))
 DECLARE month = vc WITH protect, noconstant(fillstring(2," "))
 DECLARE year = vc WITH protect, noconstant(fillstring(4," "))
 DECLARE dcp_forms_ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE dcp_forms_activity_id = f8 WITH protect, noconstant(0.0)
 SET dcp_forms_ref_id = request->dcp_forms_ref_id
 SET dcp_forms_activity_id = request->dcp_forms_activity_id
 DECLARE version_dt_tm = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime))
 DECLARE inter_dt_tm = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime))
 DECLARE inter_date = vc WITH protect, noconstant(fillstring(6," "))
 DECLARE inter_time = vc WITH protect, noconstant(fillstring(4," "))
 DECLARE error_line = vc WITH protect, noconstant(fillstring(40," "))
 DECLARE updt_dt = vc WITH protect, noconstant(fillstring(20," "))
 DECLARE updt_by = vc WITH protect, noconstant(fillstring(40," "))
 DECLARE updt_by1 = vc WITH protect, noconstant(fillstring(40," "))
 DECLARE str = vc WITH protect
 DECLARE str1 = vc WITH protect
 DECLARE str2 = vc WITH protect
 DECLARE str3 = vc WITH protect
 DECLARE tempstr = vc WITH protect
 DECLARE spaces1 = i2 WITH protect, noconstant(0)
 DECLARE spaces2 = i2 WITH protect, noconstant(0)
 DECLARE spaces3 = i2 WITH protect, noconstant(0)
 DECLARE birth_dt_tm = vc WITH protect
 DECLARE loc_facility_disp = vc WITH protect
 DECLARE tmp_loc_facility_disp = vc WITH protect
 DECLARE font_size = i4 WITH protect, noconstant(9)
 DECLARE sectheader_font_size = i4 WITH protect, noconstant(10)
 DECLARE m_cpi = f8 WITH protect, noconstant(0.0)
 DECLARE m_lpi = f8 WITH protect, noconstant(0.0)
 DECLARE sectheader_font_cpi = f8 WITH protect, noconstant(0.0)
 DECLARE sectheader_font_lpi = f8 WITH protect, noconstant(0.0)
 DECLARE max_length = i4 WITH protect, noconstant(0)
 DECLARE max_grid_length = i4 WITH protect, noconstant(0)
 DECLARE grid_indent = i4 WITH protect, noconstant(0)
 DECLARE temp_y_col = i4 WITH protect, noconstant(0)
 DECLARE comment_y_col = i4 WITH protect, noconstant(0)
 DECLARE comment_line_cnt = i4 WITH protect, noconstant(0)
 DECLARE end_y_col = i4 WITH protect, noconstant(0)
 DECLARE next_y_col = i4 WITH protect, noconstant(0)
 DECLARE next_line_cnt = i4 WITH protect, noconstant(0)
 DECLARE label_str = vc WITH protect, noconstant("")
 DECLARE seq_found_ind = i2 WITH protect, noconstant(0)
 DECLARE next_insert_val = i4 WITH protect, noconstant(0)
 DECLARE last_insert_val = i4 WITH protect, noconstant(0)
 DECLARE first_index = i4 WITH protect, noconstant(0)
 DECLARE second_index = i4 WITH protect, noconstant(0)
 DECLARE third_index = i4 WITH protect, noconstant(0)
 DECLARE m_totalchar = i4 WITH protect, noconstant(0)
 DECLARE sectheader_font_totalchar = i4 WITH protect, noconstant(0)
 DECLARE page_width = f8 WITH protect, constant(8.5)
 DECLARE footer_string = vc WITH protect, noconstant(fillstring(255," "))
 DECLARE offset = i4 WITH private, noconstant(0)
 DECLARE daylight = i4 WITH private, noconstant(0)
 DECLARE user_name = vc WITH protect
 DECLARE header_font_size = i4 WITH protect, constant(9)
 DECLARE header_font_lpi = f8 WITH protect, noconstant(0.0)
 DECLARE header_font_cpi = f8 WITH protect, noconstant(0.0)
 DECLARE header_font_totalchar = i4 WITH protect, noconstant(0)
 DECLARE print_space = f8 WITH protect, constant(7.5)
 DECLARE signature_cnt = i4 WITH protect, noconstant(0)
 DECLARE signature_line_str = vc WITH protect, noconstant(fillstring(255," "))
 DECLARE clinical_cd = f8 WITH public, constant(uar_get_code_by("MEANING",18189,"CLINCALEVENT"))
 DECLARE mrn_alias_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE admit_doc_cd = f8 WITH public, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE finnbr_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE ocfcomp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE modified_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE canceled_cd = f8 WITH public, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE date_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"DATE"))
 DECLARE text_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"TXT"))
 DECLARE num_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"NUM"))
 DECLARE child_cd = f8 WITH public, constant(uar_get_code_by("MEANING",24,"CHILD"))
 DECLARE root_cd = f8 WITH public, constant(uar_get_code_by("MEANING",24,"ROOT"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE deceased_cd_yes = f8 WITH public, constant(uar_get_code_by("MEANING",268,"YES"))
 SET error_line = uar_get_code_display(cnvtreal(value(inerror_cd)))
 DECLARE sectionstring = vc WITH protect, noconstant(fillstring(200," "))
 DECLARE prob_cnt = i4 WITH protect, noconstant(0)
 DECLARE prob_ind = i4 WITH protect, noconstant(0)
 DECLARE med_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE medlist_cnt = i4 WITH protect, noconstant(0)
 DECLARE desc_length = i4 WITH protect, noconstant(0)
 DECLARE med_idx = i4 WITH protect, noconstant(0)
 DECLARE memb_cnt = i4 WITH protect, noconstant(0)
 DECLARE memb_idx = i4 WITH protect, noconstant(0)
 DECLARE cond_cnt = i4 WITH protect, noconstant(0)
 DECLARE cond_idx = i4 WITH protect, noconstant(0)
 DECLARE cmnt_cnt = i4 WITH protect, noconstant(0)
 DECLARE cmnt_idx = i4 WITH protect, noconstant(0)
 DECLARE proc_cnt = i4 WITH protect, noconstant(0)
 DECLARE proc_idx = i4 WITH protect, noconstant(0)
 DECLARE probcnt = i4 WITH protect, noconstant(0)
 DECLARE probind = i4 WITH protect, noconstant(0)
 DECLARE dix_cnt = i4 WITH protect, noconstant(0)
 DECLARE preg_cnt = i4 WITH protect, noconstant(0)
 DECLARE preg_idx = i4 WITH protect, noconstant(0)
 DECLARE chld_cnt = i4 WITH protect, noconstant(0)
 DECLARE chld_idx = i4 WITH protect, noconstant(0)
 DECLARE pastprob_cnt = i4 WITH protect, noconstant(0)
 DECLARE shx_cnt = i4 WITH protect, noconstant(0)
 DECLARE shx_idx = i4 WITH protect, noconstant(0)
 DECLARE det_cnt = i4 WITH protect, noconstant(0)
 DECLARE det_idx = i4 WITH protect, noconstant(0)
 DECLARE commpref_cnt = i4 WITH protect, noconstant(0)
 DECLARE commpref_idx = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE gravidaval = vc WITH protect, noconstant(fillstring(2," "))
 DECLARE fulltermval = vc WITH protect, noconstant(fillstring(2," "))
 DECLARE parapretermval = vc WITH protect, noconstant(fillstring(2," "))
 DECLARE abortedval = vc WITH protect, noconstant(fillstring(2," "))
 DECLARE livingval = vc WITH protect, noconstant(fillstring(2," "))
 DECLARE medprofile_formatting(sect=i4,ctrl=i4,medindex=i4) = null
 DECLARE problem_formatting(sect=i4,ctrl=i4,probindex=i4) = null
 DECLARE dx_formatting(sect=i4,ctrl=i4,dxindex=i4) = null
 DECLARE gest_formatting(sect=i4,ctrl=i4,gestindex=i4) = null
 DECLARE encntr_formatting(sect=i4,ctrl=i4,encindex=i4) = null
 IF (((dcp_forms_activity_id <= 0) OR (dcp_forms_activity_id=null)) )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  nvp.pvc_value
  FROM app_prefs ap,
   name_value_prefs nvp
  PLAN (nvp
   WHERE nvp.pvc_name IN ("FORMS_RPT_PT_INFO", "POWERFORMSRPT.FontSize",
   "POWERFORMSRPT.Signature Line", "POWERFORMSRPT.FooterLine")
    AND nvp.active_ind=1
    AND nvp.parent_entity_name="APP_PREFS")
   JOIN (ap
   WHERE ap.app_prefs_id=nvp.parent_entity_id
    AND (ap.application_number=reqinfo->updt_app))
  ORDER BY ap.prsnl_id, ap.position_cd
  DETAIL
   IF (ap.position_cd=0
    AND ap.prsnl_id=0)
    CALL fill_prefs(nvp.pvc_name,nvp.pvc_value)
   ENDIF
   IF ((ap.position_cd=reqinfo->position_cd)
    AND ap.prsnl_id=0)
    CALL fill_prefs(nvp.pvc_name,nvp.pvc_value)
   ENDIF
   IF ((ap.prsnl_id=reqinfo->updt_id)
    AND ap.position_cd=0)
    CALL fill_prefs(nvp.pvc_name,nvp.pvc_value)
   ENDIF
  WITH nocounter
 ;end select
 IF (signature_line_str != " ")
  CALL fillsignatureline(signature_line_str)
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted, p.birth_dt_tm, ea.alias,
  pl.name_full_formatted, e.loc_nurse_unit_cd, e.loc_room_cd,
  e.loc_bed_cd, p.sex_cd, e.reg_dt_tm,
  e.person_id, e.encntr_id, dfa.version_dt_tm,
  dfa.updt_dt_tm, check = decode(p.seq,"p",epr.seq,"epr",ea.seq,
   "ea","xyz")
  FROM dcp_forms_activity dfa,
   encounter e,
   person p,
   prsnl pl,
   encntr_prsnl_reltn epr,
   encntr_alias ea,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1)
  PLAN (dfa
   WHERE dfa.dcp_forms_activity_id=dcp_forms_activity_id)
   JOIN (d1)
   JOIN (e
   WHERE e.encntr_id=dfa.encntr_id)
   JOIN (((d2)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=admit_doc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null))
    AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
   ) ORJOIN ((((d3)
   JOIN (p
   WHERE p.person_id=dfa.person_id)
   ) ORJOIN ((d4)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND ((ea.encntr_alias_type_cd=finnbr_cd) OR (ea.encntr_alias_type_cd=mrn_alias_cd)) )
   )) ))
  ORDER BY e.encntr_id, check
  HEAD REPORT
   IF (dfa.version_dt_tm=null)
    version_dt_tm = dfa.beg_activity_dt_tm
   ELSE
    version_dt_tm = dfa.version_dt_tm
   ENDIF
  HEAD e.encntr_id
   unit = substring(1,20,uar_get_code_display(e.loc_nurse_unit_cd)), room = substring(1,20,
    uar_get_code_display(e.loc_room_cd)), bed = substring(1,20,uar_get_code_display(e.loc_bed_cd)),
   loc_facility_disp = uar_get_code_display(e.loc_facility_cd), date = format(e.reg_dt_tm,
    "@SHORTDATE;;Q"), person_id = e.person_id,
   encntr_id = e.encntr_id, xxx = concat(trim(unit)," ; ",trim(room)," ; ",trim(bed)),
   tmp_loc_facility_disp = concat(trim(loc_facility_disp),"(",trim(captions->sloc),": ",trim(xxx),
    ")")
  DETAIL
   IF (check="p")
    pat_name = substring(1,30,p.name_full_formatted), age = cnvtage(p.birth_dt_tm), birth_temp->
    birth_temp_dt = p.birth_dt_tm,
    birth_temp->birth_temp_tz = validate(p.birth_tz,0), sex = substring(1,10,uar_get_code_display(p
      .sex_cd))
   ELSEIF (check="epr")
    admitdoc = substring(1,30,pl.name_full_formatted)
   ELSEIF (check="ea")
    IF (ea.encntr_alias_type_cd=finnbr_cd)
     finnbr = substring(1,20,ea.alias)
    ELSEIF (ea.encntr_alias_type_cd=mrn_alias_cd)
     mrn = substring(1,20,ea.alias)
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d2, outerjoin = d3,
   outerjoin = d4
 ;end select
 IF (curutc=1)
  SET birth_dt_tm = datetimezoneformat(birth_temp->birth_temp_dt,birth_temp->birth_temp_tz,
   "@SHORTDATE")
 ELSE
  SET birth_dt_tm = format(birth_temp->birth_temp_dt,"@SHORTDATE;;Q")
 ENDIF
 SET modify = nopredeclare
 EXECUTE dcp_get_forms_activity_prt
 SET modify = predeclare
 RECORD blob(
   1 line = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
     2 sze = i4
 )
 IF ((temp->sect_cnt=0))
  GO TO exit_script
 ENDIF
 SET sectheader_font_size = (font_size+ 1)
 SET m_cpi = (1.0/ (0.00833 * font_size))
 SET m_lpi = (72.0/ font_size)
 SET m_totalchar = cnvtint(((m_cpi * page_width) * 0.9))
 SET sectheader_font_cpi = (1.0/ (0.00833 * sectheader_font_size))
 SET sectheader_font_lpi = (72.0/ sectheader_font_size)
 SET sectheader_font_totalchar = cnvtint((sectheader_font_cpi * page_width))
 SET header_font_cpi = (1.0/ (0.00833 * header_font_size))
 SET header_font_lpi = (72.0/ header_font_size)
 SET header_font_totalchar = cnvtint((header_font_cpi * page_width))
 SET grid_indent = 7
 DECLARE header_max_length = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET max_length = cnvtint((print_space * m_cpi))
 SET max_grid_length = ((1.75 * m_cpi) - 2)
 SET header_max_length = cnvtint((print_space * header_font_cpi))
 CALL wrap_text(temp->performed_dt_str,header_max_length,header_max_length)
 SET stat = alterlist(temp->performed_qual,pt->line_cnt)
 FOR (x = 1 TO pt->line_cnt)
   SET temp->performed_qual[x].perform_wrap_str = pt->lns[x].line
 ENDFOR
 DECLARE updt_list_cnt = i4 WITH private, noconstant(size(temp->updated_prsnl,5))
 DECLARE reverse_cnt = i4 WITH protect, noconstant(0)
 FOR (updt_cnt = 1 TO updt_list_cnt)
   CALL wrap_text(temp->updated_prsnl[updt_cnt].update_dt_str,max_length,max_length)
   SET stat = alterlist(temp->updated_prsnl[updt_cnt].update_qual,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->updated_prsnl[updt_cnt].update_qual[x].update_wrap_str = pt->lns[x].line
   ENDFOR
 ENDFOR
 FOR (z = 1 TO temp->sect_cnt)
   FOR (y = 1 TO temp->sl[z].input_cnt)
     IF (trim(temp->sl[z].il[y].module)="PFEXTCTRLS")
      IF ((temp->sl[z].il[y].input_type=medprofile_control))
       FOR (w = 1 TO size(temp->sl[z].il[y].med_profile_qual,5))
         CALL medprofile_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=problemdx_control))
       SET prob_cnt = size(temp->sl[z].il[y].problem_list,5)
       FOR (w = 1 TO prob_cnt)
         CALL problem_formatting(z,y,w)
       ENDFOR
       SET dix_cnt = size(temp->sl[z].il[y].diagnosis,5)
       FOR (w = 1 TO dix_cnt)
         CALL dx_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=medlist_control))
       SET med_list_cnt = size(temp->sl[z].il[y].med_list,5)
       FOR (w = 1 TO med_list_cnt)
         CALL medlist_refname_formatting(z,y,w)
         CALL medlist_comment_formatting(z,y,w)
         CALL medlist_displayln_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=pregnancyhistory_control))
       SET preg_cnt = size(temp->sl[z].il[y].pregnancies,5)
       FOR (w = 1 TO preg_cnt)
         CALL preg_data_str_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=procedurehistory_control))
       SET proc_cnt = size(temp->sl[z].il[y].proc_list,5)
       FOR (w = 1 TO proc_cnt)
        CALL proc_term_formatting(z,y,w)
        CALL proc_comment_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=pastmedhistory_control))
       SET pastprob_cnt = size(temp->sl[z].il[y].past_prob_list,5)
       FOR (w = 1 TO pastprob_cnt)
        CALL past_prob_formatting(z,y,w)
        CALL past_prob_comment_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=familyhistory_control))
       SET memb_cnt = size(temp->sl[z].il[y].fam_members,5)
       FOR (memb_idx = 1 TO memb_cnt)
         CALL family_history_name_str_formatting(z,y,memb_idx)
         SET cond_cnt = size(temp->sl[z].il[y].fam_members[memb_idx].conditions,5)
         FOR (cond_idx = 1 TO cond_cnt)
           SET birth_dt_tm_parameter = cnvtdatetime(temp->sl[z].il[y].fam_members[memb_idx].
            memb_birth_dt_tm)
           SET temp->sl[z].il[y].fam_members[memb_idx].conditions[cond_idx].onset_year =
           calculate_onset_year(temp->sl[z].il[y].fam_members[memb_idx].conditions[cond_idx].
            onset_age,temp->sl[z].il[y].fam_members[memb_idx].conditions[cond_idx].
            onset_age_unit_cd_mean)
           CALL family_history_condition_str_formatting(z,y,memb_idx,cond_idx)
         ENDFOR
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=socialhistory_control))
       FOR (w = 1 TO size(temp->sl[z].il[y].social_cat_list,5))
         CALL social_data_str_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=communicationpreference_control))
       FOR (w = 1 TO size(temp->sl[z].il[y].comm_pref_list,5))
         CALL communication_preference_str_formatting(z,y,w)
       ENDFOR
      ENDIF
     ENDIF
     IF (trim(temp->sl[z].il[y].module)="PFPMCtrls")
      IF ((temp->sl[z].il[y].input_type=1))
       FOR (w = 1 TO size(temp->sl[z].il[y].gestational,5))
         CALL gest_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=2))
       FOR (w = 1 TO size(temp->sl[z].il[y].tracking_cmt,5))
         CALL encntr_formatting(z,y,w)
       ENDFOR
      ENDIF
     ENDIF
     SET desc_length = size(temp->sl[z].il[y].description)
     IF ((temp->sl[z].il[y].input_type IN (22, 2, 4, 6, 7,
     9, 10, 13, 18, 23))
      AND trim(temp->sl[z].il[y].module)=" ")
      SET pt->line_cnt = 0
      CALL wrap_text(temp->sl[z].il[y].event_tag,(max_length - desc_length),max_length)
      SET stat = alterlist(temp->sl[z].il[y].list_tag,pt->line_cnt)
      SET temp->sl[z].il[y].list_ln_cnt = pt->line_cnt
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[z].il[y].list_tag[x].list_line = pt->lns[x].line
      ENDFOR
     ENDIF
     IF ((((temp->sl[z].il[y].input_type=5)) OR ((((temp->sl[z].il[y].input_type=1)) OR ((temp->sl[z]
     .il[y].input_type=2)))
      AND trim(temp->sl[z].il[y].module)="PVTRACKFORMS")) )
      FOR (w = 1 TO temp->sl[z].il[y].cnt)
        SET pt->line_cnt = 0
        CALL wrap_text(temp->sl[z].il[y].qual[w].line,(max_length - desc_length),max_length)
        SET stat = alterlist(temp->sl[z].il[y].qual[w].list_tag,pt->line_cnt)
        SET temp->sl[z].il[y].qual[w].list_ln_cnt = pt->line_cnt
        FOR (x = 1 TO pt->line_cnt)
          SET temp->sl[z].il[y].qual[w].list_tag[x].list_line = pt->lns[x].line
        ENDFOR
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type=15))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        SET pt->line_cnt = 0
        CALL wrap_text(temp->sl[z].il[y].grid_qual[w].event_tag,(max_grid_length - 4),(
         max_grid_length - 4))
        SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].list_tag,pt->line_cnt)
        SET temp->sl[z].il[y].grid_qual[w].list_ln_cnt = pt->line_cnt
        FOR (x = 1 TO pt->line_cnt)
          SET temp->sl[z].il[y].grid_qual[w].list_tag[x].list_line = pt->lns[x].line
        ENDFOR
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type=14))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        SET pt->line_cnt = 0
        SET labl_length = size(temp->sl[z].il[y].grid_qual[w].label)
        CALL wrap_text(temp->sl[z].il[y].grid_qual[w].event_tag,((max_length - 7) - labl_length),(
         max_length - 10))
        SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].list_tag,pt->line_cnt)
        SET temp->sl[z].il[y].grid_qual[w].list_ln_cnt = pt->line_cnt
        FOR (x = 1 TO pt->line_cnt)
          SET temp->sl[z].il[y].grid_qual[w].list_tag[x].list_line = pt->lns[x].line
        ENDFOR
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type IN (17, 19)))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
       IF ((temp->sl[z].il[y].input_type=19))
        SET pt->line_cnt = 0
        CALL wrap_text(temp->sl[z].il[y].grid_qual[w].label,max_grid_length,max_grid_length)
        SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].label_list_tag,pt->line_cnt)
        SET temp->sl[z].il[y].grid_qual[w].label_ln_cnt = pt->line_cnt
        FOR (p = 1 TO pt->line_cnt)
          SET temp->sl[z].il[y].grid_qual[w].label_list_tag[p].label_list_line = pt->lns[p].line
        ENDFOR
       ENDIF
       FOR (q = 1 TO temp->sl[z].il[y].grid_qual[w].cnt)
         SET pt->line_cnt = 0
         CALL wrap_text(temp->sl[z].il[y].grid_qual[w].qual[q].label,max_grid_length,max_grid_length)
         SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].qual[q].label_list_tag,pt->line_cnt)
         SET temp->sl[z].il[y].grid_qual[w].qual[q].label_ln_cnt = pt->line_cnt
         FOR (p = 1 TO pt->line_cnt)
           SET temp->sl[z].il[y].grid_qual[w].qual[q].label_list_tag[p].label_list_line = pt->lns[p].
           line
         ENDFOR
         SET pt->line_cnt = 0
         CALL wrap_text(temp->sl[z].il[y].grid_qual[w].qual[q].event_tag,max_grid_length,
          max_grid_length)
         SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].qual[q].list_tag,pt->line_cnt)
         SET temp->sl[z].il[y].grid_qual[w].qual[q].list_ln_cnt = pt->line_cnt
         FOR (x = 1 TO pt->line_cnt)
           SET temp->sl[z].il[y].grid_qual[w].qual[q].list_tag[x].list_line = pt->lns[x].line
         ENDFOR
       ENDFOR
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type=11))
      FOR (w = 1 TO temp->sl[z].il[y].allergy_cnt)
        SET pt->line_cnt = 0
        CALL wrap_text(temp->sl[z].il[y].allergy_qual[w].list,17,17)
        SET stat = alterlist(temp->sl[z].il[y].allergy_qual[w].alist_tag,pt->line_cnt)
        SET temp->sl[z].il[y].allergy_qual[w].alist_ln_cnt = pt->line_cnt
        FOR (x = 1 TO pt->line_cnt)
          SET temp->sl[z].il[y].allergy_qual[w].alist_tag[x].alist_line = pt->lns[x].line
        ENDFOR
        FOR (v = 1 TO temp->sl[z].il[y].allergy_qual[w].reaction_cnt)
          IF ((temp->sl[z].il[y].allergy_qual[w].reaction_qual[v].rlist > " "))
           SET pt->line_cnt = 0
           CALL wrap_text(temp->sl[z].il[y].allergy_qual[w].reaction_qual[v].rlist,50,50)
           SET stat = alterlist(temp->sl[z].il[y].allergy_qual[w].reaction_qual[v].rlist_tag,pt->
            line_cnt)
           SET temp->sl[z].il[y].allergy_qual[w].reaction_qual[v].rlist_ln_cnt = pt->line_cnt
           FOR (x = 1 TO pt->line_cnt)
             SET temp->sl[z].il[y].allergy_qual[w].reaction_qual[v].rlist_tag[x].rlist_line = pt->
             lns[x].line
           ENDFOR
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 DECLARE x9 = vc WITH protect, noconstant(fillstring(9," "))
 DECLARE event_id = f8 WITH protect, noconstant(0.0)
 SET event_id = 0
 FOR (z = 1 TO temp->sect_cnt)
   FOR (y = 1 TO temp->sl[z].input_cnt)
     IF ((temp->sl[z].il[y].input_type=11))
      IF ((temp->sl[z].il[y].note_ind=1))
       FOR (x = 1 TO temp->sl[z].il[y].allergy_cnt)
         IF ((temp->sl[z].il[y].allergy_qual[x].note_ind=1))
          FOR (w = 1 TO temp->sl[z].il[y].allergy_qual[x].note_cnt)
            IF ((temp->sl[z].il[y].allergy_qual[x].note_qual[w].note_text > " "))
             SET temp->sl[z].il[y].allergy_qual[x].note_qual[w].note_text = concat(captions->scomment,
              ": ",trim(temp->sl[z].il[y].allergy_qual[x].note_qual[w].note_text))
             SET pt->line_cnt = 0
             SET max_length = cnvtint((print_space * m_cpi))
             CALL wrap_text(temp->sl[z].il[y].allergy_qual[x].note_qual[w].note_text,((max_length -
              size(captions->scomment,1)) - 27),((max_length - size(captions->scomment,1)) - 27))
             SET stat = alterlist(temp->sl[z].il[y].allergy_qual[x].note_qual[w].nlist_tag,pt->
              line_cnt)
             SET temp->sl[z].il[y].allergy_qual[x].note_qual[w].note_ln_cnt = pt->line_cnt
             FOR (v = 1 TO pt->line_cnt)
               IF (v=1)
                SET temp->sl[z].il[y].allergy_qual[x].note_qual[w].nlist_tag[v].note_line = pt->lns[v
                ].line
               ELSE
                SET temp->sl[z].il[y].allergy_qual[x].note_qual[w].nlist_tag[v].note_line = concat(x9,
                 pt->lns[v].line)
               ENDIF
             ENDFOR
            ENDIF
          ENDFOR
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
     IF ((((temp->sl[z].il[y].input_type IN (22, 2, 4, 5, 6,
     7, 9, 10, 13, 14,
     15, 18, 17, 19, 23))) OR ((temp->sl[z].il[y].module="PVTRACKFORMS"))) )
      SET pt->line_cnt = 0
      SET max_length = cnvtint((print_space * m_cpi))
      IF ((temp->sl[z].il[y].note_text > " "))
       SET temp->sl[z].il[y].note_text = concat(captions->scomment,": ",trim(temp->sl[z].il[y].
         note_text))
      ENDIF
      CALL wrap_text(temp->sl[z].il[y].note_text,max_length,((max_length - size(captions->scomment,1)
       ) - 2))
      SET stat = alterlist(temp->sl[z].il[y].note_qual,pt->line_cnt)
      SET temp->sl[z].il[y].note_cnt = pt->line_cnt
      FOR (x = 1 TO pt->line_cnt)
        IF (x=1)
         SET temp->sl[z].il[y].note_qual[x].note_line = pt->lns[x].line
        ELSE
         SET temp->sl[z].il[y].note_qual[x].note_line = concat(x9,pt->lns[x].line)
        ENDIF
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type IN (15, 17, 19)))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        SET pt->line_cnt = 0
        SET max_length = 100
        IF ((temp->sl[z].il[y].grid_qual[w].note_text > " "))
         SET temp->sl[z].il[y].grid_qual[w].note_text = concat(captions->scomment,": ",trim(temp->sl[
           z].il[y].grid_qual[w].note_text))
        ENDIF
        CALL wrap_text(temp->sl[z].il[y].grid_qual[w].note_text,max_grid_length,((max_grid_length -
         size(captions->scomment,1)) - 2))
        SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].note_qual,pt->line_cnt)
        SET temp->sl[z].il[y].grid_qual[w].note_cnt = pt->line_cnt
        FOR (x = 1 TO pt->line_cnt)
          IF (x=1)
           SET temp->sl[z].il[y].grid_qual[w].note_qual[x].note_line = pt->lns[x].line
          ELSE
           SET temp->sl[z].il[y].grid_qual[w].note_qual[x].note_line = concat(x9,pt->lns[x].line)
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type=14))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        SET pt->line_cnt = 0
        SET max_length = 100
        IF ((temp->sl[z].il[y].grid_qual[w].note_text > " "))
         SET temp->sl[z].il[y].grid_qual[w].note_text = concat(captions->scomment,": ",trim(temp->sl[
           z].il[y].grid_qual[w].note_text))
        ENDIF
        CALL wrap_text(temp->sl[z].il[y].grid_qual[w].note_text,(max_length - 7),(max_length - 10))
        SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].note_qual,pt->line_cnt)
        SET temp->sl[z].il[y].grid_qual[w].note_cnt = pt->line_cnt
        FOR (x = 1 TO pt->line_cnt)
          IF (x=1)
           SET temp->sl[z].il[y].grid_qual[w].note_qual[x].note_line = pt->lns[x].line
          ELSE
           SET temp->sl[z].il[y].grid_qual[w].note_qual[x].note_line = concat(x9,pt->lns[x].line)
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type IN (17, 19)))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        FOR (q = 1 TO temp->sl[z].il[y].grid_qual[w].cnt)
          SET pt->line_cnt = 0
          SET max_length = 100
          IF ((temp->sl[z].il[y].grid_qual[w].qual[q].note_text > " "))
           SET temp->sl[z].il[y].grid_qual[w].qual[q].note_text = concat(captions->scomment,": ",trim
            (temp->sl[z].il[y].grid_qual[w].qual[q].note_text))
          ENDIF
          CALL wrap_text(temp->sl[z].il[y].grid_qual[w].qual[q].note_text,max_grid_length,((
           max_grid_length - size(captions->scomment,1)) - 2))
          SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].qual[q].note_qual,pt->line_cnt)
          SET temp->sl[z].il[y].grid_qual[w].qual[q].note_cnt = pt->line_cnt
          FOR (x = 1 TO pt->line_cnt)
            IF (x=1)
             SET temp->sl[z].il[y].grid_qual[w].qual[q].note_qual[x].note_line = pt->lns[x].line
            ELSE
             SET temp->sl[z].il[y].grid_qual[w].qual[q].note_qual[x].note_line = concat(x9,pt->lns[x]
              .line)
            ENDIF
          ENDFOR
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 DECLARE mode = i2 WITH private, constant(7)
 RECORD datetemp(
   1 date = dq8
 )
 SET datetemp->date = cnvtdatetime(sysdate)
 SET captions->sprintdt = format(datetemp->date,"@SHORTDATE;;Q")
 SET captions->sprinttm = concat(datetimezoneformat(datetemp->date,0,"@TIMENOSECONDS"))
 IF ((temp->time_zone_ind != 0)
  AND curutc != 0)
  SET captions->sprinttm = concat(captions->sprinttm," ",datetimezonebyindex(0,offset,daylight,mode,
    datetemp->date))
 ENDIF
 FREE RECORD datetemp
 DECLARE bottom = i2 WITH protect, noconstant(0)
 DECLARE bottomplusten = i2 WITH protect, noconstant(0)
 SET bottom = 650
 SET bottomplusten = (bottom+ 10)
 DECLARE linestr = vc
 DECLARE signlinestr = vc
 DECLARE signlinelength = i4 WITH protect
 SET signlinelength = cnvtint((2.5 * header_font_cpi))
 SET signlinestr = fillstring(value(signlinelength),"_")
 SET linestr = fillstring(value(header_font_totalchar),"_")
 SET sectionstring = fillstring(value(header_font_totalchar)," ")
 DECLARE demogstr = vc
 DECLARE thead = vc
 DECLARE total_page_cnt = i4 WITH protect, noconstant(0)
 DECLARE temp_page_cnt = i4 WITH protect, noconstant(0)
 DECLARE headercols_per_char = f8 WITH protect, noconstant(0.0)
 DECLARE formcols_per_char = f8 WITH protect, noconstant(0.0)
 DECLARE font_string = vc WITH protect, noconstant("")
 DECLARE footerlength = i4 WITH protect, noconstant(0)
 SET footerlength = cnvtint((5 * header_font_cpi))
 CALL wrap_text(footer_string,footerlength,footerlength)
 SET stat = alterlist(footer_record->footer_qual,pt->line_cnt)
 FOR (x = 1 TO pt->line_cnt)
   SET footer_record->footer_qual[x].foot_string = pt->lns[x].line
 ENDFOR
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  DETAIL
   user_name = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 CALL wrap_text(user_name,20,20)
 SET stat = alterlist(username->usernamewrap,pt->line_cnt)
 FOR (x = 1 TO pt->line_cnt)
   SET username->usernamewrap[x].user = pt->lns[x].line
 ENDFOR
 IF (dio_value="RTF")
  CALL build_rtf("nl:")
 ELSE
  CALL print_report("nl:",font_size,total_page_cnt)
  CALL print_report(request->prtr_list[1].output_device,font_size,total_page_cnt)
 ENDIF
 IF (generatereply=1)
  SET stat = alterlist(reply->output_line,line_count)
  SET reply->status_data.status = "S"
  CALL echorecord(reply)
 ELSE
  FREE SET reply
 ENDIF
 GO TO exit_script
 SUBROUTINE (addtoheader(output=vc) =null)
   IF (generatereply=1
    AND doaddoutput=1)
    SET header_line_count += 1
    SET stat = alterlist(reply->header_line,header_line_count)
    SET reply->header_line[header_line_count].output = output
   ENDIF
 END ;Subroutine
 SUBROUTINE (addtooutput(output=vc) =null)
   IF (generatereply=1
    AND doaddoutput=1)
    SET line_count += 1
    IF (size(reply->output_line,5) < line_count)
     SET stat = alterlist(reply->output_line,(line_count+ 50))
    ENDIF
    SET reply->output_line[line_count].output = output
   ENDIF
 END ;Subroutine
 SUBROUTINE (addtortf(output=vc) =null)
   IF (generatereply=1
    AND doaddoutput=1)
    IF (rtfstring="")
     SET rtfstring = output
    ELSE
     SET rtfstring = notrim(concat(rtfstring,output))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (print_report(output_dist=vc,font_size=i4,total_page_cnt=i4(ref)) =i4)
   SET ierrorcode = error(serrormsg,1)
   IF (ierrorcode != 0)
    CALL echo("*********************************")
    CALL echo(build("ERROR MESSAGE : ",serrormsg))
    CALL echo("*********************************")
    CALL reportfailure("ERROR","F","DCP_PRT_FORMS_ACTIVITY",serrormsg)
    GO TO exit_script
   ENDIF
   FREE RECORD pt
   IF (output_dist="nl:")
    SET doaddoutput = 0
   ELSE
    SET doaddoutput = 1
   ENDIF
   DECLARE sectheadercols_per_char = i4 WITH protect, noconstant(0)
   DECLARE headercols_per_char = i4 WITH protect, noconstant(0)
   DECLARE formcols_per_char = i4 WITH protect, noconstant(0)
   SET sectheadercols_per_char = (72.0/ sectheader_font_cpi)
   SET headercols_per_char = (72.0/ header_font_cpi)
   SET formcols_per_char = (72.0/ m_cpi)
   DECLARE updt_list_cnt = i4 WITH private, noconstant(0)
   DECLARE entered_dt = vc WITH private
   DECLARE temp_ycol = i4 WITH protect, noconstant(0)
   DECLARE center_offset = i4 WITH protect, noconstant(0)
   DECLARE gestation_in_days = i4 WITH private, noconstant(0)
   DECLARE gestation_in_weeks = i4 WITH private, noconstant(0)
   SELECT INTO value(output_dist)
    FROM (dummyt d1  WITH seq = 1)
    PLAN (d1)
    HEAD REPORT
     thead = "                                                                ", temp_page_cnt = 0
    HEAD PAGE
     ycol = 20, temp_page_cnt += 1
     IF (curpage=total_page_cnt
      AND signature_cnt != 0)
      bottom = 640
     ENDIF
     IF (footer_string=" ")
      bottom += header_font_size
     ENDIF
     IF (patinfo=0)
      bottom = 680, font_string = concat("{f/0}{cpi/",trim(cnvtstring(header_font_cpi)),"}{lpi/",trim
       (cnvtstring(header_font_lpi)),"}"), font_string,
      row + 1, spaces1 = ((header_font_totalchar - size(tmp_loc_facility_disp))/ 2), xcol = cnvtint((
       headercols_per_char * spaces1)),
      ycol += 10, soutput = concat("{b}",loc_facility_disp,"{endb}","(",trim(captions->sloc),
       ": ",trim(xxx),")"),
      CALL addtoheader(build("<center>",soutput,"</center>")),
      CALL print(calcpos(xcol,ycol)), soutput, row + 1,
      font_string = concat("{f/0}{cpi/",trim(cnvtstring(header_font_cpi)),"}{lpi/",trim(cnvtstring(
         header_font_lpi)),"}"), font_string, row + 1,
      xcol = 50, ycol += 10, ycol1 = ycol,
      soutput = concat(captions->spatname,": ",pat_name),
      CALL addtoheader(build(soutput,"<br>")),
      CALL print(calcpos(xcol,ycol)),
      soutput, row + 1, ycol += 10,
      xcol = 50, soutput = concat(captions->sadmitdoc,": ",admitdoc),
      CALL addtoheader(build(soutput,"<br>")),
      CALL print(calcpos(xcol,ycol)), soutput, row + 1,
      xcol = 50, ycol += 10, soutput = concat(captions->sadmitdt," / ",captions->smrn," / ",captions
       ->sfinnbr,
       ": ",trim(date),"  ",trim(mrn),"  ",
       trim(finnbr)),
      CALL addtoheader(build(soutput,"<br>")),
      CALL print(calcpos(xcol,ycol)), soutput,
      row + 1, xcol = 300, ycol = ycol1,
      soutput = concat(captions->sage,": ",birth_dt_tm," ",age,
       " ",sex),
      CALL addtoheader(build(soutput,"<br>")),
      CALL print(calcpos(xcol,ycol)),
      soutput, row + 1, ycol += 20,
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), linestr,
      row + 1
     ENDIF
     font_string = concat("{f/0}{cpi/",trim(cnvtstring(sectheader_font_cpi)),"}{lpi/",trim(cnvtstring
       (sectheader_font_lpi)),"}"), font_string, row + 1,
     spaces1 = ((sectheader_font_totalchar - size(temp->description))/ 2), xcol = cnvtint((
      sectheadercols_per_char * spaces1)), ycol += sectheader_font_size,
     soutput = concat("{b}",temp->description,"{endb}"),
     CALL addtooutput(build("<center>",soutput,"</center>")),
     CALL print(calcpos(xcol,ycol)),
     soutput, row + 1
     IF ((temp->prsnl_ind=0))
      center_offset = ((sectheader_font_totalchar - size(temp->last_updt_str))/ 2), xcol = cnvtint((
       sectheadercols_per_char * center_offset)), ycol += sectheader_font_size,
      soutput = concat("{b}",temp->last_updt_str,"{endb}"),
      CALL addtooutput(build("<center>",soutput,"</center>")),
      CALL print(calcpos(xcol,ycol)),
      soutput, row + 1
     ELSE
      center_offset = cnvtint(((sectheader_font_totalchar - size(temp->performed_qual[1].
        perform_wrap_str))/ 2)), xcol = cnvtint((sectheadercols_per_char * center_offset)), ycol +=
      sectheader_font_size
      FOR (perform_cnt = 1 TO size(temp->performed_qual,5))
        soutput = build("{b}",temp->performed_qual.perform_wrap_str,"{endb}"),
        CALL addtooutput(build("<center>",soutput,"</center>")),
        CALL print(calcpos(xcol,ycol)),
        soutput, row + 1, ycol += sectheader_font_size
      ENDFOR
      center_offset = ((sectheader_font_totalchar - size(temp->entered_dt_str))/ 2), xcol = cnvtint((
       sectheadercols_per_char * center_offset)), soutput = build("{b}",temp->entered_dt_str,"{endb}"
       ),
      CALL addtooutput(build("<center>",soutput,"</center>")),
      CALL print(calcpos(xcol,ycol)), soutput,
      row + 1
     ENDIF
     ycol += header_font_size, acol = ycol, rcol = ycol,
     thead = trim(thead)
     IF (thead != " ")
      xcol = 30, soutput = concat("{color/19}{b}",thead,"{endb}{color/0}"),
      CALL addtooutput(build(thead,"<br>")),
      CALL print(calcpos(xcol,ycol)), soutput, row + 1,
      ycol += header_font_size, font_string = concat("{f/0}{cpi/",trim(cnvtstring(m_cpi)),"}{lpi/",
       trim(cnvtstring(m_lpi)),"}"), font_string,
      row + 1
     ENDIF
    DETAIL
     xcol = 30, updt_list_cnt = size(temp->updated_prsnl,5)
     IF (updt_list_cnt > 0)
      font_string = concat("{f/0}{cpi/",trim(cnvtstring(m_cpi)),"}{lpi/",trim(cnvtstring(m_lpi)),"}"),
      font_string, row + 1
      IF (ycol >= bottom)
       BREAK
      ENDIF
      soutput = build("{b}{u}",captions->supdatedon,"{endu}{endb}"),
      CALL addtooutput(build(soutput,"<br>")),
      CALL print(calcpos(xcol,ycol)),
      soutput, row + 1
      IF (ycol >= bottom)
       BREAK
      ENDIF
      ycol += font_size, xcol = 50
      FOR (updt_cnt = 1 TO updt_list_cnt)
       reverse_cnt = ((updt_list_cnt - updt_cnt)+ 1),
       FOR (line_cnt = 1 TO size(temp->updated_prsnl[reverse_cnt].update_qual,5))
         IF (ycol >= bottom)
          BREAK
         ENDIF
         soutput = temp->updated_prsnl[reverse_cnt].update_qual[line_cnt].update_wrap_str,
         CALL addtooutput(build(soutput,"<br>")),
         CALL print(calcpos(xcol,ycol)),
         soutput, row + 1
         IF (ycol >= bottom)
          BREAK
         ENDIF
         ycol += font_size
       ENDFOR
      ENDFOR
     ENDIF
     FOR (x = 1 TO temp->sect_cnt)
       xcol = 30
       IF ((temp->sl[x].ind=1))
        sectionstring = fillstring(200," "), thead = concat("{color/19}{b}",temp->sl[x].description,
         " (",captions->scont,")",
         sectionstring), sectionstring = concat(temp->sl[x].description,sectionstring),
        font_string = concat("{f/0}{cpi/",trim(cnvtstring(sectheader_font_cpi)),"}{lpi/",trim(
          cnvtstring(sectheader_font_lpi)),"}"), font_string, row + 1
        IF (ycol >= bottom)
         BREAK
        ENDIF
        soutput = build("{b}",sectionstring,"{endb}"),
        CALL addtooutput(build(soutput,"<br>")),
        CALL print(calcpos(xcol,ycol)),
        "{color/19}{b}", sectionstring, "{endb} {color/0}",
        row + 1
        IF (ycol >= bottom)
         BREAK
        ENDIF
        ycol += sectheader_font_size
        FOR (y = 1 TO temp->sl[x].input_cnt)
          font_string = concat("{f/0}{cpi/",trim(cnvtstring(m_cpi)),"}{lpi/",trim(cnvtstring(m_lpi)),
           "}"), font_string, row + 1
          IF ((temp->sl[x].il[y].input_type IN (22, 2, 4, 6, 7,
          9, 10, 13, 18, 23))
           AND trim(temp->sl[x].il[y].module)=" ")
           IF ((temp->sl[x].il[y].ind=1))
            xcol = 30
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build("{b}",temp->sl[x].il[y].description,": {endb}",temp->sl[x].il[y].
             list_tag[1].list_line),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1
            IF (ycol >= bottom)
             BREAK
            ENDIF
            ycol += font_size
            FOR (z = 2 TO temp->sl[x].il[y].list_ln_cnt)
              xcol = 35
              IF (ycol >= bottom)
               BREAK
              ENDIF
              soutput = temp->sl[x].il[y].list_tag[z].list_line,
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)),
              soutput, row + 1
              IF (ycol >= bottom)
               BREAK
              ENDIF
              ycol += font_size
            ENDFOR
            IF ((temp->sl[x].il[y].note_ind=1))
             FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
               xcol = 35
               IF (ycol >= bottom)
                BREAK
               ENDIF
               soutput = temp->sl[x].il[y].note_qual[w].note_line,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1
               IF (ycol >= bottom)
                BREAK
               ENDIF
               ycol += font_size
             ENDFOR
            ENDIF
           ENDIF
          ENDIF
          IF ((temp->sl[x].il[y].input_type=5))
           IF ((temp->sl[x].il[y].ind=1))
            xcol = 30
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build("{b}",temp->sl[x].il[y].description,"{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1
            IF (ycol >= bottom)
             BREAK
            ENDIF
            ycol += font_size
            FOR (z = 1 TO temp->sl[x].il[y].cnt)
              xcol = 55
              IF (ycol >= bottom)
               BREAK
              ENDIF
              label_str = substring(1,max_grid_length,temp->sl[x].il[y].qual[z].label), soutput =
              build("{b}",label_str,"{endb}"),
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput, row + 1
              FOR (w = 1 TO temp->sl[x].il[y].qual[z].list_ln_cnt)
                xcol = 180
                IF (ycol >= bottom)
                 BREAK
                ENDIF
                soutput = temp->sl[x].il[y].qual[z].list_tag[w].list_line,
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)),
                soutput, row + 1
                IF (ycol >= bottom)
                 BREAK
                ENDIF
                ycol += font_size
              ENDFOR
              IF (ycol >= bottom)
               BREAK, ycol += font_size
              ENDIF
            ENDFOR
            IF ((temp->sl[x].il[y].note_ind=1))
             FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
               xcol = 35
               IF (ycol >= bottom)
                BREAK
               ENDIF
               soutput = temp->sl[x].il[y].note_qual[w].note_line,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1
               IF (ycol >= bottom)
                BREAK
               ENDIF
               ycol += font_size
             ENDFOR
            ENDIF
           ENDIF
          ENDIF
          IF ((temp->sl[x].il[y].input_type=15))
           FOR (p = 1 TO temp->sl[x].il[y].grid_cnt)
             IF ((temp->sl[x].il[y].grid_qual[p].ind=1))
              IF (p=1)
               xcol = 30
               IF (ycol >= bottom)
                BREAK
               ENDIF
               soutput = build("{b}",temp->sl[x].il[y].label,"{endb}"),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1
               IF (ycol >= bottom)
                BREAK
               ENDIF
               ycol += font_size
              ENDIF
              IF (mod(p,3)=1)
               temp_y_col = ycol
               IF ((temp->sl[x].il[y].grid_cnt > p))
                comment_line_cnt = temp->sl[x].il[y].grid_qual[p].list_ln_cnt
                IF ((temp->sl[x].il[y].grid_cnt > (p+ 1)))
                 comment_line_cnt = maxval(temp->sl[x].il[y].grid_qual[p].list_ln_cnt,temp->sl[x].il[
                  y].grid_qual[(p+ 1)].list_ln_cnt,temp->sl[x].il[y].grid_qual[(p+ 2)].list_ln_cnt)
                ELSE
                 comment_line_cnt = maxval(temp->sl[x].il[y].grid_qual[p].list_ln_cnt,temp->sl[x].il[
                  y].grid_qual[(p+ 1)].list_ln_cnt)
                ENDIF
               ELSE
                comment_line_cnt = temp->sl[x].il[y].grid_qual[p].list_ln_cnt
               ENDIF
               comment_y_col = (ycol+ (comment_line_cnt * font_size))
               IF ((temp->sl[x].il[y].grid_cnt > p))
                IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
                 end_y_col = (comment_y_col+ (temp->sl[x].il[y].grid_qual[p].note_cnt * font_size))
                 IF ((temp->sl[x].il[y].grid_cnt > (p+ 1)))
                  end_y_col = (comment_y_col+ (maxval(temp->sl[x].il[y].grid_qual[p].note_cnt,temp->
                   sl[x].il[y].grid_qual[(p+ 1)].note_cnt,temp->sl[x].il[y].grid_qual[(p+ 2)].
                   note_cnt) * font_size))
                 ELSE
                  end_y_col = (comment_y_col+ (maxval(temp->sl[x].il[y].grid_qual[p].note_cnt,temp->
                   sl[x].il[y].grid_qual[(p+ 1)].note_cnt) * font_size))
                 ENDIF
                ELSE
                 end_y_col = (comment_y_col+ (temp->sl[x].il[y].grid_qual[p].note_cnt * font_size))
                ENDIF
               ELSE
                end_y_col = comment_y_col
               ENDIF
               IF (end_y_col >= bottom)
                BREAK, ycol += font_size, temp_y_col = ycol,
                comment_y_col = (ycol+ (comment_line_cnt * font_size))
               ENDIF
               xcol = 55
               IF (ycol >= bottom)
                BREAK
               ENDIF
               label_str = substring(1,max_grid_length,temp->sl[x].il[y].grid_qual[p].label), soutput
                = build("{b}",label_str,"{endb}"),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1
              ELSE
               ycol = temp_y_col
              ENDIF
              FOR (z = 1 TO temp->sl[x].il[y].grid_qual[p].list_ln_cnt)
                IF (mod(p,3)=0)
                 xcol = 430
                ELSEIF (mod(p,3)=1)
                 xcol = 180
                ELSE
                 xcol = 305
                ENDIF
                IF (ycol >= bottom)
                 BREAK
                ENDIF
                soutput = temp->sl[x].il[y].grid_qual[p].list_tag[z].list_line,
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)),
                soutput, row + 1
                IF (ycol >= bottom)
                 BREAK
                ENDIF
                ycol += font_size
              ENDFOR
              ycol = comment_y_col
              IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
               FOR (w = 1 TO temp->sl[x].il[y].grid_qual[p].note_cnt)
                 IF (mod(p,3)=0)
                  xcol = 430
                 ELSEIF (mod(p,3)=1)
                  xcol = 180
                 ELSE
                  xcol = 305
                 ENDIF
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
                 soutput = temp->sl[x].il[y].grid_qual[p].note_qual[w].note_line,
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)),
                 soutput, row + 1
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
                 ycol += font_size
               ENDFOR
              ENDIF
              IF (ycol >= bottom)
               BREAK, ycol += font_size
              ENDIF
             ENDIF
           ENDFOR
           IF ((temp->sl[x].il[y].note_ind=1))
            FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
              xcol = 35
              IF (ycol >= bottom)
               BREAK
              ENDIF
              soutput = temp->sl[x].il[y].note_qual[w].note_line,
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)),
              soutput, row + 1
              IF (ycol >= bottom)
               BREAK
              ENDIF
              ycol += font_size
            ENDFOR
           ENDIF
          ENDIF
          IF ((temp->sl[x].il[y].input_type=14))
           FOR (p = 1 TO temp->sl[x].il[y].grid_cnt)
            IF ((temp->sl[x].il[y].grid_qual[p].ind=1))
             IF (p=1)
              xcol = 30
              IF (ycol >= bottom)
               BREAK
              ENDIF
              soutput = build("{b}",temp->sl[x].il[y].label,"{endb}"),
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)),
              soutput, row + 1
              IF (ycol >= bottom)
               BREAK
              ENDIF
              ycol += font_size
             ENDIF
             xcol = 55
             IF (ycol >= bottom)
              BREAK
             ENDIF
             soutput = build("{b}",temp->sl[x].il[y].grid_qual[p].label," {endb}",temp->sl[x].il[y].
              grid_qual[p].list_tag[1].list_line),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1
             IF (ycol >= bottom)
              BREAK
             ENDIF
             ycol += font_size
             FOR (z = 2 TO temp->sl[x].il[y].grid_qual[p].list_ln_cnt)
               xcol = 65
               IF (ycol >= bottom)
                BREAK
               ENDIF
               soutput = temp->sl[x].il[y].grid_qual[p].list_tag[z].list_line,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1
               IF (ycol >= bottom)
                BREAK
               ENDIF
               ycol += font_size
             ENDFOR
             IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
              FOR (w = 1 TO temp->sl[x].il[y].grid_qual[p].note_cnt)
                xcol = 65
                IF (ycol >= bottom)
                 BREAK
                ENDIF
                soutput = temp->sl[x].il[y].grid_qual[p].note_qual[w].note_line,
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)),
                soutput, row + 1
                IF (ycol >= bottom)
                 BREAK
                ENDIF
                ycol += font_size
              ENDFOR
             ENDIF
            ENDIF
            ,
            IF (ycol >= bottom)
             BREAK, ycol += font_size
            ENDIF
           ENDFOR
           IF ((temp->sl[x].il[y].note_ind=1))
            FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
              xcol = 55
              IF (ycol >= bottom)
               BREAK
              ENDIF
              soutput = temp->sl[x].il[y].note_qual[w].note_line,
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)),
              soutput, row + 1
              IF (ycol >= bottom)
               BREAK
              ENDIF
              ycol += font_size
            ENDFOR
           ENDIF
          ENDIF
          IF ((temp->sl[x].il[y].input_type IN (17, 19)))
           FOR (p = 1 TO temp->sl[x].il[y].grid_cnt)
             IF (p=1)
              xcol = 30
              IF (ycol >= bottom)
               BREAK
              ENDIF
              soutput = build("{b}",temp->sl[x].il[y].description,"{endb}"),
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)),
              soutput, row + 1
              IF (ycol >= bottom)
               BREAK
              ENDIF
              ycol += font_size
             ENDIF
             IF (mod(p,3)=1)
              stat = alterlist(qual_seqs->seqs,temp->sl[x].il[y].grid_qual[p].cnt)
              FOR (q = 1 TO temp->sl[x].il[y].grid_qual[p].cnt)
                qual_seqs->seqs[q].seq = temp->sl[x].il[y].grid_qual[p].qual[q].collating_seq
              ENDFOR
              IF ((temp->sl[x].il[y].grid_cnt > p))
               FOR (q = 1 TO temp->sl[x].il[y].grid_qual[(p+ 1)].cnt)
                 seq_found_ind = 0
                 FOR (r = 1 TO size(qual_seqs->seqs,5))
                   IF ((temp->sl[x].il[y].grid_qual[(p+ 1)].qual[q].collating_seq=qual_seqs->seqs[r].
                   seq))
                    seq_found_ind = 1
                   ENDIF
                 ENDFOR
                 IF (seq_found_ind=0)
                  stat = alterlist(qual_seqs->seqs,(size(qual_seqs->seqs,5)+ 1)), qual_seqs->seqs[
                  size(qual_seqs->seqs,5)].seq = temp->sl[x].il[y].grid_qual[(p+ 1)].qual[q].
                  collating_seq
                 ENDIF
               ENDFOR
              ENDIF
              IF ((temp->sl[x].il[y].grid_cnt > (p+ 1)))
               FOR (q = 1 TO temp->sl[x].il[y].grid_qual[(p+ 2)].cnt)
                 seq_found_ind = 0
                 FOR (r = 1 TO size(qual_seqs->seqs,5))
                   IF ((temp->sl[x].il[y].grid_qual[(p+ 2)].qual[q].collating_seq=qual_seqs->seqs[r].
                   seq))
                    seq_found_ind = 1
                   ENDIF
                 ENDFOR
                 IF (seq_found_ind=0)
                  stat = alterlist(qual_seqs->seqs,(size(qual_seqs->seqs,5)+ 1)), qual_seqs->seqs[
                  size(qual_seqs->seqs,5)].seq = temp->sl[x].il[y].grid_qual[(p+ 2)].qual[q].
                  collating_seq
                 ENDIF
               ENDFOR
              ENDIF
              IF ((temp->sl[x].il[y].input_type=19))
               tempycol = ycol, maxycol = temp->sl[x].il[y].grid_qual[p].label_ln_cnt
               IF ((temp->sl[x].il[y].grid_cnt >= (p+ 1)))
                maxycol = maxval(maxycol,temp->sl[x].il[y].grid_qual[(p+ 1)].label_ln_cnt)
               ENDIF
               IF ((temp->sl[x].il[y].grid_cnt >= (p+ 2)))
                maxycol = maxval(maxycol,temp->sl[x].il[y].grid_qual[(p+ 2)].label_ln_cnt)
               ENDIF
               xcol = 180
               FOR (z = 1 TO temp->sl[x].il[y].grid_qual[p].label_ln_cnt)
                 soutput = build("{b}",temp->sl[x].il[y].grid_qual[p].label_list_tag[z].
                  label_list_line,"{endb}"),
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)),
                 soutput, row + 1
                 IF ((z < temp->sl[x].il[y].grid_qual[p].label_ln_cnt))
                  ycol += font_size
                 ENDIF
               ENDFOR
               ycol = tempycol
               IF ((temp->sl[x].il[y].grid_cnt > p))
                xcol = 305
                FOR (z = 1 TO temp->sl[x].il[y].grid_qual[(p+ 1)].label_ln_cnt)
                  soutput = build("{b}",temp->sl[x].il[y].grid_qual[(p+ 1)].label_list_tag[z].
                   label_list_line,"{endb}"),
                  CALL addtooutput(build(soutput,"<br>")),
                  CALL print(calcpos(xcol,ycol)),
                  soutput, row + 1
                  IF ((z < temp->sl[x].il[y].grid_qual[(p+ 1)].label_ln_cnt))
                   ycol += font_size
                  ENDIF
                ENDFOR
                ycol = tempycol
               ENDIF
               IF ((temp->sl[x].il[y].grid_cnt > (p+ 1)))
                xcol = 430
                FOR (z = 1 TO temp->sl[x].il[y].grid_qual[(p+ 2)].label_ln_cnt)
                  soutput = build("{b}",temp->sl[x].il[y].grid_qual[(p+ 2)].label_list_tag[z].
                   label_list_line,"{endb}"),
                  CALL addtooutput(build(soutput,"<br>")),
                  CALL print(calcpos(xcol,ycol)),
                  soutput, row + 1
                  IF ((z < temp->sl[x].il[y].grid_qual[(p+ 2)].label_ln_cnt))
                   ycol += font_size
                  ENDIF
                ENDFOR
               ENDIF
               IF (ycol >= bottom)
                BREAK
               ENDIF
               ycol = (tempycol+ (font_size * maxycol))
              ENDIF
              IF (size(qual_seqs->seqs,5) > 0)
               next_insert_val = 0, last_insert_val = 0, stat = alterlist(sorted_qual_seqs->seqs,size
                (qual_seqs->seqs,5))
               FOR (q = 1 TO size(qual_seqs->seqs,5))
                 FOR (r = 1 TO size(qual_seqs->seqs,5))
                   IF ((qual_seqs->seqs[r].seq > last_insert_val)
                    AND ((next_insert_val=0) OR ((qual_seqs->seqs[r].seq < next_insert_val))) )
                    next_insert_val = qual_seqs->seqs[r].seq
                   ENDIF
                 ENDFOR
                 sorted_qual_seqs->seqs[q].seq = next_insert_val, last_insert_val = next_insert_val,
                 next_insert_val = 0
               ENDFOR
               FOR (q = 1 TO size(sorted_qual_seqs->seqs,5))
                 first_index = 0, second_index = 0, third_index = 0
                 FOR (r = 1 TO temp->sl[x].il[y].grid_qual[p].cnt)
                   IF ((temp->sl[x].il[y].grid_qual[p].qual[r].collating_seq=sorted_qual_seqs->seqs[q
                   ].seq))
                    first_index = r
                   ENDIF
                 ENDFOR
                 IF ((temp->sl[x].il[y].grid_cnt > p))
                  FOR (r = 1 TO temp->sl[x].il[y].grid_qual[(p+ 1)].cnt)
                    IF ((temp->sl[x].il[y].grid_qual[(p+ 1)].qual[r].collating_seq=sorted_qual_seqs->
                    seqs[q].seq))
                     second_index = r
                    ENDIF
                  ENDFOR
                 ENDIF
                 IF ((temp->sl[x].il[y].grid_cnt > (p+ 1)))
                  FOR (r = 1 TO temp->sl[x].il[y].grid_qual[(p+ 2)].cnt)
                    IF ((temp->sl[x].il[y].grid_qual[(p+ 2)].qual[r].collating_seq=sorted_qual_seqs->
                    seqs[q].seq))
                     third_index = r
                    ENDIF
                  ENDFOR
                 ENDIF
                 next_line_cnt = 0
                 IF (first_index > 0)
                  next_line_cnt = temp->sl[x].il[y].grid_qual[p].qual[first_index].list_ln_cnt
                 ENDIF
                 IF (second_index > 0)
                  IF ((temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].list_ln_cnt >
                  next_line_cnt))
                   next_line_cnt = temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].list_ln_cnt
                  ENDIF
                 ENDIF
                 IF (third_index > 0)
                  IF ((temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].list_ln_cnt >
                  next_line_cnt))
                   next_line_cnt = temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].list_ln_cnt
                  ENDIF
                 ENDIF
                 next_y_col = (ycol+ (next_line_cnt * font_size))
                 IF (next_y_col >= bottom)
                  BREAK, ycol += font_size, temp_y_col = ycol,
                  next_y_col = (ycol+ (next_line_cnt * font_size))
                 ENDIF
                 xcol = 55
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
                 temp_y_col = ycol
                 IF (first_index > 0)
                  FOR (z = 1 TO temp->sl[x].il[y].grid_qual[p].qual[first_index].label_ln_cnt)
                    label_str = build("{b}",temp->sl[x].il[y].grid_qual[p].qual[first_index].
                     label_list_tag[z].label_list_line,"{endb}"),
                    CALL addtooutput(build(label_str,"<br>")),
                    CALL print(calcpos(xcol,ycol)),
                    label_str, row + 1
                    IF ((z < temp->sl[x].il[y].grid_qual[p].qual[first_index].label_ln_cnt))
                     ycol += font_size
                    ENDIF
                  ENDFOR
                 ELSEIF (second_index > 0)
                  FOR (z = 1 TO temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].label_ln_cnt)
                    label_str = build("{b}",temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].
                     label_list_tag[z].label_list_line,"{endb}"),
                    CALL addtooutput(build(label_str,"<br>")),
                    CALL print(calcpos(xcol,ycol)),
                    label_str, row + 1
                    IF ((z < temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].label_ln_cnt))
                     ycol += font_size
                    ENDIF
                  ENDFOR
                 ELSEIF (third_index > 0)
                  FOR (z = 1 TO temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].label_ln_cnt)
                    label_str = build("{b}",temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].
                     label_list_tag[z].label_list_line,"{endb}"),
                    CALL addtooutput(build(label_str,"<br>")),
                    CALL print(calcpos(xcol,ycol)),
                    label_str, row + 1
                    IF ((z < temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].label_ln_cnt))
                     ycol += font_size
                    ENDIF
                  ENDFOR
                 ENDIF
                 temp_y_col = ycol, ycolr1 = ycol, ycolr2 = ycol,
                 ycolr3 = ycol, next_y_col = ycol
                 IF (first_index > 0)
                  FOR (z = 1 TO temp->sl[x].il[y].grid_qual[p].qual[first_index].list_ln_cnt)
                    xcol = 180, soutput = temp->sl[x].il[y].grid_qual[p].qual[first_index].list_tag[z
                    ].list_line,
                    CALL addtooutput(build(soutput,"<br>")),
                    CALL print(calcpos(xcol,ycolr1)), soutput, row + 1,
                    ycolr1 += font_size
                  ENDFOR
                 ENDIF
                 IF (second_index > 0)
                  xcol = 305, ycolr2 = temp_y_col
                  FOR (z = 1 TO temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].list_ln_cnt)
                    soutput = temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].list_tag[z].
                    list_line,
                    CALL addtooutput(build(soutput,"<br>")),
                    CALL print(calcpos(xcol,ycolr2)),
                    soutput, row + 1, ycolr2 += font_size
                  ENDFOR
                 ENDIF
                 IF (third_index > 0)
                  xcol = 430, ycolr3 = temp_y_col
                  FOR (z = 1 TO temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].list_ln_cnt)
                    soutput = temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].list_tag[z].
                    list_line,
                    CALL addtooutput(build(soutput,"<br>")),
                    CALL print(calcpos(xcol,ycolr3)),
                    soutput, row + 1, ycolr3 += font_size
                  ENDFOR
                 ENDIF
                 maxycol = temp->sl[x].il[y].grid_qual[p].qual[first_index].list_ln_cnt
                 IF ((temp->sl[x].il[y].grid_cnt >= (p+ 1)))
                  maxycol = maxval(maxycol,temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].
                   list_ln_cnt)
                 ENDIF
                 IF ((temp->sl[x].il[y].grid_cnt >= (p+ 2)))
                  maxycol = maxval(maxycol,temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].
                   list_ln_cnt)
                 ENDIF
                 next_y_col += (maxycol * font_size), ycol = next_y_col, next_line_cnt = 0
                 IF (first_index > 0)
                  IF ((temp->sl[x].il[y].grid_qual[p].qual[first_index].note_ind=1))
                   next_line_cnt = temp->sl[x].il[y].grid_qual[p].qual[first_index].note_cnt
                  ENDIF
                 ENDIF
                 IF (second_index > 0)
                  IF ((temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].note_ind=1)
                   AND (temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].note_cnt >
                  next_line_cnt))
                   next_line_cnt = temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].note_cnt
                  ENDIF
                 ENDIF
                 IF (third_index > 0)
                  IF ((temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].note_ind=1)
                   AND (temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].note_cnt >
                  next_line_cnt))
                   next_line_cnt = temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].note_cnt
                  ENDIF
                 ENDIF
                 next_y_col = (ycol+ (next_line_cnt * font_size))
                 IF (next_y_col >= bottom)
                  BREAK, ycol += font_size, next_y_col = (ycol+ (next_line_cnt * font_size))
                 ENDIF
                 temp_y_col = ycol
                 IF (first_index > 0)
                  IF ((temp->sl[x].il[y].grid_qual[p].qual[first_index].note_ind=1))
                   FOR (w = 1 TO temp->sl[x].il[y].grid_qual[p].qual[first_index].note_cnt)
                     xcol = 180, soutput = temp->sl[x].il[y].grid_qual[p].qual[first_index].
                     note_qual[w].note_line,
                     CALL addtooutput(build(soutput,"<br>")),
                     CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                     ycol += font_size
                   ENDFOR
                  ENDIF
                 ENDIF
                 IF (second_index > 0)
                  IF ((temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].note_ind=1))
                   xcol = 305, ycol = temp_y_col
                   FOR (w = 1 TO temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].note_cnt)
                     soutput = temp->sl[x].il[y].grid_qual[(p+ 1)].qual[second_index].note_qual[w].
                     note_line,
                     CALL addtooutput(build(soutput,"<br>")),
                     CALL print(calcpos(xcol,ycol)),
                     soutput, row + 1, ycol += font_size
                   ENDFOR
                  ENDIF
                 ENDIF
                 IF (third_index > 0)
                  IF ((temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].note_ind=1))
                   xcol = 430, ycol = temp_y_col
                   FOR (w = 1 TO temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].note_cnt)
                     soutput = temp->sl[x].il[y].grid_qual[(p+ 2)].qual[third_index].note_qual[w].
                     note_line,
                     CALL addtooutput(build(soutput,"<br>")),
                     CALL print(calcpos(xcol,ycol)),
                     soutput, row + 1, ycol += font_size
                   ENDFOR
                  ENDIF
                 ENDIF
                 ycol = next_y_col
               ENDFOR
              ENDIF
              IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
               next_line_cnt = temp->sl[x].il[y].grid_qual[p].note_cnt
              ELSE
               next_line_cnt = 0
              ENDIF
              IF ((temp->sl[x].il[y].grid_cnt > p))
               IF ((temp->sl[x].il[y].grid_qual[(p+ 1)].note_ind=1)
                AND (temp->sl[x].il[y].grid_qual[(p+ 1)].note_cnt > next_line_cnt))
                next_line_cnt = temp->sl[x].il[y].grid_qual[(p+ 1)].note_cnt
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].grid_cnt > (p+ 1)))
               IF ((temp->sl[x].il[y].grid_qual[(p+ 2)].note_ind=1)
                AND (temp->sl[x].il[y].grid_qual[(p+ 2)].note_cnt > next_line_cnt))
                next_line_cnt = temp->sl[x].il[y].grid_qual[(p+ 2)].note_cnt
               ENDIF
              ENDIF
              next_y_col = (ycol+ (next_line_cnt * font_size))
              IF (next_y_col >= bottom)
               BREAK, ycol += font_size, next_y_col = (ycol+ (next_line_cnt * font_size))
              ENDIF
              temp_y_col = ycol
              IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
               FOR (w = 1 TO temp->sl[x].il[y].grid_qual[p].note_cnt)
                 xcol = 180, soutput = temp->sl[x].il[y].grid_qual[p].note_qual[w].note_line,
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                 ycol += font_size
               ENDFOR
              ENDIF
              IF ((temp->sl[x].il[y].grid_cnt > p))
               IF ((temp->sl[x].il[y].grid_qual[(p+ 1)].note_ind=1))
                xcol = 305, ycol = temp_y_col
                FOR (w = 1 TO temp->sl[x].il[y].grid_qual[(p+ 1)].note_cnt)
                  soutput = temp->sl[x].il[y].grid_qual[(p+ 1)].note_qual[w].note_line,
                  CALL addtooutput(build(soutput,"<br>")),
                  CALL print(calcpos(xcol,ycol)),
                  soutput, row + 1, ycol += font_size
                ENDFOR
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].grid_cnt > (p+ 1)))
               IF ((temp->sl[x].il[y].grid_qual[(p+ 2)].note_ind=1))
                xcol = 430, ycol = temp_y_col
                FOR (w = 1 TO temp->sl[x].il[y].grid_qual[(p+ 2)].note_cnt)
                  soutput = temp->sl[x].il[y].grid_qual[(p+ 2)].note_qual[w].note_line,
                  CALL addtooutput(build(soutput,"<br>")),
                  CALL print(calcpos(xcol,ycol)),
                  soutput, row + 1, ycol += font_size
                ENDFOR
               ENDIF
              ENDIF
              ycol = next_y_col
             ENDIF
             IF (mod(p,3)=1)
              IF (ycol >= bottom)
               BREAK
              ENDIF
              ycol += font_size
             ENDIF
           ENDFOR
           IF ((temp->sl[x].il[y].note_ind=1))
            FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
              xcol = 35, soutput = temp->sl[x].il[y].note_qual[w].note_line,
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput, row + 1,
              ycol += font_size
            ENDFOR
            IF (ycol >= bottom)
             BREAK
            ENDIF
            ycol = ((ycol+ font_size)+ font_size)
           ELSE
            IF (ycol >= bottom)
             BREAK
            ENDIF
            ycol += font_size
           ENDIF
          ENDIF
          IF ((temp->sl[x].il[y].input_type=11))
           xcol = 30
           IF (ycol >= bottom)
            BREAK
           ENDIF
           soutput = build("{b}{u}",captions->sallergy,"{endu}{endb}"),
           CALL addtooutput(build(soutput,"<br>")),
           CALL print(calcpos(xcol,ycol)),
           soutput, row + 1, xcol = 180
           IF (ycol >= bottom)
            BREAK
           ENDIF
           soutput = build("{b}{u}",captions->sreaction,"{endu}{endb}"),
           CALL addtooutput(build(soutput,"<br>")),
           CALL print(calcpos(xcol,ycol)),
           soutput, row + 1
           IF (ycol >= bottom)
            BREAK
           ENDIF
           ycol += font_size
           IF ((temp->sl[x].il[y].allergy_restricted_ind=1))
            xcol = 30, soutput = build("{b}{u}",captions->sallallergiesnotview,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)), soutput, row + 1
            IF (ycol >= bottom)
             BREAK
            ENDIF
            ycol += font_size
           ENDIF
           FOR (z = 1 TO temp->sl[x].il[y].allergy_cnt)
             xcol = 30, acol = ycol
             FOR (w = 1 TO temp->sl[x].il[y].allergy_qual[z].alist_ln_cnt)
               soutput = temp->sl[x].il[y].allergy_qual[z].alist_tag[w].alist_line
               IF (w=1)
                soutput = build2(trim(cnvtstring(z)),captions->slnnumberchar," ",soutput)
               ELSE
                soutput = build2("   ",soutput)
               ENDIF
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,acol)), soutput,
               row + 1, acol += font_size
             ENDFOR
             xcol = 180, rcol = ycol
             FOR (v = 1 TO temp->sl[x].il[y].allergy_qual[z].reaction_cnt)
               FOR (w = 1 TO temp->sl[x].il[y].allergy_qual[z].reaction_qual[v].rlist_ln_cnt)
                 soutput = temp->sl[x].il[y].allergy_qual[z].reaction_qual[v].rlist_tag[w].rlist_line,
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,rcol)),
                 soutput, row + 1
                 IF (rcol >= bottom)
                  BREAK, xcol = 180
                 ENDIF
                 rcol += font_size
               ENDFOR
             ENDFOR
             ycol1 = maxval(rcol,acol), ycol = ycol1
             IF (ycol >= bottom)
              BREAK, ycol += font_size
             ENDIF
             IF ((temp->sl[x].il[y].allergy_qual[z].note_ind=1))
              FOR (w = 1 TO temp->sl[x].il[y].allergy_qual[z].note_cnt)
                FOR (v = 1 TO temp->sl[x].il[y].allergy_qual[z].note_qual[w].note_ln_cnt)
                  xcol = 180
                  IF (ycol >= bottom)
                   BREAK
                  ENDIF
                  soutput = temp->sl[x].il[y].allergy_qual[z].note_qual[w].nlist_tag[v].note_line,
                  CALL addtooutput(build(soutput,"<br>")),
                  CALL print(calcpos(xcol,ycol)),
                  soutput, row + 1, ycol += font_size
                ENDFOR
              ENDFOR
             ENDIF
           ENDFOR
           IF ((temp->sl[x].il[y].allergy_cnt=0))
            xcol = 45
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = captions->snoallergy,
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1
            IF (ycol >= bottom)
             BREAK
            ENDIF
            ycol += (2 * font_size)
           ENDIF
          ENDIF
          IF ((((temp->sl[x].il[y].input_type=1)) OR ((temp->sl[x].il[y].input_type=2)))
           AND (temp->sl[x].il[y].module="PVTRACKFORMS"))
           FOR (p = 1 TO temp->sl[x].il[y].cnt)
             IF (p=1)
              xcol = 30, soutput = build("{b}",temp->sl[x].il[y].description,"{endb}"),
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput, row + 1,
              ycol += font_size
             ENDIF
             xcol = 55, soutput = build("{b}",temp->sl[x].il[y].qual[p].label,"{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput, row + 1
             FOR (z = 1 TO temp->sl[x].il[y].qual[p].list_ln_cnt)
               xcol = 180, soutput = temp->sl[x].il[y].qual[p].list_tag[z].list_line,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
             ENDFOR
             IF (ycol >= bottom)
              BREAK
             ENDIF
             ycol += font_size
           ENDFOR
           IF ((temp->sl[x].il[y].note_ind=1))
            FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
              xcol = 180, soutput = temp->sl[x].il[y].note_qual[w].note_line,
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput, row + 1,
              ycol += font_size
            ENDFOR
           ENDIF
          ENDIF
          IF ((temp->sl[x].il[y].input_type=medprofile_control)
           AND (temp->sl[x].il[y].module="PFEXTCTRLS"))
           med_cnt = size(temp->sl[x].il[y].med_profile_qual,5)
           IF (((med_cnt > 0) OR ((temp->sl[x].il[y].med_profile_restricted_ind=1))) )
            font_string = concat("{f/0}{cpi/",trim(cnvtstring(m_cpi)),"}{lpi/",trim(cnvtstring(m_lpi)
              ),"}"), font_string, row + 1,
            xcol = 30
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build("{b}{u}",captions->shomemeds,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1
            IF (ycol >= bottom)
             BREAK
            ENDIF
            ycol += font_size
            IF ((temp->sl[x].il[y].med_profile_restricted_ind=1))
             soutput = build("{b}{u}",captions->sallmedsnotview,"{endu}{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1
             IF (ycol >= bottom)
              BREAK
             ENDIF
             ycol += font_size
            ENDIF
            FOR (med_ind = 1 TO med_cnt)
              xcol = 30, tempycol = ycol
              FOR (line = 1 TO size(temp->sl[x].il[y].med_profile_qual[med_ind].hna_order_tag_list,5)
               )
                soutput = temp->sl[x].il[y].med_profile_qual[med_ind].hna_order_tag_list[line].
                order_tag,
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)),
                soutput, row + 1
                IF (ycol >= bottom)
                 BREAK
                ENDIF
                ycol += font_size
              ENDFOR
            ENDFOR
           ENDIF
          ENDIF
          IF ((temp->sl[x].il[y].input_type=1)
           AND (temp->sl[x].il[y].module="PFPMCtrls"))
           gest_ind = 1, soutput = build("{b}",captions->sgestationage,"{endb}",": ",temp->sl[x].il[y
            ].gestational[gest_ind].gest_age_concat),
           CALL addtooutput(build(soutput,"<br>")),
           CALL print(calcpos(xcol,ycol)), soutput
           IF (ycol >= bottom)
            BREAK
           ENDIF
           ycol += font_size, xcol = 30, soutput = build("{b}",captions->sgestationmethod,"{endb}",
            ": ",temp->sl[x].il[y].gestational[gest_ind].gest_age_method),
           CALL addtooutput(build(soutput,"<br>")),
           CALL print(calcpos(xcol,ycol)), soutput,
           row + 1
           IF (ycol >= bottom)
            BREAK
           ENDIF
           ycol += font_size, xcol = 30, soutput = build("{b}",captions->sgestationcomment,"{endb}",
            ": "),
           CALL addtooutput(build(soutput,"<br>")),
           CALL print(calcpos(xcol,ycol)), soutput,
           row + 1
           IF (ycol >= bottom)
            BREAK
           ENDIF
           xcol = 165
           FOR (line = 1 TO size(temp->sl[x].il[y].gestational[gest_ind].gest_tag,5))
             soutput = temp->sl[x].il[y].gestational[gest_ind].gest_tag[line].gest_line,
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1, ycol += font_size
           ENDFOR
          ENDIF
          IF ((temp->sl[x].il[y].input_type=2)
           AND (temp->sl[x].il[y].module="PFPMCtrls"))
           FOR (trck_ind = 1 TO size(temp->sl[x].il[y].tracking_cmt,5))
             IF ((temp->sl[x].il[y].tracking_cmt[trck_ind].tracking_comment != " "))
              xcol = 30, soutput = build("{b}",temp->sl[x].il[y].tracking_cmt[trck_ind].comment_lbl,
               "{endb}",": "),
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput, row + 1
              IF (ycol >= bottom)
               BREAK
              ENDIF
              xcol = 140
              FOR (line1 = 1 TO size(temp->sl[x].il[y].tracking_cmt[trck_ind].tracking_tag,5))
                soutput = temp->sl[x].il[y].tracking_cmt[trck_ind].tracking_tag[line1].tracking_line,
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)),
                soutput, row + 1, ycol += font_size
              ENDFOR
             ENDIF
           ENDFOR
          ENDIF
          IF ((temp->sl[x].il[y].input_type=problemdx_control)
           AND (temp->sl[x].il[y].module="PFEXTCTRLS"))
           prob_cnt = size(temp->sl[x].il[y].problem_list,5)
           IF (((prob_cnt > 0) OR ((temp->sl[x].il[y].problem_list_restricted_ind=1))) )
            font_string = concat("{f/0}{cpi/",trim(cnvtstring(m_cpi)),"}{lpi/",trim(cnvtstring(m_lpi)
              ),"}"), font_string, row + 1,
            xcol = 30
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build("{b}{u}",captions->sproblem,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1
            IF (ycol >= bottom)
             BREAK
            ENDIF
            ycol += font_size
            IF ((temp->sl[x].il[y].problem_list_restricted_ind=1))
             soutput = build("{b}{u}",captions->sallproblemsnotview,"{endu}{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1
             IF (ycol >= bottom)
              BREAK
             ENDIF
             ycol += font_size
            ENDIF
            FOR (prob_ind = 1 TO prob_cnt)
              xcol = 30, tempycol = ycol,
              CALL echo(build("ycol is:",ycol))
              FOR (line = 1 TO size(temp->sl[x].il[y].problem_list[prob_ind].problem_tag,5))
                soutput = build("{b}",temp->sl[x].il[y].problem_list[prob_ind].problem_tag[line].
                 problem_line,"{endb}"),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)),
                soutput, row + 1, ycol += font_size
              ENDFOR
              IF (ycol >= bottom)
               BREAK
              ENDIF
              IF ((temp->sl[x].il[y].problem_list[prob_ind].problem_recorder > " "))
               xcol = 45, soutput = captions->sproblemrecorder,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               xcol = 180, soutput = temp->sl[x].il[y].problem_list[prob_ind].problem_recorder,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
              ENDIF
              IF (ycol >= bottom)
               BREAK
              ENDIF
              IF ((temp->sl[x].il[y].problem_list[prob_ind].confirmation_disp > " "))
               xcol = 45, soutput = captions->sproblemconfirmation,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               xcol = 180, soutput = temp->sl[x].il[y].problem_list[prob_ind].confirmation_disp,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
              ENDIF
              IF (ycol >= bottom)
               BREAK
              ENDIF
              IF ((temp->sl[x].il[y].problem_list[prob_ind].qualifier_disp > " "))
               xcol = 45, soutput = captions->sproblemqualifier,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               xcol = 180, soutput = temp->sl[x].il[y].problem_list[prob_ind].qualifier_disp,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
              ENDIF
              IF ((temp->sl[x].il[y].problem_list[prob_ind].onset_dt_tm_str > " "))
               xcol = 45, soutput = captions->sproblemonsetdt,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               xcol = 180, soutput = temp->sl[x].il[y].problem_list[prob_ind].onset_dt_tm_str,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
              ENDIF
              IF ((temp->sl[x].il[y].problem_list[prob_ind].problem_status_disp > " "))
               xcol = 45, soutput = captions->sproblemstatus,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               xcol = 180, soutput = temp->sl[x].il[y].problem_list[prob_ind].problem_status_disp,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
              ENDIF
              IF (ycol >= bottom)
               BREAK
              ENDIF
            ENDFOR
           ENDIF
           dix_cnt = size(temp->sl[x].il[y].diagnosis,5)
           IF (dix_cnt > 0)
            font_string = concat("{f/0}{cpi/",trim(cnvtstring(m_cpi)),"}{lpi/",trim(cnvtstring(m_lpi)
              ),"}"), font_string, row + 1,
            xcol = 30
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build("{b}{u}",captions->sdx,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1
            IF (ycol >= bottom)
             BREAK
            ENDIF
            ycol += font_size
            FOR (dxind = 1 TO dix_cnt)
              xcol = 30
              FOR (line = 1 TO size(temp->sl[x].il[y].diagnosis[dxind].diagnosis_tag,5))
                soutput = build("{b}",temp->sl[x].il[y].diagnosis[dxind].diagnosis_tag[line].
                 diagnosis_line,"{endb}"),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)),
                soutput, row + 1
                IF (ycol >= bottom)
                 BREAK
                ENDIF
                ycol += font_size
              ENDFOR
              IF ((temp->sl[x].il[y].diagnosis[dxind].diagnosis_qualifier_disp > " "))
               xcol = 45
               IF (ycol >= bottom)
                BREAK
               ENDIF
               soutput = captions->sdxqualifier,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, xcol = 180
               IF (ycol >= bottom)
                BREAK
               ENDIF
               soutput = temp->sl[x].il[y].diagnosis[dxind].diagnosis_qualifier_disp,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1
               IF (ycol >= bottom)
                BREAK
               ENDIF
               ycol += font_size
              ENDIF
              IF ((temp->sl[x].il[y].diagnosis[dxind].diagnosis_confirmation_disp > " "))
               xcol = 45
               IF (ycol >= bottom)
                BREAK
               ENDIF
               soutput = captions->sdxconfirmation,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, xcol = 180,
               soutput = temp->sl[x].il[y].diagnosis[dxind].diagnosis_confirmation_disp,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
              ENDIF
              IF ((temp->sl[x].il[y].diagnosis[dxind].diagnosis_type_disp > " "))
               xcol = 45
               IF (ycol >= bottom)
                BREAK
               ENDIF
               soutput = captions->sdxtype,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, xcol = 180
               IF (ycol >= bottom)
                BREAK
               ENDIF
               soutput = temp->sl[x].il[y].diagnosis[dxind].diagnosis_type_disp,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1
               IF (ycol >= bottom)
                BREAK
               ENDIF
               ycol += font_size
              ENDIF
              IF ((temp->sl[x].il[y].diagnosis[dxind].diagnosis_onset_dtstr > " "))
               xcol = 45
               IF (ycol >= bottom)
                BREAK
               ENDIF
               soutput = captions->sdxonsetdttm,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, xcol = 180
               IF (ycol >= bottom)
                BREAK
               ENDIF
               soutput = temp->sl[x].il[y].diagnosis[dxind].diagnosis_onset_dtstr,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1
               IF (ycol >= bottom)
                BREAK
               ENDIF
               ycol += font_size
              ENDIF
            ENDFOR
           ENDIF
          ENDIF
          IF ((temp->sl[x].il[y].input_type=medlist_control)
           AND (temp->sl[x].il[y].module="PFEXTCTRLS"))
           medlist_cnt = size(temp->sl[x].il[y].med_list,5)
           IF (((medlist_cnt > 0) OR (size(temp->sl[x].il[y].order_compliance,5) > 0)) )
            font_string = concat("{f/0}{cpi/",trim(cnvtstring(m_cpi)),"}{lpi/",trim(cnvtstring(m_lpi)
              ),"}"), font_string, row + 1
            IF (ycol >= bottom)
             BREAK
            ENDIF
            xcol = 30, soutput = build("  ","  "),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)), soutput, row + 1,
            ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build("{b}{u}",captions->smedlist,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1, ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
           ENDIF
           IF (size(temp->sl[x].il[y].order_compliance,5) > 0)
            xcol = 40, soutput = build("  ","  "),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)), soutput, row + 1,
            ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build(captions->sordercompliance,": "),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1, ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
            IF ((temp->sl[x].il[y].order_compliance[1].unable_to_obtain_ind=1))
             soutput = build(captions->sunabletoobtain,"  ")
            ELSE
             soutput = build(captions->sobtained,"  ")
            ENDIF
            xcol = 50,
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1, ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
            IF ((temp->sl[x].il[y].order_compliance[1].no_known_home_meds_ind=1))
             soutput = build(captions->snoknownhomemeds,"   "),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
            ENDIF
            IF ((temp->sl[x].il[y].order_compliance[1].performed_by_name > ""))
             soutput = build(captions->sperformedby,": ",temp->sl[x].il[y].order_compliance[1].
              performed_by_name,";")
             IF ((temp->sl[x].il[y].order_compliance[1].performed_dt_tm_str > ""))
              soutput = concat(soutput,captions->sperformeddate,": ",temp->sl[x].il[y].
               order_compliance[1].performed_dt_tm_str)
             ENDIF
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput,
             row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
            ENDIF
           ENDIF
           IF (medlist_cnt > 0)
            IF (normalorder=1)
             xcol = 40, soutput = build("  ","  "),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput, row + 1,
             ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
             soutput = build("{b}{u}",captions->snormalorder,"{endu}{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
            ENDIF
            FOR (med_idx = 1 TO medlist_cnt)
             tempycol = ycol,
             IF ((temp->sl[x].il[y].med_list[med_idx].med_type_ind=1))
              IF (size(temp->sl[x].il[y].med_list[med_idx].name_lines,5) > 0)
               xcol = 40, soutput = build("  ","   "),
               CALL addtooutput(build(soutput,"   ","<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
               FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].name_lines,5))
                 xcol = 40, soutput = build(temp->sl[x].il[y].med_list[med_idx].name_lines[line].
                  name_line),
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                 ycol += font_size
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
               ENDFOR
              ENDIF
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].display_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].display_lines[line].
                 display_ln),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].comment_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].comment_lines[line].
                 comment_line),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              xcol = 50
              IF ((temp->sl[x].il[y].med_list[med_idx].provider_name > " "))
               soutput = build(captions->sprovider,": ",temp->sl[x].il[y].med_list[med_idx].
                provider_name),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_dt_tm_str > " "))
               soutput = build(captions->sdate,": ",temp->sl[x].il[y].med_list[med_idx].
                order_dt_tm_str),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_status > " "))
               soutput = build(captions->sstatus,": ",temp->sl[x].il[y].med_list[med_idx].
                order_status),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 2, ycol += font_size
              ENDIF
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
            ENDFOR
            IF (prescriptionorder=1)
             xcol = 40, soutput = build("  ","  "),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput, row + 1,
             ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
             soutput = build("{b}{u}",captions->sprescriptionorder,"{endu}{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
            ENDIF
            FOR (med_idx = 1 TO medlist_cnt)
             tempycol = ycol,
             IF ((temp->sl[x].il[y].med_list[med_idx].med_type_ind=2))
              IF (size(temp->sl[x].il[y].med_list[med_idx].name_lines,5) > 0)
               xcol = 40, soutput = build("  ","   "),
               CALL addtooutput(build(soutput,"   ","<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
               FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].name_lines,5))
                 xcol = 40, soutput = build(temp->sl[x].il[y].med_list[med_idx].name_lines[line].
                  name_line),
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                 ycol += font_size
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
               ENDFOR
              ENDIF
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].display_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].display_lines[line].
                 display_ln),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].comment_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].comment_lines[line].
                 comment_line),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              xcol = 50
              IF ((temp->sl[x].il[y].med_list[med_idx].provider_name > " "))
               soutput = build(captions->sprovider,": ",temp->sl[x].il[y].med_list[med_idx].
                provider_name),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_dt_tm_str > " "))
               soutput = build(captions->sdate,": ",temp->sl[x].il[y].med_list[med_idx].
                order_dt_tm_str),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_status > " "))
               soutput = build(captions->sstatus,": ",temp->sl[x].il[y].med_list[med_idx].
                order_status),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 2, ycol += font_size
              ENDIF
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
            ENDFOR
            IF (homemeds=1)
             xcol = 40, soutput = build("  ","  "),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput, row + 1,
             ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
             soutput = build("{b}{u}",captions->shomemeds,"{endu}{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
            ENDIF
            FOR (med_idx = 1 TO medlist_cnt)
             tempycol = ycol,
             IF ((temp->sl[x].il[y].med_list[med_idx].med_type_ind=3))
              IF (size(temp->sl[x].il[y].med_list[med_idx].name_lines,5) > 0)
               xcol = 40, soutput = build("  ","   "),
               CALL addtooutput(build(soutput,"   ","<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
               FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].name_lines,5))
                 xcol = 40, soutput = build(temp->sl[x].il[y].med_list[med_idx].name_lines[line].
                  name_line),
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                 ycol += font_size
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
               ENDFOR
              ENDIF
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].display_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].display_lines[line].
                 display_ln),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].comment_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].comment_lines[line].
                 comment_line),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              xcol = 50
              IF ((temp->sl[x].il[y].med_list[med_idx].provider_name > " "))
               soutput = build(captions->sprovider,": ",temp->sl[x].il[y].med_list[med_idx].
                provider_name),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_dt_tm_str > " "))
               soutput = build(captions->sdate,": ",temp->sl[x].il[y].med_list[med_idx].
                order_dt_tm_str),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_status > " "))
               soutput = build(captions->sstatus,": ",temp->sl[x].il[y].med_list[med_idx].
                order_status),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 2, ycol += font_size
              ENDIF
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
            ENDFOR
            IF (patientownsmeds=1)
             xcol = 40, soutput = build("  ","  "),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput, row + 1,
             ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
             soutput = build("{b}{u}",captions->spatientownsmeds,"{endu}{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
            ENDIF
            FOR (med_idx = 1 TO medlist_cnt)
             tempycol = ycol,
             IF ((temp->sl[x].il[y].med_list[med_idx].med_type_ind=4))
              IF (size(temp->sl[x].il[y].med_list[med_idx].name_lines,5) > 0)
               xcol = 40, soutput = build("  ","   "),
               CALL addtooutput(build(soutput,"   ","<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
               FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].name_lines,5))
                 xcol = 40, soutput = build(temp->sl[x].il[y].med_list[med_idx].name_lines[line].
                  name_line),
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                 ycol += font_size
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
               ENDFOR
              ENDIF
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].display_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].display_lines[line].
                 display_ln),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].comment_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].comment_lines[line].
                 comment_line),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              xcol = 50
              IF ((temp->sl[x].il[y].med_list[med_idx].provider_name > " "))
               soutput = build(captions->sprovider,": ",temp->sl[x].il[y].med_list[med_idx].
                provider_name),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_dt_tm_str > " "))
               soutput = build(captions->sdate,": ",temp->sl[x].il[y].med_list[med_idx].
                order_dt_tm_str),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_status > " "))
               soutput = build(captions->sstatus,": ",temp->sl[x].il[y].med_list[med_idx].
                order_status),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 2, ycol += font_size
              ENDIF
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
            ENDFOR
            IF (chargeonly=1)
             xcol = 40, soutput = build("  ","  "),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput, row + 1,
             ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
             soutput = build("{b}{u}",captions->schargeonly,"{endu}{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
            ENDIF
            FOR (med_idx = 1 TO medlist_cnt)
             tempycol = ycol,
             IF ((temp->sl[x].il[y].med_list[med_idx].med_type_ind=5))
              IF (size(temp->sl[x].il[y].med_list[med_idx].name_lines,5) > 0)
               xcol = 40, soutput = build("  ","   "),
               CALL addtooutput(build(soutput,"   ","<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
               FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].name_lines,5))
                 xcol = 40, soutput = build(temp->sl[x].il[y].med_list[med_idx].name_lines[line].
                  name_line),
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                 ycol += font_size
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
               ENDFOR
              ENDIF
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].display_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].display_lines[line].
                 display_ln),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].comment_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].comment_lines[line].
                 comment_line),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              xcol = 50
              IF ((temp->sl[x].il[y].med_list[med_idx].provider_name > " "))
               soutput = build(captions->sprovider,": ",temp->sl[x].il[y].med_list[med_idx].
                provider_name),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_dt_tm_str > " "))
               soutput = build(captions->sdate,": ",temp->sl[x].il[y].med_list[med_idx].
                order_dt_tm_str),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_status > " "))
               soutput = build(captions->sstatus,": ",temp->sl[x].il[y].med_list[med_idx].
                order_status),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 2, ycol += font_size
              ENDIF
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
            ENDFOR
            IF (satellitemeds=1)
             xcol = 40, soutput = build("  ","  "),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput, row + 1,
             ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
             soutput = build("{b}{u}",captions->ssatellitemeds,"{endu}{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
            ENDIF
            FOR (med_idx = 1 TO medlist_cnt)
             tempycol = ycol,
             IF ((temp->sl[x].il[y].med_list[med_idx].med_type_ind=6))
              IF (size(temp->sl[x].il[y].med_list[med_idx].name_lines,5) > 0)
               xcol = 40, soutput = build("  ","   "),
               CALL addtooutput(build(soutput,"   ","<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
               FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].name_lines,5))
                 xcol = 40, soutput = build(temp->sl[x].il[y].med_list[med_idx].name_lines[line].
                  name_line),
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                 ycol += font_size
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
               ENDFOR
              ENDIF
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].display_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].display_lines[line].
                 display_ln),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].comment_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].comment_lines[line].
                 comment_line),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              xcol = 50
              IF ((temp->sl[x].il[y].med_list[med_idx].provider_name > " "))
               soutput = build(captions->sprovider,": ",temp->sl[x].il[y].med_list[med_idx].
                provider_name),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_dt_tm_str > " "))
               soutput = build(captions->sdate,": ",temp->sl[x].il[y].med_list[med_idx].
                order_dt_tm_str),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_status > " "))
               soutput = build(captions->sstatus,": ",temp->sl[x].il[y].med_list[med_idx].
                order_status),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 2, ycol += font_size
              ENDIF
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
            ENDFOR
            IF (otherorder=1)
             xcol = 40, soutput = build("  ","  "),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput, row + 1,
             ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
             soutput = build("{b}{u}",captions->sotherorder,"{endu}{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
            ENDIF
            FOR (med_idx = 1 TO medlist_cnt)
             tempycol = ycol,
             IF ((temp->sl[x].il[y].med_list[med_idx].med_type_ind != 1)
              AND (temp->sl[x].il[y].med_list[med_idx].med_type_ind != 2)
              AND (temp->sl[x].il[y].med_list[med_idx].med_type_ind != 3)
              AND (temp->sl[x].il[y].med_list[med_idx].med_type_ind != 4)
              AND (temp->sl[x].il[y].med_list[med_idx].med_type_ind != 5)
              AND (temp->sl[x].il[y].med_list[med_idx].med_type_ind != 6))
              IF (size(temp->sl[x].il[y].med_list[med_idx].name_lines,5) > 0)
               xcol = 40, soutput = build("  ","   "),
               CALL addtooutput(build(soutput,"   ","<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
               FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].name_lines,5))
                 xcol = 40, soutput = build(temp->sl[x].il[y].med_list[med_idx].name_lines[line].
                  name_line),
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                 ycol += font_size
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
               ENDFOR
              ENDIF
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].display_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].display_lines[line].
                 display_ln),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].comment_lines,5))
                xcol = 50, soutput = trim(temp->sl[x].il[y].med_list[med_idx].comment_lines[line].
                 comment_line),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              xcol = 50
              IF ((temp->sl[x].il[y].med_list[med_idx].provider_name > " "))
               soutput = build(captions->sprovider,": ",temp->sl[x].il[y].med_list[med_idx].
                provider_name),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_dt_tm_str > " "))
               soutput = build(captions->sdate,": ",temp->sl[x].il[y].med_list[med_idx].
                order_dt_tm_str),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              IF ((temp->sl[x].il[y].med_list[med_idx].order_status > " "))
               soutput = build(captions->sstatus,": ",temp->sl[x].il[y].med_list[med_idx].
                order_status),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 2, ycol += font_size
              ENDIF
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
            ENDFOR
           ENDIF
          ENDIF
          IF ((temp->sl[x].il[y].input_type=pregnancyhistory_control)
           AND (temp->sl[x].il[y].module="PFEXTCTRLS"))
           preg_cnt = size(temp->sl[x].il[y].pregnancies,5), font_string = concat("{f/0}{cpi/",trim(
             cnvtstring(m_cpi)),"}{lpi/",trim(cnvtstring(m_lpi)),"}"), font_string,
           row + 1, xcol = 30
           IF (ycol >= bottom)
            BREAK
           ENDIF
           soutput = build("  ","  "),
           CALL addtooutput(build(soutput,"<br>")),
           CALL print(calcpos(xcol,ycol)),
           soutput, row + 1, ycol += font_size
           IF (ycol >= bottom)
            BREAK
           ENDIF
           soutput = build("{b}{u}",captions->spreghist,"{endu}{endb}"),
           CALL addtooutput(build(soutput,"<br>")),
           CALL print(calcpos(xcol,ycol)),
           soutput, row + 1, ycol += font_size
           IF (ycol >= bottom)
            BREAK
           ENDIF
           IF (preg_cnt <= 0
            AND size(temp->sl[x].il[y].gravida,5) <= 0
            AND (temp->sl[x].il[y].pregnancies_restricted_ind != 1))
            soutput = build("{b}{u}",captions->snopregnancy,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1
            IF (ycol >= bottom)
             BREAK
            ENDIF
            ycol += font_size
           ELSE
            IF (size(temp->sl[x].il[y].gravida,5) > 0)
             xcol = 40, soutput = build2("  ","  "),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput, row + 1,
             ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
             IF ((((temp->sl[x].il[y].gravida[1].gravida > 0)) OR ((((temp->sl[x].il[y].gravida[1].
             fullterm > 0)) OR ((((temp->sl[x].il[y].gravida[1].parapreterm > 0)) OR ((((temp->sl[x].
             il[y].gravida[1].aborted > 0)) OR ((temp->sl[x].il[y].gravida[1].living > 0))) )) )) ))
             )
              IF ((temp->sl[x].il[y].gravida[1].gravida > 0))
               gravidaval = cnvtstring(temp->sl[x].il[y].gravida[1].gravida)
              ENDIF
              IF ((temp->sl[x].il[y].gravida[1].fullterm > 0))
               fulltermval = cnvtstring(temp->sl[x].il[y].gravida[1].fullterm)
              ENDIF
              IF ((temp->sl[x].il[y].gravida[1].parapreterm > 0))
               parapretermval = cnvtstring(temp->sl[x].il[y].gravida[1].parapreterm)
              ENDIF
              IF ((temp->sl[x].il[y].gravida[1].aborted > 0))
               abortedval = cnvtstring(temp->sl[x].il[y].gravida[1].aborted)
              ENDIF
              IF ((temp->sl[x].il[y].gravida[1].living > 0))
               livingval = cnvtstring(temp->sl[x].il[y].gravida[1].living)
              ENDIF
              soutput = build2(captions->sgravida," - ",trim(gravidaval),";  ",captions->sparaterm,
               " - ",trim(fulltermval),";  ",captions->sparapreterm," - ",
               trim(parapretermval),";  ",captions->sabortions," - ",trim(abortedval),
               ";  ",captions->sliving," - ",trim(livingval),"."), xcol = 40,
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput, row + 1,
              ycol += font_size
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ELSE
              soutput = build("{b}{u}",captions->snogravida,"{endu}{endb}"),
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)),
              soutput, row + 1
              IF (ycol >= bottom)
               BREAK
              ENDIF
              ycol += font_size
             ENDIF
            ELSE
             soutput = build("{b}{u}",captions->snogravida,"{endu}{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1
             IF (ycol >= bottom)
              BREAK
             ENDIF
             ycol += font_size
            ENDIF
            IF ((temp->sl[x].il[y].pregnancies_restricted_ind=1))
             soutput = build("{b}{u}",captions->sallpregnanciesnotview,"{endu}{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1
             IF (ycol >= bottom)
              BREAK
             ENDIF
             ycol += font_size
            ENDIF
            FOR (preg_idx = 1 TO preg_cnt)
              xcol = 40, tempycol = ycol, soutput = build("  ","  "),
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput,
              row + 1, ycol += font_size
              IF (ycol >= bottom)
               BREAK
              ENDIF
              chld_cnt = size(temp->sl[x].il[y].pregnancies[preg_idx].child_list,5)
              FOR (chld_idx = 1 TO chld_cnt)
                xcol = 40, tempycol = ycol, soutput = build2("  ","  "),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput,
                row + 1, ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
                IF ((temp->sl[x].il[y].pregnancies[preg_idx].child_list[chld_idx].
                delivery_date_precision_flag=3))
                 IF ((temp->sl[x].il[y].pregnancies[preg_idx].auto_close_ind=0))
                  soutput = build2(captions->scloseddate,": ",temp->sl[x].il[y].pregnancies[preg_idx]
                   .preg_end_dt_tm_str)
                 ELSE
                  soutput = build2(captions->sautocloseddate,": ",temp->sl[x].il[y].pregnancies[
                   preg_idx].preg_end_dt_tm_str)
                 ENDIF
                ELSE
                 soutput = build2(captions->sdeliverydate,": ",temp->sl[x].il[y].pregnancies[preg_idx
                  ].child_list[chld_idx].delivery_dt_tm_str)
                ENDIF
                xcol = 40,
                CALL addtooutput(build2(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)),
                soutput, row + 1, ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
                linecnt = size(temp->sl[x].il[y].pregnancies[preg_idx].child_list[chld_idx].
                 data_str_lines,5)
                FOR (lineidx = 1 TO linecnt)
                  soutput = temp->sl[x].il[y].pregnancies[preg_idx].child_list[chld_idx].
                  data_str_lines[lineidx].aline, xcol = 55,
                  CALL addtooutput(build2(soutput,"<br>")),
                  CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                  ycol += font_size
                  IF (ycol >= bottom)
                   BREAK
                  ENDIF
                ENDFOR
              ENDFOR
            ENDFOR
           ENDIF
          ENDIF
          IF ((temp->sl[x].il[y].input_type=procedurehistory_control)
           AND (temp->sl[x].il[y].module="PFEXTCTRLS"))
           proc_cnt = size(temp->sl[x].il[y].proc_list,5)
           IF (((proc_cnt > 0) OR ((temp->sl[x].il[y].proc_list_restricted_ind=1))) )
            font_string = concat("{f/0}{cpi/",trim(cnvtstring(m_cpi)),"}{lpi/",trim(cnvtstring(m_lpi)
              ),"}"), font_string, row + 1,
            xcol = 30
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build2("  "),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1, ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build("{b}{u}",captions->sprochist,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1, ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
           ENDIF
           IF ((temp->sl[x].il[y].proc_list_restricted_ind=1))
            soutput = build("{b}{u}",captions->sallproceduresnotview,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1, ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
           ENDIF
           FOR (proc_idx = 1 TO proc_cnt)
             xcol = 45, tempycol = ycol, soutput = build2("  "),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput,
             row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
             FOR (line = 1 TO size(temp->sl[x].il[y].proc_list[proc_idx].proc_lines,5))
               soutput = build2(temp->sl[x].il[y].proc_list[proc_idx].proc_lines[line].proc_line),
               CALL addtooutput(build2(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
             ENDFOR
             FOR (line = 1 TO size(temp->sl[x].il[y].proc_list[proc_idx].perform_lines,5))
               xcol = 60, soutput = build2(temp->sl[x].il[y].proc_list[proc_idx].perform_lines[line].
                aline),
               CALL addtooutput(build2(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
             ENDFOR
             IF (trim(temp->sl[x].il[y].proc_list[proc_idx].age_at_proc) > "")
              xcol = 60, soutput = build2(captions->sonsetage,": ",trim(temp->sl[x].il[y].proc_list[
                proc_idx].age_at_proc)),
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput, row + 1,
              ycol += font_size
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
             cmnt_cnt = size(temp->sl[x].il[y].proc_list[proc_idx].comments,5)
             IF (cmnt_cnt > 0)
              xcol = 60, soutput = build2(captions->scomments,": "),
              CALL addtooutput(build2(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput, row + 1,
              ycol += font_size
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
             FOR (cmnt_idx = 1 TO cmnt_cnt)
               xcol = 70
               IF ((temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].comment_prsnl_name > "")
               )
                soutput = build2(temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].
                 comment_dt_tm_str," - ",temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].
                 comment_prsnl_name),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)),
                soutput, row + 1, ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
               ENDIF
               FOR (cmnt_line = 1 TO size(temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].
                comment_lines,5))
                 xcol = 70, soutput = temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].
                 comment_lines[cmnt_line].comment_line,
                 CALL addtooutput(build2(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                 ycol += font_size
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
               ENDFOR
               xcol = 70, soutput = build2("  "),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
             ENDFOR
           ENDFOR
          ENDIF
          IF ((temp->sl[x].il[y].input_type=pastmedhistory_control)
           AND (temp->sl[x].il[y].module="PFEXTCTRLS"))
           probcnt = size(temp->sl[x].il[y].past_prob_list,5)
           IF (((probcnt > 0) OR ((temp->sl[x].il[y].past_prob_list_restricted_ind=1))) )
            font_string = concat("{f/0}{cpi/",trim(cnvtstring(m_cpi)),"}{lpi/",trim(cnvtstring(m_lpi)
              ),"}"), font_string, row + 1,
            xcol = 30
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build2("  "),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1, ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build("{b}{u}",captions->spastmedhist,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1, ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
            IF ((temp->sl[x].il[y].past_prob_list_restricted_ind=1))
             soutput = build("{b}{u}",captions->sallpastmedsnotview,"{endu}{endb}"),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)),
             soutput, row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
            ENDIF
            FOR (probind = 1 TO probcnt)
              xcol = 45, tempycol = ycol, soutput = build2("  "),
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput,
              row + 1, ycol += font_size
              IF (ycol >= bottom)
               BREAK
              ENDIF
              FOR (line = 1 TO size(temp->sl[x].il[y].past_prob_list[probind].prob_lines,5))
                soutput = build(temp->sl[x].il[y].past_prob_list[probind].prob_lines[line].prob_line),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)),
                soutput, row + 1, ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
              ENDFOR
              soutput = ""
              IF (trim(temp->sl[x].il[y].past_prob_list[probind].onset_year) > "")
               soutput = build2(captions->sonsetyear," - ",trim(temp->sl[x].il[y].past_prob_list[
                 probind].onset_year),"; ")
              ENDIF
              IF (trim(temp->sl[x].il[y].past_prob_list[probind].onset_age) > "")
               soutput = build2(soutput,captions->sonsetage," -",trim(temp->sl[x].il[y].
                 past_prob_list[probind].onset_age))
              ENDIF
              IF (soutput > "")
               xcol = 60,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
              comt_cnt = size(temp->sl[x].il[y].past_prob_list[probind].comments,5)
              IF (comt_cnt > 0)
               xcol = 60, soutput = build(captions->scomments,": "),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
               FOR (comt_idx = 1 TO comt_cnt)
                 xcol = 75
                 IF ((temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].comment_prsnl_name
                  > ""))
                  soutput = build2(temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].
                   comment_dt_tm_str," - ",temp->sl[x].il[y].past_prob_list[probind].comments[
                   comt_idx].comment_prsnl_name),
                  CALL addtooutput(build(soutput,"<br>")),
                  CALL print(calcpos(xcol,ycol)),
                  soutput, row + 1, ycol += font_size
                  IF (ycol >= bottom)
                   BREAK
                  ENDIF
                 ENDIF
                 FOR (comt_line = 1 TO size(temp->sl[x].il[y].past_prob_list[probind].comments[
                  comt_idx].comment_lines,5))
                   soutput = build2(temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].
                    comment_lines[comt_line].comment_line),
                   CALL addtooutput(build2(soutput,"<br>")),
                   CALL print(calcpos(xcol,ycol)),
                   soutput, row + 1, ycol += font_size
                   IF (ycol >= bottom)
                    BREAK
                   ENDIF
                 ENDFOR
                 IF (comt_idx < comt_cnt)
                  soutput = build2("  "),
                  CALL addtooutput(build(soutput,"<br>")),
                  CALL print(calcpos(xcol,ycol)),
                  soutput, row + 1, ycol += font_size
                  IF (ycol >= bottom)
                   BREAK
                  ENDIF
                 ENDIF
               ENDFOR
              ENDIF
              IF ((temp->sl[x].il[y].past_prob_list[probind].life_cycle_status_disp > ""))
               xcol = 60, soutput = build2(captions->sstatus,": ",temp->sl[x].il[y].past_prob_list[
                probind].life_cycle_status_disp),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
            ENDFOR
           ENDIF
          ENDIF
          IF ((temp->sl[x].il[y].input_type=socialhistory_control)
           AND (temp->sl[x].il[y].module="PFEXTCTRLS"))
           IF ((temp->sl[x].il[y].shx_unable_to_obtain_ind > - (1)))
            font_string = concat("{f/0}{cpi/",trim(cnvtstring(m_cpi)),"}{lpi/",trim(cnvtstring(m_lpi)
              ),"}"), font_string, row + 1,
            xcol = 30
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build2("  "),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1, ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
            xcol = 30, soutput = build("{b}{u}",captions->ssocialhist,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)), soutput, row + 1,
            ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
            IF ((temp->sl[x].il[y].shx_unable_to_obtain_ind=1))
             xcol = 45, soutput = build(captions->sunabletoobtain),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput, row + 1,
             ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
            ENDIF
           ENDIF
           IF ((temp->sl[x].il[y].social_cat_list_restricted_ind=1))
            soutput = build("{b}{u}",captions->sallshxnotview,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1
            IF (ycol >= bottom)
             BREAK
            ENDIF
            ycol += font_size
           ENDIF
           shx_cnt = size(temp->sl[x].il[y].social_cat_list,5)
           FOR (shx_idx = 1 TO shx_cnt)
             xcol = 45, tempycol = ycol, soutput = build2("  "),
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput,
             row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
             FOR (line = 1 TO size(temp->sl[x].il[y].social_cat_list[shx_idx].desc_lines,5))
               soutput = build(temp->sl[x].il[y].social_cat_list[shx_idx].desc_lines[line].desc_line),
               CALL addtooutput(build2(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)),
               soutput, row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
             ENDFOR
             det_cnt = size(temp->sl[x].il[y].social_cat_list[shx_idx].detail_list,5)
             IF (det_cnt=0)
              IF (((trim(temp->sl[x].il[y].social_cat_list[shx_idx].last_updt_prsnl) > "") OR (trim(
               temp->sl[x].il[y].social_cat_list[shx_idx].last_updt_dt_tm) > "")) )
               xcol = 60, soutput = build2("(",captions->slastupdated,": ",temp->sl[x].il[y].
                social_cat_list[shx_idx].last_updt_dt_tm," ",
                captions->sby," ",temp->sl[x].il[y].social_cat_list[shx_idx].last_updt_prsnl,")"),
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
              ENDIF
             ENDIF
             FOR (det_idx = 1 TO det_cnt)
               FOR (line = 1 TO size(temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[det_idx].
                disp_lines,5))
                 xcol = 60, soutput = temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[det_idx]
                 .disp_lines[line].aline,
                 CALL addtooutput(build2(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                 ycol += font_size
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
               ENDFOR
               cmnt_cnt = size(temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[det_idx].
                comments,5)
               IF (cmnt_cnt > 0)
                xcol = 60, soutput = build2(captions->scomments,": "),
                CALL addtooutput(build2(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
               ENDIF
               FOR (cmnt_idx = 1 TO cmnt_cnt)
                xcol = 70,
                FOR (cmnt_line = 1 TO size(temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[
                 det_idx].comments[cmnt_idx].comment_lines,5))
                  xcol = 70, soutput = temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[det_idx
                  ].comments[cmnt_idx].comment_lines[cmnt_line].aline,
                  CALL addtooutput(build2(soutput,"<br>")),
                  CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                  ycol += font_size
                  IF (ycol >= bottom)
                   BREAK
                  ENDIF
                ENDFOR
               ENDFOR
             ENDFOR
           ENDFOR
          ENDIF
          IF ((temp->sl[x].il[y].input_type=familyhistory_control)
           AND (temp->sl[x].il[y].module="PFEXTCTRLS"))
           IF ( NOT ((temp->sl[x].il[y].entire_fam_hist_ind=- (1))))
            font_string = concat("{f/0}{cpi/",trim(cnvtstring(m_cpi)),"}{lpi/",trim(cnvtstring(m_lpi)
              ),"}"), font_string, row + 1
            IF (ycol >= bottom)
             BREAK
            ENDIF
            xcol = 30, soutput = build2("  "),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)), soutput, row + 1,
            ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
            soutput = build("{b}{u}",captions->sfamhist,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1, ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
           ENDIF
           soutput = ""
           IF ((temp->sl[x].il[y].entire_fam_hist_ind=0))
            soutput = build(captions->snegative)
           ELSEIF ((temp->sl[x].il[y].entire_fam_hist_ind=2))
            soutput = build(captions->sunknown)
           ELSEIF ((temp->sl[x].il[y].entire_fam_hist_ind=3))
            soutput = build(captions->sunableobtain)
           ELSEIF ((temp->sl[x].il[y].entire_fam_hist_ind=4))
            soutput = build(captions->spatientadopted)
           ENDIF
           IF (trim(soutput) > "")
            xcol = 45,
            CALL addtooutput(build2("  ","<br>")),
            CALL print(calcpos(xcol,ycol)),
            "  ", row + 1, ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)), soutput,
            row + 1, ycol += font_size
            IF (ycol >= bottom)
             BREAK
            ENDIF
           ENDIF
           IF ((temp->sl[x].il[y].fam_list_restricted_ind=1))
            soutput = build("{b}{u}",captions->sallfhxnotview,"{endu}{endb}"),
            CALL addtooutput(build(soutput,"<br>")),
            CALL print(calcpos(xcol,ycol)),
            soutput, row + 1
            IF (ycol >= bottom)
             BREAK
            ENDIF
            ycol += font_size
           ENDIF
           memb_cnt = size(temp->sl[x].il[y].fam_members,5)
           FOR (memb_idx = 1 TO memb_cnt)
             xcol = 45, tempycol = ycol, soutput = " ",
             CALL addtooutput(build(soutput,"<br>")),
             CALL print(calcpos(xcol,ycol)), soutput,
             row + 1, ycol += font_size
             IF (ycol >= bottom)
              BREAK
             ENDIF
             FOR (line = 1 TO size(temp->sl[x].il[y].fam_members[memb_idx].name_lines,5))
               xcol = 45, soutput = temp->sl[x].il[y].fam_members[memb_idx].name_lines[line].aline,
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput, row + 1,
               ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
             ENDFOR
             soutput = ""
             IF ((temp->sl[x].il[y].fam_members[memb_idx].memb_entire_hist_ind=0))
              soutput = build2(captions->snegative," ",captions->shistory)
             ELSEIF ((temp->sl[x].il[y].fam_members[memb_idx].memb_entire_hist_ind=2))
              soutput = build2(captions->sunknown," ",captions->shistory)
             ENDIF
             IF (soutput > "")
              xcol = 70,
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)),
              soutput, row + 1, ycol += font_size
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
             IF ((temp->sl[x].il[y].fam_members[memb_idx].cause_of_death > ""))
              xcol = 70, soutput = build2(captions->scauseofdeath,": ",temp->sl[x].il[y].fam_members[
               memb_idx].cause_of_death),
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput, row + 1,
              ycol += font_size
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
             IF ((temp->sl[x].il[y].fam_members[memb_idx].age_at_death_str > ""))
              xcol = 70, soutput = build2(captions->sageatdeath,": ",temp->sl[x].il[y].fam_members[
               memb_idx].age_at_death_str),
              CALL addtooutput(build(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput, row + 1,
              ycol += font_size
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
             IF ((((temp->sl[x].il[y].fam_members[memb_idx].cause_of_death > "")) OR ((temp->sl[x].
             il[y].fam_members[memb_idx].age_at_death_str > ""))) )
              xcol = 70, soutput = "  ",
              CALL addtooutput(build2(soutput,"<br>")),
              CALL print(calcpos(xcol,ycol)), soutput, row + 1,
              ycol += font_size
              IF (ycol >= bottom)
               BREAK
              ENDIF
             ENDIF
             cond_cnt = size(temp->sl[x].il[y].fam_members[memb_idx].conditions,5)
             FOR (cond_idx = 1 TO cond_cnt)
               IF (cond_idx > 1)
                xcol = 70, soutput = "  ",
                CALL addtooutput(build2(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
               ENDIF
               FOR (line = 1 TO size(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].
                src_str_lines,5))
                 xcol = 70, soutput = build2(temp->sl[x].il[y].fam_members[memb_idx].conditions[
                  cond_idx].src_str_lines[line].aline),
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                 ycol += font_size
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
               ENDFOR
               IF ((temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].fhx_value_flag=0))
                xcol = 80, soutput = build(captions->snegative),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
               ELSEIF ((temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].fhx_value_flag=2
               ))
                xcol = 80, soutput = build(captions->sunknown),
                CALL addtooutput(build(soutput,"<br>")),
                CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                ycol += font_size
                IF (ycol >= bottom)
                 BREAK
                ENDIF
               ELSE
                FOR (line = 1 TO size(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].
                 onset_lines,5))
                  soutput = build2(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].
                   onset_lines[line].aline), xcol = 80,
                  CALL addtooutput(build(soutput,"<br>")),
                  CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                  ycol += font_size
                  IF (ycol >= bottom)
                   BREAK
                  ENDIF
                ENDFOR
                cmnt_cnt = size(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].comments,
                 5)
                IF (cmnt_cnt > 0)
                 xcol = 80, soutput = build(captions->scomments,": "),
                 CALL addtooutput(build(soutput,"<br>")),
                 CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                 ycol += font_size
                 IF (ycol >= bottom)
                  BREAK
                 ENDIF
                ENDIF
                FOR (cmnt_idx = 1 TO cmnt_cnt)
                  IF ((temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].comments[cmnt_idx
                  ].comment_prsnl_name > ""))
                   soutput = build2(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].
                    comments[cmnt_idx].comment_dt_tm_str," - ",temp->sl[x].il[y].fam_members[memb_idx
                    ].conditions[cond_idx].comments[cmnt_idx].comment_prsnl_name), xcol = 90,
                   CALL addtooutput(build(soutput,"<br>")),
                   CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                   ycol += font_size
                   IF (ycol >= bottom)
                    BREAK
                   ENDIF
                  ENDIF
                  FOR (line = 1 TO size(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].
                   comments[cmnt_idx].comment_lines,5))
                    xcol = 90, soutput = build(temp->sl[x].il[y].fam_members[memb_idx].conditions[
                     cond_idx].comments[cmnt_idx].comment_lines[line].line),
                    CALL addtooutput(build(soutput,"<br>")),
                    CALL print(calcpos(xcol,ycol)), soutput, row + 1,
                    ycol += font_size
                    IF (ycol >= bottom)
                     BREAK
                    ENDIF
                  ENDFOR
                  IF (cmnt_idx < cmnt_cnt)
                   soutput = " ",
                   CALL addtooutput(build2(soutput,"<br>")),
                   CALL print(calcpos(xcol,ycol)),
                   soutput, row + 1, ycol += font_size
                   IF (ycol >= bottom)
                    BREAK
                   ENDIF
                  ENDIF
                ENDFOR
                IF (ycol >= bottom)
                 BREAK
                ENDIF
               ENDIF
             ENDFOR
           ENDFOR
          ENDIF
          IF ((temp->sl[x].il[y].input_type=communicationpreference_control)
           AND (temp->sl[x].il[y].module="PFEXTCTRLS"))
           commpref_cnt = size(temp->sl[x].il[y].comm_pref_list,5)
           FOR (commpref_idx = 1 TO commpref_cnt)
             xcol = 30
             IF (ycol >= bottom)
              BREAK
             ENDIF
             FOR (line = 1 TO size(temp->sl[x].il[y].comm_pref_list[commpref_idx].desc_lines,5))
               IF (line=1)
                soutput = build("{b}",captions->scommunicationmethod,": {endb}"," ",temp->sl[x].il[y]
                 .comm_pref_list[commpref_idx].desc_lines[line].desc_line)
               ELSE
                xcol = 35, soutput = build(temp->sl[x].il[y].comm_pref_list[commpref_idx].desc_lines[
                 line].desc_line)
               ENDIF
               CALL addtooutput(build(soutput,"<br>")),
               CALL print(calcpos(xcol,ycol)), soutput,
               row + 1, ycol += font_size
               IF (ycol >= bottom)
                BREAK
               ENDIF
             ENDFOR
           ENDFOR
          ENDIF
        ENDFOR
       ENDIF
       IF (ycol >= bottom)
        thead = "                                                         "
        IF ((x < temp->sect_cnt))
         BREAK
        ENDIF
       ENDIF
     ENDFOR
    FOOT PAGE
     IF (patinfo=1)
      font_string = concat("{f/0}{cpi/",trim(cnvtstring(header_font_cpi)),"}{lpi/",trim(cnvtstring(
         header_font_lpi)),"}"), font_string, row + 1
      IF (curpage=total_page_cnt
       AND signature_cnt != 0)
       ycol = 650
      ELSE
       ycol = 660
      ENDIF
      IF (footer_string=" ")
       ycol += header_font_size
      ENDIF
      xcol = 30,
      CALL print(calcpos(xcol,ycol)), linestr,
      row + 1, font_string = concat("{f/0}{cpi/",trim(cnvtstring(header_font_cpi)),"}{lpi/",trim(
        cnvtstring(header_font_lpi)),"}"), font_string,
      row + 1, spaces1 = ((header_font_totalchar - size(tmp_loc_facility_disp))/ 2), xcol = cnvtint((
       headercols_per_char * spaces1)),
      ycol += 10, soutput = build("{b}",loc_facility_disp,"{endb}","(",trim(captions->sloc),
       ": ",trim(xxx),")"),
      CALL addtoheader(build("<center>",soutput,"</center>")),
      CALL print(calcpos(xcol,ycol)), soutput, row + 1,
      xcol = 50, ycol += 8, ycol1 = ycol,
      soutput = concat(captions->spatname,": ",pat_name),
      CALL addtoheader(build(soutput,"<br>")),
      CALL print(calcpos(xcol,ycol)),
      soutput, row + 1, ycol += 10,
      xcol = 50, soutput = concat(captions->sadmitdoc,": ",admitdoc),
      CALL addtoheader(build(soutput,"<br>")),
      CALL print(calcpos(xcol,ycol)), soutput, row + 1,
      xcol = 50, ycol += 10, soutput = concat(captions->sadmitdt," / ",captions->smrn," / ",captions
       ->sfinnbr,
       ": ",trim(date),"  ",trim(mrn),"  ",
       trim(finnbr)),
      CALL addtoheader(build(soutput,"<br>")),
      CALL print(calcpos(xcol,ycol)), soutput,
      row + 1, xcol = 300, ycol = ycol1,
      soutput = concat(captions->sage,": ",birth_dt_tm," ",age,
       " ",sex),
      CALL addtoheader(build(soutput,"<br>")),
      CALL print(calcpos(xcol,ycol)),
      soutput, row + 1, xcol = 30,
      ycol += 5
     ENDIF
     font_string = concat("{f/0}{cpi/",trim(cnvtstring(header_font_cpi)),"}{lpi/",trim(cnvtstring(
        header_font_lpi)),"}"), font_string, row + 1,
     xcol = 30
     IF (curpage < total_page_cnt
      AND signature_cnt != 0)
      ycol = 690, bottom = 650
     ELSE
      ycol = 700, bottom = 650
     ENDIF
     IF (footer_string=" ")
      ycol += header_font_size
     ENDIF
     soutput = build("{b}",linestr,"{endb}"),
     CALL print(calcpos(xcol,ycol)), soutput,
     row + 1
     IF (curpage=total_page_cnt
      AND signature_cnt != 0)
      FOR (signindex = 1 TO signature_cnt)
        IF (mod(signindex,2)=0)
         xcol += cnvtint(((2.7 * header_font_cpi) * headercols_per_char)), ycol = temp_ycol
        ELSE
         xcol = 30, temp_ycol = ycol
        ENDIF
        ycol += (2.5 * header_font_size), soutput = build("{b}",signlinestr,"{endb}"),
        CALL print(calcpos(xcol,ycol)),
        soutput, row + 1, ycol += header_font_size,
        soutput = build("{b}",signature_lines->sign_qual[signindex].signature_value,"{endb}"),
        CALL print(calcpos(xcol,ycol)), soutput,
        row + 1
      ENDFOR
     ELSE
      ycol += (4 * header_font_size)
     ENDIF
     IF (footer_string != " ")
      spaces3 = ((header_font_totalchar - size(trim(footer_string)))/ 2), xcol = 30, ycol +=
      header_font_size
      FOR (footerindex = 1 TO size(footer_record->footer_qual,5))
        soutput = build("{b}",footer_record->footer_qual[footerindex].foot_string,"{endb}"),
        CALL print(calcpos(xcol,ycol)), soutput,
        row + 1, ycol += header_font_size
      ENDFOR
     ENDIF
     str = concat(captions->spage," ",trim(cnvtstring(curpage))," of ",trim(cnvtstring(total_page_cnt
        ))), str1 = concat(captions->sprintdate,": ",captions->sprintdt), str2 = concat(captions->
      sprinttime,": ",captions->sprinttm),
     str3 = concat(captions->sprintby,": ")
     IF (curpage < total_page_cnt
      AND signature_cnt != 0)
      ycol = (690+ header_font_size)
     ELSE
      ycol = (700+ header_font_size)
     ENDIF
     IF (footer_string=" ")
      ycol += header_font_size
     ENDIF
     xcol = 430,
     CALL print(calcpos(xcol,ycol)), str,
     row + 1, ycol += header_font_size,
     CALL print(calcpos(xcol,ycol)),
     str1, row + 1, ycol += header_font_size,
     CALL print(calcpos(xcol,ycol)), str2, row + 1,
     ycol += header_font_size,
     CALL print(calcpos(xcol,ycol)), str3,
     row + 1, xcol += cnvtint((headercols_per_char * (size(str3)+ 1)))
     FOR (userln = 1 TO size(username->usernamewrap,5))
       soutput = username->usernamewrap[userln].user,
       CALL print(calcpos(xcol,ycol)), soutput,
       row + 1, ycol += header_font_size
     ENDFOR
    FOOT REPORT
     total_page_cnt = temp_page_cnt
    WITH nocounter, dio = value(dio_value), maxcol = 800,
     maxrow = 800
   ;end select
 END ;Subroutine
 SUBROUTINE (build_rtf(output_dist=vc) =null)
   SET ierrorcode = error(serrormsg,1)
   IF (ierrorcode != 0)
    CALL echo("*********************************")
    CALL echo(build("ERROR MESSAGE : ",serrormsg))
    CALL echo("*********************************")
    CALL reportfailure("ERROR","F","DCP_PRT_FORMS_ACTIVITY",serrormsg)
    GO TO exit_script
   ENDIF
   FREE RECORD pt
   SET doaddoutput = 1
   DECLARE updt_list_cnt = i4 WITH private, noconstant(0)
   DECLARE entered_dt = vc WITH private
   SET routput = "{\rtf1\ansi\deff0"
   CALL addtortf(routput)
   SET routput = "{\fonttbl{\f0 Tahoma;}}"
   CALL addtortf(routput)
   SET routput = "{\colortbl;\red210\green210\blue210;}"
   CALL addtortf(routput)
   SET routput = "{\fs22"
   CALL addtortf(routput)
   SELECT INTO value(output_dist)
    FROM (dummyt d1  WITH seq = 1)
    PLAN (d1)
    DETAIL
     updt_list_cnt = size(temp->updated_prsnl,5)
     IF (updt_list_cnt > 0)
      routput = notrim(concat("{\pard\b\ul ",captions->supdatedon,"\b0\ul0\par}")),
      CALL addtortf(routput)
      FOR (updt_cnt = 1 TO updt_list_cnt)
       reverse_cnt = ((updt_list_cnt - updt_cnt)+ 1),
       FOR (line_cnt = 1 TO size(temp->updated_prsnl[reverse_cnt].update_qual,5))
         routput = notrim(concat("{\pard ",temp->updated_prsnl[reverse_cnt].update_qual[line_cnt].
           update_wrap_str,"\par}")), routput = notrim(concat(fillstring(5," "),routput)),
         CALL addtortf(routput)
       ENDFOR
      ENDFOR
     ENDIF
     FOR (x = 1 TO temp->sect_cnt)
      IF ((temp->sl[x].ind=1))
       sectionstring = temp->sl[x].description, routput = notrim(concat(
         "{\pard\b\chshdng\chcbpat1\cb1 ",temp->sl[x].description)), routput = notrim(concat(routput,
         "\b0\par}")),
       CALL addtortf(routput)
      ENDIF
      ,
      FOR (y = 1 TO temp->sl[x].input_cnt)
        IF ((temp->sl[x].il[y].input_type IN (22, 2, 4, 6, 7,
        9, 10, 13, 18, 23))
         AND  NOT (trim(temp->sl[x].il[y].module)="PVTRACKFORMS"))
         IF ((temp->sl[x].il[y].ind=1))
          routput = notrim(concat("{\pard\li480\fi-480\b ",temp->sl[x].il[y].description,":  \b0 ",
            temp->sl[x].il[y].list_tag[1].list_line)), routput = notrim(concat(routput,"\par}")),
          CALL addtortf(routput)
          FOR (z = 2 TO temp->sl[x].il[y].list_ln_cnt)
            routput = temp->sl[x].il[y].list_tag[z].list_line, routput = notrim(concat(
              "{\pard\li480\fi-480 ",routput,"\par}")),
            CALL addtortf(routput)
          ENDFOR
          IF ((temp->sl[x].il[y].note_ind=1))
           routput = notrim(concat("{\pard\li960\fi-480 ",temp->sl[x].il[y].note_text,"\par}")),
           CALL addtortf(routput)
          ENDIF
         ENDIF
        ENDIF
        IF ((temp->sl[x].il[y].input_type=5))
         IF ((temp->sl[x].il[y].ind=1))
          routput = notrim(concat("{\pard\b ",temp->sl[x].il[y].description,"\b0\par}")),
          CALL addtortf(routput)
          FOR (z = 1 TO temp->sl[x].il[y].cnt)
            routput = notrim(concat("{\pard\li480\b ",temp->sl[x].il[y].qual[z].label,"\b0\par}")),
            CALL addtortf(routput), routput = notrim(concat("{\pard\li1440\fi-480 ",temp->sl[x].il[y]
              .qual[z].line,"\par}")),
            CALL addtortf(routput)
          ENDFOR
          IF ((temp->sl[x].il[y].note_ind=1))
           routput = notrim(concat("{\pard\li480\fi-240 ",temp->sl[x].il[y].note_text,"\par}")),
           CALL addtortf(routput)
          ENDIF
         ENDIF
        ENDIF
        IF ((temp->sl[x].il[y].input_type=15))
         FOR (p = 1 TO temp->sl[x].il[y].grid_cnt)
           IF ((temp->sl[x].il[y].grid_qual[p].ind=1))
            IF (p=1)
             routput = notrim(concat("{\pard\b ",temp->sl[x].il[y].label,"\b0\par}")),
             CALL addtortf(routput)
            ENDIF
            routput = notrim(concat("{\pard\li480\b ",temp->sl[x].il[y].grid_qual[p].label,"\b0\par}"
              )),
            CALL addtortf(routput), routput = notrim(concat("{\pard\li1440\fi-480 ",temp->sl[x].il[y]
              .grid_qual[p].event_tag,"\par}")),
            CALL addtortf(routput), ycol = comment_y_col
            IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
             routput = notrim(concat("{\pard\li1440\fi-480 ",temp->sl[x].il[y].grid_qual[p].note_text,
               "\par}")),
             CALL addtortf(routput)
            ENDIF
           ENDIF
         ENDFOR
         IF ((temp->sl[x].il[y].note_ind=1))
          routput = notrim(concat("{\pard\li480\fi-240 ",temp->sl[x].il[y].note_text,"\par}")),
          CALL addtortf(routput)
         ENDIF
        ENDIF
        IF ((temp->sl[x].il[y].input_type=14))
         FOR (p = 1 TO temp->sl[x].il[y].grid_cnt)
           IF ((temp->sl[x].il[y].grid_qual[p].ind=1))
            IF (p=1)
             routput = notrim(concat("{\pard\b ",temp->sl[x].il[y].label,"\b0\par}")),
             CALL addtortf(routput)
            ENDIF
            routput = notrim(concat("{\pard\li480 ",temp->sl[x].il[y].grid_qual[p].label,"\par}")),
            CALL addtortf(routput), routput = notrim(concat("{\pard\li1440\fi-480 ",temp->sl[x].il[y]
              .grid_qual[p].event_tag,"\par}")),
            CALL addtortf(routput)
            IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
             routput = notrim(concat("{\pard\li1440\fi-480 ",temp->sl[x].il[y].grid_qual[p].note_text,
               "\par}")),
             CALL addtortf(routput)
            ENDIF
           ENDIF
         ENDFOR
         IF ((temp->sl[x].il[y].note_ind=1))
          routput = notrim(concat("{\pard\li480\fi-240 ",temp->sl[x].il[y].note_text,"\par}")),
          CALL addtortf(routput)
         ENDIF
        ENDIF
        IF ((temp->sl[x].il[y].input_type IN (17, 19)))
         FOR (p = 1 TO temp->sl[x].il[y].grid_cnt)
           IF (p=1)
            routput = notrim(concat("{\pard\b ",temp->sl[x].il[y].description,"\b0\par}")),
            CALL addtortf(routput)
           ENDIF
           stat = alterlist(qual_seqs->seqs,temp->sl[x].il[y].grid_qual[p].cnt)
           FOR (q = 1 TO temp->sl[x].il[y].grid_qual[p].cnt)
             qual_seqs->seqs[q].seq = temp->sl[x].il[y].grid_qual[p].qual[q].collating_seq
           ENDFOR
           IF ((temp->sl[x].il[y].input_type=19))
            routput = notrim(concat("{\pard\li240\b ",temp->sl[x].il[y].grid_qual[p].label,"\b0\par}"
              )),
            CALL addtortf(routput)
           ENDIF
           IF (size(qual_seqs->seqs,5) > 0)
            next_insert_val = 0, last_insert_val = 0, stat = alterlist(sorted_qual_seqs->seqs,size(
              qual_seqs->seqs,5))
            FOR (q = 1 TO size(qual_seqs->seqs,5))
              FOR (r = 1 TO size(qual_seqs->seqs,5))
                IF ((qual_seqs->seqs[r].seq > last_insert_val)
                 AND ((next_insert_val=0) OR ((qual_seqs->seqs[r].seq < next_insert_val))) )
                 next_insert_val = qual_seqs->seqs[r].seq
                ENDIF
              ENDFOR
              sorted_qual_seqs->seqs[q].seq = next_insert_val, last_insert_val = next_insert_val,
              next_insert_val = 0
            ENDFOR
            FOR (q = 1 TO size(sorted_qual_seqs->seqs,5))
              routput = notrim(concat("{\pard\li480 ",temp->sl[x].il[y].grid_qual[p].qual[q].label,
                "\par}")),
              CALL addtortf(routput), routput = notrim(concat("{\pard\li1440\fi-480 ",temp->sl[x].il[
                y].grid_qual[p].qual[q].event_tag,"\par}")),
              CALL addtortf(routput)
              IF ((temp->sl[x].il[y].grid_qual[p].qual[q].note_ind=1))
               routput = notrim(concat("{\pard\li1440\fi-480 ",temp->sl[x].il[y].grid_qual[p].qual[q]
                 .note_text,"\par}")),
               CALL addtortf(routput)
              ENDIF
            ENDFOR
           ENDIF
           IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
            routput = notrim(concat("{\pard\li1440\fi-480 ",temp->sl[x].il[y].grid_qual[p].note_text,
              "\par}")),
            CALL addtortf(routput)
           ENDIF
         ENDFOR
         IF ((temp->sl[x].il[y].note_ind=1))
          routput = notrim(concat("{\pard\li480\fi-240 ",temp->sl[x].il[y].note_text,"\par}")),
          CALL addtortf(routput)
         ENDIF
        ENDIF
        IF ((temp->sl[x].il[y].input_type=11))
         routput = notrim(concat("{\pard\b\ul ",captions->sallergy,"  /  ")), routput = notrim(concat
          (routput,captions->sreaction,"\ul0\b0\par}")),
         CALL addtortf(routput)
         FOR (z = 1 TO temp->sl[x].il[y].allergy_cnt)
           routput = notrim(concat("{\pard\b ",temp->sl[x].il[y].allergy_qual[z].list,"\b0\par}")),
           CALL addtortf(routput)
           FOR (v = 1 TO temp->sl[x].il[y].allergy_qual[z].reaction_cnt)
             IF ((temp->sl[x].il[y].allergy_qual[z].reaction_qual[v].rlist > " "))
              routput = notrim(concat("{\pard\li960\fi-480 ",temp->sl[x].il[y].allergy_qual[z].
                reaction_qual[v].rlist,"\par}")),
              CALL addtortf(routput)
             ENDIF
           ENDFOR
           IF ((temp->sl[x].il[y].allergy_qual[z].note_ind=1))
            FOR (w = 1 TO temp->sl[x].il[y].allergy_qual[z].note_cnt)
              IF ((temp->sl[x].il[y].allergy_qual[z].note_qual[w].note_text > " "))
               tempstr = temp->sl[x].il[y].allergy_qual[z].note_qual[w].note_text, tempstr = replace(
                tempstr,concat(char(13),char(10)),"\line ",0), routput = notrim(concat(
                 "{\pard\li480\fi-480 ",tempstr,"\par}")),
               CALL addtortf(routput)
              ENDIF
            ENDFOR
           ENDIF
         ENDFOR
         IF ((temp->sl[x].il[y].allergy_cnt=0))
          routput = notrim(concat("{\pard\li240 ",captions->snoallergy,"\par}")),
          CALL addtortf(routput)
         ENDIF
        ENDIF
        IF ((((temp->sl[x].il[y].input_type=1)) OR ((temp->sl[x].il[y].input_type=2)))
         AND (temp->sl[x].il[y].module="PVTRACKFORMS"))
         FOR (p = 1 TO temp->sl[x].il[y].cnt)
           IF (p=1)
            routput = notrim(concat("{\pard\b ",temp->sl[x].il[y].description,"\b0\par}")),
            CALL addtortf(routput)
           ENDIF
           routput = notrim(concat("{\pard\li480\b ",temp->sl[x].il[y].qual[p].label,"\b0\par}")),
           CALL addtortf(routput), routput = notrim(concat("{\pard\li1440\fi-480 ",temp->sl[x].il[y].
             qual[p].line,"\par}")),
           CALL addtortf(routput)
         ENDFOR
         IF ((temp->sl[x].il[y].note_ind=1))
          routput = notrim(concat("{\pard\li1440\fi-480 ",temp->sl[x].il[y].note_text,"\par}")),
          CALL addtortf(routput)
         ENDIF
        ENDIF
      ENDFOR
     ENDFOR
    WITH nocounter
   ;end select
   SET routput = "}}"
   CALL addtortf(routput)
   CALL breakrtfintoreplychunks(chunk_size)
 END ;Subroutine
 SUBROUTINE (breakrtfintoreplychunks(chunk_size=vc) =null)
   DECLARE chunk_cnt = i4 WITH protect, noconstant(0)
   DECLARE start = i4 WITH protect, noconstant(0)
   DECLARE finish = i4 WITH protect, noconstant(0)
   DECLARE length2 = i4 WITH protect, noconstant(0)
   SET length2 = size(rtfstring)
   IF (length2)
    SET start = 1
    SET finish = 0
    SET chunk_cnt = 0
    WHILE (finish < length2)
      SET finish += chunk_size
      IF (finish >= length2)
       SET finish = length2
      ENDIF
      SET chunk_cnt += 1
      SET stat = alterlist(reply->output_line,chunk_cnt)
      SET reply->output_line[chunk_cnt].output = substring(start,((finish - start)+ 1),rtfstring)
      SET start = (finish+ 1)
    ENDWHILE
    SET line_count = chunk_cnt
   ENDIF
 END ;Subroutine
 SUBROUTINE (fill_prefs(pvc_name=vc,pvc_value=vc) =null)
   CASE (pvc_name)
    OF "FORMS_RPT_PT_INFO":
     SET patinfo = cnvtint(pvc_value)
    OF "POWERFORMSRPT.FontSize":
     SET font_size = cnvtint(pvc_value)
    OF "POWERFORMSRPT.Signature Line":
     SET signature_line_str = pvc_value
    OF "POWERFORMSRPT.FooterLine":
     SET footer_string = pvc_value
   ENDCASE
 END ;Subroutine
 SUBROUTINE (fillsignatureline(signstr=vc) =null)
   DECLARE comma = vc WITH constant(fillstring(1,","))
   DECLARE tempsignstr = vc WITH noconstant
   DECLARE signstrlength = i4 WITH private, noconstant(0)
   DECLARE commaloc = i4 WITH private, noconstant(0)
   SET tempsignstr = signstr
   SET commaloc = findstring(comma,tempsignstr)
   SET signstrlength = textlen(signstr)
   WHILE (commaloc > 0)
     SET signature_cnt += 1
     SET stat = alterlist(signature_lines->sign_qual,signature_cnt)
     SET signature_lines->sign_qual[signature_cnt].signature_value = trim(substring(1,(commaloc - 1),
       tempsignstr))
     SET tempsignstr = substring((commaloc+ 1),(signstrlength - commaloc),tempsignstr)
     SET commaloc = findstring(comma,tempsignstr)
   ENDWHILE
   IF (tempsignstr != " ")
    SET signature_cnt += 1
    SET stat = alterlist(signature_lines->sign_qual,signature_cnt)
    SET signature_lines->sign_qual[signature_cnt].signature_value = trim(tempsignstr)
   ENDIF
 END ;Subroutine
 SUBROUTINE (medprofile_formatting(sect=i4,ctrl=i4,medindex=i4) =null)
   SET pt->line_cnt = 0
   CALL wrap_text(temp->sl[sect].il[ctrl].med_profile_qual[medindex].hna_order_mnemonic,m_totalchar,
    m_totalchar)
   SET stat = alterlist(temp->sl[sect].il[ctrl].med_profile_qual[medindex].hna_order_tag_list,pt->
    line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].med_profile_qual[medindex].hna_order_tag_list[x].order_tag = pt->
     lns[x].line
   ENDFOR
 END ;Subroutine
 SUBROUTINE (problem_formatting(sect=i4,ctrl=i4,probindex=i4) =null)
   SET pt->line_cnt = 0
   CALL wrap_text(temp->sl[sect].il[ctrl].problem_list[probindex].problem_desc,m_totalchar,
    m_totalchar)
   SET stat = alterlist(temp->sl[sect].il[ctrl].problem_list[probindex].problem_tag,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].problem_list[probindex].problem_tag[x].problem_line = pt->lns[x].
     line
   ENDFOR
 END ;Subroutine
 SUBROUTINE (dx_formatting(sect=i4,ctrl=i4,dxindex=i4) =null)
   SET pt->line_cnt = 0
   CALL wrap_text(temp->sl[sect].il[ctrl].diagnosis[dxindex].diagnosis_desc,m_totalchar,m_totalchar)
   SET stat = alterlist(temp->sl[sect].il[ctrl].diagnosis[dxindex].diagnosis_tag,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].diagnosis[dxindex].diagnosis_tag[x].diagnosis_line = pt->lns[x].line
   ENDFOR
 END ;Subroutine
 SUBROUTINE (gest_formatting(sect=i4,ctrl=i4,gestindex=i4) =null)
   SET pt->line_cnt = 0
   CALL wrap_text(temp->sl[sect].il[ctrl].gestational[gestindex].gest_comment,m_totalchar,m_totalchar
    )
   SET stat = alterlist(temp->sl[sect].il[ctrl].gestational[gestindex].gest_tag,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].gestational[gestindex].gest_tag[x].gest_line = pt->lns[x].line
   ENDFOR
 END ;Subroutine
 SUBROUTINE (encntr_formatting(sect=i4,ctrl=i4,encindex=i4) =null)
   SET pt->line_cnt = 0
   CALL wrap_text(temp->sl[sect].il[ctrl].tracking_cmt[encindex].tracking_comment,m_totalchar,
    m_totalchar)
   SET stat = alterlist(temp->sl[sect].il[ctrl].tracking_cmt[encindex].tracking_tag,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].tracking_cmt[encindex].tracking_tag[x].tracking_line = pt->lns[x].
     line
   ENDFOR
 END ;Subroutine
#exit_script
 IF (validate(reply,0))
  SET reply->formdescription = temp->description
  SET reply->performeddttm = temp->performed_dt_tm
  SET reply->performedprsnlid = temp->performed_prsnl_id
  SET reply->formstatuscode = temp->form_status_cd
  SET reply->performedtz = temp->performed_tz
  SET reply->person_id = temp->person_id
  SET reply->encntr_id = temp->encntr_id
 ENDIF
 SET modify = hipaa
 EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
 "Person", "Patient", "DCP FORMS",
 "Access/Use", request->dcp_forms_activity_id, ""
 IF ((reply->encntr_id != 0))
  EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
  "Encounter", "Patient", "Encounter",
  "Access/Use", reply->encntr_id, ""
 ELSE
  EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
  "Person", "Patient", "Patient",
  "Access/Use", reply->person_id, ""
 ENDIF
 FREE RECORD temp
 FREE RECORD username
 FREE RECORD blob
 FREE RECORD captions
 FREE RECORD signature_lines
 FREE RECORD footer_record
 CALL echo("DCP_PRT_FORMS_ACTIVITY Last Modified = 029 10/08/14")
 SET modify = nopredeclare
END GO
