CREATE PROGRAM bed_get_hs_auto_ec_matching:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 proposed_relations[*]
      2 health_sentry_item_id = f8
      2 health_sentry_code_set = i4
      2 health_sentry_descriptions[*]
        3 health_sentry_description = vc
      2 millenium_items[*]
        3 event_cd = f8
        3 event_cd_display = vc
        3 event_cd_description = vc
        3 event_set_name = vc
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
     2 dim_item_id = f8
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
  FROM br_hlth_sntry_item b,
   br_hlth_sntry_mill_item r,
   br_name_value v
  PLAN (b
   WHERE b.code_set=72
    AND b.ignore_ind=0)
   JOIN (r
   WHERE r.br_hlth_sntry_item_id=outerjoin(b.br_hlth_sntry_item_id))
   JOIN (v
   WHERE v.br_nv_key1=outerjoin("HEALTHSENTIGN")
    AND cnvtreal(v.br_name)=outerjoin(b.br_hlth_sntry_item_id))
  ORDER BY b.br_hlth_sntry_item_id, r.br_hlth_sntry_item_id, v.br_nv_key1
  HEAD REPORT
   count = 0, tempcount = 0, stat = alterlist(temphealthsentrydata->health_sentry_item,50)
  HEAD b.br_hlth_sntry_item_id
   desccount = 0
  DETAIL
   IF (r.br_hlth_sntry_item_id=0
    AND v.br_name_value_id=0)
    reply->no_item_can_map_ind = 0, count = (count+ 1), tempcount = (tempcount+ 1)
    IF (tempcount > 50)
     tempcount = 0, stat = alterlist(temphealthsentrydata->health_sentry_item,(count+ 50))
    ENDIF
    temphealthsentrydata->health_sentry_item[count].health_sentry_item_id = b.br_hlth_sntry_item_id,
    CALL modifytempdescriptions(count,b.description_1),
    CALL modifytempdescriptions(count,b.description_2),
    CALL modifytempdescriptions(count,b.description_3),
    CALL modifytempdescriptions(count,b.description_4)
   ENDIF
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
 SELECT INTO "nl:"
  healthsentryid = temphealthsentrydata->health_sentry_item[d1.seq].health_sentry_item_id
  FROM (dummyt d1  WITH seq = count),
   (dummyt d2  WITH seq = 1),
   v500_event_set_code vesc,
   v500_event_set_explode vese,
   v500_event_code vec,
   code_value cv,
   br_hlth_sntry_mill_item r
  PLAN (d1
   WHERE maxrec(d2,minval(size(temphealthsentrydata->health_sentry_item[d1.seq].
      health_sentry_descriptions,5),2)))
   JOIN (d2)
   JOIN (vesc
   WHERE vesc.event_set_name="ALL SERVICE SECTIONS")
   JOIN (vese
   WHERE vese.event_set_cd=vesc.event_set_cd)
   JOIN (vec
   WHERE vec.event_cd=vese.event_cd
    AND ((cnvtupper(vec.event_cd_disp)=cnvtupper(temphealthsentrydata->health_sentry_item[d1.seq].
    health_sentry_descriptions[d2.seq].health_sentry_description)) OR (cnvtupper(vec.event_cd_descr)=
   cnvtupper(temphealthsentrydata->health_sentry_item[d1.seq].health_sentry_descriptions[d2.seq].
    health_sentry_description))) )
   JOIN (cv
   WHERE cv.code_value=vec.event_cd
    AND cv.active_ind=1)
   JOIN (r
   WHERE r.code_value=outerjoin(vec.event_cd))
  ORDER BY healthsentryid, vec.event_cd
  HEAD REPORT
   replycount = 0, tempreplycount = 0, stat = alterlist(reply->proposed_relations,50)
  HEAD healthsentryid
   replycount = (replycount+ 1), tempreplycount = (tempreplycount+ 1)
   IF (tempreplycount > 50)
    tempreplycount = 0, stat = alterlist(reply->proposed_relations,(replycount+ 50))
   ENDIF
   reply->proposed_relations[replycount].health_sentry_item_id = temphealthsentrydata->
   health_sentry_item[d1.seq].health_sentry_item_id, reply->proposed_relations[replycount].
   health_sentry_code_set = 72, stat = moverec(temphealthsentrydata->health_sentry_item[d1.seq].
    health_sentry_descriptions,reply->proposed_relations[replycount].health_sentry_descriptions),
   codevaluecount = 0
  HEAD vec.event_cd
   IF (r.br_hlth_sntry_mill_item_id=0)
    codevaluecount = (codevaluecount+ 1), stat = alterlist(reply->proposed_relations[replycount].
     millenium_items,codevaluecount), reply->proposed_relations[replycount].millenium_items[
    codevaluecount].event_cd = vec.event_cd,
    reply->proposed_relations[replycount].millenium_items[codevaluecount].event_cd_display = vec
    .event_cd_disp, reply->proposed_relations[replycount].millenium_items[codevaluecount].
    event_cd_description = vec.event_cd_descr, reply->proposed_relations[replycount].millenium_items[
    codevaluecount].event_set_name = vec.event_set_name
   ENDIF
  FOOT  healthsentryid
   stat = alterlist(reply->proposed_relations[replycount].millenium_items,codevaluecount)
   IF (codevaluecount=0)
    tempreplycount = (tempreplycount - 1), replycount = (replycount - 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->proposed_relations,replycount)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
