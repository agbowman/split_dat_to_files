CREATE PROGRAM dcp_get_ref_text_exists_batch:dba
 SET modify = predeclare
 RECORD reply(
   1 entity_list[*]
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 text_type_list[*]
       3 text_type_cd = f8
       3 text_type_disp = vc
       3 text_type_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE slastmod = c14 WITH protect, noconstant("000 07/09/2008")
 DECLARE bstatus = i2 WITH protect, noconstant(0)
 DECLARE bdebugind = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE dstarttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE sdateclause = vc WITH protect, noconstant("")
 DECLARE ientitylistcnt = i4 WITH protect, noconstant(0)
 DECLARE itexttypecnt = i4 WITH protect, noconstant(0)
 DECLARE irequestsize = i4 WITH protect, noconstant(size(request->entity_list,5))
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE expand_size = i4 WITH protect, noconstant(20)
 DECLARE expand_total = i4 WITH noconstant((ceil((cnvtreal(irequestsize)/ expand_size)) * expand_size
  ))
 SET reply->status_data.status = "F"
 IF (validate(request->debug_ind))
  IF ((request->debug_ind=1))
   SET bdebugind = 1
  ENDIF
 ENDIF
 IF (bdebugind=1)
  CALL echo("*******************************************************")
  CALL echo("Request")
  CALL echorecord(request)
  CALL echo("*******************************************************")
 ENDIF
 IF (irequestsize <= 0)
  GO TO exit_script
 ENDIF
 SET bstatus = alterlist(request->entity_list,expand_total)
 SELECT INTO "nl:"
  FROM ref_text_reltn r,
   (dummyt d1  WITH seq = value((1+ ((expand_total - 1)/ expand_size))))
  PLAN (d1
   WHERE initarray(expand_start,evaluate(d1.seq,1,1,(expand_start+ expand_size))))
   JOIN (r
   WHERE expand(idx,expand_start,(expand_start+ (expand_size - 1)),r.parent_entity_name,request->
    entity_list[idx].parent_entity_name,
    r.parent_entity_id,request->entity_list[idx].parent_entity_id)
    AND r.beg_effective_dt_tm <= cnvtdatetime(dstarttime)
    AND r.end_effective_dt_tm >= cnvtdatetime(dstarttime))
  ORDER BY r.parent_entity_name, r.parent_entity_id
  HEAD REPORT
   ientitylistcnt = 0
  HEAD r.parent_entity_name
   bstatus = 0
  HEAD r.parent_entity_id
   ientitylistcnt = (ientitylistcnt+ 1)
   IF (mod(ientitylistcnt,10)=1)
    bstatus = alterlist(reply->entity_list,(ientitylistcnt+ 9))
   ENDIF
   reply->entity_list[ientitylistcnt].parent_entity_name = r.parent_entity_name, reply->entity_list[
   ientitylistcnt].parent_entity_id = r.parent_entity_id, itexttypecnt = 0
  HEAD r.text_type_cd
   IF (r.text_type_cd > 0)
    itexttypecnt = (itexttypecnt+ 1), bstatus = alterlist(reply->entity_list[ientitylistcnt].
     text_type_list,itexttypecnt), reply->entity_list[ientitylistcnt].text_type_list[itexttypecnt].
    text_type_cd = r.text_type_cd
   ENDIF
  FOOT REPORT
   bstatus = alterlist(reply->entity_list,ientitylistcnt)
  WITH nocounter
 ;end select
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL reportfailure("ERROR","F","DCP_GET_REF_TEXT_EXISTS2",serrormsg)
 ELSEIF (size(reply->entity_list,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (bdebugind=1)
  CALL echo("*******************************************************")
  CALL echo(build("Last Mod = ",slastmod))
  CALL echo("*******************************************************")
  CALL echo("*******************************************************")
  CALL echo(build("Total Time = ",datetimediff(cnvtdatetime(curdate,curtime3),dstarttime,5)))
  CALL echo("*******************************************************")
  CALL echo("*******************************************************")
  CALL echorecord(reply)
  CALL echo("*******************************************************")
 ENDIF
 SET modify = nopredeclare
END GO
