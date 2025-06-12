CREATE PROGRAM djh_orders_tbl
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO outdev
  o.order_id
  FROM orders o
  WHERE o.active_ind=1
   AND o.encntr_id=808856064
  WITH format = variable, formfeed = none, maxrec = 10
 ;end select
END GO
