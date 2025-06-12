CREATE PROGRAM cps_get_address_by_type:dba
 FREE SET reply
 RECORD reply(
   1 address_qual = i4
   1 address[*]
     2 address_id = f8
     2 address_type_cd = f8
     2 address_type_disp = vc
     2 address_type_mean = vc
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state = vc
     2 state_cd = f8
     2 state_disp = c40
     2 state_mean = c12
     2 zipcode = c25
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET knt = size(request->qual,5)
 CALL echo(build("knt : ",knt))
 SELECT
  IF (((knt > 0) OR ((request->qual_cnt > 0))) )
   PLAN (d
    WHERE d.seq > 0)
    JOIN (a
    WHERE a.parent_entity_name="PERSON"
     AND (a.parent_entity_id=request->person_id)
     AND (a.address_type_cd=request->qual[d.seq].address_type_cd)
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ELSE
   PLAN (d)
    JOIN (a
    WHERE a.parent_entity_name="PERSON"
     AND (a.parent_entity_id=request->person_id)
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ENDIF
  INTO "nl:"
  FROM address a,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  ORDER BY d.seq, a.address_type_seq
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->address,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->address,(cnt+ 9))
   ENDIF
   reply->address[cnt].address_id = a.address_id, reply->address[cnt].address_type_cd = a
   .address_type_cd,
   CALL echo(build("address : ",reply->address[cnt].address_type_cd)),
   CALL echo(build("d.seq : ",d.seq)), reply->address[cnt].street_addr = a.street_addr, reply->
   address[cnt].street_addr2 = a.street_addr2,
   reply->address[cnt].street_addr3 = a.street_addr3, reply->address[cnt].street_addr4 = a
   .street_addr4, reply->address[cnt].city = a.city,
   reply->address[cnt].state_cd = a.state_cd
   IF (a.state_cd > 0)
    reply->address[cnt].state = uar_get_code_display(a.state_cd)
   ELSE
    reply->address[cnt].state = a.state
   ENDIF
   CALL echo(build("state : ",reply->address[cnt].state_cd)), reply->address[cnt].zipcode = a.zipcode
  FOOT REPORT
   reply->address_qual = cnt, stat = alterlist(reply->address,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->address_qual = 0
  SET reply->status_data.status = "Z"
 ELSEIF (curqual < 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ADDRESS"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "005"
END GO
