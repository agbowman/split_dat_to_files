CREATE PROGRAM cr_chg_out_dest:dba
 PAINT
 SET width = 132
 SET modify = system
#initialize
 RECORD chart_req(
   1 qual[*]
     2 cr_id = f8
 )
 DECLARE cr_id = f8 WITH noconstant(0.0)
 DECLARE dist_id = f8 WITH noconstant(0.0)
 SET blank_line = fillstring(132," ")
 SET pswdid = 0.0
 SELECT INTO "nl:"
  p.username, p.person_id
  FROM prsnl p
  WHERE p.username=curuser
  DETAIL
   pswdid = p.person_id
  WITH maxqual(p,1)
 ;end select
 CALL text(24,1,blank_line)
#start_initial_accepts
 CALL clear(1,1)
 CALL box(2,1,23,79)
 CALL text(1,25,"Change Output Destination Utility")
 CALL text(4,4,"1  Change Individual Chart Request ID Output Destination")
 CALL text(6,4,"2  Change Whole Distribution Output Destination")
 CALL text(8,4,"3  Exit")
 CALL text(24,1,"Select Option ? ")
 CALL accept(24,17,"9;",3
  WHERE curaccept IN (1, 2, 3))
 CALL clear(24,1)
 SET choice = curaccept
 EXECUTE FROM start_clear_screen TO end_clear_screen
 CASE (choice)
  OF 1:
   EXECUTE FROM start_chart_chg TO end_chart_chg
  OF 2:
   EXECUTE FROM start_dist_chg TO end_dist_chg
  OF 3:
   GO TO end_override
 ENDCASE
 GO TO start_initial_accepts
#end_initial_accepts
#start_chart_chg
 SET output_cd = 0.0
 SET device_cd = 0.0
 SET cr_id = 0.0
 SET chart_id = 0.0
 SET od_name = fillstring(16," ")
 SET req_type = 0
 SET cur_dest = 0.0
 SET cur_name = fillstring(16," ")
 CALL text(1,20,"Change Chart Request ID Output Destination")
 CALL box(2,1,23,79)
 EXECUTE FROM start_clear_screen TO end_clear_screen
 CALL text(5,4,"Enter a chart_request_id or choose help.")
 CALL text(6,4,"(Caution: help may take a long time to load).")
 CALL text(7,4,"ID: ")
 SET help =
 SELECT INTO "nl:"
  cr.chart_request_id
  FROM chart_request cr
  WHERE cr.chart_request_id > 0
  WITH nocounter
 ;end select
 CALL accept(7,9,"P(16);C")
 SET help = off
 SET cr_id = cnvtreal(curaccept)
 SELECT INTO "nl:"
  cr.chart_request_id, cr.request_type, cr.output_dest_cd
  FROM chart_request cr
  WHERE cr.chart_request_id=cr_id
  DETAIL
   chart_id = cr.chart_request_id, req_type = cr.request_type, cur_dest = cr.output_dest_cd
  WITH nocounter
 ;end select
 CALL text(24,1,blank_line)
 IF (chart_id=0)
  CALL text(24,4,"Chart Request ID must be a valid value.")
  GO TO start_chart_chg
 ENDIF
 SELECT INTO "nl:"
  od.name
  FROM output_dest od
  WHERE od.output_dest_cd=cur_dest
  DETAIL
   cur_name = od.name
  WITH nocounter
 ;end select
 CALL text(8,4,"Current Destination: ")
 CALL text(8,31,cur_name)
 CALL text(9,4,"Current Output Dest Code: ")
 CALL text(9,31,cnvtstring(cur_dest))
 CALL text(11,4,"Choose an Output Destination to override the current destination.")
 CALL text(12,4,"New Destination: ")
 SET help =
 SELECT INTO "nl:"
  od.name
  FROM output_dest od
  WITH nocounter
 ;end select
 CALL text(24,1,blank_line)
 SET validate = 0
 SET validate =
 SELECT INTO "nl:"
  FROM output_dest od
  WHERE od.name=trim(curaccept)
  WITH nocounter
 ;end select
 CALL text(24,1,blank_line)
 CALL accept(12,27,"P(20);Cf"," ")
 SET validate = off
 SET help = off
 SET od_name = curaccept
 SELECT INTO "nl:"
  od.output_dest_cd
  FROM output_dest od
  PLAN (od
   WHERE od.name=od_name)
  DETAIL
   output_cd = od.output_dest_cd, device_cd = od.output_device_cd
  WITH nocounter
 ;end select
 CALL text(24,1,blank_line)
 CALL text(13,4,"New Output Dest Code: ")
 CALL text(13,27,cnvtstring(output_cd))
 CALL text(14,4,"New Device Code: ")
 CALL text(14,27,cnvtstring(device_cd))
 IF (output_cd > 0)
  EXECUTE FROM start_correct TO end_correct
  IF (yes_no=1)
   EXECUTE FROM start_clear_screen TO end_clear_screen
   GO TO start_chart_chg
  ENDIF
 ELSE
  CALL text(24,1,blank_line)
  CALL text(24,4,"Output Destination Code must not be zero.")
  GO TO start_chart_chg
 ENDIF
 IF (req_type=4)
  UPDATE  FROM chart_request c
   SET c.output_dest_cd = output_cd, c.output_device_cd = device_cd, c.handle_id = 0,
    c.dist_terminator_ind = 1, c.status_flag = 0, c.resubmit_dt_tm = cnvtdatetime(curdate,curtime3),
    c.resubmit_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = pswdid,
    c.updt_task = 0, c.updt_applctx = 0, c.updt_cnt = (updt_cnt+ 1)
   WHERE c.chart_request_id=chart_id
   WITH nocounter
  ;end update
 ELSE
  UPDATE  FROM chart_request c
   SET c.output_dest_cd = output_cd, c.output_device_cd = device_cd, c.handle_id = 0,
    c.status_flag = 0, c.resubmit_dt_tm = cnvtdatetime(curdate,curtime3), c.resubmit_cnt = 0,
    c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = pswdid, c.updt_task = 0,
    c.updt_applctx = 0, c.updt_cnt = (updt_cnt+ 1)
   WHERE c.chart_request_id=chart_id
   WITH nocounter
  ;end update
 ENDIF
 EXECUTE FROM start_clear_screen TO end_clear_screen
 EXECUTE FROM start_commit TO end_commit
