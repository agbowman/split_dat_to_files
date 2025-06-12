CREATE PROGRAM bbd_get_donor_nbr:dba
 RECORD reply(
   1 qual[*]
     2 person_alias_id = f8
     2 person_id = f8
     2 alias_type = vc
     2 alias = vc
     2 pa_updt_cnt = i4
     2 name_first = vc
     2 name_last = vc
     2 name_middle = vc
     2 birth_dt_tm = dq8
     2 sex_cd = f8
     2 species_cd = f8
     2 marital_type_cd = f8
     2 race_cd = f8
     2 nationality_cd = f8
     2 p_updt_cnt = i4
     2 person_name_id = f8
     2 name_maiden = vc
     2 pn_updt_cnt = i4
     2 pn_type = vc
     2 home_phone_id = f8
     2 home_phone = vc
     2 ph_home_updt_cnt = i4
     2 business_phone_id = f8
     2 business_phone = vc
     2 ph_business_updt_cnt = i4
     2 organization_id = f8
     2 person_org_reltn_id = f8
     2 por_updt_cnt = i4
     2 pd_updt_cnt = i4
     2 lock_ind = vc
     2 updt_applctx = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET code_cnt = 1
 SET donorid_code = 0.0
 SET ssn_code = 0.0
 SET drlic_code = 0.0
 SET current_code = 0.0
 SET maiden_code = 0.0
 SET home_phone_code = 0.0
 SET business_phone_code = 0.0
 SET code_set = 4
 SET cdf_meaning = "DONORID"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donorid_code)
 SET cdf_meaning = "DRLIC"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,drlic_code)
 SET cdf_meaning = "SSN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,ssn_code)
 SET code_set = 213
 SET cdf_meaning = "CURRENT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,current_code)
 SET cdf_meaning = "MAIDEN"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,maiden_code)
 SET code_set = 43
 SET cdf_meaning = "HOME"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,home_phone_code)
 SET cdf_meaning = "BUSINESS"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,business_phone_code)
 SET able_to_lock = "Y"
 SELECT INTO "nl:"
  p.*
  FROM person_donor p
  PLAN (p
   WHERE (p.person_id=request->person_id))
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].updt_applctx = p
   .updt_applctx,
   reply->qual[count].pd_updt_cnt = (p.updt_cnt+ 1), reply->status_data.status = "S"
   IF (p.lock_ind=1)
    able_to_lock = "N", reply->qual[count].lock_ind = "N"
   ENDIF
  WITH nocounter, forupdate(p)
 ;end select
 IF (able_to_lock="N")
  GO TO exitscript
 ELSE
  IF (count > 0)
   UPDATE  FROM person_donor p
    SET p.lock_ind = 1, p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
     updt_applctx
    PLAN (p
     WHERE (p.person_id=request->person_id)
      AND ((p.lock_ind = null) OR (p.lock_ind=0)) )
    WITH nocounter
   ;end update
   IF (curqual=1)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "Z"
    GO TO exitscript
   ENDIF
  ELSE
   SET able_to_lock = "X"
  ENDIF
 ENDIF
 SET count = 0
 SELECT DISTINCT INTO "nl:"
  pa.person_alias_id, pa.person_id, pa.person_alias_type_cd,
  pa.alias, pa.updt_cnt, p.name_first,
  p.name_last, p.name_middle, p.birth_dt_tm,
  p.sex_cd, p.species_cd, p.marital_type_cd,
  p.race_cd, p.nationality_cd, p.updt_cnt,
  pn.person_name_id, pn.name_type_cd, pn.name_full,
  pn.updt_cnt, ph1.updt_cnt, ph1.phone_num,
  ph2.updt_cnt, ph2.phone_num, por.organization_id,
  por.person_org_reltn_id, por.updt_cnt
  FROM person p,
   person_name pn,
   (dummyt d1  WITH seq = 1),
   person_alias pa,
   (dummyt d2  WITH seq = 1),
   phone ph1,
   (dummyt d3  WITH seq = 1),
   phone ph2,
   (dummyt d4  WITH seq = 1),
   person_org_reltn por
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
   JOIN (pn
   WHERE (pn.person_id=request->person_id)
    AND pn.active_ind=1
    AND pn.name_type_cd IN (current_code, maiden_code))
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (pa
   WHERE (pa.person_id=request->person_id)
    AND pa.active_ind=1
    AND ((pa.person_alias_type_cd=donorid_code) OR (((pa.person_alias_type_cd=ssn_code) OR (pa
   .person_alias_type_cd=drlic_code)) )) )
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (ph1
   WHERE p.person_id=ph1.parent_entity_id
    AND ph1.parent_entity_name="PERSON"
    AND ph1.phone_type_cd=home_phone_code
    AND ph1.active_ind=1)
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (ph2
   WHERE p.person_id=ph2.parent_entity_id
    AND ph2.parent_entity_name="PERSON"
    AND ph2.phone_type_cd=business_phone_code
    AND ph2.active_ind=1)
   JOIN (d4
   WHERE d4.seq=1)
   JOIN (por
   WHERE p.person_id=por.person_id
    AND por.active_ind=1)
  ORDER BY pa.person_alias_type_cd, pn.name_type_cd, 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].person_alias_id = pa
   .person_alias_id,
   reply->qual[count].person_id = pa.person_id
   IF (pa.person_alias_type_cd=donorid_code)
    reply->qual[count].alias_type = "DONORID"
   ELSEIF (pa.person_alias_type_cd=ssn_code)
    reply->qual[count].alias_type = "SSN"
   ELSEIF (pa.person_alias_type_cd=drlic_code)
    reply->qual[count].alias_type = "DRLIC"
   ENDIF
   reply->qual[count].alias = pa.alias, reply->qual[count].pa_updt_cnt = pa.updt_cnt, reply->qual[
   count].name_first = p.name_first,
   reply->qual[count].name_last = p.name_last, reply->qual[count].name_middle = p.name_middle, reply
   ->qual[count].birth_dt_tm = p.birth_dt_tm,
   reply->qual[count].sex_cd = p.sex_cd, reply->qual[count].species_cd = p.species_cd, reply->qual[
   count].marital_type_cd = p.marital_type_cd,
   reply->qual[count].race_cd = p.race_cd, reply->qual[count].nationality_cd = p.nationality_cd,
   reply->qual[count].p_updt_cnt = p.updt_cnt,
   reply->qual[count].person_name_id = pn.person_name_id
   IF (pn.name_type_cd=maiden_code)
    reply->qual[count].name_maiden = pn.name_full, reply->qual[count].pn_type = "MAIDEN"
   ELSE
    reply->qual[count].name_maiden = "", reply->qual[count].pn_type = "CURRENT"
   ENDIF
   reply->qual[count].pn_updt_cnt = pn.updt_cnt, reply->qual[count].ph_home_updt_cnt = ph1.updt_cnt,
   reply->qual[count].home_phone = ph1.phone_num,
   reply->qual[count].home_phone_id = ph1.phone_id, reply->qual[count].ph_business_updt_cnt = ph2
   .updt_cnt, reply->qual[count].business_phone = ph2.phone_num,
   reply->qual[count].business_phone_id = ph2.phone_id, reply->qual[count].organization_id = por
   .organization_id, reply->qual[count].por_updt_cnt = por.updt_cnt,
   reply->qual[count].person_org_reltn_id = por.person_org_reltn_id, reply->qual[count].lock_ind =
   able_to_lock
  WITH counter, outerjoin(d1), outerjoin(d2),
   outerjoin(d3), outerjoin(d4), dontcare(ph1),
   dontcare(ph2), dontcare(por)
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exitscript
 ENDIF
#exitscript
END GO
