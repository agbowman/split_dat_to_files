CREATE PROGRAM ams_get_product_synonyms:dba
 PROMPT
  "item_id" = "",
  "user's facility_cd" = ""
  WITH itemid, userfaccd
 DECLARE getdummyorg(null) = f8 WITH protect
 DECLARE syn_type_rx = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"RXMNEMONIC"))
 DECLARE syn_type_y = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICPROD"))
 DECLARE syn_type_z = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADEPROD"))
 DECLARE syn_type_primary = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE active_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dummy_org_cd = f8 WITH protect, constant(getdummyorg(null))
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE recordpos = i4 WITH protect
 DECLARE synpos = i4 WITH protect
 DECLARE synonymidpos = i4 WITH protect
 DECLARE vvind = i2 WITH protect
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SELECT INTO "nl:"
  ocs.synonym_id, ocs.mnemonic, vv_setting = evaluate(ofr2.synonym_id,0.0,0,1)
  FROM synonym_item_r sir,
   ocs_facility_r ofr,
   order_catalog_synonym ocs,
   ocs_facility_r ofr2
  PLAN (sir
   WHERE (sir.item_id= $ITEMID))
   JOIN (ofr
   WHERE ofr.synonym_id=sir.synonym_id
    AND ofr.facility_cd=dummy_org_cd)
   JOIN (ocs
   WHERE ocs.synonym_id=ofr.synonym_id
    AND ocs.active_ind=1
    AND ocs.hide_flag=0
    AND  NOT (ocs.mnemonic_type_cd IN (syn_type_rx, syn_type_y, syn_type_z)))
   JOIN (ofr2
   WHERE ofr2.synonym_id=outerjoin(ocs.synonym_id)
    AND ofr2.facility_cd=outerjoin( $USERFACCD))
  ORDER BY vv_setting DESC, ocs.mnemonic_key_cap
  HEAD REPORT
   stat = makedataset(20), synpos = addstringfield("SYNONYM","Synonym",visibile_ind,100),
   synonymidpos = addrealfield("SYNONYM_ID","synonym_id",invisibile_ind),
   stat = setkeyfield(synonymidpos,1)
  DETAIL
   recordpos = getnextrecord(0), stat = setstringfield(recordpos,synpos,trim(ocs.mnemonic)), stat =
   setrealfield(recordpos,synonymidpos,ocs.synonym_id)
   IF (ofr2.synonym_id > 0.0)
    stat = adddefaultkey(cnvtstring(ofr2.synonym_id))
   ENDIF
  FOOT REPORT
   stat = closedataset(0), stat = alterlist(reply->default_key_list,recordpos)
  WITH nocounter, reporthelp, check
 ;end select
 SUBROUTINE getdummyorg(null)
   DECLARE retval = f8 WITH protect
   SELECT INTO "nl:"
    dm.pref_cd
    FROM dm_prefs dm
    PLAN (dm
     WHERE dm.pref_domain="AMS_TOOLKIT"
      AND dm.pref_section="AMS_PHARM_FLEXING_UTILITY"
      AND dm.pref_name="DUMMY_ORG")
    DETAIL
     retval = dm.pref_cd
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
END GO
