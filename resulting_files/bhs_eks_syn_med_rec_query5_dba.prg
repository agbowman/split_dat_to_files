CREATE PROGRAM bhs_eks_syn_med_rec_query5:dba
 FREE RECORD t_record
 RECORD t_record(
   1 encntr_id = f8
   1 ord_dt_tm = dq8
 )
 DECLARE ordered = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED")), protect
 DECLARE pharmacy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")), protect
 SET t_record->encntr_id = trigger_encntrid
 SET retval = 0
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=t_record->encntr_id)
    AND o.orig_ord_as_flag IN (1, 2)
    AND o.catalog_type_cd=pharmacy
    AND o.order_status_cd=ordered
    AND o.template_order_flag=0
    AND  NOT ( EXISTS (
   (SELECT
    ord.order_nbr
    FROM order_recon_detail ord
    WHERE ord.order_nbr=o.order_id))))
  ORDER BY o.orig_order_dt_tm
  DETAIL
   retval = 100
  WITH nocounter
 ;end select
 CALL echo(build("retval = ",retval))
END GO
