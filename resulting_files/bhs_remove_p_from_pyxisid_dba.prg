CREATE PROGRAM bhs_remove_p_from_pyxisid:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD prodrec
 RECORD prodrec(
   1 qual[*]
     2 identid = f8
     2 itemid = f8
     2 newchrgnum = vc
     2 oldchrgnum = vc
 )
 SELECT INTO  $OUTDEV
  mi.item_id, mi.med_identifier_id, mi.value
  FROM med_identifier mi
  WHERE mi.item_id > 0
   AND mi.med_identifier_type_cd=3106.00
   AND mi.med_product_id=0
  ORDER BY mi.value
  WITH separator = " ", format, nocounter
 ;end select
#ext
END GO
