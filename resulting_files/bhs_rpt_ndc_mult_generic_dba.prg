CREATE PROGRAM bhs_rpt_ndc_mult_generic:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter partial generic name all in lowercase: " = "*drugname*"
  WITH outdev, partial_generic
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  md.ndc_formatted, m.drug_name, mmdc = mmn.main_multum_drug_code,
  strength = mp.product_strength_description, doseform = mdf.dose_form_description, md
  .inner_package_size,
  mu.unit_abbr, md.outer_package_size, mn.brand_description,
  mfg = mns.source_desc, md.obsolete_date
  FROM mltm_drug_name_map mm,
   mltm_drug_name m,
   mltm_dose_form mdf,
   mltm_product_strength mp,
   mltm_ndc_main_drug_code mnm,
   mltm_units mu,
   mltm_ndc_core_description md,
   mltm_mmdc_name_map mmn,
   mltm_ndc_brand_name mn,
   mltm_ndc_source mns
  PLAN (mm
   WHERE mm.function_id=59)
   JOIN (m
   WHERE m.drug_synonym_id=mm.drug_synonym_id
    AND (m.drug_name= $PARTIAL_GENERIC))
   JOIN (mmn
   WHERE m.drug_synonym_id=mmn.drug_synonym_id
    AND mm.function_id=mmn.function_id)
   JOIN (md
   WHERE mmn.main_multum_drug_code=md.main_multum_drug_code
    AND md.obsolete_date = null)
   JOIN (mu
   WHERE outerjoin(md.inner_package_desc_code)=mu.unit_id)
   JOIN (mnm
   WHERE md.main_multum_drug_code=mnm.main_multum_drug_code)
   JOIN (mp
   WHERE mnm.product_strength_code=mp.product_strength_code)
   JOIN (mdf
   WHERE mnm.dose_form_code=mdf.dose_form_code)
   JOIN (mn
   WHERE md.brand_code=mn.brand_code)
   JOIN (mns
   WHERE md.source_id=mns.source_id)
  ORDER BY mm.function_id, m.drug_name
  WITH time = value(maxsecs), format, separator = " "
 ;end select
END GO
