CREATE PROGRAM bed_get_pharm_fac_hier:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 facilities[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
      2 buildings[*]
        3 code_value = f8
        3 display = vc
        3 description = vc
        3 pharmacies[*]
          4 code_value = f8
          4 display = vc
          4 description = vc
        3 nursing_units[*]
          4 code_value = f8
          4 display = vc
          4 description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_locs
 RECORD temp_locs(
   1 items[*]
     2 item_id = f8
     2 locs[*]
       3 loc_cd = f8
       3 loc_disp = vc
       3 loc_mean = vc
 )
 SET reply->status_data.status = "F"
 SET fcnt = 0
 SET fac_code_value = 0.0
 SET building_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning IN ("FACILITY", "BUILDING")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="FACILITY")
    fac_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="BUILDING")
    building_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET pharm_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   pharm_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET inpatient_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4500
   AND cv.cdf_meaning="INPATIENT"
   AND cv.active_ind=1
  DETAIL
   inpatient_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET data_partition_ind = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF o IS organization
   SET field_found = validate(o.logical_domain_id)
   FREE RANGE o
   IF (field_found=1)
    SET data_partition_ind = 1
    FREE SET acm_get_acc_logical_domains_req
    RECORD acm_get_acc_logical_domains_req(
      1 write_mode_ind = i2
      1 concept = i4
    )
    FREE SET acm_get_acc_logical_domains_rep
    RECORD acm_get_acc_logical_domains_rep(
      1 logical_domain_grp_id = f8
      1 logical_domains_cnt = i4
      1 logical_domains[*]
        2 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_acc_logical_domains_req->write_mode_ind = 0
    SET acm_get_acc_logical_domains_req->concept = 3
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 DECLARE org_parse = vc
 SET org_parse = "o.organization_id = l1.organization_id "
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET org_parse = concat(org_parse," and o.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET org_parse = build(org_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM location_group lg1,
   location_group lg2,
   location l1,
   location l2,
   location l3,
   organization o,
   code_value cv,
   code_value cv2,
   code_value cv3,
   service_resource sr,
   serv_res_ext_pharm sp
  PLAN (lg1
   WHERE lg1.location_group_type_cd=fac_code_value
    AND ((lg1.root_loc_cd+ 0)=0)
    AND ((lg1.active_ind+ 0)=1))
   JOIN (lg2
   WHERE lg2.parent_loc_cd=lg1.child_loc_cd
    AND ((lg2.location_group_type_cd+ 0)=building_code_value)
    AND ((lg2.root_loc_cd+ 0)=0)
    AND ((lg2.active_ind+ 0)=1))
   JOIN (l1
   WHERE l1.location_cd=lg1.parent_loc_cd
    AND l1.active_ind=1)
   JOIN (o
   WHERE parser(org_parse))
   JOIN (l2
   WHERE l2.location_cd=lg2.parent_loc_cd
    AND l2.active_ind=1)
   JOIN (l3
   WHERE l3.location_cd=lg2.child_loc_cd
    AND l3.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg2.child_loc_cd
    AND cv.cdf_meaning IN ("AMBULATORY", "NURSEUNIT", "PHARM")
    AND cv.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=lg2.parent_loc_cd
    AND cv2.active_ind=1)
   JOIN (cv3
   WHERE cv3.code_value=lg1.parent_loc_cd
    AND cv3.active_ind=1)
   JOIN (sr
   WHERE sr.location_cd=outerjoin(lg2.child_loc_cd)
    AND sr.pharmacy_type_cd=outerjoin(inpatient_code_value)
    AND sr.activity_type_cd=outerjoin(pharm_code_value)
    AND sr.active_ind=outerjoin(1))
   JOIN (sp
   WHERE sp.service_resource_cd=outerjoin(sr.service_resource_cd))
  ORDER BY lg1.parent_loc_cd, lg2.parent_loc_cd, lg2.child_loc_cd
  HEAD REPORT
   fcnt = 0, flcnt = 0, stat = alterlist(reply->facilities,10)
  HEAD lg1.parent_loc_cd
   fcnt = (fcnt+ 1), flcnt = (flcnt+ 1)
   IF (flcnt > 10)
    stat = alterlist(reply->facilities,(fcnt+ 10)), flcnt = 1
   ENDIF
   reply->facilities[fcnt].code_value = lg1.parent_loc_cd, reply->facilities[fcnt].display = cv3
   .display, reply->facilities[fcnt].description = cv3.description,
   bcnt = 0, blcnt = 0, stat = alterlist(reply->facilities[fcnt].buildings,10)
  HEAD lg2.parent_loc_cd
   bcnt = (bcnt+ 1), blcnt = (blcnt+ 1)
   IF (blcnt > 10)
    stat = alterlist(reply->facilities[fcnt].buildings,(bcnt+ 10)), blcnt = 1
   ENDIF
   reply->facilities[fcnt].buildings[bcnt].code_value = lg2.parent_loc_cd, reply->facilities[fcnt].
   buildings[bcnt].display = cv2.display, reply->facilities[fcnt].buildings[bcnt].description = cv2
   .description,
   pcnt = 0, plcnt = 0, ncnt = 0,
   nlcnt = 0, stat = alterlist(reply->facilities[fcnt].buildings[bcnt].nursing_units,10), stat =
   alterlist(reply->facilities[fcnt].buildings[bcnt].pharmacies,10)
  HEAD lg2.child_loc_cd
   IF (cv.cdf_meaning="PHARM"
    AND sp.floorstock_ind=0)
    pcnt = (pcnt+ 1), plcnt = (plcnt+ 1)
    IF (plcnt > 10)
     stat = alterlist(reply->facilities[fcnt].buildings[bcnt].pharmacies,(pcnt+ 10)), plcnt = 1
    ENDIF
    reply->facilities[fcnt].buildings[bcnt].pharmacies[pcnt].code_value = lg2.child_loc_cd, reply->
    facilities[fcnt].buildings[bcnt].pharmacies[pcnt].display = cv.display, reply->facilities[fcnt].
    buildings[bcnt].pharmacies[pcnt].description = cv.description
   ELSEIF (((cv.cdf_meaning IN ("AMBULATORY", "NURSEUNIT")) OR (cv.cdf_meaning="PHARM"
    AND sp.floorstock_ind=1)) )
    ncnt = (ncnt+ 1), nlcnt = (nlcnt+ 1)
    IF (nlcnt > 10)
     stat = alterlist(reply->facilities[fcnt].buildings[bcnt].nursing_units,(ncnt+ 10)), nlcnt = 1
    ENDIF
    reply->facilities[fcnt].buildings[bcnt].nursing_units[ncnt].code_value = lg2.child_loc_cd, reply
    ->facilities[fcnt].buildings[bcnt].nursing_units[ncnt].display = cv.display, reply->facilities[
    fcnt].buildings[bcnt].nursing_units[ncnt].description = cv.description
   ENDIF
  FOOT  lg2.parent_loc_cd
   stat = alterlist(reply->facilities[fcnt].buildings[bcnt].pharmacies,pcnt), stat = alterlist(reply
    ->facilities[fcnt].buildings[bcnt].nursing_units,ncnt)
  FOOT  lg1.parent_loc_cd
   stat = alterlist(reply->facilities[fcnt].buildings,bcnt)
  FOOT REPORT
   stat = alterlist(reply->facilities,fcnt)
  WITH nocounter
 ;end select
#exit_script
 IF (fcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
