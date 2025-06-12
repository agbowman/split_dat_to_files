CREATE PROGRAM bed_aud_provider_enrollments:dba
 DECLARE fillcommentsinfo(null) = null
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 provider_enrollment[*]
     2 provider_enrollment_id = f8
     2 last_name = vc
     2 first_name = vc
     2 logical_domain_id = f8
     2 npi_alias = vc
     2 payer_org_name = vc
     2 health_plan_name = vc
     2 facility_name = vc
     2 processing_status = vc
     2 hold_claims_type = vc
     2 process_start_dt = vc
     2 process_end_dt = vc
     2 paperwork_submitted_dt = vc
     2 paperwork_acknowledged_dt = vc
     2 effective_start_dt = vc
     2 effective_end_dt = vc
     2 comments = vc
 )
 DECLARE field_found = i2 WITH protect, noconstant(0)
 DECLARE prg_exists_ind = i2 WITH protect, noconstant(0)
 DECLARE data_partition_ind = i2 WITH protect, noconstant(0)
 DECLARE high_volume_cnt = i4 WITH protect, noconstant(0)
 DECLARE qualifying_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE npi_code = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"NPI"))
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF p IS prsnl
   SET field_found = validate(p.logical_domain_id)
   FREE RANGE p
   IF (field_found=1)
    SET data_partition_ind = 1
    FREE SET acm_get_curr_logical_domain_req
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    FREE SET acm_get_curr_logical_domain_rep
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_curr_logical_domain_req->concept = 2
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
   ENDIF
  ENDIF
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  SELECT
   IF (validate(acm_get_curr_logical_domain_rep))
    PLAN (pe
     WHERE pe.active_ind=1)
     JOIN (p
     WHERE p.person_id=pe.prsnl_id
      AND (p.logical_domain_id=acm_get_curr_logical_domain_rep->logical_domain_id))
     JOIN (o
     WHERE o.organization_id=pe.payer_org_id)
   ELSE
   ENDIF
   INTO "nl:"
   pe_cnt = count(*)
   FROM provider_enrollment pe,
    prsnl p,
    organization o
   PLAN (pe
    WHERE pe.active_ind=1)
    JOIN (p
    WHERE p.person_id=pe.prsnl_id)
    JOIN (o
    WHERE o.organization_id=pe.payer_org_id)
   DETAIL
    high_volume_cnt = pe_cnt
   WITH nocounter
  ;end select
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   SET reply->status_data.status = "S"
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT
  IF (validate(acm_get_curr_logical_domain_rep))
   PLAN (pe
    WHERE pe.active_ind=1)
    JOIN (p
    WHERE p.person_id=pe.prsnl_id
     AND (p.logical_domain_id=acm_get_curr_logical_domain_rep->logical_domain_id))
    JOIN (o
    WHERE o.organization_id=pe.payer_org_id)
    JOIN (cv
    WHERE cv.code_value=pe.location_cd)
    JOIN (dm
    WHERE dm.table_name="PROVIDER_ENROLLMENT"
     AND dm.column_name="BILL_TYPE_FLAG"
     AND dm.flag_value=pe.bill_type_flag)
    JOIN (pa
    WHERE pa.person_id=outerjoin(p.person_id)
     AND pa.prsnl_alias_type_cd=outerjoin(npi_code)
     AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
     AND pa.active_ind=outerjoin(1))
    JOIN (hp
    WHERE hp.health_plan_id=outerjoin(pe.health_plan_id))
  ELSE
  ENDIF
  INTO "nl:"
  FROM provider_enrollment pe,
   prsnl p,
   organization o,
   code_value cv,
   dm_flags dm,
   prsnl_alias pa,
   health_plan hp
  PLAN (pe
   WHERE pe.active_ind=1)
   JOIN (p
   WHERE p.person_id=pe.prsnl_id)
   JOIN (o
   WHERE o.organization_id=pe.payer_org_id)
   JOIN (cv
   WHERE cv.code_value=pe.location_cd)
   JOIN (dm
   WHERE dm.table_name="PROVIDER_ENROLLMENT"
    AND dm.column_name="BILL_TYPE_FLAG"
    AND dm.flag_value=pe.bill_type_flag)
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.prsnl_alias_type_cd=outerjoin(npi_code)
    AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.active_ind=outerjoin(1))
   JOIN (hp
   WHERE hp.health_plan_id=outerjoin(pe.health_plan_id))
  ORDER BY cv.display, cv.code_value, pe.location_priority_seq
  HEAD REPORT
   stat = alterlist(temp->provider_enrollment,100)
  DETAIL
   qualifying_cnt = (qualifying_cnt+ 1)
   IF (mod(qualifying_cnt,100)=1
    AND qualifying_cnt > 100)
    stat = alterlist(temp->provider_enrollment,(qualifying_cnt+ 99))
   ENDIF
   temp->provider_enrollment[qualifying_cnt].provider_enrollment_id = pe.provider_enrollment_id, temp
   ->provider_enrollment[qualifying_cnt].last_name = p.name_last, temp->provider_enrollment[
   qualifying_cnt].first_name = p.name_first,
   temp->provider_enrollment[qualifying_cnt].logical_domain_id = p.logical_domain_id, temp->
   provider_enrollment[qualifying_cnt].npi_alias = pa.alias, temp->provider_enrollment[qualifying_cnt
   ].payer_org_name = o.org_name,
   temp->provider_enrollment[qualifying_cnt].health_plan_name = hp.plan_name, temp->
   provider_enrollment[qualifying_cnt].facility_name = uar_get_code_display(pe.location_cd), temp->
   provider_enrollment[qualifying_cnt].processing_status = uar_get_code_display(pe
    .participation_status_cd),
   temp->provider_enrollment[qualifying_cnt].hold_claims_type = dm.definition, temp->
   provider_enrollment[qualifying_cnt].process_start_dt = format(pe.process_beg_effective_dt_tm,
    "@SHORTDATE"), temp->provider_enrollment[qualifying_cnt].process_end_dt = format(pe
    .process_end_effective_dt_tm,"@SHORTDATE"),
   temp->provider_enrollment[qualifying_cnt].paperwork_submitted_dt = format(pe
    .submitted_to_payer_dt_tm,"@SHORTDATE"), temp->provider_enrollment[qualifying_cnt].
   paperwork_acknowledged_dt = format(pe.received_by_payer_dt_tm,"@SHORTDATE"), temp->
   provider_enrollment[qualifying_cnt].effective_start_dt = format(pe.enroll_beg_effective_dt_tm,
    "@SHORTDATE"),
   temp->provider_enrollment[qualifying_cnt].effective_end_dt = format(pe.enroll_end_effective_dt_tm,
    "@SHORTDATE"), temp->provider_enrollment[qualifying_cnt].comments = ""
  WITH nocounter
 ;end select
 IF (qualifying_cnt > 0)
  SET stat = alterlist(temp->provider_enrollment,qualifying_cnt)
  CALL fillcommentsinfo(null)
 ENDIF
 SET stat = alterlist(reply->collist,16)
 SET reply->collist[1].header_text = "Last Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "First Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Logical Domain ID"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "NPI"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Payer Organization Name"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Health Plan Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Facility Name"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Processing Status"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Hold Claims Type"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Process Start Date"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Process End Date"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Paperwork Submitted Date"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Paperwork Acknowledged Date"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Effective Start Date"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Effective End Date"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Comments"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET stat = alterlist(reply->rowlist,qualifying_cnt)
 FOR (index = 1 TO qualifying_cnt)
   SET stat = alterlist(reply->rowlist[index].celllist,16)
   SET reply->rowlist[index].celllist[1].string_value = temp->provider_enrollment[index].last_name
   SET reply->rowlist[index].celllist[2].string_value = temp->provider_enrollment[index].first_name
   SET reply->rowlist[index].celllist[3].double_value = temp->provider_enrollment[index].
   logical_domain_id
   SET reply->rowlist[index].celllist[4].string_value = temp->provider_enrollment[index].npi_alias
   SET reply->rowlist[index].celllist[5].string_value = temp->provider_enrollment[index].
   payer_org_name
   SET reply->rowlist[index].celllist[6].string_value = temp->provider_enrollment[index].
   health_plan_name
   SET reply->rowlist[index].celllist[7].string_value = temp->provider_enrollment[index].
   facility_name
   SET reply->rowlist[index].celllist[8].string_value = temp->provider_enrollment[index].
   processing_status
   SET reply->rowlist[index].celllist[9].string_value = temp->provider_enrollment[index].
   hold_claims_type
   SET reply->rowlist[index].celllist[10].string_value = temp->provider_enrollment[index].
   process_start_dt
   SET reply->rowlist[index].celllist[11].string_value = temp->provider_enrollment[index].
   process_end_dt
   SET reply->rowlist[index].celllist[12].string_value = temp->provider_enrollment[index].
   paperwork_submitted_dt
   SET reply->rowlist[index].celllist[13].string_value = temp->provider_enrollment[index].
   paperwork_acknowledged_dt
   SET reply->rowlist[index].celllist[14].string_value = temp->provider_enrollment[index].
   effective_start_dt
   SET reply->rowlist[index].celllist[15].string_value = temp->provider_enrollment[index].
   effective_end_dt
   SET reply->rowlist[index].celllist[16].string_value = temp->provider_enrollment[index].comments
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("provider_enrollment.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SUBROUTINE fillcommentsinfo(null)
   DECLARE provider_idx = i4 WITH protect, noconstant(0)
   DECLARE provider_cnt = i4 WITH protect, constant(size(temp->provider_enrollment,5))
   DECLARE priority_low = i4 WITH protect, constant(0)
   DECLARE priority_medium = i4 WITH protect, constant(1)
   DECLARE priority_high = i4 WITH protect, constant(2)
   SELECT INTO "nl:"
    FROM code_value cv,
     corsp_log_reltn clr,
     corsp_log cl,
     long_text lt
    PLAN (cv
     WHERE cv.code_set=18669
      AND cv.cdf_meaning="COMMENT"
      AND cv.active_ind=1)
     JOIN (clr
     WHERE expand(provider_idx,1,provider_cnt,clr.parent_entity_id,temp->provider_enrollment[
      provider_idx].provider_enrollment_id)
      AND clr.parent_entity_name="ENROLLMENT"
      AND clr.active_ind=true)
     JOIN (cl
     WHERE cl.activity_id=clr.activity_id
      AND cl.corsp_type_cd=cv.code_value
      AND cl.active_ind=true
      AND cl.importance_flag IN (priority_low, priority_medium, priority_high))
     JOIN (lt
     WHERE lt.long_text_id=cl.long_text_id
      AND lt.active_ind=true)
    ORDER BY clr.parent_entity_id, cl.created_dt_tm DESC, cl.activity_id
    HEAD REPORT
     idx = 0
    HEAD clr.parent_entity_id
     idx = locateval(provider_idx,1,provider_cnt,clr.parent_entity_id,temp->provider_enrollment[
      provider_idx].provider_enrollment_id)
     IF (idx > 0)
      temp->provider_enrollment[idx].comments = trim(lt.long_text,3)
     ENDIF
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
END GO
