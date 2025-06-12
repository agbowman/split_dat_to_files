CREATE PROGRAM bhs_rpt_rad_charge_master:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Program" = 0
  WITH outdev, s_prg_num
 DECLARE mf_cs6000_radiology = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"RADIOLOGY")),
 protect
 DECLARE mf_cs14002_cpt4modifier = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!23287")),
 protect
 DECLARE mf_cs14002_cpt4 = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3600")), protect
 DECLARE mf_cs13019_billcode = f8 WITH constant(uar_get_code_by("DISPLAYKEY",13019,"BILLCODE")),
 protect
 DECLARE mf_cs200_radiologybillonlys = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "RADIOLOGYBILLONLYS")), protect
 DECLARE mf_cs13016_taskassay = f8 WITH constant(uar_get_code_by("DISPLAYKEY",13016,"TASKASSAY")),
 protect
 IF (( $S_PRG_NUM=1))
  SELECT INTO  $OUTDEV
   order_primary_name = substring(1,100,oc.primary_mnemonic), catalog_code = oc.catalog_cd,
   order_activity_type = substring(1,100,uar_get_code_display(oc.activity_type_cd)),
   order_activity_subtype = substring(1,100,uar_get_code_display(oc.activity_subtype_cd)), oc
   .active_ind
   FROM order_catalog oc
   PLAN (oc
    WHERE oc.catalog_type_cd=mf_cs6000_radiology
     AND oc.active_ind=1)
   ORDER BY order_activity_subtype, oc.primary_mnemonic
   WITH nocounter, format, separator = " "
  ;end select
 ELSEIF (( $S_PRG_NUM=2))
  SELECT INTO  $OUTDEV
   order_primary_name = substring(1,100,oc.primary_mnemonic), dta = dta.mnemonic, oc.catalog_cd,
   order_activity_type = uar_get_code_display(oc.activity_type_cd), order_activity_subtype =
   uar_get_code_display(oc.activity_subtype_cd), order_active_ind = oc.active_ind,
   dta_active_ind = dta.active_ind
   FROM order_catalog oc,
    discrete_task_assay dta,
    profile_task_r ptr
   PLAN (ptr
    WHERE ptr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND dta.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=ptr.catalog_cd
     AND oc.active_ind=1
     AND oc.catalog_type_cd=mf_cs6000_radiology)
   ORDER BY oc.primary_mnemonic, dta.mnemonic
   WITH nocounter, format, separator = " "
  ;end select
 ELSEIF (( $S_PRG_NUM=3))
  SELECT INTO  $OUTDEV
   order_primary_name = substring(1,100,o.primary_mnemonic), dta = substring(1,100,bi1
    .ext_description), bill_code_schedule = uar_get_code_display(bim.key1_id),
   beg_effective_dt_tm = bim.beg_effective_dt_tm, end_effective_dt_tm = bim.end_effective_dt_tm,
   bill_code = substring(1,100,bim.key6),
   bill_code_description = substring(1,100,bim.key7), ext_owner_cd = uar_get_code_display(bi1
    .ext_owner_cd), priority = bim.bim1_int,
   cpt_thru_cdm = substring(1,20,bim1.key6)
   FROM order_catalog o,
    bill_item bi1,
    bill_item_modifier bim1,
    code_value csched,
    bill_item_modifier bim
   PLAN (o
    WHERE o.active_ind=1
     AND o.catalog_type_cd=mf_cs6000_radiology
     AND o.catalog_cd != mf_cs200_radiologybillonlys)
    JOIN (bi1
    WHERE bi1.ext_parent_reference_id=o.catalog_cd
     AND bi1.active_ind=1
     AND bi1.ext_child_contributor_cd=mf_cs13016_taskassay
     AND bi1.ext_child_entity_name="CODE_VALUE"
     AND  NOT (bi1.ext_child_reference_id IN (
    (SELECT
     cv1.code_value
     FROM code_value cv1
     WHERE cv1.code_set=14003
      AND cv1.active_ind=1
      AND cv1.display_key="RESULT"
     WITH format, time = 60))))
    JOIN (bim
    WHERE bim.bill_item_id=bi1.bill_item_id
     AND bim.bill_item_type_cd=mf_cs13019_billcode
     AND bim.key1_entity_name="CODE_VALUE"
     AND sysdate BETWEEN bim.beg_effective_dt_tm AND bim.end_effective_dt_tm)
    JOIN (csched
    WHERE csched.code_set=14002
     AND csched.cdf_meaning="CDM_SCHED"
     AND csched.active_ind=1
     AND csched.code_value=bim.key1_id)
    JOIN (bim1
    WHERE bim1.bill_item_id=bim.bill_item_id
     AND bim1.bill_item_type_cd=mf_cs13019_billcode
     AND bim1.key1_entity_name="CODE_VALUE"
     AND bim1.key1_id IN (mf_cs14002_cpt4))
   ORDER BY bi1.ext_owner_cd, o.primary_mnemonic, bi1.ext_description
   WITH nocounter, format, separator = " ",
    format(date,"mm/dd/yyyy hh:mm;;Q")
  ;end select
 ELSEIF (( $S_PRG_NUM=4))
  SELECT INTO  $OUTDEV
   bill_code_description = substring(1,100,uar_get_code_display(o.catalog_type_cd)),
   order_primary_name = substring(1,100,o.primary_mnemonic), dta = substring(1,100,bi1
    .ext_description),
   bill_item_activity_type = uar_get_code_display(o.activity_type_cd), order_activity_subtype =
   uar_get_code_display(o.activity_subtype_cd), bill_code_schedule = uar_get_code_display(bim1
    .key1_id),
   beg_effective_dt_tm = bim1.beg_effective_dt_tm, end_effective_dt_tm = bim1.end_effective_dt_tm,
   bill_code = substring(1,50,bim1.key6),
   bill_code_description = substring(1,200,bim1.key7), priority = bim1.bim1_int
   FROM order_catalog o,
    bill_item bi1,
    bill_item_modifier bim1
   PLAN (o
    WHERE o.active_ind=1
     AND o.catalog_type_cd=mf_cs6000_radiology
     AND o.catalog_cd != mf_cs200_radiologybillonlys)
    JOIN (bi1
    WHERE bi1.ext_parent_reference_id=o.catalog_cd
     AND bi1.active_ind=1
     AND bi1.ext_child_contributor_cd=mf_cs13016_taskassay
     AND bi1.ext_child_entity_name="CODE_VALUE")
    JOIN (bim1
    WHERE bim1.bill_item_id=bi1.bill_item_id
     AND bim1.bill_item_type_cd=mf_cs13019_billcode
     AND bim1.key1_entity_name="CODE_VALUE"
     AND bim1.key1_id IN (mf_cs14002_cpt4, mf_cs14002_cpt4modifier)
     AND sysdate BETWEEN bim1.beg_effective_dt_tm AND bim1.end_effective_dt_tm)
   ORDER BY o.primary_mnemonic
   WITH nocounter, format, separator = " ",
    format(date,"mm/dd/yyyy hh:mm;;Q")
  ;end select
 ENDIF
END GO
