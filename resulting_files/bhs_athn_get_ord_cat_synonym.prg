CREATE PROGRAM bhs_athn_get_ord_cat_synonym
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE where_params = vc WITH noconstant(" OC.SYNONYM_ID=0")
 FREE RECORD out_rec
 RECORD out_rec(
   1 qual[*]
     2 synonym_id = vc
     2 orderable_type_flag = vc
 )
 IF (textlen(trim( $2,3)) > 0)
  SET where_params = build(" OC.SYNONYM_ID IN (", $2,")")
 ELSE
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM order_catalog_synonym oc
  PLAN (oc
   WHERE parser(where_params))
  HEAD oc.synonym_id
   cnt += 1, stat = alterlist(out_rec->qual,cnt), out_rec->qual[cnt].synonym_id = cnvtstring(oc
    .synonym_id),
   out_rec->qual[cnt].orderable_type_flag = cnvtstring(oc.orderable_type_flag)
  WITH nocounter, separator = " ", format,
   time = 10, maxrec = 100
 ;end select
#exit_script
 SET _memory_reply_string = cnvtrectojson(out_rec,5)
 FREE RECORD out_rec
END GO
