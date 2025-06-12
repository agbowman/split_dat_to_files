CREATE PROGRAM dcp_chk_orc_ec_reltn:dba
 SET failures = 0
 SET pharmacy_cd = 0.0
 SET code_value = 0.0
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharmacy_cd = code_value
 SELECT INTO "nl:"
  oc.*
  FROM order_catalog oc,
   (dummyt d  WITH seq = 1),
   v500_event_code ec,
   (dummyt d2  WITH seq = 1),
   code_value_event_r cve
  PLAN (oc
   WHERE pharmacy_cd=oc.catalog_type_cd)
   JOIN (d)
   JOIN (ec
   WHERE ec.event_cd_descr=oc.primary_mnemonic)
   JOIN (d2)
   JOIN (cve
   WHERE cve.parent_cd=oc.catalog_cd)
  DETAIL
   failures = (failures+ 1)
  WITH outerjoin = d2, dontexist
 ;end select
 SET request->setup_proc[1].process_id = 795
 IF (failures=0)
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg =
  "Pharmacy catalog codes with valid event codes have been updates successfully"
 ELSE
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "Update of pharmacy catalog codes with valid event codes FAILED"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
