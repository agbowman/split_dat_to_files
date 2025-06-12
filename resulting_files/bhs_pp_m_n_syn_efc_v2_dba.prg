CREATE PROGRAM bhs_pp_m_n_syn_efc_v2:dba
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  powerplan = pc.description, clinical_category = uar_get_code_display(p.dcp_clin_cat_cd),
  clinical_subcategory = uar_get_code_display(p.dcp_clin_sub_cat_cd),
  primary_mnemonic = uar_get_code_display(o.catalog_cd), synonym = o.mnemonic, synonym_type =
  uar_get_code_display(o.mnemonic_type_cd),
  os.order_sentence_display_line
  FROM pathway_comp p,
   order_catalog_synonym o,
   pathway_catalog pc,
   order_sentence os
  PLAN (p
   WHERE p.active_ind=1
    AND p.parent_entity_name="ORDER*")
   JOIN (o
   WHERE o.synonym_id=p.parent_entity_id
    AND o.catalog_type_cd=2516
    AND o.mnemonic_type_cd IN (614544, 614545))
   JOIN (pc
   WHERE pc.pathway_catalog_id=p.pathway_catalog_id
    AND pc.active_ind=1)
   JOIN (os
   WHERE os.parent_entity_id=outerjoin(p.pathway_comp_id))
  ORDER BY powerplan, clinical_category, clinical_subcategory
  WITH maxrec = 99999, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
