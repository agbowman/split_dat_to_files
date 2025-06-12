CREATE PROGRAM cps_get_all_prsnl:dba
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 RECORD reply(
   1 prsnl_qual = i4
   1 prsnl[*]
     2 person_id = f8
     2 name_last = vc
     2 name_first = vc
     2 name_middle = vc
     2 name_suffix = vc
     2 name_last_key = vc
     2 name_first_key = vc
     2 name_full_formatted = vc
     2 password = vc
     2 email = vc
     2 prsnl_type_cd = f8
     2 physician_ind = i2
     2 position_cd = f8
     2 department_cd = f8
     2 username = vc
     2 section_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 data_status_cd = f8
     2 prim_assign_loc_cd = f8
     2 log_access_ind = i2
     2 log_level = i4
     2 ft_entity_name = c32
     2 ft_entity_id = f8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET name_type_cd_value = 0.0
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=213
   AND c.cdf_meaning="CURRENT"
  DETAIL
   name_type_cd_value = c.code_value
  WITH nocounter
 ;end select
 IF ((request->prsnl_qual=0.0))
  SELECT INTO "nl:"
   FROM prsnl n,
    person_name p2,
    person p
   PLAN (n
    WHERE n.active_ind=1
     AND n.person_id > 0
     AND n.physician_ind=1
     AND n.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND n.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=n.person_id)
    JOIN (p2
    WHERE p2.person_id=p.person_id
     AND p2.name_type_cd=name_type_cd_value)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1
    IF (mod(count1,100)=1)
     stat = alterlist(reply->prsnl,(count1+ 100))
    ENDIF
    reply->prsnl[count1].person_id = n.person_id, reply->prsnl[count1].updt_cnt = n.updt_cnt, reply->
    prsnl[count1].name_last = n.name_last,
    reply->prsnl[count1].name_first = n.name_first, reply->prsnl[count1].name_full_formatted = n
    .name_full_formatted, reply->prsnl[count1].prsnl_type_cd = n.prsnl_type_cd,
    reply->prsnl[count1].name_middle = p.name_middle, reply->prsnl[count1].name_suffix = p2
    .name_suffix, reply->prsnl[count1].beg_effective_dt_tm = cnvtdatetime(n.beg_effective_dt_tm),
    reply->prsnl[count1].end_effective_dt_tm = cnvtdatetime(n.end_effective_dt_tm)
   WITH nocounter
  ;end select
 ELSE
  CALL echo(build("else"))
  SELECT INTO "nl:"
   FROM prsnl pr,
    person_name pn,
    person p,
    (dummyt d  WITH seq = value(request->prsnl_qual))
   PLAN (pr
    WHERE pr.active_ind=1
     AND pr.person_id > 0
     AND pr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=pr.person_id)
    JOIN (pn
    WHERE pn.person_id=pr.person_id
     AND pn.name_type_cd=name_type_cd_value)
    JOIN (d
    WHERE (request->prsnl[d.seq].person_id=p.person_id))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1
    IF (mod(count1,100)=1)
     stat = alterlist(reply->prsnl,(count1+ 100))
    ENDIF
    reply->prsnl[count1].person_id = pr.person_id, reply->prsnl[count1].updt_cnt = pr.updt_cnt, reply
    ->prsnl[count1].name_last = pr.name_last,
    reply->prsnl[count1].name_first = pr.name_first, reply->prsnl[count1].name_full_formatted = pr
    .name_full_formatted, reply->prsnl[count1].name_last_key = pr.name_last_key,
    reply->prsnl[count1].name_first_key = pr.name_first_key, reply->prsnl[count1].name_middle = p
    .name_middle, reply->prsnl[count1].name_suffix = pn.name_suffix,
    reply->prsnl[count1].ft_entity_name = pr.ft_entity_name, reply->prsnl[count1].ft_entity_id = pr
    .ft_entity_id, reply->prsnl[count1].prim_assign_loc_cd = pr.prim_assign_loc_cd,
    reply->prsnl[count1].log_access_ind = pr.log_access_ind, reply->prsnl[count1].log_level = pr
    .log_level, reply->prsnl[count1].section_cd = pr.section_cd,
    reply->prsnl[count1].data_status_cd = pr.data_status_cd, reply->prsnl[count1].email = pr.email,
    reply->prsnl[count1].position_cd = pr.position_cd,
    reply->prsnl[count1].password = pr.password, reply->prsnl[count1].department_cd = pr
    .department_cd, reply->prsnl[count1].physician_ind = pr.physician_ind,
    reply->prsnl[count1].prsnl_type_cd = pr.prsnl_type_cd, reply->prsnl[count1].beg_effective_dt_tm
     = cnvtdatetime(pr.beg_effective_dt_tm), reply->prsnl[count1].end_effective_dt_tm = cnvtdatetime(
     pr.end_effective_dt_tm)
   WITH nocounter
  ;end select
 ENDIF
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->prsnl,count1)
 SET reply->prsnl_qual = count1
END GO
