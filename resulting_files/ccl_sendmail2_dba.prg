CREATE PROGRAM ccl_sendmail2:dba
 PROMPT
  "Enter e-mail address to send to: " = "",
  "Enter e-mail address of sender: " = "",
  "Enter subject: " = "<TEST E-MAIL SUBJECT>",
  "Enter message: " = "<TEST E-MAIL MESSAGE>"
 DECLARE msgpriority = i4
 DECLARE readmode = i4
 SET msgpriority = 5
 SET readmode = 1
 SET sendto = trim( $1)
 SET sender = trim( $2)
 SET subject = trim( $3)
 SET messagetext = trim( $4)
 SET msgclass = "IPM.NOTE"
 IF (textlen(sendto) <= 1)
  CALL echo("Enter a valid e-mail address to send message to...")
  GO TO exit_program
 ENDIF
 IF (textlen(sender) <= 1)
  CALL echo("Enter a valid e-mail address for sender...")
  GO TO exit_program
 ENDIF
 CALL uar_send_mail2(nullterm(sendto),nullterm(subject),nullterm(messagetext),nullterm(sender),
  msgpriority,
  nullterm(msgclass),readmode)
#exit_program
END GO
