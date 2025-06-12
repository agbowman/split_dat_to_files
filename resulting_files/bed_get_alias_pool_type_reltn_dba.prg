CREATE PROGRAM bed_get_alias_pool_type_reltn:dba
 CALL echo("****bed_get_alias_pool_type_reltn - 763952****")
 CALL echo("****bed_get_alias_pool_type_reltn - 786230****")
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE errmsg = vc WITH protect, noconstant("")
 RECORD reply(
   1 alias_pool_type_reltns[*]
     2 alias_pool_cd = f8
     2 entity_alias_type_cd = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SUBROUTINE (checkaliaspoolconfiguration(aliaspoolcd=f8,typecd=f8) =null)
   SELECT INTO "nl:"
    FROM alias_pool_type_reltn aptr
    WHERE aptr.alias_entity_alias_type_cd=typecd
     AND aptr.alias_pool_cd=aliaspoolcd
     AND aptr.active_ind=1
    ORDER BY aptr.alias_pool_cd
    HEAD aptr.alias_pool_cd
     cnt = (cnt+ 1), stat = alterlist(reply->alias_pool_type_reltns,cnt)
    DETAIL
     reply->alias_pool_type_reltns[cnt].entity_alias_type_cd = aptr.alias_entity_alias_type_cd, reply
     ->alias_pool_type_reltns[cnt].alias_pool_cd = aptr.alias_pool_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->alias_pool_type_reltns,cnt)
   IF (error(errmsg,0) > 0)
    SET reply->status_data.status = "F"
    SET reply->error_msg = concat(curprog,"ERROR MSG: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (checkdomainlevelconfiguration(typecd=f8) =null)
   DECLARE userlogicaldomainid = f8 WITH protect, noconstant(0.0)
   SET userlogicaldomainid = getuserlogicaldomainid(null)
   SELECT INTO "nl:"
    FROM alias_pool_type_reltn aptr,
     alias_pool a
    PLAN (aptr
     WHERE aptr.alias_entity_alias_type_cd=typecd)
     JOIN (a
     WHERE a.alias_pool_cd=aptr.alias_pool_cd
      AND a.logical_domain_id=userlogicaldomainid
      AND aptr.active_ind=1)
    ORDER BY aptr.alias_pool_cd
    HEAD aptr.alias_pool_cd
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(reply->alias_pool_type_reltns,(cnt+ 9))
     ENDIF
    DETAIL
     reply->alias_pool_type_reltns[cnt].entity_alias_type_cd = aptr.alias_entity_alias_type_cd, reply
     ->alias_pool_type_reltns[cnt].alias_pool_cd = aptr.alias_pool_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->alias_pool_type_reltns,cnt)
   IF (error(errmsg,0) > 0)
    SET reply->status_data.status = "F"
    SET reply->error_msg = concat(curprog,"ERROR MSG: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
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
 SUBROUTINE (checkaliaspoolconfigurationwithouttype(aliaspoolcd=f8) =null)
   SELECT INTO "nl:"
    FROM alias_pool_type_reltn aptr
    WHERE aptr.alias_pool_cd=aliaspoolcd
     AND aptr.active_ind=1
    ORDER BY aptr.alias_pool_cd
    HEAD aptr.alias_pool_cd
     cnt = (cnt+ 1), stat = alterlist(reply->alias_pool_type_reltns,cnt)
    DETAIL
     reply->alias_pool_type_reltns[cnt].entity_alias_type_cd = aptr.alias_entity_alias_type_cd, reply
     ->alias_pool_type_reltns[cnt].alias_pool_cd = aptr.alias_pool_cd
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->alias_pool_type_reltns,cnt)
   IF (error(errmsg,0) > 0)
    SET reply->status_data.status = "F"
    SET reply->error_msg = concat(curprog,"ERROR MSG: ",errmsg)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 IF ((request->alias_pool_cd > 0.0)
  AND (request->entity_alias_type_cd > 0.0))
  CALL checkaliaspoolconfiguration(request->alias_pool_cd,request->entity_alias_type_cd)
  IF (size(reply->alias_pool_type_reltns,5)=0)
   CALL checkdomainlevelconfiguration(request->entity_alias_type_cd)
  ENDIF
 ELSEIF ((request->entity_alias_type_cd > 0.0))
  CALL checkdomainlevelconfiguration(request->entity_alias_type_cd)
 ELSEIF ((request->alias_pool_cd > 0.0))
  CALL checkaliaspoolconfigurationwithouttype(request->alias_pool_cd)
 ENDIF
#exit_script
END GO
