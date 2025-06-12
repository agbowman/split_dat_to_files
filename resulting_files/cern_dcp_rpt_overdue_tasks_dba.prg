CREATE PROGRAM cern_dcp_rpt_overdue_tasks:dba
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
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD cern_captions(
   1 overduetasks = vc
   1 alltask = vc
   1 name = vc
   1 mrn = vc
   1 location = vc
   1 taskdesc = vc
   1 details = vc
   1 timeoverdue = vc
   1 taskdate = vc
   1 tasktime = vc
   1 taskstaus = vc
   1 pageno = vc
   1 printdate = vc
   1 printtime = vc
   1 nooverdue = vc
   1 notask = vc
   1 cnoreport1 = vc
   1 cnoreport2 = vc
   1 cnoreport3 = vc
   1 cnoreportvisit = vc
 )
 SUBROUTINE fillcaptions(dummyvar)
   SET cern_captions->overduetasks = trim(uar_i18ngetmessage(i18nhandle,"OverdueTasks",
     "OVERDUE TASKS"))
   SET cern_captions->alltask = trim(uar_i18ngetmessage(i18nhandle,"Alltask","ALL TASKS"))
   SET cern_captions->taskstaus = trim(uar_i18ngetmessage(i18nhandle,"Taskstaus","Task Status"))
   SET cern_captions->name = trim(concat(uar_i18ngetmessage(i18nhandle,"Name","Name"),":"))
   SET cern_captions->mrn = trim(concat(uar_i18ngetmessage(i18nhandle,"MRN","MRN"),":"))
   SET cern_captions->location = trim(concat(uar_i18ngetmessage(i18nhandle,"Location","Location"),":"
     ))
   SET cern_captions->taskdesc = trim(uar_i18ngetmessage(i18nhandle,"TaskDesc","Task Description"))
   SET cern_captions->details = trim(uar_i18ngetmessage(i18nhandle,"Details","Details"))
   SET cern_captions->timeoverdue = trim(uar_i18ngetmessage(i18nhandle,"TimeOverdue","Time Overdue"))
   SET cern_captions->tasktime = trim(uar_i18ngetmessage(i18nhandle,"TaskTime","Time"))
   SET cern_captions->taskdate = trim(concat(uar_i18ngetmessage(i18nhandle,"TaskDate","Task Date"),
     "/",cern_captions->tasktime))
   SET cern_captions->printtime = trim(uar_i18ngetmessage(i18nhandle,"PrintTime","Time"))
   SET cern_captions->printdate = trim(concat(uar_i18ngetmessage(i18nhandle,"PrintDate","Print Date"),
     "/",cern_captions->tasktime,":"))
   SET cern_captions->pageno = trim(concat(uar_i18ngetmessage(i18nhandle,"PageNo","Page"),":"))
   SET cern_captions->nooverdue = trim(concat(uar_i18ngetmessage(i18nhandle,"NoOverdue",
      "There are no overdue tasks for this visit"),"."))
   SET cern_captions->notask = trim(concat(uar_i18ngetmessage(i18nhandle,"NoTask",
      "There are no tasks for the selected timeframe on this visit"),"."))
   SET cern_captions->cnoreport1 = trim(uar_i18ngetmessage(i18nhandle,"CNoReport1",
     "This report cannot be printed because the report type "))
   SET cern_captions->cnoreportvisit = trim(concat(cern_captions->cnoreport1," (",uar_i18ngetmessage(
      i18nhandle,"CNoReportVisit","Visit"),")"))
   SET cern_captions->cnoreport2 = trim(concat(cern_captions->cnoreportvisit,uar_i18ngetmessage(
      i18nhandle,"CNoReport2"," does not match the value")))
   SET cern_captions->cnoreport3 = trim(concat(uar_i18ngetmessage(i18nhandle,"CNoReport3",
      "defined in Code Set 16529 or the patient you have selected does not contain visit information"
      ),"."))
 END ;Subroutine
 RECORD cern_intake_captions(
   1 patientname = vc
   1 dob = vc
   1 admitphy = vc
   1 intakemrn = vc
   1 age = vc
   1 location = vc
   1 financenum = vc
   1 intakeoutputsumm = vc
   1 intakefor = vc
   1 typetotal = vc
   1 num0000_0759_1 = vc
   1 num0000_0759_2 = vc
   1 num0800_1559_1 = vc
   1 num0800_1559_2 = vc
   1 num1600_2359_1 = vc
   1 num1600_2359_2 = vc
   1 intake = vc
   1 ivfiulds = vc
   1 d5w = vc
   1 d5wcomment = vc
   1 ns = vc
   1 nscomment = vc
   1 normalkcl = vc
   1 normalkclcomment = vc
   1 ivintake = vc
   1 ivintakecomment = vc
   1 lr = vc
   1 lrcomment = vc
   1 d5wkcl = vc
   1 d5wkclcomment = vc
   1 d10w = vc
   1 d10wcomment = vc
   1 d545percentns1 = vc
   1 d545percentns2 = vc
   1 d545percentns3 = vc
   1 d545percentnscomment1 = vc
   1 d545percentnscomment2 = vc
   1 d545percentnscomment3 = vc
   1 d52percentns1 = vc
   1 d52percentns2 = vc
   1 d52percentns3 = vc
   1 d52percentnscomment1 = vc
   1 d52percentnscomment2 = vc
   1 d52percentnscomment3 = vc
   1 ivbolus = vc
   1 ivboluscomment = vc
   1 ivflush = vc
   1 ivflushcomment = vc
   1 plasmalmd5 = vc
   1 plasmalmd5comment = vc
   1 d545percentns20kcl1 = vc
   1 d545percentns20kcl2 = vc
   1 d545percentns20kcl3 = vc
   1 d545percentns20kclcomment1 = vc
   1 d545percentns20kclcomment2 = vc
   1 d545percentns20kclcomment3 = vc
   1 lrd5 = vc
   1 lrd5comment = vc
   1 d5wns = vc
   1 d5wnscomment = vc
   1 45percentns1 = vc
   1 45percentns2 = vc
   1 45percentnscomment1 = vc
   1 45percentnscomment2 = vc
   1 lasix = vc
   1 lasixcomment = vc
   1 nitroglycer = vc
   1 nitroglycercomment = vc
   1 dopamine = vc
   1 dopaminecomment = vc
   1 dobutamine = vc
   1 dobutaminecomment = vc
   1 lidocaine = vc
   1 lidocainecomment = vc
   1 theophylline = vc
   1 theophyllinecomment = vc
   1 insulin = vc
   1 insulincomment = vc
   1 othermedication = vc
   1 othermedicationcomment = vc
   1 oralfluids = vc
   1 oralintake = vc
   1 oralintakecomment = vc
   1 tubefeed = vc
   1 tubefeeds = vc
   1 tubefeedscomment = vc
   1 bloodprod = vc
   1 packedrbc = vc
   1 packedrbccomment = vc
   1 platel = vc
   1 platelcomment = vc
   1 freshfrozenpla = vc
   1 freshfrozenplacomment = vc
   1 wholeblood = vc
   1 wholebloodcomment = vc
   1 miscintake = vc
   1 otherintake = vc
   1 otherintakecomment = vc
   1 gastricflush = vc
   1 gastricflushcomment = vc
   1 cbiin = vc
   1 cbiincomment = vc
   1 parenteralnutri = vc
   1 tpn = vc
   1 tpncomment = vc
   1 lipids = vc
   1 lipidscomment = vc
   1 totalintake = vc
   1 output = vc
   1 urine = vc
   1 urinecomment = vc
   1 urinefoley = vc
   1 urinefoleycomment = vc
   1 urinevoid = vc
   1 urinevoidcomment = vc
   1 ashvoids = vc
   1 ashvoidscomment = vc
   1 drains = vc
   1 wonddrain = vc
   1 wonddraincomment = vc
   1 chesttubedrain = vc
   1 chesttubedraincomment = vc
   1 gastricoutput = vc
   1 emesis = vc
   1 emesiscomment = vc
   1 ngdrain = vc
   1 ngdraincomment = vc
   1 gastricresidual = vc
   1 gastricresidualcomment = vc
   1 stooloutput = vc
   1 stoolcount = vc
   1 stoolcountcomment = vc
   1 ostomyoutput = vc
   1 ostomyoutputcomment = vc
   1 liquidstool = vc
   1 liquidstoolcomment = vc
   1 diapercount = vc
   1 diapercountcomment = vc
   1 diaperweight = vc
   1 diaperweightcomment = vc
   1 miscoutput = vc
   1 otheroutput = vc
   1 otheroutputcomment = vc
   1 padcount = vc
   1 padcountcomment = vc
   1 bloodloss = vc
   1 bloodlosscomment = vc
   1 cbiout = vc
   1 cbioutcomment = vc
   1 totaloutput = vc
   1 balance = vc
   1 totalfluidbalance = vc
   1 pagenum = vc
   1 noreport1 = vc
   1 noreport2 = vc
   1 noreport3 = vc
   1 noreportvisit = vc
 )
 SUBROUTINE fillcaptionsintake(dummyvar)
   SET cern_intake_captions->patientname = trim(concat(uar_i18ngetmessage(i18nhandle,"PatientName",
      "Patient Name"),":"))
   SET cern_intake_captions->dob = trim(concat(uar_i18ngetmessage(i18nhandle,"DOB","Date of Birth"),
     ":"))
   SET cern_intake_captions->admitphy = trim(concat(uar_i18ngetmessage(i18nhandle,"AdmitPhy",
      "Admitting Physician"),":"))
   SET cern_intake_captions->intakemrn = trim(concat(uar_i18ngetmessage(i18nhandle,"InTakeMRN",
      "Med Rec Num"),":"))
   SET cern_intake_captions->age = trim(concat(uar_i18ngetmessage(i18nhandle,"Age","Age"),":"))
   SET cern_intake_captions->location = trim(concat(uar_i18ngetmessage(i18nhandle,"Location",
      "Location"),":"))
   SET cern_intake_captions->financenum = trim(concat(uar_i18ngetmessage(i18nhandle,"FinanceNum",
      "Financial Num"),":"))
   SET cern_intake_captions->intakeoutputsumm = trim(uar_i18ngetmessage(i18nhandle,"IntakeOutputSumm",
     "Intake and Output Summary"))
   SET cern_intake_captions->intakefor = trim(uar_i18ngetmessage(i18nhandle,"IntakeFor","For"))
   SET cern_intake_captions->typetotal = trim(uar_i18ngetmessage(i18nhandle,"TypeTotal","Type Total")
    )
   SET cern_intake_captions->num0000_0759_1 = trim(concat(uar_i18ngetmessage(i18nhandle,
      "Num0000_0759_1","0000 "),"-"))
   SET cern_intake_captions->num0000_0759_2 = trim(concat(cern_intake_captions->num0000_0759_1,
     uar_i18ngetmessage(i18nhandle,"Num0000_0759_2"," 0759")))
   SET cern_intake_captions->num0800_1559_1 = trim(concat(uar_i18ngetmessage(i18nhandle,
      "Num0800_1559_1","0800 "),"-"))
   SET cern_intake_captions->num0800_1559_2 = trim(concat(cern_intake_captions->num0800_1559_1,
     uar_i18ngetmessage(i18nhandle,"Num0800_1559_2"," 1559")))
   SET cern_intake_captions->num1600_2359_1 = trim(concat(uar_i18ngetmessage(i18nhandle,
      "Num1600_2359_1","1600 "),"-"))
   SET cern_intake_captions->num1600_2359_2 = trim(concat(cern_intake_captions->num1600_2359_1,
     uar_i18ngetmessage(i18nhandle,"Num1600_2359_2"," 2359")))
   SET cern_intake_captions->intake = trim(uar_i18ngetmessage(i18nhandle,"Intake","INTAKE"))
   SET cern_intake_captions->ivfiulds = trim(uar_i18ngetmessage(i18nhandle,"IVFiulds","IV Fluids"))
   SET cern_intake_captions->d5w = trim(uar_i18ngetmessage(i18nhandle,"D5W","D5W"))
   SET cern_intake_captions->d5wcomment = trim(concat(uar_i18ngetmessage(i18nhandle,"D5WComment",
      "D5W comment"),":"))
   SET cern_intake_captions->ns = trim(uar_i18ngetmessage(i18nhandle,"NS","NS"))
   SET cern_intake_captions->nscomment = trim(concat(uar_i18ngetmessage(i18nhandle,"NSComment",
      "NS comment"),":"))
   SET cern_intake_captions->normalkcl = trim(uar_i18ngetmessage(i18nhandle,"NormalKCL",
     "Normal Saline with KCl"))
   SET cern_intake_captions->normalkclcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "NormalKCLComment","Normal Saline with KCl"),":"))
   SET cern_intake_captions->ivintake = trim(uar_i18ngetmessage(i18nhandle,"IVIntake","IV Intake"))
   SET cern_intake_captions->ivintakecomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "IVIntakeComment","IV Intake comment"),":"))
   SET cern_intake_captions->lr = trim(uar_i18ngetmessage(i18nhandle,"LR","LR"))
   SET cern_intake_captions->lrcomment = trim(concat(uar_i18ngetmessage(i18nhandle,"LRComment",
      "LR comment"),":"))
   SET cern_intake_captions->d5wkcl = trim(uar_i18ngetmessage(i18nhandle,"D5WKCL","D5W with KCl"))
   SET cern_intake_captions->d5wkclcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "D5WKCLComment","D5W with KCl comment"),":"))
   SET cern_intake_captions->d10w = trim(uar_i18ngetmessage(i18nhandle,"D10W","D10W"))
   SET cern_intake_captions->d10wcomment = trim(concat(uar_i18ngetmessage(i18nhandle,"D10WComment",
      "D10W comment"),":"))
   SET cern_intake_captions->d545percentns1 = trim(concat(uar_i18ngetmessage(i18nhandle,
      "D545PercentNS1","D5 "),"."))
   SET cern_intake_captions->d545percentns2 = trim(concat(cern_intake_captions->d545percentns1,
     uar_i18ngetmessage(i18nhandle,"D545PercentNS2","45"),"%"))
   SET cern_intake_captions->d545percentns3 = trim(concat(cern_intake_captions->d545percentns2,
     uar_i18ngetmessage(i18nhandle,"D545PercentNS3","  NS")))
   SET cern_intake_captions->d545percentnscomment1 = trim(concat(uar_i18ngetmessage(i18nhandle,
      "D545PercentNSComment1","D5 "),"."))
   SET cern_intake_captions->d545percentnscomment2 = trim(concat(cern_intake_captions->
     d545percentnscomment1,uar_i18ngetmessage(i18nhandle,"D545PercentNSComment2","45"),"%"))
   SET cern_intake_captions->d545percentnscomment3 = trim(concat(cern_intake_captions->
     d545percentnscomment2,uar_i18ngetmessage(i18nhandle,"D52PercentNSComment3","  NS comment"),":"))
   SET cern_intake_captions->d52percentns1 = trim(concat(uar_i18ngetmessage(i18nhandle,
      "D52PercentNS1","D5 "),"."))
   SET cern_intake_captions->d52percentns2 = trim(concat(cern_intake_captions->d52percentns1,
     uar_i18ngetmessage(i18nhandle,"D52PercentNS2","2"),"%"))
   SET cern_intake_captions->d52percentns3 = trim(concat(cern_intake_captions->d52percentns2,
     uar_i18ngetmessage(i18nhandle,"D52PercentNS3","  NS")))
   SET cern_intake_captions->d52percentnscomment1 = trim(concat(uar_i18ngetmessage(i18nhandle,
      "D52PercentNSComment1","D5 "),"."))
   SET cern_intake_captions->d52percentnscomment2 = trim(concat(cern_intake_captions->
     d52percentnscomment1,uar_i18ngetmessage(i18nhandle,"D52PercentNSComment2","2"),"%"))
   SET cern_intake_captions->d52percentnscomment3 = trim(concat(cern_intake_captions->
     d52percentnscomment2,uar_i18ngetmessage(i18nhandle,"D52PercentNSComment3","  NS comment"),":"))
   SET cern_intake_captions->ivbolus = trim(uar_i18ngetmessage(i18nhandle,"IVBolus","IV Bolus"))
   SET cern_intake_captions->ivboluscomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "IVBolusComment","IV Bolus comment"),":"))
   SET cern_intake_captions->ivflush = trim(uar_i18ngetmessage(i18nhandle,"IVFlush","IV Flush"))
   SET cern_intake_captions->ivflushcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "IVFlushComment","IV Flush comment"),":"))
   SET cern_intake_captions->plasmalmd5 = trim(uar_i18ngetmessage(i18nhandle,"PlasmalMD5",
     "Plasmalyte M D5"))
   SET cern_intake_captions->plasmalmd5comment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "PlasmalMD5Comment","Plasmalyte M D5 comment"),":"))
   SET cern_intake_captions->d545percentns20kcl1 = trim(concat(uar_i18ngetmessage(i18nhandle,
      "D545PercentNS20KCL1","D5 "),"."))
   SET cern_intake_captions->d545percentns20kcl2 = trim(concat(cern_intake_captions->
     d545percentns20kcl1,uar_i18ngetmessage(i18nhandle,"D545PercentNS20KCL2","45"),"%"))
   SET cern_intake_captions->d545percentns20kcl3 = trim(concat(cern_intake_captions->
     d545percentns20kcl2,uar_i18ngetmessage(i18nhandle,"D545PercentNS20KCL3","  NS 20 KCl")))
   SET cern_intake_captions->d545percentns20kclcomment1 = trim(concat(uar_i18ngetmessage(i18nhandle,
      "D545PercentNS20KCLComment1","D5 "),"."))
   SET cern_intake_captions->d545percentns20kclcomment2 = trim(concat(cern_intake_captions->
     d545percentns20kclcomment1,uar_i18ngetmessage(i18nhandle,"D545PercentNS20KCLComment2","45"),"%"
     ))
   SET cern_intake_captions->d545percentns20kclcomment3 = trim(concat(cern_intake_captions->
     d545percentns20kclcomment2,uar_i18ngetmessage(i18nhandle,"D545PercentNS20KCLComment3",
      "  NS 20 KCl comment"),":"))
   SET cern_intake_captions->lrd5 = trim(uar_i18ngetmessage(i18nhandle,"LRD5","LR D5"))
   SET cern_intake_captions->lrd5comment = trim(concat(uar_i18ngetmessage(i18nhandle,"LRD5Comment",
      "LR D5 comment"),":"))
   SET cern_intake_captions->d5wns = trim(uar_i18ngetmessage(i18nhandle,"D5WNS","D5WNS"))
   SET cern_intake_captions->d5wnscomment = trim(concat(uar_i18ngetmessage(i18nhandle,"D5WNSComment",
      "D5WNS comment"),":"))
   SET cern_intake_captions->45percentns1 = trim(concat(".",uar_i18ngetmessage(i18nhandle,
      "45PercentNS1","45"),"%"))
   SET cern_intake_captions->45percentns2 = trim(concat(cern_intake_captions->45percentns1,
     uar_i18ngetmessage(i18nhandle,"45PercentNS2"," NS")))
   SET cern_intake_captions->45percentnscomment1 = trim(concat(".",uar_i18ngetmessage(i18nhandle,
      "45PercentNSComment1","45"),"%"))
   SET cern_intake_captions->45percentnscomment2 = trim(concat(cern_intake_captions->
     45percentnscomment1,uar_i18ngetmessage(i18nhandle,"45PercentNSComment2"," NS comment"),":"))
   SET cern_intake_captions->lasix = trim(uar_i18ngetmessage(i18nhandle,"Lasix","Lasix"))
   SET cern_intake_captions->lasixcomment = trim(concat(uar_i18ngetmessage(i18nhandle,"LasixComment",
      "Lasix comment"),":"))
   SET cern_intake_captions->nitroglycer = trim(uar_i18ngetmessage(i18nhandle,"Nitroglycer",
     "Nitroglycerine"))
   SET cern_intake_captions->nitroglycercomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "NitroglycerComment","Nitroglycerine comment"),":"))
   SET cern_intake_captions->dopamine = trim(uar_i18ngetmessage(i18nhandle,"Dopamine","Dopamine"))
   SET cern_intake_captions->dopaminecomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "DopamineComment","Dopamine comment"),":"))
   SET cern_intake_captions->dobutamine = uar_i18ngetmessage(i18nhandle,"Dobutamine","Dobutamine")
   SET cern_intake_captions->dobutaminecomment = concat(uar_i18ngetmessage(i18nhandle,
     "DobutamineComment","Dobutamine comment"),":")
   SET cern_intake_captions->lidocaine = trim(uar_i18ngetmessage(i18nhandle,"Lidocaine","Lidocaine"))
   SET cern_intake_captions->lidocainecomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "LidocaineComment","Lidocaine comment"),":"))
   SET cern_intake_captions->theophylline = trim(uar_i18ngetmessage(i18nhandle,"Theophylline",
     "Theophylline"))
   SET cern_intake_captions->theophyllinecomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "TheophyllineComment","Theophylline comment"),":"))
   SET cern_intake_captions->insulin = trim(uar_i18ngetmessage(i18nhandle,"Insulin","Insulin"))
   SET cern_intake_captions->insulincomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "InsulinComment","Insulin comment"),":"))
   SET cern_intake_captions->othermedication = trim(uar_i18ngetmessage(i18nhandle,"OtherMedication",
     "Other Medication"))
   SET cern_intake_captions->othermedicationcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "OtherMedicationComment","Other Medication comment"),":"))
   SET cern_intake_captions->oralfluids = trim(uar_i18ngetmessage(i18nhandle,"OralFluids",
     "Oral Fluids"))
   SET cern_intake_captions->oralintake = trim(uar_i18ngetmessage(i18nhandle,"OralIntake",
     "Oral Intake"))
   SET cern_intake_captions->oralintakecomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "OralIntakeComment","Oral Intake comment"),":"))
   SET cern_intake_captions->tubefeed = uar_i18ngetmessage(i18nhandle,"TubeFeed","Tube Feeding")
   SET cern_intake_captions->tubefeeds = uar_i18ngetmessage(i18nhandle,"TubeFeeds","Tube Feedings")
   SET cern_intake_captions->tubefeedscomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "TubeFeedsComment","Tube Feedings comment"),":"))
   SET cern_intake_captions->bloodprod = trim(uar_i18ngetmessage(i18nhandle,"BloodProd",
     "Blood Products"))
   SET cern_intake_captions->packedrbc = trim(uar_i18ngetmessage(i18nhandle,"PackedRBC",
     "Packed Red Blood Cells"))
   SET cern_intake_captions->packedrbccomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "PackedRBCComment","Packed Red Blood Cells comment"),":"))
   SET cern_intake_captions->platel = trim(uar_i18ngetmessage(i18nhandle,"Platel","Platelets"))
   SET cern_intake_captions->platelcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "PlatelComment","Platelets comment"),":"))
   SET cern_intake_captions->freshfrozenpla = trim(uar_i18ngetmessage(i18nhandle,"FreshFrozenPla",
     "Fresh Frozen Plasma"))
   SET cern_intake_captions->freshfrozenplacomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "FreshFrozenPlaComment","Fresh Frozen Plasma comment"),":"))
   SET cern_intake_captions->wholeblood = trim(uar_i18ngetmessage(i18nhandle,"WholeBlood",
     "Whole Blood"))
   SET cern_intake_captions->wholebloodcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "WholeBloodComment","Whole Blood comment"),":"))
   SET cern_intake_captions->miscintake = trim(uar_i18ngetmessage(i18nhandle,"MiscIntake",
     "Miscellaneous Intake"))
   SET cern_intake_captions->otherintake = trim(uar_i18ngetmessage(i18nhandle,"OtherIntake",
     "Other Intake"))
   SET cern_intake_captions->otherintakecomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "OtherIntakeComment","Other Intake comment"),":"))
   SET cern_intake_captions->gastricflush = trim(uar_i18ngetmessage(i18nhandle,"GastricFlush",
     "Gastric Flush"))
   SET cern_intake_captions->gastricflushcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "GastricFlushComment","Gastric Flush comment"),":"))
   SET cern_intake_captions->cbiin = trim(uar_i18ngetmessage(i18nhandle,"CBIIn","CBI In"))
   SET cern_intake_captions->cbiincomment = trim(concat(uar_i18ngetmessage(i18nhandle,"CBIInComment",
      "CBI In comment"),":"))
   SET cern_intake_captions->parenteralnutri = trim(uar_i18ngetmessage(i18nhandle,"ParenteralNutri",
     "Parenteral Nutrition"))
   SET cern_intake_captions->tpn = trim(uar_i18ngetmessage(i18nhandle,"TPN","TPN"))
   SET cern_intake_captions->tpncomment = trim(concat(uar_i18ngetmessage(i18nhandle,"TPNComment",
      "TPN comment"),":"))
   SET cern_intake_captions->lipids = trim(uar_i18ngetmessage(i18nhandle,"Lipids","Lipids"))
   SET cern_intake_captions->lipidscomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "LipidsComment","Lipids comment"),":"))
   SET cern_intake_captions->totalintake = trim(uar_i18ngetmessage(i18nhandle,"TotalIntake",
     "TOTAL INTAKE"))
   SET cern_intake_captions->output = trim(uar_i18ngetmessage(i18nhandle,"Output","OUTPUT"))
   SET cern_intake_captions->urine = trim(uar_i18ngetmessage(i18nhandle,"Urine","Urine"))
   SET cern_intake_captions->urinecomment = trim(concat(uar_i18ngetmessage(i18nhandle,"UrineComment",
      "Urine comment"),":"))
   SET cern_intake_captions->urinefoley = trim(uar_i18ngetmessage(i18nhandle,"UrineFoley",
     "Urine Foley"))
   SET cern_intake_captions->urinefoleycomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "UrineFoleyComment","Urine Foley comment"),":"))
   SET cern_intake_captions->urinevoid = trim(uar_i18ngetmessage(i18nhandle,"UrineVoid",
     "Urine Voided"))
   SET cern_intake_captions->urinevoidcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "UrineVoidComment","Urine Voided comment"),":"))
   SET cern_intake_captions->ashvoids = trim(concat("#",uar_i18ngetmessage(i18nhandle,"AshVoids",
      "of Voids")))
   SET cern_intake_captions->ashvoidscomment = trim(concat("#",uar_i18ngetmessage(i18nhandle,
      "AshVoidsComment","of Voids"),":"))
   SET cern_intake_captions->drains = trim(uar_i18ngetmessage(i18nhandle,"Drains","Drains"))
   SET cern_intake_captions->wonddrain = trim(uar_i18ngetmessage(i18nhandle,"WondDrain",
     "Wound Drainage"))
   SET cern_intake_captions->wonddraincomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "WondDrainComment","Wound Drainage comment"),":"))
   SET cern_intake_captions->chesttubedrain = trim(uar_i18ngetmessage(i18nhandle,"ChestTubeDrain",
     "Chest Tube Drainage"))
   SET cern_intake_captions->chesttubedraincomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "ChestTubeDrainComment","Chest Tube Drainage comment"),":"))
   SET cern_intake_captions->gastricoutput = trim(uar_i18ngetmessage(i18nhandle,"GastricOutput",
     "Gastric Output"))
   SET cern_intake_captions->emesis = trim(uar_i18ngetmessage(i18nhandle,"Emesis","Emesis"))
   SET cern_intake_captions->emesiscomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "EmesisComment","Emesis comment"),":"))
   SET cern_intake_captions->ngdrain = trim(uar_i18ngetmessage(i18nhandle,"NGDrain","NG Drainage"))
   SET cern_intake_captions->ngdraincomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "NGDrainComment","NG Drainage comment"),":"))
   SET cern_intake_captions->gastricresidual = trim(uar_i18ngetmessage(i18nhandle,"GastricResidual",
     "Gastric Residual"))
   SET cern_intake_captions->gastricresidualcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "GastricResidualComment","Gastric Residual comment"),":"))
   SET cern_intake_captions->stooloutput = trim(uar_i18ngetmessage(i18nhandle,"StoolOutput",
     "Stool Output"))
   SET cern_intake_captions->stoolcount = trim(uar_i18ngetmessage(i18nhandle,"StoolCount",
     "Stool Count"))
   SET cern_intake_captions->stoolcountcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "StoolCountComment","Stool Count comment"),":"))
   SET cern_intake_captions->ostomyoutput = trim(uar_i18ngetmessage(i18nhandle,"OstomyOutput",
     "Ostomy Output"))
   SET cern_intake_captions->ostomyoutputcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "OstomyOutputComment","Ostomy Output comment"),":"))
   SET cern_intake_captions->liquidstool = trim(uar_i18ngetmessage(i18nhandle,"LiquidStool",
     "Liquid Stool"))
   SET cern_intake_captions->liquidstoolcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "LiquidStoolComment","Liquid Stool comment"),":"))
   SET cern_intake_captions->diapercount = trim(uar_i18ngetmessage(i18nhandle,"DiaperCount",
     "Diaper Count"))
   SET cern_intake_captions->diapercountcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "DiaperCountComment","Diaper Count comment"),":"))
   SET cern_intake_captions->diaperweight = trim(uar_i18ngetmessage(i18nhandle,"DiaperWeight",
     "Diaper Weight"))
   SET cern_intake_captions->diaperweightcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "DiaperWeightComment","Diaper Weight comment"),":"))
   SET cern_intake_captions->miscoutput = trim(uar_i18ngetmessage(i18nhandle,"MiscOutput",
     "Miscellaneous Output"))
   SET cern_intake_captions->otheroutput = trim(uar_i18ngetmessage(i18nhandle,"OtherOutput",
     "Other Output"))
   SET cern_intake_captions->otheroutputcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "OtherOutputComment","Other Output comment"),":"))
   SET cern_intake_captions->padcount = trim(uar_i18ngetmessage(i18nhandle,"PadCount","Pad Count"))
   SET cern_intake_captions->padcountcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "PadCountComment","Pad Count comment"),":"))
   SET cern_intake_captions->bloodloss = trim(uar_i18ngetmessage(i18nhandle,"BloodLoss","Blood Loss")
    )
   SET cern_intake_captions->bloodlosscomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "BloodLossComment","Blood Loss comment"),":"))
   SET cern_intake_captions->cbiout = trim(uar_i18ngetmessage(i18nhandle,"CBIOut","CBI Out"))
   SET cern_intake_captions->cbioutcomment = trim(concat(uar_i18ngetmessage(i18nhandle,
      "CBIOutComment","CBI Out comment"),":"))
   SET cern_intake_captions->totaloutput = trim(uar_i18ngetmessage(i18nhandle,"TotalOutput",
     "TOTAL OUTPUT"))
   SET cern_intake_captions->balance = trim(uar_i18ngetmessage(i18nhandle,"Balance","BALANCE"))
   SET cern_intake_captions->totalfluidbalance = trim(uar_i18ngetmessage(i18nhandle,
     "TotalFluidBalance","TOTAL FLUID BALANCE"))
   SET cern_intake_captions->pagenum = trim(uar_i18ngetmessage(i18nhandle,"PageNum","Page"))
   SET cern_intake_captions->noreport1 = trim(uar_i18ngetmessage(i18nhandle,"NoReport1",
     "This report cannot be printed because the report type "))
   SET cern_intake_captions->noreportvisit = trim(concat(cern_intake_captions->noreport1," (",
     uar_i18ngetmessage(i18nhandle,"NoReportVisit","Visit"),")"))
   SET cern_intake_captions->noreport2 = trim(concat(cern_intake_captions->noreportvisit,
     uar_i18ngetmessage(i18nhandle,"NoReport2"," does not match the value")))
   SET cern_intake_captions->noreport3 = trim(concat(uar_i18ngetmessage(i18nhandle,"NoReport3",
      "defined in Code Set 16529 or the patient you have selected does not contain visit information"
      ),"."))
 END ;Subroutine
 RECORD tasklist_caption(
   1 reportname = vc
   1 addbym = vc
   1 addbyl = vc
   1 altwithm = vc
   1 altwithl = vc
   1 bagstatm = vc
   1 bagstatl = vc
   1 clinicianm = vc
   1 clinicianl = vc
   1 completedtm = vc
   1 completedtl1 = vc
   1 completedtl2 = vc
   1 confidentm = vc
   1 confidentl = vc
   1 deptm = vc
   1 deptl = vc
   1 dosem = vc
   1 dosel = vc
   1 financialm = vc
   1 finaciall = vc
   1 frequencym = vc
   1 frequencyl = vc
   1 fromm = vc
   1 froml = vc
   1 infuseoverm = vc
   1 infuseoverl = vc
   1 ingresm = vc
   1 ingresl = vc
   1 isolationm = vc
   1 isolationl = vc
   1 lastdonedtm = vc
   1 lastdonedtl1 = vc
   1 lastdonedtl2 = vc
   1 lastdosem = vc
   1 lastdosel = vc
   1 lastgivenm = vc
   1 lastgivenl = vc
   1 lastsitem = vc
   1 lastsitel = vc
   1 mnemonicm = vc
   1 mnemonicl = vc
   1 notbeforem = vc
   1 notbeforel = vc
   1 orderdetm = vc
   1 orderdetl = vc
   1 orderstatusm = vc
   1 orderstatusl = vc
   1 priom = vc
   1 priol = vc
   1 provnamem = vc
   1 provnamel = vc
   1 ratem = vc
   1 ratel = vc
   1 reasonform = vc
   1 reasonforl = vc
   1 receviedm = vc
   1 receviedl = vc
   1 responseregm = vc
   1 responseregl = vc
   1 routem = vc
   1 routel = vc
   1 scheduleddtm = vc
   1 scheduleddtl = vc
   1 scheduleddttmm = vc
   1 scheduleddttml1 = vc
   1 scheduleddttml2 = vc
   1 startdttmm = vc
   1 startdttml1 = vc
   1 startdttml2 = vc
   1 stopdttm = vc
   1 stopdttl1 = vc
   1 stopdttl2 = vc
   1 strengthm = vc
   1 strengthl = vc
   1 subjectm = vc
   1 subjectl = vc
   1 taskdescm = vc
   1 taskdescl = vc
   1 status = vc
   1 taskstatus = vc
   1 tom = vc
   1 tol = vc
   1 typem = vc
   1 typel = vc
   1 locationm = vc
   1 locationl = vc
   1 locroombedm = vc
   1 locroombedl1 = vc
   1 locroombedl2 = vc
   1 locroombedl3 = vc
   1 mrnm = vc
   1 mrnl = vc
   1 namem = vc
   1 namel = vc
   1 roombdm = vc
   1 roombdl1 = vc
   1 roombdl2 = vc
   1 locroombdm = vc
   1 locroombdl1 = vc
   1 locroombdl2 = vc
   1 locroombdl3 = vc
   1 defaultm = vc
   1 defaultl = vc
   1 updtusernamem = vc
   1 updtusernamel = vc
   1 schedutimem = vc
   1 schedutimel = vc
   1 lastgivedttmm = vc
   1 lastgivedttml1 = vc
   1 lastgivedttml2 = vc
   1 lastvaluem = vc
   1 lastvaluel = vc
   1 desiredm = vc
   1 desiredl = vc
   1 patientname = vc
   1 pagemrn = vc
   1 ordercomment = vc
   1 pagenum = vc
 )
 SUBROUTINE fillcaptions_tasklist(dummyvar)
   SET tasklist_caption->patientname = trim(concat(uar_i18ngetmessage(i18nhandle,"Patientname",
      "Patient Name"),":"))
   SET tasklist_caption->pagemrn = trim(concat(uar_i18ngetmessage(i18nhandle,"PageMRN","MRN"),":"))
   SET tasklist_caption->ordercomment = trim(concat(uar_i18ngetmessage(i18nhandle,"OrderComment",
      "Order Comment"),":"))
   SET tasklist_caption->pagenum = trim(uar_i18ngetmessage(i18nhandle,"PageNum","Page"))
   SET tasklist_caption->reportname = trim(uar_i18ngetmessage(i18nhandle,"ReportName",
     "TASK LIST REPORT"))
   SET tasklist_caption->addbym = trim(uar_i18ngetmessage(i18nhandle,"AddbyM","ADDBY"))
   SET tasklist_caption->addbyl = trim(uar_i18ngetmessage(i18nhandle,"AddbyL","Added By"))
   SET tasklist_caption->altwithm = trim(uar_i18ngetmessage(i18nhandle,"AltwithM","ALTWITH"))
   SET tasklist_caption->altwithl = trim(uar_i18ngetmessage(i18nhandle,"AltWithL","Alternate With"))
   SET tasklist_caption->bagstatm = trim(uar_i18ngetmessage(i18nhandle,"BagstatM","BAGSTAT"))
   SET tasklist_caption->bagstatl = trim(uar_i18ngetmessage(i18nhandle,"BagstatL","Bag Status"))
   SET tasklist_caption->clinicianm = trim(uar_i18ngetmessage(i18nhandle,"ClinicianM","CLINICIAN"))
   SET tasklist_caption->clinicianl = trim(uar_i18ngetmessage(i18nhandle,"ClinicianL","Clinician"))
   SET tasklist_caption->completedtm = trim(uar_i18ngetmessage(i18nhandle,"CompletedtM","COMPLTDT"))
   SET tasklist_caption->completedtl1 = trim(uar_i18ngetmessage(i18nhandle,"CompletedtL",
     "Completed Dt"))
   SET tasklist_caption->completedtl2 = trim(concat(tasklist_caption->completedtl1,"/",
     uar_i18ngetmessage(i18nhandle,"CompletedtL2","Tm")))
   SET tasklist_caption->confidentm = trim(uar_i18ngetmessage(i18nhandle,"ConfidentM","CONFIDNTL"))
   SET tasklist_caption->confidentl = trim(uar_i18ngetmessage(i18nhandle,"ConfidentL","Confidential")
    )
   SET tasklist_caption->deptm = trim(uar_i18ngetmessage(i18nhandle,"DeptM","DEPT"))
   SET tasklist_caption->deptl = trim(uar_i18ngetmessage(i18nhandle,"DeptL","Department"))
   SET tasklist_caption->desiredm = trim(uar_i18ngetmessage(i18nhandle,"DesiredM","DESOUTCOME"))
   SET tasklist_caption->desiredl = trim(uar_i18ngetmessage(i18nhandle,"DesiredL","Desired Outcome"))
   SET tasklist_caption->dosem = trim(uar_i18ngetmessage(i18nhandle,"DoseM","DOSE"))
   SET tasklist_caption->dosel = trim(uar_i18ngetmessage(i18nhandle,"DoseL","Dose"))
   SET tasklist_caption->financialm = trim(uar_i18ngetmessage(i18nhandle,"FinancialM","FINNBR"))
   SET tasklist_caption->finaciall = trim(uar_i18ngetmessage(i18nhandle,"FinacialL","Financial Nbr"))
   SET tasklist_caption->frequencym = trim(uar_i18ngetmessage(i18nhandle,"FrequencyM","FREQ"))
   SET tasklist_caption->frequencyl = trim(uar_i18ngetmessage(i18nhandle,"FrequencyL","Frequency"))
   SET tasklist_caption->fromm = trim(uar_i18ngetmessage(i18nhandle,"FromM","FROM"))
   SET tasklist_caption->froml = trim(uar_i18ngetmessage(i18nhandle,"FromL","From"))
   SET tasklist_caption->infuseoverm = trim(uar_i18ngetmessage(i18nhandle,"InfuseOverM","INFUSEOVER")
    )
   SET tasklist_caption->infuseoverl = trim(uar_i18ngetmessage(i18nhandle,"InfuseOverL","Infuse Over"
     ))
   SET tasklist_caption->ingresm = trim(uar_i18ngetmessage(i18nhandle,"IngresM","INGREDS"))
   SET tasklist_caption->ingresl = trim(uar_i18ngetmessage(i18nhandle,"IngresL","Ingredients"))
   SET tasklist_caption->isolationm = trim(uar_i18ngetmessage(i18nhandle,"IsolationM","ISOLATION"))
   SET tasklist_caption->isolationl = trim(uar_i18ngetmessage(i18nhandle,"IsolationL","Isolation"))
   SET tasklist_caption->lastdonedtm = trim(uar_i18ngetmessage(i18nhandle,"LastDonedtM","LASTDONEDT")
    )
   SET tasklist_caption->lastdonedtl1 = trim(uar_i18ngetmessage(i18nhandle,"LastDonedtL",
     "Last Done Dt"))
   SET tasklist_caption->lastdonedtl2 = trim(concat(tasklist_caption->lastdonedtl1,"/",
     uar_i18ngetmessage(i18nhandle,"LastDonedtL2","Tm")))
   SET tasklist_caption->lastdosem = trim(uar_i18ngetmessage(i18nhandle,"LastdoseM","LASTDOSE"))
   SET tasklist_caption->lastdosel = trim(uar_i18ngetmessage(i18nhandle,"LastdoseL","Last Dose Given"
     ))
   SET tasklist_caption->lastvaluem = trim(uar_i18ngetmessage(i18nhandle,"LastvalueM","LASTVALUE"))
   SET tasklist_caption->lastvaluel = trim(uar_i18ngetmessage(i18nhandle,"LastvalueL",
     "Last Entered Value"))
   SET tasklist_caption->lastgivenm = trim(uar_i18ngetmessage(i18nhandle,"LastGivenM","LASTGIVEBY"))
   SET tasklist_caption->lastgivenl = trim(uar_i18ngetmessage(i18nhandle,"LastGivenL","Last Given By"
     ))
   SET tasklist_caption->lastgivedttmm = trim(uar_i18ngetmessage(i18nhandle,"LastgivedttmM",
     "LASTGIVEDT"))
   SET tasklist_caption->lastgivedttml1 = trim(concat(uar_i18ngetmessage(i18nhandle,"LastgivedttmL1",
      "Last Given Dt"),"/"))
   SET tasklist_caption->lastgivedttml2 = trim(concat(tasklist_caption->lastgivedttml1,
     uar_i18ngetmessage(i18nhandle,"LastgivedttmL2","Tm")))
   SET tasklist_caption->lastsitem = trim(uar_i18ngetmessage(i18nhandle,"LastsiteM","LASTSITE"))
   SET tasklist_caption->lastsitel = trim(uar_i18ngetmessage(i18nhandle,"LastsiteL","Last Site"))
   SET tasklist_caption->mnemonicm = trim(uar_i18ngetmessage(i18nhandle,"MnemonicM","MNEMONIC"))
   SET tasklist_caption->mnemonicl = trim(uar_i18ngetmessage(i18nhandle,"MnemonicL","Mnemonic"))
   SET tasklist_caption->notbeforem = trim(uar_i18ngetmessage(i18nhandle,"NotbeforeM","NOTBEFORE"))
   SET tasklist_caption->notbeforel = trim(uar_i18ngetmessage(i18nhandle,"NotbeforeL","Not Before"))
   SET tasklist_caption->orderdetm = trim(uar_i18ngetmessage(i18nhandle,"OrderdetM","ORDDET"))
   SET tasklist_caption->orderdetl = trim(uar_i18ngetmessage(i18nhandle,"OrderdetL","Order Details"))
   SET tasklist_caption->orderstatusm = trim(uar_i18ngetmessage(i18nhandle,"OrderstatusM","ORDSTATUS"
     ))
   SET tasklist_caption->orderstatusl = trim(uar_i18ngetmessage(i18nhandle,"OrderstatusL",
     "Order Status"))
   SET tasklist_caption->priom = trim(uar_i18ngetmessage(i18nhandle,"PrioM","PRIO"))
   SET tasklist_caption->priol = trim(uar_i18ngetmessage(i18nhandle,"PrioL","Priority"))
   SET tasklist_caption->provnamem = trim(uar_i18ngetmessage(i18nhandle,"ProvnameM","PROVNAME"))
   SET tasklist_caption->provnamel = trim(uar_i18ngetmessage(i18nhandle,"ProvnameL","Provider Name"))
   SET tasklist_caption->ratem = trim(uar_i18ngetmessage(i18nhandle,"RateM","RATE"))
   SET tasklist_caption->ratel = trim(uar_i18ngetmessage(i18nhandle,"RateL","Rate"))
   SET tasklist_caption->reasonform = trim(uar_i18ngetmessage(i18nhandle,"ReasonforM","REASONGIVE"))
   SET tasklist_caption->reasonforl = trim(uar_i18ngetmessage(i18nhandle,"ReasonforL",
     "Reason for Giving"))
   SET tasklist_caption->receviedm = trim(uar_i18ngetmessage(i18nhandle,"ReceviedM","RECEIVED"))
   SET tasklist_caption->receviedl = trim(uar_i18ngetmessage(i18nhandle,"ReceviedL","Received"))
   SET tasklist_caption->responseregm = trim(uar_i18ngetmessage(i18nhandle,"ResponseregM",
     "RESPONSEREQ"))
   SET tasklist_caption->responseregl = trim(uar_i18ngetmessage(i18nhandle,"ResponseregL",
     "Response Required"))
   SET tasklist_caption->routem = trim(uar_i18ngetmessage(i18nhandle,"RouteM","ROUTE"))
   SET tasklist_caption->routel = trim(uar_i18ngetmessage(i18nhandle,"RouteL","Route"))
   SET tasklist_caption->scheduleddtm = trim(uar_i18ngetmessage(i18nhandle,"ScheduleddtM","SCHEDDATE"
     ))
   SET tasklist_caption->scheduleddtl = trim(uar_i18ngetmessage(i18nhandle,"ScheduleddtL",
     "Scheduled Date"))
   SET tasklist_caption->scheduleddttmm = trim(uar_i18ngetmessage(i18nhandle,"ScheduleddttmM",
     "SCHEDDTTM"))
   SET tasklist_caption->scheduleddttml1 = trim(uar_i18ngetmessage(i18nhandle,"ScheduleddttmL1",
     "Scheduled Dt"))
   SET tasklist_caption->scheduleddttml2 = trim(concat(tasklist_caption->scheduleddttml1,"/",
     uar_i18ngetmessage(i18nhandle,"ScheduleddttmL2","Tm")))
   SET tasklist_caption->schedutimem = trim(uar_i18ngetmessage(i18nhandle,"SchedutimeM","SCHEDTIME"))
   SET tasklist_caption->schedutimel = trim(uar_i18ngetmessage(i18nhandle,"SchedutimeL",
     "Scheduled Time"))
   SET tasklist_caption->startdttmm = trim(uar_i18ngetmessage(i18nhandle,"StartdttmM","STARTDT"))
   SET tasklist_caption->startdttml1 = trim(uar_i18ngetmessage(i18nhandle,"StartdttmL1","Start Dt"))
   SET tasklist_caption->startdttml2 = trim(concat(tasklist_caption->startdttml1,"/",
     uar_i18ngetmessage(i18nhandle,"StartdttmL2","Tm")))
   SET tasklist_caption->stopdttm = trim(uar_i18ngetmessage(i18nhandle,"StopdttM","STOPDT"))
   SET tasklist_caption->stopdttl1 = trim(uar_i18ngetmessage(i18nhandle,"StopdttL1","Stop Dt"))
   SET tasklist_caption->stopdttl2 = trim(concat(tasklist_caption->stopdttl1,"/",uar_i18ngetmessage(
      i18nhandle,"StopdttL2","Tm")))
   SET tasklist_caption->strengthm = trim(uar_i18ngetmessage(i18nhandle,"StrengthM","STRENGTH"))
   SET tasklist_caption->strengthl = trim(uar_i18ngetmessage(i18nhandle,"StrengthL","Strength"))
   SET tasklist_caption->subjectm = trim(uar_i18ngetmessage(i18nhandle,"SubjectM","SUBJECT"))
   SET tasklist_caption->subjectl = trim(uar_i18ngetmessage(i18nhandle,"subjectL","Subject"))
   SET tasklist_caption->taskdescm = trim(uar_i18ngetmessage(i18nhandle,"TaskdescM","TASKDESC"))
   SET tasklist_caption->taskdescl = trim(uar_i18ngetmessage(i18nhandle,"TaskdescL",
     "Task Description"))
   SET tasklist_caption->status = trim(uar_i18ngetmessage(i18nhandle,"Status","STATUS"))
   SET tasklist_caption->taskstatus = trim(uar_i18ngetmessage(i18nhandle,"Taskstatus","Task Status"))
   SET tasklist_caption->tom = trim(uar_i18ngetmessage(i18nhandle,"ToM","TO"))
   SET tasklist_caption->tol = trim(uar_i18ngetmessage(i18nhandle,"ToL","To"))
   SET tasklist_caption->typem = trim(uar_i18ngetmessage(i18nhandle,"TypeM","TYPE"))
   SET tasklist_caption->typel = trim(uar_i18ngetmessage(i18nhandle,"TypeL","Type"))
   SET tasklist_caption->locationm = trim(uar_i18ngetmessage(i18nhandle,"LocationM","LOCATION"))
   SET tasklist_caption->locationl = trim(uar_i18ngetmessage(i18nhandle,"LocationL","Location"))
   SET tasklist_caption->locroombedm = trim(uar_i18ngetmessage(i18nhandle,"LocroombedM","LOCROOMBED")
    )
   SET tasklist_caption->locroombedl1 = trim(concat(uar_i18ngetmessage(i18nhandle,"LocroombedL1",
      "Loc"),"/"))
   SET tasklist_caption->locroombedl2 = trim(concat(tasklist_caption->locroombedl1,uar_i18ngetmessage
     (i18nhandle,"LocroombedL2","Room"),"/"))
   SET tasklist_caption->locroombedl3 = trim(concat(tasklist_caption->locroombedl2,uar_i18ngetmessage
     (i18nhandle,"LocroombedL3","Bed")))
   SET tasklist_caption->mrnm = trim(uar_i18ngetmessage(i18nhandle,"MRNM","MRN"))
   SET tasklist_caption->mrnl = trim(uar_i18ngetmessage(i18nhandle,"MRNL","MRN"))
   SET tasklist_caption->namem = trim(uar_i18ngetmessage(i18nhandle,"NameM","NAME"))
   SET tasklist_caption->namel = trim(uar_i18ngetmessage(i18nhandle,"NameL","Name"))
   SET tasklist_caption->roombdm = trim(uar_i18ngetmessage(i18nhandle,"RoombdM","ROOMBD"))
   SET tasklist_caption->roombdl1 = trim(concat(uar_i18ngetmessage(i18nhandle,"RoombdL1","Room"),"/")
    )
   SET tasklist_caption->roombdl2 = trim(concat(tasklist_caption->roombdl1,uar_i18ngetmessage(
      i18nhandle,"RoombdL2","Bed")))
   SET tasklist_caption->locroombdm = trim(uar_i18ngetmessage(i18nhandle,"LocroombdM","LOCROOMBD"))
   SET tasklist_caption->locroombdl1 = trim(concat(uar_i18ngetmessage(i18nhandle,"LocroombdL1","Loc"),
     "/"))
   SET tasklist_caption->locroombdl2 = trim(concat(tasklist_caption->locroombdl1,uar_i18ngetmessage(
      i18nhandle,"LocroombdL2","Room"),"/"))
   SET tasklist_caption->locroombdl3 = trim(concat(tasklist_caption->locroombdl2,uar_i18ngetmessage(
      i18nhandle,"LocroombdL3","Bed")))
   SET tasklist_caption->defaultm = trim(uar_i18ngetmessage(i18nhandle,"DefaultM","DEFAULT"))
   SET tasklist_caption->defaultl = trim(uar_i18ngetmessage(i18nhandle,"DefaultL","default col head")
    )
   SET tasklist_caption->updtusernamem = trim(uar_i18ngetmessage(i18nhandle,"UpdtUserNameM",
     "UPDTUSERNAME"))
   SET tasklist_caption->updtusernamel = trim(uar_i18ngetmessage(i18nhandle,"UpdtUserNameL",
     "Charted By"))
 END ;Subroutine
 DECLARE dummy_void = i2 WITH constant(0)
 CALL fillcaptions(dummy_void)
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 date = vc
     2 description = vc
     2 desc_cnt = i2
     2 desc_qual[*]
       3 desc_line = vc
     2 details = vc
     2 det_cnt = i2
     2 det_qual[*]
       3 det_line = vc
     2 overdue = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET modify = predeclare
 DECLARE abc = vc WITH noconstant(fillstring(25," "))
 DECLARE age = vc WITH noconstant(fillstring(15," "))
 DECLARE attenddoc = vc WITH noconstant(fillstring(30," "))
 DECLARE bed = vc WITH noconstant(fillstring(20," "))
 DECLARE beg_ind = i2 WITH noconstant(0)
 DECLARE date = vc WITH noconstant(fillstring(100," "))
 DECLARE daylight = i2 WITH constant(0)
 DECLARE dob = vc WITH noconstant(fillstring(15," "))
 DECLARE encntr_id = f8 WITH noconstant(0.0)
 DECLARE end_ind = i2 WITH noconstant(0)
 DECLARE fnbr = vc WITH noconstant(fillstring(20," "))
 DECLARE location = vc WITH noconstant(fillstring(50," "))
 DECLARE max_length = i2 WITH noconstant(0)
 DECLARE mrn = vc WITH noconstant(fillstring(20," "))
 DECLARE name = vc WITH noconstant(fillstring(30," "))
 DECLARE offset = i2 WITH constant(0)
 DECLARE ops_ind = c1 WITH noconstant("N")
 DECLARE person_id = f8 WITH noconstant(0.0)
 DECLARE room = vc WITH noconstant(fillstring(20," "))
 DECLARE task_ind = i2 WITH noconstant(1)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE sex = vc WITH noconstant(fillstring(40," "))
 DECLARE unit = vc WITH noconstant(fillstring(20," "))
 DECLARE valid_ind = i2 WITH noconstant(1)
 DECLARE x2 = vc WITH noconstant("  ")
 DECLARE x3 = vc WITH noconstant("   ")
 DECLARE xdays = i4 WITH noconstant(0)
 DECLARE xhours = i4 WITH noconstant(0)
 DECLARE xmins = i4 WITH noconstant(0)
 DECLARE xyz = c20 WITH noconstant("  -   -       :  :  ")
 DECLARE failed = i2 WITH noconstant(0)
 DECLARE select_error = i2 WITH constant(7)
 DECLARE table_name = vc WITH noconstant(fillstring(50," "))
 DECLARE serrmsg = vc WITH noconstant(fillstring(132," "))
 DECLARE encntr_mrn_alias_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN"))
 IF (encntr_mrn_alias_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning MRN from code_set 319"
  GO TO exit_script
 ENDIF
 DECLARE person_mrn_alias_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN"))
 IF (person_mrn_alias_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning MRN from code_set 4"
  GO TO exit_script
 ENDIF
 DECLARE finnbr_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 IF (finnbr_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning FIN NBR from code_set 319"
  GO TO exit_script
 ENDIF
 DECLARE attend_doc_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 IF (attend_doc_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning ATTENDDOC from code_set 333"
  GO TO exit_script
 ENDIF
 DECLARE overdue_cd = f8 WITH constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 IF (overdue_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = "Failed to find the code_value for cdf_meaning OVERDUE from code_set 79"
  GO TO exit_script
 ENDIF
 IF ((request->visit[1].encntr_id <= 0))
  SET valid_ind = 0
  SET task_ind = 0
  GO TO no_tasks
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   (dummyt d1  WITH seq = 1),
   encntr_alias ea,
   (dummyt d2  WITH seq = 1),
   encntr_prsnl_reltn epr,
   prsnl pl
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd IN (encntr_mrn_alias_cd, finnbr_cd)
    AND ea.active_ind=1)
   JOIN (d2)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_doc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   age = trim(cnvtage(cnvtdate(p.birth_dt_tm),curdate),3), dob = datetimezoneformat(p.birth_dt_tm,p
    .birth_tz,"@SHORTDATE"), name = substring(1,30,p.name_full_formatted),
   sex = substring(1,40,uar_get_code_display(p.sex_cd)), attenddoc = substring(1,30,pl
    .name_full_formatted), unit = substring(1,20,uar_get_code_display(e.loc_nurse_unit_cd)),
   room = substring(1,10,uar_get_code_display(e.loc_room_cd)), bed = substring(1,10,
    uar_get_code_display(e.loc_bed_cd)), location = concat(trim(unit),"/",trim(room),"/",trim(bed)),
   date = format(e.reg_dt_tm,"@SHORTDATE"), person_id = e.person_id, encntr_id = e.encntr_id
  DETAIL
   IF (ea.encntr_alias_type_cd=finnbr_cd)
    finnbr = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))
   ELSEIF (ea.encntr_alias_type_cd=encntr_mrn_alias_cd)
    mrn = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd))
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   dontcare = ea, dontcare = epr
 ;end select
 IF (textlen(trim(mrn)) <= 0)
  SELECT INTO "nl"
   FROM person_alias pa
   WHERE pa.person_id=person_id
    AND pa.person_alias_type_cd=person_mrn_alias_cd
    AND pa.active_ind=1
   ORDER BY pa.beg_effective_dt_tm DESC
   HEAD REPORT
    mrn = substring(1,20,cnvtalias(pa.alias,pa.alias_pool_cd))
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM task_activity ta,
   order_task ot,
   orders o
  PLAN (ta
   WHERE ta.person_id=person_id
    AND ta.encntr_id=encntr_id
    AND ta.task_status_cd=overdue_cd)
   JOIN (ot
   WHERE ot.reference_task_id=ta.reference_task_id)
   JOIN (o
   WHERE o.order_id=outerjoin(ta.order_id))
  ORDER BY ta.task_dt_tm
  HEAD REPORT
   temp->cnt = 0
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].date =
   concat(trim(datetimezoneformat(ta.task_dt_tm,ta.task_tz,"@SHORTDATETIME",curtimezonedef))," ",
    datetimezonebyindex(ta.task_tz,offset,daylight,7,ta.task_dt_tm)),
   temp->qual[temp->cnt].description = ot.task_description, temp->qual[temp->cnt].details = o
   .clinical_display_line, xx = datetimediff(cnvtdatetime(curdate,curtime3),cnvtdatetime(ta
     .task_dt_tm)),
   yy = (xx * 1440), xdays = (yy/ 1440), yy = mod(yy,1440),
   xhours = (yy/ 60), xmins = mod(yy,60), temp->qual[temp->cnt].overdue = build(xdays," days, ",
    xhours," hrs, ",xmins,
    " mins")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET task_ind = 0
  GO TO no_tasks
 ENDIF
 FOR (x = 1 TO temp->cnt)
   SET pt->line_cnt = 0
   SET max_length = 50
   SET modify = nopredeclare
   EXECUTE dcp_parse_text value(temp->qual[x].details), value(max_length)
   SET modify = predeclare
   SET stat = alterlist(temp->qual[x].det_qual,pt->line_cnt)
   SET temp->qual[x].det_cnt = pt->line_cnt
   FOR (w = 1 TO pt->line_cnt)
     SET temp->qual[x].det_qual[w].det_line = pt->lns[w].line
   ENDFOR
   SET pt->line_cnt = 0
   SET max_length = 27
   SET modify = nopredeclare
   EXECUTE dcp_parse_text value(temp->qual[x].description), value(max_length)
   SET modify = predeclare
   SET stat = alterlist(temp->qual[x].desc_qual,pt->line_cnt)
   SET temp->qual[x].desc_cnt = pt->line_cnt
   FOR (w = 1 TO pt->line_cnt)
     SET temp->qual[x].desc_qual[w].desc_line = pt->lns[w].line
   ENDFOR
 ENDFOR
 SELECT INTO request->output_device
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   xcol = 0, ycol = 0, scol = 0,
   zcol = 0, line_cnt = 0
  HEAD PAGE
   "{cpi/8}{f/12}", row + 1, "{pos/225/50}{b}",
   cern_captions->overduetasks, row + 1, "{cpi/12}{f/8}",
   row + 1, "{pos/30/70}{b/5}", cern_captions->name,
   " ", name, row + 1,
   "{pos/30/82}{b/4}", cern_captions->mrn, " ",
   mrn, row + 1, "{pos/30/94}{b/9}",
   cern_captions->location, " ", location,
   row + 1, "{pos/30/130}{b}{u}", cern_captions->taskdate,
   row + 1, "{pos/140/130}{b}{u}", cern_captions->taskdesc,
   row + 1, "{pos/250/130}{b}{u}", cern_captions->details,
   row + 1, "{pos/480/130}{b}{u}", cern_captions->timeoverdue,
   row + 1, "{cpi/14}", row + 1,
   ycol = 145
  DETAIL
   FOR (x = 1 TO temp->cnt)
     line_cnt = temp->qual[x].det_cnt, add_line_ind = 0
     IF ((temp->qual[x].desc_cnt > line_cnt))
      line_cnt = temp->qual[x].desc_cnt, add_line_ind = 1
     ENDIF
     IF ((((line_cnt * 10)+ ycol) > 710))
      BREAK
     ENDIF
     xcol = 30,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].date,
     row + 1, xcol = 480,
     CALL print(calcpos(xcol,ycol)),
     temp->qual[x].overdue, row + 1, xcol = 140,
     scol = ycol
     FOR (z = 1 TO temp->qual[x].desc_cnt)
       CALL print(calcpos(xcol,ycol)), temp->qual[x].desc_qual[z].desc_line, row + 1,
       ycol = (ycol+ 10), zcol = ycol
     ENDFOR
     ycol = scol, xcol = 250
     FOR (z = 1 TO temp->qual[x].det_cnt)
       CALL print(calcpos(xcol,ycol)), temp->qual[x].det_qual[z].det_line, row + 1,
       ycol = (ycol+ 10)
     ENDFOR
     IF (add_line_ind=1)
      ycol = zcol, ycol = (ycol+ 5)
     ELSE
      ycol = (ycol+ 5)
     ENDIF
   ENDFOR
  FOOT PAGE
   "{pos/200/750}", cern_captions->pageno, " ",
   curpage"##", row + 1, "{pos/275/750}",
   cern_captions->printdate, " ", curdate,
   " ", curtime, row + 1
  WITH nocounter, maxrow = 800, maxcol = 800,
   dio = postscript
 ;end select
 GO TO exit_script
