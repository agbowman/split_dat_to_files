CREATE PROGRAM afc_rpt_all:dba
 PAINT
 DECLARE afc_rpt_all_version = vc
 SET afc_rpt_all_version = "323720.FT.008"
 SET width = 140
 SET modify = system
#initialize_structs
 FREE SET file
 RECORD file(
   1 prompt_row = i2
   1 file_name = vc
 )
 FREE SET ext_owner
 RECORD ext_owner(
   1 count = i2
   1 prompt_row = i2
   1 qual[*]
     2 owner_cd = f8
     2 owner_disp = vc
 )
 FREE SET cp_sched
 RECORD cp_sched(
   1 count = i2
   1 prompt_row = i2
   1 sched[*]
     2 sched_cd = f8
     2 sched_disp = vc
 )
 FREE SET bc_sched
 RECORD bc_sched(
   1 count = i2
   1 prompt_row = i2
   1 sched[*]
     2 sched_cd = f8
     2 sched_disp = vc
 )
 FREE SET p_sched
 RECORD p_sched(
   1 count = i2
   1 prompt_row = i2
   1 sched[*]
     2 sched_cd = f8
     2 sched_disp = vc
 )
 FREE SET bi_level
 RECORD bi_level(
   1 prompt_row = i2
   1 level = i2
 )
 SET parent_only = 1
 SET child_only = 2
 SET default_only = 3
 SET parent_child = 4
 SET all_items = 5
 SET bi_level->level = all_items
 SET file->file_name = "MINE"
 SET debug_mode = 0
 SET first_time = 1
 SET start_dt_tm = cnvtdatetime(curdate,curtime)
 SET end_dt_tm = cnvtdatetime(curdate,curtime)
 SET cdf_meaning = fillstring(12," ")
#end_initialize_structs
 DECLARE stat = i4
 DECLARE code_set = i4
 DECLARE code_value = f8
 DECLARE cnt = i4
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE hdrchargeprocessing = vc
 DECLARE hdrbillcodes = vc
 DECLARE hdrpriceschedules = vc
 DECLARE dtlbiname = vc
 DECLARE dtlcpname = vc
 DECLARE dtlchargelevel = vc
 DECLARE dtlchargepoint = vc
 DECLARE dtlcppriority = vc
 DECLARE dtlbcname = vc
 DECLARE dtlbcdesc = vc
 DECLARE dtlpsname = vc
 DECLARE dtlunknowntype = vc
 DECLARE rptfilename = vc
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET cnt = 1
 SET code_set = 13016
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET cdf_meaning = "ALPHA RESP"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,code_value)
 SET cdalpharesp = code_value
#menu
 SET top_row = 3
 SET d_row = top_row
 CALL video(n)
 CALL clear(1,1)
 CALL box(3,1,23,79)
 CALL video(i)
 IF (debug_mode=0)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Charge Services Bill Item Report")
  CALL text(2,1,displaystring,w)
 ELSE
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Charge Services Bill Item Report DEBUG")
  CALL text(2,1,displaystring,w)
 ENDIF
 SET d_row = (d_row+ 1)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1"," 1)  Output File")
 CALL text(d_row,5,displaystring)
 SET file->prompt_row = d_row
 SET d_row = (d_row+ 1)
 CALL video(l)
 CALL text(d_row,12,file->file_name)
 CALL video(n)
 SET d_row = (d_row+ 1)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1"," 2)  Owner Code")
 CALL text(d_row,5,displaystring)
 SET ext_owner->prompt_row = d_row
 SET d_row = (d_row+ 1)
 CALL display_owner_codes("dummy")
 SET d_row = (d_row+ 1)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1"," 3)  Charge Processing Schedules")
 CALL text(d_row,5,displaystring)
 SET cp_sched->prompt_row = d_row
 SET d_row = (d_row+ 1)
 CALL display_cp_scheds("dummy")
 SET d_row = (d_row+ 2)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1"," 4)  Bill Code Schedules")
 CALL text(d_row,5,displaystring)
 SET bc_sched->prompt_row = d_row
 SET d_row = (d_row+ 1)
 CALL display_bc_scheds("dummy")
 SET d_row = (d_row+ 2)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1"," 5)  Price Schedules")
 CALL text(d_row,5,displaystring)
 SET p_sched->prompt_row = d_row
 SET d_row = (d_row+ 1)
 CALL display_p_scheds(p_sched->prompt_row,12)
 SET d_row = (d_row+ 2)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1"," 6)  Bill Item Level")
 CALL text(d_row,5,displaystring)
 SET bi_level->prompt_row = d_row
 CALL text(d_row,40,cnvtstring(bi_level->level))
 SET d_row = (d_row+ 1)
 CALL video(l)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1",
  "1 = Parents Only, 2 = Children Only, 3 = Default Only,")
 CALL text(d_row,12,displaystring)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","4 = Parent/Child, 5 = All")
 CALL text((d_row+ 1),12,displaystring)
 SET d_row = (d_row+ 2)
 CALL video(n)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1"," 7)  Create Report")
 CALL text(d_row,5,displaystring)
 SET d_row = (d_row+ 1)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1"," 8)  Exit")
 CALL text(d_row,5,displaystring)
 IF (first_time=1)
  EXECUTE FROM file_prompt TO end_file_prompt
  EXECUTE FROM owner_code_prompt TO end_owner_code_prompt
  EXECUTE FROM cp_scheds_prompt TO end_cp_scheds_prompt
  EXECUTE FROM bc_scheds_prompt TO end_bc_scheds_prompt
  EXECUTE FROM ps_prompt TO end_ps_prompt
  EXECUTE FROM bi_level_prompt TO end_bi_level_prompt
 ENDIF
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Select Option (1,2,3,...)")
 CALL text(24,2,displaystring)
 CALL accept(24,29,"9;",8
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7, 8, 9))
 CALL clear(24,1)
 SET first_time = 0
 CASE (curaccept)
  OF 1:
   EXECUTE FROM file_prompt TO end_file_prompt
  OF 2:
   EXECUTE FROM owner_code_prompt TO end_owner_code_prompt
  OF 3:
   EXECUTE FROM cp_scheds_prompt TO end_cp_scheds_prompt
  OF 4:
   EXECUTE FROM bc_scheds_prompt TO end_bc_scheds_prompt
  OF 5:
   EXECUTE FROM ps_prompt TO end_ps_prompt
  OF 6:
   EXECUTE FROM bi_level_prompt TO end_bi_level_prompt
  OF 7:
   EXECUTE FROM create_report TO end_create_report
  OF 8:
   GO TO end_prog
  OF 9:
   IF (debug_mode=1)
    SET debug_mode = 0
   ELSE
    SET debug_mode = 1
   ENDIF
  ELSE
   SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Option not yet active...")
   CALL text(24,2,displaystring)
 ENDCASE
 GO TO menu
#file_prompt
 CALL accept(file->prompt_row,40,"P(20);CDUS",file->file_name)
 SET file->file_name = trim(curaccept,3)
 CALL video(l)
 CALL text((file->prompt_row+ 1),12,file->file_name)
 CALL video(n)
 CALL clear(file->prompt_row,40,20)
 CALL clear(24,1)
