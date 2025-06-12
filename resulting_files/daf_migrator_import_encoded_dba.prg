CREATE PROGRAM daf_migrator_import_encoded:dba
 RECORD reply(
   1 message = vc
   1 obj_list[*]
     2 source_pk_id = f8
     2 target_pk_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(request->synch_list,"Z")="Z")
  SET reply->status_data.status = "F"
  SET reply->message = "Request structure not populated properly"
  GO TO exit_script
 ENDIF
 IF (size(request->synch_list,5)=0)
  SET reply->status_data.status = "F"
  SET reply->message = "There were no scripts selected for migration."
  GO TO exit_script
 ENDIF
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public
 SET stat = alterlist(reply->obj_list,size(request->synch_list,5))
 FOR (i = 1 TO size(request->synch_list,5))
  SET reply->obj_list[i].source_pk_id = request->synch_list[i].ccl_synch_object_id
  SELECT INTO "nl:"
   seq_val = seq(ccl_dic_synch_seq,nextval)
   FROM dual
   DETAIL
    reply->obj_list[i].target_pk_id = seq_val
   WITH nocounter
  ;end select
 ENDFOR
 INSERT  FROM ccl_synch_objects cso,
   (dummyt d  WITH seq = value(size(request->synch_list,5)))
  SET cso.cclgroup = request->synch_list[d.seq].cclgroup, cso.ccl_synch_objects_id = reply->obj_list[
   d.seq].target_pk_id, cso.checksum = request->synch_list[d.seq].checksum,
   cso.dic_data0 = request->synch_list[d.seq].dic_data0, cso.dic_data1 = request->synch_list[d.seq].
   dic_data1, cso.dic_key0 = request->synch_list[d.seq].dic_key0,
   cso.dic_key1 = request->synch_list[d.seq].dic_key1, cso.dir_name = request->synch_list[d.seq].
   dir_name, cso.endian_platform = request->synch_list[d.seq].endian_platform,
   cso.major_version = request->synch_list[d.seq].major_version, cso.minor_version = request->
   synch_list[d.seq].minor_version, cso.node_name = request->synch_list[d.seq].node_name,
   cso.object_name = request->synch_list[d.seq].object_name, cso.object_type = request->synch_list[d
   .seq].object_type, cso.qual = request->synch_list[d.seq].qual,
   cso.rcode = request->synch_list[d.seq].rcode, cso.timestamp_dt_tm = cnvtdatetime(request->
    synch_list[d.seq].timestamp_dt_tm), cso.updt_applctx = request->synch_list[d.seq].updt_applctx,
   cso.updt_cnt = request->synch_list[d.seq].updt_cnt, cso.updt_dt_tm = cnvtdatetime(request->
    synch_list[d.seq].updt_dt_tm), cso.updt_id = request->synch_list[d.seq].updt_id,
   cso.updt_task = request->synch_list[d.seq].updt_task
  PLAN (d)
   JOIN (cso)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to write ccl objects:",errmsg)
  GO TO exit_script
 ENDIF
 COMMIT
 SET reply->status_data.status = "S"
 SET reply->message = "Successfully wrote all CCL_SYNCH_OBJECTS data."
#exit_script
END GO
