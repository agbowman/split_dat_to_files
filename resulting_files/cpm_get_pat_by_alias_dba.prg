CREATE PROGRAM cpm_get_pat_by_alias:dba
 RECORD reply(
   1 qual[1]
     2 name_full_formatted = vc
     2 person_id = f8
     2 birth_dt_tm = dq8
     2 age = c12
     2 sex_cd = f8
     2 sex_disp = c40
     2 person_alias_type_cd = f8
     2 person_alias_type_disp = vc
     2 alias = vc
     2 loc_facility_cd = f8
     2 loc_facility_disp = vc
     2 loc_nurse_unit_cd = f8
     2 loc_nurse_unit_disp = vc
     2 loc_room_cd = f8
     2 loc_room_disp = vc
     2 loc_bed_cd = f8
     2 loc_bed_disp = vc
     2 encntr_id = f8
     2 med_service_cd = f8
     2 med_service_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET code_set = 302
 SET cdf_meaning = "PERSON"
 SET code_value = 0.0
 EXECUTE cpm_get_cd_for_cdf
 SET person_type_cd = code_value
 IF ((request->return_location_ind=75))
  SELECT INTO "nl:"
   p.person_id, age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(
     format(p.birth_dt_tm,"hhmm;;m")))
   FROM person_alias pa,
    person p,
    (dummyt d  WITH seq = 1),
    encntr_domain ed
   PLAN (pa
    WHERE (pa.alias=request->alias)
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE pa.person_id=p.person_id
     AND p.active_ind=1
     AND p.person_type_cd=person_type_cd
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (d)
    JOIN (ed
    WHERE p.person_id=ed.person_id
     AND ed.active_ind=1
     AND ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ed.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (count1 > 1)
     stat = alter(reply->qual,count1)
    ENDIF
    reply->qual[count1].name_full_formatted = p.name_full_formatted, reply->qual[count1].person_id =
    p.person_id, reply->qual[count1].age = age,
    reply->qual[count1].sex_cd = p.sex_cd, reply->qual[count1].birth_dt_tm = cnvtdatetime(p
     .birth_dt_tm), reply->qual[count1].loc_facility_cd = ed.loc_facility_cd,
    reply->qual[count1].loc_nurse_unit_cd = ed.loc_nurse_unit_cd, reply->qual[count1].loc_room_cd =
    ed.loc_room_cd, reply->qual[count1].loc_bed_cd = ed.loc_bed_cd,
    reply->qual[count1].encntr_id = ed.encntr_id, reply->qual[count1].med_service_cd = ed
    .med_service_cd, reply->qual[count1].alias = trim(pa.alias),
    reply->qual[count1].person_alias_type_cd = pa.person_alias_type_cd
   WITH nocounter, outerjoin = d
  ;end select
 ELSE
  SELECT INTO "nl:"
   p.person_id, age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(
     format(p.birth_dt_tm,"hhmm;;m")))
   FROM person_alias pa,
    person p
   PLAN (pa
    WHERE (pa.alias=request->alias)
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE pa.person_id=p.person_id
     AND p.active_ind=1
     AND p.person_type_cd=person_type_cd
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (count1 > 1)
     stat = alter(reply->qual,count1)
    ENDIF
    reply->qual[count1].name_full_formatted = p.name_full_formatted, reply->qual[count1].person_id =
    p.person_id, reply->qual[count1].age = age,
    reply->qual[count1].sex_cd = p.sex_cd
    IF (nullind(p.birth_dt_tm)=0)
     reply->qual[count1].birth_dt_tm = cnvtdatetime(p.birth_dt_tm)
    ENDIF
    reply->qual[count1].alias = trim(pa.alias), reply->qual[count1].person_alias_type_cd = pa
    .person_alias_type_cd
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
