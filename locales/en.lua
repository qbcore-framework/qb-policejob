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
       vehicle_cuff = "You cant cuff someone in a vehicle",
       
    },
    success = {
    },
    info = {
        blood_clear = 'Blood cleared :)',
        bullet_sleeve_remove = 'Bullet sleeves removed :)',
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