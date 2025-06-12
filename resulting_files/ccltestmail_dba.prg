CREATE PROGRAM ccltestmail:dba
 PROMPT
  "Mail Destination Name   :" = "cerjcm",
  "Mail Subject            :" = "CclTestMail",
  "Mail From Name          :" = "DiscernExplorer",
  "Mail Message 1          :" = "This is a test of the mail message line 1",
  "Mail Message 2          :" = "This is a test of the mail message line 2",
  "Mail Message 3          :" = "This is a test of the mail message line 3"
 SET msg = build( $4,char(13), $5,char(13), $6,
  char(13))
 CALL uar_send_mail(nullterm( $1),nullterm( $2),nullterm(msg),nullterm( $3),5,
  "IPM.Note")
END GO
