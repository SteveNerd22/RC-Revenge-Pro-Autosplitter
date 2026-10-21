state("LiveSplit") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/emu-help-v3")).CreateInstance("PS2");

    vars.levels = new byte[] { 2, 3, 5, 1, 4, 6, 10, 9, 8, 7, 12, 11, 14, 18, 17, 15, 16, 13, 24, 21, 22, 20, 19, 23 };
    vars.splitCount = 0;
    vars.validRace = false;
}

update
{
    vars.VersionOffset = vars.Helper.ReadString(7, 0x1ED140) == "RC Revenge Pro"
        ? 0x280 // Offset for the PAL version
        : vars.Helper.ReadString(7, 0x1ECEC0) == "RC Revenge Pro"
        ? 0x0
        : -1;

    if (vars.VersionOffset == -1)
        return false;

    current.loading = vars.Helper.Read<bool>((ulong)(0x327E84 + vars.VersionOffset));
    current.status = vars.Helper.Read<byte>((ulong)(0x1ED900 + vars.VersionOffset));
    current.level = vars.Helper.Read<byte>((ulong)(0x1EDC4A + vars.VersionOffset));
    current.raceType = vars.Helper.Read<uint>((ulong)(0x1EDC4C + vars.VersionOffset));
    current.cupRaceNo = vars.Helper.Read<byte>((ulong)(0x1EDC49 + vars.VersionOffset));

    int idx = vars.splitCount;
    byte[] levels = vars.levels;
    vars.validRace = idx < levels.Length
        && current.level == levels[idx]
        && current.raceType == 0x100001FA;

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
    vars.splitCount = 0;
}

split
{
    return vars.validRace
        && (current.status & 32) != 0 && (old.status & 32) == 0;
}

reset
{
    return vars.validRace
        && old.status == 1 && current.status == 4;
}

isLoading
{
    return current.loading == true;
}