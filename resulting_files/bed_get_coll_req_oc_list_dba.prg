CREATE PROGRAM bed_get_coll_req_oc_list:dba
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
      2 primary_mnemonic = c100
      2 ancillary_mnemonic = c100
      2 slist[*]
        3 specimen_type_cd = f8
        3 specimen_type_display = c40
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
     2 slist[*]
       3 specimen_type_cd = f8
       3 specimen_type_display = c40
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
   FROM order_catalog oc,
    orc_resource_list orl,
    code_value cv
   PLAN (oc
    WHERE parser(oc_parse)
     AND oc.resource_route_lvl=1)
    JOIN (orl
    WHERE orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
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
  SELECT INTO "NL:"
   FROM order_catalog oc,
    profile_task_r ptr,
    assay_resource_list asl,
    code_value cv
   PLAN (oc
    WHERE parser(oc_parse)
     AND oc.resource_route_lvl=2)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (asl
    WHERE asl.task_assay_cd=ptr.task_assay_cd
     AND asl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=asl.service_resource_cd
     AND cv.active_ind=1)
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
 ELSEIF ((request->activity_type="MICROBIOLOGY"))
  SELECT INTO "NL:"
   FROM order_catalog oc,
    orc_resource_list orl,
    order_catalog_synonym ocs,
    code_value cv
   PLAN (oc
    WHERE (oc.activity_type_cd=request->activity_cd)
     AND oc.active_ind=1
     AND oc.resource_route_lvl=1)
    JOIN (orl
    WHERE orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
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
  SELECT INTO "NL:"
   FROM order_catalog oc,
    profile_task_r ptr,
    assay_resource_list asl,
    order_catalog_synonym ocs,
    code_value cv
   PLAN (oc
    WHERE (oc.activity_type_cd=request->activity_cd)
     AND oc.active_ind=1
     AND oc.resource_route_lvl=2)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (asl
    WHERE asl.task_assay_cd=ptr.task_assay_cd
     AND asl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=asl.service_resource_cd
     AND cv.active_ind=1)
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
   FROM order_catalog oc,
    orc_resource_list orl,
    code_value cv
   PLAN (oc
    WHERE parser(oc_parse)
     AND oc.resource_route_lvl=1)
    JOIN (orl
    WHERE orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
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
  SELECT INTO "NL:"
   FROM order_catalog oc,
    profile_task_r ptr,
    assay_resource_list asl,
    code_value cv
   PLAN (oc
    WHERE parser(oc_parse)
     AND oc.resource_route_lvl=2)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (asl
    WHERE asl.task_assay_cd=ptr.task_assay_cd
     AND asl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=asl.service_resource_cd
     AND cv.active_ind=1)
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
 ELSEIF ((request->activity_type="BB"))
  SELECT INTO "NL:"
   FROM order_catalog oc,
    orc_resource_list orl,
    code_value cv
   PLAN (oc
    WHERE (oc.activity_type_cd=request->activity_cd)
     AND oc.active_ind=1
     AND oc.resource_route_lvl=1)
    JOIN (orl
    WHERE orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
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
  SELECT INTO "NL:"
   FROM order_catalog oc,
    profile_task_r ptr,
    assay_resource_list asl,
    code_value cv
   PLAN (oc
    WHERE (oc.activity_type_cd=request->activity_cd)
     AND oc.active_ind=1
     AND oc.resource_route_lvl=2)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (asl
    WHERE asl.task_assay_cd=ptr.task_assay_cd
     AND asl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=asl.service_resource_cd
     AND cv.active_ind=1)
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
 ELSEIF ((request->activity_type="HLA"))
  DECLARE oc_parse = vc
  SET oc_parse = concat("oc.catalog_type_cd = glb_catalog_type_cd",
   " and oc.activity_type_cd	= hla_activity_type_cd"," and oc.active_ind = 1")
  IF ((request->return_all_subtypes_ind != 1))
   SET oc_parse = concat(oc_parse," and oc.activity_subtype_cd	= request->activity_cd")
  ENDIF
  CALL echo(oc_parse)
  SELECT INTO "NL:"
   FROM order_catalog oc,
    orc_resource_list orl,
    code_value cv
   PLAN (oc
    WHERE parser(oc_parse)
     AND oc.resource_route_lvl=1)
    JOIN (orl
    WHERE orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=orl.service_resource_cd
     AND cv.active_ind=1)
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
  SELECT INTO "NL:"
   FROM order_catalog oc,
    profile_task_r ptr,
    assay_resource_list asl,
    code_value cv
   PLAN (oc
    WHERE parser(oc_parse)
     AND oc.resource_route_lvl=2)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (asl
    WHERE asl.task_assay_cd=ptr.task_assay_cd
     AND asl.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=asl.service_resource_cd
     AND cv.active_ind=1)
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
 ELSEIF ((request->activity_type="HLX"))
  DECLARE hlx_code = f8 WITH protect, noconstant(0.0)
  DECLARE cyg_code = f8 WITH protect, noconstant(0.0)
  DECLARE mdx_code = f8 WITH protect, noconstant(0.0)
  DECLARE spc_code = f8 WITH protect, noconstant(0.0)
  SET stat = uar_get_meaning_by_codeset(106,"HLX",1,hlx_code)
  SET stat = uar_get_meaning_by_codeset(106,"CYG",1,cyg_code)
  SET stat = uar_get_meaning_by_codeset(5801,"HLX_MDX",1,mdx_code)
  SET stat = uar_get_meaning_by_codeset(5801,"HLX_SPECIMEN",1,spc_code)
  CALL echo(build("HLX_code [",hlx_code,"]"))
  CALL echo(build("CYG_code [",cyg_code,"]"))
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
      AND oc.orderable_type_flag IN (0, 5, 6)
      AND oc.active_ind=1)))
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
      AND oc.orderable_type_flag IN (0, 5, 6)
      AND oc.active_ind=1)))
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
   CALL echo("Retrieving for CYTOGENETICS")
   SELECT INTO "nl:"
    FROM order_catalog oc
    WHERE oc.catalog_type_cd=glb_catalog_type_cd
     AND oc.activity_type_cd=cyg_code
     AND oc.orderable_type_flag IN (0, 5, 6)
     AND oc.active_ind=1
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
 IF (oc_cnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = oc_cnt),
    procedure_specimen_type pst,
    code_value cv
   PLAN (d)
    JOIN (pst
    WHERE (pst.catalog_cd=temp->olist[d.seq].catalog_cd))
    JOIN (cv
    WHERE cv.code_set=2052
     AND cv.code_value=pst.specimen_type_cd)
   ORDER BY d.seq
   HEAD d.seq
    sp_cnt = 0
   DETAIL
    sp_cnt = (sp_cnt+ 1), stat = alterlist(temp->olist[d.seq].slist,sp_cnt), temp->olist[d.seq].
    slist[sp_cnt].specimen_type_cd = pst.specimen_type_cd,
    temp->olist[d.seq].slist[sp_cnt].specimen_type_display = cv.display
   WITH nocounter
  ;end select
 ENDIF
 IF (oc_cnt > 0)
  SET reply_cnt = 0
  SET tot_sr_req = size(request->service_resources,5)
  FOR (o = 1 TO oc_cnt)
    SET stat = alterlist(sr->srlist,10)
    SET alterlist_srcnt = 0
    SET srcnt = 0
    IF ((temp->olist[o].resource_route_lvl=1))
     SELECT INTO "NL:"
      FROM orc_resource_list orl,
       code_value cv
      PLAN (orl
       WHERE (orl.catalog_cd=temp->olist[o].catalog_cd))
       JOIN (cv
       WHERE cv.code_value=orl.service_resource_cd
        AND cv.active_ind=1)
      DETAIL
       alterlist_srcnt = (alterlist_srcnt+ 1)
       IF (alterlist_srcnt > 10)
        stat = alterlist(sr->srlist,(srcnt+ 10)), alterlist_srcnt = 1
       ENDIF
       srcnt = (srcnt+ 1), sr->srlist[srcnt].code_value = orl.service_resource_cd
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
       alterlist_srcnt = (alterlist_srcnt+ 1)
       IF (alterlist_srcnt > 10)
        stat = alterlist(sr->srlist,(srcnt+ 10)), alterlist_srcnt = 1
       ENDIF
       srcnt = (srcnt+ 1), sr->srlist[srcnt].code_value = asl.service_resource_cd
      WITH nocounter
     ;end select
    ENDIF
    SET stat = alterlist(sr->srlist,srcnt)
    SET sr_found = 0
    FOR (s = 1 TO srcnt)
     FOR (x = 1 TO tot_sr_req)
       IF ((sr->srlist[s].code_value=request->service_resources[x].code_value))
        SET sr_found = 1
        SET x = (tot_sr_req+ 1)
       ENDIF
     ENDFOR
     IF (sr_found=1)
      SET s = (srcnt+ 1)
     ENDIF
    ENDFOR
    IF (((sr_found) OR ((temp->olist[o].resource_route_lvl=0))) )
     SET reply_cnt = (reply_cnt+ 1)
     SET stat = alterlist(reply->olist,reply_cnt)
     SET reply->olist[reply_cnt].catalog_cd = temp->olist[o].catalog_cd
     SET reply->olist[reply_cnt].primary_mnemonic = temp->olist[o].primary_mnemonic
     SET reply->olist[reply_cnt].ancillary_mnemonic = temp->olist[o].ancillary_mnemonic
     SET sp_cnt = size(temp->olist[o].slist,5)
     SET stat = alterlist(reply->olist[reply_cnt].slist,sp_cnt)
     FOR (s = 1 TO sp_cnt)
      SET reply->olist[reply_cnt].slist[s].specimen_type_cd = temp->olist[o].slist[s].
      specimen_type_cd
      SET reply->olist[reply_cnt].slist[s].specimen_type_display = temp->olist[o].slist[s].
      specimen_type_display
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
