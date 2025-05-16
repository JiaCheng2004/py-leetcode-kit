#!/bin/bash
# This file contains the leetcode() shell function.
# It should be sourced by the shell's rc file (e.g., ~/.zshrc or ~/.bashrc).

# ---- LeetCode Setup Function ----
leetcode() {
    # --- Configuration ---
    local PROJECT_ROOT="/path/to/your/py-leetcode-kit"      # Absolute path to your LeetCode project
    local MODULE_DIR_NAME="module"                          # Name of your shared module/utility directory
    local VENV_NAME="leetcode"                              # Name of the virtual environment directory
    local TEMPLATE_FILE_NAME="template.py"                  # Name of the problem template file
    local PLACEHOLDER_TEXT="__PROBLEM_NAME_PLACEHOLDER__"
    local FUNCTION_SIGNATURE_PLACEHOLDER="__FUNCTION_SIGNATURE_PLACEHOLDER__"
    local METHOD_NAME_PLACEHOLDER="__METHOD_NAME_PLACEHOLDER__"
    local DEFAULT_FUNCTION_SIGNATURE="def solve_problem(self, param1: Any, param2: Any) -> Any:"
    local DEFAULT_METHOD_NAME="solve_problem"
    # --- End Configuration ---

    local _leetcode_user_pwd
    _leetcode_user_pwd=$(pwd)

    # Construct full paths based on PROJECT_ROOT
    local MODULE_DIR_PATH="${PROJECT_ROOT}/${MODULE_DIR_NAME}"
    local TEMPLATE_FILE_PATH="${MODULE_DIR_PATH}/${TEMPLATE_FILE_NAME}"

    # --- Initial Validations ---
    if [ ! -d "$PROJECT_ROOT" ]; then
        echo -e "\033[0;31mError: Project root directory '$PROJECT_ROOT' not found. Configure it in the leetcode function.\033[0m"
        return 1
    fi
    if [ ! -d "$MODULE_DIR_PATH" ] || [ ! -f "$TEMPLATE_FILE_PATH" ]; then
        echo -e "\033[0;31mError: Module directory or template file not found. Expected in '${MODULE_DIR_PATH}'.\033[0m"
        return 1
    fi

    # Temporarily change to Project Root for easier relative pathing
    if ! cd "$PROJECT_ROOT"; then
        echo -e "\033[0;31mError: Could not change to project root '$PROJECT_ROOT'.\033[0m"
        return 1
    fi

    # --- Get Problem Title ---
    echo -n "Paste LeetCode problem title: "
    read -r title
    if [ -z "$title" ]; then
        echo -e "\n\033[0;31mError: No title provided.\033[0m"
        cd "$_leetcode_user_pwd"; return 1
    fi

    # --- Generate Folder Name (slug) ---
    local num_part title_part_for_slug slug_title_part folder_name
    num_part=$(echo "$title" | grep -oE '^[0-9]+')
    if [ -n "$num_part" ]; then
        title_part_for_slug=$(echo "$title" | sed -E "s/^${num_part}[\.\s]*//")
    else
        title_part_for_slug="$title"
    fi
    slug_title_part=$(echo "$title_part_for_slug" | tr -s ' ' | tr ' ' '-' | sed -e 's/[^a-zA-Z0-9-]//g' -e 's/-\+/-/g' -e 's/^-*//' -e 's/-*$//' | tr '[:upper:]' '[:lower:]')
    if [ -n "$num_part" ]; then
        folder_name="${num_part}-${slug_title_part}"
    else
        folder_name="${slug_title_part}"
    fi

    if [ -z "$folder_name" ]; then
        echo -e "\033[0;31mError: Could not generate folder name from title: '$title'\033[0m"
        cd "$_leetcode_user_pwd"; return 1
    fi
    echo -e "\033[0;36mFolder: $folder_name (in $PROJECT_ROOT)\033[0m"
    local target_main_file="${PROJECT_ROOT}/${folder_name}/main.py" # Absolute path to main.py

    # --- Handle Existing Directory & File Creation Logic ---
    local file_creation_needed=true
    if [ -d "$folder_name" ]; then # folder_name is relative to current dir (PROJECT_ROOT)
        echo -e "\033[0;33mWarning: Directory '$folder_name' already exists.\033[0m"
        echo -n "Overwrite \033[0;36m${target_main_file}\033[0m with template? (y/N): "
        read -r overwrite_choice
        if [[ ! "$overwrite_choice" =~ ^[Yy]$ ]]; then
            file_creation_needed=false
            echo "Skipping file creation. Navigating to existing directory."
        fi
    fi

    if $file_creation_needed; then
        if [ ! -d "$folder_name" ]; then
            if ! mkdir "$folder_name"; then
                echo -e "\033[0;31mError: Failed to create directory '$PROJECT_ROOT/$folder_name'.\033[0m"
                cd "$_leetcode_user_pwd"; return 1
            fi
        fi
        if ! cp "$TEMPLATE_FILE_PATH" "$target_main_file"; then
            echo -e "\033[0;31mError: Failed to copy template to '$target_main_file'.\033[0m"
            cd "$_leetcode_user_pwd"; return 1
        fi

        # --- Get and Process Function Signature ---
        local user_function_signature_input final_function_signature
        echo -e "Enter Python function signature (e.g., \033[0;32mdef methodName(self, params) -> RetType\033[0m)"
        echo -n "Signature (default: '$DEFAULT_FUNCTION_SIGNATURE'): "
        read -r user_function_signature_input
        if [ -z "$user_function_signature_input" ]; then
            user_function_signature_input="$DEFAULT_FUNCTION_SIGNATURE"
        fi
        
        # Ensure signature starts with "def " if likely omitted
        local temp_sig_for_def_check
        temp_sig_for_def_check=$(echo "$user_function_signature_input" | sed 's/^[[:space:]]*//') 
        if [[ "$temp_sig_for_def_check" != def\ * && "$temp_sig_for_def_check" != "" ]]; then
             user_function_signature_input="def $user_function_signature_input"
        fi

        # Ensure signature ends with a colon
        final_function_signature=$(echo "$user_function_signature_input" | sed 's/[[:space:]]*$//') 
        if [[ "$final_function_signature" != *":" ]]; then
            final_function_signature="${final_function_signature}:"
        fi
        echo -e "\033[0;36mUsing signature: $final_function_signature\033[0m"

        # --- Extract Method Name ---
        local extracted_method_name signature_no_def
        signature_no_def=$(echo "$final_function_signature" | sed -E 's/^[[:space:]]*def[[:space:]]+//')
        extracted_method_name=$(echo "$signature_no_def" | awk -F'(' '{print $1}')
        extracted_method_name=$(echo "$extracted_method_name" | sed 's/[[:space:]]*$//') # Trim trailing spaces

        if [ -z "$extracted_method_name" ]; then
            echo -e "\033[0;33mWarning: Could not parse method name. Input: '$final_function_signature'. Using default '$DEFAULT_METHOD_NAME'.\033[0m"
            extracted_method_name="$DEFAULT_METHOD_NAME"
        else
            echo -e "\033[0;36mParsed method name for test: $extracted_method_name\033[0m"
        fi

        # --- Prepare strings for sed replacement ---
        local title_for_sed signature_for_sed method_name_for_sed
        title_for_sed=$(echo "$title" | sed -e 's/[&/\]/\\&/g')
        signature_for_sed=$(echo "$final_function_signature" | sed -e 's/[&/\]/\\&/g')
        method_name_for_sed=$(echo "$extracted_method_name" | sed -e 's/[&/\]/\\&/g')

        # --- Replace placeholders in the template copy ---
        if sed -i'.bak' \
            -e "s|$PLACEHOLDER_TEXT|$title_for_sed|g" \
            -e "s|$FUNCTION_SIGNATURE_PLACEHOLDER|$signature_for_sed|g" \
            -e "s|$METHOD_NAME_PLACEHOLDER|$method_name_for_sed|g" \
            "$target_main_file"; then
            rm -f "${target_main_file}.bak"
            echo -e "\033[0;32mUpdated placeholders in '$target_main_file'.\033[0m"
        else
            echo -e "\033[0;31mError: Failed to replace placeholders in '$target_main_file'. Check ${target_main_file}.bak\033[0m"
        fi
    fi

    # --- Navigate to Problem Directory and Activate Venv ---
    if ! cd "$folder_name"; then # cd into the problem directory (relative to PROJECT_ROOT)
        echo -e "\033[0;31mError: Failed to cd into '$PROJECT_ROOT/$folder_name'.\033[0m"
        cd "$_leetcode_user_pwd"; return 1 # Go back to user's original directory on failure
    fi
    echo -e "\033[0;32mCurrent directory: $(pwd)\033[0m"

    # Venv activation path is relative from the problem directory
    local venv_activate_script_relative="../${MODULE_DIR_NAME}/${VENV_NAME}/bin/activate"
    if [ -z "$VIRTUAL_ENV" ]; then # Check if a venv is already active
        if [ -f "$venv_activate_script_relative" ]; then
            echo -e "\033[0;36mActivating venv...\033[0m"
            source "$venv_activate_script_relative"
            if [ -n "$VIRTUAL_ENV" ]; then
                echo -e "\033[0;32mVenv activated: $(basename "$VIRTUAL_ENV")\033[0m"
            else
                echo -e "\033[0;31mFailed to activate venv. Please check script and venv path.\033[0m"
            fi
        else
            echo -e "\033[0;33mWarning: Venv activate script not found at '$(pwd)/$venv_activate_script_relative'.\033[0m"
            echo -e "\033[0;33mEnsure venv '${PROJECT_ROOT}/${MODULE_DIR_NAME}/${VENV_NAME}' exists.\033[0m"
        fi
    else
        echo -e "\033[0;36mVenv '$(basename "$VIRTUAL_ENV")' already active.\033[0m"
    fi

    echo ""
    echo -e "\033[1;33mReady to code for: $title\033[0m"
    if $file_creation_needed; then
        echo "Next: open 'main.py', review the test case (arguments & expected output), add more tests, and run 'python main.py'."
    else
        echo "Navigated to existing problem. Review 'main.py'."
    fi

    # Do not cd back to _leetcode_user_pwd here, as the goal is to stay in the problem dir.
    return 0
}
# ---- End LeetCode Setup Function ----