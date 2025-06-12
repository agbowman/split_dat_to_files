CREATE PROGRAM ams_get_syn_link_for_product:dba
 PROMPT
  "item_id" = "",
  "facility_cd" = ""
  WITH linkitemid, faccd
 DECLARE active_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE orderable_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4063,"ORDERABLE"))
 DECLARE sys_pkg_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE inpatient_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
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
  link_ind = evaluate(sir.item_id,0.0,"NO","YES"), sort_order = evaluate(ocs.mnemonic_type_cd,
   syn_type_primary,0,1), ocs.synonym_id,
  ocs.mnemonic_key_cap, type = uar_get_code_display(ocs.mnemonic_type_cd)
  FROM order_catalog_item_r ocir,
   order_catalog_synonym ocs,
   synonym_item_r sir
  PLAN (ocir
   WHERE (ocir.item_id= $LINKITEMID))
   JOIN (ocs
   WHERE ocs.catalog_cd=ocir.catalog_cd
    AND ((ocs.active_ind=1
    AND  NOT (ocs.mnemonic_type_cd IN (syn_type_y, syn_type_z, syn_type_rx))) OR ((( EXISTS (
   (SELECT
    sir.synonym_id
    FROM synonym_item_r sir
    WHERE sir.item_id=ocir.item_id
     AND sir.synonym_id=ocs.synonym_id))) OR (ocs.mnemonic_type_cd=syn_type_rx
    AND  EXISTS (
   (SELECT
    mdf.item_id
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi
    WHERE mdf.item_id=ocs.item_id
     AND mdf.active_status_cd=active_type_cd
     AND mdf.flex_type_cd=sys_pkg_type_cd
     AND mdf.pharmacy_type_cd=inpatient_type_cd
     AND mfoi.med_def_flex_id=mdf.med_def_flex_id
     AND mfoi.flex_object_type_cd=orderable_type_cd
     AND mfoi.parent_entity_id IN (0,  $FACCD))))) )) )
   JOIN (sir
   WHERE sir.item_id=outerjoin( $LINKITEMID)
    AND sir.synonym_id=outerjoin(ocs.synonym_id))
  ORDER BY link_ind DESC, sort_order, type,
   ocs.mnemonic_key_cap, ocs.synonym_id
  HEAD REPORT
   stat = makedataset(20), mnemtypepos = addstringfield("MNEMTYPE","Type",visibile_ind,20),
   mnemonicpos = addstringfield("MNEMONIC","Synonym",visibile_ind,100),
   synidpos = addrealfield("SYNONYM_ID","synonym_id",invisibile_ind), stat = setkeyfield(synidpos,1)
  HEAD ocs.synonym_id
   recordpos = getnextrecord(0), stat = setstringfield(recordpos,mnemtypepos,trim(type)), stat =
   setstringfield(recordpos,mnemonicpos,trim(ocs.mnemonic)),
   stat = setrealfield(recordpos,synidpos,ocs.synonym_id)
   IF (sir.synonym_id > 0)
    stat = adddefaultkey(cnvtstring(sir.synonym_id))
   ENDIF
  FOOT REPORT
   stat = closedataset(0), stat = alterlist(reply->default_key_list,recordpos)
  WITH nocounter, reporthelp, check
 ;end select
END GO
