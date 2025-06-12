CREATE PROGRAM bed_rec_incmp_ord_cat_detail:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 paramlist[*]
      2 meaning = vc
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 res_collist[*]
      2 header_text = vc
    1 res_rowlist[*]
      2 res_celllist[*]
        3 cell_text = vc
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 o_cnt = i4
   1 olist[*]
     2 catalog_cd = f8
     2 ord_itm_desc = vc
     2 dept_name = vc
     2 primary_mnemonic = vc
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 activity_subtype_cd = f8
     2 activity_subtype_disp = vc
     2 no_dta_ind = i2
     2 no_clin_cat_ind = i2
     2 no_syn_oef_ind = i2
     2 no_required_dta_ind = i2
     2 no_required_rep_ind = i2
     2 no_event_cd_ind = i2
     2 no_subact_ind = i2
     2 no_routing_ind = i2
     2 no_coll_req_allinstr_ind = i2
     2 no_coll_req_instr_ind = i2
     2 no_coll_req_age_gaps_ind = i2
 )
 RECORD temp2(
   1 o_cnt = i4
   1 olist[*]
     2 catalog_cd = f8
     2 ord_desc = vc
     2 dept_name = vc
     2 primary_mnemonic = vc
     2 catalog_type_cd = f8
     2 catalog_type_disp = vc
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 activity_subtype_cd = f8
     2 activity_subtype_disp = vc
     2 no_dta_ind = i2
     2 no_clin_cat_ind = i2
     2 no_syn_oef_ind = i2
     2 no_required_dta_ind = i2
     2 no_required_rep_ind = i2
     2 no_event_cd_ind = i2
     2 no_subact_ind = i2
     2 no_routing_ind = i2
     2 no_coll_req_allinstr_ind = i2
     2 no_coll_req_instr_ind = i2
     2 no_coll_req_age_gaps_ind = i2
 )
 FREE SET tempage
 RECORD tempage(
   1 alist[*]
     2 catalog_val = f8
     2 service_res = f8
     2 ord_desc = vc
     2 dept_name = vc
     2 primary_mnemonic = vc
     2 catalog_type_val = f8
     2 catalog_type_disp = vc
     2 activity_type_val = f8
     2 activity_type_disp = vc
     2 activity_subtype_val = f8
     2 activity_subtype_disp = vc
     2 activity_subtype_cd = f8
     2 activity_subtype_disp = vc
     2 age_to_min = i4
     2 age_from_min = i4
 )
 SET plsize = size(request->paramlist,5)
 SET stat = alterlist(reply->res_collist,2)
 SET reply->res_collist[1].header_text = "Check Name"
 SET reply->res_collist[2].header_text = "Resolution"
 SET stat = alterlist(reply->res_rowlist,plsize)
 FOR (p = 1 TO plsize)
   SELECT INTO "nl:"
    FROM br_rec b,
     br_long_text bl2
    PLAN (b
     WHERE (b.rec_mean=request->paramlist[p].meaning))
     JOIN (bl2
     WHERE bl2.long_text_id=b.resolution_txt_id)
    DETAIL
     stat = alterlist(reply->res_rowlist[p].res_celllist,2), reply->res_rowlist[p].res_celllist[1].
     cell_text = b.short_desc, reply->res_rowlist[p].res_celllist[2].cell_text = bl2.long_text
    WITH nocounter
   ;end select
 ENDFOR
 DECLARE genlab = f8 WITH public, noconstant(0.0)
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
 SET apat_cd = 0.0
 SET glbat_cd = 0.0
 SET apspecast_cd = 0.0
 SET microat_cd = 0.0
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
   WHERE cv.code_set=106
    AND cv.cdf_meaning="MICROBIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   microat_cd = cv.code_value
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
 SET cpharm = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY"
    AND cv.active_ind=1)
  DETAIL
   cpharm = cv.code_value
  WITH nocounter
 ;end select
 SET check_no_subact_ind = 0
 SET check_no_clin_ind = 0
 SET check_no_syn_oef_ind = 0
 SET check_no_assay_ind = 0
 SET check_no_req_assay_ind = 0
 SET check_no_reqrep_ind = 0
 SET check_no_evntcd_ind = 0
 SET check_no_wrk_ind = 0
 SET check_insben_ind = 0
 SET check_all_row_ind = 0
 SET check_agegap_ind = 0
 SET no_subact_col_nbr = 0
 SET no_clin_col_nbr = 0
 SET no_syn_oef_col_nbr = 0
 SET no_assay_col_nbr = 0
 SET no_req_assay_col_nbr = 0
 SET no_reqrep_col_nbr = 0
 SET no_evntcd_col_nbr = 0
 SET no_wrk_col_nbr = 0
 SET insben_col_nbr = 0
 SET all_row_col_nbr = 0
 SET agegap_col_nbr = 0
 SET subact_col_nbr = 0
 SET colm = 0
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="GLORDNOSUBACTTYPE"))
    SET colm = (colm+ 1)
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDNOCLINCAT")) OR ((((request->paramlist[p].meaning=
   "PHARMORDMISSINCLINCAT")) OR ((request->paramlist[p].meaning="MICROORDNOCLINCAT"))) )) )
    SET colm = (colm+ 1)
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDINCMPSYNOEF")) OR ((request->paramlist[p].meaning=
   "MICROORDINCMPSYNOEF"))) )
    SET colm = (colm+ 1)
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDNOASSAYS")) OR ((request->paramlist[p].meaning=
   "MICROORDNOASSAYS"))) )
    SET colm = (colm+ 1)
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="GLORDNOREQASSAY"))
    SET colm = (colm+ 1)
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="MICROORDREQREPORTS"))
    SET colm = (colm+ 1)
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="MICROORDEVNTCDASSOC")) OR ((request->paramlist[p].meaning=
   "PHARMORDMISSINEVNTCD"))) )
    SET colm = (colm+ 1)
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDNOWRKROUTING")) OR ((request->paramlist[p].meaning=
   "MICROORDINCMPWRKROUT"))) )
    SET colm = (colm+ 1)
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDINCMPCLREQINSBEN2")) OR ((request->paramlist[p].meaning
   ="MICROORDINCMPCLREQINSBEN"))) )
    SET colm = (colm+ 1)
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDINCMPCLREQALLROW")) OR ((request->paramlist[p].meaning=
   "MICROORDINCMPCLREQALLROW"))) )
    SET colm = (colm+ 1)
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDINCMPCLREQAGEGAP")) OR ((request->paramlist[p].meaning=
   "MICROORDINCMPCLREQAGEGAP"))) )
    SET colm = (colm+ 1)
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 IF (plsize=1
  AND (request->paramlist[1].meaning="GLORDNOSUBACTTYPE"))
  SET col_cnt = (5+ colm)
 ELSE
  SET col_cnt = (6+ colm)
 ENDIF
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Orderable Item Description"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Millennium Name (Primary Synonym)"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Department Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Catalog Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Activity Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET next_col = 5
 IF (plsize=1
  AND (request->paramlist[1].meaning="GLORDNOSUBACTTYPE"))
  SET next_col = next_col
 ELSE
  SET next_col = (next_col+ 1)
  SET subact_col_nbr = next_col
  SET reply->collist[next_col].header_text = "Subactivity Type"
  SET reply->collist[next_col].data_type = 1
  SET reply->collist[next_col].hide_ind = 0
 ENDIF
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="GLORDNOSUBACTTYPE"))
    SET check_no_subact_ind = 1
    SET next_col = (next_col+ 1)
    SET no_subact_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No Subactivity Type"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDNOCLINCAT")) OR ((((request->paramlist[p].meaning=
   "PHARMORDMISSINCLINCAT")) OR ((request->paramlist[p].meaning="MICROORDNOCLINCAT"))) )) )
    SET check_no_clin_ind = 1
    SET next_col = (next_col+ 1)
    SET no_clin_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No Clinical Category"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDINCMPSYNOEF")) OR ((request->paramlist[p].meaning=
   "MICROORDINCMPSYNOEF"))) )
    SET check_no_syn_oef_ind = 1
    SET next_col = (next_col+ 1)
    SET no_syn_oef_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No Synonym Order Entry Format"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDNOASSAYS")) OR ((request->paramlist[p].meaning=
   "MICROORDNOASSAYS"))) )
    SET check_no_assay_ind = 1
    SET next_col = (next_col+ 1)
    SET no_assay_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No Assays"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
    CALL echo(build("next_col",next_col))
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="GLORDNOREQASSAY"))
    SET check_no_req_assay_ind = 1
    SET next_col = (next_col+ 1)
    SET no_req_assay_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No Required Assay"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="MICROORDREQREPORTS"))
    SET check_no_reqrep_ind = 1
    SET next_col = (next_col+ 1)
    SET no_reqrep_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No Required Reports"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="MICROORDEVNTCDASSOC")) OR ((request->paramlist[p].meaning=
   "PHARMORDMISSINEVNTCD"))) )
    SET check_no_evntcd_ind = 1
    SET next_col = (next_col+ 1)
    SET no_evntcd_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No Event Code"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDNOWRKROUTING")) OR ((request->paramlist[p].meaning=
   "MICROORDINCMPWRKROUT"))) )
    SET check_no_wrk_ind = 1
    SET next_col = (next_col+ 1)
    SET no_wrk_col_nbr = next_col
    SET reply->collist[next_col].header_text = "No Work Routing"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDINCMPCLREQINSBEN2")) OR ((request->paramlist[p].meaning
   ="MICROORDINCMPCLREQINSBEN"))) )
    SET check_insben_ind = 1
    SET next_col = (next_col+ 1)
    SET insben_col_nbr = next_col
    SET reply->collist[next_col].header_text =
    "Collection Requirements - No Instrument or Bench Rows"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDINCMPCLREQALLROW")) OR ((request->paramlist[p].meaning=
   "MICROORDINCMPCLREQALLROW"))) )
    SET check_all_row_ind = 1
    SET next_col = (next_col+ 1)
    SET all_row_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Collection Requirements - No All Row"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 FOR (p = 1 TO plsize)
   IF ((((request->paramlist[p].meaning="GLORDINCMPCLREQAGEGAP")) OR ((request->paramlist[p].meaning=
   "MICROORDINCMPCLREQAGEGAP"))) )
    SET check_agegap_ind = 1
    SET next_col = (next_col+ 1)
    SET agegap_col_nbr = next_col
    SET reply->collist[next_col].header_text = "Collection Requirements - Age Gaps"
    SET reply->collist[next_col].data_type = 1
    SET reply->collist[next_col].hide_ind = 0
    SET p = (plsize+ 1)
   ENDIF
 ENDFOR
 SET o_cnt = 0
 FOR (p = 1 TO plsize)
   IF ((request->paramlist[p].meaning="GLORDNOSUBACTTYPE"))
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=glbat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.active_ind=1
       AND o.catalog_cd > 0)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display
      IF (o.activity_subtype_cd > 0)
       temp->olist[o_cnt].activity_subtype_cd = o.activity_subtype_cd, temp->olist[o_cnt].
       activity_subtype_disp = cv3.display
      ELSE
       temp->olist[o_cnt].no_subact_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="GLORDNOCLINCAT"))
    SELECT INTO "nl:"
     FROM order_catalog oc,
      order_catalog_synonym ocs,
      code_value cv1,
      code_value cv2,
      code_value cv3
     PLAN (oc
      WHERE oc.catalog_type_cd=genlab
       AND oc.activity_type_cd=glbat_cd
       AND oc.active_ind=1
       AND oc.orderable_type_flag IN (0, 1, 5, 10))
      JOIN (ocs
      WHERE ocs.catalog_cd=oc.catalog_cd
       AND ocs.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=oc.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=oc.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=oc.activity_subtype_cd)
     ORDER BY cv2.display_key, cnvtupper(oc.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = oc
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = oc.description, temp->olist[o_cnt].dept_name = oc
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = oc.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = oc.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp
       = cv1.display, temp->olist[o_cnt].activity_type_cd = oc.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd =
      oc.activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display
      IF (oc.dcp_clin_cat_cd=0)
       temp->olist[o_cnt].no_clin_cat_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="PHARMORDMISSINCLINCAT"))
    SELECT INTO "nl:"
     FROM order_catalog oc,
      order_catalog_synonym ocs,
      code_value cv1,
      code_value cv2,
      code_value cv3
     PLAN (oc
      WHERE oc.catalog_type_cd=cpharm
       AND oc.active_ind=1
       AND oc.orderable_type_flag IN (0, 1, 8))
      JOIN (ocs
      WHERE ocs.catalog_cd=oc.catalog_cd
       AND ocs.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=oc.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=oc.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=oc.activity_subtype_cd)
     ORDER BY cv2.display_key, cnvtupper(oc.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = oc
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = oc.description, temp->olist[o_cnt].dept_name = oc
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = oc.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = oc.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp
       = cv1.display, temp->olist[o_cnt].activity_type_cd = oc.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd =
      oc.activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display
      IF (oc.dcp_clin_cat_cd=0)
       temp->olist[o_cnt].no_clin_cat_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="MICROORDNOCLINCAT"))
    SELECT INTO "nl:"
     FROM order_catalog oc,
      order_catalog_synonym ocs,
      code_value cv1,
      code_value cv2,
      code_value cv3
     PLAN (oc
      WHERE oc.catalog_type_cd=genlab
       AND oc.activity_type_cd=microat_cd
       AND oc.orderable_type_flag IN (0, 1, 5, 10)
       AND oc.active_ind=1)
      JOIN (ocs
      WHERE ocs.catalog_cd=oc.catalog_cd
       AND ocs.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=oc.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=oc.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=oc.activity_subtype_cd)
     ORDER BY cv2.display_key, cnvtupper(oc.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = oc
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = oc.description, temp->olist[o_cnt].dept_name = oc
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = oc.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = oc.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp
       = cv1.display, temp->olist[o_cnt].activity_type_cd = oc.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd =
      oc.activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display
      IF (oc.dcp_clin_cat_cd=0)
       temp->olist[o_cnt].no_clin_cat_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="GLORDINCMPSYNOEF"))
    SELECT INTO "nl:"
     FROM order_catalog_synonym ocs,
      order_catalog oc,
      code_value cv1,
      code_value cv2,
      code_value cv3
     PLAN (ocs
      WHERE ocs.catalog_type_cd=genlab
       AND ocs.activity_type_cd=glbat_cd
       AND ocs.active_ind=1)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd
       AND oc.orderable_type_flag IN (0, 1, 5, 10)
       AND oc.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=oc.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=oc.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=oc.activity_subtype_cd)
     ORDER BY cv2.display_key, cnvtupper(oc.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = oc
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = oc.description, temp->olist[o_cnt].dept_name = oc
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = oc.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = oc.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp
       = cv1.display, temp->olist[o_cnt].activity_type_cd = oc.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd =
      oc.activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display
      IF (ocs.oe_format_id=0)
       temp->olist[o_cnt].no_syn_oef_ind = 1
      ELSE
       temp->olist[o_cnt].no_syn_oef_ind = 0
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="MICROORDINCMPSYNOEF"))
    SELECT INTO "nl:"
     FROM order_catalog_synonym ocs,
      order_catalog oc,
      code_value cv1,
      code_value cv2,
      code_value cv3
     PLAN (ocs
      WHERE ocs.catalog_type_cd=genlab
       AND ocs.activity_type_cd=microat_cd
       AND ocs.active_ind=1)
      JOIN (oc
      WHERE oc.catalog_cd=ocs.catalog_cd
       AND oc.orderable_type_flag IN (0, 1, 5, 10)
       AND oc.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=oc.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=oc.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=oc.activity_subtype_cd)
     ORDER BY cv2.display_key, cnvtupper(oc.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = oc
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = oc.description, temp->olist[o_cnt].dept_name = oc
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = oc.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = oc.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp
       = cv1.display, temp->olist[o_cnt].activity_type_cd = oc.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd =
      oc.activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display
      IF (ocs.oe_format_id=0)
       temp->olist[o_cnt].no_syn_oef_ind = 1,
       CALL echo(build(temp->olist[o_cnt].primary_mnemonic)),
       CALL echo(build("mnme",ocs.mnemonic))
      ELSE
       temp->olist[o_cnt].no_syn_oef_ind = 0
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="GLORDNOASSAYS"))
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      profile_task_r ptr,
      discrete_task_assay dta,
      dummyt d
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=glbat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (d)
      JOIN (ptr
      WHERE ptr.catalog_cd=o.catalog_cd
       AND ptr.active_ind=1)
      JOIN (dta
      WHERE dta.task_assay_cd=ptr.task_assay_cd
       AND dta.active_ind=1)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_dta_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="MICROORDNOASSAYS"))
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      profile_task_r ptr,
      discrete_task_assay dta
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=microat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (ptr
      WHERE ptr.catalog_cd=o.catalog_cd
       AND ptr.active_ind=1)
      JOIN (dta
      WHERE dta.task_assay_cd=ptr.task_assay_cd
       AND dta.active_ind=1)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic), o.catalog_cd
     HEAD o.catalog_cd
      dta_cnt = 0
     DETAIL
      dta_cnt = (dta_cnt+ 1), o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt),
      temp->olist[o_cnt].catalog_cd = o.catalog_cd, temp->olist[o_cnt].ord_itm_desc = o.description,
      temp->olist[o_cnt].dept_name = o.dept_display_name,
      temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic, temp->olist[o_cnt].catalog_type_cd =
      o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp = cv1.display,
      temp->olist[o_cnt].activity_type_cd = o.activity_type_cd, temp->olist[o_cnt].activity_type_disp
       = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o.activity_subtype_cd,
      temp->olist[o_cnt].activity_subtype_disp = cv3.display
     FOOT  o.catalog_cd
      IF (dta_cnt != 1)
       temp->olist[o_cnt].no_dta_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      profile_task_r ptr,
      discrete_task_assay dta,
      dummyt d
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=microat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (d)
      JOIN (ptr
      WHERE ptr.catalog_cd=o.catalog_cd
       AND ptr.active_ind=1)
      JOIN (dta
      WHERE dta.task_assay_cd=ptr.task_assay_cd
       AND dta.active_ind=1)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_dta_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="GLORDNOREQASSAY"))
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      profile_task_r ptr,
      discrete_task_assay dta
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=glbat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (ptr
      WHERE ptr.catalog_cd=o.catalog_cd
       AND ptr.active_ind=1)
      JOIN (dta
      WHERE dta.task_assay_cd=ptr.task_assay_cd
       AND dta.active_ind=1)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic), o.catalog_cd
     HEAD o.catalog_cd
      req_cnt = 0
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display
      IF (ptr.pending_ind=1)
       req_cnt = 1
      ENDIF
     FOOT  o.catalog_cd
      IF (req_cnt=0)
       temp->olist[o_cnt].no_required_dta_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="MICROORDREQREPORTS"))
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      mic_rpt_params mrp,
      mic_req_rpt mrr
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=microat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.active_ind=1
       AND o.catalog_cd > 0)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (mrp
      WHERE mrp.catalog_cd=outerjoin(o.catalog_cd))
      JOIN (mrr
      WHERE mrr.criteria_id=outerjoin(mrp.criteria_id))
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic), o.catalog_cd
     HEAD o.catalog_cd
      req_cnt = 0
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display
      IF (mrr.required_ind=1)
       req_cnt = 1
      ENDIF
     FOOT  o.catalog_cd
      IF (req_cnt=0)
       temp->olist[o_cnt].no_required_rep_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="MICROORDEVNTCDASSOC"))
    SELECT INTO "nl:"
     FROM order_catalog oc,
      code_value_event_r cver,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      dummyt d
     PLAN (oc
      WHERE oc.catalog_type_cd=genlab
       AND oc.activity_type_cd=microat_cd
       AND oc.orderable_type_flag IN (0, 1, 5, 10)
       AND oc.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=oc.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=oc.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=oc.activity_subtype_cd)
      JOIN (d)
      JOIN (cver
      WHERE cver.parent_cd=oc.catalog_cd)
     ORDER BY cv2.display_key, cnvtupper(oc.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = oc
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = oc.description, temp->olist[o_cnt].dept_name = oc
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = oc.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = oc.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp
       = cv1.display, temp->olist[o_cnt].activity_type_cd = oc.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd =
      oc.activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_event_cd_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="PHARMORDMISSINEVNTCD"))
    SELECT INTO "nl:"
     FROM order_catalog oc,
      code_value_event_r cver,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      dummyt d
     PLAN (oc
      WHERE oc.catalog_type_cd=cpharm
       AND oc.orderable_type_flag IN (0, 1, 10)
       AND oc.active_ind=1)
      JOIN (cv1
      WHERE cv1.code_value=oc.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=oc.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=oc.activity_subtype_cd)
      JOIN (d)
      JOIN (cver
      WHERE cver.parent_cd=oc.catalog_cd)
     ORDER BY cv2.display_key, cnvtupper(oc.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = oc
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = oc.description, temp->olist[o_cnt].dept_name = oc
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = oc.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = oc.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp
       = cv1.display, temp->olist[o_cnt].activity_type_cd = oc.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd =
      oc.activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_event_cd_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="GLORDNOWRKROUTING"))
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      orc_resource_list orl,
      code_value cv,
      dummyt d
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=glbat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND ((o.resource_route_lvl < 2) OR (o.resource_route_lvl=null)) )
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (d)
      JOIN (orl
      WHERE orl.catalog_cd=o.catalog_cd
       AND orl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=orl.service_resource_cd
       AND cv.active_ind=1)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_routing_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      dummyt d,
      profile_task_r ptr,
      assay_resource_list apr,
      code_value cv
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=glbat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND o.resource_route_lvl=2)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (d)
      JOIN (ptr
      WHERE ptr.catalog_cd=o.catalog_cd
       AND ptr.active_ind=1)
      JOIN (apr
      WHERE apr.task_assay_cd=ptr.task_assay_cd
       AND apr.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=apr.service_resource_cd
       AND cv.active_ind=1)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_routing_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="MICROORDINCMPWRKROUT"))
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      dummyt d,
      orc_resource_list orl,
      code_value cv
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=microat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND ((o.resource_route_lvl < 2) OR (o.resource_route_lvl=null)) )
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (d)
      JOIN (orl
      WHERE orl.catalog_cd=o.catalog_cd
       AND orl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=orl.service_resource_cd
       AND cv.active_ind=1)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_routing_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      dummyt d,
      profile_task_r ptr,
      assay_resource_list apr,
      code_value cv
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=microat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND o.resource_route_lvl=2)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (d)
      JOIN (ptr
      WHERE ptr.catalog_cd=o.catalog_cd
       AND ptr.active_ind=1)
      JOIN (apr
      WHERE apr.task_assay_cd=ptr.task_assay_cd
       AND apr.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=apr.service_resource_cd
       AND cv.active_ind=1)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_routing_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="GLORDINCMPCLREQINSBEN2"))
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      orc_resource_list orl,
      code_value cv,
      sub_section s
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=glbat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND ((o.resource_route_lvl < 2) OR (o.resource_route_lvl=null)) )
      JOIN (orl
      WHERE orl.catalog_cd=o.catalog_cd
       AND orl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=orl.service_resource_cd
       AND cv.active_ind=1
       AND  NOT ( EXISTS (
      (SELECT
       ciq.catalog_cd
       FROM collection_info_qualifiers ciq
       WHERE ciq.catalog_cd=o.catalog_cd
        AND ciq.specimen_type_cd > 0
        AND ciq.service_resource_cd > 0
        AND ciq.service_resource_cd=cv.code_value))))
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (s
      WHERE s.service_resource_cd=outerjoin(cv.code_value))
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      IF (((s.service_resource_cd > 0
       AND s.multiplexor_ind=1) OR (s.service_resource_cd=0.0)) )
       o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
       .catalog_cd,
       temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
       .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
       temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp
        = cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
       temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd =
       o.activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
       temp->olist[o_cnt].no_coll_req_instr_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      profile_task_r ptr,
      assay_resource_list apr,
      code_value cv,
      sub_section s
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=glbat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND o.resource_route_lvl=2)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (ptr
      WHERE ptr.catalog_cd=o.catalog_cd
       AND ptr.active_ind=1)
      JOIN (apr
      WHERE apr.task_assay_cd=ptr.task_assay_cd
       AND apr.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=apr.service_resource_cd
       AND cv.active_ind=1
       AND  NOT ( EXISTS (
      (SELECT
       ciq.catalog_cd
       FROM collection_info_qualifiers ciq
       WHERE ciq.catalog_cd=o.catalog_cd
        AND ciq.specimen_type_cd > 0
        AND ciq.service_resource_cd > 0
        AND ciq.service_resource_cd=cv.code_value))))
      JOIN (s
      WHERE s.service_resource_cd=outerjoin(cv.code_value))
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      IF (((s.service_resource_cd > 0
       AND s.multiplexor_ind=1) OR (s.service_resource_cd=0.0)) )
       o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
       .catalog_cd,
       temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
       .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
       temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp
        = cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
       temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd =
       o.activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
       temp->olist[o_cnt].no_coll_req_instr_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="MICROORDINCMPCLREQINSBEN"))
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      orc_resource_list orl,
      code_value cv,
      dummyt d,
      collection_info_qualifiers ciq
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=microat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND ((o.resource_route_lvl < 2) OR (o.resource_route_lvl=null)) )
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (orl
      WHERE orl.catalog_cd=o.catalog_cd
       AND orl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=orl.service_resource_cd
       AND cv.active_ind=1)
      JOIN (d)
      JOIN (ciq
      WHERE ciq.catalog_cd=o.catalog_cd
       AND ciq.specimen_type_cd > 0
       AND ciq.service_resource_cd > 0
       AND ciq.service_resource_cd=orl.service_resource_cd)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_coll_req_instr_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      profile_task_r ptr,
      assay_resource_list apr,
      code_value cv,
      dummyt d,
      collection_info_qualifiers ciq
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=microat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND o.resource_route_lvl=2)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (ptr
      WHERE ptr.catalog_cd=o.catalog_cd
       AND ptr.active_ind=1)
      JOIN (apr
      WHERE apr.task_assay_cd=ptr.task_assay_cd
       AND apr.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=apr.service_resource_cd
       AND cv.active_ind=1)
      JOIN (d)
      JOIN (ciq
      WHERE ciq.catalog_cd=o.catalog_cd
       AND ciq.specimen_type_cd > 0
       AND ciq.service_resource_cd > 0
       AND ciq.service_resource_cd=apr.service_resource_cd)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_coll_req_instr_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="GLORDINCMPCLREQALLROW"))
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      orc_resource_list orl,
      code_value cv,
      dummyt d,
      collection_info_qualifiers ciq
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=glbat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND ((o.resource_route_lvl < 2) OR (o.resource_route_lvl=null)) )
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (orl
      WHERE orl.catalog_cd=o.catalog_cd
       AND orl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=orl.service_resource_cd
       AND cv.active_ind=1)
      JOIN (d)
      JOIN (ciq
      WHERE ciq.catalog_cd=o.catalog_cd
       AND ciq.specimen_type_cd > 0
       AND ciq.service_resource_cd=0)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_coll_req_allinstr_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      profile_task_r ptr,
      assay_resource_list apr,
      code_value cv,
      dummyt d,
      collection_info_qualifiers ciq
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=glbat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND o.resource_route_lvl=2)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (ptr
      WHERE ptr.catalog_cd=o.catalog_cd
       AND ptr.active_ind=1)
      JOIN (apr
      WHERE apr.task_assay_cd=ptr.task_assay_cd
       AND apr.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=apr.service_resource_cd
       AND cv.active_ind=1)
      JOIN (d)
      JOIN (ciq
      WHERE ciq.catalog_cd=o.catalog_cd
       AND ciq.specimen_type_cd > 0
       AND ciq.service_resource_cd=0)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_coll_req_allinstr_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="MICROORDINCMPCLREQALLROW"))
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      orc_resource_list orl,
      code_value cv,
      dummyt d,
      collection_info_qualifiers ciq
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=microat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND ((o.resource_route_lvl < 2) OR (o.resource_route_lvl=null)) )
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (orl
      WHERE orl.catalog_cd=o.catalog_cd
       AND orl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=orl.service_resource_cd
       AND cv.active_ind=1)
      JOIN (d)
      JOIN (ciq
      WHERE ciq.catalog_cd=o.catalog_cd
       AND ciq.specimen_type_cd > 0
       AND ciq.service_resource_cd=0)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_coll_req_allinstr_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
    SELECT INTO "nl:"
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      profile_task_r ptr,
      assay_resource_list apr,
      code_value cv,
      dummyt d,
      collection_info_qualifiers ciq
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=microat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND o.resource_route_lvl=2)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (ptr
      WHERE ptr.catalog_cd=o.catalog_cd
       AND ptr.active_ind=1)
      JOIN (apr
      WHERE apr.task_assay_cd=ptr.task_assay_cd
       AND apr.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=apr.service_resource_cd
       AND cv.active_ind=1)
      JOIN (d)
      JOIN (ciq
      WHERE ciq.catalog_cd=o.catalog_cd
       AND ciq.specimen_type_cd > 0
       AND ciq.service_resource_cd=0)
     ORDER BY cv2.display_key, cnvtupper(o.primary_mnemonic)
     DETAIL
      o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt), temp->olist[o_cnt].catalog_cd = o
      .catalog_cd,
      temp->olist[o_cnt].ord_itm_desc = o.description, temp->olist[o_cnt].dept_name = o
      .dept_display_name, temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic,
      temp->olist[o_cnt].catalog_type_cd = o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp =
      cv1.display, temp->olist[o_cnt].activity_type_cd = o.activity_type_cd,
      temp->olist[o_cnt].activity_type_disp = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o
      .activity_subtype_cd, temp->olist[o_cnt].activity_subtype_disp = cv3.display,
      temp->olist[o_cnt].no_coll_req_allinstr_ind = 1
     WITH nocounter, outerjoin = d, dontexist
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="GLORDINCMPCLREQAGEGAP"))
    SELECT DISTINCT INTO "nl:"
     ciq.sequence
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      orc_resource_list orl,
      code_value cv,
      collection_info_qualifiers ciq
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=glbat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND ((o.resource_route_lvl < 2) OR (o.resource_route_lvl=null)) )
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (orl
      WHERE orl.catalog_cd=o.catalog_cd
       AND orl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=orl.service_resource_cd
       AND cv.active_ind=1)
      JOIN (ciq
      WHERE ciq.catalog_cd=o.catalog_cd
       AND ciq.specimen_type_cd > 0)
     ORDER BY ciq.catalog_cd, ciq.service_resource_cd, ciq.age_from_minutes,
      ciq.age_to_minutes
     HEAD ciq.catalog_cd
      pass_ind = 0, o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt),
      temp->olist[o_cnt].catalog_cd = o.catalog_cd, temp->olist[o_cnt].ord_itm_desc = o.description,
      temp->olist[o_cnt].dept_name = o.dept_display_name,
      temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic, temp->olist[o_cnt].catalog_type_cd =
      o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp = cv1.display,
      temp->olist[o_cnt].activity_type_cd = o.activity_type_cd, temp->olist[o_cnt].activity_type_disp
       = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o.activity_subtype_cd,
      temp->olist[o_cnt].activity_subtype_disp = cv3.display
     HEAD ciq.service_resource_cd
      acnt = 0
     DETAIL
      acnt = (acnt+ 1), stat = alterlist(tempage->alist,acnt), tempage->alist[acnt].age_from_min =
      ciq.age_from_minutes,
      tempage->alist[acnt].age_to_min = ciq.age_to_minutes
     FOOT  ciq.service_resource_cd
      IF (min(ciq.age_from_minutes)=0
       AND max(ciq.age_to_minutes)=78840000)
       IF (acnt > 1)
        FOR (x = 1 TO (acnt - 1))
          IF ((tempage->alist[x].age_to_min=tempage->alist[(x+ 1)].age_from_min))
           pass_ind = 1
          ELSE
           temp->olist[o_cnt].no_coll_req_age_gaps_ind = 1, x = acnt
          ENDIF
        ENDFOR
       ELSEIF (acnt=1)
        IF ((tempage->alist[acnt].age_from_min=0)
         AND (tempage->alist[acnt].age_to_min=78840000))
         pass_ind = 1
        ELSE
         temp->olist[o_cnt].no_coll_req_age_gaps_ind = 1
        ENDIF
       ENDIF
      ELSE
       temp->olist[o_cnt].no_coll_req_age_gaps_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     ciq.sequence
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      profile_task_r ptr,
      assay_resource_list apr,
      code_value cv,
      collection_info_qualifiers ciq
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=glbat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND o.resource_route_lvl=2)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (ptr
      WHERE ptr.catalog_cd=o.catalog_cd
       AND ptr.active_ind=1)
      JOIN (apr
      WHERE apr.task_assay_cd=ptr.task_assay_cd
       AND apr.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=apr.service_resource_cd
       AND cv.active_ind=1)
      JOIN (ciq
      WHERE ciq.catalog_cd=o.catalog_cd
       AND ciq.specimen_type_cd > 0)
     ORDER BY ciq.catalog_cd, ciq.service_resource_cd, ciq.age_from_minutes,
      ciq.age_to_minutes
     HEAD ciq.catalog_cd
      pass_ind = 0, o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt),
      temp->olist[o_cnt].catalog_cd = o.catalog_cd, temp->olist[o_cnt].ord_itm_desc = o.description,
      temp->olist[o_cnt].dept_name = o.dept_display_name,
      temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic, temp->olist[o_cnt].catalog_type_cd =
      o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp = cv1.display,
      temp->olist[o_cnt].activity_type_cd = o.activity_type_cd, temp->olist[o_cnt].activity_type_disp
       = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o.activity_subtype_cd,
      temp->olist[o_cnt].activity_subtype_disp = cv3.display
     HEAD ciq.service_resource_cd
      acnt = 0
     DETAIL
      acnt = (acnt+ 1), stat = alterlist(tempage->alist,acnt), tempage->alist[acnt].age_from_min =
      ciq.age_from_minutes,
      tempage->alist[acnt].age_to_min = ciq.age_to_minutes
     FOOT  ciq.service_resource_cd
      IF (min(ciq.age_from_minutes)=0
       AND max(ciq.age_to_minutes)=78840000)
       IF (acnt > 1)
        FOR (x = 1 TO (acnt - 1))
          IF ((tempage->alist[x].age_to_min=tempage->alist[(x+ 1)].age_from_min))
           pass_ind = 1
          ELSE
           temp->olist[o_cnt].no_coll_req_age_gaps_ind = 1, x = acnt
          ENDIF
        ENDFOR
       ELSEIF (acnt=1)
        IF ((tempage->alist[acnt].age_from_min=0)
         AND (tempage->alist[acnt].age_to_min=78840000))
         pass_ind = 1
        ELSE
         temp->olist[o_cnt].no_coll_req_age_gaps_ind = 1
        ENDIF
       ENDIF
      ELSE
       temp->olist[o_cnt].no_coll_req_age_gaps_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((request->paramlist[p].meaning="MICROORDINCMPCLREQAGEGAP"))
    SELECT DISTINCT INTO "nl:"
     ciq.sequence
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      orc_resource_list orl,
      code_value cv,
      collection_info_qualifiers ciq
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=microat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND ((o.resource_route_lvl < 2) OR (o.resource_route_lvl=null)) )
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (orl
      WHERE orl.catalog_cd=o.catalog_cd
       AND orl.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=orl.service_resource_cd
       AND cv.active_ind=1)
      JOIN (ciq
      WHERE ciq.catalog_cd=o.catalog_cd
       AND ciq.specimen_type_cd > 0)
     ORDER BY ciq.catalog_cd, ciq.service_resource_cd, ciq.age_from_minutes,
      ciq.age_to_minutes
     HEAD ciq.catalog_cd
      pass_ind = 0, o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt),
      temp->olist[o_cnt].catalog_cd = o.catalog_cd, temp->olist[o_cnt].ord_itm_desc = o.description,
      temp->olist[o_cnt].dept_name = o.dept_display_name,
      temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic, temp->olist[o_cnt].catalog_type_cd =
      o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp = cv1.display,
      temp->olist[o_cnt].activity_type_cd = o.activity_type_cd, temp->olist[o_cnt].activity_type_disp
       = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o.activity_subtype_cd,
      temp->olist[o_cnt].activity_subtype_disp = cv3.display
     HEAD ciq.service_resource_cd
      acnt = 0
     DETAIL
      acnt = (acnt+ 1), stat = alterlist(tempage->alist,acnt), tempage->alist[acnt].age_from_min =
      ciq.age_from_minutes,
      tempage->alist[acnt].age_to_min = ciq.age_to_minutes
     FOOT  ciq.service_resource_cd
      IF (min(ciq.age_from_minutes)=0
       AND max(ciq.age_to_minutes)=78840000)
       IF (acnt > 1)
        FOR (x = 1 TO (acnt - 1))
          IF ((tempage->alist[x].age_to_min=tempage->alist[(x+ 1)].age_from_min))
           pass_ind = 1
          ELSE
           temp->olist[o_cnt].no_coll_req_age_gaps_ind = 1, x = acnt
          ENDIF
        ENDFOR
       ELSEIF (acnt=1)
        IF ((tempage->alist[acnt].age_from_min=0)
         AND (tempage->alist[acnt].age_to_min=78840000))
         pass_ind = 1
        ELSE
         temp->olist[o_cnt].no_coll_req_age_gaps_ind = 1
        ENDIF
       ENDIF
      ELSE
       temp->olist[o_cnt].no_coll_req_age_gaps_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    SELECT DISTINCT INTO "nl:"
     ciq.sequence
     FROM order_catalog o,
      code_value cv1,
      code_value cv2,
      code_value cv3,
      profile_task_r ptr,
      assay_resource_list apr,
      code_value cv,
      collection_info_qualifiers ciq
     PLAN (o
      WHERE o.catalog_type_cd=genlab
       AND o.activity_type_cd=microat_cd
       AND o.orderable_type_flag IN (0, 1, 5, 10)
       AND o.bill_only_ind IN (0, null)
       AND o.active_ind=1
       AND o.catalog_cd > 0
       AND o.resource_route_lvl=2)
      JOIN (cv1
      WHERE cv1.code_value=o.catalog_type_cd)
      JOIN (cv2
      WHERE cv2.code_value=o.activity_type_cd)
      JOIN (cv3
      WHERE cv3.code_value=o.activity_subtype_cd)
      JOIN (ptr
      WHERE ptr.catalog_cd=o.catalog_cd
       AND ptr.active_ind=1)
      JOIN (apr
      WHERE apr.task_assay_cd=ptr.task_assay_cd
       AND apr.active_ind=1)
      JOIN (cv
      WHERE cv.code_value=apr.service_resource_cd
       AND cv.active_ind=1)
      JOIN (ciq
      WHERE ciq.catalog_cd=o.catalog_cd
       AND ciq.specimen_type_cd > 0)
     ORDER BY ciq.catalog_cd, ciq.service_resource_cd, ciq.age_from_minutes,
      ciq.age_to_minutes
     HEAD ciq.catalog_cd
      pass_ind = 0, o_cnt = (o_cnt+ 1), stat = alterlist(temp->olist,o_cnt),
      temp->olist[o_cnt].catalog_cd = o.catalog_cd, temp->olist[o_cnt].ord_itm_desc = o.description,
      temp->olist[o_cnt].dept_name = o.dept_display_name,
      temp->olist[o_cnt].primary_mnemonic = o.primary_mnemonic, temp->olist[o_cnt].catalog_type_cd =
      o.catalog_type_cd, temp->olist[o_cnt].catalog_type_disp = cv1.display,
      temp->olist[o_cnt].activity_type_cd = o.activity_type_cd, temp->olist[o_cnt].activity_type_disp
       = cv2.display, temp->olist[o_cnt].activity_subtype_cd = o.activity_subtype_cd,
      temp->olist[o_cnt].activity_subtype_disp = cv3.display
     HEAD ciq.service_resource_cd
      acnt = 0
     DETAIL
      acnt = (acnt+ 1), stat = alterlist(tempage->alist,acnt), tempage->alist[acnt].age_from_min =
      ciq.age_from_minutes,
      tempage->alist[acnt].age_to_min = ciq.age_to_minutes
     FOOT  ciq.service_resource_cd
      IF (min(ciq.age_from_minutes)=0
       AND max(ciq.age_to_minutes)=78840000)
       IF (acnt > 1)
        FOR (x = 1 TO (acnt - 1))
          IF ((tempage->alist[x].age_to_min=tempage->alist[(x+ 1)].age_from_min))
           pass_ind = 1
          ELSE
           temp->olist[o_cnt].no_coll_req_age_gaps_ind = 1, x = acnt
          ENDIF
        ENDFOR
       ELSEIF (acnt=1)
        IF ((tempage->alist[acnt].age_from_min=0)
         AND (tempage->alist[acnt].age_to_min=78840000))
         pass_ind = 1
        ELSE
         temp->olist[o_cnt].no_coll_req_age_gaps_ind = 1
        ENDIF
       ENDIF
      ELSE
       temp->olist[o_cnt].no_coll_req_age_gaps_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET ordx = 0
 IF (o_cnt > 0)
  SET stat = alterlist(temp2->olist,o_cnt)
  SELECT INTO "nl:"
   mnem = cnvtupper(temp->olist[d.seq].primary_mnemonic)
   FROM (dummyt d  WITH seq = o_cnt)
   PLAN (d)
   ORDER BY mnem
   DETAIL
    IF ((((temp->olist[d.seq].no_subact_ind=1)) OR ((((temp->olist[d.seq].no_clin_cat_ind=1)) OR ((((
    temp->olist[d.seq].no_syn_oef_ind=1)) OR ((((temp->olist[d.seq].no_dta_ind=1)) OR ((((temp->
    olist[d.seq].no_required_dta_ind=1)) OR ((((temp->olist[d.seq].no_required_rep_ind=1)) OR ((((
    temp->olist[d.seq].no_event_cd_ind=1)) OR ((((temp->olist[d.seq].no_routing_ind=1)) OR ((((temp->
    olist[d.seq].no_coll_req_instr_ind=1)) OR ((((temp->olist[d.seq].no_coll_req_allinstr_ind=1)) OR
    ((temp->olist[d.seq].no_coll_req_age_gaps_ind=1))) )) )) )) )) )) )) )) )) )) )
     ordx = (ordx+ 1), temp2->olist[ordx].catalog_cd = temp->olist[d.seq].catalog_cd, temp2->olist[
     ordx].ord_desc = temp->olist[d.seq].ord_itm_desc,
     temp2->olist[ordx].dept_name = temp->olist[d.seq].dept_name, temp2->olist[ordx].primary_mnemonic
      = temp->olist[d.seq].primary_mnemonic, temp2->olist[ordx].catalog_type_cd = temp->olist[d.seq].
     catalog_type_cd,
     temp2->olist[ordx].catalog_type_disp = temp->olist[d.seq].catalog_type_disp, temp2->olist[ordx].
     activity_type_cd = temp->olist[d.seq].activity_type_cd, temp2->olist[ordx].activity_type_disp =
     temp->olist[d.seq].activity_type_disp,
     temp2->olist[ordx].activity_subtype_cd = temp->olist[d.seq].activity_subtype_cd, temp2->olist[
     ordx].activity_subtype_disp = temp->olist[d.seq].activity_subtype_disp, temp2->olist[ordx].
     no_subact_ind = temp->olist[d.seq].no_subact_ind,
     temp2->olist[ordx].no_dta_ind = temp->olist[d.seq].no_dta_ind, temp2->olist[ordx].
     no_clin_cat_ind = temp->olist[d.seq].no_clin_cat_ind, temp2->olist[ordx].no_event_cd_ind = temp
     ->olist[d.seq].no_event_cd_ind,
     temp2->olist[ordx].no_routing_ind = temp->olist[d.seq].no_routing_ind, temp2->olist[ordx].
     no_syn_oef_ind = temp->olist[d.seq].no_syn_oef_ind, temp2->olist[ordx].no_required_dta_ind =
     temp->olist[d.seq].no_required_dta_ind,
     temp2->olist[ordx].no_required_rep_ind = temp->olist[d.seq].no_required_rep_ind, temp2->olist[
     ordx].no_coll_req_instr_ind = temp->olist[d.seq].no_coll_req_instr_ind, temp2->olist[ordx].
     no_coll_req_allinstr_ind = temp->olist[d.seq].no_coll_req_allinstr_ind,
     temp2->olist[ordx].no_coll_req_age_gaps_ind = temp->olist[d.seq].no_coll_req_age_gaps_ind
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (ordx > 0)
  SET rcnt = 0
  SELECT INTO "nl:"
   o_id = temp2->olist[d.seq].catalog_cd, mnem2 = cnvtupper(temp2->olist[d.seq].primary_mnemonic)
   FROM (dummyt d  WITH seq = ordx)
   PLAN (d)
   ORDER BY mnem2, o_id
   HEAD o_id
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,col_cnt),
    reply->rowlist[rcnt].celllist[1].string_value = temp2->olist[d.seq].ord_desc, reply->rowlist[rcnt
    ].celllist[2].string_value = temp2->olist[d.seq].primary_mnemonic, reply->rowlist[rcnt].celllist[
    3].string_value = temp2->olist[d.seq].dept_name,
    reply->rowlist[rcnt].celllist[4].string_value = temp2->olist[d.seq].catalog_type_disp, reply->
    rowlist[rcnt].celllist[5].string_value = temp2->olist[d.seq].activity_type_disp
   DETAIL
    IF (check_no_clin_ind=1
     AND (temp2->olist[d.seq].no_clin_cat_ind=1))
     reply->rowlist[rcnt].celllist[no_clin_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_syn_oef_ind=1
     AND (temp2->olist[d.seq].no_syn_oef_ind=1))
     reply->rowlist[rcnt].celllist[no_syn_oef_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_assay_ind=1
     AND (temp2->olist[d.seq].no_dta_ind=1))
     reply->rowlist[rcnt].celllist[no_assay_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_req_assay_ind=1
     AND (temp2->olist[d.seq].no_required_dta_ind=1))
     reply->rowlist[rcnt].celllist[no_req_assay_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_reqrep_ind=1
     AND (temp2->olist[d.seq].no_required_rep_ind=1))
     reply->rowlist[rcnt].celllist[no_reqrep_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_evntcd_ind=1
     AND (temp2->olist[d.seq].no_event_cd_ind=1))
     reply->rowlist[rcnt].celllist[no_evntcd_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_wrk_ind=1
     AND (temp2->olist[d.seq].no_routing_ind=1))
     reply->rowlist[rcnt].celllist[no_wrk_col_nbr].string_value = "X"
    ENDIF
    IF (check_insben_ind=1
     AND (temp2->olist[d.seq].no_coll_req_instr_ind=1))
     reply->rowlist[rcnt].celllist[insben_col_nbr].string_value = "X"
    ENDIF
    IF (check_all_row_ind=1
     AND (temp2->olist[d.seq].no_coll_req_allinstr_ind=1))
     reply->rowlist[rcnt].celllist[all_row_col_nbr].string_value = "X"
    ENDIF
    IF (check_agegap_ind=1
     AND (temp2->olist[d.seq].no_coll_req_age_gaps_ind=1))
     reply->rowlist[rcnt].celllist[agegap_col_nbr].string_value = "X"
    ENDIF
    IF (check_no_subact_ind=1
     AND (temp2->olist[d.seq].no_subact_ind=1))
     reply->rowlist[rcnt].celllist[no_subact_col_nbr].string_value = "X"
    ELSE
     reply->rowlist[rcnt].celllist[subact_col_nbr].string_value = temp2->olist[d.seq].
     activity_subtype_disp
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
END GO
