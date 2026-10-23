state("LiveSplit") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/emu-help-v3")).CreateInstance("PS2");

    // Level order of the splits
    vars.levels = new byte[] { 2, 3, 5, 1, 4, 6, 10, 9, 8, 7, 12, 11, 14, 18, 17, 15, 16, 13, 24, 21, 22, 20, 19, 23 };

    // Level -> position in the split order
    vars.levelPos = new Dictionary<byte, int>();
    for (int i = 0; i < vars.levels.Length; i++)
        vars.levelPos[vars.levels[i]] = i;

    // Address of the disc ID ("SLxS_xxx.xx;1") in EE memory, per version
    vars.IdAddressPal = 0x4C234CUL;
    vars.IdAddressUs  = 0x4C20CCUL;

    vars.validRace = false;   // Current level matches the expected split
    vars.raceActive = false;  // Expected race has actually started (latch)
    vars.missed = 0;          // Splits skipped by the primary system
    vars.lastIdx = -1;
    vars.lastDbg = "";
}

update
{
    // emu-help-v3 bug: ReadString reads twice the requested length.
    // The IDs are 11 chars, so we ask for 6 (= 12 chars) and only compare the first 11.
    string idPal = vars.Helper.ReadString(6, vars.IdAddressPal) ?? "";
    string idUs  = vars.Helper.ReadString(6, vars.IdAddressUs) ?? "";

    // Detect game version from the disc ID
    vars.VersionOffset = idPal.StartsWith("SLES_500.77") ? 0x280  // PAL
                       : idUs.StartsWith("SLUS_201.53")  ? 0x0    // NTSC-U
                       : -1;

    if (vars.VersionOffset == -1)
    {
        // Print only when the value read changes, to keep the log readable
        string dbg = "PAL='" + idPal + "' US='" + idUs + "'";

        if (vars.lastDbg != dbg)
        {
            print("[RCRP] Game ID not recognized: " + dbg);
            vars.lastDbg = dbg;
        }

        return false;
    }

    current.loading   = vars.Helper.Read<bool>((ulong)(0x327E84 + vars.VersionOffset));
    current.status    = vars.Helper.Read<byte>((ulong)(0x1ED900 + vars.VersionOffset));
    current.level     = vars.Helper.Read<byte>((ulong)(0x1EDC4A + vars.VersionOffset));
    current.raceType  = vars.Helper.Read<uint>((ulong)(0x1EDC4C + vars.VersionOffset));
    current.cupRaceNo = vars.Helper.Read<byte>((ulong)(0x1EDC49 + vars.VersionOffset));

    // The timer's split index is the source of truth (safe with undo/skip)
    int idx = timer.CurrentSplitIndex;
    if (idx < 0)
        idx = 0;

    // New split: reset the race state
    if (idx != vars.lastIdx)
    {
        vars.raceActive = false;
        vars.lastIdx = idx;
    }

    bool raceOk = current.raceType == 0x100001FA;
    byte[] levels = vars.levels;

    vars.validRace = idx < levels.Length
        && current.level == levels[idx]
        && raceOk;

    // Latch: the expected race has really started
    if (vars.validRace && (current.status & 1) != 0)
        vars.raceActive = true;

    // Recovery: a level further ahead than expected means missed splits
    int pos = 0;
    vars.missed = 0;

    if (raceOk
        && !current.loading
        && vars.levelPos.TryGetValue(current.level, out pos)
        && pos > idx)
    {
        vars.missed = pos - idx;
    }

    return true;
}

start
{
    return current.level == 2
        && current.cupRaceNo == 0
        && (current.status & 1) != 0
        && current.raceType == 0x100001FA;
}

onStart
{
    vars.raceActive = false;
    vars.lastIdx = 0;
}

onReset
{
    vars.raceActive = false;
    vars.lastIdx = -1;
}

split
{
    // Primary: rising edge of the finish bit, only if the race had started
    if (vars.validRace
        && vars.raceActive
        && (current.status & 32) != 0
        && (old.status & 32) == 0)
    {
        return true;
    }

    // Recovery: catch up one split per tick until aligned
    return vars.missed > 0;
}

reset
{
    return vars.validRace
        && old.status == 1
        && current.status == 4;
}

isLoading
{
    return current.loading == true;
}
