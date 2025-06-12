CREATE PROGRAM ccl_prompt_get_prompts:dba
 IF ((validate(reply->actualgroupno,- (1))=- (1)))
  RECORD reply(
    1 prompts[*]
      2 promptid = f8
      2 promptname = vc
      2 position = i2
      2 control = i2
      2 display = vc
      2 description = vc
      2 defaultvalue = vc
      2 resulttype = i2
      2 width = i4
      2 height = i4
      2 components[*]
        3 componentname = vc
        3 properties[*]
          4 propertyname = vc
          4 propertyvalue = vc
      2 excludeind = i2
    1 actualgroupno = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 infonumber = i2
  )
 ENDIF
 DECLARE grpaccno = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].operationname = "Get Prompt"
 SET reply->status_data.subeventstatus[1].operationstatus = "Z"
 SET reply->status_data.subeventstatus[1].targetobjectname = concat(request->programname,":",trim(
   cnvtstring(request->groupno)))
 SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 CALL echorecord(request)
 SET request->programname = trim(cnvtupper(request->programname))
 SET grpaccno = request->groupno
 SELECT INTO "NL:"
  l.logical_domain_id
  FROM logical_domain l
  WHERE l.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 1)
  SELECT INTO "nl:"
   d.info_number
   FROM dm_info d
   WHERE d.info_name="SEC_ORG_RELTN"
    AND d.info_domain="SECURITY"
   DETAIL
    reply->infonumber = d.info_number
  ;end select
 ENDIF
 SELECT INTO "nl:"
  cpd.*, cpp.*
  FROM ccl_prompt_definitions cpd,
   ccl_prompt_properties cpp
  PLAN (cpd
   WHERE (cpd.program_name=request->programname)
    AND cpd.group_no=grpaccno)
   JOIN (cpp
   WHERE ((cpp.prompt_id=cpd.prompt_id) OR (cpp.prompt_id=0)) )
  ORDER BY cpd.position, cpd.prompt_id, cpp.component_name,
   cpp.property_name
  HEAD REPORT
   prmpt = 0, cmpt = 0, prty = 0,
   pos = 0
  HEAD cpd.position
   pos = (pos+ 1)
  HEAD cpd.prompt_id
   prmpt = (prmpt+ 1), stat = alterlist(reply->prompts,prmpt)
   IF ((cpd.group_no=request->groupno))
    reply->prompts[prmpt].promptid = cpd.prompt_id
   ELSE
    reply->prompts[prmpt].promptid = 0.0
   ENDIF
   reply->prompts[prmpt].promptname = cpd.prompt_name, reply->prompts[prmpt].position = (prmpt - 1),
   reply->prompts[prmpt].control = cpd.control,
   reply->prompts[prmpt].display = cpd.display, reply->prompts[prmpt].description = cpd.description,
   reply->prompts[prmpt].defaultvalue = cpd.default_value,
   reply->prompts[prmpt].resulttype = cpd.result_type_ind, reply->prompts[prmpt].width = cpd.width,
   reply->prompts[prmpt].height = cpd.height,
   reply->prompts[prmpt].excludeind = cpd.exclude_ind, cmpt = 0
  HEAD cpp.component_name
   cmpt = (cmpt+ 1), stat = alterlist(reply->prompts[prmpt].components,cmpt), reply->prompts[prmpt].
   components[cmpt].componentname = cpp.component_name,
   prty = 0
  HEAD cpp.property_name
   prty = (prty+ 1), stat = alterlist(reply->prompts[prmpt].components[cmpt].properties,prty), reply
   ->prompts[prmpt].components[cmpt].properties[prty].propertyname = cpp.property_name,
   reply->prompts[prmpt].components[cmpt].properties[prty].propertyvalue = notrim(cpp.property_value)
  FOOT REPORT
   reply->status_data.status = "S"
 ;end select
 SET reply->status_data.subeventstatus[1].operationstatus = "S" WITH nocounter
END GO