#end_file_prompt
#owner_code_prompt
 FREE SET bill_items
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Select Owner Code to Display")
 CALL text(24,1,displaystring)
 SET help =
 SELECT
  code_value = cv.code_value"##########;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","<HELP AVAILABLE (Shift+F5)>")
 CALL text(24,50,displaystring)
 CALL accept(ext_owner->prompt_row,40,"9(10);DS",0)
 IF (curaccept != 0)
  SET ext_owner->count = (ext_owner->count+ 1)
  SET sel_owner_cd = curaccept
  SET stat = alterlist(ext_owner->qual,ext_owner->count)
  SET sel_owner_disp = fillstring(40," ")
  SELECT INTO "nl:"
   cv.display
   FROM code_value cv
   WHERE cv.code_value=sel_owner_cd
   DETAIL
    sel_owner_disp = cv.display
   WITH nocounter
  ;end select
  SET ext_owner->qual[ext_owner->count].owner_cd = sel_owner_cd
  SET ext_owner->qual[ext_owner->count].owner_disp = sel_owner_disp
  CALL display_owner_codes("dummy")
 ENDIF
 SET help = off
 CALL clear(ext_owner->prompt_row,40,10)
 CALL clear(24,1)
#end_owner_code_prompt
#cp_scheds_prompt
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1",
  "Select Charge Processing Schedule(s) to display")
 CALL text(24,1,displaystring)
 EXECUTE FROM init_cp TO end_init_cp
 SET help =
 SELECT
  code_value = cv.code_value"##########;l", cv.display
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=14002
    AND cv.cdf_meaning="CHARGE POINT"
    AND cv.active_ind=1)
  ORDER BY cv.display
  WITH nocounter
 ;end select
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","<HELP AVAILABLE (Shift+F5)>")
 CALL text(24,50,displaystring)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Enter 0 when done.")
 CALL text(cp_sched->prompt_row,55,displaystring)
 CALL accept(cp_sched->prompt_row,40,"9(10);DS",0)
 IF (curscroll=2)
  CALL clear(cp_sched->prompt_row,40,35)
  CALL clear((ext_owner->prompt_row+ 1),12,35)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","ALL")
  CALL text((ext_owner->prompt_row+ 1),12,displaystring)
  SET ext_owner->count = 0
  EXECUTE FROM owner_code_prompt TO end_owner_code_prompt
  EXECUTE FROM cp_scheds_prompt TO end_cp_scheds_prompt
 ELSE
  IF (curaccept != 0)
   SET cp_sched->count = (cp_sched->count+ 1)
   SET sel_charge_sched = curaccept
   SET stat = alterlist(cp_sched->sched,cp_sched->count)
   SET sel_charge_sched_disp = fillstring(40," ")
   SELECT INTO "nl:"
    cv.display
    FROM code_value cv
    WHERE cv.code_value=sel_charge_sched
    DETAIL
     sel_charge_sched_disp = cv.display
    WITH nocounter
   ;end select
   SET cp_sched->sched[cp_sched->count].sched_disp = sel_charge_sched_disp
   SET cp_sched->sched[cp_sched->count].sched_cd = sel_charge_sched
   CALL display_cp_scheds("dummy")
   EXECUTE FROM cp_scheds_prompt TO end_cp_scheds_prompt
  ENDIF
 ENDIF
 SET help = off
 CALL clear(cp_sched->prompt_row,40,35)
 CALL clear(24,1)
#end_cp_scheds_prompt
#bc_scheds_prompt
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Select Bill Code Schedule(s) to display")
 CALL text(24,1,displaystring)
 EXECUTE FROM init_bc TO end_init_bc
 SET help =
 SELECT
  code_value = cv.code_value"##########;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.cdf_meaning IN ("CDM_SCHED", "CPT4", "GL", "HCPCS", "MODIFIER",
  "PROCCODE", "REVENUE")
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","<HELP AVAILABLE (Shift+F5)>")
 CALL text(24,50,displaystring)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Enter 0 when done.")
 CALL text(bc_sched->prompt_row,55,displaystring)
 CALL accept(bc_sched->prompt_row,40,"9(10);DS",0)
 IF (curscroll=2)
  CALL clear(bc_sched->prompt_row,40,35)
  EXECUTE FROM cp_scheds_prompt TO end_cp_scheds_prompt
  EXECUTE FROM bc_scheds_prompt TO end_bc_scheds_prompt
 ELSE
  IF (curaccept != 0)
   SET bc_sched->count = (bc_sched->count+ 1)
   SET sel_charge_sched = curaccept
   SET stat = alterlist(bc_sched->sched,bc_sched->count)
   SET sel_charge_sched_disp = fillstring(40," ")
   SELECT INTO "nl:"
    cv.display
    FROM code_value cv
    WHERE cv.code_value=sel_charge_sched
    DETAIL
     sel_charge_sched_disp = cv.display
    WITH nocounter
   ;end select
   SET bc_sched->sched[bc_sched->count].sched_disp = sel_charge_sched_disp
   SET bc_sched->sched[bc_sched->count].sched_cd = sel_charge_sched
   CALL display_bc_scheds("dummy")
   EXECUTE FROM bc_scheds_prompt TO end_bc_scheds_prompt
  ENDIF
 ENDIF
 SET help = off
 CALL clear(bc_sched->prompt_row,40,35)
 CALL clear(24,1)
#end_bc_scheds_prompt
#ps_prompt
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Select Price Schedules to display")
 CALL text(24,1,displaystring)
 EXECUTE FROM init_ps TO end_init_ps
 SET help =
 SELECT
  ps_id = ps.price_sched_id"##########;l", ps.price_sched_desc
  FROM price_sched ps
  WHERE ps.active_ind=1
   AND ps.pharm_ind=0
  ORDER BY ps.price_sched_desc
  WITH nocounter
 ;end select
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","<HELP AVAILABLE (Shift+F5)>")
 CALL text(24,50,displaystring)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Enter 0 when done.")
 CALL text(p_sched->prompt_row,55,displaystring)
 CALL accept(p_sched->prompt_row,40,"9(10);DS",0)
 IF (curscroll=2)
  CALL clear(p_sched->prompt_row,40,35)
  EXECUTE FROM bc_scheds_prompt TO end_bc_scheds_prompt
 ELSE
  IF (curaccept != 0)
   SET p_sched->count = (p_sched->count+ 1)
   SET sel_sched_id = curaccept
   SET stat = alterlist(p_sched->sched,p_sched->count)
   SET sel_sched_disp = fillstring(40," ")
   SELECT INTO "nl:"
    ps.price_sched_desc
    FROM price_sched ps
    WHERE ps.price_sched_id=sel_sched_id
    DETAIL
     sel_sched_disp = ps.price_sched_desc
    WITH nocounter
   ;end select
   SET p_sched->sched[p_sched->count].sched_cd = sel_sched_id
   SET p_sched->sched[p_sched->count].sched_disp = sel_sched_disp
   CALL display_p_scheds(p_sched->prompt_row,12)
   EXECUTE FROM ps_prompt TO end_ps_prompt
  ENDIF
 ENDIF
 SET help = off
 CALL clear(p_sched->prompt_row,40,35)
 CALL clear(24,1)
