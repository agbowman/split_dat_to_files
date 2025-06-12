CREATE PROGRAM cp_get_activity_for_events:dba
 RECORD reply(
   1 activity[*]
     2 chart_section_id = f8
     2 section_seq = i4
     2 section_type_flag = i2
     2 chart_group_id = f8
     2 group_seq = i4
     2 zone = i4
     2 flex_type_flag = i2
     2 doc_type_flag = i2
     2 procedure_seq = i4
     2 procedure_type_flag = i2
     2 event_set_name = vc
     2 dcp_forms_ref_id = f8
     2 catalog_cd = f8
     2 event_cds[*]
       3 event_cd = f8
       3 task_assay_cd = f8
       3 suppressed_ind = i2
   1 parent_event_ids[*]
     2 parent_event_id = f8
   1 inerr_events[*]
     2 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD chart_events(
   1 events[*]
     2 event_id = f8
     2 dontcare = i2
 )
 RECORD prelim_events(
   1 events[*]
     2 event_id = f8
     2 dontcare = i2
     2 ecg_flag = i2
 )
 DECLARE date_clause = vc
 DECLARE where_clause = vc
 DECLARE scope_clause = vc
 DECLARE other_clause = vc
 DECLARE s_date = vc
 DECLARE e_date = vc
 DECLARE auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE unauth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"UNAUTH")), protect
 DECLARE mod_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE alt_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE super_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"SUPERSEDED")), protect
 DECLARE inlab_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN LAB")), protect
 DECLARE inprog_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN PROGRESS")), protect
 DECLARE trans_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"TRANSCRIBED")), protect
 DECLARE inerror1_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR")), protect
 DECLARE inerror2_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN ERROR")), protect
 DECLARE inerrornomut_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOMUT")), protect
 DECLARE inerrornoview_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOVIEW")), protect
 DECLARE cancelled_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"CANCELLED")), protect
 DECLARE rejected_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"REJECTED")), protect
 DECLARE del_stat_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"DELETED")), protect
 DECLARE placehold_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER")), protect
 DECLARE proc_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PROCEDURE")), protect
 DECLARE doc_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
 DECLARE signed_cd = f8 WITH constant(uar_get_code_by("MEANING",4000341,"SIGNED")), protect
 DECLARE ecg_cd = f8 WITH constant(uar_get_code_by("MEANING",5801,"ECG")), protect
 DECLARE dicom_cd = f8 WITH constant(uar_get_code_by("MEANING",25,"DICOM_SIUID")), protect
 DECLARE acrnema_cd = f8 WITH constant(uar_get_code_by("MEANING",23,"ACRNEMA")), protect
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE encntr_level_doc = i2 WITH constant(1)
 DECLARE patient_level_doc = i2 WITH constant(2)
 DECLARE doctype_flag_ind = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE buildscopeclause(null) = null
 DECLARE builddateclause(null) = null
 DECLARE buildotherclause(null) = null
 DECLARE buildwhereclause(null) = null
 DECLARE getevents(null) = null
 DECLARE getchartevents(null) = null
 DECLARE killinvalidevents(null) = null
 DECLARE killinvalidecgevents(null) = null
 DECLARE moveactivitytoreply(null) = null
 CALL buildwhereclause(null)
 CALL echo(concat("Where Clause = ",where_clause))
 CALL getchartevents(null)
 CALL getevents(null)
 IF (curqual > 0)
  CALL killinvalidevents(null)
  CALL moveactivitytoreply(null)
 ENDIF
 SUBROUTINE buildwhereclause(null)
   CALL buildscopeclause(null)
   CALL builddateclause(null)
   CALL buildotherclause(null)
   SET where_clause = concat(scope_clause," and ",date_clause," and ",other_clause)
 END ;Subroutine
 SUBROUTINE buildscopeclause(null)
   SET scope_clause = build(
    "expand(idx, 1, size(chart_events->events, 5), ce.event_id, chart_events->events[idx].event_id)")
 END ;Subroutine
 SUBROUTINE builddateclause(null)
   IF ((request->date_range_ind=1))
    IF ((request->begin_dt_tm > 0))
     SET s_date = "cnvtdatetime(request->begin_dt_tm)"
    ELSE
     SET s_date = "cnvtdatetime('01-Jan-1800')"
    ENDIF
    IF ((request->end_dt_tm > 0))
     SET e_date = "cnvtdatetime(request->end_dt_tm)"
    ELSE
     SET e_date = "cnvtdatetime('31-Dec-2100')"
    ENDIF
    IF ((request->request_type=2)
     AND (request->mcis_ind=0))
     SET date_clause = concat(" (ce.verified_dt_tm between ",s_date," and ",e_date)
     IF ((((request->pending_flag=1)) OR ((request->pending_flag=2))) )
      SET date_clause = concat(date_clause," or ce.performed_dt_tm between ",s_date," and ",e_date)
     ENDIF
     IF ((request->pending_flag=2))
      SET date_clause = concat(date_clause," or ce.event_end_dt_tm between ",s_date," and ",e_date)
     ENDIF
     SET date_clause = concat(date_clause,")")
    ELSE
     IF ((request->result_lookup_ind=1))
      SET date_clause = concat(" (ce.event_end_dt_tm+0 between ",s_date," and ",e_date,")")
     ELSE
      SET date_clause = concat(" (ce.clinsig_updt_dt_tm+0 between ",s_date," and ",e_date,")")
     ENDIF
    ENDIF
   ELSE
    SET date_clause = "1=1"
   ENDIF
 END ;Subroutine
 SUBROUTINE buildotherclause(null)
  SET other_clause = concat("ce.record_status_cd != del_stat_cd and ",
   "ce.event_class_cd != placehold_class_cd and ","ce.view_level > 0 and ce.publish_flag = 1 and ",
   "(ce.result_status_cd in")
  IF ((request->pending_flag=0))
   SET other_clause = concat(other_clause," (auth_cd, mod_cd, super_cd, alt_cd))")
  ELSEIF ((request->pending_flag=1))
   SET other_clause = concat(other_clause," (auth_cd, mod_cd, super_cd, alt_cd,",
    " inlab_cd, inprog_cd))")
  ELSE
   SET other_clause = concat(other_clause," (auth_cd, mod_cd, super_cd, alt_cd,",
    " inlab_cd, inprog_cd, trans_cd, unauth_cd))")
  ENDIF
 END ;Subroutine
 SUBROUTINE getevents(null)
  CALL echo("In GetEvents")
  SELECT DISTINCT INTO "nl:"
   FROM clinical_event ce,
    (dummyt d1  WITH seq = value(size(request->activity,5))),
    (dummyt d2  WITH seq = 1)
   PLAN (ce
    WHERE parser(where_clause))
    JOIN (d1
    WHERE (request->activity[d1.seq].procedure_type_flag=0)
     AND maxrec(d2,size(request->activity[d1.seq].event_cds,5)))
    JOIN (d2
    WHERE (request->activity[d1.seq].event_cds[d2.seq].event_cd=ce.event_cd))
   ORDER BY ce.event_id
   HEAD REPORT
    eventcnt = 0
   DETAIL
    eventcnt = (eventcnt+ 1), stat = alterlist(prelim_events->events,eventcnt), prelim_events->
    events[eventcnt].event_id = ce.event_id,
    prelim_events->events[eventcnt].dontcare = 0
    IF (ce.event_class_cd=proc_class_cd)
     prelim_events->events[eventcnt].ecg_flag = 1, prelim_events->events[eventcnt].dontcare = 1
    ELSE
     prelim_events->events[eventcnt].ecg_flag = 0
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE killinvalidevents(null)
   CALL echo("In KillInvalidEvents")
   SELECT DISTINCT INTO "nl:"
    FROM clinical_event cce,
     clinical_event ce,
     (dummyt d  WITH seq = value(size(prelim_events->events,5)))
    PLAN (d)
     JOIN (cce
     WHERE (cce.event_id=prelim_events->events[d.seq].event_id)
      AND cce.parent_event_id != 0)
     JOIN (ce
     WHERE ce.event_id=cce.parent_event_id
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
    ORDER BY cce.event_id, cce.valid_until_dt_tm DESC, ce.valid_until_dt_tm DESC
    HEAD cce.event_id
     IF (ce.result_status_cd IN (inerror1_cd, inerror2_cd, inerrornomut_cd, inerrornoview_cd,
     rejected_cd,
     cancelled_cd))
      prelim_events->events[d.seq].dontcare = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (size(prelim_events->events,5) > 0)
    CALL killinvalidecgevents(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE killinvalidecgevents(null)
   CALL echo("In KillInvalidECGEvents")
   DECLARE ecg_date_clause = vc
   IF ((request->result_lookup_ind=1))
    SET ecg_date_clause = concat(" (pce.event_end_dt_tm+0 between ",s_date," and ",e_date,")")
   ELSE
    SET ecg_date_clause = concat(" (pce.clinsig_updt_dt_tm+0 between ",s_date," and ",e_date,")")
   ENDIF
   CALL echo(ecg_date_clause)
   SELECT DISTINCT INTO "nl:"
    FROM clinical_event pce,
     clinical_event ce,
     cv_proc cv,
     ce_blob_result cbr,
     (dummyt d  WITH seq = value(size(prelim_events->events,5)))
    PLAN (d
     WHERE (prelim_events->events[d.seq].ecg_flag=1))
     JOIN (pce
     WHERE (pce.event_id=prelim_events->events[d.seq].event_id)
      AND pce.event_class_cd=proc_class_cd
      AND pce.parent_event_id != 0
      AND pce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND parser(ecg_date_clause))
     JOIN (ce
     WHERE ce.parent_event_id=pce.event_id
      AND ce.event_class_cd=doc_class_cd
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     JOIN (cv
     WHERE cv.group_event_id=pce.event_id
      AND cv.proc_status_cd=signed_cd
      AND cv.activity_subtype_cd=ecg_cd)
     JOIN (cbr
     WHERE cbr.event_id=ce.event_id
      AND cbr.storage_cd=dicom_cd
      AND cbr.format_cd=acrnema_cd)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     prelim_events->events[d.seq].dontcare = 0
    WITH nocounter
   ;end select
   CALL echorecord(prelim_events)
 END ;Subroutine
 SUBROUTINE moveactivitytoreply(null)
   CALL echo("In MoveActivityToReply")
   SELECT DISTINCT INTO "nl:"
    section_seq = request->activity[d2.seq].section_seq, group_seq = request->activity[d2.seq].
    group_seq, zone = request->activity[d2.seq].zone,
    procedure_seq = request->activity[d2.seq].procedure_seq, event_cd = request->activity[d2.seq].
    event_cds[d3.seq].event_cd
    FROM clinical_event ce,
     (dummyt d1  WITH seq = value(size(prelim_events->events,5))),
     (dummyt d2  WITH seq = value(size(request->activity,5))),
     (dummyt d3  WITH seq = 1)
    PLAN (d1
     WHERE (prelim_events->events[d1.seq].dontcare=0))
     JOIN (ce
     WHERE (ce.event_id=prelim_events->events[d1.seq].event_id)
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND parser(other_clause)
      AND parser(date_clause))
     JOIN (d2
     WHERE (request->activity[d2.seq].procedure_type_flag=0)
      AND maxrec(d3,size(request->activity[d2.seq].event_cds,5)))
     JOIN (d3
     WHERE (request->activity[d2.seq].event_cds[d3.seq].event_cd=ce.event_cd))
    ORDER BY section_seq, group_seq, zone,
     procedure_seq, event_cd, ce.parent_event_id
    HEAD REPORT
     activitycnt = 0, eventcdcnt = 0, pcnt = 0
    HEAD section_seq
     do_nothing = 0
    HEAD group_seq
     do_nothing = 0
    HEAD zone
     do_nothing = 0
    HEAD procedure_seq
     IF ((((request->activity[d2.seq].doc_type_flag=encntr_level_doc)
      AND ce.encntr_id=0.0) OR ((request->activity[d2.seq].doc_type_flag=patient_level_doc)
      AND ce.encntr_id > 0.0)) )
      doctype_flag_ind = 1
     ELSE
      doctype_flag_ind = 0, activitycnt = (activitycnt+ 1)
      IF (mod(activitycnt,5)=1)
       stat = alterlist(reply->activity,(activitycnt+ 4))
      ENDIF
      reply->activity[activitycnt].chart_section_id = request->activity[d2.seq].chart_section_id,
      reply->activity[activitycnt].section_seq = request->activity[d2.seq].section_seq, reply->
      activity[activitycnt].chart_group_id = request->activity[d2.seq].chart_group_id,
      reply->activity[activitycnt].group_seq = request->activity[d2.seq].group_seq, reply->activity[
      activitycnt].zone = request->activity[d2.seq].zone, reply->activity[activitycnt].procedure_seq
       = request->activity[d2.seq].procedure_seq,
      reply->activity[activitycnt].procedure_type_flag = request->activity[d2.seq].
      procedure_type_flag, reply->activity[activitycnt].event_set_name = request->activity[d2.seq].
      event_set_name, reply->activity[activitycnt].catalog_cd = request->activity[d2.seq].catalog_cd
     ENDIF
    HEAD event_cd
     IF (doctype_flag_ind != 1)
      eventcdcnt = (eventcdcnt+ 1)
      IF (mod(eventcdcnt,5)=1)
       stat = alterlist(reply->activity[activitycnt].event_cds,(eventcdcnt+ 4))
      ENDIF
      reply->activity[activitycnt].event_cds[eventcdcnt].event_cd = event_cd
     ENDIF
    DETAIL
     IF (doctype_flag_ind != 1)
      pcnt = (pcnt+ 1)
      IF (mod(pcnt,5)=1)
       stat = alterlist(reply->parent_event_ids,(pcnt+ 4))
      ENDIF
      reply->parent_event_ids[pcnt].parent_event_id = ce.parent_event_id
     ENDIF
    FOOT  event_cd
     do_nothing = 0
    FOOT  procedure_seq
     IF (doctype_flag_ind != 1)
      stat = alterlist(reply->activity[activitycnt].event_cds,eventcdcnt), eventcdcnt = 0
     ENDIF
    FOOT  zone
     do_nothing = 0
    FOOT  group_seq
     do_nothing = 0
    FOOT  section_seq
     do_nothing = 0
    FOOT REPORT
     stat = alterlist(reply->activity,activitycnt), stat = alterlist(reply->parent_event_ids,pcnt)
    WITH nocounter
   ;end select
   SELECT DISTINCT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(prelim_events->events,5))),
     chart_req_inerr_event cre
    PLAN (d
     WHERE (prelim_events->events[d.seq].dontcare=1))
     JOIN (cre
     WHERE (cre.chart_request_id=request->request_id)
      AND (cre.event_id=prelim_events->events[d.seq].event_id))
    HEAD REPORT
     inerr_nbr = 0
    HEAD d.seq
     IF (cre.event_id=0.0)
      inerr_nbr = (inerr_nbr+ 1)
      IF (mod(inerr_nbr,5)=1)
       stat = alterlist(reply->inerr_events,(inerr_nbr+ 4))
      ENDIF
      reply->inerr_events[inerr_nbr].event_id = prelim_events->events[d.seq].event_id
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->inerr_events,inerr_nbr)
    WITH outerjoin = d, nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getchartevents(null)
  CALL echo("In GetChartEvents")
  SELECT DISTINCT INTO "nl:"
   FROM chart_request_event c,
    clinical_event ce,
    clinical_event cee
   PLAN (c
    WHERE (c.chart_request_id=request->request_id))
    JOIN (ce
    WHERE ce.event_id=c.event_id)
    JOIN (cee
    WHERE cee.parent_event_id=ce.parent_event_id)
   HEAD REPORT
    x = 0
   DETAIL
    x = (x+ 1)
    IF (mod(x,10)=1)
     stat = alterlist(chart_events->events,(x+ 9))
    ENDIF
    chart_events->events[x].event_id = cee.event_id
   FOOT REPORT
    stat = alterlist(chart_events->events,x)
   WITH nocounter
  ;end select
 END ;Subroutine
#exit_script
 IF (size(reply->activity,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
