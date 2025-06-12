CREATE PROGRAM bed_get_hs_auto_matching:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 proposed_relations[*]
      2 health_sentry_item_id = f8
      2 health_sentry_code_set = i4
      2 health_sentry_descriptions[*]
        3 health_sentry_description = vc
      2 millenium_items[*]
        3 millenium_item_code_value = f8
        3 millenium_item_display = vc
        3 millenium_item_description = vc
        3 millenium_item_definition = vc
    1 no_item_can_map_ind = i2
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
 RECORD temphealthsentrydata(
   1 health_sentry_item[*]
     2 health_sentry_item_id = f8
     2 health_sentry_descriptions[*]
       3 health_sentry_description = vc
 )
 DECLARE modifytempdescriptions(replycount=i4,description=vc) = null
 SUBROUTINE modifytempdescriptions(replycount,description)
  SET currentsize = size(temphealthsentrydata->health_sentry_item[replycount].
   health_sentry_descriptions,5)
  IF (description > " ")
   SET newsize = (currentsize+ 1)
   SET stat = alterlist(temphealthsentrydata->health_sentry_item[replycount].
    health_sentry_descriptions,newsize)
   SET temphealthsentrydata->health_sentry_item[replycount].health_sentry_descriptions[newsize].
   health_sentry_description = description
  ENDIF
 END ;Subroutine
 DECLARE count = i4
 DECLARE tempcount = i4
 DECLARE desccount = i4
 SET reply->no_item_can_map_ind = 1
 SELECT INTO "nl:"
  FROM br_hlth_sntry_item b
  PLAN (b
   WHERE (b.code_set=request->code_set)
    AND b.ignore_ind=0)
  DETAIL
   reply->no_item_can_map_ind = 0
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting from br_hlth_sntry_item to check if items can map")
 SELECT INTO "nl:"
  FROM br_hlth_sntry_item b
  PLAN (b
   WHERE (b.code_set=request->code_set)
    AND b.ignore_ind=0
    AND  NOT ( EXISTS (
   (SELECT
    r.br_hlth_sntry_item_id
    FROM br_hlth_sntry_mill_item r
    WHERE r.br_hlth_sntry_item_id=b.br_hlth_sntry_item_id)))
    AND  NOT ( EXISTS (
   (SELECT
    cnvtreal(v.br_name)
    FROM br_name_value v
    WHERE v.br_nv_key1="HEALTHSENTIGN"
     AND cnvtreal(v.br_name)=b.br_hlth_sntry_item_id))))
  ORDER BY b.br_hlth_sntry_item_id
  HEAD REPORT
   count = 0, tempcount = 0, stat = alterlist(temphealthsentrydata->health_sentry_item,50)
  HEAD b.br_hlth_sntry_item_id
   desccount = 0
  DETAIL
   count = (count+ 1), tempcount = (tempcount+ 1)
   IF (tempcount > 50)
    tempcount = 0, stat = alterlist(temphealthsentrydata->health_sentry_item,(count+ 50))
   ENDIF
   temphealthsentrydata->health_sentry_item[count].health_sentry_item_id = b.br_hlth_sntry_item_id,
   CALL modifytempdescriptions(count,b.description_1),
   CALL modifytempdescriptions(count,b.description_2),
   CALL modifytempdescriptions(count,b.description_3),
   CALL modifytempdescriptions(count,b.description_4),
   CALL modifytempdescriptions(count,b.description_5),
   CALL modifytempdescriptions(count,b.description_6)
  FOOT REPORT
   stat = alterlist(temphealthsentrydata->health_sentry_item,count)
  WITH nocounter
 ;end select
 IF (count=0)
  GO TO exit_script
 ENDIF
 DECLARE replycount = i4
 DECLARE tempreplycount = i4
 DECLARE codevaluecount = i4
 DECLARE tempcodevaluecount = i4
 DECLARE numsearchabledescriptions = i2
 IF ((request->code_set IN (1021, 1022)))
  SET numsearchabledescriptions = 1
 ELSE
  SET numsearchabledescriptions = 2
 ENDIF
 SELECT INTO "nl:"
  healthsentryid = temphealthsentrydata->health_sentry_item[d1.seq].health_sentry_item_id
  FROM (dummyt d1  WITH seq = count),
   (dummyt d2  WITH seq = 1),
   code_value cv
  PLAN (d1
   WHERE maxrec(d2,minval(size(temphealthsentrydata->health_sentry_item[d1.seq].
      health_sentry_descriptions,5),numsearchabledescriptions)))
   JOIN (d2)
   JOIN (cv
   WHERE (cv.code_set=request->code_set)
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND  NOT ( EXISTS (
   (SELECT
    r.code_value
    FROM br_hlth_sntry_mill_item r
    WHERE r.code_value=cv.code_value)))
    AND ((cnvtupper(cv.display)=cnvtupper(temphealthsentrydata->health_sentry_item[d1.seq].
    health_sentry_descriptions[d2.seq].health_sentry_description)) OR (((cnvtupper(cv.definition)=
   cnvtupper(temphealthsentrydata->health_sentry_item[d1.seq].health_sentry_descriptions[d2.seq].
    health_sentry_description)) OR (cnvtupper(cv.description)=cnvtupper(temphealthsentrydata->
    health_sentry_item[d1.seq].health_sentry_descriptions[d2.seq].health_sentry_description))) )) )
  ORDER BY healthsentryid, cv.code_value
  HEAD REPORT
   replycount = 0, tempreplycount = 0, stat = alterlist(reply->proposed_relations,50)
  HEAD healthsentryid
   replycount = (replycount+ 1), tempreplycount = (tempreplycount+ 1)
   IF (tempreplycount > 50)
    tempreplycount = 0, stat = alterlist(reply->proposed_relations,(replycount+ 50))
   ENDIF
   reply->proposed_relations[replycount].health_sentry_item_id = temphealthsentrydata->
   health_sentry_item[d1.seq].health_sentry_item_id, reply->proposed_relations[replycount].
   health_sentry_code_set = request->code_set, stat = moverec(temphealthsentrydata->
    health_sentry_item[d1.seq].health_sentry_descriptions,reply->proposed_relations[replycount].
    health_sentry_descriptions),
   codevaluecount = 0, tempcodevaluecount = 0, stat = alterlist(reply->proposed_relations[replycount]
    .millenium_items,50)
  HEAD cv.code_value
   codevaluecount = (codevaluecount+ 1), tempcodevaluecount = (tempcodevaluecount+ 1)
   IF (tempcodevaluecount > 50)
    tempcodevaluecount = 0, stat = alterlist(reply->proposed_relations[replycount].millenium_items,(
     codevaluecount+ 50))
   ENDIF
   reply->proposed_relations[replycount].millenium_items[codevaluecount].millenium_item_code_value =
   cv.code_value, reply->proposed_relations[replycount].millenium_items[codevaluecount].
   millenium_item_definition = cv.definition, reply->proposed_relations[replycount].millenium_items[
   codevaluecount].millenium_item_description = cv.description,
   reply->proposed_relations[replycount].millenium_items[codevaluecount].millenium_item_display = cv
   .display
  FOOT  healthsentryid
   stat = alterlist(reply->proposed_relations[replycount].millenium_items,codevaluecount)
  FOOT REPORT
   stat = alterlist(reply->proposed_relations,replycount)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting from code value")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
