CREATE PROGRAM dcp_get_role_note:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 note_type_list_id = f8
      2 note_type_id = f8
      2 note_type_description = vc
      2 event_cd = f8
      2 display = vc
      2 seq = i4
      2 updt_cnt = i4
      2 template_id = f8
      2 smart_template_ind = i2
      2 smart_template_cd = f8
      2 data_status_ind = i2
      2 default_level_flag = i2
      2 override_level_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
    1 filter = i2
  )
 ENDIF
 SET reply->status_data.status = "S"
 DECLARE load_by_prsnl(null) = null WITH private
 DECLARE load_by_role(null) = null WITH private
 DECLARE load_all(null) = null WITH private
 DECLARE no_filter = i2 WITH protect, constant(1)
 DECLARE author_filter = i2 WITH protect, constant(2)
 DECLARE position_filter = i2 WITH protect, constant(3)
 DECLARE false = i2 WITH protect, constant(0)
 DECLARE true = i2 WITH protect, constant(1)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = c30 WITH public, noconstant(fillstring(30," "))
 DECLARE ierrcode = i2 WITH public, noconstant(0)
 DECLARE serrmsg = c132 WITH public, noconstant(fillstring(132," "))
 DECLARE bfound = i2 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE active = i4 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 IF ((request->prsnl_id > 0))
  CALL load_by_prsnl(null)
  IF (failed=true)
   GO TO exit_script
  ENDIF
  IF (size(reply->qual,5) < 1
   AND (request->role_type_cd > 0))
   CALL load_by_role(null)
   IF (failed=true)
    GO TO exit_script
   ENDIF
   IF (size(reply->qual,5) < 1)
    CALL load_all(null)
   ENDIF
  ENDIF
 ELSEIF ((request->role_type_cd > 0))
  CALL load_by_role(null)
 ELSE
  CALL load_all(null)
 ENDIF
 SUBROUTINE load_by_prsnl(null)
   SET reply->filter = author_filter
   SET ierrcode = error(serrmsg,1)
   SELECT INTO "nl:"
    FROM note_type_list ntl,
     note_type nt,
     v500_event_code v,
     note_type_template_reltn tr,
     clinical_note_template clnt
    PLAN (ntl
     WHERE (ntl.prsnl_id=request->prsnl_id))
     JOIN (nt
     WHERE nt.note_type_id=ntl.note_type_id
      AND nt.data_status_ind > 0)
     JOIN (v
     WHERE v.event_cd=nt.event_cd
      AND v.code_status_cd=active)
     JOIN (tr
     WHERE tr.note_type_id=outerjoin(nt.note_type_id)
      AND tr.default_ind=outerjoin(1))
     JOIN (clnt
     WHERE clnt.template_id=outerjoin(tr.template_id)
      AND clnt.smart_template_ind != outerjoin(2))
    ORDER BY ntl.seq_num, nt.note_type_description
    HEAD REPORT
     cnt = 0, stat = alterlist(reply->qual,10)
    DETAIL
     bfound = 0, pos = 0, pos = locateval(num,1,cnt,ntl.note_type_id,reply->qual[num].note_type_id)
     IF (pos > 0)
      IF ((reply->qual[pos].smart_template_ind=0)
       AND (reply->qual[pos].smart_template_cd=0)
       AND (reply->qual[pos].template_id=0))
       IF (clnt.smart_template_ind=1)
        reply->qual[pos].smart_template_ind = clnt.smart_template_ind, reply->qual[pos].
        smart_template_cd = clnt.smart_template_cd
       ELSE
        reply->qual[pos].template_id = clnt.template_id
       ENDIF
      ENDIF
      bfound = 1, BREAK
     ENDIF
     IF (bfound=0)
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1
       AND cnt > 1)
       stat = alterlist(reply->qual,(cnt+ 9))
      ENDIF
      reply->qual[cnt].note_type_list_id = ntl.note_type_list_id, reply->qual[cnt].note_type_id = ntl
      .note_type_id, reply->qual[cnt].note_type_description = nt.note_type_description,
      reply->qual[cnt].display = v.event_cd_disp, reply->qual[cnt].event_cd = v.event_cd, reply->
      qual[cnt].seq = ntl.seq_num,
      reply->qual[cnt].updt_cnt = ntl.updt_cnt, reply->qual[cnt].default_level_flag = nt
      .default_level_flag, reply->qual[cnt].override_level_ind = nt.override_level_ind
      IF (clnt.smart_template_ind=1)
       reply->qual[cnt].smart_template_ind = clnt.smart_template_ind, reply->qual[cnt].
       smart_template_cd = clnt.smart_template_cd, reply->qual[cnt].template_id = 0
      ELSE
       reply->qual[cnt].smart_template_ind = 0, reply->qual[cnt].smart_template_cd = 0, reply->qual[
       cnt].template_id = clnt.template_id
      ENDIF
      reply->qual[cnt].data_status_ind = nt.data_status_ind
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->qual,cnt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = true
    SET table_name = "note_type_list"
   ENDIF
 END ;Subroutine
 SUBROUTINE load_by_role(null)
   SET reply->filter = position_filter
   SET ierrcode = error(serrmsg,1)
   SELECT INTO "nl:"
    FROM note_type_list ntl,
     note_type nt,
     v500_event_code v,
     note_type_template_reltn tr,
     clinical_note_template clnt
    PLAN (ntl
     WHERE (ntl.role_type_cd=request->role_type_cd))
     JOIN (nt
     WHERE nt.note_type_id=ntl.note_type_id
      AND nt.data_status_ind > 0)
     JOIN (v
     WHERE v.event_cd=nt.event_cd
      AND v.code_status_cd=active)
     JOIN (tr
     WHERE tr.note_type_id=outerjoin(nt.note_type_id)
      AND tr.default_ind=outerjoin(1))
     JOIN (clnt
     WHERE clnt.template_id=outerjoin(tr.template_id)
      AND clnt.smart_template_ind != outerjoin(2))
    ORDER BY ntl.seq_num, nt.note_type_description
    HEAD REPORT
     cnt = 0, stat = alterlist(reply->qual,10)
    DETAIL
     bfound = 0, pos = 0, pos = locateval(num,1,cnt,ntl.note_type_id,reply->qual[num].note_type_id)
     IF (pos > 0)
      IF ((reply->qual[pos].smart_template_ind=0)
       AND (reply->qual[pos].smart_template_cd=0)
       AND (reply->qual[pos].template_id=0))
       IF (clnt.smart_template_ind=1)
        reply->qual[pos].smart_template_ind = clnt.smart_template_ind, reply->qual[pos].
        smart_template_cd = clnt.smart_template_cd
       ELSE
        reply->qual[pos].template_id = clnt.template_id
       ENDIF
      ENDIF
      bfound = 1, BREAK
     ENDIF
     IF (bfound=0)
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1
       AND cnt > 1)
       stat = alterlist(reply->qual,(cnt+ 9))
      ENDIF
      reply->qual[cnt].note_type_list_id = ntl.note_type_list_id, reply->qual[cnt].note_type_id = ntl
      .note_type_id, reply->qual[cnt].note_type_description = nt.note_type_description,
      reply->qual[cnt].display = v.event_cd_disp, reply->qual[cnt].event_cd = v.event_cd, reply->
      qual[cnt].seq = ntl.seq_num,
      reply->qual[cnt].updt_cnt = ntl.updt_cnt, reply->qual[cnt].default_level_flag = nt
      .default_level_flag, reply->qual[cnt].override_level_ind = nt.override_level_ind
      IF (clnt.smart_template_ind=1)
       reply->qual[cnt].smart_template_ind = clnt.smart_template_ind, reply->qual[cnt].
       smart_template_cd = clnt.smart_template_cd, reply->qual[cnt].template_id = 0
      ELSE
       reply->qual[cnt].smart_template_ind = 0, reply->qual[cnt].smart_template_cd = 0, reply->qual[
       cnt].template_id = clnt.template_id
      ENDIF
      reply->qual[cnt].data_status_ind = nt.data_status_ind
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->qual,cnt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = true
    SET table_name = "note_type_list"
   ENDIF
 END ;Subroutine
 SUBROUTINE load_all(null)
   SET reply->filter = no_filter
   SET ierrcode = error(serrmsg,1)
   SELECT INTO "nl:"
    FROM note_type nt,
     v500_event_code v,
     note_type_template_reltn tr,
     clinical_note_template clnt
    PLAN (nt
     WHERE nt.event_cd != 0
      AND nt.data_status_ind > 0)
     JOIN (v
     WHERE v.event_cd=nt.event_cd
      AND v.code_status_cd=active)
     JOIN (tr
     WHERE tr.note_type_id=outerjoin(nt.note_type_id)
      AND tr.default_ind=outerjoin(1))
     JOIN (clnt
     WHERE clnt.template_id=outerjoin(tr.template_id)
      AND clnt.smart_template_ind != outerjoin(2))
    ORDER BY nt.note_type_description
    HEAD REPORT
     cnt = 0, stat = alterlist(reply->qual,10)
    DETAIL
     bfound = 0, pos = 0, pos = locateval(num,1,cnt,nt.note_type_id,reply->qual[num].note_type_id)
     IF (pos > 0)
      IF ((reply->qual[pos].smart_template_ind=0)
       AND (reply->qual[pos].smart_template_cd=0)
       AND (reply->qual[pos].template_id=0))
       IF (clnt.smart_template_ind=1)
        reply->qual[pos].smart_template_ind = clnt.smart_template_ind, reply->qual[pos].
        smart_template_cd = clnt.smart_template_cd
       ELSE
        reply->qual[pos].template_id = clnt.template_id
       ENDIF
      ENDIF
      bfound = 1, BREAK
     ENDIF
     IF (bfound=0)
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1
       AND cnt > 1)
       stat = alterlist(reply->qual,(cnt+ 9))
      ENDIF
      reply->qual[cnt].note_type_id = nt.note_type_id, reply->qual[cnt].note_type_description = nt
      .note_type_description, reply->qual[cnt].display = v.event_cd_disp,
      reply->qual[cnt].event_cd = v.event_cd, reply->qual[cnt].updt_cnt = nt.updt_cnt, reply->qual[
      cnt].default_level_flag = nt.default_level_flag,
      reply->qual[cnt].override_level_ind = nt.override_level_ind
      IF (clnt.smart_template_ind=1)
       reply->qual[cnt].smart_template_ind = clnt.smart_template_ind, reply->qual[cnt].
       smart_template_cd = clnt.smart_template_cd, reply->qual[cnt].template_id = 0
      ELSE
       reply->qual[cnt].smart_template_ind = 0, reply->qual[cnt].smart_template_cd = 0, reply->qual[
       cnt].template_id = clnt.template_id
      ENDIF
      reply->qual[cnt].data_status_ind = nt.data_status_ind
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->qual,cnt)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = true
    SET table_name = "note_type"
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed=true)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 ELSEIF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
