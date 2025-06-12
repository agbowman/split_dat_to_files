CREATE PROGRAM bhs_rpt_ews_clinevent_score:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "encntr_id" = 0
  WITH outdev, encntr_id
 FREE RECORD ewevent
 RECORD ewevent(
   1 encntr_id = f8
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 qual[*]
     2 early_warning_id = f8
     2 active_ind = i4
     2 encntr_id = f8
     2 listtype = vc
     2 event_id = f8
     2 eventtype = vc
     2 event_grouper = f8
     2 range_id = f8
     2 clinical_event_id = f8
     2 event_cd = f8
     2 event_score = i4
     2 vitals_score = i4
     2 labs_score = i4
     2 total_score = i4
     2 insert_dt_tm = dq8
     2 event_end_dt_tm = dq8
 ) WITH persist
 DECLARE msgpriority = i4 WITH noconstant(5)
 DECLARE sendto = vc WITH noconstant(" ")
 DECLARE msgsubject = vc WITH noconstant(" ")
 DECLARE msg = vc WITH noconstant(" ")
 DECLARE msgcls = vc WITH constant("IPM.NOTE")
 DECLARE sender = vc WITH constant("Discern_Expert@bhs.org")
 CALL echo("declare variables")
 DECLARE log_misc1 = vc WITH noconstant(" ")
 DECLARE templogmisc1 = vc WITH noconstant(" ")
 DECLARE log_message = vc WITH noconstant(" ")
 DECLARE retval = i4 WITH noconstant(0), public
 DECLARE eventid = f8 WITH noconstant(0.0)
 DECLARE encntr_id = f8 WITH noconstant(0.0)
 DECLARE errmsg = vc WITH noconstant("  ")
 DECLARE ewscorecnt = i4 WITH noconstant(0)
 DECLARE tempvitalscore = i4 WITH noconstant(0)
 DECLARE templabscore = i4 WITH noconstant(0)
 DECLARE temptotalscore = i4 WITH noconstant(0)
 DECLARE tempeventscore = i4 WITH noconstant(0)
 DECLARE listdesc = vc WITH noconstant(" "), public
 DECLARE patientexistsoncustomlist = i4 WITH noconstant(0)
 DECLARE patienthasactivetask = i4 WITH noconstant(0)
 DECLARE patienthadtasklast12hour = i4 WITH noconstant(0)
 DECLARE patacttype = vc WITH noconstant(" ")
 DECLARE taskliks = vc WITH noconstant("  ")
 DECLARE nurseunit = vc WITH noconstant("  ")
 DECLARE num = i4 WITH protect
 DECLARE pos = i4 WITH protect
 CALL echo("declare constants")
 DECLARE mobile = f8 WITH constant(validatecodevalue("MEANING",43,"MOBILE")), protect
 DECLARE etmodify = vc WITH constant("ETMODIFY")
 DECLARE etadd = vc WITH constant("ETADD")
 DECLARE etaudit = vc WITH constant("ETAUDIT")
 DECLARE etinactivate = vc WITH constant("ETINACTIVATE")
 DECLARE vitallisttype = vc WITH constant("VITALS")
 DECLARE lablisttype = vc WITH constant("LABS")
 DECLARE altered = f8 WITH constant(validatecodevalue("MEANING",8,"ALTERED")), protect
 DECLARE modified = f8 WITH constant(validatecodevalue("MEANING",8,"MODIFIED")), protect
 DECLARE auth = f8 WITH constant(validatecodevalue("MEANING",8,"AUTH")), protect
 DECLARE earlywarningord = f8 WITH constant(validatecodevalue("DISPLAYKEY",200,"EARLYWARNING")),
 protect
 DECLARE ordered = f8 WITH constant(validatecodevalue("MEANING",6004,"ORDERED")), protect
 DECLARE inprocessord = f8 WITH constant(validatecodevalue("MEANING",6004,"INPROCESS")), protect
 DECLARE pendingtask = f8 WITH constant(validatecodevalue("MEANING",79,"PENDING")), protect
 DECLARE updt_dt_tm = dq8
 SET updt_dt_tm = cnvtdatetime(curdate,curtime3)
 DECLARE log_message = vc
 SET listdesc = "ADULTEARLYWARNINGSYSTEM"
 SET ewscorecnt = 0
 SET updt_id = reqinfo->updt_id
 SELECT INTO "NL:"
  e.event_cd, ce.event_end_dt_tm
  FROM bhs_event_cd_list e,
   clinical_event ce
  PLAN (e
   WHERE e.listkey IN (listdesc)
    AND e.active_ind=1)
   JOIN (ce
   WHERE (ce.encntr_id= $ENCNTR_ID)
    AND ce.event_cd=e.event_cd
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (altered, modified, auth)
    AND ce.view_level=1)
  ORDER BY e.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   ewscorecnt = 0, ewevent->encntr_id = ce.encntr_id, ewevent->updt_dt_tm = updt_dt_tm,
   ewevent->updt_id = updt_id
  HEAD e.event_cd
   IF (isnumeric(ce.result_val))
    ewscorecnt = (ewscorecnt+ 1), stat = alterlist(ewevent->qual,ewscorecnt), ewevent->qual[
    ewscorecnt].active_ind = 1,
    ewevent->qual[ewscorecnt].event_id = ce.event_id, ewevent->qual[ewscorecnt].listtype = e.grouper,
    ewevent->qual[ewscorecnt].clinical_event_id = ce.clinical_event_id,
    ewevent->qual[ewscorecnt].event_cd = ce.event_cd, ewevent->qual[ewscorecnt].insert_dt_tm =
    cnvtdatetime(curdate,curtime3), ewevent->qual[ewscorecnt].event_end_dt_tm = ce.event_end_dt_tm,
    ewevent->qual[ewscorecnt].eventtype = ce.result_val, ewevent->qual[ewscorecnt].event_grouper = e
    .grouper_id
   ENDIF
  WITH nocounter
 ;end select
 IF (ewscorecnt=0)
  CALL echo("******** No qualifying rows exist for this patient yet ********")
  SET log_message = concat(log_message,
   " No qualifying rows (back load of data) exist for this patient yet; ")
  GO TO exit_program
 ENDIF
 CALL echo("calculate scores for each events")
 EXECUTE bhs_eks_early_warning_score
 SELECT INTO "NL:"
  event_grouper = ewevent->qual[d.seq].event_grouper
  FROM (dummyt d  WITH seq = size(ewevent->qual,5))
  PLAN (d
   WHERE (ewevent->qual[d.seq].active_ind=1))
  ORDER BY event_grouper
  HEAD event_grouper
   tempeventscore = ewevent->qual[d.seq].event_score
  DETAIL
   IF ((ewevent->qual[d.seq].event_score > tempeventscore))
    tempeventscore = ewevent->qual[d.seq].event_score
   ENDIF
  FOOT  event_grouper
   IF ((ewevent->qual[d.seq].listtype=vitallisttype))
    tempvitalscore = (tempvitalscore+ tempeventscore)
   ELSEIF ((ewevent->qual[d.seq].listtype=lablisttype))
    templabscore = (templabscore+ tempeventscore)
   ENDIF
  WITH nocounter
 ;end select
 SET temptotalscore = (templabscore+ tempvitalscore)
 FOR (y = 1 TO ewscorecnt)
   SET ewevent->qual[y].vitals_score = tempvitalscore
   SET ewevent->qual[y].labs_score = templabscore
   SET ewevent->qual[y].total_score = temptotalscore
 ENDFOR
 CALL echo(build("templabScore:",templabscore))
 CALL echo(build("tempVitalScore:",tempvitalscore))
 CALL echo(build("tempTotalScore:",temptotalscore))
 SUBROUTINE validatecodevalue(type,codeset,val)
   SET codeval = 0.0
   SET codeval = uar_get_code_by(value(type),codeset,value(val))
   IF (codeval <= 0)
    SET errmsg = concat("failed finding code_val - type: ",type," codeset:",build(codeset)," val:",
     val)
    GO TO exit_program
   ELSE
    CALL echo(concat("type: ",type," codeset:",build(codeset)," val:",
      val," Code_value=",cnvtstring(codeval)))
   ENDIF
   RETURN(codeval)
 END ;Subroutine
 SELECT INTO  $OUTDEV
  encntr_id = ewevent->encntr_id, ce_id = ewevent->qual[d.seq].clinical_event_id, event_cd = ewevent
  ->qual[d.seq].event_cd,
  event = uar_get_code_display(ewevent->qual[d.seq].event_cd), event_end_dt_tm = format(cnvtdatetime(
    ewevent->qual[d.seq].event_end_dt_tm),";;q"), result_val = ewevent->qual[d.seq].eventtype,
  event_score = ewevent->qual[d.seq].event_score, total_score = ewevent->qual[d.seq].total_score,
  active_ind = ewevent->qual[d.seq].active_ind,
  evtdttm = ewevent->qual[d.seq].event_end_dt_tm
  FROM (dummyt d  WITH seq = ewscorecnt)
  PLAN (d)
  ORDER BY encntr_id, evtdttm DESC
  WITH format, separator = " "
 ;end select
#exit_program
 FREE RECORD ewevent
END GO
