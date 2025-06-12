CREATE PROGRAM ct_stratum_a_c_func:dba
 RECORD stratum_a_c_func_s(
   1 curdatetime = dq8
   1 status_chg_reason_cd = f8
   1 organization_id = f8
   1 prot_amendment_id = f8
   1 stratum_label = c100
   1 stratum_cd = f8
   1 stratum_description = vc
   1 stratum_status_cd = f8
   1 stratum_cohort_type_cd = f8
   1 length_evaluation = i4
   1 length_evaluation_uom_cd = f8
   1 updt_cnt = i4
   1 parent_stratum_id = f8
 ) WITH protect
 RECORD stratum(
   1 stratum_list[*]
     2 curdatetime = dq8
     2 prot_stratum_id = f8
     2 stratum_id = f8
     2 parent_stratum_id = f8
     2 status_chg_reason_cd = f8
     2 organization_id = f8
     2 prot_amendment_id = f8
     2 stratum_label = c100
     2 stratum_cd = f8
     2 stratum_description = vc
     2 stratum_status_cd = f8
     2 stratum_cohort_type_cd = f8
     2 length_evaluation = i4
     2 length_evaluation_uom_cd = f8
     2 updt_cnt = i4
 )
 RECORD amdlist(
   1 amdlist[*]
     2 prot_amendment_id = f8
 )
 IF ( NOT (validate(amendment)))
  RECORD amendment(
    1 qual[*]
      2 prot_amendment_id = f8
      2 prot_amendment_nbr = i4
      2 revision_nbr = i4
      2 delete_ind = i2
  )
  DECLARE amd_list_size = i2 WITH public, noconstant(0)
 ENDIF
 DECLARE stratumlistsize = i2 WITH public, noconstant(0)
 DECLARE supercededcd = f8 WITH public, noconstant(0.0)
 DECLARE amendmentnbr = i2 WITH public, noconstant(- (1))
 DECLARE amendnbrstr = vc WITH public, noconstant("")
 DECLARE revision_seq = i2 WITH public, noconstant(0)
 DECLARE amdlistsize = i2 WITH public, noconstant(0)
 DECLARE stratum_a_c_func_ss_size = i2 WITH public, noconstant(0)
 DECLARE stratum_a_c_func_cs_size = i2 WITH public, noconstant(0)
 DECLARE stratum_a_c_func_susps_size = i2 WITH public, noconstant(0)
 DECLARE stratum_a_c_func_doupdate = i2 WITH public, noconstant(0)
 DECLARE stratum_a_c_func_continue = i2 WITH public, noconstant(0)
 DECLARE stratum_a_c_func_stratumid = f8 WITH public, noconstant(0.0)
 DECLARE stratum_a_c_func_protstratumid = f8 WITH public, noconstant(0.0)
 DECLARE stratum_a_c_func_i = i2 WITH public, noconstant(0)
 DECLARE stratum_a_c_func_k = i2 WITH public, noconstant(0)
 DECLARE newcohortind = i2 WITH public, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE parent_prot_master_id = f8 WITH public, noconstant(0.0)
 DECLARE revision_ind = i2 WITH public, noconstant(0)
 DECLARE collab_ind = i2 WITH public, noconstant(0)
 DECLARE stratum_ctms_extn = vc WITH public, noconstant("")
 SET stratum_a_c_func_ss_size = size(request->ss,5)
 SET stratum_a_c_func_doupdate = false
 SET stratum_a_c_func_continue = false
 SET reply->statusfunc = "F"
 SET stat = uar_get_meaning_by_codeset(17274,"SUPERCEDED",1,supercededcd)
 SET newcohortind = false
 SET stat = alterlist(reply->a_c_results,stratum_a_c_func_ss_size)
 SELECT INTO "nl:"
  FROM prot_amendment pa,
   prot_master pm
  PLAN (pa
   WHERE (pa.prot_amendment_id=request->prot_amendment_id))
   JOIN (pm
   WHERE pm.prot_master_id=pa.prot_master_id)
  DETAIL
   amendmentnbr = pa.amendment_nbr, revision_seq = pa.revision_seq, parent_prot_master_id = pm
   .parent_prot_master_id,
   revision_ind = pa.revision_ind
  WITH nocounter
 ;end select
 IF ((amendmentnbr > - (1)))
  SET amendnbrstr = build("pa.amendment_nbr >=",amendmentnbr)
  SELECT
   FROM prot_amendment pa,
    prot_master pm
   PLAN (pm
    WHERE pm.prot_master_id=parent_prot_master_id
     AND pm.collab_site_org_id=0
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_nbr=amendmentnbr
     AND pa.revision_seq=revision_seq)
   DETAIL
    amd_list_size += 1
    IF (mod(amd_list_size,10)=1)
     stat = alterlist(amendment->qual,(amd_list_size+ 9))
    ENDIF
    amendment->qual[amd_list_size].prot_amendment_id = pa.prot_amendment_id, amendment->qual[
    amd_list_size].prot_amendment_nbr = pa.amendment_nbr, amendment->qual[amd_list_size].revision_nbr
     = pa.revision_seq
    IF (pa.amendment_status_cd=supercededcd)
     amendment->qual[amd_list_size].delete_ind = 0
    ELSE
     amendment->qual[amd_list_size].delete_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SET amendnbrstr = "1=1"
 ENDIF
 SELECT
  FROM prot_amendment pa,
   prot_master pm,
   (dummyt d  WITH seq = value(amd_list_size))
  PLAN (d)
   JOIN (pm
   WHERE pm.prot_master_id=parent_prot_master_id
    AND pm.collab_site_org_id=0
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id
    AND (pa.prot_amendment_id != amendment->qual[d.seq].prot_amendment_id)
    AND pa.amendment_status_cd != supercededcd
    AND parser(amendnbrstr))
  DETAIL
   skip = 0
   IF (pa.amendment_nbr=amendmentnbr)
    IF (pa.revision_seq < revision_seq)
     skip = 1
    ENDIF
   ENDIF
   IF (skip=0)
    amd_list_size += 1
    IF (mod(amd_list_size,10)=1)
     stat = alterlist(amendment->qual,(amd_list_size+ 9))
    ENDIF
    amendment->qual[amd_list_size].prot_amendment_id = pa.prot_amendment_id, amendment->qual[
    amd_list_size].prot_amendment_nbr = pa.amendment_nbr, amendment->qual[amd_list_size].revision_nbr
     = pa.revision_seq,
    amendment->qual[amd_list_size].delete_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (amd_list_size > 0)
  SELECT
   FROM prot_master pm,
    prot_amendment pa,
    (dummyt d  WITH seq = value(amd_list_size))
   PLAN (d)
    JOIN (pm
    WHERE pm.parent_prot_master_id=parent_prot_master_id
     AND pm.prot_master_id != parent_prot_master_id
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_status_cd != supercededcd
     AND (pa.amendment_nbr=amendment->qual[d.seq].prot_amendment_nbr)
     AND (pa.revision_seq=amendment->qual[d.seq].revision_nbr))
   DETAIL
    amd_list_size += 1
    IF (mod(amd_list_size,10)=1)
     stat = alterlist(amendment->qual,(amd_list_size+ 9))
    ENDIF
    amendment->qual[amd_list_size].prot_amendment_id = pa.prot_amendment_id, amendment->qual[
    amd_list_size].prot_amendment_nbr = pa.amendment_nbr, amendment->qual[amd_list_size].revision_nbr
     = pa.revision_seq,
    amendment->qual[amd_list_size].delete_ind = amendment->qual[d.seq].delete_ind
   WITH nocounter
  ;end select
  SET stat = alterlist(amendment->qual,amd_list_size)
 ENDIF
 CALL echo(build("STRATUM_A_C_FUNC_Ss_Size= ",stratum_a_c_func_ss_size))
 FOR (stratum_a_c_func_i = 1 TO stratum_a_c_func_ss_size)
   SET reply->a_c_results[stratum_a_c_func_i].a_key = build(request->ss[stratum_a_c_func_i].a_key)
   SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "F"
   SET reply->a_c_results[stratum_a_c_func_i].prot_stratum_id = 0.0
   SET reply->a_c_results[stratum_a_c_func_i].stratum_id = 0.0
   SET stratum_ctms_extn = ""
   IF ((request->ss[stratum_a_c_func_i].delete_indicator=false))
    SET stratum_a_c_func_continue = false
    SET stratum_a_c_func_doupdate = false
    IF ((request->ss[stratum_a_c_func_i].prot_stratum_id=0.0))
     CALL echo("This is a new stratum so get a number for both prot_stratum_id and stratum_id.")
     SELECT INTO "nl:"
      num = seq(protocol_def_seq,nextval)
      FROM dual
      DETAIL
       stratum_a_c_func_protstratumid = num
      WITH format, counter
     ;end select
     SET stratum_a_c_func_continue = true
     SET stratum_a_c_func_doupdate = true
     SET stratum_a_c_func_stratumid = stratum_a_c_func_protstratumid
     SET stratum_a_c_func_s->curdatetime = cnvtdatetime(sysdate)
     IF ((request->ss[stratum_a_c_func_i].parent_stratum_id=0.0))
      SET request->ss[stratum_a_c_func_i].parent_stratum_id = stratum_a_c_func_stratumid
      IF (revision_ind=1)
       SET revision_ind = 0
      ENDIF
     ELSE
      SET collab_ind = 1
      SELECT INTO "nl:"
       FROM prot_stratum pr_str
       WHERE (pr_str.prot_stratum_id=request->ss[stratum_a_c_func_i].parent_stratum_id)
       DETAIL
        stratum_ctms_extn = pr_str.stratum_ctms_extn_txt
       WITH nocounter
      ;end select
     ENDIF
    ELSE
     CALL echo(build("locking the prot_stratum row for update"))
     SELECT INTO "nl:"
      pr_str.*
      FROM prot_stratum pr_str
      WHERE (pr_str.prot_stratum_id=request->ss[stratum_a_c_func_i].prot_stratum_id)
      DETAIL
       stratum_a_c_func_s->curdatetime = cnvtdatetime(sysdate), stratum_a_c_func_stratumid = pr_str
       .stratum_id, stratum_a_c_func_s->status_chg_reason_cd = pr_str.status_chg_reason_cd,
       stratum_a_c_func_s->organization_id = pr_str.organization_id, stratum_a_c_func_s->
       prot_amendment_id = pr_str.prot_amendment_id, stratum_a_c_func_s->stratum_label = pr_str
       .stratum_label,
       stratum_a_c_func_s->stratum_cd = pr_str.stratum_cd, stratum_a_c_func_s->stratum_description =
       pr_str.stratum_description, stratum_a_c_func_s->stratum_status_cd = pr_str.stratum_status_cd,
       stratum_a_c_func_s->stratum_cohort_type_cd = pr_str.stratum_cohort_type_cd, stratum_a_c_func_s
       ->length_evaluation = pr_str.length_evaluation, stratum_a_c_func_s->length_evaluation_uom_cd
        = pr_str.length_evaluation_uom_cd,
       stratum_a_c_func_s->updt_cnt = pr_str.updt_cnt, stratum_a_c_func_s->parent_stratum_id = pr_str
       .parent_stratum_id, stratum_ctms_extn = pr_str.stratum_ctms_extn_txt
      WITH nocounter, forupdate(pr_str)
     ;end select
     IF (curqual=1)
      CALL echo(build("Successfully locked stratum row to update ; curqual = ",curqual))
      IF ((stratum_a_c_func_s->updt_cnt != request->ss[stratum_a_c_func_i].updt_cnt))
       SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "C"
       SET problemdescriptionsize = size(reply->probdesc,5)
       SET problemdescriptionsize += 1
       SET stat = alterlist(reply->probdesc,problemdescriptionsize)
       SET reply->probdesc[problemdescriptionsize].str = build("The changes to the [",request->ss[
        stratum_a_c_func_i].stratum_label,
        "] stratum cannot be saved because another user has modified this stratum.")
      ELSE
       SET stratum_a_c_func_doupdate = false
       IF ((request->ss[stratum_a_c_func_i].status_chg_reason_cd != stratum_a_c_func_s->
       status_chg_reason_cd))
        SET stratum_a_c_func_doupdate = true
       ENDIF
       IF ((request->ss[stratum_a_c_func_i].organization_id != stratum_a_c_func_s->organization_id))
        SET stratum_a_c_func_doupdate = true
       ENDIF
       IF ((request->ss[stratum_a_c_func_i].stratum_label != stratum_a_c_func_s->stratum_label))
        SET stratum_a_c_func_doupdate = true
       ENDIF
       IF ((request->ss[stratum_a_c_func_i].stratum_cd != stratum_a_c_func_s->stratum_cd))
        SET stratum_a_c_func_doupdate = true
       ENDIF
       IF ((request->ss[stratum_a_c_func_i].stratum_description != stratum_a_c_func_s->
       stratum_description))
        SET stratum_a_c_func_doupdate = true
       ENDIF
       IF ((request->ss[stratum_a_c_func_i].stratum_status_cd != stratum_a_c_func_s->
       stratum_status_cd))
        SET stratum_a_c_func_doupdate = true
       ENDIF
       IF ((request->ss[stratum_a_c_func_i].stratum_cohort_type_cd != stratum_a_c_func_s->
       stratum_cohort_type_cd))
        SET stratum_a_c_func_doupdate = true
       ENDIF
       IF ((request->ss[stratum_a_c_func_i].length_evaluation != stratum_a_c_func_s->
       length_evaluation))
        SET stratum_a_c_func_doupdate = true
       ENDIF
       IF ((request->ss[stratum_a_c_func_i].length_evaluation_uom_cd != stratum_a_c_func_s->
       length_evaluation_uom_cd))
        SET stratum_a_c_func_doupdate = true
       ENDIF
       IF (stratum_a_c_func_doupdate=true)
        CALL echo("the stratum data passed in IS different from what exist in the data base ")
        SET stratum_a_c_func_continue = false
        UPDATE  FROM prot_stratum pr_str
         SET pr_str.end_effective_dt_tm = cnvtdatetime(stratum_a_c_func_s->curdatetime), pr_str
          .updt_cnt = (pr_str.updt_cnt+ 1), pr_str.updt_applctx = reqinfo->updt_applctx,
          pr_str.updt_task = reqinfo->updt_task, pr_str.updt_id = reqinfo->updt_id, pr_str.updt_dt_tm
           = cnvtdatetime(sysdate)
         WHERE (pr_str.prot_stratum_id=request->ss[stratum_a_c_func_i].prot_stratum_id)
         WITH nocounter
        ;end update
        IF (curqual=0)
         SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "F"
         SET stratum_a_c_func_continue = false
        ELSE
         CALL echo("get number for the prot_stratum_id")
         SELECT INTO "nl:"
          num = seq(protocol_def_seq,nextval)
          FROM dual
          DETAIL
           stratum_a_c_func_protstratumid = num
          WITH format, counter
         ;end select
         SET stratum_a_c_func_continue = true
        ENDIF
       ELSE
        CALL echo("The stratum data passed in IS *NOT* different from what exist in the data base.")
        SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "S"
        SET stratum_a_c_func_continue = true
       ENDIF
      ENDIF
     ELSE
      CALL echo("failed to lock stratum row for update")
      SET stratum_a_c_func_continue = false
      SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "L"
     ENDIF
    ENDIF
    IF (stratum_a_c_func_doupdate=true)
     CALL echo("STRATUM_A_C_FUNC_DoUpdate = TRUE")
     SET stratum_a_c_func_continue = false
     INSERT  FROM prot_stratum pr_str
      SET pr_str.stratum_id = stratum_a_c_func_stratumid, pr_str.prot_stratum_id =
       stratum_a_c_func_protstratumid, pr_str.parent_stratum_id = request->ss[stratum_a_c_func_i].
       parent_stratum_id,
       pr_str.status_chg_reason_cd = request->ss[stratum_a_c_func_i].status_chg_reason_cd, pr_str
       .organization_id = request->ss[stratum_a_c_func_i].organization_id, pr_str.prot_amendment_id
        = request->prot_amendment_id,
       pr_str.stratum_label = request->ss[stratum_a_c_func_i].stratum_label, pr_str.stratum_cd =
       request->ss[stratum_a_c_func_i].stratum_cd, pr_str.stratum_description = request->ss[
       stratum_a_c_func_i].stratum_description,
       pr_str.stratum_ctms_extn_txt =
       IF (stratum_ctms_extn="") null
       ELSE stratum_ctms_extn
       ENDIF
       , pr_str.stratum_status_cd = request->ss[stratum_a_c_func_i].stratum_status_cd, pr_str
       .stratum_cohort_type_cd = request->ss[stratum_a_c_func_i].stratum_cohort_type_cd,
       pr_str.length_evaluation = request->ss[stratum_a_c_func_i].length_evaluation, pr_str
       .length_evaluation_uom_cd = request->ss[stratum_a_c_func_i].length_evaluation_uom_cd, pr_str
       .beg_effective_dt_tm = cnvtdatetime(stratum_a_c_func_s->curdatetime),
       pr_str.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pr_str.updt_cnt = 0,
       pr_str.updt_applctx = reqinfo->updt_applctx,
       pr_str.updt_task = reqinfo->updt_task, pr_str.updt_id = reqinfo->updt_id, pr_str.updt_dt_tm =
       cnvtdatetime(sysdate)
      WITH nocounter
     ;end insert
     IF (curqual=1)
      CALL echo("successfully inserted row into stratum table")
      SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "S"
      SET stratum_a_c_func_continue = true
     ELSE
      CALL echo("failed to insert row into stratum table")
      SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "F"
      SET stratum_a_c_func_continue = false
     ENDIF
     IF ((request->ss[stratum_a_c_func_i].prot_stratum_id=0.0)
      AND revision_ind=0)
      SET amdlistsize = 0
      SET stat = alterlist(amdlist->amdlist,amdlistsize)
      SELECT INTO "nl:"
       FROM prot_amendment pa,
        prot_master pm,
        (dummyt d  WITH seq = value(amd_list_size))
       PLAN (d)
        JOIN (pm
        WHERE pm.parent_prot_master_id=parent_prot_master_id
         AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
        JOIN (pa
        WHERE pa.prot_master_id=pm.prot_master_id
         AND (pa.prot_amendment_id != request->prot_amendment_id)
         AND pa.amendment_status_cd != supercededcd
         AND (pa.prot_amendment_id=amendment->qual[d.seq].prot_amendment_id))
       DETAIL
        skip = 0
        IF (collab_ind=1)
         IF (pm.collab_site_org_id=0)
          skip = 1
         ELSEIF (pm.collab_site_org_id > 0
          AND (pa.prot_amendment_id != request->prot_amendment_id))
          skip = 1
         ENDIF
        ENDIF
        IF (skip=0)
         amdlistsize += 1
         IF (mod(amdlistsize,10)=1)
          stat = alterlist(amdlist->amdlist,(amdlistsize+ 9))
         ENDIF
         amdlist->amdlist[amdlistsize].prot_amendment_id = pa.prot_amendment_id
        ENDIF
       WITH nocounter
      ;end select
      IF (amdlistsize > 0)
       SET stat = alterlist(amdlist->amdlist,amdlistsize)
       INSERT  FROM prot_stratum pr_str,
         (dummyt d1  WITH seq = value(amdlistsize))
        SET pr_str.stratum_id = seq(protocol_def_seq,nextval), pr_str.prot_stratum_id = seq(
          protocol_def_seq,nextval), pr_str.parent_stratum_id = request->ss[stratum_a_c_func_i].
         parent_stratum_id,
         pr_str.status_chg_reason_cd = request->ss[stratum_a_c_func_i].status_chg_reason_cd, pr_str
         .organization_id = request->ss[stratum_a_c_func_i].organization_id, pr_str.prot_amendment_id
          = amdlist->amdlist[d1.seq].prot_amendment_id,
         pr_str.stratum_label = request->ss[stratum_a_c_func_i].stratum_label, pr_str.stratum_cd =
         request->ss[stratum_a_c_func_i].stratum_cd, pr_str.stratum_description = request->ss[
         stratum_a_c_func_i].stratum_description,
         pr_str.stratum_ctms_extn_txt =
         IF (stratum_ctms_extn="") null
         ELSE stratum_ctms_extn
         ENDIF
         , pr_str.stratum_status_cd = request->ss[stratum_a_c_func_i].stratum_status_cd, pr_str
         .stratum_cohort_type_cd = request->ss[stratum_a_c_func_i].stratum_cohort_type_cd,
         pr_str.length_evaluation = request->ss[stratum_a_c_func_i].length_evaluation, pr_str
         .length_evaluation_uom_cd = request->ss[stratum_a_c_func_i].length_evaluation_uom_cd, pr_str
         .beg_effective_dt_tm = cnvtdatetime(stratum_a_c_func_s->curdatetime),
         pr_str.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pr_str.updt_cnt = 0,
         pr_str.updt_applctx = reqinfo->updt_applctx,
         pr_str.updt_task = reqinfo->updt_task, pr_str.updt_id = reqinfo->updt_id, pr_str.updt_dt_tm
          = cnvtdatetime(sysdate)
        PLAN (d1)
         JOIN (pr_str)
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET problemdescriptionsize = size(reply->probdesc,5)
        SET problemdescriptionsize += 1
        SET stat = alterlist(reply->probdesc,problemdescriptionsize)
        SET reply->probdesc[problemdescriptionsize].str =
        "failed to insert row into stratum table for all amendments"
        SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "F"
        SET stratum_a_c_func_continue = false
       ELSE
        CALL echo("successfully inserted row into stratum table for all amendments")
        SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "S"
        SET stratum_a_c_func_continue = true
       ENDIF
      ENDIF
     ENDIF
     IF ((((request->ss[stratum_a_c_func_i].prot_stratum_id != 0.0)) OR ((request->ss[
     stratum_a_c_func_i].prot_stratum_id=0.0)
      AND revision_ind=1)) )
      IF (stratum_a_c_func_doupdate=true
       AND stratum_a_c_func_continue=true)
       SET stratumlistsize = 0
       SET stat = alterlist(stratum->stratum_list,stratumlistsize)
       SELECT INTO "nl:"
        pr_str.*
        FROM prot_stratum pr_str,
         prot_amendment pa,
         (dummyt d  WITH seq = value(amd_list_size))
        PLAN (d)
         JOIN (pr_str
         WHERE (pr_str.parent_stratum_id=stratum_a_c_func_s->parent_stratum_id)
          AND pr_str.stratum_id != stratum_a_c_func_stratumid
          AND pr_str.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
         JOIN (pa
         WHERE pa.prot_amendment_id=pr_str.prot_amendment_id
          AND pa.amendment_status_cd != supercededcd
          AND (pa.prot_amendment_id=amendment->qual[d.seq].prot_amendment_id))
        DETAIL
         stratumlistsize += 1
         IF (mod(stratumlistsize,10)=1)
          stat = alterlist(stratum->stratum_list,(stratumlistsize+ 9))
         ENDIF
         stratum->stratum_list[stratumlistsize].curdatetime = cnvtdatetime(sysdate), stratum->
         stratum_list[stratumlistsize].stratum_id = pr_str.stratum_id, stratum->stratum_list[
         stratumlistsize].prot_stratum_id = pr_str.prot_stratum_id,
         stratum->stratum_list[stratumlistsize].parent_stratum_id = pr_str.parent_stratum_id, stratum
         ->stratum_list[stratumlistsize].status_chg_reason_cd = pr_str.status_chg_reason_cd, stratum
         ->stratum_list[stratumlistsize].organization_id = pr_str.organization_id,
         stratum->stratum_list[stratumlistsize].prot_amendment_id = pr_str.prot_amendment_id, stratum
         ->stratum_list[stratumlistsize].stratum_label = pr_str.stratum_label, stratum->stratum_list[
         stratumlistsize].stratum_cd = pr_str.stratum_cd,
         stratum->stratum_list[stratumlistsize].stratum_description = pr_str.stratum_description,
         stratum->stratum_list[stratumlistsize].stratum_status_cd = pr_str.stratum_status_cd, stratum
         ->stratum_list[stratumlistsize].stratum_cohort_type_cd = pr_str.stratum_cohort_type_cd,
         stratum->stratum_list[stratumlistsize].length_evaluation = pr_str.length_evaluation, stratum
         ->stratum_list[stratumlistsize].length_evaluation_uom_cd = pr_str.length_evaluation_uom_cd,
         stratum->stratum_list[stratumlistsize].updt_cnt = pr_str.updt_cnt
        WITH nocounter
       ;end select
       SET stat = alterlist(stratum->stratum_list,stratumlistsize)
       IF (stratumlistsize > 0)
        IF (curqual=0)
         SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "F"
         SET stratum_a_c_func_doupdate = false
        ELSE
         SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "S"
         SET stratum_a_c_func_doupdate = true
        ENDIF
        IF (stratum_a_c_func_doupdate=true)
         UPDATE  FROM prot_stratum pr_str,
           (dummyt d  WITH seq = value(stratumlistsize))
          SET pr_str.end_effective_dt_tm = cnvtdatetime(stratum_a_c_func_s->curdatetime), pr_str
           .updt_cnt = (pr_str.updt_cnt+ 1), pr_str.updt_applctx = reqinfo->updt_applctx,
           pr_str.updt_task = reqinfo->updt_task, pr_str.updt_id = reqinfo->updt_id, pr_str
           .updt_dt_tm = cnvtdatetime(sysdate)
          PLAN (d)
           JOIN (pr_str
           WHERE (pr_str.prot_stratum_id=stratum->stratum_list[d.seq].prot_stratum_id))
          WITH counter
         ;end update
         IF (curqual=0)
          SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "F"
          SET stratum_a_c_func_continue = false
         ELSE
          SET stratum_a_c_func_continue = true
         ENDIF
        ELSE
         SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "F"
         SET stratum_a_c_func_continue = false
        ENDIF
        IF (stratum_a_c_func_continue=true)
         INSERT  FROM prot_stratum pr_str,
           (dummyt d  WITH seq = value(stratumlistsize))
          SET pr_str.stratum_id = stratum->stratum_list[d.seq].stratum_id, pr_str.prot_stratum_id =
           seq(protocol_def_seq,nextval), pr_str.parent_stratum_id = stratum->stratum_list[d.seq].
           parent_stratum_id,
           pr_str.status_chg_reason_cd = request->ss[stratum_a_c_func_i].status_chg_reason_cd, pr_str
           .organization_id = stratum->stratum_list[d.seq].organization_id, pr_str.prot_amendment_id
            = stratum->stratum_list[d.seq].prot_amendment_id,
           pr_str.stratum_label = request->ss[stratum_a_c_func_i].stratum_label, pr_str.stratum_cd =
           request->ss[stratum_a_c_func_i].stratum_cd, pr_str.stratum_description = request->ss[
           stratum_a_c_func_i].stratum_description,
           pr_str.stratum_ctms_extn_txt =
           IF (stratum_ctms_extn="") null
           ELSE stratum_ctms_extn
           ENDIF
           , pr_str.stratum_status_cd = request->ss[stratum_a_c_func_i].stratum_status_cd, pr_str
           .stratum_cohort_type_cd = request->ss[stratum_a_c_func_i].stratum_cohort_type_cd,
           pr_str.length_evaluation = request->ss[stratum_a_c_func_i].length_evaluation, pr_str
           .length_evaluation_uom_cd = request->ss[stratum_a_c_func_i].length_evaluation_uom_cd,
           pr_str.beg_effective_dt_tm = cnvtdatetime(stratum_a_c_func_s->curdatetime),
           pr_str.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), pr_str.updt_cnt = 0,
           pr_str.updt_applctx = reqinfo->updt_applctx,
           pr_str.updt_task = reqinfo->updt_task, pr_str.updt_id = reqinfo->updt_id, pr_str
           .updt_dt_tm = cnvtdatetime(sysdate)
          PLAN (d)
           JOIN (pr_str)
          WITH nocounter
         ;end insert
         IF (curqual != 0)
          CALL echo("successfully inserted rows into stratum table")
          SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "S"
          SET stratum_a_c_func_continue = true
         ELSE
          CALL echo("failed to insert rows into stratum table")
          SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "F"
          SET stratum_a_c_func_continue = false
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ELSE
     SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "S"
    ENDIF
    IF (stratum_a_c_func_continue=true)
     SET request->ss[stratum_a_c_func_i].stratum_id = stratum_a_c_func_stratumid
     CALL echo("Dealt successfully with stratums so process cohorts")
     SET stratum_a_c_func_cs_size = size(request->ss[stratum_a_c_func_i].cs,5)
     SET reply->a_c_results[stratum_a_c_func_i].cohortsummary = "S"
     IF (stratum_a_c_func_cs_size > 0)
      SET stat = alterlist(reply->a_c_results[stratum_a_c_func_i].cohorts,stratum_a_c_func_cs_size)
     ENDIF
     FOR (stratum_a_c_func_k = 1 TO stratum_a_c_func_cs_size)
       SET reply->a_c_results[stratum_a_c_func_i].cohorts[stratum_a_c_func_k].a_key = build(request->
        ss[stratum_a_c_func_i].cs[stratum_a_c_func_k].a_key)
       IF ((request->ss[stratum_a_c_func_i].cs[stratum_a_c_func_k].delete_indicator=false))
        CALL echo("pre CT_COHORT_A_C_FUNC")
        SET cohort_a_c_func_ssindex = stratum_a_c_func_i
        SET cohort_a_c_func_csindex = stratum_a_c_func_k
        DECLARE cohort_a_c_func_amendmentnbr = i4
        SET cohort_a_c_func_amendmentnbr = amendmentnbr
        EXECUTE ct_cohort_a_c_func
        CALL echo("post CT_COHORT_A_C_FUNC")
       ELSE
        CALL echo("pre CT_COHORT_D_L_FUNC")
        SELECT INTO "nl:"
         coh.cohort_id
         FROM prot_cohort coh
         WHERE (coh.prot_cohort_id=request->ss[stratum_a_c_func_i].cs[stratum_a_c_func_k].
         prot_cohort_id)
         DETAIL
          request->ss[stratum_a_c_func_i].cs[stratum_a_c_func_k].cohort_id = coh.cohort_id, request->
          ss[stratum_a_c_func_i].cs[stratum_a_c_func_k].parent_cohort_id = coh.parent_cohort_id
         WITH nocounter
        ;end select
        SET stratumlistsize = 0
        SELECT
         ps.prot_stratum_id
         FROM prot_cohort pc,
          prot_stratum ps,
          prot_amendment pa,
          (dummyt d  WITH seq = value(amd_list_size))
         PLAN (d)
          JOIN (pc
          WHERE (pc.parent_cohort_id=request->ss[stratum_a_c_func_i].cs[stratum_a_c_func_k].
          parent_cohort_id))
          JOIN (ps
          WHERE ps.stratum_id=pc.stratum_id
           AND (ps.parent_stratum_id=request->ss[stratum_a_c_func_i].parent_stratum_id)
           AND ps.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
          JOIN (pa
          WHERE pa.prot_amendment_id=ps.prot_amendment_id
           AND pa.amendment_status_cd != supercededcd
           AND (pa.prot_amendment_id=amendment->qual[d.seq].prot_amendment_id)
           AND (amendment->qual[d.seq].delete_ind=1))
         DETAIL
          stratumlistsize += 1
          IF (mod(stratumlistsize,10)=1)
           stat = alterlist(stratum->stratum_list,(stratumlistsize+ 9))
          ENDIF
          stratum->stratum_list[stratumlistsize].prot_stratum_id = ps.prot_stratum_id, stratum->
          stratum_list[stratumlistsize].stratum_id = ps.stratum_id
         WITH nocounter
        ;end select
        SET stat = alterlist(stratum->stratum_list,stratumlistsize)
        SET cohort_d_l_func_ssindex = stratum_a_c_func_i
        SET cohort_d_l_func_csindex = stratum_a_c_func_k
        EXECUTE ct_cohort_d_l_func
        CALL echo("post CT_COHORT_D_L_FUNC")
       ENDIF
       IF ((reply->a_c_results[stratum_a_c_func_i].cohorts[stratum_a_c_func_k].cohortstatus != "S"))
        SET reply->a_c_results[stratum_a_c_func_i].cohortsummary = "F"
        SET stratum_a_c_func_continue = false
       ENDIF
     ENDFOR
    ENDIF
    IF (stratum_a_c_func_continue=true)
     SET request->ss[stratum_a_c_func_i].stratum_id = stratum_a_c_func_stratumid
     CALL echo("dealt successfully with stratums and cohorts so process suspensions")
     SET stratum_a_c_func_susps_size = size(request->ss[stratum_a_c_func_i].susps,5)
     CALL echo(build("STRATUM_A_C_FUNC_Susps_Size = ",stratum_a_c_func_susps_size))
     IF (stratum_a_c_func_susps_size > 0)
      SET stat = alterlist(reply->a_c_results[stratum_a_c_func_i].susps,stratum_a_c_func_susps_size)
     ENDIF
     SET reply->a_c_results[stratum_a_c_func_i].suspsummary = "S"
     FOR (stratum_a_c_func_k = 1 TO stratum_a_c_func_susps_size)
       SET reply->a_c_results[stratum_a_c_func_i].susps[stratum_a_c_func_k].a_key = build(request->
        ss[stratum_a_c_func_i].susps[stratum_a_c_func_k].a_key)
       CALL echo("pre CT_STRATUM_SUSP_A_C_FUNC")
       SET stratum_susp_a_c_func_ssindex = stratum_a_c_func_i
       SET stratum_susp_a_c_func_suspsindex = stratum_a_c_func_k
       EXECUTE ct_stratum_susp_a_c_func
       CALL echo("post CT_STRATUM_SUSP_A_C_FUNC")
       IF ((reply->a_c_results[stratum_a_c_func_i].susps[stratum_a_c_func_k].suspstatus != "S"))
        SET reply->a_c_results[stratum_a_c_func_i].suspsummary = "F"
        SET stratum_a_c_func_continue = false
       ENDIF
     ENDFOR
    ENDIF
    IF (stratum_a_c_func_continue=false)
     SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "F"
     CALL echo("along the way something of the stratum failed")
    ELSE
     SET reply->a_c_results[stratum_a_c_func_i].stratum_id = stratum_a_c_func_stratumid
     SET reply->a_c_results[stratum_a_c_func_i].prot_stratum_id = stratum_a_c_func_protstratumid
     SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "S"
     CALL echo("everything of the stratum went okay")
    ENDIF
   ELSE
    SET stratum_d_l_func_ssindex = stratum_a_c_func_i
    EXECUTE ct_stratum_d_l_func
    IF ((reply->a_c_results[stratum_a_c_func_i].stratumstatus != "S"))
     SET reply->a_c_results[stratum_a_c_func_i].stratumstatus = "F"
     SET stratum_a_c_func_continue = false
    ENDIF
   ENDIF
 ENDFOR
 SET reply->statusfunc = "S"
 SET last_mod = "007"
 SET mod_date = "Nov 18, 2019"
#noecho
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd += 1
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
