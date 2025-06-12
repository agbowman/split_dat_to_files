CREATE PROGRAM cp_powerforms_chart:dba
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
 RECORD birth_temp(
   1 birth_temp_dt = dq8
   1 birth_temp_tz = i4
 )
 RECORD form_temp(
   1 forms[*]
     2 dcp_forms_activity_id = f8
     2 form_start_line_idx = i4
     2 form_total_line = i4
 )
 DECLARE xr_indicator = i2 WITH public, noconstant(0)
 DECLARE xr_font_size = i4 WITH public, noconstant(10)
 DECLARE xr_page_width_in_inches = f8 WITH public, noconstant(7.5)
 DECLARE encntr_cnt = i4 WITH protect, noconstant(0)
 DECLARE person_id = f8 WITH protect, noconstant(0)
 DECLARE dummyvoid = i2 WITH constant(0)
 DECLARE cp_prsnl_id = f8 WITH protect, noconstant(0)
 RECORD reply(
   1 num_lines = f8
   1 qual[*]
     2 line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 CALL fillcaptions(dummyvoid)
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
   SET reply->status_data[1].status = "Z"
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE esc_cnt = i4 WITH constant(size(request->code_list,5)), protect
 IF (esc_cnt=0)
  SET reply->status_data[1].status = "Z"
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
  SET reply->status_data[1].status = "Z"
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
   IF ((request->result_lookup_ind=1))
    SELECT INTO "nl:"
     FROM (dummyt d2  WITH value(fr_idx_cnt)),
      dcp_forms_activity dfa
     PLAN (d2
      WHERE assign(cp_expand_start,evaluate(d2.seq,1,1,(cp_expand_start+ exp_max_cnt))))
      JOIN (dfa
      WHERE expand(encntr_idx,encntr_start,encntr_end,dfa.encntr_id,encntr_temp->encntr_qual[
       encntr_idx].encntr_id)
       AND expand(cp_expand_idx,cp_expand_start,(cp_expand_start+ (exp_max_cnt - 1)),dfa
       .dcp_forms_ref_id,flist_temp->fref_l[cp_expand_idx].dcp_forms_ref_id)
       AND dfa.form_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
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
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d2  WITH value(fr_idx_cnt)),
      dcp_forms_activity dfa,
      clinical_event ce,
      dcp_forms_activity_comp dfac
     PLAN (d2
      WHERE assign(cp_expand_start,evaluate(d2.seq,1,1,(cp_expand_start+ exp_max_cnt))))
      JOIN (dfa
      WHERE expand(encntr_idx,1,encntr_cnt,dfa.encntr_id,encntr_temp->encntr_qual[encntr_idx].
       encntr_id)
       AND expand(cp_expand_idx,cp_expand_start,(cp_expand_start+ (exp_max_cnt - 1)),dfa
       .dcp_forms_ref_id,flist_temp->fref_l[cp_expand_idx].dcp_forms_ref_id))
      JOIN (dfac
      WHERE dfa.dcp_forms_activity_id=dfac.dcp_forms_activity_id)
      JOIN (ce
      WHERE dfac.parent_entity_id=ce.event_id
       AND ce.valid_until_dt_tm=cnvtdatetime("31-Dec-2100,00:00:00")
       AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(s_date) AND cnvtdatetime(e_date))
     ORDER BY dfa.encntr_id, dfa.dcp_forms_ref_id, dfa.dcp_forms_activity_id
     HEAD dfa.dcp_forms_ref_id
      cp_loc_pos = locateval(cp_loc_idx,1,frcnt,dfa.dcp_forms_ref_id,flist->fref_l[cp_loc_idx].
       dcp_forms_ref_id), facnt = flist->fref_l[cp_loc_idx].fact_cnt
     HEAD dfa.dcp_forms_activity_id
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
   ENDIF
 ENDFOR
 SET stat = alterlist(flist->fref_l,frcnt)
 SET reply->num_lines = 0
 IF (one_found="N")
  CALL echo(build("one_found: ",one_found))
  SET reply->status_data[1].status = "Z"
  GO TO exit_script
 ENDIF
 SET cp_prsnl_id = reqinfo->updt_id
 IF (validate(request->request_prsnl_id))
  SET reqinfo->updt_id = request->request_prsnl_id
 ENDIF
 EXECUTE cp_powerforms_chart_impl
 SET reqinfo->updt_id = cp_prsnl_id
 IF ((reply->status_data.status="F"))
  GO TO exit_script
 ELSEIF ((reply->num_lines > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 CALL echorecord(reply)
 FREE RECORD temp
 FREE RECORD captions
 FREE RECORD encntr_temp
 FREE RECORD code_temp
 FREE RECORD flist_temp
END GO
