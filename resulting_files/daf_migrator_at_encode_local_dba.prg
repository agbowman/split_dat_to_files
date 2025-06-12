CREATE PROGRAM daf_migrator_at_encode_local:dba
 RECORD reply(
   1 message = vc
   1 bad_list[*]
     2 script_name = vc
     2 script_group = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public
 DECLARE dmacl_ccl_exists_ind = i2 WITH public, noconstant(0)
 DECLARE dmacl_cso_exists_ind = i2 WITH public, noconstant(0)
 DECLARE dmacl_bad_list = i4 WITH public, noconstant(0)
 IF (size(request->obj_list,5)=0)
  SET reply->status_data.status = "F"
  SET reply->message = "Request structure contains no script data."
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO value(size(request->obj_list,5)))
   SET dmacl_ccl_exists_ind = 0
   SET dmacl_cso_exists_ind = 0
   SELECT INTO "nl:"
    dp.user_name, dp.source_name, dp.datestamp,
    dp.timestamp
    FROM dprotect dp
    WHERE dp.object IN ("P", "E")
     AND dp.object_name=cnvtupper(request->obj_list[i].script_name)
     AND (dp.group=request->obj_list[i].script_group)
    DETAIL
     dmacl_ccl_exists_ind = 1
    WITH nocounter
   ;end select
   IF (dmacl_ccl_exists_ind=1)
    EXECUTE ccl_dic_export_objects request->obj_list[i].script_name, request->obj_list[i].
    script_group, "Y"
    SET errcode = error(errmsg,1)
    IF (errcode != 0)
     ROLLBACK
     SET reply->status_data.status = "F"
     SET reply->message = concat("Error exporting ",request->obj_list[i].script_name,": ",errmsg)
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     cso.object_name
     FROM ccl_synch_objects cso
     WHERE cso.object_name=cnvtupper(request->obj_list[i].script_name)
      AND (cso.cclgroup=request->obj_list[i].script_group)
     DETAIL
      dmacl_cso_exists_ind = 1
     WITH nocounter
    ;end select
    IF (dmacl_cso_exists_ind=0)
     SET dmacl_bad_list = (dmacl_bad_list+ 1)
     SET stat = alterlist(reply->bad_list,dmacl_bad_list)
     SET reply->bad_list[dmacl_bad_list].script_name = request->obj_list[i].script_name
     SET reply->bad_list[dmacl_bad_list].script_group = request->obj_list[i].script_group
    ENDIF
   ELSE
    SET dmacl_bad_list = (dmacl_bad_list+ 1)
    SET stat = alterlist(reply->bad_list,dmacl_bad_list)
    SET reply->bad_list[dmacl_bad_list].script_name = request->obj_list[i].script_name
    SET reply->bad_list[dmacl_bad_list].script_group = request->obj_list[i].script_group
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->message = "Scripts were staged successfully."
#exit_script
END GO
