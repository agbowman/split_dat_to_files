CREATE PROGRAM bhs_eks_order_status:dba
 DECLARE inprocess_6004 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS")), protect
 DECLARE inprocess_14281 = f8 WITH constant(uar_get_code_by("MEANING",14281,"LABINPROCESS")), protect
 DECLARE pedipost = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"PEDIPOSTPROCEDUREINTERVIEW")),
 protect
 SET encntrid = trigger_encntrid
 SET personid = trigger_personid
 SET mode = "A"
 SET listid = 31196309.00
 SET orderid = 0
 SELECT INTO "nl:"
  FROM orders o
  WHERE o.encntr_id=encntrid
   AND o.catalog_cd=pedipost
   AND o.dept_status_cd != inprocess_14281
  DETAIL
   orderid = o.order_id
  WITH nocounter
 ;end select
 CALL echo(build("orderid:",orderid))
 CALL echo(build("curqual:",curqual))
 CALL echo(build("inprocess_6004:",inprocess_6004))
 CALL echo(build("inprocess_14281:",inprocess_14281))
 CALL echo(build("pedipost:",pedipost))
 IF (curqual > 0)
  UPDATE  FROM orders o
   SET o.order_status_cd = inprocess_6004, o.dept_status_cd = inprocess_14281
   WHERE o.order_id=orderid
   WITH nocounter
  ;end update
  COMMIT
  UPDATE  FROM order_action oa
   SET oa.order_status_cd = inprocess_6004, oa.dept_status_cd = inprocess_14281
   WHERE oa.order_id=orderid
   WITH nocounter
  ;end update
  COMMIT
  EXECUTE bhs_eks_updt_custom_list listid, "A", personid,
  encntrid
 ELSE
  SET retval = 0
 ENDIF
END GO
