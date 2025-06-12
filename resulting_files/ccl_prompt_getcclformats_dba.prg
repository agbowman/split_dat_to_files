CREATE PROGRAM ccl_prompt_getcclformats:dba
 DECLARE addformat(i=i2,display=vc,format=vc) = null WITH public
 RECORD request(
   1 action = i2
 )
 RECORD reply(
   1 count = i4
   1 formats[*]
     2 name = vc
     2 format = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET stat = alterlist(reply->formats,19)
 CALL addformat(1,"@SHORTDATE",cclfmt->shortdate)
 CALL addformat(2,"@MEDIUMDATE",cclfmt->mediumdate)
 CALL addformat(3,"@LONGDATE",cclfmt->longdate)
 CALL addformat(4,"@SHORTDATETIME",cclfmt->shortdatetime)
 CALL addformat(5,"@MEDIUMDATETIME",cclfmt->mediumdatetime)
 CALL addformat(6,"@LONGDATETIME",cclfmt->longdatetime)
 CALL addformat(7,"@TIMEWITHSECONDS",cclfmt->timewithseconds)
 CALL addformat(8,"@TIMENOSECONDS",cclfmt->timenoseconds)
 CALL addformat(9,"@WEEKDAYNUMBER",cclfmt->weekdaynumber)
 CALL addformat(10,"@WEEKDAYABBREV",cclfmt->weekdayabbrev)
 CALL addformat(11,"@WEEKDAYNAME",cclfmt->weekdayname)
 CALL addformat(12,"@MONTHNUMBER",cclfmt->monthnumber)
 CALL addformat(13,"@MONTHABBREV",cclfmt->monthabbrev)
 CALL addformat(14,"@MONTHNAME",cclfmt->monthname)
 CALL addformat(15,"@SHORTDATE4YR",cclfmt->shortdate4yr)
 CALL addformat(16,"@MEDIUMDATE4YR",cclfmt->mediumdate4yr)
 CALL addformat(17,"@SHORTDATETIMENOSEC",cclfmt->shortdatetimenosec)
 CALL addformat(18,"@DATETIMECONDENSED",cclfmt->datetimecondensed)
 CALL addformat(19,"@DATECONDENSED",cclfmt->datecondensed)
 SET reply->count = 19
 RETURN
 SUBROUTINE addformat(i,display,format)
  SET reply->formats[i].name = display
  SET reply->formats[i].format = format
 END ;Subroutine
END GO
