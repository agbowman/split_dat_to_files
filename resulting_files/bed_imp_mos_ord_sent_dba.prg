CREATE PROGRAM bed_imp_mos_ord_sent:dba
 RECORD requestin(
   1 list_0[*]
     2 generic = vc
     2 order_cat_cki = vc
     2 mmdc = vc
     2 mmdc_desc = vc
     2 count = vc
     2 script = vc
     2 strengthdose = vc
     2 strengthdoseunit = vc
     2 volumedose = vc
     2 volumedoseunit = vc
     2 freq = vc
     2 priority = vc
     2 rxroute = vc
     2 sch_prn = vc
     2 prnreason = vc
     2 specinx = vc
     2 rate = vc
     2 rateunit = vc
     2 freetextrate = vc
     2 infuseover = vc
     2 infuseoverunit = vc
     2 duration = vc
     2 durationunit = vc
 )
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_req
 RECORD temp_req(
   1 list_0[*]
     2 sent_id = f8
     2 order_cat_cki = vc
     2 mmdc = vc
     2 count = vc
     2 script = vc
     2 strengthdose = vc
     2 strengthdoseunit = vc
     2 volumedose = vc
     2 volumedoseunit = vc
     2 freq = vc
     2 priority = vc
     2 rxroute = vc
     2 drugform = vc
     2 sch_prn = vc
     2 prnreason = vc
     2 specinx = vc
     2 rate = vc
     2 rateunit = vc
     2 freetextrate = vc
     2 infuseover = vc
     2 infuseoverunit = vc
     2 duration = vc
     2 durationunit = vc
 )
 FREE SET temp_drugform
 RECORD temp_drugform(
   1 list_0[*]
     2 mmdc = vc
     2 drugform = vc
 )
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET req_cnt = size(requestin->list_0,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp_req->list_0,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET temp_req->list_0[x].count = requestin->list_0[x].count
   SET temp_req->list_0[x].duration = requestin->list_0[x].duration
   SET temp_req->list_0[x].durationunit = requestin->list_0[x].durationunit
   SET temp_req->list_0[x].freetextrate = requestin->list_0[x].freetextrate
   SET temp_req->list_0[x].freq = requestin->list_0[x].freq
   SET temp_req->list_0[x].infuseover = requestin->list_0[x].infuseover
   SET temp_req->list_0[x].infuseoverunit = requestin->list_0[x].infuseoverunit
   SET temp_req->list_0[x].mmdc = requestin->list_0[x].mmdc
   SET temp_req->list_0[x].order_cat_cki = requestin->list_0[x].order_cat_cki
   SET temp_req->list_0[x].priority = requestin->list_0[x].priority
   SET temp_req->list_0[x].prnreason = requestin->list_0[x].prnreason
   SET temp_req->list_0[x].rate = requestin->list_0[x].rate
   SET temp_req->list_0[x].rateunit = requestin->list_0[x].rateunit
   SET temp_req->list_0[x].rxroute = requestin->list_0[x].rxroute
   SET temp_req->list_0[x].sch_prn = requestin->list_0[x].sch_prn
   SET temp_req->list_0[x].script = requestin->list_0[x].script
   SET temp_req->list_0[x].specinx = requestin->list_0[x].specinx
   SET temp_req->list_0[x].strengthdose = requestin->list_0[x].strengthdose
   SET temp_req->list_0[x].strengthdoseunit = requestin->list_0[x].strengthdoseunit
   SET temp_req->list_0[x].volumedose = requestin->list_0[x].volumedose
   SET temp_req->list_0[x].volumedoseunit = requestin->list_0[x].volumedoseunit
 ENDFOR
 SET cinpatient = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET csystem = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET cnt = 0
 SELECT INTO "nl:"
  md.cki, md.form_cd, form = uar_get_code_display(md.form_cd)
  FROM medication_definition md,
   item_definition id,
   med_def_flex mdf
  PLAN (md
   WHERE md.item_id > 0
    AND md.med_type_flag=0
    AND md.form_cd > 0
    AND trim(md.cki) > " ")
   JOIN (id
   WHERE id.item_id=md.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.flex_type_cd=csystem
    AND mdf.pharmacy_type_cd=cinpatient)
  ORDER BY md.cki, md.form_cd
  HEAD REPORT
   cnt = 0
  HEAD md.cki
   last_form_cd = 0, item_count = 0, write_form_ind = 1,
   write_form_cd = md.form_cd
  DETAIL
   item_count = (item_count+ 1)
   IF (item_count > 1
    AND md.form_cd != last_form_cd)
    write_form_ind = 0
   ENDIF
   last_form_cd = md.form_cd
  FOOT  md.cki
   IF (write_form_ind=1)
    cnt = (cnt+ 1), stat = alterlist(temp_drugform->list_0,cnt), temp_drugform->list_0[cnt].mmdc =
    trim(md.cki),
    temp_drugform->list_0[cnt].drugform = trim(form)
   ENDIF
  WITH nullreport
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   mmdc = temp_req->list_0[d2.seq].mmdc, drugform = temp_drugform->list_0[d.seq].drugform
   FROM (dummyt d  WITH seq = value(size(temp_drugform->list_0,5))),
    (dummyt d2  WITH seq = value(size(temp_req->list_0,5)))
   PLAN (d2)
    JOIN (d
    WHERE (temp_drugform->list_0[d.seq].mmdc=trim(cnvtupper(temp_req->list_0[d2.seq].mmdc))))
   DETAIL
    temp_req->list_0[d2.seq].drugform = temp_drugform->list_0[d.seq].drugform
   WITH nullreport
  ;end select
 ENDIF
 SELECT INTO "NL:"
  j = seq(bedrock_seq,nextval)"##################;rp0"
  FROM dual du,
   (dummyt d  WITH seq = value(req_cnt))
  PLAN (d)
   JOIN (du)
  DETAIL
   temp_req->list_0[d.seq].sent_id = cnvtreal(j)
  WITH format, counter
 ;end select
 SET ierrcode = 0
 INSERT  FROM br_ordsent b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_id = temp_req->list_0[d.seq].sent_id, b.catalog_cki = temp_req->list_0[d.seq].
   order_cat_cki, b.ordsent_count = cnvtint(trim(temp_req->list_0[d.seq].count)),
   b.mmdc = temp_req->list_0[d.seq].mmdc, b.ordsent_display = temp_req->list_0[d.seq].script, b
   .source_flag = 1,
   b.updt_id = reqinfo->updt_id, b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_task = reqinfo
   ->updt_task,
   b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT ORDSENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "STRENGTHDOSE",
   b.oe_field_value = temp_req->list_0[d.seq].strengthdose, b.updt_id = reqinfo->updt_id, b
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].strengthdose > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL1"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "STRENGTHDOSEUNIT",
   b.oe_field_value = temp_req->list_0[d.seq].strengthdoseunit, b.updt_id = reqinfo->updt_id, b
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].strengthdoseunit > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL2"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "VOLUMEDOSE",
   b.oe_field_value = temp_req->list_0[d.seq].volumedose, b.updt_id = reqinfo->updt_id, b.updt_dt_tm
    = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].volumedose > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL3"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "VOLUMEDOSEUNIT",
   b.oe_field_value = temp_req->list_0[d.seq].volumedoseunit, b.updt_id = reqinfo->updt_id, b
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].volumedoseunit > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL4"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "RXROUTE",
   b.oe_field_value = temp_req->list_0[d.seq].rxroute, b.updt_id = reqinfo->updt_id, b.updt_dt_tm =
   cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].rxroute > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL5"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "DRUGFORM",
   b.oe_field_value = temp_req->list_0[d.seq].drugform, b.updt_id = reqinfo->updt_id, b.updt_dt_tm =
   cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].drugform > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL15"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "SCH/PRN",
   b.oe_field_value = temp_req->list_0[d.seq].sch_prn, b.updt_id = reqinfo->updt_id, b.updt_dt_tm =
   cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].sch_prn > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL6"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "PRNREASON",
   b.oe_field_value = temp_req->list_0[d.seq].prnreason, b.updt_id = reqinfo->updt_id, b.updt_dt_tm
    = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].prnreason > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL7"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "FREQ",
   b.oe_field_value = temp_req->list_0[d.seq].freq, b.updt_id = reqinfo->updt_id, b.updt_dt_tm =
   cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].freq > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL8"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "FREETEXTRATE",
   b.oe_field_value = temp_req->list_0[d.seq].freetextrate, b.updt_id = reqinfo->updt_id, b
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].freetextrate > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL9"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "RATE",
   b.oe_field_value = temp_req->list_0[d.seq].rate, b.updt_id = reqinfo->updt_id, b.updt_dt_tm =
   cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].rate > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL10"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "RATEUNIT",
   b.oe_field_value = temp_req->list_0[d.seq].rateunit, b.updt_id = reqinfo->updt_id, b.updt_dt_tm =
   cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].rateunit > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL11"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "INFUSEOVER",
   b.oe_field_value = temp_req->list_0[d.seq].infuseover, b.updt_id = reqinfo->updt_id, b.updt_dt_tm
    = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].infuseover > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL12"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "INFUSEOVERUNIT",
   b.oe_field_value = temp_req->list_0[d.seq].infuseoverunit, b.updt_id = reqinfo->updt_id, b
   .updt_dt_tm = cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].infuseoverunit > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL13"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 INSERT  FROM br_ordsent_detail b,
   (dummyt d  WITH seq = value(req_cnt))
  SET b.br_ordsent_detail_id = seq(bedrock_seq,nextval), b.br_ordsent_id = temp_req->list_0[d.seq].
   sent_id, b.oe_field_meaning = "RXPRIORITY",
   b.oe_field_value = temp_req->list_0[d.seq].priority, b.updt_id = reqinfo->updt_id, b.updt_dt_tm =
   cnvtdatetime(curdate,curtime),
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
  PLAN (d
   WHERE (temp_req->list_0[d.seq].priority > " "))
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSERT DETAIL14"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
