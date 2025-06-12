CREATE PROGRAM daf_migrator_grab_cso_admin:dba
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
 DECLARE dmgca_bad_cnt = i4 WITH public, noconstant(0)
 IF ((request->environment_id=0))
  SET reply->status_data.status = "F"
  SET reply->message = "There was no environment id chosen for this operation."
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO size(request->obj_list,5))
   DELETE  FROM ccl_synch_objects cso
    WHERE cso.object_name=cnvtupper(trim(request->obj_list[i].script_name,3))
     AND (cso.cclgroup=request->obj_list[i].script_group)
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Error deleting ",request->obj_list[i].script_name," from CSO: ",
     errmsg)
    GO TO exit_script
   ENDIF
   INSERT  FROM ccl_synch_objects cso
    (cso.ccl_synch_objects_id, cso.object_name, cso.cclgroup,
    cso.object_type, cso.checksum, cso.dic_data0,
    cso.dic_data1, cso.dic_key0, cso.dic_key1,
    cso.dir_name, cso.endian_platform, cso.major_version,
    cso.minor_version, cso.node_name, cso.qual,
    cso.rcode, cso.timestamp_dt_tm, cso.updt_applctx,
    cso.updt_cnt, cso.updt_dt_tm, cso.updt_id,
    cso.updt_task)(SELECT
     dacso.dm_adm_ccl_synch_objects_id, dacso.object_name, dacso.cclgroup,
     dacso.object_type, dacso.checksum, dacso.dic_data0,
     dacso.dic_data1, dacso.dic_key0, dacso.dic_key1,
     dacso.dir_name, dacso.endian_platform, dacso.major_version,
     dacso.minor_version, dacso.node_name, dacso.qual,
     dacso.rcode, dacso.timestamp_dt_tm, dacso.updt_applctx,
     dacso.updt_cnt, dacso.updt_dt_tm, dacso.updt_id,
     dacso.updt_task
     FROM dm_adm_ccl_synch_objects dacso
     WHERE (dacso.environment_id=request->environment_id)
      AND dacso.object_name=cnvtupper(trim(request->obj_list[i].script_name,3))
      AND (dacso.cclgroup=request->obj_list[i].script_group))
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Error exporting ",request->obj_list[i].script_name,": ",errmsg)
    GO TO exit_script
   ENDIF
   IF (curqual=0)
    SET dmgca_bad_cnt = (dmgca_bad_cnt+ 1)
    SET stat = alterlist(reply->bad_list,dmgca_bad_cnt)
    SET reply->bad_list[dmgca_bad_cnt].script_name = request->obj_list[i].script_name
    SET reply->bad_list[dmgca_bad_cnt].script_group = request->obj_list[i].script_group
   ENDIF
   COMMIT
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->message = "Scripts were grabbed from Admin database successfully."
#exit_script
END GO
