CREATE PROGRAM bed_ens_rpt_node_info:dba
 IF ( NOT (validate(temp,0)))
  RECORD temp(
    1 infonumberandsessioninfo[*]
      2 infonumber = f8
      2 sessionstatus = i2
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 nodename = vc
    1 rowidentifier = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 DECLARE bed_is_logical_domain(dummyvar=i2) = i2
 DECLARE bed_get_logical_domain(dummyvar=i2) = f8
 SUBROUTINE bed_is_logical_domain(dummyvar)
   RETURN(checkprg("ACM_GET_CURR_LOGICAL_DOMAIN"))
 END ;Subroutine
 SUBROUTINE bed_get_logical_domain(dummyvar)
  IF (bed_is_logical_domain(null))
   IF (validate(ld_concept_person)=0)
    DECLARE ld_concept_person = i2 WITH public, constant(1)
   ENDIF
   IF (validate(ld_concept_prsnl)=0)
    DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
   ENDIF
   IF (validate(ld_concept_organization)=0)
    DECLARE ld_concept_organization = i2 WITH public, constant(3)
   ENDIF
   IF (validate(ld_concept_healthplan)=0)
    DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
   ENDIF
   IF (validate(ld_concept_alias_pool)=0)
    DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
   ENDIF
   IF (validate(ld_concept_minvalue)=0)
    DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
   ENDIF
   IF (validate(ld_concept_maxvalue)=0)
    DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
   ENDIF
   RECORD acm_get_curr_logical_domain_req(
     1 concept = i4
   )
   RECORD acm_get_curr_logical_domain_rep(
     1 logical_domain_id = f8
     1 status_block
       2 status_ind = i2
       2 error_code = i4
   )
   SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
   EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
   replace("REPLY",acm_get_curr_logical_domain_rep)
   IF ( NOT (acm_get_curr_logical_domain_rep->status_block.status_ind)
    AND checkfun("BEDERROR"))
    CALL bederror(build("Logical Domain Error: ",acm_get_curr_logical_domain_rep->status_block.
      error_code))
   ENDIF
   RETURN(acm_get_curr_logical_domain_rep->logical_domain_id)
  ENDIF
  RETURN(null)
 END ;Subroutine
 IF ( NOT (validate(logical_domain_id)))
  DECLARE logical_domain_id = f8 WITH protect, constant(bed_get_logical_domain(0))
 ENDIF
 IF ( NOT (validate(info_domain_name)))
  DECLARE info_domain_name = vc WITH protect, constant("Bedrock Report Node")
 ENDIF
 DECLARE node_info_domain_name = vc WITH protect, constant(concat(trim(curnode),";",info_domain_name)
  )
 IF ( NOT (validate(true)))
  DECLARE true = i2 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(false)))
  DECLARE false = vc WITH protect, constant(0)
 ENDIF
 DECLARE createdminforowforthisreport() = vc
 DECLARE updatedminforowforthisreport() = null
 DECLARE checkifthereportinforowexistsondminfo() = i2
 DECLARE purgeolddatamorethan30days() = null
 DECLARE checkandupdateifcurrentsessionended() = null
 IF ( NOT (validate(error_flag)))
  DECLARE error_flag = vc WITH protect, noconstant("N")
 ENDIF
 IF ( NOT (validate(ierrcode)))
  DECLARE ierrcode = i4 WITH protect, noconstant(0)
 ENDIF
 IF ( NOT (validate(serrmsg)))
  DECLARE serrmsg = vc WITH protect, noconstant("")
 ENDIF
 DECLARE nextbedrockseq = f8 WITH protect, noconstant(0.0)
 IF (validate(bedbeginscriptrptlogging,char(128))=char(128))
  DECLARE bedbeginscriptrptlogging(dummyvar=i2) = null
  SUBROUTINE bedbeginscriptrptlogging(dummyvar)
    SET reply->status_data.status = "F"
    SET serrmsg = fillstring(132," ")
    SET ierrcode = error(serrmsg,1)
    SET error_flag = "N"
  END ;Subroutine
 ENDIF
 IF (validate(bederrorrptlogging,char(128))=char(128))
  DECLARE bederrorrptlogging(errordescription=vc) = null
  SUBROUTINE bederrorrptlogging(errordescription)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
    GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bederrorrptloggingcheck,char(128))=char(128))
  DECLARE bederrorrptloggingcheck(errordescription=vc) = null
  SUBROUTINE bederrorrptloggingcheck(errordescription)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    CALL bederrorrptlogging(errordescription)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedexitscriptrptlogging,char(128))=char(128))
  DECLARE bedexitscriptrptlogging(commitind=i2) = null
  SUBROUTINE bedexitscriptrptlogging(commitind)
   CALL bederrorrptloggingcheck("Descriptive error message not provided.")
   IF (error_flag="N")
    SET reply->status_data.status = "S"
    IF (commitind)
     COMMIT
    ENDIF
   ELSE
    CALL bederrorrptloggingcheck("This script failed to write/update or delete row(s).")
    SET reply->status_data.status = "F"
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedlogmessagerptlogging,char(128))=char(128))
  DECLARE bedlogmessagerptlogging(subroutinename=vc,message=vc) = null
  SUBROUTINE bedlogmessagerptlogging(subroutinename,message)
    CALL echo("==================================================================")
    CALL echo(build2(curprog," : ",subroutinename,"() :",message))
    CALL echo("==================================================================")
  END ;Subroutine
 ENDIF
 SUBROUTINE logdebugmessagerptlogging(message_header,message)
  IF (validate(debug,0)=1)
   CALL bedlogmessagerptlogging(message_header,message)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE createdminforowforthisreport(dummyvar)
   DECLARE reportname = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    z = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     nextbedrockseq = cnvtreal(z)
    WITH nocounter
   ;end select
   CALL bederrorrptloggingcheck("ERROR 001: Error while getting next bedrock_seq.")
   SET reportname = concat(request->reportname,trim(cnvtstring(nextbedrockseq,20)))
   INSERT  FROM dm_info
    SET info_domain = node_info_domain_name, info_name = reportname, info_domain_id =
     logical_domain_id,
     info_number = cnvtreal(currdbhandle), info_char = "In Progress", info_date = cnvtdatetime(
      curdate,curtime3),
     updt_task = reqinfo->updt_task, updt_id = reqinfo->updt_id, updt_dt_tm = cnvtdatetime(curdate,
      curtime3)
    WITH nocounter
   ;end insert
   CALL bederrorrptloggingcheck("ERROR 002: Error while insert into dm_info.")
   RETURN(reportname)
 END ;Subroutine
 SUBROUTINE updatedminforowforthisreport(dummyvar)
  UPDATE  FROM dm_info
   SET info_number = cnvtreal(currdbhandle), info_char = "Completed", updt_task = reqinfo->updt_task,
    updt_id = reqinfo->updt_id, updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE info_domain=node_info_domain_name
    AND (info_name=request->rowidentifier)
    AND info_domain_id=logical_domain_id
   WITH nocounter
  ;end update
  CALL bederrorrptloggingcheck(concat(
    "ERROR 003: Error while updating into dm_info for logical domain of ",cnvtstring(
     logical_domain_id)))
 END ;Subroutine
 SUBROUTINE checkifthereportinforowexistsondminfo(dummyvar)
   SELECT INTO "NL:"
    FROM dm_info d
    WHERE d.info_domain=node_info_domain_name
     AND (d.info_name=request->rowidentifier)
     AND d.info_domain_id=logical_domain_id
    WITH nocounter
   ;end select
   CALL bederrorrptloggingcheck(concat(
     "ERROR 004: Error while selecting from dm_info for logical domain of ",cnvtstring(
      logical_domain_id)))
   IF (curqual > 0)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE purgeolddatamorethan30days(dummyvar)
  DELETE  FROM dm_info d
   WHERE d.info_domain=patstring(concat("*",info_domain_name,"*"))
    AND d.info_domain_id=logical_domain_id
    AND d.info_date < cnvtdatetime((curdate - 30),curtime3)
   WITH nocounter
  ;end delete
  CALL bederrorrptloggingcheck(concat(
    "ERROR 005: Error while purging old data from dm_info for logical domain of ",cnvtstring(
     logical_domain_id)))
 END ;Subroutine
 SUBROUTINE checkandupdateifcurrentsessionended(dummyvar)
   DECLARE cnt = i4 WITH prtect, noconstant(0)
   DECLARE num = i4 WITH prtect, noconstant(0)
   DECLARE ind = i4 WITH protect, noconstant(0)
   DECLARE index = i4 WITH protect, noconstant(0)
   SELECT INTO "NL:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=node_info_domain_name
      AND di.info_domain_id=logical_domain_id
      AND di.info_char="In Progress")
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(temp->infonumberandsessioninfo,cnt), temp->
     infonumberandsessioninfo[cnt].infonumber = di.info_number,
     temp->infonumberandsessioninfo[cnt].sessionstatus = 0
    WITH nocounter
   ;end select
   CALL bederrorrptloggingcheck(concat(
     "ERROR 006: Error while selecting info_number for logical domain of ",cnvtstring(
      logical_domain_id)))
   SELECT INTO "NL:"
    FROM gv$session vs
    PLAN (vs
     WHERE expand(num,1,size(temp->infonumberandsessioninfo,5),vs.audsid,temp->
      infonumberandsessioninfo[num].infonumber))
    DETAIL
     pos = locateval(index,1,size(temp->infonumberandsessioninfo,5),vs.audsid,temp->
      infonumberandsessioninfo[index].infonumber)
     IF (pos > 0)
      temp->infonumberandsessioninfo[pos].sessionstatus = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorrptloggingcheck(concat(
     "ERROR 007: Error while selecting audsid(gv$session) for logical domain of ",cnvtstring(
      logical_domain_id)))
   FOR (ind = 1 TO size(temp->infonumberandsessioninfo,5))
     IF ((temp->infonumberandsessioninfo[ind].sessionstatus=0))
      UPDATE  FROM dm_info di
       SET di.info_char = "Inactive", di.updt_task = reqinfo->updt_task, di.updt_id = reqinfo->
        updt_id,
        di.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WHERE di.info_domain=node_info_domain_name
        AND di.info_domain_id=logical_domain_id
        AND (di.info_number=temp->infonumberandsessioninfo[ind].infonumber)
       WITH nocounter
      ;end update
      CALL bederrorrptloggingcheck(concat(
        "ERROR 008: Error while updating into dm_info for logical domain of ",cnvtstring(
         logical_domain_id)))
     ENDIF
   ENDFOR
 END ;Subroutine
 CALL bedbeginscriptrptlogging(0)
 CALL purgeolddatamorethan30days(0)
 CALL checkandupdateifcurrentsessionended(0)
 IF ((request->completedind=0))
  SET reply->rowidentifier = createdminforowforthisreport(0)
 ELSEIF ((request->completedind=1))
  IF (checkifthereportinforowexistsondminfo(0)=true)
   CALL updatedminforowforthisreport(0)
   SET reply->rowidentifier = request->rowidentifier
  ELSE
   SET reply->rowidentifier = createdminforowforthisreport(0)
   CALL bedlogmessagerptlogging("The report row was not inserted for some unknown reason.",concat(
     "The logical domain id for this was  ",cnvtstring(logical_domain_id)))
  ENDIF
 ELSE
  CALL bedlogmessagerptlogging("The report script failed.",concat(
    "The report was not generated due to failure of the script that generates the ",request->
    reportname))
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "The report script failed during execution."
  CALL bederrorrptlogging(concat(
    "ERROR 006: The Report was not written because of the failure of the report script for .",request
    ->reportname))
 ENDIF
 SET reply->nodename = curnode
#exit_script
 IF (validate(debug,0)=1)
  CALL bedexitscriptrptlogging(0)
 ELSE
  CALL bedexitscriptrptlogging(1)
 ENDIF
END GO
