CREATE PROGRAM bed_get_pos_by_mean:dba
 FREE SET reply
 RECORD reply(
   1 rlist[*]
     2 step_cat_mean = vc
     2 position_code_value = f8
     2 display = vc
     2 display_seq = i2
     2 desc = vc
     2 long_desc = vc
     2 resident_ind = i2
     2 physician_ind = i2
     2 physoffice_ind = i2
     2 physassist_ind = i2
     2 physassist_rx_flag = i2
     2 physassist_chg_flag = i2
     2 nursepract_ind = i2
     2 nursepract_rx_flag = i2
     2 nursepract_chg_flag = i2
     2 newposition_ind = i2
     2 newposition_rx_flag = i2
     2 newposition_chg_flag = i2
     2 default_selected_ind = i2
     2 reviewed_ind = i2
     2 personnel_count = i2
     2 hnam_physician_ind = i2
   1 reslist[*]
     2 category_id = f8
     2 res_code_value = f8
     2 res_display = vc
     2 res_display_seq = i2
     2 default_selected_ind = i2
     2 reviewed_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 rlist[*]
     2 step_cat_mean = vc
     2 category_id = f8
     2 position_code_value = f8
     2 display = vc
     2 display_seq = i2
     2 desc = vc
     2 long_desc = vc
     2 resident_ind = i2
     2 physician_ind = i2
     2 physoffice_ind = i2
     2 physassist_ind = i2
     2 nursepract_ind = i2
     2 newposition_ind = i1
     2 default_selected_ind = i2
     2 reviewed_ind = i2
     2 hnam_physician_ind = i2
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET count = 0
 SET client_total = 0
 SET rescnt = 0
 SET physassist_code_value = 0.0
 SET physassist_idx = 0
 SET nursepract_code_value = 0.0
 SET nursepract_idx = 0
 SET auto_client_id = 0.0
 SELECT INTO "NL:"
  FROM br_client b
  DETAIL
   auto_client_id = b.autobuild_client_id
  WITH nocounter
 ;end select
 IF ((request->step_mean="PCOWHOWORKS"))
  SET stat = alterlist(reply->reslist,5)
  SET reply->reslist[1].res_display = "Year 1 Resident"
  SET reply->reslist[2].res_display = "Year 2 Resident"
  SET reply->reslist[3].res_display = "Year 3 Resident"
  SET reply->reslist[4].res_display = "Year 4 Resident"
  SET reply->reslist[5].res_display = "Year 5 Resident"
  SET reply->reslist[1].res_display_seq = 4
  SET reply->reslist[2].res_display_seq = 5
  SET reply->reslist[3].res_display_seq = 6
  SET reply->reslist[4].res_display_seq = 7
  SET reply->reslist[5].res_display_seq = 8
  SELECT INTO "nl:"
   FROM br_position_category bpc
   PLAN (bpc
    WHERE bpc.step_cat_mean="PCO")
   DETAIL
    reply->reslist[1].category_id = bpc.category_id, reply->reslist[2].category_id = bpc.category_id,
    reply->reslist[3].category_id = bpc.category_id,
    reply->reslist[4].category_id = bpc.category_id, reply->reslist[5].category_id = bpc.category_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->all_mean_ind=1))
  SELECT INTO "NL:"
   FROM br_position_category bpc,
    br_position_cat_comp bpcc,
    code_value cv,
    br_long_text lt,
    br_name_value bnv
   PLAN (bpc
    WHERE bpc.active_ind=1)
    JOIN (bpcc
    WHERE bpcc.category_id=bpc.category_id)
    JOIN (cv
    WHERE cv.code_set=88
     AND cv.active_ind=1
     AND cv.code_value=bpcc.position_cd)
    JOIN (lt
    WHERE lt.parent_entity_name=outerjoin("CODE_VALUE")
     AND lt.parent_entity_id=outerjoin(bpcc.position_cd))
    JOIN (bnv
    WHERE bnv.br_nv_key1=outerjoin("PCONEWPOSITION")
     AND bnv.br_name=outerjoin("CVFROMCS88")
     AND bnv.br_value=outerjoin(cnvtstring(bpcc.position_cd)))
   ORDER BY bpcc.position_cd
   HEAD REPORT
    stat = alterlist(temp->rlist,50), tot_count = 0, count = 0,
    rescnt = 0
   HEAD bpcc.position_cd
    IF (cv.display_key="YEAR*1*RESIDENT"
     AND (request->step_mean="PCOWHOWORKS"))
     rescnt = 1, reply->reslist[rescnt].res_code_value = cv.code_value, reply->reslist[rescnt].
     res_display = cv.display
    ELSEIF (cv.display_key="YEAR*2*RESIDENT"
     AND (request->step_mean="PCOWHOWORKS"))
     rescnt = 2, reply->reslist[rescnt].res_code_value = cv.code_value, reply->reslist[rescnt].
     res_display = cv.display
    ELSEIF (cv.display_key="YEAR*3*RESIDENT"
     AND (request->step_mean="PCOWHOWORKS"))
     rescnt = 3, reply->reslist[rescnt].res_code_value = cv.code_value, reply->reslist[rescnt].
     res_display = cv.display
    ELSEIF (cv.display_key="YEAR*4*RESIDENT"
     AND (request->step_mean="PCOWHOWORKS"))
     rescnt = 4, reply->reslist[rescnt].res_code_value = cv.code_value, reply->reslist[rescnt].
     res_display = cv.display
    ELSEIF (cv.display_key="YEAR*5*RESIDENT"
     AND (request->step_mean="PCOWHOWORKS"))
     rescnt = 5, reply->reslist[rescnt].res_code_value = cv.code_value, reply->reslist[rescnt].
     res_display = cv.display
    ELSE
     tot_count = (tot_count+ 1), count = (count+ 1)
     IF (count > 50)
      stat = alterlist(temp->rlist,(tot_count+ 50)), count = 1
     ENDIF
     temp->rlist[tot_count].step_cat_mean = bpc.step_cat_mean, temp->rlist[tot_count].
     position_code_value = bpcc.position_cd, temp->rlist[tot_count].display = cv.display,
     temp->rlist[tot_count].desc = cv.description, temp->rlist[tot_count].hnam_physician_ind = bpcc
     .physician_ind
     IF (trim(cv.display_key)="RESIDENT")
      temp->rlist[tot_count].resident_ind = 1
     ELSEIF (trim(cv.display_key)="PHYSICIAN")
      temp->rlist[tot_count].physician_ind = 1
     ELSEIF (trim(cv.display_key)="PHYSICIANOFFICECLINICONLY")
      temp->rlist[tot_count].physoffice_ind = 1
     ELSEIF (trim(cv.display_key)="NURSEPRACTITIONER")
      temp->rlist[tot_count].nursepract_ind = 1
     ELSEIF (trim(cv.display_key)="PHYSICIANASSISTANT")
      temp->rlist[tot_count].physassist_ind = 1
     ENDIF
     IF (bnv.br_name_value_id > 0)
      temp->rlist[tot_count].newposition_ind = 1
     ENDIF
     IF (lt.long_text_id > 0)
      temp->rlist[tot_count].long_desc = lt.long_text
     ELSE
      temp->rlist[tot_count].long_desc = "Description not available."
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(temp->rlist,tot_count)
  SET stat = alterlist(reply->rlist,tot_count)
  GO TO enditnow
 ELSE
  SET mcnt = size(request->mlist,5)
 ENDIF
 IF (mcnt > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = mcnt),
    br_position_category bpc,
    br_position_cat_comp bpcc,
    code_value cv,
    br_long_text lt,
    br_name_value bnv
   PLAN (d)
    JOIN (bpc
    WHERE bpc.active_ind=1
     AND bpc.step_cat_mean=trim(request->mlist[d.seq].step_cat_mean))
    JOIN (bpcc
    WHERE bpcc.category_id=bpc.category_id)
    JOIN (cv
    WHERE cv.code_set=88
     AND cv.active_ind=1
     AND cv.code_value=bpcc.position_cd)
    JOIN (lt
    WHERE lt.parent_entity_name=outerjoin("CODE_VALUE")
     AND lt.parent_entity_id=outerjoin(bpcc.position_cd))
    JOIN (bnv
    WHERE bnv.br_nv_key1=outerjoin("PCONEWPOSITION")
     AND bnv.br_name=outerjoin("CVFROMCS88")
     AND bnv.br_value=outerjoin(cnvtstring(bpcc.position_cd)))
   ORDER BY bpc.step_cat_mean, bpc.description
   HEAD REPORT
    tot_count = 0, count = 0, stat = alterlist(temp->rlist,50)
   HEAD bpcc.position_cd
    IF (cv.display_key="YEAR*1*RESIDENT"
     AND (request->step_mean="PCOWHOWORKS"))
     rescnt = 1, reply->reslist[rescnt].res_code_value = cv.code_value, reply->reslist[rescnt].
     res_display = cv.display
    ELSEIF (cv.display_key="YEAR*2*RESIDENT"
     AND (request->step_mean="PCOWHOWORKS"))
     rescnt = 2, reply->reslist[rescnt].res_code_value = cv.code_value, reply->reslist[rescnt].
     res_display = cv.display
    ELSEIF (cv.display_key="YEAR*3*RESIDENT"
     AND (request->step_mean="PCOWHOWORKS"))
     rescnt = 3, reply->reslist[rescnt].res_code_value = cv.code_value, reply->reslist[rescnt].
     res_display = cv.display
    ELSEIF (cv.display_key="YEAR*4*RESIDENT"
     AND (request->step_mean="PCOWHOWORKS"))
     rescnt = 4, reply->reslist[rescnt].res_code_value = cv.code_value, reply->reslist[rescnt].
     res_display = cv.display
    ELSEIF (cv.display_key="YEAR*5*RESIDENT"
     AND (request->step_mean="PCOWHOWORKS"))
     rescnt = 5, reply->reslist[rescnt].res_code_value = cv.code_value, reply->reslist[rescnt].
     res_display = cv.display
    ELSE
     tot_count = (tot_count+ 1), count = (count+ 1)
     IF (count > 50)
      stat = alterlist(temp->rlist,(tot_count+ 50)), count = 1
     ENDIF
     temp->rlist[tot_count].step_cat_mean = bpc.step_cat_mean, temp->rlist[tot_count].category_id =
     bpc.category_id, temp->rlist[tot_count].position_code_value = bpcc.position_cd,
     temp->rlist[tot_count].display = cv.display, temp->rlist[tot_count].desc = cv.description, temp
     ->rlist[tot_count].hnam_physician_ind = bpcc.physician_ind
     IF (trim(cv.display_key)="RESIDENT")
      temp->rlist[tot_count].resident_ind = 1
     ELSEIF (trim(cv.display_key)="PHYSICIAN")
      temp->rlist[tot_count].physician_ind = 1
     ELSEIF (trim(cv.display_key)="PHYSICIANOFFICECLINICONLY")
      temp->rlist[tot_count].physoffice_ind = 1
     ELSEIF (trim(cv.display_key)="NURSEPRACTITIONER")
      temp->rlist[tot_count].nursepract_ind = 1
     ELSEIF (trim(cv.display_key)="PHYSICIANASSISTANT")
      temp->rlist[tot_count].physassist_ind = 1
     ENDIF
     IF (bnv.br_name_value_id > 0)
      temp->rlist[tot_count].newposition_ind = 1
     ENDIF
     IF (lt.long_text_id > 0)
      temp->rlist[tot_count].long_desc = lt.long_text
     ELSE
      temp->rlist[tot_count].long_desc = "Description not available."
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(temp->rlist,tot_count)
  SET stat = alterlist(reply->rlist,tot_count)
  GO TO enditnow
 ENDIF
