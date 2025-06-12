CREATE PROGRAM cp_get_allergy_hist:dba
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
     2 allergy_string = vc
     2 substance_nom_id = f8
     2 substance_type_cd = f8
     2 substance_type_disp = c40
     2 reaction_class_cd = f8
     2 reaction_class_disp = c40
     2 severity_cd = f8
     2 severity_disp = c40
     2 source_of_info = vc
     2 source_of_info_cd = f8
     2 onset_dt_tm = dq8
     2 onset_tz = i4
     2 onset_precision_cd = f8
     2 onset_precision_disp = c40
     2 onset_precision_flag = i2
     2 reaction_status_cd = f8
     2 reaction_status_disp = c40
     2 reaction_status_dt_tm = dq8
     2 created_dt_tm = dq8
     2 created_prsnl_id = f8
     2 created_prsnl_name = vc
     2 reviewed_dt_tm = dq8
     2 reviewed_tz = i4
     2 reviewed_prsnl_id = f8
     2 reviewed_prsnl_name = vc
     2 cancel_reason_cd = f8
     2 cancel_reason_disp = c40
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_prsnl_name = vc
     2 active_status_prsnl_id = f8
     2 active_status_prsnl_name = vc
     2 orig_prsnl_id = f8
     2 orig_prsnl_name = vc
     2 reaction_qual = i4
     2 reaction[*]
       3 allergy_instance_id = f8
       3 reaction_id = f8
       3 reaction_string = vc
       3 reaction_nom_id = f8
       3 beg_effective_dt_tm = dq8
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 updt_prsnl_name = vc
       3 active_ind = i2
     2 comment_qual = i4
     2 comment[*]
       3 allergy_instance_id = f8
       3 allergy_comment_id = f8
       3 allergy_comment = vc
       3 updt_dt_tm = dq8
       3 updt_id = f8
       3 updt_prsnl_name = vc
       3 active_ind = i2
       3 comment_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET allergy_req
 RECORD allergy_req(
   1 qual[*]
     2 allergy_id = f8
 )
 DECLARE y = i4
 DECLARE allergy_id_cnt = i4
 DECLARE allergy_id_cnt2 = i4
 SELECT INTO "nl:"
  FROM allergy a
  WHERE (a.person_id=request->person_id)
  ORDER BY a.allergy_id
  HEAD REPORT
   y = 0, stat = alterlist(allergy_req->qual,10)
  HEAD a.allergy_id
   y = (y+ 1)
   IF (mod(y,10)=1
    AND y != 1)
    stat = alterlist(allergy_req->qual,(y+ 10))
   ENDIF
   allergy_req->qual[y].allergy_id = a.allergy_id,
   CALL echo(build("allergy_id2 = ",allergy_req->qual[y].allergy_id))
  FOOT  a.allergy_id
   do_nothing = 0
  FOOT REPORT
   stat = alterlist(allergy_req->qual,y), allergy_id_cnt2 = y
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  allergy_name =
  IF (a.substance_nom_id > 0) trim(cnvtupper(n1.source_string))
  ELSE trim(cnvtupper(a.substance_ftdesc))
  ENDIF
  , info_source = uar_get_code_display(a.source_of_info_cd)
  FROM allergy a,
   (dummyt d  WITH seq = allergy_id_cnt2),
   nomenclature n1
  PLAN (d)
   JOIN (a
   WHERE (a.allergy_id=allergy_req->qual[d.seq].allergy_id))
   JOIN (n1
   WHERE n1.nomenclature_id=a.substance_nom_id)
  ORDER BY allergy_name, cnvtdatetime(a.beg_effective_dt_tm)
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10), x = 0
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   x = (x+ 1), reply->qual[x].allergy_id = a.allergy_id, reply->qual[x].allergy_instance_id = a
   .allergy_instance_id,
   CALL echo(build("allergy_id = ",reply->qual[x].allergy_id)),
   CALL echo(build("allergy_instance_id = ",reply->qual[x].allergy_instance_id))
   IF (a.substance_nom_id > 0)
    reply->qual[knt].allergy_string = n1.source_string
   ELSE
    reply->qual[knt].allergy_string = a.substance_ftdesc
   ENDIF
   reply->qual[knt].substance_nom_id = a.substance_nom_id, reply->qual[knt].substance_type_cd = a
   .substance_type_cd, reply->qual[knt].reaction_class_cd = a.reaction_class_cd,
   reply->qual[knt].severity_cd = a.severity_cd, reply->qual[knt].source_of_info_cd = a
   .source_of_info_cd
   IF (a.source_of_info_cd > 0)
    reply->qual[knt].source_of_info = info_source
   ELSE
    reply->qual[knt].source_of_info = a.source_of_info_ft
   ENDIF
   reply->qual[knt].onset_dt_tm = a.onset_dt_tm, reply->qual[knt].onset_tz = validate(a.onset_tz,0),
   reply->qual[knt].onset_precision_cd = a.onset_precision_cd,
   reply->qual[knt].onset_precision_flag = a.onset_precision_flag, reply->qual[knt].
   reaction_status_cd = a.reaction_status_cd, reply->qual[knt].created_dt_tm = a.created_dt_tm,
   reply->qual[knt].created_prsnl_id = a.created_prsnl_id, reply->qual[knt].reviewed_dt_tm = a
   .reviewed_dt_tm, reply->qual[knt].reviewed_tz = validate(a.reviewed_tz,0),
   reply->qual[knt].reviewed_prsnl_id = a.reviewed_prsnl_id, reply->qual[knt].cancel_reason_cd = a
   .cancel_reason_cd, reply->qual[knt].orig_prsnl_id = a.orig_prsnl_id,
   reply->qual[knt].updt_id = a.updt_id, reply->qual[knt].beg_effective_dt_tm = a.beg_effective_dt_tm,
   reply->qual[knt].beg_effective_tz = validate(a.beg_effective_tz,0),
   reply->qual[knt].updt_dt_tm = a.updt_dt_tm, reply->qual[knt].active_status_prsnl_id = a
   .active_status_prsnl_id
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt), allergy_id_cnt = x
  WITH counter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ALLERGY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ELSE
  IF ((reply->qual_knt < 1))
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d2  WITH seq = allergy_id_cnt),
   allergy a,
   reaction r,
   nomenclature n2
  PLAN (d2)
   JOIN (a
   WHERE (a.allergy_id=reply->qual[d2.seq].allergy_id)
    AND (a.allergy_instance_id=reply->qual[d2.seq].allergy_instance_id))
   JOIN (r
   WHERE (r.allergy_instance_id=reply->qual[d2.seq].allergy_instance_id))
   JOIN (n2
   WHERE n2.nomenclature_id=r.reaction_nom_id)
  ORDER BY d2.seq
  HEAD REPORT
   rknt = 0, do_nothing = 0
  HEAD d2.seq
   do_nothing = 0
  DETAIL
   rknt = (rknt+ 1)
   IF (mod(rknt,10)=1)
    stat = alterlist(reply->qual[d2.seq].reaction,(rknt+ 9))
   ENDIF
   reply->qual[d2.seq].reaction[rknt].allergy_instance_id = r.allergy_instance_id, reply->qual[d2.seq
   ].reaction[rknt].reaction_id = r.reaction_id
   IF (r.reaction_nom_id > 0)
    reply->qual[d2.seq].reaction[rknt].reaction_string = n2.source_string
   ELSE
    reply->qual[d2.seq].reaction[rknt].reaction_string = r.reaction_ftdesc
   ENDIF
   reply->qual[d2.seq].reaction[rknt].reaction_nom_id = r.reaction_nom_id, reply->qual[d2.seq].
   reaction[rknt].beg_effective_dt_tm = r.beg_effective_dt_tm, reply->qual[d2.seq].reaction[rknt].
   updt_dt_tm = r.updt_dt_tm,
   reply->qual[d2.seq].reaction[rknt].updt_id = r.updt_id, reply->qual[d2.seq].reaction[rknt].
   active_ind = r.active_ind
  FOOT  d2.seq
   reply->qual[d2.seq].reaction_qual = rknt, stat = alterlist(reply->qual[d2.seq].reaction,rknt),
   rknt = 0
  FOOT REPORT
   do_nothing = 0
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ALLERGY_COMMENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ELSE
  IF ((reply->qual_knt < 1))
   IF ((reply->status_data.status != "S"))
    SET reply->status_data.status = "Z"
   ENDIF
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SELECT
  IF ((request->order_seq=1))
   ORDER BY d3.seq, ac.allergy_id, ac.allergy_comment_id
  ELSE
   ORDER BY d3.seq, ac.allergy_id, ac.allergy_comment_id DESC
  ENDIF
  INTO "nl:"
  FROM (dummyt d3  WITH seq = allergy_id_cnt),
   allergy_comment ac
  PLAN (d3)
   JOIN (ac
   WHERE (ac.allergy_id=reply->qual[d3.seq].allergy_id))
  ORDER BY d3.seq
  HEAD REPORT
   cknt = 0, prev_allg_id = 0, new_id = 0
  HEAD d3.seq
   do_nothing = 0
  HEAD ac.allergy_id
   IF (prev_allg_id != ac.allergy_id)
    new_id = 1
   ENDIF
  DETAIL
   IF (new_id=1)
    cknt = (cknt+ 1)
    IF (mod(cknt,10)=1)
     stat = alterlist(reply->qual[d3.seq].comment,(cknt+ 9))
    ENDIF
    CALL echo(build("Number of seq= ",size(d3.seq,5))),
    CALL echo(build("Allg_instance_id = ",ac.allergy_instance_id)), reply->qual[d3.seq].comment[cknt]
    .allergy_instance_id = ac.allergy_instance_id,
    reply->qual[d3.seq].comment[cknt].allergy_comment_id = ac.allergy_comment_id, reply->qual[d3.seq]
    .comment[cknt].allergy_comment = ac.allergy_comment, reply->qual[d3.seq].comment[cknt].updt_dt_tm
     = ac.updt_dt_tm,
    reply->qual[d3.seq].comment[cknt].updt_id = ac.updt_id, reply->qual[d3.seq].comment[cknt].
    active_ind = ac.active_ind, reply->qual[d3.seq].comment[cknt].comment_tz = ac.comment_tz
   ENDIF
  FOOT  ac.allergy_id
   prev_allg_id = reply->qual[d3.seq].allergy_id, new_id = 0
  FOOT  d3.seq
   reply->qual[d3.seq].comment_qual = cknt, stat = alterlist(reply->qual[d3.seq].comment,cknt), cknt
    = 0
  FOOT REPORT
   do_nothing = 0
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ALLERGY_COMMENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ELSE
  IF ((reply->qual_knt < 1))
   SET reply->status_data.status = "Z"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
#exit_script
END GO
