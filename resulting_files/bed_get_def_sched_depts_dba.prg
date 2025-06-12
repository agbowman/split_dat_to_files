CREATE PROGRAM bed_get_def_sched_depts:dba
 FREE SET reply
 RECORD reply(
   1 facilities[*]
     2 code_value = f8
     2 display = vc
     2 prefix = vc
     2 buildings[*]
       3 code_value = f8
       3 display = vc
       3 departments[*]
         4 code_value = f8
         4 display = vc
         4 prefix = vc
         4 unit_type_meaning = vc
         4 dept_type_id = f8
         4 dept_type_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE SET temporgs
 RECORD temporgs(
   1 orgs[*]
     2 id = f8
 )
 FREE SET valid_facs
 RECORD valid_facs(
   1 facs[*]
     2 code_value = f8
 )
 SET org_cnt = size(request->facilities,5)
 SET stat = alterlist(temporgs->orgs,org_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = org_cnt),
   location l
  PLAN (d)
   JOIN (l
   WHERE (l.location_cd=request->facilities[d.seq].code_value)
    AND l.active_ind=1)
  DETAIL
   temporgs->orgs[d.seq].id = l.organization_id
  WITH nocounter
 ;end select
 SET facility_cd = 0.0
 SET building_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning IN ("FACILITY", "BUILDING")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="FACILITY")
    facility_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="BUILDING")
    building_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET data_partition_ind = 0
 SET field_found = 0
 RANGE OF o IS organization
 SET field_found = validate(o.logical_domain_id)
 FREE RANGE o
 IF (field_found=1)
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
 ENDIF
 DECLARE oparse = vc
 SET oparse = "o.active_ind = 1"
 IF (data_partition_ind=1)
  SET oparse = build2(oparse," and o.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
 ENDIF
 IF ((request->search_string=null))
  SET request->search_string = " "
 ENDIF
 IF ((request->search_type_flag=null))
  SET request->search_type_flag = "S"
 ENDIF
 DECLARE search_string = vc
 IF ((request->search_type_flag="S"))
  SET search_string = build('"',trim(cnvtupper(cnvtalphanum(request->search_string))),'*"')
 ELSEIF ((request->search_type_flag="C"))
  SET search_string = build('"*',trim(cnvtupper(cnvtalphanum(request->search_string))),'*"')
 ENDIF
 DECLARE cvparse = vc
 SET cvparse = "cv.active_ind = 1"
 IF ((request->search_string > " "))
  SET cvparse = build2(cvparse," and cv.display_key = ",search_string)
 ENDIF
 DECLARE cv3parse = vc
 SET cv3parse = "cv3.active_ind = 1"
 IF ((request->search_string > " "))
  SET cv3parse = build2(cv3parse," and cv3.display_key = ",search_string)
 ENDIF
 SET valid_fac_cnt = 0
 SELECT INTO "nl:"
  FROM br_sched_dept b,
   code_value cv,
   location l,
   organization o,
   location_group lg1,
   location_group lg2
  PLAN (b)
   JOIN (cv
   WHERE cv.code_value=b.location_cd
    AND parser(cvparse))
   JOIN (l
   WHERE l.location_cd=b.location_cd
    AND l.active_ind=1)
   JOIN (o
   WHERE o.organization_id=l.organization_id
    AND parser(oparse))
   JOIN (lg1
   WHERE lg1.child_loc_cd=b.location_cd
    AND lg1.location_group_type_cd=building_cd
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND lg2.location_group_type_cd=facility_cd
    AND lg2.active_ind=1)
  DETAIL
   continue_ind = 1
   IF (org_cnt > 0)
    found_ind = 0, start = 1, num = 0,
    found_ind = locateval(num,start,org_cnt,o.organization_id,temporgs->orgs[num].id)
    IF (found_ind=0)
     continue_ind = 0
    ENDIF
   ENDIF
   IF (continue_ind=1)
    found_ind = 0, start = 1, num = 0
    IF (valid_fac_cnt > 0)
     found_ind = locateval(num,start,valid_fac_cnt,lg2.parent_loc_cd,valid_facs->facs[num].code_value
      )
    ENDIF
    IF (found_ind=0)
     valid_fac_cnt = (valid_fac_cnt+ 1), stat = alterlist(valid_facs->facs,valid_fac_cnt), valid_facs
     ->facs[valid_fac_cnt].code_value = lg2.parent_loc_cd
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET fcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = valid_fac_cnt),
   location_group lg1,
   code_value cv1,
   location_group lg2,
   code_value cv2,
   br_sched_dept b,
   br_sched_dept_type bt,
   code_value cv3,
   location l,
   organization o,
   code_value cv4,
   br_organization bo
  PLAN (d)
   JOIN (lg1
   WHERE (lg1.parent_loc_cd=valid_facs->facs[d.seq].code_value)
    AND lg1.location_group_type_cd=facility_cd
    AND lg1.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=lg1.parent_loc_cd
    AND cv1.active_ind=1)
   JOIN (lg2
   WHERE lg2.parent_loc_cd=lg1.child_loc_cd
    AND lg2.location_group_type_cd=building_cd
    AND lg2.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=lg2.parent_loc_cd
    AND cv2.active_ind=1)
   JOIN (b
   WHERE b.location_cd=lg2.child_loc_cd)
   JOIN (bt
   WHERE bt.dept_type_id=b.dept_type_id)
   JOIN (cv3
   WHERE cv3.code_value=b.location_cd
    AND parser(cv3parse))
   JOIN (l
   WHERE l.location_cd=b.location_cd
    AND l.active_ind=1)
   JOIN (o
   WHERE o.organization_id=l.organization_id
    AND o.active_ind=1)
   JOIN (cv4
   WHERE cv4.code_value=l.location_type_cd
    AND cv4.active_ind=1)
   JOIN (bo
   WHERE bo.organization_id=outerjoin(l.organization_id))
  ORDER BY cv1.code_value, cv2.code_value, cv3.code_value
  HEAD cv1.code_value
   fcnt = (fcnt+ 1), stat = alterlist(reply->facilities,fcnt), reply->facilities[fcnt].code_value =
   cv1.code_value,
   reply->facilities[fcnt].display = cv1.display, reply->facilities[fcnt].prefix = bo.br_prefix, bcnt
    = 0
  HEAD cv2.code_value
   bcnt = (bcnt+ 1), stat = alterlist(reply->facilities[fcnt].buildings,bcnt), reply->facilities[fcnt
   ].buildings[bcnt].code_value = cv2.code_value,
   reply->facilities[fcnt].buildings[bcnt].display = cv2.display, dcnt = 0
  HEAD cv3.code_value
   continue_ind = 1
   IF (data_partition_ind=1)
    IF ((o.logical_domain_id != acm_get_curr_logical_domain_rep->logical_domain_id))
     continue_ind = 0
    ENDIF
   ENDIF
   IF (continue_ind=1)
    IF (org_cnt > 0)
     found_ind = 0, start = 1, num = 0,
     found_ind = locateval(num,start,org_cnt,o.organization_id,temporgs->orgs[num].id)
     IF (found_ind=0)
      continue_ind = 0
     ENDIF
    ENDIF
   ENDIF
   IF (continue_ind=1)
    dcnt = (dcnt+ 1), stat = alterlist(reply->facilities[fcnt].buildings[bcnt].departments,dcnt),
    reply->facilities[fcnt].buildings[bcnt].departments[dcnt].code_value = cv3.code_value,
    reply->facilities[fcnt].buildings[bcnt].departments[dcnt].display = cv3.display, reply->
    facilities[fcnt].buildings[bcnt].departments[dcnt].prefix = b.dept_prefix, reply->facilities[fcnt
    ].buildings[bcnt].departments[dcnt].unit_type_meaning = cv4.cdf_meaning,
    reply->facilities[fcnt].buildings[bcnt].departments[dcnt].dept_type_id = bt.dept_type_id, reply->
    facilities[fcnt].buildings[bcnt].departments[dcnt].dept_type_display = bt.dept_type_display
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
