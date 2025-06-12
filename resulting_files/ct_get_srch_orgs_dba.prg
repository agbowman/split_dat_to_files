CREATE PROGRAM ct_get_srch_orgs:dba
 RECORD reply(
   1 qual[*]
     2 org_name = c100
     2 organization_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD user_org_reply(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 SET search_name = concat(trim(cnvtupper(cnvtalphanum(request->org_name))),"*")
 SET search_alias = concat(trim(cnvtupper(cnvtalphanum(request->org_alias))),"*")
 DECLARE user_org_count = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE index = i2 WITH protect, noconstant(0)
 DECLARE cur_user_org_cnt = i2 WITH noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(1)
 DECLARE batch_size = i2 WITH protect, noconstant(20)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE new_user_org_cnt = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE bstat = i2 WITH protect, noconstant(0)
 RECORD org_sec_reply(
   1 orgsecurityflag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
 CALL echo(build("org_sec_reply->OrgSecurityFlag: ",org_sec_reply->orgsecurityflag))
 IF ((org_sec_reply->orgsecurityflag=1))
  EXECUTE ct_get_user_orgs  WITH replace("REPLY","USER_ORG_REPLY")
  CALL echorecord(user_org_reply)
  SET cur_user_org_cnt = size(user_org_reply->organizations,5)
  IF (cur_user_org_cnt > 0)
   SET user_org_count = 0
   SET loop_cnt = ceil((cnvtreal(cur_user_org_cnt)/ batch_size))
   SET new_user_org_cnt = (batch_size * loop_cnt)
   SET stat = alterlist(user_org_reply->organizations,new_user_org_cnt)
   FOR (i = (cur_user_org_cnt+ 1) TO new_user_org_cnt)
     SET user_org_reply->organizations[i].organization_id = user_org_reply->organizations[
     cur_user_org_cnt].organization_id
   ENDFOR
   IF ((request->search_ind=0))
    SET cnt = 0
    IF ((request->org_type_cd > 0))
     SELECT INTO "nl:"
      o.organization_id, o.org_name
      FROM organization o,
       org_type_reltn t,
       (dummyt d  WITH seq = value(loop_cnt))
      PLAN (d
       WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
       JOIN (t
       WHERE expand(idx,nstart,((nstart+ batch_size) - 1),t.organization_id,user_org_reply->
        organizations[idx].organization_id)
        AND t.active_ind=1
        AND (t.org_type_cd=request->org_type_cd)
        AND t.org_type_cd > 0
        AND t.organization_id > 0.0
        AND t.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND t.end_effective_dt_tm >= cnvtdatetime(sysdate))
       JOIN (o
       WHERE o.organization_id=t.organization_id
        AND o.active_ind=1
        AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND o.org_name_key=patstring(search_name))
      ORDER BY o.org_name_key
      DETAIL
       cnt += 1, stat = alterlist(reply->qual,cnt), reply->qual[cnt].organization_id = o
       .organization_id,
       reply->qual[cnt].org_name = o.org_name
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      o.organization_id, o.org_name
      FROM organization o,
       (dummyt d  WITH seq = value(loop_cnt))
      PLAN (d
       WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
       JOIN (o
       WHERE expand(idx,nstart,((nstart+ batch_size) - 1),o.organization_id,user_org_reply->
        organizations[idx].organization_id)
        AND o.active_ind=1
        AND o.organization_id > 0.0
        AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND o.org_name_key=patstring(search_name))
      ORDER BY o.org_name_key
      DETAIL
       cnt += 1, stat = alterlist(reply->qual,cnt), reply->qual[cnt].organization_id = o
       .organization_id,
       reply->qual[cnt].org_name = o.org_name
      WITH nocounter
     ;end select
    ENDIF
   ELSEIF ((request->search_ind=1))
    SET cnt = 0
    IF ((request->org_type_cd > 0))
     SELECT DISTINCT INTO "nl:"
      o.organization_id, o.org_name
      FROM organization_alias a,
       org_type_reltn t,
       organization o,
       (dummyt d  WITH seq = value(loop_cnt))
      PLAN (d
       WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
       JOIN (a
       WHERE expand(idx,nstart,((nstart+ batch_size) - 1),a.organization_id,user_org_reply->
        organizations[idx].organization_id)
        AND a.alias=patstring(search_alias)
        AND a.active_ind=1
        AND a.organization_id > 0.0
        AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND a.end_effective_dt_tm >= cnvtdatetime(sysdate))
       JOIN (t
       WHERE a.organization_id=t.organization_id
        AND t.active_ind=1
        AND t.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND t.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (t.org_type_cd=request->org_type_cd)
        AND t.org_type_cd > 0)
       JOIN (o
       WHERE t.organization_id=o.organization_id
        AND o.active_ind=1
        AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND o.end_effective_dt_tm >= cnvtdatetime(sysdate))
      ORDER BY o.org_name_key
      DETAIL
       cnt += 1, stat = alterlist(reply->qual,cnt), reply->qual[cnt].organization_id = o
       .organization_id,
       reply->qual[cnt].org_name = o.org_name
      WITH nocounter
     ;end select
    ELSE
     SELECT DISTINCT INTO "nl:"
      o.organization_id, o.org_name
      FROM organization_alias a,
       organization o,
       (dummyt d  WITH seq = value(loop_cnt))
      PLAN (d
       WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
       JOIN (a
       WHERE expand(idx,nstart,((nstart+ batch_size) - 1),a.organization_id,user_org_reply->
        organizations[idx].organization_id)
        AND a.alias=patstring(search_alias)
        AND a.active_ind=1
        AND a.organization_id > 0.0
        AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND a.end_effective_dt_tm >= cnvtdatetime(sysdate))
       JOIN (o
       WHERE a.organization_id=o.organization_id
        AND o.active_ind=1
        AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND o.end_effective_dt_tm >= cnvtdatetime(sysdate))
      ORDER BY o.org_name_key
      DETAIL
       cnt += 1, stat = alterlist(reply->qual,cnt), reply->qual[cnt].organization_id = o
       .organization_id,
       reply->qual[cnt].org_name = o.org_name
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   SET stat = alterlist(user_org_reply->organizations,cur_user_org_cnt)
   SET cnt = size(reply->qual,5)
  ENDIF
 ELSE
  IF ((request->search_ind=0))
   SET cnt = 0
   IF ((request->org_type_cd > 0))
    SELECT INTO "nl:"
     o.organization_id, o.org_name
     FROM organization o,
      org_type_reltn t
     PLAN (t
      WHERE t.active_ind=1
       AND (t.org_type_cd=request->org_type_cd)
       AND t.org_type_cd > 0
       AND t.organization_id > 0.0
       AND t.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND t.end_effective_dt_tm >= cnvtdatetime(sysdate))
      JOIN (o
      WHERE t.organization_id=o.organization_id
       AND o.active_ind=1
       AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND o.org_name_key=patstring(search_name)
       AND (o.logical_domain_id=domain_reply->logical_domain_id))
     ORDER BY o.org_name_key
     DETAIL
      cnt += 1, stat = alterlist(reply->qual,cnt), reply->qual[cnt].organization_id = o
      .organization_id,
      reply->qual[cnt].org_name = o.org_name
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     o.organization_id, o.org_name
     FROM organization o
     WHERE o.active_ind=1
      AND o.organization_id > 0.0
      AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND o.org_name_key=patstring(search_name)
      AND (o.logical_domain_id=domain_reply->logical_domain_id)
     ORDER BY o.org_name_key
     DETAIL
      cnt += 1, stat = alterlist(reply->qual,cnt), reply->qual[cnt].organization_id = o
      .organization_id,
      reply->qual[cnt].org_name = o.org_name
     WITH nocounter
    ;end select
   ENDIF
  ELSEIF ((request->search_ind=1))
   SET cnt = 0
   IF ((request->org_type_cd > 0))
    SELECT DISTINCT INTO "nl:"
     o.organization_id, o.org_name
     FROM organization_alias a,
      org_type_reltn t,
      organization o
     PLAN (a
      WHERE a.alias=patstring(search_alias)
       AND a.active_ind=1
       AND a.organization_id > 0.0
       AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND a.end_effective_dt_tm >= cnvtdatetime(sysdate))
      JOIN (t
      WHERE a.organization_id=t.organization_id
       AND t.active_ind=1
       AND t.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND t.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND (t.org_type_cd=request->org_type_cd)
       AND t.org_type_cd > 0)
      JOIN (o
      WHERE t.organization_id=o.organization_id
       AND o.active_ind=1
       AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND (o.logical_domain_id=domain_reply->logical_domain_id))
     ORDER BY o.org_name_key
     DETAIL
      cnt += 1, stat = alterlist(reply->qual,cnt), reply->qual[cnt].organization_id = o
      .organization_id,
      reply->qual[cnt].org_name = o.org_name
     WITH nocounter
    ;end select
   ELSE
    SELECT DISTINCT INTO "nl:"
     o.organization_id, o.org_name
     FROM organization_alias a,
      organization o
     PLAN (a
      WHERE a.alias=patstring(search_alias)
       AND a.active_ind=1
       AND a.organization_id > 0.0
       AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND a.end_effective_dt_tm >= cnvtdatetime(sysdate))
      JOIN (o
      WHERE a.organization_id=o.organization_id
       AND o.active_ind=1
       AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND o.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND (o.logical_domain_id=domain_reply->logical_domain_id))
     ORDER BY o.org_name_key
     DETAIL
      cnt += 1, stat = alterlist(reply->qual,cnt), reply->qual[cnt].organization_id = o
      .organization_id,
      reply->qual[cnt].org_name = o.org_name
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  SET cnt = size(reply->qual,5)
 ENDIF
 CALL echo(cnt)
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "002"
 SET mod_date = "February 25, 2019"
END GO
