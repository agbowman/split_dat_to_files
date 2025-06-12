CREATE PROGRAM cp_get_location_address:dba
 RECORD reply(
   1 facility_add_1 = vc
   1 facility_add_2 = vc
   1 facility_city = vc
   1 facility_state = vc
   1 facility_zip_code = vc
   1 facility_country = vc
   1 building_add_1 = vc
   1 building_add_2 = vc
   1 building_city = vc
   1 building_state = vc
   1 building_zip_code = vc
   1 building_country = vc
   1 nurse_unit_add_1 = vc
   1 nurse_unit_add_2 = vc
   1 nurse_unit_city = vc
   1 nurse_unit_state = vc
   1 nurse_unit_zip_code = vc
   1 nurse_unit_country = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE bus_addr_cd = f8
 SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",1,bus_addr_cd)
 SELECT INTO "nl:"
  FROM address a
  WHERE a.parent_entity_id IN (request->loc_facility_cd, request->loc_building_cd, request->
  loc_nurse_unit_cd)
   AND a.parent_entity_name="LOCATION"
   AND a.address_type_cd=bus_addr_cd
   AND active_ind=1
   AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY a.parent_entity_id, a.address_type_seq
  HEAD a.parent_entity_id
   IF ((a.parent_entity_id=request->loc_facility_cd))
    reply->facility_add_1 = a.street_addr, reply->facility_add_2 = a.street_addr2, reply->
    facility_city = a.city,
    reply->facility_zip_code = a.zipcode
    IF (a.state_cd > 0)
     reply->facility_state = uar_get_code_display(a.state_cd)
    ELSE
     reply->facility_state = a.state
    ENDIF
    IF (a.country_cd > 0)
     reply->facility_country = uar_get_code_display(a.country_cd)
    ELSE
     reply->facility_country = a.country
    ENDIF
   ELSEIF ((a.parent_entity_id=request->loc_building_cd))
    reply->building_add_1 = a.street_addr, reply->building_add_2 = a.street_addr2, reply->
    building_city = a.city,
    reply->building_zip_code = a.zipcode
    IF (a.state_cd > 0)
     reply->building_state = uar_get_code_display(a.state_cd)
    ELSE
     reply->building_state = a.state
    ENDIF
    IF (a.country_cd > 0)
     reply->building_country = uar_get_code_display(a.country_cd)
    ELSE
     reply->building_country = a.country
    ENDIF
   ELSE
    reply->nurse_unit_add_1 = a.street_addr, reply->nurse_unit_add_2 = a.street_addr2, reply->
    nurse_unit_city = a.city,
    reply->nurse_unit_zip_code = a.zipcode
    IF (a.state_cd > 0)
     reply->nurse_unit_state = uar_get_code_display(a.state_cd)
    ELSE
     reply->nurse_unit_state = a.state
    ENDIF
    IF (a.country_cd > 0)
     reply->nurse_unit_country = uar_get_code_display(a.country_cd)
    ELSE
     reply->nurse_unit_country = a.country
    ENDIF
   ENDIF
  DETAIL
   donothing = 0
  FOOT  a.parent_entity_id
   donothing = 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
