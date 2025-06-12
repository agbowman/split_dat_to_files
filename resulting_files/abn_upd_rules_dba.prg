CREATE PROGRAM abn_upd_rules:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET active_cd = 0.0
 SET inactive_cd = 0.0
 SET principle_type_cd = 0.0
 SET source_vocabulary_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",code_cnt,active_cd)
 SET stat = uar_get_meaning_by_codeset(48,"INACTIVE",code_cnt,inactive_cd)
 SET stat = uar_get_meaning_by_codeset(401,"PROCEDURE",code_cnt,principle_type_cd)
 SET stat = uar_get_meaning_by_codeset(400,"CPT4",code_cnt,source_vocabulary_cd)
 IF (((active_cd=0.0) OR (((inactive_cd=0.0) OR (((principle_type_cd=0.0) OR (source_vocabulary_cd=
 0.0)) )) )) )
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_MEANING_BY_CODESET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE TABLE"
  GO TO exit_script
 ENDIF
 RECORD temp(
   1 from_cd = f8
   1 to_cd = f8
   1 qual_cnt = i4
   1 qual[*]
     2 action = i2
     2 status = i2
     2 fin_cd = f8
     2 encntr_type_cd = f8
     2 cpt_id = f8
     2 flg_ind = i2
     2 beg_dt = dq8
     2 carrier_id = f8
     2 diag_id = f8
 )
 SET counter = 0
 IF ((request->copy_type=1))
  SELECT INTO "nl:"
   a.*
   FROM abn_rule a
   WHERE (a.fin_class_cd=request->copy_to_fin_cd)
    AND a.active_ind=1
   WITH nocounter, forupdate(a)
  ;end select
  SET temp->qual_cnt = 0
  SELECT INTO "nl:"
   a.updt_cnt
   FROM abn_rule a
   WHERE (a.fin_class_cd=request->copy_from_fin_cd)
    AND a.active_ind=1
   HEAD REPORT
    temp->qual_cnt = 0
   DETAIL
    temp->qual_cnt = (temp->qual_cnt+ 1)
    IF (mod(temp->qual_cnt,10000)=1)
     stat = alterlist(temp->qual,(temp->qual_cnt+ 9999))
    ENDIF
    temp->qual[temp->qual_cnt].fin_cd = a.fin_class_cd, temp->qual[temp->qual_cnt].carrier_id = a
    .carrier_id, temp->qual[temp->qual_cnt].encntr_type_cd = a.encntr_type_cd,
    temp->qual[temp->qual_cnt].cpt_id = a.cpt_nomen_id, temp->qual[temp->qual_cnt].beg_dt = a
    .beg_effective_dt_tm, temp->qual[temp->qual_cnt].flg_ind = a.valid_diag_flg,
    temp->qual[temp->qual_cnt].diag_id = a.icd9_nomen_id, temp->qual[temp->qual_cnt].action = 1
   FOOT REPORT
    IF (mod(temp->qual_cnt,10000) != 0)
     stat = alterlist(temp->qual,temp->qual_cnt)
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((request->copy_type=2))
  SELECT INTO "nl:"
   a.*
   FROM abn_rule a
   WHERE (request->copy_to_fin_cd=a.fin_class_cd)
    AND (request->copy_from_encntr_type_cd=a.encntr_type_cd)
    AND (request->copy_from_cpt_cd=a.cpt_nomen_id)
    AND a.active_ind=1
   WITH nocounter, forupdate(a)
  ;end select
  SET temp->qual_cnt = 0
  SELECT INTO "nl:"
   a.updt_cnt
   FROM abn_rule a
   WHERE (a.fin_class_cd=request->copy_from_fin_cd)
    AND (a.encntr_type_cd=request->copy_from_encntr_type_cd)
    AND (a.cpt_nomen_id=request->copy_from_cpt_cd)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.active_ind=1
   HEAD REPORT
    temp->qual_cnt = 0
   DETAIL
    temp->qual_cnt = (temp->qual_cnt+ 1)
    IF (mod(temp->qual_cnt,10000)=1)
     stat = alterlist(temp->qual,(temp->qual_cnt+ 9999))
    ENDIF
    temp->qual[temp->qual_cnt].fin_cd = a.fin_class_cd, temp->qual[temp->qual_cnt].carrier_id = a
    .carrier_id, temp->qual[temp->qual_cnt].encntr_type_cd = a.encntr_type_cd,
    temp->qual[temp->qual_cnt].cpt_id = a.cpt_nomen_id, temp->qual[temp->qual_cnt].beg_dt = a
    .beg_effective_dt_tm, temp->qual[temp->qual_cnt].flg_ind = a.valid_diag_flg,
    temp->qual[temp->qual_cnt].diag_id = a.icd9_nomen_id, temp->qual[temp->qual_cnt].action = 1
   FOOT REPORT
    IF (mod(temp->qual_cnt,10000) != 0)
     stat = alterlist(temp->qual,temp->qual_cnt)
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((request->copy_type=3))
  SELECT INTO "nl:"
   a.*
   FROM abn_rule a
   WHERE (request->copy_to_fin_cd=a.fin_class_cd)
    AND (request->copy_to_encntr_type_cd=a.encntr_type_cd)
    AND (request->copy_to_cpt_cd=a.cpt_nomen_id)
    AND a.active_ind=1
   WITH nocounter, forupdate(a)
  ;end select
  SET temp->qual_cnt = 0
  SELECT INTO "nl:"
   a.updt_cnt
   FROM abn_rule a
   WHERE (a.fin_class_cd=request->copy_from_fin_cd)
    AND (a.encntr_type_cd=request->copy_from_encntr_type_cd)
    AND (a.cpt_nomen_id=request->copy_from_cpt_cd)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.active_ind=1
   HEAD REPORT
    temp->qual_cnt = 0
   DETAIL
    temp->qual_cnt = (temp->qual_cnt+ 1)
    IF (mod(temp->qual_cnt,10000)=1)
     stat = alterlist(temp->qual,(temp->qual_cnt+ 9999))
    ENDIF
    temp->qual[temp->qual_cnt].fin_cd = a.fin_class_cd, temp->qual[temp->qual_cnt].carrier_id = a
    .carrier_id, temp->qual[temp->qual_cnt].encntr_type_cd = request->copy_to_encntr_type_cd,
    temp->qual[temp->qual_cnt].cpt_id = a.cpt_nomen_id, temp->qual[temp->qual_cnt].beg_dt = a
    .beg_effective_dt_tm, temp->qual[temp->qual_cnt].flg_ind = a.valid_diag_flg,
    temp->qual[temp->qual_cnt].diag_id = a.icd9_nomen_id, temp->qual[temp->qual_cnt].action = 1
   FOOT REPORT
    IF (mod(temp->qual_cnt,10000) != 0)
     stat = alterlist(temp->qual,temp->qual_cnt)
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((request->copy_type=4))
  RECORD temp2(
    1 qual[*]
      2 cpt_id = f8
  )
  SET counter = 0
  SET tempstr = 0.0
  SET range1 = (cnvtreal(request->range_from_cpt_cd) - 1)
  SET range2 = (cnvtreal(request->range_to_cpt_cd)+ 1)
  SELECT INTO "nl:"
   *
   FROM nomenclature n
   WHERE n.source_vocabulary_cd=source_vocabulary_cd
    AND n.principle_type_cd=principle_type_cd
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND n.active_ind=1
   DETAIL
    tempstr = cnvtreal(concat(trim(n.source_identifier)))
    IF (tempstr < range2
     AND tempstr > range1)
     counter = (counter+ 1), stat = alterlist(temp2->qual,counter), temp2->qual[counter].cpt_id = n
     .nomenclature_id
    ENDIF
   WITH nocounter
  ;end select
  SET counter = 0
  SELECT INTO "nl:"
   *
   FROM abn_rule a
   WHERE (a.fin_class_cd=request->copy_from_fin_cd)
    AND (a.encntr_type_cd=request->copy_from_encntr_type_cd)
    AND (a.cpt_nomen_id=request->copy_from_cpt_cd)
    AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND a.active_ind=1
   DETAIL
    counter = (counter+ 1), stat = alterlist(temp->qual,counter), temp->qual[counter].fin_cd = a
    .fin_class_cd,
    temp->qual[counter].carrier_id = a.carrier_id, temp->qual[counter].encntr_type_cd = a
    .encntr_type_cd, temp->qual[counter].cpt_id = a.cpt_nomen_id,
    temp->qual[counter].beg_dt = a.beg_effective_dt_tm, temp->qual[counter].flg_ind = a
    .valid_diag_flg, temp->qual[counter].diag_id = a.icd9_nomen_id
   WITH nocounter
  ;end select
  SET temp_count = size(temp->qual,5)
  SET temp2_count = size(temp2->qual,5)
  FOR (x = 1 TO temp2_count)
   SELECT INTO "nl:"
    a.*
    FROM abn_rule a
    WHERE (request->copy_to_fin_cd=a.fin_class_cd)
     AND (a.encntr_type_cd=request->copy_from_encntr_type_cd)
     AND (a.cpt_nomen_id=temp2->qual[x].cpt_id)
     AND a.active_ind=1
    WITH nocounter, forupdate(a)
   ;end select
   UPDATE  FROM abn_rule a
    SET a.active_ind = 0, a.updt_cnt = (a.updt_cnt+ 1), a.active_status_cd = inactive_cd,
     a.active_status_prsnl_id = reqinfo->updt_id, a.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), a.end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (request->copy_to_fin_cd=a.fin_class_cd)
     AND (a.encntr_type_cd=request->copy_from_encntr_type_cd)
     AND (a.cpt_nomen_id=temp2->qual[x].cpt_id)
     AND a.active_ind=1
    WITH nocounter
   ;end update
  ENDFOR
  FOR (idx = 1 TO temp_count)
    FOR (idx2 = 1 TO temp2_count)
      SELECT INTO "nl:"
       a.*
       FROM abn_rule a
       WHERE (a.fin_class_cd=request->copy_to_fin_cd)
        AND (a.carrier_id=temp->qual[idx].carrier_id)
        AND (a.encntr_type_cd=request->copy_from_encntr_type_cd)
        AND (a.cpt_nomen_id=temp2->qual[idx2].cpt_id)
        AND (a.icd9_nomen_id=temp->qual[idx].diag_id)
       WITH nocounter, forupdate(a)
      ;end select
      UPDATE  FROM abn_rule a
       SET a.active_ind = 1, a.active_status_cd = active_cd, a.beg_effective_dt_tm = cnvtdatetime(
         temp->qual[idx].beg_dt),
        a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), a.updt_cnt = (a.updt_cnt+ 1),
        a.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        a.active_status_prsnl_id = reqinfo->updt_id, a.valid_diag_flg = temp->qual[idx].flg_ind
       WHERE (a.fin_class_cd=request->copy_to_fin_cd)
        AND (a.carrier_id=temp->qual[idx].carrier_id)
        AND (a.encntr_type_cd=request->copy_from_encntr_type_cd)
        AND (a.cpt_nomen_id=temp2->qual[idx2].cpt_id)
        AND (a.icd9_nomen_id=temp->qual[idx].diag_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET new_nbr = 0.0
       SELECT INTO "nl:"
        y = seq(abn_sequence,nextval)
        FROM dual
        DETAIL
         new_nbr = cnvtreal(y)
        WITH nocounter
       ;end select
       INSERT  FROM abn_rule a
        SET a.abn_rule_id = new_nbr, a.fin_class_cd = request->copy_to_fin_cd, a.carrier_id = temp->
         qual[idx].carrier_id,
         a.encntr_type_cd = temp->qual[idx].encntr_type_cd, a.cpt_nomen_id = temp2->qual[idx2].cpt_id,
         a.active_status_cd = active_cd,
         a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.active_status_prsnl_id = reqinfo->
         updt_id, a.icd9_nomen_id = temp->qual[idx].diag_id,
         a.valid_diag_flg = temp->qual[idx].flg_ind, a.beg_effective_dt_tm = cnvtdatetime(temp->qual[
          idx].beg_dt), a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
         a.active_ind = 1.0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->
         updt_id,
         a.updt_task = reqinfo->updt_task, a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET reply->status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "INSERT"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = "ABN_RULE TABLE"
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
  GO TO exit_script
 ELSEIF ((request->copy_type=5))
  SELECT INTO "nl:"
   a.*
   FROM abn_rule a
   WHERE (a.encntr_type_cd=request->copy_to_encntr_type_cd)
    AND a.active_ind=1
   WITH nocounter, forupdate(a)
  ;end select
  SET temp->qual_cnt = 0
  SELECT INTO "nl:"
   a.updt_cnt
   FROM abn_rule a
   WHERE (a.encntr_type_cd=request->copy_from_encntr_type_cd)
    AND a.active_ind=1
   HEAD REPORT
    temp->qual_cnt = 0
   DETAIL
    temp->qual_cnt = (temp->qual_cnt+ 1)
    IF (mod(temp->qual_cnt,10000)=1)
     stat = alterlist(temp->qual,(temp->qual_cnt+ 9999))
    ENDIF
    temp->qual[temp->qual_cnt].fin_cd = a.fin_class_cd, temp->qual[temp->qual_cnt].carrier_id = a
    .carrier_id, temp->qual[temp->qual_cnt].encntr_type_cd = request->copy_from_encntr_type_cd,
    temp->qual[temp->qual_cnt].cpt_id = a.cpt_nomen_id, temp->qual[temp->qual_cnt].beg_dt = a
    .beg_effective_dt_tm, temp->qual[temp->qual_cnt].flg_ind = a.valid_diag_flg,
    temp->qual[temp->qual_cnt].diag_id = a.icd9_nomen_id, temp->qual[temp->qual_cnt].action = 1
   FOOT REPORT
    IF (mod(temp->qual_cnt,10000) != 0)
     stat = alterlist(temp->qual,temp->qual_cnt)
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF ((request->copy_type=6))
  SELECT INTO "nl:"
   a.*
   FROM abn_rule a
   WHERE (request->copy_to_fin_cd=a.fin_class_cd)
    AND (request->copy_to_encntr_type_cd=a.encntr_type_cd)
    AND a.active_ind=1
   WITH nocounter, forupdate(a)
  ;end select
  SET temp->qual_cnt = 0
  SELECT INTO "nl:"
   a.updt_cnt
   FROM abn_rule a
   WHERE (a.fin_class_cd=request->copy_from_fin_cd)
    AND (a.encntr_type_cd=request->copy_from_encntr_type_cd)
    AND a.active_ind=1
   HEAD REPORT
    temp->qual_cnt = 0
   DETAIL
    temp->qual_cnt = (temp->qual_cnt+ 1)
    IF (mod(temp->qual_cnt,10000)=1)
     stat = alterlist(temp->qual,(temp->qual_cnt+ 9999))
    ENDIF
    temp->qual[temp->qual_cnt].fin_cd = a.fin_class_cd, temp->qual[temp->qual_cnt].carrier_id = a
    .carrier_id, temp->qual[temp->qual_cnt].encntr_type_cd = request->copy_from_encntr_type_cd,
    temp->qual[temp->qual_cnt].cpt_id = a.cpt_nomen_id, temp->qual[temp->qual_cnt].beg_dt = a
    .beg_effective_dt_tm, temp->qual[temp->qual_cnt].flg_ind = a.valid_diag_flg,
    temp->qual[temp->qual_cnt].diag_id = a.icd9_nomen_id, temp->qual[temp->qual_cnt].action = 1
   FOOT REPORT
    IF (mod(temp->qual_cnt,10000) != 0)
     stat = alterlist(temp->qual,temp->qual_cnt)
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  GO TO exit_sub
 ENDIF
 IF ((temp->qual_cnt > 0))
  SELECT INTO "nl:"
   a.updt_cnt
   FROM (dummyt d  WITH seq = value(temp->qual_cnt)),
    abn_rule a
   PLAN (d)
    JOIN (a
    WHERE (a.fin_class_cd=
    IF ((request->copy_type=5)) temp->qual[d.seq].fin_cd
    ELSE request->copy_to_fin_cd
    ENDIF
    )
     AND (a.carrier_id=temp->qual[d.seq].carrier_id)
     AND (a.encntr_type_cd=
    IF ((request->copy_type=5)) request->copy_to_encntr_type_cd
    ELSEIF ((request->copy_type=6)) request->copy_to_encntr_type_cd
    ELSE temp->qual[d.seq].encntr_type_cd
    ENDIF
    )
     AND (a.cpt_nomen_id=
    IF ((request->copy_type=3)) request->copy_to_cpt_cd
    ELSE temp->qual[d.seq].cpt_id
    ENDIF
    )
     AND (a.icd9_nomen_id=temp->qual[d.seq].diag_id))
   DETAIL
    temp->qual[d.seq].action = 2
   WITH nocounter, forupdate(a)
  ;end select
  UPDATE  FROM (dummyt d  WITH seq = value(temp->qual_cnt)),
    abn_rule a
   SET a.active_ind = 1, a.active_status_cd = active_cd, a.beg_effective_dt_tm = cnvtdatetime(temp->
     qual[d.seq].beg_dt),
    a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), a.updt_cnt = (a.updt_cnt+ 1), a
    .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    a.active_status_prsnl_id = reqinfo->updt_id, a.valid_diag_flg = temp->qual[d.seq].flg_ind
   PLAN (d
    WHERE (temp->qual[d.seq].action=2))
    JOIN (a
    WHERE (a.fin_class_cd=
    IF ((request->copy_type=5)) temp->qual[d.seq].fin_cd
    ELSE request->copy_to_fin_cd
    ENDIF
    )
     AND (a.carrier_id=temp->qual[d.seq].carrier_id)
     AND (a.encntr_type_cd=
    IF ((request->copy_type=5)) request->copy_to_encntr_type_cd
    ELSEIF ((request->copy_type=6)) request->copy_to_encntr_type_cd
    ELSE temp->qual[d.seq].encntr_type_cd
    ENDIF
    )
     AND (a.cpt_nomen_id=
    IF ((request->copy_type=3)) request->copy_to_cpt_cd
    ELSE temp->qual[d.seq].cpt_id
    ENDIF
    )
     AND (a.icd9_nomen_id=temp->qual[d.seq].diag_id))
   WITH nocounter, status(temp->qual[d.seq].status)
  ;end update
  FOR (i = 1 TO temp->qual_cnt)
    IF ((temp->qual[i].action=2)
     AND (temp->qual[i].status <= 0))
     CALL echo(build("time= ",cnvttime(curtime3)))
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "ABN_RULE TABLE"
    ENDIF
  ENDFOR
  INSERT  FROM (dummyt d  WITH seq = value(temp->qual_cnt)),
    abn_rule a
   SET a.abn_rule_id = seq(abn_sequence,nextval), a.fin_class_cd =
    IF ((request->copy_type=5)) temp->qual[d.seq].fin_cd
    ELSE request->copy_to_fin_cd
    ENDIF
    , a.carrier_id = temp->qual[d.seq].carrier_id,
    a.encntr_type_cd =
    IF ((request->copy_type=5)) request->copy_to_encntr_type_cd
    ELSEIF ((request->copy_type=6)) request->copy_to_encntr_type_cd
    ELSE temp->qual[d.seq].encntr_type_cd
    ENDIF
    , a.cpt_nomen_id =
    IF ((request->copy_type=3)) request->copy_to_cpt_cd
    ELSE temp->qual[d.seq].cpt_id
    ENDIF
    , a.active_status_cd = active_cd,
    a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.active_status_prsnl_id = reqinfo->
    updt_id, a.icd9_nomen_id = temp->qual[d.seq].diag_id,
    a.valid_diag_flg = temp->qual[d.seq].flg_ind, a.beg_effective_dt_tm = cnvtdatetime(temp->qual[d
     .seq].beg_dt), a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    a.active_ind = 1.0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id,
    a.updt_task = reqinfo->updt_task, a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (temp->qual[d.seq].action=1))
    JOIN (a)
   WITH nocounter, status(temp->qual[d.seq].status)
  ;end insert
  FOR (i = 1 TO temp->qual_cnt)
    IF ((temp->qual[i].action=1)
     AND (temp->qual[i].status <= 0))
     CALL echo(build("Add failed on temp->qual[",i,"]->status = ",temp->qual[i].status))
     SET reply->status_data.subeventstatus[1].operationname = "INSERTaction = 1"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "ABN_RULE TABLE"
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF ((reply->status="F"))
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("status = ",reply->status))
END GO
