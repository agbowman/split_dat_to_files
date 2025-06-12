CREATE PROGRAM bed_get_rel_prsnl_specialty:dba
 FREE SET reply
 RECORD reply(
   1 rel_list[*]
     2 prsnl_id = f8
     2 prsnl_name = vc
     2 specialty_id = f8
     2 specialty_value = vc
     2 specialty_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET stat = alterlist(reply->rel_list,100)
 SET pcnt = size(request->plist,5)
 SET scnt = size(request->slist,5)
 SET tot_count = 0
 SET count = 0
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
 SET prsnl_parse = "b.prsnl_id = p.person_id and p.active_ind = 1"
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
 FOR (x = 1 TO pcnt)
   SELECT INTO "NL:"
    FROM br_prsnl_specialty b,
     br_name_value bnv,
     prsnl p
    PLAN (b
     WHERE (b.prsnl_id=request->plist[x].prsnl_id))
     JOIN (bnv
     WHERE bnv.br_name_value_id=b.specialty_id)
     JOIN (p
     WHERE parser(prsnl_parse))
    DETAIL
     tot_count = (tot_count+ 1), count = (count+ 1)
     IF (count > 100)
      stat = alterlist(reply->rel_list,(tot_count+ 100)), count = 1
     ENDIF
     CALL echo(b.prsnl_id), reply->rel_list[tot_count].prsnl_id = b.prsnl_id, reply->rel_list[
     tot_count].prsnl_name = p.name_full_formatted,
     reply->rel_list[tot_count].specialty_id = b.specialty_id, reply->rel_list[tot_count].
     specialty_value = bnv.br_value, reply->rel_list[tot_count].specialty_name = bnv.br_name
    WITH nocounter
   ;end select
 ENDFOR
 FOR (x = 1 TO scnt)
   SELECT INTO "NL:"
    FROM br_prsnl_specialty b,
     br_name_value bnv,
     prsnl p
    PLAN (b
     WHERE (b.specialty_id=request->slist[x].specialty_id))
     JOIN (bnv
     WHERE bnv.br_name_value_id=b.specialty_id)
     JOIN (p
     WHERE parser(prsnl_parse))
    DETAIL
     tot_count = (tot_count+ 1), count = (count+ 1)
     IF (count > 100)
      stat = alterlist(reply->rel_list,(tot_count+ 100)), count = 1
     ENDIF
     reply->rel_list[tot_count].prsnl_id = b.prsnl_id, reply->rel_list[tot_count].prsnl_name = p
     .name_full_formatted, reply->rel_list[tot_count].specialty_id = b.specialty_id,
     reply->rel_list[tot_count].specialty_value = bnv.br_value, reply->rel_list[tot_count].
     specialty_name = bnv.br_name
    WITH nocounter
   ;end select
 ENDFOR
 GO TO exit_script
#exit_script
 SET stat = alterlist(reply->rel_list,tot_count)
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
