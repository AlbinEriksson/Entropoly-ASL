state("Entropoly", "Not supported") {
    string32 obj_gameManager_level_to_load : 0x0;
    int obj_bed_Count : 0x0;
    double obj_bed_ypos : 0x0;
    double obj_bed_activated : 0x0;

    float obj_player_y : 0x0;

    double obj_saveManager_current_save_file : 0x0;

    ulong obj_level_portal_tetra_Iter : 0x0;
    ulong obj_level_portal_cube_Iter : 0x0;
    ulong obj_level_portal_octa_Iter : 0x0;
    ulong obj_level_portal_icosa_Iter : 0x0;
    ulong obj_level_portal_dodeca_Iter : 0x0;

    double obj_finish_tetra_exiting : 0x0;
    double obj_finish_cube_exiting : 0x0;
    double obj_finish_octa_exiting : 0x0;
    double obj_finish_icosa_exiting : 0x0;
    double obj_finish_dodeca_exiting : 0x0;
}

state("Entropoly", "1.0.2") {
    string32 obj_gameManager_level_to_load : 0x132ace8, 0x0, 0x2f0, 0x18, 0x50, 0x10, 0x48, 0x10, 0x210, 0x0, 0x0, 0x0;

    int obj_bed_Count : 0x132ace8, 0x0, 0x5a0, 0x18, 0x60;
    double obj_bed_ypos : 0x132ace8, 0x0, 0x5a0, 0x18, 0x50, 0x10, 0x48, 0x10, 0x110, 0x0;
    double obj_bed_activated : 0x132ace8, 0x0, 0x5a0, 0x18, 0x50, 0x10, 0x48, 0x10, 0x20, 0x0;

    float obj_player_y : 0x132ace8, 0x0, 0x5e0, 0x18, 0x50, 0x10, 0xec;

    double obj_saveManager_current_save_file : 0x132ace8, 0x0, 0x610, 0x18, 0x50, 0x10, 0x48, 0x10, 0x1a0, 0x0;

    ulong obj_level_portal_tetra_Iter : 0x132ace8, 0x0, 0x790, 0x18, 0x50;
    ulong obj_level_portal_cube_Iter : 0x132ace8, 0x0, 0x7a0, 0x18, 0x50;
    ulong obj_level_portal_octa_Iter : 0x132ace8, 0x0, 0x7b0, 0x18, 0x50;
    ulong obj_level_portal_icosa_Iter : 0x132ace8, 0x0, 0x7c0, 0x18, 0x50;
    ulong obj_level_portal_dodeca_Iter : 0x132ace8, 0x0, 0x7d0, 0x18, 0x50;

    double obj_finish_tetra_exiting : 0x132ace8, 0x0, 0x740, 0x18, 0x50, 0x10, 0x48, 0x10, 0x6b0, 0x0;
    double obj_finish_cube_exiting : 0x132ace8, 0x0, 0x750, 0x18, 0x50, 0x10, 0x48, 0x10, 0x6b0, 0x0;
    double obj_finish_octa_exiting : 0x132ace8, 0x0, 0x760, 0x18, 0x50, 0x10, 0x48, 0x10, 0x6b0, 0x0;
    double obj_finish_icosa_exiting : 0x132ace8, 0x0, 0x770, 0x18, 0x50, 0x10, 0x48, 0x10, 0x6b0, 0x0;
    double obj_finish_dodeca_exiting : 0x132ace8, 0x0, 0x780, 0x18, 0x50, 0x10, 0x48, 0x10, 0x6b0, 0x0;
}

init {
    int moduleSize = modules.First().ModuleMemorySize;
    vars.Debug("Module size: " + moduleSize);
    if (moduleSize == 23105536) {
        version = "1.0.2";
    } else {
        version = "Not supported";
        vars.Debug("Unknown version!");
        return;
    }
    vars.Debug("Version detected: " + version);
}

