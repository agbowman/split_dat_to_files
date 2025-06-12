CREATE PROGRAM dcp_get_allergy_info:dba
 RECORD reply(
   1 allergy_id = f8
   1 allergy_instance_id = f8
   1 encntr_id = f8
   1 source_string = vc
   1 substance_nom_id = f8
   1 substance_ftdesc = vc
   1 substance_type_cd = f8
   1 substance_type_disp = c20
   1 substance_type_mean = c20
   1 reaction_class_cd = f8
   1 reaction_class_disp = c20
   1 reaction_class_mean = c20
   1 severity_cd = f8
   1 severity_disp = c20
   1 severity_mean = c20
   1 source_of_info_cd = f8
   1 source_of_info_disp = c20
   1 source_of_info_mean = c20
   1 source_of_info_ft = vc
   1 onset_dt_tm = dq8
   1 reaction_status_cd = f8
   1 reaction_status_disp = c20
   1 reaction_status_mean = c20
   1 created_dt_tm = dq8
   1 created_prsnl_id = f8
   1 created_prsnl_name = vc
   1 cancel_reason_cd = f8
   1 cancel_dt_tm = dq8
   1 cancel_prsnl_id = f8
   1 cancel_prsnl_name = vc
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 data_status_cd = f8
   1 data_status_dt_tm = dq8
   1 data_status_prsnl_id = f8
   1 contributor_system_cd = f8
   1 active_ind = i2
   1 active_status_cd = f8
   1 active_status_dt_tm = dq8
   1 active_status_prsnl_id = f8
   1 rec_src_identifier = vc
   1 rec_src_string = vc
   1 rec_src_vocab_cd = f8
   1 verified_status_flag = i2
   1 reaction_qual = i4
   1 reaction[*]
     2 allergy_instance_id = f8
     2 reaction_id = f8
     2 reaction_nom_id = f8
     2 source_string = vc
     2 reaction_ftdesc = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
   1 comment_qual = i4
   1 comment[*]
     2 allergy_comment_id = f8
     2 allergy_instance_id = f8
     2 comment_dt_tm = dq8
     2 comment_prsnl_id = f8
     2 comment_prsnl_name = vc
     2 allergy_comment = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
     2 contributor_system_cd = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET table_name = "ALLERGY"
 SET failed = false
 SET count = 0
 SET r_count = 0
 SET ac_count = 0
 SET ac_cnt = 0
 SELECT INTO "nl:"
  a.allergy_id, n.nomenclature_id, p1.person_id,
  r.reaction_id, n2.nomenclature_id
  FROM allergy a,
   prsnl p1,
   nomenclature n,
   (dummyt d1  WITH seq = 1),
   reaction r,
   (dummyt d2  WITH seq = 1),
   nomenclature n2,
   (dummyt d3  WITH seq = 1)
  PLAN (a
   WHERE (a.allergy_instance_id=request->allergy_instance_id))
   JOIN (p1
   WHERE p1.person_id=a.created_prsnl_id)
   JOIN (d1)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
   JOIN (d2)
   JOIN (r
   WHERE r.allergy_id=a.allergy_id
    AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d3)
   JOIN (n2
   WHERE n2.nomenclature_id=r.reaction_nom_id)
  HEAD REPORT
   count = 0
  HEAD a.allergy_id
   r_cnt = 0, ac_cnt = 0, reply->allergy_id = a.allergy_id,
   reply->allergy_instance_id = a.allergy_instance_id, reply->encntr_id = a.encntr_id, reply->
   substance_nom_id = a.substance_nom_id,
   reply->source_string = n.source_string, reply->substance_ftdesc = a.substance_ftdesc, reply->
   substance_type_cd = a.substance_type_cd,
   reply->reaction_class_cd = a.reaction_class_cd, reply->severity_cd = a.severity_cd, reply->
   source_of_info_cd = a.source_of_info_cd,
   reply->source_of_info_ft = a.source_of_info_ft, reply->onset_dt_tm = a.onset_dt_tm, reply->
   reaction_status_cd = a.reaction_status_cd,
   reply->created_dt_tm = a.created_dt_tm, reply->created_prsnl_id = a.created_prsnl_id, reply->
   created_prsnl_name = p1.name_full_formatted,
   reply->cancel_reason_cd = a.cancel_reason_cd, reply->cancel_dt_tm = a.cancel_dt_tm, reply->
   cancel_prsnl_id = a.cancel_prsnl_id,
   reply->beg_effective_dt_tm = a.beg_effective_dt_tm, reply->end_effective_dt_tm = a
   .end_effective_dt_tm, reply->data_status_dt_tm = a.data_status_dt_tm,
   reply->data_status_cd = a.data_status_cd, reply->data_status_prsnl_id = a.data_status_prsnl_id,
   reply->contributor_system_cd = a.contributor_system_cd,
   reply->active_ind = a.active_ind, reply->active_status_cd = a.active_status_cd, reply->
   active_status_prsnl_id = a.active_status_prsnl_id,
   reply->active_status_dt_tm = a.active_status_dt_tm, reply->rec_src_identifier = a
   .rec_src_identifer, reply->rec_src_string = a.rec_src_string,
   reply->rec_src_vocab_cd = a.rec_src_vocab_cd, reply->verified_status_flag = a.verified_status_flag
  DETAIL
   IF (r.reaction_id > 0.0)
    r_cnt = (r_cnt+ 1)
    IF (mod(r_cnt,10)=1)
     stat = alterlist(reply->reaction,(r_cnt+ 10))
    ENDIF
    reply->reaction[r_cnt].allergy_instance_id = r.allergy_instance_id, reply->reaction[r_cnt].
    reaction_id = r.reaction_id, reply->reaction[r_cnt].reaction_nom_id = r.reaction_nom_id,
    reply->reaction[r_cnt].source_string = n2.source_string, reply->reaction[r_cnt].reaction_ftdesc
     = r.reaction_ftdesc, reply->reaction[r_cnt].beg_effective_dt_tm = r.beg_effective_dt_tm,
    reply->reaction[r_cnt].data_status_dt_tm = r.data_status_dt_tm, reply->reaction[r_cnt].
    data_status_prsnl_id = r.data_status_prsnl_id, reply->reaction[r_cnt].data_status_cd = r
    .data_status_cd,
    reply->reaction[r_cnt].contributor_system_cd = r.contributor_system_cd, reply->reaction[r_cnt].
    active_ind = r.active_ind, reply->reaction[r_cnt].active_status_cd = r.active_status_cd,
    reply->reaction[r_cnt].active_status_dt_tm = r.active_status_dt_tm, reply->reaction[r_cnt].
    active_status_prsnl_id = r.active_status_prsnl_id
   ENDIF
  FOOT  a.allergy_id
   reply->reaction_qual = r_cnt, stat = alterlist(reply->reaction,r_cnt)
  WITH nocounter, outerjoin(n), outerjoin(r),
   outerjoin(n2)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  IF (curqual > 0)
   SET reply->comment_qual = 0
   SET table_name = "ALLERGY_COMMENT"
   SELECT INTO "NL:"
    ac.allergy_id, ac.allergy_comment_id, p.person_id
    FROM allergy_comment ac,
     (dummyt d1  WITH seq = 1),
     prsnl p
    PLAN (d1)
     JOIN (ac
     WHERE (ac.allergy_id=reply->allergy_id)
      AND (ac.allergy_instance_id=reply->allergy_instance_id)
      AND ac.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ac.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (p
     WHERE p.person_id=ac.comment_prsnl_id)
    HEAD ac.allergy_id
     ac_cnt = 0, reply->comment_qual = 0
    HEAD ac.allergy_comment_id
     ac_cnt = (ac_cnt+ 1)
     IF (mod(ac_cnt,10)=1)
      stat = alterlist(reply->comment,(ac_cnt+ 10))
     ENDIF
     reply->comment[ac_cnt].allergy_instance_id = ac.allergy_instance_id, reply->comment[ac_cnt].
     allergy_comment_id = ac.allergy_comment_id, reply->comment[ac_cnt].allergy_comment = ac
     .allergy_comment,
     reply->comment[ac_cnt].comment_dt_tm = ac.comment_dt_tm, reply->comment[ac_cnt].comment_prsnl_id
      = ac.comment_prsnl_id, reply->comment[ac_cnt].beg_effective_dt_tm = ac.beg_effective_dt_tm,
     reply->comment[ac_cnt].data_status_dt_tm = ac.data_status_dt_tm, reply->comment[ac_cnt].
     data_status_prsnl_id = ac.data_status_prsnl_id, reply->comment[ac_cnt].data_status_cd = ac
     .data_status_cd,
     reply->comment[ac_cnt].contributor_system_cd = ac.contributor_system_cd, reply->comment[ac_cnt].
     active_ind = ac.active_ind, reply->comment[ac_cnt].active_status_cd = ac.active_status_cd,
     reply->comment[ac_cnt].active_status_dt_tm = ac.active_status_dt_tm, reply->comment[ac_cnt].
     active_status_prsnl_id = ac.active_status_prsnl_id, reply->comment[ac_cnt].comment_prsnl_name =
     p.name_full_formatted
    FOOT  ac.allergy_id
     reply->comment_qual = ac_cnt, stat = alterlist(reply->comment,ac_cnt)
    WITH nocounter
   ;end select
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 GO TO error_check
#error_check
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF select_error:
    SET reply->status_data.subeventstatus[1].operationname = "GET"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
 ENDIF
 GO TO end_program
#end_program
END GO
