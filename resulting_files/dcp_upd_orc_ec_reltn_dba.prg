CREATE PROGRAM dcp_upd_orc_ec_reltn:dba
 RECORD catalogs(
   1 catalog_cnt = i2
   1 catalog[*]
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 event_cd = f8
 )
 SET count1 = 0
 SET pharmacy_cd = 0.0
 SET code_value = 0.0
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy_cd = code_value
 SELECT INTO "nl:"
  oc.catalog_cd
  FROM order_catalog oc,
   (dummyt d  WITH seq = 1),
   code_value_event_r cve
  PLAN (oc
   WHERE pharmacy_cd=oc.catalog_type_cd)
   JOIN (d)
   JOIN (cve
   WHERE cve.parent_cd=oc.catalog_cd)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(catalogs->catalog,5))
    stat = alterlist(catalogs->catalog,(count1+ 5))
   ENDIF
   catalogs->catalog[count1].catalog_cd = oc.catalog_cd, catalogs->catalog[count1].primary_mnemonic
    = oc.primary_mnemonic, catalogs->catalog[count1].event_cd = 0.0
  FOOT REPORT
   catalogs->catalog_cnt = count1, stat = alterlist(catalogs->catalog,count1)
  WITH outerjoin = d, dontexist
 ;end select
 SET nbr_to_check = size(catalogs->catalog,5)
 IF (nbr_to_check > 0)
  SELECT INTO "nl:"
   ec.event_cd, x = d.seq
   FROM (dummyt d  WITH seq = value(nbr_to_check)),
    v500_event_code ec
   PLAN (d)
    JOIN (ec
    WHERE (((catalogs->catalog[d.seq].primary_mnemonic=ec.event_cd_descr)) OR ((catalogs->catalog[d
    .seq].primary_mnemonic=ec.event_cd_definition))) )
   DETAIL
    catalogs->catalog[x].event_cd = ec.event_cd
   WITH check
  ;end select
  INSERT  FROM code_value_event_r cve,
    (dummyt d  WITH seq = value(catalogs->catalog_cnt))
   SET cve.parent_cd = catalogs->catalog[d.seq].catalog_cd, cve.event_cd = catalogs->catalog[d.seq].
    event_cd
   PLAN (d
    WHERE (catalogs->catalog[d.seq].catalog_cd > 0)
     AND (catalogs->catalog[d.seq].event_cd > 0))
    JOIN (cve)
   WITH check
  ;end insert
  IF (curqual > 0)
   IF (validate(readme_data->readme_id,0) > 0)
    SET readme_data->message = build("PVReadMe 1111: ",curqual,
     " rows successfully added to code_value_event_r.")
   ELSE
    CALL echo(build("Success"))
   ENDIF
  ELSE
   IF (validate(readme_data->readme_id,0) > 0)
    SET readme_data->message = build("PVReadMe 1111: No update needed.")
   ELSE
    CALL echo(build("No update needed"))
   ENDIF
  ENDIF
  IF (validate(readme_data->readme_id,0) > 0)
   SET readme_data->status = "S"
   EXECUTE dm_readme_status
  ENDIF
  COMMIT
 ELSE
  IF (validate(readme_data->readme_id,0) > 0)
   SET readme_data->message = build("PVReadMe 1111: No Pharmacy items defined. No update needed")
   SET readme_data->status = "S"
   EXECUTE dm_readme_status
  ENDIF
 ENDIF
END GO
