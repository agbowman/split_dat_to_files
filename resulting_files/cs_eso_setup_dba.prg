CREATE PROGRAM cs_eso_setup:dba
 SET trace = recpersist
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 FREE SET trigger
 RECORD trigger(
   1 trigger_id = f8
   1 class = vc
   1 stype = vc
   1 subtype = vc
   1 scp_binding = c128
   1 request_nbr = i4
   1 processing_control = i4
 )
 FREE SET routine
 RECORD routine(
   1 routine_id = f8
   1 routine = vc
   1 script = vc
   1 description = vc
   1 args_default = vc
   1 args_help = vc
 )
 SUBROUTINE add_trigger(dummy)
   FREE SET request
   RECORD request(
     1 eso_trigger_qual = i2
     1 eso_trigger[1]
       2 trigger_id = f8
       2 class = c15
       2 stype = c15
       2 subtype = c15
       2 subtype_detail = c15
       2 scp_binding = c128
       2 request_nbr = i4
       2 processing_control = i4
   )
   SET found = false
   SELECT INTO "nl:"
    t.seq
    FROM eso_trigger t
    PLAN (t
     WHERE cnvtupper(t.class)=cnvtupper(trigger->class)
      AND cnvtupper(t.type)=cnvtupper(trigger->stype)
      AND cnvtupper(t.subtype)=cnvtupper(trigger->subtype))
    DETAIL
     found = true
    WITH nocounter
   ;end select
   IF (found=false)
    SET request->eso_trigger_qual = 1
    SET request->eso_trigger[1].class = trigger->class
    SET request->eso_trigger[1].stype = trigger->stype
    SET request->eso_trigger[1].subtype = trigger->subtype
    SET request->eso_trigger[1].scp_binding = trigger->scp_binding
    SET request->eso_trigger[1].request_nbr = trigger->request_nbr
    SET request->eso_trigger[1].processing_control = trigger->processing_control
    EXECUTE eso_add_trigger
    FREE SET reply
   ENDIF
   FREE SET request
 END ;Subroutine
 SUBROUTINE add_routine(dummy)
   FREE SET request
   RECORD request(
     1 eso_routine_qual = i2
     1 eso_routine[1]
       2 routine_id = f8
       2 routine = c50
       2 script = c50
       2 description = c255
       2 args_default = c255
       2 args_help = c255
   )
   SET found = false
   SELECT INTO "nl:"
    r.seq
    FROM eso_routine r
    PLAN (r
     WHERE cnvtupper(r.routine)=cnvtupper(routine->routine)
      AND cnvtupper(r.script)=cnvtupper(routine->script))
    DETAIL
     found = true
    WITH nocounter
   ;end select
   IF (found=false)
    SET request->eso_routine_qual = 1
    SET request->eso_routine[1].routine = routine->routine
    SET request->eso_routine[1].script = routine->script
    SET request->eso_routine[1].description = routine->description
    SET request->eso_routine[1].args_default = routine->args_default
    SET request->eso_routine[1].args_help = routine->args_help
    EXECUTE eso_add_routine
    FREE SET reply
   ENDIF
   FREE SET request
 END ;Subroutine
 SUBROUTINE add_relation(class,type,subtype,script,seq)
   FREE SET request
   RECORD request(
     1 eso_trig_routine_r_qual = i2
     1 eso_trig_routine_r[1]
       2 trigger_id = f8
       2 routine_id = f8
       2 sequence_nbr = i4
       2 routine_args = c255
       2 routine_control = i4
       2 debug_ind_ind = i2
       2 debug_ind = i2
       2 verbosity_flag_ind = i2
       2 verbosity_flag = i2
   )
   SET trigger_id = 0
   SELECT INTO "nl:"
    t.seq
    FROM eso_trigger t
    PLAN (t
     WHERE cnvtupper(t.class)=cnvtupper(class)
      AND cnvtupper(t.type)=cnvtupper(type)
      AND cnvtupper(t.subtype)=cnvtupper(subtype))
    DETAIL
     trigger_id = t.trigger_id
    WITH nocounter
   ;end select
   SET routine_id = 0
   SELECT INTO "nl:"
    r.seq
    FROM eso_routine r
    PLAN (r
     WHERE cnvtupper(r.script)=cnvtupper(script))
    DETAIL
     routine_id = r.routine_id
    WITH nocounter
   ;end select
   IF (trigger_id > 0
    AND routine_id > 0)
    SELECT INTO "nl:"
     r.seq
     FROM eso_trig_routine_r r
     PLAN (r
      WHERE r.trigger_id=trigger_id
       AND r.routine_id=routine_id)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET request->eso_trig_routine_r_qual = 1
     SET request->eso_trig_routine_r[1].trigger_id = trigger_id
     SET request->eso_trig_routine_r[1].routine_id = routine_id
     SET request->eso_trig_routine_r[1].sequence_nbr = seq
     SET request->eso_trig_routine_r[1].debug_ind = 0
     SET request->eso_trig_routine_r[1].verbosity_flag = 0
     SET request->eso_trig_routine_r[1].routine_args = ""
     SET request->eso_trig_routine_r[1].routine_control = 0
     EXECUTE eso_add_trig_r
     FREE SET reply
    ENDIF
   ENDIF
   FREE SET request
 END ;Subroutine
 SET true = 1
 SET false = 0
 SET reqinfo->updt_id = 1
 SET reqinfo->updt_app = 1
 SET reqinfo->updt_task = 1
 SET trigger->stype = "FT1"
 SET trigger->subtype = "BEGIN"
 SET trigger->class = "CHARGE"
 SET trigger->scp_binding = ""
 SET trigger->request_nbr = 1202303
 SET trigger->processing_control = 1057
 CALL add_trigger(1)
 SET trigger->stype = "FT1"
 SET trigger->subtype = "HEADER"
 SET trigger->class = "CHARGE"
 SET trigger->scp_binding = ""
 SET trigger->request_nbr = 1202303
 SET trigger->processing_control = 1057
 CALL add_trigger(1)
 SET trigger->stype = "FT1"
 SET trigger->subtype = "DETAIL"
 SET trigger->class = "CHARGE"
 SET trigger->scp_binding = ""
 SET trigger->request_nbr = 1202303
 SET trigger->processing_control = 1057
 CALL add_trigger(1)
 SET trigger->stype = "FT1"
 SET trigger->subtype = "TRAILER"
 SET trigger->class = "CHARGE"
 SET trigger->scp_binding = ""
 SET trigger->request_nbr = 1202303
 SET trigger->processing_control = 1057
 CALL add_trigger(1)
 SET trigger->stype = "FT1"
 SET trigger->subtype = "END"
 SET trigger->class = "CHARGE"
 SET trigger->scp_binding = ""
 SET trigger->request_nbr = 1202303
 SET trigger->processing_control = 1057
 CALL add_trigger(1)
 SET routine->routine = "generic_script_use_ctx"
 SET routine->script = "CS_ESO_MSH"
 SET routine->description = "HL7 MSH Segment"
 SET routine->args_default = ""
 SET routine->args_help = ""
 CALL add_routine(1)
 SET routine->routine = "generic_script_use_ctx"
 SET routine->script = "CS_ESO_EVN"
 SET routine->description = "HL7 EVN Segment"
 SET routine->args_default = ""
 SET routine->args_help = ""
 CALL add_routine(1)
 SET routine->routine = "generic_script_use_ctx"
 SET routine->script = "CS_ESO_FT1"
 SET routine->description = "HL7 FT1 Segment"
 SET routine->args_default = ""
 SET routine->args_help = ""
 CALL add_routine(1)
 SET routine->routine = "generic_script_use_ctx"
 SET routine->script = "FSI_PID_COMMON"
 SET routine->description =
 "This script populates the PID segment by using the person_id and encntr_id "
 SET routine->description = concat(trim(routine->description,3),
  "passed in through the ESOINFO structure.")
 SET routine->args_default = ""
 SET routine->args_help = ""
 CALL add_routine(1)
 SET routine->routine = "generic_script_use_ctx"
 SET routine->script = "FSI_PV1_COMMON"
 SET routine->description =
 "This script populates the PV1 segment by using the person_id and encntr_id "
 SET routine->description = concat(trim(routine->description,3),
  "passed in through the ESOINFO structure.")
 SET routine->args_default = ""
 SET routine->args_help = ""
 CALL add_routine(1)
 CALL add_relation("CHARGE","FT1","BEGIN","CS_ESO_MSH",1)
 CALL add_relation("CHARGE","FT1","HEADER","CS_ESO_MSH",1)
 CALL add_relation("CHARGE","FT1","DETAIL","CS_ESO_MSH",1)
 CALL add_relation("CHARGE","FT1","DETAIL","CS_ESO_EVN",2)
 CALL add_relation("CHARGE","FT1","DETAIL","FSI_PID_COMMON",3)
 CALL add_relation("CHARGE","FT1","DETAIL","FSI_PV1_COMMON",4)
 CALL add_relation("CHARGE","FT1","DETAIL","CS_ESO_FT1",5)
 CALL add_relation("CHARGE","FT1","TRAILER","CS_ESO_MSH",1)
 CALL add_relation("CHARGE","FT1","END","CS_ESO_MSH",1)
#9999_end
 SET trace = norecpersist
END GO
