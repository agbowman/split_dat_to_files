CREATE PROGRAM bhs_pp_med_syn_sent_efc:dba
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
  powerplan = p.description, o.mnemonic, o_mnemonic_type_disp = uar_get_code_display(o
   .mnemonic_type_cd),
  pc_dcp_clin_cat_disp = uar_get_code_display(pc.dcp_clin_cat_cd), os.order_sentence_display_line
  FROM pathway_catalog p,
   pathway_comp pc,
   order_catalog_synonym o,
   pw_comp_os_reltn pco,
   order_sentence os
  PLAN (p
   WHERE p.active_ind=1)
   JOIN (pc
   WHERE pc.pathway_catalog_id=p.pathway_catalog_id
    AND pc.comp_type_cd=10736
    AND pc.dcp_clin_cat_cd=10577)
   JOIN (o
   WHERE o.synonym_id=pc.parent_entity_id)
   JOIN (pco
   WHERE pco.pathway_comp_id=outerjoin(pc.pathway_comp_id))
   JOIN (os
   WHERE os.order_sentence_id=outerjoin(pco.order_sentence_id)
    AND os.order_sentence_display_line IN ("*Pain*", "*pain*", "*PAIN*"))
  ORDER BY powerplan, o.mnemonic
  WITH maxrec = 99999, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
