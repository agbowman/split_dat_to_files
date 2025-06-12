CREATE PROGRAM dba_alertmon:dba
 SET message = noinformation
 SET message = window
 SET message = 0
 RECORD dir_rec(
   1 qual[*]
     2 new_path = vc
 )
 SET mon_type = "S"
 SET stat = alterlist(dir_rec->qual,1)
 SET dir_rec->qual[1].new_path = logical("ora_dump")
 SET acc_flag = 0
 SET wait_sec = 0
 IF (((cursys="AXP") OR (cursys="VMS")) )
  SET com = fillstring(250," ")
  SET com = "delete ccluserdir:dba_alertmon_command.ccl;"
  CALL dcl(trim(com),size(trim(com)),0)
 ENDIF
 IF (cursys="AIX")
  SET com = fillstring(250," ")
  SET com = "rm /tmp/dba_alertmon_command.ccl"
  CALL dcl(trim(com),size(trim(com)),0)
 ENDIF
 IF (( $1 != ""))
  SET group_name =  $1
  SET mon_type =  $2
  SET wait_sec =  $3
  SET back_ground = "TRUE"
  GO TO monitor_start
 ENDIF
 SET back_ground = "FALSE"
#menu1
 CALL video(r)
 CALL clear(1,1)
 CALL box(3,5,20,75)
 CALL box(3,5,5,75)
 CALL text(4,5,"   ****            A L E R T L O G     M O N I T O R        ****     ")
 CALL video(n)
 CALL text(8,9,"1. Modify Alertlog Group Info.")
 CALL text(10,9,"2. Modify Service Level Agreement Info (SLA) ")
 CALL text(12,9,"3. Modify Search String Info")
 CALL text(14,9,"4. Assign SLA to Alertlog Groups")
 CALL text(16,9,"5. Monitor Alertlog Group")
 CALL text(18,9,"Your Selection(0 to exit)")
 CALL accept(18,35,"p"
  WHERE curaccept IN (1, 2, 3, 4, 5,
  0))
 SET option = curaccept
 CASE (option)
  OF 1:
   GO TO lbl_grp
  OF 2:
   GO TO lbl_ser
  OF 3:
   GO TO lbl_err
  OF 4:
   GO TO lbl_grpser
  OF 5:
   GO TO lbl_mon
  OF 0:
   GO TO lbl_exit
 ENDCASE
#lbl_ser
 EXECUTE setup_services
 GO TO menu1
#lbl_grpser
 EXECUTE group_service
 GO TO menu1
#lbl_err
 EXECUTE setup_errors
 GO TO menu1
#lbl_grp
 EXECUTE setup_groups
 GO TO menu1
#lbl_mon
 CALL video(r)
 CALL clear(1,1)
 CALL box(5,5,18,75)
 CALL box(5,5,7,75)
 CALL text(6,5,"             ****            M O N I T O R I N G          ****        ")
 CALL video(n)
 CALL text(10,7,"Enter Group :")
 CALL text(13,7,"Start/Restart (S/R)")
 CALL text(15,7,"Check Alertlog for every ")
 CALL text(15,37,"Seconds")
 IF (acc_flag=1)
  GO TO acc_montype
 ENDIF
#acc_dir
 SET help =
 SELECT
  group_name = substring(1,30,g.group_name)";l"
  FROM dba_alertmon_groups g
 ;end select
 SET validate =
 SELECT INTO "nl:"
  g.group_name
  FROM dba_alertmon_groups g
  WHERE cnvtupper(trim(g.group_name))=cnvtupper(trim(curaccept))
 ;end select
 SET validate = 1
 CALL accept(11,7,"p(30);cu")
 SET group_name = curaccept
 SET help = off
 SET validate = off
 SET mgid = 0
 SELECT INTO "nl:"
  g.*
  FROM dba_alertmon_groups g
  WHERE cnvtupper(g.group_name)=cnvtupper(group_name)
  DETAIL
   mgid = g.group_no
  WITH nocounter
 ;end select
 SET num = 0
 SELECT INTO "nl:"
  g.*
  FROM dba_alertmon_paths gd,
   dba_alertmon_groups g
  WHERE gd.group_no=g.group_no
   AND g.group_no=mgid
  HEAD REPORT
   num = 0
  DETAIL
   num = (num+ 1), stat = alterlist(dir_rec->qual,num), dir_rec->qual[num].new_path = gd.path
  WITH nocounter
 ;end select
 CALL clear(1,1)
 SET help =
 SELECT INTO "nl:"
  gd.path
  FROM dba_alertmon_paths gd
  WHERE gd.group_no=mgid
  WITH nocounter
 ;end select
 CALL text(20,5,"Want to continue ? (Y/N)")
 CALL accept(20,30,"p;cuf")
 CALL accept(20,30,"p;cu"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  GO TO lbl_exit
 ENDIF
 SET acc_flag = 1
 GO TO lbl_mon
#acc_montype
 CALL text(10,20,group_name)
 CALL accept(13,30,"p;cu",mon_type
  WHERE curaccept IN ("S", "R"))
 SET mon_type = curaccept
 SET wait_sec = 0
 CALL accept(15,32,"999;c",wait_sec)
 SET wait_sec = cnvtint(wait_sec)
 SET message = nowindow
#monitor_start
 IF (back_ground="TRUE")
  SET mgid = 0
  SELECT INTO "nl:"
   g.*
   FROM dba_alertmon_groups g
   WHERE cnvtupper(g.group_name)=cnvtupper(group_name)
   DETAIL
    mgid = g.group_no
   WITH nocounter
  ;end select
  SET num = 0
  SELECT INTO "nl:"
   g.*
   FROM dba_alertmon_paths gd,
    dba_alertmon_groups g
   WHERE gd.group_no=g.group_no
    AND g.group_no=mgid
   HEAD REPORT
    num = 0
   DETAIL
    num = (num+ 1), stat = alterlist(dir_rec->qual,num), dir_rec->qual[num].new_path = gd.path,
    col 0, gd.path, row + 1
   WITH nocounter
  ;end select
 ENDIF
 EXECUTE watchalert
#lbl_exit
END GO
