CREATE PROGRAM bhs_careset_audit_v2
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter First Few Letters of Mnemonic" = "",
  "Select From List:" = 0
  WITH outdev, ocs_mnemonic1, ocs_mnemonic2
 SELECT INTO  $OUTDEV
  cs = uar_get_code_display(cs.catalog_cd), oc.primary_mnemonic, ocs.mnemonic,
  cs.comp_seq, longtext = substring(1,70,replace(replace(lt.long_text,char(13)," ",0),char(10)," ",0)
   )
  FROM order_catalog_synonym ocs,
   cs_component cs,
   order_catalog oc,
   long_text lt
  PLAN (ocs
   WHERE (ocs.synonym_id= $OCS_MNEMONIC2))
   JOIN (cs
   WHERE ocs.synonym_id=cs.comp_id)
   JOIN (oc
   WHERE cs.catalog_cd=oc.catalog_cd)
   JOIN (lt
   WHERE oc.ord_com_template_long_text_id=lt.long_text_id)
  ORDER BY oc.primary_mnemonic, cs.comp_seq
  WITH nocounter, format, separator = " "
 ;end select
END GO
