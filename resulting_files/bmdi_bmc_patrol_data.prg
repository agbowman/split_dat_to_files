CREATE PROGRAM bmdi_bmc_patrol_data
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD devicelist(
   1 qual[*]
     2 device_cd = f8
     2 create_dt_tm = dq8
 )
 DECLARE count = i2
 DECLARE index = i2
 DECLARE dummyindex = i2
 DECLARE devcd = f8
 DECLARE mindiff = f8
 DECLARE datetime = vc
 DECLARE devname = vc
 SET count = 0
 SET index = 0
 SET dummyindex = 0
 SET devcd = 0.0
 SET mindiff = 0.0
 SET datetime = ""
 SET devname = ""
 SELECT DISTINCT INTO "nl:"
  bmd.device_cd
  FROM bmdi_monitored_device bmd
  WHERE bmd.device_cd > 0
  DETAIL
   count = (count+ 1), stat = alterlist(devicelist->qual,count), devicelist->qual[count].device_cd =
   bmd.device_cd
  WITH nocounter
 ;end select
 FOR (index = 1 TO count)
   SELECT INTO "nl:"
    cqm.create_dt_tm
    FROM cqm_bmdi_results_que cqm
    WHERE cqm.class=cnvtstring(devicelist->qual[index].device_cd)
     AND cqm.queue_id > 0
    ORDER BY cqm.create_dt_tm DESC
    DETAIL
     devicelist->qual[index].create_dt_tm = cqm.create_dt_tm
    WITH maxqual(cqm,1)
   ;end select
 ENDFOR
 SET count = 0
 SET index = 0
 SELECT INTO bmdimonitoreddata
  FROM (dummyt d1  WITH seq = value(dummyindex))
  DETAIL
   count = size(devicelist,5)
   FOR (index = 1 TO count)
     devname = uar_get_code_display(devicelist->qual[index].device_cd), datetime = format(devicelist
      ->qual[index].create_dt_tm,";;Q"), mindiff = datetimediff(cnvtdatetime(curdate,curtime3),
      devicelist->qual[index].create_dt_tm,4),
     col 0, devicelist->qual[index].device_cd, col 25,
     ",", col 26, devname,
     col 50, ",", col 51,
     datetime, col 74, ",",
     col 75, mindiff
   ENDFOR
  WITH format = pcformat, noheading
 ;end select
 SET reply->status_data.status = "S"
END GO
