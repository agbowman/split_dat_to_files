CREATE PROGRAM dcp_get_person_working_view:dba
 SET modify = predeclare
 RECORD reply(
   1 working_view_person_id = f8
   1 encntr_id = f8
   1 working_view_id = f8
   1 working_view_person_sections[*]
     2 working_view_person_section_id = f8
     2 event_set_name = vc
     2 required_ind = i2
     2 included_ind = i2
     2 falloff_view_minutes = i4
     2 section_type_flag = i2
     2 working_view_person_items[*]
       3 working_view_personitem_id = f8
       3 primitive_event_set_name = vc
       3 parent_event_set_name = vc
       3 included_ind = i2
       3 updt_dt_tm = dq8
       3 last_action_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE sect_count = i4 WITH noconstant(0)
 DECLARE item_count = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant("")
 SELECT INTO "nl:"
  FROM working_view_person wvp,
   working_view_section wvs,
   working_view_person_sect wvps,
   working_view_personitem wvpi
  PLAN (wvp
   WHERE (wvp.working_view_id=request->working_view_id)
    AND (wvp.encntr_id=request->encntr_id))
   JOIN (wvs
   WHERE wvs.working_view_id=outerjoin(wvp.working_view_id))
   JOIN (wvps
   WHERE wvps.working_view_person_id=outerjoin(wvp.working_view_person_id))
   JOIN (wvpi
   WHERE wvpi.working_view_person_sect_id=outerjoin(wvps.working_view_person_sect_id))
  ORDER BY wvp.working_view_person_id, wvps.working_view_person_sect_id, wvpi
   .working_view_personitem_id
  HEAD wvp.working_view_person_id
   sect_count = 0
   IF (wvp.working_view_person_id > 0)
    reply->working_view_person_id = wvp.working_view_person_id, reply->encntr_id = wvp.encntr_id,
    reply->working_view_id = wvp.working_view_id
   ENDIF
  HEAD wvps.working_view_person_sect_id
   item_count = 0
   IF (wvps.working_view_person_sect_id > 0)
    sect_count = (sect_count+ 1)
    IF (mod(sect_count,10)=1)
     stat = alterlist(reply->working_view_person_sections,(sect_count+ 9))
    ENDIF
    reply->working_view_person_sections[sect_count].working_view_person_section_id = wvps
    .working_view_person_sect_id, reply->working_view_person_sections[sect_count].event_set_name =
    wvps.event_set_name, reply->working_view_person_sections[sect_count].included_ind = wvps
    .included_ind,
    reply->working_view_person_sections[sect_count].required_ind = wvs.required_ind, reply->
    working_view_person_sections[sect_count].section_type_flag = wvps.section_type_flag
   ENDIF
  HEAD wvpi.working_view_personitem_id
   IF (wvpi.working_view_personitem_id > 0)
    item_count = (item_count+ 1)
    IF (mod(item_count,10)=1)
     stat = alterlist(reply->working_view_person_sections[sect_count].working_view_person_items,(
      item_count+ 9))
    ENDIF
    reply->working_view_person_sections[sect_count].working_view_person_items[item_count].
    working_view_personitem_id = wvpi.working_view_personitem_id, reply->
    working_view_person_sections[sect_count].working_view_person_items[item_count].
    primitive_event_set_name = wvpi.primitive_event_set_name, reply->working_view_person_sections[
    sect_count].working_view_person_items[item_count].parent_event_set_name = wvpi
    .parent_event_set_name,
    reply->working_view_person_sections[sect_count].working_view_person_items[item_count].
    included_ind = wvpi.included_ind, reply->working_view_person_sections[sect_count].
    working_view_person_items[item_count].updt_dt_tm = wvpi.updt_dt_tm, reply->
    working_view_person_sections[sect_count].working_view_person_items[item_count].last_action_dt_tm
     = wvpi.last_action_dt_tm
   ENDIF
  FOOT  wvps.working_view_person_sect_id
   IF (wvps.working_view_person_sect_id > 0)
    stat = alterlist(reply->working_view_person_sections[sect_count].working_view_person_items,
     item_count)
   ENDIF
  FOOT  wvp.working_view_person_id
   IF (wvp.working_view_person_id > 0)
    stat = alterlist(reply->working_view_person_sections,sect_count)
   ENDIF
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF (sect_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
