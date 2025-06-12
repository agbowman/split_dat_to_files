CREATE PROGRAM ccl_prompt_del_prompts:dba
 DECLARE getpromptid(void=i2) = null
 DECLARE deletepromptproperties(void=i2) = null
 DECLARE deletepromptdefintions(void=i2) = null
 DECLARE isprotected(userid=f8) = i1
 IF (validate(reply->status_data.status,"?")="?")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD prompttable
 RECORD prompttable(
   1 prompts[*]
     2 promptid = f8
 )
 SET reply->status_data.status = "S"
 SET request->programname = cnvtupper(trim(request->programname))
 CALL getpromptid(0)
 IF (size(prompttable->prompts,5) > 0)
  IF (validate(reqinfo->updt_id,0.0) != 0.0
   AND isprotected(reqinfo->updt_id)=1)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Form Protection Check"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = build(request->programname,":",request
    ->groupno)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "can not delete a protected prompt form"
  ELSE
   CALL deletepromptproperties(0)
   CALL deletepromptdefintions(0)
   COMMIT
   SET reply->status_data.status = "S"
   SELECT INTO "nl:"
    cpd.program_name
    FROM ccl_prompt_definitions cpd
    WHERE (cpd.program_name=request->programname)
     AND (cpd.group_no=request->groupno)
    DETAIL
     reply->status_data.status = "S"
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "Validate Form Exist"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = build(request->programname,":",request
   ->groupno)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "form not found"
 ENDIF
 RETURN
 SUBROUTINE isprotected(userid)
   DECLARE username = vc WITH protect
   DECLARE bprotected = i1 WITH protect, noconstant(1)
   DECLARE owner = vc WITH protect
   IF (validate(_user_override_,"N")="Y")
    CALL echo("user protect override = Y")
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.person_id=userid
    DETAIL
     username = build(p.username)
    WITH nocounter
   ;end select
   IF (textlen(username) > 0)
    DECLARE bprotectfound = i1 WITH protect, noconstant(0)
    SELECT
     *
     FROM ccl_prompt_definitions cpd,
      ccl_prompt_properties cpp
     WHERE cpd.program_name=cnvtupper(request->programname)
      AND (cpd.group_no=request->groupno)
      AND cpd.position=0
      AND cpp.prompt_id=cpd.prompt_id
      AND cpp.component_name="GENERAL"
      AND cpp.property_name="LOCK-PROTECTION"
     DETAIL
      bprotectfound = 1, owner = cpp.property_value
      IF (username=trim(owner))
       bprotected = 0
      ENDIF
     WITH nocounter
    ;end select
    IF (bprotectfound=1)
     RETURN(bprotected)
    ENDIF
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getpromptid(void)
  SELECT INTO "nl:"
   prompt_id
   FROM ccl_prompt_definitions cpd
   WHERE (trim(cpd.program_name)=request->programname)
    AND (cpd.group_no=request->groupno)
   ORDER BY cpd.prompt_id
   HEAD REPORT
    prmpt = 0
   DETAIL
    prmpt = (prmpt+ 1), stat = alterlist(prompttable->prompts,prmpt), prompttable->prompts[prmpt].
    promptid = cpd.prompt_id
   WITH nocounter
  ;end select
  RETURN
 END ;Subroutine
 SUBROUTINE deletepromptproperties(void)
   FOR (i = 1 TO size(prompttable->prompts,5))
     DELETE  FROM ccl_prompt_properties cpp
      WHERE (cpp.prompt_id=prompttable->prompts[i].promptid)
      WITH nocounter
     ;end delete
   ENDFOR
 END ;Subroutine
 SUBROUTINE deletepromptdefintions(void)
  FOR (i = 1 TO size(prompttable->prompts,5))
    DELETE  FROM ccl_prompt_definitions cpd
     WHERE (cpd.prompt_id=prompttable->prompts[i].promptid)
     WITH nocounter
    ;end delete
  ENDFOR
  DELETE  FROM ccl_prompt_programs cpp
   WHERE cpp.control_class_id=1
    AND (cpp.program_name=request->programname)
    AND (cpp.group_no=request->groupno)
   WITH nocounter
  ;end delete
 END ;Subroutine
END GO
