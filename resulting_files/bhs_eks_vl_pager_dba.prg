CREATE PROGRAM bhs_eks_vl_pager:dba
 DECLARE catalogval = vc
 SET retval = 0
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.order_id=trigger_orderid
    AND (o.catalog_cd=
   (SELECT
    code_value
    FROM code_value
    WHERE code_set=200
     AND display_key="VL*"
     AND active_ind=1))
    AND o.order_status_cd=2550)
  DETAIL
   catalogval = uar_get_code_display(o.catalog_cd)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 100
  SET log_misc1 = catalogval
 ENDIF
 IF (retval=100)
  SET log_message = build2(trigger_orderid," find VL order",catalogval)
 ELSE
  SET log_message = build2(trigger_orderid," failed finding VL order")
 ENDIF
END GO
