CREATE PROGRAM dcp_upd_allergies:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD allergy(
   1 allergy_cnt = i4
   1 allqual[*]
     2 allergy_instance_id = f8
     2 allergy_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 substance_nom_id = f8
     2 substance_ftdesc = c255
     2 substance_type_cd = f8
     2 reaction_class_cd = f8
     2 severity_cd = f8
     2 source_of_info_cd = f8
     2 source_of_info_ft = c50
     2 onset_dt_tm = dq8
     2 reaction_status_cd = f8
     2 created_dt_tm = dq8
     2 created_prsnl_id = f8
     2 cancel_reason_cd = f8
     2 cancel_dt_tm = dq8
     2 cancel_prsnl_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 verified_status_flag = i2
     2 rec_src_vocab_cd = f8
     2 rec_src_identifer = c50
     2 rec_src_string = c255
     2 reaction_cnt = i4
     2 reaction[*]
       3 reaction_id = f8
       3 reaction_nom_id = f8
       3 reaction_ftdesc = c255
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 contributor_system_cd = f8
       3 data_status_cd = f8
       3 data_status_dt_tm = dq8
       3 data_status_prsnl_id = f8
     2 allergy_comment_cnt = i4
     2 allergy_comment[*]
       3 allergy_comment_id = f8
       3 comment_dt_tm = dq8
       3 comment_prsnl_id = f8
       3 allergy_comment = c32000
       3 active_ind = i2
       3 active_status_cd = f8
       3 active_status_dt_tm = dq8
       3 active_status_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 contributor_system_cd = f8
       3 data_status_cd = f8
       3 data_status_dt_tm = dq8
       3 data_status_prsnl_id = f8
 )
 SET reply->status_data.status = "S"
 SET x = 0
 SET alg_cnt = 0
 SET reaction_cnt = 0
 SET comment_cnt = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cur_reaction_id = 0.0
 SET cur_allergy_comment_id = 0.0
 SET inactive_cd = 0.0
 SET cancel_cd = 0.0
 SET react_id_cnt = 0
 SET comment_id_cnt = 0
 SET code_set = 48
 SET cdf_meaning = "INACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET inactive_cd = code_value
 SET code_set = 12025
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET cancel_cd = code_value
 FOR (x = 1 TO request->allergy_cnt)
   SELECT INTO "nl:"
    a.allergy_instance_id, a.allergy_id, r.allergy_instance_id,
    r.allergy_id, r.reaction_id
    FROM allergy a,
     (dummyt d1  WITH seq = 1),
     reaction r
    PLAN (a
     WHERE (a.allergy_instance_id=request->allergy[x].allergy_instance_id)
      AND (a.allergy_id=request->allergy[x].allergy_id))
     JOIN (d1)
     JOIN (r
     WHERE r.allergy_instance_id=a.allergy_instance_id
      AND r.allergy_id=a.allergy_id
      AND r.active_ind=1)
    ORDER BY a.allergy_instance_id, r.reaction_id
    HEAD REPORT
     reaction_cnt = 0
    HEAD a.allergy_instance_id
     reaction_cnt = 0, comment_cnt = 0, alg_cnt = (alg_cnt+ 1)
     IF (alg_cnt > size(allergy->allqual,5))
      stat = alterlist(allergy->allqual,(alg_cnt+ 5))
     ENDIF
     allergy->allqual[alg_cnt].allergy_instance_id = a.allergy_instance_id, allergy->allqual[alg_cnt]
     .allergy_id = a.allergy_id, allergy->allqual[alg_cnt].person_id = a.person_id,
     allergy->allqual[alg_cnt].encntr_id = a.encntr_id, allergy->allqual[alg_cnt].substance_nom_id =
     a.substance_nom_id, allergy->allqual[alg_cnt].substance_ftdesc = a.substance_ftdesc,
     allergy->allqual[alg_cnt].substance_type_cd = a.substance_type_cd, allergy->allqual[alg_cnt].
     reaction_class_cd = a.reaction_class_cd, allergy->allqual[alg_cnt].severity_cd = a.severity_cd,
     allergy->allqual[alg_cnt].source_of_info_cd = a.source_of_info_cd, allergy->allqual[alg_cnt].
     source_of_info_ft = a.source_of_info_ft, allergy->allqual[alg_cnt].onset_dt_tm = a.onset_dt_tm,
     allergy->allqual[alg_cnt].reaction_status_cd = cancel_cd, allergy->allqual[alg_cnt].
     created_dt_tm = a.created_dt_tm, allergy->allqual[alg_cnt].created_prsnl_id = a.created_prsnl_id,
     allergy->allqual[alg_cnt].cancel_reason_cd = 0, allergy->allqual[alg_cnt].cancel_dt_tm =
     cnvtdatetime(curdate,curtime3), allergy->allqual[alg_cnt].cancel_prsnl_id = reqinfo->updt_id,
     allergy->allqual[alg_cnt].contributor_system_cd = a.contributor_system_cd, allergy->allqual[
     alg_cnt].verified_status_flag = a.verified_status_flag, allergy->allqual[alg_cnt].
     rec_src_vocab_cd = a.rec_src_vocab_cd,
     allergy->allqual[alg_cnt].rec_src_identifer = a.rec_src_identifer, allergy->allqual[alg_cnt].
     rec_src_string = a.rec_src_string, allergy->allqual[alg_cnt].data_status_cd = a.data_status_cd,
     allergy->allqual[alg_cnt].data_status_dt_tm = a.data_status_dt_tm, allergy->allqual[alg_cnt].
     data_status_prsnl_id = a.data_status_prsnl_id, allergy->allqual[alg_cnt].beg_effective_dt_tm = a
     .beg_effective_dt_tm,
     allergy->allqual[alg_cnt].end_effective_dt_tm = a.end_effective_dt_tm, allergy->allqual[alg_cnt]
     .active_ind = a.active_ind, allergy->allqual[alg_cnt].active_status_cd = a.active_status_cd,
     allergy->allqual[alg_cnt].active_status_prsnl_id = a.active_status_prsnl_id, allergy->allqual[
     alg_cnt].active_status_dt_tm = a.active_status_dt_tm
    DETAIL
     IF (r.reaction_id > 0)
      reaction_cnt = (reaction_cnt+ 1)
      IF (reaction_cnt > size(allergy->allqual[alg_cnt].reaction,5))
       stat = alterlist(allergy->allqual[alg_cnt].reaction,(reaction_cnt+ 5))
      ENDIF
      allergy->allqual[alg_cnt].reaction[reaction_cnt].reaction_id = r.reaction_id, allergy->allqual[
      alg_cnt].reaction[reaction_cnt].reaction_nom_id = r.reaction_nom_id, allergy->allqual[alg_cnt].
      reaction[reaction_cnt].reaction_ftdesc = r.reaction_ftdesc,
      allergy->allqual[alg_cnt].reaction[reaction_cnt].contributor_system_cd = r
      .contributor_system_cd, allergy->allqual[alg_cnt].reaction[reaction_cnt].data_status_cd = r
      .data_status_cd, allergy->allqual[alg_cnt].reaction[reaction_cnt].data_status_dt_tm = r
      .data_status_dt_tm,
      allergy->allqual[alg_cnt].reaction[reaction_cnt].data_status_prsnl_id = r.data_status_prsnl_id,
      allergy->allqual[alg_cnt].reaction[reaction_cnt].beg_effective_dt_tm = r.beg_effective_dt_tm,
      allergy->allqual[alg_cnt].reaction[reaction_cnt].end_effective_dt_tm = r.end_effective_dt_tm,
      allergy->allqual[alg_cnt].reaction[reaction_cnt].active_ind = r.active_ind, allergy->allqual[
      alg_cnt].reaction[reaction_cnt].active_status_cd = r.active_status_cd, allergy->allqual[alg_cnt
      ].reaction[reaction_cnt].active_status_prsnl_id = r.active_status_prsnl_id,
      allergy->allqual[alg_cnt].reaction[reaction_cnt].active_status_dt_tm = r.active_status_dt_tm
     ENDIF
    FOOT  a.allergy_instance_id
     allergy->allqual[alg_cnt].reaction_cnt = reaction_cnt, stat = alterlist(allergy->allqual[alg_cnt
      ].reaction,reaction_cnt)
    WITH outerjoin = d1, dontcare = d1
   ;end select
   SELECT INTO "nl:"
    ac.allergy_instance_id, ac.allergy_id
    FROM allergy_comment ac
    WHERE (ac.allergy_id=request->allergy[alg_cnt].allergy_id)
     AND (ac.allergy_instance_id=request->allergy[alg_cnt].allergy_instance_id)
     AND ac.active_ind=1
    ORDER BY ac.allergy_instance_id
    DETAIL
     comment_cnt = (comment_cnt+ 1)
     IF (comment_cnt > size(allergy->allqual[alg_cnt].allergy_comment,5))
      stat = alterlist(allergy->allqual[alg_cnt].allergy_comment,(comment_cnt+ 5))
     ENDIF
     allergy->allqual[alg_cnt].allergy_comment[comment_cnt].allergy_comment_id = ac
     .allergy_comment_id, allergy->allqual[alg_cnt].allergy_comment[comment_cnt].comment_dt_tm = ac
     .comment_dt_tm, allergy->allqual[alg_cnt].allergy_comment[comment_cnt].comment_prsnl_id = ac
     .comment_prsnl_id,
     allergy->allqual[alg_cnt].allergy_comment[comment_cnt].allergy_comment = ac.allergy_comment,
     allergy->allqual[alg_cnt].allergy_comment[comment_cnt].contributor_system_cd = ac
     .contributor_system_cd, allergy->allqual[alg_cnt].allergy_comment[comment_cnt].data_status_cd =
     ac.data_status_cd,
     allergy->allqual[alg_cnt].allergy_comment[comment_cnt].data_status_dt_tm = ac.data_status_dt_tm,
     allergy->allqual[alg_cnt].allergy_comment[comment_cnt].data_status_prsnl_id = ac
     .data_status_prsnl_id, allergy->allqual[alg_cnt].allergy_comment[comment_cnt].
     beg_effective_dt_tm = ac.beg_effective_dt_tm,
     allergy->allqual[alg_cnt].allergy_comment[comment_cnt].end_effective_dt_tm = ac
     .end_effective_dt_tm, allergy->allqual[alg_cnt].allergy_comment[comment_cnt].active_ind = ac
     .active_ind, allergy->allqual[alg_cnt].allergy_comment[comment_cnt].active_status_cd = ac
     .active_status_cd,
     allergy->allqual[alg_cnt].allergy_comment[comment_cnt].active_status_prsnl_id = ac
     .active_status_prsnl_id, allergy->allqual[alg_cnt].allergy_comment[comment_cnt].
     active_status_dt_tm = ac.active_status_dt_tm
    WITH nocounter
   ;end select
   SET allergy->allqual[alg_cnt].allergy_comment_cnt = comment_cnt
   SET stat = alterlist(allergy->allqual[alg_cnt].allergy_comment,comment_cnt)
 ENDFOR
 SET allergy->allergy_cnt = alg_cnt
 SET stat = alterlist(allergy->allqual,alg_cnt)
 UPDATE  FROM allergy a,
   (dummyt d2  WITH seq = value(request->allergy_cnt))
  SET a.active_ind = false, a.active_status_cd = inactive_cd, a.active_status_prsnl_id = reqinfo->
   updt_id,
   a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.end_effective_dt_tm = cnvtdatetime(
    curdate,curtime3), a.updt_cnt = (a.updt_cnt+ 1),
   a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_applctx =
   reqinfo->updt_applctx,
   a.updt_task = reqinfo->updt_task
  PLAN (d2)
   JOIN (a
   WHERE (a.allergy_instance_id=request->allergy[d2.seq].allergy_instance_id)
    AND (a.allergy_id=request->allergy[d2.seq].allergy_id))
  WITH nocounter
 ;end update
 IF ((curqual != request->allergy_cnt))
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO allergy->allergy_cnt)
   SELECT INTO "nl:"
    num = seq(health_status_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     allergy->allqual[x].allergy_instance_id = cnvtreal(num)
    WITH format, counter
   ;end select
   INSERT  FROM allergy a
    SET a.allergy_instance_id = allergy->allqual[x].allergy_instance_id, a.allergy_id = allergy->
     allqual[x].allergy_id, a.person_id = allergy->allqual[x].person_id,
     a.encntr_id = allergy->allqual[x].encntr_id, a.substance_nom_id = allergy->allqual[x].
     substance_nom_id, a.substance_ftdesc = allergy->allqual[x].substance_ftdesc,
     a.substance_type_cd = allergy->allqual[x].substance_type_cd, a.reaction_class_cd = allergy->
     allqual[x].reaction_class_cd, a.severity_cd = allergy->allqual[x].severity_cd,
     a.source_of_info_cd = allergy->allqual[x].source_of_info_cd, a.source_of_info_ft = allergy->
     allqual[x].source_of_info_ft, a.onset_dt_tm = cnvtdatetime(allergy->allqual[x].onset_dt_tm),
     a.reaction_status_cd = allergy->allqual[x].reaction_status_cd, a.created_dt_tm = cnvtdatetime(
      allergy->allqual[x].created_dt_tm), a.created_prsnl_id = allergy->allqual[x].created_prsnl_id,
     a.cancel_reason_cd = allergy->allqual[x].cancel_reason_cd, a.cancel_dt_tm = cnvtdatetime(allergy
      ->allqual[x].cancel_dt_tm), a.cancel_prsnl_id = allergy->allqual[x].cancel_prsnl_id,
     a.contributor_system_cd = allergy->allqual[x].contributor_system_cd, a.verified_status_flag =
     allergy->allqual[x].verified_status_flag, a.rec_src_vocab_cd = allergy->allqual[x].
     rec_src_vocab_cd,
     a.rec_src_identifer = allergy->allqual[x].rec_src_identifer, a.rec_src_string = allergy->
     allqual[x].rec_src_string, a.data_status_cd = allergy->allqual[x].data_status_cd,
     a.data_status_dt_tm = cnvtdatetime(allergy->allqual[x].data_status_dt_tm), a
     .data_status_prsnl_id = allergy->allqual[x].data_status_prsnl_id, a.beg_effective_dt_tm =
     cnvtdatetime(allergy->allqual[x].beg_effective_dt_tm),
     a.end_effective_dt_tm = cnvtdatetime(allergy->allqual[x].end_effective_dt_tm), a.active_ind =
     allergy->allqual[x].active_ind, a.active_status_cd = allergy->allqual[x].active_status_cd,
     a.active_status_prsnl_id = allergy->allqual[x].active_status_prsnl_id, a.active_status_dt_tm =
     cnvtdatetime(allergy->allqual[x].active_status_dt_tm), a.updt_cnt = 0,
     a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_applctx =
     reqinfo->updt_applctx,
     a.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF ((allergy->allqual[x].reaction_cnt > 0))
    UPDATE  FROM reaction r,
      (dummyt d3  WITH seq = value(allergy->allqual[x].reaction_cnt))
     SET r.active_ind = false, r.active_status_cd = inactive_cd, r.active_status_prsnl_id = reqinfo->
      updt_id,
      r.active_status_dt_tm = cnvtdatetime(curdate,curtime3), r.end_effective_dt_tm = cnvtdatetime(
       curdate,curtime3), r.updt_cnt = (r.updt_cnt+ 1),
      r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id, r.updt_applctx =
      reqinfo->updt_applctx,
      r.updt_task = reqinfo->updt_task
     PLAN (d3)
      JOIN (r
      WHERE (r.reaction_id=allergy->allqual[x].reaction[d3.seq].reaction_id))
     WITH nocounter
    ;end update
    IF ((curqual != allergy->allqual[x].reaction_cnt))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
    FOR (react_id_cnt = 1 TO allergy->allqual[x].reaction_cnt)
      SELECT INTO "nl:"
       num = seq(health_status_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        allergy->allqual[x].reaction[react_id_cnt].reaction_id = cnvtreal(num)
       WITH format, counter
      ;end select
    ENDFOR
    INSERT  FROM reaction r,
      (dummyt d4  WITH seq = value(allergy->allqual[x].reaction_cnt))
     SET r.reaction_id = allergy->allqual[x].reaction[d4.seq].reaction_id, r.allergy_instance_id =
      allergy->allqual[x].allergy_instance_id, r.allergy_id = allergy->allqual[x].allergy_id,
      r.reaction_nom_id = allergy->allqual[x].reaction[d4.seq].reaction_nom_id, r.reaction_ftdesc =
      allergy->allqual[x].reaction[d4.seq].reaction_ftdesc, r.contributor_system_cd = allergy->
      allqual[x].reaction[d4.seq].contributor_system_cd,
      r.data_status_cd = allergy->allqual[x].reaction[d4.seq].data_status_cd, r.data_status_dt_tm =
      cnvtdatetime(allergy->allqual[x].reaction[d4.seq].data_status_dt_tm), r.data_status_prsnl_id =
      allergy->allqual[x].reaction[d4.seq].data_status_prsnl_id,
      r.beg_effective_dt_tm = cnvtdatetime(allergy->allqual[x].reaction[d4.seq].beg_effective_dt_tm),
      r.end_effective_dt_tm = cnvtdatetime(allergy->allqual[x].reaction[d4.seq].end_effective_dt_tm),
      r.active_ind = allergy->allqual[x].reaction[d4.seq].active_ind,
      r.active_status_cd = allergy->allqual[x].reaction[d4.seq].active_status_cd, r
      .active_status_prsnl_id = allergy->allqual[x].reaction[d4.seq].active_status_prsnl_id, r
      .active_status_dt_tm = cnvtdatetime(allergy->allqual[x].reaction[d4.seq].active_status_dt_tm),
      r.updt_cnt = 0, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id,
      r.updt_applctx = reqinfo->updt_applctx, r.updt_task = reqinfo->updt_task
     PLAN (d4)
      JOIN (r)
     WITH nocounter
    ;end insert
    IF ((curqual != allergy->allqual[x].reaction_cnt))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((allergy->allqual[x].allergy_comment_cnt > 0))
    UPDATE  FROM allergy_comment ac,
      (dummyt d5  WITH seq = value(allergy->allqual[x].allergy_comment_cnt))
     SET ac.active_ind = false, ac.active_status_cd = inactive_cd, ac.active_status_prsnl_id =
      reqinfo->updt_id,
      ac.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ac.end_effective_dt_tm = cnvtdatetime(
       curdate,curtime3), ac.updt_cnt = (ac.updt_cnt+ 1),
      ac.updt_dt_tm = cnvtdatetime(curdate,curtime3), ac.updt_id = reqinfo->updt_id, ac.updt_applctx
       = reqinfo->updt_applctx,
      ac.updt_task = reqinfo->updt_task
     PLAN (d5)
      JOIN (ac
      WHERE (ac.allergy_comment_id=allergy->allqual[x].allergy_comment[d5.seq].allergy_comment_id))
     WITH nocounter
    ;end update
    IF ((curqual != allergy->allqual[x].allergy_comment_cnt))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
    FOR (comment_id_cnt = 1 TO allergy->allqual[x].allergy_comment_cnt)
      SELECT INTO "nl:"
       num = seq(health_status_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        allergy->allqual[x].allergy_comment[comment_id_cnt].allergy_comment_id = cnvtreal(num)
       WITH format, counter
      ;end select
    ENDFOR
    INSERT  FROM allergy_comment ac,
      (dummyt d6  WITH seq = value(allergy->allqual[x].allergy_comment_cnt))
     SET ac.allergy_comment_id = allergy->allqual[x].allergy_comment[d6.seq].allergy_comment_id, ac
      .allergy_instance_id = allergy->allqual[x].allergy_instance_id, ac.allergy_id = allergy->
      allqual[x].allergy_id,
      ac.comment_dt_tm = cnvtdatetime(allergy->allqual[x].allergy_comment[d6.seq].comment_dt_tm), ac
      .comment_prsnl_id = allergy->allqual[x].allergy_comment[d6.seq].comment_prsnl_id, ac
      .allergy_comment = allergy->allqual[x].allergy_comment[d6.seq].allergy_comment,
      ac.contributor_system_cd = allergy->allqual[x].allergy_comment[d6.seq].contributor_system_cd,
      ac.data_status_cd = allergy->allqual[x].allergy_comment[d6.seq].data_status_cd, ac
      .data_status_dt_tm = cnvtdatetime(allergy->allqual[x].allergy_comment[d6.seq].data_status_dt_tm
       ),
      ac.data_status_prsnl_id = allergy->allqual[x].allergy_comment[d6.seq].data_status_prsnl_id, ac
      .beg_effective_dt_tm = cnvtdatetime(allergy->allqual[x].allergy_comment[d6.seq].
       beg_effective_dt_tm), ac.end_effective_dt_tm = cnvtdatetime(allergy->allqual[x].
       allergy_comment[d6.seq].end_effective_dt_tm),
      ac.active_ind = allergy->allqual[x].allergy_comment[d6.seq].active_ind, ac.active_status_cd =
      allergy->allqual[x].allergy_comment[d6.seq].active_status_cd, ac.active_status_prsnl_id =
      allergy->allqual[x].allergy_comment[d6.seq].active_status_prsnl_id,
      ac.active_status_dt_tm = cnvtdatetime(allergy->allqual[x].allergy_comment[d6.seq].
       active_status_dt_tm), ac.updt_cnt = 0, ac.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ac.updt_id = reqinfo->updt_id, ac.updt_applctx = reqinfo->updt_applctx, ac.updt_task = reqinfo
      ->updt_task
     PLAN (d6)
      JOIN (ac)
     WITH nocounter
    ;end insert
    IF ((curqual != allergy->allqual[x].allergy_comment_cnt))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "UPD ALLERGY"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ALLERGY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ALLERGY"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
