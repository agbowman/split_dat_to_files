CREATE PROGRAM bhs_early_warning_audit2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin dt/tm:" = "12-DEC-2010 00:00:00",
  "End dt/tm  :" = "14-DEC-2010 23:59:59"
  WITH outdev, begin_date, end_date
 CALL echo("declare variables")
 DECLARE ewscorecnt = i4 WITH noconstant(0)
 DECLARE tempvitalscore = i4 WITH noconstant(0)
 DECLARE templabscore = i4 WITH noconstant(0)
 DECLARE temptotalscore = f8 WITH noconstant(0)
 DECLARE tempeventscore = i4 WITH noconstant(0)
 DECLARE tempeventtext = vc WITH noconstant(" ")
 DECLARE updt_dt_tm = dq8 WITH noconstant(sysdate)
 DECLARE ml_enc_cnt = i4 WITH protect, noconstant(0)
 DECLARE listdesc = vc WITH noconstant("ADULTEARLYWARNINGSYSTEM"), public
 DECLARE etmodify = vc WITH constant("ETMODIFY")
 DECLARE etadd = vc WITH constant("ETADD")
 DECLARE etaudit = vc WITH constant("ETAUDIT")
 DECLARE etinactivate = vc WITH constant("ETINACTIVATE")
 DECLARE vitallisttype = vc WITH constant("VITALS")
 DECLARE lablisttype = vc WITH constant("LABS")
 DECLARE ml_scope_in_days = i4 WITH protect, constant(2)
 DECLARE altered = f8 WITH constant(validatecodevalue("MEANING",8,"ALTERED")), protect
 DECLARE modified = f8 WITH constant(validatecodevalue("MEANING",8,"MODIFIED")), protect
 DECLARE auth = f8 WITH constant(validatecodevalue("MEANING",8,"AUTH")), protect
 CALL echo("declare Record structures")
 FREE RECORD ceresult
 RECORD ceresult(
   1 qual[*]
     2 clinical_event_id = f8
 )
 FREE RECORD encs
 RECORD encs(
   1 qual[*]
     2 f_eid = f8
     2 d_reg_dt_tm = dq8
 )
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
     2 event_score_text = vc
     2 vitals_score = i4
     2 labs_score = i4
     2 total_score = i4
     2 insert_dt_tm = dq8
     2 event_end_dt_tm = dq8
 ) WITH persist
 FREE RECORD requesttemp
 RECORD requesttemp(
   1 clin_detail_list[*]
     2 clinical_event_id = f8
 )
 CALL echo("Begin logic")
 SELECT INTO "nl:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE e.reg_dt_tm BETWEEN cnvtdatetime( $BEGIN_DATE) AND cnvtdatetime( $END_DATE))
   JOIN (p
   WHERE p.person_id=e.person_id)
  DETAIL
   IF (datetimecmp(cnvtdatetime(curdate,curtime3),p.birth_dt_tm) > 6574)
    agequal = 1, stat = alterlist(encs->qual,(size(encs->qual,5)+ 1)), encs->qual[size(encs->qual,5)]
    .f_eid = e.encntr_id
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("Number of encounters: ",cnvtint(size(encs->qual,5))))
 SET stat = alterlist(encs->qual,3)
 SET encs->qual[1].f_eid = 64675942
 SET encs->qual[2].f_eid = 64742107
 SET encs->qual[3].f_eid = 64732496
 SET encs->qual[1].f_eid = 62773577
 SET encs->qual[1].d_reg_dt_tm = cnvtdatetime("12-DEC-2010 00:00:00")
 SET encs->qual[2].f_eid = 62725612
 SET encs->qual[2].d_reg_dt_tm = cnvtdatetime("12-DEC-2010 00:00:00")
 SET encs->qual[3].f_eid = 62741583
 SET encs->qual[3].d_reg_dt_tm = cnvtdatetime("12-DEC-2010 00:00:00")
 CALL echo("Get the warning system events for the first 24 hours after arrival")
 FOR (ml_enc_cnt = 1 TO size(encs->qual,5))
  SELECT INTO "NL:"
   e.event_cd, ce.event_end_dt_tm
   FROM bhs_event_cd_list e,
    clinical_event ce
   PLAN (e
    WHERE e.listkey IN ("ADULTEARLYWARNINGSYSTEM")
     AND e.active_ind=1)
    JOIN (ce
    WHERE (ce.encntr_id=encs->qual[ml_enc_cnt].f_eid)
     AND ce.event_cd=e.event_cd
     AND ce.event_end_dt_tm BETWEEN cnvtdatetime(encs->qual[ml_enc_cnt].d_reg_dt_tm) AND datetimeadd(
     cnvtdatetime(encs->qual[ml_enc_cnt].d_reg_dt_tm),ml_scope_in_days)
     AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND ce.result_status_cd IN (altered, modified, auth)
     AND ce.view_level=1)
   ORDER BY e.event_cd, ce.event_end_dt_tm DESC
   HEAD REPORT
    ewscorecnt = 0, ewevent->encntr_id = ce.encntr_id, ewevent->updt_dt_tm = updt_dt_tm,
    ewevent->updt_id = reqinfo->updt_id
   HEAD e.event_cd
    IF (isnumeric(ce.result_val))
     ewscorecnt = (ewscorecnt+ 1), stat = alterlist(ewevent->qual,ewscorecnt), ewevent->qual[
     ewscorecnt].active_ind = 1,
     ewevent->qual[ewscorecnt].event_id = ce.event_id, ewevent->qual[ewscorecnt].listtype = e.grouper,
     ewevent->qual[ewscorecnt].clinical_event_id = ce.clinical_event_id,
     ewevent->qual[ewscorecnt].event_cd = ce.event_cd, ewevent->qual[ewscorecnt].insert_dt_tm =
     cnvtdatetime(curdate,curtime3), ewevent->qual[ewscorecnt].eventtype = etadd,
     ewevent->qual[ewscorecnt].event_grouper = e.grouper_id
    ENDIF
   WITH nocounter
  ;end select
  IF (size(ewevent->qual,5)=0)
   CALL echo(concat("*** Encounter #",trim(cnvtstring(encs->qual[ml_enc_cnt].f_eid),3),
     " did not have any qualifying labs/results events ***"))
   SET temptotalscore = 0
  ELSE
   CALL echo(concat("Calculate scores for events in encounter #",trim(cnvtstring(encs->qual[
       ml_enc_cnt].f_eid),3)," [",trim(cnvtstring(ml_enc_cnt),3),"/",
     trim(cnvtstring(size(encs->qual,5)),3),"]"))
   EXECUTE bhs_eks_early_warning_score
   SELECT INTO "NL:"
    event_grouper = ewevent->qual[d.seq].event_grouper
    FROM (dummyt d  WITH seq = size(ewevent->qual,5))
    PLAN (d
     WHERE (ewevent->qual[d.seq].active_ind=1))
    ORDER BY event_grouper
    HEAD event_grouper
     tempeventscore = ewevent->qual[d.seq].event_score, tempeventtext = ewevent->qual[d.seq].
     event_score_text
    DETAIL
     IF ((ewevent->qual[d.seq].event_score > tempeventscore))
      tempeventscore = ewevent->qual[d.seq].event_score, tempeventtext = ewevent->qual[d.seq].
      event_score_text
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
     IF ((ewevent->qual[y].eventtype IN (etadd, etinactivate, etmodify)))
      SET ewevent->qual[y].vitals_score = tempvitalscore
      SET ewevent->qual[y].labs_score = templabscore
      SET ewevent->qual[y].total_score = temptotalscore
     ENDIF
   ENDFOR
   CALL echo(build("templabScore:",templabscore))
   CALL echo(build("tempVitalScore:",tempvitalscore))
   CALL echo(build("tempTotalScore:",temptotalscore))
  ENDIF
 ENDFOR
#exit_script
 SUBROUTINE validatecodevalue(type,codeset,val)
   SET codeval = 0.0
   SET codeval = uar_get_code_by(value(type),codeset,value(val))
   IF (codeval <= 0)
    GO TO exit_script
   ELSE
    CALL echo(concat("type: ",type," codeset:",build(codeset)," val:",
      val," Code_value=",cnvtstring(codeval)))
   ENDIF
   RETURN(codeval)
 END ;Subroutine
END GO
