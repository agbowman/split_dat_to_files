CREATE PROGRAM dcp_get_task_form:dba
 SET modify = predeclare
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
 RECORD reply(
   1 task_cnt = i4
   1 task_qual[*]
     2 reference_task_id = f8
     2 task_description = vc
     2 dcp_forms_ref_id = f8
     2 form_description = vc
     2 cdf_meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE task_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET i18nhandle = uar_i18nalphabet_init()
 DECLARE highbuffer = c20 WITH protect, noconstant(fillstring(20," "))
 DECLARE highvalues = vc
 SET modify = nopredeclare
 CALL uar_i18nalphabet_highchar(i18nhandle,highbuffer,size(highbuffer))
 SET modify = predeclare
 SET highvalues = trim(highbuffer)
 SET modify = nopredeclare
 CALL uar_i18nalphabet_end(i18nhandle)
 SET modify = predeclare
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE taskdescupper = vc WITH protect, noconstant("")
 SET taskdescupper = cnvtupper(request->task_description)
 SELECT
  IF ((request->task_type_cd > 0))
   PLAN (ot
    WHERE ot.task_description_key BETWEEN taskdescupper AND highvalues
     AND ot.reference_task_id != 0
     AND (ot.task_type_cd=request->task_type_cd))
    JOIN (dfr
    WHERE dfr.dcp_forms_ref_id=outerjoin(ot.dcp_forms_ref_id)
     AND dfr.active_ind=outerjoin(1))
  ELSE
   PLAN (ot
    WHERE ot.task_description_key BETWEEN taskdescupper AND highvalues
     AND ot.reference_task_id != 0)
    JOIN (dfr
    WHERE dfr.dcp_forms_ref_id=outerjoin(ot.dcp_forms_ref_id)
     AND dfr.active_ind=outerjoin(1))
  ENDIF
  INTO "nl:"
  ot.task_description, ot.task_type_cd, ot.reference_task_id,
  dfr.dcp_forms_ref_id, dfr.description
  FROM order_task ot,
   dcp_forms_ref dfr
  ORDER BY ot.task_description_key
  HEAD REPORT
   task_cnt = 0
  DETAIL
   task_cnt = (task_cnt+ 1)
   IF (task_cnt > size(reply->task_qual,5))
    stat = alterlist(reply->task_qual,(task_cnt+ 51))
   ENDIF
   reply->task_qual[task_cnt].reference_task_id = ot.reference_task_id, reply->task_qual[task_cnt].
   task_description = ot.task_description, reply->task_qual[task_cnt].dcp_forms_ref_id = dfr
   .dcp_forms_ref_id,
   reply->task_qual[task_cnt].form_description = dfr.description, reply->task_qual[task_cnt].
   cdf_meaning = uar_get_code_meaning(ot.task_type_cd)
  WITH maxqual(ot,51)
 ;end select
 SET reply->task_cnt = task_cnt
 SET stat = alterlist(reply->task_qual,task_cnt)
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL reportfailure("ERROR","F","DCP_GET_TASK_FORM",serrormsg)
 ELSEIF ((reply->task_cnt=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "006 03/01/16"
 SET modify = nopredeclare
END GO
