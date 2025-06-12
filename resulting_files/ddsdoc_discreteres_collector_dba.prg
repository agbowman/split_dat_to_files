CREATE PROGRAM ddsdoc_discreteres_collector:dba
 SET stat = alterlist(reply->solcap,1)
 SET stat = alterlist(reply->solcap[1].other,2)
 SET reply->solcap[1].identifier = "2014.2.00295.1"
 SET reply->solcap[1].degree_of_use_str = "Dynamic Documentation - Structured Discrete Results"
 SET reply->solcap[1].other[1].category_name = "Saved Discrete Result Event Codes by Display"
 SET reply->solcap[1].other[2].category_name = "Saved Discrete Result Event Class Codes by Display"
 DECLARE null_date = vc WITH protect, noconstant("31-DEC-2100 00:00:00.00")
 SELECT INTO "nl:"
  discrete_res_cnt = count(ddsd.fkey_entity_id)
  FROM dd_sdoc_section s,
   dd_sdoc_data ddsd
  PLAN (s
   WHERE s.dd_sdoc_section_id > 0.0
    AND s.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((s.author_id+ 0) > 0.0))
   JOIN (ddsd
   WHERE ddsd.dd_sdoc_section_id=s.dd_sdoc_section_id
    AND ddsd.fkey_entity_name="CLINICAL_EVENT"
    AND ddsd.fkey_entity_id > 0.0)
  DETAIL
   reply->solcap[1].degree_of_use_num = discrete_res_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  author_cnt = count(DISTINCT s.author_id)
  FROM dd_sdoc_section s,
   dd_sdoc_data ddsd
  PLAN (s
   WHERE s.dd_sdoc_section_id > 0.0
    AND s.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((s.author_id+ 0) > 0.0))
   JOIN (ddsd
   WHERE ddsd.dd_sdoc_section_id=s.dd_sdoc_section_id
    AND ddsd.fkey_entity_name="CLINICAL_EVENT"
    AND ddsd.fkey_entity_id > 0.0)
  DETAIL
   reply->solcap[1].distinct_user_count = author_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  discrete_results_per_position = count(p.position_cd), p.position_cd
  FROM dd_sdoc_section s,
   dd_sdoc_data ddsd,
   prsnl p
  PLAN (s
   WHERE s.dd_sdoc_section_id > 0.0
    AND s.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((s.author_id+ 0) > 0.0))
   JOIN (ddsd
   WHERE ddsd.dd_sdoc_section_id=s.dd_sdoc_section_id
    AND ddsd.fkey_entity_name="CLINICAL_EVENT"
    AND ddsd.fkey_entity_id > 0.0)
   JOIN (p
   WHERE p.person_id=s.author_id
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
   position[index].value_num = discrete_results_per_position, reply->solcap[1].position[index].
   value_str = "Discrete Results"
  FOOT REPORT
   stat = alterlist(reply->solcap[1].position,index)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  discrete_results_per_facility = count(e.loc_facility_cd), e.loc_facility_cd
  FROM dd_sdoc_section s,
   dd_sdoc_data ddsd,
   encounter e
  PLAN (s
   WHERE s.dd_sdoc_section_id > 0.0
    AND s.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((s.encntr_id+ 0) > 0.0)
    AND ((s.author_id+ 0) > 0.0))
   JOIN (ddsd
   WHERE ddsd.dd_sdoc_section_id=s.dd_sdoc_section_id
    AND ddsd.fkey_entity_name="CLINICAL_EVENT"
    AND ddsd.fkey_entity_id > 0.0)
   JOIN (e
   WHERE e.encntr_id=s.encntr_id
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
   1].facility[index].value_num = discrete_results_per_facility, reply->solcap[1].facility[index].
   value_str = "Discrete Results"
  FOOT REPORT
   stat = alterlist(reply->solcap[1].facility,index)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  event_cd_cnt = count(ce.event_cd), ce.event_cd
  FROM dd_sdoc_section s,
   dd_sdoc_data ddsd,
   clinical_event ce
  PLAN (s
   WHERE s.dd_sdoc_section_id > 0.0
    AND s.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((s.author_id+ 0) > 0.0))
   JOIN (ddsd
   WHERE ddsd.dd_sdoc_section_id=s.dd_sdoc_section_id
    AND ddsd.fkey_entity_name="CLINICAL_EVENT"
    AND ddsd.fkey_entity_id > 0.0)
   JOIN (ce
   WHERE ce.event_id=ddsd.fkey_entity_id
    AND ce.valid_until_dt_tm=cnvtdatetime(null_date))
  GROUP BY ce.event_cd
  HEAD REPORT
   index = 0
  DETAIL
   index = (index+ 1)
   IF (mod(index,10)=1)
    stat = alterlist(reply->solcap[1].other[1].value,(index+ 9))
   ENDIF
   reply->solcap[1].other[1].value[index].display = uar_get_code_display(ce.event_cd), reply->solcap[
   1].other[1].value[index].value_num = event_cd_cnt, reply->solcap[1].other[1].value[index].
   value_str = "Discrete Results"
  FOOT REPORT
   stat = alterlist(reply->solcap[1].other[1].value,index)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  event_class_cd_cnt = count(ce.event_class_cd), ce.event_class_cd
  FROM dd_sdoc_section s,
   dd_sdoc_data ddsd,
   clinical_event ce
  PLAN (s
   WHERE s.dd_sdoc_section_id > 0.0
    AND s.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((s.author_id+ 0) > 0.0))
   JOIN (ddsd
   WHERE ddsd.dd_sdoc_section_id=s.dd_sdoc_section_id
    AND ddsd.fkey_entity_name="CLINICAL_EVENT"
    AND ddsd.fkey_entity_id > 0.0)
   JOIN (ce
   WHERE ce.event_id=ddsd.fkey_entity_id
    AND ce.valid_until_dt_tm=cnvtdatetime(null_date))
  GROUP BY ce.event_class_cd
  HEAD REPORT
   index = 0
  DETAIL
   index = (index+ 1)
   IF (mod(index,10)=1)
    stat = alterlist(reply->solcap[1].other[2].value,(index+ 9))
   ENDIF
   reply->solcap[1].other[2].value[index].display = uar_get_code_display(ce.event_class_cd), reply->
   solcap[1].other[2].value[index].value_num = event_class_cd_cnt, reply->solcap[1].other[2].value[
   index].value_str = "Discrete Results"
  FOOT REPORT
   stat = alterlist(reply->solcap[1].other[2].value,index)
  WITH nocounter
 ;end select
END GO
