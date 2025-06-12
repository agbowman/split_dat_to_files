CREATE PROGRAM bed_get_coll_incomplete_ords:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 activity_type = c12
    1 activity_cd = f8
    1 service_resources[*]
      2 code_value = f8
    1 return_all_subtypes_ind = i2
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 olist[*]
      2 catalog_cd = f8
      2 primary_mnemonic = vc
      2 ancillary_mnemonic = vc
      2 slist[*]
        3 specimen_type_cd = f8
        3 specimen_type_disp = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 olist[*]
     2 catalog_cd = f8
     2 primary_mnemonic = c100
     2 ancillary_mnemonic = c100
     2 resource_route_lvl = i4
     2 incomplete_ord_ind = i2
     2 slist[*]
       3 specimen_type_cd = f8
       3 specimen_type_disp = c40
       3 incomplete_spec_type_ind = i2
 )
 RECORD sr(
   1 srlist[*]
     2 code_value = f8
 )
 SET reply->status_data.status = "F"
 SET ancillary_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.cdf_meaning="ANCILLARY"
   AND cv.code_set=6011
  DETAIL
   ancillary_cd = cv.code_value
  WITH nocounter
 ;end select
 SET glb_catalog_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.cdf_meaning="GENERAL LAB"
   AND cv.code_set=6000
   AND cv.active_ind=1
  DETAIL
   glb_catalog_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET glb_activity_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.cdf_meaning="GLB"
   AND cv.code_set=106
   AND cv.active_ind=1
  DETAIL
   glb_activity_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET ap_activity_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.cdf_meaning="AP"
   AND cv.code_set=106
   AND cv.active_ind=1
  DETAIL
   ap_activity_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET hla_activity_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.cdf_meaning="HLA"
   AND cv.code_set=106
   AND cv.active_ind=1
  DETAIL
   hla_activity_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->olist,50)
 SET alterlist_cnt = 0
 SET oc_cnt = 0
 IF ((request->activity_type="GLB"))
  DECLARE oc_parse = vc
  SET oc_parse = concat("oc.catalog_type_cd = glb_catalog_type_cd",
   " and oc.activity_type_cd	= glb_activity_type_cd"," and oc.active_ind = 1")
  IF ((request->return_all_subtypes_ind != 1))
   SET oc_parse = concat(oc_parse," and oc.activity_subtype_cd	= request->activity_cd")
  ENDIF
  CALL echo(oc_parse)
  SELECT INTO "NL:"
   FROM order_catalog oc
   WHERE parser(oc_parse)
   ORDER BY oc.catalog_cd
   DETAIL
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(temp->olist,(oc_cnt+ 50)), alterlist_cnt = 1
    ENDIF
    oc_cnt = (oc_cnt+ 1), temp->olist[oc_cnt].catalog_cd = oc.catalog_cd, temp->olist[oc_cnt].
    primary_mnemonic = oc.primary_mnemonic,
    temp->olist[oc_cnt].resource_route_lvl = oc.resource_route_lvl
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="MICROBIOLOGY"))
  SELECT INTO "NL:"
   FROM order_catalog oc,
    order_catalog_synonym ocs
   PLAN (oc
    WHERE (oc.activity_type_cd=request->activity_cd)
     AND oc.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=outerjoin(oc.catalog_cd)
     AND ocs.mnemonic_type_cd=outerjoin(ancillary_cd))
   ORDER BY oc.catalog_cd, ocs.catalog_cd
   HEAD oc.catalog_cd
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(temp->olist,(oc_cnt+ 50)), alterlist_cnt = 1
    ENDIF
    oc_cnt = (oc_cnt+ 1), temp->olist[oc_cnt].catalog_cd = oc.catalog_cd, temp->olist[oc_cnt].
    primary_mnemonic = oc.primary_mnemonic,
    temp->olist[oc_cnt].resource_route_lvl = oc.resource_route_lvl
   HEAD ocs.catalog_cd
    temp->olist[oc_cnt].ancillary_mnemonic = ocs.mnemonic
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="AP"))
  DECLARE oc_parse = vc
  SET oc_parse = concat("oc.catalog_type_cd = glb_catalog_type_cd",
   " and oc.activity_type_cd	= ap_activity_type_cd"," and oc.active_ind = 1")
  IF ((request->return_all_subtypes_ind != 1))
   SET oc_parse = concat(oc_parse," and oc.activity_subtype_cd	= request->activity_cd")
  ENDIF
  CALL echo(oc_parse)
  SELECT INTO "NL:"
   FROM order_catalog oc
   WHERE parser(oc_parse)
   ORDER BY oc.catalog_cd
   DETAIL
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(temp->olist,(oc_cnt+ 50)), alterlist_cnt = 1
    ENDIF
    oc_cnt = (oc_cnt+ 1), temp->olist[oc_cnt].catalog_cd = oc.catalog_cd, temp->olist[oc_cnt].
    primary_mnemonic = oc.primary_mnemonic,
    temp->olist[oc_cnt].resource_route_lvl = oc.resource_route_lvl
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="BB"))
  SELECT INTO "NL:"
   FROM order_catalog oc
   WHERE (oc.activity_type_cd=request->activity_cd)
    AND oc.active_ind=1
   ORDER BY oc.catalog_cd
   DETAIL
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(temp->olist,(oc_cnt+ 50)), alterlist_cnt = 1
    ENDIF
    oc_cnt = (oc_cnt+ 1), temp->olist[oc_cnt].catalog_cd = oc.catalog_cd, temp->olist[oc_cnt].
    primary_mnemonic = oc.primary_mnemonic,
    temp->olist[oc_cnt].resource_route_lvl = oc.resource_route_lvl
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="HLA"))
  DECLARE oc_parse = vc
  SET oc_parse = concat("oc.catalog_type_cd = glb_catalog_type_cd",
   " and oc.activity_type_cd	= hla_activity_type_cd"," and oc.active_ind = 1")
  IF ((request->return_all_subtypes_ind != 1))
   SET oc_parse = concat(oc_parse," and oc.activity_subtype_cd	= request->activity_cd")
  ENDIF
  CALL echo(oc_parse)
  SELECT INTO "NL:"
   FROM order_catalog oc
   WHERE parser(oc_parse)
   ORDER BY oc.catalog_cd
   DETAIL
    alterlist_cnt = (alterlist_cnt+ 1)
    IF (alterlist_cnt > 50)
     stat = alterlist(temp->olist,(oc_cnt+ 50)), alterlist_cnt = 1
    ENDIF
    oc_cnt = (oc_cnt+ 1), temp->olist[oc_cnt].catalog_cd = oc.catalog_cd, temp->olist[oc_cnt].
    primary_mnemonic = oc.primary_mnemonic,
    temp->olist[oc_cnt].resource_route_lvl = oc.resource_route_lvl
   WITH nocounter
  ;end select
 ELSEIF ((request->activity_type="HLX"))
  DECLARE hlx_code = f8 WITH protect, noconstant(0.0)
  DECLARE cyg_code = f8 WITH protect, noconstant(0.0)
  DECLARE mdx_code = f8 WITH protect, noconstant(0.0)
  DECLARE spc_code = f8 WITH protect, noconstant(0.0)
  SET stat = uar_get_meaning_by_codeset(106,"HLX",1,hlx_code)
  SET stat = uar_get_meaning_by_codeset(106,"CYG",1,cyg_code)
  SET stat = uar_get_meaning_by_codeset(5801,"HLX_MDX",1,mdx_code)
  SET stat = uar_get_meaning_by_codeset(5801,"HLX_SPECIMEN",1,spc_code)
  IF ((request->return_all_subtypes_ind=1))
   SELECT INTO "nl:"
    catalog_cd = oc.catalog_cd, primary_mnemonic = oc.primary_mnemonic, resource_route_lvl = oc
    .resource_route_lvl
    FROM order_catalog oc,
     orc_resource_list orl,
     code_value cv
    WHERE oc.catalog_type_cd=glb_catalog_type_cd
     AND oc.activity_type_cd=hlx_code
     AND oc.activity_subtype_cd IN (mdx_code, spc_code)
     AND oc.resource_route_lvl=1
     AND oc.orderable_type_flag=0
     AND orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1
     AND cv.code_value=orl.service_resource_cd
     AND ((cv.active_ind=1) UNION (
    (SELECT
     catalog_cd = oc.catalog_cd, primary_mnemonic = oc.primary_mnemonic, resource_route_lvl = oc
     .resource_route_lvl
     FROM order_catalog oc
     WHERE oc.catalog_type_cd=glb_catalog_type_cd
      AND oc.activity_type_cd IN (hlx_code, cyg_code)
      AND oc.orderable_type_flag=6)))
    ORDER BY catalog_cd
    HEAD catalog_cd
     alterlist_cnt = (alterlist_cnt+ 1)
     IF (alterlist_cnt > 50)
      stat = alterlist(temp->olist,(oc_cnt+ 50)), alterlist_cnt = 1
     ENDIF
     oc_cnt = (oc_cnt+ 1), temp->olist[oc_cnt].catalog_cd = catalog_cd, temp->olist[oc_cnt].
     primary_mnemonic = primary_mnemonic,
     temp->olist[oc_cnt].resource_route_lvl = resource_route_lvl
    WITH nocounter, rdbunion
   ;end select
  ELSEIF ((request->activity_cd=hlx_code))
   SELECT INTO "nl:"
    catalog_cd = oc.catalog_cd, primary_mnemonic = oc.primary_mnemonic, resource_route_lvl = oc
    .resource_route_lvl
    FROM order_catalog oc,
     orc_resource_list orl,
     code_value cv
    WHERE oc.catalog_type_cd=glb_catalog_type_cd
     AND oc.activity_type_cd=hlx_code
     AND oc.activity_subtype_cd IN (mdx_code, spc_code)
     AND oc.resource_route_lvl=1
     AND oc.orderable_type_flag=0
     AND orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1
     AND cv.code_value=orl.service_resource_cd
     AND ((cv.active_ind=1) UNION (
    (SELECT
     catalog_cd = oc.catalog_cd, primary_mnemonic = oc.primary_mnemonic, resource_route_lvl = oc
     .resource_route_lvl
     FROM order_catalog oc
     WHERE oc.catalog_type_cd=glb_catalog_type_cd
      AND oc.activity_type_cd=hlx_code
      AND oc.orderable_type_flag=6)))
    ORDER BY catalog_cd
    HEAD catalog_cd
     alterlist_cnt = (alterlist_cnt+ 1)
     IF (alterlist_cnt > 50)
      stat = alterlist(temp->olist,(oc_cnt+ 50)), alterlist_cnt = 1
     ENDIF
     oc_cnt = (oc_cnt+ 1), temp->olist[oc_cnt].catalog_cd = catalog_cd, temp->olist[oc_cnt].
     primary_mnemonic = primary_mnemonic,
     temp->olist[oc_cnt].resource_route_lvl = resource_route_lvl
    WITH nocounter, rdbunion
   ;end select
  ELSEIF ((request->activity_cd=cyg_code))
   SELECT INTO "nl:"
    FROM order_catalog oc
    WHERE oc.catalog_type_cd=glb_catalog_type_cd
     AND oc.activity_type_cd=cyg_code
     AND oc.orderable_type_flag=6
    ORDER BY oc.catalog_cd
    HEAD oc.catalog_cd
     alterlist_cnt = (alterlist_cnt+ 1)
     IF (alterlist_cnt > 50)
      stat = alterlist(temp->olist,(oc_cnt+ 50)), alterlist_cnt = 1
     ENDIF
     oc_cnt = (oc_cnt+ 1), temp->olist[oc_cnt].catalog_cd = oc.catalog_cd, temp->olist[oc_cnt].
     primary_mnemonic = oc.primary_mnemonic,
     temp->olist[oc_cnt].resource_route_lvl = oc.resource_route_lvl
    WITH nocounter
   ;end select
  ELSE
   GO TO exit_script
  ENDIF
 ELSE
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp->olist,oc_cnt)
 CALL echorecord(temp)
 CALL echo(build("oc_cnt:",oc_cnt))
 IF (oc_cnt=0)
  GO TO exit_script
 ENDIF
 SET tot_sr_req = size(request->service_resources,5)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = oc_cnt),
   procedure_specimen_type pst,
   code_value cv
  PLAN (d)
   JOIN (pst
   WHERE (pst.catalog_cd=temp->olist[d.seq].catalog_cd))
   JOIN (cv
   WHERE cv.code_set=2052
    AND cv.code_value=pst.specimen_type_cd
    AND cv.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   sp_cnt = 0
  DETAIL
   sp_cnt = (sp_cnt+ 1), stat = alterlist(temp->olist[d.seq].slist,sp_cnt), temp->olist[d.seq].slist[
   sp_cnt].specimen_type_cd = pst.specimen_type_cd,
   temp->olist[d.seq].slist[sp_cnt].specimen_type_disp = cv.display
  WITH nocounter
 ;end select
 FOR (o = 1 TO oc_cnt)
   SET temp->olist[o].incomplete_ord_ind = 0
   SET stat = alterlist(sr->srlist,10)
   SET alterlist_sr_cnt = 0
   SET sr_cnt = 0
   IF ((temp->olist[o].resource_route_lvl=1))
    SELECT INTO "NL:"
     FROM orc_resource_list orl,
      code_value cv
     PLAN (orl
      WHERE (orl.catalog_cd=temp->olist[o].catalog_cd)
       AND orl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=orl.service_resource_cd
       AND cv.active_ind=1)
     DETAIL
      sr_found = 0
      FOR (x = 1 TO tot_sr_req)
        IF ((orl.service_resource_cd=request->service_resources[x].code_value))
         sr_found = 1, x = (tot_sr_req+ 1)
        ENDIF
      ENDFOR
      IF (sr_found=1)
       alterlist_sr_cnt = (alterlist_sr_cnt+ 1)
       IF (alterlist_sr_cnt > 10)
        stat = alterlist(sr->srlist,(sr_cnt+ 10)), alterlist_sr_cnt = 1
       ENDIF
       sr_cnt = (sr_cnt+ 1), sr->srlist[sr_cnt].code_value = orl.service_resource_cd
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF ((temp->olist[o].resource_route_lvl=2))
    SELECT INTO "NL:"
     FROM profile_task_r ptr,
      assay_resource_list asl,
      code_value cv
     PLAN (ptr
      WHERE (ptr.catalog_cd=temp->olist[o].catalog_cd)
       AND ptr.active_ind=1)
      JOIN (asl
      WHERE asl.task_assay_cd=ptr.task_assay_cd
       AND asl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=asl.service_resource_cd
       AND cv.active_ind=1)
     DETAIL
      sr_found = 0
      FOR (x = 1 TO tot_sr_req)
        IF ((asl.service_resource_cd=request->service_resources[x].code_value))
         sr_found = 1, x = (tot_sr_req+ 1)
        ENDIF
      ENDFOR
      IF (sr_found=1)
       alterlist_sr_cnt = (alterlist_sr_cnt+ 1)
       IF (alterlist_sr_cnt > 10)
        stat = alterlist(sr->srlist,(sr_cnt+ 10)), alterlist_sr_cnt = 1
       ENDIF
       sr_cnt = (sr_cnt+ 1), sr->srlist[sr_cnt].code_value = asl.service_resource_cd
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   SET stat = alterlist(sr->srlist,sr_cnt)
   IF ((request->activity_type="HLX"))
    IF (((sr_cnt > 0) OR ((temp->olist[o].resource_route_lvl=0))) )
     SET sr_cnt = (sr_cnt+ 1)
     SET stat = alterlist(sr->srlist,sr_cnt)
     SET sr->srlist[sr_cnt].code_value = 0.0
     SET sp_cnt = 0
     SET sp_cnt = size(temp->olist[o].slist,5)
     IF (sp_cnt=0)
      SET temp->olist[o].incomplete_ord_ind = 1
     ELSE
      FOR (s = 1 TO sp_cnt)
       SET temp->olist[o].slist[s].incomplete_spec_type_ind = 0
       FOR (r = 1 TO sr_cnt)
        SELECT INTO "NL:"
         FROM collection_info_qualifiers ciq
         WHERE (ciq.catalog_cd=temp->olist[o].catalog_cd)
          AND (ciq.specimen_type_cd=temp->olist[o].slist[s].specimen_type_cd)
          AND (ciq.service_resource_cd=sr->srlist[r].code_value)
         WITH nocounter
        ;end select
        IF (curqual=0)
         SET temp->olist[o].slist[s].incomplete_spec_type_ind = 1
         SET temp->olist[o].incomplete_ord_ind = 1
         SET r = (sr_cnt+ 1)
        ENDIF
       ENDFOR
      ENDFOR
     ENDIF
    ENDIF
   ELSEIF (sr_cnt > 0)
    SET sr_cnt = (sr_cnt+ 1)
    SET stat = alterlist(sr->srlist,sr_cnt)
    SET sr->srlist[sr_cnt].code_value = 0.0
    SET sp_cnt = 0
    SET sp_cnt = size(temp->olist[o].slist,5)
    IF (sp_cnt=0)
     SET temp->olist[o].incomplete_ord_ind = 1
    ELSE
     FOR (s = 1 TO sp_cnt)
      SET temp->olist[o].slist[s].incomplete_spec_type_ind = 0
      FOR (r = 1 TO sr_cnt)
       SELECT INTO "NL:"
        FROM collection_info_qualifiers ciq
        WHERE (ciq.catalog_cd=temp->olist[o].catalog_cd)
         AND (ciq.specimen_type_cd=temp->olist[o].slist[s].specimen_type_cd)
         AND (ciq.service_resource_cd=sr->srlist[r].code_value)
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET temp->olist[o].slist[s].incomplete_spec_type_ind = 1
        SET temp->olist[o].incomplete_ord_ind = 1
        SET r = (sr_cnt+ 1)
       ENDIF
      ENDFOR
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 SET reply_ord_cnt = 0
 FOR (o = 1 TO oc_cnt)
   IF ((temp->olist[o].incomplete_ord_ind=1))
    SET reply_ord_cnt = (reply_ord_cnt+ 1)
    SET stat = alterlist(reply->olist,reply_ord_cnt)
    SET reply->olist[reply_ord_cnt].catalog_cd = temp->olist[o].catalog_cd
    SET reply->olist[reply_ord_cnt].primary_mnemonic = temp->olist[o].primary_mnemonic
    SET reply->olist[reply_ord_cnt].ancillary_mnemonic = temp->olist[o].ancillary_mnemonic
    SET sp_cnt = size(temp->olist[o].slist,5)
    SET reply_spec_cnt = 0
    FOR (s = 1 TO sp_cnt)
      IF ((temp->olist[o].slist[s].incomplete_spec_type_ind=1))
       SET reply_spec_cnt = (reply_spec_cnt+ 1)
       SET stat = alterlist(reply->olist[reply_ord_cnt].slist,reply_spec_cnt)
       SET reply->olist[reply_ord_cnt].slist[reply_spec_cnt].specimen_type_cd = temp->olist[o].slist[
       s].specimen_type_cd
       SET reply->olist[reply_ord_cnt].slist[reply_spec_cnt].specimen_type_disp = temp->olist[o].
       slist[s].specimen_type_disp
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
