CREATE PROGRAM dd_solcap_collector:dba
 SET stat = alterlist(reply->solcap,1)
 SET stat = alterlist(reply->solcap[1].other,1)
 SET reply->solcap[1].identifier = "2012.1.00015.1"
 SET reply->solcap[1].other[1].category_name = "Submitted Documents by Status"
 DECLARE null_date = vc WITH protect, noconstant("31-DEC-2100 00:00:00.00")
 SELECT INTO "nl:"
  document_cnt = count(dd.mdoc_event_id)
  FROM dd_contribution dd,
   clinical_event ce
  PLAN (dd
   WHERE dd.mdoc_event_id > 0.0
    AND dd.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
   )
   JOIN (ce
   WHERE ce.event_id=dd.mdoc_event_id
    AND ce.valid_until_dt_tm=cnvtdatetime(null_date))
  DETAIL
   reply->solcap[1].degree_of_use_num = document_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  author_cnt = count(DISTINCT dd.author_id)
  FROM dd_contribution dd,
   clinical_event ce
  PLAN (dd
   WHERE dd.mdoc_event_id > 0.0
    AND dd.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((dd.author_id+ 0) > 0.0))
   JOIN (ce
   WHERE ce.event_id=dd.mdoc_event_id
    AND ce.valid_until_dt_tm=cnvtdatetime(null_date))
  DETAIL
   reply->solcap[1].distinct_user_count = author_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  documents_per_position = count(p.position_cd), p.position_cd
  FROM dd_contribution dd,
   prsnl p
  PLAN (dd
   WHERE dd.mdoc_event_id > 0.0
    AND dd.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((dd.author_id+ 0) > 0.0))
   JOIN (p
   WHERE p.person_id=dd.author_id
    AND ((p.position_cd+ 0) > 0.0))
  GROUP BY p.position_cd
  HEAD REPORT
   index = 0
  DETAIL
   index = (index+ 1)
   IF (mod(index,10)=1)
    stat = alterlist(reply->solcap[1].position,(index+ 9))
   ENDIF
   reply->solcap[1].position[index].display = uar_get_code_display(p.position_cd), reply->solcap[1].
   position[index].value_num = documents_per_position, reply->solcap[1].position[index].value_str =
   "Notes"
  FOOT REPORT
   stat = alterlist(reply->solcap[1].position,index)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  documents_per_facility = count(e.loc_facility_cd), e.loc_facility_cd
  FROM dd_contribution dd,
   encounter e
  PLAN (dd
   WHERE dd.mdoc_event_id > 0.0
    AND dd.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((dd.encntr_id+ 0) > 0.0)
    AND ((dd.author_id+ 0) > 0.0))
   JOIN (e
   WHERE e.encntr_id=dd.encntr_id
    AND ((e.loc_facility_cd+ 0) > 0.0))
  GROUP BY e.loc_facility_cd
  HEAD REPORT
   index = 0
  DETAIL
   index = (index+ 1)
   IF (mod(index,10)=1)
    stat = alterlist(reply->solcap[1].facility,(index+ 9))
   ENDIF
   reply->solcap[1].facility[index].display = uar_get_code_display(e.loc_facility_cd), reply->solcap[
   1].facility[index].value_num = documents_per_facility, reply->solcap[1].facility[index].value_str
    = "Notes"
  FOOT REPORT
   stat = alterlist(reply->solcap[1].facility,index)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  documents_cnt = count(ce.result_status_cd), ce.result_status_cd
  FROM dd_contribution dd,
   clinical_event ce
  PLAN (dd
   WHERE dd.mdoc_event_id > 0.0
    AND dd.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((dd.author_id+ 0) > 0.0))
   JOIN (ce
   WHERE ce.event_id=dd.mdoc_event_id
    AND ce.valid_until_dt_tm=cnvtdatetime(null_date))
  GROUP BY ce.result_status_cd
  HEAD REPORT
   index = 0
  DETAIL
   index = (index+ 1)
   IF (mod(index,10)=1)
    stat = alterlist(reply->solcap[1].other[1].value,(index+ 9))
   ENDIF
   reply->solcap[1].other[1].value[index].display = uar_get_code_display(ce.result_status_cd), reply
   ->solcap[1].other[1].value[index].value_num = documents_cnt, reply->solcap[1].other[1].value[index
   ].value_str = "Notes"
  FOOT REPORT
   stat = alterlist(reply->solcap[1].other[1].value,index)
  WITH nocounter
 ;end select
END GO
