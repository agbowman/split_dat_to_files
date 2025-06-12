CREATE PROGRAM bed_get_ep_meas_defined:dba
 RECORD mu_years_temp(
   1 years_list[*]
     2 year = vc
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 ep_prsnl_list[*]
      2 ep_id = f8
      2 measure_cnt = i4
      2 pilot_measures_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
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
 DECLARE measure_cnt = i4 WITH protect, noconstant(0)
 DECLARE pilot_cnt = i4 WITH protect, noconstant(0)
 DECLARE measure_type = i4 WITH protect, noconstant(0)
 DECLARE epcnt = i4 WITH protect, noconstant(0)
 SET epcnt = size(request->ep_prsnl_list,5)
 IF (validate(request->measure_type_flag))
  SET measure_type = request->measure_type_flag
 ENDIF
 IF (epcnt > 0)
  SET stat = alterlist(reply->ep_prsnl_list,epcnt)
  FOR (x = 1 TO epcnt)
    SET reply->ep_prsnl_list[x].ep_id = request->ep_prsnl_list[x].ep_id
  ENDFOR
  IF (measure_type=0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(epcnt)),
     br_elig_prov_meas_reltn epmr,
     pca_quality_measure pqm
    PLAN (d)
     JOIN (epmr
     WHERE epmr.br_eligible_provider_id=outerjoin(reply->ep_prsnl_list[d.seq].ep_id)
      AND epmr.active_ind=1
      AND epmr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (pqm
     WHERE pqm.pca_quality_measure_id=outerjoin(epmr.pca_quality_measure_id))
    ORDER BY d.seq
    HEAD d.seq
     measure_cnt = 0
    DETAIL
     IF (pqm.pca_quality_measure_id > 0)
      measure_cnt = (measure_cnt+ 1)
     ENDIF
    FOOT  d.seq
     reply->ep_prsnl_list[d.seq].measure_cnt = measure_cnt
    WITH nocounter
   ;end select
   CALL bederrorcheck("error on get NQF measures")
  ELSEIF (measure_type=1)
   DECLARE pilot_cnt = i4 WITH protect
   SET pilot_cnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(epcnt)),
     br_pqrs_meas_provider_reltn br,
     br_pqrs_meas brm
    PLAN (d)
     JOIN (br
     WHERE (br.br_eligible_provider_id=reply->ep_prsnl_list[d.seq].ep_id)
      AND br.active_ind=1
      AND br.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (brm
     WHERE brm.br_pqrs_meas_id=br.br_pqrs_meas_id)
    ORDER BY d.seq
    HEAD d.seq
     measure_cnt = 0, pilot_cnt = 0
    DETAIL
     IF ((request->pqrs_type=1))
      IF (brm.br_pqrs_meas_id > 0
       AND br.pilot_eligible_ind=0)
       pilot_cnt = (pilot_cnt+ 1)
      ELSEIF (brm.br_pqrs_meas_id > 0
       AND br.pilot_eligible_ind=1)
       measure_cnt = (measure_cnt+ 1)
      ENDIF
     ELSEIF (brm.br_pqrs_meas_id > 0)
      measure_cnt = (measure_cnt+ 1)
     ENDIF
    FOOT  d.seq
     reply->ep_prsnl_list[d.seq].measure_cnt = measure_cnt, reply->ep_prsnl_list[d.seq].
     pilot_measures_cnt = pilot_cnt
    WITH nocounter
   ;end select
   CALL bederrorcheck("error on get PQRS measures")
  ELSEIF (measure_type=2)
   DECLARE parse_string = vc
   DECLARE parse_report_type = vc
   DECLARE mu_year = vc
   SET parse_string = build("cqm.lh_cqm_meas_id = cqmr.lh_cqm_meas_id")
   SET parse_report_type = build(" 1=1")
   IF (validate(request->mu_years))
    FOR (year_cnt = 1 TO size(request->mu_years,5))
      SET stat = alterlist(mu_years_temp->years_list,year_cnt)
      SET mu_years_temp->years_list[year_cnt].year = cnvtstring(request->mu_years[year_cnt].year)
      IF (year_cnt=1)
       SET parse_string = build(parse_string,
        " and substring(TEXTLEN(trim(cqm.meas_ident,7))-3, TEXTLEN(trim(cqm.meas_ident,7)),",
        " trim(cqm.meas_ident,7)) = mu_years_temp->years_list[",year_cnt,"]->year")
      ELSE
       SET parse_string = build(parse_string,
        " or substring(TEXTLEN(trim(cqm.meas_ident,7))-3, TEXTLEN(trim(cqm.meas_ident,7)),",
        " trim(cqm.meas_ident,7)) = mu_years_temp->years_list[",year_cnt,"]->year")
      ENDIF
    ENDFOR
   ENDIF
   IF ((request->report_type_id IN ("TMIPS", null, "")))
    SET parse_report_type = build(" cqmr.lh_cqm_report_type_tflg in ('',null,'TMIPS')")
   ELSEIF ( NOT ((request->report_type_id IN ("TMIPS", null, ""))))
    SET parse_report_type = build(" cqmr.lh_cqm_report_type_tflg = ","request->report_type_id")
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(epcnt)),
     lh_cqm_meas_svc_entity_r cqmr,
     lh_cqm_meas cqm
    PLAN (d)
     JOIN (cqmr
     WHERE cqmr.parent_entity_id=outerjoin(reply->ep_prsnl_list[d.seq].ep_id)
      AND cqmr.active_ind=1
      AND cqmr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND parser(parse_report_type))
     JOIN (cqm
     WHERE parser(parse_string))
    ORDER BY d.seq
    HEAD d.seq
     measure_cnt = 0
    DETAIL
     measure_cnt = (measure_cnt+ 1)
    FOOT  d.seq
     reply->ep_prsnl_list[d.seq].measure_cnt = measure_cnt
    WITH nocounter
   ;end select
   CALL bederrorcheck("error on get CQM measures")
  ELSEIF (measure_type=3)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(epcnt)),
     br_svc_entity_report_reltn svc,
     br_datamart_report rep,
     br_datamart_category cat
    PLAN (d)
     JOIN (svc
     WHERE (svc.parent_entity_id=reply->ep_prsnl_list[d.seq].ep_id)
      AND svc.active_ind=1
      AND svc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (rep
     WHERE rep.br_datamart_report_id=svc.br_datamart_report_id)
     JOIN (cat
     WHERE cat.br_datamart_category_id=rep.br_datamart_category_id
      AND cat.category_mean="MUSE_FUNCTIONAL")
    ORDER BY d.seq
    HEAD d.seq
     measure_cnt = 0
    DETAIL
     measure_cnt = (measure_cnt+ 1)
    FOOT  d.seq
     reply->ep_prsnl_list[d.seq].measure_cnt = measure_cnt
    WITH nocounter
   ;end select
   CALL bederrorcheck("GETDEFINEDFM1INDERROR")
  ELSEIF (measure_type=4)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(epcnt)),
     br_svc_entity_report_reltn svc,
     br_datamart_report rep,
     br_datamart_category cat
    PLAN (d)
     JOIN (svc
     WHERE (svc.parent_entity_id=reply->ep_prsnl_list[d.seq].ep_id)
      AND svc.active_ind=1
      AND svc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (rep
     WHERE rep.br_datamart_report_id=svc.br_datamart_report_id)
     JOIN (cat
     WHERE cat.br_datamart_category_id=rep.br_datamart_category_id
      AND cat.category_mean="MUSE_FUNCTIONAL_2")
    ORDER BY d.seq
    HEAD d.seq
     measure_cnt = 0
    DETAIL
     measure_cnt = (measure_cnt+ 1)
    FOOT  d.seq
     reply->ep_prsnl_list[d.seq].measure_cnt = measure_cnt
    WITH nocounter
   ;end select
   CALL bederrorcheck("GETDEFINEDFM2INDERROR")
  ENDIF
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
