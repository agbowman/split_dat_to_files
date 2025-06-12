CREATE PROGRAM dcpdelorderbyrange:dba
 PAINT
  box(1,1,15,80), text(2,5,"Please enter the range of orders you want to delete."), line(3,1,80,xhor),
  text(4,5,"This script wil delete any orders having order_id  fall into"), text(5,5,
   "the range between start and stop order_id."), text(7,5,
   "If you want to delete ONE record, enter the same order_id"),
  text(8,5,"for both prompts."), text(11,5,"Please enter the start order_id:"), text(12,5,
   "Please enter the stop order_id:"),
  accept(11,40,"99999999",0), accept(12,40,"99999999",0)
 SET failed = "F"
 SET orderid1 =  $1
 SET orderid2 =  $2
 DELETE  FROM ingredient_detail ingd
  WHERE ingd.order_id >= orderid1
   AND ingd.order_id <= orderid2
  WITH nocounter
 ;end delete
 DELETE  FROM order_ingredient ing
  WHERE ing.order_id >= orderid1
   AND ing.order_id <= orderid2
  WITH nocounter
 ;end delete
 DELETE  FROM order_review rev
  WHERE rev.order_id >= orderid1
   AND rev.order_id <= orderid2
  WITH nocounter
 ;end delete
 DELETE  FROM order_detail det
  WHERE det.order_id >= orderid1
   AND det.order_id <= orderid2
  WITH nocounter
 ;end delete
 DELETE  FROM order_comment comm
  WHERE comm.order_id >= orderid1
   AND comm.order_id <= orderid2
  WITH nocounter
 ;end delete
 DELETE  FROM order_action act
  WHERE act.order_id >= orderid1
   AND act.order_id <= orderid2
  WITH nocounter
 ;end delete
 DELETE  FROM order_alias ali
  WHERE ali.order_id >= orderid1
   AND ali.order_id <= orderid2
  WITH nocounter
 ;end delete
 DELETE  FROM eco_queue eco
  WHERE eco.order_id >= orderid1
   AND eco.order_id <= orderid2
  WITH nocounter
 ;end delete
 DELETE  FROM task_activity task
  WHERE task.order_id >= orderid1
   AND task.order_id <= orderid2
  WITH nocounter
 ;end delete
 DELETE  FROM orders ord
  WHERE ord.order_id >= orderid1
   AND ord.order_id <= orderid2
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET failed = "T"
 ENDIF
 IF (failed="T")
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
END GO
