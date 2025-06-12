CREATE PROGRAM dcp_get_sort_dialog:dba
 RECORD reply(
   1 qual[*]
     2 spread_type_cd = f8
     2 column_cd = f8
     2 column_description = c12
     2 sort_level = i2
     2 position_cd = f8
     2 prsnl_id = f8
     2 column_sort_id = f8
     2 sort_direction_ind = i2
     2 sort_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET count = 0
 IF ((request->from_tool_ind=1))
  CALL echo("From Tool Ind = 1")
  IF ((request->prsnl_id > 0))
   CALL echo("Going to find_prsnl")
   GO TO find_prsnl
  ELSEIF ((request->position_cd > 0))
   CALL echo("Going to find_position")
   GO TO find_position
  ELSEIF ((request->prsnl_id=0)
   AND (request->position_cd=0))
   CALL echo("Going to find_system")
   GO TO find_system
  ELSE
   CALL echo("from tool = 1. didn't find anything. going to exit script. failed to T")
   SET failed = "T"
   CALL echo("exit script failed = T")
   GO TO exit_script
  ENDIF
 ENDIF
#find_prsnl
 IF ((request->prsnl_id > 0))
  CALL echo("Went into prsnl select")
  SELECT INTO "nl:"
   dcs.spread_type_cd, dcs.prsnl_id
   FROM dcp_custom_cols_sort dcs
   WHERE (dcs.spread_type_cd=request->spread_type_cd)
    AND (dcs.prsnl_id=request->prsnl_id)
   DETAIL
    count = (count+ 1)
    IF (count > size(reply->qual,5))
     stat = alterlist(reply->qual,(count+ 5))
    ENDIF
    reply->qual[count].spread_type_cd = dcs.spread_type_cd, reply->qual[count].column_cd = dcs
    .column_cd, reply->qual[count].column_description = dcs.column_description,
    reply->qual[count].sort_level = dcs.sort_level_flag, reply->qual[count].position_cd = dcs
    .position_cd, reply->qual[count].prsnl_id = dcs.prsnl_id,
    reply->qual[count].column_sort_id = dcs.column_sort_id, reply->qual[count].sort_direction_ind =
    dcs.sort_direction_ind, reply->qual[count].sort_type_flag = dcs.sort_type_flag
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("After prsnl_id select. Count = ",count))
 IF (count > 0)
  SET stat = alterlist(reply->qual,count)
  SET failed = "F"
 ELSE
  SET failed = "T"
 ENDIF
 CALL echo(build("Failed = ",failed))
 CALL echo(build("curqual = ",curqual))
 IF (curqual=0)
  IF ((request->from_tool_ind != 1))
   IF ((request->position_cd > 0))
    CALL echo("Didn't find anything. curqual = 0. Going to find_position")
    GO TO find_position
   ELSE
    CALL echo("Positions is 0 so Going to find_system")
    GO TO find_system
   ENDIF
  ELSE
   CALL echo("curqual = 0. Going to exit_script")
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("Curqual > 0, going to exit script.")
  GO TO exit_script
 ENDIF
#find_position
 CALL echo("Went into position select")
 SELECT INTO "nl:"
  dcs.spread_type_cd, dcs.prsnl_id
  FROM dcp_custom_cols_sort dcs
  WHERE (dcs.spread_type_cd=request->spread_type_cd)
   AND (dcs.position_cd=request->position_cd)
   AND dcs.prsnl_id=0
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->qual,5))
    stat = alterlist(reply->qual,(count+ 5))
   ENDIF
   reply->qual[count].spread_type_cd = dcs.spread_type_cd, reply->qual[count].column_cd = dcs
   .column_cd, reply->qual[count].column_description = dcs.column_description,
   reply->qual[count].sort_level = dcs.sort_level_flag, reply->qual[count].position_cd = dcs
   .position_cd, reply->qual[count].prsnl_id = dcs.prsnl_id,
   reply->qual[count].column_sort_id = dcs.column_sort_id, reply->qual[count].sort_direction_ind =
   dcs.sort_direction_ind, reply->qual[count].sort_type_flag = dcs.sort_type_flag
  WITH nocounter
 ;end select
 CALL echo(build("After position_cd select. Count = ",count))
 IF (count > 0)
  SET stat = alterlist(reply->qual,count)
  SET failed = "F"
 ELSE
  SET failed = "T"
 ENDIF
 CALL echo(build("Failed = ",failed))
 CALL echo(build("curqual = ",curqual))
 IF (curqual=0)
  IF ((request->from_tool_ind != 1))
   CALL echo("Didn't find anything. curqual = 0. Going to find_system")
   GO TO find_system
  ELSE
   CALL echo("curqual = 0. Going to exit_script")
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("exit script")
  GO TO exit_script
 ENDIF
#find_system
 CALL echo("Inside system select.")
 CALL echo(build(" Request->prsnl_id = ",request->prsnl_id))
 CALL echo(build(" Request->position_cd = ",request->position_cd))
 SELECT INTO "nl:"
  dcs.spread_type_cd, dcs.prsnl_id
  FROM dcp_custom_cols_sort dcs
  WHERE (dcs.spread_type_cd=request->spread_type_cd)
   AND dcs.prsnl_id=0
   AND dcs.position_cd=0
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->qual,5))
    stat = alterlist(reply->qual,(count+ 5))
   ENDIF
   reply->qual[count].spread_type_cd = dcs.spread_type_cd, reply->qual[count].column_cd = dcs
   .column_cd, reply->qual[count].column_description = dcs.column_description,
   reply->qual[count].sort_level = dcs.sort_level_flag, reply->qual[count].position_cd = dcs
   .position_cd, reply->qual[count].prsnl_id = dcs.prsnl_id,
   reply->qual[count].column_sort_id = dcs.column_sort_id, reply->qual[count].sort_direction_ind =
   dcs.sort_direction_ind, reply->qual[count].sort_type_flag = dcs.sort_type_flag
  WITH nocounter
 ;end select
 CALL echo(build("After system select. Count = ",count))
 IF (count > 0)
  SET stat = alterlist(reply->qual,count)
  SET failed = "F"
 ELSE
  SET failed = "T"
 ENDIF
 CALL echo(build("Failed = ",failed))
 CALL echo(build("curqual = ",curqual))
 IF (curqual=0)
  CALL echo("exit script failed2")
  GO TO exit_script
 ENDIF
#exit_script
 CALL echo(build("status2 = ",failed))
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP SORT DIALOG"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO RETRIEVE"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("status3 = ",failed))
 CALL echo(build("STATUS:  ",reply->status_data.status))
 CALL echo(build("********COLUMN INFO**********"))
 CALL echo(build("count:",count))
 FOR (x = 1 TO count)
   CALL echo("------------------------------------------")
   CALL echo(build("spead_type_cd:",reply->qual[x].spread_type_cd))
   CALL echo(build("column_description:",reply->qual[x].column_description))
   CALL echo(build("position_cd:",reply->qual[x].position_cd))
   CALL echo(build("prsnl_id:",reply->qual[x].prsnl_id))
   CALL echo(build("sort_direction_ind:",reply->qual[x].sort_direction_ind))
   CALL echo(build("sort_type_flag:",reply->qual[x].sort_type_flag))
   CALL echo("-------------------------------------------")
 ENDFOR
END GO
