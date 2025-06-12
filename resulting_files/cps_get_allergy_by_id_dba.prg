CREATE PROGRAM cps_get_allergy_by_id:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE SET reply
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 allergy_instance_id = f8
     2 allergy_id = f8
     2 substance = vc
     2 reaction_class_cd = f8
     2 reaction_class_disp = c40
     2 source_of_info = vc
     2 severity_cd = f8
     2 severity_disp = c40
     2 reaction_knt = i4
     2 reaction[*]
       3 reaction_id = f8
       3 name = vc
     2 comment_knt = i4
     2 comment[*]
       3 allergy_comment_id = f8
       3 comment_prsnl_id = f8
       3 comment_prsnl_name = vc
       3 comment_dt_tm = dq8
       3 allergy_comment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  a.allergy_instance_id, r.reaction_id
  FROM allergy a,
   reaction r,
   (dummyt d1  WITH seq = value(request->qual_knt)),
   (dummyt d2  WITH seq = 1),
   nomenclature n1,
   nomenclature n2
  PLAN (d1
   WHERE d1.seq > 0)
   JOIN (a
   WHERE (a.allergy_instance_id=request->qual[d1.seq].allergy_instance_id))
   JOIN (n1
   WHERE n1.nomenclature_id=a.substance_nom_id)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (r
   WHERE r.allergy_id=a.allergy_id
    AND r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND r.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (n2
   WHERE n2.nomenclature_id=r.reaction_nom_id)
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10)
  HEAD a.allergy_id
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   reply->qual[knt].allergy_instance_id = a.allergy_instance_id, reply->qual[knt].allergy_id = a
   .allergy_id
   IF (a.substance_nom_id > 0)
    reply->qual[knt].substance = n1.source_string
   ELSE
    reply->qual[knt].substance = a.substance_ftdesc
   ENDIF
   reply->qual[knt].reaction_class_cd = a.reaction_class_cd, reply->qual[knt].severity_cd = a
   .severity_cd
   IF (a.source_of_info_cd > 0)
    reply->qual[knt].source_of_info = uar_get_code_display(a.source_of_info_cd)
   ELSE
    reply->qual[knt].source_of_info = a.source_of_info_ft
   ENDIF
   rknt = 0, stat = alterlist(reply->qual[knt].reaction,10), t_react_id = 0.0
  DETAIL
   IF (r.reaction_id > 0
    AND t_react_id != r.reaction_id)
    rknt = (rknt+ 1)
    IF (mod(rknt,10)=1
     AND rknt != 1)
     stat = alterlist(reply->qual[knt].reaction,(rknt+ 9))
    ENDIF
    reply->qual[knt].reaction[rknt].reaction_id = r.reaction_id
    IF (r.reaction_nom_id > 0)
     reply->qual[knt].reaction[rknt].name = n2.source_string
    ELSE
     reply->qual[knt].reaction[rknt].name = r.reaction_ftdesc
    ENDIF
    t_react_id = r.reaction_id
   ENDIF
  FOOT  a.allergy_id
   reply->qual[knt].reaction_knt = rknt, stat = alterlist(reply->qual[knt].reaction,rknt)
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter, outerjoin = d2
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ALLERGY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ELSEIF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(reply->qual_knt)),
   allergy_comment ac,
   prsnl p
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ac
   WHERE (ac.allergy_id=reply->qual[d.seq].allergy_id)
    AND ac.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ac.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=ac.comment_prsnl_id)
  HEAD d.seq
   cknt = 0, stat = alterlist(reply->qual[d.seq].comment,10), t_commt_id = 0.0
  DETAIL
   IF (ac.allergy_comment_id > 0
    AND t_commt_id != ac.allergy_comment_id)
    cknt = (cknt+ 1)
    IF (mod(cknt,10)=1
     AND cknt != 1)
     stat = alterlist(reply->qual[d.seq].comment,(cknt+ 9))
    ENDIF
    reply->qual[d.seq].comment[cknt].allergy_comment_id = ac.allergy_comment_id, reply->qual[d.seq].
    comment[cknt].comment_prsnl_id = ac.comment_prsnl_id, reply->qual[d.seq].comment[cknt].
    comment_prsnl_name = p.name_full_formatted,
    reply->qual[d.seq].comment[cknt].comment_dt_tm = ac.comment_dt_tm, reply->qual[d.seq].comment[
    cknt].allergy_comment = ac.allergy_comment, t_commt_id = ac.allergy_comment_id
   ENDIF
  FOOT  d.seq
   reply->qual[d.seq].comment_knt = cknt, stat = alterlist(reply->qual[d.seq].comment,cknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ALLERGY_COMMENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
END GO
