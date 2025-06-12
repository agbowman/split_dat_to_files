CREATE PROGRAM cs_srv_get_facility_timezones:dba
 CALL echo("CS_SRV_GET_INTERFACE VERSION - 708407.00")
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(request)
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE cs222_facility_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE cs278_org_type_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",278,"CLIENT"))
 DECLARE facilitycount = i4 WITH protect, noconstant(0)
 SELECT
  IF ((request->load_all=1))
   PLAN (o
    WHERE o.organization_id > 0.0
     AND o.active_ind=true)
    JOIN (l
    WHERE l.organization_id=o.organization_id
     AND l.location_type_cd=cs222_facility_cd
     AND l.active_ind=true
     AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND l.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (ot
    WHERE ot.organization_id=o.organization_id
     AND ot.org_type_cd=cs278_org_type_cd
     AND ot.active_ind=true)
    JOIN (tzr
    WHERE (tzr.parent_entity_id= Outerjoin(l.location_cd))
     AND (tzr.parent_entity_name= Outerjoin("LOCATION")) )
  ELSE
   PLAN (o
    WHERE (o.organization_id=request->organization_id)
     AND o.active_ind=true)
    JOIN (l
    WHERE l.organization_id=o.organization_id
     AND l.location_type_cd=cs222_facility_cd
     AND l.active_ind=true
     AND l.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND l.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (ot
    WHERE ot.organization_id=o.organization_id
     AND ot.org_type_cd=cs278_org_type_cd
     AND ot.active_ind=true)
    JOIN (tzr
    WHERE (tzr.parent_entity_id= Outerjoin(l.location_cd))
     AND (tzr.parent_entity_name= Outerjoin("LOCATION")) )
  ENDIF
  INTO "nl:"
  FROM organization o,
   org_type_reltn ot,
   location l,
   time_zone_r tzr
  ORDER BY o.organization_id
  HEAD o.organization_id
   facilitycount += 1
   IF (mod(facilitycount,10)=1)
    stat = alterlist(reply->orgtimezonelist,(facilitycount+ 9))
   ENDIF
   reply->orgtimezonelist[facilitycount].organization_id = o.organization_id
   IF (tzr.parent_entity_id != 0.0)
    reply->orgtimezonelist[facilitycount].time_zone_index = datetimezonebyname(tzr.time_zone)
   ELSE
    reply->orgtimezonelist[facilitycount].time_zone_index = curtimezoneapp
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->orgtimezonelist,facilitycount)
 IF (facilitycount > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
