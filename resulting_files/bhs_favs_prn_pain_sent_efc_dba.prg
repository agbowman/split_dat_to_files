CREATE PROGRAM bhs_favs_prn_pain_sent_efc:dba
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
  p.name_full_formatted, p.username, folder_name = ascl.long_description,
  oc.mnemonic, os.order_sentence_display_line
  FROM order_catalog o,
   order_catalog_synonym oc,
   alt_sel_list a,
   alt_sel_cat ascl,
   order_sentence os,
   prsnl p
  PLAN (o
   WHERE o.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd
    AND oc.dcp_clin_cat_cd=10577)
   JOIN (a
   WHERE a.synonym_id=oc.synonym_id)
   JOIN (ascl
   WHERE ascl.alt_sel_category_id=a.alt_sel_category_id)
   JOIN (os
   WHERE os.order_sentence_id=a.order_sentence_id
    AND os.order_sentence_display_line IN ("*PAIN*", "*Pain*", "*pain*"))
   JOIN (p
   WHERE p.person_id=ascl.owner_id)
  ORDER BY p.name_full_formatted, folder_name, oc.mnemonic
  WITH maxrec = 99999, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
