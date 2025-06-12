CREATE PROGRAM dcp_get_template_by_criteria:dba
 RECORD reply(
   1 template[*]
     2 template_id = f8
     2 template_name = vc
     2 smart_template_ind = i2
     2 smart_template_cd = f8
     2 default_ind = i2
     2 note_type[*]
       3 note_type_id = f8
     2 prsnl[*]
       3 prsnl_id = f8
     2 location[*]
       3 location_cd = f8
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 SET reply->status_data.status = "F"
 RECORD template_reltns(
   1 template_reltn[*]
     2 template_reltn_id = f8
     2 template_id = f8
     2 default_ind = f8
 )
 DECLARE retrievetemplatesbycriteria(null) = null
 DECLARE filtertemplatebynotetype(note_type_id=f8,default_ind=i2) = null
 DECLARE filtertemplatebyprsnlloc(prsnl_id=f8,loc_cd=f8,external_filter_ind=i2) = null
 DECLARE retrievetemplates(name=vc,external_filter_ind=i2) = null
 DECLARE retrieveadditionalattributes(note_type_info=i2,prsnl_id_info=i2,facility_info=i2) = null
 DECLARE checkforerrors(operation=vc) = null
 DECLARE no_filter = i2 WITH protect, constant(0)
 DECLARE external_filter = i2 WITH protect, constant(1)
 DECLARE expand_size = i4 WITH protect, constant(100)
 DECLARE expand_cnt = i4 WITH protect, noconstant(0)
 DECLARE expand_total = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(0)
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 CALL retrievetemplatesbycriteria(null)
#exit_script
 IF (errcode=0)
  IF (size(reply->template,5) > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 FREE RECORD template_reltns
 SET modify = nopredeclare
 SUBROUTINE retrievetemplatesbycriteria(null)
   DECLARE reltn_filter_ind = i2 WITH noconstant(0)
   IF (((request->prsnl_id_ind) OR (request->facility_cd_ind)) )
    SET reltn_filter_ind = 1
   ENDIF
   IF (request->note_type_ind)
    IF (reltn_filter_ind)
     CALL filtertemplatebynotetype(request->note_type,0)
    ELSE
     CALL filtertemplatebynotetype(request->note_type,1)
    ENDIF
   ENDIF
   IF (reltn_filter_ind)
    CALL filtertemplatebyprsnlloc(request->prsnl_id,request->facility_cd,request->note_type_ind)
   ENDIF
   IF (((request->note_type_ind) OR (reltn_filter_ind)) )
    CALL retrievetemplates(request->search_name,external_filter)
   ELSE
    CALL retrievetemplates(request->search_name,no_filter)
   ENDIF
   IF (size(reply->template,5) > 0)
    CALL retrieveadditionalattributes(request->return_note_types_ind,request->return_prsnl_ids_ind,
     request->return_facility_cds_ind)
   ENDIF
   CALL checkforerrors("retrieveTemplatesByCriteria")
 END ;Subroutine
 SUBROUTINE filtertemplatebynotetype(note_type_id,default_ind)
  SELECT INTO "nl:"
   FROM note_type_template_reltn nttr,
    clinical_note_template cnt
   PLAN (nttr
    WHERE nttr.note_type_id=note_type_id)
    JOIN (cnt
    WHERE cnt.template_id=nttr.template_id
     AND ((cnt.smart_template_ind+ 0) < 2))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(template_reltns->template_reltn,(cnt+ 9))
    ENDIF
    template_reltns->template_reltn[cnt].template_reltn_id = nttr.note_type_template_reltn_id,
    template_reltns->template_reltn[cnt].template_id = nttr.template_id
    IF (default_ind)
     template_reltns->template_reltn[cnt].default_ind = nttr.default_ind
    ENDIF
   FOOT REPORT
    stat = alterlist(template_reltns->template_reltn,cnt)
   WITH nocounter
  ;end select
  CALL checkforerrors("filterTemplateByNoteType")
 END ;Subroutine
 SUBROUTINE filtertemplatebyprsnlloc(prsnl_id,loc_cd,external_filter_ind)
   DECLARE prsnlloc_parser = vc WITH private
   DECLARE multi_qualifier = i2 WITH private, noconstant(0)
   DECLARE reltn_cnt = i4 WITH protect, noconstant(size(template_reltns->template_reltn,5))
   DECLARE t_r_temp_cnt = i4 WITH protect, noconstant(0)
   IF (prsnl_id=0
    AND loc_cd=0)
    IF (external_filter_ind=no_filter)
     RETURN
    ELSE
     SET stat = alterlist(template_reltns->template_reltn,0)
     RETURN
    ENDIF
   ENDIF
   IF ((request->facility_cd_ind=1))
    SET prsnlloc_parser = concat(prsnlloc_parser," pltr.location_cd = ",cnvtstring(loc_cd,11,1))
    SET multi_qualifier = 1
   ENDIF
   IF ((request->prsnl_id_ind=1))
    IF (multi_qualifier)
     SET prsnlloc_parser = concat(prsnlloc_parser," and ")
    ENDIF
    SET prsnlloc_parser = concat(prsnlloc_parser," pltr.prsnl_id = ",cnvtstring(prsnl_id,11,1))
    SET multi_qualifier = 1
   ENDIF
   IF (multi_qualifier=0)
    SET prsnlloc_parser = "1 = 1"
   ENDIF
   IF (external_filter_ind=no_filter)
    SELECT INTO "nl:"
     FROM prsnl_loc_template_reltn pltr,
      note_type_template_reltn nttr,
      clinical_note_template cnt
     PLAN (pltr
      WHERE parser(prsnlloc_parser))
      JOIN (nttr
      WHERE nttr.note_type_template_reltn_id=pltr.note_type_template_reltn_id)
      JOIN (cnt
      WHERE cnt.template_id=nttr.template_id
       AND ((cnt.smart_template_ind+ 0) < 2))
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(template_reltns->template_reltn,(cnt+ 9))
      ENDIF
      template_reltns->template_reltn[cnt].default_ind = pltr.default_ind, template_reltns->
      template_reltn[cnt].template_id = nttr.template_id
     FOOT REPORT
      stat = alterlist(template_reltns->template_reltn,cnt)
     WITH nocounter
    ;end select
   ELSE
    IF (reltn_cnt=0)
     RETURN
    ENDIF
    RECORD t_r_temp(
      1 template_reltn[*]
        2 template_reltn_id = f8
        2 template_id = f8
        2 default_ind = f8
    )
    SELECT INTO "nl:"
     FROM prsnl_loc_template_reltn pltr
     PLAN (pltr
      WHERE expand(expand_cnt,1,reltn_cnt,pltr.note_type_template_reltn_id,template_reltns->
       template_reltn[expand_cnt].template_reltn_id)
       AND parser(prsnlloc_parser))
     HEAD REPORT
      cnt = 0, pos = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(t_r_temp->template_reltn,(cnt+ 9))
      ENDIF
      pos = locateval(pos,1,reltn_cnt,pltr.note_type_template_reltn_id,template_reltns->
       template_reltn[pos].template_reltn_id), t_r_temp->template_reltn[cnt].template_reltn_id =
      template_reltns->template_reltn[pos].template_reltn_id, t_r_temp->template_reltn[cnt].
      template_id = template_reltns->template_reltn[pos].template_id,
      t_r_temp->template_reltn[cnt].default_ind = pltr.default_ind
     FOOT REPORT
      stat = alterlist(t_r_temp->template_reltn,cnt)
     WITH nocounter
    ;end select
    SET t_r_temp_cnt = size(t_r_temp->template_reltn,5)
    SET stat = alterlist(template_reltns->template_reltn,t_r_temp_cnt)
    IF (t_r_temp_cnt)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(t_r_temp_cnt))
      ORDER BY t_r_temp->template_reltn[d.seq].template_reltn_id
      HEAD REPORT
       cnt = 0
      HEAD d.seq
       cnt = (cnt+ 1), template_reltns->template_reltn[cnt].template_reltn_id = t_r_temp->
       template_reltn[d.seq].template_reltn_id, template_reltns->template_reltn[cnt].template_id =
       t_r_temp->template_reltn[d.seq].template_id,
       template_reltns->template_reltn[cnt].default_ind = t_r_temp->template_reltn[d.seq].default_ind
      WITH nocounter
     ;end select
    ENDIF
    FREE RECORD t_r_temp
   ENDIF
   CALL checkforerrors("filterTemplateByPrsnlLoc")
 END ;Subroutine
 SUBROUTINE retrievetemplates(name,external_filter_ind)
   DECLARE cnt_parser = vc WITH private
   DECLARE multi_qualifier = i2 WITH private, noconstant(0)
   DECLARE reltn_cnt = i4 WITH protect, noconstant(size(template_reltns->template_reltn,5))
   DECLARE expand_cnt = i4 WITH protect, noconstant(0)
   IF ((request->search_name_ind=1))
    IF (textlen(trim(name)) > 0)
     SET cnt_parser = concat(cnt_parser,"cnvtupper(cnt.template_name) = '",cnvtupper(name),"*'")
     SET multi_qualifier = 1
    ENDIF
   ENDIF
   IF ((request->active_template_ind=1))
    IF (multi_qualifier)
     SET cnt_parser = concat(cnt_parser," and ")
    ENDIF
    SET cnt_parser = concat(cnt_parser," cnt.template_active_ind = 1")
    SET multi_qualifier = 1
   ENDIF
   IF (multi_qualifier=0)
    SET cnt_parser = "1 = 1"
   ENDIF
   IF (external_filter_ind=no_filter)
    SELECT INTO "nl:"
     FROM clinical_note_template cnt
     WHERE parser(cnt_parser)
      AND ((cnt.smart_template_ind+ 0) < 2)
     ORDER BY cnt.template_name
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->template,(cnt+ 9))
      ENDIF
      reply->template[cnt].template_id = cnt.template_id, reply->template[cnt].template_name = cnt
      .template_name, reply->template[cnt].smart_template_ind = cnt.smart_template_ind,
      reply->template[cnt].smart_template_cd = cnt.smart_template_cd, reply->template[cnt].cki = cnt
      .cki
     FOOT REPORT
      stat = alterlist(reply->template,cnt)
     WITH nocounter
    ;end select
   ELSE
    IF (reltn_cnt=0)
     RETURN
    ENDIF
    SELECT INTO "nl:"
     FROM clinical_note_template cnt
     WHERE expand(expand_cnt,1,reltn_cnt,cnt.template_id,template_reltns->template_reltn[expand_cnt].
      template_id)
      AND parser(cnt_parser)
     ORDER BY cnt.template_name
     HEAD REPORT
      cnt = 0, pos = 0
     DETAIL
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->template,(cnt+ 9))
      ENDIF
      pos = locateval(pos,1,reltn_cnt,cnt.template_id,template_reltns->template_reltn[pos].
       template_id), reply->template[cnt].default_ind = template_reltns->template_reltn[pos].
      default_ind, reply->template[cnt].template_id = cnt.template_id,
      reply->template[cnt].template_name = cnt.template_name, reply->template[cnt].smart_template_ind
       = cnt.smart_template_ind, reply->template[cnt].smart_template_cd = cnt.smart_template_cd,
      reply->template[cnt].cki = cnt.cki
     FOOT REPORT
      stat = alterlist(reply->template,cnt)
     WITH nocounter
    ;end select
   ENDIF
   CALL checkforerrors("retrieveTemplates")
 END ;Subroutine
 SUBROUTINE retrieveadditionalattributes(note_type_info,prsnl_id_info,facility_info)
   DECLARE template_cnt = i4 WITH protect, noconstant(size(reply->template,5))
   IF (note_type_info)
    SET expand_total = (template_cnt+ (expand_size - mod(template_cnt,expand_size)))
    SET expand_start = 1
    SET stat = alterlist(reply->template,expand_total)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((expand_total - 1)/ expand_size)))),
      note_type_template_reltn nttr
     PLAN (d
      WHERE initarray(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
      JOIN (nttr
      WHERE expand(expand_cnt,expand_start,(expand_start+ (expand_size - 1)),nttr.template_id,reply->
       template[expand_cnt].template_id,
       expand_size)
       AND nttr.note_type_id > 0)
     ORDER BY nttr.template_id
     HEAD REPORT
      cnt = 0, pos = 0
     HEAD nttr.template_id
      cnt = 0, pos = locateval(pos,1,template_cnt,nttr.template_id,reply->template[pos].template_id)
     DETAIL
      cnt = (cnt+ 1)
      IF (mod(cnt,10)=1)
       stat = alterlist(reply->template[pos].note_type,(cnt+ 9))
      ENDIF
      reply->template[pos].note_type[cnt].note_type_id = nttr.note_type_id
     FOOT  nttr.template_id
      stat = alterlist(reply->template[pos].note_type,cnt)
     WITH nocounter
    ;end select
    SET stat = alterlist(reply->template,template_cnt)
   ENDIF
   IF (((prsnl_id_info) OR (facility_info)) )
    RECORD prsnl_flat(
      1 qual[*]
        2 prsnl_id = f8
        2 reply_index = i4
        2 prsnl_index = i4
    )
    SET expand_total = (template_cnt+ (expand_size - mod(template_cnt,expand_size)))
    SET expand_start = 1
    SET stat = alterlist(reply->template,expand_total)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value((1+ ((expand_total - 1)/ expand_size)))),
      note_type_template_reltn nttr,
      prsnl_loc_template_reltn pltr
     PLAN (d1
      WHERE initarray(expand_start,evaluate(d1.seq,1,1,(expand_start+ expand_size))))
      JOIN (nttr
      WHERE expand(expand_cnt,expand_start,(expand_start+ (expand_size - 1)),nttr.template_id,reply->
       template[expand_cnt].template_id,
       expand_size))
      JOIN (pltr
      WHERE pltr.note_type_template_reltn_id=nttr.note_type_template_reltn_id)
     ORDER BY nttr.template_id, pltr.location_cd
     HEAD REPORT
      prsnl_cnt = 0, loc_cnt = 0, pos = 0,
      add_prsnl_ind = 0, prsnl_index = 0
     HEAD nttr.template_id
      prsnl_cnt = 0, loc_cnt = 0, pos = locateval(pos,1,template_cnt,nttr.template_id,reply->
       template[pos].template_id)
     HEAD pltr.location_cd
      IF (facility_info)
       IF (pltr.location_cd > 0)
        loc_cnt = (loc_cnt+ 1)
        IF (mod(loc_cnt,10)=1)
         stat = alterlist(reply->template[pos].location,(loc_cnt+ 9))
        ENDIF
        reply->template[pos].location[loc_cnt].location_cd = pltr.location_cd
       ENDIF
      ENDIF
     DETAIL
      IF (prsnl_id_info=1
       AND pltr.prsnl_id > 0)
       add_prsnl_ind = 1
       FOR (prsnl_index = 1 TO prsnl_cnt)
         IF ((reply->template[pos].prsnl[prsnl_index].prsnl_id=pltr.prsnl_id))
          add_prsnl_ind = 0, prsnl_index = prsnl_cnt
         ENDIF
       ENDFOR
       IF (add_prsnl_ind=1)
        prsnl_cnt = (prsnl_cnt+ 1)
        IF (mod(prsnl_cnt,10)=1)
         stat = alterlist(reply->template[pos].prsnl,(prsnl_cnt+ 9))
        ENDIF
        reply->template[pos].prsnl[prsnl_cnt].prsnl_id = pltr.prsnl_id
       ENDIF
      ENDIF
     FOOT  nttr.template_id
      stat = alterlist(reply->template[pos].prsnl,prsnl_cnt), stat = alterlist(reply->template[pos].
       location,loc_cnt)
     WITH nocounter
    ;end select
    SET stat = alterlist(reply->template,template_cnt)
   ENDIF
   CALL checkforerrors("retrieveAdditionalAttributes")
 END ;Subroutine
 SUBROUTINE checkforerrors(operation)
   SET errcode = 1
   WHILE (errcode != 0)
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     SET error_cnt = (error_cnt+ 1)
     IF (size(reply->status_data.subeventstatus,5) < error_cnt)
      SET stat = alterlist(reply->status_data.subeventstatus,error_cnt)
     ENDIF
     SET reply->status_data.subeventstatus[error_cnt].operationname = substring(1,25,trim(operation))
     SET reply->status_data.subeventstatus[error_cnt].targetobjectname = cnvtstring(errcode)
     SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = errmsg
    ENDIF
   ENDWHILE
   IF (error_cnt > 0)
    SET errcode = 1
    GO TO exit_script
   ENDIF
 END ;Subroutine
END GO
