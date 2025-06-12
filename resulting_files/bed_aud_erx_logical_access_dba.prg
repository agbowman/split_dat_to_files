CREATE PROGRAM bed_aud_erx_logical_access:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 person_id_list[*]
      2 person_id = f8
    1 location_cd_list[*]
      2 location_cd = f8
    1 nominator_flag = i2
    1 approved_flag = i2
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD temp_rep
 RECORD temp_rep(
   1 prsnl[*]
     2 prsnl_id = f8
     2 name_full_formatted = vc
     2 user_name = vc
     2 erx_reltns[*]
       3 prsnl_reltn_id = f8
       3 location_display = vc
       3 location_description = vc
       3 nominated_id = f8
       3 approved = vc
 )
 FREE RECORD temp_audit_prsnl
 RECORD temp_audit_prsnl(
   1 prsnl[*]
     2 prsnl_id = f8
     2 name_full_formatted = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE deliveredcodevalue = f8 WITH constant(uar_get_code_by("MEANING",3401,"DELIVERED"))
 DECLARE auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE build_person_ids(dummyvar=i2) = null
 DECLARE build_location_cds(dummyvar=i2) = null
 DECLARE highvolumecheck(highflag=i2) = null
 DECLARE data_partition_ind = i4 WITH protect
 DECLARE eparse = vc WITH protect
 DECLARE pparse = vc WITH protect
 DECLARE person_parse = vc WITH protect
 DECLARE location_parse = vc WITH protect
 DECLARE person_cnt = i4 WITH protect
 DECLARE person_r_cnt = i4 WITH protect
 DECLARE temp_person_cnt = i4 WITH protect
 DECLARE temp_person_r_cnt = i4 WITH protect
 DECLARE nominator_flag = i2 WITH protect
 DECLARE high_volume_flag = i2 WITH protect
 DECLARE pos = i2 WITH protect
 DECLARE high_data_limit = i2 WITH protect, constant(10000)
 DECLARE medium_data_limit = i2 WITH protect, constant(5000)
 SET eparse = "band(e.service_level_nbr, 2048) > 0 and e.status_cd = deliveredCodeValue"
 IF (((validate(request->approved_flag) > 0) OR (validate(request->nominator_flag) > 0)) )
  SET nominator_flag = 0
  IF (validate(request->approved_flag,0) > 0)
   SET nominator_flag = 1
   SET eparse = concat(eparse," and e.cs_approver_sig_txt > ' ' ")
  ENDIF
  IF (((validate(request->nominator_flag,0) > 0) OR (nominator_flag > 0)) )
   SET eparse = concat(eparse," and e.cs_nominator_id > 0 ")
  ENDIF
 ENDIF
 SET person_parse = " p.person_id = pr.person_id and p.active_ind = 1"
 SET location_parse = " l.location_cd = pr.parent_entity_id and l.active_ind = 1"
 SET pparse = " prsnl.person_id > 0 "
 SET pparse = concat(pparse," and prsnl.active_ind = 1 ",
  " and prsnl.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) ",
  "  and prsnl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3) ")
 SET pparse = build(pparse," and prsnl.data_status_cd  = ",auth_cd)
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
   SET pparse = concat(pparse," and prsnl.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET pparse = build(pparse,acm_get_acc_logical_domains_rep->logical_domains[d].logical_domain_id,
       ")")
     ELSE
      SET pparse = build(pparse,acm_get_acc_logical_domains_rep->logical_domains[d].logical_domain_id,
       ",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 CALL build_person_ids(0)
 CALL build_location_cds(0)
 SELECT INTO "nl:"
  FROM eprescribe_detail e,
   prsnl_reltn pr,
   person p,
   prsnl prsnl,
   location l,
   code_value c
  PLAN (e
   WHERE parser(eparse))
   JOIN (pr
   WHERE pr.prsnl_reltn_id=e.prsnl_reltn_id
    AND pr.active_ind=1
    AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND pr.parent_entity_name="LOCATION")
   JOIN (p
   WHERE parser(person_parse))
   JOIN (prsnl
   WHERE prsnl.person_id=p.person_id
    AND parser(pparse))
   JOIN (l
   WHERE parser(location_parse))
   JOIN (c
   WHERE c.code_value=l.location_cd
    AND c.active_ind=1)
  ORDER BY p.name_full_formatted, c.display
  HEAD REPORT
   person_cnt = 0, temp_person_cnt = 0, stat = alterlist(temp_rep->prsnl,100)
  HEAD p.name_full_formatted
   person_cnt = (person_cnt+ 1), temp_person_cnt = (temp_person_cnt+ 1)
   IF (person_cnt > high_data_limit)
    CALL highvolumecheck(2)
   ENDIF
   IF (temp_person_cnt > 100)
    temp_person_cnt = 1, stat = alterlist(temp_rep->prsnl,(person_cnt+ 100))
   ENDIF
   temp_rep->prsnl[person_cnt].prsnl_id = p.person_id, temp_rep->prsnl[person_cnt].
   name_full_formatted = p.name_full_formatted, temp_rep->prsnl[person_cnt].user_name = prsnl
   .username,
   person_r_cnt = 0, temp_person_r_cnt = 0, stat = alterlist(temp_rep->prsnl[person_cnt].erx_reltns,
    100)
  DETAIL
   person_r_cnt = (person_r_cnt+ 1), temp_person_r_cnt = (temp_person_r_cnt+ 1)
   IF (person_r_cnt > high_data_limit)
    CALL highvolumecheck(2)
   ENDIF
   IF (temp_person_r_cnt > 100)
    temp_person_r_cnt = 1, stat = alterlist(temp_rep->prsnl[person_cnt].erx_reltns,(person_r_cnt+ 100
     ))
   ENDIF
   temp_rep->prsnl[person_cnt].erx_reltns[person_r_cnt].prsnl_reltn_id = pr.prsnl_reltn_id, temp_rep
   ->prsnl[person_cnt].erx_reltns[person_r_cnt].location_display = c.display, temp_rep->prsnl[
   person_cnt].erx_reltns[person_r_cnt].location_description = c.description,
   temp_rep->prsnl[person_cnt].erx_reltns[person_r_cnt].nominated_id = e.cs_nominator_id, temp_rep->
   prsnl[person_cnt].erx_reltns[person_r_cnt].approved = trim(e.cs_approver_sig_txt)
  FOOT  p.name_full_formatted
   stat = alterlist(temp_rep->prsnl[person_cnt].erx_reltns,person_r_cnt)
  FOOT REPORT
   stat = alterlist(temp_rep->prsnl,person_cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting items for bed_aud_erx_logical_access report.")
 IF ((request->skip_volume_check_ind=0))
  IF (((person_cnt > high_data_limit) OR (person_r_cnt > high_data_limit)) )
   CALL highvolumecheck(2)
  ELSEIF (((person_cnt > medium_data_limit) OR (person_r_cnt > medium_data_limit)) )
   CALL highvolumecheck(1)
  ENDIF
 ENDIF
 DECLARE col_cnt = i4 WITH protect
 SET col_cnt = 6
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Name Full Formatted"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "User name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Location Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Location Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Nominated"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Approved"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 DECLARE tot_prsnl_cnt = i4 WITH protect
 DECLARE tot_erx_reltns_cnt = i4 WITH protect
 DECLARE x = i4 WITH protect
 DECLARE y = i4 WITH protect
 DECLARE row_cnt = i4 WITH protect
 SET row_cnt = 0
 DECLARE audit_prsnl_cnt = i4 WITH noconstant(0)
 DECLARE locate_num = i4 WITH noconstant(0)
 SET tot_prsnl_cnt = size(temp_rep->prsnl,5)
 FOR (x = 1 TO tot_prsnl_cnt)
  SET tot_erx_reltns_cnt = size(temp_rep->prsnl[x].erx_reltns,5)
  FOR (y = 1 TO tot_erx_reltns_cnt)
    SET row_cnt = (row_cnt+ 1)
    SET stat = alterlist(reply->rowlist,row_cnt)
    SET stat = alterlist(reply->rowlist[row_cnt].celllist,col_cnt)
    SET reply->rowlist[row_cnt].celllist[1].string_value = temp_rep->prsnl[x].name_full_formatted
    SET reply->rowlist[row_cnt].celllist[2].string_value = temp_rep->prsnl[x].user_name
    SET reply->rowlist[row_cnt].celllist[3].string_value = temp_rep->prsnl[x].erx_reltns[y].
    location_display
    SET reply->rowlist[row_cnt].celllist[4].string_value = temp_rep->prsnl[x].erx_reltns[y].
    location_description
    IF ((temp_rep->prsnl[x].erx_reltns[y].nominated_id > 0))
     SET reply->rowlist[row_cnt].celllist[5].string_value = "X"
    ENDIF
    IF (size(temp_rep->prsnl[x].erx_reltns[y].approved,1) > 0)
     SET reply->rowlist[row_cnt].celllist[6].string_value = "X"
     SET locate_num = 0
     SET pos = locateval(locate_num,1,audit_prsnl_cnt,temp_rep->prsnl[x].prsnl_id,temp_audit_prsnl->
      prsnl[locate_num].prsnl_id)
     IF (pos=0)
      SET audit_prsnl_cnt = (audit_prsnl_cnt+ 1)
      SET stat = alterlist(temp_audit_prsnl->prsnl,audit_prsnl_cnt)
      SET temp_audit_prsnl->prsnl[audit_prsnl_cnt].prsnl_id = temp_rep->prsnl[x].prsnl_id
      SET temp_audit_prsnl->prsnl[audit_prsnl_cnt].name_full_formatted = temp_rep->prsnl[x].
      name_full_formatted
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
 FOR (x = 1 TO audit_prsnl_cnt)
   EXECUTE cclaudit 0, "EPCS View approved providers", "View",
   "Person", "Security User Entity", "Provider",
   "Access/Use", value(temp_audit_prsnl->prsnl[x].prsnl_id), value(temp_audit_prsnl->prsnl[x].
    name_full_formatted)
 ENDFOR
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE build_person_ids(dummyvar)
   DECLARE parse_person_code = vc WITH protect
   DECLARE person_cnt = f8 WITH protect
   FOR (p_cnt = 1 TO size(request->person_id_list,5))
     IF (person_cnt > 999)
      SET parse_person_code = replace(parse_person_code,",","",2)
      SET parse_person_code = build(parse_person_code,") or p.person_id in (")
      SET person_cnt = 0
     ENDIF
     SET parse_person_code = build(parse_person_code,request->person_id_list[p_cnt].person_id,",")
     SET person_cnt = (person_cnt+ 1)
   ENDFOR
   SET parse_person_code = replace(parse_person_code,",","",2)
   IF (size(request->person_id_list,5) > 0)
    SET person_parse = build(person_parse," and p.person_id in (",parse_person_code,")")
   ENDIF
 END ;Subroutine
 SUBROUTINE build_location_cds(dummyvar)
   DECLARE parse_location_code = vc WITH protect
   DECLARE location_cnt = f8 WITH protect
   FOR (loc_cnt = 1 TO size(request->location_cd_list,5))
     IF (location_cnt > 999)
      SET parse_location_code = replace(parse_location_code,",","",2)
      SET parse_location_code = build(parse_location_code,") or l.location_cd in (")
      SET location_cnt = 0
     ENDIF
     SET parse_location_code = build(parse_location_code,request->location_cd_list[loc_cnt].
      location_cd,",")
     SET location_cnt = (location_cnt+ 1)
   ENDFOR
   SET parse_location_code = replace(parse_location_code,",","",2)
   IF (size(request->location_cd_list,5) > 0)
    SET location_parse = build(location_parse," and l.location_cd in (",parse_location_code,")")
   ENDIF
 END ;Subroutine
 SUBROUTINE highvolumecheck(highflag)
   IF (highflag=2)
    SET reply->high_volume_flag = 2
    SET stat = alterlist(reply->rowlist,0)
    GO TO exit_program
   ELSEIF (highflag=1)
    SET reply->high_volume_flag = 1
    SET stat = alterlist(reply->rowlist,0)
    GO TO exit_program
   ENDIF
 END ;Subroutine
#exit_program
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bed_aud_erx_logical_access.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
