CREATE PROGRAM bed_get_datamart_flex_params:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 filter_ids[*]
      2 filter_id = f8
      2 flex_ids[*]
        3 flex_id = f8
        3 params[*]
          4 parent_entity_name = vc
          4 parent_entity_value = f8
          4 parent_entity_type_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE vparse = vc
 SET vparse = "v.end_effective_dt_tm > cnvtdatetime(curdate,curtime)"
 SET data_partition_ind = 0
 SET br_datamart_value_field_found = 0
 RANGE OF b IS br_datamart_value
 SET br_datamart_value_field_found = validate(b.logical_domain_id)
 FREE RANGE b
 SET prsnl_field_found = 0
 RANGE OF p IS prsnl
 SET prsnl_field_found = validate(p.logical_domain_id)
 FREE RANGE p
 IF (prsnl_field_found=1
  AND br_datamart_value_field_found=1)
  SET data_partition_ind = 1
 ENDIF
 IF (data_partition_ind=1)
  IF (validate(ld_concept_person)=0)
   DECLARE ld_concept_person = i2 WITH public, constant(1)
  ENDIF
  IF (validate(ld_concept_prsnl)=0)
   DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
  ENDIF
  IF (validate(ld_concept_organization)=0)
   DECLARE ld_concept_organization = i2 WITH public, constant(3)
  ENDIF
  IF (validate(ld_concept_healthplan)=0)
   DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
  ENDIF
  IF (validate(ld_concept_alias_pool)=0)
   DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
  ENDIF
  IF (validate(ld_concept_minvalue)=0)
   DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
  ENDIF
  IF (validate(ld_concept_maxvalue)=0)
   DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
  ENDIF
  RECORD acm_get_curr_logical_domain_req(
    1 concept = i4
  )
  RECORD acm_get_curr_logical_domain_rep(
    1 logical_domain_id = f8
    1 status_block
      2 status_ind = i2
      2 error_code = i4
  )
  SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
  EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
  replace("REPLY",acm_get_curr_logical_domain_rep)
  SET vparse = build2(vparse," and v.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
 ENDIF
 SET icnt = 0
 SET fcnt = 0
 SET pcnt = 0
 SELECT INTO "nl:"
  FROM br_datamart_value v,
   br_datamart_flex f
  PLAN (v
   WHERE (v.br_datamart_category_id=request->br_datamart_category_id)
    AND v.br_datamart_flex_id > 0
    AND parser(vparse))
   JOIN (f
   WHERE f.br_datamart_flex_id=v.br_datamart_flex_id)
  ORDER BY v.br_datamart_filter_id, f.br_datamart_flex_id, f.parent_entity_name,
   f.parent_entity_id, f.parent_entity_type_flag
  HEAD v.br_datamart_filter_id
   icnt = (icnt+ 1), fcnt = 0, stat = alterlist(reply->filter_ids,icnt),
   reply->filter_ids[icnt].filter_id = v.br_datamart_filter_id
  HEAD f.br_datamart_flex_id
   fcnt = (fcnt+ 1), pcnt = 0, stat = alterlist(reply->filter_ids[icnt].flex_ids,fcnt),
   reply->filter_ids[icnt].flex_ids[fcnt].flex_id = f.br_datamart_flex_id
  HEAD f.parent_entity_name
   xcnt = 0
  HEAD f.parent_entity_id
   xcnt = 0
  HEAD f.parent_entity_type_flag
   pcnt = (pcnt+ 1), stat = alterlist(reply->filter_ids[icnt].flex_ids[fcnt].params,pcnt), reply->
   filter_ids[icnt].flex_ids[fcnt].params[pcnt].parent_entity_name = f.parent_entity_name,
   reply->filter_ids[icnt].flex_ids[fcnt].params[pcnt].parent_entity_value = f.parent_entity_id,
   reply->filter_ids[icnt].flex_ids[fcnt].params[pcnt].parent_entity_type_flag = f
   .parent_entity_type_flag
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
