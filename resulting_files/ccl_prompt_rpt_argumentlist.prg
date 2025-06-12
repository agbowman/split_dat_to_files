CREATE PROGRAM ccl_prompt_rpt_argumentlist
 RECORD list_o_values(
   1 value = vc
   1 items[*]
     2 text = vc
     2 type = vc
     2 array[*]
       3 type = vc
       3 element = vc
 )
 SET count = 1
 SET tp = reflect(parameter(count,0))
 WHILE (tp > " "
  AND count < 100)
   IF (substring(1,1,tp) != "L")
    SET stat = alterlist(list_o_values->items,count)
    SET list_o_values->items[count].type = tp
    SET list_o_values->items[count].text = parameter(count,0)
   ELSE
    SET stat = alterlist(list_o_values->items,count)
    SET list_o_values->items[count].type = tp
    SET sub = 1
    WHILE (substring(1,1,tp) > " ")
      SET stat = alterlist(list_o_values->items[count].array,sub)
      SET list_o_values->items[count].array[sub].type = reflect(parameter(count,sub))
      SET list_o_values->items[count].array[sub].element = parameter(count,sub)
      SET sub = (sub+ 1)
      SET tp = reflect(parameter(count,sub))
    ENDWHILE
   ENDIF
   SET count = (count+ 1)
   SET tp = reflect(parameter(count,0))
 ENDWHILE
 SELECT INTO  $OUTDEV
  FROM (dummyt d  WITH seq = size(list_o_values->items,5))
  HEAD REPORT
   col 1, "The following arguments were passed:", row + 2,
   col 1, "ARG#", col 10,
   "TYPE", col 15, "VALUE",
   row + 1, col 1, "----",
   col 10, "-------------------------------------------------------", row + 1
  DETAIL
   col 1, d.seq"###", col 10,
   list_o_values->items[d.seq].type
   IF (substring(1,1,list_o_values->items[d.seq].type)="L")
    FOR (i = 1 TO size(list_o_values->items[d.seq].array,5))
      col 20, i"###", ") ",
      col 25, list_o_values->items[d.seq].array[i].type, col 30,
      "[", list_o_values->items[d.seq].array[i].element, "]",
      row + 1
    ENDFOR
   ELSE
    col 15, "[", list_o_values->items[d.seq].text,
    "]"
   ENDIF
   row + 1
  WITH nocounter
 ;end select
END GO
