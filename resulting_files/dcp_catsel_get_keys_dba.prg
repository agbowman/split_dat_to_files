CREATE PROGRAM dcp_catsel_get_keys:dba
 RECORD reply(
   1 qual_cnt = i4
   1 qual[10]
     2 display = vc
     2 keyval = vc
     2 code = f8
     2 type = i2
     2 ref_text_mask = i4
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 oe_format_id = f8
     2 cat_not_avail_ind = i2
     2 cat_not_avail_msg = vc
     2 cat_not_avail_qual[*]
       3 surg_area_cd = f8
       3 location_cd = f8
       3 location_disp = c40
       3 location_desc = c60
       3 location_mean = c12
   1 exact_match_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE loc_cnt = i4 WITH private, noconstant(0)
 DECLARE bcontinue = i2 WITH private, noconstant(0)
 DECLARE stat = i4 WITH private, noconstant(0)
 DECLARE idx = i4
 DECLARE idx2 = i4
 DECLARE cur_idx = i4 WITH private, noconstant(0)
 DECLARE loc_size = i4
 RECORD loc_cd(
   1 qual[*]
     2 location_cd = f8
     2 surg_area_cd = f8
 )
 IF (validate(request->location_cd,0) > 0)
  SET bcontinue = 1
 ENDIF
 IF (validate(request->location_qual) > 0)
  IF (size(request->location_qual,5) > 0)
   SET bcontinue = 1
  ENDIF
 ENDIF
 IF (bcontinue=0)
  SET stat = alterlist(loc_cd->qual,1)
  SET loc_cd->qual[1].location_cd = 0.0
  SET loc_cd->qual[1].surg_area_cd = 0.0
 ELSE
  SET code_set = 223
  SET code_value = 0.0
  SET cdf_meaning = fillstring(12," ")
  SET cdf_meaning = "SURGAREA"
  EXECUTE cpm_get_cd_for_cdf
  SET serv_res_type_cd = code_value
  IF (validate(request->location_cd,0) > 0)
   SET stat = alterlist(loc_cd->qual,1)
   SET loc_cd->qual[1].location_cd = request->location_cd
  ELSE
   SET loc_cnt = size(request->location_qual,5)
   SET stat = alterlist(loc_cd->qual,loc_cnt)
   FOR (x = 1 TO loc_cnt)
     SET loc_cd->qual[x].location_cd = request->location_qual[x].location_cd
   ENDFOR
  ENDIF
  SET loc_size = size(loc_cd->qual,5)
  SELECT INTO "NL:"
   FROM service_resource sr
   PLAN (sr
    WHERE expand(idx,1,loc_size,sr.location_cd,loc_cd->qual[idx].location_cd)
     AND sr.service_resource_type_cd=serv_res_type_cd
     AND sr.active_ind=1)
   DETAIL
    cur_idx = locateval(idx2,1,loc_size,sr.location_cd,loc_cd->qual[idx2].location_cd)
    IF (cur_idx > 0)
     loc_cd->qual[cur_idx].surg_area_cd = sr.service_resource_cd
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE m_logical_domain_id = f8 WITH protected, noconstant(0.0)
 DECLARE logical_domain_flag = i4 WITH protected, noconstant(0)
 IF (validate(request->logical_domain_flag,0) > 0)
  SET logical_domain_flag = request->logical_domain_flag
 ENDIF
 IF (logical_domain_flag=1)
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
  EXECUTE acm_get_curr_logical_domain
  IF ((acm_get_curr_logical_domain_rep->status_block.status_ind=true))
   SET m_logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
  ENDIF
 ELSEIF (logical_domain_flag=2
  AND validate(request->logical_domain_loc_cd,0) > 0)
  SELECT INTO "nl:"
   l.location_cd
   FROM location l,
    organization o
   PLAN (l
    WHERE (l.location_cd=request->logical_domain_loc_cd))
    JOIN (o
    WHERE o.organization_id=l.organization_id)
   DETAIL
    m_logical_domain_id = o.logical_domain_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->all_cat_types_ind=1)
  AND (request->all_mnem_type_ind=1))
  SET whereclause = concat(
   "(ocs.orderable_type_flag is NULL or ocs.orderable_type_flag in (0,1,2,3,6,8,9,10,11))")
  GO TO key_call
 ELSEIF ((request->all_cat_types_ind=1))
  GO TO mnemonic_filter
 ELSEIF ((request->all_mnem_type_ind=1))
  GO TO type_filter
 ENDIF
#mnemonic_filter
 SET mnemonic_filter = fillstring(4000," ")
 FOR (x = 1 TO request->mnemonic_type_cnt)
   SET mnemonic_filter = concat(trim(mnemonic_filter),
    IF (x != 1) ","
    ENDIF
    ,format(request->mnemonic_types[x].mnemonic_type_cd,"##########.##"))
 ENDFOR
 IF ((request->all_cat_types_ind=1))
  SET whereclause = concat("(ocs.mnemonic_type_cd in (",trim(mnemonic_filter),
   ") and (ocs.orderable_type_flag is NULL or  ocs.orderable_type_flag in (0,1,2,3,6,8,9,10,11)))")
  GO TO key_call
 ENDIF
#type_filter
 SET type_filter = fillstring(4000," ")
 SET x = 0
 FOR (x = 1 TO request->catalog_type_cnt)
   SET type_filter = concat(trim(type_filter),
    IF (x != 1) ","
    ENDIF
    ,format(request->catalog_types[x].catalog_type_cd,"##########.####"))
 ENDFOR
 IF ((request->all_mnem_type_ind=1))
  SET whereclause = concat("(ocs.catalog_type_cd in (",trim(type_filter),
   ") and (ocs.orderable_type_flag is NULL or ocs.orderable_type_flag in (0,1,2,3,6, 8,9,10,11)))")
  GO TO key_call
 ELSE
  SET whereclause = concat("(ocs.mnemonic_type_cd in (",trim(mnemonic_filter),
   ") and ocs.catalog_type_cd in (",trim(type_filter),
   ") and (ocs.orderable_type_flag is NULL or  ocs.orderable_type_flag in (0,1,2,3,6,8,9,10,11)))")
  GO TO key_call
 ENDIF
#key_call
 IF ((request->orderable_search_method=1))
  EXECUTE dcp_catsel_key_call_intl sqlpassthru(whereclause)
 ELSE
  EXECUTE dcp_catsel_key_call sqlpassthru(whereclause)
 ENDIF
 SET last_mod = "181728 11/18/08 CERSUM"
END GO
