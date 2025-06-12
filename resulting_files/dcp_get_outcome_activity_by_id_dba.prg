CREATE PROGRAM dcp_get_outcome_activity_by_id:dba
 SET modify = predeclare
 CALL echo("<------------------------------------------------->")
 CALL echo("<---   BEGIN: DCP_GET_OUTCOME_ACTIVITY_BY_ID   --->")
 CALL echo("<------------------------------------------------->")
 DECLARE qtimerbegindttm = dq8 WITH private, noconstant(cnvtdatetime(sysdate))
 CALL echo("====================================================")
 CALL echo(build("===     Begin Dt/Tm: ",format(qtimerbegindttm,";;Q"),"      ==="))
 CALL echo("====================================================")
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 outcomes[*]
      2 outcomeactid = f8
      2 encntrid = f8
      2 eventcd = f8
      2 taskassaycd = f8
      2 outcomecatid = f8
      2 outcomeclasscd = f8
      2 outcometypecd = f8
      2 description = vc
      2 expectation = vc
      2 outcomestatuscd = f8
      2 resulttypecd = f8
      2 tgttypecd = f8
      2 tgtdurationqty = i4
      2 tgtdurationunitcd = f8
      2 expandqty = i4
      2 expandunitcd = f8
      2 startdttm = dq8
      2 enddttm = dq8
      2 operandmean = vc
      2 updtcnt = i4
      2 singleselectind = i2
      2 hideexpectationind = i2
      2 starttz = i4
      2 endtz = i4
      2 nomenstringflag = i2
      2 preferred[*]
        3 nomenclatureid = f8
        3 nomendisp = vc
      2 criteria[*]
        3 outcomecriteriaid = f8
        3 operatorcd = f8
        3 resultvalue = f8
        3 resultunitcd = f8
        3 nomenclatureid = f8
        3 sequence = i4
      2 startestimatedind = i2
      2 endestimatedind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(request->debug,0)=1)
  CALL echo("DCP_GET_OUTCOME_ACTIVITY_BY_ID request")
  CALL echorecord(request)
 ENDIF
 DECLARE i = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE batch_size = i4 WITH constant(20)
 DECLARE sdisplay = vc
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE nexpandindex = i4 WITH noconstant(nstart)
 DECLARE noutcomenum = i4 WITH noconstant(0)
 DECLARE noutcomeindex = i4 WITH noconstant(0)
 DECLARE npreferredsize = i4 WITH noconstant(0)
 DECLARE npreferredindex = i4 WITH noconstant(0)
 DECLARE npreferrednum = i4 WITH noconstant(0)
 DECLARE idcnt = i4 WITH noconstant(0)
 DECLARE cdcnt = i4 WITH noconstant(0)
 DECLARE idhigh = i4 WITH constant(value(size(request->outcomes,5)))
 DECLARE cdhigh = i4 WITH constant(value(size(request->statuses,5)))
 DECLARE whereclause = vc
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE dentirescriptdiffinsec = f8 WITH protect, noconstant(0.0)
 IF (idhigh > 0)
  SET whereclause =
  "expand(idCnt,1,idHigh,oa.outcome_activity_id,request->outcomes[idCnt]->outcomeActId)"
 ELSE
  CALL report_failure("VALIDATE","F","REQUEST","No outcomeActivityId's in the incoming request")
  GO TO endscript
 ENDIF
 IF (cdhigh > 0)
  SET whereclause = concat(whereclause,
   " AND expand(cdCnt,1,cdHigh,oa.outcome_status_cd,request->statuses[cdCnt]->outcomeStatusCd)")
 ENDIF
 SELECT INTO "nl:"
  FROM outcome_activity oa,
   outcome_criteria oc
  PLAN (oa
   WHERE parser(trim(whereclause)))
   JOIN (oc
   WHERE oc.outcome_activity_id=oa.outcome_activity_id)
  HEAD REPORT
   outcnt = 0
  HEAD oa.outcome_activity_id
   outcnt += 1
   IF (outcnt > size(reply->outcomes,5))
    stat = alterlist(reply->outcomes,(outcnt+ 10))
   ENDIF
   reply->outcomes[outcnt].outcomeactid = oa.outcome_activity_id, reply->outcomes[outcnt].encntrid =
   oa.encntr_id, reply->outcomes[outcnt].eventcd = oa.event_cd,
   reply->outcomes[outcnt].taskassaycd = oa.task_assay_cd, reply->outcomes[outcnt].outcomecatid = oa
   .outcome_catalog_id, reply->outcomes[outcnt].outcomeclasscd = oa.outcome_class_cd,
   reply->outcomes[outcnt].outcometypecd = oa.outcome_type_cd, reply->outcomes[outcnt].description =
   oa.description, reply->outcomes[outcnt].expectation = oa.expectation,
   reply->outcomes[outcnt].outcomestatuscd = oa.outcome_status_cd, reply->outcomes[outcnt].
   resulttypecd = oa.result_type_cd, reply->outcomes[outcnt].tgttypecd = oa.target_type_cd,
   reply->outcomes[outcnt].tgtdurationqty = oa.target_duration_qty, reply->outcomes[outcnt].
   tgtdurationunitcd = oa.target_duration_unit_cd, reply->outcomes[outcnt].expandqty = oa.expand_qty,
   reply->outcomes[outcnt].expandunitcd = oa.expand_unit_cd, reply->outcomes[outcnt].startdttm =
   cnvtdatetime(oa.start_dt_tm), reply->outcomes[outcnt].enddttm = cnvtdatetime(oa.end_dt_tm),
   reply->outcomes[outcnt].operandmean = oa.operand_mean, reply->outcomes[outcnt].updtcnt = oa
   .updt_cnt, reply->outcomes[outcnt].singleselectind = oa.single_select_ind,
   reply->outcomes[outcnt].hideexpectationind = oa.hide_expectation_ind, reply->outcomes[outcnt].
   starttz = oa.start_tz, reply->outcomes[outcnt].endtz = oa.end_tz,
   reply->outcomes[outcnt].nomenstringflag = oa.nomen_string_flag, reply->outcomes[outcnt].
   startestimatedind = oa.start_estimated_ind, reply->outcomes[outcnt].endestimatedind = oa
   .end_estimated_ind,
   critcnt = 0
  DETAIL
   critcnt += 1
   IF (critcnt > size(reply->outcomes[outcnt].criteria,5))
    stat = alterlist(reply->outcomes[outcnt].criteria,(critcnt+ 5))
   ENDIF
   reply->outcomes[outcnt].criteria[critcnt].outcomecriteriaid = oc.outcome_criteria_id, reply->
   outcomes[outcnt].criteria[critcnt].operatorcd = oc.operator_cd, reply->outcomes[outcnt].criteria[
   critcnt].resultvalue = oc.result_value,
   reply->outcomes[outcnt].criteria[critcnt].resultunitcd = oc.result_unit_cd, reply->outcomes[outcnt
   ].criteria[critcnt].nomenclatureid = oc.nomenclature_id, reply->outcomes[outcnt].criteria[critcnt]
   .sequence = oc.sequence
  FOOT  oa.outcome_activity_id
   stat = alterlist(reply->outcomes[outcnt].criteria,critcnt)
  FOOT REPORT
   stat = alterlist(reply->outcomes,outcnt)
  WITH nocounter
 ;end select
 DECLARE list_size = i4 WITH constant(size(reply->outcomes,5))
 DECLARE loop_count = i4 WITH constant(ceil((cnvtreal(list_size)/ batch_size)))
 DECLARE new_size = i4 WITH constant((loop_count * batch_size))
 DECLARE dtaskassaycd = f8 WITH noconstant(0.0)
 DECLARE dnomenclatureid = f8 WITH noconstant(0.0)
 DECLARE ssourcestring = vc
 DECLARE sshortstring = vc
 DECLARE smnemonic = vc
 SET stat = alterlist(reply->outcomes,new_size)
 FOR (i = (list_size+ 1) TO new_size)
  SET reply->outcomes[i].taskassaycd = reply->outcomes[list_size].taskassaycd
  SET reply->outcomes[i].nomenstringflag = reply->outcomes[list_size].nomenstringflag
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_count)),
   reference_range_factor rrf,
   alpha_responses ar,
   nomenclature n
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (rrf
   WHERE expand(nexpandindex,nstart,(nstart+ (batch_size - 1)),rrf.task_assay_cd,reply->outcomes[
    nexpandindex].taskassaycd))
   JOIN (ar
   WHERE ar.reference_range_factor_id=rrf.reference_range_factor_id)
   JOIN (n
   WHERE n.nomenclature_id=ar.nomenclature_id)
  ORDER BY rrf.task_assay_cd, n.nomenclature_id
  HEAD REPORT
   noutcomeindex = 0
  HEAD n.nomenclature_id
   dtaskassaycd = rrf.task_assay_cd, dnomenclatureid = n.nomenclature_id, ssourcestring = n
   .source_string,
   sshortstring = n.short_string, smnemonic = n.mnemonic, noutcomeindex = 0,
   noutcomeindex = locateval(noutcomenum,1,list_size,dtaskassaycd,reply->outcomes[noutcomenum].
    taskassaycd)
   WHILE (noutcomeindex > 0)
     npreferredsize = 0, npreferredsize = size(reply->outcomes[noutcomeindex].preferred,5)
     IF (npreferredsize > 0)
      npreferredindex = locateval(npreferrednum,1,npreferredsize,dnomenclatureid,reply->outcomes[
       noutcomeindex].preferred[npreferrednum].nomenclatureid)
     ENDIF
     IF (npreferredindex < 1)
      npreferredsize += 1
      IF ((reply->outcomes[noutcomeindex].nomenstringflag=0))
       sdisplay = sshortstring
      ELSEIF ((reply->outcomes[noutcomeindex].nomenstringflag=1))
       sdisplay = smnemonic
      ELSE
       sdisplay = ssourcestring
      ENDIF
      stat = alterlist(reply->outcomes[noutcomeindex].preferred,npreferredsize), reply->outcomes[
      noutcomeindex].preferred[npreferredsize].nomenclatureid = dnomenclatureid, reply->outcomes[
      noutcomeindex].preferred[npreferredsize].nomendisp = sdisplay
     ENDIF
     noutcomeindex = locateval(noutcomenum,(noutcomeindex+ 1),list_size,dtaskassaycd,reply->outcomes[
      noutcomenum].taskassaycd)
   ENDWHILE
  DETAIL
   dummy = 0
  FOOT  n.nomenclature_id
   dummy = 0
  FOOT REPORT
   dummy = 0
  WITH nocounter, orahintcbo(
    "LEADING(RRF) INDEX(RRF XIE1REFERENCE_RANGE_FACTOR) INDEX(N XPKNOMENCLATURE)")
 ;end select
 SET stat = alterlist(reply->outcomes,list_size)
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   SET cfailed = "T"
   SET stat = alterlist(reply->status_data.subeventstatus,(value(size(reply->status_data.
      subeventstatus,5))+ 1))
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#endscript
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (validate(request->debug,0)=1)
  CALL echo("DCP_GET_OUTCOME_ACTIVITY_BY_ID reply")
  CALL echorecord(reply)
 ENDIF
 SET mod_date = "January 30, 2020"
 SET last_mod = "010"
 SET dentirescriptdiffinsec = datetimediff(cnvtdatetime(sysdate),qtimerbegindttm,5)
 CALL echo("=====================================")
 CALL echo(build("===   Total Script Time in Seconds: ",dentirescriptdiffinsec,"   ==="))
 CALL echo("=====================================")
 CALL echo("<---------------------------------------------->")
 CALL echo("<---   END DCP_GET_OUTCOME_ACTIVITY_BY_ID   --->")
 CALL echo("<---------------------------------------------->")
END GO
