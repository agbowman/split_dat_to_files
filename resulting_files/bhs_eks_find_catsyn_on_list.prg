CREATE PROGRAM bhs_eks_find_catsyn_on_list
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE log_message = vc WITH protect, noconstant(" ")
 SET retval = - (1)
 DECLARE ms_orderid = vc WITH protect, noconstant(" ")
 DECLARE catalogcd = vc WITH protect, noconstant(" ")
 DECLARE eid = f8
 SET eid = trigger_encntrid
 DECLARE oid = f8
 SET oid = trigger_orderid
 DECLARE mn_found = i2 WITH protect, noconstant(0)
 DECLARE ms_list = vc WITH protect, noconstant(" ")
 DECLARE ms_id = vc WITH protect, noconstant(" ")
 DECLARE mn_num = i2 WITH protect, noconstant(0)
 FREE RECORD ord
 RECORD ord(
   1 qual[*]
     2 f_catalog_cd = f8
     2 order_id = f8
 )
 IF (reflect(parameter(1,0))="C*")
  SET ms_list = parameter(1,0)
 ELSE
  GO TO exit_script
 ENDIF
 IF (reflect(parameter(2,0))="C*")
  SET ms_id = parameter(2,0)
 ELSE
  GO TO exit_script
 ENDIF
 IF (ms_id="orderID")
  SELECT INTO "nl:"
   duration = datetimediff(o.projected_stop_dt_tm,o.current_start_dt_tm,3)"##.##"
   FROM bhs_ordcatsyn_list bol,
    orders o,
    order_detail od
   PLAN (bol
    WHERE bol.list_key=ms_list
     AND bol.active_ind=1)
    JOIN (o
    WHERE o.order_id=oid
     AND o.catalog_cd=bol.catalog_cd
     AND o.order_status_cd=mf_ordered_cd
     AND o.template_order_id=0)
    JOIN (od
    WHERE o.order_id=od.order_id
     AND od.oe_field_meaning IN ("RXROUTE"))
   DETAIL
    IF (od.oe_field_meaning="RXROUTE"
     AND od.oe_field_display_value IN ("Intramuscular", "IV Push", "IV Push Slowly", "IVPB",
    "Subcutaneous Infusion",
    "Subcutaneous Injection", "IV Intermittent Infusion")
     AND duration > 24)
     mn_found = 1
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (ms_id="encntrID")
  SELECT INTO "nl:"
   duration = datetimediff(o.projected_stop_dt_tm,o.current_start_dt_tm,3)"##.##"
   FROM orders o,
    order_detail od
   PLAN (o
    WHERE o.encntr_id=eid
     AND o.template_order_id=0
     AND o.order_status_cd=mf_ordered_cd
     AND o.catalog_type_cd=2516)
    JOIN (od
    WHERE o.order_id=od.order_id
     AND od.oe_field_meaning IN ("RXROUTE"))
   ORDER BY o.order_id
   HEAD REPORT
    cnt = 0
   HEAD o.order_id
    IF (od.oe_field_meaning="RXROUTE"
     AND od.oe_field_display_value IN ("Intramuscular", "IV Push", "IV Push Slowly", "IVPB",
    "Subcutaneous Infusion",
    "Subcutaneous Injection", "IV Intermittent Infusion")
     AND duration > 24)
     cnt = (cnt+ 1), stat = alterlist(ord->qual,cnt), ord->qual[cnt].f_catalog_cd = o.catalog_cd,
     ord->qual[cnt].order_id = o.order_id, ms_orderid = cnvtstring(o.order_id),
     CALL echo(build("cnt = ",cnt)),
     CALL echo(build("ms_orderid: ",ms_orderid))
    ENDIF
   WITH nocounter
  ;end select
  CALL echorecord(ord)
  IF (curqual > 0)
   SELECT INTO "nl:"
    FROM bhs_ordcatsyn_list bol
    PLAN (bol
     WHERE expand(mn_num,1,size(ord->qual,5),bol.catalog_cd,ord->qual[mn_num].f_catalog_cd)
      AND bol.list_key=ms_list
      AND bol.active_ind=1)
    DETAIL
     mn_found = 1, catalogcd = cnvtstring(bol.catalog_cd),
     CALL echo(build("catalogCd: ",catalogcd))
    WITH expand = 1, nocounter
   ;end select
  ENDIF
 ENDIF
 IF (mn_found=1)
  SET retval = 100
  SET log_message = build2(ms_orderid)
  SET log_message = build2(catalogcd)
  GO TO exit_script
 ELSE
  SET retval = 0
  SET log_message = build2("order not found.")
 ENDIF
#exit_script
 CALL echo(log_message)
END GO
