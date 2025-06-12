CREATE PROGRAM check_isparent:dba
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.order_id=oid
    AND ((o.template_order_flag+ 0)=1))
  DETAIL
   isparent = 1
  WITH nocounter
 ;end select
END GO
