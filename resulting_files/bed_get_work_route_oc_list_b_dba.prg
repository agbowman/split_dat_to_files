CREATE PROGRAM bed_get_work_route_oc_list_b:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 catalog_type_code_value = f8
    1 activity_type_code_value = f8
    1 activity_subtype_code_value = f8
    1 departments[*]
      2 code_value = f8
    1 exclude_bill_only_ind = i2
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
 RECORD temp(
   1 service_resources[*]
     2 code_value = f8
 )
 SET reply->status_data.status = "F"
 SET dcnt = size(request->departments,5)
 DECLARE oc_parse = vc
 SET oc_parse = concat("oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2",
  " and oc.active_ind = 1 and (oc.resource_route_lvl != 2 or oc.resource_route_lvl = NULL)")
 IF ((request->catalog_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.catalog_type_cd = ",request->catalog_type_code_value)
 ENDIF
 IF ((request->activity_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.activity_type_cd = ",request->activity_type_code_value)
 ENDIF
 IF ((request->activity_subtype_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.activity_subtype_cd = ",request->activity_subtype_code_value
   )
 ENDIF
 IF ((request->exclude_bill_only_ind > 0))
  SET oc_parse = concat(oc_parse," and (oc.bill_only_ind = 0 or oc.bill_only_ind = NULL) ")
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
 SET stat = alterlist(temp->service_resources,100)
 SET scnt = 0
 SET tot_scnt = 0
 IF (dcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = dcnt),
    code_value cv,
    resource_group r1,
    resource_group r2,
    resource_group r3
   PLAN (d)
    JOIN (r1
    WHERE (r1.parent_service_resource_cd=request->departments[d.seq].code_value)
     AND r1.active_ind=1)
    JOIN (r2
    WHERE r2.parent_service_resource_cd=r1.child_service_resource_cd
     AND r2.active_ind=1)
    JOIN (r3
    WHERE r3.parent_service_resource_cd=r2.child_service_resource_cd
     AND r3.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=r3.child_service_resource_cd
     AND cv.active_ind=1
     AND cv.code_set=221
     AND ((cv.cdf_meaning="BENCH") OR (cv.cdf_meaning="INSTRUMENT")) )
   DETAIL
    tot_scnt = (tot_scnt+ 1), scnt = (scnt+ 1)
    IF (scnt > 100)
     stat = alterlist(temp->service_resources,(tot_scnt+ 100)), scnt = 0
    ENDIF
    temp->service_resources[tot_scnt].code_value = cv.code_value
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = dcnt),
    code_value cv,
    resource_group r1,
    resource_group r2,
    sub_section ss
   PLAN (d)
    JOIN (r1
    WHERE (r1.parent_service_resource_cd=request->departments[d.seq].code_value)
     AND r1.active_ind=1)
    JOIN (r2
    WHERE r2.parent_service_resource_cd=r1.child_service_resource_cd
     AND r2.active_ind=1)
    JOIN (ss
    WHERE ss.multiplexor_ind=1
     AND ss.service_resource_cd=r2.child_service_resource_cd)
    JOIN (cv
    WHERE cv.code_value=r2.child_service_resource_cd
     AND cv.active_ind=1
     AND cv.code_set=221
     AND cv.cdf_meaning="SUBSECTION")
   DETAIL
    tot_scnt = (tot_scnt+ 1), scnt = (scnt+ 1)
    IF (scnt > 100)
     stat = alterlist(temp->service_resources,(tot_scnt+ 100)), scnt = 0
    ENDIF
    temp->service_resources[tot_scnt].code_value = cv.code_value
   WITH nocounter
  ;end select
  SET stat = alterlist(temp->service_resources,tot_scnt)
 ENDIF
 IF (tot_scnt > 0
  AND ocnt > 0)
  FOR (o = 1 TO ocnt)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = tot_scnt),
      orc_resource_list orl
     PLAN (d
      WHERE (reply->orderables[o].assigned_ind=0))
      JOIN (orl
      WHERE (orl.catalog_cd=reply->orderables[o].code_value)
       AND (orl.service_resource_cd=temp->service_resources[d.seq].code_value)
       AND orl.active_ind=1)
     DETAIL
      reply->orderables[o].assigned_ind = 1
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
