local Translations = {
    error = {
        license_already = 'プレイヤーは既に免許を所持しています。',
        error_license = 'プレイヤーはその免許証を所持していません。',
        no_camera = 'カメラが存在しません。',
        blood_not_cleared = '血はクリアできていません。',
        bullet_casing_not_removed = '弾薬を補充できていません。',
        none_nearby = '近くに誰もいません。',
        canceled = 'キャンセルされました。',
        time_higher = '時間は0より大きい必要があります',
        amount_higher = '金額は0より大きい必要があります',
        vehicle_cuff = '車両の中では逮捕できません。',
        no_cuff = 'あなたは手錠を所持していません。',
        no_impound = '押収車両保管庫に車両はありません。',
        no_spikestripe = 'これ以上スパイクベルトを設置できません。',
        error_license_type = '無効な免許証です。',
        rank_license = '免許証を交付するための階級が足りません。',
        revoked_license = '免許証が剥奪されました。',
        rank_revoke = '免許証を剥奪するための階級が足りません。',
        on_duty_police_only = '出勤中の警察官のみ可能です。',
        vehicle_not_flag = '車両に不備はありません。',
        not_towdriver = 'レッカー車の運転手ではありません。',
        not_lawyer = '弁護士ではありません。',
        no_anklet = 'この人は監視用GPSを装着していません。',
        have_evidence_bag = '空の証拠袋を携帯する必要があります。',
        no_driver_license = '運転免許証がありません。',
        not_cuffed_dead = '市民は逮捕または死亡していません。',
        fine_yourself = '自身を罰することはできません。',
        not_online = "この人はオフラインです。"
    },
    success = {
        uncuffed = '手錠が外されました。',
        granted_license = '免許証が交付されました。',
        grant_license = '免許証を交付しました。',
        revoke_license = '免許証を剥奪しました。',
        tow_paid = '$500を支払いました。',
        blood_clear = '血をクリアしました。',
        bullet_casing_removed = '弾薬を補充中',
        anklet_taken_off = '監視用GPSが外されました。',
        took_anklet_from = '%{firstname} %{lastname}の監視用GPSを外しました。',
        put_anklet = '監視用GPSが装着されました。',
        put_anklet_on = '%{firstname} %{lastname}に監視用GPSを装着させました。',
        vehicle_flagged = '車両ナンバー %{plate} は %{reason} の不備があります。',
        impound_vehicle_removed = '車両が押収車両保管庫から出庫されました。',
        impounded = '車両を押収車両保管庫に保管しました。',
 },
    info = {
        mr = 'Mr.',
        mrs = 'Mrs.',
        impound_price = 'プレイヤーが押収車両保管庫から車両を出庫するために必要な金額 (0の場合もあります)',
        plate_number = '車両のナンバープレート',
        flag_reason = '車両の不備',
        camera_id = 'カメラID',
        callsign_name = 'あなたのコールサイン',
        poobject_object = '生成するオブジェクトまたは「delete」で削除',
        player_id = 'プレイヤーID',
        citizen_id = 'プレイヤーの市民ID',
        dna_sample = 'DNAサンプル',
        jail_time = '刑務所に投獄される時間',
        jail_time_no = '投獄時間は0より大きい必要があります。',
        license_type = '免許証の種類 (運転/武器)',
        ankle_location = '監視用GPSの場所',
        cuff = '逮捕されました!',
        cuffed_walk = '逮捕されましたが、歩くことは可能です。',
        vehicle_flagged = '車両 %{vehicle} は %{reason} の不備があります。',
        unflag_vehicle = '車両 %{vehicle} の不備はありません。',
        tow_driver_paid = 'レッカー車に支払いました。',
        paid_lawyer = '弁護士に支払いました。',
        vehicle_taken_depot = '車両は$%{price}で引き取られました。',
        vehicle_seized = '車両は押収されました。',
        stolen_money = 'あなたは$%{stolen}を盗みました',
        cash_robbed = 'あなたは$%{money}を盗まれました。',
        driving_license_confiscated = 'あなたの運転免許証は没収されました。',
        cash_confiscated = 'あなたの現金は没収されました。',
        being_searched = '所持品検査中',
        cash_found = '$%{cash}が市民から見つかりました。',
        sent_jail_for = '対象者を%{time}ヶ月投獄しました。',
        fine_received = '$%{fine}の罰金を受けました。',
        blip_text = '110番通報 - %{value}',
        jail_time_input = '投獄時間',
        submit = '送信',
        time_months = '月単位の時間',
        bill = '明細書',
        amount = '金額',
        police_plate = 'LSPD', --Should only be 4 characters long
        vehicle_info = 'エンジン: %{value}% | ガソリン: %{value2}%',
        evidence_stash = '証拠の隠し場所 | %{value}',
        slot = 'スロット番号 (1,2,3)',
        current_evidence = '%{value} | 引き出し %{value2}',
        on_duty = '[E] - 出勤する',
        off_duty = '[E] - 退勤する',
        onoff_duty = '~g~出勤~s~/~r~退勤~s~',
        stash = '隠し場所 %{value}',
        delete_spike = '[~r~E~s~] スパイクベルト削除',
        close_camera = 'カメラを閉じる',
        bullet_casing = '[~g~G~s~] 薬莢 %{value}',
        casing = '薬莢',
        blood = '血',
        blood_text = '[~g~G~s~] 血 %{value}',
        fingerprint_text = '[G] 指紋',
        fingerprint = '指紋',
        store_heli = '[E] ヘリコプターを格納',
        take_heli = '[E] ヘリコプターを出庫',
        impound_veh = '[E] - 車両を押収',
        store_veh = '[E] - 車両を格納',
        armory = '武器庫',
        enter_armory = '[E] 武器庫',
        finger_scan = '指紋検査',
        scan_fingerprint = '[E] 指紋を検査',
        trash = 'ゴミ',
        trash_enter = '[E] ゴミ箱',
        stash_enter = '[E] ロッカーに入る',
        target_location = '%{firstname} %{lastname}の場所を地図にマークしました。',
        anklet_location = '監視用GPSの場所',
        new_call = '新しい110番通報',
        officer_down = '警察官 %{lastname} | %{callsign} が負傷',
        fine_issued = '違反者に罰金が正常に科されました。',
        received_fine = '中央司法徴収機関は自動的に回収されるべき罰金を回収しました。'
    },
    evidence = {
        red_hands = '赤い手',
        wide_pupils = '広い瞳孔',
        red_eyes = '充血した目',
        weed_smell = '雑草のような匂い',
        gunpowder = '衣服に付着した火薬',
        chemicals = '化学物質の匂い',
        heavy_breathing = '荒い呼吸',
        sweat = '大量の汗',
        handbleed = '手に付着した血',
        confused = '困惑している状態',
        alcohol = 'アルコールのような匂い',
        heavy_alcohol = '非常に強いアルコールの匂い',
        agitated = '興奮状態',
        serial_not_visible = 'シリアルナンバーが見えない',
    },
    menu = {
        garage_title = '警察組織の車庫',
        close = 'メニューを閉じる',
        impound = '押収車両',
        pol_impound = '押収車両保管庫',
        pol_garage = '警察車両車庫',
        pol_armory = '警察武器保管庫',
    },
    email = {
        sender = '中央司法徴収機関',
        subject = '罰金回収について',
        message = '%{value}様宛 %{value2}<br /><br />中央司法徴収機関はあなたが警察から請求された罰金を請求しました。<br />あなたの口座から<strong>$%{value3}</strong>が引き落とされています。<br /><br />よろしくお願いします。<br />中央司法徴収機関代表',
    },
    commands = {
        place_spike = 'スパイクベルトを設置 (警察専用)',
        license_grant = '誰かに免許証を交付する',
        license_revoke = '誰かから免許証を剥奪する',
        place_object = 'オブジェクトを設置/削除 (警察専用)',
        cuff_player = 'プレイヤーを逮捕 (警察専用)',
        escort = 'プレイヤーをエスコート',
        callsign = 'コールサインを指定',
        clear_casign = 'Clear Area of Casings (警察専用)',
        jail_player = 'プレイヤーを投獄 (警察専用)',
        unjail_player = 'プレイヤーを釈放 (警察専用)',
        clearblood = '範囲内の血をクリア (警察専用)',
        seizecash = '現金を押収 (警察専用)',
        softcuff = '優しく逮捕 (警察専用)',
        camera = '監視カメラを視聴 (警察専用)',
        flagplate = 'ナンバープレートに不備を付加 (警察専用)',
        unflagplate = 'ナンバープレートから不備を撤回 (警察専用)',
        plateinfo = 'ナンバープレートを照会 (警察専用)',
        depot = '罰金付きで押収 (警察専用)',
        impound = '車両を押収 (警察専用)',
        paytow = 'レッカー車に支払い (警察専用)',
        paylawyer = '弁護士に支払い (警察, 裁判官専用)',
        anklet = '監視用GPSを装着させる (警察専用)',
        ankletlocation = '監視用GPSの場所を取得',
        removeanklet = '監視用GPSを取り外す (警察専用)',
        drivinglicense = '運転免許証の剥奪 (警察専用)',
        takedna = '対象からDNAを採取 (空の証拠袋が必要) (警察専用)',
        police_report = '警察の報告',
        message_sent = '送信するメッセージ',
        civilian_call = '110番通報',
        emergency_call = '110番通報',
        fine = '罰金'
    },
    progressbar = {
        blood_clear = '血をクリア中',
        bullet_casing = '薬莢を補充中',
        robbing = '逮捕中',
        place_object = 'オブジェクトを設置中',
        remove_object = 'オブジェクトを除去中',
        impound = '車両を押収中',
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
