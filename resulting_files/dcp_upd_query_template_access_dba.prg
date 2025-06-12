CREATE PROGRAM dcp_upd_query_template_access:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD patient_list(
   1 qual[*]
     2 patient_list_id = f8
     2 keep_flag = i2
     2 owner_id = f8
 )
 SET modify = predeclare
 DECLARE positioncnt = i4 WITH noconstant(size(request->positions,5))
 DECLARE provgrpcnt = i4 WITH noconstant(size(request->provider_groups,5))
 DECLARE provcnt = i4 WITH noconstant(size(request->providers,5))
 DECLARE tempaccess_seq = f8 WITH noconstant(0.0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE pl_cnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 DELETE  FROM dcp_pl_query_temp_access dpqta
  WHERE (dpqta.template_id=request->template_id)
  WITH nocounter
 ;end delete
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_pl_query_list ql,
   dcp_patient_list dpl
  PLAN (ql
   WHERE (ql.template_id=request->template_id))
   JOIN (dpl
   WHERE dpl.patient_list_id=ql.patient_list_id)
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   IF (mod(pl_cnt,10)=0)
    stat = alterlist(patient_list->qual,(pl_cnt+ 10))
   ENDIF
   pl_cnt = (pl_cnt+ 1), patient_list->qual[pl_cnt].patient_list_id = ql.patient_list_id,
   patient_list->qual[pl_cnt].keep_flag = 0,
   patient_list->qual[pl_cnt].owner_id = dpl.owner_prsnl_id
  FOOT REPORT
   stat = alterlist(patient_list->qual,pl_cnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO positioncnt)
   SELECT INTO "nl:"
    num = seq(dcp_patient_list_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     tempaccess_seq = cnvtreal(num)
    WITH format, counter
   ;end select
   INSERT  FROM dcp_pl_query_temp_access dpqta
    SET dpqta.position_cd = request->positions[x].position_cd, dpqta.template_access_id =
     tempaccess_seq, dpqta.template_id = request->template_id,
     dpqta.updt_cnt = 0, dpqta.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpqta.updt_id = reqinfo->
     updt_id,
     dpqta.updt_applctx = reqinfo->updt_applctx, dpqta.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
 ENDFOR
 IF (positioncnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = pl_cnt),
    prsnl p
   PLAN (d
    WHERE (patient_list->qual[d.seq].keep_flag=0))
    JOIN (p
    WHERE (p.person_id=patient_list->qual[d.seq].owner_id)
     AND expand(x,1,positioncnt,p.position_cd,request->positions[x].position_cd))
   DETAIL
    patient_list->qual[d.seq].keep_flag = 1
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO provgrpcnt)
   SELECT INTO "nl:"
    num = seq(dcp_patient_list_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     tempaccess_seq = cnvtreal(num)
    WITH format, counter
   ;end select
   INSERT  FROM dcp_pl_query_temp_access dpqta
    SET dpqta.provider_group_id = request->provider_groups[x].provider_group_id, dpqta
     .template_access_id = tempaccess_seq, dpqta.template_id = request->template_id,
     dpqta.updt_cnt = 0, dpqta.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpqta.updt_id = reqinfo->
     updt_id,
     dpqta.updt_applctx = reqinfo->updt_applctx, dpqta.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
 ENDFOR
 IF (provcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = pl_cnt),
    prsnl_group_reltn pgr
   PLAN (d
    WHERE (patient_list->qual[d.seq].keep_flag=0))
    JOIN (pgr
    WHERE (pgr.person_id=patient_list->qual[d.seq].owner_id)
     AND expand(x,1,provcnt,pgr.prsnl_group_id,request->provider_groups[x].provider_group_id))
   DETAIL
    patient_list->qual[d.seq].keep_flag = 1
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO provcnt)
   SELECT INTO "nl:"
    num = seq(dcp_patient_list_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     tempaccess_seq = cnvtreal(num)
    WITH format, counter
   ;end select
   INSERT  FROM dcp_pl_query_temp_access dpqta
    SET dpqta.provider_id = request->providers[x].provider_id, dpqta.template_access_id =
     tempaccess_seq, dpqta.template_id = request->template_id,
     dpqta.updt_cnt = 0, dpqta.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpqta.updt_id = reqinfo->
     updt_id,
     dpqta.updt_applctx = reqinfo->updt_applctx, dpqta.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = pl_cnt)
    PLAN (d
     WHERE (patient_list->qual[d.seq].keep_flag=0))
    DETAIL
     IF ((patient_list->qual[d.seq].owner_id=request->providers[x].provider_id))
      patient_list->qual[d.seq].keep_flag = 1
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 FOR (i = 1 TO size(patient_list->qual,5))
   IF ((patient_list->qual[i].keep_flag=0))
    IF ((patient_list->qual[i].patient_list_id > 0))
     EXECUTE dcp_del_patient_list value(patient_list->qual[i].patient_list_id)
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
