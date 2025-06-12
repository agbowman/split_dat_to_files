CREATE PROGRAM do_concept_filter_list:dba
 DECLARE viewtable = vc WITH protect
 DECLARE limittable = vc WITH protect
 DECLARE limitqual = vc WITH protect
 DECLARE conceptsearch = vc WITH protect
 DECLARE resumequal = vc WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE count = i4 WITH protect
 DECLARE msg = vc WITH protect
 RECORD contextuuids(
   1 data[*]
     2 uuid = vc
 )
 IF (size(request->params,5) > 0)
  SET stat = alterlist(contextuuids->data,size(request->params[1].data,5))
  FOR (count = 1 TO size(request->params[1].data,5))
    SET contextuuids->data[count].uuid = request->params[1].data[count].currcv
  ENDFOR
 ENDIF
 SET conceptsearch = concat(trim(cnvtupper(start_value),3),"*")
 IF (isnumeric(request->val2))
  SET viewtable = "do_code_value_concept_vw"
  SET limittable = "code_value"
  SET limitqual = "lim.code_value = dvw.code_value and lim.code_set = cnvtint(request->val2)"
 ELSE
  SET viewtable = "do_nomenclature_concept_vw"
  SET limittable = "nomenclature"
  SET limitqual = "lim.nomenclature_id = dvw.nomenclature_id"
 ENDIF
 IF ((context->context_ind=1))
  SET resumequal = "dc.do_concept_name >= context->string1 and dc.do_concept_id > context->num1"
 ELSE
  SET resumequal = "1 = 1"
 ENDIF
 SELECT DISTINCT INTO "nl:"
  dc.do_concept_name, dc.do_concept_uuid, dc.do_concept_id
  FROM do_concept dc,
   do_context_version dxv,
   (
   (
   (SELECT
    dxv.do_context_id, version = max(dxv.do_context_version_nbr)
    FROM do_context dx,
     do_context_version dxv
    WHERE dxv.do_context_id=dx.do_context_id
     AND expand(count,1,size(contextuuids->data,5),dx.do_context_uuid,contextuuids->data[count].uuid)
    GROUP BY dxv.do_context_id
    WITH sqltype("F8","I4")))
   dv),
   (parser(viewtable) dvw),
   (parser(limittable) lim)
  WHERE dxv.do_context_version_id=dc.do_context_version_id
   AND dv.version=dxv.do_context_version_nbr
   AND dv.do_context_id=dxv.do_context_id
   AND dvw.do_concept_id=dc.do_concept_id
   AND parser(limitqual)
   AND cnvtupper(dc.do_concept_name)=patstring(conceptsearch)
   AND parser(resumequal)
  ORDER BY dc.do_concept_name, dc.do_concept_id
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,100)=1)
    stat = alterlist(reply->datacoll,(count+ 99))
   ENDIF
   reply->datacoll[count].description = dc.do_concept_name, reply->datacoll[count].currcv = dc
   .do_concept_uuid
   IF (count=maxqualrows)
    context->context_ind = 1, context->maxqual = maxqualrows, context->start_value = start_value,
    context->num1 = dc.do_concept_id, context->string1 = dc.do_concept_name
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->datacoll,count)
  WITH nocounter, maxqual(dc,value(maxqualrows))
 ;end select
 IF (error(msg,0) != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ERROR"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = msg
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_now
 CALL echorecord(reply)
 CALL echorecord(context)
END GO
