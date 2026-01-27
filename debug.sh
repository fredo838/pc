echo "--- Terminal.app Configuration Debug ---"
# 1. Get the name of the Default Profile
DEFAULT_PROFILE=$(defaults read com.apple.Terminal "Default Window Settings")
echo "Active Profile: $DEFAULT_PROFILE"

# 2. Check "Use Option as Meta"
# 1 = Enabled, 0 or missing = Disabled
IS_META=$(defaults read com.apple.Terminal "Window Settings" | grep -A 20 "<key>$DEFAULT_PROFILE</key>" | grep "useOptionAsMetaKey" -A 1 | grep -oE "true|false|1|0")
echo "Use Option as Meta: ${IS_META:-false (default)}"

echo -e "\n--- Custom Key Bindings ---"
# 3. Extract Key Map for the active profile
# We look for the 'keyMapBoundKeys' dictionary which stores custom overrides
defaults read com.apple.Terminal "Window Settings" | \
awk "/<key>$DEFAULT_PROFILE<\/key>/,/<key>keyMapBoundKeys<\/key>/" | \
grep -A 100 "keyMapBoundKeys" | grep -m 1 -B 100 "/dict" | \
grep -E "key|string" | sed 's/<key>//g;s/<\/key>//g;s/<string>//g;s/<\/string>//g'

