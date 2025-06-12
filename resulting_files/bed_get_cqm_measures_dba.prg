CREATE PROGRAM bed_get_cqm_measures:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 measures[*]
      2 measure_id = f8
      2 meas_ident = vc
      2 adult_pediatric_type = vc
      2 measure_description = vc
      2 domain = vc
      2 high_priority_ind = i2
      2 outcome_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD mu_years_temp(
   1 years_list[*]
     2 year = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE mu_ec_cms2 = vc WITH noconstant("MU_EC_CMS2_"), protect
 DECLARE mu_ec_cms122 = vc WITH noconstant("MU_EC_CMS122_"), protect
 DECLARE mu_ec_cms137 = vc WITH noconstant("MU_EC_CMS137_"), protect
 DECLARE mu_ec_cms165 = vc WITH noconstant("MU_EC_CMS165_"), protect
 DECLARE mu_ec_cms347 = vc WITH noconstant("MU_EC_CMS347_"), protect
 DECLARE mu_ec_cms349 = vc WITH noconstant("MU_EC_CMS349_"), protect
 DECLARE mu_ec_cms68 = vc WITH noconstant("MU_EC_CMS68_"), protect
 DECLARE mu_ec_cms154 = vc WITH noconstant("MU_EC_CMS154_"), protect
 DECLARE mu_ec_cms69 = vc WITH noconstant("MU_EC_CMS69_"), protect
 DECLARE mu_ec_cms56 = vc WITH noconstant("MU_EC_CMS56_"), protect
 DECLARE mu_ec_cms127 = vc WITH noconstant("MU_EC_CMS127_"), protect
 DECLARE measure_cnt = i4
 DECLARE temp_cnt = i4
 SET service_entity_flag = request->service_entity_flag
 SET report_type_id = request->report_type_id
 DECLARE parse_string = vc
 DECLARE parse_report_type = vc
 DECLARE mu_year = vc
 SET parse_string = build("bcm.lh_cqm_meas_id > 0 and service_entity_flag = bcm.svc_entity_type_flag"
  )
 SET parse_report_type = build(" 1=1")
 IF (validate(request->mu_years))
  FOR (year_cnt = 1 TO size(request->mu_years,5))
    SET stat = alterlist(mu_years_temp->years_list,year_cnt)
    SET mu_years_temp->years_list[year_cnt].year = cnvtstring(request->mu_years[year_cnt].year)
    IF (year_cnt=1)
     SET parse_string = build(parse_string,
      " and substring(TEXTLEN(trim(bcm.meas_ident,7))-3, TEXTLEN(trim(bcm.meas_ident,7)),",
      " trim(bcm.meas_ident,7)) = mu_years_temp->years_list[",year_cnt,"]->year")
    ELSE
     SET parse_string = build(parse_string,
      " or substring(TEXTLEN(trim(bcm.meas_ident,7))-3, TEXTLEN(trim(bcm.meas_ident,7)),",
      " trim(bcm.meas_ident,7)) = mu_years_temp->years_list[",year_cnt,"]->year")
    ENDIF
    SET mu_ec_cms2 = trim(concat(mu_ec_cms2,mu_years_temp->years_list[year_cnt].year))
    SET mu_ec_cms122 = trim(concat(mu_ec_cms122,mu_years_temp->years_list[year_cnt].year))
    SET mu_ec_cms137 = trim(concat(mu_ec_cms137,mu_years_temp->years_list[year_cnt].year))
    SET mu_ec_cms165 = trim(concat(mu_ec_cms165,mu_years_temp->years_list[year_cnt].year))
    SET mu_ec_cms347 = trim(concat(mu_ec_cms347,mu_years_temp->years_list[year_cnt].year))
    SET mu_ec_cms349 = trim(concat(mu_ec_cms349,mu_years_temp->years_list[year_cnt].year))
    SET mu_ec_cms68 = trim(concat(mu_ec_cms68,mu_years_temp->years_list[year_cnt].year))
    SET mu_ec_cms154 = trim(concat(mu_ec_cms154,mu_years_temp->years_list[year_cnt].year))
    SET mu_ec_cms69 = trim(concat(mu_ec_cms69,mu_years_temp->years_list[year_cnt].year))
    SET mu_ec_cms56 = trim(concat(mu_ec_cms56,mu_years_temp->years_list[year_cnt].year))
    SET mu_ec_cms127 = trim(concat(mu_ec_cms127,mu_years_temp->years_list[year_cnt].year))
    IF (report_type_id="M0003")
     SET parse_report_type = build(" bcm.meas_ident in (MU_EC_CMS68)")
    ELSEIF (report_type_id="M0005")
     SET parse_report_type = build(
      " bcm.meas_ident in (MU_EC_CMS2,MU_EC_CMS122,MU_EC_CMS137,MU_EC_CMS165,MU_EC_CMS347,MU_EC_CMS349)"
      )
    ELSEIF (report_type_id="G0057")
     SET parse_report_type = build(" bcm.meas_ident in (MU_EC_CMS154)")
    ELSEIF (report_type_id="G0053")
     SET parse_report_type = build(" bcm.meas_ident in (MU_EC_CMS2,MU_EC_CMS68)")
    ELSEIF (report_type_id="G0058")
     SET parse_report_type = build(" bcm.meas_ident in (MU_EC_CMS69,MU_EC_CMS56,MU_EC_CMS127)")
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM lh_cqm_meas bcm,
   lh_cqm_domain bcd
  PLAN (bcm
   WHERE parser(parse_string)
    AND parser(parse_report_type))
   JOIN (bcd
   WHERE bcm.lh_cqm_domain_id=bcd.lh_cqm_domain_id)
  HEAD REPORT
   measure_cnt = 0
  DETAIL
   measure_cnt = (measure_cnt+ 1), stat = alterlist(reply->measures,measure_cnt), reply->measures[
   measure_cnt].measure_id = bcm.lh_cqm_meas_id,
   reply->measures[measure_cnt].meas_ident = bcm.measure_short_desc, reply->measures[measure_cnt].
   adult_pediatric_type = bcm.population_category_txt, reply->measures[measure_cnt].
   measure_description = bcm.meas_desc,
   reply->measures[measure_cnt].domain = bcd.lh_cqm_domain_name, reply->measures[measure_cnt].
   high_priority_ind = bcm.high_priority_ind, reply->measures[measure_cnt].outcome_ind = bcm
   .outcome_ind
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting CQ measures.")
 CALL echorecord(reply)
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
