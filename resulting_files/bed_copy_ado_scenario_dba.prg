CREATE PROGRAM bed_copy_ado_scenario:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 FREE RECORD temp
 RECORD temp(
   1 details[*]
     2 category_id = f8
     2 notes = vc
     2 select_ind = i2
     2 options[*]
       3 option_id = f8
       3 preselect_ind = i2
       3 sequence = i4
       3 notes = vc
       3 ord_list[*]
         4 synonym_id = f8
         4 sentence_id = f8
         4 sequence = i4
     2 category_seq = i4
 )
 FREE RECORD del_temp
 RECORD del_temp(
   1 details[*]
     2 detail_id = f8
     2 options[*]
       3 option_id = f8
       3 ord_list[*]
         4 ord_list_id = f8
 )
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE error_flag = vc WITH protect, noconstant("")
 DECLARE detail_id = f8 WITH protect, noconstant(0)
 DECLARE option_id = f8 WITH protect, noconstant(0)
 DECLARE ord_lst_id = f8 WITH protect, noconstant(0)
 DECLARE scnt = i2 WITH protect, noconstant(0)
 DECLARE op_cnt = i2 WITH protect, noconstant(0)
 DECLARE ol_cnt = i2 WITH protect, noconstant(0)
 DECLARE c_cnt = i2 WITH protect, noconstant(0)
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i4
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE frm_scenario_mean = vc
 DECLARE to_scenario_mean = vc
 DECLARE deleteadoordlist(details_counter=i2,option_counter=i2,ol_counter=i2) = null
 DECLARE deleteadooption(details_counter=i2,option_counter=i2) = null
 DECLARE deleteadodetail(details_counter=i2) = null
 DECLARE insertbradoordlist(details_counter=i2,option_counter=i2,ol_counter=i2) = null
 DECLARE insertbradooption(details_counter=i2,option_counter=i2) = null
 DECLARE insertbradodetail(details_counter=i2) = null
 IF ((request->from_scenario_id > 0))
  SELECT INTO "nl:"
   FROM br_ado_topic_scenario s
   PLAN (s
    WHERE (s.br_ado_topic_scenario_id=request->from_scenario_id))
   DETAIL
    frm_scenario_mean = s.scenario_mean
   WITH nocounter
  ;end select
  SET cnt = 0
  SELECT INTO "nl:"
   FROM br_ado_detail d,
    br_ado_option o,
    br_ado_ord_list ol
   PLAN (d
    WHERE d.scenario_mean=frm_scenario_mean
     AND (d.facility_cd=request->facility_code_value))
    JOIN (o
    WHERE o.br_ado_detail_id=d.br_ado_detail_id)
    JOIN (ol
    WHERE ol.br_ado_option_id=o.br_ado_option_id)
   ORDER BY d.br_ado_category_id, o.br_ado_option_id, ol.br_ado_ord_list_id
   HEAD d.br_ado_category_id
    cnt = (cnt+ 1), ocnt = 0, stat = alterlist(temp->details,cnt),
    temp->details[cnt].category_id = d.br_ado_category_id, temp->details[cnt].notes = d.note_txt,
    temp->details[cnt].select_ind = d.select_ind,
    temp->details[cnt].category_seq = d.scenario_category_seq
   HEAD o.br_ado_option_id
    ocnt = (ocnt+ 1), olcnt = 0, stat = alterlist(temp->details[cnt].options,ocnt),
    temp->details[cnt].options[ocnt].option_id = o.br_ado_option_id, temp->details[cnt].options[ocnt]
    .preselect_ind = o.preselect_ind, temp->details[cnt].options[ocnt].sequence = o.option_seq
   HEAD ol.br_ado_ord_list_id
    olcnt = (olcnt+ 1), stat = alterlist(temp->details[cnt].options[ocnt].ord_list,olcnt), temp->
    details[cnt].options[ocnt].ord_list[olcnt].synonym_id = ol.synonym_id,
    temp->details[cnt].options[ocnt].ord_list[olcnt].sentence_id = ol.sentence_id, temp->details[cnt]
    .options[ocnt].ord_list[olcnt].sequence = ol.synonym_seq
   WITH nocounter
  ;end select
  CALL echorecord(temp)
  SET scnt = size(request->to_scenarios,5)
  SET cnt = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(scnt)),
    br_ado_topic_scenario s,
    br_ado_detail det,
    br_ado_option o,
    br_ado_ord_list ol
   PLAN (d)
    JOIN (s
    WHERE (s.br_ado_topic_scenario_id=request->to_scenarios[d.seq].topic_scenario_id))
    JOIN (det
    WHERE det.scenario_mean=s.scenario_mean
     AND (det.facility_cd=request->facility_code_value))
    JOIN (o
    WHERE o.br_ado_detail_id=det.br_ado_detail_id)
    JOIN (ol
    WHERE ol.br_ado_option_id=o.br_ado_option_id)
   ORDER BY det.br_ado_detail_id, o.br_ado_option_id, ol.br_ado_ord_list_id
   HEAD det.br_ado_detail_id
    cnt = (cnt+ 1), ocnt = 0, stat = alterlist(del_temp->details,cnt),
    del_temp->details[cnt].detail_id = det.br_ado_detail_id
   HEAD o.br_ado_option_id
    ocnt = (ocnt+ 1), olcnt = 0, stat = alterlist(del_temp->details[cnt].options,ocnt),
    del_temp->details[cnt].options[ocnt].option_id = o.br_ado_option_id
   HEAD ol.br_ado_ord_list_id
    olcnt = (olcnt+ 1), stat = alterlist(del_temp->details[cnt].options[ocnt].ord_list,olcnt),
    del_temp->details[cnt].options[ocnt].ord_list[olcnt].ord_list_id = ol.br_ado_ord_list_id
   WITH nocounter
  ;end select
  SET c_cnt = size(del_temp->details,5)
  FOR (x = 1 TO c_cnt)
    SET op_cnt = size(del_temp->details[x].options,5)
    FOR (y = 1 TO op_cnt)
      SET ol_cnt = size(del_temp->details[x].options[y].ord_list,5)
      FOR (z = 1 TO ol_cnt)
        CALL deleteadoordlist(x,y,z)
      ENDFOR
      CALL deleteadooption(x,y)
    ENDFOR
    CALL deleteadodetail(x)
  ENDFOR
  SUBROUTINE deleteadoordlist(details_counter,option_counter,ol_counter)
    DELETE  FROM br_ado_ord_list ol
     WHERE (ol.br_ado_ord_list_id=del_temp->details[details_counter].options[option_counter].
     ord_list[ol_counter].ord_list_id)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Error on OrdList Delete"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
  END ;Subroutine
  SUBROUTINE deleteadooption(details_counter,option_counter)
    DELETE  FROM br_ado_option o
     WHERE (o.br_ado_option_id=del_temp->details[details_counter].options[option_counter].option_id)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Error on Option Delete"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
  END ;Subroutine
  SUBROUTINE deleteadodetail(details_counter)
    DELETE  FROM br_ado_detail d
     WHERE (d.br_ado_detail_id=del_temp->details[details_counter].detail_id)
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET error_flag = "Y"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Error on Detail Delete"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
     GO TO exit_script
    ENDIF
  END ;Subroutine
  FOR (s = 1 TO scnt)
    SELECT INTO "nl:"
     FROM br_ado_topic_scenario s
     PLAN (s
      WHERE (s.br_ado_topic_scenario_id=request->to_scenarios[s].topic_scenario_id))
     DETAIL
      to_scenario_mean = s.scenario_mean
     WITH nocounter
    ;end select
    SET c_cnt = size(temp->details,5)
    FOR (x = 1 TO c_cnt)
      CALL insertbradodetail(x)
      SET op_cnt = size(temp->details[x].options,5)
      FOR (y = 1 TO op_cnt)
        CALL insertbradooption(x,y)
        SET ol_cnt = size(temp->details[x].options[y].ord_list,5)
        FOR (z = 1 TO ol_cnt)
          CALL insertbradoordlist(x,y,z)
        ENDFOR
        CALL echo(build("option1: ",option_id))
      ENDFOR
    ENDFOR
  ENDFOR
 ENDIF
 SUBROUTINE insertbradoordlist(x,y,z)
   SET ord_lst_id = 0.0
   SELECT INTO "nl:"
    tmp = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     ord_lst_id = cnvtreal(tmp)
    WITH nocounter
   ;end select
   CALL echo(build("ordlist id: ",ord_lst_id))
   SET ierrcode = 0
   INSERT  FROM br_ado_ord_list ol
    SET ol.br_ado_ord_list_id = ord_lst_id, ol.br_ado_option_id = option_id, ol.br_ado_detail_id =
     detail_id,
     ol.synonym_id = temp->details[x].options[y].ord_list[z].synonym_id, ol.sentence_id = temp->
     details[x].options[y].ord_list[z].sentence_id, ol.synonym_seq = temp->details[x].options[y].
     ord_list[z].sequence,
     ol.updt_cnt = 0, ol.updt_dt_tm = cnvtdatetime(curdate,curtime3), ol.updt_id = reqinfo->updt_id,
     ol.updt_task = reqinfo->updt_task, ol.updt_applctx = reqinfo->updt_applctx
    PLAN (ol)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Error on insert 3"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insertbradooption(x,y)
   SET option_id = 0.0
   SELECT INTO "nl:"
    tmp = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     option_id = cnvtreal(tmp),
     CALL echo(build("option2: ",option_id))
    WITH nocounter
   ;end select
   SET ierrcode = 0
   INSERT  FROM br_ado_option o
    SET o.br_ado_option_id = option_id, o.br_ado_detail_id = detail_id, o.preselect_ind = temp->
     details[x].options[y].preselect_ind,
     o.option_seq = temp->details[x].options[y].sequence, o.updt_cnt = 0, o.updt_dt_tm = cnvtdatetime
     (curdate,curtime3),
     o.updt_id = reqinfo->updt_id, o.updt_task = reqinfo->updt_task, o.updt_applctx = reqinfo->
     updt_applctx
    PLAN (o)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Error on insert 2"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insertbradodetail(x)
   SET detail_id = 0.0
   SELECT INTO "nl:"
    tmp = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     detail_id = cnvtreal(tmp),
     CALL echo(detail_id)
    WITH nocounter
   ;end select
   SET ierrcode = 0
   INSERT  FROM br_ado_detail d
    SET d.br_ado_detail_id = detail_id, d.scenario_mean = to_scenario_mean, d.br_ado_category_id =
     temp->details[x].category_id,
     d.facility_cd = request->facility_code_value, d.note_txt = temp->details[x].notes, d.select_ind
      = temp->details[x].select_ind,
     d.scenario_category_seq = temp->details[x].category_seq, d.updt_cnt = 0, d.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Error on insert 1"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
