CREATE PROGRAM aps_get_consulting_physicians:dba
 RECORD reply(
   1 phys_qual[*]
     2 physician_id = f8
     2 physician_name = vc
     2 reltn_qual[*]
       3 prsnl_reltn_activity_id = f8
       3 prsnl_reltn_id = f8
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nprsnlcnt = i4 WITH protect, noconstant(0)
 DECLARE dconsultphystypeid = f8 WITH protect, noconstant(0.0)
 DECLARE nmaxreltncnt = i4 WITH protect, noconstant(0)
 DECLARE nprsnlreltncheckprg = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET max_phys_cnt = 5
 SET phys_cnt = 0
 SET stat = uar_get_meaning_by_codeset(333,"CONSULTDOC",1,dconsultphystypeid)
 IF (checkprg("PPR_GET_PRSNL_RELTN_ACT") > 0)
  SET nprsnlreltncheckprg = 1
 ENDIF
 SELECT INTO "nl:"
  cp.physician_id, pr.name_full_formatted
  FROM case_provider cp,
   prsnl pr
  PLAN (cp
   WHERE (request->case_id=cp.case_id))
   JOIN (pr
   WHERE cp.physician_id=pr.person_id)
  HEAD REPORT
   stat = alterlist(reply->phys_qual,max_phys_cnt)
  DETAIL
   phys_cnt = (phys_cnt+ 1)
   IF (phys_cnt > max_phys_cnt)
    stat = alterlist(reply->phys_qual,phys_cnt), max_phys_cnt = phys_cnt
   ENDIF
   reply->phys_qual[phys_cnt].physician_id = cp.physician_id, reply->phys_qual[phys_cnt].
   physician_name = trim(pr.name_full_formatted)
  FOOT REPORT
   stat = alterlist(reply->phys_qual,phys_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_PROVIDER"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->status_data.status="S")
  AND nprsnlreltncheckprg=1)
  IF ( NOT (validate(req4299300,0)))
   RECORD req4299300(
     1 qual[*]
       2 prsnl_id = f8
       2 parent_entity_id = f8
       2 parent_entity_name = c30
       2 entity_type_id = f8
       2 entity_type_name = c30
       2 person_id = f8
       2 encntr_id = f8
       2 order_id = f8
       2 accession_nbr = c20
   )
  ENDIF
  IF ( NOT (validate(rep4299300,0)))
   RECORD rep4299300(
     1 qual[*]
       2 prsnl_reltn[*]
         3 prsnl_reltn_activity_id = f8
         3 prsnl_id = f8
         3 parent_entity_id = f8
         3 parent_entity_name = c30
         3 entity_type_id = f8
         3 entity_type_name = c30
         3 prsnl_reltn_id = f8
         3 person_id = f8
         3 encntr_id = f8
         3 accession_nbr = c20
         3 order_id = f8
         3 usage_nbr = i4
         3 updt_cnt = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  SELECT INTO "nl:"
   d1.*
   FROM (dummyt d1  WITH seq = value(phys_cnt))
   PLAN (d1)
   DETAIL
    nprsnlcnt = (nprsnlcnt+ 1)
    IF (mod(nprsnlcnt,10)=1)
     stat = alterlist(req4299300->qual,(nprsnlcnt+ 9))
    ENDIF
    req4299300->qual[nprsnlcnt].prsnl_id = reply->phys_qual[d1.seq].physician_id, req4299300->qual[
    nprsnlcnt].parent_entity_id = request->case_id, req4299300->qual[nprsnlcnt].parent_entity_name =
    "ACCESSION",
    req4299300->qual[nprsnlcnt].entity_type_name = "CODE_VALUE", req4299300->qual[nprsnlcnt].
    entity_type_id = dconsultphystypeid
   FOOT REPORT
    stat = alterlist(req4299300->qual,nprsnlcnt)
   WITH nocounter
  ;end select
  EXECUTE ppr_get_prsnl_reltn_act  WITH replace("REQUEST","REQ4299300"), replace("REPLY","REP4299300"
   )
  IF ((rep4299300->status_data.status="S"))
   SELECT INTO "nl:"
    d1.seq
    FROM (dummyt d1  WITH seq = value(size(rep4299300->qual,5)))
    PLAN (d1)
    DETAIL
     IF (size(rep4299300->qual[d1.seq].prsnl_reltn,5) > nmaxreltncnt)
      nmaxreltncnt = size(rep4299300->qual[d1.seq].prsnl_reltn,5)
     ENDIF
    WITH nocounter
   ;end select
   IF (nmaxreltncnt > 0)
    SELECT INTO "nl:"
     d1.seq
     FROM (dummyt d1  WITH seq = value(size(rep4299300->qual,5))),
      (dummyt d2  WITH seq = value(nmaxreltncnt))
     PLAN (d1)
      JOIN (d2
      WHERE d2.seq <= size(rep4299300->qual[d1.seq].prsnl_reltn,5))
     ORDER BY d1.seq
     HEAD d1.seq
      nprsnlcnt = 0
     DETAIL
      nprsnlcnt = (nprsnlcnt+ 1), stat = alterlist(reply->phys_qual[d1.seq].reltn_qual,nprsnlcnt),
      reply->phys_qual[d1.seq].reltn_qual[nprsnlcnt].prsnl_reltn_activity_id = rep4299300->qual[d1
      .seq].prsnl_reltn[d2.seq].prsnl_reltn_activity_id,
      reply->phys_qual[d1.seq].reltn_qual[nprsnlcnt].prsnl_reltn_id = rep4299300->qual[d1.seq].
      prsnl_reltn[d2.seq].prsnl_reltn_id, reply->phys_qual[d1.seq].reltn_qual[nprsnlcnt].updt_cnt =
      rep4299300->qual[d1.seq].prsnl_reltn[d2.seq].updt_cnt
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  FREE RECORD rep4299300
  FREE RECORD req4299300
 ENDIF
END GO
