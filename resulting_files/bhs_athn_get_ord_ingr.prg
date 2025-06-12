CREATE PROGRAM bhs_athn_get_ord_ingr
 SET where_params = build("OI.ORDER_ID =", $2)
 SELECT INTO  $1
  oi.action_sequence, oi.order_detail_display_line
  FROM order_ingredient oi
  PLAN (oi
   WHERE parser(where_params)
    AND ((oi.ingredient_type_flag=0) OR (oi.ingredient_type_flag=3)) )
  ORDER BY oi.action_sequence DESC
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1
  HEAD oi.action_sequence
   row + 1, v1 = build("<IngredientDisplay>",oi.order_detail_display_line,"</IngredientDisplay>"),
   col + 1,
   v1, row + 1, row + 1
  FOOT REPORT
   row + 1, col + 1, "</ReplyMessage>",
   row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
