CREATE PROGRAM bhs_athn_dxreq_catalog
 DECLARE cnt = f8
 SET cnt = 0
 FREE RECORD out_rec
 RECORD out_rec(
   1 qual[*]
     2 catalog_type_cd = vc
     2 catalog_type_disp = vc
     2 config_cd = vc
     2 config_mean = vc
     2 health_plan_id = vc
     2 order_diag_config_id = vc
 ) WITH protect
 SELECT INTO "nl:"
  o.catalog_type_cd, o_catalog_type_disp = uar_get_code_display(o.catalog_type_cd), o.config_meaning,
  o.config_value, o.health_plan_id, o.order_diag_config_id
  FROM order_diag_config o
  WHERE o.config_meaning="DXREQ"
   AND o.config_value=1
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(out_rec->qual,cnt), out_rec->qual[cnt].catalog_type_cd =
   cnvtstring(o.catalog_type_cd),
   out_rec->qual[cnt].catalog_type_disp = o_catalog_type_disp, out_rec->qual[cnt].config_cd =
   cnvtstring(o.config_value), out_rec->qual[cnt].config_mean = o.config_meaning,
   out_rec->qual[cnt].health_plan_id = cnvtstring(o.health_plan_id), out_rec->qual[cnt].
   order_diag_config_id = cnvtstring(o.order_diag_config_id)
  WITH time = 30
 ;end select
 CALL echorecord(out_rec)
 CALL echojson(out_rec, $1)
 FREE RECORD out_rec
END GO
