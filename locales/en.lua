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

       
    },
    success = {
        uncuffed = "You are uncuffed!",
        grated_license = "You have been granted a license",
        grant_license = "You granted a license",
        revoke_license = "You revoked a license",
    },
    info = {
        blood_clear = 'Blood cleared :)',
        bullet_sleeve_remove = 'Bullet sleeves removed :)',
        cuff = "You are cuffed!",
        cuffed_walk = "You are cuffed, but you can walk",
        dont_know_var = ''..v..'',
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