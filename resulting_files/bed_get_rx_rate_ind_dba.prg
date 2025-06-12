CREATE PROGRAM bed_get_rx_rate_ind:dba
 FREE SET reply
 RECORD reply(
   1 rate_found_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->rate_found_ind = 0
 RANGE OF m IS med_oe_defaults
 SET reply->rate_found_ind = validate(m.rate_nbr)
 FREE RANGE m
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
