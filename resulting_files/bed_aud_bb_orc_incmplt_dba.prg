CREATE PROGRAM bed_aud_bb_orc_incmplt:dba
 DECLARE genlab = f8 WITH public, noconstant(0.0)
 DECLARE bbat_cd = f8 WITH protect, noconstant(0.0)
 DECLARE apat_cd = f8 WITH protect, noconstant(0.0)
 DECLARE glbat_cd = f8 WITH protect, noconstant(0.0)
 DECLARE apspecast_cd = f8 WITH protect, noconstant(0.0)
 DECLARE high_volume_cnt = i4 WITH protect, noconstant(0)
 DECLARE row_nbr = i4 WITH protect, noconstant(0)
 DECLARE no_dta_cnt = i4 WITH protect, noconstant(0)
 DECLARE no_routing_cnt = i4 WITH protect, noconstant(0)
 DECLARE no_coll_req_cnt = i4 WITH protect, noconstant(0)
 DECLARE no_proc_type_cnt = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
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
      2 statistic_meaning = vc
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
   1 o_cnt = i4
   1 olist[*]
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 activity_subtype_cd = f8
     2 activity_subtype_disp = vc
     2 no_dta_ind = i2
     2 no_subact_ind = i2
     2 no_routing_ind = i2
     2 no_coll_req_ind = i2
     2 no_proc_type_ind = i2
     2 resource_route_lvl = i2
 )
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="GENERAL LAB"
    AND cv.active_ind=1)
  DETAIL
   genlab = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="BB"
    AND cv.active_ind=1)
  DETAIL
   bbat_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="AP"
    AND cv.active_ind=1)
  DETAIL
   apat_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="GLB"
    AND cv.active_ind=1)
  DETAIL
   glbat_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=5801
    AND cv.cdf_meaning="APSPECIMEN"
    AND cv.active_ind=1)
  DETAIL
   apspecast_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  hv_cnt = count(*)
  FROM order_catalog oc,
   code_value cv1,
   code_value cv2,
   code_value cv3
  PLAN (oc
   WHERE oc.catalog_type_cd=genlab
    AND oc.activity_type_cd=bbat_cd
    AND oc.active_ind=1
    AND ((oc.concept_cki=null) OR (oc.concept_cki != "CERNER!ACt72QERS//WF4B0CqIGfQ")) )
   JOIN (cv1
   WHERE cv1.code_value=oc.catalog_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=oc.activity_type_cd)
   JOIN (cv3
   WHERE cv3.code_value=oc.activity_subtype_cd)
  DETAIL
   high_volume_cnt = hv_cnt
  WITH nocounter
 ;end select
 CALL echo(high_volume_cnt)
 IF ((request->skip_volume_check_ind=0))
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET temp->o_cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog o,
   code_value cv1,
   code_value cv2,
   code_value cv3
  PLAN (o
   WHERE o.catalog_type_cd=genlab
    AND o.activity_type_cd=bbat_cd
    AND o.active_ind=1
    AND ((o.concept_cki=null) OR (o.concept_cki != "CERNER!ACt72QERS//WF4B0CqIGfQ")) )
   JOIN (cv1
   WHERE cv1.code_value=o.catalog_type_cd)
   JOIN (cv2
   WHERE cv2.code_value=o.activity_type_cd)
   JOIN (cv3
   WHERE cv3.code_value=o.activity_subtype_cd)
  ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
  HEAD REPORT
   o_cnt = 0
  DETAIL
   o_cnt = (o_cnt+ 1), temp->o_cnt = o_cnt, stat = alterlist(temp->olist,o_cnt),
   temp->olist[o_cnt].catalog_cd = o.catalog_cd, temp->olist[o_cnt].primary_mnemonic = o
   .primary_mnemonic, temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd,
   temp->olist[o_cnt].catalog_type_disp = cv1.display, temp->olist[o_cnt].activity_type_cd = o
   .activity_type_cd, temp->olist[o_cnt].activity_type_disp = cv2.display,
   temp->olist[o_cnt].no_subact_ind = 0, temp->olist[o_cnt].resource_route_lvl = o.resource_route_lvl
   IF (o.activity_subtype_cd > 0)
    temp->olist[o_cnt].activity_subtype_cd = o.activity_subtype_cd, temp->olist[o_cnt].
    activity_subtype_disp = cv3.display
   ELSE
    IF (o.activity_type_cd IN (apat_cd, glbat_cd))
     temp->olist[o_cnt].no_subact_ind = 1
    ENDIF
   ENDIF
   temp->olist[o_cnt].no_dta_ind = 1, temp->olist[o_cnt].no_routing_ind = 1, temp->olist[o_cnt].
   no_proc_type_ind = 1
   IF (o.activity_type_cd=apat_cd
    AND o.activity_subtype_cd != apspecast_cd)
    temp->olist[o_cnt].no_coll_req_ind = 0
   ELSE
    temp->olist[o_cnt].no_coll_req_ind = 1
   ENDIF
   IF (((o.orderable_type_flag=2) OR (o.orderable_type_flag=6)) )
    temp->olist[o_cnt].no_dta_ind = 0, temp->olist[o_cnt].no_routing_ind = 0, temp->olist[o_cnt].
    no_coll_req_ind = 0,
    temp->olist[o_cnt].no_proc_type_ind = 0
   ENDIF
   IF (o.bill_only_ind=1)
    temp->olist[o_cnt].no_dta_ind = 0, temp->olist[o_cnt].no_routing_ind = 0, temp->olist[o_cnt].
    no_coll_req_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Activity Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Primary Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "No Assays"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "No Work Routing"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Incomplete Collection Requirements"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "No Procedure Type"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Catalog Cd"
 SET reply->collist[7].data_type = 2
 SET reply->collist[7].hide_ind = 1
 IF ((temp->o_cnt=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   profile_task_r ptr,
   discrete_task_assay dta
  PLAN (d)
   JOIN (ptr
   WHERE (ptr.catalog_cd=temp->olist[d.seq].catalog_cd)
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.active_ind=1)
  DETAIL
   temp->olist[d.seq].no_dta_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   orc_resource_list orl,
   code_value cv
  PLAN (d
   WHERE (temp->olist[d.seq].resource_route_lvl < 2))
   JOIN (orl
   WHERE (orl.catalog_cd=temp->olist[d.seq].catalog_cd)
    AND orl.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=orl.service_resource_cd
    AND cv.active_ind=1)
  DETAIL
   temp->olist[d.seq].no_routing_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   profile_task_r ptr,
   assay_resource_list apr,
   code_value cv
  PLAN (d
   WHERE (temp->olist[d.seq].resource_route_lvl=2))
   JOIN (ptr
   WHERE (ptr.catalog_cd=temp->olist[d.seq].catalog_cd)
    AND ptr.active_ind=1)
   JOIN (apr
   WHERE apr.task_assay_cd=ptr.task_assay_cd
    AND apr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=apr.service_resource_cd
    AND cv.active_ind=1)
  DETAIL
   temp->olist[d.seq].no_routing_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   collection_info_qualifiers ciq1,
   collection_info_qualifiers ciq2
  PLAN (d)
   JOIN (ciq1
   WHERE (ciq1.catalog_cd=temp->olist[d.seq].catalog_cd)
    AND ciq1.specimen_type_cd > 0)
   JOIN (ciq2
   WHERE ciq2.catalog_cd=outerjoin(ciq1.catalog_cd)
    AND ciq2.specimen_type_cd=outerjoin(ciq1.specimen_type_cd)
    AND ciq2.service_resource_cd=outerjoin(0))
  ORDER BY d.seq, ciq1.catalog_cd
  HEAD ciq1.catalog_cd
   all_match = 1
  DETAIL
   IF (((ciq1.catalog_cd != ciq2.catalog_cd) OR (ciq1.specimen_type_cd != ciq2.specimen_type_cd)) )
    all_match = 0
   ENDIF
  FOOT  ciq1.catalog_cd
   IF (all_match=1)
    temp->olist[d.seq].no_coll_req_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   service_directory sd
  PLAN (d)
   JOIN (sd
   WHERE (sd.catalog_cd=temp->olist[d.seq].catalog_cd)
    AND sd.active_ind=1
    AND sd.bb_processing_cd > 0)
  DETAIL
   temp->olist[d.seq].no_proc_type_ind = 0
  WITH nocounter
 ;end select
 FOR (x = 1 TO temp->o_cnt)
   IF ((((temp->olist[x].no_dta_ind=1)) OR ((((temp->olist[x].no_routing_ind=1)) OR ((((temp->olist[x
   ].no_coll_req_ind=1)) OR ((temp->olist[x].no_proc_type_ind=1))) )) )) )
    SET row_nbr = (row_nbr+ 1)
    SET stat = alterlist(reply->rowlist,row_nbr)
    SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
    SET reply->rowlist[row_nbr].celllist[1].string_value = temp->olist[x].activity_type_disp
    SET reply->rowlist[row_nbr].celllist[2].string_value = temp->olist[x].primary_mnemonic
    SET reply->rowlist[row_nbr].celllist[7].double_value = temp->olist[x].catalog_cd
    IF ((temp->olist[x].no_dta_ind=1))
     SET no_dta_cnt = (no_dta_cnt+ 1)
     SET reply->rowlist[row_nbr].celllist[3].string_value = "X"
    ELSE
     SET reply->rowlist[row_nbr].celllist[3].string_value = " "
    ENDIF
    IF ((temp->olist[x].no_routing_ind=1))
     SET no_routing_cnt = (no_routing_cnt+ 1)
     SET reply->rowlist[row_nbr].celllist[4].string_value = "X"
    ELSE
     SET reply->rowlist[row_nbr].celllist[4].string_value = " "
    ENDIF
    IF ((temp->olist[x].no_coll_req_ind=1))
     SET no_coll_req_cnt = (no_coll_req_cnt+ 1)
     SET reply->rowlist[row_nbr].celllist[5].string_value = "X"
    ELSE
     SET reply->rowlist[row_nbr].celllist[5].string_value = " "
    ENDIF
    IF ((temp->olist[x].no_proc_type_ind=1))
     SET no_proc_type_cnt = (no_proc_type_cnt+ 1)
     SET reply->rowlist[row_nbr].celllist[6].string_value = "X"
    ELSE
     SET reply->rowlist[row_nbr].celllist[6].string_value = " "
    ENDIF
   ENDIF
 ENDFOR
 IF (no_dta_cnt=0
  AND no_routing_cnt=0
  AND no_coll_req_cnt=0
  AND no_proc_type_cnt=0)
  SET reply->run_status_flag = 1
 ELSE
  SET reply->run_status_flag = 3
 ENDIF
 SET stat = alterlist(reply->statlist,4)
 SET reply->statlist[1].total_items = row_nbr
 SET reply->statlist[1].qualifying_items = no_dta_cnt
 SET reply->statlist[1].statistic_meaning = "PATHBBORCNODTA"
 IF (no_dta_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].total_items = row_nbr
 SET reply->statlist[2].qualifying_items = no_routing_cnt
 SET reply->statlist[2].statistic_meaning = "PATHBBORCNOROUTING"
 IF (no_routing_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SET reply->statlist[3].total_items = row_nbr
 SET reply->statlist[3].qualifying_items = no_coll_req_cnt
 SET reply->statlist[3].statistic_meaning = "PATHBBORCNOCOLLREQ"
 IF (no_coll_req_cnt > 0)
  SET reply->statlist[3].status_flag = 3
 ELSE
  SET reply->statlist[3].status_flag = 1
 ENDIF
 SET reply->statlist[4].total_items = row_nbr
 SET reply->statlist[4].qualifying_items = no_proc_type_cnt
 SET reply->statlist[4].statistic_meaning = "PATHBBORCNOPROCTYPE"
 IF (no_proc_type_cnt > 0)
  SET reply->statlist[4].status_flag = 3
 ELSE
  SET reply->statlist[4].status_flag = 1
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bb_orc_incmplt_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
