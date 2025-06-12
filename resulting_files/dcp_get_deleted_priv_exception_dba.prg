CREATE PROGRAM dcp_get_deleted_priv_exception:dba
 FREE RECORD export_long_text
 RECORD export_long_text(
   1 qual[*]
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 long_text = vc
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE findprivexceptionsonlongtext(category=vc) = null
 DECLARE exportprivexceptioncsvfile(category=vc) = null
 CASE (cursys)
  OF "AIX":
   SET separator = "/"
  OF "AXP":
   SET separator = ""
 ENDCASE
 DECLARE cer_log_path = vc
 DECLARE head_line = vc WITH protected, noconstant("")
 DECLARE line = vc WITH noconstant
 CALL findprivexceptionsonlongtext("PrivExceptionCleanup:Category1")
 CALL findprivexceptionsonlongtext("PrivExceptionCleanup:Category2")
 CALL findprivexceptionsonlongtext("PrivExceptionCleanup:Category3")
 CALL findprivexceptionsonlongtext("PrivExceptionCleanup:Category4")
 CALL findprivexceptionsonlongtext("PrivExceptionCleanup:Category5")
 CALL findprivexceptionsonlongtext("PrivExceptionCleanup:Category6")
 CALL findprivexceptionsonlongtext("PrivExceptionCleanup:Category7")
 CALL findprivexceptionsonlongtext("PrivExceptionCleanup:Category8")
 CALL findprivexceptionsonlongtext("PrivExceptionCleanup:Category9")
 CALL exitscript("S")
 SUBROUTINE findprivexceptionsonlongtext(category)
   SET stat = initrec(export_long_text)
   DECLARE loop_counter = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    FROM long_text lt
    WHERE lt.parent_entity_id=5004
     AND lt.active_ind=1
     AND lt.parent_entity_name=category
    ORDER BY lt.long_text_id
    DETAIL
     loop_counter = (loop_counter+ 1)
     IF (mod(loop_counter,10)=1)
      stat = alterlist(export_long_text->qual,(loop_counter+ 9))
     ENDIF
     export_long_text->qual[loop_counter].parent_entity_name = lt.parent_entity_name,
     export_long_text->qual[loop_counter].parent_entity_id = lt.parent_entity_id, export_long_text->
     qual[loop_counter].long_text = lt.long_text
    WITH nocounter
   ;end select
   SET stat = alterlist(export_long_text->qual,loop_counter)
   CALL exportprivexceptioncsvfile(category)
 END ;Subroutine
 SUBROUTINE exportprivexceptioncsvfile(category)
  CASE (category)
   OF "PrivExceptionCleanup:Category1":
    SET cer_log_path = build(logical("CER_LOG"),separator,"Priv_Exception_Valid_Del_Prevent_Dups.csv"
     )
   OF "PrivExceptionCleanup:Category2":
    SET cer_log_path = build(logical("CER_LOG"),separator,
     "Priv_Exception_Multi_Match_Code_Values.csv")
   OF "PrivExceptionCleanup:Category3":
    SET cer_log_path = build(logical("CER_LOG"),separator,"Priv_Exception_Invalid_Event_Set_Name.csv"
     )
   OF "PrivExceptionCleanup:Category4":
    SET cer_log_path = build(logical("CER_LOG"),separator,"Priv_Exception_Empty_Event_Set_Name.csv")
   OF "PrivExceptionCleanup:Category5":
    SET cer_log_path = build(logical("CER_LOG"),separator,"Priv_Exception_Non_Event_Set.csv")
   OF "PrivExceptionCleanup:Category6":
    SET cer_log_path = build(logical("CER_LOG"),separator,
     "Priv_Exception_Not_Event_Set_Or_Event_Code.csv")
   OF "PrivExceptionCleanup:Category7":
    SET cer_log_path = build(logical("CER_LOG"),separator,"Priv_Exception_Invalid_Type_Cd.csv")
   OF "PrivExceptionCleanup:Category8":
    SET cer_log_path = build(logical("CER_LOG"),separator,"Priv_Exception_Invalid_Entity_Name.csv")
   OF "PrivExceptionCleanup:Category9":
    SET cer_log_path = build(logical("CER_LOG"),separator,"Priv_Exception_Without_Exception.csv")
  ENDCASE
  IF (value(size(export_long_text->qual,5)) > 0)
   SELECT INTO value(cer_log_path)
    FROM (dummyt d  WITH seq = value(size(export_long_text->qual,5)))
    DETAIL
     line = export_long_text->qual[d.seq].long_text, col 0, line,
     row + 1
    WITH nocounter, noformfeed, format = variable,
     maxrow = 1, maxcol = 32000
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE exitscript(scriptstatus)
  IF (scriptstatus="F")
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  GO TO endscript
 END ;Subroutine
#endscript
 FREE RECORD export_long_text
 CALL echo(build("Please see the csv files in: ",logical("CER_LOG"),separator,"priv_exception_*.csv")
  )
END GO
