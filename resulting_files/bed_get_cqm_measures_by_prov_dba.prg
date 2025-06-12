CREATE PROGRAM bed_get_cqm_measures_by_prov:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 providers[*]
      2 provider_id = f8
      2 measures[*]
        3 measure_id = f8
        3 meas_ident = vc
        3 adult_pediatric_type = vc
        3 measure_description = vc
        3 domain = vc
        3 mu_year = vc
        3 high_priority_ind = i2
        3 outcome_ind = i2
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
 DECLARE provider_cnt = i4 WITH protect
 DECLARE measure_cnt = i4 WITH protect
 DECLARE req_size = i4 WITH protect
 DECLARE meas_ident_length = i4 WITH protect
 SET req_size = size(request->providers,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SET provider_cnt = 0
 DECLARE parse_string = vc
 DECLARE mu_year = vc
 DECLARE parse_report_type = vc
 SET report_type_id = request->report_type_id
 SET parse_string = build("bcm.lh_cqm_meas_id = r.lh_cqm_meas_id")
 IF (report_type_id IN ("", null, "TMIPS"))
  SET parse_report_type = build("r.lh_cqm_report_type_tflg in ('',null,'TMIPS')")
 ELSE
  SET parse_report_type = build("r.lh_cqm_report_type_tflg = report_type_id")
 ENDIF
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
  ENDFOR
 ENDIF
 SET meas_ident_length = 0
 SET mu_year = ""
 CALL echo("********")
 CALL echo(parse_report_type)
 CALL echo("********")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = req_size),
   lh_cqm_meas_svc_entity_r r,
   lh_cqm_meas bcm,
   lh_cqm_domain bcd
  PLAN (d)
   JOIN (r
   WHERE (r.parent_entity_id=request->providers[d.seq].provider_id)
    AND r.active_ind=1
    AND parser(parse_report_type)
    AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND r.parent_entity_name=evaluate2(
    IF ((request->providers[d.seq].service_entity_flag=1)) "BR_ELIGIBLE_PROVIDER"
    ELSEIF ((request->providers[d.seq].service_entity_flag=2)) "BR_CCN"
    ENDIF
    ))
   JOIN (bcm
   WHERE parser(parse_string)
    AND (bcm.svc_entity_type_flag=request->providers[d.seq].service_entity_flag))
   JOIN (bcd
   WHERE bcd.lh_cqm_domain_id=bcm.lh_cqm_domain_id)
  ORDER BY r.parent_entity_id
  HEAD r.parent_entity_id
   measure_cnt = 0, provider_cnt = (provider_cnt+ 1), stat = alterlist(reply->providers,provider_cnt),
   reply->providers[provider_cnt].provider_id = r.parent_entity_id
  DETAIL
   measure_cnt = (measure_cnt+ 1), stat = alterlist(reply->providers[provider_cnt].measures,
    measure_cnt), reply->providers[provider_cnt].measures[measure_cnt].measure_id = bcm
   .lh_cqm_meas_id,
   reply->providers[provider_cnt].measures[measure_cnt].meas_ident = bcm.measure_short_desc, reply->
   providers[provider_cnt].measures[measure_cnt].adult_pediatric_type = bcm.population_category_txt,
   reply->providers[provider_cnt].measures[measure_cnt].measure_description = bcm.meas_desc,
   reply->providers[provider_cnt].measures[measure_cnt].domain = bcd.lh_cqm_domain_name, reply->
   providers[provider_cnt].measures[measure_cnt].high_priority_ind = bcm.high_priority_ind, reply->
   providers[provider_cnt].measures[measure_cnt].outcome_ind = bcm.outcome_ind,
   meas_ident_length = textlen(bcm.meas_ident), mu_year = substring((meas_ident_length - 3),
    meas_ident_length,bcm.meas_ident)
   IF (((mu_year="2014") OR (mu_year="2015")) )
    reply->providers[provider_cnt].measures[measure_cnt].mu_year = "2014/2015"
   ELSE
    reply->providers[provider_cnt].measures[measure_cnt].mu_year = mu_year
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Return measures error")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
