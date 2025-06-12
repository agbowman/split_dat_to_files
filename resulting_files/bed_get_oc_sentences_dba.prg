CREATE PROGRAM bed_get_oc_sentences:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 order_sent_id[*]
      2 order_sent_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD tempreply(
   1 order_sent_id[*]
     2 order_sent_id = f8
 )
 SET reply->status_data.status = "F"
 IF ( NOT (validate(cs6003_order_action_type_cd)))
  DECLARE cs6003_order_action_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,
    "ORDER"))
 ENDIF
 IF ( NOT (validate(cs6003_dischorder_action_type_cd)))
  DECLARE cs6003_dischorder_action_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,
    "DISORDER"))
 ENDIF
 DECLARE usage_flag_parser = vc WITH protect, noconstant(" ")
 DECLARE order_action_cd_ind = i2 WITH protect, noconstant(0)
 DECLARE dischorder_action_cd_ind = i2 WITH protect, noconstant(0)
 DECLARE sentence_cnt = i4 WITH protect, noconstant(0)
 DECLARE req_cnt = i4 WITH protect, noconstant(size(request->orders,5))
 DECLARE usemedadminflag = i2 WITH protect, noconstant(0)
 DECLARE useprescriptionflag = i2 WITH protect, noconstant(0)
 DECLARE useallflags = i2 WITH protect, noconstant(0)
 IF (validate(request->usage_flags) != 0)
  FOR (i = 1 TO size(request->usage_flags,5))
    IF (i=1)
     SET usage_flag_parser = build2("os.usage_flag = ",value(request->usage_flags[i].flag))
    ELSE
     SET usage_flag_parser = build2(usage_flag_parser," or os.usage_flag = ",value(request->
       usage_flags[i].flag))
    ENDIF
  ENDFOR
 ELSE
  IF ((request->usage_flag=0))
   SET usage_flag_parser = "os.usage_flag = 1 or os.usage_flag = 2 "
  ELSE
   SET usage_flag_parser = build2("os.usage_flag = ",value(request->usage_flag))
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_cnt)),
   order_catalog_synonym ocs,
   ord_cat_sent_r ocsr,
   order_sentence os,
   order_sentence_detail osd
  PLAN (d1)
   JOIN (ocs
   WHERE (ocs.catalog_cd=request->orders[d1.seq].catalog_code_value))
   JOIN (ocsr
   WHERE ocsr.synonym_id=ocs.synonym_id)
   JOIN (os
   WHERE os.order_sentence_id=ocsr.order_sentence_id
    AND parser(usage_flag_parser))
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
  ORDER BY os.order_sentence_id
  HEAD os.order_sentence_id
   sentence_cnt = (sentence_cnt+ 1), stat = alterlist(tempreply->order_sent_id,sentence_cnt),
   tempreply->order_sent_id[sentence_cnt].order_sent_id = os.order_sentence_id
  WITH nocounter
 ;end select
 IF (validate(request->usage_flags) != 0)
  FOR (i = 1 TO size(request->usage_flags,5))
    IF ((request->usage_flags[i].flag=1))
     SET usemedadminflag = true
    ELSEIF ((request->usage_flags[i].flag=2))
     SET useprescriptionflag = true
    ELSE
     SET useallflags = true
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_cnt)),
   cs_component cs,
   order_sentence os
  PLAN (d1)
   JOIN (cs
   WHERE (cs.catalog_cd=request->orders[d1.seq].catalog_code_value))
   JOIN (os
   WHERE os.order_sentence_id=cs.order_sentence_id
    AND os.order_sentence_id > 0.0)
  ORDER BY cs.order_sentence_id
  HEAD cs.order_sentence_id
   IF (os.usage_flag=0)
    sentence_cnt = (sentence_cnt+ 1), stat = alterlist(tempreply->order_sent_id,sentence_cnt),
    tempreply->order_sent_id[sentence_cnt].order_sent_id = cs.order_sentence_id
   ELSE
    IF (((useprescriptionflag=true
     AND os.usage_flag=2) OR (((usemedadminflag=true
     AND os.usage_flag=1) OR (useallflags=true)) )) )
     sentence_cnt = (sentence_cnt+ 1), stat = alterlist(tempreply->order_sent_id,sentence_cnt),
     tempreply->order_sent_id[sentence_cnt].order_sent_id = cs.order_sentence_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (validate(request->usage_flags) != 0)
  FOR (i = 1 TO size(request->usage_flags,5))
    IF ((request->usage_flags[i].flag IN (0, 1)))
     SET order_action_cd_ind = true
    ELSEIF ((request->usage_flags[i].flag=2))
     SET dischorder_action_cd_ind = true
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(req_cnt)),
   order_catalog_synonym ocs,
   alt_sel_list l,
   order_sentence os,
   order_sentence_detail osd,
   order_entry_format oef
  PLAN (d1)
   JOIN (ocs
   WHERE (ocs.catalog_cd=request->orders[d1.seq].catalog_code_value))
   JOIN (l
   WHERE l.synonym_id=ocs.synonym_id
    AND l.order_sentence_id > 0.0)
   JOIN (os
   WHERE os.order_sentence_id=l.order_sentence_id)
   JOIN (osd
   WHERE osd.order_sentence_id=os.order_sentence_id)
   JOIN (oef
   WHERE oef.oe_format_id=os.oe_format_id
    AND ((order_action_cd_ind=1
    AND oef.action_type_cd=cs6003_order_action_type_cd) OR (dischorder_action_cd_ind=1
    AND oef.action_type_cd=cs6003_dischorder_action_type_cd)) )
  ORDER BY os.order_sentence_id
  HEAD os.order_sentence_id
   sentence_cnt = (sentence_cnt+ 1), stat = alterlist(tempreply->order_sent_id,sentence_cnt),
   tempreply->order_sent_id[sentence_cnt].order_sent_id = os.order_sentence_id
  WITH nocounter
 ;end select
 SET sentence_cnt = 0
 IF (size(tempreply->order_sent_id,5) > 0)
  SELECT INTO "nl:"
   ordersentenceid = tempreply->order_sent_id[d.seq].order_sent_id
   FROM (dummyt d  WITH seq = size(tempreply->order_sent_id,5))
   PLAN (d)
   ORDER BY ordersentenceid
   HEAD ordersentenceid
    sentence_cnt = (sentence_cnt+ 1), stat = alterlist(reply->order_sent_id,sentence_cnt), reply->
    order_sent_id[sentence_cnt].order_sent_id = tempreply->order_sent_id[d.seq].order_sent_id
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 DECLARE serrmsg = vc WITH protect, noconstant("")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