#end_chart_chg
#start_dist_chg
 SET output_cd = 0.0
 SET device_cd = 0.0
 SET dist_id = 0.0
 SET dist_descr = fillstring(30," ")
 SET cur_dest = 0.0
 SET od_name = fillstring(16," ")
 SET cur_name = fillstring(16," ")
 SET date_string = fillstring(50," ")
 SET time_string = fillstring(50," ")
 SET temp_date_string = fillstring(50," ")
 SET dist_date = cnvtdatetime(curdate,curtime3)
 SET dist_type_code = 0.0
 SET count = 0
 SET init_num = 0
 SET term_num = 0
 SET chart_id = 0.0
 SET choice = 0
 CALL text(1,20,"Change Distribution Output Destination")
 CALL box(2,1,23,79)
 EXECUTE FROM start_clear_screen TO end_clear_screen
 CALL text(5,4,"Enter a distribution id.")
 CALL text(6,4,"ID: ")
 SET help =
 SELECT INTO "nl:"
  cd.distribution_id";l", cd.dist_descr
  FROM chart_distribution cd
  WHERE cd.distribution_id > 0
   AND cd.active_ind=1
  WITH nocounter
 ;end select
 CALL accept(6,9,"P(16);Cf")
 CALL text(24,1,blank_line)
 SET dist_id = cnvtreal(curaccept)
 SELECT INTO "nl:"
  cd.dist_descr
  FROM chart_distribution cd
  WHERE cd.distribution_id=dist_id
  DETAIL
   dist_descr = substring(1,30,cd.dist_descr)
  WITH nocounter
 ;end select
 CALL text(6,32,dist_descr)
 SET help = off
 CALL text(7,4,"Enter a distribution date/time.")
 CALL text(8,4,"Date: ")
 CALL text(9,4,"Time: ")
 CALL accept(8,10,"nndpppdnnnn;cs",format(curdate,"dd-mmm-yyyy;;d"))
 SET date_string = curaccept
 CALL accept(9,10,"hh:mm;cs",format(cnvtdatetime(curdate,0),"hh:mm;;m"))
 SET time_string = curaccept
 SET temp_date_string = concat(trim(date_string)," ",trim(time_string))
 SET dist_date = cnvtdatetime(temp_date_string)
 CALL text(10,4,"Enter a distribution run type.")
 CALL text(11,4,"Run type: ")
 SET help =
 SELECT INTO "nl:"
  c.display
  FROM code_value c
  WHERE c.code_set=14119
   AND c.active_ind=1
  WITH nocounter
 ;end select
 SET validate = 0
 SET validate =
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=14119
   AND c.active_ind=1
   AND c.display=trim(curaccept)
  WITH nocounter
 ;end select
 CALL accept(11,14,"P(40);Cf"," ")
 SET validate = off
 SET help = off
 SET dist_type_name = curaccept
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=14119
   AND c.display=trim(dist_type_name)
  DETAIL
   dist_type_code = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cr.chart_request_id, cr.output_dest_cd
  FROM chart_request cr
  WHERE cr.distribution_id=dist_id
   AND cr.dist_run_type_cd=dist_type_code
   AND cr.dist_run_dt_tm=cnvtdatetime(dist_date)
  ORDER BY cr.chart_request_id
  DETAIL
   count = (count+ 1), stat = alterlist(chart_req->qual,count), chart_req->qual[count].cr_id = cr
   .chart_request_id,
   cur_dest = cr.output_dest_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  od.name
  FROM output_dest od
  WHERE od.output_dest_cd=cur_dest
  DETAIL
   cur_name = od.name
  WITH nocounter
 ;end select
 CALL text(13,4,"Current Destination: ")
 CALL text(13,31,cur_name)
 CALL text(14,4,"Current Output Dest Code: ")
 CALL text(14,31,cnvtstring(cur_dest))
 CALL text(15,4,"Chart Request ID count: ")
 CALL text(15,31,cnvtstring(count))
 IF (count=0)
  CALL text(24,1,blank_line)
  CALL text(24,4,"No chart request ids for selected distribution at selected time.")
  GO TO start_dist_chg
 ENDIF
 CALL text(17,4,"Choose an Output Destination to override the current destination.")
 CALL text(18,4,"New Destination: ")
 SET help =
 SELECT INTO "nl:"
  od.name
  FROM output_dest od
  WITH nocounter
 ;end select
 CALL text(24,1,blank_line)
 SET validate = 0
 SET validate =
 SELECT INTO "nl:"
  FROM output_dest od
  WHERE od.name=trim(curaccept)
  WITH nocounter
 ;end select
 CALL text(24,1,blank_line)
 CALL accept(18,27,"P(20);Cf"," ")
 SET validate = off
 SET help = off
 SET od_name = curaccept
 SELECT INTO "nl:"
  od.output_dest_cd
  FROM output_dest od
  PLAN (od
   WHERE od.name=od_name)
  DETAIL
   output_cd = od.output_dest_cd, device_cd = od.output_device_cd
  WITH nocounter
 ;end select
 CALL text(24,1,blank_line)
 CALL text(19,4,"New Output Dest Code: ")
 CALL text(19,27,cnvtstring(output_cd))
 CALL text(20,4,"New Device Code: ")
 CALL text(20,27,cnvtstring(device_cd))
 IF (output_cd > 0)
  EXECUTE FROM start_correct TO end_correct
  IF (yes_no=1)
   EXECUTE FROM start_clear_screen TO end_clear_screen
   GO TO start_dist_chg
  ENDIF
 ELSE
  CALL text(24,1,blank_line)
  CALL text(24,4,"Output Destination Code must not be zero.")
  GO TO start_dist_chg
 ENDIF
 FOR (idx = 1 TO count)
   IF (idx=1)
    SET init_num = 1
   ELSE
    SET init_num = 0
   ENDIF
   IF (idx=count)
    SET term_num = 1
   ELSE
    SET term_num = 0
   ENDIF
   UPDATE  FROM chart_request c
    SET c.output_dest_cd = output_cd, c.output_device_cd = device_cd, c.handle_id = 0,
     c.status_flag = 0, c.dist_initiator_ind = init_num, c.dist_terminator_ind = term_num,
     c.resubmit_dt_tm = cnvtdatetime(curdate,curtime3), c.resubmit_cnt = 0, c.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     c.updt_id = pswdid, c.updt_task = 0, c.updt_applctx = 0,
     c.updt_cnt = (updt_cnt+ 1)
    WHERE (c.chart_request_id=chart_req->qual[idx].cr_id)
    WITH nocounter
   ;end update
 ENDFOR
 EXECUTE FROM start_clear_screen TO end_clear_screen
 EXECUTE FROM start_commit TO end_commit
