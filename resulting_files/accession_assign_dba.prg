CREATE PROGRAM accession_assign:dba
 DECLARE mic_cdf = c12 WITH constant("MICROBIOLOGY"), protect
 DECLARE ap_cdf = c12 WITH constant("AP"), protect
 RECORD accession_info(
   1 qual[*]
     2 site_prefix_cd = f8
     2 site_prefix_disp = c5
     2 accession_dt_tm = dq8
     2 accession_year = i4
     2 accession_day = i4
     2 accession_format_cd = f8
     2 accession_format_mean = c12
     2 accession_class_cd = f8
     2 alpha_prefix = c2
     2 accession_pool_id = f8
     2 accession_seq_nbr = i4
     2 accession = c20
     2 accession_id = f8
     2 assignment_status = i2
     2 assignment_meaning = vc
     2 assignment_date = dq8
   1 proc_qual[*]
     2 info_index = i4
 )
 DECLARE nbr_to_assign = i2 WITH noconstant(size(accession_fmt->qual,5))
 DECLARE nbr_to_group = i2 WITH noconstant(size(accession_grp->qual,5))
 IF (nbr_to_assign=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(accession_info->qual,nbr_to_assign)
 EXECUTE accession_settings
 IF ((acc_settings->site_code_length > 0))
  SET stat = facilitysiteprefix(0)
 ENDIF
 SET stat = accessionclass(0)
 IF ((accession_fmt->cpri_lookup=1))
  SET stat = collectionpriorityinfo(1,nbr_to_assign)
 ENDIF
 IF ((accession_grp->cpri_lookup=1))
  SET stat = collectionpriorityinfo(0,nbr_to_group)
 ENDIF
 SET stat = activitytypeinfo(1,nbr_to_assign)
 SET stat = activitytypeinfo(0,nbr_to_group)
 SET stat = accessionassignxref(0)
 IF (codevalueinfo(0)=0)
  GO TO exit_script
 ENDIF
 IF (accessionnetting(0)=1)
  SET stat = accessionassignment(size(accession_info->qual,5))
 ENDIF
#exit_script
 SUBROUTINE (facilitysiteprefix(no_param=i2(value)) =i2)
  SELECT INTO "nl:"
   d1.seq, l.facility_accn_prefix_cd
   FROM (dummyt d1  WITH seq = value(nbr_to_assign)),
    location l
   PLAN (d1
    WHERE (accession_fmt->qual[d1.seq].site_prefix_cd=0)
     AND (accession_fmt->qual[d1.seq].catalog_cd > 0))
    JOIN (l
    WHERE (l.location_cd=accession_fmt->qual[d1.seq].facility_cd))
   DETAIL
    IF (l.facility_accn_prefix_cd > 0)
     accession_fmt->qual[d1.seq].site_prefix_cd = l.facility_accn_prefix_cd
    ELSE
     accession_fmt->qual[d1.seq].site_prefix_cd = acc_settings->default_site_cd
    ENDIF
   WITH nocounter, outerjoin = d1, dontcare = l
  ;end select
  RETURN(curqual)
 END ;Subroutine
 SUBROUTINE (accessionclass(no_param=i2(value)) =i2)
  SELECT INTO "nl:"
   d1.seq, ps.accession_class_cd, ac.accession_format_cd
   FROM (dummyt d1  WITH seq = value(nbr_to_assign)),
    procedure_specimen_type ps,
    accession_class ac
   PLAN (d1
    WHERE (accession_fmt->qual[d1.seq].accession_format_cd=0)
     AND (accession_fmt->qual[d1.seq].catalog_cd > 0))
    JOIN (ps
    WHERE (accession_fmt->qual[d1.seq].specimen_type_cd=ps.specimen_type_cd)
     AND (accession_fmt->qual[d1.seq].catalog_cd=ps.catalog_cd))
    JOIN (ac
    WHERE ps.accession_class_cd=ac.accession_class_cd)
   DETAIL
    accession_fmt->qual[d1.seq].accession_class_cd = ac.accession_class_cd, accession_fmt->qual[d1
    .seq].accession_format_cd = ac.accession_format_cd
   WITH nocounter
  ;end select
  RETURN(curqual)
 END ;Subroutine
 SUBROUTINE (accessionassignxref(no_param=i2(value)) =i2)
  SELECT INTO "nl:"
   d1.seq, aax.site_prefix_cd, accession_fmt->qual[d1.seq].accession_format_cd,
   aax.accession_assignment_pool_id
   FROM (dummyt d1  WITH seq = value(nbr_to_assign)),
    accession_assign_xref aax
   PLAN (d1
    WHERE (accession_fmt->qual[d1.seq].accession_class_cd != - (1)))
    JOIN (aax
    WHERE (accession_fmt->qual[d1.seq].accession_format_cd=aax.accession_format_cd)
     AND (accession_fmt->qual[d1.seq].site_prefix_cd=aax.site_prefix_cd))
   DETAIL
    accession_fmt->qual[d1.seq].accession_pool_id = aax.accession_assignment_pool_id
    IF ((accession_fmt->qual[d1.seq].activity_type_cd=0))
     accession_fmt->qual[d1.seq].activity_type_cd = aax.activity_type_cd
    ENDIF
   WITH nocounter
  ;end select
  RETURN(curqual)
 END ;Subroutine
 SUBROUTINE (codevalueinfo(no_param=i2(value)) =i2)
   FOR (uar_idx = 1 TO nbr_to_assign)
     SET an_mean = fillstring(12," ")
     SET an_display = fillstring(40," ")
     IF ((accession_fmt->qual[uar_idx].accession_format_cd > 0))
      SET an_display = uar_get_code_display(accession_fmt->qual[uar_idx].accession_format_cd)
      IF (textlen(trim(an_display))=0)
       SELECT INTO "nl:"
        c.display, c.cdf_meaning
        FROM code_value c
        PLAN (c
         WHERE (c.code_value=accession_fmt->qual[uar_idx].accession_format_cd))
        DETAIL
         an_display = c.display, an_mean = c.cdf_meaning
        WITH nocounter
       ;end select
      ELSE
       SET an_mean = uar_get_code_meaning(accession_fmt->qual[uar_idx].accession_format_cd)
      ENDIF
      SET accession_fmt->qual[uar_idx].alpha_prefix = substring(1,2,an_display)
      SET accession_fmt->qual[uar_idx].accession_format_mean = trim(substring(1,3,an_mean))
     ENDIF
     IF ((accession_fmt->qual[uar_idx].site_prefix_cd > 0))
      SET acc_site_prefix_cd = accession_fmt->qual[uar_idx].site_prefix_cd
      EXECUTE accession_site_code
      SET accession_fmt->qual[uar_idx].site_prefix_disp = acc_site_prefix
     ENDIF
     SET t1 = cnvtdatetime(cnvtdate(accession_fmt->qual[uar_idx].accession_dt_tm),cnvttime(
       accession_fmt->qual[uar_idx].accession_dt_tm))
     SET accession_fmt->qual[uar_idx].accession_dt_tm = t1
     SET days = datetimecmp(acc_settings->assignment_dt_tm,accession_fmt->qual[uar_idx].
      accession_dt_tm)
     IF (days < 0)
      SET accession_status = acc_future
      SET accession_meaning = "Invalid assignment date/time (future accession)"
      RETURN(0)
     ENDIF
     SET d1 = cnvtdatetime(null)
     SET d2 = cnvtdatetime(accession_fmt->qual[uar_idx].accession_dt_tm)
     IF (d1=d2)
      SET accession_status = acc_null_dt_tm
      SET accession_meaning = "Invalid assignment date/time (null)"
      RETURN(0)
     ENDIF
     SET accession_fmt->qual[uar_idx].accession_year = year(accession_fmt->qual[uar_idx].
      accession_dt_tm)
     SET accession_fmt->qual[uar_idx].accession_day = julian(accession_fmt->qual[uar_idx].
      accession_dt_tm)
   ENDFOR
   FOR (uar_idx = 1 TO nbr_to_group)
    SET t1 = cnvtdatetime(cnvtdate(accession_grp->qual[uar_idx].accession_dt_tm),cnvttime(
      accession_grp->qual[uar_idx].accession_dt_tm))
    SET accession_grp->qual[uar_idx].accession_dt_tm = t1
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (accessionnetting(no_param=i2(value)) =i2)
   DECLARE ai_idx = i2 WITH noconstant(0)
   DECLARE gi_idx = i2 WITH noconstant(0)
   DECLARE activity_ind = i2 WITH noconstant(0)
   FOR (a_idx = 1 TO nbr_to_assign)
    IF ((accession_fmt->qual[a_idx].activity_type_mean=ap_cdf))
     SET activity_ind = 0
    ELSE
     SET activity_ind = 1
    ENDIF
    IF ((accession_fmt->qual[a_idx].accession_pool_id > 0))
     SET an_idx = 1
     SET new_acc = 1
     SET stat = alterlist(accession_fmt->qual[a_idx].linked_qual,0)
     WHILE (an_idx < a_idx)
      IF ((accession_fmt->qual[a_idx].accession_class_cd > 0))
       IF ((accession_fmt->qual[a_idx].site_prefix_cd=accession_fmt->qual[an_idx].site_prefix_cd)
        AND (accession_fmt->qual[a_idx].accession_class_cd=accession_fmt->qual[an_idx].
       accession_class_cd)
        AND (accession_fmt->qual[a_idx].accession_format_cd=accession_fmt->qual[an_idx].
       accession_format_cd)
        AND (accession_fmt->qual[a_idx].accession_dt_tm=accession_fmt->qual[an_idx].accession_dt_tm)
        AND (accession_fmt->qual[a_idx].accession_pool_id=accession_fmt->qual[an_idx].
       accession_pool_id)
        AND (accession_fmt->qual[a_idx].accession_flag=accession_fmt->qual[an_idx].accession_flag))
        IF ((accession_fmt->qual[a_idx].catalog_cd=accession_fmt->qual[an_idx].catalog_cd)
         AND (accession_fmt->qual[a_idx].specimen_type_cd=accession_fmt->qual[an_idx].
        specimen_type_cd)
         AND activity_ind=1)
         SET new_acc = 1
        ELSE
         IF ((accession_fmt->qual[an_idx].accession_info_pos > 0))
          SET new_acc = collectionpriorityind(accession_fmt->qual[a_idx].collection_priority_cd,
           accession_fmt->qual[a_idx].group_with_other_flag,accession_fmt->qual[an_idx].
           collection_priority_cd,accession_fmt->qual[an_idx].group_with_other_flag)
          IF (new_acc=0
           AND activity_ind=1)
           SET pos = accession_fmt->qual[an_idx].accession_parent
           IF (pos > 0)
            IF ((accession_fmt->qual[a_idx].catalog_cd=accession_fmt->qual[pos].catalog_cd)
             AND (accession_fmt->qual[a_idx].specimen_type_cd=accession_fmt->qual[pos].
            specimen_type_cd))
             SET new_acc = 1
            ELSE
             FOR (i = 1 TO size(accession_fmt->qual[pos].linked_qual,5))
              SET _pos = accession_fmt->qual[pos].linked_qual[i].linked_pos
              IF ((accession_fmt->qual[a_idx].catalog_cd=accession_fmt->qual[_pos].catalog_cd)
               AND (accession_fmt->qual[a_idx].specimen_type_cd=accession_fmt->qual[_pos].
              specimen_type_cd))
               SET new_acc = 1
              ENDIF
             ENDFOR
            ENDIF
           ENDIF
           IF (new_acc=0
            AND size(accession_fmt->qual[an_idx].linked_qual,5) > 0)
            FOR (i = 1 TO size(accession_fmt->qual[an_idx].linked_qual,5))
             SET _pos = accession_fmt->qual[an_idx].linked_qual[i].linked_pos
             IF ((accession_fmt->qual[a_idx].catalog_cd=accession_fmt->qual[_pos].catalog_cd)
              AND (accession_fmt->qual[a_idx].specimen_type_cd=accession_fmt->qual[_pos].
             specimen_type_cd))
              SET new_acc = 1
             ENDIF
            ENDFOR
           ENDIF
          ENDIF
          IF (new_acc=0)
           SET accession_fmt->qual[a_idx].accession_info_pos = accession_fmt->qual[an_idx].
           accession_info_pos
           SET accession_fmt->qual[a_idx].accession_parent = an_idx
           SET link = (size(accession_fmt->qual[an_idx].linked_qual,5)+ 1)
           SET stat = alterlist(accession_fmt->qual[an_idx].linked_qual,link)
           SET accession_fmt->qual[an_idx].linked_qual[link].linked_pos = a_idx
           SET an_idx = a_idx
          ELSE
           SET accession_fmt->qual[a_idx].accession_info_pos = 0
           SET accession_fmt->qual[a_idx].accession_parent = 0
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      SET an_idx += 1
     ENDWHILE
     IF (new_acc=1)
      IF (nbr_to_group > 0)
       FOR (i = 1 TO nbr_to_group)
         IF ((accession_fmt->qual[a_idx].site_prefix_cd=accession_grp->qual[i].site_prefix_cd)
          AND (accession_fmt->qual[a_idx].accession_class_cd=accession_grp->qual[i].
         accession_class_cd)
          AND (accession_fmt->qual[a_idx].accession_format_cd=accession_grp->qual[i].
         accession_format_cd)
          AND (accession_fmt->qual[a_idx].accession_dt_tm=accession_grp->qual[i].accession_dt_tm)
          AND (accession_fmt->qual[a_idx].accession_pool_id=accession_grp->qual[i].accession_pool_id)
          AND (accession_fmt->qual[a_idx].accession_flag=accession_grp->qual[i].accession_flag))
          IF ((accession_fmt->qual[a_idx].catalog_cd=accession_grp->qual[i].catalog_cd)
           AND (accession_fmt->qual[a_idx].specimen_type_cd=accession_grp->qual[i].specimen_type_cd)
           AND (accession_fmt->qual[a_idx].service_area_cd=accession_grp->qual[i].service_area_cd)
           AND activity_ind=1)
           SET new_acc = 1
          ELSE
           SET new_acc = collectionpriorityind(accession_fmt->qual[a_idx].collection_priority_cd,
            accession_fmt->qual[a_idx].group_with_other_flag,accession_grp->qual[i].
            collection_priority_cd,accession_grp->qual[i].group_with_other_flag)
           IF (new_acc=0)
            SET accession_fmt->qual[a_idx].accession = accession_grp->qual[i].accession
            SET accession_fmt->qual[a_idx].accession_id = accession_grp->qual[i].accession_id
            SET accession_fmt->qual[a_idx].assignment_status = acc_success
            SET accession_fmt->qual[a_idx].assignment_meaning =
            "Order grouped on to an existing accession"
            SET new_acc = 0
            SET i = nbr_to_group
            SET gi_idx += 1
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      IF (new_acc=1)
       SET ai_idx += 1
       SET accession_info->qual[ai_idx].site_prefix_cd = accession_fmt->qual[a_idx].site_prefix_cd
       SET accession_info->qual[ai_idx].site_prefix_disp = accession_fmt->qual[a_idx].
       site_prefix_disp
       SET accession_info->qual[ai_idx].accession_class_cd = accession_fmt->qual[a_idx].
       accession_class_cd
       SET accession_info->qual[ai_idx].accession_format_cd = accession_fmt->qual[a_idx].
       accession_format_cd
       SET accession_info->qual[ai_idx].accession_format_mean = accession_fmt->qual[a_idx].
       accession_format_mean
       SET accession_info->qual[ai_idx].alpha_prefix = accession_fmt->qual[a_idx].alpha_prefix
       SET accession_info->qual[ai_idx].accession_pool_id = accession_fmt->qual[a_idx].
       accession_pool_id
       SET accession_info->qual[ai_idx].accession_dt_tm = accession_fmt->qual[a_idx].accession_dt_tm
       SET accession_info->qual[ai_idx].accession_year = year(accession_fmt->qual[a_idx].
        accession_dt_tm)
       SET accession_info->qual[ai_idx].accession_day = julian(accession_fmt->qual[a_idx].
        accession_dt_tm)
       SET accession_info->qual[ai_idx].assignment_status = - (1)
       SET accession_info->qual[ai_idx].assignment_meaning = ""
       SET accession_info->qual[ai_idx].accession = ""
       IF ((accession_info->qual[ai_idx].accession_format_cd > 0))
        SET accession_info->qual[ai_idx].assignment_date = cnvtdatetimeutc(cnvtdatetime(cnvtdate2(
           concat("0101",cnvtstring(accession_info->qual[ai_idx].accession_year,4,0,r)),"mmddyyyy"),0
          ),2)
       ELSE
        SET accession_info->qual[ai_idx].assignment_date = cnvtdatetimeutc(cnvtdatetime(cnvtdate(
           accession_fmt->qual[a_idx].accession_dt_tm),0),2)
       ENDIF
       SET accession_fmt->qual[a_idx].accession_info_pos = ai_idx
      ENDIF
     ENDIF
    ENDIF
   ENDFOR
   SET stat = alterlist(accession_info->qual,ai_idx)
   IF (ai_idx=0
    AND gi_idx=0)
    SET accession_status = acc_error
    SET accession_meaning = "Error netting orders to an accession"
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (accessionassignment(ai_max=i2(value)) =i2)
   DECLARE accession_seq_nbr = i4 WITH noconstant(0)
   DECLARE accession_increment = i2 WITH noconstant(0)
   DECLARE error_code = i4 WITH noconstant(0), protect
   DECLARE error_string = vc WITH noconstant(" "), protect
   SELECT INTO "nl:"
    d1.seq, pool_id = accession_info->qual[d1.seq].accession_pool_id, assign_date = accession_info->
    qual[d1.seq].assignment_date
    FROM (dummyt d1  WITH seq = value(ai_max))
    PLAN (d1
     WHERE (accession_info->qual[d1.seq].accession_pool_id > 0))
    ORDER BY pool_id, assign_date, d1.seq
    HEAD REPORT
     pq_cnt = 0, stat = alterlist(accession_info->proc_qual,ai_max)
    DETAIL
     pq_cnt += 1, accession_info->proc_qual[pq_cnt].info_index = d1.seq
    WITH nocounter
   ;end select
   FOR (j = 1 TO ai_max)
     SET i = accession_info->proc_qual[j].info_index
     SET accession_seq_nbr = 0
     SET accession_increment = 0
     SELECT INTO "nl:"
      aa.accession_seq_nbr, aa.increment_value
      FROM accession_assignment aa
      WHERE (aa.acc_assign_pool_id=accession_info->qual[i].accession_pool_id)
       AND aa.acc_assign_date=cnvtdatetimeutc(accession_info->qual[i].assignment_date,0)
      DETAIL
       accession_seq_nbr = aa.accession_seq_nbr, accession_increment = aa.increment_value
      WITH nocounter, forupdatewait(aa)
     ;end select
     SET error_code = error(error_string,0)
     CALL echo(build("Error Code for getting ACC_POOL: outside if",error_code))
     IF (error_code > 0)
      CALL echo("inside ACC_TEMPLATE if")
      SET accession_status = acc_template
      SET accession_meaning = "Error getting accession pool information"
      RETURN(0)
     ENDIF
     IF (curqual=0)
      SELECT INTO "nl:"
       aap.increment_value, aap.initial_value
       FROM accession_assign_pool aap
       WHERE (aap.accession_assignment_pool_id=accession_info->qual[i].accession_pool_id)
       DETAIL
        accession_increment = aap.increment_value, accession_seq_nbr = aap.initial_value
       WITH nocounter, forupdatewait(aap)
      ;end select
      CALL echo(build("Error Code for getting ACC_POOL; outside if",error_code))
      IF (curqual=0)
       SET accession_status = acc_template
       SET accession_meaning = "Error getting accession pool information"
       RETURN(0)
      ENDIF
      SET error_code = error(error_string,0)
      CALL echo(build("Error Code for getting ACC_POOL",error_code))
      IF (error_code > 0)
       CALL echo("inside ACC_Template 2nd if")
       SET accession_status = acc_template
       SET accession_meaning = "Error getting accession pool information"
       RETURN(0)
      ENDIF
      SELECT INTO "nl:"
       aa.accession_seq_nbr, aa.increment_value
       FROM accession_assignment aa
       WHERE (aa.acc_assign_pool_id=accession_info->qual[i].accession_pool_id)
        AND aa.acc_assign_date=cnvtdatetimeutc(accession_info->qual[i].assignment_date,0)
       DETAIL
        accession_seq_nbr = aa.accession_seq_nbr, accession_increment = aa.increment_value
       WITH nocounter, forupdatewait(aa)
      ;end select
      SET error_code = error(error_string,0)
      CALL echo(build("Error Code for getting ACC_POOL: outside if",error_code))
      IF (error_code > 0)
       SET accession_status = acc_pool
       SET accession_meaning = "Error inserting accession pool on the accession_assignment table"
       RETURN(0)
      ENDIF
      IF (curqual=0)
       INSERT  FROM accession_assignment aa
        SET aa.acc_assign_pool_id = accession_info->qual[i].accession_pool_id, aa.acc_assign_date =
         cnvtdatetimeutc(accession_info->qual[i].assignment_date,0), aa.accession_seq_nbr =
         accession_seq_nbr,
         aa.increment_value = accession_increment, aa.last_increment_dt_tm = cnvtdatetime(sysdate),
         aa.updt_dt_tm = cnvtdatetime(sysdate),
         aa.updt_id = reqinfo->updt_id, aa.updt_task = reqinfo->updt_task, aa.updt_applctx = reqinfo
         ->updt_applctx,
         aa.updt_cnt = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET accession_status = acc_pool
        SET accession_meaning = "Error inserting accession pool on the accession_assignment table"
        RETURN(0)
       ENDIF
       SET error_code = error(error_string,0)
       CALL echo(build("Error Code for inserting ACC_POOL",error_code))
       IF (error_code > 0)
        SET accession_status = acc_pool
        SET accession_meaning = "Error inserting accession pool on the accession_assignment table"
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
     SET acc_loop = 1
     SET accession_status = acc_error
     WHILE (acc_loop=1)
       SET accession_info->qual[i].accession_seq_nbr = accession_seq_nbr
       SET accession_info->qual[i].accession = fillstring(20," ")
       SET accession_str->site_prefix_disp = accession_info->qual[i].site_prefix_disp
       SET accession_str->accession_year = accession_info->qual[i].accession_year
       SET accession_str->accession_day = accession_info->qual[i].accession_day
       SET accession_str->alpha_prefix = accession_info->qual[i].alpha_prefix
       SET accession_str->accession_seq_nbr = accession_info->qual[i].accession_seq_nbr
       SET accession_str->accession_pool_id = accession_info->qual[i].accession_pool_id
       EXECUTE accession_string
       SET accession_info->qual[i].accession = accession_nbr
       SET accession_chk->check_disp_ind = acc_settings->check_disp_ind
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
       EXECUTE accession_check
       IF (accession_status=acc_success)
        SET accession_info->qual[i].assignment_status = accession_status
        SET accession_info->qual[i].assignment_meaning = accession_meaning
        SET accession_info->qual[i].accession_id = accession_id
        SET acc_loop = 0
       ELSEIF (accession_status != acc_duplicate)
        RETURN(0)
       ENDIF
       SET accession_seq_nbr += accession_increment
     ENDWHILE
     IF (accession_status=acc_success)
      UPDATE  FROM accession_assignment aa
       SET aa.accession_seq_nbr = accession_seq_nbr, aa.updt_dt_tm = cnvtdatetime(sysdate), aa
        .updt_id = reqinfo->updt_id,
        aa.updt_task = reqinfo->updt_task, aa.updt_applctx = reqinfo->updt_applctx, aa.updt_cnt = (aa
        .updt_cnt+ 1)
       PLAN (aa
        WHERE (aa.acc_assign_pool_id=accession_info->qual[i].accession_pool_id)
         AND aa.acc_assign_date=cnvtdatetimeutc(accession_info->qual[i].assignment_date,0))
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET assignment_status = acc_pool_sequence
       SET assignment_meaning = "Error updating the accession pool sequence number"
       RETURN(0)
      ENDIF
     ENDIF
   ENDFOR
   IF (accession_status=acc_success)
    FOR (i = 1 TO nbr_to_assign)
     SET info_pos = accession_fmt->qual[i].accession_info_pos
     IF (info_pos > 0)
      SET accession_fmt->qual[i].accession_id = accession_info->qual[info_pos].accession_id
      SET accession_fmt->qual[i].accession_seq_nbr = accession_info->qual[info_pos].accession_seq_nbr
      SET accession_fmt->qual[i].assignment_meaning = accession_info->qual[info_pos].
      assignment_meaning
      SET accession_fmt->qual[i].assignment_status = accession_info->qual[info_pos].assignment_status
      SET accession_fmt->qual[i].accession = accession_info->qual[info_pos].accession
      SET accession_fmt->qual[i].accession_formatted = cnvtacc(accession_info->qual[info_pos].
       accession)
     ENDIF
    ENDFOR
    IF ((accession_fmt->insert_aor_ind=1))
     INSERT  FROM accession_order_r aor,
       (dummyt d1  WITH seq = value(nbr_to_assign))
      SET aor.order_id = accession_fmt->qual[d1.seq].order_id, aor.accession_id = accession_fmt->
       qual[d1.seq].accession_id, aor.accession = accession_fmt->qual[d1.seq].accession,
       aor.activity_type_cd = accession_fmt->qual[d1.seq].activity_type_cd, aor.primary_flag = 0, aor
       .updt_dt_tm = cnvtdatetime(sysdate),
       aor.updt_id = reqinfo->updt_id, aor.updt_task = reqinfo->updt_task, aor.updt_applctx = reqinfo
       ->updt_applctx,
       aor.updt_cnt = 0
      PLAN (d1
       WHERE (accession_fmt->qual[d1.seq].order_id > 0)
        AND (accession_fmt->qual[d1.seq].assignment_status=acc_success))
       JOIN (aor)
      WITH nocounter
     ;end insert
     IF (curqual != nbr_to_assign)
      SET accession_status = acc_error
      SET accession_meaning = "Error inserting accession_order table"
      RETURN(0)
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (collectionpriorityind(cp_cd1=f8(value),gwo_flag1=i2(value),cp_cd2=f8(value),gwo_flag2=i2
  (value)) =i2)
   IF (cp_cd1 > 0
    AND cp_cd2 > 0
    AND cp_cd1 != cp_cd2)
    IF (gwo_flag1 > 0
     AND gwo_flag2 > 0)
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (collectionpriorityinfo(fmt_ind=i2(value),cp_size=i2(value)) =i2)
   IF (cp_size=0)
    RETURN(0)
   ENDIF
   IF (fmt_ind=1)
    SELECT INTO "nl:"
     d1.seq, cp.collection_priority_cd, cp.group_with_other_flag
     FROM (dummyt d1  WITH seq = value(cp_size)),
      collection_priority cp
     PLAN (d1
      WHERE (accession_fmt->qual[d1.seq].collection_priority_cd > 0))
      JOIN (cp
      WHERE (accession_fmt->qual[d1.seq].collection_priority_cd=cp.collection_priority_cd))
     DETAIL
      accession_fmt->qual[d1.seq].group_with_other_flag = cp.group_with_other_flag
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     d1.seq, cp.collection_priority_cd, cp.group_with_other_flag
     FROM (dummyt d1  WITH seq = value(cp_size)),
      collection_priority cp
     PLAN (d1
      WHERE (accession_grp->qual[d1.seq].collection_priority_cd > 0))
      JOIN (cp
      WHERE (accession_grp->qual[d1.seq].collection_priority_cd=cp.collection_priority_cd))
     DETAIL
      accession_grp->qual[d1.seq].group_with_other_flag = cp.group_with_other_flag
     WITH nocounter
    ;end select
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (activitytypeinfo(fmt_ind=i2(value),at_sze=i2(value)) =i2)
   IF (at_sze=0)
    RETURN(0)
   ENDIF
   IF (fmt_ind=1)
    SELECT INTO "nl:"
     d1.seq, oc.catalog_cd, oc.activity_type_cd
     FROM (dummyt d1  WITH seq = value(at_sze)),
      order_catalog oc
     PLAN (d1
      WHERE (accession_fmt->qual[d1.seq].catalog_cd > 0)
       AND (accession_fmt->qual[d1.seq].activity_type_cd=0))
      JOIN (oc
      WHERE (oc.catalog_cd=accession_fmt->qual[d1.seq].catalog_cd))
     DETAIL
      accession_fmt->qual[d1.seq].activity_type_cd = oc.activity_type_cd
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     d1.seq, oc.catalog_cd, oc.activity_type_cd
     FROM (dummyt d1  WITH seq = value(at_sze)),
      order_catalog oc
     PLAN (d1
      WHERE (accession_grp->qual[d1.seq].catalog_cd > 0)
       AND (accession_grp->qual[d1.seq].activity_type_cd=0))
      JOIN (oc
      WHERE (oc.catalog_cd=accession_grp->qual[d1.seq].catalog_cd))
     DETAIL
      accession_grp->qual[d1.seq].activity_type_cd = oc.activity_type_cd
     WITH nocounter
    ;end select
   ENDIF
   RETURN(1)
 END ;Subroutine
END GO
