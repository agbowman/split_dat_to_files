CREATE PROGRAM bhs_rpt_all_cdms
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter CDM number with wild card (* )" = ""
  WITH outdev, cdm
 RECORD requestin(
   1 list_0[*]
     2 cdm = vc
     2 desc = vc
 )
 SET stat = alterlist(requestin->list_0,1)
 FOR (x = 1 TO size(requestin->list_0,5))
   SET requestin->list_0[x].cdm = substring(1,7,trim(requestin->list_0[x].cdm,3))
 ENDFOR
 SELECT INTO  $OUTDEV
  oc.description, oc.catalog_cd, ocs.mnemonic,
  synonym_code = uar_get_code_display(ocs.mnemonic_type_cd), order_description = bi.ext_description,
  cdm = bim.key6,
  charge_description = bim.key7, itemmatch =
  IF (trim(cnvtupper(oc.description),3)=trim(cnvtupper(bim.key7),3)) "YES"
  ELSE "NO"
  ENDIF
  FROM bill_item bi,
   bill_item_modifier bim,
   (dummyt d  WITH seq = size(requestin->list_0,5)),
   order_catalog oc,
   order_catalog_synonym ocs
  PLAN (d)
   JOIN (bim
   WHERE bim.key6=outerjoin(requestin->list_0[d.seq].cdm))
   JOIN (bi
   WHERE bi.bill_item_id=outerjoin(bim.bill_item_id)
    AND bi.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=outerjoin(bi.ext_parent_reference_id))
   JOIN (ocs
   WHERE ocs.catalog_cd=outerjoin(oc.catalog_cd)
    AND ocs.active_ind=outerjoin(1))
  ORDER BY bim.key6, oc.description
  WITH nocounter, format, separator = " "
 ;end select
END GO
