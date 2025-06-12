CREATE PROGRAM bhs_athn_add_triage_encntr
 FREE RECORD result
 RECORD result(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req115551
 RECORD req115551(
   1 transactioninformation[*]
   1 encounter
     2 patientid = f8
     2 clientorganizationid = f8
     2 typecd = f8
     2 registrationdatetime = dq8
     2 dischargedatetime = dq8
     2 locationid = f8
     2 medicalservicecd = f8
     2 reasonforvisit = vc
     2 financialclasscd = f8
     2 pregnancystatuscd = f8
     2 initialcontactdate = dq8
     2 estimatedarrivaldatetime = dq8
     2 estimateddeparturedatetime = dq8
     2 userdefinedattributes[*]
     2 accommodationcd = f8
     2 admitsourcecd = f8
     2 placeofserviceorganizationid = f8
     2 placeofservicetypecd = f8
     2 placeofserviceadmitdatetime = dq8
     2 _estfinresponsibilityamt = i2
     2 estfinresponsibilityamt = f8
     2 admittypecd = f8
     2 patientcaseid = f8
     2 arrivaldatetime = dq8
     2 inpatientadmitdatetime = dq8
     2 ambulatoryconditioncd = f8
     2 onsetdatetime = dq8
     2 lastmenstrualperioddatetime = dq8
     2 referringcomment = vc
     2 patientinformationprovider = vc
     2 courtesycd = f8
     2 isolationcd = f8
     2 vipcd = f8
     2 visitorstatuscd = f8
     2 dischargedispositioncd = f8
     2 dischargetolocationcd = f8
     2 preregistrationdatetime = dq8
     2 admitdecisiondatetime = dq8
     2 _accidentrelatedvisitind = i2
     2 accidentrelatedvisitind = i2
     2 referralsourcecd = f8
     2 servicecategorycd = f8
     2 accommodationrequestcd = f8
     2 paymentcollectionstatuscd = f8
     2 ordersourcecd = f8
     2 earlyadmissionindicator = i2
     2 confidentialitylevelcd = f8
     2 observationstartdatetime = dq8
     2 kioskqueuenumber = vc
     2 kioskqueuenumberdatetime = dq8
     2 diettypecd = f8
     2 lodgercd = f8
     2 refertounitstaffcd = f8
     2 arrivalmodecd = f8
     2 expecteddeliverydatetime = dq8
     2 treatmentphasecd = f8
     2 temporarylocationid = f8
     2 outpatientinbeddatetime = dq8
     2 clinicaldischargedatetime = dq8
     2 completeregistrationdatetime = dq8
     2 clergyvisitcd = f8
     2 clientbillingorganizationid = f8
     2 healthplanprofiletypecd = f8
     2 militaryservicerelatedcd = f8
     2 referringfacilitycd = f8
     2 incidentcd = f8
     2 emergencydeptreferralsourcecd = f8
   1 aliases[*]
   1 personnelrelationships[*]
   1 personrelationships[*]
   1 guarantorrelationships[*]
   1 patientinformation[*]
   1 healthplanrelationships[*]
   1 accidents[*]
   1 legacycomments[*]
   1 valuecodes[*]
   1 specializedvaluecodes[*]
   1 questionnaireactivites[*]
   1 questionaireanswers[*]
   1 caremanagementinformation[*]
   1 comments[*]
   1 communitycaseinformation[*]
   1 conditioncodes[*]
   1 occurrencecodes[*]
   1 occurrencespancodes[*]
   1 leaves[*]
   1 coordinationofbenefitsinfo[*]
   1 events[*]
   1 catchmentrelationships[*]
   1 legalauthorityrelationships[*]
   1 admittingdiagnoses[*]
   1 guarantorfinresponsibilities[*]
   1 socialhealthcareinformation[*]
   1 datanotcollectedinformation[*]
   1 ambulanceinformation[*]
   1 medicaremanagementinformation[*]
   1 locations[*]
 ) WITH protect
 FREE RECORD rep115551
 RECORD rep115551(
   1 transactionstatus
     2 successindicator = i2
     2 debugerrormessage = vc
   1 exceptioninformation[*]
     2 exceptiontype = vc
     2 entitytype = vc
     2 entityid = f8
     2 combinedintold = f8
   1 encounterid = f8
   1 transactiondatetime = dq8
   1 transactionhistoryid = f8
   1 entityids[*]
     2 entityreferencekey = vc
     2 entityid = f8
 ) WITH protect
 DECLARE calladmitencounter(null) = i4
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE now = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSON ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $4 <= 0.0))
  CALL echo("INVALID LOCATION CD PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $5 <= 0.0))
  CALL echo("INVALID ORGANIZATION ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = calladmitencounter(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 DECLARE v1 = vc WITH protect, noconstant("")
 DECLARE v2 = vc WITH protect, noconstant("")
 DECLARE v3 = vc WITH protect, noconstant("")
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, v2 = build("<EncounterID>",trim(replace(cnvtstring(rep115551->encounterid),".000000",
       "",0),3),"</EncounterID>"),
    col + 1, v2, row + 1,
    v3 = build("<ErrorMessage>",rep115551->transactionstatus.debugerrormessage,"</ErrorMessage>"),
    col + 1, v3,
    row + 1, col + 1, "</ReplyMessage>",
    row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req115551
 FREE RECORD rep115551
 FREE RECORD i_request
 FREE RECORD i_reply
 SUBROUTINE calladmitencounter(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(967100)
   DECLARE requestid = i4 WITH constant(115551)
   DECLARE outpatient_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",71,"OUTPATIENT"))
   DECLARE errmsg = vc WITH protect, noconstant("")
   FREE RECORD i_request
   RECORD i_request(
     1 prsnl_id = f8
   ) WITH protect
   FREE RECORD i_reply
   RECORD i_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   SET req115551->encounter.patientid =  $2
   SET req115551->encounter.clientorganizationid =  $5
   SET req115551->encounter.typecd = outpatient_cd
   SET req115551->encounter.registrationdatetime = now
   SET req115551->encounter.locationid =  $4
   CALL echorecord(req115551)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req115551,
    "REC",rep115551,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep115551)
   IF ((rep115551->transactionstatus.successindicator=1))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
