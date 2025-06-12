CREATE PROGRAM bhs_rpt_ndc_mult_brand:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter all or part of the product's brand name: " = "*brand name*"
  WITH outdev, partial_brand
 SELECT INTO  $OUTDEV
  mb.brand_description, md.ndc_formatted, m.drug_name,
  strength = mp.product_strength_description, doseform = mdf.dose_form_description, md
  .inner_package_size,
  mu.unit_abbr, md.outer_package_size, mfg = mns.source_desc,
  md.obsolete_date
  FROM mltm_ndc_brand_name mb,
   mltm_ndc_core_description md,
   mltm_mmdc_name_map mmn,
   mltm_drug_name m,
   mltm_dose_form mdf,
   mltm_product_strength mp,
   mltm_ndc_main_drug_code mnm,
   mltm_units mu,
   mltm_ndc_source mns
  PLAN (mb
   WHERE (mb.brand_description= $PARTIAL_BRAND))
   JOIN (md
   WHERE mb.brand_code=md.brand_code
    AND md.obsolete_date = null)
   JOIN (mmn
   WHERE md.main_multum_drug_code=mmn.main_multum_drug_code
    AND mmn.function_id=16)
   JOIN (m
   WHERE mmn.drug_synonym_id=m.drug_synonym_id)
   JOIN (mnm
   WHERE md.main_multum_drug_code=mnm.main_multum_drug_code)
   JOIN (mp
   WHERE mnm.product_strength_code=mp.product_strength_code)
   JOIN (mdf
   WHERE mnm.dose_form_code=mdf.dose_form_code)
   JOIN (mu
   WHERE outerjoin(md.inner_package_desc_code)=mu.unit_id)
   JOIN (mns
   WHERE md.source_id=mns.source_id)
  WITH format, separator = " "
 ;end select
END GO
