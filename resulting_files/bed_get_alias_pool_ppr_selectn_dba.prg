CREATE PROGRAM bed_get_alias_pool_ppr_selectn:dba
 RECORD reply(
   1 person_reltn_alias_pools[*]
     2 alias_pool_cd = f8
     2 person_relations[*]
       3 reltn_type_cd = f8
       3 reltn_type_disp = vc
       3 reltn_type_meaning = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE expandindex = i4 WITH noconstant(0), protect
 DECLARE prsnreltnapcnt = i4 WITH noconstant(0), protect
 DECLARE prsnreltnscnt = i4 WITH noconstant(0), protect
 DECLARE errmsg = vc WITH noconstant(""), protect
 IF (size(request->alias_pool,5) > 0)
  SELECT INTO "nl:"
   FROM alias_pool_ppr_selection apps,
    code_value cv
   PLAN (apps
    WHERE expand(expandindex,1,size(request->alias_pool,5),apps.alias_pool_cd,request->alias_pool[
     expandindex].alias_pool_cd)
     AND apps.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=apps.person_reltn_type_cd)
   ORDER BY apps.alias_pool_cd, cv.display
   HEAD apps.alias_pool_cd
    prsnreltnapcnt = (prsnreltnapcnt+ 1), prsnreltnscnt = 0
    IF (mod(prsnreltnapcnt,10)=1)
     stat = alterlist(reply->person_reltn_alias_pools,(prsnreltnapcnt+ 9))
    ENDIF
    reply->person_reltn_alias_pools[prsnreltnapcnt].alias_pool_cd = apps.alias_pool_cd
   DETAIL
    prsnreltnscnt = (prsnreltnscnt+ 1)
    IF (mod(prsnreltnscnt,10)=1)
     stat = alterlist(reply->person_reltn_alias_pools[prsnreltnapcnt].person_relations,(prsnreltnscnt
      + 9))
    ENDIF
    reply->person_reltn_alias_pools[prsnreltnapcnt].person_relations[prsnreltnscnt].reltn_type_cd =
    apps.person_reltn_type_cd, reply->person_reltn_alias_pools[prsnreltnapcnt].person_relations[
    prsnreltnscnt].reltn_type_disp = cv.display, reply->person_reltn_alias_pools[prsnreltnapcnt].
    person_relations[prsnreltnscnt].reltn_type_meaning = cv.cdf_meaning
   FOOT  apps.alias_pool_cd
    stat = alterlist(reply->person_reltn_alias_pools[prsnreltnapcnt].person_relations,prsnreltnscnt)
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->person_reltn_alias_pools,prsnreltnapcnt)
  IF (error(errmsg,0) > 0)
   SET reply->status_data.status = "F"
   SET reply->error_msg = concat(curprog,"ERROR MSG: ",errmsg)
   GO TO exit_script
  ELSEIF (curqual <= 0)
   SET reply->status_data.status = "Z"
   SET reply->error_msg = concat(curprog,"ERROR MSG: ","No row found for the given alias_pool_cd")
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(curprog,"ERROR MSG: ","No values passed in request.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
