CREATE PROGRAM bed_ext_other_names:dba
 SET latest_start_version = 0
 SELECT DISTINCT INTO "NL:"
  b.start_version_nbr
  FROM br_client b
  ORDER BY b.start_version_nbr
  DETAIL
   latest_start_version = b.start_version_nbr
  WITH skipbedrock = 1, nocounter
 ;end select
 SELECT INTO "CER_INSTALL:other_names.csv"
  FROM br_other_names b,
   order_catalog oc,
   br_auto_order_catalog boc
  PLAN (b
   WHERE b.parent_entity_name="CODE_VALUE")
   JOIN (oc
   WHERE oc.active_ind=outerjoin(1)
    AND oc.catalog_cd=outerjoin(b.parent_entity_id)
    AND oc.start_version_nbr=outerjoin(latest_start_version))
   JOIN (boc
   WHERE boc.catalog_cd=outerjoin(b.parent_entity_id))
  ORDER BY b.parent_entity_id
  HEAD REPORT
   "primary_name,alias_name,concept_cki"
  DETAIL
   IF (oc.catalog_cd > 0)
    primary = concat('"',trim(oc.primary_mnemonic),'"'), concept_cki = concat('"',trim(oc.concept_cki
      ),'"')
   ELSE
    primary = concat('"',trim(boc.primary_mnemonic),'"'), concept_cki = concat('"',trim(boc
      .concept_cki),'"')
   ENDIF
   alias = concat('"',trim(b.alias_name),'"'), row + 1, line = concat(trim(primary),",",trim(alias),
    ",",trim(concept_cki)),
   line
  WITH maxcol = 500, maxrow = 1, noformfeed,
   format = variable, nocounter
 ;end select
END GO
