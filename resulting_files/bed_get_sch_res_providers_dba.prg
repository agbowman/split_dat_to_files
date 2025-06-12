CREATE PROGRAM bed_get_sch_res_providers:dba
 FREE SET reply
 RECORD reply(
   1 providers[*]
     2 person_id = f8
     2 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 RECORD temp(
   1 qual[*]
     2 id = f8
     2 name = vc
 )
 SET reply->status_data.status = "F"
 SET pcnt = 0
 SET reply->too_many_results_ind = 0
 DECLARE prsnl_string = vc
 DECLARE tmax = i4
 DECLARE tcnt = i4
 SET auth_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=8
    AND cv.cdf_meaning="AUTH")
  DETAIL
   auth_cd = cv.code_value
  WITH nocounter
 ;end select
 SET prsnl_string = "p.physician_ind = 1"
 IF ((request->name.last > " "))
  SET prsnl_string = concat(prsnl_string," and p.name_last_key = '",nullterm(cnvtalphanum(cnvtupper(
      trim(request->name.last)))),"*'")
 ENDIF
 IF ((request->name.first > " "))
  SET prsnl_string = concat(prsnl_string," and p.name_first_key = '",nullterm(cnvtalphanum(cnvtupper(
      trim(request->name.first)))),"*'")
 ENDIF
 SET prsnl_string = concat(prsnl_string," and p.active_ind = 1")
 SET data_partition_ind = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
  IF (prg_exists_ind > 0)
   SET field_found = 0
   RANGE OF p IS prsnl
   SET field_found = validate(p.logical_domain_id)
   FREE RANGE p
   IF (field_found=1)
    SET data_partition_ind = 1
    FREE SET acm_get_acc_logical_domains_req
    RECORD acm_get_acc_logical_domains_req(
      1 write_mode_ind = i2
      1 concept = i4
    )
    FREE SET acm_get_acc_logical_domains_rep
    RECORD acm_get_acc_logical_domains_rep(
      1 logical_domain_grp_id = f8
      1 logical_domains_cnt = i4
      1 logical_domains[*]
        2 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_acc_logical_domains_req->write_mode_ind = 0
    SET acm_get_acc_logical_domains_req->concept = 2
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET prsnl_string = concat(prsnl_string," and p.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET prsnl_string = build(prsnl_string,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET prsnl_string = build(prsnl_string,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET max_cnt = 0
 IF ((request->max_reply > 0))
  SET max_cnt = request->max_reply
 ELSE
  SET max_cnt = 100000
 ENDIF
 SET tmax = max_cnt
 SET cnt = 0
 SET tcnt = 0
 IF ((request->g_one_limit_ind=1))
  SELECT INTO "nl:"
   FROM prsnl p,
    sch_resource s
   PLAN (s
    WHERE s.person_id > 0
     AND s.quota > 1)
    JOIN (p
    WHERE p.person_id=s.person_id
     AND parser(prsnl_string)
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND p.data_status_cd=auth_cd)
   ORDER BY p.name_full_formatted
   HEAD p.person_id
    cnt = (cnt+ 1), tcnt = (tcnt+ 1), stat = alterlist(temp->qual,cnt),
    temp->qual[cnt].id = p.person_id, temp->qual[cnt].name = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("Cnt = ",cnt,"     tmax = ",tmax))
 SET tcnt = 0
 IF ((request->one_limit_ind=1))
  SELECT INTO "nl:"
   FROM prsnl p,
    sch_resource s
   PLAN (s
    WHERE s.person_id > 0
     AND s.quota=1)
    JOIN (p
    WHERE p.person_id=s.person_id
     AND parser(prsnl_string)
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND p.data_status_cd=auth_cd)
   ORDER BY p.name_full_formatted
   HEAD p.person_id
    cnt = (cnt+ 1), tcnt = (tcnt+ 1), stat = alterlist(temp->qual,cnt),
    temp->qual[cnt].id = p.person_id, temp->qual[cnt].name = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("Cnt = ",cnt,"     tmax = ",tmax))
 SET tcnt = 0
 IF ((request->zero_limit_ind=1))
  SELECT INTO "nl:"
   FROM prsnl p,
    sch_resource s
   PLAN (s
    WHERE s.person_id > 0
     AND s.quota=0)
    JOIN (p
    WHERE p.person_id=s.person_id
     AND parser(prsnl_string)
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND p.data_status_cd=auth_cd)
   ORDER BY p.name_full_formatted
   HEAD p.person_id
    cnt = (cnt+ 1), tcnt = (tcnt+ 1), stat = alterlist(temp->qual,cnt),
    temp->qual[cnt].id = p.person_id, temp->qual[cnt].name = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("Cnt = ",cnt,"     tmax = ",tmax))
 SET tcnt = 0
 IF ((request->blank_limit_ind=1))
  SELECT INTO "nl:"
   FROM prsnl p,
    sch_resource s,
    dummyt d
   PLAN (p
    WHERE parser(prsnl_string)
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND p.data_status_cd=auth_cd)
    JOIN (d)
    JOIN (s
    WHERE s.person_id=p.person_id)
   ORDER BY p.name_full_formatted
   HEAD p.person_id
    cnt = (cnt+ 1), tcnt = (tcnt+ 1), stat = alterlist(temp->qual,cnt),
    temp->qual[cnt].id = p.person_id, temp->qual[cnt].name = p.name_full_formatted
   WITH nocounter, outerjoin = d, dontexist
  ;end select
 ENDIF
 CALL echo(build("Cnt = ",cnt,"     tmax = ",tmax))
 CALL echorecord(temp)
 IF ((request->specialty_code_value > 0))
  SET temp_cnt = size(temp->qual,5)
  IF (temp_cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = temp_cnt),
     prsnl_group_reltn pgr,
     prsnl_group pg
    PLAN (d)
     JOIN (pgr
     WHERE (pgr.person_id=temp->qual[d.seq].id)
      AND pgr.active_ind=1)
     JOIN (pg
     WHERE pg.prsnl_group_id=pgr.prsnl_group_id
      AND (pg.prsnl_group_type_cd=request->specialty_code_value)
      AND pg.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     pcnt = (pcnt+ 1), stat = alterlist(reply->providers,pcnt), reply->providers[pcnt].person_id =
     temp->qual[d.seq].id,
     reply->providers[pcnt].name_full_formatted = temp->qual[d.seq].name
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SET pcnt = size(temp->qual,5)
  SET stat = alterlist(reply->providers,pcnt)
  FOR (x = 1 TO size(temp->qual,5))
   SET reply->providers[x].person_id = temp->qual[x].id
   SET reply->providers[x].name_full_formatted = temp->qual[x].name
  ENDFOR
 ENDIF
#exit_script
 IF (pcnt=0)
  SET reply->status_data.status = "Z"
 ELSEIF (pcnt >= max_cnt)
  SET stat = alterlist(reply->providers,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
