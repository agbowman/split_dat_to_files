CREATE PROGRAM aps_create_orderable_evt_cds
 RECORD internal(
   1 int_rec[*]
     2 catalog_cd = f8
     2 mnemonic = vc
 )
 FREE SET dm_post_event_code
 RECORD dm_post_event_code(
   1 event_set_name = c40
   1 event_cd_disp = c40
   1 event_cd_descr = c60
   1 event_cd_definition = c100
   1 status = c12
   1 format = c12
   1 storage = c12
   1 event_class = c12
   1 event_confid_level = c12
   1 event_subclass = c12
   1 event_code_status = c12
   1 event_cd = f8
   1 parent_cd = f8
   1 flex1_cd = f8
   1 flex2_cd = f8
   1 flex3_cd = f8
   1 flex4_cd = f8
   1 flex5_cd = f8
 )
 SET code_value = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET primary_cd = 0.0
 SET ap_cat_cd = 0.0
 SET ap_act_sub_cd = 0.0
 SET aps01_source_cd = 0.0
 SET aps02_source_cd = 0.0
 SET code_set = 6000
 SET cdf_meaning = "GENERAL LAB"
 EXECUTE cpm_get_cd_for_cdf
 SET ap_cat_cd = code_value
 SET code_set = 73
 SET cdf_meaning = "APS01"
 EXECUTE cpm_get_cd_for_cdf
 SET aps01_source_cd = code_value
 SET code_set = 73
 SET cdf_meaning = "APS02"
 EXECUTE cpm_get_cd_for_cdf
 SET aps02_source_cd = code_value
 SET code_set = 5801
 SET cdf_meaning = "APREPORT"
 EXECUTE cpm_get_cd_for_cdf
 SET ap_act_sub_cd = code_value
 SET code_set = 6011
 SET cdf_meaning = "PRIMARY"
 EXECUTE cpm_get_cd_for_cdf
 SET primary_cd = code_value
 SET cnt = 0
 SET x = 0
 SELECT INTO "NL:"
  oc.seq, oc.catalog_cd, oc.catalog_type_cd,
  oc.activity_type_cd, ocs.mnemonic_type_cd, ocs.mnemonic
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.catalog_type_cd=ap_cat_cd
    AND oc.activity_subtype_cd=ap_act_sub_cd
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND ocs.mnemonic_type_cd=primary_cd
    AND ocs.active_ind=1)
  ORDER BY ocs.mnemonic
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->int_rec,cnt), internal->int_rec[cnt].catalog_cd = oc
   .catalog_cd,
   internal->int_rec[cnt].mnemonic = ocs.mnemonic
  WITH nocounter
 ;end select
 CALL echo(build("count :",cnt))
 FOR (x = 1 TO cnt)
   SET dm_post_event_code->event_set_name = substring(1,40,internal->int_rec[x].mnemonic)
   SET dm_post_event_code->event_cd_disp = substring(1,40,internal->int_rec[x].mnemonic)
   SET dm_post_event_code->event_cd_descr = substring(1,60,internal->int_rec[x].mnemonic)
   SET dm_post_event_code->event_cd_definition = internal->int_rec[x].mnemonic
   SET dm_post_event_code->status = "ACTIVE"
   SET dm_post_event_code->format = "UNKNOWN"
   SET dm_post_event_code->storage = "UNKNOWN"
   SET dm_post_event_code->event_class = "MDOC"
   SET dm_post_event_code->event_confid_level = "ROUTCLINICAL"
   SET dm_post_event_code->event_subclass = "UNKNOWN"
   SET dm_post_event_code->event_code_status = "AUTH"
   SET dm_post_event_code->event_cd = 0.0
   SET dm_post_event_code->parent_cd = internal->int_rec[x].catalog_cd
   SET dm_post_event_code->flex1_cd = 0.0
   SET dm_post_event_code->flex2_cd = 0.0
   SET dm_post_event_code->flex3_cd = 0.0
   SET dm_post_event_code->flex4_cd = 0.0
   SET dm_post_event_code->flex5_cd = 0.0
   EXECUTE dm_post_event_code
   CALL echo(build("added :",dm_post_event_code->event_cd_disp,"->",dm_post_event_code->parent_cd,
     "->",
     dm_post_event_code->event_cd))
 ENDFOR
 SET dm_post_event_code->event_set_name = "ANATOMPATH"
 SET dm_post_event_code->event_cd_disp = "Anatomic Pathology"
 SET dm_post_event_code->event_cd_descr = "Anatomic Pathology"
 SET dm_post_event_code->event_cd_definition = "Anatomic Pathology"
 SET dm_post_event_code->status = "ACTIVE"
 SET dm_post_event_code->format = "UNKNOWN"
 SET dm_post_event_code->storage = "UNKNOWN"
 SET dm_post_event_code->event_class = "AP"
 SET dm_post_event_code->event_confid_level = "ROUTCLINICAL"
 SET dm_post_event_code->event_subclass = "UNKNOWN"
 SET dm_post_event_code->event_code_status = "AUTH"
 SET dm_post_event_code->event_cd = 0.0
 SET dm_post_event_code->parent_cd = aps01_source_cd
 SET dm_post_event_code->flex1_cd = 0.0
 SET dm_post_event_code->flex2_cd = 0.0
 SET dm_post_event_code->flex3_cd = 0.0
 SET dm_post_event_code->flex4_cd = 0.0
 SET dm_post_event_code->flex5_cd = 0.0
 EXECUTE dm_post_event_code
 CALL echo(build("added :",dm_post_event_code->event_cd_disp,"->",dm_post_event_code->parent_cd,"->",
   dm_post_event_code->event_cd))
 SET dm_post_event_code->event_set_name = "AP IMAGING"
 SET dm_post_event_code->event_cd_disp = "AP Imaging"
 SET dm_post_event_code->event_cd_descr = "AP Imaging"
 SET dm_post_event_code->event_cd_definition = "AP Imaging"
 SET dm_post_event_code->status = "ACTIVE"
 SET dm_post_event_code->format = "UNKNOWN"
 SET dm_post_event_code->storage = "UNKNOWN"
 SET dm_post_event_code->event_class = "DOC"
 SET dm_post_event_code->event_confid_level = "ROUTCLINICAL"
 SET dm_post_event_code->event_subclass = "UNKNOWN"
 SET dm_post_event_code->event_code_status = "AUTH"
 SET dm_post_event_code->event_cd = 0.0
 SET dm_post_event_code->parent_cd = aps02_source_cd
 SET dm_post_event_code->flex1_cd = 0.0
 SET dm_post_event_code->flex2_cd = 0.0
 SET dm_post_event_code->flex3_cd = 0.0
 SET dm_post_event_code->flex4_cd = 0.0
 SET dm_post_event_code->flex5_cd = 0.0
 EXECUTE dm_post_event_code
 CALL echo(build("added :",dm_post_event_code->event_cd_disp,"->",dm_post_event_code->parent_cd,"->",
   dm_post_event_code->event_cd))
END GO
