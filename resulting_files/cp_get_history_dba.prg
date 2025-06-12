CREATE PROGRAM cp_get_history:dba
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
 DECLARE where_clause = vc
 DECLARE auth_cd = f8
 DECLARE mod_cd = f8
 DECLARE alt_cd = f8
 DECLARE super_cd = f8
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,auth_cd)
 SET stat = uar_get_meaning_by_codeset(8,"MODIFIED",1,mod_cd)
 SET stat = uar_get_meaning_by_codeset(8,"ALTERED",1,alt_cd)
 SET stat = uar_get_meaning_by_codeset(8,"SUPERSEDED",1,super_cd)
 DECLARE placehold_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER")), protect
 SET where_clause = build("ce.person_id = ",request->person_id,
  " and ce.valid_until_dt_tm >= cnvtdatetime('31-Dec-2100')"," and ce.view_level = 0",
  " and ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd)")
 SET where_clause = concat(where_clause," and ce.event_class_cd != placehold_class_cd")
 IF ((request->pending_flag > 0))
  SET where_clause = concat(where_clause," and ce.publish_flag > 0")
 ELSE
  SET where_clause = concat(where_clause," and ce.publish_flag = 1")
 ENDIF
 CALL echo(concat("Where Clause = ",where_clause))
 SELECT
  IF ((request->chart_section_ind=0))
   FROM clinical_event ce,
    (dummyt d1  WITH seq = value(size(request->activity,5))),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(request->activity[d1.seq].event_cds,5)))
    JOIN (d2)
    JOIN (ce
    WHERE parser(where_clause)
     AND (((request->activity[d1.seq].procedure_type_flag=0)
     AND (ce.event_cd=request->activity[d1.seq].event_cds[d2.seq].event_cd)) OR ((request->activity[
    d1.seq].procedure_type_flag=1)
     AND (ce.catalog_cd=request->activity[d1.seq].catalog_cd)
     AND (ce.event_cd=request->activity[d1.seq].event_cds[d2.seq].event_cd))) )
  ELSE
   FROM clinical_event ce,
    chart_request_section crs,
    (dummyt d1  WITH seq = value(size(request->activity,5))),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(request->activity[d1.seq].event_cds,5)))
    JOIN (d2)
    JOIN (crs
    WHERE (crs.chart_request_id=request->request_id)
     AND (request->activity[d1.seq].chart_section_id=crs.chart_section_id))
    JOIN (ce
    WHERE parser(where_clause)
     AND (((request->activity[d1.seq].procedure_type_flag=0)
     AND (ce.event_cd=request->activity[d1.seq].event_cds[d2.seq].event_cd)) OR ((request->activity[
    d1.seq].procedure_type_flag=1)
     AND (ce.catalog_cd=request->activity[d1.seq].catalog_cd)
     AND (ce.event_cd=request->activity[d1.seq].event_cds[d2.seq].event_cd))) )
  ENDIF
  DISTINCT INTO "nl:"
  group_seq = request->activity[d1.seq].group_seq, zone = request->activity[d1.seq].zone,
  procedure_seq = request->activity[d1.seq].procedure_seq,
  event_cd = request->activity[d1.seq].event_cds[d2.seq].event_cd
  ORDER BY group_seq, zone, procedure_seq,
   event_cd
  HEAD REPORT
   activitycnt = 0, eventcdcnt = 0
  HEAD group_seq
   do_nothing = 0
  HEAD zone
   do_nothing = 0
  HEAD procedure_seq
   activitycnt = (activitycnt+ 1)
   IF (mod(activitycnt,5)=1)
    stat = alterlist(reply->activity,(activitycnt+ 4))
   ENDIF
   reply->activity[activitycnt].chart_section_id = request->activity[d1.seq].chart_section_id, reply
   ->activity[activitycnt].section_seq = request->activity[d1.seq].section_seq, reply->activity[
   activitycnt].chart_group_id = request->activity[d1.seq].chart_group_id,
   reply->activity[activitycnt].group_seq = request->activity[d1.seq].group_seq, reply->activity[
   activitycnt].zone = request->activity[d1.seq].zone, reply->activity[activitycnt].procedure_seq =
   request->activity[d1.seq].procedure_seq,
   reply->activity[activitycnt].procedure_type_flag = request->activity[d1.seq].procedure_type_flag,
   reply->activity[activitycnt].event_set_name = request->activity[d1.seq].event_set_name, reply->
   activity[activitycnt].catalog_cd = request->activity[d1.seq].catalog_cd
  DETAIL
   eventcdcnt = (eventcdcnt+ 1)
   IF (mod(eventcdcnt,5)=1)
    stat = alterlist(reply->activity[activitycnt].event_cds,(eventcdcnt+ 4))
   ENDIF
   reply->activity[activitycnt].event_cds[eventcdcnt].event_cd = event_cd
  FOOT  procedure_seq
   stat = alterlist(reply->activity[activitycnt].event_cds,eventcdcnt), eventcdcnt = 0
  FOOT  zone
   do_nothing = 0
  FOOT  group_seq
   do_nothing = 0
  FOOT REPORT
   stat = alterlist(reply->activity,activitycnt)
  WITH nocounter
 ;end select
#exit_script
 IF (size(reply->activity,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