#enditnow
 FOR (x = 1 TO tot_count)
   IF ((temp->rlist[x].step_cat_mean="PCO"))
    IF ((temp->rlist[x].position_code_value=634808))
     SET temp->rlist[x].display_seq = 1
    ELSEIF ((temp->rlist[x].position_code_value=634809))
     SET temp->rlist[x].display_seq = 2
    ELSEIF ((temp->rlist[x].position_code_value=455))
     SET temp->rlist[x].display_seq = 3
    ELSEIF ((temp->rlist[x].position_code_value=452))
     SET temp->rlist[x].display_seq = 9
    ELSEIF ((temp->rlist[x].position_code_value=644372))
     SET temp->rlist[x].display_seq = 10
    ELSEIF ((temp->rlist[x].position_code_value=637903))
     SET temp->rlist[x].display_seq = 11
    ELSEIF ((temp->rlist[x].position_code_value=681027))
     SET temp->rlist[x].display_seq = 12
    ELSEIF ((temp->rlist[x].position_code_value=681028))
     SET temp->rlist[x].display_seq = 13
    ELSEIF ((temp->rlist[x].position_code_value=637904))
     SET temp->rlist[x].display_seq = 14
    ELSEIF ((temp->rlist[x].position_code_value=644508))
     SET temp->rlist[x].display_seq = 15
    ELSEIF ((temp->rlist[x].position_code_value=637901))
     SET temp->rlist[x].display_seq = 16
    ELSEIF ((temp->rlist[x].position_code_value=637902))
     SET temp->rlist[x].display_seq = 17
    ELSEIF ((temp->rlist[x].position_code_value=681273))
     SET temp->rlist[x].display_seq = 18
    ELSEIF ((temp->rlist[x].position_code_value=644373))
     SET temp->rlist[x].display_seq = 19
    ELSEIF ((temp->rlist[x].position_code_value=644374))
     SET temp->rlist[x].display_seq = 20
    ELSEIF ((temp->rlist[x].position_code_value=637550))
     SET temp->rlist[x].display_seq = 21
    ELSE
     SET temp->rlist[x].display_seq = 100
    ENDIF
    SELECT INTO "nl:"
     FROM br_name_value bnv
     PLAN (bnv
      WHERE bnv.br_nv_key1="REVIEWED"
       AND (bnv.br_name=request->step_mean)
       AND bnv.br_value=cnvtstring(temp->rlist[x].position_code_value))
     DETAIL
      temp->rlist[x].reviewed_ind = 1
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->rlist,tot_count)
 IF (tot_count > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_count)
   PLAN (d)
   ORDER BY temp->rlist[d.seq].step_cat_mean, temp->rlist[d.seq].display_seq, cnvtupper(temp->rlist[d
     .seq].display)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), reply->rlist[cnt].step_cat_mean = temp->rlist[d.seq].step_cat_mean, reply->rlist[
    cnt].position_code_value = temp->rlist[d.seq].position_code_value,
    reply->rlist[cnt].display = temp->rlist[d.seq].display, reply->rlist[cnt].display_seq = temp->
    rlist[d.seq].display_seq, reply->rlist[cnt].desc = temp->rlist[d.seq].desc,
    reply->rlist[cnt].long_desc = temp->rlist[d.seq].long_desc, reply->rlist[cnt].resident_ind = temp
    ->rlist[d.seq].resident_ind, reply->rlist[cnt].physician_ind = temp->rlist[d.seq].physician_ind,
    reply->rlist[cnt].physoffice_ind = temp->rlist[d.seq].physoffice_ind, reply->rlist[cnt].
    physassist_ind = temp->rlist[d.seq].physassist_ind, reply->rlist[cnt].physassist_rx_flag = 0,
    reply->rlist[cnt].physassist_chg_flag = 0, reply->rlist[cnt].nursepract_ind = temp->rlist[d.seq].
    nursepract_ind, reply->rlist[cnt].nursepract_rx_flag = 0,
    reply->rlist[cnt].nursepract_chg_flag = 0, reply->rlist[cnt].newposition_ind = temp->rlist[d.seq]
    .newposition_ind, reply->rlist[cnt].newposition_rx_flag = 0,
    reply->rlist[cnt].newposition_chg_flag = 0, reply->rlist[cnt].default_selected_ind = temp->rlist[
    d.seq].default_selected_ind, reply->rlist[cnt].reviewed_ind = temp->rlist[d.seq].reviewed_ind,
    reply->rlist[cnt].hnam_physician_ind = temp->rlist[d.seq].hnam_physician_ind
   WITH nocounter
  ;end select
 ENDIF
 IF (tot_count > 0
  AND (request->personnel_count_ind=1))
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
  FOR (r = 1 TO tot_count)
    SET pcnt = 0
    SELECT INTO "NL:"
     FROM prsnl p
     WHERE (p.position_cd=reply->rlist[r].position_code_value)
      AND p.data_status_cd=auth_cd
      AND parser(prsnl_parse)
     DETAIL
      pcnt = (pcnt+ 1)
     WITH nocounter
    ;end select
    SET reply->rlist[r].personnel_count = pcnt
  ENDFOR
 ENDIF
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_count),
    br_name_value bnv
   PLAN (d
    WHERE (reply->rlist[d.seq].position_code_value > 0)
     AND (reply->rlist[d.seq].step_cat_mean="PCO"))
    JOIN (bnv
    WHERE bnv.br_nv_key1=concat(reply->rlist[d.seq].step_cat_mean,"PSNSELECTED")
     AND bnv.br_name="CVFROMCS88"
     AND bnv.br_value=cnvtstring(reply->rlist[d.seq].position_code_value))
   DETAIL
    reply->rlist[d.seq].default_selected_ind = 1
    IF ((reply->rlist[d.seq].physassist_ind=1))
     physassist_code_value = reply->rlist[d.seq].position_code_value, physassist_idx = d.seq
    ELSEIF ((reply->rlist[d.seq].nursepract_ind=1))
     nursepract_code_value = reply->rlist[d.seq].position_code_value, nursepract_idx = d.seq
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  GO TO exit_script
 ENDIF
 IF ((request->step_mean="PCOWHOWORKS")
  AND rescnt > 0)
  SET reply->status_data.status = "S"
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = 5),
    br_name_value bnv
   PLAN (d
    WHERE (reply->reslist[d.seq].res_code_value > 0))
    JOIN (bnv
    WHERE bnv.br_nv_key1="PCOPSNSELECTED"
     AND bnv.br_name="CVFROMCS88"
     AND bnv.br_value=cnvtstring(reply->reslist[d.seq].res_code_value))
   DETAIL
    reply->reslist[d.seq].default_selected_ind = 1
   WITH nocounter
  ;end select
  IF ((request->step_mean > " "))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = 5),
     br_name_value bnv
    PLAN (d)
     JOIN (bnv
     WHERE bnv.br_nv_key1="REVIEWED"
      AND (bnv.br_name=request->step_mean)
      AND bnv.br_value=cnvtstring(reply->reslist[d.seq].res_code_value))
    DETAIL
     reply->reslist[d.seq].reviewed_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((request->step_mean != "PCOSECURITY"))
  GO TO exit_script
 ENDIF
 SET newposition_cnt = 0
 FOR (n = 1 TO tot_count)
   IF ((reply->rlist[n].newposition_ind=1))
    SET newposition_cnt = 1
    SET n = (tot_count+ 1)
   ENDIF
 ENDFOR
 IF (physassist_code_value=0
  AND nursepract_code_value=0
  AND newposition_cnt=0)
  GO TO exit_script
 ENDIF
 SET easyscript_ind = 0
 SET superbill_ind = 0
 SET medadmin_ind = 0
 SET immadmin_ind = 0
 SET cosign_ind = 0
 SET chartprep_ind = 0
 SET phonemsg_ind = 0
 SET medrefill_ind = 0
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="AUTOPROCESSES"
    AND bnv.br_name IN ("EASYSCRIPT", "SUPERBILL", "MEDADMIN", "IMMADMIN", "COSIGN",
   "CHARTPREP", "PHONEMSG", "MEDREFILL"))
  DETAIL
   IF (bnv.br_name="EASYSCRIPT"
    AND cnvtint(bnv.br_value)=1)
    easyscript_ind = 1
   ELSEIF (bnv.br_name="SUPERBILL"
    AND cnvtint(bnv.br_value)=1)
    superbill_ind = 1
   ELSEIF (bnv.br_name="MEDADMIN"
    AND cnvtint(bnv.br_value)=1)
    medadmin_ind = 1
   ELSEIF (bnv.br_name="IMMADMIN"
    AND cnvtint(bnv.br_value)=1)
    immadmin_ind = 1
   ELSEIF (bnv.br_name="COSIGN"
    AND cnvtint(bnv.br_value)=1)
    cosign_ind = 1
   ELSEIF (bnv.br_name="CHARTPREP"
    AND cnvtint(bnv.br_value)=1)
    chartprep_ind = 1
   ELSEIF (bnv.br_name="PHONEMSG"
    AND cnvtint(bnv.br_value)=1)
    phonemsg_ind = 1
   ELSEIF (bnv.br_name="MEDREFILL"
    AND cnvtint(bnv.br_value)=1)
    medrefill_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (easyscript_ind=0
  AND superbill_ind=0
  AND medadmin_ind=0
  AND immadmin_ind=0
  AND cosign_ind=0
  AND chartprep_ind=0
  AND phonemsg_ind=0
  AND medrefill_ind=0)
  SET process_cnt = 0
  SELECT INTO "nl:"
   FROM br_name_value bnv
   WHERE bnv.br_nv_key1="AUTOPROCESSES"
   DETAIL
    process_cnt = (process_cnt+ 1)
   WITH nocounter
  ;end select
  IF (process_cnt=0)
   SET easyscript_ind = 1
   SET superbill_ind = 1
   SET medadmin_ind = 1
   SET immadmin_ind = 1
   SET cosign_ind = 1
   SET chartprep_ind = 1
   SET phonemsg_ind = 1
   SET medrefill_ind = 1
  ENDIF
 ENDIF
 IF (easyscript_ind=0
  AND superbill_ind=0
  AND medadmin_ind=0
  AND immadmin_ind=0
  AND cosign_ind=0
  AND chartprep_ind=0
  AND phonemsg_ind=0
  AND medrefill_ind=0)
  GO TO exit_script
 ENDIF
 IF (easyscript_ind=0
  AND chartprep_ind=0
  AND phonemsg_ind=0
  AND medrefill_ind=0
  AND cosign_ind=0)
  GO TO superbill
 ENDIF
 SET no_cd = 0.0
 SET yes_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6017
    AND c.cdf_meaning IN ("YES", "NO"))
  DETAIL
   IF (c.cdf_meaning="YES")
    yes_cd = c.code_value
   ELSE
    no_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET rxphysproxy_cd = 0.0
 SET mlskipcosign_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6016
    AND c.cdf_meaning IN ("RXPHYSPROXY", "MLSKIPCOSIGN"))
  DETAIL
   IF (c.cdf_meaning="RXPHYSPROXY")
    rxphysproxy_cd = c.code_value
   ELSE
    mlskipcosign_cd = c.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (physassist_code_value > 0)
  SET plr_id = 0.0
  SELECT INTO "nl:"
   FROM priv_loc_reltn plr
   PLAN (plr
    WHERE plr.position_cd=physassist_code_value
     AND plr.person_id=0
     AND plr.ppr_cd=0
     AND plr.location_cd=0)
   DETAIL
    plr_id = plr.priv_loc_reltn_id
   WITH nocounter
  ;end select
  SET rxphysproxy_priv_value = no_cd
  SET mlskipcosign_priv_value = yes_cd
  IF (plr_id > 0)
   SELECT INTO "nl:"
    FROM privilege p
    PLAN (p
     WHERE p.priv_loc_reltn_id=plr_id
      AND p.privilege_cd IN (rxphysproxy_cd, mlskipcosign_cd))
    DETAIL
     IF (p.privilege_cd=rxphysproxy_cd)
      rxphysproxy_priv_value = p.priv_value_cd
     ELSE
      mlskipcosign_priv_value = p.priv_value_cd
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF (rxphysproxy_priv_value=yes_cd)
   IF (mlskipcosign_priv_value=yes_cd)
    SET reply->rlist[physassist_idx].physassist_rx_flag = 2
   ELSE
    SET reply->rlist[physassist_idx].physassist_rx_flag = 3
   ENDIF
  ELSE
   SELECT INTO "nl:"
    FROM br_position_cat_comp bpcc
    PLAN (bpcc
     WHERE bpcc.position_cd=physassist_code_value)
    DETAIL
     IF (bpcc.physician_ind=1)
      reply->rlist[physassist_idx].physassist_rx_flag = 1
     ELSE
      reply->rlist[physassist_idx].physassist_rx_flag = 4
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (nursepract_code_value > 0)
  SET plr_id = 0.0
  SELECT INTO "nl:"
   FROM priv_loc_reltn plr
   PLAN (plr
    WHERE plr.position_cd=nursepract_code_value
     AND plr.person_id=0
     AND plr.ppr_cd=0
     AND plr.location_cd=0)
   DETAIL
    plr_id = plr.priv_loc_reltn_id
   WITH nocounter
  ;end select
  SET rxphysproxy_priv_value = no_cd
  SET mlskipcosign_priv_value = yes_cd
  IF (plr_id > 0)
   SELECT INTO "nl:"
    FROM privilege p
    PLAN (p
     WHERE p.priv_loc_reltn_id=plr_id
      AND p.privilege_cd IN (rxphysproxy_cd, mlskipcosign_cd))
    DETAIL
     IF (p.privilege_cd=rxphysproxy_cd)
      rxphysproxy_priv_value = p.priv_value_cd
     ELSE
      mlskipcosign_priv_value = p.priv_value_cd
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  IF (rxphysproxy_priv_value=yes_cd)
   IF (mlskipcosign_priv_value=yes_cd)
    SET reply->rlist[nursepract_idx].nursepract_rx_flag = 2
   ELSE
    SET reply->rlist[nursepract_idx].nursepract_rx_flag = 3
   ENDIF
  ELSE
   SELECT INTO "nl:"
    FROM br_position_cat_comp bpcc
    PLAN (bpcc
     WHERE bpcc.position_cd=nursepract_code_value)
    DETAIL
     IF (bpcc.physician_ind=1)
      reply->rlist[nursepract_idx].nursepract_rx_flag = 1
     ELSE
      reply->rlist[nursepract_idx].nursepract_rx_flag = 4
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 FOR (n = 1 TO tot_count)
   IF ((reply->rlist[n].newposition_ind=1))
    SET plr_id = 0.0
    SELECT INTO "nl:"
     FROM priv_loc_reltn plr
     PLAN (plr
      WHERE (plr.position_cd=reply->rlist[n].position_code_value)
       AND plr.person_id=0
       AND plr.ppr_cd=0
       AND plr.location_cd=0)
     DETAIL
      plr_id = plr.priv_loc_reltn_id
     WITH nocounter
    ;end select
    SET rxphysproxy_priv_value = no_cd
    SET mlskipcosign_priv_value = yes_cd
    IF (plr_id > 0)
     SELECT INTO "nl:"
      FROM privilege p
      PLAN (p
       WHERE p.priv_loc_reltn_id=plr_id
        AND p.privilege_cd IN (rxphysproxy_cd, mlskipcosign_cd))
      DETAIL
       IF (p.privilege_cd=rxphysproxy_cd)
        rxphysproxy_priv_value = p.priv_value_cd
       ELSE
        mlskipcosign_priv_value = p.priv_value_cd
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
    IF (rxphysproxy_priv_value=yes_cd)
     IF (mlskipcosign_priv_value=yes_cd)
      SET reply->rlist[n].newposition_rx_flag = 2
     ELSE
      SET reply->rlist[n].newposition_rx_flag = 3
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM br_position_cat_comp bpcc
      PLAN (bpcc
       WHERE (bpcc.position_cd=reply->rlist[n].position_code_value))
      DETAIL
       IF (bpcc.physician_ind=1)
        reply->rlist[n].newposition_rx_flag = 1
       ELSE
        reply->rlist[n].newposition_rx_flag = 4
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 ENDFOR
#superbill
 IF (superbill_ind=0
  AND medadmin_ind=0
  AND immadmin_ind=0
  AND cosign_ind=0)
  GO TO exit_script
 ENDIF
 IF (physassist_code_value > 0)
  SELECT INTO "nl:"
   FROM br_position_cat_comp bpcc
   PLAN (bpcc
    WHERE bpcc.position_cd=physassist_code_value)
   DETAIL
    IF (bpcc.physician_ind=1)
     reply->rlist[physassist_idx].physassist_chg_flag = 1
    ELSE
     reply->rlist[physassist_idx].physassist_chg_flag = 2
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (nursepract_code_value > 0)
  SELECT INTO "nl:"
   FROM br_position_cat_comp bpcc
   PLAN (bpcc
    WHERE bpcc.position_cd=nursepract_code_value)
   DETAIL
    IF (bpcc.physician_ind=1)
     reply->rlist[nursepract_idx].nursepract_chg_flag = 1
    ELSE
     reply->rlist[nursepract_idx].nursepract_chg_flag = 2
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FOR (n = 1 TO tot_count)
   IF ((reply->rlist[n].newposition_ind=1))
    SELECT INTO "nl:"
     FROM br_position_cat_comp bpcc
     PLAN (bpcc
      WHERE (bpcc.position_cd=reply->rlist[n].position_code_value))
     DETAIL
      IF (bpcc.physician_ind=1)
       reply->rlist[n].newposition_chg_flag = 1
      ELSE
       reply->rlist[n].newposition_chg_flag = 2
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
