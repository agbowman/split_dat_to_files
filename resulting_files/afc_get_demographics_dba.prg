CREATE PROGRAM afc_get_demographics:dba
 IF ("Z"=validate(afc_get_demographics_vrsn,"Z"))
  DECLARE afc_get_demographics_vrsn = vc WITH noconstant("95504.012")
 ENDIF
 SET afc_get_demographics_vrsn = "95504.012"
 RECORD reply(
   1 person_qual = i2
   1 qual[*]
     2 person_id = f8
     2 patient_name = vc
     2 dob = dq8
     2 birth_tz = i4
     2 sex_type_cd = f8
     2 sex_type_disp = c40
     2 sex_type_desc = c60
     2 sex_type_mean = c12
     2 med_rec_num = vc
     2 fin_num = vc
     2 doctor = vc
     2 unit_type_cd = f8
     2 unit_type_disp = c40
     2 unit_type_desc = c60
     2 unit_type_mean = c12
     2 facility_type_cd = f8
     2 facility_type_disp = c40
     2 facility_type_desc = c60
     2 facility_type_mean = c12
     2 room_type_cd = f8
     2 room_type_disp = c40
     2 room_type_desc = c60
     2 room_type_mean = c12
     2 room_type_cd = f8
     2 room_type_disp = c40
     2 room_type_desc = c60
     2 room_type_mean = c12
     2 bed_type_cd = f8
     2 bed_type_disp = c60
     2 bed_type_desc = c40
     2 bed_type_mean = c12
     2 loc_nurse_unit_type_cd = f8
     2 loc_nurse_unit_type_disp = c40
     2 loc_nurse_unit_type_desc = c60
     2 loc_nurse_unit_type_mean = c12
     2 financial_class_cd = f8
     2 financial_class_disp = c40
     2 financial_class_desc = c60
     2 financial_class_mean = c12
     2 building_cd = f8
     2 building_disp = c40
     2 building_desc = c60
     2 building_mean = c12
     2 organization = vc
     2 reg_dt_tm = dq8
     2 health_plan_id = f8
     2 primary_health_plan = vc
     2 encntr_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SET count1 = 0
 DECLARE mrn = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET code_set = 319
 SET cdf_meaning = "MRN"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,mrn)
 DECLARE fin = f8
 SET cdf_meaning = "FIN NBR"
 SET code_set = 319
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,fin)
 DECLARE admit_doc = f8
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,admit_doc)
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SET stat = alterlist(reply->qual,(count1+ 10))
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM person p
  WHERE (p.person_id=request->person_id)
  DETAIL
   count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].person_id = p.person_id,
   reply->qual[count1].patient_name = p.name_full_formatted, reply->qual[count1].dob = p.birth_dt_tm,
   reply->qual[count1].birth_tz = p.birth_tz,
   reply->qual[count1].sex_type_cd = p.sex_cd
  WITH nocounter
 ;end select
 SET reply->person_qual = count1
 DECLARE organization_id = f8
 SELECT INTO "nl:"
  e.person_id
  FROM encounter e,
   (dummyt d1  WITH seq = value(reply->person_qual))
  PLAN (d1)
   JOIN (e
   WHERE (e.encntr_id=request->encntr_id))
  DETAIL
   request->person_id = e.person_id, reply->qual[d1.seq].building_cd = e.loc_building_cd,
   organization_id = e.organization_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM organization o,
   (dummyt d1  WITH seq = value(reply->person_qual))
  PLAN (d1)
   JOIN (o
   WHERE o.organization_id=organization_id)
  DETAIL
   reply->qual[d1.seq].organization = o.org_name
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  ea.encntr_id
  FROM encntr_alias ea,
   (dummyt d1  WITH seq = value(reply->person_qual))
  PLAN (d1
   WHERE (reply->qual[d1.seq].person_id > 0))
   JOIN (ea
   WHERE (ea.encntr_id=request->encntr_id)
    AND ea.encntr_alias_type_cd=mrn
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  DETAIL
   reply->qual[d1.seq].med_rec_num = cnvtalias(ea.alias,ea.alias_pool_cd)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  ea.encntr_id
  FROM encntr_alias ea,
   (dummyt d1  WITH seq = value(reply->person_qual))
  PLAN (d1
   WHERE (reply->qual[d1.seq].person_id > 0))
   JOIN (ea
   WHERE (ea.encntr_id=request->encntr_id)
    AND ea.encntr_alias_type_cd=fin
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  DETAIL
   reply->qual[d1.seq].fin_num = cnvtalias(ea.alias,ea.alias_pool_cd)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pr.prsnl_person_id, ps.name_full_formatted
  FROM encntr_prsnl_reltn pr,
   prsnl ps,
   (dummyt d1  WITH seq = value(reply->person_qual))
  PLAN (d1)
   JOIN (pr
   WHERE (pr.encntr_id=request->encntr_id)
    AND pr.encntr_prsnl_r_cd=admit_doc
    AND pr.active_ind=1)
   JOIN (ps
   WHERE ps.person_id=pr.prsnl_person_id
    AND pr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pr.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND ps.active_ind=1)
  DETAIL
   reply->qual[d1.seq].doctor = ps.name_full_formatted
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  e.encntr_id
  FROM encounter e,
   (dummyt d1  WITH seq = value(reply->person_qual))
  PLAN (d1
   WHERE (reply->qual[d1.seq].person_id > 0))
   JOIN (e
   WHERE (e.encntr_id=request->encntr_id)
    AND e.active_ind=1)
  DETAIL
   reply->qual[d1.seq].unit_type_cd = e.location_cd, reply->qual[d1.seq].facility_type_cd = e
   .loc_facility_cd, reply->qual[d1.seq].room_type_cd = e.loc_room_cd,
   reply->qual[d1.seq].bed_type_cd = e.loc_bed_cd, reply->qual[d1.seq].loc_nurse_unit_type_cd = e
   .loc_nurse_unit_cd, reply->qual[d1.seq].financial_class_cd = e.financial_class_cd,
   reply->qual[d1.seq].reg_dt_tm = e.reg_dt_tm, reply->qual[d1.seq].encntr_type_cd = e.encntr_type_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_plan_reltn e,
   (dummyt d1  WITH seq = value(reply->person_qual))
  PLAN (d1
   WHERE (reply->qual[d1.seq].person_id > 0))
   JOIN (e
   WHERE (e.encntr_id=request->encntr_id)
    AND e.priority_seq=1
    AND e.active_ind=1)
  DETAIL
   reply->qual[d1.seq].health_plan_id = e.health_plan_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM health_plan h,
   (dummyt d1  WITH seq = value(reply->person_qual))
  PLAN (d1
   WHERE (reply->qual[d1.seq].person_id > 0))
   JOIN (h
   WHERE (h.health_plan_id=reply->qual[d1.seq].health_plan_id))
  DETAIL
   reply->qual[d1.seq].primary_health_plan = h.plan_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORGANIZATION"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
