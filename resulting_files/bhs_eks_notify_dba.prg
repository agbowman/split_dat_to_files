CREATE PROGRAM bhs_eks_notify:dba
 FREE RECORD bhsreqinfo
 RECORD bhsreqinfo(
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_id = f8
   1 updt_applctx = i4
   1 position_cd = f8
   1 commit_ind = i2
   1 perform_cnt = i4
   1 client_node_name = c100
 )
 SET retval = 0
 SET updt_app = reqinfo->updt_app
 SET updt_task = reqinfo->updt_task
 SET updt_req = reqinfo->updt_req
 SET updt_id = reqinfo->updt_id
 SET updt_applctx = reqinfo->updt_applctx
 SET position_cd = reqinfo->position_cd
 SET commit_ind = reqinfo->commit_ind
 SET perform_cnt = reqinfo->perform_cnt
 SET client_node_name = reqinfo->client_node_name
 DECLARE display_line = vc
 SET oid = trigger_orderid
 SET eid = trigger_encntrid
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od
  PLAN (o
   WHERE o.order_id=oid)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.action_sequence=o.last_action_sequence
    AND od.oe_field_meaning="ORDEROUTPUTDEST"
    AND od.oe_field_value > 0)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET retval = 100
  SELECT INTO "nl:"
   FROM orders o,
    order_action oa,
    prsnl pr,
    person p,
    encounter e,
    application_context ap
   PLAN (o
    WHERE o.order_id=oid)
    JOIN (oa
    WHERE o.order_id=oa.order_id
     AND o.last_action_sequence=oa.action_sequence)
    JOIN (pr
    WHERE oa.action_personnel_id=pr.person_id)
    JOIN (p
    WHERE p.person_id=o.person_id)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (ap
    WHERE ap.applctx=oa.updt_applctx)
   HEAD REPORT
    patloc = uar_get_code_display(e.loc_building_cd), dt = format(oa.updt_dt_tm,";;q"), dev = build(
     ap.application_image,"-",ap.client_node_name,"/",ap.logdirectory),
    display_line = build2("Patient: ",trim(p.name_full_formatted)," Provider: ",trim(pr
      .name_full_formatted)," Order: ",
     o.order_mnemonic," Order ID: ",cnvtstring(trigger_orderid)," D/T: ",dt,
     " Device: ",trim(dev)," PT Loc: ",patloc)
   WITH nocounter
  ;end select
  SET log_message = build(display_line)
  SET log_misc1 = build(display_line)
 ELSE
  SET log_message = "it is not a fax"
  SET retval = 0
 ENDIF
END GO