startup {
    settings.Add("AutoStart", true, "Start timer when selecting a save file");
    settings.Add("AutoReset", false, "Reset timer when quitting to main menu");
    settings.Add("SplitHub", true, "Split when entering a level hub");
    settings.Add("SplitDomain", false, "Split when entering the Domain of Hearts");
    settings.Add("SplitCrossroads", false, "Split when entering Crossroads");
    settings.Add("SplitTouchPortal", false, "Split when touching a level portal");
    settings.Add("SplitTouchFinish", true, "Split when touching a level finish");
    settings.Add("SplitEnterLevel", false, "Split when pressing 'Enter' after touching a level portal");
    settings.Add("SplitContinueToHub", false, "Split when pressing 'Continue' after finishing a level");
    settings.Add("SplitIntroPortals", false, "Split when touching an intro portal");

    Func<string, bool> IsHub = (hubName) => {
        return (
            hubName == "earthhub" ||
            hubName == "airhub" ||
            hubName == "waterhub" ||
            hubName == "firehub" ||
            hubName == "mindhub" ||
            hubName == "hearthub"
        );
    };
    vars.IsHub = IsHub;

    Func<string, bool> IsRealm = (realmName) => {
        return (
            realmName == "earth" ||
            realmName == "air" ||
            realmName == "water" ||
            realmName == "fire" ||
            realmName == "mind" ||
            realmName == "heart"
        );
    };

    Func<string, Tuple<string, int>> GetRealmAndLevel = (levelName) => {
        if (levelName == null) return null;
        int levelStringIndex = levelName.IndexOfAny("0123456789".ToCharArray());
        if (levelStringIndex < 0) return null;

        string realm = levelName.Substring(0, levelStringIndex);
        string levelString = levelName.Substring(levelStringIndex);
        int level;
        try {
            level = Int32.Parse(levelString);
        } catch {
            return null;
        }

        return new Tuple<string, int>(realm, level);
    };
    vars.GetRealmAndLevel = GetRealmAndLevel;

    Func<string, bool> IsLevel = (levelName) => {
        var realmLevel = vars.GetRealmAndLevel(levelName);
        if (realmLevel == null) return false;

        string realm = realmLevel.Item1;
        int level = realmLevel.Item2;
        if (!IsRealm(realm)) return false;

        return level >= 0 && level <= 7;
    };
    vars.IsLevel = IsLevel;

    Func<string, bool> IsIntro = (levelName) => {
        var realmLevel = vars.GetRealmAndLevel(levelName);
        if (realmLevel == null) return false;

        string realm = realmLevel.Item1;
        int level = realmLevel.Item2;
        if (realm != "intro") return false;

        return level >= 0 && level <= 4;
    };
    vars.IsIntro = IsIntro;

    vars.UpdatesSinceTouchedBed = 999;
    vars.OldUpdatesSinceTouchedBed = 999;
    vars.UpdatesSinceRoomChange = 999;

    vars.TouchedLevelPortal = false;
    vars.OldTouchedLevelPortal = false;
    vars.TouchedLevelFinish = false;
    vars.OldTouchedLevelFinish = false;
    Func<ulong, Process, Process, bool> IsEnteringPortal = (iter, _game, _memory) => {
        var iterPtr = new IntPtr((Int64)iter);
        while (iterPtr != IntPtr.Zero) {
            var pointer = new DeepPointer(iterPtr + 0x10, 0x48, 0x10, 0x6a0, 0x0);
            double exiting = pointer.Deref<double>(_game);
            if (exiting == 1) {
                return true;
            }
            iterPtr = _memory.ReadPointer(iterPtr);
        }
        return false;
    };
    vars.IsEnteringPortal = IsEnteringPortal;

    Action<string> Debug = (text) => {
        print("[ENTROPOLY Autosplitter] " + text);
    };
    vars.Debug = Debug;
    vars.Debug("Initialized!");
}

start {
    if (
        settings["AutoStart"] &&
        old.obj_saveManager_current_save_file == -1 &&
        current.obj_saveManager_current_save_file >= 0
    ) {
        vars.Debug("Starting timer.");
        return true;
    }

    return false;
}

reset {
    vars.Debug(vars.UpdatesSinceTouchedBed + "");
    if (
        settings["AutoReset"] && 
        old.obj_saveManager_current_save_file >= 0 &&
        current.obj_saveManager_current_save_file == -1 &&
        vars.UpdatesSinceTouchedBed > 100
    ) {
        vars.Debug("Resetting timer.");
        return true;
    }

    return false;
}

