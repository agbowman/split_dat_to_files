CREATE PROGRAM bbd_get_recruiting_rslts:dba
 RECORD reply(
   1 list[*]
     2 list_id = f8
     2 from_dt_tm = di8
     2 to_dt_tm = di8
     2 rare_type_cd = f8
     2 donation_procedure_cd = f8
     2 special_interest_cd = f8
     2 abo_cd = f8
     2 rh_cd = f8
     2 race_cd = f8
     2 organization_id = f8
     2 org_name = vc
     2 completed_ind = i2
     2 last_person_id = f8
     2 updt_cnt = i4
     2 antigen[*]
       3 recruit_antigen_id = f8
       3 antigen_cd = f8
       3 antigen_cd_disp = vc
       3 antigen_cd_mean = vc
       3 updt_cnt = i4
     2 zipcode[*]
       3 zip_code_id = f8
       3 zip_code = c25
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET lcount = 0
 SET acount = 0
 SET zcount = 0
 SET hold_list_id = 0.0
 SELECT INTO "nl:"
  FROM bbd_recruiting_list l,
   (dummyt d3  WITH seq = 1),
   organization o,
   (dummyt d1  WITH seq = 1),
   bbd_recruiting_antigen a,
   (dummyt d2  WITH seq = 1),
   bbd_recruiting_zipcode z
  PLAN (l
   WHERE l.list_id > 0
    AND l.active_ind=1
    AND l.completed_ind=0)
   JOIN (d3)
   JOIN (o
   WHERE o.organization_id=l.organization_id
    AND o.active_ind=1)
   JOIN (((d1
   WHERE d1.seq=1)
   JOIN (a
   WHERE a.list_id=l.list_id
    AND a.active_ind=1)
   ) ORJOIN ((d2
   WHERE d2.seq=1)
   JOIN (z
   WHERE z.list_id=l.list_id
    AND z.active_ind=1)
   ))
  ORDER BY l.list_id
  HEAD REPORT
   lcount = 0
  HEAD l.list_id
   IF (l.list_id != hold_list_id)
    hold_list_id = l.list_id, lcount = (lcount+ 1), acount = 0,
    zcount = 0, stat = alterlist(reply->list,lcount), reply->list[lcount].list_id = l.list_id,
    reply->list[lcount].from_dt_tm = l.from_dt_tm, reply->list[lcount].to_dt_tm = l.to_dt_tm, reply->
    list[lcount].rare_type_cd = l.rare_type_cd,
    reply->list[lcount].donation_procedure_cd = l.donation_procedure_cd, reply->list[lcount].
    special_interest_cd = l.special_interest_cd, reply->list[lcount].abo_cd = l.abo_cd,
    reply->list[lcount].rh_cd = l.rh_cd, reply->list[lcount].race_cd = l.race_cd, reply->list[lcount]
    .organization_id = l.organization_id,
    reply->list[lcount].org_name = o.org_name, reply->list[lcount].completed_ind = l.completed_ind,
    reply->list[lcount].last_person_id = l.last_person_id,
    reply->list[lcount].updt_cnt = l.updt_cnt
   ENDIF
  DETAIL
   row + 0
  FOOT  a.recruit_antigen_id
   IF (a.recruit_antigen_id > 0)
    acount = (acount+ 1), stat = alterlist(reply->list[lcount].antigen,acount), reply->list[lcount].
    antigen[acount].recruit_antigen_id = a.recruit_antigen_id,
    reply->list[lcount].antigen[acount].antigen_cd = a.antigen_cd, reply->list[lcount].antigen[acount
    ].updt_cnt = a.updt_cnt
   ENDIF
  FOOT  z.zip_code
   IF (z.zip_code_id > 0)
    zcount = (zcount+ 1), stat = alterlist(reply->list[lcount].zipcode,zcount), reply->list[lcount].
    zipcode[zcount].zip_code_id = z.zip_code_id,
    reply->list[lcount].zipcode[zcount].zip_code = z.zip_code, reply->list[lcount].zipcode[zcount].
    updt_cnt = z.updt_cnt
   ENDIF
  WITH counter, dontcare = o, outerjoin = d1,
   outerjoin = d2
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