#end_ps_prompt
#bi_level_prompt
 FREE SET bill_items
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Choose Level of Bill Items to display")
 CALL text(24,1,displaystring)
 CALL accept(bi_level->prompt_row,40,"9;DS",all_items)
 IF (curscroll=2)
  EXECUTE FROM ps_prompt TO end_ps_prompt
  EXECUTE FROM bi_level_prompt TO end_bi_level_prompt
 ELSE
  SET bi_level->level = curaccept
  CALL clear(bi_level->prompt_row,40,35)
  CALL video(l)
  CALL text(bi_level->prompt_row,40,cnvtstring(bi_level->level))
  CALL video(n)
  CALL clear(24,1)
 ENDIF
#end_bi_level_prompt
#init_cp
 FREE SET charge_proc
 RECORD charge_proc(
   1 cp_qual[*]
     2 bi_id = f8
     2 bim_id = f8
     2 sched_cd = f8
     2 sched_disp = vc
     2 cp_cd = f8
     2 cp_disp = vc
     2 cp_mean = vc
     2 cl_cd = f8
     2 cl_disp = vc
     2 cl_mean = vc
     2 csv_string = vc
     2 bi_seq = i2
 )
#end_init_cp
#init_bc
 FREE SET bill_code
 RECORD bill_code(
   1 bc_qual[*]
     2 bi_id = f8
     2 bim_id = f8
     2 sched_cd = f8
     2 sched_disp = vc
     2 code = vc
     2 desc = vc
     2 priority = i2
     2 csv_string = vc
     2 bi_seq = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
#end_init_bc
#init_ps
 FREE SET price_sched
 RECORD price_sched(
   1 ps_qual[*]
     2 bi_seq = i2
     2 bi_id = f8
     2 psi_id = f8
     2 ps_id = f8
     2 ps_desc = vc
     2 price = f8
     2 csv_string = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
#end_init_ps
 SUBROUTINE display_owner_codes(dummyvar)
   CALL video(l)
   SET start_row = ext_owner->prompt_row
   SET start_col = 12
   SET idx = 0
   IF ((ext_owner->count=0))
    SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","ALL")
    CALL text((start_row+ 1),start_col,displaystring)
   ELSE
    IF ((ext_owner->count < 2))
     SET to_val = ext_owner->count
    ELSE
     SET to_val = ((ext_owner->count/ 2)+ mod(ext_owner->count,2))
    ENDIF
    FOR (x = 1 TO to_val)
     IF (x > 1)
      SET start_col = (start_col+ 25)
     ENDIF
     IF (start_col <= 65)
      FOR (y = 1 TO 2)
        IF ((idx < ext_owner->count))
         SET idx = (idx+ 1)
         SET displaystring = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(ext_owner->qual[idx].
            owner_disp,3)))
         CALL text((start_row+ y),start_col,displaystring)
        ENDIF
      ENDFOR
     ENDIF
    ENDFOR
   ENDIF
   CALL video(n)
 END ;Subroutine
 SUBROUTINE display_cp_scheds(dummyvar)
   CALL video(l)
   SET start_row = cp_sched->prompt_row
   SET start_col = 12
   SET idx = 0
   IF ((cp_sched->count=0))
    SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","ALL")
    CALL text((start_row+ 1),start_col,displaystring)
   ELSE
    IF ((cp_sched->count < 2))
     SET to_val = cp_sched->count
    ELSE
     SET to_val = ((cp_sched->count/ 2)+ mod(cp_sched->count,2))
    ENDIF
    FOR (x = 1 TO to_val)
     IF (x > 1)
      SET start_col = (start_col+ 25)
     ENDIF
     IF (start_col <= 65)
      FOR (y = 1 TO 2)
        IF ((idx < cp_sched->count))
         SET idx = (idx+ 1)
         SET displaystring = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(cp_sched->sched[idx].
            sched_disp,3)))
         CALL text((start_row+ y),start_col,displaystring)
        ENDIF
      ENDFOR
     ENDIF
    ENDFOR
   ENDIF
   CALL video(n)
 END ;Subroutine
 SUBROUTINE display_bc_scheds(dummyvar)
   CALL video(l)
   SET start_row = bc_sched->prompt_row
   SET start_col = 12
   SET idx = 0
   IF ((bc_sched->count=0))
    SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","ALL")
    CALL text((start_row+ 1),start_col,displaystring)
   ELSE
    IF ((bc_sched->count < 2))
     SET to_val = bc_sched->count
    ELSE
     SET to_val = ((bc_sched->count/ 2)+ mod(bc_sched->count,2))
    ENDIF
    FOR (x = 1 TO to_val)
     IF (x > 1)
      SET start_col = (start_col+ 25)
     ENDIF
     IF (start_col <= 65)
      FOR (y = 1 TO 2)
        IF ((idx < bc_sched->count))
         SET idx = (idx+ 1)
         SET displaystring = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(bc_sched->sched[idx].
            sched_disp,3)))
         CALL text((start_row+ y),start_col,displaystring)
        ENDIF
      ENDFOR
     ENDIF
    ENDFOR
   ENDIF
   CALL video(n)
 END ;Subroutine
 SUBROUTINE display_p_scheds(start_row,start_col)
   CALL video(l)
   SET idx = 0
   IF ((p_sched->count=0))
    SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","ALL")
    CALL text((start_row+ 1),start_col,displaystring)
   ELSE
    IF ((p_sched->count < 2))
     SET to_val = p_sched->count
    ELSE
     SET to_val = ((p_sched->count/ 2)+ mod(p_sched->count,2))
    ENDIF
    FOR (x = 1 TO to_val)
     IF (x > 1)
      SET start_col = (start_col+ 25)
     ENDIF
     IF (start_col <= 65)
      FOR (y = 1 TO 2)
        IF ((idx < p_sched->count))
         SET idx = (idx+ 1)
         SET displaystring = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(p_sched->sched[idx].
            sched_disp,3)))
         CALL text((start_row+ y),start_col,displaystring)
        ENDIF
      ENDFOR
     ENDIF
    ENDFOR
   ENDIF
   CALL video(n)
 END ;Subroutine
