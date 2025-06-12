CREATE PROGRAM ddsdoc_solcap_collector:dba
 SET stat = alterlist(reply->solcap,1)
 SET stat = alterlist(reply->solcap[1].other,1)
 SET reply->solcap[1].identifier = "2013.2.00143.1"
 SET reply->solcap[1].other[1].category_name = "Saved Structured Sections by Display"
 DECLARE null_date = vc WITH protect, noconstant("31-DEC-2100 00:00:00.00")
 SELECT INTO "nl:"
  section_cnt = count(s.dd_sdoc_section_id)
  FROM dd_sdoc_section s
  PLAN (s
   WHERE s.dd_sdoc_section_id > 0.0
    AND s.parent_dd_sdoc_section_id=0.0
    AND s.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((s.author_id+ 0) > 0.0))
  DETAIL
   reply->solcap[1].degree_of_use_num = section_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  author_cnt = count(DISTINCT s.author_id)
  FROM dd_sdoc_section s
  PLAN (s
   WHERE s.dd_sdoc_section_id > 0.0
    AND s.parent_dd_sdoc_section_id=0.0
    AND s.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((s.author_id+ 0) > 0.0))
  DETAIL
   reply->solcap[1].distinct_user_count = author_cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sections_per_position = count(p.position_cd), p.position_cd
  FROM dd_sdoc_section s,
   prsnl p
  PLAN (s
   WHERE s.dd_sdoc_section_id > 0.0
    AND s.parent_dd_sdoc_section_id=0.0
    AND s.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((s.author_id+ 0) > 0.0))
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
   position[index].value_num = sections_per_position, reply->solcap[1].position[index].value_str =
   "Sections"
  FOOT REPORT
   stat = alterlist(reply->solcap[1].position,index)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sections_per_facility = count(e.loc_facility_cd), e.loc_facility_cd
  FROM dd_sdoc_section s,
   encounter e
  PLAN (s
   WHERE s.dd_sdoc_section_id > 0.0
    AND s.parent_dd_sdoc_section_id=0.0
    AND s.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((s.encntr_id+ 0) > 0.0)
    AND ((s.author_id+ 0) > 0.0))
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
   1].facility[index].value_num = sections_per_facility, reply->solcap[1].facility[index].value_str
    = "Sections"
  FOOT REPORT
   stat = alterlist(reply->solcap[1].facility,index)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sections_cnt = count(dd.display), dd.display
  FROM dd_sdoc_section s,
   dd_sref_section dd
  PLAN (s
   WHERE s.dd_sdoc_section_id > 0.0
    AND s.parent_dd_sdoc_section_id=0.0
    AND s.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((s.author_id+ 0) > 0.0))
   JOIN (dd
   WHERE dd.dd_sref_section_id=s.dd_sref_section_id)
  GROUP BY dd.display
  HEAD REPORT
   index = 0
  DETAIL
   index = (index+ 1)
   IF (mod(index,10)=1)
    stat = alterlist(reply->solcap[1].other[1].value,(index+ 9))
   ENDIF
   reply->solcap[1].other[1].value[index].display = dd.display, reply->solcap[1].other[1].value[index
   ].value_num = sections_cnt, reply->solcap[1].other[1].value[index].value_str = "Sections"
  FOOT REPORT
   stat = alterlist(reply->solcap[1].other[1].value,index)
  WITH nocounter
 ;end select
END GO
