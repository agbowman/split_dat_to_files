CREATE PROGRAM cervicaleventstest:dba
 DECLARE cdilation_cki = vc WITH protect, constant("CERNER!86D59A58-992F-4FAE-A470-FC6D6A2103D2")
 DECLARE ceffacement_cki = vc WITH protect, constant("CERNER!0A276863-603D-4B81-A00D-03B8E0785CD8")
 DECLARE cstation_cki = vc WITH protect, constant("CERNER!5DA57B04-B101-43C8-B3B9-9F4887321C48")
 FREE RECORD dilations
 RECORD dilations(
   1 dilation[*]
     2 event_set_name = vc
     2 concept_cki = vc
     2 event_cd = f8
 )
 FREE RECORD stations
 RECORD stations(
   1 station[*]
     2 event_set_name = vc
     2 concept_cki = vc
     2 event_cd = f8
 )
 FREE RECORD effacements
 RECORD effacements(
   1 effacement[*]
     2 event_set_name = vc
     2 concept_cki = vc
     2 event_cd = f8
 )
 FREE RECORD working_views
 RECORD working_views(
   1 working_view_band[*]
     2 working_view = vc
     2 working_view_section = vc
     2 event_set_name = vc
 )
 SET stat = alterlist(working_views->working_view_band,100)
 SET bandcount = 0
 CALL echo("----------------------------------------------------")
 CALL echo("Results for EventCode Existance test")
 CALL echo("----------------------------------------------------")
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE dilationcnt = i4 WITH protect, noconstant(0)
 DECLARE stationcnt = i4 WITH protect, noconstant(0)
 DECLARE effacementcnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv,
   v500_event_set_explode vese,
   v500_event_set_code vesc,
   v500_event_code vec
  PLAN (cv
   WHERE cv.concept_cki IN (cdilation_cki, ceffacement_cki, cstation_cki))
   JOIN (vese
   WHERE vese.event_set_cd=cv.code_value)
   JOIN (vesc
   WHERE vesc.event_set_cd=vese.event_set_cd)
   JOIN (vec
   WHERE vec.event_cd=vese.event_cd)
  DETAIL
   IF (cv.concept_cki=cdilation_cki)
    dilationcnt = (dilationcnt+ 1)
    IF (mod(dilationcnt,10)=1)
     lstat = alterlist(dilations->dilation,(dilationcnt+ 9))
    ENDIF
    dilations->dilation[dilationcnt].event_set_name = vec.event_set_name, dilations->dilation[
    dilationcnt].event_cd = vec.event_cd, dilations->dilation[dilationcnt].concept_cki = cv
    .concept_cki
   ENDIF
   IF (cv.concept_cki=cstation_cki)
    stationcnt = (stationcnt+ 1)
    IF (mod(stationcnt,10)=1)
     lstat = alterlist(stations->station,(stationcnt+ 9))
    ENDIF
    stations->station[stationcnt].event_set_name = vec.event_set_name, stations->station[stationcnt].
    event_cd = vec.event_cd, stations->station[stationcnt].concept_cki = cv.concept_cki
   ENDIF
   IF (cv.concept_cki=ceffacement_cki)
    effacementcnt = (effacementcnt+ 1)
    IF (mod(effacementcnt,10)=1)
     lstat = alterlist(effacements->effacement,(effacementcnt+ 9))
    ENDIF
    effacements->effacement[effacementcnt].event_set_name = vec.event_set_name, effacements->
    effacement[effacementcnt].event_cd = vec.event_cd, effacements->effacement[effacementcnt].
    concept_cki = cv.concept_cki
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Sorry ,NO Cervical Event codes are found in the Tables.")
 ELSE
  IF (effacementcnt > 0
   AND dilationcnt > 0
   AND stationcnt > 0)
   CALL echo(" Event codes for all the cervical CKI values are present in the domain.")
   CALL echo("	Check the record structure for any duplicate Event names and event codes")
  ELSE
   CALL echo(" Event codes for one or more cervical CKI values are missing in the domain.")
   CALL echo(" Also check for duplicate Event names and event codes in th record structure.")
  ENDIF
  CALL echo("Warnings :")
  IF (effacementcnt > 0)
   SET lstat = alterlist(effacements->effacement,effacementcnt)
  ELSE
   CALL echo("There are no Event Codes matching Effacement CKI values")
  ENDIF
  IF (dilationcnt > 0)
   SET lstat = alterlist(dilations->dilation,dilationcnt)
  ELSE
   CALL echo("There are no Event Codes matching Dilation CKI values")
  ENDIF
  IF (stationcnt > 0)
   SET lstat = alterlist(stations->station,stationcnt)
  ELSE
   CALL echo("There are no Event Codes matching STATION CKI values")
  ENDIF
  CALL echo("-------Events count----")
  CALL echo(build("Station count :",stationcnt))
  CALL echo(build("Dilation count :",dilationcnt))
  CALL echo(build("Effacement count :",effacementcnt))
  CALL echo("")
  CALL echo("")
  CALL echo("")
 ENDIF
 CALL echo(
  "==============================================================================================")
 CALL echo(" Section 1 : To check for the presence of the Event codes coressponding to cki values ")
 CALL echorecord(effacements)
 CALL echorecord(dilations)
 CALL echorecord(stations)
 SELECT DISTINCT
  wv.display_name, wvs.event_set_name, wvi.primitive_event_set_name
  FROM code_value cv,
   v500_event_set_explode vese,
   v500_event_set_code vesc,
   v500_event_code vec,
   working_view_item wvi,
   working_view_section wvs,
   working_view wv
  PLAN (cv
   WHERE cv.concept_cki IN (cdilation_cki, ceffacement_cki, cstation_cki))
   JOIN (vese
   WHERE vese.event_set_cd=cv.code_value)
   JOIN (vesc
   WHERE vesc.event_set_cd=vese.event_set_cd)
   JOIN (vec
   WHERE vec.event_cd=vese.event_cd)
   JOIN (wvi
   WHERE cnvtupper(wvi.primitive_event_set_name)=cnvtupper(vec.event_set_name))
   JOIN (wvs
   WHERE wvs.working_view_section_id=wvi.working_view_section_id
    AND wvs.included_ind=1)
   JOIN (wv
   WHERE wvs.working_view_id=wv.working_view_id)
  ORDER BY wv.display_name
  DETAIL
   bandcount = (bandcount+ 1), working_views->working_view_band[bandcount].working_view = wv
   .display_name, working_views->working_view_band[bandcount].working_view_section = wvs
   .event_set_name,
   working_views->working_view_band[bandcount].event_set_name = wvi.primitive_event_set_name
  WITH nocounter
 ;end select
 SET stat = alterlist(working_views->working_view_band,bandcount)
 CALL echo(
  "==============================================================================================")
 CALL echo("Section 2 : The event sets mapping the cki values are present in the following Bands")
 CALL echo(" under the mentioned working view section ")
 CALL echorecord(working_views)
END GO
