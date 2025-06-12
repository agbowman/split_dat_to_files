CREATE PROGRAM bed_get_form_status_facs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 facilities[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET active_code_value = 0.0
 SET active_code_value = uar_get_code_by("MEANING",48,"ACTIVE")
 SET auth_code_value = 0.0
 SET auth_code_value = uar_get_code_by("MEANING",8,"AUTH")
 DECLARE tot_fac_cnt = i4
 DECLARE temp_cnt = i4
 SET tot_fac_cnt = 0
 SELECT DISTINCT INTO "nl:"
  offr.facility_cd
  FROM ocs_facility_formulary_r offr,
   location l,
   code_value cv,
   order_catalog_synonym ocs
  PLAN (offr
   WHERE offr.synonym_id > 0
    AND offr.facility_cd > 0)
   JOIN (l
   WHERE l.location_cd=offr.facility_cd
    AND l.active_ind=1
    AND l.active_status_cd=active_code_value
    AND l.data_status_cd=auth_code_value
    AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cv
   WHERE cv.code_value=l.location_cd
    AND cv.code_set=220
    AND cv.cdf_meaning="FACILITY"
    AND cv.active_ind=1
    AND cv.active_type_cd=active_code_value
    AND cv.data_status_cd=auth_code_value
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (ocs
   WHERE ocs.synonym_id=offr.synonym_id
    AND ocs.active_ind=1)
  ORDER BY offr.facility_cd
  HEAD REPORT
   temp_cnt = 0, stat = alterlist(reply->facilities,50)
  DETAIL
   tot_fac_cnt = (tot_fac_cnt+ 1), temp_cnt = (temp_cnt+ 1)
   IF (temp_cnt > 50)
    stat = alterlist(reply->facilities,(tot_fac_cnt+ 50)), temp_cnt = 1
   ENDIF
   reply->facilities[tot_fac_cnt].code_value = l.location_cd, reply->facilities[tot_fac_cnt].
   description = cv.description, reply->facilities[tot_fac_cnt].display = cv.display
  FOOT REPORT
   stat = alterlist(reply->facilities,tot_fac_cnt)
  WITH nocounter
 ;end select
 IF ((request->get_all_fac_ind=1))
  SELECT DISTINCT INTO "nl:"
   offr.facility_cd
   FROM ocs_facility_formulary_r offr,
    order_catalog_synonym ocs
   PLAN (offr
    WHERE offr.synonym_id > 0
     AND offr.facility_cd=0)
    JOIN (ocs
    WHERE ocs.synonym_id=offr.synonym_id
     AND ocs.active_ind=1)
   DETAIL
    tot_fac_cnt = (tot_fac_cnt+ 1), stat = alterlist(reply->facilities,tot_fac_cnt), reply->
    facilities[tot_fac_cnt].code_value = 0,
    reply->facilities[tot_fac_cnt].description = "", reply->facilities[tot_fac_cnt].display = ""
   FOOT REPORT
    stat = alterlist(reply->facilities,tot_fac_cnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
