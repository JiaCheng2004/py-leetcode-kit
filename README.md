# Python LeetCode Kit

Streamline your Python LeetCode problem-solving workflow! This kit provides a shell command to quickly generate a structured directory for new LeetCode problems, including a Python template, a testing helper, and virtual environment activation.

##### Important Note: Designed for Python3.

## Features

*   **Quick Problem Setup**: A `leetcode` command to generate a new problem directory.
*   **Customizable Title & Signature**: Prompts for the problem title and Python function signature.
*   **Automatic Renaming**: The main solution method name in the template's example test call is updated based on your provided signature.
*   **Virtual Environment Integration**: Activates a dedicated Python virtual environment for each problem session.
*   **Organized Structure**: Creates a separate folder for each problem.
*   **Built-in Testing Helper**: Includes `module/test.py` for easily defining and running test cases with colored output and timing.
*   **Path Management**: Automatically adds the project root to `sys.path` in generated files for easy module imports.

## File Structure

Your LeetCode project will be structured like this:

```
py-leetcode-kit/  <-- This is your main project root (e.g., ~/Documents/leetcode)
├── module/
│   ├── leetcode/     <-- Python virtual environment (you'll need to create this)
│   ├── template.py   <-- Template for new problem files
│   └── test.py       <-- Test runner utility
├── 1-two-sum/        <-- Example problem directory
│   └── main.py
├── 2-add-two-numbers/ <-- Example problem directory
│   └── main.py
└── ... (other problem directories)
```

## Prerequisites

*   A Unix-like shell (Bash or Zsh recommended). Tested on Zsh (macOS).
*   Python 3 installed.
*   `git` for cloning (optional, if you host this on GitHub).

## Setup Instructions

1.  **Clone the Repository (or Create Manually):**
    If you've hosted this kit on GitHub:
    ```bash
    git clone https://github.com/JiaCheng2004/py-leetcode-kit.git
    cd py-leetcode-kit
    ```
    Let's assume the root of this kit is now at `py-leetcode-kit`.

2.  **Create the Python Virtual Environment:**
    Navigate to the `module` directory and create a Python virtual environment named `leetcode`, then return to the project root:
    ```bash
    cd module
    python3 -m venv leetcode
    cd ..
    ```
    You can install any common packages you use for LeetCode into this venv later (e.g., `source module/leetcode/bin/activate` then `pip install numpy`).

3.  **Configure the `leetcode` Shell Function:**
    *   Open the `leetcode_setup.sh` file.
    *   **Crucially, edit the `PROJECT_ROOT` variable** inside this `leetcode_setup.sh` file to point to the *absolute path* of your `py-leetcode-kit` directory.
    *   You may modify these variables in your own favor:
    ```bash
    local PROJECT_ROOT="/path/to/your/py-leetcode-kit"      # Absolute path to your LeetCode project
    local MODULE_DIR_NAME="module"                          # Name of your shared module/utility directory
    local VENV_NAME="leetcode"                              # Name of the virtual environment directory
    local TEMPLATE_FILE_NAME="template.py"                  # Name of the problem template file
    ```

4.  **Source the Function in Your Shell Configuration:**
    Copy the leecode function to the end of your shell's configuration file (e.g., `~/.zshrc` for Zsh, `~/.bashrc` for Bash)

5.  **Apply Changes:**
    Open a new terminal window or source your shell configuration file:
    *   For Zsh: `source ~/.zshrc`
    *   For Bash: `source ~/.bashrc`

## Usage

1.  Open your terminal.
2.  Run the `leetcode` command from any directory:
    ```bash
    leetcode
    ```
3.  **Follow the Prompts:**
    *   It will ask for the LeetCode problem title (e.g., "1. Two Sum").
    *   If the problem directory already exists, it will ask if you want to overwrite `main.py`.
        *   If you choose 'n' (no), it will navigate to the existing directory and activate the venv.
    *   If creating/overwriting, it will ask for the Python function signature (e.g., `def twoSum(self, nums: List[int], target: int) -> List[int]:`).
4.  **Directory and Venv:**
    *   A new directory for the problem will be created (or navigated to).
    *   The `module/leetcode` virtual environment will be activated in your current shell session.
    *   `main.py` will be created from `template.py` with placeholders replaced.
5.  **Start Coding:**
    *   Open the generated `main.py` file in your editor.
    *   Implement your solution in the `Solution` class method.
    *   **Add test cases** in the `if __name__ == "__main__":` block using the `test.run()` helper. Remember to update the method name in `test.run(sol.your_method_name, ...)` if it wasn't automatically parsed correctly, and provide the correct input arguments and expected output for each test.
    *   Run your solution and tests:
        ```bash
        python main.py
        ```

### Example Interaction

```
$ leetcode
Paste LeetCode problem title: 42. Trapping Rain Water
Folder: 42-trapping-rain-water (in /Users/yourname/py-leetcode-kit)
Enter Python function signature (e.g., def methodName(self, params) -> RetType)
Signature (default: 'def solve_problem(self, param1: Any, param2: Any) -> Any:'): def trap(self, height: List[int]) -> int:
Using signature: def trap(self, height: List[int]) -> int:
Parsed method name for test: trap
Updated placeholders in '/Users/yourname/py-leetcode-kit/42-trapping-rain-water/main.py'.
Current directory: /Users/yourname/py-leetcode-kit/42-trapping-rain-water
Activating venv...
Venv activated: leetcode

Ready to code for: 42. Trapping Rain Water
Next: open 'main.py', review the test case (arguments & expected output), add more tests, and run 'python main.py'.
(leetcode) $ # Your venv is active, you are in the problem directory
```

## Customization

*   **`module/template.py`**: Modify this file to change the default structure of new `main.py` files.
*   **`module/test.py`**: Enhance the testing helper with more features if needed.
*   **Shell Function (`leetcode_setup.sh`)**:
    *   Adjust default values (`DEFAULT_FUNCTION_SIGNATURE`, `DEFAULT_METHOD_NAME`).
    *   Modify the folder naming convention.

## `test.py` Usage

The `module/test.py` provides a `test.run()` function:

```python
import module.test as test

# Inside if __name__ == "__main__":
sol = Solution()
test.reset() # Resets counters for fresh test runs

# Example 1: Two sum problem
test.run(
    func_to_test=sol.twoSum, # The method from your Solution class
    args=([2, 7, 11, 15], 9), # Arguments as a tuple
    expected_output=[0, 1],
    test_name="Example 1 from LeetCode"
)

# Example 2: Single argument
test.run(
    sol.trap,
    ([0,1,0,2,1,0,1,3,2,1,2,1],), # Note the comma to make it a tuple
    6,
    "Complex rain water case"
)

# Example 3: Floating point comparison
test.run(
    sol.calculate_average,
    ([1.0, 2.0, 3.5],),
    2.16666,
    "Average with floats",
    precision=3 # Compare up to 3 decimal places
)

test.summary() # Prints a summary of passed/failed tests and timing
```

## Contributing

Feel free to fork, modify, and suggest improvements!

---