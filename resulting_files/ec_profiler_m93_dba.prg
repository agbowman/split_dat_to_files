CREATE PROGRAM ec_profiler_m93:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE mdradnetproductcd = f8 WITH protect, constant(uar_get_code_by("MEANING",26822,"RADNET"))
 DECLARE mlcdimask = i4 WITH protect, noconstant(0)
 DECLARE mdotgstoragecd = f8 WITH protect, constant(uar_get_code_by("MEANING",25,"OTG"))
 DECLARE dfacilitycd = f8 WITH noconstant(0.0)
 DECLARE dpositioncd = f8 WITH noconstant(0.0)
 SELECT INTO "nl:"
  cve.field_value
  FROM code_value_extension cve
  WHERE cve.code_set=26822
   AND cve.code_value=mdradnetproductcd
  DETAIL
   mlcdimask = cnvtint(cve.field_value)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cdichk =
  IF (band(cnvtint(cve.field_value),mlcdimask)=mlcdimask) 1
  ELSE 0
  ENDIF
  FROM order_action oa,
   orders o,
   blob_reference br,
   code_value_extension cve,
   encounter e,
   prsnl p
  PLAN (oa
   WHERE oa.action_sequence=1
    AND oa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm))
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND ((o.template_order_id+ 0)=0))
   JOIN (br
   WHERE br.parent_entity_name="ORDERS"
    AND br.parent_entity_id=o.order_id
    AND br.storage_cd=mdotgstoragecd
    AND br.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
    AND br.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cve
   WHERE ((cve.code_set+ 0)=26820)
    AND cve.field_name="PRODUCT BITMAP"
    AND cve.code_value=br.blob_type_cd)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (p
   WHERE p.person_id=oa.action_personnel_id)
  ORDER BY e.loc_facility_cd DESC, p.position_cd, e.encntr_id
  HEAD REPORT
   facilitycnt = 0, positioncnt = 0
  HEAD e.loc_facility_cd
   dfacilitycd = e.loc_facility_cd
  HEAD p.position_cd
   dpositioncd = p.position_cd, encntrcnt = 0
  HEAD e.encntr_id
   IF (cdichk)
    encntrcnt = (encntrcnt+ 1)
   ENDIF
  FOOT  p.position_cd
   IF (cdichk)
    IF (size(reply->facilities,5) > 0)
     IF ((reply->facilities[facilitycnt].facility_cd != dfacilitycd))
      facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(
       reply->facilities,facilitycnt),
      reply->facilities[facilitycnt].facility_cd = e.loc_facility_cd
     ENDIF
    ELSE
     facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(
      reply->facilities,facilitycnt),
     reply->facilities[facilitycnt].facility_cd = e.loc_facility_cd
    ENDIF
    IF (size(reply->facilities[facilitycnt].positions,5) > 0)
     IF ((reply->facilities[facilitycnt].positions[positioncnt].position_cd != dpositioncd))
      positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
      position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,
       positioncnt),
      reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
      facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
     ENDIF
    ELSE
     positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
     position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,
      positioncnt),
     reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
     facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
    ENDIF
    detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
    facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
     facilities[facilitycnt].positions[positioncnt].details,detailcnt),
    reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = "", reply
    ->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = trim(
     cnvtstring(encntrcnt))
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
