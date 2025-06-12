CREATE PROGRAM dm_estimate_questions_maint:dba
 PAINT
 FREE SET requestin
 RECORD requestin(
   1 list_0[1]
     2 question_number = f8
     2 description = c100
     2 question_type = f8
 )
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET last_time = "Q"
#start_prg
 CALL video(wi)
 CALL box(1,1,24,132)
 CALL text(2,10,
  "Do you wish to (M)odify a question, (D)elete a question, (A)dd a question, (V)iew a question, or (Q)uit?"
  )
#line1
 CALL accept(20,66,"A;CU",last_time)
 IF (curaccept != "M"
  AND curaccept != "D"
  AND curaccept != "A"
  AND curaccept != "V"
  AND curaccept != "Q")
  GO TO line1
 ENDIF
 SET last_time = curaccept
 IF (curaccept="Q")
  GO TO end_prg
 ELSEIF (curaccept="M")
  CALL modify_question(1)
 ELSEIF (curaccept="D")
  CALL delete_question(1)
 ELSEIF (curaccept="A")
  CALL add_question(1)
 ELSEIF (curaccept="V")
  CALL view_question(1)
 ENDIF
 COMMIT
 GO TO start_prg
 SUBROUTINE modify_question(dummy)
   CALL box(9,55,13,77)
   CALL text(11,57,"Which question? ")
   CALL accept(11,73,"99999")
   SET temp_number = curaccept
   SET temp_description = fillstring(100," ")
   SET temp_type = 0
   SELECT INTO "nl:"
    dq.*
    FROM dm_question dq
    WHERE dq.question_number=temp_number
    DETAIL
     temp_description = dq.description, temp_type = dq.question_type
    WITH nocounter
   ;end select
   FOR (count = 9 TO 13)
     CALL clear(count,55,77)
   ENDFOR
   IF (curqual=0)
    CALL box(9,55,13,77)
    CALL text(11,57," Invalid Question.")
    CALL accept(11,75,"P"," ")
    GO TO start_prg
   ENDIF
   CALL show_question(temp_number,temp_description,temp_type)
   SET requestin->list_0[1].question_number = temp_number
   SET requestin->list_0[1].description = temp_description
   SET requestin->list_0[1].question_type = temp_type
   GO TO edit_fields
 END ;Subroutine
#edit_fields
#descrip
 CALL accept(12,16,"P(100);CS",requestin->list_0[1].description)
 IF (curscroll IN (1, 2, 25))
  GO TO temp_type
 ELSEIF (curscroll BETWEEN 3 AND 24)
  GO TO descrip
 ENDIF
 SET requestin->list_0[1].description = curaccept
#temp_type
 CALL accept(14,32,"9;S",requestin->list_0[1].question_type)
 IF (curscroll IN (1, 2, 25))
  GO TO descrip
 ELSEIF (curscroll BETWEEN 3 AND 24)
  GO TO temp_type
 ENDIF
 IF (curaccept IN (1, 2))
  SET requestin->list_0[1].question_type = curaccept
 ELSE
  GO TO temp_type
 ENDIF
 CALL text(15,17,"Continue? ")
 CALL accept(15,27,"A;CU","Y")
 IF (curaccept="Y")
  EXECUTE dm_estimate_question_import
  IF ((reply->status_data.status IN ("s", "S")))
   CALL text(15,16,"   Success.")
  ELSE
   CALL text(15,16,"   Failure.")
  ENDIF
  CALL accept(15,27,"P"," ")
 ENDIF
 GO TO start_prg
 SUBROUTINE delete_question(dummy)
   CALL box(9,55,13,77)
   CALL text(11,57,"Which question? ")
   CALL accept(11,73,"99999")
   SET temp_number = curaccept
   SET temp_description = fillstring(100," ")
   SET temp_type = 0
   SELECT INTO "nl:"
    dq.*
    FROM dm_question dq
    WHERE dq.question_number=temp_number
    DETAIL
     temp_description = dq.description, temp_type = dq.question_type
    WITH nocounter
   ;end select
   FOR (count = 9 TO 13)
     CALL clear(count,55,77)
   ENDFOR
   IF (curqual=0)
    CALL box(9,55,13,77)
    CALL text(11,57," Invalid Question.")
    CALL accept(11,75,"P"," ")
    GO TO start_prg
   ENDIF
   CALL show_question(temp_number,temp_description,temp_type)
   CALL text(15,17,"Delete? ")
   CALL accept(15,25,"A;CU","Y")
   IF (curaccept != "Y")
    GO TO start_prg
   ENDIF
   DELETE  FROM dm_question dq
    WHERE dq.question_number=temp_number
    WITH nocounter
   ;end delete
   IF (curqual != 0)
    CALL text(15,16,"Delete successful.")
   ELSE
    CALL text(15,16," Delete a failure.")
   ENDIF
   CALL accept(15,34,"P"," ")
 END ;Subroutine
 SUBROUTINE add_question(dummy)
   CALL box(9,55,13,77)
   CALL text(11,57,"Which question? ")
   CALL accept(11,73,"99999")
   SET temp_number = curaccept
   SET temp_description = fillstring(100," ")
   SET temp_type = 1
   SELECT INTO "nl:"
    dq.*
    FROM dm_question dq
    WHERE dq.question_number=temp_number
    WITH nocounter
   ;end select
   IF (curqual != 0)
    CALL box(9,51,13,79)
    CALL clear(10,52,27)
    CALL clear(12,52,27)
    CALL text(11,53,"Question already exists.")
    CALL accept(11,77,"P"," ")
    GO TO start_prg
   ENDIF
   FOR (count = 9 TO 13)
     CALL clear(count,55,77)
   ENDFOR
   CALL show_question(temp_number,temp_description,temp_type)
   SET requestin->list_0[1].question_number = temp_number
   SET requestin->list_0[1].description = temp_description
   SET requestin->list_0[1].question_type = temp_type
   GO TO edit_fields
 END ;Subroutine
 SUBROUTINE view_question(dummy)
   CALL box(9,55,13,77)
   CALL text(11,57,"Which question? ")
   CALL accept(11,73,"99999")
   SET temp_number = curaccept
   SET temp_description = fillstring(100," ")
   SET temp_type = 0
   SELECT INTO "nl:"
    dq.*
    FROM dm_question dq
    WHERE dq.question_number=temp_number
    DETAIL
     temp_description = dq.description, temp_type = dq.question_type
    WITH nocounter
   ;end select
   FOR (count = 9 TO 13)
     CALL clear(count,55,77)
   ENDFOR
   IF (curqual=0)
    CALL box(9,55,13,77)
    CALL text(11,57," Invalid Question.")
    CALL accept(11,75,"P"," ")
    GO TO start_prg
   ENDIF
   CALL show_question(temp_number,temp_description,temp_type)
   CALL accept(15,16,"P"," ")
 END ;Subroutine
 SUBROUTINE show_question(num,descrip,type)
   CALL box(7,14,16,117)
   CALL text(9,16,"Question number: ")
   CALL text(9,34,cnvtstring(num))
   CALL text(11,16,"Description:")
   CALL text(12,16,descrip)
   CALL text(14,16,"Question type: ")
   CALL text(14,32,cnvtstring(type))
 END ;Subroutine
#end_prg
 COMMIT
 FOR (count = 1 TO 24)
   CALL clear(count,1,132)
 ENDFOR
END GO
