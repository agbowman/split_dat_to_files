CREATE PROGRAM dcp_get_spec_details:dba
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->order_list,5))
 SET new_action_type_cd = 0.0
 SET modify_action_type_cd = 0.0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET new_action_type_cd = code_value
 SET code_set = 6003
 SET cdf_meaning = "MODIFY"
 EXECUTE cpm_get_cd_for_cdf
 SET modify_action_type_cd = code_value
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   o.order_id, o.template_order_id, od.order_id,
   od.oe_field_id
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    orders o,
    order_action oa,
    order_detail od
   PLAN (d)
    JOIN (o
    WHERE (o.order_id=request->order_list[d.seq].order_id))
    JOIN (oa
    WHERE (((oa.order_id=request->order_list[d.seq].order_id)
     AND ((oa.action_type_cd=new_action_type_cd) OR (oa.action_type_cd=modify_action_type_cd))
     AND oa.action_rejected_ind=0) OR (o.template_order_flag IN (2, 3, 4, 6)
     AND oa.order_id=o.template_order_id
     AND ((oa.action_type_cd=new_action_type_cd) OR (oa.action_type_cd=modify_action_type_cd))
     AND oa.action_rejected_ind=0)) )
    JOIN (od
    WHERE oa.order_id=od.order_id
     AND oa.action_sequence=od.action_sequence
     AND ((od.oe_field_meaning="FREQ") OR (((od.oe_field_meaning="RSN") OR (od.oe_field_meaning=
    "RXROUTE")) )) )
   ORDER BY o.order_id, o.template_order_id, od.order_id,
    od.oe_field_id, od.action_sequence
   HEAD REPORT
    count1 = 0
   HEAD o.order_id
    count1 += 1
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].order_id = o.order_id
   DETAIL
    CALL echo(build("oe_field_meaning:",od.oe_field_meaning)),
    CALL echo(build("o.template_order_id",o.template_order_id)),
    CALL echo(build("od.order_id",od.order_id))
    IF (((o.order_id=od.order_id) OR (o.order_id != od.order_id
     AND od.oe_field_meaning="FREQ")) )
     CALL echo(build("detail passes check"))
     CASE (od.oe_field_meaning)
      OF "FREQ":
       reply->get_list[count1].frequency_cd = od.oe_field_value,reply->get_list[count1].frequency =
       od.oe_field_display_value
      OF "RSN":
       reply->get_list[count1].reason_for_giving = od.oe_field_display_value
      OF "RXROUTE":
       reply->get_list[count1].route = od.oe_field_display_value
     ENDCASE
    ENDIF
   FOOT  od.oe_field_id
    col + 0
   FOOT REPORT
    stat = alterlist(reply->get_list,count1)
   WITH check
  ;end select
 ENDIF
 SET x = 0
 FOR (x = 1 TO count1)
   CALL echo(build("order_id:",reply->get_list[x].order_id))
   CALL echo(build("freq cd:",reply->get_list[x].frequency_cd))
   CALL echo(build("freq:",reply->get_list[x].frequency))
   CALL echo(build("route:",reply->get_list[x].route))
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
