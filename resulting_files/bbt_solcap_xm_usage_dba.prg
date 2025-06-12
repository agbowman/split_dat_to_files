CREATE PROGRAM bbt_solcap_xm_usage:dba
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE ahgxm_phase_mean = c5 WITH protect, constant("AHGXM")
 DECLARE computerxm_phase_mean = c10 WITH protect, constant("COMPUTERXM")
 DECLARE flexiblexm_phase_mean = c10 WITH protect, constant("FLEXIBLEXM")
 DECLARE inventory_states_cs = i4 WITH protect, constant(1610)
 DECLARE xm_inventory_state_mean = c1 WITH protect, constant("3")
 DECLARE xm_inventory_state_cd = f8 WITH protect, noconstant(0.0)
 DECLARE assay_rslt_proc_cs = i4 WITH protect, constant(1636)
 DECLARE xm_interp_mean = c12 WITH protect, constant("HISTRY & UPD")
 DECLARE xm_interp_cd = f8 WITH protect, noconstant(0.0)
 DECLARE xm_hist_only_interp_mean = c11 WITH protect, constant("HISTRY ONLY")
 DECLARE xm_hist_only_interp_cd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(inventory_states_cs,xm_inventory_state_mean,1,
  xm_inventory_state_cd)
 SET stat = uar_get_meaning_by_codeset(assay_rslt_proc_cs,xm_interp_mean,1,xm_interp_cd)
 SET stat = uar_get_meaning_by_codeset(assay_rslt_proc_cs,xm_hist_only_interp_mean,1,
  xm_hist_only_interp_cd)
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2014.2.00250.9"
 SET reply->solcap[1].degree_of_use_num = 0
 SET reply->solcap[1].degree_of_use_str = "NO"
 SET stat = alterlist(reply->solcap[1].other,2)
 SET reply->solcap[1].other[1].category_name =
 "Number of crossmatched products without using flexible crossmatch"
 SET stat = alterlist(reply->solcap[1].other[1].value,1)
 SET reply->solcap[1].other[1].value[1].display = "XM"
 SET reply->solcap[1].other[1].value[1].value_num = 0
 SET reply->solcap[1].other[1].value[1].value_str = "NO"
 SET reply->solcap[1].other[2].category_name =
 "Number of crossmatched products using flexible crossmatch, grouped by crossmatch type"
 SET stat = alterlist(reply->solcap[1].other[2].value,3)
 SET reply->solcap[1].other[2].value[1].display = "AHGXM"
 SET reply->solcap[1].other[2].value[1].value_num = 0
 SET reply->solcap[1].other[2].value[1].value_str = "NO"
 SET reply->solcap[1].other[2].value[2].display = "COMPUTERXM"
 SET reply->solcap[1].other[2].value[2].value_num = 0
 SET reply->solcap[1].other[2].value[2].value_str = "NO"
 SET reply->solcap[1].other[2].value[3].display = "FLEXIBLEXM"
 SET reply->solcap[1].other[2].value[3].value_num = 0
 SET reply->solcap[1].other[2].value[3].value_str = "NO"
 IF (xm_inventory_state_cd > 0
  AND ((xm_interp_cd > 0) OR (xm_hist_only_interp_cd > 0)) )
  SELECT INTO "nl:"
   p.product_id, productcnt = count(p.product_id)
   FROM product p,
    product_event pe,
    orders o,
    profile_task_r ptr,
    discrete_task_assay dta,
    result r
   PLAN (p
    WHERE p.product_id > 0.0
     AND p.active_ind=1)
    JOIN (pe
    WHERE pe.product_id=p.product_id
     AND pe.event_type_cd=xm_inventory_state_cd
     AND pe.active_ind=1
     AND pe.event_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (o
    WHERE o.order_id=pe.order_id
     AND o.active_ind=1)
    JOIN (ptr
    WHERE ptr.catalog_cd=o.catalog_cd
     AND ptr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND ((dta.bb_result_processing_cd=xm_interp_cd) OR (dta.bb_result_processing_cd=
    xm_hist_only_interp_cd)) )
    JOIN (r
    WHERE r.order_id=pe.order_id
     AND r.task_assay_cd=ptr.task_assay_cd
     AND r.bb_result_id=pe.bb_result_id)
   DETAIL
    reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+ productcnt), reply->
    solcap[1].other[1].value[1].value_num = productcnt
   WITH nocounter
  ;end select
  IF ((reply->solcap[1].other[1].value[1].value_num > 0))
   SET reply->solcap[1].other[1].value[1].value_str = "YES"
  ENDIF
  SELECT INTO "nl:"
   pg.phase_group_cd, phasegroupmean = uar_get_code_meaning(pg.phase_group_cd), productcnt = count(pg
    .phase_group_cd)
   FROM product p,
    product_event pe,
    orders o,
    bb_order_phase bop,
    phase_group pg,
    discrete_task_assay dta,
    result r
   PLAN (p
    WHERE p.product_id > 0.0
     AND p.active_ind=1)
    JOIN (pe
    WHERE pe.product_id=p.product_id
     AND pe.event_type_cd=xm_inventory_state_cd
     AND pe.active_ind=1
     AND pe.event_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (o
    WHERE o.order_id=pe.order_id
     AND o.active_ind=1)
    JOIN (bop
    WHERE bop.order_id=o.order_id)
    JOIN (pg
    WHERE pg.phase_group_cd=bop.phase_grp_cd
     AND pg.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=pg.task_assay_cd
     AND ((dta.bb_result_processing_cd=xm_interp_cd) OR (dta.bb_result_processing_cd=
    xm_hist_only_interp_cd))
     AND dta.active_ind=1)
    JOIN (r
    WHERE r.order_id=pe.order_id
     AND r.task_assay_cd=pg.task_assay_cd
     AND r.bb_result_id=pe.bb_result_id)
   GROUP BY pg.phase_group_cd
   DETAIL
    CASE (phasegroupmean)
     OF ahgxm_phase_mean:
      reply->solcap[1].other[2].value[1].value_num = (reply->solcap[1].other[2].value[1].value_num+
      productcnt),reply->solcap[1].other[2].value[1].value_str = "YES"
     OF computerxm_phase_mean:
      reply->solcap[1].other[2].value[2].value_num = (reply->solcap[1].other[2].value[2].value_num+
      productcnt),reply->solcap[1].other[2].value[2].value_str = "YES"
     OF flexiblexm_phase_mean:
      reply->solcap[1].other[2].value[3].value_num = (reply->solcap[1].other[2].value[3].value_num+
      productcnt),reply->solcap[1].other[2].value[3].value_str = "YES"
    ENDCASE
    reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+ productcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->solcap[1].degree_of_use_num > 0))
  SET reply->solcap[1].degree_of_use_str = "YES"
 ENDIF
END GO
