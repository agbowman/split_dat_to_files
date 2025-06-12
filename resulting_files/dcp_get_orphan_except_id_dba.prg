CREATE PROGRAM dcp_get_orphan_except_id:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 csv_file_name = vc
    1 orphaned_priv_except[*]
      2 privilege_exception_id = f8
      2 privilege_id = f8
      2 privilege = vc
      2 privilege_value = vc
      2 privilege_level = vc
      2 exception_id = f8
      2 event_set_name = vc
    1 orphaned_except_groups[*]
      2 group_description = vc
      2 log_grouping_cd = f8
      2 item_cd_disp = vc
      2 ditemcd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE findorphanedexceptionid(null) = null
 DECLARE findexceptiongroupswithorphans(null) = null
 CASE (cursys)
  OF "AIX":
   SET separator = "/"
  OF "AXP":
   SET separator = ""
 ENDCASE
 DECLARE ccluserdir_path = vc WITH protect, noconstant("")
 SET ccluserdir_path = build(logical("CCLUSERDIR"),separator,"Orphaned_Privilege_Exceptions.csv")
 SET reply->status_data.status = "F"
 IF ((request->first_request_ind=1))
  SET stat = remove(ccluserdir_path)
 ENDIF
 CALL findorphanedexceptionid(null)
 CALL findexceptiongroupswithorphans(null)
 IF (((size(reply->orphaned_priv_except,5) > 0) OR (size(reply->orphaned_except_groups,5) > 0)) )
  CALL echo(ccluserdir_path)
  SET reply->csv_file_name = ccluserdir_path
 ENDIF
 CALL exitscript("S")
 SUBROUTINE findorphanedexceptionid(null)
   DECLARE qual_counter = i4 WITH protect, noconstant(0)
   DECLARE title_line = vc WITH protect, noconstant("")
   SET title_line = build("Privilege Exceptions that will contain an orphaned event set,",format(
     cnvtdatetime(sysdate),"DD-MMM-YYYY HH:MM;;D"))
   DECLARE head_line = vc WITH protect, noconstant("")
   SET head_line =
   "Exception_id,Event_Set_Name,Priv_exception_id,Privilege_id,Privilege,Privilege_value,Privilege_level"
   DECLARE line = vc WITH protect, noconstant("")
   SELECT
    IF ((request->first_request_ind=1))
     WITH nocounter, noformfeed, format = variable,
      maxrow = 1, maxcol = 32000
    ELSE
     WITH nocounter, noformfeed, format = variable,
      maxrow = 1, maxcol = 32000, append
    ENDIF
    INTO value(ccluserdir_path)
    FROM privilege_exception pe,
     privilege p,
     priv_loc_reltn plr
    PLAN (pe
     WHERE pe.exception_entity_name="V500_EVENT_SET_CODE"
      AND pe.exception_id != 0
      AND pe.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      ese.event_set_cd
      FROM v500_event_set_explode ese
      WHERE pe.exception_id=ese.event_set_cd))))
     JOIN (p
     WHERE p.privilege_id=pe.privilege_id
      AND p.active_ind=1)
     JOIN (plr
     WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id)
    ORDER BY pe.exception_id
    HEAD REPORT
     row + 1, col 0, title_line,
     row + 1, col 0, head_line,
     row + 1
    DETAIL
     qual_counter += 1
     IF (mod(qual_counter,10)=1)
      stat = alterlist(reply->orphaned_priv_except,(qual_counter+ 9))
     ENDIF
     reply->orphaned_priv_except[qual_counter].exception_id = pe.exception_id, reply->
     orphaned_priv_except[qual_counter].privilege_exception_id = pe.privilege_exception_id, reply->
     orphaned_priv_except[qual_counter].privilege_id = p.privilege_id,
     reply->orphaned_priv_except[qual_counter].privilege = replace(uar_get_code_display(p
       .privilege_cd),",","",0), reply->orphaned_priv_except[qual_counter].privilege_value = replace(
      uar_get_code_display(p.priv_value_cd),",","",0), reply->orphaned_priv_except[qual_counter].
     privilege_level = evaluate(plr.position_cd,0.00,evaluate(plr.ppr_cd,0.00,evaluate(plr.person_id,
        0.00,"NONE",concat("PERSON - ",build(plr.person_id))),concat("PPR - ",uar_get_code_display(
         plr.ppr_cd))),concat("POSITION - ",uar_get_code_display(plr.position_cd))),
     reply->orphaned_priv_except[qual_counter].event_set_name = replace(uar_get_code_display(pe
       .exception_id),",","",0), line = build(build(reply->orphaned_priv_except[qual_counter].
       exception_id,", "),build(reply->orphaned_priv_except[qual_counter].event_set_name,","),build(
       reply->orphaned_priv_except[qual_counter].privilege_exception_id,", "),build(reply->
       orphaned_priv_except[qual_counter].privilege_id,", "),build(reply->orphaned_priv_except[
       qual_counter].privilege,","),
      build(reply->orphaned_priv_except[qual_counter].privilege_value,","),reply->
      orphaned_priv_except[qual_counter].privilege_level), col 0,
     line, row + 1
   ;end select
   SET stat = alterlist(reply->orphaned_priv_except,qual_counter)
   IF ((request->first_request_ind=1)
    AND size(reply->orphaned_priv_except,5)=0)
    SET stat = remove(ccluserdir_path)
   ENDIF
 END ;Subroutine
 SUBROUTINE findexceptiongroupswithorphans(null)
   DECLARE qual_counter = i4 WITH protect, noconstant(0)
   DECLARE nitemcdind = i4 WITH protect, noconstant(0)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   SET lstat = alterlist(reply->orphaned_except_groups,1)
   IF ( NOT (validate(reply->orphaned_except_groups[1].ditemcd,1)))
    SET nitemcdind = 1
   ENDIF
   SET lstat = alterlist(reply->orphaned_except_groups,0)
   DECLARE title_line = vc WITH protect, noconstant("")
   SET title_line = build("Exception Groups that will contain an orphaned event set,",format(
     cnvtdatetime(sysdate),"DD-MMM-YYYY HH:MM;;D"))
   DECLARE head_line = vc WITH protect, noconstant("")
   IF (nitemcdind=1)
    SET head_line = "Group Description,Log_Grouping_cd,Event_Set_Name,Event_Set_Code"
   ELSE
    SET head_line = "Group Description,Log_Grouping_cd,Event_Set_Name"
   ENDIF
   DECLARE line = vc WITH protect, noconstant("")
   SELECT
    IF ((request->first_request_ind=1)
     AND size(reply->orphaned_priv_except,5)=0)
     WITH nocounter, noformfeed, format = variable,
      maxrow = 1, maxcol = 32000
    ELSE
     WITH nocounter, noformfeed, format = variable,
      maxrow = 1, maxcol = 32000, append
    ENDIF
    INTO value(ccluserdir_path)
    FROM log_group_entry lge,
     logical_grouping lg
    PLAN (lge
     WHERE lge.log_grouping_cd != 0
      AND lge.exception_entity_name="V500_EVENT_SET_CODE"
      AND  NOT ( EXISTS (
     (SELECT
      ese.event_set_cd
      FROM v500_event_set_explode ese
      WHERE lge.item_cd=ese.event_set_cd))))
     JOIN (lg
     WHERE lg.log_grouping_cd != 0
      AND lge.log_grouping_cd=lg.log_grouping_cd)
    ORDER BY lg.logical_group_desc
    HEAD REPORT
     row + 1, col 0, title_line,
     row + 1, col 0, head_line,
     row + 1
    DETAIL
     qual_counter += 1
     IF (mod(qual_counter,10)=1)
      lstat = alterlist(reply->orphaned_except_groups,(qual_counter+ 9))
     ENDIF
     reply->orphaned_except_groups[qual_counter].group_description = lg.logical_group_desc, reply->
     orphaned_except_groups[qual_counter].log_grouping_cd = lg.log_grouping_cd, reply->
     orphaned_except_groups[qual_counter].item_cd_disp = replace(uar_get_code_display(lge.item_cd),
      ",","",0),
     line = build(reply->orphaned_except_groups[qual_counter].group_description,build(",",reply->
       orphaned_except_groups[qual_counter].log_grouping_cd,","),reply->orphaned_except_groups[
      qual_counter].item_cd_disp)
     IF (nitemcdind=1)
      CALL assignitemcd(lge.item_cd,qual_counter), line = build(line,",",lge.item_cd)
     ENDIF
     col 0, line, row + 1
   ;end select
   SET lstat = alterlist(reply->orphaned_except_groups,qual_counter)
   IF ((request->first_request_ind=1)
    AND size(reply->orphaned_priv_except,5)=0
    AND size(reply->orphaned_except_groups,5)=0)
    SET lstat = remove(ccluserdir_path)
   ENDIF
 END ;Subroutine
 SUBROUTINE (assignitemcd(ditemcode=f8,lcounter=i4) =null)
   SET reply->orphaned_except_groups[lcounter].ditemcd = ditemcode
 END ;Subroutine
 SUBROUTINE (exitscript(scriptstatus=vc) =null)
  IF (scriptstatus="F")
   SET reply->status_data.status = "F"
   SET reqinfo->commit_ind = 0
  ELSEIF (scriptstatus="S")
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ENDIF
  GO TO endscript
 END ;Subroutine
#endscript
END GO
