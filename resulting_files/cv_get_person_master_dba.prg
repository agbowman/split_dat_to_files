CREATE PROGRAM cv_get_person_master:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 person_id = f8
      2 name_full_formatted = vc
      2 birth_dt_tm = dq8
      2 age = vc
      2 race_cd = f8
      2 race_disp = c40
      2 race_mean = c12
      2 sex_cd = f8
      2 sex_disp = c40
      2 sex_mean = c12
      2 name_last = vc
      2 name_first = vc
      2 name_middle = vc
      2 person_alias[*]
        3 person_alias_id = f8
        3 alias_pool_cd = f8
        3 person_alias_type_cd = f8
        3 person_alias_type_disp = c40
        3 person_alias_type_mean = c12
        3 alias = vc
        3 alias_formatted = vc
      2 person_name[*]
      2 address[*]
        3 address_id = f8
        3 address_type_cd = f8
        3 address_type_disp = c40
        3 address_type_mean = c12
        3 street_addr = vc
        3 street_addr2 = vc
        3 street_addr3 = vc
        3 street_addr4 = vc
        3 city = vc
        3 state_cd = f8
        3 state_disp = c40
        3 state_mean = c12
        3 zipcode = c25
        3 county_cd = f8
        3 county_disp = c40
        3 county_mean = c25
        3 country_cd = f8
        3 country_disp = c40
        3 country_mean = c25
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->status_data.status = "F"
 FREE SET count
 SET number_to_select = size(request->qual,5)
 SET count = 0
 SET stat = alterlist(reply->qual,size(request->qual,5))
 SELECT INTO "nl:"
  p.seq
  FROM person p,
   (dummyt d  WITH seq = value(number_to_select))
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=request->qual[d.seq].person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d.seq
  HEAD REPORT
   count = 0
  DETAIL
   count = d.seq, reply->qual[count].person_id = request->qual[d.seq].person_id, reply->qual[count].
   name_full_formatted = p.name_full_formatted,
   reply->qual[count].birth_dt_tm = p.birth_dt_tm, reply->qual[count].age = cnvtage(cnvtdate(p
     .birth_dt_tm),1), reply->qual[count].race_cd = p.race_cd,
   reply->qual[count].sex_cd = p.sex_cd, reply->qual[count].name_last = p.name_last, reply->qual[
   count].name_first = p.name_first,
   reply->qual[count].name_middle = p.name_middle
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PERSON"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (band(request->select_nbr,1)=1)
  SET count = 0
  SELECT INTO "nl:"
   FROM person_alias p,
    (dummyt d  WITH seq = value(number_to_select))
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=request->qual[d.seq].person_id)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY d.seq
   HEAD d.seq
    count = 0
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual[d.seq].person_alias,count), reply->qual[d.seq].
    person_alias[count].person_alias_id = p.person_alias_id,
    reply->qual[d.seq].person_alias[count].alias_pool_cd = p.alias_pool_cd, reply->qual[d.seq].
    person_alias[count].person_alias_type_cd = p.person_alias_type_cd, reply->qual[d.seq].
    person_alias[count].alias = p.alias,
    reply->qual[d.seq].person_alias[count].alias_formatted = cnvtalias(p.alias,p.alias_pool_cd)
   WITH nocounter
  ;end select
 ENDIF
 IF (band(request->select_nbr,2)=2)
  SELECT INTO "nl:"
   FROM person_name p,
    (dummyt d  WITH seq = value(number_to_select))
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=request->qual[d.seq].person_id)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY d.seq
   HEAD d.seq
    count = 0
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual[d.seq].person_name,count)
   WITH nocounter
  ;end select
 ENDIF
 IF (band(request->select_nbr,8)=8)
  SET count = 0
  SELECT INTO "nl:"
   FROM address a,
    (dummyt d  WITH seq = value(number_to_select))
   PLAN (d)
    JOIN (a
    WHERE (a.parent_entity_id=request->qual[d.seq].person_id)
     AND a.parent_entity_name="PERSON"
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY d.seq
   HEAD d.seq
    count = 0
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual[d.seq].address,count), reply->qual[d.seq].
    address[count].address_id = a.address_id,
    reply->qual[d.seq].address[count].address_type_cd = a.address_type_cd, reply->qual[d.seq].
    address[count].street_addr = a.street_addr, reply->qual[d.seq].address[count].street_addr2 = a
    .street_addr2,
    reply->qual[d.seq].address[count].street_addr3 = a.street_addr3, reply->qual[d.seq].address[count
    ].street_addr4 = a.street_addr4, reply->qual[d.seq].address[count].city = a.city,
    reply->qual[d.seq].address[count].state_cd = a.state_cd
    IF (a.state_cd=0)
     reply->qual[d.seq].address[count].state_disp = a.state
    ENDIF
    reply->qual[d.seq].address[count].county_cd = a.county_cd
    IF (a.county_cd=0)
     reply->qual[d.seq].address[count].county_disp = a.county
    ENDIF
    reply->qual[d.seq].address[count].country_cd = a.country_cd
    IF (a.country_cd=0)
     reply->qual[d.seq].address[count].country_disp = a.country
    ENDIF
    reply->qual[d.seq].address[count].zipcode = a.zipcode, a.parent_entity_id, d.seq,
    a.address_id, count, row + 1
   WITH nocounter
  ;end select
 ENDIF
#9999_end
#exit_script
END GO
