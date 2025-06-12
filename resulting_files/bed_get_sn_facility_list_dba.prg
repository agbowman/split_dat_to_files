CREATE PROGRAM bed_get_sn_facility_list:dba
 FREE SET reply
 RECORD reply(
   01 facility[*]
     02 location_code_value = f8
     02 fac_short_description = vc
     02 fac_full_description = vc
     02 organization_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
 SET facility_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=222
    AND c.cdf_meaning="FACILITY")
  DETAIL
   facility_cd = c.code_value
  WITH nocounter
 ;end select
 SET dm_info_number = 0
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="SECURITY"
   AND d.info_name="SEC_ORG_RELTN"
  DETAIL
   dm_info_number = d.info_number
  WITH nocounter
 ;end select
 SET wcard = "*"
 DECLARE fac_name_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_txt) > " ")
  IF ((request->search_type_flag="S"))
   SET search_string = concat(trim(cnvtupper(request->search_txt)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->search_txt)),wcard)
  ENDIF
  SET fac_name_parse = concat("cnvtupper(c.description) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET fac_name_parse = concat("cnvtupper(c.display_key) = '",search_string,"'")
 ENDIF
 SET ocnt = 0
 IF (dm_info_number=0)
  SELECT INTO "nl:"
   fac_name_key = trim(cnvtalphanum(cnvtupper(c.description)))
   FROM code_value c,
    location l
   PLAN (c
    WHERE parser(fac_name_parse)
     AND c.code_set=220
     AND c.cdf_meaning="FACILITY"
     AND c.active_ind=1)
    JOIN (l
    WHERE l.location_cd=c.code_value
     AND l.location_type_cd=facility_cd
     AND l.active_ind=1)
   ORDER BY fac_name_key
   HEAD REPORT
    ocnt = 0
   DETAIL
    ocnt = (ocnt+ 1), stat = alterlist(reply->facility,ocnt), reply->facility[ocnt].
    location_code_value = c.code_value,
    reply->facility[ocnt].fac_short_description = c.display, reply->facility[ocnt].
    fac_full_description = c.description, reply->facility[ocnt].organization_id = l.organization_id
   WITH nocounter, maxqual(c,value((max_cnt+ 1)))
  ;end select
 ELSE
  SELECT INTO "nl:"
   fac_name_key = trim(cnvtalphanum(cnvtupper(c.description)))
   FROM code_value c,
    location l,
    prsnl_org_reltn p
   PLAN (c
    WHERE parser(fac_name_parse)
     AND c.code_set=220
     AND c.cdf_meaning="FACILITY"
     AND c.active_ind=1)
    JOIN (l
    WHERE l.location_cd=c.code_value
     AND l.location_type_cd=facility_cd
     AND l.active_ind=1)
    JOIN (p
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.organization_id=l.organization_id)
   ORDER BY fac_name_key
   HEAD REPORT
    ocnt = 0
   DETAIL
    ocnt = (ocnt+ 1), stat = alterlist(reply->facility,ocnt), reply->facility[ocnt].
    location_code_value = c.code_value,
    reply->facility[ocnt].fac_short_description = c.display, reply->facility[ocnt].
    fac_full_description = c.description, reply->facility[ocnt].organization_id = l.organization_id
   WITH nocounter, maxqual(c,value((max_cnt+ 1)))
  ;end select
 ENDIF
 IF (ocnt=0)
  SET reply->status_data.status = "Z"
 ELSEIF (ocnt > max_cnt)
  SET stat = alterlist(reply->facility,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
