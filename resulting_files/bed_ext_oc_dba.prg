CREATE PROGRAM bed_ext_oc:dba
 SET active_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
  DETAIL
   active_cd = cv.code_value
  WITH nocounter
 ;end select
 SET pharm_catalog_type = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=6000
   AND cv.cdf_meaning="PHARMACY"
  DETAIL
   pharm_catalog_type = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "CER_INSTALL:ps_oc.csv"
  FROM br_auto_order_catalog b,
   br_auto_oc_synonym syn,
   code_value cv106,
   code_value cv16389,
   code_value cv6011,
   code_value cv6000,
   code_value cv5801,
   code_value cv6003,
   order_entry_format oef
  PLAN (b)
   JOIN (syn
   WHERE b.catalog_cd=syn.catalog_cd)
   JOIN (cv6003
   WHERE cv6003.active_ind=1
    AND cv6003.cdf_meaning="ORDER")
   JOIN (oef
   WHERE oef.oe_format_id=b.oe_format_id
    AND oef.action_type_cd=cv6003.code_value)
   JOIN (cv6011
   WHERE cv6011.active_ind=1
    AND cv6011.code_value=syn.mnemonic_type_cd)
   JOIN (cv6000
   WHERE cv6000.active_ind=1
    AND cv6000.code_value=b.catalog_type_cd)
   JOIN (cv106
   WHERE cv106.active_ind=outerjoin(1)
    AND cv106.code_value=outerjoin(b.activity_type_cd))
   JOIN (cv5801
   WHERE cv5801.active_ind=outerjoin(1)
    AND cv5801.code_value=outerjoin(b.activity_subtype_cd))
   JOIN (cv16389
   WHERE cv16389.active_ind=outerjoin(1)
    AND cv16389.code_value=outerjoin(b.dcp_clin_cat_cd))
  ORDER BY b.catalog_type_cd, b.activity_type_cd, b.activity_subtype_cd,
   b.description, cv6011.display DESC
  HEAD REPORT
   "source,catalog_type_cd,activity_type_cd,activity_subtype_cd,description,hna_mnemonic,",
   "mnemonic_type,mnemonic,dept_name,order_entry_format,concept_cki,dcp_clin_cat_cd,cpt4,loinc,catalog_cki,",
   "catalog_type_mean, activity_type_mean, activity_subtype_mean,dcp_mean,mnemonic_type_mean"
  HEAD b.catalog_cd
   hna_mnemonic = concat('"',trim(b.primary_mnemonic),'"'), description = concat('"',trim(b
     .description),'"'), dept_name = concat('"',trim(b.dept_name),'"'),
   cpt4 = concat('"',trim(b.cpt4),'"'), loinc = concat('"',trim(b.loinc),'"'), catalog_type = concat(
    '"',trim(cv6000.display),'"'),
   catalog_type_mean = concat('"',trim(cv6000.cdf_meaning),'"'), concept_cki = concat('"',trim(b
     .concept_cki),'"'), catalog_cki = concat('"',trim(b.cki),'"')
   IF (b.activity_type_cd > 0)
    activity_type = concat('"',trim(cv106.display),'"'), activity_type_mean = concat('"',trim(cv106
      .cdf_meaning),'"')
   ELSE
    activity_type = " ", activity_type_mean = " "
   ENDIF
   IF (b.activity_subtype_cd > 0)
    activity_subtype = concat('"',trim(cv5801.display),'"'), activity_subtype_mean = concat('"',trim(
      cv5801.cdf_meaning),'"')
   ELSE
    activity_subtype = " ", activity_subtype_mean = " "
   ENDIF
   IF (b.oe_format_id > 0)
    oef_name = concat('"',trim(oef.oe_format_name),'"')
   ELSE
    oef_name = " "
   ENDIF
   IF (b.dcp_clin_cat_cd > 0)
    dcp = concat('"',trim(cv16389.display),'"'), dcp_mean = concat('"',trim(cv16389.cdf_meaning),'"')
   ELSE
    dcp = " ", dcp_mean = " "
   ENDIF
  DETAIL
   mnemonic = concat('"',trim(syn.mnemonic),'"'), mnemonic_type = concat('"',trim(cv6011.display),'"'
    ), mnemonic_type_mean = concat('"',trim(cv6011.cdf_meaning),'"'),
   row + 1, line = concat("AUTOBUILD,",trim(catalog_type),",",trim(activity_type),",",
    trim(activity_subtype),",",trim(description),",",trim(hna_mnemonic),
    ",",trim(mnemonic_type),",",trim(mnemonic),",",
    trim(dept_name),",",trim(oef_name),",",trim(concept_cki),
    ",",trim(dcp),",",trim(cpt4),",",
    trim(loinc),",",trim(catalog_cki),",",trim(catalog_type_mean),
    ",",trim(activity_type_mean),",",trim(activity_subtype_mean),",",
    trim(dcp_mean),",",trim(mnemonic_type_mean)), line
  WITH maxcol = 2000, maxrow = 1, noformfeed,
   format = variable, nocounter
 ;end select
END GO
