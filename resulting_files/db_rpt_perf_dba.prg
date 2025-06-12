CREATE PROGRAM db_rpt_perf:dba
 PAINT
#start
 SET rs = 0
 SET dblink = fillstring(30," ")
 CALL video(r)
 CALL clear(1,1)
 CALL box(2,20,22,60)
 CALL video(n)
 CALL line(6,21,39)
 CALL text(4,30,"PERFORMANCE MONITORING")
 CALL text(8,25,"1.Generate new report")
 CALL text(10,30,"B. Begin Monitoring")
 CALL text(12,30,"E. End Monitoring")
 CALL text(15,25,"2. Print old report")
 CALL text(17,30,"R. Run Report")
 CALL text(19,25,"3. QUIT")
 CALL text(21,25,"Enter Your choice(B,E,R,Q) : ")
 CALL accept(21,55,"A;cu","Q"
  WHERE curaccept IN ("B", "E", "R", "Q"))
 SET ch = curaccept
 CASE (ch)
  OF "B":
   EXECUTE db_perf_begin_menu
   GO TO start
  OF "E":
   CALL clear(1,1)
   CALL video(r)
   CALL box(10,5,20,70)
   CALL video(n)
   CALL text(13,15,"Enter Report sequence :")
   CALL text(23,1,"Help available on <HLP> key. Press F3 to exit.")
   SET help =
   SELECT
    l.report_seq";l", l.begin_date, r.instance_name
    FROM ref_instance_id r,
     ref_report_log l,
     ref_report_parms_log p
    WHERE p.report_seq=l.report_seq
     AND p.parm_value=cnvtstring(r.instance_cd)
     AND p.parm_cd=1
     AND l.end_date=null
     AND l.report_cd=3
    WITH nocounter
   ;end select
   SET validate =
   SELECT INTO "nl:"
    l.report_seq
    FROM ref_report_log l
    WHERE l.end_date=null
     AND l.report_seq=curaccept
     AND l.report_cd=3
    WITH nocounter
   ;end select
   SET validate = 1
   CALL accept(13,45,"9(6)")
   SET rs = cnvtint(curaccept)
   CALL clear(23,1)
   SET help = off
   SET validate = off
   SET i_code = 0.0
   SELECT INTO "nl:"
    FROM ref_report_log l,
     ref_report_parms_log p,
     ref_instance_id r
    WHERE p.report_seq=l.report_seq
     AND l.report_seq=rs
     AND p.parm_value=cnvtstring(r.instance_cd)
     AND p.parm_cd=1
     AND l.report_cd=3
    DETAIL
     i_code = r.instance_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM ref_instance_id s
    WHERE s.instance_cd=cnvtint(i_code)
    DETAIL
     dblink = s.node_address
    WITH nocounter
   ;end select
   CALL text(23,1,"Processing... Wait.")
   EXECUTE db_perf_end "dblink", rs
   GO TO start
  OF "R":
   CALL clear(1,1)
   CALL video(r)
   CALL box(10,5,20,70)
   CALL video(n)
   CALL text(13,15,"Enter Report sequence :")
   CALL text(23,1,"Help available on <HLP> key. Press F3 to exit.")
   SET help =
   SELECT
    l.report_seq";l", l.begin_date, r.instance_name
    FROM ref_instance_id r,
     ref_report_log l,
     ref_report_parms_log p
    WHERE p.report_seq=l.report_seq
     AND p.parm_value=cnvtstring(r.instance_cd)
     AND p.parm_cd=1
     AND l.report_cd=3
    ORDER BY l.report_seq DESC
    WITH nocounter
   ;end select
   SET validate =
   SELECT INTO "nl:"
    l.report_seq
    FROM ref_report_log l
    WHERE l.report_cd=3
     AND l.report_seq=curaccept
    WITH nocounter
   ;end select
   SET validate = 1
   CALL accept(13,45,"9(6)")
   SET rs = cnvtint(curaccept)
   SET help = off
   SET validate = off
   CALL clear(23,1)
   EXECUTE db_perf_generate_rpt rs
   GO TO start
  OF "Q":
   GO TO terminate
 ENDCASE
#terminate
END GO
