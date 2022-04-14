# qb-policejob

Added different departments for Police Job.

Easy to install, added SASP and BCSO

# HOW TO INSTALL

    1) For scripts which check for the job "police" also add a check for "bcso" and "sasp"

    2) In QB-Management added boss menus for BCSO and SASP.
    qb-management/client/cl_config.lua add the code below.
    Config.BossMenus = {
    ['police'] = {
        vector3(462.11, -985.55, 30.73),
    },
    ['bcso'] = {
        vector3(1834.39, 3677.0, 38.87),
    },
    ['sasp'] = {
        vector3(624.81, 8.12, 84.39),
    },



    Config.BossMenuZones = {
    ['police'] = {
        { coords = vector3(462.11, -985.55, 30.73), length = 1.0, width = 1.0, heading = 351.0, minZ = 29, maxZ = 31 } ,
    },
    ['bcso'] = {
        { coords = vector3(1834.39, 3677.0, 38.87), length = 1.0, width = 1.0, heading = 351.0, minZ = 37, maxZ = 39 } ,
    },
    ['sasp'] = {
        { coords = vector3(624.81, 8.12, 84.39), length = 1.0, width = 1.0, heading = 351.0, minZ = 83, maxZ = 85 } ,
    },
    
    
    3) Run the SQL

    INSERT INTO `management_funds` (`job_name`, `amount`, `type`) VALUES
    ('bcso', 0, 'boss'),
    ('sasp', 0, 'boss');
