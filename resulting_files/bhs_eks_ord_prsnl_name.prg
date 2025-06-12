CREATE PROGRAM bhs_eks_ord_prsnl_name
 DECLARE order_action_type_cd = f8
 SET order_action_type_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SELECT INTO "nl:"
  oa.order_id, pr.name_full_formatted
  FROM order_action oa,
   prsnl pr
  PLAN (oa
   WHERE oa.order_id=link_orderid
    AND oa.action_type_cd=order_action_type_cd)
   JOIN (pr
   WHERE pr.person_id=oa.action_personnel_id)
  DETAIL
   cclprogram_message = pr.name_full_formatted, cclprogram_status = 1, col 1,
   oa.order_id, row + 1, col 1,
   pr.name_full_formatted
  WITH nocounter
 ;end select
 IF (cclprogram_status != 1)
  SET cclprogram_message = "Unknown Personnel"
  SET cclprogram_status = 1
 ENDIF
END GO
