CREATE PROGRAM bed_get_iview_wv_info:dba
 FREE SET reply
 RECORD reply(
   1 views[*]
     2 working_view_id = f8
     2 sections[*]
       3 working_view_section_id = f8
       3 event_set_name = vc
       3 display_name = vc
       3 included_ind = i2
       3 required_ind = i2
       3 section_type_flag = i2
       3 items[*]
         4 working_view_item_id = f8
         4 event_set_name = vc
         4 included_ind = i2
         4 parent_event_set_name = vc
         4 falloff_view_minutes = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = 0
 SET icnt = 0
 SET vcnt = 0
 SET vcnt = size(request->views,5)
 SET stat = alterlist(reply->views,vcnt)
 FOR (x = 1 TO vcnt)
  SET reply->views[x].working_view_id = request->views[x].working_view_id
  SELECT INTO "nl:"
   FROM working_view_section s,
    working_view_item i
   PLAN (s
    WHERE (s.working_view_id=request->views[x].working_view_id))
    JOIN (i
    WHERE i.working_view_section_id=outerjoin(s.working_view_section_id))
   ORDER BY s.working_view_section_id, i.working_view_item_id
   HEAD s.working_view_section_id
    icnt = 0, scnt = (scnt+ 1), stat = alterlist(reply->views[x].sections,scnt),
    reply->views[x].sections[scnt].working_view_section_id = s.working_view_section_id, reply->views[
    x].sections[scnt].event_set_name = s.event_set_name, reply->views[x].sections[scnt].display_name
     = s.display_name,
    reply->views[x].sections[scnt].included_ind = s.included_ind, reply->views[x].sections[scnt].
    required_ind = s.required_ind, reply->views[x].sections[scnt].section_type_flag = s
    .section_type_flag
   HEAD i.working_view_item_id
    icnt = (icnt+ 1), stat = alterlist(reply->views[x].sections[scnt].items,icnt), reply->views[x].
    sections[scnt].items[icnt].working_view_item_id = i.working_view_item_id,
    reply->views[x].sections[scnt].items[icnt].event_set_name = i.primitive_event_set_name, reply->
    views[x].sections[scnt].items[icnt].included_ind = i.included_ind, reply->views[x].sections[scnt]
    .items[icnt].parent_event_set_name = i.parent_event_set_name,
    reply->views[x].sections[scnt].items[icnt].falloff_view_minutes = i.falloff_view_minutes
   WITH nocounter
  ;end select
 ENDFOR
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
