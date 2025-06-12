CREATE PROGRAM bed_get_alias_pool_by_type:dba
 FREE SET reply
 RECORD reply(
   1 alias_pool_list[*]
     2 req_alias_type_cd = f8
     2 req_alias_type_disp = vc
     2 req_alias_type_mean = vc
     2 alias_pool_cd = f8
     2 alias_pool_display = vc
     2 alias_pool_meaning = vc
     2 alias_pool_description = vc
     2 active_ind = i2
     2 unique_ind = i2
     2 format_mask = vc
     2 check_digit_code_value = f8
     2 check_digit_disp = vc
     2 check_digit_mean = vc
     2 dup_allowed_flag = i2
     2 sys_assign_flag = i2
     2 cmb_inactive_ind = i2
     2 alias_method_code_value = f8
     2 alias_method_disp = vc
     2 alias_method_mean = vc
     2 alias_pool_ext_code_value = f8
     2 alias_pool_ext_disp = vc
     2 alias_pool_ext_mean = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
    SET acm_get_acc_logical_domains_req->concept = 5
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 DECLARE ap_parse = vc
 SET ap_parse = "a.alias_pool_cd = o.alias_pool_cd"
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET ap_parse = concat(ap_parse," and a.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET ap_parse = build(ap_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET ap_parse = build(ap_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET reply->status_data.status = "F"
 SET found_alias_pool = "F"
 SET acnt = size(request->alias_type_cd_list,5)
 SET x = 0
 IF ((request->alias_type_cd_list[1].alias_type_cd > 0))
  IF ((request->load.load_full_ind=0))
   FOR (i = 1 TO acnt)
     SELECT INTO "nl:"
      o.alias_entity_alias_type_cd, o.alias_pool_cd, a.alias_pool_cd,
      typ_disp = decode(ct.seq,ct.display," "), typ_mean = decode(ct.seq,ct.cdf_meaning," "),
      pool_disp = decode(cp.seq,cp.display," "),
      pool_mean = decode(cp.seq,cp.cdf_meaning," "), pool_desc = decode(cp.seq,cp.description," ")
      FROM org_alias_pool_reltn o,
       alias_pool a,
       code_value ct,
       code_value cp,
       dummyt d1
      PLAN (o
       WHERE (o.alias_entity_alias_type_cd=request->alias_type_cd_list[i].alias_type_cd)
        AND o.alias_pool_cd > 0.0)
       JOIN (a
       WHERE parser(ap_parse))
       JOIN (ct
       WHERE ct.code_value=o.alias_entity_alias_type_cd)
       JOIN (d1)
       JOIN (cp
       WHERE cp.code_value=a.alias_pool_cd)
      ORDER BY o.alias_pool_cd
      HEAD o.alias_pool_cd
       found_alias_pool = "T", x = (x+ 1), stat = alterlist(reply->alias_pool_list,x),
       reply->alias_pool_list[x].req_alias_type_cd = o.alias_entity_alias_type_cd, reply->
       alias_pool_list[x].req_alias_type_disp = typ_disp, reply->alias_pool_list[x].
       req_alias_type_mean = typ_mean,
       reply->alias_pool_list[x].alias_pool_cd = a.alias_pool_cd, reply->alias_pool_list[x].
       alias_pool_display = pool_disp, reply->alias_pool_list[x].alias_pool_meaning = pool_mean,
       reply->alias_pool_list[x].alias_pool_description = pool_desc
      WITH dontcare = cp, nocounter
     ;end select
   ENDFOR
  ELSE
   FOR (i = 1 TO acnt)
     SELECT INTO "nl:"
      typ_disp = decode(ct.seq,ct.display," "), typ_mean = decode(ct.seq,ct.cdf_meaning," "),
      pool_disp = decode(cp.seq,cp.display," "),
      pool_mean = decode(cp.seq,cp.cdf_meaning," "), pool_desc = decode(cp.seq,cp.description," "),
      disp2 = decode(c2.seq,c2.display," "),
      mean2 = decode(c2.seq,c2.cdf_meaning," "), disp3 = decode(c3.seq,c3.display," "), mean3 =
      decode(c3.seq,c3.cdf_meaning," "),
      disp4 = decode(c4.seq,c4.display," "), mean4 = decode(c4.seq,c4.cdf_meaning," ")
      FROM org_alias_pool_reltn o,
       alias_pool a,
       code_value ct,
       code_value cp,
       code_value c2,
       code_value c3,
       code_value c4,
       dummyt d1,
       dummyt d2,
       dummyt d3,
       dummyt d4
      PLAN (o
       WHERE (o.alias_entity_alias_type_cd=request->alias_type_cd_list[i].alias_type_cd))
       JOIN (a
       WHERE parser(ap_parse))
       JOIN (ct
       WHERE ct.code_value=o.alias_entity_alias_type_cd)
       JOIN (d1)
       JOIN (cp
       WHERE cp.code_value=a.alias_pool_cd)
       JOIN (d2)
       JOIN (c2
       WHERE c2.code_value=a.check_digit_cd)
       JOIN (d3)
       JOIN (c3
       WHERE c3.code_value=a.alias_method_cd)
       JOIN (d4)
       JOIN (c4
       WHERE c4.code_value=a.alias_pool_ext_cd)
      ORDER BY o.alias_pool_cd
      HEAD o.alias_pool_cd
       found_alias_pool = "T", x = (x+ 1), stat = alterlist(reply->alias_pool_list,x),
       reply->alias_pool_list[x].req_alias_type_cd = o.alias_entity_alias_type_cd, reply->
       alias_pool_list[x].req_alias_type_disp = typ_disp, reply->alias_pool_list[x].
       req_alias_type_mean = typ_mean,
       reply->alias_pool_list[x].alias_pool_cd = a.alias_pool_cd, reply->alias_pool_list[x].
       alias_pool_display = pool_disp, reply->alias_pool_list[x].alias_pool_meaning = pool_mean,
       reply->alias_pool_list[x].alias_pool_description = pool_desc, reply->alias_pool_list[x].
       active_ind = a.active_ind, reply->alias_pool_list[x].unique_ind = a.unique_ind,
       reply->alias_pool_list[x].format_mask = a.format_mask, reply->alias_pool_list[x].
       check_digit_code_value = a.check_digit_cd, reply->alias_pool_list[x].check_digit_disp = disp2,
       reply->alias_pool_list[x].check_digit_mean = mean2, reply->alias_pool_list[x].dup_allowed_flag
        = a.dup_allowed_flag, reply->alias_pool_list[x].sys_assign_flag = a.sys_assign_flag,
       reply->alias_pool_list[x].cmb_inactive_ind = a.cmb_inactive_ind, reply->alias_pool_list[x].
       alias_method_code_value = a.alias_method_cd, reply->alias_pool_list[x].alias_method_disp =
       disp3,
       reply->alias_pool_list[x].alias_method_mean = mean3, reply->alias_pool_list[x].
       alias_pool_ext_code_value = a.alias_pool_ext_cd, reply->alias_pool_list[x].alias_pool_ext_disp
        = disp4,
       reply->alias_pool_list[x].alias_pool_ext_mean = mean4
      WITH dontcare = cp, dontcare = c2, dontcare = c3,
       dontcare = c4, nocounter
     ;end select
   ENDFOR
  ENDIF
 ELSE
  IF ((request->load.load_full_ind=0))
   SELECT INTO "nl:"
    o.alias_entity_alias_type_cd, o.alias_pool_cd, a.alias_pool_cd,
    typ_disp = decode(ct.seq,ct.display," "), typ_mean = decode(ct.seq,ct.cdf_meaning," "), pool_disp
     = decode(cp.seq,cp.display," "),
    pool_mean = decode(cp.seq,cp.cdf_meaning," "), pool_desc = decode(cp.seq,cp.description," ")
    FROM org_alias_pool_reltn o,
     alias_pool a,
     code_value ct,
     code_value cp,
     dummyt d1
    PLAN (o)
     JOIN (a
     WHERE parser(ap_parse))
     JOIN (ct
     WHERE ct.code_value=o.alias_entity_alias_type_cd)
     JOIN (d1)
     JOIN (cp
     WHERE cp.code_value=a.alias_pool_cd)
    ORDER BY o.alias_pool_cd
    HEAD o.alias_pool_cd
     found_alias_pool = "T", x = (x+ 1), stat = alterlist(reply->alias_pool_list,x),
     reply->alias_pool_list[x].req_alias_type_cd = o.alias_entity_alias_type_cd, reply->
     alias_pool_list[x].req_alias_type_disp = typ_disp, reply->alias_pool_list[x].req_alias_type_mean
      = typ_mean,
     reply->alias_pool_list[x].alias_pool_cd = a.alias_pool_cd, reply->alias_pool_list[x].
     alias_pool_display = pool_disp, reply->alias_pool_list[x].alias_pool_meaning = pool_mean,
     reply->alias_pool_list[x].alias_pool_description = pool_desc
    WITH dontcare = cp, nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    typ_disp = decode(ct.seq,ct.display," "), typ_mean = decode(ct.seq,ct.cdf_meaning," "), pool_disp
     = decode(cp.seq,cp.display," "),
    pool_mean = decode(cp.seq,cp.cdf_meaning," "), pool_desc = decode(cp.seq,cp.description," "),
    disp2 = decode(c2.seq,c2.display," "),
    mean2 = decode(c2.seq,c2.cdf_meaning," "), disp3 = decode(c3.seq,c3.display," "), mean3 = decode(
     c3.seq,c3.cdf_meaning," "),
    disp4 = decode(c4.seq,c4.display," "), mean4 = decode(c4.seq,c4.cdf_meaning," ")
    FROM org_alias_pool_reltn o,
     alias_pool a,
     code_value ct,
     code_value cp,
     code_value c2,
     code_value c3,
     code_value c4,
     dummyt d1,
     dummyt d2,
     dummyt d3,
     dummyt d4
    PLAN (o)
     JOIN (a
     WHERE parser(ap_parse))
     JOIN (ct
     WHERE ct.code_value=o.alias_entity_alias_type_cd)
     JOIN (d1)
     JOIN (cp
     WHERE cp.code_value=a.alias_pool_cd)
     JOIN (d2)
     JOIN (c2
     WHERE c2.code_value=a.check_digit_cd)
     JOIN (d3)
     JOIN (c3
     WHERE c3.code_value=a.alias_method_cd)
     JOIN (d4)
     JOIN (c4
     WHERE c4.code_value=a.alias_pool_ext_cd)
    ORDER BY o.alias_pool_cd
    HEAD o.alias_pool_cd
     found_alias_pool = "T", x = (x+ 1), stat = alterlist(reply->alias_pool_list,x),
     reply->alias_pool_list[x].req_alias_type_cd = o.alias_entity_alias_type_cd, reply->
     alias_pool_list[x].req_alias_type_disp = typ_disp, reply->alias_pool_list[x].req_alias_type_mean
      = typ_mean,
     reply->alias_pool_list[x].alias_pool_cd = a.alias_pool_cd, reply->alias_pool_list[x].
     alias_pool_display = pool_disp, reply->alias_pool_list[x].alias_pool_meaning = pool_mean,
     reply->alias_pool_list[x].alias_pool_description = pool_desc, reply->alias_pool_list[x].
     active_ind = a.active_ind, reply->alias_pool_list[x].unique_ind = a.unique_ind,
     reply->alias_pool_list[x].format_mask = a.format_mask, reply->alias_pool_list[x].
     check_digit_code_value = a.check_digit_cd, reply->alias_pool_list[x].check_digit_disp = disp2,
     reply->alias_pool_list[x].check_digit_mean = mean2, reply->alias_pool_list[x].dup_allowed_flag
      = a.dup_allowed_flag, reply->alias_pool_list[x].sys_assign_flag = a.sys_assign_flag,
     reply->alias_pool_list[x].cmb_inactive_ind = a.cmb_inactive_ind, reply->alias_pool_list[x].
     alias_method_code_value = a.alias_method_cd, reply->alias_pool_list[x].alias_method_disp = disp3,
     reply->alias_pool_list[x].alias_method_mean = mean3, reply->alias_pool_list[x].
     alias_pool_ext_code_value = a.alias_pool_ext_cd, reply->alias_pool_list[x].alias_pool_ext_disp
      = disp4,
     reply->alias_pool_list[x].alias_pool_ext_mean = mean4
    WITH dontcare = cp, dontcare = c2, dontcare = c3,
     dontcare = c4, nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME: BED_GET_ALIAS_POOL_BY_TYPE  >> ERROR MESSAGE: ",
   error_msg)
 ELSE
  IF (found_alias_pool="T")
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 CALL echorecord(reply)
END GO
