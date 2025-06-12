CREATE PROGRAM cdi_get_location_address:dba
 SET modify = predeclare
 IF (validate(request)=0)
  RECORD request(
    1 qual[*]
      2 location_cd = f8
  )
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 qual[*]
      2 location_cd = f8
      2 street_addr = vc
      2 street_addr2 = vc
      2 street_addr3 = vc
      2 street_addr4 = vc
      2 city = vc
      2 state = vc
      2 zipcode = vc
      2 country = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE lreq_size = i4 WITH protect, constant(size(request->qual,5))
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE dstarttime = f8 WITH private, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH private, noconstant(0.0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lpos = i4 WITH protect, noconstant(0)
 DECLARE lscnt = i4 WITH protect, noconstant(0)
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 DECLARE attrcount = i4 WITH protect, noconstant(0)
 DECLARE actioncount = i4 WITH protect, noconstant(0)
 DECLARE actionsloaded = i2 WITH protect, noconstant(false)
 CALL echo(sline)
 CALL echo("********** BEGIN cdi_get_location_address **********")
 CALL echo(sline)
 CALL echorecord(request)
 CALL echo(sline)
 IF (lreq_size <= 0)
  SET sscriptstatus = "Z"
  SET sscriptmsg = "REQUEST WAS EMPTY"
  GO TO exit_script
 ENDIF
 SET dstat = alterlist(reply->qual,lreq_size)
 FOR (lidx = 1 TO lreq_size)
   SET reply->qual[lidx].location_cd = request->qual[lidx].location_cd
 ENDFOR
 SELECT INTO "nl:"
  FROM address addr
  WHERE expand(lidx,1,lreq_size,addr.parent_entity_id,request->qual[lidx].location_cd)
   AND addr.parent_entity_name="LOCATION"
  ORDER BY addr.parent_entity_id
  HEAD addr.parent_entity_id
   actionsloaded = false, lpos = locateval(lidx,1,lreq_size,addr.parent_entity_id,reply->qual[lidx].
    location_cd)
   IF (lpos > 0)
    lscnt += 1, reply->qual[lpos].location_cd = addr.parent_entity_id, reply->qual[lpos].street_addr
     = addr.street_addr,
    reply->qual[lpos].street_addr2 = addr.street_addr2, reply->qual[lpos].street_addr3 = addr
    .street_addr3, reply->qual[lpos].street_addr4 = addr.street_addr4
    IF (addr.city_cd > 0)
     reply->qual[lpos].city = uar_get_code_display(addr.city_cd)
    ELSE
     reply->qual[lpos].city = addr.city
    ENDIF
    IF (addr.state_cd > 0)
     reply->qual[lpos].state = uar_get_code_display(addr.state_cd)
    ELSE
     reply->qual[lpos].state = addr.state
    ENDIF
    reply->qual[lpos].zipcode = addr.zipcode
    IF (addr.country_cd > 0)
     reply->qual[lpos].country = uar_get_code_display(addr.country_cd)
    ELSE
     reply->qual[lpos].country = addr.country
    ENDIF
    sscriptstatus = "S"
   ENDIF
  WITH nocounter
 ;end select
 IF (lscnt=size(reply->qual,5))
  SET sscriptstatus = "S"
  SET sscriptmsg = "All addresses were found"
 ELSEIF (lscnt > 0)
  SET sscriptstatus = "S"
  SET sscriptmsg = "Some addresses were not found, check individual status"
 ELSE
  SET sscriptstatus = "Z"
  SET sscriptmsg = "All addresses were not found"
 ENDIF
#exit_script
 SET reply->status_data.status = sscriptstatus
 CALL alterlist(reply->subeventstatus,1)
 SET reply->status_data.subeventstatus[1].operationstatus = sscriptstatus
 SET reply->status_data.subeventstatus[1].operationname = "SELECT"
 SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_GET_LOCATION_ADDRESS"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 CALL echo(sline)
 CALL echorecord(reply)
 CALL echo(sline)
 SET delapsedtime = ((curtime3 - dstarttime)/ 100)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(delapsedtime,12,2),3)))
 CALL echo("Last Mod: 000")
 CALL echo("Mod Date: 11/11/2015")
 CALL echo(sline)
 SET modify = nopredeclare
 CALL echo("********** END CDI_GET_LOCATION_ADDRESS **********")
 CALL echo(sline)
END GO
