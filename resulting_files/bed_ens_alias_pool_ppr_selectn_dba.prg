CREATE PROGRAM bed_ens_alias_pool_ppr_selectn:dba
 CALL echo("*****bed_ens_alias_pool_ppr_select.prg - 763952*****")
 SUBROUTINE (getnextsequencenumber(sseqname=vc) =f8)
   DECLARE dnextseqnum = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    temp_number = seq(parser(sseqname),nextval)
    FROM dual
    DETAIL
     dnextseqnum = cnvtreal(temp_number)
    WITH nocounter
   ;end select
   RETURN(dnextseqnum)
 END ;Subroutine
 RECORD temprec(
   1 person_reltn_alias_pools[*]
     2 alias_pool_code = f8
     2 person_relation[*]
       3 action_flag = i2
       3 type_cd = f8
       3 updt_ind = i2
       3 insrt_ind = i2
 ) WITH protect
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE inactive_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"INACTIVE")), protect
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE errorflag = vc WITH noconstant("N"), protect
 DECLARE errormsg = vc WITH noconstant(""), protect
 DECLARE counter1 = i4 WITH noconstant(0), protect
 DECLARE counter2 = i4 WITH noconstant(0), protect
 SUBROUTINE (insertaliaspoolpprselectionrow(daliaspoolcd=f8,dtypecd=f8) =null)
   DECLARE dseqnumber = f8 WITH noconstant(0.0), protect
   SET dseqnumber = getnextsequencenumber("REFERENCE_SEQ")
   INSERT  FROM alias_pool_ppr_selection apps
    SET apps.active_ind = 1, apps.active_status_prsnl_id = reqinfo->updt_id, apps.active_status_cd =
     active_cd,
     apps.active_status_dt_tm = cnvtdatetime(curdate,curtime3), apps.alias_pool_cd = daliaspoolcd,
     apps.alias_pool_ppr_selection_id = dseqnumber,
     apps.person_reltn_type_cd = dtypecd, apps.updt_cnt = 0, apps.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     apps.updt_applctx = reqinfo->updt_applctx, apps.updt_id = reqinfo->updt_id, apps.updt_task =
     reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual <= 0)
    SET errorflag = "Y"
    SET errormsg = concat(
     "Error in inserting into alias_pool_ppr_selection table for alias pool code: ",cnvtstring(
      daliaspoolcd)," and type code: ",cnvtstring(dtypecd))
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (updatealiaspoolpprselectionrow(daliaspoolcd=f8,dtypecd=f8) =null)
  UPDATE  FROM alias_pool_ppr_selection apps
   SET apps.active_ind = 0, apps.active_status_prsnl_id = reqinfo->updt_id, apps.active_status_cd =
    inactive_cd,
    apps.updt_cnt = (apps.updt_cnt+ 1), apps.updt_dt_tm = cnvtdatetime(curdate,curtime3), apps
    .updt_applctx = reqinfo->updt_applctx,
    apps.updt_id = reqinfo->updt_id, apps.updt_task = reqinfo->updt_task
   WHERE apps.active_ind=1
    AND apps.alias_pool_cd=daliaspoolcd
    AND apps.person_reltn_type_cd=dtypecd
   WITH nocounter
  ;end update
  IF (curqual <= 0)
   SET errorflag = "Y"
   SET errormsg = concat(
    "Error in inactivating row in alias_pool_ppr_selection table for alias pool code: ",cnvtstring(
     daliaspoolcd)," and type cd: ",cnvtstring(typecd))
   GO TO exit_script
  ENDIF
 END ;Subroutine
#main
 FOR (counter1 = 1 TO size(request->person_reltn_alias_pools,5))
   SET stat = alterlist(temprec->person_reltn_alias_pools,size(request->person_reltn_alias_pools,5))
   FOR (counter2 = 1 TO size(request->person_reltn_alias_pools[counter1].person_relation,5))
     SET stat = alterlist(temprec->person_reltn_alias_pools[counter1].person_relation,size(request->
       person_reltn_alias_pools[counter1].person_relation,5))
     SET temprec->person_reltn_alias_pools[counter1].alias_pool_code = request->
     person_reltn_alias_pools[counter1].alias_pool_code
     SET temprec->person_reltn_alias_pools[counter1].person_relation[counter2].type_cd = request->
     person_reltn_alias_pools[counter1].person_relation[counter2].type_cd
     SET temprec->person_reltn_alias_pools[counter1].person_relation[counter2].action_flag = request
     ->person_reltn_alias_pools[counter1].person_relation[counter2].action_flag
     SET temprec->person_reltn_alias_pools[counter1].person_relation[counter2].updt_ind = 0
     SET temprec->person_reltn_alias_pools[counter1].person_relation[counter2].insrt_ind = 1
   ENDFOR
   IF ((request->person_reltn_alias_pools[counter1].alias_pool_code > 0.0))
    SELECT INTO "nl:"
     FROM alias_pool_ppr_selection apps,
      (dummyt d  WITH seq = value(size(request->person_reltn_alias_pools[counter1].person_relation,5)
       ))
     PLAN (d
      WHERE d.seq > 0)
      JOIN (apps
      WHERE apps.active_ind=1
       AND (apps.alias_pool_cd=request->person_reltn_alias_pools[counter1].alias_pool_code)
       AND (apps.person_reltn_type_cd=request->person_reltn_alias_pools[counter1].person_relation[d
      .seq].type_cd))
     DETAIL
      IF ((request->person_reltn_alias_pools[counter1].person_relation[d.seq].action_flag=1))
       temprec->person_reltn_alias_pools[counter1].person_relation[d.seq].insrt_ind = 0
      ELSEIF ((request->person_reltn_alias_pools[counter1].person_relation[d.seq].action_flag=3))
       temprec->person_reltn_alias_pools[counter1].person_relation[d.seq].updt_ind = 1
      ENDIF
     WITH nocounter
    ;end select
    FOR (counter2 = 1 TO size(temprec->person_reltn_alias_pools[counter1].person_relation,5))
      IF ((temprec->person_reltn_alias_pools[counter1].person_relation[counter2].insrt_ind=1)
       AND (temprec->person_reltn_alias_pools[counter1].person_relation[counter2].action_flag=1))
       IF ((request->person_reltn_alias_pools[counter1].person_relation[counter2].type_cd > 0.0))
        CALL insertaliaspoolpprselectionrow(temprec->person_reltn_alias_pools[counter1].
         alias_pool_code,temprec->person_reltn_alias_pools[counter1].person_relation[counter2].
         type_cd)
       ELSE
        SET errorflag = "Y"
        SET errormsg = concat("Invalid person relation type code: ",cnvtstring(temprec->
          person_reltn_alias_pools[counter1].person_relation[counter2].type_cd))
        GO TO exit_script
       ENDIF
      ELSEIF ((temprec->person_reltn_alias_pools[counter1].person_relation[counter2].updt_ind=1))
       CALL updatealiaspoolpprselectionrow(temprec->person_reltn_alias_pools[counter1].
        alias_pool_code,temprec->person_reltn_alias_pools[counter1].person_relation[counter2].type_cd
        )
      ENDIF
    ENDFOR
   ELSE
    SET errorflag = "Y"
    SET errormsg = concat("Invalid alias pool code: ",cnvtstring(request->person_reltn_alias_pools[
      counter1].alias_pool_code))
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (errorflag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  SET reply->error_msg = concat(curprog,"ERROR MSG: ",errormsg)
 ENDIF
END GO
