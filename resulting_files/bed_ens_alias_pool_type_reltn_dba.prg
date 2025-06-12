CREATE PROGRAM bed_ens_alias_pool_type_reltn:dba
 CALL echo("*****bed_ens_alias_pool_type_reltn.prg - 763952*****")
 IF ((validate(bpmgenerateidsubinclude,- (9))=- (9)))
  DECLARE bpmgenerateidsubinclude = i2 WITH noconstant(true)
  IF (validate(serrmsg,"ZZZ")="ZZZ")
   DECLARE serrmsg = vc WITH noconstant(""), protect
  ENDIF
  IF ((validate(lerror,- (99))=- (99)))
   DECLARE lerror = i4 WITH noconstant(0), protect
   SET lerror = error(serrmsg,1)
  ENDIF
  DECLARE generateidbysequencename(ssequencename=vc) = f8
  SUBROUTINE generateidbysequencename(ssequencename)
    DECLARE dnewid = f8 WITH noconstant(0.0), protect
    SET ssequencename = cnvtupper(trim(ssequencename,3))
    SELECT INTO "nl:"
     tempid = seq(parser(ssequencename),nextval)
     FROM dual
     DETAIL
      dnewid = cnvtreal(tempid)
     WITH format, nocounter
    ;end select
    SET lerror = error(serrmsg,0)
    IF (lerror > 0
     AND curqual=0)
     RETURN(0.0)
    ELSE
     RETURN(dnewid)
    ENDIF
  END ;Subroutine
 ENDIF
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 error_msg = vc
 ) WITH protect
 DECLARE inactive_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"INACTIVE")), protect
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE errormsg = vc WITH noconstant(""), protect
 DECLARE personalias_entityname = vc WITH constant("PERSON_ALIAS"), protect
 SUBROUTINE (insertaliaspooltyperelationrow(aliaspoolcd=f8,typecd=f8) =null)
   DECLARE seqnumber = f8 WITH noconstant(0.0), protect
   DECLARE entityname = vc WITH noconstant(""), protect
   SET seqnumber = generateidbysequencename("REFERENCE_SEQ")
   IF (getcodeset(request->alias_type_cd)=4)
    SET entityname = personalias_entityname
   ENDIF
   INSERT  FROM alias_pool_type_reltn aptr
    SET aptr.active_ind = 1, aptr.active_status_prsnl_id = reqinfo->updt_id, aptr.active_status_cd =
     active_cd,
     aptr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), aptr.alias_pool_cd = aliaspoolcd,
     aptr.alias_pool_type_reltn_id = seqnumber,
     aptr.alias_entity_alias_type_cd = typecd, aptr.alias_entity_name = entityname, aptr.updt_cnt = 0,
     aptr.updt_dt_tm = cnvtdatetime(curdate,curtime3), aptr.updt_applctx = reqinfo->updt_applctx,
     aptr.updt_id = reqinfo->updt_id,
     aptr.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual <= 0)
    SET errormsg = "Error in inserting into alias_pool_type_reltn table"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (activatealiaspooltyperelationrow(aliaspoolcd=f8,typecd=f8) =null)
  UPDATE  FROM alias_pool_type_reltn aptr
   SET aptr.active_ind = 1, aptr.active_status_prsnl_id = reqinfo->updt_id, aptr.active_status_dt_tm
     = cnvtdatetime(curdate,curtime3),
    aptr.active_status_cd = active_cd, aptr.updt_cnt = (aptr.updt_cnt+ 1), aptr.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    aptr.updt_applctx = reqinfo->updt_applctx, aptr.updt_id = reqinfo->updt_id, aptr.updt_task =
    reqinfo->updt_task
   WHERE aptr.active_ind=0
    AND aptr.alias_pool_cd=aliaspoolcd
    AND aptr.alias_entity_alias_type_cd=typecd
   WITH nocounter
  ;end update
  IF (curqual <= 0)
   SET errormsg = "Error in activating row in alias_pool_type_reltn table"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE (inactivatealiaspooltyperelationrow(aliaspoolcd=f8) =null)
  UPDATE  FROM alias_pool_type_reltn aptr
   SET aptr.active_ind = 0, aptr.active_status_prsnl_id = reqinfo->updt_id, aptr.active_status_dt_tm
     = cnvtdatetime(curdate,curtime3),
    aptr.active_status_cd = inactive_cd, aptr.updt_cnt = (aptr.updt_cnt+ 1), aptr.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    aptr.updt_applctx = reqinfo->updt_applctx, aptr.updt_id = reqinfo->updt_id, aptr.updt_task =
    reqinfo->updt_task
   WHERE aptr.active_ind=1
    AND aptr.alias_pool_cd=aliaspoolcd
   WITH nocounter
  ;end update
  IF (curqual <= 0)
   SET errormsg = "Error in inactivating row in alias_pool_type_reltn table"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE (getcodeset(typecd=f8) =i4)
   DECLARE codeset = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_value=typecd
    DETAIL
     codeset = cv.code_set
    WITH nocounter
   ;end select
   RETURN(codeset)
 END ;Subroutine
#main
 IF ((request->alias_pool_cd > 0.0))
  IF ((request->alias_type_cd_flag=1))
   IF ((request->alias_type_cd > 0.0))
    IF (checkexistingdomainlevelconfiguration(null)=true)
     SET errormsg = "There already exists a row for the user's logical domain id"
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     FROM alias_pool_type_reltn aptr
     WHERE (aptr.alias_pool_cd=request->alias_pool_cd)
      AND (aptr.alias_entity_alias_type_cd=request->alias_type_cd)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL activatealiaspooltyperelationrow(request->alias_pool_cd,request->alias_type_cd)
    ELSE
     CALL insertaliaspooltyperelationrow(request->alias_pool_cd,request->alias_type_cd)
    ENDIF
   ELSE
    SET errormsg = "Invalid alias type code"
    GO TO exit_script
   ENDIF
  ELSEIF ((request->alias_type_cd_flag=3))
   CALL inactivatealiaspooltyperelationrow(request->alias_pool_cd)
  ENDIF
 ELSE
  SET errormsg = "Invalid alias pool code"
  GO TO exit_script
 ENDIF
 SUBROUTINE (getuserlogicaldomainid(null) =f8)
   DECLARE userlogicaldomainid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    DETAIL
     userlogicaldomainid = p.logical_domain_id
    WITH nocounter
   ;end select
   RETURN(userlogicaldomainid)
 END ;Subroutine
 SUBROUTINE (checkexistingdomainlevelconfiguration(null) =i2)
   DECLARE userlogicaldomainid = f8 WITH protect, noconstant(0.0)
   SET userlogicaldomainid = getuserlogicaldomainid(null)
   SELECT INTO "nl:"
    FROM alias_pool_type_reltn aptr,
     alias_pool ap
    WHERE ap.logical_domain_id=userlogicaldomainid
     AND aptr.alias_pool_cd=ap.alias_pool_cd
     AND aptr.active_ind=1
    WITH nocounter
   ;end select
   IF (curqual > 0)
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
#exit_script
 IF (textlen(trim(errormsg,3))=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  SET reply->error_msg = concat(curprog," ERROR MSG:",errormsg)
 ENDIF
END GO
