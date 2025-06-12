CREATE PROGRAM bhs_athn_get_orders_from_cki
 RECORD out_rec(
   1 orders[*]
     2 order_id = vc
     2 order_status = vc
     2 catalog_code = vc
     2 synonym_id = vc
     2 catalog_desc = vc
     2 synonym_mnemonic = vc
     2 catalog_type = vc
     2 clinical_category = vc
     2 display_line = vc
 )
 DECLARE future_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE incomplete_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6004,"INCOMPLETE"))
 DECLARE inprocess_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE onholdmedstudent_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6004,
   "ONHOLDMEDSTUDENT"))
 DECLARE ordered_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE pendingcomplete_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6004,
   "PENDINGCOMPLETE"))
 DECLARE pendingreview_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",6004,
   "PENDINGREVIEW"))
 DECLARE varmnemonic = vc WITH noconstant("")
 IF (( $3="MUL.ORD!*"))
  SELECT INTO "nl:"
   FROM orders o,
    order_ingredient oi,
    order_catalog oc,
    order_catalog_synonym ocs
   PLAN (o
    WHERE (o.person_id= $2)
     AND o.order_status_cd IN (future_cd, inprocess_cd, onholdmedstudent_cd, ordered_cd,
    pendingcomplete_cd,
    pendingreview_cd)
     AND o.template_order_flag IN (0, 1)
     AND o.active_ind=1)
    JOIN (oi
    WHERE oi.order_id=o.order_id)
    JOIN (oc
    WHERE oc.catalog_cd=oi.catalog_cd
     AND (oc.cki= $3)
     AND oc.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd
     AND ocs.synonym_id=oi.synonym_id
     AND ocs.active_ind=1)
   ORDER BY o.order_id
   HEAD REPORT
    cnt = 0
   HEAD o.order_id
    cnt = (cnt+ 1)
    IF (mod(cnt,100)=1)
     stat = alterlist(out_rec->orders,(cnt+ 99))
    ENDIF
    IF (o.hna_order_mnemonic=o.ordered_as_mnemonic)
     varmnemonic = trim(replace(replace(replace(replace(replace(o.hna_order_mnemonic,"&","&amp;",0),
          "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
    ELSE
     varmnemonic = build(trim(replace(replace(replace(replace(replace(o.hna_order_mnemonic,"&",
            "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)," (",trim(
       replace(replace(replace(replace(replace(o.ordered_as_mnemonic,"&","&amp;",0),"<","&lt;",0),">",
          "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),")")
    ENDIF
    out_rec->orders[cnt].order_id = trim(cnvtstring(o.order_id)), out_rec->orders[cnt].order_status
     = uar_get_code_display(o.order_status_cd), out_rec->orders[cnt].catalog_code = trim(cnvtstring(
      oc.catalog_cd)),
    out_rec->orders[cnt].synonym_id = trim(cnvtstring(ocs.synonym_id)), out_rec->orders[cnt].
    catalog_desc = uar_get_code_display(oc.catalog_cd), out_rec->orders[cnt].synonym_mnemonic =
    varmnemonic,
    out_rec->orders[cnt].catalog_type = uar_get_code_display(oc.catalog_type_cd), out_rec->orders[cnt
    ].clinical_category = uar_get_code_display(ocs.dcp_clin_cat_cd), out_rec->orders[cnt].
    display_line = trim(replace(replace(replace(replace(replace(o.simplified_display_line,"&","&amp;",
          0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
   FOOT REPORT
    stat = alterlist(out_rec->orders,cnt)
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF (( $3="MUL.ORD-SYN!*"))
  SELECT INTO "nl:"
   FROM orders o,
    order_ingredient oi,
    order_catalog_synonym ocs,
    order_catalog oc
   PLAN (o
    WHERE (o.person_id= $2)
     AND o.order_status_cd IN (future_cd, incomplete_cd, inprocess_cd, onholdmedstudent_cd,
    ordered_cd,
    pendingcomplete_cd, pendingreview_cd)
     AND o.template_order_flag IN (0, 1)
     AND o.active_ind=1)
    JOIN (oi
    WHERE oi.order_id=o.order_id)
    JOIN (ocs
    WHERE ocs.catalog_cd=oi.catalog_cd
     AND (ocs.cki= $3))
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd)
   ORDER BY o.order_id
   HEAD REPORT
    cnt = 0
   HEAD o.order_id
    cnt = (cnt+ 1)
    IF (mod(cnt,100)=1)
     stat = alterlist(out_rec->orders,(cnt+ 99))
    ENDIF
    IF (o.hna_order_mnemonic=o.ordered_as_mnemonic)
     varmnemonic = trim(replace(replace(replace(replace(replace(o.hna_order_mnemonic,"&","&amp;",0),
          "<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
    ELSE
     varmnemonic = build(trim(replace(replace(replace(replace(replace(o.hna_order_mnemonic,"&",
            "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)," (",trim(
       replace(replace(replace(replace(replace(o.ordered_as_mnemonic,"&","&amp;",0),"<","&lt;",0),">",
          "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),")")
    ENDIF
    out_rec->orders[cnt].order_id = trim(cnvtstring(o.order_id)), out_rec->orders[cnt].order_status
     = uar_get_code_display(o.order_status_cd), out_rec->orders[cnt].catalog_code = trim(cnvtstring(
      oc.catalog_cd)),
    out_rec->orders[cnt].synonym_id = trim(cnvtstring(ocs.synonym_id)), out_rec->orders[cnt].
    catalog_desc = uar_get_code_display(oc.catalog_cd), out_rec->orders[cnt].synonym_mnemonic =
    varmnemonic,
    out_rec->orders[cnt].catalog_type = uar_get_code_display(oc.catalog_type_cd), out_rec->orders[cnt
    ].clinical_category = uar_get_code_display(ocs.dcp_clin_cat_cd), out_rec->orders[cnt].
    display_line = trim(replace(replace(replace(replace(replace(o.simplified_display_line,"&","&amp;",
          0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
   FOOT REPORT
    stat = alterlist(out_rec->orders,cnt)
   WITH nocounter, time = 30
  ;end select
 ENDIF
 CALL echojson(out_rec, $1)
END GO
