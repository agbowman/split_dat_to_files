CREATE PROGRAM bed_get_existing_aliases:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 description = vc
     2 inbound_aliases[*]
       3 alias = vc
     2 outbound_alias = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 orderables[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 description = vc
     2 inbound_aliases[*]
       3 alias = vc
     2 outbound_alias = vc
 )
 SET reply->status_data.status = "F"
 DECLARE oc_parse = vc
 SET oc_parse = build2(" oc.active_ind = 1 and oc.catalog_type_cd = ",cnvtstring(request->
   catalog_type_code_value)," and oc.activity_type_cd = ",cnvtstring(request->
   activity_type_code_value))
 IF ((request->subactivity_type_code_value > 0))
  SET oc_parse = build2(oc_parse," and oc.activity_subtype_cd = ",cnvtstring(request->
    subactivity_type_code_value))
 ENDIF
 SET ocnt = 0
 SELECT INTO "NL:"
  FROM order_catalog oc,
   code_value cv,
   code_value_outbound cvo,
   code_value_alias cva
  PLAN (oc
   WHERE parser(oc_parse))
   JOIN (cv
   WHERE cv.code_value=oc.catalog_cd
    AND cv.active_ind=1)
   JOIN (cvo
   WHERE cvo.code_value=outerjoin(oc.catalog_cd)
    AND cvo.contributor_source_cd=outerjoin(request->contributor_source_code_value))
   JOIN (cva
   WHERE cva.code_value=outerjoin(oc.catalog_cd)
    AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
  ORDER BY oc.catalog_cd
  HEAD oc.catalog_cd
   ocnt = (ocnt+ 1), stat = alterlist(temp->orderables,ocnt), temp->orderables[ocnt].code_value = oc
   .catalog_cd,
   temp->orderables[ocnt].display = cv.display, temp->orderables[ocnt].mean = cv.cdf_meaning, temp->
   orderables[ocnt].description = cv.description
   IF (cvo.code_value > 0)
    IF (cvo.alias > " ")
     temp->orderables[ocnt].outbound_alias = cvo.alias
    ELSE
     temp->orderables[ocnt].outbound_alias = "<space>"
    ENDIF
   ENDIF
   icnt = 0
  DETAIL
   IF (cva.alias > " ")
    icnt = (icnt+ 1), stat = alterlist(temp->orderables[ocnt].inbound_aliases,icnt), temp->
    orderables[ocnt].inbound_aliases[icnt].alias = cva.alias
   ENDIF
  WITH nocounter
 ;end select
 SET rcnt = 0
 FOR (o = 1 TO ocnt)
   SET icnt = size(temp->orderables[o].inbound_aliases,5)
   SET move_to_reply = 0
   IF ((temp->orderables[o].outbound_alias > " "))
    SET move_to_reply = 1
   ELSE
    FOR (i = 1 TO icnt)
      IF ((temp->orderables[o].inbound_aliases[i].alias > " "))
       SET move_to_reply = 1
      ENDIF
    ENDFOR
   ENDIF
   IF (move_to_reply=1)
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->orderables,rcnt)
    SET reply->orderables[rcnt].code_value = temp->orderables[o].code_value
    SET reply->orderables[rcnt].display = temp->orderables[o].display
    SET reply->orderables[rcnt].mean = temp->orderables[o].mean
    SET reply->orderables[rcnt].description = temp->orderables[o].description
    SET reply->orderables[rcnt].outbound_alias = temp->orderables[o].outbound_alias
    IF (icnt > 0)
     SET stat = alterlist(reply->orderables[rcnt].inbound_aliases,icnt)
     FOR (i = 1 TO icnt)
       SET reply->orderables[rcnt].inbound_aliases[i].alias = temp->orderables[o].inbound_aliases[i].
       alias
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
