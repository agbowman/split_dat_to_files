CREATE PROGRAM bed_get_sch_slottype:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 slot_type_id = f8
     2 mnemonic = vc
     2 def_duration = i4
     2 contiguous_ind = i2
     2 slot_color = i4
     2 interval = i4
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = 0
 SELECT INTO "nl:"
  FROM sch_slot_type sst,
   sch_disp_scheme sds
  PLAN (sst
   WHERE sst.slot_type_id > 0)
   JOIN (sds
   WHERE sds.disp_scheme_id=outerjoin(sst.disp_scheme_id))
  ORDER BY sst.mnemonic_key
  HEAD REPORT
   scnt = 0
  DETAIL
   scnt = (scnt+ 1), stat = alterlist(reply->slist,scnt), reply->slist[scnt].slot_type_id = sst
   .slot_type_id,
   reply->slist[scnt].mnemonic = sst.mnemonic, reply->slist[scnt].def_duration = sst.def_duration,
   reply->slist[scnt].contiguous_ind = sst.contiguous_ind,
   reply->slist[scnt].slot_color = sds.back_color, reply->slist[scnt].interval = sst.interval
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
