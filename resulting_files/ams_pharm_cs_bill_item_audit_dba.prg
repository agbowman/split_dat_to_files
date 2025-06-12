CREATE PROGRAM ams_pharm_cs_bill_item_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  'Select Facility: (Leave blank to include products that are designated as "All Facilities")' = 0,
  "Charge Preference:" = "",
  "Include inactive products:" = 1,
  "" = "",
  "(Optional) Select up to 2 additional product identifiers to audit for:" = 0,
  "" = 0,
  "(Optional) Select up to 2 cost types to audit for:" = 0,
  "" = 0,
  "(Optional) Select up to 6 bill codes schedules to audit for (2 of each type below):" = "",
  "" = "",
  "Select HCPCS codes to audit for:" = "",
  "" = "",
  "Select CDM codes to audit for:" = "",
  "" = ""
  WITH outdev, selfac, dispchargesetting,
  selincludeinactive, whitespace, selprodident1,
  selprodident2, selcosttype1, selcosttype2,
  selrevcode1, selrevcode2, selhcpcscode1,
  selhcpcscode2, selcdmcode1, selcdmcode2
 DECLARE script_name = c28 WITH protect, constant("AMS_PHARM_CS_BILL_ITEM_AUDIT")
 DECLARE cd_active_stat = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE cd_pharm_inpat_type = f8 WITH constant(uar_get_code_by("MEANING",4500,"INPATIENT")), protect
 DECLARE cd_syspkgtype_flex_type = f8 WITH constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP")),
 protect
 DECLARE cd_system_flex_type = f8 WITH constant(uar_get_code_by("MEANING",4062,"SYSTEM")), protect
 DECLARE cd_orderable_flex_obj_type = f8 WITH constant(uar_get_code_by("MEANING",4063,"ORDERABLE")),
 protect
 DECLARE cd_ndc_ident_type = f8 WITH constant(uar_get_code_by("MEANING",11000,"NDC")), protect
 DECLARE cd_desc_ident_type = f8 WITH constant(uar_get_code_by("MEANING",11000,"DESC")), protect
 DECLARE cd_hcpcs_ident_type = f8 WITH constant(uar_get_code_by("MEANING",11000,"HCPCS")), protect
 DECLARE cd_cdm_ident_type = f8 WITH constant(uar_get_code_by("MEANING",11000,"CDM")), protect
 DECLARE cd_pyxis_ident_type = f8 WITH constant(uar_get_code_by("MEANING",11000,"PYXIS")), protect
 DECLARE cd_pharm_act_type = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY")), protect
 DECLARE chargepreference = i2 WITH protect
 DECLARE logicaldomainid = f8 WITH protect
 SET searchfac = - (2)
 SET trace = nocallecho
 EXECUTE ams_define_toolkit_common
 CALL updtdminfo(script_name,cnvtreal(1))
 SET trace = callecho
 SELECT DISTINCT
  preference = evaluate(dp.pref_nbr,1,"Drug Formulation","Manufactured Item"), dp.pref_nbr
  FROM dm_prefs dpx,
   dm_prefs dp
  PLAN (dpx
   WHERE dpx.pref_domain="PHARMNET-INPATIENT")
   JOIN (dp
   WHERE dp.pref_domain=outerjoin(dpx.pref_domain)
    AND dp.application_nbr=outerjoin(300000)
    AND dp.person_id=outerjoin(0)
    AND dp.pref_domain=outerjoin("PHARMNET-INPATIENT")
    AND dp.pref_section=outerjoin("BILLING")
    AND dp.pref_name=outerjoin("CDM OPTION"))
  DETAIL
   IF (dp.pref_nbr=1)
    chargepreference = 1
   ELSE
    chargepreference = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (( $SELFAC=0))
  SELECT INTO "nl:"
   p.logical_domain_id
   FROM prsnl p
   WHERE (p.person_id=reqinfo->updt_id)
   DETAIL
    IF (p.logical_domain_id != 0)
     logicaldomainid = p.logical_domain_id
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   GO TO exit_script
  ENDIF
  IF (logicaldomainid != 0)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT
  IF (chargepreference=1)
   FROM medication_definition md,
    med_def_flex mdf,
    order_catalog_item_r ocir,
    order_catalog oc,
    med_def_flex mdfx,
    med_flex_object_idx mfoi,
    code_value cv,
    med_flex_object_idx mfoix,
    med_def_flex mdf2,
    med_flex_object_idx mfoi2,
    med_oe_defaults mod,
    price_sched ps,
    med_identifier mi1,
    med_identifier mi2,
    med_identifier mi3,
    med_identifier mi4,
    med_identifier mi5,
    med_identifier mi6,
    med_identifier mi7,
    med_product mp,
    med_cost_hx mch,
    med_cost_hx mch2,
    package_type pt,
    package_type pt2,
    package_type pt3,
    bill_item bi,
    bill_item_modifier rev1,
    bill_item_modifier rev2,
    bill_item_modifier hcpcs1,
    bill_item_modifier hcpcs2,
    bill_item_modifier cdm1,
    bill_item_modifier cdm2
   PLAN (md
    WHERE md.med_type_flag IN (0, 1, 2))
    JOIN (mdf
    WHERE mdf.item_id=md.item_id
     AND mdf.pharmacy_type_cd=cd_pharm_inpat_type
     AND mdf.flex_type_cd=cd_syspkgtype_flex_type
     AND mdf.active_ind IN (1, cnvtint( $SELINCLUDEINACTIVE)))
    JOIN (ocir
    WHERE ocir.item_id=mdf.item_id)
    JOIN (oc
    WHERE oc.catalog_cd=ocir.catalog_cd)
    JOIN (mfoi
    WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
     AND mfoi.flex_object_type_cd=cd_orderable_flex_obj_type
     AND mfoi.parent_entity_id IN ( $SELFAC))
    JOIN (cv
    WHERE cv.code_value=mfoi.parent_entity_id)
    JOIN (mdfx
    WHERE mdfx.item_id=mdf.item_id
     AND mdfx.flex_type_cd=cd_system_flex_type)
    JOIN (mfoix
    WHERE mfoix.med_def_flex_id=mdfx.med_def_flex_id
     AND mfoix.parent_entity_name="MED_PRODUCT")
    JOIN (mch
    WHERE mch.med_product_id=outerjoin(mfoix.parent_entity_id)
     AND mch.cost_type_cd=outerjoin(cnvtreal( $SELCOSTTYPE1))
     AND mch.active_ind=outerjoin(1)
     AND mch.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
     AND mch.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (mch2
    WHERE mch2.med_product_id=outerjoin(mfoix.parent_entity_id)
     AND mch2.cost_type_cd=outerjoin(cnvtreal( $SELCOSTTYPE2))
     AND mch2.active_ind=outerjoin(1)
     AND mch2.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
     AND mch2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (mi1
    WHERE mi1.item_id=mdf.item_id
     AND mi1.med_product_id=mfoix.parent_entity_id
     AND mi1.med_identifier_type_cd=cd_ndc_ident_type
     AND mi1.pharmacy_type_cd=cd_pharm_inpat_type
     AND mi1.primary_ind=1)
    JOIN (mi2
    WHERE mi2.item_id=mdf.item_id
     AND mi2.med_product_id=0
     AND mi2.med_identifier_type_cd=cd_desc_ident_type
     AND mi2.pharmacy_type_cd=cd_pharm_inpat_type
     AND mi2.primary_ind=1)
    JOIN (mi3
    WHERE mi3.item_id=outerjoin(mdf.item_id)
     AND mi3.med_product_id=outerjoin(0)
     AND mi3.med_identifier_type_cd=outerjoin(cd_hcpcs_ident_type)
     AND mi3.pharmacy_type_cd=outerjoin(cd_pharm_inpat_type)
     AND mi3.primary_ind=outerjoin(1))
    JOIN (mi4
    WHERE mi4.item_id=outerjoin(mdf.item_id)
     AND mi4.med_product_id=outerjoin(0)
     AND mi4.med_identifier_type_cd=outerjoin(cnvtreal( $SELPRODIDENT1))
     AND mi4.pharmacy_type_cd=outerjoin(cd_pharm_inpat_type)
     AND mi4.primary_ind=outerjoin(1))
    JOIN (mi5
    WHERE mi5.item_id=outerjoin(mdf.item_id)
     AND mi5.med_product_id=outerjoin(0)
     AND mi5.med_identifier_type_cd=outerjoin(cnvtreal( $SELPRODIDENT2))
     AND mi5.pharmacy_type_cd=outerjoin(cd_pharm_inpat_type)
     AND mi5.primary_ind=outerjoin(1))
    JOIN (mi6
    WHERE mi6.item_id=outerjoin(mdf.item_id)
     AND mi6.med_product_id=outerjoin(0)
     AND mi6.med_identifier_type_cd=outerjoin(cd_cdm_ident_type)
     AND mi6.pharmacy_type_cd=outerjoin(cd_pharm_inpat_type)
     AND mi6.primary_ind=outerjoin(1))
    JOIN (mi7
    WHERE mi7.item_id=outerjoin(mdf.item_id)
     AND mi7.med_product_id=outerjoin(0)
     AND mi7.med_identifier_type_cd=outerjoin(cd_pyxis_ident_type)
     AND mi7.pharmacy_type_cd=outerjoin(cd_pharm_inpat_type)
     AND mi7.primary_ind=outerjoin(1))
    JOIN (mdf2
    WHERE mdf2.item_id=mdf.item_id
     AND mdf2.flex_type_cd=value(uar_get_code_by("MEANING",4062,"SYSTEM"))
     AND mdf2.pharmacy_type_cd=value(uar_get_code_by("MEANING",4500,"INPATIENT")))
    JOIN (mfoi2
    WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
     AND mfoi2.parent_entity_name="MED_OE_DEFAULTS")
    JOIN (mod
    WHERE mod.med_oe_defaults_id=mfoi2.parent_entity_id)
    JOIN (ps
    WHERE ps.price_sched_id=outerjoin(mod.price_sched_id)
     AND ps.active_ind=outerjoin(1))
    JOIN (mp
    WHERE mp.med_product_id=mfoix.parent_entity_id)
    JOIN (pt
    WHERE pt.item_id=mp.manf_item_id
     AND pt.base_package_type_ind=1)
    JOIN (pt2
    WHERE pt2.package_type_id=mp.inner_pkg_type_id)
    JOIN (pt3
    WHERE pt3.package_type_id=mp.outer_pkg_type_id)
    JOIN (bi
    WHERE bi.ext_parent_reference_id=outerjoin(mdfx.med_def_flex_id)
     AND bi.ext_owner_cd=outerjoin(cd_pharm_act_type)
     AND bi.active_ind=outerjoin(1)
     AND bi.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
     AND bi.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (rev1
    WHERE rev1.bill_item_id=outerjoin(bi.bill_item_id)
     AND rev1.key1_id=outerjoin(cnvtreal( $SELREVCODE1))
     AND rev1.active_ind=outerjoin(1)
     AND rev1.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
     AND rev1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (rev2
    WHERE rev2.bill_item_id=outerjoin(bi.bill_item_id)
     AND rev2.key1_id=outerjoin(cnvtreal( $SELREVCODE2))
     AND rev2.active_ind=outerjoin(1)
     AND rev2.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
     AND rev2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (hcpcs1
    WHERE hcpcs1.bill_item_id=outerjoin(bi.bill_item_id)
     AND hcpcs1.key1_id=outerjoin(cnvtreal( $SELHCPCSCODE1))
     AND hcpcs1.active_ind=outerjoin(1)
     AND hcpcs1.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
     AND hcpcs1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (hcpcs2
    WHERE hcpcs2.bill_item_id=outerjoin(bi.bill_item_id)
     AND hcpcs2.key1_id=outerjoin(cnvtreal( $SELHCPCSCODE2))
     AND hcpcs2.active_ind=outerjoin(1)
     AND hcpcs2.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
     AND hcpcs2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (cdm1
    WHERE cdm1.bill_item_id=outerjoin(bi.bill_item_id)
     AND cdm1.key1_id=outerjoin(cnvtreal( $SELCDMCODE1))
     AND cdm1.active_ind=outerjoin(1)
     AND cdm1.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
     AND cdm1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (cdm2
    WHERE cdm2.bill_item_id=outerjoin(bi.bill_item_id)
     AND cdm2.key1_id=outerjoin(cnvtreal( $SELCDMCODE2))
     AND cdm2.active_ind=outerjoin(1)
     AND cdm2.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
     AND cdm2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ELSE
  ENDIF
  INTO  $OUTDEV
  facility =
  IF (cv.code_value=0) substring(1,40,"All Facilities")
  ELSE substring(1,40,cv.display)
  ENDIF
  , generic = substring(1,100,oc.primary_mnemonic), product_active_ind = mdf.active_ind,
  mdf.item_id, item_type = evaluate(md.med_type_flag,0.00,"Product",1.00,"Repackaged item",
   2.00,"Compound",3.00,"IV Set",4.00,
   "Order Set","OTHER"), pha_description = replace(replace(substring(1,100,mi2.value),char(13),""),
   char(10),""),
  pha_charge_number = replace(replace(substring(1,100,mi6.value),char(13),""),char(10),""),
  pha_pyxis_id = replace(replace(substring(1,100,mi7.value),char(13),""),char(10),""), pha_hcpcs =
  replace(replace(substring(1,200,mi3.value),char(13),""),char(10),""),
  pha_price_schedule = replace(replace(substring(1,50,ps.price_sched_short_desc),char(13),""),char(10
    ),""), mfoix.sequence, ndc = replace(replace(substring(1,100,mi1.value),char(13),""),char(10),""),
  ndc_active_ind = mfoix.active_ind, pha_base = pt.qty, pha_base_uom = substring(1,40,
   uar_get_code_display(pt.uom_cd)),
  pha_inner = evaluate(cnvtstring(mp.inner_pkg_type_id),"0"," ",format(pt2.qty,
    "###############.###;,RI")), pha_inner_uom = evaluate(cnvtstring(mp.inner_pkg_type_id),"0"," ",
   substring(1,40,uar_get_code_display(pt2.uom_cd))), pha_outer = evaluate(cnvtstring(mp
    .outer_pkg_type_id),"0"," ",format(pt3.qty,"###############.###;,RI")),
  pha_outer_uom = evaluate(cnvtstring(mp.outer_pkg_type_id),"0"," ",substring(1,40,
    uar_get_code_display(pt3.uom_cd))), pha_cost_type_a = substring(1,40,uar_get_code_display(
    cnvtreal( $SELCOSTTYPE1))), pha_cost_a = evaluate(cnvtstring(mch.med_cost_hx_id),"0"," ",format(
    mch.cost,"###############.#####;,$RI")),
  pha_cost_type_b = substring(1,40,uar_get_code_display(cnvtreal( $SELCOSTTYPE2))), pha_cost_b =
  evaluate(cnvtstring(mch2.med_cost_hx_id),"0"," ",format(mch2.cost,"###############.#####;,$RI")),
  pha_cust_ident_type_1 = substring(1,40,uar_get_code_display(cnvtreal( $SELPRODIDENT1))),
  pha_cust_ident_1 = replace(replace(substring(1,200,mi4.value),char(13),""),char(10),""),
  pha_cust_ident_type_2 = substring(1,40,uar_get_code_display(cnvtreal( $SELPRODIDENT2))),
  pha_cust_ident_2 = replace(replace(substring(1,200,mi5.value),char(13),""),char(10),""),
  bi.bill_item_id, bill_item_description = replace(replace(substring(1,200,bi.ext_description),char(
     13),""),char(10),""), rev_code_1_type = substring(1,40,uar_get_code_display(cnvtreal(
      $SELREVCODE1))),
  rev_code_1 = substring(1,4,rev1.key6), rev_code_2_type = substring(1,40,uar_get_code_display(
    cnvtreal( $SELREVCODE2))), rev_code_2 = substring(1,4,rev2.key6),
  hcpcs_type_1 = substring(1,40,uar_get_code_display(cnvtreal( $SELHCPCSCODE1))), hcpcs_1 = substring
  (1,5,hcpcs1.key6), hcpcs_qcf_1 = evaluate(hcpcs1.key6," "," ",format(hcpcs1.bim1_nbr,"####.###")),
  hcpcs_type_2 = substring(1,40,uar_get_code_display(cnvtreal( $SELHCPCSCODE2))), hcpcs_2 = substring
  (1,5,hcpcs2.key6), hcpcs_qcf_2 = evaluate(hcpcs2.key6," "," ",format(hcpcs2.bim1_nbr,"####.###")),
  cdm_type_1 = substring(1,40,uar_get_code_display(cnvtreal( $SELCDMCODE1))), cdm_1 = substring(1,4,
   cdm1.key6), cdm_type_2 = substring(1,40,uar_get_code_display(cnvtreal( $SELCDMCODE2))),
  cdm_2 = substring(1,4,cdm2.key6)
  FROM medication_definition md,
   med_def_flex mdf,
   order_catalog_item_r ocir,
   order_catalog oc,
   med_def_flex mdfx,
   med_flex_object_idx mfoi,
   code_value cv,
   med_flex_object_idx mfoix,
   med_def_flex mdf2,
   med_flex_object_idx mfoi2,
   med_oe_defaults mod,
   price_sched ps,
   med_identifier mi1,
   med_identifier mi2,
   med_identifier mi3,
   med_identifier mi4,
   med_identifier mi5,
   med_identifier mi6,
   med_identifier mi7,
   med_product mp,
   med_cost_hx mch,
   med_cost_hx mch2,
   package_type pt,
   package_type pt2,
   package_type pt3,
   bill_item bi,
   bill_item_modifier rev1,
   bill_item_modifier rev2,
   bill_item_modifier hcpcs1,
   bill_item_modifier hcpcs2,
   bill_item_modifier cdm1,
   bill_item_modifier cdm2
  PLAN (md
   WHERE md.med_type_flag IN (0, 1, 2))
   JOIN (mdf
   WHERE md.item_id=mdf.item_id
    AND mdf.pharmacy_type_cd=cd_pharm_inpat_type
    AND mdf.flex_type_cd=cd_syspkgtype_flex_type
    AND mdf.active_ind IN (1, cnvtint( $SELINCLUDEINACTIVE)))
   JOIN (ocir
   WHERE ocir.item_id=mdf.item_id)
   JOIN (oc
   WHERE oc.catalog_cd=ocir.catalog_cd)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=cd_orderable_flex_obj_type
    AND mfoi.parent_entity_id IN ( $SELFAC))
   JOIN (cv
   WHERE cv.code_value=mfoi.parent_entity_id)
   JOIN (mdfx
   WHERE mdfx.item_id=mdf.item_id
    AND mdfx.flex_type_cd=cd_system_flex_type)
   JOIN (mfoix
   WHERE mfoix.med_def_flex_id=mdfx.med_def_flex_id
    AND mfoix.parent_entity_name="MED_PRODUCT")
   JOIN (mch
   WHERE mch.med_product_id=outerjoin(mfoix.parent_entity_id)
    AND mch.cost_type_cd=outerjoin(cnvtreal( $SELCOSTTYPE1))
    AND mch.active_ind=outerjoin(1)
    AND mch.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
    AND mch.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (mch2
   WHERE mch2.med_product_id=outerjoin(mfoix.parent_entity_id)
    AND mch2.cost_type_cd=outerjoin(cnvtreal( $SELCOSTTYPE2))
    AND mch2.active_ind=outerjoin(1)
    AND mch2.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
    AND mch2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (mi1
   WHERE mi1.item_id=mdf.item_id
    AND mi1.med_product_id=mfoix.parent_entity_id
    AND mi1.med_identifier_type_cd=cd_ndc_ident_type
    AND mi1.pharmacy_type_cd=cd_pharm_inpat_type
    AND mi1.primary_ind=1)
   JOIN (mi2
   WHERE mi2.item_id=mdf.item_id
    AND mi2.med_product_id=0
    AND mi2.med_identifier_type_cd=cd_desc_ident_type
    AND mi2.pharmacy_type_cd=cd_pharm_inpat_type
    AND mi2.primary_ind=1)
   JOIN (mi3
   WHERE mi3.item_id=outerjoin(mdf.item_id)
    AND mi3.med_product_id=outerjoin(0)
    AND mi3.med_identifier_type_cd=outerjoin(cd_hcpcs_ident_type)
    AND mi3.pharmacy_type_cd=outerjoin(cd_pharm_inpat_type)
    AND mi3.primary_ind=outerjoin(1))
   JOIN (mi4
   WHERE mi4.item_id=outerjoin(mdf.item_id)
    AND mi4.med_product_id=outerjoin(0)
    AND mi4.med_identifier_type_cd=outerjoin(cnvtreal( $SELPRODIDENT1))
    AND mi4.pharmacy_type_cd=outerjoin(cd_pharm_inpat_type)
    AND mi4.primary_ind=outerjoin(1))
   JOIN (mi5
   WHERE mi5.item_id=outerjoin(mdf.item_id)
    AND mi5.med_product_id=outerjoin(0)
    AND mi5.med_identifier_type_cd=outerjoin(cnvtreal( $SELPRODIDENT2))
    AND mi5.pharmacy_type_cd=outerjoin(cd_pharm_inpat_type)
    AND mi5.primary_ind=outerjoin(1))
   JOIN (mi6
   WHERE mi6.item_id=outerjoin(mdf.item_id)
    AND mi6.med_product_id=outerjoin(0)
    AND mi6.med_identifier_type_cd=outerjoin(cd_cdm_ident_type)
    AND mi6.pharmacy_type_cd=outerjoin(cd_pharm_inpat_type)
    AND mi6.primary_ind=outerjoin(1))
   JOIN (mi7
   WHERE mi7.item_id=outerjoin(mdf.item_id)
    AND mi7.med_product_id=outerjoin(0)
    AND mi7.med_identifier_type_cd=outerjoin(cd_pyxis_ident_type)
    AND mi7.pharmacy_type_cd=outerjoin(cd_pharm_inpat_type)
    AND mi7.primary_ind=outerjoin(1))
   JOIN (mdf2
   WHERE mdf2.item_id=mdf.item_id
    AND mdf2.flex_type_cd=value(uar_get_code_by("MEANING",4062,"SYSTEM"))
    AND mdf2.pharmacy_type_cd=value(uar_get_code_by("MEANING",4500,"INPATIENT")))
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
    AND mfoi2.parent_entity_name="MED_OE_DEFAULTS")
   JOIN (mod
   WHERE mod.med_oe_defaults_id=mfoi2.parent_entity_id)
   JOIN (ps
   WHERE ps.price_sched_id=outerjoin(mod.price_sched_id)
    AND ps.active_ind=outerjoin(1))
   JOIN (mp
   WHERE mp.med_product_id=mfoix.parent_entity_id)
   JOIN (pt
   WHERE pt.item_id=mp.manf_item_id
    AND pt.base_package_type_ind=1)
   JOIN (pt2
   WHERE pt2.package_type_id=mp.inner_pkg_type_id)
   JOIN (pt3
   WHERE pt3.package_type_id=mp.outer_pkg_type_id)
   JOIN (bi
   WHERE bi.ext_parent_reference_id=outerjoin(mp.manf_item_id)
    AND bi.ext_owner_cd=outerjoin(cd_pharm_act_type)
    AND bi.active_ind=outerjoin(1)
    AND bi.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
    AND bi.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (rev1
   WHERE rev1.bill_item_id=outerjoin(bi.bill_item_id)
    AND rev1.key1_id=outerjoin(cnvtreal( $SELREVCODE1))
    AND rev1.active_ind=outerjoin(1)
    AND rev1.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
    AND rev1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (rev2
   WHERE rev2.bill_item_id=outerjoin(bi.bill_item_id)
    AND rev2.key1_id=outerjoin(cnvtreal( $SELREVCODE2))
    AND rev2.active_ind=outerjoin(1)
    AND rev2.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
    AND rev2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (hcpcs1
   WHERE hcpcs1.bill_item_id=outerjoin(bi.bill_item_id)
    AND hcpcs1.key1_id=outerjoin(cnvtreal( $SELHCPCSCODE1))
    AND hcpcs1.active_ind=outerjoin(1)
    AND hcpcs1.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
    AND hcpcs1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (hcpcs2
   WHERE hcpcs2.bill_item_id=outerjoin(bi.bill_item_id)
    AND hcpcs2.key1_id=outerjoin(cnvtreal( $SELHCPCSCODE2))
    AND hcpcs2.active_ind=outerjoin(1)
    AND hcpcs2.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
    AND hcpcs2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (cdm1
   WHERE cdm1.bill_item_id=outerjoin(bi.bill_item_id)
    AND cdm1.key1_id=outerjoin(cnvtreal( $SELCDMCODE1))
    AND cdm1.active_ind=outerjoin(1)
    AND cdm1.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
    AND cdm1.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (cdm2
   WHERE cdm2.bill_item_id=outerjoin(bi.bill_item_id)
    AND cdm2.key1_id=outerjoin(cnvtreal( $SELCDMCODE2))
    AND cdm2.active_ind=outerjoin(1)
    AND cdm2.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
    AND cdm2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY cnvtupper(cv.display), cnvtupper(oc.primary_mnemonic), cnvtupper(mi2.value),
   mi2.item_id, mfoix.sequence
  WITH nocounter, separator = " ", format,
   format(date,";;q")
 ;end select
 SET last_mod = "000"
#exit_script
END GO
