CREATE PROGRAM cp_powerforms_chart2:dba
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
   1 sdeliverydate = vc
   1 scloseddate = vc
   1 sautocloseddate = vc
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
   1 sformactprtfail = vc
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
   SET captions->scloseddate = trim(uar_i18ngetmessage(i18nhandle,"CLOSEDDATE","Closed Date"))
   SET captions->sautocloseddate = trim(uar_i18ngetmessage(i18nhandle,"CLOSEDPREGNANCY",
     "Closed Pregnancy (AUTO-CLOSED):"))
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
   SET captions->sformactprtfail = trim(uar_i18ngetmessage(i18nhandle,"FORMFAILED",
     "*Failed to retrieve form data! Printed data may be incomplete.*"))
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
 END ;Subroutine
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
 DECLARE calculate_onset_year(onset_age=i4,onset_age_unit_cd_mean=vc) = i4
 DECLARE wrap_text(blob_string=vc,wrap_max_length=i4,sec_wrap_max_length=i4) = null
 DECLARE family_history_condition_str_formatting(sect=i4,ctrl=i4,memidx=i4,conidx=i4) = null
 DECLARE family_history_name_str_formatting(sect=i4,ctrl=i4,memidx=i4) = null
 DECLARE medlist_comment_formatting(sect=i4,ctrl=i4,medlistindex=i4) = null
 DECLARE medlist_displayln_formatting(sect=i4,ctrl=i4,medlistindex=i4) = null
 DECLARE medlist_refname_formatting(sect=i4,ctrl=i4,medlistindex=i4) = null
 DECLARE preg_data_str_formatting(sect=i4,ctrl=i4,pregindex=i4) = null
 DECLARE past_prob_formatting(sect=i4,ctrl=i4,probindex=i4) = null
 DECLARE past_prob_comment_formatting(sect=i4,ctrl=i4,probindex=i4) = null
 DECLARE proc_term_formatting(sect=i4,ctrl=i4,procindex=i4) = null
 DECLARE proc_comment_formatting(sect=i4,ctrl=i4,procindex=i4) = null
 DECLARE social_data_str_formatting(sect=i4,ctrl=i4,socialindex=i4) = null
 DECLARE communication_preference_str_formatting(sect=i4,ctrl=i4,commprefindex=i4) = null
 DECLARE birth_dt_tm_parameter = dq8 WITH protect, noconstant(0)
 SUBROUTINE calculate_onset_year(onset_age,onset_age_unit_cd_mean)
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
 SUBROUTINE wrap_text(blob_string,wrap_max_length,wrap_sec_max_length)
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
     SET blob->cnt = (blob->cnt+ 1)
     SET stat = alterlist(blob->qual,blob->cnt)
     SET blob->qual[blob->cnt].line = trim(blob->line)
     SET blob->qual[blob->cnt].sze = textlen(trim(blob->line))
     SET cr = findstring(lf,check_blob)
     SET checkstring = substring(1,(cr - 1),check_blob)
     SET lfcheck = findstring(check,checkstring)
   ENDWHILE
   IF (trim(check_blob) != " ")
    SET blob->cnt = (blob->cnt+ 1)
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
         SET l = (l+ 1)
         SET stat = alterlist(pt->lns,l)
         SET pt->lns[l].line = substring(1,c,blob->qual[j].line)
         SET blob->qual[j].line = substring((c+ 1),(blob->qual[j].sze - c),blob->qual[j].line)
         SET c = 1
        ENDIF
        SET c = (c - 1)
       ENDWHILE
       IF (h=l)
        SET l = (l+ 1)
        SET stat = alterlist(pt->lns,l)
        SET pt->lns[l].line = substring(1,wrap_max_length,blob->qual[j].line)
        SET blob->qual[j].line = substring((wrap_max_length+ 1),(blob->qual[j].sze - wrap_max_length),
         blob->qual[j].line)
       ENDIF
       SET blob->qual[j].sze = size(trim(blob->qual[j].line))
       SET wrap_max_length = wrap_sec_max_length
     ENDWHILE
     SET l = (l+ 1)
     SET stat = alterlist(pt->lns,l)
     SET pt->lns[l].line = substring(1,blob->qual[j].sze,blob->qual[j].line)
     SET pt->line_cnt = l
     IF (l=1)
      SET wrap_max_length = wrap_sec_max_length
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE medlist_refname_formatting(sect,ctrl,medlistindex)
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
 SUBROUTINE medlist_comment_formatting(sect,ctrl,medlistindex)
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
 SUBROUTINE medlist_displayln_formatting(sect,ctrl,medlistindex)
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
 SUBROUTINE preg_data_str_formatting(sect,ctrl,pregindex)
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
 SUBROUTINE proc_term_formatting(sect,ctrl,procindex)
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
 SUBROUTINE proc_comment_formatting(sect,ctrl,procindex)
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
 SUBROUTINE past_prob_formatting(sect,ctrl,probindex)
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
 SUBROUTINE past_prob_comment_formatting(sect,ctrl,probindex)
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
 SUBROUTINE family_history_name_str_formatting(sect,ctrl,memidx)
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
 SUBROUTINE family_history_condition_str_formatting(sect,ctrl,memidx,conidx)
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
 SUBROUTINE social_data_str_formatting(sect,ctrl,socialindex)
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
 SUBROUTINE communication_preference_str_formatting(sect,ctrl,commprefindex)
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
 DECLARE dummyvoid = i2 WITH constant(0)
 CALL fillcaptions(dummyvoid)
 RECORD reply(
   1 num_lines = f8
   1 qual[*]
     2 line = c255
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD flist(
   1 fref_cnt = i2
   1 fref_l[*]
     2 dcp_forms_ref_id = f8
     2 fact_cnt = i2
     2 fact_l[*]
       3 dcp_forms_activity_id = f8
       3 last_activity_dt_tm = dq8
       3 last_activity_by = vc
       3 last_activity_by1 = vc
       3 version_dt_tm = dq8
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD r_print(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD encntr_temp(
   1 encntr_qual[*]
     2 encntr_id = f8
 )
 RECORD code_temp(
   1 code_qual[*]
     2 code = f8
 )
 RECORD flist_temp(
   1 fref_cnt = i2
   1 fref_l[*]
     2 dcp_forms_ref_id = f8
 )
 RECORD blob(
   1 line = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
     2 sze = i4
 )
 DECLARE encntr_cnt = i4
 DECLARE ln_number = vc
 DECLARE prob_desc_size = i4 WITH noconstant(0), protect
 DECLARE prob_desc_idx = i4 WITH noconstant(1), protect
 DECLARE dx_desc_size = i4 WITH noconstant(0), protect
 DECLARE dx_desc_idx = i4 WITH noconstant(1), protect
 DECLARE prob_count = i4 WITH noconstant(0), protect
 DECLARE dx_count = i4 WITH noconstant(0), protect
 DECLARE facnt = i4 WITH noconstant(0), protect
 SET ec = char(0)
 SET blob_out = fillstring(32000," ")
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET ycol = 0
 SET xcol = 0
 SET xxx = fillstring(40," ")
 SET person_id = 0.0
 SET encntr_cnt = 0
 SET day = fillstring(2," ")
 SET month = fillstring(2," ")
 SET year = fillstring(2," ")
 SET hour = fillstring(2," ")
 SET minute = fillstring(2," ")
 SET error_line = fillstring(40," ")
 SET ln = 0
 SET done = "F"
 SET numrows = 0
 SET pagevar = 0
 SET last_activity_dt_tm = cnvtdatetime(curdate,curtime)
 SET last_activity_date = fillstring(20," ")
 SET last_activity_by = fillstring(30," ")
 SET version_dt_tm = cnvtdatetime(curdate,curtime)
 SET labl_length = 0
 RECORD birth_temp(
   1 birth_temp_dt = dq8
   1 birth_temp_tz = i4
 )
 DECLARE medprofile_formatting(sect=i4,ctrl=i4,medindex=i4) = null
 DECLARE problem_formatting(sect=i4,ctrl=i4,probindex=i4) = null
 DECLARE dx_formatting(sect=i4,ctrl=i4,dxindex=i4) = null
 DECLARE gest_formatting(sect=i4,ctrl=i4,gestindex=i4) = null
 DECLARE encntr_formatting(sect=i4,ctrl=i4,encindex=i4) = null
 DECLARE clinical_cd = f8 WITH public, constant(uar_get_code_by("MEANING",18189,"CLINCALEVENT"))
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
 DECLARE max_length = i4 WITH protect, noconstant(0)
 DECLARE linecnt = i4 WITH protect, noconstant(0)
 DECLARE lineidx = i4 WITH protect, noconstant(0)
 DECLARE pat_name = vc WITH protect, noconstant(fillstring(100," "))
 DECLARE memb_ind_str = vc WITH protect, noconstant(fillstring(100," "))
 DECLARE m_totalchar = i4 WITH protect, noconstant(88)
 DECLARE memb_cnt = i4 WITH protect, noconstant(0)
 DECLARE memb_idx = i4 WITH protect, noconstant(0)
 DECLARE cond_cnt = i4 WITH protect, noconstant(0)
 DECLARE cond_idx = i4 WITH protect, noconstant(0)
 DECLARE cmnt_cnt = i4 WITH protect, noconstant(0)
 DECLARE cmnt_idx = i4 WITH protect, noconstant(0)
 DECLARE pastprob_cnt = i4 WITH protect, noconstant(0)
 DECLARE preg_cnt = i4 WITH protect, noconstant(0)
 DECLARE proc_cnt = i4 WITH protect, noconstant(0)
 DECLARE med_cnt = i4 WITH protect, noconstant(0)
 DECLARE inter_dt_tm = dq8 WITH protect
 DECLARE x11 = vc WITH protect, noconstant(fillstring(11," "))
 DECLARE x9 = vc WITH protect, noconstant(fillstring(9," "))
 DECLARE shx_cnt = i4 WITH protect, noconstant(0)
 DECLARE shx_idx = i4 WITH protect, noconstant(0)
 DECLARE det_cnt = i4 WITH protect, noconstant(0)
 DECLARE det_idx = i4 WITH protect, noconstant(0)
 IF ((request->start_dt_tm > 0))
  SET s_date = cnvtdatetime(request->start_dt_tm)
 ELSE
  SET s_date = cnvtdatetime("01-jan-1800 00:00:00.00")
 ENDIF
 IF ((request->end_dt_tm > 0))
  SET e_date = cnvtdatetime(request->end_dt_tm)
 ELSE
  SET e_date = cnvtdatetime("31-dec-2100 00:00:00.00")
 ENDIF
 SET person_id = request->person_id
 SELECT INTO "nl"
  FROM person p
  WHERE p.person_id=person_id
   AND p.active_ind=1
  HEAD p.person_id
   pat_name = trim(p.name_full_formatted), birth_temp->birth_temp_dt = p.birth_dt_tm, birth_temp->
   birth_temp_tz = p.birth_tz
  WITH nocounter
 ;end select
 SET encntr_cnt = size(request->xencntr_qual,5)
 SET stat = alterlist(encntr_temp->encntr_qual,encntr_cnt)
 FOR (i = 1 TO encntr_cnt)
   SET encntr_temp->encntr_qual[i].encntr_id = request->xencntr_qual[i].encntr_id
 ENDFOR
 IF (encntr_cnt=0)
  IF ((request->encntr_id != 0))
   SET stat = alterlist(encntr_temp->encntr_qual,1)
   SET encntr_temp->encntr_qual[1].encntr_id = request->encntr_id
   SET encntr_cnt = 1
  ELSE
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE esc_cnt = i4 WITH constant(size(request->code_list,5)), protect
 IF (esc_cnt=0)
  GO TO exit_script
 ENDIF
 DECLARE exp_max_cnt = i4 WITH constant(200), protect
 DECLARE esc_idx_cnt = i4 WITH constant(ceil(((esc_cnt * 1.0)/ exp_max_cnt))), protect
 DECLARE cp_expand_start = i4 WITH noconstant(1), protect
 DECLARE cp_expand_idx = i4 WITH noconstant(0), protect
 DECLARE frcnt = i4 WITH noconstant(0), protect
 SET one_found = "N"
 DECLARE esc_max_cnt = i4 WITH constant((esc_idx_cnt * exp_max_cnt)), protect
 DECLARE code_cnt = i4 WITH noconstant(0), protect
 SET stat = alterlist(code_temp->code_qual,esc_max_cnt)
 FOR (code_cnt = 1 TO esc_cnt)
   SET code_temp->code_qual[code_cnt].code = request->code_list[code_cnt].code
 ENDFOR
 FOR (cp_expand_idx = (esc_cnt+ 1) TO esc_max_cnt)
   SET code_temp->code_qual[cp_expand_idx].code = request->code_list[esc_cnt].code
 ENDFOR
 SET cp_expand_idx = 1
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(esc_idx_cnt)),
   v500_event_set_code vesc,
   dcp_forms_ref dfr
  PLAN (d1
   WHERE assign(cp_expand_start,evaluate(d1.seq,1,1,(cp_expand_start+ exp_max_cnt))))
   JOIN (vesc
   WHERE expand(cp_expand_idx,cp_expand_start,(cp_expand_start+ (exp_max_cnt - 1)),vesc.event_set_cd,
    code_temp->code_qual[cp_expand_idx].code))
   JOIN (dfr
   WHERE dfr.event_set_name=vesc.event_set_name
    AND dfr.dcp_forms_ref_id > 0)
  ORDER BY dfr.dcp_forms_ref_id
  HEAD dfr.dcp_forms_ref_id
   IF (mod(frcnt,exp_max_cnt)=0)
    stat = alterlist(flist->fref_l,(frcnt+ exp_max_cnt))
   ENDIF
   frcnt = (frcnt+ 1), flist->fref_l[frcnt].dcp_forms_ref_id = dfr.dcp_forms_ref_id
  WITH nocounter
 ;end select
 IF (frcnt=0)
  GO TO exit_script
 ENDIF
 SET flist->fref_cnt = frcnt
 DECLARE fr_idx = i4 WITH noconstant(0), protect
 DECLARE mod_fr_idx = i4 WITH constant(ceil(((frcnt * 1.0)/ exp_max_cnt))), protect
 DECLARE fr_max_idx = i4 WITH constant((mod_fr_idx * exp_max_cnt)), protect
 SET stat = alterlist(flist_temp->fref_l,fr_max_idx)
 FOR (fr_idx = 1 TO frcnt)
   SET flist_temp->fref_l[fr_idx].dcp_forms_ref_id = flist->fref_l[fr_idx].dcp_forms_ref_id
 ENDFOR
 FOR (fr_idx = (frcnt+ 1) TO fr_max_idx)
   SET flist_temp->fref_l[fr_idx].dcp_forms_ref_id = flist->fref_l[frcnt].dcp_forms_ref_id
 ENDFOR
 SET flist_temp->fref_cnt = fr_max_idx
 SET cp_expand_idx = 1
 DECLARE fr_idx_cnt = i4 WITH constant(ceil(((frcnt * 1.0)/ exp_max_cnt)))
 DECLARE encntr_idx = i4 WITH noconstant(0), protect
 SET cp_expand_start = 1
 DECLARE cp_loc_idx = i4 WITH noconstant(0), protect
 DECLARE cp_loc_pos = i4 WITH noconstant(0), protect
 DECLARE mod_encntr_idx = i4 WITH constant(ceil(((encntr_cnt * 1.0)/ exp_max_cnt))), protect
 DECLARE encntr_max_idx = i4 WITH constant((mod_encntr_idx * exp_max_cnt)), protect
 SET stat = alterlist(encntr_temp->encntr_qual,encntr_max_idx)
 FOR (encntr_idx = (encntr_cnt+ 1) TO encntr_max_idx)
   SET encntr_temp->encntr_qual[encntr_idx].encntr_id = encntr_temp->encntr_qual[encntr_cnt].
   encntr_id
 ENDFOR
 DECLARE encntr_start = i4 WITH noconstant(0), protect
 DECLARE encntr_end = i4 WITH noconstant(0), protect
 FOR (x = 1 TO mod_encntr_idx)
   SET encntr_start = (encntr_end+ 1)
   SET encntr_end = ((encntr_start+ exp_max_cnt) - 1)
   SELECT
    IF ((request->result_lookup_ind=1))
     PLAN (d2
      WHERE assign(cp_expand_start,evaluate(d2.seq,1,1,(cp_expand_start+ exp_max_cnt))))
      JOIN (dfa
      WHERE expand(encntr_idx,encntr_start,encntr_end,dfa.encntr_id,encntr_temp->encntr_qual[
       encntr_idx].encntr_id)
       AND expand(cp_expand_idx,cp_expand_start,(cp_expand_start+ (exp_max_cnt - 1)),dfa
       .dcp_forms_ref_id,flist_temp->fref_l[cp_expand_idx].dcp_forms_ref_id)
       AND dfa.form_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
    ELSE
     PLAN (d2
      WHERE assign(cp_expand_start,evaluate(d2.seq,1,1,(cp_expand_start+ exp_max_cnt))))
      JOIN (dfa
      WHERE expand(encntr_idx,1,encntr_cnt,dfa.encntr_id,encntr_temp->encntr_qual[encntr_idx].
       encntr_id)
       AND expand(cp_expand_idx,cp_expand_start,(cp_expand_start+ (exp_max_cnt - 1)),dfa
       .dcp_forms_ref_id,flist_temp->fref_l[cp_expand_idx].dcp_forms_ref_id)
       AND dfa.last_activity_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
    ENDIF
    INTO "nl:"
    FROM (dummyt d2  WITH value(fr_idx_cnt)),
     dcp_forms_activity dfa
    ORDER BY dfa.encntr_id, dfa.dcp_forms_ref_id, dfa.dcp_forms_activity_id
    HEAD dfa.dcp_forms_ref_id
     cp_loc_pos = locateval(cp_loc_idx,1,frcnt,dfa.dcp_forms_ref_id,flist->fref_l[cp_loc_idx].
      dcp_forms_ref_id), facnt = flist->fref_l[cp_loc_idx].fact_cnt
    DETAIL
     IF (cp_loc_pos != 0)
      one_found = "Y", facnt = (facnt+ 1), stat = alterlist(flist->fref_l[cp_loc_idx].fact_l,facnt),
      flist->fref_l[cp_loc_idx].fact_l[facnt].dcp_forms_activity_id = dfa.dcp_forms_activity_id,
      flist->fref_l[cp_loc_idx].fact_l[facnt].last_activity_dt_tm = cnvtdatetime(dfa
       .last_activity_dt_tm)
      IF (dfa.version_dt_tm=null)
       flist->fref_l[cp_loc_idx].fact_l[facnt].version_dt_tm = cnvtdatetime(dfa.beg_activity_dt_tm)
      ELSE
       flist->fref_l[cp_loc_idx].fact_l[facnt].version_dt_tm = cnvtdatetime(dfa.version_dt_tm)
      ENDIF
     ENDIF
    FOOT  dfa.dcp_forms_ref_id
     flist->fref_l[cp_loc_idx].fact_cnt = facnt
    WITH nocounter
   ;end select
 ENDFOR
 SET stat = alterlist(flist->fref_l,frcnt)
 SET reply->num_lines = 0
 IF (one_found="N")
  CALL echo(build("one_found: ",one_found))
  GO TO exit_script
 ENDIF
 FOR (frcnt = 1 TO flist->fref_cnt)
  SET dcp_forms_ref_id = flist->fref_l[frcnt].dcp_forms_ref_id
  FOR (facnt = 1 TO flist->fref_l[frcnt].fact_cnt)
    SET dcp_forms_activity_id = flist->fref_l[frcnt].fact_l[facnt].dcp_forms_activity_id
    SET version_dt_tm = cnvtdatetime(flist->fref_l[frcnt].fact_l[facnt].version_dt_tm)
    EXECUTE FROM init_temp_begin TO init_temp_end
    EXECUTE dcp_get_forms_activity_prt
    EXECUTE FROM print_act_begin TO print_act_end
    FREE RECORD temp
  ENDFOR
 ENDFOR
 GO TO exit_script
#init_temp_begin
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
#init_temp_end
#print_act_begin
 FOR (z = 1 TO temp->sect_cnt)
   FOR (y = 1 TO temp->sl[z].input_cnt)
     SET max_length = 50
     IF ((temp->sl[z].il[y].input_type IN (22, 2, 4, 6, 7,
     9, 10, 18, 23))
      AND trim(temp->sl[z].il[y].module)=" ")
      SET pt->line_cnt = 0
      EXECUTE dcp_parse_text value(temp->sl[z].il[y].event_tag), value(max_length)
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
        EXECUTE dcp_parse_text value(temp->sl[z].il[y].qual[w].line), value(max_length)
        SET stat = alterlist(temp->sl[z].il[y].qual[w].list_tag,pt->line_cnt)
        SET temp->sl[z].il[y].qual[w].list_ln_cnt = pt->line_cnt
        FOR (x = 1 TO pt->line_cnt)
          SET temp->sl[z].il[y].qual[w].list_tag[x].list_line = pt->lns[x].line
        ENDFOR
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type=11))
      FOR (w = 1 TO temp->sl[z].il[y].allergy_cnt)
        SET pt->line_cnt = 0
        EXECUTE dcp_parse_text value(temp->sl[z].il[y].allergy_qual[w].list), value(42)
        SET stat = alterlist(temp->sl[z].il[y].allergy_qual[w].alist_tag,pt->line_cnt)
        SET temp->sl[z].il[y].allergy_qual[w].alist_ln_cnt = pt->line_cnt
        FOR (x = 1 TO pt->line_cnt)
          SET temp->sl[z].il[y].allergy_qual[w].alist_tag[x].alist_line = pt->lns[x].line
        ENDFOR
        FOR (v = 1 TO temp->sl[z].il[y].allergy_qual[w].reaction_cnt)
          IF ((temp->sl[z].il[y].allergy_qual[w].reaction_qual[v].rlist > " "))
           SET pt->line_cnt = 0
           EXECUTE dcp_parse_text value(temp->sl[z].il[y].allergy_qual[w].reaction_qual[v].rlist),
           value(max_length)
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
     IF (trim(temp->sl[z].il[y].module)="PFEXTCTRLS")
      IF ((temp->sl[z].il[y].input_type=problemdx_control))
       SET prob_count = size(temp->sl[z].il[y].problem_list,5)
       FOR (w = 1 TO prob_count)
         CALL problem_formatting(z,y,w)
       ENDFOR
       SET dx_count = size(temp->sl[z].il[y].diagnosis,5)
       FOR (w = 1 TO dx_count)
         CALL dx_formatting(z,y,w)
       ENDFOR
      ENDIF
      IF ((temp->sl[z].il[y].input_type=medlist_control))
       SET med_cnt = size(temp->sl[z].il[y].med_list,5)
       FOR (w = 1 TO med_cnt)
        CALL medlist_refname_formatting(z,y,w)
        CALL medlist_comment_formatting(z,y,w)
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
     IF ((temp->sl[z].il[y].input_type=15))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        SET pt->line_cnt = 0
        EXECUTE dcp_parse_text value(temp->sl[z].il[y].grid_qual[w].event_tag), value(max_length)
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
        SET max_length = 77
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
     IF ((temp->sl[z].il[y].input_type=13))
      SET pt->line_cnt = 0
      SET max_length = 77
      SET labl_length = size(temp->sl[z].il[y].description)
      CALL wrap_text(temp->sl[z].il[y].event_tag,(max_length - 14),(max_length - 14))
      SET stat = alterlist(temp->sl[z].il[y].list_tag,pt->line_cnt)
      SET temp->sl[z].il[y].list_ln_cnt = pt->line_cnt
      FOR (x = 1 TO pt->line_cnt)
        SET temp->sl[z].il[y].list_tag[x].list_line = pt->lns[x].line
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type IN (17, 19)))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        FOR (q = 1 TO temp->sl[z].il[y].grid_qual[w].cnt)
          SET pt->line_cnt = 0
          SET max_length = 50
          EXECUTE dcp_parse_text value(temp->sl[z].il[y].grid_qual[w].qual[q].event_tag), value(
           max_length)
          SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].qual[q].list_tag,pt->line_cnt)
          SET temp->sl[z].il[y].grid_qual[w].qual[q].list_ln_cnt = pt->line_cnt
          FOR (x = 1 TO pt->line_cnt)
            SET temp->sl[z].il[y].grid_qual[w].qual[q].list_tag[x].list_line = pt->lns[x].line
          ENDFOR
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SET x11 = fillstring(11," ")
 SET x9 = fillstring(9," ")
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
             SET max_length = 50
             EXECUTE dcp_parse_text value(temp->sl[z].il[y].allergy_qual[x].note_qual[w].note_text),
             value(max_length)
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
      SET max_length = 50
      IF ((temp->sl[z].il[y].note_ind=1))
       IF ((temp->sl[z].il[y].note_text > " "))
        SET temp->sl[z].il[y].note_text = concat(captions->scomment,": ",trim(temp->sl[z].il[y].
          note_text))
       ENDIF
       EXECUTE dcp_parse_text value(temp->sl[z].il[y].note_text), value(max_length)
       SET stat = alterlist(temp->sl[z].il[y].note_qual,pt->line_cnt)
       SET temp->sl[z].il[y].note_cnt = pt->line_cnt
       FOR (x = 1 TO pt->line_cnt)
         IF (x=1)
          SET temp->sl[z].il[y].note_qual[x].note_line = pt->lns[x].line
         ELSE
          SET temp->sl[z].il[y].note_qual[x].note_line = concat(x11,pt->lns[x].line)
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
     IF ((temp->sl[z].il[y].input_type IN (15, 17, 19)))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        IF ((temp->sl[z].il[y].grid_qual[w].note_ind=1))
         SET pt->line_cnt = 0
         SET max_length = 50
         IF ((temp->sl[z].il[y].grid_qual[w].note_text > " "))
          SET temp->sl[z].il[y].grid_qual[w].note_text = concat(captions->scomment,": ",trim(temp->
            sl[z].il[y].grid_qual[w].note_text))
         ENDIF
         EXECUTE dcp_parse_text value(temp->sl[z].il[y].grid_qual[w].note_text), value(max_length)
         SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].note_qual,pt->line_cnt)
         SET temp->sl[z].il[y].grid_qual[w].note_cnt = pt->line_cnt
         FOR (x = 1 TO pt->line_cnt)
           IF (x=1)
            SET temp->sl[z].il[y].grid_qual[w].note_qual[x].note_line = pt->lns[x].line
           ELSE
            SET temp->sl[z].il[y].grid_qual[w].note_qual[x].note_line = concat(x11,pt->lns[x].line)
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type=14))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        IF ((temp->sl[z].il[y].grid_qual[w].note_ind=1))
         SET pt->line_cnt = 0
         SET max_length = 77
         IF ((temp->sl[z].il[y].grid_qual[w].note_text > " "))
          SET temp->sl[z].il[y].grid_qual[w].note_text = concat(captions->scomment,": ",trim(temp->
            sl[z].il[y].grid_qual[w].note_text))
         ENDIF
         CALL wrap_text(temp->sl[z].il[y].grid_qual[w].note_text,(max_length - 7),(max_length - 10))
         SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].note_qual,pt->line_cnt)
         SET temp->sl[z].il[y].grid_qual[w].note_cnt = pt->line_cnt
         FOR (x = 1 TO pt->line_cnt)
           IF (x=1)
            SET temp->sl[z].il[y].grid_qual[w].note_qual[x].note_line = pt->lns[x].line
           ELSE
            SET temp->sl[z].il[y].grid_qual[w].note_qual[x].note_line = concat(x11,pt->lns[x].line)
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
     IF ((temp->sl[z].il[y].input_type IN (17, 19)))
      FOR (w = 1 TO temp->sl[z].il[y].grid_cnt)
        FOR (q = 1 TO temp->sl[z].il[y].grid_qual[w].cnt)
          IF ((temp->sl[z].il[y].grid_qual[w].qual[q].note_ind=1))
           SET pt->line_cnt = 0
           SET max_length = 50
           IF ((temp->sl[z].il[y].grid_qual[w].qual[q].note_text > " "))
            SET temp->sl[z].il[y].grid_qual[w].qual[q].note_text = concat(captions->scomment,": ",
             trim(temp->sl[z].il[y].grid_qual[w].qual[q].note_text))
           ENDIF
           EXECUTE dcp_parse_text value(temp->sl[z].il[y].grid_qual[w].qual[q].note_text), value(
            max_length)
           SET stat = alterlist(temp->sl[z].il[y].grid_qual[w].qual[q].note_qual,pt->line_cnt)
           SET temp->sl[z].il[y].grid_qual[w].qual[q].note_cnt = pt->line_cnt
           FOR (x = 1 TO pt->line_cnt)
             IF (x=1)
              SET temp->sl[z].il[y].grid_qual[w].qual[q].note_qual[x].note_line = pt->lns[x].line
             ELSE
              SET temp->sl[z].il[y].grid_qual[w].qual[q].note_qual[x].note_line = concat(x11,pt->lns[
               x].line)
             ENDIF
           ENDFOR
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SET inter_dt_tm = cnvtdatetime(curdate,curtime3)
 SET captions->sprintdt = format(inter_dt_tm,"@SHORTDATE;;Q")
 SET captions->sprinttm = format(inter_dt_tm,"@TIMENOSECONDS;;Q")
 SELECT INTO request->output_device
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   ">>>", row + 1, col 50,
   temp->description, row + 1
   IF ((temp->prsnl_ind=0))
    col 40, temp->last_updt_str, row + 1
   ELSE
    col 40, temp->performed_dt_str, row + 1,
    col 40, temp->entered_dt_str, row + 1
   ENDIF
   "<<<", row + 1, xcol = 30,
   updt_list_cnt = size(temp->updated_prsnl,5)
   IF (updt_list_cnt > 0)
    col 0, ">>", row + 1,
    col 1, captions->supdatedon, row + 1
    FOR (updt_cnt = 1 TO updt_list_cnt)
      reverse_cnt = ((updt_list_cnt - updt_cnt)+ 1), col 10, temp->updated_prsnl[reverse_cnt].
      update_dt_str,
      row + 1
    ENDFOR
    "<<", row + 1
   ENDIF
  DETAIL
   FOR (x = 1 TO temp->sect_cnt)
    IF ((temp->sl[x].ind=1))
     col 0, ">>", row + 1,
     col 1, temp->sl[x].description, row + 1,
     "<<", row + 1
    ENDIF
    ,
    FOR (y = 1 TO temp->sl[x].input_cnt)
      IF ((temp->sl[x].il[y].input_type IN (22, 2, 4, 6, 7,
      9, 10, 13, 18, 23))
       AND trim(temp->sl[x].il[y].module)=" ")
       IF ((temp->sl[x].il[y].ind=1))
        col 1, temp->sl[x].il[y].description
        FOR (z = 1 TO temp->sl[x].il[y].list_ln_cnt)
          col 49, temp->sl[x].il[y].list_tag[z].list_line, row + 1
        ENDFOR
        IF ((temp->sl[x].il[y].note_ind=1))
         FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
           col 49, temp->sl[x].il[y].note_qual[w].note_line, row + 1
         ENDFOR
        ENDIF
       ENDIF
      ENDIF
      IF ((temp->sl[x].il[y].input_type=5))
       IF ((temp->sl[x].il[y].ind=1))
        col 1, temp->sl[x].il[y].description, row + 1
        FOR (z = 1 TO temp->sl[x].il[y].cnt)
          col 6, temp->sl[x].il[y].qual[z].label
          FOR (w = 1 TO temp->sl[x].il[y].qual[z].list_ln_cnt)
            col 49, temp->sl[x].il[y].qual[z].list_tag[w].list_line, row + 1
          ENDFOR
        ENDFOR
        IF ((temp->sl[x].il[y].note_ind=1))
         FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
           col 49, temp->sl[x].il[y].note_qual[w].note_line, row + 1
         ENDFOR
        ENDIF
       ENDIF
       temp->sl[x].il[y].cnt = 0, temp->sl[x].il[y].ind = 0
      ENDIF
      IF ((temp->sl[x].il[y].input_type=15))
       FOR (p = 1 TO temp->sl[x].il[y].grid_cnt)
         IF ((temp->sl[x].il[y].grid_qual[p].ind=1))
          IF (p=1)
           col 1, temp->sl[x].il[y].label, row + 1
          ENDIF
          col 6, temp->sl[x].il[y].grid_qual[p].label
          FOR (z = 1 TO temp->sl[x].il[y].grid_qual[p].list_ln_cnt)
            col 49, temp->sl[x].il[y].grid_qual[p].list_tag[z].list_line, row + 1
          ENDFOR
          IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
           FOR (w = 1 TO temp->sl[x].il[y].grid_qual[p].note_cnt)
             col 49, temp->sl[x].il[y].grid_qual[p].note_qual[w].note_line, row + 1
           ENDFOR
          ENDIF
         ENDIF
       ENDFOR
       IF ((temp->sl[x].il[y].note_ind=1))
        FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
          col 49, temp->sl[x].il[y].note_qual[w].note_line, row + 1
        ENDFOR
       ENDIF
       temp->sl[x].il[y].grid_cnt = 0
      ENDIF
      IF ((temp->sl[x].il[y].input_type=14))
       FOR (p = 1 TO temp->sl[x].il[y].grid_cnt)
         IF ((temp->sl[x].il[y].grid_qual[p].ind=1))
          col 1
          IF (p=1)
           temp->sl[x].il[y].label, row + 1
          ENDIF
          col 6, temp->sl[x].il[y].grid_qual[p].label, labl_length = size(temp->sl[x].il[y].
           grid_qual[p].label),
          call reportmove('COL',(8+ labl_length),0), temp->sl[x].il[y].grid_qual[p].list_tag[1].
          list_line, row + 1
          FOR (z = 2 TO temp->sl[x].il[y].grid_qual[p].list_ln_cnt)
            col 8, temp->sl[x].il[y].grid_qual[p].list_tag[z].list_line, row + 1
          ENDFOR
          IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
           FOR (w = 1 TO temp->sl[x].il[y].grid_qual[p].note_cnt)
             col 8, temp->sl[x].il[y].grid_qual[p].note_qual[w].note_line, row + 1
           ENDFOR
          ENDIF
         ENDIF
       ENDFOR
       IF ((temp->sl[x].il[y].note_ind=1))
        FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
          col 6, temp->sl[x].il[y].note_qual[w].note_line, row + 1
        ENDFOR
       ENDIF
       temp->sl[x].il[y].grid_cnt = 0
      ENDIF
      IF ((temp->sl[x].il[y].input_type IN (17, 19)))
       FOR (p = 1 TO temp->sl[x].il[y].grid_cnt)
         IF (p=1)
          col 1, temp->sl[x].il[y].description, row + 1
         ENDIF
         IF ((temp->sl[x].il[y].input_type=19))
          col 6, temp->sl[x].il[y].grid_qual[p].label, row + 1
         ENDIF
         FOR (q = 1 TO temp->sl[x].il[y].grid_qual[p].cnt)
           ln_number = trim(cnvtstring(p))
           IF ((temp->sl[x].il[y].input_type=17)
            AND q=1)
            col 3, ln_number, captions->slnnumberchar,
            " "
           ELSE
            col 6
           ENDIF
           temp->sl[x].il[y].grid_qual[p].qual[q].label
           FOR (z = 1 TO temp->sl[x].il[y].grid_qual[p].qual[q].list_ln_cnt)
             IF ((temp->sl[x].il[y].grid_qual[p].qual[q].list_tag[z].list_line > " "))
              col 49, temp->sl[x].il[y].grid_qual[p].qual[q].list_tag[z].list_line, row + 1
             ENDIF
           ENDFOR
           IF ((temp->sl[x].il[y].grid_qual[p].qual[q].note_ind=1))
            FOR (w = 1 TO temp->sl[x].il[y].grid_qual[p].qual[q].note_cnt)
              col 49, temp->sl[x].il[y].grid_qual[p].qual[q].note_qual[w].note_line, row + 1
            ENDFOR
           ENDIF
         ENDFOR
         IF ((temp->sl[x].il[y].grid_qual[p].note_ind=1))
          FOR (w = 1 TO temp->sl[x].il[y].grid_qual[p].note_cnt)
            col 49, temp->sl[x].il[y].grid_qual[p].note_qual[w].note_line, row + 1
          ENDFOR
         ENDIF
       ENDFOR
       IF ((temp->sl[x].il[y].note_ind=1))
        FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
          col 49, temp->sl[x].il[y].note_qual[w].note_line, row + 1
        ENDFOR
       ENDIF
       temp->sl[x].il[y].grid_cnt = 0
      ENDIF
      IF ((temp->sl[x].il[y].input_type=11))
       col 1, captions->sallergy, col 49,
       captions->sreaction, row + 1
       FOR (z = 1 TO temp->sl[x].il[y].allergy_cnt)
         rline_cnt = 0, temp_cnt = 0, this_rline_cnt = 0,
         r_print->line_cnt = 0, ln_number = trim(cnvtstring(z))
         FOR (v = 1 TO temp->sl[x].il[y].allergy_qual[z].reaction_cnt)
           this_rline_cnt = temp->sl[x].il[y].allergy_qual[z].reaction_qual[v].rlist_ln_cnt,
           rline_cnt = (rline_cnt+ this_rline_cnt), r_print->line_cnt = rline_cnt
           IF (this_rline_cnt > 0)
            stat = alterlist(r_print->lns,rline_cnt)
            FOR (n = 1 TO this_rline_cnt)
              r_print->lns[(temp_cnt+ n)].line = trim(temp->sl[x].il[y].allergy_qual[z].
               reaction_qual[v].rlist_tag[n].rlist_line)
            ENDFOR
            temp_cnt = rline_cnt
           ENDIF
         ENDFOR
         IF ((r_print->line_cnt >= temp->sl[x].il[y].allergy_qual[z].alist_ln_cnt))
          FOR (w = 1 TO r_print->line_cnt)
            IF ((w <= temp->sl[x].il[y].allergy_qual[z].alist_ln_cnt))
             col 1
             IF (w=1)
              ln_number, captions->slnnumberchar, " "
             ELSE
              "   "
             ENDIF
             temp->sl[x].il[y].allergy_qual[z].alist_tag[w].alist_line
            ENDIF
            col 49, r_print->lns[w].line, row + 1
          ENDFOR
         ELSE
          FOR (w = 1 TO temp->sl[x].il[y].allergy_qual[z].alist_ln_cnt)
            col 1
            IF (w=1)
             ln_number, captions->slnnumberchar, " "
            ELSE
             "   "
            ENDIF
            temp->sl[x].il[y].allergy_qual[z].alist_tag[w].alist_line
            IF ((w <= r_print->line_cnt))
             col 49, r_print->lns[w].line
            ENDIF
            row + 1
          ENDFOR
         ENDIF
         IF ((temp->sl[x].il[y].allergy_qual[z].note_ind=1))
          FOR (w = 1 TO temp->sl[x].il[y].allergy_qual[z].note_cnt)
            FOR (v = 1 TO temp->sl[x].il[y].allergy_qual[z].note_qual[w].note_ln_cnt)
              col 49, temp->sl[x].il[y].allergy_qual[z].note_qual[w].nlist_tag[v].note_line, row + 1
            ENDFOR
          ENDFOR
         ENDIF
         stat = alterlist(r_print->lns,0)
       ENDFOR
       IF ((temp->sl[x].il[y].allergy_cnt=0))
        col 1, captions->snoallergy, row + 1
       ENDIF
      ENDIF
      IF ((((temp->sl[x].il[y].input_type=1)) OR ((temp->sl[x].il[y].input_type=2)))
       AND (temp->sl[x].il[y].module="PVTRACKFORMS"))
       FOR (p = 1 TO temp->sl[x].il[y].cnt)
         IF (p=1)
          col 1, temp->sl[x].il[y].description, row + 1
         ENDIF
         col 1, temp->sl[x].il[y].qual[p].label
         FOR (z = 1 TO temp->sl[x].il[y].qual[p].list_ln_cnt)
           col 49, temp->sl[x].il[y].qual[p].list_tag[z].list_line, row + 1
         ENDFOR
       ENDFOR
       IF ((temp->sl[x].il[y].note_ind=1))
        FOR (w = 1 TO temp->sl[x].il[y].note_cnt)
          col 49, temp->sl[x].il[y].note_qual[w].note_line, row + 1
        ENDFOR
       ENDIF
      ENDIF
      IF ((temp->sl[x].il[y].module="PFPMCtrls"))
       IF ((temp->sl[x].il[y].input_type=1))
        gest_ind_cp = 1, col 1, captions->sgestationage,
        col 49, temp->sl[x].il[y].gestational[gest_ind_cp].gest_age_concat, row + 1,
        col 1, captions->sgestationmethod, col 49,
        temp->sl[x].il[y].gestational[gest_ind_cp].gest_age_method, row + 1, col 1,
        captions->sgestationcomment, gest_comment_size = size(temp->sl[x].il[y].gestational[
         gest_ind_cp].gest_tag,5)
        FOR (gest_comment_idx = 1 TO gest_comment_size)
          col 49, temp->sl[x].il[y].gestational[gest_ind_cp].gest_tag[gest_comment_idx].gest_line,
          row + 1
        ENDFOR
       ENDIF
       IF ((temp->sl[x].il[y].input_type=2))
        FOR (trck_ind_cp = 1 TO size(temp->sl[x].il[y].tracking_cmt,5))
          IF ((temp->sl[x].il[y].tracking_cmt[trck_ind_cp].tracking_comment != " "))
           col 1, temp->sl[x].il[y].tracking_cmt[trck_ind_cp].comment_lbl
           FOR (line_cp = 1 TO size(temp->sl[x].il[y].tracking_cmt[trck_ind_cp].tracking_tag,5))
             col 49, temp->sl[x].il[y].tracking_cmt[trck_ind_cp].tracking_tag[line_cp].tracking_line,
             row + 1
           ENDFOR
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
      IF ((temp->sl[x].il[y].module="PFEXTCTRLS"))
       IF ((temp->sl[x].il[y].input_type=medprofile_control))
        med_cnt = size(temp->sl[x].il[y].med_profile_qual,5)
        IF (med_cnt > 0)
         col 1, captions->shomemeds, row + 1
         FOR (med_ind = 1 TO med_cnt)
           col 1, temp->sl[x].il[y].med_profile_qual[med_ind].hna_order_mnemonic, row + 1
         ENDFOR
        ENDIF
       ENDIF
       IF ((temp->sl[x].il[y].input_type=medlist_control))
        medlist_cnt = size(temp->sl[x].il[y].med_list,5)
        IF (medlist_cnt > 0)
         ">>", row + 1, col 1,
         captions->smedlist, row + 1, "<<",
         row + 1
         IF (size(temp->sl[x].il[y].order_compliance,5) > 0)
          col 6, "  ", row + 1,
          col 6, captions->sordercompliance, ": ",
          row + 1, col 10
          IF ((temp->sl[x].il[y].order_compliance[1].unable_to_obtain_ind=1))
           captions->sunabletoobtain, "  "
          ELSE
           captions->sobtained, "  "
          ENDIF
          row + 1
          IF ((temp->sl[x].il[y].order_compliance[1].no_known_home_meds_ind=1))
           col 10, captions->snoknownhomemeds, row + 1
          ENDIF
          IF ((temp->sl[x].il[y].order_compliance[1].performed_by_name > ""))
           col 10, captions->sperformedby, ": ",
           temp->sl[x].il[y].order_compliance[1].performed_by_name, ";"
           IF ((temp->sl[x].il[y].order_compliance[1].performed_dt_tm_str > ""))
            captions->sperformeddate, ": ", temp->sl[x].il[y].order_compliance[1].performed_dt_tm_str
           ENDIF
           row + 1
          ENDIF
         ENDIF
         FOR (med_idx = 1 TO medlist_cnt)
           IF (size(temp->sl[x].il[y].med_list[med_idx].name_lines,5) > 0)
            col 6, "   ", row + 1
            FOR (linecnt = 1 TO size(temp->sl[x].il[y].med_list[med_idx].name_lines,5))
              col 6, temp->sl[x].il[y].med_list[med_idx].name_lines[linecnt].name_line, row + 1
            ENDFOR
           ENDIF
           IF ((temp->sl[x].il[y].med_list[med_idx].display_line > ""))
            col 10, captions->ssig, ": ",
            temp->sl[x].il[y].med_list[med_idx].display_line, row + 1
           ENDIF
           FOR (line = 1 TO size(temp->sl[x].il[y].med_list[med_idx].comment_lines,5))
             col 10, temp->sl[x].il[y].med_list[med_idx].comment_lines[line].comment_line, row + 1
           ENDFOR
           IF ((temp->sl[x].il[y].med_list[med_idx].provider_name > " "))
            col 10, captions->sprovider, ": ",
            temp->sl[x].il[y].med_list[med_idx].provider_name, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].med_list[med_idx].order_dt_tm_str > " "))
            col 10, captions->sdate, ": ",
            temp->sl[x].il[y].med_list[med_idx].order_dt_tm_str, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].med_list[med_idx].order_status > " "))
            col 10, captions->sstatus, ": ",
            temp->sl[x].il[y].med_list[med_idx].order_status, row + 1
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
       IF ((temp->sl[x].il[y].input_type=pregnancyhistory_control))
        preg_cnt = size(temp->sl[x].il[y].pregnancies,5)
        IF (((preg_cnt > 0) OR (size(temp->sl[x].il[y].gravida,5) > 0)) )
         ">> ", row + 1, col 1,
         captions->spreghist, row + 1, "<<",
         row + 1
        ENDIF
        IF (size(temp->sl[x].il[y].gravida,5) > 0)
         col 4, "  ", row + 1,
         gravida_str = fillstring(100," "), gravida_str = build2(captions->sgravida," - ",trim(
           cnvtstring(temp->sl[x].il[y].gravida[1].gravida)),"; ",captions->sparaterm,
          " - ",trim(cnvtstring(temp->sl[x].il[y].gravida[1].fullterm)),"; ",captions->sparapreterm,
          " - ",
          trim(cnvtstring(temp->sl[x].il[y].gravida[1].parapreterm)),"; ",captions->sabortions," - ",
          trim(cnvtstring(temp->sl[x].il[y].gravida[1].aborted)),
          "; ",captions->sliving," - ",trim(cnvtstring(temp->sl[x].il[y].gravida[1].living))), col 4,
         gravida_str, row + 1
        ENDIF
        FOR (preg_idx = 1 TO preg_cnt)
          col 4, "   ", row + 1
          FOR (chld_idx = 1 TO size(temp->sl[x].il[y].pregnancies[preg_idx].child_list,5))
            col 8, "   ", row + 1,
            col 8, captions->sdeliverydate, ": ",
            temp->sl[x].il[y].pregnancies[preg_idx].child_list[chld_idx].delivery_dt_tm_str, row + 1,
            linecnt = size(temp->sl[x].il[y].pregnancies[preg_idx].child_list[chld_idx].
             data_str_lines,5)
            FOR (lineidx = 1 TO linecnt)
              col 12, temp->sl[x].il[y].pregnancies[preg_idx].child_list[chld_idx].data_str_lines[
              lineidx].aline, row + 1
            ENDFOR
          ENDFOR
        ENDFOR
       ENDIF
       IF ((temp->sl[x].il[y].input_type=pastmedhistory_control))
        past_prob_cnt = size(temp->sl[x].il[y].past_prob_list,5)
        IF (past_prob_cnt > 0)
         ">>", row + 1, col 1,
         captions->spastmedhist, row + 1, "<<",
         row + 1
         FOR (probind = 1 TO past_prob_cnt)
           col 5, "   ", row + 1
           FOR (line = 1 TO size(temp->sl[x].il[y].past_prob_list[probind].prob_lines,5))
             col 5, temp->sl[x].il[y].past_prob_list[probind].prob_lines[line].prob_line, row + 1
           ENDFOR
           col 10
           IF (trim(temp->sl[x].il[y].past_prob_list[probind].onset_year) > "")
            captions->sonsetyear, " - ", temp->sl[x].il[y].past_prob_list[probind].onset_year,
            "; "
           ENDIF
           IF (trim(temp->sl[x].il[y].past_prob_list[probind].onset_age) > "")
            captions->sonsetage, " -", temp->sl[x].il[y].past_prob_list[probind].onset_age
           ENDIF
           row + 1, comt_cnt = size(temp->sl[x].il[y].past_prob_list[probind].comments,5)
           IF (comt_cnt > 0)
            col 10, captions->scomments, ": ",
            row + 1
           ENDIF
           FOR (comt_idx = 1 TO comt_cnt)
            IF ((temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].comment_prsnl_name > ""
            ))
             col 15, temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].comment_dt_tm_str,
             " - ",
             temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].comment_prsnl_name, row + 1
            ENDIF
            ,
            FOR (comt_line = 1 TO size(temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].
             comment_lines,5))
              col 15, temp->sl[x].il[y].past_prob_list[probind].comments[comt_idx].comment_lines[
              comt_line].comment_line, row + 1
            ENDFOR
           ENDFOR
           IF ((temp->sl[x].il[y].past_prob_list[probind].life_cycle_status_disp > ""))
            col 10, captions->sstatus, ": ",
            temp->sl[x].il[y].past_prob_list[probind].life_cycle_status_disp, row + 1
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
       IF ((temp->sl[x].il[y].input_type=procedurehistory_control))
        proc_cnt = size(temp->sl[x].il[y].proc_list,5)
        IF (proc_cnt > 0)
         ">>", row + 1, col 1,
         captions->sprochist, row + 1, "<<",
         row + 1
        ENDIF
        FOR (proc_idx = 1 TO proc_cnt)
          col 4, "   ", row + 1
          FOR (line = 1 TO size(temp->sl[x].il[y].proc_list[proc_idx].proc_lines,5))
            col 4, temp->sl[x].il[y].proc_list[proc_idx].proc_lines[line].proc_line, row + 1
          ENDFOR
          FOR (line = 1 TO size(temp->sl[x].il[y].proc_list[proc_idx].perform_lines,5))
            col 8, temp->sl[x].il[y].proc_list[proc_idx].perform_lines[line].aline, row + 1
          ENDFOR
          IF (trim(temp->sl[x].il[y].proc_list[proc_idx].age_at_proc) > "")
           col 8, captions->sonsetage, ":",
           temp->sl[x].il[y].proc_list[proc_idx].age_at_proc, row + 1
          ENDIF
          cmnt_cnt = size(temp->sl[x].il[y].proc_list[proc_idx].comments,5)
          IF (cmnt_cnt > 0)
           col 8, captions->scomments, ": ",
           row + 1
          ENDIF
          FOR (cmnt_idx = 1 TO cmnt_cnt)
            IF ((temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].comment_prsnl_name > ""))
             col 12, temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].comment_dt_tm_str,
             " - ",
             temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].comment_prsnl_name, row + 1
            ENDIF
            FOR (cmnt_line = 1 TO size(temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].
             comment_lines,5))
              col 12, temp->sl[x].il[y].proc_list[proc_idx].comments[cmnt_idx].comment_lines[
              cmnt_line].comment_line, row + 1
            ENDFOR
            col 12, " ", row + 1
          ENDFOR
        ENDFOR
       ENDIF
       IF ((temp->sl[x].il[y].input_type=socialhistory_control))
        IF ((temp->sl[x].il[y].shx_unable_to_obtain_ind > - (1)))
         ">>", row + 1, col 1,
         captions->ssocialhist, row + 1, "<<",
         row + 1
         IF ((temp->sl[x].il[y].shx_unable_to_obtain_ind=1))
          col 4, "   ", row + 1,
          col 4, captions->sunabletoobtain, row + 1
         ENDIF
        ENDIF
        shx_cnt = size(temp->sl[x].il[y].social_cat_list,5)
        FOR (shx_idx = 1 TO shx_cnt)
          col 4, "  ", row + 1
          FOR (line = 1 TO size(temp->sl[x].il[y].social_cat_list[shx_idx].desc_lines,5))
            col 4, temp->sl[x].il[y].social_cat_list[shx_idx].desc_lines[line].desc_line, row + 1
          ENDFOR
          det_cnt = size(temp->sl[x].il[y].social_cat_list[shx_idx].detail_list,5)
          IF (det_cnt=0)
           IF (((trim(temp->sl[x].il[y].social_cat_list[shx_idx].last_updt_prsnl) > "") OR (trim(temp
            ->sl[x].il[y].social_cat_list[shx_idx].last_updt_dt_tm) > "")) )
            col 8, "(", captions->slastupdated,
            ": ", temp->sl[x].il[y].social_cat_list[shx_idx].last_updt_dt_tm, " ",
            captions->sby, " ", temp->sl[x].il[y].social_cat_list[shx_idx].last_updt_prsnl,
            ")", row + 1
           ENDIF
          ENDIF
          FOR (det_idx = 1 TO det_cnt)
            FOR (line = 1 TO size(temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[det_idx].
             disp_lines,5))
              col 8, temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[det_idx].disp_lines[line]
              .aline, row + 1
            ENDFOR
            cmnt_cnt = size(temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[det_idx].comments,
             5)
            IF (cmnt_cnt > 0)
             col 8, captions->scomments, ": ",
             row + 1
            ENDIF
            FOR (cmnt_idx = 1 TO cmnt_cnt)
              FOR (cmnt_line = 1 TO size(temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[
               det_idx].comments[cmnt_idx].comment_lines,5))
                col 12, temp->sl[x].il[y].social_cat_list[shx_idx].detail_list[det_idx].comments[
                cmnt_idx].comment_lines[cmnt_line].aline, row + 1
              ENDFOR
            ENDFOR
          ENDFOR
        ENDFOR
       ENDIF
       IF ((temp->sl[x].il[y].input_type=familyhistory_control))
        IF ( NOT ((temp->sl[x].il[y].entire_fam_hist_ind=- (1))))
         ">>", row + 1, col 1,
         captions->sfamhist, row + 1, "<<",
         row + 1
        ENDIF
        col 4
        IF ((temp->sl[x].il[y].entire_fam_hist_ind=0))
         captions->snegative
        ELSEIF ((temp->sl[x].il[y].entire_fam_hist_ind=2))
         captions->sunknown
        ELSEIF ((temp->sl[x].il[y].entire_fam_hist_ind=3))
         captions->sunableobtain
        ELSEIF ((temp->sl[x].il[y].entire_fam_hist_ind=4))
         captions->spatientadopted
        ENDIF
        row + 1, memb_cnt = size(temp->sl[x].il[y].fam_members,5)
        FOR (memb_idx = 1 TO memb_cnt)
          col 4, "  ", row + 1
          FOR (line = 1 TO size(temp->sl[x].il[y].fam_members[memb_idx].name_lines,5))
            col 4, temp->sl[x].il[y].fam_members[memb_idx].name_lines[line].aline, row + 1
          ENDFOR
          memb_ind_str = ""
          IF ((temp->sl[x].il[y].fam_members[memb_idx].memb_entire_hist_ind=0))
           memb_ind_str = build2(captions->snegative," ",captions->shistory)
          ELSEIF ((temp->sl[x].il[y].fam_members[memb_idx].memb_entire_hist_ind=2))
           memb_ind_str = build2(captions->sunknown," ",captions->shistory)
          ENDIF
          IF (trim(memb_ind_str) > "")
           col 8, memb_ind_str, row + 1
          ENDIF
          IF ((temp->sl[x].il[y].fam_members[memb_idx].cause_of_death > ""))
           col 8, captions->scauseofdeath, ": ",
           temp->sl[x].il[y].fam_members[memb_idx].cause_of_death, row + 1
          ENDIF
          IF ((temp->sl[x].il[y].fam_members[memb_idx].age_at_death_str > ""))
           col 8, captions->sageatdeath, ": ",
           temp->sl[x].il[y].fam_members[memb_idx].age_at_death_str, row + 1
          ENDIF
          IF ((((temp->sl[x].il[y].fam_members[memb_idx].cause_of_death > "")) OR ((temp->sl[x].il[y]
          .fam_members[memb_idx].age_at_death_str > ""))) )
           col 8, " ", row + 1
          ENDIF
          cond_cnt = size(temp->sl[x].il[y].fam_members[memb_idx].conditions,5)
          FOR (cond_idx = 1 TO cond_cnt)
            term_line_cnt = size(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].
             src_str_lines,5)
            FOR (term_line_idx = 1 TO term_line_cnt)
              col 8, temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].src_str_lines[
              term_line_idx].aline, row + 1
            ENDFOR
            IF ((temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].fhx_value_flag=0))
             col 12, captions->snegative, row + 1
            ELSEIF ((temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].fhx_value_flag=2))
             col 12, captions->sunknown, row + 1
            ELSE
             FOR (line = 1 TO size(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].
              onset_lines,5))
               col 12, temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].onset_lines[line]
               .aline, row + 1
             ENDFOR
             cmnt_cnt = size(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].comments,5)
             IF (cmnt_cnt > 0)
              col 12, captions->scomments, ": ",
              row + 1
             ENDIF
             FOR (cmnt_idx = 1 TO cmnt_cnt)
               IF (cmnt_idx > 1)
                col 16, " ", row + 1
               ENDIF
               IF ((temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].comments[cmnt_idx].
               comment_prsnl_name > ""))
                col 16, temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].comments[
                cmnt_idx].comment_dt_tm_str, " - ",
                temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].comments[cmnt_idx].
                comment_prsnl_name, row + 1
               ENDIF
               FOR (line = 1 TO size(temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].
                comments[cmnt_idx].comment_lines,5))
                 col 16, temp->sl[x].il[y].fam_members[memb_idx].conditions[cond_idx].comments[
                 cmnt_idx].comment_lines[line].line, row + 1
               ENDFOR
             ENDFOR
            ENDIF
          ENDFOR
        ENDFOR
       ENDIF
       IF ((temp->sl[x].il[y].input_type=problemdx_control))
        prob_count = size(temp->sl[x].il[y].problem_list,5)
        IF (prob_count > 0)
         col 1, captions->sproblem, row + 1
         FOR (prob_ind = 1 TO prob_count)
           prob_desc_size = size(temp->sl[x].il[y].problem_list[prob_ind].problem_tag,5)
           FOR (prob_desc_idx = 1 TO prob_desc_size)
             col 2, temp->sl[x].il[y].problem_list[prob_ind].problem_tag[prob_desc_idx].problem_line,
             row + 1
           ENDFOR
           IF ((temp->sl[x].il[y].problem_list[prob_ind].problem_recorder > " "))
            col 4, captions->sproblemrecorder, col 50,
            temp->sl[x].il[y].problem_list[prob_ind].problem_recorder, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].problem_list[prob_ind].confirmation_disp > " "))
            col 4, captions->sproblemconfirmation, col 50,
            temp->sl[x].il[y].problem_list[prob_ind].confirmation_disp, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].problem_list[prob_ind].qualifier_disp > " "))
            col 4, captions->sproblemqualifier, col 50,
            temp->sl[x].il[y].problem_list[prob_ind].qualifier_disp, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].problem_list[prob_ind].onset_dt_tm_str > " "))
            col 4, captions->sproblemonsetdt, col 50,
            temp->sl[x].il[y].problem_list[prob_ind].onset_dt_tm_str, row + 1
           ENDIF
         ENDFOR
        ENDIF
        dx_count = size(temp->sl[x].il[y].diagnosis,5)
        IF (dx_count > 0)
         col 1, captions->sdx, row + 1
         FOR (dxind = 1 TO dx_count)
           dx_desc_size = size(temp->sl[x].il[y].diagnosis[dxind].diagnosis_tag,5)
           FOR (dx_desc_idx = 1 TO dx_desc_size)
             col 2, temp->sl[x].il[y].diagnosis[dxind].diagnosis_tag[dx_desc_idx].diagnosis_line, row
              + 1
           ENDFOR
           IF ((temp->sl[x].il[y].diagnosis[dxind].diagnosis_qualifier_disp > " "))
            col 4, captions->sdxqualifier, col 50,
            temp->sl[x].il[y].diagnosis[dxind].diagnosis_qualifier_disp, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].diagnosis[dxind].diagnosis_confirmation_disp > " "))
            col 4, captions->sdxconfirmation, col 50,
            temp->sl[x].il[y].diagnosis[dxind].diagnosis_confirmation_disp, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].diagnosis[dxind].diagnosis_type_disp > " "))
            col 4, captions->sdxtype, col 50,
            temp->sl[x].il[y].diagnosis[dxind].diagnosis_type_disp, row + 1
           ENDIF
           IF ((temp->sl[x].il[y].diagnosis[dxind].diagnosis_onset_dtstr > " "))
            col 4, captions->sdxonsetdttm, col 50,
            temp->sl[x].il[y].diagnosis[dxind].diagnosis_onset_dtstr, row + 1
           ENDIF
         ENDFOR
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
  FOOT PAGE
   numrows = row, stat = alterlist(reply->qual,((ln+ numrows)+ 1))
   FOR (pagevar = 0 TO numrows)
     ln = (ln+ 1), reply->qual[ln].line = reportrow((pagevar+ 1)), done = "F"
     WHILE (done="F")
      nullpos = findstring(char(0),reply->qual[ln].line),
      IF (nullpos > 0)
       stat = movestring(" ",1,reply->qual[ln].line,nullpos,1)
      ELSE
       done = "T"
      ENDIF
     ENDWHILE
   ENDFOR
  WITH nocounter, maxcol = 250, maxrow = 104
 ;end select
