CREATE PROGRAM bhs_athn_parse_oe_details_v2
 IF (validate(request)=0)
  FREE RECORD request
  RECORD request(
    1 oe_params = vc
  ) WITH protect
 ENDIF
 IF (validate(reply)=0)
  FREE RECORD reply
  RECORD reply(
    1 detaillist[*]
      2 oefieldid = f8
      2 oefieldvalue = f8
      2 oefielddisplayvalue = vc
      2 oefielddttmvalue = dq8
      2 oefieldmeaning = vc
      2 modified_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD order_entry
 RECORD order_entry(
   1 blocklist[*]
     2 oefield = vc
 ) WITH protect
 FREE RECORD req_format_str
 RECORD req_format_str(
   1 param = vc
 ) WITH protect
 FREE RECORD rep_format_str
 RECORD rep_format_str(
   1 param = vc
 ) WITH protect
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 IF (textlen(request->oe_params)=0)
  CALL echo("INVALID REQUEST OE_PARAMS...EXITING")
  GO TO exit_script
 ENDIF
 DECLARE oedetailparam = vc WITH protect, noconstant("")
 DECLARE oeblockcnt = i4 WITH protect, noconstant(0)
 DECLARE startpos = i4 WITH protect, noconstant(0)
 DECLARE endpos = i4 WITH protect, noconstant(0)
 DECLARE param = vc WITH protect, noconstant("")
 DECLARE block = vc WITH protect, noconstant("")
 DECLARE oefieldcnt = i4 WITH protect, noconstant(0)
 DECLARE oefieldcntvalidind = i2 WITH protect, noconstant(0)
 DECLARE dttmspacepos = i4 WITH protect, noconstant(0)
 DECLARE dateparam = vc WITH protect, noconstant("")
 DECLARE timeparam = vc WITH protect, noconstant("")
 DECLARE stat = i2 WITH protect, noconstant(0)
 CALL echo(build2("OE_PARAMS IS: ",request->oe_params))
 SET startpos = 1
 SET oedetailparam = trim(request->oe_params,3)
 WHILE (size(oedetailparam) > 0)
   SET endpos = (findstring("|",oedetailparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(oedetailparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,oedetailparam)
    CALL echo(build("PARAM:",param))
    IF (size(param) > 0)
     SET param = replace(param,"-!pipe!-","|",0)
     CALL echo(build("ADDING OEFIELD TO BLOCKLIST: ",param))
     SET oeblockcnt = (oeblockcnt+ 1)
     CALL echo(build("OEBLOCKCNT:",oeblockcnt))
     SET stat = alterlist(order_entry->blocklist,oeblockcnt)
     SET order_entry->blocklist[oeblockcnt].oefield = param
    ENDIF
   ENDIF
   SET oedetailparam = substring((endpos+ 2),(size(oedetailparam) - endpos),oedetailparam)
   CALL echo(build("OEDETAILPARAM:",oedetailparam))
   CALL echo(build("SIZE(OEDETAILPARAM):",size(oedetailparam)))
 ENDWHILE
 SET stat = alterlist(reply->detaillist,oeblockcnt)
 FOR (idx = 1 TO oeblockcnt)
   SET block = order_entry->blocklist[idx].oefield
   SET oefieldcnt = 0
   SET startpos = 0
   IF (((idx=1) OR (oefieldcntvalidind=1)) )
    SET oefieldcntvalidind = 0
    WHILE (size(block) > 0)
      SET endpos = findstring(";",block,1)
      IF (endpos=1)
       SET param = ""
       SET block = substring(2,(size(block) - 1),block)
       CALL echo(build("BLOCK:",block))
       CALL echo(size(block))
      ELSE
       SET endpos = (endpos - 1)
       IF (endpos <= 0)
        SET endpos = size(block)
       ENDIF
       CALL echo(build("ENDPOS:",endpos))
       IF (startpos < endpos)
        SET param = substring(1,endpos,block)
        CALL echo(build("PARAM:",param))
       ENDIF
       SET block = substring((endpos+ 2),(size(block) - endpos),block)
       CALL echo(build("BLOCK:",block))
       CALL echo(size(block))
      ENDIF
      SET param = replace(param,"ltscolgt",";",0)
      CALL echo(build("ADDING OEFIELD TO BLOCKLIST: ",param))
      SET oefieldcnt = (oefieldcnt+ 1)
      CALL echo(build("OEFIELDCNT:",oefieldcnt))
      IF (oefieldcnt=1)
       SET reply->detaillist[idx].oefieldid = cnvtreal(param)
      ELSEIF (oefieldcnt=2)
       SET reply->detaillist[idx].oefieldvalue = cnvtreal(param)
      ELSEIF (oefieldcnt=3)
       SET req_format_str->param = param
       EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST","REQ_FORMAT_STR"), replace("REPLY",
        "REP_FORMAT_STR")
       SET reply->detaillist[idx].oefielddisplayvalue = rep_format_str->param
      ELSEIF (oefieldcnt=4)
       SET reply->detaillist[idx].modified_ind = cnvtint(param)
       SET oefieldcntvalidind = 1
      ELSEIF (oefieldcnt > 4)
       CALL echorecord(order_entry)
       CALL echo("INVALID NUMBER OF OE DETAIL FIELDS (TOO MANY)...EXITING")
       CALL echo("CHECK THAT OEFIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE"
        )
       GO TO exit_script
      ENDIF
    ENDWHILE
   ENDIF
 ENDFOR
 IF (oefieldcntvalidind=0)
  CALL echo("INVALID NUMBER OF OE DETAIL FIELDS (TOO FEW)...EXITING")
  CALL echo("CHECK THAT OEFIELDS CONTAINING RESERVED CHARACTERS USE APPROPRIATE ESCAPE SEQUENCE")
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM order_entry_fields oef,
   oe_field_meaning ofm
  PLAN (oef
   WHERE expand(idx,1,oeblockcnt,oef.oe_field_id,reply->detaillist[idx].oefieldid))
   JOIN (ofm
   WHERE ofm.oe_field_meaning_id=oef.oe_field_meaning_id)
  ORDER BY oef.oe_field_id, ofm.oe_field_meaning_id
  HEAD oef.oe_field_id
   locidx = locateval(idx,1,oeblockcnt,oef.oe_field_id,reply->detaillist[idx].oefieldid)
   IF (locidx > 0)
    reply->detaillist[locidx].oefielddttmvalue = evaluate(oef.field_type_flag,5,cnvtdatetime(reply->
      detaillist[locidx].oefielddisplayvalue),3,cnvtdatetime(substring(1,11,reply->detaillist[locidx]
       .oefielddisplayvalue)),
     0.0), reply->detaillist[locidx].oefieldmeaning = ofm.oe_field_meaning
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
 FREE RECORD order_entry
 FREE RECORD req_format_str
 FREE RECORD rep_format_str
END GO
