CREATE PROGRAM bed_get_specialty:dba
 FREE SET reply
 RECORD reply(
   1 nlist[*]
     2 name = vc
     2 value = vc
     2 name_value_id = f8
     2 personnel_count = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET count = 0
 SET pcount = 0
 SET stat = alterlist(reply->nlist,50)
 SELECT INTO "NL:"
  FROM br_name_value bnv
  WHERE bnv.br_nv_key1="PCOSPECIALTY"
  ORDER BY bnv.br_name_value_id
  DETAIL
   count = (count+ 1), tot_count = (tot_count+ 1)
   IF (count > 50)
    stat = alterlist(reply->nlist,(tot_count+ 50)), count = 1
   ENDIF
   reply->nlist[tot_count].name = bnv.br_name, reply->nlist[tot_count].value = bnv.br_value, reply->
   nlist[tot_count].name_value_id = bnv.br_name_value_id
  WITH nocounter
 ;end select
 IF ((request->load.personnel_count_ind=1))
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
  DECLARE prsnl_parse = vc
  SET prsnl_parse = "p.active_ind = 1"
  IF (data_partition_ind=1)
   IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
    SET prsnl_parse = concat(prsnl_parse," and p.logical_domain_id in (")
    FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
      IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
       SET prsnl_parse = build(prsnl_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
        logical_domain_id,")")
      ELSE
       SET prsnl_parse = build(prsnl_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
        logical_domain_id,",")
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_count),
    br_prsnl_specialty b,
    prsnl p
   PLAN (d)
    JOIN (b
    WHERE (b.specialty_id=reply->nlist[d.seq].name_value_id)
     AND b.specialty_id > 0)
    JOIN (p
    WHERE p.person_id=b.prsnl_id
     AND parser(prsnl_parse))
   HEAD d.seq
    pcount = 0
   DETAIL
    pcount = (pcount+ 1)
   FOOT  d.seq
    reply->nlist[d.seq].personnel_count = pcount
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->nlist,tot_count)
 IF (tot_count=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
#exit_script
 CALL echorecord(reply)
END GO
