CREATE PROGRAM cps_get_person_addr:dba
 RECORD reply(
   1 name_qual = i4
   1 name[*]
     2 name_full = vc
     2 name_first = vc
     2 name_middle = vc
     2 name_last = vc
     2 name_degree = vc
     2 name_title = vc
     2 name_prefix = vc
     2 name_suffix = vc
     2 name_initials = vc
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
     2 state_cd = f8
     2 state_disp = c40
     2 state_mean = c12
     2 zipcode = c25
     2 address_type_seq = i4
   1 phone_qual = i4
   1 phone[*]
     2 phone_id = f8
     2 phone_type_cd = f8
     2 phone_type_disp = vc
     2 phone_type_mean = vc
     2 phone_format_cd = f8
     2 phone_format_disp = vc
     2 phone_format_mean = vc
     2 phone_num = vc
     2 extension = vc
     2 paging_code = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->name_qual = 0
 SET reply->address_qual = 0
 SET reply->phone_qual = 0
 SET count1 = 0
 SET nbr_of_people = size(request->person_list,5)
 SELECT INTO "NL:"
  p.person_id
  FROM person_name p,
   (dummyt d  WITH seq = value(nbr_of_people))
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=request->person_list[d.seq].person_id))
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->name,10)
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->name,(count1+ 9))
   ENDIF
   reply->name[count1].name_full = p.name_full, reply->name[count1].name_first = p.name_first, reply
   ->name[count1].name_middle = p.name_middle,
   reply->name[count1].name_last = p.name_last, reply->name[count1].name_degree = p.name_degree,
   reply->name[count1].name_title = p.name_title,
   reply->name[count1].name_prefix = p.name_prefix, reply->name[count1].name_suffix = p.name_suffix,
   reply->name[count1].name_initials = p.name_initials
  FOOT REPORT
   reply->name_qual = count1, stat = alterlist(reply->name,count1)
  WITH check, nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "NL:"
  FROM address a,
   code_value c,
   code_value c1,
   (dummyt d  WITH seq = value(size(request->person_list,5)))
  PLAN (d)
   JOIN (a
   WHERE (request->person_list[d.seq].person_id=a.parent_entity_id)
    AND a.parent_entity_name="PERSON")
   JOIN (c
   WHERE a.address_type_cd=c.code_value)
   JOIN (c1
   WHERE a.state_cd=c1.code_value)
  HEAD REPORT
   stat = alterlist(reply->address,10), count1 = 1
  DETAIL
   IF (size(reply->address,5) <= count1)
    stat = alterlist(reply->address,(count1+ 10))
   ENDIF
   reply->address[count1].address_id = a.address_id, reply->address[count1].address_type_cd = a
   .address_type_cd, reply->address[count1].address_type_disp = c.display,
   reply->address[count1].address_type_mean = c.cdf_meaning, reply->address[count1].street_addr = a
   .street_addr, reply->address[count1].street_addr2 = a.street_addr2,
   reply->address[count1].street_addr3 = a.street_addr3, reply->address[count1].street_addr4 = a
   .street_addr4, reply->address[count1].city = a.city,
   reply->address[count1].state_cd = a.state_cd, reply->address[count1].state_disp = c1.display,
   reply->address[count1].state_mean = c1.cdf_meaning,
   reply->address[count1].zipcode = a.zipcode, reply->address[count1].address_type_seq = a
   .address_type_seq, count1 += 1
  FOOT REPORT
   stat = alterlist(reply->address,count1), reply->address_qual = count1
  WITH check, nocounter
 ;end select
 SELECT INTO "NL:"
  FROM phone p,
   code_value c,
   code_value c1,
   (dummyt d  WITH seq = value(size(request->person_list,5)))
  PLAN (d)
   JOIN (p
   WHERE (request->person_list[d.seq].person_id=p.parent_entity_id)
    AND p.parent_entity_name="PERSON")
   JOIN (c
   WHERE p.phone_type_cd=c.code_value)
   JOIN (c1
   WHERE p.phone_format_cd=c1.code_value)
  HEAD REPORT
   stat = alterlist(reply->phone,10), count1 = 1
  DETAIL
   IF (size(reply->phone,5) <= count1)
    stat = alterlist(reply->phone,(count1+ 10))
   ENDIF
   reply->phone[count1].phone_id = p.phone_id, reply->phone[count1].phone_type_cd = p.phone_type_cd,
   reply->phone[count1].phone_type_disp = c.display,
   reply->phone[count1].phone_type_mean = c.cdf_meaning, reply->phone[count1].phone_format_cd = p
   .phone_format_cd, reply->phone[count1].phone_format_disp = c1.display,
   reply->phone[count1].phone_format_mean = c1.cdf_meaning, reply->phone[count1].phone_num = p
   .phone_num, reply->phone[count1].extension = p.extension,
   reply->phone[count1].paging_code = p.paging_code
  FOOT REPORT
   stat = alterlist(reply->phone,count1), reply->phone_qual = count1
  WITH check, nocounter
 ;end select
END GO
