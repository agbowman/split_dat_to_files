CREATE PROGRAM djh_orders_detail_tbl
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT
  *
  FROM order_detail od
  WHERE od.order_id=834073675
  WITH format = variable, formfeed = none, maxrec = 10
 ;end select
END GO
