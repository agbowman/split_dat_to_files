CREATE PROGRAM bhs_eks_complete_exam:dba
 SET retval = 0
 DECLARE accessionnbr = vc
 UPDATE  FROM order_radiology o
  SET o.start_dt_tm = (sysdate - 1), o.complete_dt_tm = sysdate, o.exam_status_cd = 4224
  WHERE o.order_id=link_orderid
  WITH nocounter
 ;end update
 SET log_message = build("accessionid:",link_accessionid,"order id:",link_orderid)
 SET retval = 100
 COMMIT
END GO
