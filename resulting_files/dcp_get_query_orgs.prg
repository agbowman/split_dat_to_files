CREATE PROGRAM dcp_get_query_orgs
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
    1 qual[*]
      2 display = c100
      2 id = f8
  )
 ENDIF
 FREE RECORD logical_domains
 RECORD logical_domains(
   1 qual[*]
     2 logical_domain_id = f8
 )
 DECLARE getlogicaldomain(null) = null
 DECLARE ldcnt = i4 WITH protect, noconstant(0)
 DECLARE logical_domain_id = f8 WITH protect, noconstant(0.0)
 DECLARE logical_domain_grp_id = f8 WITH protect, noconstant(0.0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE num_ids = i4 WITH protect, noconstant(0)
 DECLARE org_cd = f8 WITH protect, noconstant(0.0)
 DECLARE auth_cd = f8 WITH protect, noconstant(0.0)
 DECLARE facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE facility_loc_cd = f8 WITH protect, noconstant(0.0)
 SET num_ids = size(request->qual,5)
 SET org_cd = uar_get_code_by("MEANING",396,"ORG")
 SET auth_cd = uar_get_code_by("MEANING",8,"AUTH")
 SET facility_cd = uar_get_code_by("MEANING",278,"FACILITY")
 SET facility_loc_cd = uar_get_code_by("MEANING",222,"FACILITY")
 SELECT INTO "nl:"
  l.logical_domain_id
  FROM logical_domain l,
   prsnl p
  WHERE (p.person_id=request->person_id)
   AND p.logical_domain_id=l.logical_domain_id
   AND l.active_ind=1
   AND l.logical_domain_id != 0.0
  DETAIL
   logical_domain_id = p.logical_domain_id
  WITH nocounter
 ;end select
 IF (num_ids > 0)
  SELECT
   *
   FROM organization o,
    (dummyt d  WITH seq = value(num_ids))
   PLAN (d)
    JOIN (o
    WHERE (o.organization_id=request->qual[d.seq].id))
   ORDER BY o.org_name_key
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->qual,(cnt+ 9))
    ENDIF
    reply->qual[cnt].display = o.org_name, reply->qual[cnt].id = o.organization_id
   FOOT REPORT
    stat = alterlist(reply->qual,cnt)
   WITH nocounter
  ;end select
 ELSEIF (logical_domain_id > 0.0)
  CALL getlogicaldomain(null)
  SELECT INTO "nl:"
   o.organization_id
   FROM organization o,
    location l,
    org_type_reltn otr
   PLAN (o
    WHERE o.org_class_cd=org_cd
     AND o.data_status_cd=auth_cd
     AND trim(o.org_name) > " "
     AND o.active_ind=1
     AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND expand(idx,1,ldcnt,o.logical_domain_id,logical_domains->qual[idx].logical_domain_id))
    JOIN (otr
    WHERE otr.organization_id=o.organization_id
     AND otr.org_type_cd=facility_cd
     AND otr.active_ind=1
     AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND otr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (l
    WHERE l.organization_id=o.organization_id
     AND l.location_type_cd=facility_loc_cd
     AND l.patcare_node_ind=1
     AND l.active_ind=1
     AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY o.org_name_key
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->qual,(cnt+ 9))
    ENDIF
    reply->qual[cnt].display = o.org_name, reply->qual[cnt].id = o.organization_id
   FOOT REPORT
    stat = alterlist(reply->qual,cnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   o.organization_id
   FROM organization o
   PLAN (o
    WHERE o.org_class_cd=org_cd
     AND o.data_status_cd=auth_cd
     AND trim(o.org_name) > " "
     AND o.active_ind=1
     AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND  EXISTS (
    (SELECT
     otr.organization_id
     FROM org_type_reltn otr
     WHERE otr.organization_id=o.organization_id
      AND otr.org_type_cd=facility_cd
      AND otr.active_ind=1
      AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND otr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)))
     AND  EXISTS (
    (SELECT
     l.organization_id
     FROM location l
     WHERE l.organization_id=o.organization_id
      AND l.location_type_cd=facility_loc_cd
      AND l.patcare_node_ind=1
      AND l.active_ind=1
      AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))))
   ORDER BY o.org_name_key
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->qual,(cnt+ 9))
    ENDIF
    reply->qual[cnt].display = o.org_name, reply->qual[cnt].id = o.organization_id
   FOOT REPORT
    stat = alterlist(reply->qual,cnt)
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE getlogicaldomain(null)
  SELECT INTO "nl:"
   p.logical_domain_id, p.logical_domain_grp_id
   FROM prsnl p
   WHERE (p.person_id=request->person_id)
   DETAIL
    logical_domain_id = p.logical_domain_id, logical_domain_grp_id = p.logical_domain_grp_id
   WITH nocounter
  ;end select
  IF (logical_domain_grp_id > 0)
   SELECT INTO "nl:"
    FROM logical_domain_grp_reltn ldgr
    WHERE ldgr.logical_domain_grp_id=logical_domain_grp_id
    HEAD REPORT
     stat = alterlist(logical_domains->qual,10)
    DETAIL
     ldcnt = (ldcnt+ 1)
     IF (mod(ldcnt,10)=1)
      stat = alterlist(logical_domains->qual,(ldcnt+ 9))
     ENDIF
     logical_domains->qual[ldcnt].logical_domain_id = ldgr.logical_domain_id
    FOOT REPORT
     stat = alterlist(logical_domains->qual,ldcnt)
    WITH nocounter
   ;end select
  ELSEIF (logical_domain_id > 0)
   SET ldcnt = (ldcnt+ 1)
   SET stat = alterlist(logical_domains->qual,1)
   SET logical_domains->qual[1].logical_domain_id = logical_domain_id
  ENDIF
 END ;Subroutine
 IF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
