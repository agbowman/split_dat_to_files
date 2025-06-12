CREATE PROGRAM dcp_get_working_view:dba
 SET modify = predeclare
 RECORD reply(
   1 working_view_id = f8
   1 version_num = f8
   1 current_working_view = f8
   1 active_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 position_cd = f8
   1 location_cd = f8
   1 display_name = vc
   1 working_view_sections[*]
     2 working_view_section_id = f8
     2 event_set_name = vc
     2 required_ind = i2
     2 included_ind = i2
     2 falloff_view_minutes = i4
     2 section_type_flag = i2
     2 display_name = vc
     2 working_view_items[*]
       3 working_view_item_id = f8
       3 primitive_event_set_name = vc
       3 parent_event_set_name = vc
       3 included_ind = i2
       3 falloff_view_minutes = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE item_counter = i4 WITH noconstant(0)
 DECLARE section_counter = i4 WITH noconstant(0)
 DECLARE io2g_reserved = c42 WITH constant("**IO2GRESERVED**")
 DECLARE error_msg = vc WITH noconstant("")
 SELECT
  IF ((request->io2g_ind=1)
   AND (request->working_view_id=0))
   PLAN (wv
    WHERE wv.display_name=io2g_reserved)
    JOIN (wvs
    WHERE wvs.working_view_id=outerjoin(wv.working_view_id))
    JOIN (wvi
    WHERE wvi.working_view_section_id=outerjoin(wvs.working_view_section_id))
  ELSE
   PLAN (wv
    WHERE (wv.working_view_id=request->working_view_id))
    JOIN (wvs
    WHERE wvs.working_view_id=outerjoin(wv.working_view_id))
    JOIN (wvi
    WHERE wvi.working_view_section_id=outerjoin(wvs.working_view_section_id))
  ENDIF
  INTO "nl:"
  FROM working_view wv,
   working_view_section wvs,
   working_view_item wvi
  ORDER BY wv.working_view_id, wvs.working_view_section_id, wvi.working_view_item_id
  HEAD wv.working_view_id
   section_counter = 0, reply->working_view_id = wv.working_view_id, reply->version_num = wv
   .version_num,
   reply->current_working_view = wv.current_working_view, reply->active_ind = wv.active_ind, reply->
   beg_effective_dt_tm = cnvtdatetime(wv.beg_effective_dt_tm),
   reply->end_effective_dt_tm = cnvtdatetime(wv.end_effective_dt_tm), reply->position_cd = wv
   .position_cd, reply->location_cd = wv.location_cd,
   reply->display_name = wv.display_name
  HEAD wvs.working_view_section_id
   item_counter = 0
   IF (wvs.working_view_section_id > 0)
    section_counter = (section_counter+ 1)
    IF (mod(section_counter,10)=1)
     stat = alterlist(reply->working_view_sections,(section_counter+ 9))
    ENDIF
    reply->working_view_sections[section_counter].working_view_section_id = wvs
    .working_view_section_id, reply->working_view_sections[section_counter].event_set_name = wvs
    .event_set_name, reply->working_view_sections[section_counter].required_ind = wvs.required_ind,
    reply->working_view_sections[section_counter].included_ind = wvs.included_ind, reply->
    working_view_sections[section_counter].section_type_flag = wvs.section_type_flag, reply->
    working_view_sections[section_counter].display_name = wvs.display_name
   ENDIF
  HEAD wvi.working_view_item_id
   IF (wvi.working_view_item_id > 0)
    item_counter = (item_counter+ 1)
    IF (mod(item_counter,10)=1)
     stat = alterlist(reply->working_view_sections[section_counter].working_view_items,(item_counter
      + 9))
    ENDIF
    reply->working_view_sections[section_counter].working_view_items[item_counter].
    working_view_item_id = wvi.working_view_item_id, reply->working_view_sections[section_counter].
    working_view_items[item_counter].primitive_event_set_name = wvi.primitive_event_set_name, reply->
    working_view_sections[section_counter].working_view_items[item_counter].parent_event_set_name =
    wvi.parent_event_set_name,
    reply->working_view_sections[section_counter].working_view_items[item_counter].included_ind = wvi
    .included_ind, reply->working_view_sections[section_counter].working_view_items[item_counter].
    falloff_view_minutes = wvi.falloff_view_minutes
   ENDIF
  FOOT  wvs.working_view_section_id
   IF (wvs.working_view_section_id > 0)
    stat = alterlist(reply->working_view_sections[section_counter].working_view_items,item_counter)
   ENDIF
  FOOT  wv.working_view_id
   IF (wv.working_view_id > 0)
    stat = alterlist(reply->working_view_sections,section_counter)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
