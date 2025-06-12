CREATE PROGRAM afc_get_missing_orders:dba
 SET afc_get_missing_orders_vrsn = "129876.013"
 DECLARE code_set = i4
 DECLARE code_value = f8
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE order_complete = f8
 DECLARE order_ordered = f8
 DECLARE pharm_cat = f8
 DECLARE order_id = f8
 DECLARE catalog_cd = f8
 DECLARE cs_order_id = f8
 DECLARE order_labinlab = f8
 DECLARE ce_inlab = f8
 SET code_set = 6004
 SET cdf_meaning = "COMPLETED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,order_complete)
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,order_ordered)
 SET code_set = 14281
 SET cdf_meaning = "LABINLAB"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,order_labinlab)
 SET code_set = 13029
 SET cdf_meaning = "IN LAB"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,ce_inlab)
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,pharm_cat)
 DECLARE apbilling_cd = f8 WITH noconstant(0.0)
 DECLARE approcess_cd = f8 WITH noconstant(0.0)
 DECLARE apspecimen_cd = f8 WITH noconstant(0.0)
 DECLARE apreport_cd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(5801,"APBILLING",1,apbilling_cd)
 SET stat = uar_get_meaning_by_codeset(5801,"APPROCESS",1,approcess_cd)
 SET stat = uar_get_meaning_by_codeset(5801,"APSPECIMEN",1,apspecimen_cd)
 SET stat = uar_get_meaning_by_codeset(5801,"APREPORT",1,apreport_cd)
 SET count1 = 0
 SELECT INTO "nl:"
  o.order_id, o.cs_order_id, o.order_mnemonic,
  o.catalog_cd, o.current_start_dt_tm, o.person_id,
  o.encntr_id, o.activity_type_cd, o.order_status_cd,
  oa.dept_status_cd, service_resource_cd = decode(pt.service_resource_cd,pt.service_resource_cd,rt
   .service_resource_cd,rt.service_resource_cd,osrc.service_resource_cd,
   osrc.service_resource_cd,orl.service_resource_cd,orl.service_resource_cd,0.0)
  FROM order_action oa,
   orders o,
   order_catalog oc,
   order_serv_res_container osrc,
   orc_resource_list orl,
   processing_task pt,
   report_task rt,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   dummyt d4
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate))
   JOIN (o
   WHERE o.order_id=oa.order_id
    AND o.catalog_type_cd != pharm_cat
    AND o.template_order_flag != 1
    AND ((o.person_id+ 0) > 0)
    AND ((o.product_id+ 0)=0))
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
   JOIN (d1)
   JOIN (((pt
   WHERE pt.order_id=o.order_id
    AND ((oc.activity_subtype_cd=apbilling_cd) OR (((oc.activity_subtype_cd=approcess_cd) OR (oc
   .activity_subtype_cd=apspecimen_cd)) )) )
   ) ORJOIN ((d2)
   JOIN (((rt
   WHERE rt.order_id=o.order_id
    AND oc.activity_subtype_cd=apreport_cd)
   ) ORJOIN ((d3)
   JOIN (((osrc
   WHERE osrc.order_id=o.order_id)
   ) ORJOIN ((d4)
   JOIN (orl
   WHERE orl.catalog_cd=o.catalog_cd
    AND orl.primary_ind=1
    AND orl.active_ind=1)
   )) )) ))
  ORDER BY oa.order_id
  HEAD oa.order_id
   count1 = (count1+ 1), stat = alterlist(orders->orders,count1), orders->orders[count1].order_id = o
   .order_id,
   orders->orders[count1].cs_order_id = o.cs_order_id, orders->orders[count1].order_mnemonic = o
   .order_mnemonic, orders->orders[count1].catalog_cd = o.catalog_cd,
   orders->orders[count1].cs_catalog_cd = 0.0, orders->orders[count1].orig_order_dt_tm = o
   .current_start_dt_tm, orders->orders[count1].person_id = o.person_id,
   orders->orders[count1].encntr_id = o.encntr_id, orders->orders[count1].activity_type_cd = o
   .activity_type_cd, orders->orders[count1].order_status_cd = o.order_status_cd,
   orders->orders[count1].completed_flag =
   IF ((orders->orders[count1].order_status_cd=order_complete)) 1
   ELSE 0
   ENDIF
   , orders->orders[count1].ordered_flag =
   IF ((((orders->orders[count1].order_status_cd=order_ordered)) OR ((orders->orders[count1].
   order_status_cd=order_complete))) ) 1
   ELSE 0
   ENDIF
   , orders->orders[count1].activity_type_disp = uar_get_code_display(o.activity_type_cd),
   orders->orders[count1].inlab_flag = 0, orders->orders[count1].service_resource_cd =
   service_resource_cd
  DETAIL
   IF (oa.dept_status_cd=order_labinlab)
    orders->orders[count1].inlab_flag = 1
   ENDIF
   dummy_var = 0
  WITH nocounter, outerjoin = d1, dontcare = pt,
   outerjoin = d2, dontcare = rt, outerjoin = d3,
   dontcare = osrc, outerjoin = d4, dontcare = osl
 ;end select
 SET orders->order_qual = count1
 IF (count1 > 0)
  FOR (i = 1 TO value(size(orders->orders,5)))
    SELECT INTO "nl:"
     o.catalog_cd, o.cs_order_id, o.order_id
     FROM orders o
     WHERE (o.order_id=orders->orders[i].order_id)
     DETAIL
      orders->orders[i].catalog_cd = o.catalog_cd, order_id = o.order_id, cs_order_id = o.cs_order_id
     WITH nocounter
    ;end select
    WHILE (cs_order_id > 0)
     SELECT INTO "nl:"
      o.catalog_cd, o.cs_order_id, o.order_id
      FROM orders o
      WHERE o.order_id=cs_order_id
      DETAIL
       order_id = o.order_id, catalog_cd = o.catalog_cd, cs_order_id = o.cs_order_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET cs_order_id = 0.0
     ENDIF
    ENDWHILE
    SET orders->orders[i].m_cs_order_id = order_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(count1)),
    order_detail od
   PLAN (d1)
    JOIN (od
    WHERE (od.order_id=orders->orders[d1.seq].order_id)
     AND od.oe_field_meaning_id IN (57, 1126, 1127))
   DETAIL
    IF (od.oe_field_meaning_id=57)
     orders->orders[d1.seq].quantity = cnvtint(od.oe_field_value)
    ELSE
     IF (od.oe_field_meaning_id=1126)
      orders->orders[d1.seq].start_dt_tm = cnvtdatetime(od.oe_field_dt_tm_value)
     ELSE
      orders->orders[d1.seq].stop_dt_tm = cnvtdatetime(od.oe_field_dt_tm_value)
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   oc.collection_status_flag
   FROM (dummyt d1  WITH seq = value(count1)),
    order_container_r oc,
    container c
   PLAN (d1)
    JOIN (oc
    WHERE (oc.order_id=orders->orders[d1.seq].order_id))
    JOIN (c
    WHERE c.container_id=oc.container_id)
   HEAD c.container_id
    orders->orders[d1.seq].collected_flag = 0
   DETAIL
    orders->orders[d1.seq].orig_order_dt_tm = c.drawn_dt_tm
    IF (oc.collection_status_flag=1)
     orders->orders[d1.seq].collected_flag = 1
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cea.charge_event_act_id
   FROM (dummyt d1  WITH seq = value(orders->order_qual)),
    charge_event c,
    charge_event_act cea
   PLAN (d1
    WHERE (orders->orders[d1.seq].ordered_flag=1))
    JOIN (c
    WHERE (((c.ext_m_event_id=orders->orders[d1.seq].order_id)
     AND (c.ext_i_event_id=orders->orders[d1.seq].order_id)
     AND (orders->orders[d1.seq].cs_order_id=0)) OR ((((c.ext_m_event_id=orders->orders[d1.seq].
    cs_order_id)
     AND (c.ext_p_event_id=orders->orders[d1.seq].cs_order_id)
     AND (c.ext_i_event_id=orders->orders[d1.seq].order_id)
     AND (orders->orders[d1.seq].cs_order_id != 0)) OR ((c.ext_m_event_id=orders->orders[d1.seq].
    m_cs_order_id)
     AND (c.ext_p_event_id=orders->orders[d1.seq].cs_order_id)
     AND (c.ext_i_event_id=orders->orders[d1.seq].order_id)
     AND (orders->orders[d1.seq].cs_order_id != 0))) )) )
    JOIN (cea
    WHERE cea.charge_event_id=c.charge_event_id
     AND cea.cea_type_cd=ce_ordered)
   DETAIL
    IF (cea.charge_event_act_id != 0)
     orders->orders[d1.seq].ce_ordered_flag = 1
    ELSE
     orders->orders[d1.seq].ce_ordered_flag = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cea.charge_event_act_id
   FROM (dummyt d1  WITH seq = value(orders->order_qual)),
    charge_event c,
    charge_event_act cea
   PLAN (d1
    WHERE (orders->orders[d1.seq].inlab_flag=1))
    JOIN (c
    WHERE (((c.ext_m_event_id=orders->orders[d1.seq].order_id)
     AND (c.ext_i_event_id=orders->orders[d1.seq].order_id)
     AND (orders->orders[d1.seq].cs_order_id=0)) OR ((((c.ext_m_event_id=orders->orders[d1.seq].
    cs_order_id)
     AND (c.ext_p_event_id=orders->orders[d1.seq].cs_order_id)
     AND (c.ext_i_event_id=orders->orders[d1.seq].order_id)
     AND (orders->orders[d1.seq].cs_order_id != 0)) OR ((c.ext_m_event_id=orders->orders[d1.seq].
    m_cs_order_id)
     AND (c.ext_p_event_id=orders->orders[d1.seq].cs_order_id)
     AND (c.ext_i_event_id=orders->orders[d1.seq].order_id)
     AND (orders->orders[d1.seq].cs_order_id != 0))) )) )
    JOIN (cea
    WHERE cea.charge_event_id=c.charge_event_id
     AND cea.cea_type_cd=ce_inlab)
   DETAIL
    IF (cea.charge_event_act_id != 0)
     orders->orders[d1.seq].ce_inlab_flag = 1
    ELSE
     orders->orders[d1.seq].ce_inlab_flag = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cea.charge_event_act_id
   FROM (dummyt d1  WITH seq = value(orders->order_qual)),
    charge_event c,
    charge_event_act cea
   PLAN (d1
    WHERE (orders->orders[d1.seq].collected_flag=1))
    JOIN (c
    WHERE (((c.ext_m_event_id=orders->orders[d1.seq].order_id)
     AND (c.ext_i_event_id=orders->orders[d1.seq].order_id)
     AND (orders->orders[d1.seq].cs_order_id=0)) OR ((((c.ext_m_event_id=orders->orders[d1.seq].
    cs_order_id)
     AND (c.ext_p_event_id=orders->orders[d1.seq].cs_order_id)
     AND (c.ext_i_event_id=orders->orders[d1.seq].order_id)
     AND (orders->orders[d1.seq].cs_order_id != 0)) OR ((c.ext_m_event_id=orders->orders[d1.seq].
    m_cs_order_id)
     AND (c.ext_p_event_id=orders->orders[d1.seq].cs_order_id)
     AND (c.ext_i_event_id=orders->orders[d1.seq].order_id)
     AND (orders->orders[d1.seq].cs_order_id != 0))) )) )
    JOIN (cea
    WHERE cea.charge_event_id=c.charge_event_id
     AND cea.cea_type_cd=ce_collected)
   DETAIL
    IF (cea.charge_event_act_id != 0)
     orders->orders[d1.seq].ce_collected_flag = 1
    ELSE
     orders->orders[d1.seq].ce_collected_flag = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cea.charge_event_act_id
   FROM (dummyt d1  WITH seq = value(orders->order_qual)),
    charge_event c,
    charge_event_act cea
   PLAN (d1
    WHERE (orders->orders[d1.seq].completed_flag=1))
    JOIN (c
    WHERE (((c.ext_m_event_id=orders->orders[d1.seq].order_id)
     AND (c.ext_i_event_id=orders->orders[d1.seq].order_id)
     AND (orders->orders[d1.seq].cs_order_id=0)) OR ((((c.ext_m_event_id=orders->orders[d1.seq].
    cs_order_id)
     AND (c.ext_p_event_id=orders->orders[d1.seq].cs_order_id)
     AND (c.ext_i_event_id=orders->orders[d1.seq].order_id)
     AND (orders->orders[d1.seq].cs_order_id != 0)) OR ((c.ext_m_event_id=orders->orders[d1.seq].
    m_cs_order_id)
     AND (c.ext_p_event_id=orders->orders[d1.seq].cs_order_id)
     AND (c.ext_i_event_id=orders->orders[d1.seq].order_id)
     AND (orders->orders[d1.seq].cs_order_id != 0))) )) )
    JOIN (cea
    WHERE cea.charge_event_id=c.charge_event_id
     AND cea.cea_type_cd=ce_complete)
   DETAIL
    IF (cea.charge_event_act_id != 0)
     orders->orders[d1.seq].ce_completed_flag = 1
    ELSE
     orders->orders[d1.seq].ce_completed_flag = 0
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   o.catalog_cd
   FROM orders o,
    (dummyt d1  WITH seq = value(orders->order_qual))
   PLAN (d1
    WHERE (orders->orders[d1.seq].cs_order_id != 0))
    JOIN (o
    WHERE (o.order_id=orders->orders[d1.seq].cs_order_id))
   DETAIL
    orders->orders[d1.seq].cs_catalog_cd = o.catalog_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM (dummyt d1  WITH seq = value(orders->order_qual)),
    person p
   PLAN (d1
    WHERE (((orders->orders[d1.seq].ordered_flag=1)
     AND (orders->orders[d1.seq].ce_ordered_flag=0)) OR ((((orders->orders[d1.seq].collected_flag=1)
     AND (orders->orders[d1.seq].ce_collected_flag=0)) OR ((orders->orders[d1.seq].completed_flag=1)
     AND (orders->orders[d1.seq].ce_completed_flag=0))) )) )
    JOIN (p
    WHERE (p.person_id=orders->orders[d1.seq].person_id))
   DETAIL
    orders->orders[d1.seq].person_name = p.name_full_formatted
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   a.accession
   FROM (dummyt d1  WITH seq = value(orders->order_qual)),
    accession_order_r r,
    accession a
   PLAN (d1
    WHERE (((orders->orders[d1.seq].ordered_flag=1)
     AND (orders->orders[d1.seq].ce_ordered_flag=0)) OR ((((orders->orders[d1.seq].collected_flag=1)
     AND (orders->orders[d1.seq].ce_collected_flag=0)) OR ((orders->orders[d1.seq].completed_flag=1)
     AND (orders->orders[d1.seq].ce_completed_flag=0))) )) )
    JOIN (r
    WHERE (r.order_id=orders->orders[d1.seq].order_id))
    JOIN (a
    WHERE a.accession_id=r.accession_id)
   DETAIL
    orders->orders[d1.seq].accession = a.accession
   WITH nocounter
  ;end select
 ENDIF
END GO