#no_tasks
 SELECT INTO request->output_device
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   xcol = 0, ycol = 0, scol = 0,
   zcol = 0, line_cnt = 0
  HEAD PAGE
   "{cpi/8}{f/12}", row + 1, "{pos/225/50}{b}",
   cern_captions->overduetasks, row + 1, "{cpi/12}{f/8}",
   row + 1, "{pos/30/70}{b/5}", cern_captions->name,
   " ", name, row + 1,
   "{pos/30/82}{b/4}", cern_captions->mrn, " ",
   mrn, row + 1, "{pos/30/94}{b/9}",
   cern_captions->location, " ", location,
   row + 1, "{pos/30/130}{b}{u}", cern_captions->taskdate,
   row + 1, "{pos/140/130}{b}{u}", cern_captions->taskdesc,
   row + 1, "{pos/250/130}{b}{u}", cern_captions->details,
   row + 1, "{pos/480/130}{b}{u}", cern_captions->timeoverdue,
   row + 1, "{cpi/14}", row + 1,
   ycol = 145
  DETAIL
   xcol = 30
   IF (valid_ind=1)
    CALL print(calcpos(xcol,ycol)), cern_captions->nooverdue, row + 1
   ELSE
    CALL print(calcpos(xcol,ycol)), cern_captions->cnoreport2, row + 1,
    ycol = (ycol+ 10),
    CALL print(calcpos(xcol,ycol)), cern_captions->cnoreport3,
    row + 1
   ENDIF
  FOOT PAGE
   "{pos/200/750}", cern_captions->pageno, " ",
   curpage"##", row + 1, "{pos/275/750}",
   cern_captions->printdate, " ", curdate,
   " ", curtime, row + 1
  WITH nocounter, maxrow = 800, maxcol = 800,
   dio = postscript
 ;end select
#exit_script
 IF (failed != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
 ELSEIF (task_ind=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD cern_captions
 FREE RECORD cern_intake_captions
 FREE RECORD tasklist_caption
END GO
