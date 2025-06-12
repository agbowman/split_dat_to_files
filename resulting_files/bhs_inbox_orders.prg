CREATE PROGRAM bhs_inbox_orders
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE o_canceled_cd = f8
 DECLARE o_discontinued_cd = f8
 DECLARE o_deleted_cd = f8
 SET o_canceled_cd = uar_get_code_by("MEANING",6004,"CANCELED")
 SET o_discontinued_cd = uar_get_code_by("MEANING",6004,"DISCONTINUED")
 SET o_deleted_cd = uar_get_code_by("MEANING",6004,"DELETED")
 SELECT INTO  $1
  FROM order_review orv,
   prsnl p,
   orders o
  PLAN (p
   WHERE p.physician_ind=1)
   JOIN (orv
   WHERE orv.provider_id=p.person_id
    AND orv.review_type_flag=2
    AND orv.reviewed_status_flag=0
    AND  NOT (orv.order_id IN (
   (SELECT
    orn.order_id
    FROM order_notification orn
    WHERE orv.order_id=orn.order_id
     AND orv.provider_id=orn.from_prsnl_id
     AND orn.caused_by_flag IN (1, 2)))))
   JOIN (o
   WHERE o.order_id=orv.order_id
    AND  NOT (o.order_status_cd IN (o_deleted_cd)))
  ORDER BY p.name_full_formatted, orv.order_id
  HEAD p.name_full_formatted
   cnt = 0
  HEAD orv.order_id
   cnt = (cnt+ 1)
  FOOT  p.name_full_formatted
   phys_name_disp = substring(1,30,p.name_full_formatted), col 1, phys_name_disp,
   col 45, cnt, row + 1
  WITH nocounter, maxqual(p,10)
 ;end select
END GO
