CREATE PROGRAM bed_get_xr_detailed_xrefs:dba
 RECORD reply(
   1 entity[*]
     2 xref_id = f8
     2 parent_entity_id = f8
     2 parent_entity_display = vc
     2 parent_entity_type = vc
     2 destination_cd = f8
     2 destination_display = vc
     2 destination_type = vc
     2 destination_type_cd = f8
     2 active_ind = i2
     2 invalid_ind = i2
   1 last_page_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE start_rec = i4 WITH noconstant(0)
 DECLARE end_rec = i4 WITH noconstant(0)
 DECLARE where_clause = vc WITH noconstant("")
 DECLARE parent_entity_name_filter = vc WITH noconstant("")
 DECLARE secure_email_code = f8 WITH noconstant(0.0)
 DECLARE personnel_logical_domain_id = f8 WITH noconstant(0.0)
 DECLARE printer_type_cd = f8 WITH constant(uar_get_code_by("MEANING",3000,"PRINTER")), protect
 DECLARE fax_type_cd = f8 WITH constant(uar_get_code_by("MEANING",3000,"FAX")), protect
 SET reply->status_data.status = "F"
 SET reply->last_page_ind = 1
 SET secure_email_code = uar_get_code_by("MEANING",4636013,"SECURE_EMAIL")
 SET where_clause = "d.device_cd = outerjoin(cdx.device_cd) and cdx.active_ind = 1"
 IF (size(trim(request->parent_entity_name)) != 0)
  SET parent_entity_name_filter = request->parent_entity_name
  SET where_clause = build2(where_clause," and cdx.parent_entity_name = parent_entity_name_filter")
 ENDIF
 IF ((request->device_cd != 0))
  SET where_clause = build2(where_clause," and cdx.device_cd = ",request->device_cd)
 ENDIF
 IF ((request->destination_type_cd != 0))
  SET where_clause = build2(where_clause," and cdx.destination_type_cd = ",request->
   destination_type_cd)
 ENDIF
 SET start_rec = (((request->page_number - 1) * request->page_size)+ 1)
 SET end_rec = (start_rec+ request->page_size)
 SELECT INTO "nl:"
  p.logical_domain_id
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   personnel_logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 SELECT
  *
  FROM (
   (
   (SELECT
    xref_id = t.xref_id, parent_entity_id = t.parent_entity_id, parent_entity_display = t
    .parent_entity_display,
    parent_entity_type = t.parent_entity_type, device_cd = t.device_cd, device_cd_actual = t
    .device_cd_actual,
    device_name = t.device_name, device_type_cd = t.device_type_cd, dest_type_cd = t.dest_type_cd,
    dms_service_identifier = t.dms_service_identifier, active_ind = t.active_ind, rank = dense_rank()
     OVER(
    ORDER BY t.parent_entity_type, cnvtupper(t.parent_entity_display), t.parent_entity_id)
    FROM (
     (
     (SELECT
      xref_id = cdx.cr_destination_xref_id, parent_entity_id = cdx.parent_entity_id,
      parent_entity_display = p.name_full_formatted,
      parent_entity_type = cdx.parent_entity_name, device_cd = cdx.device_cd, device_cd_actual = d
      .device_cd,
      device_name = d.name, device_type_cd = d.device_type_cd, dest_type_cd = cdx.destination_type_cd,
      dms_service_identifier = cdx.dms_service_identifier, active_ind = p.active_ind
      FROM cr_destination_xref cdx,
       prsnl p,
       device d
      WHERE cdx.parent_entity_name="PRSNL"
       AND parser(where_clause)
       AND p.person_id=cdx.parent_entity_id
       AND ((p.logical_domain_id=personnel_logical_domain_id) UNION (
      (SELECT
       xref_id = cdx.cr_destination_xref_id, parent_entity_id = cdx.parent_entity_id,
       parent_entity_display = cd.description,
       parent_entity_type = cdx.parent_entity_name, device_cd = cdx.device_cd, device_cd_actual = d
       .device_cd,
       device_name = d.name, device_type_cd = d.device_type_cd, dest_type_cd = cdx
       .destination_type_cd,
       dms_service_identifier = cdx.dms_service_identifier, active_ind = loc.active_ind
       FROM cr_destination_xref cdx,
        device d,
        code_value cd,
        location loc,
        organization org
       WHERE cdx.parent_entity_name="LOCATION"
        AND parser(where_clause)
        AND cd.code_value=cdx.parent_entity_id
        AND loc.location_cd=cdx.parent_entity_id
        AND loc.organization_id=org.organization_id
        AND ((org.logical_domain_id=personnel_logical_domain_id) UNION (
       (SELECT
        xref_id = cdx.cr_destination_xref_id, parent_entity_id = cdx.parent_entity_id,
        parent_entity_display = org.org_name,
        parent_entity_type = cdx.parent_entity_name, device_cd = cdx.device_cd, device_cd_actual = d
        .device_cd,
        device_name = d.name, device_type_cd = d.device_type_cd, dest_type_cd = cdx
        .destination_type_cd,
        dms_service_identifier = cdx.dms_service_identifier, active_ind = org.active_ind
        FROM cr_destination_xref cdx,
         organization org,
         device d
        WHERE cdx.parent_entity_name="ORGANIZATION"
         AND parser(where_clause)
         AND org.organization_id=cdx.parent_entity_id
         AND ((org.logical_domain_id=personnel_logical_domain_id) UNION (
        (SELECT
         xref_id = cdx.cr_destination_xref_id, parent_entity_id = cdx.parent_entity_id,
         parent_entity_display = cd.description,
         parent_entity_type = cdx.parent_entity_name, device_cd = cdx.device_cd, device_cd_actual = d
         .device_cd,
         device_name = d.name, device_type_cd = d.device_type_cd, dest_type_cd = cdx
         .destination_type_cd,
         dms_service_identifier = cdx.dms_service_identifier, active_ind = sr.active_ind
         FROM cr_destination_xref cdx,
          device d,
          code_value cd,
          service_resource sr,
          organization org
         WHERE cdx.parent_entity_name="SERVICE_RESOURCE"
          AND parser(where_clause)
          AND cd.code_value=cdx.parent_entity_id
          AND sr.service_resource_cd=cdx.parent_entity_id
          AND sr.organization_id=org.organization_id
          AND org.logical_domain_id=personnel_logical_domain_id))) ))) ))) ))
     t)
    WITH sqltype("F8","F8","VC","VC","F8",
      "F8","VC","F8","F8","VC",
      "I2","I4")))
   e)
  WHERE e.rank BETWEEN start_rec AND end_rec
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->entity,request->page_size)
  DETAIL
   IF (e.rank < end_rec)
    count1 = (count1+ 1)
    IF (count1 > size(reply->entity,5))
     stat = alterlist(reply->entity,(count1+ 10))
    ENDIF
    reply->entity[count1].xref_id = e.xref_id, reply->entity[count1].parent_entity_id = e
    .parent_entity_id, reply->entity[count1].parent_entity_display = e.parent_entity_display,
    reply->entity[count1].parent_entity_type = e.parent_entity_type, reply->entity[count1].
    destination_cd = e.device_cd
    IF (e.dest_type_cd=secure_email_code)
     reply->entity[count1].destination_display = e.dms_service_identifier
    ELSE
     reply->entity[count1].destination_display = e.device_name
    ENDIF
    reply->entity[count1].destination_type = uar_get_code_display(e.dest_type_cd), reply->entity[
    count1].destination_type_cd = e.dest_type_cd, reply->entity[count1].active_ind = e.active_ind
    IF (e.device_cd=e.device_cd_actual
     AND ((e.device_type_cd IN (fax_type_cd, printer_type_cd)) OR (e.dest_type_cd=secure_email_code
    )) )
     reply->entity[count1].invalid_ind = 0
    ELSE
     reply->entity[count1].invalid_ind = 1
    ENDIF
   ELSE
    reply->last_page_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->entity,count1), reply->status_data.status = "S"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
