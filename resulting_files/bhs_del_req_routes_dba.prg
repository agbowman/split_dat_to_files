CREATE PROGRAM bhs_del_req_routes:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "csv filename" = ""
  WITH outdev, s_filename
 EXECUTE bhs_hlp_csv
 FREE RECORD m_rec
 RECORD m_rec(
   1 id[*]
     2 f_rtg_id = f8
 ) WITH protect
 DECLARE ms_input_file = vc WITH protect, noconstant( $S_FILENAME)
 DECLARE ms_rtl_file = vc WITH protect, noconstant(" ")
 DECLARE ml_rtg_id_col = i4 WITH protect, noconstant(6)
 DECLARE ml_rec_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_blocks = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_start = i4 WITH protect, noconstant(0)
 DECLARE ml_end = i4 WITH protect, noconstant(0)
 DECLARE ml_blocksize = i4 WITH protect, noconstant(200)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 IF (findfile(concat("bhscust:",ms_input_file))=0)
  CALL echo(concat(ms_input_file," not found: exit"))
  GO TO exit_script
 ENDIF
 CALL parser(concat('set logical ms_rtl_file "bhscust:',ms_input_file,'" go'))
 FREE DEFINE rtl2
 DEFINE rtl2 "ms_rtl_file"
 SELECT INTO "nl:"
  FROM rtl2t r
  WHERE r.line > " "
   AND r.line != "ROUTE_DESCRIPTION*"
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   ms_tmp = "", stat = getcsvcolumnatindex(r.line,ml_rtg_id_col,ms_tmp,",",'"')
   IF (stat=1)
    IF (cnvtreal(ms_tmp) != 0)
     pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->id,pl_cnt), m_rec->id[pl_cnt].f_rtg_id = cnvtreal(
      ms_tmp)
    ENDIF
   ENDIF
  FOOT REPORT
   CALL echo(concat(trim(cnvtstring(pl_cnt))," ids found"))
  WITH nocounter
 ;end select
 SET ml_rec_cnt = size(m_rec->id,5)
 IF (ml_rec_cnt > ml_blocksize)
  SET ml_blocks = (ml_rec_cnt/ ml_blocksize)
  IF (mod(ml_rec_cnt,ml_blocksize) > 0)
   SET ml_blocks = (ml_blocks+ 1)
  ENDIF
 ELSE
  SET ml_blocks = 1
 ENDIF
 FOR (ml_cnt = 1 TO ml_blocks)
   SET ml_start = (((ml_cnt - 1) * ml_blocksize)+ 1)
   IF (((ml_start+ ml_blocksize) > ml_rec_cnt))
    SET ml_end = ml_rec_cnt
   ELSE
    SET ml_end = ((ml_start - 1)+ ml_blocksize)
   ENDIF
   DELETE  FROM dcp_flex_rtg dfr
    WHERE expand(ml_idx,ml_start,ml_end,dfr.dcp_flex_rtg_id,m_rec->id[ml_idx].f_rtg_id,
     ml_blocksize)
    WITH nocounter
   ;end delete
   DELETE  FROM dcp_flex_printer dfp
    WHERE expand(ml_idx,ml_start,ml_end,dfp.dcp_flex_rtg_id,m_rec->id[ml_idx].f_rtg_id,
     ml_blocksize)
    WITH nocounter
   ;end delete
   COMMIT
 ENDFOR
#exit_script
 FREE RECORD m_rec
END GO
