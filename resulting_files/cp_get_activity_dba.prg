CREATE PROGRAM cp_get_activity:dba
 RECORD reply(
   1 qual[*]
     2 event_cd = f8
     2 mdoc_id = f8
     2 view_level = i4
     2 publish_flag = i2
     2 catalog_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count = 0
 SET reply->status_data.status = "F"
 SET where_clause = fillstring(900," ")
 SET person_clause = fillstring(250," ")
 SET date_clause = fillstring(500," ")
 SET other_clause = fillstring(200," ")
 SET c1 = fillstring(100," ")
 SET c2 = fillstring(120," ")
 SET c3 = fillstring(120," ")
 SET c4 = fillstring(120," ")
 SET c5 = fillstring(120," ")
 SET cep_where_clause = fillstring(800," ")
 SET cep_person_clause = fillstring(250," ")
 SET cep_date_clause = fillstring(400," ")
 SET cep_other_clause = fillstring(200," ")
 SET cep1 = fillstring(100," ")
 SET cep2 = fillstring(120," ")
 SET cep3 = fillstring(100," ")
 SET cep4 = fillstring(100," ")
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET mic_activity_cd = 0.0
 SET auth_cd = 0.0
 SET unauth_cd = 0.0
 SET mod_cd = 0.0
 SET alt_cd = 0.0
 SET super_cd = 0.0
 SET inlab_cd = 0.0
 SET inprog_cd = 0.0
 SET trans_cd = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  PLAN (c
   WHERE c.code_set=8
    AND c.cdf_meaning IN ("AUTH", "UNAUTH", "MODIFIED", "SUPERSEDED", "ALTERED",
   "TRANSCRIBED", "IN LAB", "IN PROGRESS"))
  DETAIL
   IF (c.cdf_meaning="AUTH")
    auth_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="UNAUTH")
    unauth_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="MODIFIED")
    mod_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="ALTERED")
    alt_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="SUPERSEDED")
    super_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="TRANSCRIBED")
    trans_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="IN LAB")
    inlab_cd = c.code_value
   ENDIF
   IF (c.cdf_meaning="IN PROGRESS")
    inprog_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 CASE (request->scope_flag)
  OF 2:
   SET c1 = concat("  and ce.person_id+0 = ",cnvtstring(request->person_id))
   SET c2 = concat("  ce.encntr_id = ",cnvtstring(request->encntr_id))
   SET person_clause = concat(trim(c2)," ",trim(c1))
   SET cep1 = concat("  and cep.person_id+0 = ",cnvtstring(request->person_id))
   SET cep2 = concat("  cep.encntr_id = ",cnvtstring(request->encntr_id))
   SET cep_person_clause = concat(trim(cep2)," ",trim(cep1))
  OF 3:
   SET c1 = concat("  and ce.person_id+0 = ",cnvtstring(request->person_id))
   SET c2 = concat("  and ce.encntr_id = ",cnvtstring(request->encntr_id))
   SET c3 = concat("  ce.order_id = ",cnvtstring(request->order_id))
   SET person_clause = concat(trim(c3)," ",trim(c2)," ",trim(c1))
   SET cep1 = concat("  and cep.person_id+0 = ",cnvtstring(request->person_id))
   SET cep2 = concat("  and cep.encntr_id = ",cnvtstring(request->encntr_id))
   SET cep3 = concat("  cep.order_id = ",cnvtstring(request->order_id))
   SET cep_person_clause = concat(trim(cep3)," ",trim(cep2)," ",trim(cep1))
  OF 4:
   SET c1 = concat("  and ce.person_id+0 = ",cnvtstring(request->person_id))
   SET c2 = concat("  and ce.encntr_id+0 = ",cnvtstring(request->encntr_id))
   SET c4 = concat("  ce.accession_nbr = ","request->accession_nbr")
   SET person_clause = concat(trim(c4)," ",trim(c2)," ",trim(c1))
   SET cep1 = concat("  and cep.person_id+0 = ",cnvtstring(request->person_id))
   SET cep2 = concat("  and cep.encntr_id+0 = ",cnvtstring(request->encntr_id))
   SET cep4 = concat("  cep.accession_nbr = ","request->accession_nbr")
   SET cep_person_clause = concat(trim(cep4)," ",trim(cep2)," ",trim(cep1))
 ENDCASE
 SET c1 = " "
 SET c2 = " "
 SET c3 = " "
 SET c4 = " "
 SET c5 = " "
 SET v_until_dt = cnvtdatetime("31-Dec-2100 00:00:00.00")
 IF ((request->date_range_ind=0))
  SET c1 = " and ce.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
 ELSE
  IF ((request->request_type > 1))
   SET c1 = " and ce.valid_until_dt_tm >= cnvtdatetime(request->end_dt_tm)"
  ELSE
   SET c1 = " and ce.valid_until_dt_tm > cnvtdatetime(request->end_dt_tm)"
   SET c5 = " and ce.valid_from_dt_tm < cnvtdatetime(request->end_dt_tm)"
  ENDIF
 ENDIF
 IF ((request->date_range_ind=1))
  IF ((request->begin_dt_tm > 0))
   SET s_date = cnvtdatetime(request->begin_dt_tm)
  ELSE
   SET s_date = cnvtdatetime("01-jan-1800 00:00:00.00")
  ENDIF
  IF ((request->end_dt_tm > 0))
   SET e_date = cnvtdatetime(request->end_dt_tm)
  ELSE
   SET e_date = cnvtdatetime("31-dec-2100 23:59:59.99")
  ENDIF
  SET c2 = " and (ce.verified_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date)"
  IF ((((request->pending_flag=1)) OR ((request->pending_flag=2))) )
   SET c3 = " or ce.performed_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date)"
  ENDIF
  IF ((request->pending_flag=2))
   SET c4 = " or ce.event_end_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
  ELSE
   SET c3 = concat(trim(c3),")")
  ENDIF
 ENDIF
 SET date_clause = concat(trim(c1)," ",trim(c5)," ",trim(c2),
  " ",trim(c3)," ",trim(c4))
 SET c1 = " and ce.view_level >= 0"
 SET cep1 = " and cep.view_level >= 0"
 IF ((request->pending_flag=0))
  SET c2 = " and ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd)"
  SET cep2 = " and cep.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd)"
 ELSE
  IF ((request->pending_flag=1))
   SET c2 = " and ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)"
   SET cep2 = " and cep.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)"
  ELSE
   SET c2 =
   " and ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd, trans_cd, unauth_cd)"
   SET cep2 =
   " and cep.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd, trans_cd, unauth_cd)"
  ENDIF
 ENDIF
 SET other_clause = concat(trim(c1)," ",trim(c2))
 SET cep_other_clause = concat(trim(cep1)," ",trim(cep2))
 SET where_clause = concat(trim(person_clause)," ",trim(date_clause)," ",trim(other_clause))
 SET cep_where_clause = concat(trim(cep_person_clause)," ",trim(cep_other_clause))
 CALL echo(trim(where_clause))
 CALL echo(trim(cep_where_clause))
 IF ((request->radiology_ind=1))
  SELECT DISTINCT INTO "nl:"
   ce.event_cd, ce.catalog_cd, ce.view_level
   FROM clinical_event ce,
    (dummyt d  WITH seq = 1),
    ce_linked_result lr,
    ce_linked_result lr2
   PLAN (ce
    WHERE parser(where_clause))
    JOIN (d
    WHERE d.seq=1)
    JOIN (lr
    WHERE lr.event_id=ce.event_id)
    JOIN (lr2
    WHERE lr2.linked_event_id=lr.linked_event_id)
   ORDER BY ce.event_cd, ce.catalog_cd, ce.view_level
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1)
    IF (mod(count,10)=1)
     stat = alterlist(reply->qual,(count+ 9))
    ENDIF
    reply->qual[count].event_cd = ce.event_cd, reply->qual[count].mdoc_id = lr2.linked_event_id,
    reply->qual[count].view_level = ce.view_level,
    reply->qual[count].publish_flag = ce.publish_flag, reply->qual[count].catalog_cd = ce.catalog_cd
   FOOT REPORT
    stat = alterlist(reply->qual,count)
   WITH orahint("INDEX (LR XPKCE_LINKED_RESULT)"), nocounter, outerjoin = d
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   ce.event_cd, ce.catalog_cd, ce.view_level
   FROM clinical_event ce
   PLAN (ce
    WHERE parser(where_clause))
   ORDER BY ce.event_cd, ce.catalog_cd, ce.view_level
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1)
    IF (mod(count,10)=1)
     stat = alterlist(reply->qual,(count+ 9))
    ENDIF
    reply->qual[count].event_cd = ce.event_cd, reply->qual[count].view_level = ce.view_level, reply->
    qual[count].publish_flag = ce.publish_flag,
    reply->qual[count].catalog_cd = ce.catalog_cd
   FOOT REPORT
    stat = alterlist(reply->qual,count)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->date_range_ind=1))
  SET code_set = 106
  SET cdf_meaning = "MICROBIOLOGY"
  EXECUTE cpm_get_cd_for_cdf
  SET mic_activity_cd = code_value
  SET where_clause = concat("cep.event_id = ce.parent_event_id and ",trim(where_clause))
  SELECT DISTINCT INTO "nl:"
   cep.event_cd, cep.catalog_cd, cep.view_level
   FROM clinical_event cep,
    order_catalog oc,
    clinical_event ce
   PLAN (cep
    WHERE parser(cep_where_clause))
    JOIN (oc
    WHERE oc.catalog_cd=cep.catalog_cd
     AND oc.activity_type_cd=mic_activity_cd)
    JOIN (ce
    WHERE parser(where_clause))
   ORDER BY cep.event_cd, cep.catalog_cd, cep.view_level
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].event_cd = cep
    .event_cd,
    reply->qual[count].view_level = cep.view_level, reply->qual[count].publish_flag = cep
    .publish_flag, reply->qual[count].catalog_cd = cep.catalog_cd
   WITH nocounter
  ;end select
 ENDIF
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(build("curqual =",count))
 ENDIF
END GO
