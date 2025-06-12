CREATE PROGRAM bhs_rpt_extract_formulary:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_check_domain
 RECORD data(
   1 ndc[*]
     2 s_field_0_ndc = vc
     2 s_field_1_brand_name = vc
     2 s_field_2_generic_name = vc
     2 s_field_3_theraputic_class = vc
     2 s_field_4_dosage_form = vc
     2 s_field_5_free_text_dose = vc
     2 s_field_6_given_strength = vc
     2 s_field_10_doserate = vc
     2 s_field_11_oedef_infuse_over_disp = vc
     2 s_field_12_route = vc
     2 s_field_13_manufacturer = vc
     2 s_field_14_oedef_frequency = vc
     2 s_field_16_pyxis_interface_id = vc
     2 s_field_18_mdisp_volume = vc
     2 s_field_19_mdisp_volume_unit = vc
     2 s_field_20_strength = vc
     2 s_formulary_status_disp = vc
     2 n_oe_format_flag = i2
     2 f_parent_item_id = f8
 ) WITH protect
 DECLARE mf_pyxisinterfaceid = f8 WITH constant(uar_get_code_by("MEANING",11000,"PYXIS")), protect
 DECLARE mf_lotnumber = f8 WITH constant(uar_get_code_by("MEANING",11000,"LOT_NBR")), protect
 DECLARE mf_desc_short = f8 WITH constant(uar_get_code_by("MEANING",11000,"DESC_SHORT")), protect
 DECLARE mf_brandname = f8 WITH constant(uar_get_code_by("MEANING",11000,"BRAND_NAME")), protect
 DECLARE mf_genericname = f8 WITH constant(uar_get_code_by("MEANING",11000,"GENERIC_NAME")), protect
 DECLARE mf_ndc = f8 WITH constant(uar_get_code_by("DISPLAYKEY",11000,"NDC")), protect
 DECLARE mf_system = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4062,"SYSTEM")), protect
 DECLARE mf_inpatient = f8 WITH constant(uar_get_code_by("MEANING",4500,"INPATIENT")), protect
 DECLARE mf_medproduct = f8 WITH constant(uar_get_code_by("MEANING",4063,"MEDPRODUCT")), protect
 DECLARE mf_syspkgtyp = f8 WITH constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP")), protect
 DECLARE mf_oedefault = f8 WITH constant(uar_get_code_by("MEANING",4063,"OEDEF")), protect
 DECLARE mf_orderable = f8 WITH constant(uar_get_code_by("MEANING",4063,"ORDERABLE")), protect
 DECLARE mf_dispense = f8 WITH constant(uar_get_code_by("MEANING",4063,"DISPENSE")), protect
 DECLARE mf_pharmacy = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY")), protect
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_rpt_extract_formulary/"))
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ms_pharm_form_file = vc WITH protect
 SET ms_pharm_form_file = build(ms_loc_dir,"med",format(cnvtdatetime(sysdate),"YYYYMMDD;;D"),".csv")
 CALL echo(ms_pharm_form_file)
 SELECT INTO "nl:"
  FROM medication_definition md,
   med_def_flex mdf2,
   med_flex_object_idx mfoi3,
   med_def_flex mdpkg,
   med_flex_object_idx imdisp,
   med_dispense mdisp,
   med_product mp,
   manufacturer_item manf,
   med_cost_hx mch,
   med_flex_object_idx odemf,
   med_oe_defaults oedef,
   med_identifier ndcmi,
   med_identifier brndmi,
   med_identifier mgenr,
   med_identifier mipyx,
   order_catalog oc,
   order_catalog_item_r ocir,
   order_catalog_synonym ocs,
   alt_sel_list l1,
   alt_sel_cat c1
  PLAN (md
   WHERE md.item_id > 0)
   JOIN (mdf2
   WHERE mdf2.item_id=md.item_id
    AND mdf2.flex_type_cd=mf_system
    AND mdf2.pharmacy_type_cd=mf_inpatient)
   JOIN (mfoi3
   WHERE mfoi3.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi3.flex_object_type_cd=mf_medproduct)
   JOIN (mdpkg
   WHERE md.item_id=mdpkg.item_id
    AND mdpkg.flex_type_cd=mf_syspkgtyp
    AND mdpkg.pharmacy_type_cd=mf_inpatient)
   JOIN (imdisp
   WHERE imdisp.med_def_flex_id=mdpkg.med_def_flex_id
    AND imdisp.flex_object_type_cd=mf_dispense
    AND imdisp.sequence=1
    AND imdisp.active_ind=1)
   JOIN (mdisp
   WHERE mdisp.med_dispense_id=imdisp.parent_entity_id)
   JOIN (mp
   WHERE mp.med_product_id=mfoi3.parent_entity_id)
   JOIN (manf
   WHERE mp.manf_item_id=manf.item_id)
   JOIN (mch
   WHERE mp.med_product_id=mch.med_product_id)
   JOIN (odemf
   WHERE odemf.med_def_flex_id=mdf2.med_def_flex_id
    AND odemf.flex_object_type_cd=mf_oedefault)
   JOIN (oedef
   WHERE oedef.med_oe_defaults_id=odemf.parent_entity_id)
   JOIN (ndcmi
   WHERE ndcmi.item_id=md.item_id
    AND ndcmi.med_identifier_type_cd=mf_ndc
    AND ndcmi.med_product_id=mch.med_product_id
    AND ndcmi.active_ind=1
    AND ndcmi.pharmacy_type_cd=mf_inpatient)
   JOIN (mgenr
   WHERE mgenr.item_id=md.item_id
    AND mgenr.med_identifier_type_cd=mf_genericname
    AND mgenr.med_product_id=0
    AND mgenr.pharmacy_type_cd=mf_inpatient)
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (oc
   WHERE oc.catalog_cd=ocir.catalog_cd
    AND oc.activity_type_cd=mf_pharmacy)
   JOIN (ocs
   WHERE ocs.catalog_cd=ocir.catalog_cd
    AND ocs.synonym_id=ocir.synonym_id)
   JOIN (mipyx
   WHERE (mipyx.item_id= Outerjoin(md.item_id))
    AND (mipyx.med_identifier_type_cd= Outerjoin(mf_pyxisinterfaceid))
    AND (mipyx.med_product_id= Outerjoin(0))
    AND (mipyx.pharmacy_type_cd= Outerjoin(mf_inpatient)) )
   JOIN (brndmi
   WHERE brndmi.item_id=md.item_id
    AND brndmi.med_identifier_type_cd=mf_brandname
    AND brndmi.med_product_id=mch.med_product_id
    AND brndmi.pharmacy_type_cd=mf_inpatient)
   JOIN (l1
   WHERE (l1.synonym_id= Outerjoin(ocs.synonym_id)) )
   JOIN (c1
   WHERE (c1.alt_sel_category_id= Outerjoin(l1.alt_sel_category_id))
    AND (c1.alt_sel_category_id> Outerjoin(0))
    AND (c1.ahfs_ind= Outerjoin(1)) )
  ORDER BY substring(0,50,mgenr.value), substring(0,13,ndcmi.value), substring(0,50,brndmi.value),
   trim(md.given_strength,3), uar_get_code_display(oedef.infuse_over_cd), uar_get_code_display(oedef
    .route_cd),
   evaluate(manf.manufacturer_cd,null," ",replace(uar_get_code_display(manf.manufacturer_cd),",","")),
   mipyx.value, replace(format(mdisp.volume,"##########.##;,IRT(1);F"),",","")
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_num = 0, ml_idx = locateval(ml_num,1,size(data->ndc,5),substring(0,13,ndcmi.value),data->ndc[
    ml_num].s_field_0_ndc)
   IF (ml_idx=0)
    ml_cnt += 1
    IF (size(data->ndc,5) < ml_cnt)
     CALL alterlist(data->ndc,(ml_cnt+ 100))
    ENDIF
    data->ndc[ml_cnt].s_field_0_ndc = substring(0,13,ndcmi.value), data->ndc[ml_cnt].
    s_field_1_brand_name = substring(0,50,brndmi.value), data->ndc[ml_cnt].s_field_2_generic_name =
    substring(0,50,mgenr.value),
    data->ndc[ml_cnt].s_field_3_theraputic_class = substring(0,50,c1.long_description), data->ndc[
    ml_cnt].s_field_4_dosage_form = uar_get_code_display(md.form_cd), data->ndc[ml_cnt].
    s_field_5_free_text_dose = trim(oedef.freetext_dose,3),
    data->ndc[ml_cnt].s_field_6_given_strength = trim(md.given_strength,3), data->ndc[ml_cnt].
    s_field_10_doserate = evaluate(oedef.infuse_over,- (1)," ",format(oedef.infuse_over,
      "##########.####;,IT(1);F")), data->ndc[ml_cnt].s_field_11_oedef_infuse_over_disp =
    uar_get_code_display(oedef.infuse_over_cd),
    data->ndc[ml_cnt].s_field_12_route = uar_get_code_display(oedef.route_cd), data->ndc[ml_cnt].
    s_field_13_manufacturer = evaluate(manf.manufacturer_cd,null," ",replace(uar_get_code_display(
       manf.manufacturer_cd),",","")), data->ndc[ml_cnt].s_field_14_oedef_frequency =
    uar_get_code_display(oedef.frequency_cd),
    data->ndc[ml_cnt].s_field_16_pyxis_interface_id = mipyx.value, data->ndc[ml_cnt].
    s_field_18_mdisp_volume = replace(format(mdisp.volume,"##########.##;,IRT(1);F"),",",""), data->
    ndc[ml_cnt].s_field_19_mdisp_volume_unit = uar_get_code_display(mdisp.volume_unit_cd),
    data->ndc[ml_cnt].s_field_20_strength = substring(0,20,evaluate(mdisp.strength,0.0,"",concat(trim
       (replace(format(mdisp.strength,"##########.##;,IRT(1);F"),",",""),3)," ",trim(
        uar_get_code_display(mdisp.strength_unit_cd),3)))), data->ndc[ml_cnt].s_formulary_status_disp
     = uar_get_code_display(md.formulary_status_cd), data->ndc[ml_cnt].n_oe_format_flag = md
    .oe_format_flag,
    data->ndc[ml_cnt].f_parent_item_id = md.parent_item_id
   ENDIF
  FOOT REPORT
   CALL alterlist(data->ndc,ml_cnt)
  WITH nocounter
 ;end select
 SELECT INTO value(ms_pharm_form_file)
  FROM (dummyt d  WITH seq = size(data->ndc,5))
  PLAN (d)
  HEAD REPORT
   line = build("field_0_ndc",",","field_1_brand_name",",","field_2_generic_name",
    ",","field_3_theraputic_class",",","field_4_dosage_form",",",
    "field_5_free_text_dose ",",","field_6_given_strength",",","field_10_doserate",
    ",","field_11_oedef_infuse_over_disp",",","field_12_route",",",
    "field_13_manufacturer",",","field_16_pyxis_interface_id",",","field_18_mdisp_volume",
    ",","field_19_mdisp_volume_unit",",","field_20_strength"), col 0, line,
   row + 1
  DETAIL
   line = build('"',data->ndc[d.seq].s_field_0_ndc,'","',data->ndc[d.seq].s_field_1_brand_name,'","',
    data->ndc[d.seq].s_field_2_generic_name,'","',data->ndc[d.seq].s_field_3_theraputic_class,'","',
    data->ndc[d.seq].s_field_4_dosage_form,
    '","',data->ndc[d.seq].s_field_5_free_text_dose,'","',data->ndc[d.seq].s_field_6_given_strength,
    '","',
    data->ndc[d.seq].s_field_10_doserate,'","',data->ndc[d.seq].s_field_11_oedef_infuse_over_disp,
    '","',data->ndc[d.seq].s_field_12_route,
    '","',data->ndc[d.seq].s_field_13_manufacturer,'","',data->ndc[d.seq].
    s_field_16_pyxis_interface_id,'","',
    data->ndc[d.seq].s_field_18_mdisp_volume,'","',data->ndc[d.seq].s_field_19_mdisp_volume_unit,
    '","',trim(data->ndc[d.seq].s_field_20_strength,3),
    '","',data->ndc[d.seq].s_formulary_status_disp,'","',data->ndc[d.seq].n_oe_format_flag,'","',
    data->ndc[d.seq].f_parent_item_id,'"'), col 0, line,
   row + 1
  WITH nocounter, format = variable, formfeed = none,
   maxcol = 2000, maxrow = 1
 ;end select
END GO
