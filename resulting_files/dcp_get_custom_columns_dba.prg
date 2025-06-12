CREATE PROGRAM dcp_get_custom_columns:dba
 RECORD reply(
   1 qual[*]
     2 spread_type_cd = f8
     2 custom_column_cd = f8
     2 custom_column_meaning = c12
     2 caption = vc
     2 sequence = i2
     2 position_cd = f8
     2 prsnl_id = f8
     2 spread_column_id = f8
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
   GO TO exit_script
  ENDIF
 ELSE
  IF ((request->spread_type_cd <= 0))
   GO TO exit_script
  ENDIF
 ENDIF
#find_prsnl
 IF ((request->prsnl_id > 0))
  CALL echo("Went into prsnl select")
  SELECT INTO "nl:"
   dcp.spread_type_cd, dcp.prsnl_id
   FROM dcp_custom_columns dcp
   WHERE (dcp.spread_type_cd=request->spread_type_cd)
    AND (dcp.prsnl_id=request->prsnl_id)
   ORDER BY dcp.sequence_ind
   DETAIL
    count = (count+ 1)
    IF (count > size(reply->qual,5))
     stat = alterlist(reply->qual,(count+ 5))
    ENDIF
    reply->qual[count].spread_type_cd = dcp.spread_type_cd, reply->qual[count].custom_column_cd = dcp
    .custom_column_cd, reply->qual[count].custom_column_meaning = dcp.custom_column_meaning,
    reply->qual[count].caption = dcp.caption, reply->qual[count].sequence = dcp.sequence_ind, reply->
    qual[count].position_cd = dcp.position_cd,
    reply->qual[count].prsnl_id = dcp.prsnl_id, reply->qual[count].spread_column_id = dcp
    .spread_column_id
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
   CALL echo("Didn't find anything. curqual = 0. Going to find_position")
   GO TO find_position
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
  dcp.spread_type_cd, dcp.prsnl_id
  FROM dcp_custom_columns dcp
  WHERE (dcp.spread_type_cd=request->spread_type_cd)
   AND (dcp.position_cd=request->position_cd)
  ORDER BY dcp.sequence_ind
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->qual,5))
    stat = alterlist(reply->qual,(count+ 5))
   ENDIF
   reply->qual[count].spread_type_cd = dcp.spread_type_cd, reply->qual[count].custom_column_cd = dcp
   .custom_column_cd, reply->qual[count].custom_column_meaning = dcp.custom_column_meaning,
   reply->qual[count].caption = dcp.caption, reply->qual[count].sequence = dcp.sequence_ind, reply->
   qual[count].position_cd = dcp.position_cd,
   reply->qual[count].prsnl_id = dcp.prsnl_id, reply->qual[count].spread_column_id = dcp
   .spread_column_id
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
  GO TO exit_script
 ENDIF
#find_system
 CALL echo("Inside system select.")
 CALL echo(build(" Request->prsnl_id = ",request->prsnl_id))
 CALL echo(build(" Request->position_cd = ",request->position_cd))
 SELECT INTO "nl:"
  dcp.spread_type_cd, dcp.prsnl_id
  FROM dcp_custom_columns dcp
  WHERE (dcp.spread_type_cd=request->spread_type_cd)
   AND dcp.prsnl_id=0
   AND dcp.position_cd=0
  ORDER BY dcp.sequence_ind
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->qual,5))
    stat = alterlist(reply->qual,(count+ 5))
   ENDIF
   reply->qual[count].spread_type_cd = dcp.spread_type_cd, reply->qual[count].custom_column_cd = dcp
   .custom_column_cd, reply->qual[count].custom_column_meaning = dcp.custom_column_meaning,
   reply->qual[count].caption = dcp.caption, reply->qual[count].sequence = dcp.sequence_ind, reply->
   qual[count].position_cd = dcp.position_cd,
   reply->qual[count].prsnl_id = dcp.prsnl_id, reply->qual[count].spread_column_id = dcp
   .spread_column_id
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
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DCP CUSTOM COLUMNS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO RETRIEVE"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("STATUS:  ",reply->status_data.status))
 CALL echo(build("********COLUMN INFO**********"))
 CALL echo(build("count:",count))
 FOR (x = 1 TO count)
   CALL echo("------------------------------------------")
   CALL echo(build("spead_type_cd:",reply->qual[x].spread_type_cd))
   CALL echo(build("custom_column_meaning:",reply->qual[x].custom_column_meaning))
   CALL echo(build("sequence:",reply->qual[x].sequence))
   CALL echo(build("caption:",reply->qual[x].caption))
   CALL echo("-------------------------------------------")
 ENDFOR
END GO
