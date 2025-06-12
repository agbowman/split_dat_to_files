CREATE PROGRAM bhs_prax_get_order_comment
 DECLARE moutputdevice = vc WITH protect, constant(request->output_device)
 DECLARE orderid = f8 WITH protect, constant(request->person[1].person_id)
 SELECT INTO value(moutputdevice)
  comment_dt = format(l.active_status_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), comments = substring(1,500,
   trim(replace(replace(replace(replace(replace(l.long_text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0
       ),"'","&apos;",0),'"',"&quot;",0),3)), comment_type = trim(replace(replace(replace(replace(
       replace(uar_get_code_display(o.comment_type_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3),
  action_seq = cnvtint(o.action_sequence), comment_prsnl = trim(replace(replace(replace(replace(
       replace(p.name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3)
  FROM order_comment o,
   long_text l,
   prsnl p
  PLAN (o
   WHERE o.order_id=orderid)
   JOIN (l
   WHERE l.long_text_id=o.long_text_id)
   JOIN (p
   WHERE p.person_id=l.active_status_prsnl_id)
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  DETAIL
   v0 = build("<","Comments",">"), col + 1, v0,
   row + 1, v1 = build("<CommentDateTime>",comment_dt,"</CommentDateTime>"), col + 1,
   v1, row + 1, v2 = build("<Comments>",comments,"</Comments>"),
   col + 1, v2, row + 1,
   v3 = build("<CommentType>",comment_type,"</CommentType>"), col + 1, v3,
   row + 1, v4 = build("<ActionSeq>",action_seq,"</ActionSeq>"), col + 1,
   v4, row + 1, v5 = build("<CommentPrsnl>",comment_prsnl,"</CommentPrsnl>"),
   col + 1, v5, row + 1,
   v6 = build("</","Comments",">"), col + 1, v6,
   row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH nocounter, nullreport, formfeed = none,
   maxcol = 32000, format = variable, maxrow = 0,
   time = 30
 ;end select
END GO
