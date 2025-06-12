CREATE PROGRAM bed_get_hs_source_items:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 code_sets[*]
      2 code_set = i4
      2 items[*]
        3 br_hlth_sntry_item_id = f8
        3 dim_item_ident = f8
        3 descriptions[*]
          4 text = vc
        3 searchable_descriptions[*]
          4 text = vc
        3 mapped_ind = i2
        3 ignore_ind = i2
    1 no_item_can_map_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE req_size = i4 WITH protect
 DECLARE search = vc
 DECLARE string_search = vc
 DECLARE mapped_search = vc
 DECLARE ignore_search = vc
 SET req_size = size(request->code_sets,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->code_sets,req_size)
 FOR (x = 1 TO req_size)
   SET reply->code_sets[x].code_set = request->code_sets[x].code_set
 ENDFOR
 SET search = ""
 SET string_search = 'b.description_1 > " "'
 IF ((request->search_flag=1))
  SET search = concat('"',cnvtupper(trim(request->search_string)),'*"')
  SET string_search = concat(string_search," and cnvtupper(b.description_1) = ",search)
  SET string_search = concat(string_search," or cnvtupper(b.description_2) = ",search)
  SET string_search = concat(string_search," or cnvtupper(b.description_3) = ",search)
  SET string_search = concat(string_search," or cnvtupper(b.description_4) = ",search)
  SET string_search = concat(string_search," or cnvtupper(b.description_5) = ",search)
  SET string_search = concat(string_search," or cnvtupper(b.description_6) = ",search)
 ELSEIF ((request->search_flag=2))
  SET search = concat('"*',cnvtupper(trim(request->search_string)),'*"')
  SET string_search = concat(string_search," and cnvtupper(b.description_1) = ",search)
  SET string_search = concat(string_search," or cnvtupper(b.description_2) = ",search)
  SET string_search = concat(string_search," or cnvtupper(b.description_3) = ",search)
  SET string_search = concat(string_search," or cnvtupper(b.description_4) = ",search)
  SET string_search = concat(string_search," or cnvtupper(b.description_5) = ",search)
  SET string_search = concat(string_search," or cnvtupper(b.description_6) = ",search)
 ENDIF
 SET reply->no_item_can_map_ind = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_size)),
   br_hlth_sntry_item b
  PLAN (d)
   JOIN (b
   WHERE (b.code_set=request->code_sets[d.seq].code_set)
    AND b.ignore_ind=0)
  DETAIL
   reply->no_item_can_map_ind = 0
  WITH nocounter
 ;end select
 DECLARE tcnt = i4 WITH noconstant(0), protect
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_size)),
   br_hlth_sntry_item b,
   br_name_value v,
   br_hlth_sntry_mill_item r
  PLAN (d)
   JOIN (b
   WHERE (b.code_set=reply->code_sets[d.seq].code_set)
    AND (b.ignore_ind=request->can_not_map_ind)
    AND parser(string_search))
   JOIN (v
   WHERE v.br_nv_key1=outerjoin("HEALTHSENTIGN")
    AND cnvtreal(v.br_name)=outerjoin(b.br_hlth_sntry_item_id))
   JOIN (r
   WHERE r.br_hlth_sntry_item_id=outerjoin(b.br_hlth_sntry_item_id))
  ORDER BY d.seq, b.br_hlth_sntry_item_id
  HEAD d.seq
   cnt = 0, tcnt = 0, stat = alterlist(reply->code_sets[d.seq].items,500)
  HEAD b.br_hlth_sntry_item_id
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 500)
    cnt = 1, stat = alterlist(reply->code_sets[d.seq].items,(tcnt+ 500))
   ENDIF
   reply->code_sets[d.seq].items[tcnt].br_hlth_sntry_item_id = b.br_hlth_sntry_item_id, reply->
   code_sets[d.seq].items[tcnt].dim_item_ident = b.dim_item_ident, stat = alterlist(reply->code_sets[
    d.seq].items[tcnt].descriptions,6),
   reply->code_sets[d.seq].items[tcnt].descriptions[1].text = b.description_1, reply->code_sets[d.seq
   ].items[tcnt].descriptions[2].text = b.description_2, reply->code_sets[d.seq].items[tcnt].
   descriptions[3].text = b.description_3,
   reply->code_sets[d.seq].items[tcnt].descriptions[4].text = b.description_4, reply->code_sets[d.seq
   ].items[tcnt].descriptions[5].text = b.description_5, reply->code_sets[d.seq].items[tcnt].
   descriptions[6].text = b.description_6,
   stat = alterlist(reply->code_sets[d.seq].items[tcnt].searchable_descriptions,1), reply->code_sets[
   d.seq].items[tcnt].searchable_descriptions[1].text = b.description_1
   IF ( NOT (b.code_set IN (1021, 1022)))
    stat = alterlist(reply->code_sets[d.seq].items[tcnt].searchable_descriptions,2), reply->
    code_sets[d.seq].items[tcnt].searchable_descriptions[2].text = b.description_2
   ENDIF
   IF ((((request->ignore_ind=0)
    AND v.br_name_value_id > 0.0) OR ((request->mapped_ind=0)
    AND r.br_hlth_sntry_mill_item_id > 0.0)) )
    tcnt = (tcnt - 1)
   ELSEIF ((((request->ignore_ind=1)) OR ((request->mapped_ind=1))) )
    reply->code_sets[d.seq].items[tcnt].ignore_ind = evaluate(v.br_name_value_id,0.0,0,1), reply->
    code_sets[d.seq].items[tcnt].mapped_ind = evaluate(r.br_hlth_sntry_mill_item_id,0.0,0,1)
   ENDIF
  FOOT  d.seq
   stat = alterlist(reply->code_sets[d.seq].items,tcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting items")
 IF ((tcnt > request->max_reply))
  SET reply->too_many_results_ind = 1
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
