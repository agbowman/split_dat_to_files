CREATE PROGRAM cpmstartup_esitrace:dba
 EXECUTE cpmstartup_esidbg
 CALL trace(1)
END GO
