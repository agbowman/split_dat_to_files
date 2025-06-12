CREATE PROGRAM cs_srv_get_hierarchy:dba
 CALL echo(concat("CS_SRV_GET_HIERARCHY - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;S")))
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(request)
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE cnt = i2
 DECLARE cur_cd = f8
 SET stat = alterlist(reply->items,(request->begin_level+ 1))
 SET reply->items[(request->begin_level+ 1)].level_cd = request->begin_cd
 IF ((request->code_set=221))
  CALL echo("Read resource_group table")
  IF ((request->begin_level > 1))
   SET cnt = request->begin_level
   SET cur_cd = request->begin_cd
   WHILE (cnt > 1)
    SELECT INTO "nl:"
     r.parent_service_resource_cd, r.child_service_resource_cd, r.resource_group_type_cd
     FROM resource_group r
     WHERE r.child_service_resource_cd=cur_cd
      AND r.active_ind=1
      AND r.root_service_resource_cd=0
     DETAIL
      IF (((cnt=5
       AND (((r.resource_group_type_cd=g_cs223->subsection)) OR ((r.resource_group_type_cd=g_cs223->
      surgstage))) ) OR (((cnt=4
       AND (((r.resource_group_type_cd=g_cs223->section)) OR ((r.resource_group_type_cd=g_cs223->
      surgarea))) ) OR (((cnt=3
       AND (r.resource_group_type_cd=g_cs223->department)) OR (cnt=2
       AND (r.resource_group_type_cd=g_cs223->institution))) )) )) )
       cur_cd = r.parent_service_resource_cd, reply->items[cnt].level_cd = cur_cd
      ENDIF
     WITH nocounter
    ;end select
    SET cnt -= 1
   ENDWHILE
   IF ((reply->items[2].level_cd > 0))
    CALL echo("Read service_resource table to get organization_id")
    SELECT INTO "nl:"
     sr.organization_id
     FROM service_resource sr
     WHERE (sr.service_resource_cd=reply->items[2].level_cd)
     DETAIL
      reply->items[1].level_cd = sr.organization_id
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
 ELSEIF ((request->code_set=220))
  CALL echo("Read location_group table")
  IF ((request->begin_level > 0))
   SET cnt = request->begin_level
   SET cur_cd = request->begin_cd
   WHILE (cnt > 0)
    SELECT INTO "nl:"
     l.parent_loc_cd, l.child_loc_cd, l.location_group_type_cd
     FROM location_group l
     WHERE l.child_loc_cd=cur_cd
      AND l.active_ind=1
      AND l.root_loc_cd=0
     DETAIL
      IF (((cnt=4
       AND (l.location_group_type_cd=g_cs222->room)) OR (((cnt=3
       AND (((l.location_group_type_cd=g_cs222->nurseunit)) OR ((l.location_group_type_cd=g_cs222->
      ambulatory))) ) OR (((cnt=2
       AND (l.location_group_type_cd=g_cs222->building)) OR (cnt=1
       AND (l.location_group_type_cd=g_cs222->facility))) )) )) )
       cur_cd = l.parent_loc_cd, reply->items[cnt].level_cd = cur_cd
      ENDIF
     WITH nocounter
    ;end select
    SET cnt -= 1
   ENDWHILE
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
