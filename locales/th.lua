local Translations = {
    error = {
        license_already = 'พลเรือนมีใบอนุญาตอยู่แล้ว',
        error_license = 'พลเรือนไม่มีใบอนุญาตนั้นอยู่',
        no_camera = 'ไม่มีกล้องตัวนี้',
        blood_not_cleared = 'ยังไม่ฟอกเลือด',
        bullet_casing_not_removed = 'ยังไม่ถอดปลอกกระสุน',
        none_nearby = 'ไม่มีใครอยู่ใกล้ๆ !',
        canceled = 'ยกเลิกแล้ว..',
        time_higher = 'ระยะเวลาต้องมากกว่า 0',
        amount_higher = 'จำนวนต้องมากกว่า 0',
        vehicle_cuff = 'คุณไม่สามารถมัดใครไว้ในรถได้',
        no_cuff = 'คุณไม่มีกุญแจมือ',
        no_impound = 'ไม่มียานพาหนะที่ถูกยึด',
        no_spikestripe = 'ไม่สามารถวางแถบลวดหนามได้อีก',
        error_license_type = 'ประเภทใบอนุญาติไม่ถูกต้อง',
        rank_license = 'คุณมีตำแหน่งไม่สูงพอที่จะให้ใบอนุญาต',
        revoked_license = 'คุณถูกเพิกถอนใบอนุญาต',
        rank_revoke = 'คุณมีตำแหน่งไม่สูงพอที่จะเพิกถอนใบอนุญาต',
        on_duty_police_only = 'สำหรับตำรวจที่เข้าเวรอยู่เท่านั้น',
        vehicle_not_flag = 'รถไม่มีข้อหา',
        not_towdriver = 'ไม่ใช่คนขับรถบรรทุกพ่วง',
        not_lawyer = 'บุคคลนี้ไม่ใช่ทนายความ',
        no_anklet = 'คนนี้ไม่มีกำไลติดตามที่ข้อเท้า',
        have_evidence_bag = 'คุณต้องมีกระเป๋าหลักฐานที่ว่างเปล่า',
        no_driver_license = 'ไม่มีใบอนุญาตขับขี่',
        not_cuffed_dead = 'พลเรือนไม่ได้ถูกใส่กุญแจมือหรือตาย',
    },
    success = {
        uncuffed = 'คุณได้รับการปลดกุญแจมือ',
        granted_license = 'คุณได้รับใบอนุญาต',
        grant_license = 'รับใบอนุญาต',
        revoke_license = 'คุณถูกเพิงถอนใบอนุญาต',
        tow_paid = 'คุณได้รับเงิน $500',
        blood_clear = 'ฟอกเลือดแล้ว',
        bullet_casing_removed = 'ถอดปลอกกระสุนแล้ว...',
        anklet_taken_off = 'ตัวติดตามข้อเท้าของคุณถูกถอดออก.',
        took_anklet_from = 'คุณเอาที่ติดตามออกจาก %{firstname} %{lastname}',
        put_anklet = 'คุณใส่กำลังติดตามที่ข้อเท้า.',
        put_anklet_on = 'คุณใส่กำลังติดตามที่ข้อเท้าของ %{firstname} %{lastname}',
        vehicle_flagged = 'ยานพาหนะทะเบียน %{plate} ถูกตั้งข้อหา %{reason}',
        impound_vehicle_removed = 'นำยานพาหนะออกจากการกักกัน!',
        impounded = 'ยานพาหนะถูกยึด',
 },
    info = {
        mr = 'นาย',
        mrs = 'นางสาว',
        impound_price = 'ราคาที่ผู้เล่นจ่ายเพื่อนำรถออกจากการกักกัน (can be 0)',
        plate_number = 'ทะเบียนรถ',
        flag_reason = 'เหตผลสำหรับข้อหาของยานพาหนะ',
        camera_id = 'เลขกล้อง',
        callsign_name = 'ชื่อเล่น',
        poobject_object = 'วัตถุที่จะวางหรือลบ',
        player_id = 'ไอดีของผู้เล่น',
        citizen_id = 'เลขบัตรประจำตัวประชาชนของผู้เล่น',
        dna_sample = 'ตัวอย่างพันธุกรรม',
        jail_time = 'ถึงเวลาต้องติดคุก',
        jail_time_no = 'ระยะเวลาติดคุกต้องมากกว่า 0',
        license_type = 'ประเภทใบอนุญาต (ขับรถ/อาวุธ)',
        ankle_location = 'ตำแหน่งของที่ติดตามข้อเท้า',
        cuff = 'คุณถูกใส่กุญแจมือ!',
        cuffed_walk = 'คุณถูกใส่กุญแจมือ แต่ยังสามารถเดินได้',
        vehicle_flagged = 'ยานพาหนะ %{vehicle} ถูกต้องข้อหาสำหรับ: %{reason}',
        unflag_vehicle = 'ยานพาหนะ %{vehicle} ถูกลบข้อหา',
        tow_driver_paid = 'คุณจ่ายเงินให้คนขับรถบรรทุกพ่วง',
        paid_lawyer = 'คุณจ่ายเงินให้ทนายความ',
        vehicle_taken_depot = 'ยานพาหนะถูกนำเข้าคลังในราคา $%{price}',
        vehicle_seized = 'ยึดยานพาหนะ',
        stolen_money = 'คุณได้ขโมยเงิน $%{stolen}',
        cash_robbed = 'คุณถูกปล้นเป็นเงิน $%{money}',
        driving_license_confiscated = 'ใบขับขี่ของคุณถูกยึด',
        cash_confiscated = 'เงินสดของคุณถูกยึด',
        being_searched = 'คุณกำลังถูกตรวจค้น',
        cash_found = 'พบเงิน $%{cash} อยู่กับพลเรือน',
        sent_jail_for = 'คุณส่งพลเรือนเข้าคุกเป็นเวลา %{time} เดือน',
        fine_received = 'คุณได้รับค่าปรับเป็นจำนวน $%{fine}',
        blip_text = 'การแจ้งเตือนของตำรวจ - %{value}',
        jail_time_input = 'ระยะเวลาติดคุก',
        submit = 'ส่ง',
        time_months = 'เวลาใน 1 เดือน',
        bill = 'บิล',
        amount = 'จำนวน',
        police_plate = 'LSPD', --Should only be 4 characters long
        vehicle_info = 'เครื่องยนต์: %{value} % | น้ำมัน: %{value2} %',
        evidence_stash = 'หลักฐานที่รวบรวมไว้ | %{value}',
        slot = 'เลขที่ช่อง. (1,2,3)',
        current_evidence = '%{value} | ลิ้นชัก %{value2}',
        on_duty = '[E] - เข้าเวร',
        off_duty = '[E] - ออกเวร',
        onoff_duty = '~g~เข้า~s~/~r~ออก~s~ เวร',
        stash = 'รวบรวม %{value}',
        delete_spike = '[~r~E~s~] เอาแถบลวดหนามออก',
        close_camera = 'ปิดกล้อง',
        bullet_casing = '[~g~G~s~] ปลอกกระสุน %{value}',
        casing = 'ปลอกกระสุน',
        blood = 'เลือด',
        blood_text = '[~g~G~s~] เลือด %{value}',
        fingerprint_text = '[G] ลายนิ้วมือ',
        fingerprint = 'ลายนิ้วมือ',
        store_heli = '[E] เก็บเฮลิคอปเตอร์',
        take_heli = '[E] เรียกเฮลิคอปเตอร์',
        impound_veh = '[E] - ยึดยานพาหนะ',
        store_veh = '[E] - เก็บยานพาหนะ',
        armory = 'คลังอาวุธ',
        enter_armory = '[E] เข้าคลังอาวุธ',
        finger_scan = 'ตรวจหารอยนิ้วมือ',
        scan_fingerprint = '[E] ตรวจหารอยนิ้วมือ',
        trash = 'ขยะ',
        trash_enter = '[E] ถังขยะ',
        stash_enter = '[E] เข้าล็อคเกอร์',
        target_location = 'ตำแหน่งของ %{firstname} %{lastname} แสดงอยู่บนแผนที่',
        anklet_location = 'ตำแหน่งกำไลข้อเท้า',
        new_call = 'โทร',
        officer_down = 'เจ้าหน้าที่ %{lastname} | %{callsign} กองอยู่ที่พื้นละ'
    },
    evidence = {
        red_hands = 'มือแดง',
        wide_pupils = 'รูม่านตาขยาย',
        red_eyes = 'ตาแดง',
        weed_smell = 'กลิ่นเหมือนยาสูบ',
        gunpowder = 'มีดินปืนอยู่ในชุด',
        chemicals = 'กลิ่นสารเคมี',
        heavy_breathing = 'หายใจแรง',
        sweat = 'เหงื่อออกมาก',
        handbleed = 'มีเลือดออกที่มือ',
        confused = 'ยุ่งเหยิง / สับสน',
        alcohol = 'กลิ่นเหมือนแอลกอฮอล์',
        heavy_alcohol = 'กลิ่นเหมือนแอลกอฮอล์สุดๆ',
        agitated = 'กระสับกระสาย - เป็นสัญญานของการใช้ยาบ้า',
        serial_not_visible = 'Serial number ไม่ปรากฏ...',
    },
    menu = {
        garage_title = 'ยาพาหนะตำรวจ',
        close = '⬅ ปิดเมนู',
        impound = 'ยึดยานพาหนะ',
        pol_impound = 'ตำรวจยึด',
        pol_garage = 'โรงรถตำรวจ',
        pol_armory = 'คลังอาวุธตำรวจ',
    },
    email = {
        sender = 'หน่วยงานจัดเก็บกลางภายใต้ศาลตุลาการ',
        subject = 'ใบแจ้หนี้',
        message = 'เรียน %{value}. %{value2}, <br /><br />หน่วยงานจัดเก็บกลางภายใต้ศาลตุลากา เรียกเก็บค่าปรับที่คุณได้รับใบสั่งจากตำรวจ.<br />จำนวนเงิน <strong>$%{value3}</strong> จะถูกถอนออกจากบัญชีของคุณ.<br /><br />ขอแสดงความนับถือ,<br />นาย วรพล ศาลเตี้ย',
    },
    commands = {
        place_spike = 'วางแถบลวดหนาม (ตำรวจเท่านั้น)',
        license_grant = 'ให้ใบอนุญาตแก่บุคคล',
        license_revoke = 'ถอนใบอนุญาตจากบุคคล',
        place_object = 'วาง/ลบ วัตถุ (ตำรวจเท่านั้น)',
        cuff_player = 'ใส่กุญแจมือผู้เล่น (ตำรวจเท่านั้น)',
        escort = 'คุ้มกันผู้เล่น',
        callsign = 'ตั้งชื่อเล่นของคุณ',
        clear_casign = 'เคลียร์ปลอกกระสุนในพื้นที่ (ตำรวจเท่านั้น)',
        jail_player = 'นำผู้เล่นเข้าคุก (ตำรวจเท่านั้น)',
        unjail_player = 'นำผู้เล่นออกจากคุก (ตำรวจเท่านั้น)',
        clearblood = 'เคลียร์เลือดในพื้นที่ (ตำรวจเท่านั้น)',
        seizecash = 'ยึดเงินสด (ตำรวจเท่านั้น)',
        softcuff = 'ใส่กุญแจมือผู้เล่นแบบไม่เข้มงวด (ตำรวจเท่านั้น)',
        camera = 'ดูกล้องวงจรปิด (ตำรวจเท่านั้น)',
        flagplate = 'ตั้งข้อหาทะเบียนรถ (ตำรวจเท่านั้น)',
        unflagplate = 'ถอนข้อหาทะเบียนรถ (ตำรวจเท่านั้น)',
        plateinfo = 'ดูข้อมูลทะเบียนรถ (ตำรวจเท่านั้น)',
        depot = 'ยึดและตั้งราคา (ตำรวจเท่านั้น)',
        impound = 'ยึดยานพาหนะ (ตำรวจเท่านั้น)',
        paytow = 'จ่ายเงินคนขับรถบรรทุก (ตำรวจเท่านั้น)',
        paylawyer = 'จ่ายเงินทนาย (ตำรวจหรือผู้พิพากษาเท่านั้น)',
        anklet = 'ติดเครื่องติดตามที่ข้อเท้า (ตำรวจเท่านั้น)',
        ankletlocation = 'หาตำแหน่งของบุคคลจากกำลังข้อเท้า',
        removeanklet = 'ถอดกำไลติดตามข้อเท้า (ตำรวจเท่านั้น)',
        drivinglicense = 'ยึดใบขับขี่ (ตำรวจเท่านั้น)',
        takedna = 'เก็บตัวอย่างพันธุกรรมจากผู้เล่น (จำเป็นต้องใช้ถุงหลักฐานเปล่า) (ตำรวจเท่านั้น)',
        police_report = 'รายงานของตำรวจ',
        message_sent = 'ข้อความที่จะส่ง',
        civilian_call = 'โทรหาพลเรือน',
        emergency_call = 'โทรหา 911',
    },
    progressbar = {
        blood_clear = 'กำลังฟอกเลือด...',
        bullet_casing = 'กำลังถอดปลอกกระสุนออก..',
        robbing = 'กำลังปล้น...',
        place_object = 'กำลังวางวัตถุ..',
        remove_object = 'ลบวัตถุ..',
        impound = 'กำลังยึดยานพาหนะ..',
    },
}

if GetConvar('qb_locale', 'en') == 'th' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