update {
    // Scuffed method to check whether Poly is standing on the bed
    vars.OldUpdatesSinceTouchedBed = vars.UpdatesSinceTouchedBed;
    vars.UpdatesSinceTouchedBed += 1;
    if (
        current.obj_bed_Count == 1 &&
        current.obj_bed_activated == 1 &&
        Math.Abs(current.obj_bed_ypos - current.obj_player_y) < 0.001 && (
            current.obj_gameManager_level_to_load == "domain of hearts" ||
            current.obj_gameManager_level_to_load == "hearthub"
        )
    ) {
        vars.UpdatesSinceTouchedBed = 0;
    }

    vars.OldTouchedLevelPortal = vars.TouchedLevelPortal;
    vars.TouchedLevelPortal = false;
    if (settings["SplitTouchPortal"]) {
        vars.TouchedLevelPortal |= vars.IsEnteringPortal(current.obj_level_portal_tetra_Iter, game, memory);
        vars.TouchedLevelPortal |= vars.IsEnteringPortal(current.obj_level_portal_cube_Iter, game, memory);
        vars.TouchedLevelPortal |= vars.IsEnteringPortal(current.obj_level_portal_octa_Iter, game, memory);
        vars.TouchedLevelPortal |= vars.IsEnteringPortal(current.obj_level_portal_icosa_Iter, game, memory);
        vars.TouchedLevelPortal |= vars.IsEnteringPortal(current.obj_level_portal_dodeca_Iter, game, memory);
    }

    vars.OldTouchedLevelFinish = vars.TouchedLevelFinish;
    vars.TouchedLevelFinish = false;
    if (settings["SplitTouchFinish"] || settings["SplitIntroPortals"]) {
        vars.TouchedLevelFinish |= current.obj_finish_tetra_exiting == 1;
        vars.TouchedLevelFinish |= current.obj_finish_cube_exiting == 1;
        vars.TouchedLevelFinish |= current.obj_finish_octa_exiting == 1;
        vars.TouchedLevelFinish |= current.obj_finish_icosa_exiting == 1;
        vars.TouchedLevelFinish |= current.obj_finish_dodeca_exiting == 1;
    }

    vars.UpdatesSinceRoomChange += 1;
    if (old.obj_gameManager_level_to_load != current.obj_gameManager_level_to_load) {
        vars.UpdatesSinceRoomChange = 0;
    }
}

split {
    if (
        vars.UpdatesSinceTouchedBed == 0 &&
        vars.OldUpdatesSinceTouchedBed > 100
    ) {
        vars.Debug("Touched bed.");
        return true;
    } else if (
        settings["SplitHub"] &&
        old.obj_gameManager_level_to_load == "crossroads" &&
        vars.IsHub(current.obj_gameManager_level_to_load)
    ) {
        vars.Debug("Entered level hub.");
        return true;
    } else if (
        settings["SplitDomain"] &&
        old.obj_gameManager_level_to_load == "crossroads" &&
        current.obj_gameManager_level_to_load == "domain of hearts"
    ) {
        vars.Debug("Entered Domain of Hearts.");
        return true;
    } else if (
        settings["SplitCrossroads"] &&
        old.obj_gameManager_level_to_load != "crossroads" &&
        current.obj_gameManager_level_to_load == "crossroads" &&
        !vars.IsIntro(old.obj_gameManager_level_to_load)
    ) {
        vars.Debug("Entered Crossroads.");
        return true;
    } else if (
        settings["SplitTouchPortal"] &&
        vars.TouchedLevelPortal &&
        !vars.OldTouchedLevelPortal &&
        vars.UpdatesSinceRoomChange > 100
    ) {
        vars.Debug("Touched a portal.");
        return true;
    } else if (
        settings["SplitTouchFinish"] &&
        vars.TouchedLevelFinish &&
        !vars.OldTouchedLevelFinish &&
        vars.IsLevel(current.obj_gameManager_level_to_load)
    ) {
        vars.Debug("Touched a finish.");
        return true;
    } else if (
        settings["SplitEnterLevel"] && (
            vars.IsHub(old.obj_gameManager_level_to_load) ||
            old.obj_gameManager_level_to_load == "domain of hearts"
        ) && vars.IsLevel(current.obj_gameManager_level_to_load)
    ) {
        vars.Debug("Entered a level.");
        return true;
    } else if (
        settings["SplitContinueToHub"] &&
        vars.IsLevel(old.obj_gameManager_level_to_load) && (
            vars.IsHub(current.obj_gameManager_level_to_load) ||
            current.obj_gameManager_level_to_load == "domain of hearts"
        )
    ) {
        vars.Debug("Continued to hub.");
        return true;
    } else if (
        settings["SplitIntroPortals"] &&
        vars.TouchedLevelFinish &&
        !vars.OldTouchedLevelFinish &&
        vars.IsIntro(current.obj_gameManager_level_to_load)
    ) {
        vars.Debug("Touched an intro portal.");
        return true;
    }
    return false;
}