CREATE PROGRAM bed_get_work_route_orders_ex:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 catalog_type_code_value = f8
    1 load_assigned_ind = i2
    1 routing_level_ind = i2
    1 activity_types[*]
      2 code_value = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orderables[*]
      2 code_value = f8
      2 primary_mnemonic = c100
      2 assigned_ind = i2
      2 activity_subtype_code_value = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE oc_parse = vc
 SET oc_parse = concat("oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2",
  " and oc.active_ind = 1"," and (oc.bill_only_ind = 0 or oc.bill_only_ind = NULL) ")
 IF ((request->routing_level_ind=1))
  SET oc_parse = concat(oc_parse," and (oc.resource_route_lvl != 2 or oc.resource_route_lvl = NULL)")
 ELSE
  SET oc_parse = concat(oc_parse," and (oc.resource_route_lvl != 1 or oc.resource_route_lvl = NULL)")
 ENDIF
 IF ((request->catalog_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.catalog_type_cd = ",request->catalog_type_code_value)
 ENDIF
 DECLARE inclause = vc
 DECLARE atcnt = i4
 DECLARE atidx = i4
 SET atcnt = size(request->activity_types,5)
 IF (atcnt > 0)
  FOR (atidx = 1 TO atcnt)
    IF (atidx=1)
     SET inclause = build(inclause,request->activity_types[atidx].code_value)
    ELSE
     SET inclause = build(inclause,", ",request->activity_types[atidx].code_value)
    ENDIF
  ENDFOR
  CALL echo(inclause)
  SET oc_parse = build(oc_parse," and oc.activity_type_cd in (",inclause,")")
 ENDIF
 CALL echo(oc_parse)
 SET ocnt = 0
 SET alterlist_ocnt = 0
 SET stat = alterlist(reply->orderables,100)
 SELECT INTO "nl:"
  FROM order_catalog oc
  WHERE parser(oc_parse)
  DETAIL
   ocnt = (ocnt+ 1), alterlist_ocnt = (alterlist_ocnt+ 1)
   IF (alterlist_ocnt > 100)
    stat = alterlist(reply->orderables,(ocnt+ 100)), alterlist_ocnt = 1
   ENDIF
   reply->orderables[ocnt].code_value = oc.catalog_cd, reply->orderables[ocnt].primary_mnemonic = oc
   .primary_mnemonic, reply->orderables[ocnt].activity_subtype_code_value = oc.activity_subtype_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->orderables,ocnt)
 IF ((request->load_assigned_ind=1)
  AND ocnt > 0)
  IF ((request->routing_level_ind=1))
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     orc_resource_list orl,
     code_value cv
    PLAN (d)
     JOIN (orl
     WHERE (orl.catalog_cd=reply->orderables[d.seq].code_value)
      AND orl.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=orl.service_resource_cd
      AND cv.active_ind=1)
    DETAIL
     reply->orderables[d.seq].assigned_ind = 1
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     profile_task_r ptr,
     assay_resource_list asl,
     code_value cv
    PLAN (d)
     JOIN (ptr
     WHERE (ptr.catalog_cd=reply->orderables[d.seq].code_value)
      AND ptr.active_ind=1)
     JOIN (asl
     WHERE asl.task_assay_cd=ptr.task_assay_cd
      AND asl.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=asl.service_resource_cd
      AND cv.active_ind=1)
    DETAIL
     reply->orderables[d.seq].assigned_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
