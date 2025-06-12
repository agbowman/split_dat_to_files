CREATE PROGRAM accession_chk:dba
 RECORD reply(
   1 assignment_meaning = c12
   1 qual[1]
     2 order_id = f8
     2 accession = c20
     2 accession_updt_cnt = i4
     2 accession_id = f8
     2 accession_status = i2
     2 accession_meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD accession_pool(
   1 qual[1]
     2 accession_pool_id = f8
     2 site_prefix_disp = c5
 )
 SET nbr_of_accessions = size(request->qual,5)
 SET stat = alter(reply->qual,nbr_of_accessions)
 SET check_cnt = nbr_of_accessions
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
   IF ((accession_str->alpha_prefix > " "))
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
#accession_chk
 SET acc_pool_idx = 0
 SET stat = alter(accession_pool->qual,nbr_of_accessions)
 SELECT INTO "nl:"
  aax.site_prefix_cd, aax.accession_format_cd, aax.accession_assignment_pool_id
  FROM (dummyt d1  WITH seq = value(size(request->qual,5))),
   accession_assign_xref aax,
   code_value c
  PLAN (d1
   WHERE d1.seq <= nbr_of_accessions)
   JOIN (aax
   WHERE (request->qual[d1.seq].accession_format_cd=aax.accession_format_cd)
    AND (request->qual[d1.seq].site_prefix_cd=aax.site_prefix_cd))
   JOIN (c
   WHERE (request->qual[d1.seq].site_prefix_cd=c.code_value))
  DETAIL
   acc_pool_idx = (acc_pool_idx+ 1), accession_pool->qual[acc_pool_idx].accession_pool_id = aax
   .accession_assignment_pool_id
   IF (c.code_value > 0)
    site_str = c.display, site_sze = size(trim(site_str))
   ELSE
    site_str = "00000", site_sze = size(site_str,1)
   ENDIF
   accession_pool->qual[d1.seq].site_prefix_disp = ""
   IF (site_sze < 5)
    FOR (i = 1 TO (5 - site_sze))
      accession_pool->qual[d1.seq].site_prefix_disp = concat(trim(accession_pool->qual[d1.seq].
        site_prefix_disp),"0")
    ENDFOR
   ENDIF
   accession_pool->qual[d1.seq].site_prefix_disp = concat(trim(accession_pool->qual[d1.seq].
     site_prefix_disp),trim(site_str))
  WITH nocounter, outerjoin = d1, dontcare = aax
 ;end select
 IF (acc_pool_idx > 0)
  FOR (i = 1 TO nbr_of_accessions)
    IF ((accession_pool->qual[i].accession_pool_id > 0))
     SET accession_str->site_prefix_disp = accession_pool->qual[i].site_prefix_disp
     SET acc_year = cnvtint(substring(8,4,request->qual[i].accession))
     IF ((acc_year > request->qual[i].accession_year))
      SET request->qual[i].accession_year = acc_year
     ENDIF
     SET accession_str->accession_year = request->qual[i].accession_year
     SET accession_str->accession_day = request->qual[i].accession_day
     SET accession_str->alpha_prefix = request->qual[i].alpha_prefix
     SET accession_str->accession_seq_nbr = request->qual[i].accession_seq_nbr
     SET accession_str->accession_pool_id = accession_pool->qual[i].accession_pool_id
     CALL accession_str(0)
     SET accession_chk->site_prefix_cd = request->qual[i].site_prefix_cd
     SET accession_chk->accession_year = request->qual[i].accession_year
     SET accession_chk->accession_day = request->qual[i].accession_day
     SET accession_chk->accession_pool_id = accession_pool->qual[i].accession_pool_id
     SET accession_chk->accession_seq_nbr = request->qual[i].accession_seq_nbr
     SET accession_chk->accession_class_cd = 0
     SET accession_chk->accession_format_cd = request->qual[i].accession_format_cd
     SET accession_chk->alpha_prefix = request->qual[i].alpha_prefix
     SET accession_chk->accession = accession_nbr
     SET accession_chk->accession_nbr_check = accession_nbr_chk
     SET accession_chk->action_ind = request->action_ind
     SET accession_chk->preactive_ind = request->qual[i].preactive_ind
     SET accession_chk->accession_updt_cnt = request->qual[i].accession_updt_cnt
     SET accession_chk->accession_id = request->qual[i].accession_id
     CALL accession_chk(0)
     SET reply->qual[i].accession = accession_nbr
     SET reply->qual[i].accession_meaning = accession_chk_meaning
     SET reply->qual[i].accession_status = accession_chk_status
     SET reply->qual[i].accession_updt_cnt = accession_updt_cnt
     IF (accession_chk_meaning="chkDupAcc")
      SET check_cnt = (check_cnt - 1)
      SET reply->qual[i].accession_id = accession_dup_id
     ELSE
      SET reply->qual[i].accession_id = accession_id
     ENDIF
    ELSE
     SET reply->qual[i].accession = accession_nbr
     SET reply->qual[i].accession_meaning = "chkPoolId"
     SET reply->qual[i].accession_status = accession_pool_id
    ENDIF
  ENDFOR
 ELSE
  SET check_cnt = 0
  SET nbr_of_accessions = 1
 ENDIF
#accession_chk_exit
 IF (check_cnt=nbr_of_accessions)
  SET reply->status_data.status = "S"
  IF ((request->action_ind=1))
   SET reply->assignment_meaning = "ACCESSION_CHK:  All accession are valid."
  ELSE
   SET reply->assignment_meaning = "ACCESSION_CHK:  All accessions assigned."
  ENDIF
 ELSE
  IF (check_cnt=0)
   SET reply->status_data.status = "F"
   IF ((request->action_ind=1))
    SET reply->assignment_meaning = "ACCESSION_CHK:  Accessions not valid."
   ELSE
    SET reply->assignment_meaning = "ACCESSION_CHK:  Accessions not assigned."
   ENDIF
  ELSE
   SET reply->status_data.status = "P"
   IF ((request->action_ind=1))
    SET reply->assignment_meaning = "ACCESSION_CHK:  Partial accession validation."
   ELSE
    SET reply->assignment_meaning = "ACCESSION_CHK:  Partial accession assignment."
   ENDIF
  ENDIF
 ENDIF
 IF ((request->acc_ord_r=1)
  AND (reply->status_data.status != "F"))
  INSERT  FROM accession_order_r a,
    (dummyt d1  WITH seq = value(size(reply->qual,5)))
   SET a.order_id = reply->qual[d1.seq].order_id, a.accession_id = reply->qual[d1.seq].accession_id,
    a.accession = reply->qual[d1.seq].accession,
    a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_task =
    reqinfo->updt_task,
    a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = 0
   PLAN (d1
    WHERE d1.seq <= nbr_of_accessions
     AND (reply->qual[d1.seq].order_id > 0)
     AND (reply->qual[d1.seq].accession_status=1))
    JOIN (a
    WHERE (reply->qual[d1.seq].order_id != a.order_id)
     AND (reply->qual[d1.seq].accession_id != a.accession_id))
   WITH nocounter
  ;end insert
 ENDIF
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
