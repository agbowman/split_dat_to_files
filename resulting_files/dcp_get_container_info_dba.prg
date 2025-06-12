CREATE PROGRAM dcp_get_container_info:dba
 RECORD reply(
   1 container_list[*]
     2 container_id = f8
     2 specimen_type_cd = f8
     2 specimen_cntnr_cd = f8
     2 specimen_id = f8
     2 volume = f8
     2 volume_unit_cd = f8
     2 accession_nbr = i4
     2 accession = c20
     2 accession_fmt = c25
     2 collection_status_flag = i2
     2 coll_class_cd = f8
     2 collection_method_cd = f8
     2 updt_cnt = i4
     2 spec_updt_cnt = i4
     2 orders[*]
       3 order_id = f8
       3 ocr_updt_cnt = i4
     2 accession_id = f8
   1 related_containers[*]
     2 container_id = f8
     2 collection_status_flag = i2
     2 coll_class_cd = f8
     2 accession_nbr = i4
     2 accession = c20
     2 accession_fmt = c25
     2 volume = f8
     2 volume_unit_cd = f8
     2 orders[*]
       3 order_id = f8
       3 ocr_updt_cnt = i4
   1 orders[*]
     2 order_id = f8
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 order_mnemonic = vc
     2 order_detail_display_line = vc
     2 dept_status_cd = f8
     2 order_status_cd = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 oe_format_id = f8
     2 catalog_type_cd = f8
     2 updt_cnt = i4
     2 catalog_cd = f8
     2 activity_type_cd = f8
     2 encntr_id = f8
     2 synonym_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE cont_cnt = i4 WITH noconstant(0)
 DECLARE ord_cnt = i4 WITH noconstant(0)
 DECLARE cont_ord_cnt = i4 WITH noconstant(0)
 DECLARE rel_cont_cnt = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE cont_idx = i4 WITH noconstant(0)
 DECLARE prev_used_collection_status_flag = i2 WITH noconstant(- (1)), protect
 DECLARE pending = i2 WITH constant(0), protect
 DECLARE collected = i2 WITH constant(1), protect
 DECLARE missedandtoberecollected = i2 WITH constant(3), protect
 DECLARE canceled = i2 WITH constant(5), protect
 DECLARE loggedin = i2 WITH constant(0), protect
 DECLARE inlab = i2 WITH constant(1), protect
 DECLARE resulted = i2 WITH constant(2), protect
 SET stat = alterlist(reply->container_list,size(request->containers,5))
 FOR (num = 1 TO size(request->containers,5))
   SET reply->container_list[num].container_id = request->containers[num].container_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(reply->container_list,5))),
   order_container_r ocr,
   container c,
   container_accession ca,
   v500_specimen s,
   order_serv_res_container osrc
  PLAN (d1)
   JOIN (ocr
   WHERE (ocr.container_id=reply->container_list[d1.seq].container_id))
   JOIN (c
   WHERE (c.container_id=reply->container_list[d1.seq].container_id))
   JOIN (ca
   WHERE (ca.container_id=reply->container_list[d1.seq].container_id))
   JOIN (s
   WHERE s.specimen_id=c.specimen_id)
   JOIN (osrc
   WHERE osrc.container_id=ocr.container_id
    AND osrc.order_id=ocr.order_id)
  ORDER BY ocr.container_id, ocr.order_id
  HEAD ocr.container_id
   prev_used_collection_status_flag = - (1), cont_ord_cnt = 0, cont_cnt = (cont_cnt+ 1),
   cont_idx = locateval(num,1,size(reply->container_list,5),ocr.container_id,reply->container_list[
    num].container_id)
   IF (cont_idx > 0)
    reply->container_list[cont_idx].specimen_type_cd = c.specimen_type_cd, reply->container_list[
    cont_idx].specimen_cntnr_cd = c.spec_cntnr_cd, reply->container_list[cont_idx].specimen_id = c
    .specimen_id,
    reply->container_list[cont_idx].volume = c.volume, reply->container_list[cont_idx].volume_unit_cd
     = c.units_cd, reply->container_list[cont_idx].coll_class_cd = c.coll_class_cd,
    reply->container_list[cont_idx].collection_method_cd = c.collection_method_cd, reply->
    container_list[cont_idx].accession_nbr = ca.accession_container_nbr, reply->container_list[
    cont_idx].accession = ca.accession,
    reply->container_list[cont_idx].accession_id = ca.accession_id, reply->container_list[cont_idx].
    accession_fmt = uar_fmt_accession(ca.accession,size(ca.accession,1)), reply->container_list[
    cont_idx].updt_cnt = c.updt_cnt,
    reply->container_list[cont_idx].spec_updt_cnt = s.updt_cnt
   ENDIF
  DETAIL
   cont_ord_cnt = (cont_ord_cnt+ 1)
   IF (cont_ord_cnt > size(reply->container_list[cont_idx].orders,5))
    stat = alterlist(reply->container_list[cont_idx].orders,(cont_ord_cnt+ 5))
   ENDIF
   reply->container_list[cont_idx].orders[cont_ord_cnt].order_id = ocr.order_id, reply->
   container_list[cont_idx].orders[cont_ord_cnt].ocr_updt_cnt = ocr.updt_cnt
   IF (locateval(num,1,size(reply->orders,5),ocr.order_id,reply->orders[num].order_id)=0)
    ord_cnt = (ord_cnt+ 1)
    IF (ord_cnt > size(reply->orders,5))
     stat = alterlist(reply->orders,(ord_cnt+ 5))
    ENDIF
    reply->orders[ord_cnt].order_id = ocr.order_id
   ENDIF
   IF (((cont_ord_cnt=1) OR (prev_used_collection_status_flag=canceled
    AND ocr.collection_status_flag != canceled)) )
    reply->container_list[cont_idx].collection_status_flag = evaluate(ocr.collection_status_flag,
     pending,pending,collected,evaluate(osrc.status_flag,loggedin,inlab,resulted),
     missedandtoberecollected), prev_used_collection_status_flag = ocr.collection_status_flag
   ELSEIF (ocr.collection_status_flag != canceled)
    reply->container_list[cont_idx].collection_status_flag = maxval(reply->container_list[cont_idx].
     collection_status_flag,evaluate(ocr.collection_status_flag,pending,pending,collected,evaluate(
       osrc.status_flag,loggedin,inlab,resulted),
      missedandtoberecollected)), prev_used_collection_status_flag = ocr.collection_status_flag
   ENDIF
  FOOT  ocr.container_id
   IF (cont_ord_cnt < size(reply->container_list[cont_idx].orders,5))
    stat = alterlist(reply->container_list[cont_idx].orders,cont_ord_cnt)
   ENDIF
  FOOT REPORT
   IF (ord_cnt < size(reply->orders,5))
    stat = alterlist(reply->orders,ord_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request->order_info_flag=1))
  CALL getorderinfo(null)
 ENDIF
 IF ((request->related_container_flag=1))
  CALL getrelatedcontainers(null)
 ENDIF
 SUBROUTINE getorderinfo(null)
   CALL echo(build("GetOrderInfo"))
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(reply->orders,5))),
     orders o
    PLAN (d1)
     JOIN (o
     WHERE (o.order_id=reply->orders[d1.seq].order_id))
    DETAIL
     reply->orders[d1.seq].hna_order_mnemonic = o.hna_order_mnemonic, reply->orders[d1.seq].
     ordered_as_mnemonic = o.ordered_as_mnemonic, reply->orders[d1.seq].order_mnemonic = o
     .order_mnemonic,
     reply->orders[d1.seq].order_detail_display_line = o.order_detail_display_line, reply->orders[d1
     .seq].dept_status_cd = o.dept_status_cd, reply->orders[d1.seq].order_status_cd = o
     .order_status_cd,
     reply->orders[d1.seq].orig_order_dt_tm = o.orig_order_dt_tm, reply->orders[d1.seq].orig_order_tz
      = o.orig_order_tz, reply->orders[d1.seq].oe_format_id = o.oe_format_id,
     reply->orders[d1.seq].catalog_type_cd = o.catalog_type_cd, reply->orders[d1.seq].updt_cnt = o
     .updt_cnt, reply->orders[d1.seq].catalog_cd = o.catalog_cd,
     reply->orders[d1.seq].activity_type_cd = o.activity_type_cd, reply->orders[d1.seq].encntr_id = o
     .encntr_id, reply->orders[d1.seq].synonym_id = o.synonym_id
    WITH nocounter
   ;end select
   CALL echo(build("end GetOrderInfo"))
 END ;Subroutine
 SUBROUTINE getrelatedcontainers(null)
   CALL echo(build("GetRelatedContainers"))
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(reply->orders,5))),
     order_container_r ocr,
     container c,
     container_accession ca,
     order_serv_res_container osrc
    PLAN (d1)
     JOIN (ocr
     WHERE (ocr.order_id=reply->orders[d1.seq].order_id)
      AND  NOT (expand(num,1,size(reply->container_list,5),ocr.container_id,reply->container_list[num
      ].container_id)))
     JOIN (c
     WHERE ocr.container_id=c.container_id)
     JOIN (ca
     WHERE ocr.container_id=ca.container_id)
     JOIN (osrc
     WHERE osrc.container_id=ocr.container_id
      AND osrc.order_id=ocr.order_id)
    ORDER BY ocr.container_id
    HEAD ocr.container_id
     prev_used_collection_status_flag = - (1), rel_cont_ord_cnt = 0, rel_cont_cnt = (rel_cont_cnt+ 1)
     IF (rel_cont_cnt > size(reply->related_containers,5))
      stat = alterlist(reply->related_containers,(rel_cont_cnt+ 5))
     ENDIF
     reply->related_containers[rel_cont_cnt].container_id = ocr.container_id, reply->
     related_containers[rel_cont_cnt].volume = c.volume, reply->related_containers[rel_cont_cnt].
     volume_unit_cd = c.units_cd,
     reply->related_containers[rel_cont_cnt].accession_nbr = ca.accession_container_nbr, reply->
     related_containers[rel_cont_cnt].accession = ca.accession, reply->related_containers[
     rel_cont_cnt].accession_fmt = uar_fmt_accession(ca.accession,size(ca.accession,1)),
     reply->related_containers[rel_cont_cnt].coll_class_cd = c.coll_class_cd
    DETAIL
     rel_cont_ord_cnt = (rel_cont_ord_cnt+ 1)
     IF (rel_cont_ord_cnt > size(reply->related_containers[rel_cont_cnt].orders,5))
      stat = alterlist(reply->related_containers[rel_cont_cnt].orders,(rel_cont_ord_cnt+ 5))
     ENDIF
     reply->related_containers[rel_cont_cnt].orders[rel_cont_ord_cnt].order_id = ocr.order_id, reply
     ->related_containers[rel_cont_cnt].orders[rel_cont_ord_cnt].ocr_updt_cnt = ocr.updt_cnt
     IF (((rel_cont_ord_cnt=1) OR (prev_used_collection_status_flag=canceled
      AND ocr.collection_status_flag != canceled)) )
      reply->related_containers[rel_cont_cnt].collection_status_flag = evaluate(ocr
       .collection_status_flag,pending,pending,collected,evaluate(osrc.status_flag,loggedin,inlab,
        resulted),
       missedandtoberecollected), prev_used_collection_status_flag = ocr.collection_status_flag
     ELSEIF (ocr.collection_status_flag != canceled)
      reply->related_containers[rel_cont_cnt].collection_status_flag = maxval(reply->container_list[
       rel_cont_cnt].collection_status_flag,evaluate(ocr.collection_status_flag,pending,pending,
        collected,evaluate(osrc.status_flag,loggedin,inlab,resulted),
        missedandtoberecollected)), prev_used_collection_status_flag = ocr.collection_status_flag
     ENDIF
    FOOT  ocr.container_id
     IF (rel_cont_ord_cnt < size(reply->related_containers[rel_cont_cnt].orders,5))
      stat = alterlist(reply->related_containers[rel_cont_cnt].orders,rel_cont_ord_cnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (rel_cont_cnt < size(reply->related_containers,5))
    SET stat = alterlist(reply->related_containers,rel_cont_cnt)
   ENDIF
   CALL echo(build("end GetRelatedContainers"))
 END ;Subroutine
 CALL echorecord(reply)
END GO
