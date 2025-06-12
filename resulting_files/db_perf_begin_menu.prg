CREATE PROGRAM db_perf_begin_menu
 PAINT
 SET rs = 0
 SET dblink = fillstring(100," ")
 SET i_code = 0
 CALL video(r)
 CALL clear(1,1)
 CALL box(2,3,22,77)
 CALL video(n)
 CALL text(7,15,"Begin Date  :")
 CALL text(5,15,"Instance_Cd :")
 CALL text(7,45,"Begin Time :")
 CALL text(9,15,"End Date :")
 CALL text(9,45,"End Time :")
 CALL text(11,15,"Request User :")
 CALL text(13,15,"User Notes")
 CALL text(23,1,"Help available on <HLP> key. Press F3 to exit.")
 SET help =
 SELECT
  r.instance_cd";l", r.instance_name
  FROM ref_instance_id r
 ;end select
 SET validate =
 SELECT INTO "nl:"
  r.instance_cd
  FROM ref_instance_id r
  WHERE r.instance_cd=curaccept
 ;end select
 SET validate = 1
 CALL accept(5,30,"##.##")
 SET i_code = curaccept
 CALL clear(23,1)
 SELECT INTO "nl:"
  FROM ref_instance_id s
  WHERE s.instance_cd=i_code
  DETAIL
   dblink = s.node_address
  WITH nocounter
 ;end select
 SET help = off
 SET validate = off
 SET bdate = curdate
 CALL accept(7,30,"nndpppdnnnn;c",format(bdate,"dd-mmm-yyyy;;d"))
 SET bdate = cnvtdate2(curaccept,"dd-mmm-yyyy")
 SET btime = curtime
 CALL accept(7,60,"nndnn;c",format(btime,"hh:mm;;m")
  WHERE format(cnvtint(cnvtalphanum(curaccept)),"hh:mm;;m")=curaccept)
 SET btime = cnvtint(cnvtalphanum(curaccept))
 SET edate = 0
 CALL accept(9,30,"nndpppdnnnn;ch",format(edate,"dd-mmm-yyyy;3;d"))
 SET edate = cnvtdate2(curaccept,"dd-mmm-yyyy")
 SET etime = 0
 CALL accept(9,60,"nndnn;ch",format(etime,"hh:mm;;m"))
 SET etime = cnvtint(cnvtalphanum(curaccept))
 SET ruser = fillstring(30," ")
 CALL accept(11,30,"p(30);c",curuser)
 SET ruser = curaccept
 SET unotes = fillstring(250," ")
 SET un1 = fillstring(50," ")
 SET un2 = fillstring(50," ")
 SET un3 = fillstring(50," ")
 SET un4 = fillstring(50," ")
 SET un5 = fillstring(50," ")
 CALL accept(13,30,"p(40);c"," ")
 SET un1 = curaccept
 IF (size(curaccept)=1)
  GO TO un
 ENDIF
 CALL accept(14,30,"p(40);c"," ")
 SET un2 = curaccept
 IF (size(curaccept)=1)
  GO TO un
 ENDIF
 CALL accept(15,30,"p(40);c"," ")
 SET un3 = curaccept
 IF (size(curaccept)=1)
  GO TO un
 ENDIF
 CALL accept(16,30,"p(40);c"," ")
 SET un4 = curaccept
 IF (size(curaccept)=1)
  GO TO un
 ENDIF
 CALL accept(17,30,"p(40);c"," ")
 SET un5 = curaccept
 IF (size(curaccept)=1)
  GO TO un
 ENDIF
#un
 SET unotes = concat(trim(un1),trim(un2),trim(un3),trim(un4),trim(un5))
 CALL text(23,1,"Your Monitoring started. Wait for your report sequence number.")
 EXECUTE db_perf_begin "dblink"
 CALL clear(23,1)
 CALL text(23,1,"Your Report Sequence is :")
 CALL text(23,25,cnvtstring(rs))
 CALL accept(23,30,"p;c"," ")
 CALL text(22,1,"bdt = ",cnvtdatetime(bdate,btime))
 INSERT  FROM ref_report_log
  SET report_cd = 3, report_seq = rs, begin_date = cnvtdatetime(bdate,btime),
   request_user = trim(ruser), user_notes = trim(unotes), end_date =
   IF (etime=0) null
   ELSE cnvtdatetime(edate,etime)
   ENDIF
  WITH nocounter
 ;end insert
 INSERT  FROM ref_report_parms_log p
  SET p.report_seq = rs, p.parm_cd = 1, p.value_seq = 1,
   p.parm_value = cnvtstring(i_code)
  WITH nocounter
 ;end insert
 COMMIT
#terminate
 EXECUTE db_rpt_perf
END GO
