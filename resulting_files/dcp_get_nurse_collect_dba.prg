CREATE PROGRAM dcp_get_nurse_collect:dba
 SET junk = 0
 SET oecount = 0
 SET ordercnt = 0
 SET code_value = 0
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET action_type_cd_for_order = code_value
 SET nbr_to_get = cnvtint(size(request->order_list,5))
 CALL echo(build("nbr_to_get = ",nbr_to_get))
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   o.order_id, off.oe_format_id, oef.oe_field_id,
   ofm.oe_field_meaning_id
   FROM (dummyt d1  WITH seq = value(nbr_to_get)),
    orders o,
    oe_format_fields off,
    order_entry_fields oef,
    oe_field_meaning ofm
   PLAN (d1)
    JOIN (o
    WHERE (o.order_id=request->order_list[d1.seq].order_id)
     AND o.active_ind=1)
    JOIN (off
    WHERE off.oe_format_id=o.oe_format_id
     AND off.action_type_cd=action_type_cd_for_order)
    JOIN (oef
    WHERE oef.oe_field_id=off.oe_field_id)
    JOIN (ofm
    WHERE ofm.oe_field_meaning_id=oef.oe_field_meaning_id
     AND ((ofm.oe_field_meaning="COLLBY") OR (((ofm.oe_field_meaning="COLLECTEDYN") OR (ofm
    .oe_field_meaning="REQSTARTDTTM")) )) )
   ORDER BY o.order_id
   HEAD REPORT
    junk = junk, ordercnt = 0
   HEAD o.order_id
    ordercnt += 1
    IF (ordercnt > size(reply->order_list,5))
     stat = alterlist(reply->order_list,(ordercnt+ 5))
    ENDIF
    reply->order_list[ordercnt].order_id = o.order_id, reply->order_list[ordercnt].oe_format_id = o
    .oe_format_id, oecount = 0
   DETAIL
    oecount += 1
    IF (oecount > size(reply->order_list[ordercnt].oe_list,5))
     stat = alterlist(reply->order_list[ordercnt].oe_list,(oecount+ 5))
    ENDIF
    reply->order_list[ordercnt].oe_list[oecount].oe_field_id = oef.oe_field_id, reply->order_list[
    ordercnt].oe_list[oecount].oe_field_meaning = ofm.oe_field_meaning, reply->order_list[ordercnt].
    oe_list[oecount].oe_field_meaning_id = ofm.oe_field_meaning_id
   FOOT  o.order_id
    stat = alterlist(reply->order_list[ordercnt].oe_list,oecount)
   FOOT REPORT
    stat = alterlist(reply->order_list,ordercnt)
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 FOR (x = 1 TO ordercnt)
   CALL echo(build("action_type_cd ",action_type_cd_for_order))
   CALL echo(build("order_id =",reply->order_list[x].order_id))
   SET oecount = size(reply->order_list[x].oe_list,5)
   CALL echo(build("x =",x,"  OECount=",oecount))
   FOR (y = 1 TO oecount)
     CALL echo(build("oe_field_id=",reply->order_list[x].oe_list[y].oe_field_id))
     CALL echo(build("oe_field_meaning=",reply->order_list[x].oe_list[y].oe_field_meaning))
     CALL echo(build("oe_field_meaning_id=",reply->order_list[x].oe_list[y].oe_field_meaning_id))
   ENDFOR
 ENDFOR
END GO
