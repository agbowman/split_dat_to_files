CREATE PROGRAM cps_get_preferred_rx:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 rx_qual[*]
       3 routing_dest_cd = f8
       3 routing_dest_display = vc
       3 organization_id = f8
       3 organization_name = vc
       3 org_type_cd = f8
       3 updt_dt_tm = dq8
       3 freetext_fax_nbr = vc
       3 order_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET reply->status_data.status = "S"
 DECLARE cfax = i4 WITH protect, constant(138)
 DECLARE cfreetextfax = i4 WITH protect, constant(139)
 DECLARE max_rx_cnt = i4 WITH protect, noconstant(0)
 DECLARE p_cnt = i4 WITH protect, noconstant(0)
 DECLARE crx = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(278,"PHARMACY",1,crx)
 DECLARE cfaxtypecd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(3000,"FAX",1,cfaxtypecd)
 DECLARE crxtypecd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(6000,"PHARMACY",1,crxtypecd)
 DECLARE new_list_size = i4
 DECLARE cur_list_size = i4
 DECLARE batch_size = i4 WITH constant(10)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 SET cur_list_size = size(request->qual,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(request->qual,new_list_size)
 SET stat = alterlist(reply->qual,new_list_size)
 SET nstart = 1
 CALL echo(build("cur_list_size = ",cur_list_size))
 FOR (idx = 1 TO cur_list_size)
   SET reply->qual[idx].person_id = request->qual[cur_list_size].person_id
 ENDFOR
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
  SET request->qual[idx].person_id = request->qual[cur_list_size].person_id
  SET reply->qual[idx].person_id = request->qual[cur_list_size].person_id
 ENDFOR
 CALL echorecord(reply)
 DECLARE num = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  od.*
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   orders o,
   order_detail od,
   output_dest ods,
   device_xref dx,
   organization org
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (o
   WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),o.person_id,request->qual[idx].person_id)
    AND o.catalog_type_cd=crxtypecd
    AND o.orig_ord_as_flag=1)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning_id=cfax)
   JOIN (ods
   WHERE ods.output_dest_cd=od.oe_field_value)
   JOIN (dx
   WHERE dx.device_cd=ods.device_cd
    AND trim(dx.parent_entity_name)="ORGANIZATION"
    AND ((dx.usage_type_cd+ 0)=cfaxtypecd))
   JOIN (org
   WHERE org.organization_id=dx.parent_entity_id
    AND  EXISTS (
   (SELECT
    otr.organization_id
    FROM org_type_reltn otr
    WHERE otr.organization_id=org.organization_id
     AND otr.org_type_cd=crx)))
  ORDER BY o.person_id, od.updt_dt_tm DESC
  HEAD REPORT
   p_cnt = 0
  HEAD o.person_id
   p_cnt = (p_cnt+ 1), stat = alterlist(reply->qual,p_cnt), reply->qual[p_cnt].person_id = o
   .person_id,
   o_cnt = 0
  DETAIL
   ipos = 0
   IF (o_cnt > 0)
    ipos = locateval(num,1,o_cnt,od.oe_field_value,reply->qual[p_cnt].rx_qual[num].routing_dest_cd)
   ENDIF
   IF (o_cnt <= 5
    AND ipos=0)
    o_cnt = (o_cnt+ 1)
    IF (o_cnt > max_rx_cnt)
     max_rx_cnt = o_cnt
    ENDIF
    stat = alterlist(reply->qual[p_cnt].rx_qual,o_cnt), reply->qual[p_cnt].rx_qual[o_cnt].
    routing_dest_cd = od.oe_field_value, reply->qual[p_cnt].rx_qual[o_cnt].updt_dt_tm = od.updt_dt_tm,
    reply->qual[p_cnt].rx_qual[o_cnt].organization_id = dx.parent_entity_id, reply->qual[p_cnt].
    rx_qual[o_cnt].organization_name = org.org_name, reply->qual[p_cnt].rx_qual[o_cnt].org_type_cd =
    crx,
    reply->qual[p_cnt].rx_qual[o_cnt].order_id = od.order_id
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,p_cnt)
 SELECT INTO "nl:"
  *
  FROM (dummyt d1  WITH seq = value(size(reply->qual,5))),
   (dummyt d2  WITH seq = value(max_rx_cnt)),
   order_detail od
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(reply->qual[d1.seq].rx_qual,5))
   JOIN (od
   WHERE (od.order_id=reply->qual[d1.seq].rx_qual[d2.seq].order_id)
    AND od.oe_field_meaning_id=cfreetextfax)
  DETAIL
   reply->qual[d1.seq].rx_qual[d2.seq].freetext_fax_nbr = od.oe_field_display_value
  WITH nocounter
 ;end select
#exit_script
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->status_data.status = "F"
 ELSEIF (size(reply->qual,5)=0)
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "005"
END GO
