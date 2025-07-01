#!/bin/bash

# Krix-Term Avatar Generator
# Creates configuration files for all 12 avatars

# Configuration
AVATAR_DIR="$(dirname "$0")/avatars"

# Avatar configurations
declare -A AVATARS=(
    ["01-matsya"]="Matsya The Guide navigation help file_operations"
    ["02-kurma"]="Kurma The_Supporter stability maintenance monitoring"
    ["03-varaha"]="Varaha The_Rescuer recovery backup data"
    ["04-narasimha"]="Narasimha The_Protector security defense protection"
    ["05-vamana"]="Vamana The_Expander resources optimization scaling"
    ["06-parashurama"]="Parashurama The_Warrior cleanup maintenance optimization"
    ["07-rama"]="Rama The_Ruler configuration settings customization"
    ["08-krishna"]="Krishna The_Advisor guidance advice recommendations"
    ["09-buddha"]="Buddha The_Teacher learning documentation education"
    ["10-kalki"]="Kalki The_Future prediction automation advanced_ai"
    ["11-hayagriva"]="Hayagriva The_Knowledge_Keeper information search data"
    ["12-dhanvantari"]="Dhanvantari The_Healer health diagnostics repair"
)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to create avatar config
create_avatar_config() {
    local id=$1
    local name=$2
    local title=${3//_/ }
    local features=${@:4}
    
    local config_file="$AVATAR_DIR/$id/config.json"
    
    # Create config file
    cat > "$config_file" << EOF
{
    "id": "$id",
    "name": "$name",
    "title": "$title",
    "description": "Placeholder for $name avatar - $title",
    "version": "1.0.0",
    "author": "Dharma OS",
    "enabled": true,
    "ai_capable": true,
    "features": ["placeholder"],
    "dependencies": []
}
EOF
    
    # Create a simple ASCII art avatar
    cat > "$AVATAR_DIR/$id/avatar.txt" << EOF
   _,,,   
  (o o)   
-{_${name:0:1}_}-  
  (u u)   
EOF
    
    # Create a simple script placeholder
    mkdir -p "$AVATAR_DIR/$id/scripts"
    cat > "$AVATAR_DIR/$id/scripts/hello.sh" << 'EOF'
#!/bin/bash
# Sample script for $name

echo "Hello from $name - The $title"
echo "This is a placeholder script."
echo "AI capabilities will be available after installation."
EOF
    
    chmod +x "$AVATAR_DIR/$id/scripts/hello.sh"
    
    echo -e "${GREEN}Created${NC} $name ($title) configuration"
}

# Main execution
echo -e "${YELLOW}Generating avatar configurations...${NC}"

# Process each avatar
for avatar_id in "${!AVATARS[@]}"; do
    create_avatar_config "$avatar_id" ${AVATARS[$avatar_id]}
done

echo -e "\n${YELLOW}All avatar configurations generated in:${NC} $AVATAR_DIR"
echo -e "\nTo use these avatars in Krix-Term, copy them to /usr/share/krix-term/avatars/"

# Create a tarball of the avatars
echo -e "\n${YELLOW}Creating avatars archive...${NC}"
tar -czf "$AVATAR_DIR/../krix-term-avatars.tar.gz" -C "$AVATAR_DIR" .
echo -e "Archive created: ${GREEN}$(realpath "$AVATAR_DIR/../krix-term-avatars.tar.gz")${NC}"

exit 0