#create_report
 SET start_dt_tm = cnvtdatetime(curdate,curtime)
 SET line_cnt = 0
 CALL video(b)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Processing...")
 CALL text(24,1,displaystring)
 CALL video(n)
 SET count1 = 0
 IF ((cp_sched->count <= 0))
  CALL clear(24,30)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Reading Charge Point Schedules")
  CALL text(24,30,displaystring)
  SELECT INTO "nl:"
   cv.code_value, cv.display
   FROM code_value cv
   WHERE cv.code_set=14002
    AND cv.cdf_meaning="CHARGE POINT"
    AND cv.active_ind=1
   DETAIL
    count1 = (count1+ 1), stat = alterlist(cp_sched->sched,count1), cp_sched->count = count1,
    cp_sched->sched[count1].sched_cd = cv.code_value, cp_sched->sched[count1].sched_disp = cv.display
   WITH nocounter
  ;end select
 ENDIF
 SET count1 = 0
 IF ((bc_sched->count <= 0))
  CALL clear(24,30)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Reading Bill Code Schedules")
  CALL text(24,30,displaystring)
  SELECT INTO "nl:"
   cv.code_value, cv.display
   FROM code_value cv
   WHERE cv.code_set=14002
    AND cv.cdf_meaning IN ("CDM_SCHED", "CPT4", "GL", "HCPCS", "MODIFIER",
   "PROCCODE", "REVENUE")
    AND cv.active_ind=1
   DETAIL
    count1 = (count1+ 1), stat = alterlist(bc_sched->sched,count1), bc_sched->count = count1,
    bc_sched->sched[count1].sched_cd = cv.code_value, bc_sched->sched[count1].sched_disp = cv.display
   WITH nocounter
  ;end select
 ENDIF
 SET count1 = 0
 IF ((p_sched->count <= 0))
  CALL clear(24,30)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Reading Price Schedules")
  CALL text(24,30,displaystring)
  SELECT INTO "nl:"
   ps.price_sched_id, ps.price_sched_desc
   FROM price_sched ps
   WHERE ps.active_ind=1
    AND ps.pharm_ind=0
   DETAIL
    count1 = (count1+ 1), stat = alterlist(p_sched->sched,count1), p_sched->count = count1,
    p_sched->sched[count1].sched_cd = ps.price_sched_id, p_sched->sched[count1].sched_disp = ps
    .price_sched_desc
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(bill_items->test_ind,999)=999)
  FREE SET bill_items
  RECORD bill_items(
    1 test_ind = i2
    1 bi[*]
      2 bi_id = f8
      2 p_ref_id = f8
      2 p_ref_cd = f8
      2 c_ref_id = f8
      2 c_ref_cd = f8
      2 ext_desc = c100
      2 ext_owner_cd = f8
      2 level = i2
      2 cp_qual = i2
      2 bc_qual = i2
      2 ps_qual = i2
  )
  CALL clear(24,30)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Reading Bill Items")
  CALL text(24,30,displaystring)
  SET count1 = 0
  IF ((((bi_level->level=all_items)) OR ((bi_level->level=parent_child))) )
   FREE SET sorted_parents
   RECORD sorted_parents(
     1 bi[*]
       2 id = f8
       2 ref_id = f8
       2 ref_cd = f8
       2 ext_desc = vc
   )
   SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Getting sorted parents")
   CALL text(24,30,displaystring)
   SELECT
    IF ((ext_owner->count <= 0))INTO "nl:"
     extownercd = b.ext_owner_cd, uc_desc = cnvtupper(substring(1,100,b.ext_description)), b.*
     FROM bill_item b
     WHERE b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id=0
      AND b.active_ind=1
      AND b.ext_owner_cd >= 0
     ORDER BY extownercd, uc_desc
    ELSE INTO "nl:"
     uc_desc = cnvtupper(substring(1,100,b.ext_description)), b.*
     FROM bill_item b
     WHERE b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id=0
      AND b.active_ind=1
      AND (b.ext_owner_cd=ext_owner->qual[1].owner_cd)
     ORDER BY uc_desc
    ENDIF
    DETAIL
     count1 = (count1+ 1), stat = alterlist(sorted_parents->bi,count1), sorted_parents->bi[count1].id
      = b.bill_item_id,
     sorted_parents->bi[count1].ref_id = b.ext_parent_reference_id, sorted_parents->bi[count1].ref_cd
      = b.ext_parent_contributor_cd, sorted_parents->bi[count1].ext_desc = b.ext_description
    WITH nocounter
   ;end select
   SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Getting children for sorted parents")
   CALL text(24,30,displaystring)
   SET count1 = 0
   SELECT INTO "nl:"
    d1.seq, b.*, bi_id = sorted_parents->bi[d1.seq].id,
    bi_desc = sorted_parents->bi[d1.seq].ext_desc, uc_desc = cnvtupper(substring(1,100,b
      .ext_description))
    FROM bill_item b,
     (dummyt d1  WITH seq = value(size(sorted_parents->bi,5)))
    PLAN (d1)
     JOIN (b
     WHERE (b.ext_parent_reference_id=sorted_parents->bi[d1.seq].ref_id)
      AND (b.ext_parent_contributor_cd=sorted_parents->bi[d1.seq].ref_cd)
      AND b.active_ind=1)
    ORDER BY d1.seq, b.ext_parent_reference_id, b.ext_parent_contributor_cd,
     uc_desc
    HEAD d1.seq
     count1 = (count1+ 1), stat = alterlist(bill_items->bi,count1), bill_items->bi[count1].bi_id =
     sorted_parents->bi[d1.seq].id,
     bill_items->bi[count1].p_ref_id = sorted_parents->bi[d1.seq].ref_id, bill_items->bi[count1].
     p_ref_cd = sorted_parents->bi[d1.seq].ref_cd, bill_items->bi[count1].c_ref_id = 0,
     bill_items->bi[count1].c_ref_cd = 0, bill_items->bi[count1].ext_desc =
     IF (trim(sorted_parents->bi[d1.seq].ext_desc,3)="") "<BLANK>"
     ELSE sorted_parents->bi[d1.seq].ext_desc
     ENDIF
     , bill_items->bi[count1].level = 1
    DETAIL
     IF (b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id != 0)
      count1 = (count1+ 1), stat = alterlist(bill_items->bi,count1), bill_items->bi[count1].bi_id = b
      .bill_item_id,
      bill_items->bi[count1].p_ref_id = b.ext_parent_reference_id, bill_items->bi[count1].p_ref_cd =
      b.ext_parent_contributor_cd, bill_items->bi[count1].c_ref_id = b.ext_child_reference_id,
      bill_items->bi[count1].c_ref_cd = b.ext_child_contributor_cd, bill_items->bi[count1].ext_desc
       =
      IF (trim(b.ext_description,3)="") "<BLANK>"
      ELSE b.ext_description
      ENDIF
      , bill_items->bi[count1].level = 2
      IF ((bi_level->level=all_items))
       count1 = (count1+ 1), stat = alterlist(bill_items->bi,count1), bill_items->bi[count1].level =
       3
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   FREE SET sorted_parents
   IF ((ext_owner->count <= 0))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(bill_items->bi,5))),
      bill_item b
     PLAN (d1)
      JOIN (b
      WHERE (b.ext_parent_reference_id=bill_items->bi[d1.seq].c_ref_id)
       AND (b.ext_parent_contributor_cd=bill_items->bi[d1.seq].c_ref_cd)
       AND b.ext_child_contributor_cd=cdalpharesp)
     DETAIL
      count1 = (count1+ 1), stat = alterlist(bill_items->bi,count1), bill_items->bi[count1].bi_id = b
      .bill_item_id,
      bill_items->bi[count1].p_ref_id = b.ext_parent_reference_id, bill_items->bi[count1].p_ref_cd =
      b.ext_parent_contributor_cd, bill_items->bi[count1].c_ref_id = b.ext_child_reference_id,
      bill_items->bi[count1].c_ref_cd = b.ext_child_contributor_cd, bill_items->bi[count1].ext_desc
       =
      IF (trim(b.ext_description,3)="") "<BLANK>"
      ELSE b.ext_description
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ELSE
   SELECT
    IF ((bi_level->level=parent_only)
     AND (ext_owner->count <= 0))INTO "nl:"
     b.*, extownercd = b.ext_owner_cd, uc_desc = cnvtupper(substring(1,100,b.ext_description))
     FROM bill_item b
     WHERE b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id=0
      AND b.active_ind=1
      AND b.ext_owner_cd >= 0
     ORDER BY extownercd, uc_desc, b.ext_parent_reference_id,
      b.ext_parent_contributor_cd
    ELSEIF ((bi_level->level=parent_only))INTO "nl:"
     b.*, uc_desc = cnvtupper(substring(1,100,b.ext_description))
     FROM bill_item b
     WHERE b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id=0
      AND b.active_ind=1
      AND (b.ext_owner_cd=ext_owner->qual[1].owner_cd)
     ORDER BY uc_desc, b.ext_parent_reference_id, b.ext_parent_contributor_cd
    ELSEIF ((bi_level->level=child_only)
     AND (ext_owner->count <= 0))INTO "nl:"
     b.*, extownercd = b.ext_owner_cd, uc_desc = cnvtupper(substring(1,100,b.ext_description))
     FROM bill_item b
     WHERE b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id != 0
      AND b.active_ind=1
      AND b.ext_owner_cd >= 0
     ORDER BY extownercd, uc_desc, b.ext_parent_reference_id,
      b.ext_parent_contributor_cd
    ELSEIF ((bi_level->level=child_only))INTO "nl:"
     b.*, uc_desc = cnvtupper(substring(1,100,b.ext_description))
     FROM bill_item b
     WHERE b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id != 0
      AND b.active_ind=1
      AND (b.ext_owner_cd=ext_owner->qual[1].owner_cd)
     ORDER BY uc_desc, b.ext_parent_reference_id, b.ext_parent_contributor_cd
    ELSEIF ((bi_level->level=default_only))INTO "nl:"
     b.*, uc_desc = cnvtupper(substring(1,100,b.ext_description))
     FROM bill_item b
     WHERE b.ext_parent_reference_id=0
      AND b.ext_child_reference_id != 0
      AND b.active_ind=1
     ORDER BY uc_desc, b.ext_parent_reference_id, b.ext_parent_contributor_cd
    ELSE
    ENDIF
    DETAIL
     count1 = (count1+ 1), stat = alterlist(bill_items->bi,count1), bill_items->bi[count1].bi_id = b
     .bill_item_id,
     bill_items->bi[count1].p_ref_id = b.ext_parent_reference_id, bill_items->bi[count1].p_ref_cd = b
     .ext_parent_contributor_cd, bill_items->bi[count1].c_ref_id = b.ext_child_reference_id,
     bill_items->bi[count1].c_ref_cd = b.ext_child_contributor_cd, bill_items->bi[count1].ext_desc =
     IF (trim(b.ext_description,3)="") "<BLANK>"
     ELSE b.ext_description
     ENDIF
     IF (b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id=0)
      bill_items->bi[count1].level = 1
     ELSEIF (b.ext_parent_reference_id != 0
      AND b.ext_child_reference_id != 0)
      bill_items->bi[count1].level = 2
      IF ((bi_level->level=all_items))
       count1 = (count1+ 1), stat = alterlist(bill_items->bi,count1), bill_items->bi[count1].level =
       3
      ENDIF
     ELSEIF (b.ext_parent_reference_id=0
      AND b.ext_child_reference_id != 0)
      bill_items->bi[count1].level = 3
     ELSE
      bill_items->bi[count1].level = 999
     ENDIF
     CALL text(24,70,cnvtstring(count1))
    WITH nocounter
   ;end select
  ENDIF
  IF ((bi_level->level=all_items))
   SET count1 = 0
   CALL clear(24,30)
   SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Reading Default Bill Items")
   CALL text(24,30,displaystring)
   SELECT INTO "nl:"
    b.*
    FROM bill_item b,
     (dummyt d1  WITH seq = value(size(bill_items->bi,5)))
    PLAN (d1
     WHERE (bill_items->bi[d1.seq].level=2))
     JOIN (b
     WHERE b.ext_parent_reference_id=0
      AND (b.ext_child_reference_id=bill_items->bi[d1.seq].c_ref_id)
      AND (b.ext_child_contributor_cd=bill_items->bi[d1.seq].c_ref_cd)
      AND b.active_ind=1)
    DETAIL
     count1 = (d1.seq+ 1), bill_items->bi[count1].bi_id = b.bill_item_id, bill_items->bi[count1].
     p_ref_id = b.ext_parent_reference_id,
     bill_items->bi[count1].p_ref_cd = b.ext_parent_contributor_cd, bill_items->bi[count1].c_ref_id
      = b.ext_child_reference_id, bill_items->bi[count1].c_ref_cd = b.ext_child_contributor_cd,
     bill_items->bi[count1].ext_desc = b.ext_description,
     CALL text(24,70,cnvtstring(count1))
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   FROM bill_item b,
    (dummyt d1  WITH seq = value(size(bill_items->bi,5)))
   PLAN (d1)
    JOIN (b
    WHERE (b.bill_item_id=bill_items->bi[d1.seq].bi_id))
   DETAIL
    bill_items->bi[d1.seq].ext_owner_cd = b.ext_owner_cd
   WITH nocounter
  ;end select
 ENDIF
 IF (size(charge_proc->cp_qual,5) <= 0)
  CALL clear(24,30)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Getting Charge Processing Information")
  CALL text(24,30,displaystring)
  SET item_count = 0
  FOR (x = 1 TO size(bill_items->bi,5))
   FOR (y = 1 TO cp_sched->count)
     SET item_count = (item_count+ 1)
     SET stat = alterlist(charge_proc->cp_qual,item_count)
     SET charge_proc->cp_qual[item_count].bi_seq = x
     SET charge_proc->cp_qual[item_count].bi_id = bill_items->bi[x].bi_id
     SET charge_proc->cp_qual[item_count].sched_cd = cp_sched->sched[y].sched_cd
     SET charge_proc->cp_qual[item_count].sched_disp = cp_sched->sched[y].sched_disp
     SET charge_proc->cp_qual[item_count].csv_string = concat(",,")
   ENDFOR
   SET bill_items->bi[x].cp_qual = cp_sched->count
  ENDFOR
  SELECT INTO "nl:"
   cv1.display, cv2.display, b.*
   FROM (dummyt d3  WITH seq = value(size(charge_proc->cp_qual,5))),
    bill_item_modifier b,
    code_value cv1,
    code_value cv2
   PLAN (d3
    WHERE (charge_proc->cp_qual[d3.seq].bi_seq > 0))
    JOIN (b
    WHERE (b.bill_item_id=charge_proc->cp_qual[d3.seq].bi_id)
     AND (b.key1_id=charge_proc->cp_qual[d3.seq].sched_cd)
     AND b.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=b.key2_id)
    JOIN (cv2
    WHERE cv2.code_value=b.key4_id)
   DETAIL
    charge_proc->cp_qual[d3.seq].bim_id = b.bill_item_mod_id, charge_proc->cp_qual[d3.seq].cp_cd = b
    .key2_id, charge_proc->cp_qual[d3.seq].cp_disp =
    IF (b.key2_id > 0) cv1.display
    ENDIF
    ,
    charge_proc->cp_qual[d3.seq].cp_mean = cv1.cdf_meaning, charge_proc->cp_qual[d3.seq].cl_cd = b
    .key4_id, charge_proc->cp_qual[d3.seq].cl_disp =
    IF (b.key4_id > 0) cv2.display
    ENDIF
    ,
    charge_proc->cp_qual[d3.seq].cl_mean = cv2.cdf_meaning, charge_proc->cp_qual[d3.seq].csv_string
     = concat(',"',trim(charge_proc->cp_qual[d3.seq].cl_disp,3),'","',trim(charge_proc->cp_qual[d3
      .seq].cp_disp,3),'"')
   WITH nocounter
  ;end select
 ENDIF
 IF (size(bill_code->bc_qual,5) <= 0)
  CALL clear(24,30)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Getting Bill Codes")
  CALL text(24,30,displaystring)
  SET item_count = 0
  FOR (x = 1 TO size(bill_items->bi,5))
   FOR (y = 1 TO bc_sched->count)
     SET item_count = (item_count+ 1)
     SET stat = alterlist(bill_code->bc_qual,item_count)
     SET bill_code->bc_qual[item_count].bi_seq = x
     SET bill_code->bc_qual[item_count].bi_id = bill_items->bi[x].bi_id
     SET bill_code->bc_qual[item_count].sched_cd = bc_sched->sched[y].sched_cd
     SET bill_code->bc_qual[item_count].sched_disp = bc_sched->sched[y].sched_disp
     SET bill_code->bc_qual[item_count].csv_string = ",,,"
   ENDFOR
   SET bill_items->bi[x].bc_qual = bc_sched->count
  ENDFOR
  SET count1 = 0
  SELECT INTO "nl:"
   d2.seq, b.*
   FROM (dummyt d2  WITH seq = value(size(bill_code->bc_qual,5))),
    bill_item_modifier b
   PLAN (d2
    WHERE (bill_code->bc_qual[d2.seq].bi_seq > 0))
    JOIN (b
    WHERE (b.bill_item_id=bill_code->bc_qual[d2.seq].bi_id)
     AND (b.key1_id=bill_code->bc_qual[d2.seq].sched_cd)
     AND b.bim1_int=1
     AND b.active_ind=1)
   DETAIL
    bill_code->bc_qual[d2.seq].bim_id = b.bill_item_mod_id, bill_code->bc_qual[d2.seq].sched_disp =
    bill_code->bc_qual[d2.seq].sched_disp, bill_code->bc_qual[d2.seq].code = b.key6,
    bill_code->bc_qual[d2.seq].desc = b.key7, bill_code->bc_qual[d2.seq].priority = b.bim1_int,
    bill_code->bc_qual[d2.seq].csv_string = concat(',"',trim(bill_code->bc_qual[d2.seq].code,3),'","',
     trim(bill_code->bc_qual[d2.seq].desc,3),'",',
     format(bill_code->bc_qual[d2.seq].priority,"##")),
    CALL text(24,70,cnvtstring(d2.seq)), bill_code->bc_qual[d2.seq].beg_effective_dt_tm = b
    .beg_effective_dt_tm, bill_code->bc_qual[d2.seq].end_effective_dt_tm = b.end_effective_dt_tm
   WITH nocounter
  ;end select
 ENDIF
 IF (size(price_sched->ps_qual,5) <= 0)
  CALL clear(24,30)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Getting Prices")
  CALL text(24,30,displaystring)
  SET item_count = 0
  FOR (x = 1 TO size(bill_items->bi,5))
   FOR (y = 1 TO p_sched->count)
     SET item_count = (item_count+ 1)
     SET stat = alterlist(price_sched->ps_qual,item_count)
     SET price_sched->ps_qual[item_count].bi_seq = x
     SET price_sched->ps_qual[item_count].bi_id = bill_items->bi[x].bi_id
     SET price_sched->ps_qual[item_count].ps_id = p_sched->sched[y].sched_cd
     SET price_sched->ps_qual[item_count].ps_desc = p_sched->sched[y].sched_disp
     SET price_sched->ps_qual[item_count].csv_string = ","
   ENDFOR
   SET bill_items->bi[x].ps_qual = p_sched->count
  ENDFOR
  SELECT INTO "nl:"
   psi.price_sched_items_id, psi.price
   FROM price_sched_items psi,
    (dummyt d1  WITH seq = value(size(price_sched->ps_qual,5)))
   PLAN (d1
    WHERE (price_sched->ps_qual[d1.seq].bi_seq > 0))
    JOIN (psi
    WHERE (psi.bill_item_id=price_sched->ps_qual[d1.seq].bi_id)
     AND (psi.price_sched_id=price_sched->ps_qual[d1.seq].ps_id)
     AND psi.active_ind=1
     AND cnvtdatetime(curdate,curtime2) BETWEEN psi.beg_effective_dt_tm AND psi.end_effective_dt_tm)
   DETAIL
    price_sched->ps_qual[d1.seq].psi_id = psi.price_sched_items_id, price_sched->ps_qual[d1.seq].
    price = psi.price, price_sched->ps_qual[d1.seq].csv_string = concat(',"',format(price_sched->
      ps_qual[d1.seq].price,"######.##"),'"'),
    price_sched->ps_qual[d1.seq].beg_effective_dt_tm = psi.beg_effective_dt_tm, price_sched->ps_qual[
    d1.seq].end_effective_dt_tm = psi.end_effective_dt_tm
   WITH nocounter
  ;end select
 ENDIF
 IF (findstring(".",file->file_name,1,1)=0)
  CALL clear(24,30)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Preparing Report")
  CALL text(24,30,displaystring)
  SET sub_header_col = 20
  SET data_beg_col = (sub_header_col+ 20)
  SET sline = fillstring(115,"=")
  SET hdrchargeprocessing = uar_i18ngetmessage(i18nhandle,"k1","Charge Processing:")
  SET hdrbillcodes = uar_i18ngetmessage(i18nhandle,"k1","Bill Codes:")
  SET hdrpriceschedules = uar_i18ngetmessage(i18nhandle,"k1","Price Schedules:")
  SET dtlunknowntype = uar_i18ngetmessage(i18nhandle,"k1"," Unknown Type")
  SELECT INTO value(file->file_name)
   d1.seq, d2.seq, d4.seq,
   d5.seq, bi_id = bill_items->bi[d1.seq].bi_id, desc = substring(1,50,bill_items->bi[d1.seq].
    ext_desc),
   cp_bim_id = charge_proc->cp_qual[d2.seq].bim_id, sched_disp = substring(1,20,charge_proc->cp_qual[
    d2.seq].sched_disp), cl_disp = substring(1,10,charge_proc->cp_qual[d2.seq].cl_disp),
   cp_disp = substring(1,10,charge_proc->cp_qual[d2.seq].cp_disp), bim_id = charge_proc->cp_qual[d2
   .seq].bim_id, bc_bim_id = bill_code->bc_qual[d4.seq].bim_id,
   bc_begdt = format(bill_code->bc_qual[d4.seq].beg_effective_dt_tm,"dd/mmm/yyyy;;d"), bc_enddt =
   format(bill_code->bc_qual[d4.seq].end_effective_dt_tm,"dd/mmm/yyyy;;d"), bc_sched_disp = substring
   (1,20,bill_code->bc_qual[d4.seq].sched_disp),
   bc_code = substring(1,20,bill_code->bc_qual[d4.seq].code), bc_desc = substring(1,20,bill_code->
    bc_qual[d4.seq].desc), priority = bill_code->bc_qual[d4.seq].priority,
   ps_desc = substring(1,20,price_sched->ps_qual[d5.seq].ps_desc), ps_begdt = format(price_sched->
    ps_qual[d5.seq].beg_effective_dt_tm,"dd/mmm/yyyy;;d"), ps_enddt = format(price_sched->ps_qual[d5
    .seq].end_effective_dt_tm,"dd/mmm/yyyy;;d"),
   price = price_sched->ps_qual[d5.seq].price, psi_id = price_sched->ps_qual[d5.seq].psi_id
   FROM (dummyt d1  WITH seq = value(size(bill_items->bi,5))),
    (dummyt d2  WITH seq = value(size(charge_proc->cp_qual,5))),
    (dummyt d4  WITH seq = value(size(bill_code->bc_qual,5))),
    (dummyt d5  WITH seq = value(size(price_sched->ps_qual,5)))
   PLAN (d1
    WHERE (bill_items->bi[d1.seq].bi_id != 0))
    JOIN (d2
    WHERE (charge_proc->cp_qual[d2.seq].bi_seq=d1.seq))
    JOIN (d4
    WHERE (bill_code->bc_qual[d4.seq].bi_seq=d1.seq))
    JOIN (d5
    WHERE (price_sched->ps_qual[d5.seq].bi_seq=d1.seq))
   ORDER BY d1.seq, d2.seq, d4.seq
   HEAD d1.seq
    cp_count = 0, bc_count = 0, ps_count = 0
    IF (debug_mode=1)
     col 05, bi_id"##########"
    ENDIF
    dtlbiname = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(desc)))
    IF ((bill_items->bi[d1.seq].p_ref_id != 0)
     AND (bill_items->bi[d1.seq].c_ref_id=0))
     col 00, sline, row + 1,
     line_cnt = (line_cnt+ 1), col 5, dtlbiname
    ELSEIF ((bill_items->bi[d1.seq].p_ref_id != 0)
     AND (bill_items->bi[d1.seq].c_ref_id != 0))
     col 10, dtlbiname
    ELSEIF ((bill_items->bi[d1.seq].p_ref_id=0)
     AND (bill_items->bi[d1.seq].c_ref_id != 0))
     col 15, dtlbiname
    ELSE
     col 5, dtlbiname, dtlunknowntype
    ENDIF
    row + 1, line_cnt = (line_cnt+ 1),
    CALL text(24,50,concat(format(d1.seq,"#######")," of ",format(size(bill_items->bi,5),"#######")))
   HEAD d2.seq
    IF (cp_count=0)
     col sub_header_col, hdrchargeprocessing
    ENDIF
    cp_count = (cp_count+ 1)
    IF (debug_mode=1)
     call reportmove('COL',(data_beg_col - 25),0), d2.seq"#####", call reportmove('COL',(data_beg_col
      - 11),0),
     bim_id"##########"
    ENDIF
    dtlcpname = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(sched_disp))), col data_beg_col,
    dtlcpname"##################",
    dtlchargelevel = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(cl_disp))), call reportmove(
    'COL',(data_beg_col+ 21),0), dtlchargelevel"##########",
    dtlchargepoint = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(cp_disp))), call reportmove(
    'COL',(data_beg_col+ 32),0), dtlchargepoint"############################",
    row + 1, line_cnt = (line_cnt+ 1)
   HEAD d4.seq
    IF ((cp_count=bill_items->bi[d1.seq].cp_qual))
     IF (bc_count=0)
      row + 1, line_cnt = (line_cnt+ 1), col sub_header_col,
      hdrbillcodes, row + 1
     ENDIF
     bc_count = (bc_count+ 1)
     IF (debug_mode=1)
      call reportmove('COL',(data_beg_col - 25),0), d4.seq"#####", call reportmove('COL',(
      data_beg_col - 11),0),
      bim_id"##########"
     ENDIF
     call reportmove('COL',(data_beg_col - 25),0), bc_begdt, call reportmove('COL',(data_beg_col - 13
     ),0),
     bc_enddt, dtlbcname = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(bc_sched_disp))), col
     data_beg_col,
     dtlbcname"##################", call reportmove('COL',(data_beg_col+ 21),0), bc_code"##########",
     dtlbcdesc = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(bc_desc))), call reportmove('COL',(
     data_beg_col+ 32),0), dtlbcdesc"##############################",
     call reportmove('COL',(data_beg_col+ 66),0), bill_code->bc_qual[d4.seq].priority"#########", row
      + 1,
     line_cnt = (line_cnt+ 1)
    ENDIF
   DETAIL
    IF ((bc_count=bill_items->bi[d1.seq].bc_qual))
     IF (ps_count=0)
      row + 1, col sub_header_col, hdrpriceschedules
     ENDIF
     ps_count = (ps_count+ 1)
     IF (debug_mode=1)
      call reportmove('COL',(data_beg_col - 25),0), d5.seq"#####", call reportmove('COL',(
      data_beg_col - 11),0),
      psi_id"##########"
     ENDIF
     dtlpsname = uar_i18ngetmessage(i18nhandle,"k1",nullterm(trim(ps_desc))), col data_beg_col,
     dtlpsname,
     call reportmove('COL',(data_beg_col+ 21),0), ps_begdt, call reportmove('COL',(data_beg_col+ 33)
     ,0),
     ps_enddt, call reportmove('COL',(data_beg_col+ 65),0), price"#######.##",
     row + 1, line_cnt = (line_cnt+ 1)
    ENDIF
    end_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter, compress, nolandscape,
    maxrow = 60, maxcol = 132
  ;end select
  EXECUTE FROM finished_box TO end_finished_box
 ELSE
  SET max_len = 0
  FREE SET csv
  RECORD csv(
    1 line[*]
      2 csv_string = vc
  )
  SET stat = alterlist(csv->line,(size(bill_items->bi,5)+ 2))
  SET csv->line[1].csv_string = concat('"Bill_item_id"',",",'"Parent_reference_id"',",",
   '"Child_reference_id"',
   ",",'"Bill Item"',",",'"Activity Type"')
  SET csv->line[2].csv_string = concat('" "',",",'" "',",",'" "',
   ",",'"Description"',",",'" "')
  CALL clear(24,30)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Moving Bill Items")
  CALL text(24,30,displaystring)
  SELECT INTO "nl:"
   d1.seq, bi_desc = trim(bill_items->bi[d1.seq].ext_desc,3), bi_seq = d1.seq
   FROM (dummyt d1  WITH seq = value(size(bill_items->bi,5)))
   ORDER BY d1.seq
   DETAIL
    csv->line[(d1.seq+ 2)].csv_string =
    IF (debug_mode=1) concat(cnvtstring(bill_items->bi[d1.seq].bi_id,17,2),",",cnvtstring(bill_items
       ->bi[d1.seq].p_ref_id,17,2),",",cnvtstring(bill_items->bi[d1.seq].p_ref_cd,17,2),
      ",",cnvtstring(bill_items->bi[d1.seq].c_ref_id,17,2),",",cnvtstring(bill_items->bi[d1.seq].
       c_ref_cd,17,2),",",
      '"',trim(bi_desc,3),'"',",",'"',
      trim(uar_get_code_display(bill_items->bi[d1.seq].ext_owner_cd),3),'"')
    ELSE concat(cnvtstring(bill_items->bi[d1.seq].bi_id,17,2),",",cnvtstring(bill_items->bi[d1.seq].
       p_ref_id,17,2),",",cnvtstring(bill_items->bi[d1.seq].c_ref_id,17,2),
      ",",'"',trim(bi_desc,3),'"',",",
      '"',trim(uar_get_code_display(bill_items->bi[d1.seq].ext_owner_cd),3),'"')
    ENDIF
   WITH nocounter
  ;end select
  FREE SET bill_items
  CALL clear(24,30)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Flattening Charge Points")
  CALL text(24,30,displaystring)
  SET last_sch = 0
  SELECT INTO "nl:"
   csv_string = charge_proc->cp_qual[d1.seq].csv_string, head_string = charge_proc->cp_qual[d1.seq].
   sched_disp, bi_seq = charge_proc->cp_qual[d1.seq].bi_seq
   FROM (dummyt d1  WITH seq = value(size(charge_proc->cp_qual,5)))
   DETAIL
    IF ((last_sch != charge_proc->cp_qual[d1.seq].sched_cd)
     AND bi_seq=1)
     last_sch = charge_proc->cp_qual[d1.seq].sched_cd, csv->line[1].csv_string = concat(trim(csv->
       line[1].csv_string,3),',"',trim(charge_proc->cp_qual[d1.seq].sched_disp,3),'",'), csv->line[2]
     .csv_string = concat(trim(csv->line[2].csv_string,3),',"Charge Level","Charge Point"')
    ENDIF
    csv->line[(bi_seq+ 2)].csv_string = concat(trim(csv->line[(bi_seq+ 2)].csv_string,3),trim(
      charge_proc->cp_qual[d1.seq].csv_string,3))
   WITH nocounter
  ;end select
  EXECUTE FROM init_cp TO end_init_cp
  CALL clear(24,30)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Flattening Bill Codes")
  CALL text(24,30,displaystring)
  SET last_sch = 0
  SELECT INTO "nl:"
   csv_string = bill_code->bc_qual[d1.seq].csv_string, head_string = bill_code->bc_qual[d1.seq].
   sched_disp, bi_seq = bill_code->bc_qual[d1.seq].bi_seq
   FROM (dummyt d1  WITH seq = value(size(bill_code->bc_qual,5)))
   DETAIL
    IF ((last_sch != bill_code->bc_qual[d1.seq].sched_cd)
     AND bi_seq=1)
     last_sch = bill_code->bc_qual[d1.seq].sched_cd, csv->line[1].csv_string = concat(trim(csv->line[
       1].csv_string,3),',"',trim(bill_code->bc_qual[d1.seq].sched_disp,3),'",,'), csv->line[2].
     csv_string = concat(trim(csv->line[2].csv_string,3),',"Code","Description","Priority"')
    ENDIF
    csv->line[(bi_seq+ 2)].csv_string = concat(trim(csv->line[(bi_seq+ 2)].csv_string,3),trim(
      bill_code->bc_qual[d1.seq].csv_string,3))
   WITH nocounter
  ;end select
  EXECUTE FROM init_bc TO end_init_bc
  CALL clear(24,30)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Flattening Prices")
  CALL text(24,30,displaystring)
  SET last_sch = 0
  SELECT INTO "nl:"
   csv_string = price_sched->ps_qual[d1.seq].csv_string, head_string = price_sched->ps_qual[d1.seq].
   ps_desc, bi_seq = price_sched->ps_qual[d1.seq].bi_seq
   FROM (dummyt d1  WITH seq = value(size(price_sched->ps_qual,5)))
   DETAIL
    IF ((last_sch != price_sched->ps_qual[d1.seq].ps_id)
     AND bi_seq=1)
     last_sch = price_sched->ps_qual[d1.seq].ps_id, csv->line[1].csv_string = concat(trim(csv->line[1
       ].csv_string,3),',"',trim(price_sched->ps_qual[d1.seq].ps_desc,3),'"'), csv->line[2].
     csv_string = concat(trim(csv->line[2].csv_string,3),',"Price"')
    ENDIF
    csv->line[(bi_seq+ 2)].csv_string = concat(trim(csv->line[(bi_seq+ 2)].csv_string,3),trim(
      price_sched->ps_qual[d1.seq].csv_string,3))
   WITH nocounter
  ;end select
  EXECUTE FROM init_ps TO end_init_ps
  CALL clear(24,1)
  SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Creating")
  CALL text(24,30,concat(displaystring," ",file->file_name))
  SET temp_len = 0
  FOR (x = 1 TO size(csv->line,5))
    IF (x > 2)
     SET csv->line[x].csv_string = concat(csv->line[x].csv_string,",",cnvtstring(x),",")
    ELSEIF (x=1)
     SET csv->line[x].csv_string = concat(csv->line[x].csv_string,',"Sequence",')
    ELSEIF (x=2)
     SET csv->line[x].csv_string = concat(csv->line[x].csv_string,",,")
    ENDIF
    SET temp_len = size(trim(csv->line[x].csv_string,3))
    IF (temp_len > max_len)
     SET max_len = (temp_len+ 1)
    ENDIF
  ENDFOR
  FOR (x = size(csv->line[1].csv_string) TO max_len)
    SET csv->line[1].csv_string = concat(csv->line[1].csv_string,"+")
  ENDFOR
  SET total_rec = size(csv->line,5)
  SELECT INTO value(file->file_name)
   d2.seq, csv_line = csv->line[d2.seq].csv_string
   FROM (dummyt d2  WITH seq = value(total_rec))
   PLAN (d2)
   ORDER BY d2.seq
   DETAIL
    col 00, csv_line, row + 1
    IF (mod(d2.seq,100)=1)
     CALL text(24,1,concat(format(d2.seq,"999999")," of ",format(total_rec,"999999")))
    ENDIF
    line_cnt = (line_cnt+ 1)
   WITH nocounter, noformfeed, maxcol = value((max_len+ 4)),
    format = variable
  ;end select
  SET end_dt_tm = cnvtdatetime(curdate,curtime3)
  EXECUTE FROM finished_box TO end_finished_box
 ENDIF
