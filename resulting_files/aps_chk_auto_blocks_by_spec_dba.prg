CREATE PROGRAM aps_chk_auto_blocks_by_spec:dba
 RECORD reply(
   1 qual[*]
     2 specimen_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD protocol(
   1 prefix_cd = f8
   1 pathologist_id = f8
   1 max_task_cnt = i2
   1 spec[*]
     2 specimen_cd = f8
     2 case_specimen_id = f8
     2 fixative_cd = f8
     2 priority_cd = f8
     2 priority_disp = c40
     2 protocol_id = f8
     2 task[*]
       3 catalog_cd = f8
       3 task_assay_cd = f8
       3 begin_section = i4
       3 begin_level = i4
       3 create_inventory_flag = i4
       3 stain_ind = i2
       3 t_no_charge_ind = i2
       3 task_type_flag = i2
       3 catalog_type_cd = f8
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  ap.prefix_id
  FROM ap_prefix ap
  PLAN (ap
   WHERE (request->prefix_id=ap.prefix_id)
    AND ap.initiate_protocol_ind=1)
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.seq, specimen_cd = request->qual[d.seq].specimen_cd
  FROM (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d)
  ORDER BY specimen_cd
  HEAD REPORT
   cnt = 0, protocol->prefix_cd = request->prefix_id, protocol->pathologist_id = request->
   pathologist_id
  HEAD specimen_cd
   cnt = (cnt+ 1)
   IF (mod(cnt,5)=1)
    stat = alterlist(protocol->spec,(cnt+ 4))
   ENDIF
   protocol->spec[cnt].specimen_cd = request->qual[d.seq].specimen_cd, protocol->spec[cnt].
   protocol_id = 0.0
  FOOT REPORT
   stat = alterlist(protocol->spec,cnt)
  WITH nocounter
 ;end select
 EXECUTE aps_load_specimen_protocol
 IF ((protocol->max_task_cnt=0))
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt d  WITH seq = value(size(protocol->spec,5))),
   (dummyt d1  WITH seq = value(protocol->max_task_cnt))
  PLAN (d)
   JOIN (d1
   WHERE d1.seq <= size(protocol->spec[d.seq].task,5)
    AND (protocol->spec[d.seq].task[d1.seq].create_inventory_flag IN (1, 3)))
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0
  HEAD d.seq
   cnt = (cnt+ 1)
   IF (mod(cnt,5)=1)
    stat = alterlist(reply->qual,(cnt+ 4))
   ENDIF
   reply->qual[cnt].specimen_cd = protocol->spec[d.seq].specimen_cd
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
