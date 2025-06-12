CREATE PROGRAM cds_load_eal:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Please Select a Trust for EAL Load" = ""
  WITH outdev, trust
 SET last_mod = "145493"
 FREE RECORD cds
 RECORD cds(
   1 activity[*]
     2 update_type = i2
     2 cds_batch_content_id = f8
     2 cds_batch_cnt_hist_id = f8
     2 cds_batch_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = c30
     2 encntr_id = f8
     2 cds_type_cd = f8
     2 cds_row_error_ind = i2
     2 provider_org_id = f8
     2 encntr_org_id = f8
     2 update_del_flag = i2
     2 activity_dt_tm = dq8
 )
 FREE RECORD encntr_types
 RECORD encntr_types(
   1 eal[*]
     2 episode_type_cd = f8
   1 eal_cnt = i4
 )
 DECLARE ce_slice_type = f8 WITH public, noconstant(uar_get_code_by("MEANING",401571,"CONSULT_EP"))
 DECLARE update_dt_tm = q8 WITH public, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE null_dt_tm = q8 WITH public, noconstant(cnvtdatetime("31-DEC-2100"))
 DECLARE nhs_trust_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",278,"NHSTRUST"))
 DECLARE nhs_trust_child_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",369,"NHSTRUSTCHLD"
   ))
 DECLARE maternity_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MATERNITY"))
 DECLARE newborn_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"NEWBORN"))
 DECLARE psych_ip_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "PSYCHIATRICINPATIENT"))
 DECLARE reg_day_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "REGULARDAYADMISSION"))
 DECLARE reg_night_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "REGULARNIGHTADMISSION"))
 DECLARE mortuary_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"MORTUARY"))
 DECLARE daycare_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"DAYCARE"))
 DECLARE direct_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"DIRECTREFERRAL"))
 DECLARE ed_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCYDEPARTMENT"))
 DECLARE ip_preadmit_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "INPATIENTPREADMISSION"))
 DECLARE op_prereg_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTPREREGISTRATION"))
 DECLARE daycase_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"DAYCASE"))
 DECLARE daycase_wl_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "DAYCASEWAITINGLIST"))
 DECLARE ip_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE ip_wl_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "INPATIENTWAITINGLIST"))
 DECLARE op_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT"))
 DECLARE op_referral_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "OUTPATIENTREFERRAL"))
 DECLARE community_ahp_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "COMMUNITYAHP"))
 DECLARE mentalhealth_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "MENTALHEALTH"))
 DECLARE psych_op_type = f8 WITH public, noconstant(uar_get_code_by("DISPLAYKEY",71,
   "PSYCHIATRICOUTPATIENT"))
 DECLARE offer_date = q8 WITH public, noconstant(uar_get_code_by("MEANING",356,"OFFERMADEDAT"))
 DECLARE suspend_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",14778,"SUSPEND"))
 DECLARE appt_confirmed = f8 WITH public, noconstant(uar_get_code_by("MEANING",14233,"CONFIRMED"))
 DECLARE appt_hold = f8 WITH public, noconstant(uar_get_code_by("MEANING",14233,"HOLD"))
 DECLARE appt_resched = f8 WITH public, noconstant(uar_get_code_by("MEANING",14233,"RESCHEDULED"))
 DECLARE appt_cancelled = f8 WITH public, noconstant(uar_get_code_by("MEANING",14233,"CANCELLED"))
 IF (appt_cancelled < 1)
  SET appt_cancelled = uar_get_code_by("MEANING",14233,"CANCELED")
 ENDIF
 DECLARE nhs_trace = f8 WITH public, noconstant(uar_get_code_by("MEANING",30700,"NHS_TRACE"))
 DECLARE patient = f8 WITH public, noconstant(uar_get_code_by("MEANING",14250,"PATIENT"))
 DECLARE cds_010 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"010"))
 DECLARE cds_020 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"020"))
 DECLARE cds_030 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"030"))
 DECLARE cds_040 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"040"))
 DECLARE cds_050 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"050"))
 DECLARE cds_060 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"060"))
 DECLARE cds_070 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"070"))
 DECLARE cds_080 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"080"))
 DECLARE cds_090 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"090"))
 DECLARE cds_100 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"100"))
 DECLARE cds_110 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"110"))
 DECLARE cds_120 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"120"))
 DECLARE cds_130 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"130"))
 DECLARE cds_140 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"140"))
 DECLARE cds_150 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"150"))
 DECLARE cds_160 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"160"))
 DECLARE cds_170 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"170"))
 DECLARE cds_180 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"180"))
 DECLARE cds_190 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"190"))
 DECLARE cds_200 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"200"))
 DECLARE cds_210 = f8 WITH public, noconstant(uar_get_code_by("MEANING",4001897,"210"))
 DECLARE start = i4 WITH noconstant(1), public
 DECLARE trust = f8 WITH public, noconstant(0.0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE trust_rel_code = f8 WITH public, constant(uar_get_code_by("MEANING",369,"NHSTRUSTCHLD"))
 DECLARE cdstype_eal = f8 WITH public, constant(uar_get_code_by("MEANING",4001896,"EAL"))
 SELECT INTO "nl:"
  FROM code_value_group cvg
  PLAN (cvg
   WHERE cvg.parent_code_value=cdstype_eal
    AND ((cvg.code_set+ 0)=71))
  HEAD REPORT
   eal_cnt = 0, stat = alterlist(encntr_types->eal,10)
  DETAIL
   eal_cnt = (eal_cnt+ 1)
   IF (mod(eal_cnt,10)=1)
    stat = alterlist(encntr_types->eal,(eal_cnt+ 9))
   ENDIF
   encntr_types->eal[eal_cnt].episode_type_cd = cvg.child_code_value
  FOOT REPORT
   stat = alterlist(encntr_types->eal,eal_cnt), encntr_types->eal_cnt = eal_cnt
  WITH nocounter
 ;end select
 IF ((encntr_types->eal_cnt=0))
  SET encntr_types->eal_cnt = 4
  SET stat = alterlist(encntr_types->eal,encntr_types->eal_cnt)
  SET encntr_types->eal[1].episode_type_cd = ip_wl_type
  SET encntr_types->eal[2].episode_type_cd = daycase_wl_type
  SET encntr_types->eal[3].episode_type_cd = daycase_type
  SET encntr_types->eal[4].episode_type_cd = ip_type
 ENDIF
 SET trust =  $TRUST
 IF (trust=0)
  SELECT INTO  $OUTDEV
   FROM (dummyt  WITH seq = 1)
   DETAIL
    col 5, "Error: No Trust selected"
   WITH nocounter, maxcol = 500
  ;end select
  GO TO cds_load_eal_exit
 ENDIF
 SELECT INTO "nl:"
  FROM pm_wait_list pwl,
   encounter e,
   person p,
   cds_batch_content cbc,
   cds_batch cb
  PLAN (e
   WHERE expand(idx,1,encntr_types->eal_cnt,e.encntr_type_cd,encntr_types->eal[idx].episode_type_cd)
    AND ((e.organization_id=trust) OR (e.organization_id IN (
   (SELECT
    oor.related_org_id
    FROM org_org_reltn oor
    WHERE oor.organization_id=trust
     AND ((oor.org_org_reltn_cd+ 0)=trust_rel_code))))) )
   JOIN (pwl
   WHERE pwl.encntr_id=e.encntr_id
    AND pwl.waiting_end_dt_tm = null)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND  NOT (p.name_last_key="ZZZ*"))
   JOIN (cbc
   WHERE cbc.encntr_id=outerjoin(e.encntr_id))
   JOIN (cb
   WHERE cb.cds_batch_id=outerjoin(cbc.cds_batch_id))
  ORDER BY pwl.pm_wait_list_id, 0
  HEAD REPORT
   cnt = 0, stat = alterlist(cds->activity,2000)
  HEAD pwl.pm_wait_list_id
   cnt = (cnt+ 1)
   IF (cnt > size(cds->activity,5))
    stat = alterlist(cds->activity,(cnt+ 499))
   ENDIF
   IF (e.encntr_type_cd=op_referral_type)
    cds->activity[cnt].cds_type_cd = cds_020, cds->activity[cnt].activity_dt_tm = pwl
    .adj_waiting_start_dt_tm
   ELSE
    cds->activity[cnt].cds_type_cd = cds_060, cds->activity[cnt].activity_dt_tm = pwl
    .admit_decision_dt_tm
   ENDIF
   cds->activity[cnt].cds_batch_content_id = cbc.cds_batch_content_id, cds->activity[cnt].
   cds_batch_id = cbc.cds_batch_id, cds->activity[cnt].parent_entity_id = pwl.pm_wait_list_id,
   cds->activity[cnt].parent_entity_name = "PM_WAIT_LIST", cds->activity[cnt].encntr_org_id = e
   .organization_id, cds->activity[cnt].encntr_id = e.encntr_id
   IF (e.active_ind=0)
    cds->activity[cnt].update_del_flag = 1
   ELSE
    cds->activity[cnt].update_del_flag = 9
   ENDIF
  FOOT REPORT
   stat = alterlist(cds->activity,cnt)
  WITH nocounter
 ;end select
 CALL echo(build("Size->",size(cds->activity,5)))
 IF (size(cds->activity,5) > 0)
  CALL echo("Getting Provider Organisation ID")
  SELECT INTO "nl:"
   decode_table = decode(otr.seq,"otr",oor.seq,"oor","zzz")
   FROM (dummyt d  WITH seq = value(size(cds->activity,5))),
    dummyt d1,
    dummyt d2,
    org_type_reltn otr,
    org_type_reltn otr2,
    org_org_reltn oor
   PLAN (d)
    JOIN (((d1)
    JOIN (otr
    WHERE (otr.organization_id=cds->activity[d.seq].encntr_org_id)
     AND otr.org_type_cd=nhs_trust_cd
     AND otr.active_ind=1
     AND otr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND otr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    ) ORJOIN ((d2)
    JOIN (oor
    WHERE (oor.related_org_id=cds->activity[d.seq].encntr_org_id)
     AND oor.org_org_reltn_cd=nhs_trust_child_cd
     AND ((oor.active_ind+ 0)=1)
     AND oor.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND oor.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (otr2
    WHERE otr2.organization_id=oor.organization_id
     AND otr2.org_type_cd=nhs_trust_cd
     AND otr2.active_ind=1
     AND otr2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND otr2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    ))
   DETAIL
    IF (decode_table="otr")
     cds->activity[d.seq].provider_org_id = otr.organization_id
    ELSEIF (decode_table="oor")
     cds->activity[d.seq].provider_org_id = otr2.organization_id
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(cds->activity,5)))
   DETAIL
    IF ((cds->activity[d.seq].activity_dt_tm=0))
     cds->activity[d.seq].activity_dt_tm = cnvtdatetime(curdate,curtime3)
    ENDIF
   WITH nocounter
  ;end select
  DECLARE cds_size = i4 WITH protect, noconstant(size(cds->activity,5))
  DECLARE updt_type1_cnt = i4 WITH protect, noconstant(0)
  DECLARE loc_idx = i4 WITH protect, noconstant(0)
  DECLARE bcds = i4 WITH protect, noconstant(0)
  SET bcds = locateval(loc_idx,1,cds_size,0.0,cds->activity[loc_idx].provider_org_id)
  WHILE (bcds > 0)
    SET cds->activity[bcds].provider_org_id = cds->activity[bcds].encntr_org_id
    SET cds->activity[bcds].cds_row_error_ind = 1
    SET bcds = locateval(loc_idx,(bcds+ 1),cds_size,0.0,cds->activity[loc_idx].provider_org_id)
  ENDWHILE
  FOR (bcds = 1 TO cds_size)
    IF ((cds->activity[bcds].cds_batch_content_id=0))
     SET cds->activity[bcds].update_type = 1
     SET updt_type1_cnt = (updt_type1_cnt+ 1)
    ELSE
     IF ((cds->activity[bcds].cds_batch_id=0))
      SET cds->activity[bcds].update_type = 2
     ELSE
      SET cds->activity[bcds].update_type = 3
      SET cds->activity[bcds].cds_batch_id = 0
     ENDIF
    ENDIF
  ENDFOR
  IF (updt_type1_cnt > 0)
   IF (updt_type1_cnt < 500)
    SELECT INTO "nl:"
     y = seq(cds_batch_content_seq,nextval)
     FROM code_value c
     HEAD REPORT
      idx = 0, loc = 0
     DETAIL
      idx = locateval(loc,(idx+ 1),cds_size,0.0,cds->activity[loc].cds_batch_content_id)
      IF (idx > 0)
       cds->activity[idx].cds_batch_content_id = cnvtreal(y)
      ENDIF
     WITH nocounter, maxqual(c,value(updt_type1_cnt))
    ;end select
   ELSE
    DECLARE padded_size = i4 WITH protect, noconstant((ceil((cnvtreal(updt_type1_cnt)/ 500)) * 500))
    DECLARE num_seqs = i4 WITH protect, noconstant(0)
    FOR (bcds = 1 TO (padded_size/ 500))
     IF (((((bcds - 1) * 500)+ 500) > updt_type1_cnt))
      SET num_seqs = (updt_type1_cnt - ((bcds - 1) * 500))
     ELSE
      SET num_seqs = 500
     ENDIF
     CALL parser(concat("select into 'nl:' ","    y = seq(cds_batch_content_seq, nextval) ",
       "from code_value c ","head report ","    idx = 0 ",
       "    loc = 0 ","detail ",
       "    idx = locateval(loc, idx + 1, cds_size, 0.0, cds->activity[loc].cds_batch_content_id) ",
       "    if (idx > 0) ","        cds->activity[idx].cds_batch_content_id = cnvtreal(y) ",
       "    endif ","with nocounter, maxqual(c, ",cnvtstring(num_seqs),") go"))
    ENDFOR
   ENDIF
  ENDIF
  INSERT  FROM cds_batch_content cbc,
    (dummyt d  WITH seq = value(cds_size))
   SET cbc.cds_batch_content_id = cds->activity[d.seq].cds_batch_content_id, cbc.cds_batch_id = cds->
    activity[d.seq].cds_batch_id, cbc.parent_entity_id = cds->activity[d.seq].parent_entity_id,
    cbc.parent_entity_name = cds->activity[d.seq].parent_entity_name, cbc.cds_type_cd = cds->
    activity[d.seq].cds_type_cd, cbc.cds_row_error_ind = cds->activity[d.seq].cds_row_error_ind,
    cbc.organization_id = cds->activity[d.seq].provider_org_id, cbc.update_del_flag = cds->activity[d
    .seq].update_del_flag, cbc.encntr_id = cds->activity[d.seq].encntr_id,
    cbc.updt_dt_tm = cnvtdatetime(update_dt_tm), cbc.activity_dt_tm = cnvtdatetime(cds->activity[d
     .seq].activity_dt_tm)
   PLAN (d
    WHERE (cds->activity[d.seq].update_type=1))
    JOIN (cbc)
   WITH nocounter
  ;end insert
  COMMIT
  UPDATE  FROM cds_batch_content cbc,
    (dummyt d  WITH seq = value(cds_size))
   SET cbc.cds_batch_id = cds->activity[d.seq].cds_batch_id, cbc.parent_entity_id = cds->activity[d
    .seq].parent_entity_id, cbc.parent_entity_name = cds->activity[d.seq].parent_entity_name,
    cbc.cds_type_cd = cds->activity[d.seq].cds_type_cd, cbc.cds_row_error_ind = cds->activity[d.seq].
    cds_row_error_ind, cbc.organization_id = cds->activity[d.seq].provider_org_id,
    cbc.encntr_id = cds->activity[d.seq].encntr_id, cbc.update_del_flag = cds->activity[d.seq].
    update_del_flag, cbc.updt_dt_tm = cnvtdatetime(update_dt_tm),
    cbc.activity_dt_tm = cnvtdatetime(cds->activity[d.seq].activity_dt_tm)
   PLAN (d
    WHERE (cds->activity[d.seq].update_type IN (2, 3)))
    JOIN (cbc
    WHERE (cbc.cds_batch_content_id=cds->activity[d.seq].cds_batch_content_id))
   WITH nocounter
  ;end update
  COMMIT
  CALL echo("inserting into history")
  INSERT  FROM cds_batch_content_hist cbch,
    (dummyt d  WITH seq = value(cds_size))
   SET cbch.cds_batch_cnt_hist_id = seq(cds_batch_content_seq,nextval), cbch.cds_batch_content_id =
    cds->activity[d.seq].cds_batch_content_id, cbch.cds_batch_id = cds->activity[d.seq].cds_batch_id,
    cbch.parent_entity_id = cds->activity[d.seq].parent_entity_id, cbch.parent_entity_name = cds->
    activity[d.seq].parent_entity_name, cbch.cds_type_cd = cds->activity[d.seq].cds_type_cd,
    cbch.encounter_id = cds->activity[d.seq].encntr_id, cbch.cds_row_error_ind = cds->activity[d.seq]
    .cds_row_error_ind, cbch.organization_id = cds->activity[d.seq].provider_org_id,
    cbch.update_del_flag = cds->activity[d.seq].update_del_flag, cbch.transaction_dt_tm =
    cnvtdatetime(update_dt_tm), cbch.activity_dt_tm = cnvtdatetime(cds->activity[d.seq].
     activity_dt_tm)
   PLAN (d
    WHERE (((cds->activity[d.seq].update_type IN (1, 3))) OR ((cds->activity[d.seq].
    cds_batch_cnt_hist_id=0.0))) )
    JOIN (cbch)
   WITH nocounter
  ;end insert
  COMMIT
  CALL echo("updating into history")
  UPDATE  FROM cds_batch_content_hist cbch,
    (dummyt d  WITH seq = value(cds_size))
   SET cbch.cds_batch_content_id = cds->activity[d.seq].cds_batch_content_id, cbch.cds_batch_id = cds
    ->activity[d.seq].cds_batch_id, cbch.parent_entity_id = cds->activity[d.seq].parent_entity_id,
    cbch.parent_entity_name = cds->activity[d.seq].parent_entity_name, cbch.cds_type_cd = cds->
    activity[d.seq].cds_type_cd, cbch.encounter_id = cds->activity[d.seq].encntr_id,
    cbch.cds_row_error_ind = cds->activity[d.seq].cds_row_error_ind, cbch.organization_id = cds->
    activity[d.seq].provider_org_id, cbch.update_del_flag = cds->activity[d.seq].update_del_flag,
    cbch.transaction_dt_tm = cnvtdatetime(update_dt_tm), cbch.activity_dt_tm = cnvtdatetime(cds->
     activity[d.seq].activity_dt_tm)
   PLAN (d
    WHERE (cds->activity[d.seq].update_type=2))
    JOIN (cbch
    WHERE (cbch.cds_batch_cnt_hist_id=
    (SELECT
     max(cbch.cds_batch_cnt_hist_id)
     FROM cds_batch_content_hist cbch
     WHERE (cbch.cds_batch_content_id=cds->activity[d.seq].cds_batch_content_id)
      AND cbch.cds_batch_id=0.0)))
   WITH nocounter
  ;end update
  COMMIT
 ELSE
  CALL echo("Nothing to process")
 ENDIF
 SELECT INTO  $OUTDEV
  FROM organization o
  WHERE o.organization_id=trust
  DETAIL
   outstring = concat("EAL Load completed for ",o.org_name), col 5, outstring
  WITH nocounter, maxcol = 500
 ;end select
 FREE RECORD cds
#cds_load_eal_exit
END GO
