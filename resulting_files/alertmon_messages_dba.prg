CREATE PROGRAM alertmon_messages:dba
 SET i =  $1
 SET email_flag = 0
 SET amail_flag = 0
 SET last_page_flag = 0
 SET minutes = cnvtmin2(cnvtdate2(format(curdate,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(
    curtime,"hhmm;;m")))
 SELECT INTO "nl:"
  e.*
  FROM dba_alertmon_errors e
  WHERE (e.error_code=codes->qual[i].err_code)
   AND e.last_page_time != null
  DETAIL
   last_page_time = e.last_page_time, minutes = cnvtmin2(cnvtdate2(format(last_page_time,
      "mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(last_page_time,"hhmm;;m"))), last_page_flag = 1
  WITH nocounter
 ;end select
 FOR (ii = 1 TO nof_keys)
   IF (trim(cnvtupper(rec1->qual[x].trace_file))=trim(cnvtupper(service->qual[ii].path)))
    SET file_size = size(rec1->qual[x].trace_file)
    SET log_size = size(rec1->qual[x].new_line)
    SET full_log = rec1->qual[x].new_line
    IF (((cursys="AXP") OR (cursys="VMS")) )
     SET emsg_file = "ccluserdir:dba_alertmon_email_file.mail"
     SET amsg_file = "ccluserdir:dba_alertmon_amail_file.mail"
     SET log_file = substring((file_size+ 1),((log_size - file_size) - 12),full_log)
    ENDIF
    IF (cursys="AIX")
     SET emsg_file = "/tmp/alertmon_email_file.mail"
     SET amsg_file = "/tmp/alertmon_amail_file.mail"
     SET l_file = substring((file_size+ 8),((log_size - file_size) - 11),full_log)
     SET log_file = concat(trim(t_node),"_",trim(l_file))
    ENDIF
    FOR (jj = 1 TO service->qual[ii].nof_slas)
      SET time_s = service->qual[ii].qual[jj].st_time
      SET time_e = service->qual[ii].qual[jj].end_time
      SET time_c = cnvtint(format(curtime,"hhmm;;m"))
      SET time_diff = (cnvtmin2(curdate,curtime,1) - minutes)
      IF (last_page_flag=1
       AND (time_diff < service->qual[ii].qual[jj].interval))
       GO TO lbl_end
      ENDIF
      IF (time_c >= time_s
       AND time_c <= time_e)
       SET emsg_flag = 0
       SET amsg_flag = 0
       FOR (kk = 1 TO service->qual[ii].qual[jj].nof_types)
         SET maddr = fillstring(100," ")
         SET maddr = service->qual[ii].qual[jj].qual[kk].address
         SET mtype = service->qual[ii].qual[jj].qual[kk].type
         SET mcc_flag = service->qual[ii].qual[jj].qual[kk].cc_flag
         IF (cnvtupper(trim(mtype))="E"
          AND emsg_flag=0)
          SELECT
           IF (cursys="AIX")INTO "/tmp/alertmon_email_file.mail "
           ELSEIF (((cursys="AXP") OR (cursys="VMS")) )INTO "dba_alertmon_email_file.mail "
           ELSE
           ENDIF
           d.seq
           FROM (dummyt d  WITH seq = 1)
           HEAD REPORT
            IF ((codes->qual[i].email != null))
             custmess = fillstring(80," "), custmess = substring(1,80,codes->qual[i].email), position
              = 80
             WHILE (custmess != " ")
               col 0, custmess, row + 1,
               custmess = fillstring(80," "), custmess = substring((position+ 1),80,codes->qual[i].
                email), position = (position+ 80)
             ENDWHILE
            ELSE
             col 0, log_file, row + 1,
             col 0, codes->qual[i].err_code, row + 1,
             cust_mess1 = substring(1,125,mail->qual[xx].message), col 0, cust_mess1,
             row + 1, cust_mess2 = substring(126,125,mail->qual[xx].message), col 0,
             cust_mess2
            ENDIF
           WITH nocounter, maxcol = 132, noformfeed
          ;end select
          SET emsg_flag = 1
          SET email_flag = 1
         ENDIF
         IF (cnvtupper(trim(mtype))="A"
          AND amsg_flag=0)
          SELECT
           IF (cursys="AIX")INTO "/tmp/alertmon_amail_file.mail "
           ELSEIF (((cursys="AXP") OR (cursys="VMS")) )INTO "dba_alertmon_amail_file.mail "
           ELSE
           ENDIF
           d.seq
           FROM (dummyt d  WITH seq = 1)
           HEAD REPORT
            col 0, log_file, col 20,
            codes->qual[i].err_code, cust_mess1 = trim(substring(1,40,mail->qual[xx].message)), col
            40,
            cust_mess1, cust_mess2 = trim(substring(41,80,mail->qual[xx].message)), col + 0,
            cust_mess2
           WITH nocounter, noformfeed, maxcol = 200
          ;end select
          SET amsg_flag = 1
          SET amail_flag = 1
         ENDIF
         IF (((trim(cnvtupper(mtype))="E") OR (trim(cnvtupper(mtype))="A")) )
          IF (trim(cnvtupper(mtype))="E")
           SET msg_file = fillstring(100," ")
           SET msg_file = emsg_file
          ENDIF
          IF (trim(cnvtupper(mtype))="A")
           SET msg_file = fillstring(100," ")
           SET msg_file = amsg_file
           UPDATE  FROM dba_alertmon_errors e
            SET e.last_page_time = cnvtdatetime(curdate,curtime)
            WHERE (e.error_code=codes->qual[i].err_code)
            WITH nocounter
           ;end update
           COMMIT
          ENDIF
          IF (cnvtupper(mcc_flag)="N")
           EXECUTE email maddr, " ", "alertlog error",
           msg_file
          ELSE
           EXECUTE email " ", maddr, "alertlog error",
           msg_file
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 IF (((cursys="VMS") OR (cursys="AXP")) )
  SET ecom = "delete ccluserdir:dba_alertmon_email_file.mail;"
  SET acom = "delete ccluserdir:dba_alertmon_amail_file.mail;"
 ENDIF
 IF (cursys="AIX")
  SET ecom = "rm /tmp/alertmon_email_file.mail*"
  SET acom = "rm /tmp/alertmon_amail_file.mail*"
 ENDIF
 IF (email_flag=1)
  CALL dcl(trim(ecom),size(trim(ecom)),0)
 ENDIF
 IF (amail_flag=1)
  CALL dcl(trim(acom),size(trim(ecom)),0)
 ENDIF
#lbl_end
END GO
