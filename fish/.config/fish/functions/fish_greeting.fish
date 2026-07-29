function _easy_eel_sea_greeting
    set greetings \
        "🐠 Swim in the currents of creativity and passion!" \
        "🐟 Just keep swimming, just keep coding!" \
        "🐡 Puff up with pride for your accomplishments!" \
        "🦈 Take a byte out of those challenges!" \
        "🐙 Channel your inner octopus: calm, adaptable, and resourceful!" \
        "🐚 Shell we conquer the day together?" \
        "🦐 You're shrimply the best!" \
        "🦑 Ink your thoughts into reality!" \
        "🐳 Have a whale of a time today!" \
        "🐋 Whale hello there! Ready to dive into greatness?" \
        "🦞 Claw your way to success!" \
        "🦀 Feeling crabby? Code it out!" \
        "🐬 Ride the waves of wisdom and discovery!" \
        "🦭 Dive headfirst, seal every opportunity!" \
        "🦩 Dip into the waters of opportunity with elegance and flair!" \
        "🐢 Turtley ready to take it slow and crush it today?" \
        "🦪 Let's crack today open and find the pearl inside!" \
        "🌊 Ride the wave of inspiration today!" \
        "🪸 Stay resilient and colorful, come high tide or low!" \
        "⚓ Stay grounded and secure amidst life's storms!" \
        "🌅 Here's to fresh starts and endless horizons. Embrace the day!" \
        "🏖️ Feeling sandy? Find your beach-y zen amidst the chaos!" \
        "☀️ You're solar-powered! Time to shine and out-bright the sun!" \
        "🪼 Dance through challenges, jellyfish style: fluid and fearless!"

    set index (random 1 (count $greetings))
    printf "%s\n" $greetings[$index]
end

function fish_greeting
    if functions -q easy_eel_override_greeting
        easy_eel_override_greeting
    else
        _easy_eel_sea_greeting
    end
end

