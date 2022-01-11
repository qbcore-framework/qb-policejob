local Translations = {
    error = {
       no_camera = "Camera doesn\'t exist..",
       current_status_list = ''..CurrentStatusList[statusId].text..'',
       blood_not_cleared = 'Blood not cleared..',
       bullet_sleeve_not_remove = 'Bullet sleeves not removed',
       none_nearby = "No one nearby!",
       canceled = "Canceled..",
       time_higher = "Time must be higher than 0..",
       price_higher = "Price must be higher than 0..",
       vehicle_cuff = "You can\'t cuff someone in a vehicle",
       no_cuff = "You don\'t have handcuffs on you",
       no_impound = "There are no impounded vehicles",
       no_spikestripe = 'There are no Spikestrips left..',
       error_license = "Invalid license type",
       rank_license = "You must be a Sergeant to grant licenses!",
       revoked_license = "You've had a license revoked",
       rank_revoke = "You must be a Sergeant to revoke licenses!",
       on_duty_police_only = 'For on-duty police only',
       vehicle_not_flag = 'Vehicle not flagged',
       not_towdriver = 'Not a tow truck driver',
       not_lawyer = 'Person is not a lawyer',
       no_anklet = 'This person doesn\'t have an anklet on.',
       have_evidence_bag = "You must have an empty evidence bag with you",
       unimpound_vehicle = "Vehicle unimpounded!",
       anklet_taken_off = 'Your anklet is taken off.',
       took_anklet_from = 'You took off an ankle bracelet from ' .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname .."",
       put_anklet = 'You put on an ankle strap.',
       put_anklet_on = 'You put on an ankle strap to ' .. Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname .. "",
       no_driver_license = 'No drivers license',
       not_cuffed_dead = "Civilian isn't cuffed or dead"

       
    },
    success = {
        uncuffed = "You are uncuffed!",
        grated_license = "You have been granted a license",
        grant_license = "You granted a license",
        revoke_license = "You revoked a license",
        tow_paid = 'You were paid $500',
    },
    info = {
        blood_clear = 'Blood cleared :)',
        bullet_sleeve_remove = 'Bullet sleeves removed :)',
        cuff = "You are cuffed!",
        cuffed_walk = "You are cuffed, but you can walk",
        dont_know_var = ''..v..'',
        vehicle_flagged = "Vehicle (" .. args[1]:upper() .. ") is flagged for: " .. table.concat(reason, " "),
        unflag_vehicle = "Vehicle (" .. args[1]:upper() .. ") is unflagged",
        tow_driver_paid = 'You paid the tow truck driver',
        paid_lawyer = 'You paid a lawyer',
        vehicle_taken_depot = "Vehicle taken into depot for $" .. price .. "!",
        vehicle_seized = "Vehicle seized",
        stolen_money = "You have stolen $" .. money .."",
        robbed_off = "You have been robbed of $" .. money .."",
        driving_license_confiscated = 'Your driving license has been confiscated',
        cash_confiscated = 'Your cash was confiscated',
        beign_searched = "You are being searched",
        cash_found = 'Found $'..SearchedPlayer.PlayerData.money["cash"]..' on the civilian',
        sent_jail_for = "You sent the person to prison for " .. time .. " months",
        fine_received = "You received a fine of $" .. price .. "",
    },
    general = {
    },
    options = {
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})