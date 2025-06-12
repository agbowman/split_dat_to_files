CREATE PROGRAM aps_get_omf_flags:dba
 IF (validate(reply->omf_transcription_activity_ind,null)=null)
  RECORD reply(
    1 omf_info_qual[*]
      2 dm_info_name = vc
      2 dm_info_date = dq8
      2 dm_info_char = vc
      2 dm_info_number = f8
      2 dm_info_long_id = f8
      2 updt_cnt = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
#script
 SET reply->status_data.status = "F"
 SET omf_info_cnt = 0
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="ANATOMIC PATHOLOGY"
  HEAD REPORT
   omf_info_cnt = 0
  DETAIL
   omf_info_cnt = (omf_info_cnt+ 1)
   IF (mod(omf_info_cnt,10)=1)
    stat = alterlist(reply->omf_info_qual,(omf_info_cnt+ 9))
   ENDIF
   reply->omf_info_qual[omf_info_cnt].dm_info_name = di.info_name, reply->omf_info_qual[omf_info_cnt]
   .dm_info_date = di.info_date, reply->omf_info_qual[omf_info_cnt].dm_info_char = di.info_char,
   reply->omf_info_qual[omf_info_cnt].dm_info_number = di.info_number, reply->omf_info_qual[
   omf_info_cnt].dm_info_long_id = di.info_long_id, reply->omf_info_qual[omf_info_cnt].updt_cnt = di
   .updt_cnt
  FOOT REPORT
   stat = alterlist(reply->omf_info_qual,omf_info_cnt)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