#end_dist_chg
#start_commit
 CALL text(7,4,"****  Commit/Rollback  ****")
 CALL text(9,4,"1 Commit   (Save changes to the database)")
 CALL text(10,4,"2 Rollback (Do not save changes to the database)")
 CALL text(11,4,"3 Quit     (Exit program -- changes are not saved but")
 CALL text(12,4,"            can be viewed in the current session)")
 CALL text(24,1,"Select Option ? ")
 CALL accept(24,17,"9;",3
  WHERE curaccept IN (1, 2, 3))
 CASE (curaccept)
  OF 1:
   COMMIT
  OF 2:
   ROLLBACK
  OF 3:
   GO TO end_override
 ENDCASE
 GO TO initialize
#end_commit
#start_correct
 CALL text(24,1,blank_line)
 CALL text(24,1,"Continue or Start over? (C/S): ")
 CALL accept(24,32,"p;cu","C"
  WHERE curaccept IN ("C", "S"))
 CALL text(24,1,fillstring(80," "))
 CASE (curaccept)
  OF "C":
   SET yes_no = 0
  OF "S":
   SET yes_no = 1
 ENDCASE
#end_correct
#start_clear_screen
 FOR (x = 3 TO 22)
   CALL clear(x,3,75)
 ENDFOR
#end_clear_screen
#end_override
 FOR (x = 1 TO 24)
   CALL clear(x,1,132)
 ENDFOR
END GO
