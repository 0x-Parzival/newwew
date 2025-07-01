#!/bin/bash
set -euo pipefail

echo "🔍 Validating Phase 5 Success Criteria..."
echo "--------------------------------------"

# Function to check if a command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "❌ Missing required command: $1"
        exit 1
    fi
}

# Check for required commands
check_command python3
check_command jq
check_command ollama

echo "✅ System requirements verified"

# Validate Avatar System Configuration
validate_avatar_config() {
    local config_file="/opt/kalki/avatars/enhanced-avatar-config.json"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ Missing avatar configuration file"
        return 1
    fi
    
    local avatar_count=$(jq '.avatars | length' "$config_file" 2>/dev/null || echo "0")
    if [[ "$avatar_count" -ne 12 ]]; then
        echo "❌ Expected 12 avatars, found $avatar_count"
        return 1
    fi
    
    echo "✅ Found $avatar_count avatars in configuration"
    return 0
}

# Validate AI Models
validate_ai_models() {
    echo "🔍 Checking AI models..."
    local models_ok=1
    
    # Check for required models
    declare -a required_models=(
        "deepseek-r1:8b"
        "dolphin-mixtral:8x7b"
    )
    
    for model in "${required_models[@]}"; do
        if ! ollama list | grep -q "$model"; then
            echo "❌ Missing required model: $model"
            models_ok=0
            continue
        fi
        echo "✅ Found model: $model"
    done
    
    return $((! models_ok))
}

# Validate Avatar Tools
validate_avatar_tools() {
    echo "🔍 Validating avatar tools..."
    local tools_ok=1
    
    # Check for required tool directories
    declare -a required_dirs=(
        "/opt/kalki/avatars/tools/mushak"
        "/opt/kalki/avatars/tools/bunni"
        "/opt/kalki/avatars/tools/nandi"
        "/opt/kalki/avatars/tools/shera"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            echo "❌ Missing tool directory: $dir"
            tools_ok=0
            continue
        fi
        
        # Check for main tool file in each directory
        local tool_name=$(basename "$dir")
        if [[ ! -f "$dir/${tool_name}_tools.py" ]]; then
            echo "❌ Missing main tool file in $dir"
            tools_ok=0
            continue
        fi
        
        echo "✅ Validated tools for: $tool_name"
    done
    
    return $((! tools_ok))
}

# Validate Krix-Term
validate_krix_term() {
    echo "🔍 Validating Krix-Term..."
    
    if [[ ! -f "/usr/bin/krix-term-enhanced" ]]; then
        echo "❌ Krix-Term enhanced not found"
        return 1
    fi
    
    if [[ ! -L "/usr/bin/krix" ]]; then
        echo "❌ Krix symlink not found"
        return 1
    fi
    
    echo "✅ Krix-Term installation verified"
    return 0
}

# Main validation
main() {
    local all_checks_passed=1
    
    # Run all validations
    echo "\n🔹 Validating Avatar Configuration..."
    if ! validate_avatar_config; then
        all_checks_passed=0
    fi
    
    echo "\n🔹 Validating AI Models..."
    if ! validate_ai_models; then
        all_checks_passed=0
    fi
    
    echo "\n🔹 Validating Avatar Tools..."
    if ! validate_avatar_tools; then
        all_checks_passed=0
    fi
    
    echo "\n🔹 Validating Krix-Term..."
    if ! validate_krix_term; then
        all_checks_passed=0
    fi
    
    # Final result
    echo "\n=== Validation Complete ==="
    if [[ $all_checks_passed -eq 1 ]]; then
        echo "✅ All Phase 5 success criteria validated successfully!"
        echo "🚀 The Avatar System is ready for deployment!"
        exit 0
    else
        echo "❌ Some validations failed. Please check the output above."
        echo "💡 Run the individual validation functions to see detailed error messages."
        exit 1
    fi
}

# Run main function
main "$@"
