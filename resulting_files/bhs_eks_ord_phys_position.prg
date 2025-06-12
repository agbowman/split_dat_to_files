CREATE PROGRAM bhs_eks_ord_phys_position
 PROMPT
  "semi-colon seperated list of positions" = "0"
 DECLARE position_list = vc
 DECLARE delimiter = i4
 DECLARE cnt = i4
 SET position_list =  $1
 SET cnt = 0
 FREE RECORD positions
 RECORD positions(
   1 list[*]
     2 position_cd = f8
 )
 SET delimiter = findstring(";",position_list)
 IF (delimiter > 0)
  WHILE (delimiter > 0)
    SET delimiter = findstring(";",position_list)
    IF (delimiter > 0)
     SET cnt = (cnt+ 1)
     SET stat = alterlist(positions->list,cnt)
     SET positions->list[cnt].position_cd = cnvtreal(substring(1,(delimiter - 1),position_list))
     SET position_list = substring((delimiter+ 1),size(position_list),position_list)
    ELSE
     SET cnt = (cnt+ 1)
     SET stat = alterlist(positions->list,cnt)
     SET positions->list[cnt].position_cd = cnvtreal(position_list)
     SET position_list = ""
    ENDIF
    IF ((positions->list[cnt].position_cd=0.00))
     SET cnt = (cnt - 1)
     SET stat = alterlist(positions->list,cnt)
    ENDIF
  ENDWHILE
 ELSE
  SET cnt = (cnt+ 1)
  SET stat = alterlist(positions->list,cnt)
  SET positions->list[cnt].position_cd = cnvtreal(position_list)
  SET position_list = ""
 ENDIF
 CALL echorecord(positions)
 DECLARE qual_position = f8
 DECLARE qual_name = vc
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE (pr.person_id=request->orderlist[event_repeat_index].physician))
  DETAIL
   qual_position = pr.position_cd, qual_name = pr.name_full_formatted
  WITH nocounter
 ;end select
 CALL echo(qual_position)
 CALL echo(qual_name)
 SET found = 0
 FOR (i = 1 TO size(positions->list,5))
   IF ((positions->list[i].position_cd=qual_position))
    SET found = 1
   ENDIF
 ENDFOR
 IF (found=1)
  SET log_message = concat("TRUE!! Physician :",qual_name," is a ",trim(uar_get_code_display(
     qual_position)))
  SET retval = 100
 ELSE
  SET log_message = concat("FALSE!! Physician :",qual_name," is a ",trim(uar_get_code_display(
     qual_position)))
  SET retval = 0
 ENDIF
END GO