#print_act_end
 SUBROUTINE problem_formatting(sect,ctrl,probindex)
   SET pt->line_cnt = 0
   EXECUTE dcp_parse_text value(temp->sl[sect].il[ctrl].problem_list[probindex].problem_desc), 70
   SET stat = alterlist(temp->sl[sect].il[ctrl].problem_list[probindex].problem_tag,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].problem_list[probindex].problem_tag[x].problem_line = pt->lns[x].
     line
   ENDFOR
 END ;Subroutine
 SUBROUTINE dx_formatting(sect,ctrl,dxindex)
   SET pt->line_cnt = 0
   EXECUTE dcp_parse_text temp->sl[sect].il[ctrl].diagnosis[dxindex].diagnosis_desc, 70
   SET stat = alterlist(temp->sl[sect].il[ctrl].diagnosis[dxindex].diagnosis_tag,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].diagnosis[dxindex].diagnosis_tag[x].diagnosis_line = pt->lns[x].line
   ENDFOR
 END ;Subroutine
 SUBROUTINE gest_formatting(sect,ctrl,gestindex)
   SET pt->line_cnt = 0
   EXECUTE dcp_parse_text temp->sl[sect].il[ctrl].gestational[gestindex].gest_comment, 70
   SET stat = alterlist(temp->sl[sect].il[ctrl].gestational[gestindex].gest_tag,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].gestational[gestindex].gest_tag[x].gest_line = pt->lns[x].line
   ENDFOR
 END ;Subroutine
 SUBROUTINE encntr_formatting(sect,ctrl,encindex)
   SET pt->line_cnt = 0
   EXECUTE dcp_parse_text temp->sl[sect].il[ctrl].tracking_cmt[encindex].tracking_comment, 70
   SET stat = alterlist(temp->sl[sect].il[ctrl].tracking_cmt[encindex].tracking_tag,pt->line_cnt)
   FOR (x = 1 TO pt->line_cnt)
     SET temp->sl[sect].il[ctrl].tracking_cmt[encindex].tracking_tag[x].tracking_line = pt->lns[x].
     line
   ENDFOR
 END ;Subroutine
#exit_script
 SET reply->num_lines = ln
 IF ((reply->num_lines > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
 FREE RECORD pt
 FREE RECORD temp
 FREE RECORD captions
 FREE RECORD encntr_temp
 FREE RECORD code_temp
 FREE RECORD flist_temp
 FREE RECORD birth_temp
 FREE RECORD blob
END GO
