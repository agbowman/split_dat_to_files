CREATE PROGRAM ams_get_syn_vv_for_product:dba
 PROMPT
  "item_id" = "",
  "facility_cd" = ""
  WITH itemid, facilitycd
 DECLARE syn_type_rx = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC"))
 DECLARE syn_type_y = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICPROD"))
 DECLARE syn_type_z = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADEPROD"))
 DECLARE syn_type_primary = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE mnemonicpos = i4 WITH protect
 DECLARE mnemtypepos = i4 WITH protect
 DECLARE synidpos = i4 WITH protect
 DECLARE recordpos = i4 WITH protect
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SELECT INTO "nl:"
  vv_ind = evaluate(ofr.synonym_id,0.0,"NO","YES"), sort_order = evaluate(ocs.mnemonic_type_cd,
   syn_type_primary,0,1), ocs.synonym_id,
  ocs.mnemonic_key_cap, type = uar_get_code_display(ocs.mnemonic_type_cd), ofr.facility_cd
  FROM order_catalog_item_r ocir,
   order_catalog_synonym ocs,
   ocs_facility_r ofr
  PLAN (ocir
   WHERE (ocir.item_id= $ITEMID))
   JOIN (ocs
   WHERE ocs.catalog_cd=ocir.catalog_cd
    AND ocs.hide_flag=0
    AND ocs.active_ind=1
    AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx, syn_type_y, syn_type_z)))
   JOIN (ofr
   WHERE ofr.synonym_id=outerjoin(ocs.synonym_id)
    AND ofr.facility_cd=outerjoin( $FACILITYCD))
  ORDER BY vv_ind DESC, sort_order, type,
   ocs.mnemonic_key_cap, ocs.synonym_id
  HEAD REPORT
   stat = makedataset(20), mnemtypepos = addstringfield("MNEMTYPE","Type",visibile_ind,20),
   mnemonicpos = addstringfield("MNEMONIC","Synonym",visibile_ind,100),
   synidpos = addrealfield("SYNONYM_ID","synonym_id",invisibile_ind), stat = setkeyfield(synidpos,1)
  HEAD ocs.synonym_id
   recordpos = getnextrecord(0), stat = setstringfield(recordpos,mnemtypepos,trim(type)), stat =
   setstringfield(recordpos,mnemonicpos,trim(ocs.mnemonic)),
   stat = setrealfield(recordpos,synidpos,ocs.synonym_id)
   IF (ofr.facility_cd > 0)
    stat = adddefaultkey(cnvtstring(ocs.synonym_id))
   ENDIF
  FOOT REPORT
   stat = closedataset(0), stat = alterlist(reply->default_key_list,recordpos)
  WITH nocounter, reporthelp, check
 ;end select
END GO
