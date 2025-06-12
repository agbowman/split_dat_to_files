CREATE PROGRAM bhs_rpt_fix_inbox_orders
 SET doctor_review_type_flag = 2
 SET cosign_notification_type_flag = 2
 SET pending_notification_status_flag = 1
 SET not_reviewed_status_flag = 0
 SET max_review_sequence = 20
 SET package_install_dt_tm = cnvtdatetime("30-JAN-2011 00:00:00")
 INSERT  FROM order_review orev
  (orev.order_id, orev.action_sequence, orev.review_sequence,
  orev.review_type_flag, orev.reviewed_status_flag, orev.provider_id,
  orev.updt_dt_tm, orev.updt_cnt, orev.updt_id)(SELECT DISTINCT
   onotif.order_id, onotif.action_sequence, max_review_sequence,
   doctor_review_type_flag, not_reviewed_status_flag, onotif.to_prsnl_id,
   cnvtdatetime(curdate,curtime3), 0, reqinfo->updt_id
   FROM order_notification onotif
   WHERE onotif.to_prsnl_id > 0.0
    AND onotif.notification_status_flag=pending_notification_status_flag
    AND onotif.notification_type_flag=cosign_notification_type_flag
    AND ((onotif.updt_dt_tm+ 0) > cnvtdatetime(package_install_dt_tm))
    AND  NOT ( EXISTS (
   (SELECT
    orev2.order_id
    FROM order_review orev2
    WHERE orev2.order_id=onotif.order_id
     AND orev2.action_sequence=onotif.action_sequence
     AND ((orev2.review_type_flag+ 0)=doctor_review_type_flag)
     AND ((orev2.reviewed_status_flag+ 0)=not_reviewed_status_flag))))
    AND sqlpassthru("rownum <= 250000"))
  WITH nocounter
 ;end insert
 COMMIT
END GO
