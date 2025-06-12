CREATE PROGRAM accession_req:dba
#accession_req_begin
 RECORD reply(
   1 assignment_meaning = vc
   1 qual[1]
     2 reply_tag = vc
     2 order_id = f8
     2 catalog_cd = f8
     2 facility_cd = f8
     2 site_prefix_cd = f8
     2 site_prefix_disp = c5
     2 accession_id = f8
     2 accession_day = i4
     2 accession_year = i4
     2 accession_format_cd = f8
     2 accession_format_meaning = c12
     2 alpha_prefix = c2
     2 accession_pool_id = f8
     2 accession_seq_nbr = i4
     2 accession = c20
     2 accession_formatted = c25
     2 assignment_meaning = vc
     2 assignment_status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD accession_fmt(
   1 qual[1]
     2 order_id = f8
     2 catalog_cd = f8
     2 facility_cd = f8
     2 site_prefix_cd = f8
     2 site_prefix_disp = c5
     2 accession_format_cd = f8
     2 accession_class_cd = f8
     2 specimen_type_cd = f8
     2 accession_dt_tm = dq8
     2 accession_day = i4
     2 accession_year = i4
     2 alpha_prefix = c2
     2 accession_seq_nbr = i4
     2 accession_pool_id = f8
     2 assignment_meaning = c200
     2 assignment_status = i2
     2 accession_id = f8
     2 accession = c20
     2 accession_formatted = c25
     2 activity_type_cd = f8
     2 order_tag = i2
 )
 RECORD accession_grp(
   1 qual[1]
     2 order_id = f8
     2 catalog_cd = f8
     2 facility_cd = f8
     2 site_prefix_cd = f8
     2 site_prefix_disp = c5
     2 accession_format_cd = f8
     2 accession_class_cd = f8
     2 accession_dt_tm = dq8
     2 alpha_prefix = c2
     2 accession_pool_id = f8
     2 accession_id = f8
     2 accession = c20
 )
 SET commit_ind = 0
 SET acc_ord_r = 0
 SET time_flag = 0
 SET accession_class_code_set = 2056
 SET accession_format_code_set = 2057
 DECLARE accession_status = c1
 DECLARE accession_meaning = c200
 DECLARE uar_fmt_accession(p1) = c25
 SET accession_status = ""
 SET accession_meaning = ""
 RECORD accession_info(
   1 qual[1]
     2 site_prefix_cd = f8
     2 site_prefix_disp = c5
     2 accession_dt_tm = dq8
     2 accession_year = i4
     2 accession_day = i4
     2 accession_format_cd = f8
     2 accession_format_meaning = c12
     2 accession_class_cd = f8
     2 alpha_prefix = c2
     2 accession_pool_id = f8
     2 accession_seq_nbr = i4
     2 accession = c20
     2 accession_id = f8
     2 assignment_status = i2
     2 assignment_meaning = c200
 )
 DECLARE assignment_status = i4
 DECLARE assignment_meaning = c200
 SET accession_assigned = 0
 SET accession_template = 300
 SET accession_pool = 310
 SET accession_pool_seq = 320
 DECLARE accession_chk_status = i4
 DECLARE accession_chk_meaning = c200
 DECLARE accession_id = f8
 DECLARE accession_dup_id = f8
 DECLARE accession_updt_cnt = i4
 RECORD accession_chk(
   1 site_prefix_cd = f8
   1 accession_year = i4
   1 accession_day = i4
   1 accession_pool_id = f8
   1 accession_seq_nbr = i4
   1 accession_class_cd = f8
   1 accession_format_cd = f8
   1 alpha_prefix = c2
   1 accession_id = f8
   1 accession = c20
   1 accession_nbr_check = c50
   1 accession_updt_cnt = i4
   1 action_ind = i2
   1 preactive_ind = i2
 )
 SET success = 0
 SET duplicate_accession = 410
 SET modify_accession = 420
 SET accesssion_sequence = 430
 SET insert_accession = 440
 SET accession_pool_id = 450
 DECLARE check_accession(ca_none) = i4
 SUBROUTINE check_accession(ca_none)
   SELECT INTO "nl:"
    a.accession_id, a.accession, a.accession_nbr_check
    FROM accession a
    WHERE (accession_chk->accession_nbr_check=a.accession_nbr_check)
    DETAIL
     accession_dup_id = a.accession_id, accession_updt_cnt = a.updt_cnt
    WITH nocounter
   ;end select
   IF (curqual=0
    AND (accession_chk->accession_id > 0))
    SELECT INTO "nl:"
     a.accession_id, a.accession, a.accession_nbr_check
     FROM accession a
     WHERE (accession_chk->accession_id=a.accession_id)
     DETAIL
      accession_dup_id = a.accession_id, accession_updt_cnt = a.updt_cnt
     WITH nocounter
    ;end select
    RETURN(0)
   ENDIF
   RETURN(curqual)
 END ;Subroutine
 DECLARE accession_sequence(as_none) = i4
 SUBROUTINE accession_sequence(as_none)
   SET accession_id = 0
   SELECT INTO "nl:"
    nextsequence = seq(accession_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     accession_id = cnvtint(nextsequence)
    WITH format, counter
   ;end select
   RETURN(curqual)
 END ;Subroutine
 DECLARE insert_accession(ia_none) = i4
 SUBROUTINE insert_accession(ia_none)
   INSERT  FROM accession a
    SET a.accession_id = accession_id, a.accession = accession_chk->accession, a.accession_nbr_check
      = trim(accession_chk->accession_nbr_check),
     a.site_prefix_cd = accession_chk->site_prefix_cd, a.accession_year = accession_chk->
     accession_year, a.accession_day = accession_chk->accession_day,
     a.accession_format_cd = accession_chk->accession_format_cd, a.alpha_prefix = accession_chk->
     alpha_prefix, a.accession_sequence_nbr = accession_chk->accession_seq_nbr,
     a.accession_class_cd = accession_chk->accession_class_cd, a.accession_pool_id = accession_chk->
     accession_pool_id, a.preactive_ind = accession_chk->preactive_ind,
     a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_task =
     reqinfo->updt_task,
     a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
    WITH nocounter
   ;end insert
   SET accession_updt_cnt = 0
   RETURN(curqual)
 END ;Subroutine
 DECLARE modify_accession(ia_none) = i4
 SUBROUTINE modify_accession(ia_none)
   SELECT INTO "nl:"
    a.accession_id
    FROM accession a
    WHERE (accession_chk->accession_id=a.accession_id)
    WITH nocounter, forupdate(a)
   ;end select
   IF (curqual > 0)
    UPDATE  FROM accession a
     SET a.accession = accession_chk->accession, a.accession_nbr_check = trim(accession_chk->
       accession_nbr_check), a.site_prefix_cd = accession_chk->site_prefix_cd,
      a.accession_year = accession_chk->accession_year, a.accession_day = accession_chk->
      accession_day, a.accession_format_cd = accession_chk->accession_format_cd,
      a.alpha_prefix = accession_chk->alpha_prefix, a.accession_sequence_nbr = accession_chk->
      accession_seq_nbr, a.accession_class_cd = accession_chk->accession_class_cd,
      a.accession_pool_id = accession_chk->accession_pool_id, a.preactive_ind = accession_chk->
      preactive_ind, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
      updt_applctx,
      a.updt_cnt = (a.updt_cnt+ 1)
     WHERE (a.accession_id=accession_chk->accession_id)
      AND (a.updt_cnt=accession_chk->accession_updt_cnt)
     WITH nocounter
    ;end update
    SET accession_updt_cnt = (accession_updt_cnt+ 1)
   ENDIF
   RETURN(curqual)
 END ;Subroutine
 SUBROUTINE accession_chk(ac_none)
   SET accession_chk_status = 0
   SET accession_chk_meaning = ""
   IF (check_accession(0) != 0)
    SET accession_chk_status = duplicate_accession
    SET accession_chk_meaning = "ACCESSION_CHK:  Duplicate Accession."
   ELSE
    IF ((accession_chk->action_ind=1))
     SET accession_chk_status = success
     SET accession_chk_meaning = "ACCESSION_CHK:  Accession not on table ACCESSION."
    ELSE
     IF ((accession_chk->action_ind=2))
      IF (modify_accession(0)=0)
       SET accession_chk_status = modify_accession
       SET accession_chk_meaning = "ACCESSION_CHK: Update failed on table ACCESSION."
      ELSE
       SET accession_chk_status = success
       SET accession_chk_meaning = "ACCESSION_CHK: Accession modified."
      ENDIF
     ELSE
      IF (accession_sequence(0)=0)
       SET accession_chk_status = accession_sequence
       SET accession_chk_meaning = "ACCESSION_CHK: Unable to get next sequence number."
      ELSE
       IF (insert_accession(0)=0)
        SET accession_chk_status = insert_accession
        SET accession_chk_meaning = "ACCESSION_CHK: Insert failed on table ACCESSION."
       ELSE
        SET accession_chk_status = success
        SET accession_chk_meaning = "ACCESSION_CHK: Accession Assigned."
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE accession_nbr = c20
 DECLARE accession_nbr_chk = c50
 RECORD accession_str(
   1 site_prefix_disp = c5
   1 accession_year = i4
   1 accession_day = i4
   1 alpha_prefix = c2
   1 accession_seq_nbr = i4
   1 accession_pool_id = f8
 )
 SUBROUTINE accession_str(astr_none)
   SET accession_nbr = ""
   SET accession_nbr_chk = ""
   SET acc_pool_string = cnvtstring(accession_str->accession_pool_id,32,6,r)
   SET bpos = 0
   SET epos = 0
   FOR (cnt1 = 1 TO 32)
     IF (cnvtint(substring(cnt1,1,acc_pool_string)) > 0)
      SET bpos = cnt1
      SET cnt1 = 32
      SET cnt2 = 32
      WHILE (cnt2 > bpos)
        IF (((cnvtint(substring(cnt2,1,acc_pool_string)) > 0) OR (substring(cnt2,1,acc_pool_string)=
        ".")) )
         IF (substring(cnt2,1,acc_pool_string)=".")
          SET epos = (cnt2 - 1)
         ELSE
          SET epos = cnt2
         ENDIF
         SET cnt2 = (bpos - 1)
        ELSE
         SET cnt2 = (cnt2 - 1)
        ENDIF
      ENDWHILE
     ENDIF
   ENDFOR
   SET strlength = ((epos - bpos)+ 1)
   IF (strlength <= 0)
    SET strlength = 1
   ENDIF
   IF ((accession_str->site_prefix_disp=""))
    SET accession_str->site_prefix_disp = "00000"
   ENDIF
   IF (size(trim(accession_str->alpha_prefix)) > 0
    AND (accession_str->alpha_prefix > " "))
    IF (size(trim(accession_str->alpha_prefix))=1)
     SET accession_str->alpha_prefix = concat(" ",accession_str->alpha_prefix)
    ENDIF
    SET accession_nbr = concat(trim(accession_nbr),accession_str->site_prefix_disp,accession_str->
     alpha_prefix,cnvtstring(accession_str->accession_year,4,0,r),cnvtstring(accession_str->
      accession_seq_nbr,7,0,r))
    SET accession_nbr_chk = concat(trim(accession_nbr_chk),cnvtstring(accession_str->accession_year,4,
      0,r),substring(bpos,strlength,acc_pool_string),cnvtstring(accession_str->accession_seq_nbr,7,0,
      r))
   ELSE
    SET accession_nbr = concat(trim(accession_nbr),accession_str->site_prefix_disp,cnvtstring(
      accession_str->accession_year,4,0,r),cnvtstring(accession_str->accession_day,3,0,r),cnvtstring(
      accession_str->accession_seq_nbr,6,0,r))
    SET accession_nbr_chk = concat(trim(accession_nbr_chk),cnvtstring(accession_str->accession_year,4,
      0,r),cnvtstring(accession_str->accession_day,3,0,r),substring(bpos,strlength,acc_pool_string),
     cnvtstring(accession_str->accession_seq_nbr,6,0,r))
   ENDIF
 END ;Subroutine
 SUBROUTINE accession_grp(agi)
  SET grp_cnt = size(accession_grp->qual,5)
  FOR (gci = 1 TO grp_cnt)
    IF ((accession_info->qual[agi].site_prefix_cd=accession_grp->qual[gci].site_prefix_cd)
     AND (accession_info->qual[agi].accession_class_cd=accession_grp->qual[gci].accession_class_cd)
     AND (accession_info->qual[agi].accession_format_cd=accession_grp->qual[gci].accession_format_cd)
     AND (accession_info->qual[agi].accession_dt_tm=accession_grp->qual[gci].accession_dt_tm)
     AND (accession_info->qual[agi].accession_pool_id=accession_grp->qual[gci].accession_pool_id))
     SET accession_info->qual[agi].accession = accession_grp->qual[gci].accession
     SET accession_info->qual[agi].accession_id = accession_grp->qual[gci].accession_id
     SET accession_info->qual[agi].assignment_status = accession_assigned
     SET accession_info->qual[agi].assignment_meaning = "ACCESSION_GRP:  Accession Grouped"
     SET gci = grp_cnt
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE accession_asn(asn_none)
   SET accession_seq_nbr = 0
   SET accession_increment = 0
   SET accession_initial = 0
   SET assigned_cnt = size(accession_info->qual,5)
   FOR (i = 1 TO size(accession_info->qual,5))
     IF ((accession_info->qual[i].alpha_prefix > " "))
      SET accession_assignment_date = cnvtdatetime(cnvtdate2(concat("0101",cnvtstring(accession_info
          ->qual[i].accession_year,4,0,r)),"mmddyyyy"),0)
     ELSE
      SET accession_assignment_date = cnvtdatetime(cnvtdate(accession_info->qual[i].accession_dt_tm),
       0)
     ENDIF
     IF (size(accession_grp->qual,5) > 0)
      CALL accession_grp(i)
     ENDIF
     IF ((accession_info->qual[i].assignment_status != accession_assigned))
      SELECT INTO "nl:"
       aa.*
       FROM accession_assignment aa
       WHERE (accession_info->qual[i].accession_pool_id=aa.acc_assign_pool_id)
        AND cnvtdatetime(accession_assignment_date)=aa.acc_assign_date
       DETAIL
        accession_seq_nbr = aa.accession_seq_nbr, accession_increment = aa.increment_value
       WITH nocounter, forupdatewait(aa)
      ;end select
      SET assignment_status = - (1)
      SET assignment_meaning = ""
      SET assignment_id = 0
      IF (curqual=0)
       SELECT INTO "nl:"
        aap.accession_assignment_pool_id
        FROM accession_assign_pool aap
        WHERE (accession_info->qual[i].accession_pool_id=aap.accession_assignment_pool_id)
        DETAIL
         accession_increment = aap.increment_value, accession_seq_nbr = aap.initial_value
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET assignment_status = accession_template
        SET assignment_meaning =
        "ACCESSION_ASN:  Unable to retrieve template from table ACCESSION_ASSIGN_POOL."
       ELSE
        INSERT  FROM accession_assignment aa
         SET aa.acc_assign_pool_id = accession_info->qual[i].accession_pool_id, aa.acc_assign_date =
          cnvtdatetime(accession_assignment_date), aa.accession_seq_nbr = accession_seq_nbr,
          aa.increment_value = accession_increment, aa.last_increment_dt_tm = cnvtdatetime(curdate,
           curtime3), aa.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          aa.updt_id = reqinfo->updt_id, aa.updt_task = reqinfo->updt_task, aa.updt_applctx = reqinfo
          ->updt_applctx,
          aa.updt_cnt = 0
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET assignment_status = accession_pool
         SET assignment_meaning =
         "ACCESSION_ASN:  Unable to create accession pool on table ACCESSION_ASSIGNMENT"
        ENDIF
       ENDIF
      ENDIF
      WHILE ((assignment_status=- (1)))
       UPDATE  FROM accession_assignment aa
        SET aa.accession_seq_nbr = (aa.accession_seq_nbr+ aa.increment_value), aa.updt_dt_tm =
         cnvtdatetime(curdate,curtime3), aa.updt_id = reqinfo->updt_id,
         aa.updt_task = reqinfo->updt_task, aa.updt_applctx = reqinfo->updt_applctx, aa.updt_cnt = (
         aa.updt_cnt+ 1)
        WHERE (accession_info->qual[i].accession_pool_id=aa.acc_assign_pool_id)
         AND cnvtdatetime(accession_assignment_date)=aa.acc_assign_date
        WITH nocounter
       ;end update
       IF (curqual=0)
        SET assignment_status = accession_pool_seq
        SET assignment_meaning =
        "ACCESSION_ASN:  Unable to update sequence number in table ACCESSION_ASSIGNMENT"
       ELSE
        IF (accession_chk_status=duplicate_accession)
         SET accession_seq_nbr = (accession_seq_nbr+ accession_increment)
        ENDIF
        SET accession_info->qual[i].accession_seq_nbr = accession_seq_nbr
        SET accession_info->qual[i].accession = ""
        SET accession_str->site_prefix_disp = accession_info->qual[i].site_prefix_disp
        SET accession_str->accession_year = accession_info->qual[i].accession_year
        SET accession_str->accession_day = accession_info->qual[i].accession_day
        SET accession_str->alpha_prefix = accession_info->qual[i].alpha_prefix
        SET accession_str->accession_seq_nbr = accession_info->qual[i].accession_seq_nbr
        SET accession_str->accession_pool_id = accession_info->qual[i].accession_pool_id
        CALL accession_str(0)
        SET accession_info->qual[i].accession = accession_nbr
        SET accession_chk->site_prefix_cd = accession_info->qual[i].site_prefix_cd
        SET accession_chk->accession_year = accession_info->qual[i].accession_year
        SET accession_chk->accession_day = accession_info->qual[i].accession_day
        SET accession_chk->accession_pool_id = accession_info->qual[i].accession_pool_id
        SET accession_chk->accession_seq_nbr = accession_info->qual[i].accession_seq_nbr
        SET accession_chk->accession_class_cd = accession_info->qual[i].accession_class_cd
        SET accession_chk->accession_format_cd = accession_info->qual[i].accession_format_cd
        SET accession_chk->alpha_prefix = accession_info->qual[i].alpha_prefix
        SET accession_chk->accession = accession_nbr
        SET accession_chk->accession_nbr_check = accession_nbr_chk
        SET accession_chk->action_ind = 0
        SET accession_chk->preactive_ind = 0
        CALL accession_chk(0)
        IF (accession_chk_status != duplicate_accession)
         SET assignment_status = accession_chk_status
         SET assignment_meaning = accession_chk_meaning
        ENDIF
       ENDIF
      ENDWHILE
      SET accession_info->qual[i].assignment_status = assignment_status
      SET accession_info->qual[i].assignment_meaning = assignment_meaning
      SET accession_info->qual[i].accession_id = accession_id
     ENDIF
     IF ((accession_info->qual[i].assignment_status > 1))
      SET assigned_cnt = (assigned_cnt - 1)
     ENDIF
   ENDFOR
   IF (assigned_cnt=size(accession_info->qual,5))
    SET accession_status = "S"
    SET accession_meaning = "ACCESSION_ASN:  All the accession numbers were assigned."
   ELSE
    SET accession_status = "F"
    SET accession_meaning = "ACCESSION_ASN: No accession numbers were assigned."
   ENDIF
 END ;Subroutine
 RECORD accession(
   1 qual[1]
     2 site_prefix_cd = f8
     2 site_prefix_disp = c5
     2 accession_dt_tm = dq8
     2 accession_format_cd = f8
     2 accession_format_meaning = c12
     2 alpha_prefix = c2
     2 accession_class_cd = f8
     2 accession_pool_id = f8
     2 accession_info_pos = i2
     2 accession_fmt_pos = i2
     2 catalog_cd = f8
     2 specimen_type_cd = f8
     2 activity_type_cd = f8
     2 activity_type_mean = c12
 )
 SET site_length = 5
 SUBROUTINE accession_net(net_none)
   IF (commit_ind=0)
    SET nbr_of_accessions = size(accession_fmt->qual,5)
   ENDIF
   SET stat = alter(accession->qual,nbr_of_accessions)
   SET stat = alter(accession_info->qual,nbr_of_accessions)
   SET acc_cnt = 0
   SET default_site_cd = 0
   SET default_site_prefix = "00000"
   SELECT INTO "nl:"
    a.default_site_cd, c.display
    FROM accession_setup a,
     code_value c
    PLAN (a
     WHERE a.accession_setup_id=72696.00)
     JOIN (c
     WHERE a.default_site_cd=c.code_value)
    DETAIL
     default_site_cd = a.default_site_cd
     IF (c.code_value > 0)
      default_site_prefix = c.display
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    l.facility_accn_prefix_cd, d1.seq, c.code_value
    FROM (dummyt d1  WITH seq = value(nbr_of_accessions)),
     (dummyt d2  WITH seq = 1),
     location l,
     code_value c
    PLAN (d1
     WHERE d1.seq <= nbr_of_accessions
      AND (accession_fmt->qual[d1.seq].site_prefix_cd=0)
      AND (accession_fmt->qual[d1.seq].catalog_cd > 0))
     JOIN (d2
     WHERE d2.seq=1)
     JOIN (l
     WHERE (l.location_cd=accession_fmt->qual[d1.seq].facility_cd))
     JOIN (c
     WHERE c.code_value=l.facility_accn_prefix_cd)
    DETAIL
     IF (c.code_value > 0)
      accession_fmt->qual[d1.seq].site_prefix_cd = c.code_value, site_str = c.display
     ELSE
      accession_fmt->qual[d1.seq].site_prefix_cd = default_site_cd, site_str = default_site_prefix
     ENDIF
     site_sze = size(trim(site_str)), accession_fmt->qual[d1.seq].site_prefix_disp = ""
     IF (site_sze < site_length)
      FOR (i = 1 TO (site_length - site_sze))
        accession_fmt->qual[d1.seq].site_prefix_disp = concat(trim(accession_fmt->qual[d1.seq].
          site_prefix_disp),"0")
      ENDFOR
     ENDIF
     accession_fmt->qual[d1.seq].site_prefix_disp = concat(trim(accession_fmt->qual[d1.seq].
       site_prefix_disp),trim(site_str))
    WITH nocounter, outerjoin = d2, dontcare = l
   ;end select
   SELECT INTO "nl:"
    aax.site_prefix_cd, ps.accession_class_cd, ac.accession_format_cd,
    aax.accession_assignment_pool_id, accession_fmt->qual[d1.seq].accession_dt_tm
    "dd-mmm-yyyy-hhmm;;d", d1.seq,
    ps.specimen_type_cd, ps.catalog_cd, c.display
    FROM (dummyt d1  WITH seq = value(nbr_of_accessions)),
     procedure_specimen_type ps,
     accession_class ac,
     code_value c,
     accession_assign_xref aax
    PLAN (d1
     WHERE d1.seq <= nbr_of_accessions
      AND (accession_fmt->qual[d1.seq].catalog_cd > 0))
     JOIN (ps
     WHERE (accession_fmt->qual[d1.seq].specimen_type_cd=ps.specimen_type_cd)
      AND (accession_fmt->qual[d1.seq].catalog_cd=ps.catalog_cd))
     JOIN (ac
     WHERE ps.accession_class_cd=ac.accession_class_cd)
     JOIN (c
     WHERE ac.accession_format_cd=c.code_value)
     JOIN (aax
     WHERE c.code_value=aax.accession_format_cd
      AND (accession_fmt->qual[d1.seq].site_prefix_cd=aax.site_prefix_cd))
    DETAIL
     acc_cnt = (acc_cnt+ 1), accession->qual[acc_cnt].site_prefix_cd = accession_fmt->qual[d1.seq].
     site_prefix_cd, accession->qual[acc_cnt].site_prefix_disp = accession_fmt->qual[d1.seq].
     site_prefix_disp,
     accession->qual[acc_cnt].accession_dt_tm = accession_fmt->qual[d1.seq].accession_dt_tm,
     accession->qual[acc_cnt].accession_class_cd = ac.accession_class_cd, accession->qual[acc_cnt].
     accession_format_cd = ac.accession_format_cd,
     accession->qual[acc_cnt].accession_format_meaning = c.cdf_meaning
     IF (ac.accession_format_cd > 0)
      accession->qual[acc_cnt].alpha_prefix = trim(c.display)
     ELSE
      accession->qual[acc_cnt].alpha_prefix = ""
     ENDIF
     accession->qual[acc_cnt].accession_pool_id = aax.accession_assignment_pool_id, accession->qual[
     acc_cnt].accession_fmt_pos = d1.seq, accession->qual[acc_cnt].catalog_cd = accession_fmt->qual[
     d1.seq].catalog_cd,
     accession->qual[acc_cnt].specimen_type_cd = accession_fmt->qual[d1.seq].specimen_type_cd,
     accession->qual[acc_cnt].activity_type_cd = accession_fmt->qual[d1.seq].activity_type_cd,
     accession->qual[acc_cnt].accession_info_pos = 0
    WITH nocounter
   ;end select
   IF (acc_cnt < nbr_of_accessions)
    SELECT INTO "nl:"
     aax.site_prefix_cd, accession_fmt->qual[d1.seq].accession_format_cd, aax
     .accession_assignment_pool_id,
     accession_fmt->qual[d1.seq].accession_dt_tm"dd-mmm-yyyy-hhmm;;d", d1.seq, c.display
     FROM (dummyt d1  WITH seq = value(nbr_of_accessions)),
      code_value c,
      accession_assign_xref aax
     PLAN (d1
      WHERE d1.seq <= nbr_of_accessions
       AND (accession_fmt->qual[d1.seq].accession_format_cd > 0))
      JOIN (c
      WHERE (accession_fmt->qual[d1.seq].accession_format_cd=c.code_value))
      JOIN (aax
      WHERE c.code_value=aax.accession_format_cd
       AND (accession_fmt->qual[d1.seq].site_prefix_cd=aax.site_prefix_cd))
     DETAIL
      acc_cnt = (acc_cnt+ 1), accession->qual[acc_cnt].site_prefix_cd = accession_fmt->qual[d1.seq].
      site_prefix_cd, accession->qual[acc_cnt].site_prefix_disp = accession_fmt->qual[d1.seq].
      site_prefix_disp,
      accession->qual[acc_cnt].accession_dt_tm = accession_fmt->qual[d1.seq].accession_dt_tm,
      accession->qual[acc_cnt].accession_class_cd = 0, accession->qual[acc_cnt].accession_format_cd
       = accession_fmt->qual[d1.seq].accession_format_cd
      IF ((accession->qual[acc_cnt].accession_format_cd > 0))
       accession->qual[acc_cnt].alpha_prefix = trim(c.display)
      ELSE
       accession->qual[acc_cnt].alpha_prefix = ""
      ENDIF
      accession->qual[acc_cnt].accession_pool_id = aax.accession_assignment_pool_id, accession->qual[
      acc_cnt].accession_fmt_pos = d1.seq, accession->qual[acc_cnt].accession_info_pos = 0,
      accession->qual[acc_cnt].catalog_cd = 0, accession->qual[acc_cnt].activity_type_cd =
      accession_fmt->qual[d1.seq].activity_type_cd, accession->qual[acc_cnt].activity_type_mean = "",
      accession->qual[acc_cnt].specimen_type_cd = 0
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    accession->qual[d1.seq].activity_type_cd, c.cdf_meaning
    FROM (dummyt d1  WITH seq = value(acc_cnt)),
     code_value c
    PLAN (d1)
     JOIN (c
     WHERE (accession->qual[d1.seq].activity_type_cd=c.code_value))
    DETAIL
     accession->qual[d1.seq].activity_type_mean = trim(substring(1,3,c.cdf_meaning))
    WITH nocounter
   ;end select
   IF (time_flag > 0)
    FOR (ti_idx = 1 TO acc_cnt)
      SET t1 = format(cnvtdatetime(accession->qual[ti_idx].accession_dt_tm),"dd-mmm-yyyy hh:mm;;d")
      SET t2 = cnvtdatetime(t1)
      SET accession->qual[ti_idx].accession_dt_tm = t2
    ENDFOR
   ENDIF
   SET ai_idx = 0
   FOR (a_idx = 1 TO acc_cnt)
     IF ((accession->qual[a_idx].accession_pool_id > 0))
      SET an_idx = 1
      SET new_acc = 1
      WHILE (an_idx < a_idx)
       IF ((accession->qual[a_idx].accession_class_cd > 0))
        IF ((accession->qual[a_idx].site_prefix_cd=accession->qual[an_idx].site_prefix_cd)
         AND (accession->qual[a_idx].accession_class_cd=accession->qual[an_idx].accession_class_cd)
         AND (accession->qual[a_idx].accession_format_cd=accession->qual[an_idx].accession_format_cd)
         AND (accession->qual[a_idx].accession_dt_tm=accession->qual[an_idx].accession_dt_tm)
         AND (accession->qual[a_idx].accession_pool_id=accession->qual[an_idx].accession_pool_id))
         IF ((accession->qual[a_idx].catalog_cd=accession->qual[an_idx].catalog_cd)
          AND (accession->qual[a_idx].specimen_type_cd=accession->qual[an_idx].specimen_type_cd)
          AND (accession->qual[a_idx].activity_type_mean != "AP"))
          SET new_acc = 1
          SET an_idx = a_idx
         ELSE
          IF ((accession->qual[a_idx].accession_info_pos=0)
           AND (accession->qual[an_idx].accession_info_pos > 0))
           SET accession->qual[a_idx].accession_info_pos = accession->qual[an_idx].accession_info_pos
           SET new_acc = 0
          ENDIF
         ENDIF
        ENDIF
       ENDIF
       SET an_idx = (an_idx+ 1)
      ENDWHILE
      IF (new_acc=1)
       SET ai_idx = (ai_idx+ 1)
       SET accession_info->qual[ai_idx].site_prefix_cd = accession->qual[a_idx].site_prefix_cd
       SET accession_info->qual[ai_idx].site_prefix_disp = accession->qual[a_idx].site_prefix_disp
       SET accession_info->qual[ai_idx].accession_class_cd = accession->qual[a_idx].
       accession_class_cd
       SET accession_info->qual[ai_idx].accession_format_cd = accession->qual[a_idx].
       accession_format_cd
       SET accession_info->qual[ai_idx].accession_format_meaning = accession->qual[a_idx].
       accession_format_meaning
       SET accession_info->qual[ai_idx].alpha_prefix = accession->qual[a_idx].alpha_prefix
       SET accession_info->qual[ai_idx].accession_pool_id = accession->qual[a_idx].accession_pool_id
       SET accession_info->qual[ai_idx].accession_dt_tm = accession->qual[a_idx].accession_dt_tm
       SET accession_info->qual[ai_idx].accession_year = year(accession->qual[a_idx].accession_dt_tm)
       SET accession_info->qual[ai_idx].accession_day = julian(accession->qual[a_idx].accession_dt_tm
        )
       SET accession_info->qual[ai_idx].assignment_status = - (1)
       SET accession_info->qual[ai_idx].assignment_meaning = ""
       SET accession_info->qual[ai_idx].accession = ""
       SET accession->qual[a_idx].accession_info_pos = ai_idx
      ENDIF
     ENDIF
   ENDFOR
   IF (ai_idx > 0)
    SET stat = alter(accession_info->qual,ai_idx)
    CALL accession_asn(0)
   ELSE
    SET accession_status = "F"
    SET accession_meaning = "ACCESSION_NET:  Missing Accession Information"
   ENDIF
   IF (accession_status != "F")
    SELECT INTO "nl:"
     d1.seq
     FROM (dummyt d1  WITH seq = value(acc_cnt))
     PLAN (d1)
     DETAIL
      accession_fmt->qual[accession->qual[d1.seq].accession_fmt_pos].accession_id = accession_info->
      qual[accession->qual[d1.seq].accession_info_pos].accession_id, accession_fmt->qual[accession->
      qual[d1.seq].accession_fmt_pos].accession_day = accession_info->qual[accession->qual[d1.seq].
      accession_info_pos].accession_day, accession_fmt->qual[accession->qual[d1.seq].
      accession_fmt_pos].accession_year = accession_info->qual[accession->qual[d1.seq].
      accession_info_pos].accession_year,
      accession_fmt->qual[accession->qual[d1.seq].accession_fmt_pos].alpha_prefix = accession_info->
      qual[accession->qual[d1.seq].accession_info_pos].alpha_prefix, accession_fmt->qual[accession->
      qual[d1.seq].accession_fmt_pos].accession_seq_nbr = accession_info->qual[accession->qual[d1.seq
      ].accession_info_pos].accession_seq_nbr, accession_fmt->qual[accession->qual[d1.seq].
      accession_fmt_pos].accession_pool_id = accession_info->qual[accession->qual[d1.seq].
      accession_info_pos].accession_pool_id,
      accession_fmt->qual[accession->qual[d1.seq].accession_fmt_pos].assignment_meaning =
      accession_info->qual[accession->qual[d1.seq].accession_info_pos].assignment_meaning,
      accession_fmt->qual[accession->qual[d1.seq].accession_fmt_pos].assignment_status =
      accession_info->qual[accession->qual[d1.seq].accession_info_pos].assignment_status,
      accession_fmt->qual[accession->qual[d1.seq].accession_fmt_pos].accession_format_cd =
      accession_info->qual[accession->qual[d1.seq].accession_info_pos].accession_format_cd,
      accession_fmt->qual[accession->qual[d1.seq].accession_fmt_pos].accession = accession_info->
      qual[accession->qual[d1.seq].accession_info_pos].accession, accession_fmt->qual[accession->
      qual[d1.seq].accession_fmt_pos].accession_formatted = uar_fmt_accession(accession_info->qual[
       accession->qual[d1.seq].accession_info_pos].accession,size(accession_info->qual[accession->
        qual[d1.seq].accession_info_pos].accession))
     WITH nocounter
    ;end select
    IF (acc_ord_r=1)
     INSERT  FROM accession_order_r a,
       (dummyt d1  WITH seq = value(nbr_of_accessions))
      SET a.order_id = accession_fmt->qual[d1.seq].order_id, a.accession_id = accession_fmt->qual[d1
       .seq].accession_id, a.accession = accession_fmt->qual[d1.seq].accession,
       a.activity_type_cd = accession_fmt->qual[d1.seq].activity_type_cd, a.updt_dt_tm = cnvtdatetime
       (curdate,curtime3), a.updt_id = reqinfo->updt_id,
       a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
      PLAN (d1
       WHERE d1.seq <= nbr_of_accessions
        AND (accession_fmt->qual[d1.seq].order_id > 0)
        AND (accession_fmt->qual[d1.seq].assignment_status=0))
       JOIN (a
       WHERE (accession_fmt->qual[d1.seq].order_id != a.order_id)
        AND (accession_fmt->qual[d1.seq].accession_id != a.accession_id))
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
 END ;Subroutine
 SET nbr_of_accessions = size(request->qual,5)
 SET stat = alter(reply->qual,nbr_of_accessions)
 SET stat = alter(accession_fmt->qual,nbr_of_accessions)
#begin
 SET af_cnt = 0
 SELECT INTO "nl:"
  d1.seq
  FROM (dummyt d1  WITH seq = value(nbr_of_accessions))
  PLAN (d1)
  DETAIL
   af_cnt = (af_cnt+ 1), accession_fmt->qual[af_cnt].order_id = request->qual[d1.seq].order_id,
   accession_fmt->qual[af_cnt].facility_cd = request->qual[d1.seq].facility_cd,
   accession_fmt->qual[af_cnt].site_prefix_cd = request->qual[d1.seq].site_prefix_cd, accession_fmt->
   qual[af_cnt].site_prefix_disp = request->qual[d1.seq].site_prefix_disp, accession_fmt->qual[af_cnt
   ].catalog_cd = request->qual[d1.seq].catalog_cd,
   accession_fmt->qual[af_cnt].activity_type_cd = request->qual[d1.seq].activity_type_cd
   IF ((request->qual[d1.seq].specimen_type_cd > 0))
    accession_fmt->qual[af_cnt].specimen_type_cd = request->qual[d1.seq].specimen_type_cd,
    accession_fmt->qual[af_cnt].accession_format_cd = 0
   ELSE
    accession_fmt->qual[af_cnt].accession_format_cd = request->qual[d1.seq].accession_format_cd,
    accession_fmt->qual[af_cnt].specimen_type_cd = 0
   ENDIF
   accession_fmt->qual[af_cnt].accession_dt_tm = request->qual[d1.seq].accession_dt_tm
  WITH nocounter
 ;end select
 SET group_count = size(request->group_qual,5)
 SET ag_cnt = 0
 IF (group_count > 0)
  SELECT INTO "nl:"
   d1.seq
   FROM (dummyt d1  WITH seq = value(group_count)),
    accession a
   PLAN (d1)
    JOIN (a
    WHERE (request->group_qual[d1.seq].accession_id=a.accession_id))
   DETAIL
    IF (ag_cnt > size(accession_grp->qual,5))
     stat = alter(accession_grp->qual,(ag_cnt+ 1))
    ENDIF
    accession_grp->qual[ag_cnt].site_prefix_cd = a.site_prefix_cd, accession_grp->qual[ag_cnt].
    accession_class_cd = a.accession_class_cd, accession_grp->qual[ag_cnt].accession_format_cd = a
    .accession_format_cd,
    accession_grp->qual[ag_cnt].accession_dt_tm = request->group_qual[d1.seq].accession_dt_tm,
    accession_grp->qual[ag_cnt].accession_pool_id = a.accession_pool_id, accession_grp->qual[ag_cnt].
    accession = a.accession,
    accession_grp->qual[ag_cnt].accession_id = a.accession_id
   WITH nocounter
  ;end select
  SET stat = alter(accession_grp->qual,ag_cnt)
 ENDIF
#build_reply
 IF (af_cnt > 0)
  SET commit_ind = 1
  SET acc_ord_r = request->acc_ord_r
  SET time_flag = request->time_flag
  CALL accession_net(0)
  SELECT INTO "nl:"
   d1.seq
   FROM (dummyt d1  WITH seq = value(nbr_of_accessions))
   PLAN (d1
    WHERE d1.seq <= nbr_of_accessions)
   DETAIL
    reply->qual[d1.seq].reply_tag = request->qual[d1.seq].request_tag, reply->qual[d1.seq].order_id
     = accession_fmt->qual[d1.seq].order_id, reply->qual[d1.seq].catalog_cd = accession_fmt->qual[d1
    .seq].catalog_cd,
    reply->qual[d1.seq].facility_cd = accession_fmt->qual[d1.seq].facility_cd, reply->qual[d1.seq].
    site_prefix_cd = accession_fmt->qual[d1.seq].site_prefix_cd, reply->qual[d1.seq].site_prefix_disp
     = accession_fmt->qual[d1.seq].site_prefix_disp,
    reply->qual[d1.seq].accession_day = accession_fmt->qual[d1.seq].accession_day, reply->qual[d1.seq
    ].accession_year = accession_fmt->qual[d1.seq].accession_year, reply->qual[d1.seq].
    accession_format_cd = accession_fmt->qual[d1.seq].accession_format_cd,
    reply->qual[d1.seq].alpha_prefix = accession_fmt->qual[d1.seq].alpha_prefix, reply->qual[d1.seq].
    accession_seq_nbr = accession_fmt->qual[d1.seq].accession_seq_nbr, reply->qual[d1.seq].
    accession_pool_id = accession_fmt->qual[d1.seq].accession_pool_id,
    reply->qual[d1.seq].accession_id = accession_fmt->qual[d1.seq].accession_id, reply->qual[d1.seq].
    accession = accession_fmt->qual[d1.seq].accession, reply->qual[d1.seq].accession_formatted =
    accession_fmt->qual[d1.seq].accession_formatted,
    reply->qual[d1.seq].assignment_status = accession_fmt->qual[d1.seq].assignment_status, reply->
    qual[d1.seq].assignment_meaning = accession_fmt->qual[d1.seq].assignment_meaning
   WITH nocounter
  ;end select
 ELSE
  SET accession_status = "F"
  SET accession_meaning = "ACCESSION REQ:  Unable to build accession request."
 ENDIF
#accession_req_exit
 IF (commit_ind=1)
  IF (accession_status="F")
   SET reqinfo->commit_ind = 0
  ELSE
   SET reqinfo->commit_ind = 1
  ENDIF
 ENDIF
 SET reply->status_data.status = accession_status
 SET reply->assignment_meaning = trim(accession_meaning)
END GO
