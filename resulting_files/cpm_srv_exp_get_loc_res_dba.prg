CREATE PROGRAM cpm_srv_exp_get_loc_res:dba
 DECLARE cnt = i4
 IF ((request->loadloc=1))
  SELECT INTO "nl:"
   lg.child_loc_cd, lg.parent_loc_cd
   FROM location_group lg
   WHERE lg.active_ind=1
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->location,(cnt+ 10))
    ENDIF
    reply->location[cnt].childcd = lg.child_loc_cd, reply->location[cnt].parentcd = lg.parent_loc_cd
   FOOT REPORT
    stat = alterlist(reply->location,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->loadsrvres=1))
  SELECT INTO "nl:"
   rg.child_service_resource_cd, rg.parent_service_resource_cd
   FROM resource_group rg
   WHERE rg.active_ind=1
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->srvres,(cnt+ 10))
    ENDIF
    reply->srvres[cnt].childcd = rg.child_service_resource_cd, reply->srvres[cnt].parentcd = rg
    .parent_service_resource_cd
   FOOT REPORT
    stat = alterlist(reply->srvres,cnt)
   WITH nocounter
  ;end select
 ENDIF
END GO
