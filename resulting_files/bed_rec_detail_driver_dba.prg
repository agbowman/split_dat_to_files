CREATE PROGRAM bed_rec_detail_driver:dba
 FREE SET reply
 RECORD reply(
   1 collist[*]
     2 header_text = vc
     2 data_type = i2
     2 hide_ind = i2
   1 rowlist[*]
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
   1 high_volume_flag = i2
   1 output_filename = vc
   1 run_status_flag = i2
   1 statlist[*]
     2 statistic_meaning = vc
     2 status_flag = i2
     2 qualifying_items = i4
     2 total_items = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
   1 res_collist[*]
     2 header_text = vc
   1 res_rowlist[*]
     2 res_celllist[*]
       3 cell_text = vc
 )
 DECLARE program_name = vc
 SET reply->status_data.status = "F"
 IF (trim(request->program_name) > " ")
  SET program_name = cnvtupper(trim(request->program_name))
  EXECUTE value(program_name)
 ENDIF
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 IF ((((reply->run_status_flag < 0)) OR ((reply->run_status_flag > 3))) )
  SET reply->run_status_flag = 0
 ENDIF
 SET reply->status_data.status = "S"
END GO
