CREATE PROGRAM bhs_eks_chk_sunquest_man_can:dba
 SELECT
  FROM orders o
  PLAN (o
   WHERE trigger_orderid=o.order_id
    AND o.active_status_prsnl_id > 1)
  ORDER BY o.order_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 100
 ELSE
  SET retval = 0
 ENDIF
END GO
