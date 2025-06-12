CREATE PROGRAM ec_profiler_m16:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE pvcval1 = vc WITH constant("1 - Search for Inpatient and Ambulatory - In Office orders.")
 DECLARE pvcval2 = vc WITH constant("2 - Search for Inpatient, Discharge Meds and Ambulatory Meds.")
 DECLARE pvcval3 = vc WITH constant(
  "3 - Search for Inpatient, Discharge Meds, Ambulatory - In Office, and Ambulatory Meds. (ALL)")
 SELECT INTO "nl"
  FROM app_prefs ap,
   name_value_prefs nvp
  PLAN (ap
   WHERE ap.prsnl_id=0
    AND ap.position_cd >= 0
    AND ap.application_number > 0.0)
   JOIN (nvp
   WHERE nvp.parent_entity_id=ap.app_prefs_id
    AND trim(nvp.pvc_name)="UNIFIED_ORDERING_CONFIG")
  ORDER BY ap.position_cd
  HEAD REPORT
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = 0.0
  HEAD ap.position_cd
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = ap.position_cd
   IF (cnvtint(nvp.pvc_value) > 0)
    reply->facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1, detailcnt = (
    reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->facilities[
    facilitycnt].positions[positioncnt].detail_cnt = detailcnt,
    stat = alterlist(reply->facilities[facilitycnt].positions[positioncnt].details,detailcnt), reply
    ->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name = nvp.pvc_name
    IF (cnvtint(nvp.pvc_value)=1)
     reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt =
     pvcval1
    ELSEIF (cnvtint(nvp.pvc_value)=2)
     reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt =
     pvcval2
    ELSEIF (cnvtint(nvp.pvc_value)=3)
     reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt =
     pvcval3
    ELSE
     reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_value_txt = nvp
     .pvc_value
    ENDIF
   ELSE
    reply->facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 0
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
