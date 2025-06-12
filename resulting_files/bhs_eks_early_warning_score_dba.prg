CREATE PROGRAM bhs_eks_early_warning_score:dba
 CALL echo("************ INSIDE bhs_eks_early_warning_score *************")
 IF (size(ewevent->qual,5) <= 0)
  CALL echo("no records were passed in")
  GO TO exit_program
 ENDIF
 IF ((validate(ewreason->l_cnt,- (1))=- (1)))
  FREE RECORD ewreason
  RECORD ewreason(
    1 l_cnt = i4
    1 qual[*]
      2 f_event_cd = f8
      2 s_reason = vc
  ) WITH protect
 ENDIF
 FREE RECORD scoresystem
 RECORD scoresystem(
   1 qual[*]
     2 event_cd = f8
     2 grouperid = f8
     2 lookbackhours = i4
     2 eventcompare = i4
     2 scores[*]
       3 index = f8
       3 scoretype = vc
       3 seq = i4
       3 score = i4
       3 lowerrange = f8
       3 upperrange = f8
       3 val = vc
       3 changetype = vc
       3 parentid = f8
 )
 DECLARE num = i4 WITH protect
 DECLARE pos = i4 WITH protect
 DECLARE actual_size = i4 WITH protect
 DECLARE expand_total = i4 WITH protect
 DECLARE expand_start = i4 WITH noconstant(1), protect
 DECLARE expand_stop = i4 WITH noconstant(200), protect
 DECLARE altered = f8 WITH constant(validatecodevalue("MEANING",8,"ALTERED")), protect
 DECLARE modified = f8 WITH constant(validatecodevalue("MEANING",8,"MODIFIED")), protect
 DECLARE auth = f8 WITH constant(validatecodevalue("MEANING",8,"AUTH")), protect
 DECLARE locnum = i4 WITH noconstant(0)
 DECLARE mostrecenteventcdval = vc WITH noconstant(" ")
 DECLARE mostrecenteventid = f8 WITH noconstant(0.0)
 DECLARE highestresult = vc WITH noconstant(" ")
 DECLARE lowestresult = vc WITH noconstant(" ")
 DECLARE firstresult = vc WITH noconstant(" ")
 DECLARE prevresult = vc WITH noconstant(" ")
 DECLARE scorefound = i4 WITH noconstant(0)
 SUBROUTINE sequence(temp)
   SET early_warning_id = 0
   SELECT INTO "nl:"
    nextid = seq(bhs_eks_seq,nextval)
    FROM dual d
    DETAIL
     early_warning_id = nextid
    WITH nocounter
   ;end select
   RETURN(early_warning_id)
 END ;Subroutine
 FREE RECORD scoresystem
 RECORD scoresystem(
   1 qual[*]
     2 event_cd = f8
     2 grouperid = f8
     2 lookbackhours = i4
     2 eventcompare = i4
     2 scores[*]
       3 index = f8
       3 scoretype = vc
       3 seq = i4
       3 score = i4
       3 lowerrange = f8
       3 upperrange = f8
       3 val = vc
       3 changetype = vc
       3 parentid = f8
       3 range_id = f8
 )
 SET qualcnt = 0
 SET scorecnt = 0
 SET num = 0
 CALL echorecord(ewevent)
 SELECT INTO "NL:"
  ce.event_cd, ce.event_end_dt_tm
  FROM clinical_event ce,
   bhs_event_cd_list becl,
   bhs_range_system brs
  PLAN (ce
   WHERE expand(num,1,value(size(ewevent->qual,5)),ce.event_id,ewevent->qual[num].event_id)
    AND ce.result_status_cd IN (altered, modified, auth)
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.view_level=1)
   JOIN (becl
   WHERE becl.listkey=listdesc
    AND becl.active_ind=1
    AND becl.event_cd=ce.event_cd)
   JOIN (brs
   WHERE brs.parent_entity_id=becl.event_cd_list_id
    AND brs.active_ind=1)
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   qualcnt = 0
  HEAD ce.event_cd
   qualcnt = (qualcnt+ 1), stat = alterlist(scoresystem->qual,qualcnt), scoresystem->qual[qualcnt].
   event_cd = ce.event_cd,
   scoresystem->qual[qualcnt].lookbackhours = brs.look_back_hours, scoresystem->qual[qualcnt].
   grouperid = 1, scoresystem->qual[qualcnt].eventcompare = 0,
   scoresystem->qual[qualcnt].eventcompare = 0, scorecnt = 0
  DETAIL
   IF ((scoresystem->qual[qualcnt].event_cd=ce.event_cd))
    scorecnt = (scorecnt+ 1), stat = alterlist(scoresystem->qual[qualcnt].scores,scorecnt),
    scoresystem->qual[qualcnt].scores[scorecnt].scoretype = brs.range_type,
    scoresystem->qual[qualcnt].scores[scorecnt].changetype = brs.change_type, scoresystem->qual[
    qualcnt].scores[scorecnt].lowerrange = brs.lowerrange, scoresystem->qual[qualcnt].scores[scorecnt
    ].upperrange = brs.upperrange,
    scoresystem->qual[qualcnt].scores[scorecnt].val = brs.val, scoresystem->qual[qualcnt].scores[
    scorecnt].score = brs.score, scoresystem->qual[qualcnt].scores[scorecnt].parentid = brs
    .parent_entity_id,
    scoresystem->qual[qualcnt].scores[scorecnt].range_id = brs.range_id
    IF (brs.range_type IN ("PERCENTINCREASE", "PERCENTDECREASE", "NUMERICINCREASE", "NUMERICDECREASE",
    "PERCENTCHANGEANY",
    "NUMERICCHANGEANY"))
     scoresystem->qual[qualcnt].eventcompare = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(scoresystem)
 SET num = 0
 CALL echo("calculate the patients score.")
 SELECT INTO "NL:"
  ce.event_cd, ce.event_end_dt_tm, ce2.event_end_dt_tm
  FROM clinical_event ce,
   clinical_event ce2,
   (dummyt d  WITH seq = size(scoresystem->qual,5))
  PLAN (d)
   JOIN (ce
   WHERE expand(num,1,size(ewevent->qual,5),ce.event_id,ewevent->qual[num].event_id)
    AND (ce.event_cd=scoresystem->qual[d.seq].event_cd)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.result_status_cd IN (altered, modified, auth)
    AND ce.event_end_dt_tm >= cnvtlookbehind(concat(trim(build2(scoresystem->qual[d.seq].
       lookbackhours),3),",H"),cnvtdatetime(curdate,curtime))
    AND ce.view_level=1)
   JOIN (ce2
   WHERE ce2.encntr_id=ce.encntr_id
    AND ((ce2.event_cd+ 0)=ce.event_cd)
    AND ((((ce2.valid_until_dt_tm+ 0) >= cnvtdatetime(curdate,curtime))
    AND ce2.result_status_cd IN (altered, modified, auth)
    AND (scoresystem->qual[d.seq].eventcompare=1)) OR (ce2.event_id=ce.event_id
    AND (scoresystem->qual[d.seq].eventcompare=0))) )
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC, ce2.event_end_dt_tm DESC
  HEAD ce.event_cd
   CALL echo("head"), highestresult = ce.result_val, lowestresult = ce.result_val,
   mostrecenteventcdval = trim(ce.result_val,3), mostrecenteventid = ce.event_id, cnt = 0
  DETAIL
   CALL echo("detail")
   IF ((scoresystem->qual[d.seq].eventcompare=1))
    CALL echo("Score contains a Compare")
    IF (cnt=1)
     prevresult = ce2.result_val, cnt = 0
    ELSEIF (ce2.event_id=mostrecenteventid)
     cnt = 1
    ENDIF
    IF (isnumeric(trim(ce2.result_val)))
     tempresultval = cnvtreal(ce2.result_val)
     IF (tempresultval > cnvtreal(trim(highestresult,3)))
      highestresult = ce2.result_val
     ENDIF
     IF (tempresultval < cnvtreal(trim(lowestresult,3)))
      lowestresult = ce2.result_val
     ENDIF
     CALL echo(highestresult)
    ELSE
     CALL echo("error trying to compare string to numeric value")
    ENDIF
   ENDIF
  FOOT  ce.event_cd
   CALL echo("FOOT"), firstresult = trim(ce2.result_val,3),
   CALL echo(mostrecenteventcdval),
   pos = locateval(locnum,1,size(scoresystem->qual[d.seq].scores,5),trim(mostrecenteventcdval,3),
    scoresystem->qual[d.seq].scores[locnum].val)
   IF (pos > 0
    AND (scoresystem->qual[d.seq].scores[pos].scoretype="EQUALTO"))
    x = pos, xend = pos,
    CALL echo("found scoreSystem Match without looping")
   ELSE
    x = 1, xend = size(scoresystem->qual[d.seq].scores,5)
   ENDIF
   score = - (1)
   FOR (y = x TO xend)
     CALL echo(y),
     CALL echo(xend),
     CALL echo(build("inital loop score:",score)),
     scoretype = scoresystem->qual[d.seq].scores[y].scoretype, changetype = scoresystem->qual[d.seq].
     scores[y].changetype, scoreval = scoresystem->qual[d.seq].scores[y].val,
     CALL echo(changetype),
     CALL echo(scoretype)
     IF ((scoresystem->qual[d.seq].eventcompare=1))
      IF (changetype="SINCEADMIN")
       stat = 0
      ELSEIF (changetype="SINCEFIRSTRESULT")
       lowestresult = firstresult, highestresult = firstresult
      ELSEIF (changetype="SINCEPREVRESULT")
       lowestresult = prevresult, highestresult = prevresult
      ENDIF
     ENDIF
     CALL echo("******START************"),
     CALL echo(changetype),
     CALL echo(scoretype),
     CALL echo("******************"),
     CALL echo(build("highestResult:",highestresult)),
     CALL echo(build("LowestResult:",lowestresult)),
     CALL echo(build("firstResult:",firstresult)),
     CALL echo(build("prevResult:",prevresult)),
     CALL echo(build("Current Value:",mostrecenteventcdval))
     IF (scoretype != "EQUALTO"
      AND isnumeric(mostrecenteventcdval)=0)
      CALL echo("Non-numeric value being compared")
     ELSE
      IF (scoretype="RANGE")
       IF (cnvtreal(mostrecenteventcdval) BETWEEN scoresystem->qual[d.seq].scores[y].lowerrange AND
       scoresystem->qual[d.seq].scores[y].upperrange)
        score = scoresystem->qual[d.seq].scores[y].score, ewreason->l_cnt = (ewreason->l_cnt+ 1),
        stat = alterlist(ewreason->qual,ewreason->l_cnt),
        ewreason->qual[ewreason->l_cnt].f_event_cd = ce.event_cd, ewreason->qual[ewreason->l_cnt].
        s_reason = concat(trim(uar_get_code_display(ce.event_cd))," is between ",trim(cnvtstring(
           scoresystem->qual[d.seq].scores[y].lowerrange))," and ",trim(cnvtstring(scoresystem->qual[
           d.seq].scores[y].upperrange)),
         " (",mostrecenteventcdval,")")
       ENDIF
      ELSEIF (scoretype="GREATERTHEN")
       IF (cnvtreal(mostrecenteventcdval) > cnvtreal(scoreval))
        score = scoresystem->qual[d.seq].scores[y].score, ewreason->l_cnt = (ewreason->l_cnt+ 1),
        stat = alterlist(ewreason->qual,ewreason->l_cnt),
        ewreason->qual[ewreason->l_cnt].f_event_cd = ce.event_cd, ewreason->qual[ewreason->l_cnt].
        s_reason = concat(trim(uar_get_code_display(ce.event_cd))," is greater than ",trim(scoreval),
         "(",mostrecenteventcdval,
         ")")
       ENDIF
      ELSEIF (scoretype="LESSTHEN")
       IF (cnvtreal(mostrecenteventcdval) < cnvtreal(scoreval))
        score = scoresystem->qual[d.seq].scores[y].score, ewreason->l_cnt = (ewreason->l_cnt+ 1),
        stat = alterlist(ewreason->qual,ewreason->l_cnt),
        ewreason->qual[ewreason->l_cnt].f_event_cd = ce.event_cd, ewreason->qual[ewreason->l_cnt].
        s_reason = concat(trim(uar_get_code_display(ce.event_cd))," is less than ",trim(scoreval),"(",
         mostrecenteventcdval,
         ")")
       ENDIF
      ELSEIF (scoretype="EQUALTO")
       IF (isnumeric(trim(mostrecenteventcdval)))
        IF (cnvtreal(mostrecenteventcdval)=cnvtreal(scoreval))
         score = scoresystem->qual[d.seq].scores[y].score
        ENDIF
       ELSEIF (mostrecenteventcdval < trim(scoreval,3))
        score = scoresystem->qual[d.seq].scores[y].score
       ENDIF
      ELSEIF (scoretype IN ("PERCENTDECREASE", "PERCENTINCREASE", "PERCENTCHANGEANY"))
       IF (scoretype IN ("PERCENTINCREASE", "PERCENTCHANGEANY"))
        IF (((100 * ((cnvtreal(mostrecenteventcdval) - cnvtreal(lowestresult))/ cnvtreal(lowestresult
         ))) >= cnvtreal(scoreval)))
         score = scoresystem->qual[d.seq].scores[y].score, ewreason->l_cnt = (ewreason->l_cnt+ 1),
         stat = alterlist(ewreason->qual,ewreason->l_cnt),
         ewreason->qual[ewreason->l_cnt].f_event_cd = ce.event_cd, ewreason->qual[ewreason->l_cnt].
         s_reason = concat(trim(uar_get_code_display(ce.event_cd))," increased by ",trim(cnvtstring((
            100 * ((cnvtreal(mostrecenteventcdval) - cnvtreal(lowestresult))/ cnvtreal(lowestresult))
            ))),"%.")
        ENDIF
       ENDIF
       IF (scoretype IN ("PERCENTDECREASE", "PERCENTCHANGEANY"))
        IF ((((100 * (cnvtreal(highestresult) - (cnvtreal(mostrecenteventcdval)/ cnvtreal(
         mostrecenteventcdval)))) >= cnvtreal(scoreval)) >= cnvtreal(scoreval)))
         score = scoresystem->qual[d.seq].scores[y].score
        ENDIF
       ENDIF
      ELSEIF (scoretype IN ("NUMERICDECREASE", "NUMERICINCREASE", "NUMERICCHANGEANY"))
       IF (scoretype IN ("NUMERICINCREASE", "NUMERICCHANGEANY"))
        IF (((cnvtreal(mostrecenteventcdval) - cnvtreal(lowestresult)) >= cnvtreal(scoreval)))
         CALL echo("NUMERIC INCREASE"), score = scoresystem->qual[d.seq].scores[y].score
        ENDIF
       ENDIF
       IF (scoretype IN ("NUMERICDECREASE", "NUMERICCHANGEANY"))
        IF (((cnvtreal(highestresult) - cnvtreal(mostrecenteventcdval)) >= cnvtreal(scoreval)))
         CALL echo("NUMERIC DECREASE"), score = scoresystem->qual[d.seq].scores[y].score
        ENDIF
       ENDIF
      ENDIF
      IF (score > 0)
       CALL echo("######################score added exiting for loop#########################"),
       locnum = 0, pos = locateval(locnum,1,size(ewevent->qual,5),mostrecenteventid,ewevent->qual[
        locnum].event_id)
       IF (pos > 0)
        ewevent->qual[pos].event_score = score, ewevent->qual[pos].range_id = scoresystem->qual[d.seq
        ].scores[y].range_id
       ENDIF
       y = (xend+ 1)
      ENDIF
      CALL echo(build("SCORE:",score)),
      CALL echo("******END************")
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 CALL echorecord(ewevent)
#exit_program
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
 CALL echo("************ leaving bhs_eks_early_warning_score *************")
 CALL echorecord(ewreason)
END GO
