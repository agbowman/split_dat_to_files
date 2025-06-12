CREATE PROGRAM cclserver:dba
 PAINT
 SET stat = 0
 SET more = "R"
 DECLARE buffer = c100
 SET output_name = cnvtlower(build("cclout",format(curtime3,"hhmmsscc;3;m"),".log"))
 WHILE (more="R")
   CALL clear(1,1)
   CALL box(1,1,7,80)
   CALL line(3,1,80,xhor)
   CALL text(2,5,concat("CCL Server HNAM Server Monitor for ",cursys))
   CALL text(4,5,"Server Name")
   CASE (cursys)
    OF "AXP":
     CALL text(5,5,"Example:       srv1075")
     CALL text(10,1,curuser)
     CALL dcl("show proc/quota",30,stat)
     CALL accept(4,20,"p(40);c","srv")
    OF "AIX":
     CALL text(5,5,"Example:       cpm_srvscript")
     CALL text(10,1,curuser)
     CALL dcl("ulimit -a",30,stat)
     CALL accept(4,20,"p(40);c","srv")
   ENDCASE
   SET server = curaccept
   SET more = "Y"
   WHILE (more="Y")
     CALL clear(8,1)
     CASE (cursys)
      OF "AXP":
       SET buffer = concat("show sys/out=",output_name,"/proc=",trim(cnvtupper(server)),"*")
       CALL dcl(buffer,size(trim(buffer)),stat)
       CALL cclserver_report(
        "  Pid    Process Name    State  Pri      I/O       CPU       Page flts  Pages")
       SET buffer = concat("delete/nolog ",output_name,";*")
       CALL dcl(buffer,size(trim(buffer)),stat)
      OF "AIX":
       SET buffer = concat('ps -elo "%U %p %P %C   %n   %z %t %x %a" |grep ',trim(server),
        ">> ",output_name)
       CALL dcl(buffer,size(trim(buffer)),stat)
       CALL cclserver_report(
        "  UID     PID    PPID  %CPU  NICE  VSIZE   ELAPSED     CPU       COMMAND ")
       SET buffer = concat("rm ",output_name)
       CALL dcl(buffer,size(trim(buffer)),stat)
     ENDCASE
     CALL clear(24,1)
     CALL text(24,1,"Repeat(Yes/No/Restart)")
     CALL accept(24,25,"P;cu","Y")
     SET more = curaccept
   ENDWHILE
 ENDWHILE
 SUBROUTINE cclserver_report(p_head)
   DEFINE rtl2 trim(output_name)
   SELECT INTO mine
    rline = substring(1,150,r.line)
    FROM rtl2t r
    WHERE cnvtupper(r.line)=patstring(concat("*",trim(cnvtupper(server)),"*"))
     AND r.line != "*grep *"
    HEAD REPORT
     line = fillstring(130,"="), p_head, row + 1,
     line, row + 1
    DETAIL
     IF (cursys="AIX")
      CALL print(substring(1,65,rline)), col + 1, pos = findstring(trim(cnvtupper(server)),cnvtupper(
        rline))
      IF (pos > 0)
       CALL print(substring(pos,50,rline))
      ENDIF
     ELSE
      rline
     ENDIF
     row + 1
    FOOT REPORT
     ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>",
     row + 1
     CASE (cursys)
      OF "AIX":
       "UID:      The user id.",row + 1,"PID:      The process ID of the process.",
       row + 1,"PPID:     The parent process ID.",row + 1,
       "%CPU:     Percent CPU utilization of process or thread.",row + 1,
       "NI:       The nice value 1 to 100; calculating priority for the sched other policy.",
       row + 1,"ELAPSED   The total elapsed time for the process.",row + 1,
       "CPU:      Total CPU utilization of process or thread.",row + 1,
       "COMMAND:  Contains the command name.",
       row + 1
      OF "AXP":
       "PID:      The process id",row + 1,"PROCESS:  The process name",
       row + 1,"STATE:    The state of the process",row + 1,
       "PRI:      The priority of the process(1-32 with 1 being the lowest priority)",row + 1,
       "I/O:      Number of direct disk read/writes made",
       row + 1,"CPU:      The cpu utilization",row + 1,
       "PAGE FLTS The number of page faults made: ",row + 1,
       "PAGES:    Size in blocks for virtual pages",
       row + 1
     ENDCASE
    WITH nocounter, maxrow = 1, maxcol = 151,
     noformfeed
   ;end select
   FREE DEFINE rtl2
 END ;Subroutine
END GO
