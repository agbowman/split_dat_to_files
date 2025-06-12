CREATE PROGRAM ams_qual_ctrl
 DEFINE rtl2 "ccluserdir:utility.csv"
 DECLARE rcnt = i4
 DECLARE row_count = i4
 FREE RECORD orig_content
 RECORD orig_content(
   1 qual[*]
     2 control_name = vc
     2 long_desc = vc
     2 manufacture = vc
     2 control_type = vc
     2 lot = vc
     2 rec_date_time = vc
     2 exp_date_time = vc
 )
 FREE RECORD request
 RECORD request(
   1 description = vc
   1 short_description = c20
   1 manufacturer_cd = f8
   1 control_type_cd = f8
   1 blind_sample_ind = i2
 )
 SELECT
  r.line
  FROM rtl2t r
  HEAD REPORT
   row_count = 0, i = 0, count = 0,
   stat = alterlist(orig_content->qual,10)
  HEAD r.line
   line1 = r.line,
   CALL echo(line1)
   IF (size(trim(line1),1) > 0)
    count = (count+ 1)
    IF (count > 1)
     row_count = (row_count+ 1)
     IF (mod(row_count,10)=1
      AND row_count > 10)
      stat = alterlist(orig_content->qual,(row_count+ 9))
     ENDIF
     orig_content->qual[row_count].control_name = piece(line1,",",1,"Not Found"), orig_content->qual[
     row_count].long_desc = piece(line1,",",2,"Not Found"), orig_content->qual[row_count].manufacture
      = piece(line1,",",3,"Not Found"),
     orig_content->qual[row_count].control_type = piece(line1,",",4,"Not Found"), orig_content->qual[
     row_count].lot = piece(line1,",",5,"Not Found"), orig_content->qual[row_count].rec_date_time =
     piece(line1,",",6,"Not Found"),
     orig_content->qual[row_count].exp_date_time = piece(line1,",",7,"Not Found")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(orig_content->qual,row_count)
  WITH nocounter, format, separator = ""
 ;end select
 CALL echorecord(orig_content)
 SET rcnt = 0
 FOR (i = 1 TO value(size(orig_content->qual,5)))
   SET request->short_description = orig_content->qual[i].control_name
   SET request->description = orig_content->qual[i].long_desc
   SELECT
    cv.display, cv.code_value
    FROM code_value cv
    WHERE cv.code_set=1908
     AND trim(cv.display)=trim(orig_content->qual[i].manufacture)
    HEAD cv.code_value
     request->manufacturer_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT
    cv.display, cv.code_value
    FROM code_value cv
    WHERE cv.code_set=1907
     AND trim(cv.display)=trim(orig_content->qual[i].control_type)
    HEAD cv.code_value
     request->control_type_cd = cv.code_value
    WITH nocounter
   ;end select
   SET request->blind_sample_ind = 0
 ENDFOR
 RECORD reply(
   1 control_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 CALL echorecord(request)
 EXECUTE glb_add_control:dba  WITH replace("REQUEST",request), replace("REPLY",reply)
 CALL echorecord(reply)
 FREE RECORD request
 RECORD request(
   1 control_id = f8
   1 lot_id = f8
   1 short_description = c20
   1 lot_number = vc
   1 receive_dt_tm = dq8
   1 expiration_dt_tm = dq8
   1 lot_flag = i2
 )
 SET rcnt = 0
 FOR (i = 1 TO value(size(orig_content->qual,5)))
   SET request->control_id = reply->control_id
   SET request->lot_id = (reply->control_id+ 6)
   SET request->short_description = ""
   SET request->lot_number = orig_content->qual[i].lot
   SET request->receive_dt_tm = cnvtdatetime(orig_content->qual[i].rec_date_time)
   SET request->expiration_dt_tm = cnvtdatetime(orig_content->qual[i].exp_date_time)
   SET request->lot_flag = 2
 ENDFOR
 CALL echorecord(request)
 SET last_mod = "000 04/15/2016 AN035214  Initial Release"
END GO
