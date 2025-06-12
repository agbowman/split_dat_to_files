CREATE PROGRAM cr_extract_purged_request:dba
 DECLARE hpersonid = i4 WITH protect, noconstant(0)
 DECLARE personid = f8 WITH protect, noconstant(0.0)
 DECLARE getchildelementoccurrencehandle(pelementhandle=i4,pchildname=vc,poccurrenceindex=i4) = i4
 IF (validate(uar_xml_getattrbyname,char(128))=char(128))
  DECLARE uar_xml_getattrbyname(nodehandle=i4(ref),attrname=vc,attributehandle=i4(ref)) = i4
 ENDIF
 IF (validate(uar_xml_getattrvalue,char(128))=char(128))
  DECLARE uar_xml_getattrvalue(attributehandle=i4(ref)) = vc
 ENDIF
 IF (uar_xml_getattrbyname(request->hrequest,"personId",hpersonid)=sc_ok)
  SET personid = cnvtreal(uar_xml_getattrvalue(hpersonid))
  IF (validate(debug,0)=1)
   CALL echo(build2("Currently evaluating person: ",personid," Person#: ",request->requestidx))
  ENDIF
 ENDIF
 IF (personid > 0.0)
  SET stat = alterlist(objrequeststoconvert->requests,request->requestidx)
  SET objrequeststoconvert->requests[request->requestidx].personid = personid
  SET objrequeststoconvert->requests[request->requestidx].logicaldomainid = - (1.0)
  SET objrequeststoconvert->requests[request->requestidx].hrequest = request->hrequest
 ENDIF
 SET request->requestidx += 1
 SET request->hrequest = getreportelementoccurrencehandle(request->hrequests,"reportRequest",request
  ->requestidx)
 SUBROUTINE getreportelementoccurrencehandle(pelementhandle,pchildname,poccurrenceindex)
   DECLARE __chidx = i4 WITH private, noconstant(poccurrenceindex)
   DECLARE __osnumber = i4 WITH private, noconstant(0)
   DECLARE __chcnt = i4 WITH private, noconstant(0)
   DECLARE __tmpnode = i4 WITH private, noconstant(0)
   IF (pelementhandle > 0.0)
    SET __osnumber = 0
    SET __tmpnode = 0
    IF (uar_xml_getchildnode(pelementhandle,(__chidx - 1),__tmpnode) != sc_ok)
     RETURN(0)
    ENDIF
    IF (uar_xml_getnodename(__tmpnode)=pchildname)
     SET __osnumber += 1
     RETURN(__tmpnode)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
END GO
