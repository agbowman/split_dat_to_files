CREATE PROGRAM aps_get_cyto_user_info:dba
 RECORD reply(
   1 tech_qual[*]
     2 username = c50
     2 prsnl_id = f8
     2 role_cdf = c12
     2 limits[1]
       3 sequence = i4
       3 reviewed_dttm = dq8
       3 slide_limit = i4
       3 screening_hours = i4
       3 updt_cnt = i4
       3 comments = vc
       3 requeue_flag = i2
     2 security[1]
       3 sequence = i4
       3 reviewed_dttm = dq8
       3 verify_level = i4
       3 norm_percentage = i4
       3 norm_rq_flag = i2
       3 norm_srvc_rsrce_cd = f8
       3 norm_rq_rank = i2
       3 abnorm_percentage = i4
       3 abnorm_rq_flag = i2
       3 abnorm_srvc_rsrce_cd = f8
       3 abnorm_rq_rank = i2
       3 atyp_percentage = i4
       3 atyp_rq_flag = i2
       3 atyp_srvc_rsrce_cd = f8
       3 atyp_rq_rank = i2
       3 chr_percentage = i4
       3 chr_rq_flag = i2
       3 chr_srvc_rsrce_cd = f8
       3 chr_rq_rank = i2
       3 unsat_percentage = i4
       3 unsat_rq_flag = i2
       3 unsat_srvc_rsrce_cd = f8
       3 updt_cnt = i4
       3 comments = vc
     2 proficiency_qual[*]
       3 proficiency_type_cd = f8
       3 proficiency_type_disp = c40
       3 sequence = i4
       3 result_flag = i2
       3 reviewed_dt_tm = dq8
       3 administered_dt_tm = dq8
       3 notification_dt_tm = dq8
       3 updt_cnt = i4
       3 comments = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 DECLARE i = i4
 SELECT INTO "nl:"
  c.code_value, p.name_full_formatted, pgr.prsnl_group_reltn_id,
  csl.sequence, css.updt_cnt
  FROM code_value c,
   prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p,
   dummyt d,
   cyto_screening_limits csl,
   cyto_screening_security css,
   cyto_screening_limits csl1
  PLAN (c
   WHERE 357=c.code_set
    AND c.cdf_meaning IN ("CYTOTECH", "PATHOLOGIST", "PATHRESIDENT"))
   JOIN (pg
   WHERE c.code_value=pg.prsnl_group_type_cd
    AND pg.active_ind=1
    AND pg.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pgr
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id
    AND pgr.active_ind=1)
   JOIN (p
   WHERE pgr.person_id=p.person_id)
   JOIN (d)
   JOIN (((csl
   WHERE p.person_id=csl.prsnl_id
    AND 1=csl.active_ind
    AND c.cdf_meaning="CYTOTECH")
   JOIN (css
   WHERE csl.prsnl_id=css.prsnl_id
    AND 1=css.active_ind)
   ) ORJOIN ((csl1
   WHERE p.person_id=csl1.prsnl_id
    AND 1=csl1.active_ind
    AND (request->checkpathslidelmt=1)
    AND ((c.cdf_meaning="PATHOLOGIST") OR (c.cdf_meaning="PATHRESIDENT")) )
   ))
  HEAD REPORT
   cnt = 0
  DETAIL
   flag = 0, x = 0, x = locateval(i,1,cnt,p.person_id,reply->tech_qual[i].prsnl_id)
   IF (x=0)
    cnt = (cnt+ 1), x = cnt
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->tech_qual,(cnt+ 9))
    ENDIF
    reply->tech_qual[x].username = p.name_full_formatted, reply->tech_qual[x].prsnl_id = p.person_id,
    flag = 1
   ELSE
    IF (c.cdf_meaning="CYTOTECH")
     flag = 1
    ENDIF
   ENDIF
   IF (flag=1)
    reply->tech_qual[x].role_cdf = c.cdf_meaning
    IF (c.cdf_meaning="CYTOTECH")
     reply->tech_qual[x].limits[1].sequence = csl.sequence, reply->tech_qual[x].limits[1].
     reviewed_dttm = csl.reviewed_dt_tm, reply->tech_qual[x].limits[1].slide_limit = csl.slide_limit,
     reply->tech_qual[x].limits[1].screening_hours = csl.screening_hours, reply->tech_qual[x].limits[
     1].updt_cnt = csl.updt_cnt, reply->tech_qual[x].limits[1].comments = csl.comments,
     reply->tech_qual[x].limits[1].requeue_flag = csl.requeue_flag, reply->tech_qual[x].security[1].
     sequence = css.sequence, reply->tech_qual[x].security[1].reviewed_dttm = css.reviewed_dt_tm,
     reply->tech_qual[x].security[1].verify_level = css.verify_level, reply->tech_qual[x].security[1]
     .norm_percentage = css.normal_percentage, reply->tech_qual[x].security[1].norm_rq_flag = css
     .normal_requeue_flag,
     reply->tech_qual[x].security[1].norm_srvc_rsrce_cd = css.normal_service_resource_cd, reply->
     tech_qual[x].security[1].norm_rq_rank = css.normal_requeue_rank, reply->tech_qual[x].security[1]
     .abnorm_percentage = css.abnormal_percentage,
     reply->tech_qual[x].security[1].abnorm_rq_flag = css.abnormal_requeue_flag, reply->tech_qual[x].
     security[1].abnorm_srvc_rsrce_cd = css.abnormal_service_resource_cd, reply->tech_qual[x].
     security[1].abnorm_rq_rank = css.abnormal_requeue_rank,
     reply->tech_qual[x].security[1].atyp_percentage = css.atypical_percentage, reply->tech_qual[x].
     security[1].atyp_rq_flag = css.atypical_requeue_flag, reply->tech_qual[x].security[1].
     atyp_srvc_rsrce_cd = css.atypical_service_resource_cd,
     reply->tech_qual[x].security[1].atyp_rq_rank = css.atypical_requeue_rank, reply->tech_qual[x].
     security[1].chr_percentage = css.chr_percentage, reply->tech_qual[x].security[1].chr_rq_flag =
     css.chr_requeue_flag,
     reply->tech_qual[x].security[1].chr_srvc_rsrce_cd = css.chr_service_resource_cd, reply->
     tech_qual[x].security[1].chr_rq_rank = css.chr_requeue_rank, reply->tech_qual[x].security[1].
     unsat_percentage = css.unsat_percentage,
     reply->tech_qual[x].security[1].unsat_rq_flag = css.unsat_requeue_flag, reply->tech_qual[x].
     security[1].unsat_srvc_rsrce_cd = css.unsat_service_resource_cd, reply->tech_qual[x].security[1]
     .updt_cnt = css.updt_cnt,
     reply->tech_qual[x].security[1].comments = css.comments
    ELSE
     reply->tech_qual[x].limits[1].sequence = csl1.sequence, reply->tech_qual[x].limits[1].
     reviewed_dttm = csl1.reviewed_dt_tm, reply->tech_qual[x].limits[1].slide_limit = csl1
     .slide_limit,
     reply->tech_qual[x].limits[1].screening_hours = csl1.screening_hours, reply->tech_qual[x].
     limits[1].updt_cnt = csl1.updt_cnt, reply->tech_qual[x].limits[1].comments = csl1.comments,
     reply->tech_qual[x].limits[1].requeue_flag = csl1.requeue_flag
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->tech_qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET nbr_techs = cnvtint(size(reply->tech_qual,5))
 IF (nbr_techs > 0)
  SELECT INTO "nl:"
   pe.prsnl_id, d.seq
   FROM (dummyt d  WITH seq = value(nbr_techs)),
    proficiency_event pe
   PLAN (d)
    JOIN (pe
    WHERE (reply->tech_qual[d.seq].prsnl_id=pe.prsnl_id)
     AND 1=pe.active_ind)
   ORDER BY d.seq
   HEAD REPORT
    y = 0
   HEAD d.seq
    y = 0
   DETAIL
    y = (y+ 1)
    IF (y > 0)
     stat = alterlist(reply->tech_qual[d.seq].proficiency_qual,y)
    ENDIF
    reply->tech_qual[d.seq].proficiency_qual[y].proficiency_type_cd = pe.proficiency_type_cd, reply->
    tech_qual[d.seq].proficiency_qual[y].sequence = pe.sequence, reply->tech_qual[d.seq].
    proficiency_qual[y].result_flag = pe.result_flag,
    reply->tech_qual[d.seq].proficiency_qual[y].reviewed_dt_tm = pe.reviewed_dt_tm, reply->tech_qual[
    d.seq].proficiency_qual[y].administered_dt_tm = pe.administered_dt_tm, reply->tech_qual[d.seq].
    proficiency_qual[y].notification_dt_tm = pe.notification_dt_tm,
    reply->tech_qual[d.seq].proficiency_qual[y].updt_cnt = pe.updt_cnt, reply->tech_qual[d.seq].
    proficiency_qual[y].comments = pe.comments
   WITH nocounter
  ;end select
 ENDIF
END GO
