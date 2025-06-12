CREATE PROGRAM bed_get_sn_surgeons_list:dba
 DECLARE auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE prsnl_comm_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16289,"PRSNL"))
 DECLARE data_partition_ind = i2 WITH protect, noconstant(0)
 DECLARE field_found = i4 WITH protect, noconstant(0)
 DECLARE scnt = i4 WITH protect, noconstant(0)
 DECLARE acnt = i4 WITH protect, noconstant(0)
 DECLARE pick_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE alterlist_scnt = i4 WITH protect, noconstant(0)
 DECLARE prg_exists_ind = i2 WITH protect, noconstant(0)
 DECLARE prsnl_parse = vc WITH protect
 DECLARE search_string = vc WITH protect
 DECLARE max_reply = i4 WITH protect, constant(501)
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 surgeon_id = f8
     2 surgeon_name = c100
     2 pick_list_for_all_surg_area_ind = i2
     2 surgeon_comments_exist_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 SET reply->status_data.status = "F"
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
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
 IF (size(trim(request->search_txt),1) > 0)
  SET search_string = trim(cnvtalphanum(request->search_txt))
  IF ((request->search_type_flag="S"))
   SET search_string = concat(cnvtupper(search_string),"*")
  ELSE
   SET search_string = concat("*",cnvtupper(search_string),"*")
  ENDIF
  SET prsnl_parse = concat(prsnl_parse," and cnvtupper(p.name_full_formatted) = '",search_string,"'")
 ENDIF
 SET stat = alterlist(reply->slist,50)
 IF ((request->specialty_code_value > 0))
  CALL echo("********** 1st half of if statement")
  SELECT DISTINCT INTO "NL:"
   FROM prsnl p,
    prsnl_group pgspec,
    prsnl_group_reltn pgrspec,
    sn_comment_text sct,
    long_text_reference ltr,
    dummyt d
   PLAN (p
    WHERE parser(prsnl_parse)
     AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ((p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null))
     AND p.physician_ind=1
     AND p.data_status_cd=auth_cd)
    JOIN (pgspec
    WHERE (pgspec.prsnl_group_type_cd=request->specialty_code_value)
     AND pgspec.active_ind=1)
    JOIN (pgrspec
    WHERE pgrspec.prsnl_group_id=pgspec.prsnl_group_id
     AND pgrspec.active_ind=1
     AND pgrspec.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ((pgrspec.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (pgrspec
    .end_effective_dt_tm=null))
     AND pgrspec.person_id=p.person_id)
    JOIN (sct
    WHERE sct.root_id=outerjoin(p.person_id)
     AND sct.root_name=outerjoin("PRSNL")
     AND sct.surg_area_cd=outerjoin(0.0)
     AND sct.comment_type_cd=outerjoin(prsnl_comm_type_cd)
     AND sct.active_ind=outerjoin(1))
    JOIN (ltr
    WHERE ltr.long_text_id=outerjoin(sct.long_text_id))
    JOIN (d
    WHERE ltr.long_text > " ")
   DETAIL
    scnt = (scnt+ 1), alterlist_scnt = (alterlist_scnt+ 1)
    IF (alterlist_scnt > 50)
     stat = alterlist(reply->slist,(scnt+ 50)), alterlist_scnt = 1
    ENDIF
    reply->slist[scnt].surgeon_id = p.person_id, reply->slist[scnt].surgeon_name = p
    .name_full_formatted, reply->slist[scnt].surgeon_comments_exist_ind = 0
    IF (sct.long_text_id > 0
     AND ltr.long_text_id > 0
     AND ltr.long_text > "     *")
     reply->slist[scnt].surgeon_comments_exist_ind = 1
    ENDIF
   WITH maxrec = max_reply, outerjoin = ltr
  ;end select
 ELSE
  CALL echo("********** 2nd half of if statement")
  SELECT DISTINCT INTO "NL:"
   FROM prsnl p,
    sn_comment_text sct,
    long_text_reference ltr,
    dummyt d
   PLAN (p
    WHERE parser(prsnl_parse)
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (p.end_effective_dt_tm=null))
     AND p.physician_ind=1
     AND p.data_status_cd=auth_cd)
    JOIN (sct
    WHERE sct.root_id=outerjoin(p.person_id)
     AND sct.root_name=outerjoin("PRSNL")
     AND sct.surg_area_cd=outerjoin(0.0)
     AND sct.comment_type_cd=outerjoin(prsnl_comm_type_cd)
     AND sct.active_ind=outerjoin(1))
    JOIN (ltr
    WHERE ltr.long_text_id=outerjoin(sct.long_text_id))
    JOIN (d
    WHERE ltr.long_text > " ")
   DETAIL
    scnt = (scnt+ 1), alterlist_scnt = (alterlist_scnt+ 1)
    IF (alterlist_scnt > 50)
     stat = alterlist(reply->slist,(scnt+ 50)), alterlist_scnt = 1
    ENDIF
    reply->slist[scnt].surgeon_id = p.person_id, reply->slist[scnt].surgeon_name = p
    .name_full_formatted, reply->slist[scnt].surgeon_comments_exist_ind = 0
    IF (sct.long_text_id > 0
     AND ltr.long_text_id > 0
     AND ltr.long_text > "     *")
     reply->slist[scnt].surgeon_comments_exist_ind = 1
    ENDIF
   WITH maxrec = max_reply, outerjoin = ltr
  ;end select
 ENDIF
 SET stat = alterlist(reply->slist,scnt)
 IF (scnt > 0)
  SET acnt = size(request->alist,5)
  IF ((request->catalog_code_value > 0)
   AND acnt > 0)
   FOR (s = 1 TO scnt)
     SET pick_list_cnt = 0
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = acnt),
       preference_card pc,
       pref_card_pick_list pl
      PLAN (d)
       JOIN (pc
       WHERE (pc.catalog_cd=request->catalog_code_value)
        AND (pc.surg_area_cd=request->alist[d.seq].surg_area_code_value)
        AND (pc.prsnl_id=reply->slist[s].surgeon_id))
       JOIN (pl
       WHERE pl.pref_card_id=pc.pref_card_id
        AND pl.active_ind=1)
      ORDER BY pc.surg_area_cd
      HEAD pc.surg_area_cd
       pick_list_cnt = (pick_list_cnt+ 1)
      WITH nocounter
     ;end select
     IF (pick_list_cnt < acnt)
      SET reply->slist[s].pick_list_for_all_surg_area_ind = 0
     ELSE
      SET reply->slist[s].pick_list_for_all_surg_area_ind = 1
     ENDIF
   ENDFOR
  ELSEIF (acnt=0)
   FOR (s = 1 TO scnt)
    SELECT INTO "NL:"
     FROM preference_card pc,
      pref_card_pick_list pl
     PLAN (pc
      WHERE (pc.prsnl_id=reply->slist[s].surgeon_id))
      JOIN (pl
      WHERE pl.pref_card_id=pc.pref_card_id
       AND pl.active_ind=1)
     DETAIL
      pick_list_cnt = (pick_list_cnt+ 1)
     WITH nocounter
    ;end select
    IF (pick_list_cnt=0)
     SET reply->slist[s].pick_list_for_all_surg_area_ind = 0
    ELSE
     SET reply->slist[s].pick_list_for_all_surg_area_ind = 1
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF (scnt > 0)
  IF (scnt >= max_reply)
   SET reply->too_many_results_ind = 1
   SET reply->status_data.status = "S"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF ((reply->too_many_results_ind=1))
  SET stat = alterlist(reply->slist,0)
 ENDIF
 CALL echorecord(reply)
END GO
