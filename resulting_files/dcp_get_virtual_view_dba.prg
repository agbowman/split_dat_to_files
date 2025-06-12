CREATE PROGRAM dcp_get_virtual_view:dba
 RECORD reply(
   1 qual[*]
     2 facility_cd = f8
     2 virtual_view_offset = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncnt = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE high = i4 WITH noconstant(value(size(request->qual,5)))
 DECLARE cfailed = c1 WITH noconstant("F")
 SET reply->status_data.status = "F"
 IF ((request->pref_value="PTFAC/VORC"))
  SELECT INTO "NL:"
   FROM dcp_entity_reltn der
   PLAN (der
    WHERE expand(num,1,high,der.entity1_id,request->qual[num].facility_cd)
     AND (der.entity_reltn_mean=request->pref_value)
     AND der.active_ind=1)
   HEAD REPORT
    ncnt = 0
   DETAIL
    ncnt = (ncnt+ 1)
    IF (ncnt > size(reply->qual,5))
     stat = alterlist(reply->qual,(ncnt+ 10))
    ENDIF
    reply->qual[ncnt].facility_cd = der.entity1_id, reply->qual[ncnt].virtual_view_offset = der
    .entity2_id
   FOOT REPORT
    stat = alterlist(reply->qual,ncnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
