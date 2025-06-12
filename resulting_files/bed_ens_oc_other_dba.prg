CREATE PROGRAM bed_ens_oc_other:dba
 FREE SET oc
 RECORD oc(
   1 olist[*]
     2 name = c100
     2 parent_name = c32
     2 code_value = f8
 )
 DELETE  FROM br_other_names
  WHERE parent_entity_name IN ("ORDER_CATALOG", "BR_AUTO_ORDER_CATALOG")
  WITH nocounter
 ;end delete
 SET tot_oc = 0
 SET oc_count = 0
 SET stat = alterlist(oc->olist,100)
 SELECT INTO "NL:"
  FROM order_catalog o
  WHERE cnvtupper(o.primary_mnemonic) != cnvtupper(o.description)
   AND o.description != cnvtupper(o.description)
   AND o.description > "  *"
  DETAIL
   tot_oc = (tot_oc+ 1), oc_count = (oc_count+ 1)
   IF (oc_count > 100)
    stat = alterlist(oc->olist,(tot_oc+ 100)), oc_count = 1
   ENDIF
   oc->olist[tot_oc].name = trim(o.description), oc->olist[tot_oc].parent_name = "ORDER_CATALOG", oc
   ->olist[tot_oc].code_value = o.catalog_cd
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM order_catalog o
  WHERE cnvtupper(o.primary_mnemonic) != cnvtupper(o.dept_display_name)
   AND cnvtupper(o.dept_display_name) != cnvtupper(o.description)
   AND o.dept_display_name != cnvtupper(o.dept_display_name)
   AND o.dept_display_name > "  *"
  DETAIL
   tot_oc = (tot_oc+ 1), oc_count = (oc_count+ 1)
   IF (oc_count > 100)
    stat = alterlist(oc->olist,(tot_oc+ 100)), oc_count = 1
   ENDIF
   oc->olist[tot_oc].name = trim(o.dept_display_name), oc->olist[tot_oc].parent_name =
   "ORDER_CATALOG", oc->olist[tot_oc].code_value = o.catalog_cd
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM br_auto_order_catalog o
  WHERE cnvtupper(o.primary_mnemonic) != cnvtupper(o.description)
   AND o.description > "  *"
   AND o.description != cnvtupper(o.description)
  DETAIL
   tot_oc = (tot_oc+ 1), oc_count = (oc_count+ 1)
   IF (oc_count > 100)
    stat = alterlist(oc->olist,(tot_oc+ 100)), oc_count = 1
   ENDIF
   oc->olist[tot_oc].name = trim(o.description), oc->olist[tot_oc].parent_name =
   "BR_AUTO_ORDER_CATALOG", oc->olist[tot_oc].code_value = o.catalog_cd
  WITH skipbedrock = 1, nocounter
 ;end select
 SELECT INTO "NL:"
  FROM br_auto_order_catalog o
  WHERE cnvtupper(o.primary_mnemonic) != cnvtupper(o.dept_name)
   AND o.dept_name != cnvtupper(o.dept_name)
   AND cnvtupper(o.dept_name) != cnvtupper(o.description)
   AND o.dept_name > "  *"
  DETAIL
   tot_oc = (tot_oc+ 1), oc_count = (oc_count+ 1)
   IF (oc_count > 100)
    stat = alterlist(oc->olist,(tot_oc+ 100)), oc_count = 1
   ENDIF
   oc->olist[tot_oc].name = trim(o.dept_name), oc->olist[tot_oc].parent_name =
   "BR_AUTO_ORDER_CATALOG", oc->olist[tot_oc].code_value = o.catalog_cd
  WITH skipbedrock = 1, nocounter
 ;end select
 SET stat = alterlist(oc->olist,tot_oc)
 FOR (x = 1 TO tot_oc)
  SELECT INTO "NL:"
   FROM br_other_names b
   WHERE (b.alias_name=oc->olist[x].name)
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM br_other_names b
    SET b.parent_entity_name = oc->olist[x].parent_name, b.parent_entity_id = oc->olist[x].code_value,
     b.alias_name = oc->olist[x].name,
     b.alias_name_key_cap = cnvtupper(oc->olist[x].name), b.updt_dt_tm = cnvtdatetime(curdate,
      curtime3)
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",trim(oc->olist[x].name),
     " into the br_other_names table.")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
END GO
