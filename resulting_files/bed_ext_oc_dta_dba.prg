CREATE PROGRAM bed_ext_oc_dta:dba
 SELECT INTO "CER_INSTALL:ps_oc_dta.csv"
  FROM br_auto_oc_dta b,
   br_auto_order_catalog boc,
   br_auto_dta bdta
  PLAN (b)
   JOIN (boc
   WHERE boc.catalog_cd=b.catalog_cd)
   JOIN (bdta
   WHERE bdta.task_assay_cd=b.task_assay_cd)
  ORDER BY b.catalog_cd, b.sequence
  HEAD REPORT
   "primary_mnemonic,concept_cki,assay_mnemonic", primary = fillstring(100," "), concept_cki =
   fillstring(100," "),
   last_primary = fillstring(100,"x"), assay = fillstring(40," ")
  DETAIL
   IF (trim(boc.primary_mnemonic)=trim(last_primary))
    primary = " ", concept_cki = " "
   ELSE
    last_primary = boc.primary_mnemonic, primary = concat('"',trim(boc.primary_mnemonic),'"'),
    concept_cki = boc.concept_cki
   ENDIF
   assay = concat('"',trim(bdta.mnemonic),'"'), row + 1, line = concat(trim(primary),",",trim(
     concept_cki),",",trim(assay)),
   line
  WITH maxcol = 500, noformfeed, format = variable,
   nocounter
 ;end select
END GO
