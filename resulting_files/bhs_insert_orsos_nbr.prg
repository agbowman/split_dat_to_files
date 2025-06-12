CREATE PROGRAM bhs_insert_orsos_nbr
 DECLARE orderid = f8 WITH protect, noconstant(0.0)
 DECLARE personid = f8 WITH protect, noconstant(0.0)
 DECLARE encntrid = f8 WITH protect, noconstant(0.0)
 DECLARE preop = f8 WITH protect, noconstant(0.0)
 SET orso_nbr = request->qual[1].data[1].vc_var
 SET isnew = 1
 SET preop = uar_get_code_by("displaykey",200,"PREOPCHECKLIST")
 SET retval = 0
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.encntr_id=trigger_encntrid
    AND ((o.catalog_cd+ 0)=preop)
    AND ((o.order_status_cd+ 0) != 2542))
  ORDER BY o.order_id
  HEAD REPORT
   orderid = 0.0
  HEAD o.order_id
   orderid = o.order_id
  WITH nocounter
 ;end select
 IF (orderid > 0.0)
  UPDATE  FROM long_text lt
   SET lt.long_text = orso_nbr
   WHERE lt.parent_entity_id=orderid
    AND lt.parent_entity_name="ORDER_COMMENT"
    AND lt.active_ind=1
   WITH nocounter
  ;end update
  COMMIT
  SET log_message = build("orso_nbr:<<",orso_nbr,">>order_id:<<",orderid,">>")
  SET retval = 100
 ENDIF
END GO
