CREATE PROGRAM dcp_get_letter_types
 RECORD temp(
   1 qual[*]
     2 event_set_name = c40
 )
 RECORD temparray(
   1 qual[*]
     2 event_set_name = c40
 )
 RECORD reply(
   1 lettertypelist[*]
     2 letter_type_cd = f8
     2 letter_disp = vc
     2 letter_desc = vc
     2 letter_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE eventcdcnt = i4 WITH constant(size(request->resulteventcodes,5))
 DECLARE dummyvar = i4 WITH noconstant(1)
 DECLARE bflag = i2 WITH noconstant(1)
 DECLARE icounter = i4 WITH noconstant(0)
 DECLARE tempcnt = i4 WITH noconstant(0)
 DECLARE reduxcnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 CALL echo(build("BEGIN1"))
 CALL echo(build("BEGIN2.2,",icounter))
 SELECT INTO "nl:"
  vese.event_cd
  FROM v500_event_set_explode vese,
   v500_event_set_code esc,
   corr_event_set_mapping cesm
  PLAN (vese
   WHERE expand(tempcnt,1,eventcdcnt,vese.event_cd,request->resulteventcodes[tempcnt].event_cd))
   JOIN (esc
   WHERE esc.event_set_cd=vese.event_set_cd)
   JOIN (cesm
   WHERE cesm.event_set_name=esc.event_set_name
    AND (request->correspond_type_cd=cesm.correspondence_type_cd))
  ORDER BY vese.event_cd, vese.event_set_level
  HEAD vese.event_cd
   bflag = 1
  DETAIL
   CALL echo(build("BEGIN2"))
   IF (bflag=1)
    icounter = (icounter+ 1), stat = alterlist(temp->qual,icounter), temp->qual[icounter].
    event_set_name = cesm.mapped_event_set_name
    IF (cesm.inheritance_flag=0)
     bflag = 0
    ENDIF
   ENDIF
  FOOT  vese.event_cd
   dummyvar = 1,
   CALL echo(build("BEGIN3"))
  WITH nocounter
 ;end select
 CALL echo(build("BEGIN4"))
 CALL echo(build("BEGIN4.4,",tempcnt))
 IF (icounter <= 0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET tempcnt = 0
 SET icounter = 0
 SET reduxcnt = size(temp->qual,5)
 SELECT DISTINCT INTO "nl"
  FROM (dummyt d2  WITH seq = value(reduxcnt))
  ORDER BY temp->qual[d2.seq].event_set_name
  DETAIL
   icounter = (icounter+ 1), stat = alterlist(temparray->qual,icounter), temparray->qual[icounter].
   event_set_name = temp->qual[d2.seq].event_set_name
  WITH nocounter
 ;end select
 DECLARE cnt2 = i4 WITH noconstant(0)
 CALL echo(build("BEGIN5"))
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt d  WITH seq = value(icounter)),
   v500_event_set_code esc,
   v500_event_set_explode exp
  PLAN (d)
   JOIN (esc
   WHERE (esc.event_set_name=temparray->qual[d.seq].event_set_name))
   JOIN (exp
   WHERE exp.event_set_cd=esc.event_set_cd)
  ORDER BY exp.event_cd
  DETAIL
   cnt2 = (cnt2+ 1), stat = alterlist(reply->lettertypelist,cnt2), reply->lettertypelist[cnt2].
   letter_type_cd = exp.event_cd
  WITH nocounter
 ;end select
 IF (cnt2 <= 0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 SET reply->status_data.subeventstatus.operationname = "Get Letter Types"
 SET reply->status_data.subeventstatus.targetobjectname = "dcp_get_letter_types"
 SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_get_letter_types.prg"
 IF ((reply->status_data.status="S"))
  SET reply->status_data.subeventstatus.operationstatus = "S"
 ELSEIF ((reply->status_data.status="Z"))
  SET reply->status_data.subeventstatus.operationstatus = "Z"
 ELSE
  SET reply->status_data.subeventstatus.operationstatus = "F"
 ENDIF
 CALL echorecord(reply)
END GO
