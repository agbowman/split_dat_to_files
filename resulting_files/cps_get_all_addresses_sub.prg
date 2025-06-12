CREATE PROGRAM cps_get_all_addresses_sub
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET nbr_parent_id_rows = size(request->qual,5)
 IF (trim(request->parent_entity_name)="")
  SELECT INTO "nl:"
   FROM address a
   PLAN (a
    WHERE a.active_ind=1
     AND a.address_id > 0
     AND a.parent_entity_id > 0
     AND a.parent_entity_id < 2000000000
     AND a.parent_entity_name IN ("PERSON", "ORGANIZATION", "PLAN_CONTACT", "PLANCONTACT")
     AND a.street_addr > " "
     AND a.state > " ")
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,100)=1)
     stat = alterlist(reply->address,(count1+ 100))
    ENDIF
    reply->address[count1].address_id = a.address_id, reply->address[count1].parent_entity_name = a
    .parent_entity_name, reply->address[count1].parent_entity_id = a.parent_entity_id,
    reply->address[count1].updt_cnt = a.updt_cnt, reply->address[count1].street_addr = a.street_addr,
    reply->address[count1].street_addr2 = a.street_addr2,
    reply->address[count1].city = a.city, reply->address[count1].state = a.state, reply->address[
    count1].zipcode = a.zipcode,
    reply->address[count1].county = a.county, reply->address[count1].country = a.country, reply->
    address[count1].address_type_cd = a.address_type_cd,
    reply->address[count1].address_type_seq = a.address_type_seq, reply->address[count1].comment_txt
     = a.comment_txt, reply->address[count1].beg_effective_dt_tm = cnvtdatetime(a.beg_effective_dt_tm
     ),
    reply->address[count1].end_effective_dt_tm = cnvtdatetime(a.end_effective_dt_tm),
    CALL echo(a.address_id)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM address a,
    (dummyt d  WITH seq = value(nbr_parent_id_rows))
   PLAN (d)
    JOIN (a
    WHERE (request->qual[d.seq].parent_entity_id=a.parent_entity_id)
     AND  $1
     AND  $2
     AND (a.parent_entity_name=request->parent_entity_name)
     AND a.active_ind=1
     AND a.address_id > 0
     AND a.parent_entity_id > 0
     AND a.parent_entity_id < 2000000000
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,100)=1)
     stat = alterlist(reply->address,(count1+ 100))
    ENDIF
    reply->address[count1].address_id = a.address_id, reply->address[count1].parent_entity_name = a
    .parent_entity_name, reply->address[count1].parent_entity_id = a.parent_entity_id,
    reply->address[count1].updt_cnt = a.updt_cnt, reply->address[count1].street_addr = a.street_addr,
    reply->address[count1].street_addr2 = a.street_addr2,
    reply->address[count1].city = a.city, reply->address[count1].state = a.state, reply->address[
    count1].zipcode = a.zipcode,
    reply->address[count1].county = a.county, reply->address[count1].country = a.country, reply->
    address[count1].address_type_cd = a.address_type_cd,
    reply->address[count1].address_type_seq = a.address_type_seq, reply->address[count1].comment_txt
     = a.comment_txt, reply->address[count1].beg_effective_dt_tm = cnvtdatetime(a.beg_effective_dt_tm
     ),
    reply->address[count1].end_effective_dt_tm = cnvtdatetime(a.end_effective_dt_tm)
   WITH nocounter
  ;end select
 ENDIF
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->address,count1)
 SET reply->address_qual = count1
END GO
