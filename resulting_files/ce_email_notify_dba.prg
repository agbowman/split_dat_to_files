CREATE PROGRAM ce_email_notify:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE name = vc WITH noconstant(" ")
 DECLARE username = vc WITH noconstant(" ")
 DECLARE application_number = i4 WITH noconstant(0)
 DECLARE application_image = vc WITH noconstant(" ")
 SELECT INTO "nl:"
  FROM application_context a
  WHERE (a.applctx=request->applctx)
  DETAIL
   name = a.name, username = a.username, application_number = a.application_number,
   application_image = a.application_image
  WITH nocounter
 ;end select
 SET cnt = size(request->email_address_list,5)
 FOR (listsize = 1 TO cnt)
   CALL uar_send_mail(nullterm(request->email_address_list[listsize].address),nullterm(concat(
      "CE-Server Failure   ",request->domain," on ",request->node)),nullterm(concat(name,char(10),
      char(13),username,char(10),
      char(13),cnvtstring(application_number),char(10),char(13),application_image,
      char(10),char(13),request->error_text)),nullterm(request->sender_address),5,
    nullterm("IPM.NOTE"))
 ENDFOR
END GO
