CREATE PROGRAM ccl_prompt_updt_prompts:dba
 IF (validate(reply,"n")="n")
  RECORD reply(
    1 prompts[*]
      2 promptid = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE promptexist(nprompt=i2) = i2
 DECLARE promptidexist(nprompt=i2) = i2
 DECLARE addprompt(nprompt=i2) = null
 DECLARE updateprompt(nprompt=i2) = null
 DECLARE deleteprompt(nprompt=i2) = null
 DECLARE addtoprograms(sprgname=vc,grpno=i2) = null
 DECLARE addproperties(nprompt=i2) = null
 DECLARE nextsequence(x=i2) = f8
 DECLARE deleteproperties(nprompt=i2) = null
 DECLARE writelog(msg=vc) = null
 DECLARE unchanged = i2 WITH constant(0)
 DECLARE new = i2 WITH constant(1)
 DECLARE updated = i2 WITH constant(2)
 DECLARE deleted = i2 WITH constant(3)
 DECLARE newline = vc
 DECLARE nerrorcount = i2 WITH noconstant(0)
 DECLARE strerror = vc WITH notrim
 SET reply->status_data.status = "Z"
 SET newline = concat(char(10),char(13))
 SET request->programname = cnvtupper(request->programname)
 CALL writelog(concat("updating prompt defintions for ",request->programname))
 FOR (i = 1 TO size(request->prompts,5))
  SET stat = alterlist(reply->prompts,i)
  IF ((request->prompts[i].promptid != 0.0))
   SET reply->prompts[i].promptid = request->prompts[i].promptid
   CASE (request->prompts[i].operation)
    OF deleted:
     CALL deleteprompt(i)
   ENDCASE
  ENDIF
 ENDFOR
 FOR (i = 1 TO size(request->prompts,5))
   SET stat = alterlist(reply->prompts,i)
   SET reply->prompts[i].promptid = request->prompts[i].promptid
   CASE (request->prompts[i].operation)
    OF new:
     CALL addprompt(i)
    OF updated:
     IF ((request->prompts[i].promptid=0.0))
      CALL addprompt(i)
     ELSE
      CALL updateprompt(i)
     ENDIF
   ENDCASE
 ENDFOR
 IF (nerrorcount > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = request->programname
  SET reply->status_data.subeventstatus[1].targetobjectvalue = strerror
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  CALL addtoprograms(request->programname,request->groupno)
  COMMIT
 ENDIF
 SUBROUTINE nextsequence(x)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    oracleseq = seq(ccl_seq,nextval)
    FROM dual
    DETAIL
     nsequence = oracleseq
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 SUBROUTINE addprompt(nprompt)
   DECLARE nseq = f8
   CALL writelog(concat("add prompt ",cnvtstring(nprompt)," definition"))
   IF (promptexist(nprompt)=0)
    SET nseq = nextsequence(0)
    SET reply->prompts[nprompt].promptid = nseq
    SET request->prompts[nprompt].promptid = nseq
    INSERT  FROM ccl_prompt_definitions cpd
     SET cpd.prompt_id = request->prompts[nprompt].promptid, cpd.program_name = trim(request->
       programname,3), cpd.group_no = request->groupno,
      cpd.prompt_name = trim(substring(1,30,request->prompts[nprompt].promptname),3), cpd.position =
      request->prompts[nprompt].position, cpd.control = request->prompts[nprompt].control,
      cpd.display = request->prompts[nprompt].display, cpd.description = request->prompts[nprompt].
      description, cpd.default_value = request->prompts[nprompt].defaultvalue,
      cpd.result_type_ind = request->prompts[nprompt].resulttype, cpd.width = request->prompts[
      nprompt].width, cpd.height = request->prompts[nprompt].height,
      cpd.exclude_ind = request->prompts[nprompt].excludeind, cpd.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), cpd.updt_id = reqinfo->updt_id,
      cpd.updt_task = reqinfo->updt_task, cpd.updt_cnt = 1, cpd.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    CALL deleteproperties(i)
    CALL addproperties(i)
    RETURN
   ELSE
    SET nerrorcount = (nerrorcount+ 1)
    SET strerror = concat(strerror,"duplicate prompt name [",trim(request->programname,3),":",trim(
      cnvtstring(request->groupno),3),
     "->",trim(request->prompts[nprompt].promptname,3),"]/",trim(cnvtstring(request->prompts[nprompt]
       .promptid)),"/",
     trim(cnvtstring(request->prompts[nprompt].operation))," constraint violation",newline)
   ENDIF
 END ;Subroutine
 SUBROUTINE updateprompt(nprompt)
  CALL writelog(concat("update prompt #",cnvtstring(nprompt)))
  IF (promptidexist(nprompt)=1)
   CALL writelog("update prompt definition row")
   UPDATE  FROM ccl_prompt_definitions cpd
    SET cpd.program_name = trim(request->programname,3), cpd.group_no = request->groupno, cpd
     .prompt_name = trim(request->prompts[nprompt].promptname,3),
     cpd.position = request->prompts[nprompt].position, cpd.control = request->prompts[nprompt].
     control, cpd.display = request->prompts[nprompt].display,
     cpd.description = request->prompts[nprompt].description, cpd.default_value = request->prompts[
     nprompt].defaultvalue, cpd.result_type_ind = request->prompts[nprompt].resulttype,
     cpd.width = request->prompts[nprompt].width, cpd.height = request->prompts[nprompt].height, cpd
     .exclude_ind = request->prompts[nprompt].excludeind,
     cpd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpd.updt_id = reqinfo->updt_id, cpd.updt_task
      = reqinfo->updt_task,
     cpd.updt_cnt = (cpd.updt_cnt+ 1), cpd.updt_applctx = reqinfo->updt_applctx
    WHERE (cpd.prompt_id=request->prompts[nprompt].promptid)
    WITH nocounter
   ;end update
   CALL writelog("update prompts component table")
   CALL deleteproperties(nprompt)
   CALL addproperties(nprompt)
  ELSE
   CALL addprompt(nprompt)
   SET nerrorcount = (nerrorcount+ 1)
   SET strerror = concat(strerror,"invalid prompt id for ",trim(cnvtstring(request->prompts[nprompt].
      promptid),3),"[",trim(request->prompts[nprompt].promptname,3),
    "] can not update record",newline)
  ENDIF
 END ;Subroutine
 SUBROUTINE deleteprompt(nprompt)
  CALL writelog(concat("delete definition for prompt ",cnvtstring(nprompt)))
  IF ((request->prompts[nprompt].promptid > 0))
   CALL deleteproperties(nprompt)
   DELETE  FROM ccl_prompt_definitions cpd
    WHERE (cpd.prompt_id=request->prompts[nprompt].promptid)
    WITH nocounter
   ;end delete
   RETURN
  ELSE
   SET nerrorcount = (nerrorcount+ 1)
   SET strerror = concat(strerror,"could not delete prompt [",request->prompts[nprompt].promptname,
    "]",newline)
  ENDIF
 END ;Subroutine
 SUBROUTINE addproperties(nprompt)
   DECLARE ncompcount = i2
   DECLARE npropcount = i2
   DECLARE strcomp = vc
   CALL writelog(concat("add properties for prompt ",cnvtstring(nprompt)))
   IF (nprompt > 0)
    FOR (comp = 1 TO size(request->prompts[nprompt].components,5))
      IF ((request->prompts[nprompt].components[comp].componentname > ""))
       FOR (prty = 1 TO size(request->prompts[nprompt].components[comp].properties,5))
         IF ((request->prompts[nprompt].components[comp].properties[prty].propertyname > ""))
          INSERT  FROM ccl_prompt_properties cpp
           SET cpp.prompt_id = request->prompts[nprompt].promptid, cpp.component_name = trim(
             substring(1,30,request->prompts[nprompt].components[comp].componentname),3), cpp
            .property_name = trim(substring(1,30,request->prompts[nprompt].components[comp].
              properties[prty].propertyname),3),
            cpp.property_value = substring(1,1000,request->prompts[nprompt].components[comp].
             properties[prty].propertyvalue), cpp.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpp
            .updt_id = reqinfo->updt_id,
            cpp.updt_task = reqinfo->updt_task, cpp.updt_cnt = 1, cpp.updt_applctx = reqinfo->
            updt_applctx
           WITH nocounter
          ;end insert
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ELSE
    CALL echo("invalid prompt identifier")
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE deleteproperties(nprompt)
  CALL writelog(concat("delete properties for prompt ",cnvtstring(nprompt)))
  IF ((request->prompts[nprompt].promptid > 0))
   DELETE  FROM ccl_prompt_properties
    WHERE (prompt_id=request->prompts[nprompt].promptid)
    WITH nocounter
   ;end delete
  ENDIF
 END ;Subroutine
 SUBROUTINE promptexist(nprompt)
   DECLARE bfound = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM ccl_prompt_definitions cpd
    WHERE trim(cpd.program_name,3)=trim(cnvtupper(request->programname),3)
     AND (cpd.group_no=request->groupno)
     AND trim(cpd.prompt_name,3)=trim(cnvtupper(request->prompts[nprompt].promptname),3)
    DETAIL
     bfound = 1
    WITH nocounter
   ;end select
   RETURN(bfound)
 END ;Subroutine
 SUBROUTINE promptidexist(nprompt)
   DECLARE bfound = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    count(*)
    FROM ccl_prompt_definitions cpd
    WHERE cpd.prompt_id=nprompt
    DETAIL
     bfound = 1
    WITH nocounter
   ;end select
   RETURN(bfound)
 END ;Subroutine
 SUBROUTINE addtoprograms(sprgname,grpno)
   DECLARE bfoundprog = i2
   SET bfoundprog = 0
   SELECT INTO "nl:"
    cpg.*
    FROM ccl_prompt_programs cpg
    WHERE cpg.group_no=grpno
     AND cpg.program_name=sprgname
     AND cpg.control_class_id=1
    DETAIL
     bfoundprog = 1
    WITH nocounter
   ;end select
   IF (bfoundprog=0)
    INSERT  FROM ccl_prompt_programs cpg
     SET cpg.program_name = sprgname, cpg.group_no = grpno, cpg.display = sprgname,
      cpg.description = sprgname, cpg.control_class_id = 1, cpg.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      cpg.updt_id = reqinfo->updt_id, cpg.updt_task = reqinfo->updt_task, cpg.updt_cnt = 0,
      cpg.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
 END ;Subroutine
 SUBROUTINE writelog(msg)
   RETURN
 END ;Subroutine
END GO
