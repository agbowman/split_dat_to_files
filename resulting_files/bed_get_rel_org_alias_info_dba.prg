CREATE PROGRAM bed_get_rel_org_alias_info:dba
 FREE SET reply
 RECORD reply(
   1 alias_rel_list[*]
     2 group_nbr = i4
     2 parent_org_id = f8
     2 parent_org_name = vc
     2 alias_type_flag = i4
     2 orgs[*]
       3 organization_id = f8
       3 org_name = vc
       3 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE patseq = i4
 DECLARE visseq = i4
 SET reply->status_data.status = "Z"
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
   RANGE OF o IS organization
   SET field_found = validate(o.logical_domain_id)
   FREE RANGE o
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
    SET acm_get_acc_logical_domains_req->concept = 3
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 DECLARE org_parse = vc
 SET org_parse = "org.active_ind = 1"
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET org_parse = concat(org_parse," and org.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET org_parse = concat(org_parse,trim(cnvtstring(acm_get_acc_logical_domains_rep->
         logical_domains[d].logical_domain_id)),")")
     ELSE
      SET org_parse = concat(org_parse,trim(cnvtstring(acm_get_acc_logical_domains_rep->
         logical_domains[d].logical_domain_id)),",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET tot_count = 0
 SET patseq = 0
 SET visseq = 0
 IF ((request->load.patient_ind=1))
  SELECT INTO "NL:"
   FROM br_org_alias_group b,
    organization org,
    organization parent_org
   PLAN (b
    WHERE b.patient_seq > 0
     AND ((b.process_flag=0) OR (b.process_flag=2)) )
    JOIN (org
    WHERE b.organization_id=org.organization_id
     AND parser(org_parse))
    JOIN (parent_org
    WHERE b.parent_org_id=parent_org.organization_id
     AND parent_org.active_ind=1)
   ORDER BY b.patient_seq, b.organization_id
   HEAD REPORT
    org_count = 0
   HEAD b.patient_seq
    patseq = (patseq+ 1), tot_count = (tot_count+ 1), org_count = 0,
    stat = alterlist(reply->alias_rel_list,tot_count), reply->alias_rel_list[tot_count].
    alias_type_flag = 1, reply->alias_rel_list[tot_count].parent_org_id = b.parent_org_id,
    reply->alias_rel_list[tot_count].parent_org_name = parent_org.org_name, reply->alias_rel_list[
    tot_count].group_nbr = patseq
   HEAD b.organization_id
    org_count = (org_count+ 1), stat = alterlist(reply->alias_rel_list[tot_count].orgs,org_count),
    reply->alias_rel_list[tot_count].orgs[org_count].organization_id = b.organization_id,
    reply->alias_rel_list[tot_count].orgs[org_count].org_name = org.org_name, reply->alias_rel_list[
    tot_count].orgs[org_count].sequence = patseq
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->alias_rel_list,tot_count)
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request->load.use_groups_ind=0))
  IF ((request->load.visit_ind=1))
   SELECT INTO "NL:"
    FROM br_org_alias_group b,
     organization org,
     organization parent_org
    PLAN (b
     WHERE b.visit_seq > 0
      AND ((b.process_flag=0) OR (b.process_flag=1)) )
     JOIN (org
     WHERE b.organization_id=org.organization_id
      AND parser(org_parser))
     JOIN (parent_org
     WHERE b.parent_org_id=parent_org.organization_id
      AND parent_org.active_ind=1)
    ORDER BY b.visit_seq, b.organization_id
    HEAD REPORT
     org_count = 0
    HEAD b.visit_seq
     visseq = (visseq+ 1), org_count = 0, tot_count = (tot_count+ 1),
     stat = alterlist(reply->alias_rel_list,tot_count), reply->alias_rel_list[tot_count].group_nbr =
     visseq, reply->alias_rel_list[tot_count].alias_type_flag = 2,
     reply->alias_rel_list[tot_count].parent_org_id = b.parent_org_id, reply->alias_rel_list[
     tot_count].parent_org_name = parent_org.org_name
    HEAD b.organization_id
     org_count = (org_count+ 1), stat = alterlist(reply->alias_rel_list[tot_count].orgs,org_count),
     reply->alias_rel_list[tot_count].orgs[org_count].organization_id = b.organization_id,
     reply->alias_rel_list[tot_count].orgs[org_count].org_name = org.org_name, reply->alias_rel_list[
     tot_count].orgs[org_count].sequence = visseq
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->alias_rel_list,tot_count)
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF ((request->load.use_groups_ind=1))
  IF ((request->load.visit_ind=1))
   SET mrn = 0
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=4
      AND cv.cdf_meaning="MRN"
      AND cv.active_ind=1)
    DETAIL
     mrn = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM org_alias_pool_reltn oapr,
     organization org
    PLAN (oapr
     WHERE oapr.alias_entity_alias_type_cd=mrn
      AND oapr.active_ind=1)
     JOIN (org
     WHERE org.organization_id=oapr.organization_id
      AND parser(org_parse))
    ORDER BY oapr.alias_pool_cd, oapr.organization_id
    HEAD REPORT
     org_count = 0
    HEAD oapr.alias_pool_cd
     visseq = (visseq+ 1), org_count = 0, tot_count = (tot_count+ 1),
     stat = alterlist(reply->alias_rel_list,tot_count), reply->alias_rel_list[tot_count].group_nbr =
     visseq, reply->alias_rel_list[tot_count].alias_type_flag = 2,
     reply->alias_rel_list[tot_count].parent_org_id = oapr.organization_id, reply->alias_rel_list[
     tot_count].parent_org_name = org.org_name
    HEAD oapr.organization_id
     org_count = (org_count+ 1), stat = alterlist(reply->alias_rel_list[tot_count].orgs,org_count),
     reply->alias_rel_list[tot_count].orgs[org_count].organization_id = oapr.organization_id,
     reply->alias_rel_list[tot_count].orgs[org_count].org_name = org.org_name, reply->alias_rel_list[
     tot_count].orgs[org_count].sequence = visseq
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->alias_rel_list,tot_count)
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
 IF (tot_count=0)
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
