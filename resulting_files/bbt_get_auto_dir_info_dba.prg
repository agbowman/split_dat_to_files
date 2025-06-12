CREATE PROGRAM bbt_get_auto_dir_info:dba
 RECORD reply(
   1 name_full_formatted = vc
   1 person_id = f8
   1 encounter_id = f8
   1 alias = vc
   1 expected_usage_dt_tm = dq8
   1 associated_dt_tm = dq8
   1 abo_cd = f8
   1 rh_cd = f8
   1 producteventlist[*]
     2 product_event_id = f8
     2 name_full_formatted = vc
     2 person_id = f8
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 age = vc
     2 gender_cd = f8
     2 gender_disp = c40
     2 encounter_id = f8
     2 mrn = vc
     2 fin = vc
     2 ssn = vc
     2 expected_usage_dt_tm = dq8
     2 associated_dt_tm = dq8
     2 abo_cd = f8
     2 abo_disp = c40
     2 rh_cd = f8
     2 rh_disp = c40
     2 donated_by_relative_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD queryproductevents(
   1 producteventlist[*]
     2 product_event_id = f8
 )
 DECLARE finaliastypecd = f8 WITH protected, noconstant(0.0)
 DECLARE idxproductevent = i4 WITH protected, noconstant(0)
 DECLARE mrnaliastypecd = f8 WITH protected, noconstant(0.0)
 DECLARE producteventcnt = i4 WITH protected, noconstant(0)
 DECLARE requestproducteventcnt = i4 WITH protected, noconstant(0)
 DECLARE ssnaliastypecd = f8 WITH protected, noconstant(0.0)
 DECLARE stat = i4 WITH protected, noconstant(0)
 DECLARE uselistinquery = i2 WITH protected, noconstant(0)
 SET mrnaliastypecd = uar_get_code_by("MEANING",319,"MRN")
 CALL echo(build(mrnaliastypecd))
 IF (mrnaliastypecd < 1.0)
  GO TO fail_script
 ENDIF
 SET finaliastypecd = uar_get_code_by("MEANING",319,"FIN NBR")
 CALL echo(build(finaliastypecd))
 IF (finaliastypecd < 1.0)
  GO TO fail_script
 ENDIF
 SET ssnaliastypecd = uar_get_code_by("MEANING",4,"SSN")
 CALL echo(build(ssnaliastypecd))
 IF (ssnaliastypecd < 1.0)
  GO TO fail_script
 ENDIF
 SET requestproducteventcnt = size(request->producteventlist,5)
 IF (requestproducteventcnt > 0
  AND (request->product_event_id > 0.0))
  GO TO fail_script
 ENDIF
 IF (requestproducteventcnt=0
  AND (request->product_event_id=0.0))
  GO TO fail_script
 ENDIF
 IF (requestproducteventcnt=0)
  SET requestproducteventcnt = 1
  SET stat = alterlist(queryproductevents->producteventlist,1)
  SET queryproductevents->producteventlist[1].product_event_id = request->product_event_id
  SET uselistinquery = 0
 ELSE
  SET stat = alterlist(queryproductevents->producteventlist,requestproducteventcnt)
  FOR (idxproductevent = 1 TO requestproducteventcnt)
    SET queryproductevents->producteventlist[idxproductevent].product_event_id = request->
    producteventlist[idxproductevent].product_event_id
  ENDFOR
  SET uselistinquery = 1
 ENDIF
 SELECT INTO "nl:"
  ad.expected_usage_dt_tm, ad.donated_by_relative_ind, per.birth_dt_tm,
  per.birth_tz, age = cnvtage(per.birth_dt_tm), per.name_full_formatted,
  per.person_id, gender = per.sex_cd, ad.encntr_id,
  mrn = cnvtalias(ea_mrn.alias,ea_mrn.alias_pool_cd), fin = cnvtalias(ea_fin.alias,ea_fin
   .alias_pool_cd), ssn = cnvtalias(palias.alias,palias.alias_pool_cd),
  pa.abo_cd, pa.rh_cd
  FROM auto_directed ad,
   product p,
   person per,
   encntr_alias ea_mrn,
   encntr_alias ea_fin,
   person_alias palias,
   person_aborh pa
  PLAN (ad
   WHERE expand(idxproductevent,1,requestproducteventcnt,ad.product_event_id,queryproductevents->
    producteventlist[idxproductevent].product_event_id)
    AND ad.active_ind=1
    AND ad.person_id != null
    AND ad.person_id > 0.0)
   JOIN (p
   WHERE p.product_id=ad.product_id)
   JOIN (per
   WHERE per.person_id=ad.person_id
    AND per.active_ind=1)
   JOIN (ea_mrn
   WHERE (ea_mrn.encntr_id= Outerjoin(ad.encntr_id))
    AND (ea_mrn.encntr_alias_type_cd= Outerjoin(mrnaliastypecd))
    AND (ea_mrn.active_ind= Outerjoin(1)) )
   JOIN (ea_fin
   WHERE (ea_fin.encntr_id= Outerjoin(ad.encntr_id))
    AND (ea_fin.encntr_alias_type_cd= Outerjoin(finaliastypecd))
    AND (ea_fin.active_ind= Outerjoin(1)) )
   JOIN (palias
   WHERE (palias.person_id= Outerjoin(per.person_id))
    AND (palias.person_alias_type_cd= Outerjoin(ssnaliastypecd))
    AND (palias.active_ind= Outerjoin(1)) )
   JOIN (pa
   WHERE (pa.person_id= Outerjoin(per.person_id))
    AND (pa.active_ind= Outerjoin(1)) )
  DETAIL
   IF (uselistinquery=0)
    reply->name_full_formatted = per.name_full_formatted, reply->person_id = per.person_id, reply->
    encounter_id = ad.encntr_id
    IF (ea_mrn.encntr_id > 0.0
     AND ea_mrn.encntr_id != null)
     reply->alias = mrn
    ENDIF
    reply->abo_cd = pa.abo_cd, reply->rh_cd = pa.rh_cd, reply->expected_usage_dt_tm = cnvtdatetime(ad
     .expected_usage_dt_tm),
    reply->associated_dt_tm = cnvtdatetime(ad.associated_dt_tm)
   ELSE
    producteventcnt += 1
    IF (producteventcnt > size(reply->producteventlist,5))
     stat = alterlist(reply->producteventlist,(producteventcnt+ 4))
    ENDIF
    reply->producteventlist[producteventcnt].product_event_id = ad.product_event_id, reply->
    producteventlist[producteventcnt].donated_by_relative_ind = ad.donated_by_relative_ind, reply->
    producteventlist[producteventcnt].name_full_formatted = per.name_full_formatted,
    reply->producteventlist[producteventcnt].person_id = per.person_id, reply->producteventlist[
    producteventcnt].birth_dt_tm = per.birth_dt_tm, reply->producteventlist[producteventcnt].birth_tz
     = per.birth_tz,
    reply->producteventlist[producteventcnt].age = age, reply->producteventlist[producteventcnt].
    gender_cd = gender, reply->producteventlist[producteventcnt].encounter_id = ad.encntr_id
    IF (ea_mrn.encntr_id > 0.0
     AND ea_mrn.encntr_id != null)
     reply->producteventlist[producteventcnt].mrn = mrn
    ENDIF
    IF (ea_fin.encntr_id > 0.0
     AND ea_fin.encntr_id != null)
     reply->producteventlist[producteventcnt].fin = fin
    ENDIF
    reply->producteventlist[producteventcnt].ssn = ssn, reply->producteventlist[producteventcnt].
    abo_cd = pa.abo_cd, reply->producteventlist[producteventcnt].rh_cd = pa.rh_cd,
    reply->producteventlist[producteventcnt].expected_usage_dt_tm = cnvtdatetime(ad
     .expected_usage_dt_tm), reply->producteventlist[producteventcnt].associated_dt_tm = cnvtdatetime
    (ad.associated_dt_tm)
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->producteventlist,producteventcnt)
 IF (curqual=0)
#fail_script
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
