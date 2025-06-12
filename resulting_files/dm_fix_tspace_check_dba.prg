CREATE PROGRAM dm_fix_tspace_check:dba
 FREE SET tspace
 RECORD tspace(
   1 count = i4
   1 qual[*]
     2 name = c30
     2 initial = i4
     2 next = i4
 )
 SET stat = alterlist(tspace->qual,0)
 SET tspace->count = 0
 SET t_factor = 500
 SET one_k = 1024
 SET block_size = 8192
 SET error_msg = "Default storage for tablespaces successfuly modified!"
 SET request->setup_proc[1].error_msg = "Default storage for tablespaces successfuly modified!"
 SET request->setup_proc[1].success_ind = 1
 SELECT INTO "nl:"
  FROM v$parameter v
  WHERE v.name="db_block_size"
  DETAIL
   block_size = cnvtint(v.value)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ddf.tablespace_name, total_space = sum(ddf.bytes)
  FROM dba_data_files ddf
  WHERE ((ddf.tablespace_name="D_*") OR (ddf.tablespace_name="I_*"))
  GROUP BY ddf.tablespace_name
  DETAIL
   tspace->count = (tspace->count+ 1), stat = alterlist(tspace->qual,tspace->count), tspace->qual[
   tspace->count].name = ddf.tablespace_name,
   tspace->qual[tspace->count].initial = (cnvtint(((total_space/ t_factor)/ one_k))+ 1)
   IF ((tspace->qual[tspace->count].initial < ((2 * block_size)/ one_k)))
    tspace->qual[tspace->count].initial = cnvtint(((2 * block_size)/ one_k))
   ENDIF
   tspace->qual[tspace->count].next = (cnvtint(((total_space/ t_factor)/ one_k))+ 1)
   IF ((tspace->qual[tspace->count].next < ((2 * block_size)/ one_k)))
    tspace->qual[tspace->count].next = cnvtint(((2 * block_size)/ one_k))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM user_tablespaces ut,
   (dummyt d  WITH seq = value(tspace->count))
  PLAN (ut
   WHERE ((ut.tablespace_name="D_*") OR (ut.tablespace_name="I_*")) )
   JOIN (d
   WHERE (ut.tablespace_name=tspace->qual[d.seq].name))
  ORDER BY ut.tablespace_name
  DETAIL
   initial = (cnvtint((ut.initial_extent/ one_k))+ 1), next = (cnvtint((ut.next_extent/ one_k))+ 1)
   IF ((((initial < tspace->qual[d.seq].initial)) OR ((next < tspace->qual[d.seq].next))) )
    error_msg = "ERROR: Default storage for tablespaces NOT modified!", request->setup_proc[1].
    error_msg = "ERROR: Default storage for tablespaces NOT modified!", request->setup_proc[1].
    success_ind = 0
   ENDIF
  WITH counter
 ;end select
 EXECUTE dm_add_upt_setup_proc_log
 CALL echo(error_msg)
END GO