#end_create_report
#finished_box
 CALL clear(1,1)
 CALL box(6,20,18,60)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Finished.")
 CALL text(7,21,displaystring)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Started:")
 CALL text(9,25,concat(displaystring,"   ",format(start_dt_tm,"hh:mm:ss;;s")))
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Finished:")
 CALL text(10,25,concat(displaystring,"  ",format(end_dt_tm,"hh:mm:ss;;s")))
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Line Count: ")
 CALL text(12,25,concat(displaystring,"  ",format(line_cnt,"##########")))
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Continue?  (Y/N)")
 CALL text(17,21,displaystring)
 CALL accept(17,37,"P;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  GO TO end_prog
 ELSE
  EXECUTE FROM initialize_structs TO end_initialize_structs
  GO TO menu
 ENDIF
#end_finished_box
 GO TO end_prog
#end_prog
 CALL clear(1,1)
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Started: ")
 CALL text(1,1,concat(displaystring,format(start_dt_tm,"hh:mm:ss;;s")))
 SET displaystring = uar_i18ngetmessage(i18nhandle,"k1","Finished: ")
 CALL text(2,1,concat(displaystring,format(end_dt_tm,"hh:mm:ss;;s")))
 FREE SET cp_sched
 FREE SET bc_sched
 FREE SET p_sched
 FREE SET bill_items
 FREE SET ext_owner
 FREE SET file
 FREE SET charge_proc
 FREE SET bill_code
 FREE SET price_sched
 FREE SET bi_level
END GO
