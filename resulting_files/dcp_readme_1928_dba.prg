CREATE PROGRAM dcp_readme_1928:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE cnt = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 RECORD temp(
   1 qual[*]
     2 id = f8
     2 flag = i2
 )
 SET readme_data->message = "Gathering visit relationships."
 EXECUTE dm_readme_status
 SELECT INTO "nl:"
  FROM team_mem_ppr_reltn team
  WHERE team.ppr_cd IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=333))
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(temp->qual,(cnt+ 9))
   ENDIF
   temp->qual[cnt].id = team.team_mem_ppr_reltn_id, temp->qual[cnt].flag = 1
  WITH nocounter
 ;end select
 SET readme_data->message = "Gathering lifetime relationships."
 EXECUTE dm_readme_status
 SELECT INTO "nl:"
  FROM team_mem_ppr_reltn team
  WHERE team.ppr_cd IN (
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=331))
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(temp->qual,(cnt+ 9))
   ENDIF
   temp->qual[cnt].id = team.team_mem_ppr_reltn_id, temp->qual[cnt].flag = 0
  WITH nocounter
 ;end select
 SET readme_data->message = build("Total rows to be altered: ",cnt)
 EXECUTE dm_readme_status
 FOR (i = 1 TO cnt)
  UPDATE  FROM team_mem_ppr_reltn team
   SET team.ppr_flag = temp->qual[i].flag
   WHERE (team.team_mem_ppr_reltn_id=temp->qual[i].id)
   WITH nocounter
  ;end update
  IF (mod(i,1000)=0)
   SET readme_data->message = build("Updating rows (",i,"/",cnt,")")
   EXECUTE dm_readme_status
  ENDIF
 ENDFOR
 SET readme_data->status = "S"
 EXECUTE dm_readme_status
END GO
