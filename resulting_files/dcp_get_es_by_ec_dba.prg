CREATE PROGRAM dcp_get_es_by_ec:dba
 SET modify = predeclare
 RECORD reply(
   1 event_cd_list[*]
     2 event_cd = f8
     2 event_cd_display = c40
     2 event_set_list[*]
       3 event_set_name = c40
       3 event_set_cd = f8
       3 event_set_cd_disp = c40
       3 event_set_cd_descr = vc
       3 event_set_cd_definition = vc
       3 event_set_icon_name = c16
       3 primitive_ind = i2
       3 show_if_no_data_ind = i2
       3 display_association_ind = i2
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
 DECLARE slastmod = c14 WITH protect, noconstant("001 07/09/2008")
 DECLARE bdebugind = i2 WITH protect, noconstant(0)
 DECLARE bstatus = i2 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE dstarttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE event_cd_cnt = i4 WITH protect, noconstant(0)
 DECLARE event_set_cnt = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE request_cnt = i4 WITH protect, noconstant(size(request->event_list,5))
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE expand_size = i4 WITH protect, noconstant(20)
 DECLARE expand_total = i4 WITH noconstant((ceil((cnvtreal(request_cnt)/ expand_size)) * expand_size)
  )
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
 SET bstatus = alterlist(request->event_list,expand_total)
 SELECT INTO "nl:"
  v.event_cd, ve.event_cd, ves.event_set_cd
  FROM v500_event_code v,
   v500_event_set_explode ve,
   v500_event_set_code ves,
   (dummyt d1  WITH seq = value((1+ ((expand_total - 1)/ expand_size))))
  PLAN (d1
   WHERE initarray(expand_start,evaluate(d1.seq,1,1,(expand_start+ expand_size))))
   JOIN (v
   WHERE expand(lidx,expand_start,(expand_start+ (expand_size - 1)),v.event_cd,request->event_list[
    lidx].event_cd))
   JOIN (ve
   WHERE ve.event_cd=v.event_cd)
   JOIN (ves
   WHERE ves.event_set_cd=ve.event_set_cd
    AND ve.event_set_level=0)
  ORDER BY v.event_cd, ve.event_set_cd
  HEAD v.event_cd
   IF (v.event_cd > 0)
    event_cd_cnt = (event_cd_cnt+ 1)
    IF (mod(event_cd_cnt,10)=1)
     bstatus = alterlist(reply->event_cd_list,(event_cd_cnt+ 9))
    ENDIF
    reply->event_cd_list[event_cd_cnt].event_cd = v.event_cd, reply->event_cd_list[event_cd_cnt].
    event_cd_display = v.event_cd_disp, event_set_cnt = 0
   ENDIF
  HEAD ve.event_set_cd
   IF (ve.event_set_cd > 0)
    event_set_cnt = (event_set_cnt+ 1)
    IF (mod(event_set_cnt,10)=1)
     bstatus = alterlist(reply->event_cd_list[event_cd_cnt].event_set_list,(event_set_cnt+ 9))
    ENDIF
    reply->event_cd_list[event_cd_cnt].event_set_list[event_set_cnt].event_set_name = ves
    .event_set_name, reply->event_cd_list[event_cd_cnt].event_set_list[event_set_cnt].event_set_cd =
    ve.event_set_cd, reply->event_cd_list[event_cd_cnt].event_set_list[event_set_cnt].
    event_set_cd_disp = ves.event_set_cd_disp,
    reply->event_cd_list[event_cd_cnt].event_set_list[event_set_cnt].event_set_cd_descr = ves
    .event_set_cd_descr, reply->event_cd_list[event_cd_cnt].event_set_list[event_set_cnt].
    event_set_cd_definition = ves.event_set_cd_definition, reply->event_cd_list[event_cd_cnt].
    event_set_list[event_set_cnt].event_set_icon_name = ves.event_set_icon_name,
    reply->event_cd_list[event_cd_cnt].event_set_list[event_set_cnt].primitive_ind = 1, reply->
    event_cd_list[event_cd_cnt].event_set_list[event_set_cnt].show_if_no_data_ind = ves
    .show_if_no_data_ind, reply->event_cd_list[event_cd_cnt].event_set_list[event_set_cnt].
    display_association_ind = ves.display_association_ind
   ENDIF
  FOOT  ve.event_set_cd
   bstatus = alterlist(reply->event_cd_list[event_cd_cnt].event_set_list,event_set_cnt)
  FOOT REPORT
   bstatus = alterlist(reply->event_cd_list,event_cd_cnt)
  WITH nocounter
 ;end select
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL reportfailure("ERROR","F","dcp_get_es_by_ec",serrormsg)
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
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
