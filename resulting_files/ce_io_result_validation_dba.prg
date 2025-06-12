CREATE PROGRAM ce_io_result_validation:dba
 EXECUTE crmrtl
 EXECUTE srvrtl
 DECLARE findtotaldefbyperformeddttm(totaldefinitionid=f8,performeddttm=q8) = i4
 RECORD suspecttotals(
   1 lst[*]
     2 ce_io_total_result_id = f8
 )
 RECORD suspectcandidates(
   1 lst[*]
     2 ce_io_total_result_id = f8
     2 io_total_definition_id = f8
     2 performed_dt_tm = dq8
     2 event_id = f8
     2 event_cd = f8
     2 suspect_flag = i2
 )
 RECORD totaldefinition(
   1 lst[*]
     2 total_definition_id = f8
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 type_cd = f8
     2 elements[*]
       3 event_cd = f8
       3 route_cd = f8
       3 iv_event_cd = f8
 )
 DECLARE find_weight_suspects(null) = null
 DECLARE find_potential_weight_suspects(null) = null
 DECLARE find_potential_io_suspects(null) = null
 DECLARE retrieve_total_definition_info(null) = null
 DECLARE query_simple_medication_io_results(null) = null
 DECLARE query_continuous_iv_results(null) = null
 DECLARE determine_med_result_suspects(null) = null
 DECLARE determine_io_result_suspects(null) = null
 DECLARE update_suspect_io_total_results(null) = null
 DECLARE io_total_intake = f8 WITH constant(uar_get_code_by("MEANING",200008,"INTAKE"))
 DECLARE io_total_output = f8 WITH constant(uar_get_code_by("MEANING",200008,"OUTPUT"))
 DECLARE io_total_balance = f8 WITH constant(uar_get_code_by("MEANING",200008,"BALANCE"))
 DECLARE io_total_allintake = f8 WITH constant(uar_get_code_by("MEANING",200008,"ALLINTAKE"))
 DECLARE io_total_alloutput = f8 WITH constant(uar_get_code_by("MEANING",200008,"ALLOUTPUT"))
 DECLARE io_total_allbalance = f8 WITH constant(uar_get_code_by("MEANING",200008,"ALLBALANCE"))
 DECLARE valenddttm = q8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE valstartdttm = q8 WITH constant(datetimeadd(valenddttm,- (7)))
 DECLARE ioresultitemcnt = i4 WITH constant(size(request->io_result_list,5))
 DECLARE meditemcnt = i4 WITH constant(size(request->med_result_list,5))
 DECLARE weightitemcnt = i4 WITH constant(size(request->weight_result_list,5))
 DECLARE stat = i4 WITH protect
 IF (weightitemcnt)
  CALL find_weight_suspects(null)
 ENDIF
 IF (ioresultitemcnt)
  CALL find_potential_io_suspects(null)
 ENDIF
 IF (meditemcnt)
  CALL find_potential_med_suspects(null)
 ENDIF
 IF (size(suspectcandidates->lst,5))
  CALL retrieve_total_definition_info(null)
  IF (ioresultitemcnt)
   CALL query_simple_medication_io_results(null)
   CALL query_continuous_iv_results(null)
  ENDIF
  CALL determine_med_result_suspects(null)
  CALL determine_io_result_suspects(null)
 ENDIF
 CALL update_suspect_io_total_results(null)
 SUBROUTINE find_weight_suspects(null)
  DECLARE ndx = i4 WITH protect, noconstant(0)
  SELECT INTO "nl"
   FROM ce_contributor_link cecl,
    ce_io_total_result iotr,
    (dummyt d  WITH seq = value(weightitemcnt))
   PLAN (d
    WHERE (request->weight_result_list[d.seq].person_id != 0))
    JOIN (cecl
    WHERE (cecl.contributor_event_id=request->weight_result_list[d.seq].event_id)
     AND ((cecl.valid_until_dt_tm+ 0)=cnvtdatetimeutc("31-DEC-2100")))
    JOIN (iotr
    WHERE iotr.event_id=cecl.event_id
     AND iotr.valid_until_dt_tm=cnvtdatetimeutc("31-dec-2100")
     AND iotr.io_total_end_dt_tm > cnvtdatetimeutc(valstartdttm)
     AND iotr.suspect_flag != 1)
   HEAD REPORT
    ndx = 0
   DETAIL
    IF (((iotr.encntr_focused_ind=0) OR (iotr.encntr_focused_ind=1
     AND (iotr.encntr_id=request->weight_result_list[d.seq].encntr_id))) )
     ndx = (ndx+ 1)
     IF (mod(ndx,10)=1)
      stat = alterlist(suspecttotals->lst,(ndx+ 9))
     ENDIF
     suspecttotals->lst[ndx].ce_io_total_result_id = iotr.ce_io_total_result_id
    ENDIF
   FOOT REPORT
    stat = alterlist(suspecttotals->lst,ndx)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE find_potential_io_suspects(null)
  DECLARE ndx = i4 WITH protect, noconstant(0)
  SELECT INTO "nl"
   FROM ce_io_total_result iotr,
    clinical_event ce,
    (dummyt d  WITH seq = value(ioresultitemcnt))
   PLAN (d
    WHERE (request->io_result_list[d.seq].person_id != 0))
    JOIN (iotr
    WHERE (iotr.person_id=request->io_result_list[d.seq].person_id)
     AND iotr.io_total_end_dt_tm > cnvtdatetimeutc(valstartdttm)
     AND iotr.io_total_end_dt_tm >= cnvtdatetimeutc(request->io_result_list[d.seq].io_end_dt_tm)
     AND iotr.io_total_start_dt_tm <= cnvtdatetimeutc(request->io_result_list[d.seq].io_end_dt_tm)
     AND iotr.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100")
     AND iotr.suspect_flag != 1)
    JOIN (ce
    WHERE ce.event_id=iotr.event_id
     AND ce.valid_until_dt_tm=iotr.valid_until_dt_tm)
   HEAD REPORT
    ndx = size(suspectcandidates->lst,5)
    IF (mod(ndx,10))
     stat = alterlist(suspectcandidates->lst,(ndx+ (10 - mod(ndx,10))))
    ENDIF
   DETAIL
    IF (((iotr.encntr_focused_ind=0) OR (iotr.encntr_focused_ind=1
     AND (iotr.encntr_id=request->io_result_list[d.seq].encntr_id))) )
     ndx = (ndx+ 1)
     IF (mod(ndx,10)=1)
      stat = alterlist(suspectcandidates->lst,(ndx+ 9))
     ENDIF
     suspectcandidates->lst[ndx].ce_io_total_result_id = iotr.ce_io_total_result_id,
     suspectcandidates->lst[ndx].io_total_definition_id = iotr.io_total_definition_id,
     suspectcandidates->lst[ndx].event_id = request->io_result_list[d.seq].event_id,
     suspectcandidates->lst[ndx].event_cd = request->io_result_list[d.seq].event_cd,
     suspectcandidates->lst[ndx].performed_dt_tm = ce.performed_dt_tm
    ENDIF
   FOOT REPORT
    stat = alterlist(suspectcandidates->lst,ndx)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE find_potential_med_suspects(null)
  DECLARE ndx = i4 WITH protect, noconstant(0)
  SELECT INTO "nl"
   FROM ce_io_total_result iotr,
    clinical_event ce,
    clinical_event ce2,
    ce_intake_output_result ior,
    (dummyt d  WITH seq = value(meditemcnt))
   PLAN (d
    WHERE (request->med_result_list[d.seq].person_id != 0))
    JOIN (ce2
    WHERE (ce2.event_id=request->med_result_list[d.seq].event_id)
     AND ce2.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100"))
    JOIN (ior
    WHERE ior.reference_event_id=ce2.parent_event_id
     AND ior.valid_until_dt_tm=ce2.valid_until_dt_tm)
    JOIN (iotr
    WHERE (iotr.person_id=request->med_result_list[d.seq].person_id)
     AND iotr.io_total_end_dt_tm > cnvtdatetimeutc(valstartdttm)
     AND iotr.io_total_end_dt_tm >= ior.io_end_dt_tm
     AND iotr.io_total_start_dt_tm <= ior.io_end_dt_tm
     AND iotr.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100")
     AND iotr.suspect_flag != 1)
    JOIN (ce
    WHERE ce.event_id=iotr.event_id
     AND ce.valid_until_dt_tm=iotr.valid_until_dt_tm)
   HEAD REPORT
    ndx = size(suspectcandidates->lst,5)
    IF (mod(ndx,10))
     stat = alterlist(suspectcandidates->lst,(ndx+ (10 - mod(ndx,10))))
    ENDIF
   DETAIL
    IF (((iotr.encntr_focused_ind=0) OR (iotr.encntr_focused_ind=1
     AND (iotr.encntr_id=request->med_result_list[d.seq].encntr_id))) )
     ndx = (ndx+ 1)
     IF (mod(ndx,10)=1)
      stat = alterlist(suspectcandidates->lst,(ndx+ 9))
     ENDIF
     suspectcandidates->lst[ndx].ce_io_total_result_id = iotr.ce_io_total_result_id,
     suspectcandidates->lst[ndx].io_total_definition_id = iotr.io_total_definition_id,
     suspectcandidates->lst[ndx].event_id = request->med_result_list[d.seq].event_id,
     suspectcandidates->lst[ndx].performed_dt_tm = cnvtdatetimeutc(ce.performed_dt_tm)
    ENDIF
   FOOT REPORT
    stat = alterlist(suspectcandidates->lst,ndx)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE findtotaldefbyperformeddttm(iototaldefinitionid,performeddttm)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE lastpos = i4 WITH protect, noconstant(0)
   DECLARE totaldefcount = i4 WITH protect, constant(size(totaldefinition->lst,5))
   DECLARE done = i4 WITH protect, noconstant(0)
   DECLARE totaldefidx = i4 WITH protect, noconstant(0)
   DECLARE candidatecount = i4 WITH protect, constant(size(suspectcandidates->lst,5))
   DECLARE definitioncount = i4 WITH protect, noconstant(0)
   DECLARE elementcount = i4 WITH protect, noconstant(0)
   DECLARE ndx = i4 WITH protect, noconstant(0)
   DECLARE ndx2 = i4 WITH protect, noconstant(0)
   SET pos = 0
   SET lastpos = 1
   WHILE (negate(done))
    SET pos = locateval(totaldefidx,lastpos,totaldefcount,iototaldefinitionid,totaldefinition->lst[
     totaldefidx].total_definition_id)
    IF (pos != 0)
     IF ((totaldefinition->lst[pos].begin_effective_dt_tm < performeddttm)
      AND (performeddttm <= totaldefinition->lst[pos].end_effective_dt_tm))
      SET done = 1
     ELSE
      SET lastpos = (pos+ 1)
     ENDIF
    ELSE
     SET done = 1
    ENDIF
   ENDWHILE
   CALL echo(build("findTotalDefByPerformedDtTm = ",pos))
   RETURN(pos)
 END ;Subroutine
 SUBROUTINE retrieve_total_definition_info(null)
   DECLARE crmstatus = i2
   DECLARE srvstat = i4
   DECLARE happ = i4 WITH protect, noconstant(0)
   DECLARE htask = i4 WITH protect, noconstant(0)
   DECLARE hstep = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hrep = i4 WITH protect, noconstant(0)
   DECLARE hitem = i4 WITH protect, noconstant(0)
   DECLARE helement = i4 WITH protect, noconstant(0)
   DECLARE hstruct = i4 WITH protect, noconstant(0)
   DECLARE totaldefidx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE lastpos = i4 WITH protect, noconstant(0)
   DECLARE candidatecount = i4 WITH protect, constant(size(suspectcandidates->lst,5))
   DECLARE totaldefcount = i4 WITH protect, noconstant(0)
   DECLARE definitioncount = i4 WITH protect, noconstant(0)
   DECLARE elementcount = i4 WITH protect, noconstant(0)
   DECLARE ndx = i4 WITH protect, noconstant(0)
   DECLARE ndx2 = i4 WITH protect, noconstant(0)
   SET stat = alterlist(totaldefinition->lst,candidatecount)
   FOR (ndx = 1 TO candidatecount)
     SET pos = 0
     SET lastpos = 1
     WHILE (pos=0)
      SET pos = locateval(totaldefidx,lastpos,totaldefcount,suspectcandidates->lst[ndx].
       io_total_definition_id,totaldefinition->lst[totaldefidx].total_definition_id)
      IF (pos=0)
       SET totaldefcount = (totaldefcount+ 1)
       SET totaldefinition->lst[totaldefcount].total_definition_id = suspectcandidates->lst[ndx].
       io_total_definition_id
       SET totaldefinition->lst[totaldefcount].begin_effective_dt_tm = suspectcandidates->lst[ndx].
       performed_dt_tm
       SET pos = totaldefcount
      ELSE
       IF ((suspectcandidates->lst[ndx].performed_dt_tm != totaldefinition->lst[totaldefidx].
       begin_effective_dt_tm))
        SET lastpos = (pos+ 1)
        SET pos = 0
       ENDIF
      ENDIF
     ENDWHILE
   ENDFOR
   IF (totaldefcount != candidatecount)
    SET stat = alterlist(totaldefinition->lst,totaldefcount)
   ENDIF
   SET crmstatus = uar_crmbeginapp(3202004,happ)
   IF (crmstatus != 0)
    CALL echo("Error in Begin App for application 3202004.")
    CALL echo(build("Crm Status: ",crmstatus))
    CALL echo("Cannot call Event_Ensure. Exiting Script.")
    GO TO exit_script
   ENDIF
   SET crmstatus = uar_crmbegintask(happ,3202004,htask)
   IF (crmstatus != 0)
    CALL echo("Error in Begin Task for task 3202004.")
    CALL echo(build("Crm Status: ",crmstatus))
    CALL echo("Cannot call Event_Ensure. Exiting Script.")
    CALL uar_crmendapp(happ)
    SET happ = 0
    GO TO exit_script
   ENDIF
   SET crmstatus = uar_crmbeginreq(htask,"",3200203,hstep)
   IF (crmstatus != 0)
    CALL echo("Error in Begin Request for request 3200203.")
    CALL echo(build("Crm Status: ",crmstatus))
   ELSE
    SET hreq = uar_crmgetrequest(hstep)
    FOR (ndx = 1 TO totaldefcount)
      SET hitem = uar_srvadditem(hreq,"definition_ids")
      SET srvstat = uar_srvsetdouble(hitem,"definition_id",totaldefinition->lst[ndx].
       total_definition_id)
      SET srvstat = uar_srvsetdate(hitem,"definition_effective_dt_tm",cnvtdatetimeutc(totaldefinition
        ->lst[ndx].begin_effective_dt_tm))
    ENDFOR
    SET stat = alterlist(totaldefinition->lst,0)
    SET crmstatus = uar_crmperform(hstep)
    IF (crmstatus != 0)
     CALL echo(build("CrmPerform: stat = ",crmstatus))
     GO TO exit_script
    ENDIF
    SET hrep = uar_crmgetreply(hstep)
    SET definitioncount = uar_srvgetitemcount(hrep,"definitions")
    SET stat = alterlist(totaldefinition->lst,definitioncount)
    FOR (ndx = 1 TO definitioncount)
      SET hitem = uar_srvgetitem(hrep,"definitions",(ndx - 1))
      SET totaldefinition->lst[ndx].total_definition_id = uar_srvgetdouble(hitem,"definition_id")
      SET totaldefinition->lst[ndx].type_cd = uar_srvgetdouble(hitem,"type_cd")
      SET stat = uar_srvgetdate(hitem,"begin_effective_dt_tm",totaldefinition->lst[ndx].
       begin_effective_dt_tm)
      SET stat = uar_srvgetdate(hitem,"end_effective_dt_tm",totaldefinition->lst[ndx].
       end_effective_dt_tm)
      SET elementcount = uar_srvgetitemcount(hitem,"elements")
      SET stat = alterlist(totaldefinition->lst[ndx].elements,elementcount)
      FOR (ndx2 = 1 TO elementcount)
        SET helement = uar_srvgetitem(hitem,"elements",(ndx2 - 1))
        SET totaldefinition->lst[ndx].elements[ndx2].event_cd = uar_srvgetdouble(helement,"event_cd")
        SET totaldefinition->lst[ndx].elements[ndx2].route_cd = uar_srvgetdouble(helement,"route_cd")
        SET totaldefinition->lst[ndx].elements[ndx2].iv_event_cd = uar_srvgetdouble(helement,
         "iv_event_cd")
      ENDFOR
    ENDFOR
    SET crmstatus = uar_crmendreq(hstep)
    IF (crmstatus != 0)
     CALL echo(build("CrmEndReq: stat = ",crmstatus))
    ENDIF
   ENDIF
   SET crmstatus = uar_crmendtask(htask)
   SET crmstatus = uar_crmendapp(happ)
 END ;Subroutine
 SUBROUTINE query_simple_medication_io_results(null)
   SELECT DISTINCT INTO "nl"
    ceior.event_id, cemr.admin_route_cd, cemr.iv_event_cd
    FROM ce_intake_output_result ceior,
     clinical_event ce,
     ce_med_result cemr,
     (dummyt d  WITH seq = value(ioresultitemcnt))
    PLAN (d
     WHERE (request->io_result_list[d.seq].person_id != 0))
     JOIN (ceior
     WHERE (ceior.event_id=request->io_result_list[d.seq].event_id)
      AND ceior.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100")
      AND ceior.io_end_dt_tm > cnvtdatetimeutc(valstartdttm))
     JOIN (ce
     WHERE ce.parent_event_id=ceior.reference_event_id
      AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100"))
     JOIN (cemr
     WHERE cemr.event_id=ce.event_id
      AND cemr.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100"))
    DETAIL
     request->io_result_list[d.seq].route_cd = cemr.admin_route_cd, request->io_result_list[d.seq].
     iv_event_cd = cemr.iv_event_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE query_continuous_iv_results(null)
   SELECT DISTINCT INTO "nl"
    ior.event_id, cem.admin_route_cd, cem.iv_event_cd
    FROM ce_intake_output_result ior,
     clinical_event ce,
     ce_med_result cem,
     (dummyt d  WITH seq = value(ioresultitemcnt))
    PLAN (d
     WHERE (request->io_result_list[d.seq].person_id != 0)
      AND (request->io_result_list[d.seq].route_cd=0.0)
      AND (request->io_result_list[d.seq].iv_event_cd=0.0))
     JOIN (ior
     WHERE (ior.event_id=request->io_result_list[d.seq].event_id)
      AND ior.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100")
      AND ior.io_end_dt_tm > cnvtdatetimeutc(valstartdttm))
     JOIN (ce
     WHERE ce.event_id=ior.reference_event_id
      AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100"))
     JOIN (cem
     WHERE cem.event_id=ce.event_id
      AND cem.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100"))
    DETAIL
     request->io_result_list[d.seq].route_cd = cem.admin_route_cd, request->io_result_list[d.seq].
     iv_event_cd = cem.iv_event_cd
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE determine_med_result_suspects(null)
   DECLARE medndx = i4 WITH protect
   DECLARE totaldefndx = i4 WITH protect
   DECLARE suspectndx = i4 WITH protect
   DECLARE totaldefcnt = i4 WITH protect, constant(size(totaldefinition->lst,5))
   DECLARE candidatecnt = i4 WITH protect, constant(size(suspectcandidates->lst,5))
   DECLARE elementcnt = i4 WITH protect
   DECLARE oldroutepos = i4 WITH protect
   DECLARE newroutepos = i4 WITH protect
   DECLARE candidatendx = i4 WITH protect
   FOR (medndx = 1 TO meditemcnt)
    SET candidatendx = 1
    WHILE (candidatendx > 0
     AND candidatendx <= candidatecnt)
      SET oldroutepos = 0
      SET newroutepos = 0
      SET totaldefndx = 0
      SET candidatendx = locateval(candidatendx,candidatendx,candidatecnt,request->med_result_list[
       medndx].event_id,suspectcandidates->lst[candidatendx].event_id)
      IF (candidatendx)
       SET totaldefndx = findtotaldefbyperformeddttm(suspectcandidates->lst[candidatendx].
        io_total_definition_id,cnvtdatetimeutc(suspectcandidates->lst[candidatendx].performed_dt_tm))
      ENDIF
      IF (totaldefndx)
       IF ((((totaldefinition->lst[totaldefndx].type_cd=io_total_intake)) OR ((((totaldefinition->
       lst[totaldefndx].type_cd=io_total_output)) OR ((totaldefinition->lst[totaldefndx].type_cd=
       io_total_balance))) )) )
        SET elementcnt = size(totaldefinition->lst[totaldefndx].elements,5)
        SET oldroutepos = 0
        SET oldroutepos = locateval(oldroutepos,1,elementcnt,request->med_result_list[medndx].
         old_admin_route_cd,totaldefinition->lst[totaldefndx].elements[oldroutepos].route_cd)
        SET newroutepos = 0
        SET newroutepos = locateval(newroutepos,1,elementcnt,request->med_result_list[medndx].
         new_admin_route_cd,totaldefinition->lst[totaldefndx].elements[newroutepos].route_cd)
       ENDIF
      ENDIF
      IF (((oldroutepos != 0
       AND newroutepos=0) OR (oldroutepos=0
       AND newroutepos != 0)) )
       SET suspectcandidates->lst[candidatendx].suspect_flag = 1
      ENDIF
      IF (candidatendx)
       SET candidatendx = (candidatendx+ 1)
      ENDIF
    ENDWHILE
   ENDFOR
 END ;Subroutine
 SUBROUTINE determine_io_result_suspects(null)
   DECLARE ioresultndx = i4 WITH protect
   DECLARE totaldefndx = i4 WITH protect
   DECLARE candidatendx = i4 WITH protect
   DECLARE elementcnt = i4 WITH protect
   DECLARE elementpos = i4 WITH protect
   DECLARE totaldefcnt = i4 WITH protect, constant(size(totaldefinition->lst,5))
   DECLARE candidatecnt = i4 WITH protect, constant(size(suspectcandidates->lst,5))
   FOR (ioresultndx = 1 TO ioresultitemcnt)
    SET candidatendx = 1
    WHILE (candidatendx > 0
     AND candidatendx <= candidatecnt)
      SET totaldefndx = 0
      SET candidatendx = locateval(candidatendx,candidatendx,candidatecnt,request->io_result_list[
       ioresultndx].event_id,suspectcandidates->lst[candidatendx].event_id)
      IF (candidatendx)
       SET totaldefndx = findtotaldefbyperformeddttm(suspectcandidates->lst[candidatendx].
        io_total_definition_id,cnvtdatetimeutc(suspectcandidates->lst[candidatendx].performed_dt_tm))
      ENDIF
      IF (totaldefndx)
       IF ((request->io_result_list[ioresultndx].io_type_flag=1)
        AND (((totaldefinition->lst[totaldefndx].type_cd=io_total_allintake)) OR ((totaldefinition->
       lst[totaldefndx].type_cd=io_total_allbalance))) )
        SET suspectcandidates->lst[candidatendx].suspect_flag = 1
       ELSEIF ((request->io_result_list[ioresultndx].io_type_flag=2)
        AND (((totaldefinition->lst[totaldefndx].type_cd=io_total_alloutput)) OR ((totaldefinition->
       lst[totaldefndx].type_cd=io_total_allbalance))) )
        SET suspectcandidates->lst[candidatendx].suspect_flag = 1
       ELSEIF ((((totaldefinition->lst[totaldefndx].type_cd=io_total_intake)) OR ((((totaldefinition
       ->lst[totaldefndx].type_cd=io_total_output)) OR ((totaldefinition->lst[totaldefndx].type_cd=
       io_total_balance))) )) )
        SET elementcnt = size(totaldefinition->lst[totaldefndx].elements,5)
        SET elementpos = 0
        IF ((request->io_result_list[ioresultndx].event_cd != 0.0))
         SET elementpos = locateval(elementpos,1,elementcnt,request->io_result_list[ioresultndx].
          event_cd,totaldefinition->lst[totaldefndx].elements[elementpos].event_cd)
        ENDIF
        IF ((request->io_result_list[ioresultndx].route_cd != 0.0)
         AND elementpos=0)
         SET elementpos = locateval(elementpos,1,elementcnt,request->io_result_list[ioresultndx].
          route_cd,totaldefinition->lst[totaldefndx].elements[elementpos].route_cd)
        ENDIF
        IF ((request->io_result_list[ioresultndx].iv_event_cd != 0.0)
         AND elementpos=0)
         SET elementpos = locateval(elementpos,1,elementcnt,request->io_result_list[ioresultndx].
          iv_event_cd,totaldefinition->lst[totaldefndx].elements[elementpos].iv_event_cd)
        ENDIF
        IF (elementpos)
         SET suspectcandidates->lst[candidatendx].suspect_flag = 1
        ENDIF
       ENDIF
      ENDIF
      IF (candidatendx)
       SET candidatendx = (candidatendx+ 1)
      ENDIF
    ENDWHILE
   ENDFOR
 END ;Subroutine
 SUBROUTINE update_suspect_io_total_results(null)
   DECLARE suspecttotalcnt = i4 WITH protect, noconstant(size(suspecttotals->lst,5))
   DECLARE candidatecnt = i4 WITH protect, constant(size(suspectcandidates->lst,5))
   DECLARE suspectpos = i4 WITH protect
   DECLARE ndx = i4 WITH protect
   IF (mod(suspecttotalcnt,10))
    SET stat = alterlist(suspecttotals->lst,(10 - mod(suspecttotalcnt,10)))
   ENDIF
   FOR (ndx = 1 TO candidatecnt)
     IF ((suspectcandidates->lst[ndx].suspect_flag=1))
      SET suspectpos = 0
      SET suspectpos = locateval(suspectpos,1,suspecttotalcnt,suspectcandidates->lst[ndx].
       ce_io_total_result_id,suspecttotals->lst[suspectpos].ce_io_total_result_id)
      IF (suspectpos=0)
       SET suspecttotalcnt = (suspecttotalcnt+ 1)
       IF (mod(suspecttotalcnt,10)=1)
        SET stat = alterlist(suspecttotals->lst,(suspecttotalcnt+ 9))
       ENDIF
       SET suspecttotals->lst[suspecttotalcnt].ce_io_total_result_id = suspectcandidates->lst[ndx].
       ce_io_total_result_id
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(suspecttotals->lst,suspecttotalcnt)
   IF (suspecttotalcnt)
    UPDATE  FROM ce_io_total_result iotr,
      (dummyt d  WITH seq = value(suspecttotalcnt))
     SET iotr.suspect_flag = 1
     PLAN (d)
      JOIN (iotr
      WHERE (iotr.ce_io_total_result_id=suspecttotals->lst[d.seq].ce_io_total_result_id))
     WITH nocounter
    ;end update
    COMMIT
   ENDIF
 END ;Subroutine
#exit_script
 SET stat = alterlist(suspecttotals->lst,0)
 SET stat = alterlist(suspectcandidates->lst,0)
 DECLARE totaldefinitioncnt = i4 WITH constant(size(totaldefinition->lst,5))
 DECLARE elementcnt = i4 WITH noconstant(0)
 DECLARE ndx = i4
 DECLARE ndx2 = i4
 FOR (ndx = 1 TO totaldefinitioncnt)
  SET elementcnt = size(totaldefinition->lst[ndx].elements,5)
  FOR (ndx2 = 1 TO elementcnt)
    SET stat = alterlist(totaldefinition->lst[ndx].elements,0)
  ENDFOR
 ENDFOR
 SET stat = alterlist(totaldefinition->lst,0)
END GO
