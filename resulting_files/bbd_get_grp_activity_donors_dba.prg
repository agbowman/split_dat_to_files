CREATE PROGRAM bbd_get_grp_activity_donors:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 name = vc
     2 number = vc
     2 donation_dt_tm = dq8
     2 donation_level = f4
     2 last_donated = dq8
     2 outcome = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD struct(
   1 qual[*]
     2 success_cd = f8
 )
 RECORD struct_1(
   1 qual[*]
     2 unsuccess_cd = f8
 )
 SET reply->status_data.status = "F"
 SET qual_cnt = 0
 SET don_grand_total = 0.00
 SET donor_nbr_cd = 0.0
 SET contact_type_cd = 0.0
 SET donor_org_cd = 0.0
 SET struct_counter = 0
 SET struct1_counter = 0
 SET success_cd = 0.0
 SET unsuccess_cd = 0.0
 SET stat = alterlist(reply->qual,20)
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0
 SET code_cnt = 1
 SET code_set = 338
 SET cdf_meaning = "DONOR"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donor_org_cd)
 SET code_set = 14220
 SET cdf_meaning = "DONATE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,contact_type_cd)
 SET code_set = 4
 SET cdf_meaning = "DONORID"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donor_nbr_cd)
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=14221
   AND c.cdf_meaning="SUCCESS"
   AND c.active_ind=1
  DETAIL
   struct_counter = (struct_counter+ 1), stat1 = alterlist(struct->qual,struct_counter), struct->
   qual[struct_counter].success_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET nbr_struct = size(struct->qual,5)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=14221
   AND c.cdf_meaning != "SUCCESS"
   AND c.active_ind=1
  DETAIL
   struct1_counter = (struct1_counter+ 1), stat2 = alterlist(struct_1->qual,struct1_counter),
   struct_1->qual[struct1_counter].unsuccess_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET nbr = size(struct_1->qual,5)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SELECT INTO "nl:"
  dc.contact_dt_tm, dr.outcome_cd, outcome = uar_get_code_meaning(dr.outcome_cd),
  dc.person_id, pd.donation_level, pd.donation_level_trans,
  p.name_full_formatted, pa.alias
  FROM person_org_reltn po,
   bbd_donor_contact dc,
   person_donor pd,
   person_alias pa,
   person p,
   bbd_donation_results dr,
   (dummyt d1  WITH seq = value(nbr_struct)),
   (dummyt d2  WITH seq = value(nbr))
  PLAN (po
   WHERE (po.organization_id=request->organization_id)
    AND po.person_org_reltn_cd=donor_org_cd
    AND po.active_ind=1)
   JOIN (dc
   WHERE dc.organization_id=po.organization_id
    AND dc.person_id=po.person_id
    AND dc.contact_type_cd=contact_type_cd
    AND dc.contact_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND dc.active_ind=1)
   JOIN (d1)
   JOIN (d2)
   JOIN (dr
   WHERE dr.person_id=dc.person_id
    AND (((request->donation_type=1)
    AND (dr.outcome_cd=struct->qual[d1.seq].success_cd)) OR ((((request->donation_type=2)
    AND (dr.outcome_cd=struct_1->qual[d2.seq].unsuccess_cd)) OR ((request->donation_type=0)
    AND (((dr.outcome_cd=struct->qual[d1.seq].success_cd)) OR ((dr.outcome_cd=struct_1->qual[d2.seq].
   unsuccess_cd)))
    AND dr.active_ind=1)) )) )
   JOIN (p
   WHERE p.person_id=dc.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=donor_nbr_cd
    AND pa.active_ind=1)
   JOIN (pd
   WHERE pd.person_id=pa.person_id
    AND pd.active_ind=1)
  ORDER BY p.name_full_formatted, dc.person_id, dc.contact_dt_tm DESC
  HEAD dc.person_id
   don_grand_total = (pd.donation_level_trans+ pd.donation_level), qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,20)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 20))
   ENDIF
   reply->qual[qual_cnt].name = p.name_full_formatted, reply->qual[qual_cnt].number = pa.alias, reply
   ->qual[qual_cnt].donation_dt_tm = pd.last_donation_dt_tm,
   reply->qual[qual_cnt].donation_level = don_grand_total, reply->qual[qual_cnt].person_id = p
   .person_id, reply->qual[qual_cnt].last_donated = dc.contact_dt_tm,
   reply->qual[qual_cnt].outcome = outcome, don_grand_total = 0.0
  DETAIL
   row + 0
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alterlist(reply->qual,qual_cnt)
#exitscript
END GO
