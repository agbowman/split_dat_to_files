CREATE PROGRAM bbt_get_dispense_locn:dba
 RECORD reply(
   1 qual[*]
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = c60
     2 location_mean = c12
     2 location_type_cd = f8
     2 resource_ind = i2
     2 active_ind = i2
     2 census_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 DECLARE slocationname = vc WITH protect, noconstant("")
 SET count1 = 0
 SET nurse_unit_cd = 0.0
 SET ancilsurg_cd = 0.0
 SET ambulatory_cd = 0.0
 SET active_status_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,active_status_cd)
 IF (active_status_cd <= 0)
  SET reply->status_data.status = "F"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get active status code value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "ACTIVE"
  GO TO exit_script
 ENDIF
 SET nurse_unit_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(222,"NURSEUNIT",1,nurse_unit_cd)
 IF (nurse_unit_cd <= 0)
  SET reply->status_data.status = "F"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get Nurse Unit code value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "NURSEUNIT"
  GO TO exit_script
 ENDIF
 SET ancilsurg_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(222,"ANCILSURG",1,ancilsurg_cd)
 IF (ancilsurg_cd <= 0)
  SET reply->status_data.status = "F"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get Ancillary Surgery code value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "ANCILSURG"
  GO TO exit_script
 ENDIF
 SET ambulatory_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(222,"AMBULATORY",1,ambulatory_cd)
 IF (ambulatory_cd <= 0)
  SET reply->status_data.status = "F"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get Ancillary Surgery code value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "AMBULATORY"
  GO TO exit_script
 ENDIF
 DECLARE dlogicaldomain = f8 WITH noconstant(0.0)
 FREE RECORD acm_get_curr_logical_domain_req
 FREE RECORD acm_get_curr_logical_domain_rep
 IF (validate(ld_concept_person)=0)
  DECLARE ld_concept_person = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_prsnl)=0)
  DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
 ENDIF
 IF (validate(ld_concept_organization)=0)
  DECLARE ld_concept_organization = i2 WITH public, constant(3)
 ENDIF
 IF (validate(ld_concept_healthplan)=0)
  DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
 ENDIF
 IF (validate(ld_concept_alias_pool)=0)
  DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
 ENDIF
 IF (validate(ld_concept_minvalue)=0)
  DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_maxvalue)=0)
  DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
 ENDIF
 RECORD acm_get_curr_logical_domain_req(
   1 concept = i4
 )
 RECORD acm_get_curr_logical_domain_rep(
   1 logical_domain_id = f8
   1 status_block
     2 status_ind = i2
     2 error_code = i4
 )
 SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
 EXECUTE acm_get_curr_logical_domain
 SET dlogicaldomain = acm_get_curr_logical_domain_rep->logical_domain_id
 FREE RECORD acm_get_curr_logical_domain_req
 FREE RECORD acm_get_curr_logical_domain_rep
 SET slocationname = concat(cnvtupper(request->location_name),"*")
 SELECT
  IF (trim(request->location_name)="")
   PLAN (l
    WHERE l.location_type_cd IN (nurse_unit_cd, ancilsurg_cd, ambulatory_cd)
     AND l.active_status_cd=active_status_cd)
    JOIN (cv
    WHERE cv.code_value=l.location_cd
     AND cnvtdatetime(curdate,curtime3) >= cv.begin_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= cv.end_effective_dt_tm
     AND cv.active_ind=1)
    JOIN (o
    WHERE o.organization_id=l.organization_id
     AND ((o.logical_domain_id=dlogicaldomain) OR (o.organization_id=0)) )
  ELSE
   PLAN (l
    WHERE l.location_type_cd IN (nurse_unit_cd, ancilsurg_cd, ambulatory_cd)
     AND l.active_status_cd=active_status_cd)
    JOIN (cv
    WHERE cv.code_value=l.location_cd
     AND cnvtdatetime(curdate,curtime3) >= cv.begin_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= cv.end_effective_dt_tm
     AND cv.active_ind=1
     AND cnvtupper(cv.display)=patstring(slocationname))
    JOIN (o
    WHERE o.organization_id=l.organization_id
     AND ((o.logical_domain_id=dlogicaldomain) OR (o.organization_id=0)) )
  ENDIF
  INTO "nl:"
  l.seq, l.location_type_cd, l.resource_ind,
  l.active_ind, l.census_ind, l.active_status_cd,
  l.active_status_dt_tm, l.updt_cnt, cv.seq
  FROM location l,
   code_value cv,
   organization o
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].location_cd = l.location_cd, reply->qual[count1].location_type_cd = l
   .location_type_cd, reply->qual[count1].resource_ind = l.resource_ind,
   reply->qual[count1].active_ind = l.active_ind, reply->qual[count1].census_ind = l.census_ind,
   reply->qual[count1].active_status_cd = l.active_status_cd
   IF (null(l.active_status_dt_tm)=0)
    reply->qual[count1].active_status_dt_tm = cnvtdatetime(l.active_status_dt_tm)
   ENDIF
   reply->qual[count1].updt_cnt = l.updt_cnt
  WITH nocounter
 ;end select
 IF (count1 != 0)
  SET stat = alterlist(reply->qual,count1)
 ENDIF
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
