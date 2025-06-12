CREATE PROGRAM aps_get_proxy_individuals:dba
 RECORD reply(
   1 max_qual = i2
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET qual_size = cnvtint(size(request->qual,5))
 SET last_name = fillstring(100," ")
 SET first_name = fillstring(100," ")
 IF (textlen(trim(request->last_name)) > 0)
  SET last_name = build('p.name_last_key = "')
  SET last_name = build(last_name,cnvtupper(cnvtalphanum(request->last_name)))
  SET last_name = build(last_name,'*"')
 ELSE
  SET last_name = build('p.name_last_key = "*"')
 ENDIF
 IF (textlen(trim(request->first_name)) > 0)
  SET first_name = build('p.name_first_key = "')
  SET first_name = build(first_name,cnvtupper(cnvtalphanum(request->first_name)))
  SET first_name = build(first_name,'*"')
 ELSE
  SET first_name = build('p.name_first_key = "*"')
 ENDIF
 CALL echo(build("last name = ",last_name))
 CALL echo(build("first name = ",first_name))
 IF (qual_size > 0)
  CALL echo("In first select")
  SELECT INTO "nl:"
   p.person_id, p.name_full_formatted, pg.prsnl_group_name,
   pgr.person_id
   FROM prsnl p,
    prsnl_group pg,
    prsnl_group_reltn pgr,
    (dummyt d  WITH seq = value(size(request->qual,5)))
   PLAN (d)
    JOIN (pg
    WHERE (pg.prsnl_group_id=request->qual[d.seq].prsnl_group_id)
     AND pg.active_ind=1
     AND pg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pgr
    WHERE pgr.prsnl_group_id=pg.prsnl_group_id
     AND pgr.active_ind=1
     AND pgr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pgr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (p
    WHERE p.person_id=pgr.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND parser(last_name)
     AND parser(first_name))
   ORDER BY p.person_id
   HEAD REPORT
    reply->max_qual = 0, ind_cnt = 0
   HEAD p.person_id
    ind_cnt = (ind_cnt+ 1)
    IF (mod(ind_cnt,10)=1)
     stat = alterlist(reply->qual,(ind_cnt+ 9))
    ENDIF
    reply->qual[ind_cnt].person_id = p.person_id, reply->qual[ind_cnt].name_full_formatted = p
    .name_full_formatted,
    CALL echo(build("name :",p.name_full_formatted)),
    CALL echo(build("count: ",ind_cnt))
   FOOT REPORT
    stat = alterlist(reply->qual,ind_cnt)
   WITH nocounter
  ;end select
 ELSEIF ((request->include_inactives_ind=1))
  SELECT INTO "nl:"
   p.person_id, p.name_full_formatted
   FROM prsnl p
   PLAN (p
    WHERE parser(last_name)
     AND parser(first_name))
   HEAD REPORT
    ind_cnt = 0, reply->max_qual = 0
   DETAIL
    ind_cnt = (ind_cnt+ 1)
    IF (mod(ind_cnt,10)=1)
     stat = alterlist(reply->qual,(ind_cnt+ 9))
    ENDIF
    reply->qual[ind_cnt].person_id = p.person_id, reply->qual[ind_cnt].name_full_formatted = p
    .name_full_formatted, reply->qual[ind_cnt].active_ind = p.active_ind,
    CALL echo(build("count: ",ind_cnt)),
    CALL echo(build("Name: ",p.name_full_formatted))
    IF (ind_cnt > 100)
     reply->max_qual = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->qual,ind_cnt)
   WITH nocounter, maxqual(p,101)
  ;end select
 ELSE
  CALL echo("In second select")
  CALL echo(build("last name = ",last_name))
  CALL echo(build("first name = ",first_name))
  SELECT INTO "nl:"
   p.person_id, p.name_full_formatted
   FROM prsnl p
   PLAN (p
    WHERE parser(last_name)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND parser(first_name))
   HEAD REPORT
    ind_cnt = 0, reply->max_qual = 0
   DETAIL
    ind_cnt = (ind_cnt+ 1)
    IF (mod(ind_cnt,10)=1)
     stat = alterlist(reply->qual,(ind_cnt+ 9))
    ENDIF
    reply->qual[ind_cnt].person_id = p.person_id, reply->qual[ind_cnt].name_full_formatted = p
    .name_full_formatted,
    CALL echo(build("count: ",ind_cnt)),
    CALL echo(build("Name: ",p.name_full_formatted))
    IF (ind_cnt > 100)
     reply->max_qual = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->qual,ind_cnt)
   WITH nocounter, maxqual(p,101)
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRSNL"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
